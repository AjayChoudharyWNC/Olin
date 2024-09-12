({
    afterRender : function(component) {
        this.superAfterRender();
        console.log("after render");
        /*window.addEventListener("message", function(event) {
            console.log("----------------caught");
            console.log(event.data);
        }, false);*/
    }
})