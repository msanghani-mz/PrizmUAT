/**
* @File Name          : InitiateSocureQueueable.cls
* @Description        : This Job submit the SocureIDPlusProcessor for the applicant
* @Author             : financial Spectra
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 8/24/2019, 12:13:28 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    8/24/2019, 12:12:55 AM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class InitiateSocureQueueable implements Queueable ,Database.AllowsCallouts{
    
    private Set<Id> mRecordIds;
    
    public InitiateSocureQueueable(Set<Id> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }
    public void execute(QueueableContext context) {
        try{
            System.debug(loggingLevel.ERROR, mRecordIds);
            fsCore.ActionInput acrInput = new fsCore.ActionInput();
            acrInput.addRecords(mRecordIds);
            fsSocr.SocureIDPlusProcessor socureObj = new fsSocr.SocureIDPlusProcessor();
            socureObj.setInput(acrInput);
            socureObj.process(); 
            System.debug(loggingLevel.ERROR, 'Success');
        }catch(Exception ex){
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            fsCore.DiagnosticLogUtil.logErrors('InitiateSocureQueueable', 'execute', errorObjectList);
        }
        
    }
    
}