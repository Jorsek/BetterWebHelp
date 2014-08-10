// If page hasn't loaded before, create index from source and save to local storage
var idx = "";
var indexData = "";
var previousNav = "";
var loaded = 0;
var titles = [];

var substringMatcher = function(strs) {
	return function findMatches(q,cb) {
		var matches, substrRegex;
		
		// an array that will be populated with substring matches
		matches = [];
		
		// regex used to determine if a string contains the substring `q`
		substrRegex = new RegExp(q, 'i');
		
		// iterate through the pool of strings and for any string that
		// contains the substring `q`, add it to the `matches` array
		$.each(strs, function(i, str) {
			if (substrRegex.test(str)) {
				// the typeahead jQuery plugin expects suggestions to a
				// JavaScript object, refer to typeahead docs for more info
				matches.push({ value: str });
			}
		});
		
		cb(matches);
	};
};

function loadIndex() {
	$.get('indexes/lunrIndex.txt', function(data) {
		idx = lunr.Index.load(JSON.parse(data));
		console.log("Index Load Complete.");
		loaded += 1;
	});
	$.get('indexes/lunrData.txt', function(data) {
		indexData = JSON.parse(data);
		console.log("Data Load Complete.");
		loaded += 1;
		
		for (i=0;i<indexData.length-1;i++) {
			titles.push(indexData[i].Title);
		}
				
		$('.typeahead').typeahead({
			hint: true,
			highlight: true,
			minLength: 1
		},{
			name: 'Titles',
			displayKey: 'value',
			source: substringMatcher(titles),
			templates: {
				empty: [
					'<div class="empty-message">',
					'No matching titles',
					'</div>'].join('\n')
			}
		}).on("typeahead:selected", function (event, data, dataset) {
        	doSearch();
    	});
		
	});
}

function doSearch() {
	input = document.getElementById("q").value;
	results = idx.search(input);
	
	if (location.hash.indexOf('#q=') != -1 && location.hash.substring(3) != input) {
		try {
			ga('send', 'event', 'search', 'double-search', {
				'page': location.pathname + location.hash,
				'eventValue': input
			});
		} catch (e) {}
	}
	
	if ($('#result-num').length == 0) {
		previousNav = $('.web-help-nav')[0].outerHTML;
	}
	
/*	output = document.getElementsByClassName("web-help-nav")[0];*/
	output = document.getElementById("web-help-c2");
	var resultString = "<div id='result-set'><li style='font-weight:bold;' id='result-num'>" + ((results.length > 20) ? '20+' : String(results.length)) + " results found for \"" + input + "\"</li>"
	for (x in results) {
		if (x > 20) {break};
		title = indexData[results[x].ref].Title;
		link = indexData[results[x].ref].URI;
		resultString += "<li class='result-element ajaxLink' href=\"" + link + "\"><div class='result-title'>" + title + "</div>";
		
		child = $("span[href='"+link+"']", $(defaultNav))[0];
		el = $(child).parent()[0];
		if (!el) {
			alert("Index not set up Properly.\nPlease recompile your BWH build.");
			return;
		}
		treeComplete = 'false';
		tree = [];
		while (treeComplete != 'true') {

			tree.unshift($(el).children('.navtitle').text());
			
			if (el.parentElement.parentElement != null) {
				el = el.parentElement.parentElement.previousElementSibling;
			} else {treeComplete = 'true'}
		}

		for (t in tree) {
			if (t == 0) {
				resultString += "<div class='result-tree'>" + tree[t];
			} else if (t != tree.length - 1) {
				resultString += " > " + tree[t];
			} else {
				resultString += " > " + tree[t] + "</div>";
			};
		};
		resultString += "</li>";
	}
	output.innerHTML = resultString + "</div>";
	if (location.hash.substring(3) != input) {
		location.hash = 'q=' + input;
	}
	
	console.log('Searched for : ' + input + '. Results:');
	console.log(results);
}

function resetSearch() {
	if (location.hash.indexOf('&q=') != -1) {
		location.hash = locSubstr(location.hash);
	}
	if (previousNav == "") {
		document.getElementsByClassName("web-help-nav")[0].outerHTML = defaultNav;
	} else {
		document.getElementsByClassName("web-help-nav")[0].outerHTML = previousNav;
	}
	
	$('.clearable').val('');
	$('.typeahead').typeahead('val', '');
}

function locSubstr(locstring) {
	return locstring.substring(1, locstring.indexOf("&q="));
}

$( document ).ready( function() {
	loadIndex();
	
	/*$('#q').keyup(function(event) {
		if ($('#q').val().length >= 3) {
			doSearch();
		} else {
			resetSearch();
		}
	});*/
	
	$('#search-button').on('click',function(e) {
		doSearch();
		return false;
	});
	$('#q').on('input',function(e) {
		setTimeout(function() {$('.tt-dropdown-menu').scrollTop(0)}, 10);
	});
});