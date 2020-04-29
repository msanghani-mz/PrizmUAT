@RestResource(urlMapping='/setApplicationFinalSettlementReached/*')
global class updateLendingApplicationService {
    @HttpPost
    global static void setApplicationFinalSettlementReached(){
        system.debug('++++++++');
        String jsonStr = '';
        String result = '';
        system.debug(logginglevel.error,'###RestContext.request::'+RestContext.request.requestBody);
        //Checking the type of response based on the keywords
        if (RestContext.request.requestBody != NULL)
            jsonStr = RestContext.request.requestBody.toString();    
        system.debug(logginglevel.error,'###jsonStr::'+jsonStr);
     //   result = CreateopportunityAccount(jsonStr,false);
        RestResponse response = RestContext.response;
       
        String str;
        if(result != ''){
            response.statusCode = 200; 
        }
        else{
            response.statusCode = 400;
        }
    }
}
