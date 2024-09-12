({
    afterRender: function (component, helper) {
        this.superAfterRender();
        var cmp = component.getConcreteComponent().getElements();
         var cmp1 = component.getElements();
        var elements1 = document.getElementsByClassName("modal-container slds-modal__container");
        console.log("elements1.length: " + elements1.length);
        for (var i=0; i<elements1.length; i++) {
            console.log(elements1[i].innerHTML);
        }
        console.log('@@@@@cmp',cmp); 
        //console.log('@@@@@elements1',elements1);
        //console.log('@@@@@cmp',cmp['target']);
        //console.log('@@@@@cmp cmpnt ',cmp['0']);
        // console.log('@@@@@cmp array',cmp[0].div);
        
        //cmpobjectName.property   
        
        for (var i = 0; i < cmp.length; i++) { 
            console.log('value of cmp i@@@@@'+cmp[i]);
        }
        var allEl = cmp[0].childNodes;
        console.log('@@@ale1',allEl);
        /*console.log(allEl.getElementsByClassName('modal-container'));
        console.log(allEl.getElementsByTagName('div'));*/
        //cmp[0].offsetParent.addClass('widePopUp');
    }
})