@isTest
Global class GThttpMockCallout implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
      
        System.assertEquals('https://cs27.salesforce.com/services/oauth2/token', request.getEndpoint()); //  http://example.com/example/test
        System.assertEquals('POST', request.getMethod());
     
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{"invoiceList":[{"ImportId":"00T0m00000BjJbzEAF","currentTaskId":"00T22000003MRPvEAO"}]}');
      
       
      if(request.getBody().contains('Access Token'))
        response.setBody('{"access_token":"somevalidAccessToken"}');
    else if(request.getBody().contains('ImportId')){
        response.setBody('{"invoiceList":[{"ImportId":"00T0m00000BjJbzEAF","currentTaskId":"00T22000003MRPvEAO"}]}');
    }   
        response.setStatusCode(200);
        return response; 
    }
    
 }