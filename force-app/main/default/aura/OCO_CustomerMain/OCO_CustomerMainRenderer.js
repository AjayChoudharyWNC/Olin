({
    afterRender: function(component, helper) {
        this.superAfterRender();
        console.log('after rendering: ', document.querySelectorAll("span[id^='lang']"));
    }
})