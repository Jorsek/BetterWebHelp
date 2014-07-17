var queries = {};
try {
	$.each(document.location.search.substr(1).split('&'),function(c,q){
		var i = q.split('=');
		queries[i[0].toString()] = i[1].toString();
	});
} catch (err) {}