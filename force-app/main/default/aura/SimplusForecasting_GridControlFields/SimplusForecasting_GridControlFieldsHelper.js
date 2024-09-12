({
	sortByOrder : function(array, key) {
		return array.sort(function(a, b) {
			var x = a["sortOrder"]; var y = b["sortOrder"];
			return ((x < y) ? -1 : ((x > y) ? 1 : 0));
		});
	}
})