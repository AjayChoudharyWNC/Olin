({
	expandTest : function(component, event, helper) {
		/*console.log(component.find("formulaBase"));
		console.log(component.find("formulaBase").parentNode);
		var tgt = component.find("formulaBase").getElement();

		var safety = 0;
		console.log(tgt, tgt.className);

		while(tgt.className.indexOf("modal-container") < 0) {
			console.log(tgt.className, tgt.classList);
			tgt = tgt.parentNode;

			while(!tgt.parentNode) tgt = tgt.body.parentNode;

			safety += 1;
			if(safety > 20) break;
		}
		console.log(tgt);*/
		var r = document.getElementsByClassName("modal-container");
		console.log(r);
	}
})