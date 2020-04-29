/**
* @File Name          : ServicingRoundRobinQueueable.cls
* @Description        : This Job submit the Contracts for Round Robin Assignment
* @Author             : financial Spectra
**/
public class ServicingRoundRobinQueueable implements Queueable{
    
    private Set<Id> mRecordIds;
    
    public ServicingRoundRobinQueueable(Set<Id> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }
    public void execute(QueueableContext context) {
        try{
            System.debug(loggingLevel.ERROR, mRecordIds);
            fsCore.ActionInput acrInput = new fsCore.ActionInput();
            acrInput.addRecords(mRecordIds);
            ServicingRoundRobinProcessor obj = new ServicingRoundRobinProcessor();
            obj.setInput(acrInput);
            obj.process(); 
            System.debug(loggingLevel.ERROR, 'Success');
        }catch(Exception ex){
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            fsCore.DiagnosticLogUtil.logErrors('ServicingRoundRobinQueueable', 'execute', errorObjectList);
        }
        
    }
    
}