public class MuleSoftCalloutManager {
    
    public static HttpResponse doClone(Set<String> quoteIds) {
        Mulesoft_CloneEndpoint__c mc = Mulesoft_CloneEndpoint__c.getOrgDefaults();
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        //Mulesoft Additional Auth
        Blob headerValue = Blob.valueOf(mc.username__c+':'+mc.password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        req.setEndpoint(mc.Endpoint__c);
        req.setMethod(mc.Operation__c);
        req.setTimeout((Integer)mc.Timeout__c);
        //Mulesoft Additional Auth
        req.setHeader('Authorization', authorizationHeader);

        req.setHeader('Accept', 'text/plain');
        req.setHeader('Content-type', 'text/plain');
        //req.setHeader('Authorization', mc.Authentication__c); //BASIC?
        List<String> l=new List<String>();
        l.addAll(quoteIds);

        String jsonBody = String.join(l, ','); //JSON.serialize(quoteds);
        if(new Set<String> {'POST', 'PUT'}.contains(mc.Operation__c)) {
            req.setBody(
                //TODO: Process body here
                jsonBody
            );
        }
        System.debug(jsonBody);
        System.debug('' + req);


        HttpResponse res;
        if(!Test.isRunningTest()) res = h.send(req);
        //TODO: do error handling
        return res;
    }
    
    public static HttpResponse doCloneandSubmit(Set<String> quoteIds) {
        Mulesoft_CloneEndpoint__c mc = Mulesoft_CloneEndpoint__c.getOrgDefaults();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //Mulesoft Additional Auth
        Blob headerValue = Blob.valueOf(mc.username__c+':'+mc.password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

        req.setEndpoint(mc.Submit_Endpoint__c);
        req.setMethod(mc.Operation__c);
        req.setTimeout((Integer)mc.Timeout__c);
        
        req.setHeader('Accept', 'text/plain');
        req.setHeader('Content-type', 'text/plain');
        //req.setHeader('Authorization', mc.Authentication__c); //BASIC?
        List<String> l=new List<String>();
        l.addAll(quoteIds);

        String jsonBody = String.join(l, ','); //JSON.serialize(quoteds);
        if(new Set<String> {'POST', 'PUT'}.contains(mc.Operation__c)) {
            req.setBody(
                //TODO: Process body here
                jsonBody
            );
        }
        System.debug(jsonBody);
        System.debug('' + req);


        HttpResponse res;
        if(!Test.isRunningTest()) res = h.send(req);
        //TODO: do error handling
        return res;
    }
    
    
    public static HttpResponse doUpdate(Set<String> quoteIds) {
        
        //TODO: Update based on clone operation
        Mulesoft_CloneEndpoint__c mc = Mulesoft_CloneEndpoint__c.getOrgDefaults();
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        //Mulesoft Additional Auth
        Blob headerValue = Blob.valueOf(mc.username__c+':'+mc.password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

        req.setEndpoint(mc.Endpoint__c);
        req.setMethod(mc.Operation__c);
        req.setTimeout((Integer)mc.Timeout__c);
        
        req.setHeader('Accept', 'text/plain');
        req.setHeader('Content-type', 'text/plain');
        //req.setHeader('Authorization', mc.Authentication__c); //BASIC?
        List<String> l=new List<String>();
        l.addAll(quoteIds);

        String jsonBody = String.join(l, ','); //JSON.serialize(quoteds);
        if(new Set<String> {'POST', 'PUT'}.contains(mc.Operation__c)) {
            req.setBody(
                jsonBody
            );
        }
        System.debug(jsonBody);
        System.debug('' + req);


        HttpResponse res;
        if(!Test.isRunningTest()) res = h.send(req);
        return res;
    }
    
    public static HttpResponse doContractSubmit(Set<String> quoteIds) {
        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        //Mulesoft Additional Auth
        Blob headerValue = Blob.valueOf(mc.username__c+':'+mc.password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        req.setEndpoint(mc.Endpoint__c);
        req.setMethod(mc.Operation__c);
        req.setTimeout((Integer)mc.Timeout__c);
        
        req.setHeader('Accept', 'text/plain');
        req.setHeader('Content-type', 'text/plain');
        //req.setHeader('Authorization', mc.Authentication__c); //BASIC?
        List<String> l=new List<String>();
        l.addAll(quoteIds);

        String jsonBody = String.join(l, ','); //JSON.serialize(quoteds);
        if(new Set<String> {'POST', 'PUT'}.contains(mc.Operation__c)) {
            req.setBody(
                //TODO: Process body here
                jsonBody
            );
        }
        System.debug(jsonBody);
        System.debug('' + req);


        HttpResponse res;
        if(!Test.isRunningTest()) res = h.send(req);
        //TODO: do error handling
        return res;
    }

}