/**
 * @File Name          : InitiateLobQueueable.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/7/2020, 9:58:52 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/7/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class InitiateLobQueueable implements Queueable ,Database.AllowsCallouts{
    
    private Id appId;
    private fsCore__Lending_Application__c app;   
    private Set<Id> mRecordIds;
    
    public InitiateLobQueueable(Set<Id> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }
    public void execute(QueueableContext context) {
        try{
            fsCore.ActionInput acInput = new fsCore.ActionInput();
            appId =  (new list<Id>(mRecordIds))[0];
            app = [Select id , Name, Rejection_Causes__c from fsCore__Lending_Application__c where id =:appId];
            acInput.addRecord(appId);   
            VCLLobRequestService(appId);
            System.debug(loggingLevel.ERROR, 'Success');
            
        }catch(Exception ex){
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            fsCore.DiagnosticLogUtil.logErrors('InitiateLobQueueable', 'execute', errorObjectList);
        }
        
    }
    
    public static void VCLLobRequestService(Id pApplicationId)
    {
        fsCore.ActionOutput aOpt = new fsCore.ActionOutput();
        try{
            VCLLobRequest srvc = new VCLLobRequest(pApplicationId);
            srvc.invoke();
            srvc.saveLogs();
            srvc.saveErrors();
            HttpResponse res = srvc.getResponse();
            System.debug(loggingLevel.ERROR , res.getStatusCode());
            if(res.getStatusCode()== 200){
                aOpt.setMessage('Lob Request has been sent successfully.');
                aOpt.setIsSuccess(true);   
                System.debug(loggingLevel.ERROR ,'checkpoint 1');
            }
            else{
                System.debug(loggingLevel.ERROR ,'checkpoint 2'+res.getStatus());
                aOpt.setMessage(res.getStatus());
                aOpt.setIsSuccess(false);  
            }
        }
        
        catch(Exception e){
            System.debug(loggingLevel.ERROR ,'checkpoint 3');
            System.debug(loggingLevel.ERROR, e.getMessage());
            aOpt.addError(e.getMessage());
        }
        
    }
}