/* 
 * Values for dragdealer to open/close the nav panel on mobile:
 * vertical: 1 is closed, 0 is open
 * horizontal: 0 is closed, 1 is open
 * (0,1) will close, (1,0) will open
 * 
 */

// So that we can know whenther the site uses a horizontal or vertical slide out nav panel on mobile
var navStyle;
// Default html for the nav panel, so that it can be searched to find the tree structure of the site
var defaultNav;

/*
Use AJAX to load content from url link.
And optionally automatically close the nav panel on load (on mobile).
*/
function loadContent (location,url,shrinkNav) {
	$('#web-help-c2').scrollTop(0);
	$(location).load(url, function( response, status, xhr ) {
		if (status == "error") {
			throw "[AJAX] " + xhr.status + ": " + xhr.statusText;
		}
	});
	shrinkNav = shrinkNav || "yes";
	if (shrinkNav == "yes") {
		setTimeout(function() {dd.setValue(0,1)},100);
	};
};

/* 
 * Slide out sub navigation lists when folders are clicked on
 * 
 * "item" should be the li element with class .folder immediately preceeding the ul element with the list you want to expand
 * 
 * "restrict" can disable the toggle feature of the function
 * Acceptable values for restrict are: "expand" , "collapse" or "no"
 * Expand will only expand the subnav, and won't do anything if already open
 * Collapse will only collapse the subnav, and won't do anything if already closed
 * No will toggle open/close
 * 
 */
function expandSubNav(item,restrict) {

	if (!restrict) {restrict = "no"};

	var div = $(item).next();
	var dd = $(item).next().children()[0];
	var button = $(item).children('.folderButton')[0];

	if ($(div).hasClass("collapsed") && restrict != "collapse") {
		$(div).removeClass("collapsed");
		$(div).addClass("moving");
		$(div).css("display","block");
		$(button).removeClass('collapsed');
		$(button).addClass("expanded");
		button.innerHTML = "-";
		$(dd).animate({'margin-top': '0px'},500,"easeOutQuad",function() {
			$(this).parent().removeClass("moving");
			$(this).parent().addClass("expanded");
		});
	} else if ($(div).hasClass("expanded") && restrict != "expand") {
		$(div).removeClass("expanded");
		$(div).addClass("moving");
		$(button).removeClass('expanded');
		$(button).addClass("collapsed");
		button.innerHTML = "+";
		$(dd).animate({'margin-top': -($(div).height()+15)},500,"easeOutQuad",function() {
			$(this).parent().css("display", "none");
			$(this).parent().removeClass("moving");
			$(this).parent().addClass("collapsed");
		});
	};
};

// Translate the nav panel along with the handle.
// Mobile Only
function slideNav(x,y) {
	// link the handle transformations with the navigation panel transforms
	var trans = document.getElementById('drag-handle').style.webkitTransform;
	document.getElementById('web-help-c1').style.webkitTransform = trans;
	var trans = document.getElementById('drag-handle').style.mozTransform;
	document.getElementById('web-help-c1').style.mozTransform = trans;
	var trans = document.getElementById('drag-handle').style.msTransform;
	document.getElementById('web-help-c1').style.msTransform = trans;
	var trans = document.getElementById('drag-handle').style.oTransform;
	document.getElementById('web-help-c1').style.oTransform = trans;
	var trans = document.getElementById('drag-handle').style.transform;
	document.getElementById('web-help-c1').style.transform = trans;
	
	// Fade out the background as the nav panel slides up.
	var newx = 1-x;
	if (newx > 0.3 && newx < 0.99 && navStyle == 'horiz' ) {
		document.getElementById('web-help-c2').style.opacity = newx;
		document.getElementById('heading').style.opacity = newx;
	} else if (y > 0.3 && y < 0.99 && navStyle == 'vert') {
		document.getElementById('web-help-c2').style.opacity = y;
		document.getElementById('heading').style.opacity = y;
	}
	
	// Make sure that you can't click on the links in the content pane when the nav panel is open
	if (y < 0.7 && navStyle == 'vert') {
		document.getElementById('web-help-c2').style.pointerEvents = 'none';
		document.getElementById('heading').style.pointerEvents = 'none';
	} else if (newx < 0.7 && navStyle == 'horiz') {
		document.getElementById('web-help-c2').style.pointerEvents = 'none';
		document.getElementById('heading').style.pointerEvents = 'none';
	} else {
		document.getElementById('web-help-c2').style.pointerEvents = 'auto';
		document.getElementById('heading').style.pointerEvents = 'auto';
	}
	
	if ($( '#drag-handle' ).hasClass('fade')) {
		if (dd.getValue() != "0,0" && dd.getValue() != "0,1") {
			$( '#drag-handle' ).removeClass('fade');
			$( '#drag-handle' ).addClass('unfade');
		}
	}
}

// Fade the handle when using side nav panel so that the handle doesn't cover the content.
function fadeHandle(x,y) {
	if (navStyle == 'horiz') {
		// 0 is closed, 1 is open
		if (x == 0) {
			setTimeout(function() {
				$( '#drag-handle' ).addClass('fade')
				$( '#drag-handle' ).removeClass('unfade')
			},1200);
		}
	}
}

// Functionality to open and close the nav panel by clicking on the handle.
function openCloseNav() {
	// vertical: 1 is closed, 0 is open
	// horizontal: 0 is closed, 1 is open
	// (0,1) will close, (1,0) will open
	if (dd.getValue() == "1,0" || dd.getValue() == "0,1") {
		dd.setValue(0,0);
	} else if (dd.getValue() == "0,0") {
		dd.setValue(1,1);
	};
}

/*
 * Initialize the navigation panel
 * Collapses all the subnavigation panels and sets display: none
 * 
 */
function navInit() {
	
	var subnavs = $( '.web-help-subnav' );
	
	for (i=subnavs.length-1;i>=0;i--) {
		el = subnavs[i];
		child = $(el).children()[0];
		$(child).css("margin-top",-($(el).height()+15));
		$(el).css('display','none');
		$(el).addClass("collapsed");
	}
	
	var folderbuttons = $( '.folderButton' )
	
	for (j=0;j<folderbuttons.length;j++) {
		el = folderbuttons[j];
		el.innerHTML = "+";
		$(el).addClass("collapsed");
	}
	
	defaultNav = $('.web-help-nav')[0].outerHTML;
}

// Make sure that the nav panel sticks to the handle when the screen is resized.
// Mobile Only
$(window).resize(function() {
	setTimeout(function() {slideNav()},10);
	
	if ($( window ).width() > 600) {
		dd.setValue(0,1);
	};
	
});

/*
 * Instead of using traditional HTTP requests, BWH uses AJAX requests,
 * so we must manually load the content when the hash changes
 * 
 */
window.onhashchange = function() {

	// If the user hasn't searched (normal link)
	if (location.hash.indexOf('q=') == -1) {
	
		var siteloc = location.hash.substring(1);
	
		if (siteloc == "") {
			// Load homepage when no hash
			loadContent("#web-help-c2",'preface.html');
		} else {
			// Load content if link is clicked
			linkClicked = document.activeElement;
			// Don't close the nav panel (on mobile) if the user clicks on a folder
			if ($(linkClicked).hasClass('folder')) {
				loadContent("#web-help-c2",siteloc, 'no');
			} else {
				loadContent("#web-help-c2",siteloc);
			}
		}
		
		// If the user gets to a page somehow other than using the nav panel, auto open navigation tree to the current page
		openNavTree();
		
	} else {
		// If hash starts with #q=, execute search
		$('#q').val(location.hash.substring(3));
		doSearch();
	}
	
	// Google Analytics adding hash changes as new pages
	ga('send', 'pageview', {
		'page': location.pathname + location.hash
	});
	
}

// Remove relative paths from hrefs
function getPathAfterUpFolder(link) {
	if (link.indexOf("./") == -1) {
		return link;
	} else if (link.indexOf("../") == -1) {
		return getPathAfterUpFolder(link.substring(link.indexOf("../")+3));
	} else {
		return getPathAfterUpFolder(link.substring(link.indexOf("./")+2));
	}
}

// Auto expand subnav lists when viewing page
function openNavTree() {
	if (location.hash.indexOf('q=') == -1 && location.hash.length > 1) {
		var href = getPathAfterUpFolder(location.hash.substring(1));
		var el = $('#web-help-c1 span[href*="'+href+'"').parent();
		if (el.length == 0) {return};
		
		// If the loaded page has a child subnav, open it
		if ($(el).next().hasClass("web-help-subnav")) {
			expandSubNav(el,"expand");
		}
		tempel = el;
		
		// Sequentially expand all the subnavs above the loaded page
		while (!$(tempel).parent().hasClass('web-help-nav')) {
			tempel = tempel.parent().parent().prev();
			expandSubNav(tempel, "expand");
		}
		
		// Scroll to the loaded page in the nav panel
		setTimeout(function() {
			$("#web-help-c1").animate({
				scrollTop: ($(el).offset().top - ($(window).height()/2))
			}, 200);
		}, 500);
	}
}

function firstLoad() {
	// Make sure that the search index and search data are loaded
	if (loaded != 2) {
		// If not, check again in 50 ms
		setTimeout(firstLoad, 50);
	} else {
		// Once they're loaded either execute search or load page
		if (location.hash.length > 1) {
			if (location.hash.indexOf('q=') != -1) {
				$('#q').val(location.hash.substring(3));
				doSearch();
			} else {
				loadContent("#web-help-c2",location.hash.substring(1));
				openNavTree();
			}
		} else {
			loadContent("#web-help-c2","preface.html");
		}
	}
}

// Do these once the document's basic structure is set
$( document ).ready(function() {

	$('#heading').html("");
	$('#footer').html("");
	$('#web-help-c2').html("<div class='loading'>Loading...</div>");

	// Load the heading and footer from the user-created heading.html and footer.html files
	var headingLoc = "heading.html";
	$.ajax({url:headingLoc, type:'HEAD',
		error: function() {
			// If there is no heading.html file, display blank header
        	document.getElementById("heading").innerHTML = "";
    	},
    	success: function() {
        	loadContent("#heading",headingLoc,"no");
    	}
	});
	var footerLoc = "footer.html";
	$.ajax({url:footerLoc, type:'HEAD',
		error: function() {
			// If there is no footer.html file, don't display the footer at all.
			$('#footer').css("display","none");
			$('#web-help-c2').css("bottom", "0");
		},
    	success: function() {
        	loadContent("#footer",footerLoc,"no");
    	}
	});
	
	// Determine if the nav bar is horizontal or vertical.
	if ($( '#drag-container' ).width() > 100) {
		navStyle = 'horiz';
	} else {
		navStyle = 'vert';
	};
	
	navInit();
	firstLoad();
	
	// Load the webpage content in the content pane when any ajaxLink is clicked on
	$(document).on("click",".ajaxLink",function (e) {
		e.preventDefault();
		location.hash = $(this).attr('href');
	});
	
	// Expand the subnav lists when a folder is clicked on
	$(document).on("click",".folder",function (e) {
		expandSubNav($(this).parent(), "expand");
	});
	
	// Auto open/close the nav panel (on mobile) when the tab is clicked
	$(document).on("click","#drag-handle",function (e) {
		openCloseNav();
	});
	
	// Load homepage when you click on the heading text
	$(document).on("click","#heading h1", function(e) {
		location.hash = '';
	});
	
	$(document).on("click",".folderButton", function (e) {
		expandSubNav($(this).parent());
	});
	
});

// Add "x" in search bar to clear entry while typing
jQuery(function($) {
	var padding = 25;
	
	function tog(v){return v?'addClass':'removeClass';} 
	
	$(document).on('click', '.clearable', function(){
		if (!$(this).hasClass('x')) {
			$(this).addClass('x');
		}
	})
	
	$(document).on('input', '.clearable', function(){
		$(this)[tog(this.value)]('x');
		}).on('mousemove', '.x', function( e ){
		$(this)[tog(this.offsetWidth-padding < e.clientX-this.getBoundingClientRect().left)]('onX');   
		}).on('click', '.onX', function(){
		$('.clearable').removeClass('x onX').val('');
		$('.typeahead').typeahead('val', '');
		
		/*if ($('#result-num').length != 0) {
			resetSearch();
		}*/
	});
});

// Manually catch AJAX 404 Errors
window.onerror = function(message, file, lineNumber) {
	if (message.indexOf("AJAX") != -1 && message.indexOf("404") != -1) {
		loadContent("#web-help-c2","fallback.html");
	}
	// Let other error function as normal
	return false;
}