@RestResource(urlMapping='/setApplicationFinalSettlementReached/*')
global class updateLendingApplicationService {
    @HttpPost
    global static void setApplicationFinalSettlementReached(){
        system.debug('++++++++');
        String jsonStr = '';
        Set<String> applicationIdSet = new Set<String>();
        system.debug(logginglevel.error,'###RestContext.request::'+RestContext.request.requestBody);
        //Checking the type of response based on the keywords
        if (RestContext.request.requestBody != NULL)
            jsonStr = RestContext.request.requestBody.toString();    
        system.debug('++++jsonStr++'+jsonStr);
        applicationIdSet = (Set<String>)System.JSON.deserialize(jsonStr, Set<String>.class);
        RestResponse response = RestContext.response;
        system.debug('++++++response+++++'+response);
        system.debug('++++++applicationIdSet+++++'+applicationIdSet);
        if(!applicationIdSet.isEmpty()){
            response.statusCode = 200; 
        }else{
            response.statusCode = 400;
        }
    }

    private static string approveLendingApplications(Set<Id> applicationIdSet) {

        return 'SUCESS';
    }
}