/**
* @File Name          : OpportunityNuDebtStatusUpdateQueueable.cls
* @Description        : This Job is used to call UpdateOpportunityStatus for the class OpportunityRoundRobinAssignmentHandler
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
public class OpportunityNuDebtStatusUpdateQueueable implements Queueable ,Database.AllowsCallouts{
    
    private String mOpportunityList;
    
    public OpportunityNuDebtStatusUpdateQueueable(String OpportunityList) {
        this.mOpportunityList = OpportunityList;
    }
    public void execute(QueueableContext context) {
        try{
            System.debug(loggingLevel.ERROR, mOpportunityList);
            OpportunityRoundRobinAssignmentHandler.UpdateOpportunityStatus(mOpportunityList);
            System.debug(loggingLevel.ERROR, 'Success');
        }catch(Exception ex){
          errors(ex.getMessage(),ex.getStackTraceString());
        }
        
    }
    public void errors(String pMessage, String pStackTrace){
          fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(pMessage);
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(pStackTrace);
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            fsCore.DiagnosticLogUtil.logErrors('InitiateSocureQueueable', 'execute', errorObjectList);
    }
    
}