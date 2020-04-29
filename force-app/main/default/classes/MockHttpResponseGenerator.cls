@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://lob-qa-lsw.azurewebsites.net/lobapi', req.getEndpoint());
        System.assertEquals('PUT', req.getMethod());

        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"phone":"9899995247","name":"John Smith","mailing_street":"254 Eves Street","mailing_state":"New Jersey","mailing_postal_code":"07307","mailing_country":"US","mailing_city":"Jersey City","loanamount":"16000.00","fico":"600","external_reasons":"<p><strong>External Reason(s)</strong></p><ul><li>Limited credit experience</li><li>Income insufficient for amount of credit requested</li></ul>","decline_cause":null,"creditscore":"scorefactor1;scorefactor2","credit_pulldate":"2020-03-25","application_date":"2020-03-25"}');
        response.setStatusCode(200);
        return response;
          
    }  
    
}