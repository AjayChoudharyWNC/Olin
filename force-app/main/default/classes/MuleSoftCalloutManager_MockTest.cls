@isTest
global class MuleSoftCalloutManager_MockTest implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}