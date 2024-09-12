({   
    toggleSelect: function(component,event,helper){
        var tc = event.currentTarget.checked;
        component.set('v.logo',tc);
        component.set('v.sta',tc);
        component.set('v.exes',tc);
        component.set('v.apro',tc);
        component.set('v.asg',tc);
        component.set('v.ets',tc);
        component.set('v.cps',tc);
        component.set('v.cbs',tc);
        component.set('v.cana',tc);
        component.set('v.swot',tc);
        component.set('v.apt',tc);
        component.set('v.kc',tc);
        component.set('v.cr',tc);
        component.set('v.mp',tc);
    },
    
    showPDF: function(component,event,helper){
        var s = '';
        s += component.get('v.logo') == true ? 't': 'f';
        s += component.get('v.sta') == true ? 't': 'f';
        s += component.get('v.exes') == true ? 't': 'f';
        s += component.get('v.apro') == true ? 't': 'f';
        s += component.get('v.asg') == true ? 't': 'f';
        s += component.get('v.ets') == true ? 't': 'f';
        s += component.get('v.cps') == true ? 't': 'f';
        s += component.get('v.cbs') == true ? 't': 'f';
        s += component.get('v.cana') == true ? 't': 'f';
        s += component.get('v.swot') == true ? 't': 'f';
        s += component.get('v.apt') == true ? 't': 'f';
        s += component.get('v.kc') == true ? 't': 'f';
        s += component.get('v.cr') == true ? 't': 'f';
        s += component.get('v.mp') == true ? 't': 'f';
        console.log(s);
        component.set('v.sec',s);
    }
})