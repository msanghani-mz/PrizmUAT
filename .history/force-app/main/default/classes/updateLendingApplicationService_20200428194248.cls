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
            approveLendingApplications(applicationIdSet);
        }
    }

    private static void approveLendingApplications(Set<Id> applicationIdSet) {

        List<fsCore__Lending_Application__c> applicationsToUpdate = new List<fsCore__Lending_Application__c>();
        for (fsCore__Lending_Application__c application: [Select Id, fsCore__Application_Status__c from fsCore__Lending_Application__c where Id IN :applicationIdSet and fsCore__Application_Status__c != :SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED]) {
            application.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            applicationsToUpdate.add(application);
        }
        if (!applicationsToUpdate.isEmpty()) {
            update applicationsToUpdate;
            List<Database.UpsertResult> applicationResultList = Database.upsert(applicationsToUpdate);
            List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>();
            for (Database.UpsertResult result : applicationResultList) {
            
                if (result.isSuccess() == FALSE) {
                    
                    nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                    List<String> errMsgs = new List<String>();
                                        
                    for (Database.Error err: result.getErrors()) {
                        errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                    }
                    
                    errLog.nu_dse__Class_Method__c = 'updateLendingApplicationService.approveLendingApplications';
                    errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                    errLog.nu_dse__User_Context__c = UserInfo.getName();
                    errLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                    
                    errLogList.add(errLog);
                }
            }
            if (!errLogList.isEmpty()) {
                insert errLogList;
            }
        }
    }
}
