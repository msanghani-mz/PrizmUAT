@RestResource(urlMapping='/setApplicationFinalSettlementReached/*')
global class updateLendingApplicationService {
    @HttpPost
    global static void setApplicationFinalSettlementReached(){
        system.debug('++++++++');
        String jsonStr = '';
        Set<Id> applicationIdSet = new Set<Id>();
        system.debug(logginglevel.error,'###RestContext.request::'+RestContext.request.requestBody);
        //Checking the type of response based on the keywords
        if (RestContext.request.requestBody != NULL)
            jsonStr = RestContext.request.requestBody.toString();    
        system.debug(logginglevel.error,'###jsonStr::'+jsonStr);
        applicationIdSet = JSON.deserialize(jsonStr,  Set<Id>.class);
        RestResponse response = RestContext.response;
        system.debug('++++++response+++++'+response);
        String str;
        if(!applicationIdSet.isEmpty()){
            response.statusCode = 200; 
        }else{
            response.statusCode = 400;
        }
    }
}
