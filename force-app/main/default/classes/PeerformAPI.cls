public with sharing class PeerformAPI{

    private static PeerformAPI self;
    private static String urlAuthService = 'AuthenticationServices.svc/rest/';
    private static String urlService = 'SalesforceService.svc/rest/';
    private static String cookieAuth;
    
    // Builds a login request and returns the req
    public static String LoginAuth(Boolean test)
    {
        http h = new Http();
        HttpRequest lreq = new HttpRequest();
        HttpResponse lres = new HttpResponse();

        lreq.setHeader('Content-Type','application/json; charset=utf-8');
        lreq.setMethod('POST');
        lreq.setEndpoint(getAPIUrl() + urlAuthService + 'Login');
        lreq.setBody('{"username":"'+getUserName()+'", "password":"'+getAuthenticationId()+'", "customCredential":"'+null+'", "isPersistent":"' + true + '", "setCookie":"' + true + '"}');

        try {
            if (!test) {
                lres = h.send(lreq);
                return lres.getHeader('Set-Cookie');
            }
        }catch(System.CalloutException e) {
            System.debug(lres.toString());
        }
        return 'testvalue';
    }

    // Builds a generic service call and returns the Request
    public static void ServiceCall(String requestType, String request, String data, Boolean test)
    {
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        
        req.setHeader('Content-Type','application/json; charset=utf-8');
        req.setHeader('Accept', 'application/json; charset=utf-8');
        req.setHeader('Cookie', LoginAuth(test));
        req.setTimeout(20000);
        
        String endpoint = getAPIUrl() + urlService + request;
        req.setMethod(requestType);
        req.setEndpoint(endpoint);
        if(data != null)
            req.setBody(data);
        
        try {
            if (!test) {
                res = h.send(req);
                System.debug(res.toString());
            }
        }catch(System.CalloutException e) {
            System.debug(res.toString());
        }
    }
    @future (callout=true)
    public static void UpdateFlagStatus(string flagId, String flagStatus, Boolean test)
    {
        System.Debug(flagId + ' ' + flagStatus);
        String request = 'Flags/' + flagId + '/FlagStatus/';
        Integer flagStatusId = 0;
        if(flagStatus.toLowerCase().equals('pending')){
            flagStatusId = 1;
        }
        
        if(flagStatus.toLowerCase().equals('resolved')){
            flagStatusId = 2;
        }
        
        if(flagStatus.toLowerCase().equals('not resolved')){
            flagStatusId = 3;
        }
        request = request + string.valueOf(flagStatusId);
        ServiceCall('GET', request, null, test);
    }
    @future (callout=true)
    public static void UpdateLoanContentStatus(string loanId, String loanContentStatus, Boolean test)
    {
        System.Debug(loanId + ' ' + loanContentStatus);
        String request = 'Loans/' + loanId + '/LoanContentStatus/';
        Integer loanContentStatusId = 0;
        if(loanContentStatus.toLowerCase().equals('none')){
            loanContentStatusId = 1;
        }
        if(loanContentStatus.toLowerCase().equals('pending verification')){
            loanContentStatusId = 2;
        }
        if(loanContentStatus.toLowerCase().equals('accepted')){
            loanContentStatusId = 3;
        }
        if(loanContentStatus.toLowerCase().equals('rejected')){
            loanContentStatusId = 4;
        }
        if(loanContentStatus.toLowerCase().equals('rejected title')){
            loanContentStatusId = 7;
        }
        if(loanContentStatus.toLowerCase().equals('rejected description')){
            loanContentStatusId = 8;
        }
        request = request + string.valueOf(loanContentStatusId);
        ServiceCall('GET',  request, null, test);
    }
    @future (callout=true)
    public static void RunTask(string taskId, Boolean test)
    {
        ServiceCall('POST', 'Tasks', '{"id":"' + taskId + '"}', test);
    }
    @future (callout=true)
    public static void UpdateLoanVerificationStatusItem(string loanId, Integer questionId, string status, string comment, Boolean test)
    {
        System.debug(loanId + ' ' + questionId + ' ' + status + ' ' + comment);
        Integer statusId = -2;
        
        if(status.toLowerCase().equals('pending')){
            statusId = 0;
        }
        
        if(status.toLowerCase().equals('verified')){
            statusId = 1;
        }
        
        if(status.toLowerCase().equals('error')){
            statusId = 2;
        }
        
        if (statusId != -2){
            Datetime d = System.now();
            String data = '{"Comment":"'+comment+'", "LoanCheckingId":"'+loanId+'", "LoanCheckingQuestionId":"'+questionId+'", "Status":"' + statusId + '", "UpdateDate":"' + toWCFFormat(d) + '"}';
            ServiceCall('PUT', 'LoanCheckingAnswers', data, test);
        }
    }
    @future (callout=true)
    public static void UpdateHardPullStatus(string loanId, string hardPullStatus, Boolean test)
    {
        System.Debug(loanId + ' ' + hardPullStatus);
        String request = 'Loans/' + loanId + '/HardPullStatus/';
        Integer hardpullStatusId = 0;
        if(hardPullStatus.toLowerCase().equals('pending')){
            hardpullStatusId = 0;
        }
        if(hardPullStatus.toLowerCase().equals('verified')){
            hardpullStatusId = 1;
        }
        if(hardPullStatus.toLowerCase().equals('error')){
            hardpullStatusId = 2;
        }
        request = request + string.valueOf(hardpullStatusId);
        ServiceCall('GET',  request, null, test);
    }
    @future (callout=true)
    public static void UpdateIncomeStatus(string LoanId, string incomeStatus, Boolean test)
    {
        System.Debug(loanId + ' ' + incomeStatus); 
        String request = 'Loans/' + loanId + '/VerifyIncome/';
        Integer incomeStatusId = 0;
        if(incomeStatus.toLowerCase().equals('pending')){
            incomeStatusId = 0;
        }
        if(incomeStatus.toLowerCase().equals('verified')){
            incomeStatusId = 1;
        }
        if(incomeStatus.toLowerCase().equals('error')){
            incomeStatusId = 2;
        }
        request = request + string.valueOf(incomeStatusId);
        ServiceCall('GET',  request, null, test);   
    }
    @future (callout=true)
    public static void UpdateIDTheft(string UserId, Boolean theftStatus, Boolean test)
    {
        System.Debug(UserId + ' ' + theftStatus); 
        String request = 'Users/' + UserId + '/TheftStatus/';
        
        request = request + string.valueOf(theftStatus);
        ServiceCall('GET',  request, null, test);   
    }

    // Tools
    public static String getAPIUrl(){
        if(isSandBox())
            return 'https://www.peerforming.com:4430/';
        else
            return 'https://www.peerform.com:4430/';
    }
    public static String getAuthenticationId(){
        String idUser = UserInfo.getUserId();
        String authenticationId = [SELECT Peerform__c FROM User WHERE Id =:idUser][0].Peerform__C;
        return authenticationId;
    }
    public static String getUserName(){
        return UserInfo.getUserName().replace('.pfsandbox', '');
    }
    public static Boolean isSandBox(){
        String organisationId = UserInfo.getOrganizationId();
        if(organisationId == '00Dd0000000eeaCEAQ')
            return false;
        else
            return true;
    }
    private static String toWCFFormat(Datetime d){
        String result = '/Date(' + d.getTime() + ')/';
        return result;
    }
}