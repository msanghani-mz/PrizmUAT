/**
 * @File Name          : TransactionAllocationRollupQueueable.cls
 * @Description        : This class is called from the contract Balances trigger
 *                     : to update the balances on the contract
 * @Author             : fSpectra
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/18/2019, 6:35:48 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/22/2019   fSpectra     Initial Version
**/
public class TransactionAllocationRollupQueueable implements Queueable{
    
    private Set<Id> mInboundPaymentIds = new Set<Id>();
    
    public TransactionAllocationRollupQueueable(Set<Id> pInboundPaymentIds) {
        this.mInboundPaymentIds = pInboundPaymentIds;
    }
    public void execute(QueueableContext context) {
        process();
    }  
    public void process() {
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(mInboundPaymentIds);

        TransactionAllocationRollupAction TxnRollupAction = new TransactionAllocationRollupAction();
        TxnRollupAction.setInput(acInput);
        TxnRollupAction.process();
        fsCore.ActionOutput acOutput = TxnRollupAction.getOutput();
    }        
    
}