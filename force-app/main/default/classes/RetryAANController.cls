public class RetryAANController {
    @AuraEnabled
    public static String retryLobService(id pAppId){
        fsCore.ActionOutput acOpt = new fsCore.ActionOutput();
        try{
            fsCore__Lending_Application__c application  = [SELECT Id,Retry_Batch__c,Lob_Response_Status__c,Lob_Response_Error__c,Lob_Response_Message__c FROM fsCore__Lending_Application__c WHERE id=:pAppId ];
            if(application.Lob_Response_Status__c)
            {
                acOpt.setMessage('Letter has already been Sent');
                acOpt.setIsSuccess(false); 
                 acOpt.addError('Letter has already been Sent');
            }
            else{
            VCLLobRequest srvc = new VCLLobRequest(pAppId);
            srvc.invoke();
            HttpResponse res = srvc.getResponse();
            System.debug(loggingLevel.ERROR , res.getStatusCode());
            if(res.getStatusCode()== 200){
                fsCore__Lending_Application__c app = [SELECT Id,Retry_Batch__c,Lob_Response_Status__c,Lob_Response_Error__c,Lob_Response_Message__c FROM fsCore__Lending_Application__c WHERE id=:pAppId ];
                if(app.Retry_Batch__c == false)
                {
                acOpt.setMessage('AAN Re-attempted');
                acOpt.setIsSuccess(true);   
                System.debug(loggingLevel.ERROR ,'AAN Re-attempted');
                 }
                else  if(app.Retry_Batch__c )
                {
                acOpt.setMessage(app.Lob_Response_Error__c);
                acOpt.setIsSuccess(false); 
                acOpt.addError(app.Lob_Response_Error__c);
                }
                
            }
                else{
                System.debug(loggingLevel.ERROR ,'AAN 2'+res.getStatus());
                acOpt.setMessage(res.getStatus());
                acOpt.setIsSuccess(false);  
            }
         }
        }
        catch(Exception e){
            System.debug(loggingLevel.ERROR ,'AAN 3');
            System.debug(loggingLevel.ERROR, e.getMessage());
            acOpt.addError(e.getMessage());
           
        }  
        return acOpt.getJSONString();
    
}
}