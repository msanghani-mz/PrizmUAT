/**
* @File Name          : UpdateVelocifyQueueable.cls
* @Description        : This Job is to Update Velocify when Status is updated in Prizm (Decline , Withdrawn) SW-91,93
* @Author             : financial Spectra
**/
public class UpdateVelocifyQueueable implements Queueable ,Database.AllowsCallouts{
    
    private Set<Id> mApplicationIds;
    
    public UpdateVelocifyQueueable(Set<Id> pApplicationIds) {
        this.mApplicationIds = pApplicationIds;
    }
    public void execute(QueueableContext context) {
        try{
            System.debug(loggingLevel.ERROR, 'Application Ids size :'+mApplicationIds.size());
            
            for (Id applicationId: mApplicationIds){
                System.debug(loggingLevel.ERROR, 'Application Id :'+applicationId);
                VCLChangeStatusService srvc = new VCLChangeStatusService(applicationID);
                srvc.invoke();
                srvc.saveLogs();
                srvc.saveErrors();
            }
            System.debug(loggingLevel.ERROR, 'Success');
        }catch(Exception ex){
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            fsCore.DiagnosticLogUtil.logErrors('UpdateVelocifyQueueable', 'execute', errorObjectList);
        }
        
    }
    
}