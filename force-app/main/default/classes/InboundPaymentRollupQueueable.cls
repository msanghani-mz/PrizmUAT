/**
 * @File Name          : InboundPaymentRollupQueueable.cls
 * @Description        : This class is called from the TransactionAllocationRollupAction
 *                     : to update the first and second payment information on the contract (Analytics team requirement)
 * @Author             : fSpectra
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/18/2019, 6:39:01 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/22/2019   fSpectra     Initial Version
**/
public class InboundPaymentRollupQueueable implements Queueable{
    
    private Set<Id> mContractIds = new Set<Id>();
    
    public InboundPaymentRollupQueueable(Set<Id> pContractIds) {
        this.mContractIds = pContractIds;
        if(Test.isRunningTest()){
            process();
        }
    }
    public void execute(QueueableContext context) {
        process();
    }  
    public void process() {
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(mContractIds);

        InboundPaymentRollupAction paymentRollupAction = new InboundPaymentRollupAction();
        paymentRollupAction.setInput(acInput);
        paymentRollupAction.process();
        fsCore.ActionOutput acOutput = paymentRollupAction.getOutput();
    }        
    
}