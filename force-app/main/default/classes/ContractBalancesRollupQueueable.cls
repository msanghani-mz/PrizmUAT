/**
 * @File Name          : ContractBalancesRollupQueueable.cls
 * @Description        : This class is called from the contract Balances trigger
 *                     : to update the balances on the contract
 * @Author             : fSpectra
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/18/2019, 6:19:55 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/22/2019   fSpectra     Initial Version
**/
public class ContractBalancesRollupQueueable implements Queueable{
    
    private Set<Id> mContractIds = new Set<Id>();
    
    public ContractBalancesRollupQueueable(Set<Id> pContractIds) {
        this.mContractIds = pContractIds;
    }
    public void execute(QueueableContext context) {
        system.debug(logginglevel.error,'**** mContractIds :'+mContractIds);
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(mContractIds);

        ContractBalancesRollupAction BalanceRollupAction = new ContractBalancesRollupAction();
        BalanceRollupAction.setInput(acInput);
        BalanceRollupAction.process();
        fsCore.ActionOutput acOutput = BalanceRollupAction.getOutput();
    }    
    
}