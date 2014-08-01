// vertical: 1 is closed, 0 is open
// horizontal: 0 is closed, 1 is open
// (0,1) will close, (1,0) will open

var navStyle;
var defaultNav;

/*
Use AJAX to load content from url link.
And optionally automatically close the nav panel on load.
*/
function loadContent (location,url,shrinkNav) {
	$('#web-help-c2').scrollTop(0);
	$(location).load(url);
	shrinkNav = shrinkNav || "yes";
	if (shrinkNav == "yes") {
		setTimeout(function() {dd.setValue(0,1)},100);
	};
};

function expandSubNav(item,restrict) {

// Acceptable values for restrict are: "expand" , "collapse" or "no"
// Expand will only expand the subnav, and won't do anything if already open
// Collapse will only collapse the subnav, and won't do anything if already closed
	if (!restrict) {restrict = "no"};

	var div = $(item).next();
	var dd = $(item).next().children()[0];

	if ($(div).hasClass("collapsed") && restrict != "collapse") {
		$(div).removeClass("collapsed");
		$(div).addClass("moving");
		$(div).css("display","block");
		$(dd).animate({'margin-top': '0px'},500,"easeOutQuad",function() {
			$(this).parent().removeClass("moving");
			$(this).parent().addClass("expanded");
		});
	} else if ($(div).hasClass("expanded") && restrict != "expand") {
		$(div).removeClass("expanded");
		$(div).addClass("moving");
		$(dd).animate({'margin-top': -($(div).height()+15)},500,"easeOutQuad",function() {
			$(this).parent().css("display", "none");
			$(this).parent().removeClass("moving");
			$(this).parent().addClass("collapsed");
		});
	};
};

// Translate the nav panel along with the handle.
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

function navInit() {
	
	var subnavs = $( '.web-help-subnav' );
	
	for (i=subnavs.length-1;i>=0;i--) {
		el = subnavs[i];
		child = $(el).children()[0];
		$(child).css("margin-top",-($(el).height()+15));
		$(el).css('display','none');
		$(el).addClass("collapsed");
	}
	
	defaultNav = $('.web-help-nav')[0].outerHTML;
}

// Make sure that the nav panel sticks to the handle when the screen is resized.
$(window).resize(function() {
	setTimeout(function() {slideNav()},10);
	
	if ($( window ).width() > 600) {
		dd.setValue(0,1);
	};
	
});

window.onhashchange = function() {

	if (location.hash.indexOf('q=') == -1) {
	
		var siteloc = location.hash.substring(1);
	
		if (siteloc == "") {
			loadContent("#web-help-c2",'preface.html');
		} else {
			linkClicked = document.activeElement;
			if ($(linkClicked).hasClass('folder')) {
				loadContent("#web-help-c2",siteloc, 'no');
			} else {
				loadContent("#web-help-c2",siteloc);
			}
		}
		
		openNavTree();
		
	} else {
		$('#q').val(location.hash.substring(3));
		doSearch();
	}
	
	ga('send', 'pageview', {
		'page': location.pathname + location.hash
	});
	
}

function getPathAfterUpFolder(link) {
	if (link.indexOf("./") == -1) {
		return link;
	} else if (link.indexOf("../") == -1) {
		return getPathAfterUpFolder(link.substring(link.indexOf("../")+3));
	} else {
		return getPathAfterUpFolder(link.substring(link.indexOf("./")+2));
	}
}

function openNavTree() {
	if (location.hash.indexOf('q=') == -1 && location.hash.length > 1) {
		var href = getPathAfterUpFolder(location.hash.substring(1));
		var el = $('#web-help-c1 li[href*="'+href+'"');
		if ($(el).next().hasClass("web-help-subnav")) {
			expandSubNav(el,"expand");
		}
		tempel = el;
		while (!$(tempel).parent().hasClass('web-help-nav')) {
			tempel = tempel.parent().parent().prev();
			expandSubNav(tempel, "expand");
		}
		setTimeout(function() {
			$("#web-help-c1").animate({
				scrollTop: ($(el).offset().top - ($(window).height()/2))
			}, 200);
		}, 500);
	}
}

function firstLoad() {
	if (loaded != 2) {
		setTimeout(firstLoad, 50);
	} else {
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

/*
When the document is ready, check to see if the user has set a heading file,
and if so, load it into the heading div on the page.
*/
$( document ).ready(function() {
	var headingLoc = "heading.html";
	$.ajax({url:headingLoc, type:'HEAD',
		error: function() {
        	document.getElementById("heading").innerHTML = "";
    	},
    	success: function() {
        	loadContent("#heading",headingLoc,"no");
    	}
	});
	var footerLoc = "footer.html";
	$.ajax({url:footerLoc, type:'HEAD',
		error: function() {
			$('#footer').css("display","none");
		},
    	success: function() {
        	loadContent("#footer",footerLoc,"no");
    	}
	});
	
	navInit();
	
	// Determine if the nav bar is horizontal or vertical.
	if ($( '#drag-container' ).width() > 100) {
		navStyle = 'horiz';
	} else {
		navStyle = 'vert';
	};
	
	firstLoad();
	
	$(document).on("click",".ajaxLink",function (e) {
		e.preventDefault();
		location.hash = $(this).attr('href');
	});
	
	$(document).on("click",".folder",function (e) {
		expandSubNav(this);
	});
	
	$(document).on("click","#drag-handle",function (e) {
		openCloseNav();
	});
	
	$(document).on("click","#heading h1", function(e) {
		location.hash = '';
	});
	
});

// Add "x" in search bar to clear entry while typing.
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