/**
 * @File Name          : ValidateStageAndMoveNextStageQueueable.cls
 * @Description        : This class is used to validate the current stage and move to the next stage.
 *                     : 
 * @Author             : fSpectra
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/10/2019, 11:28:33 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/22/2019   fSpectra     Initial Version
**/
public class ValidateStageAndMoveNextStageQueueable implements Queueable{
    
    private Set<Id> mApplicationIds;
    
    public ValidateStageAndMoveNextStageQueueable(Set<Id> pApplicationIds) {
        this.mApplicationIds = pApplicationIds;
    }
  
    public void execute(QueueableContext context) {
        if (mApplicationIds.size()>0){
            System.debug(loggingLevel.Error , 'inside execute');
              ValidateStageAndMoveNextStageProcessor.process(mApplicationIds);
        }
       
    }
    
}