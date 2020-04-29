/**
 * @File Name          : RAMBankAccountVerifyCompQueueable.cls
 * @Description        : This class is called from the BankAccountVerificationTriggerWrapper
 *                     : to initiate the BAV Deposit through RAM
 * @Author             : fSpectra
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/3/2019, 4:32:39 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/22/2019   fSpectra     Initial Version
**/
public class RAMBankAccountVerifyCompQueueable implements Queueable,Database.AllowsCallouts{
    
    private Set<Id> mBAVIds = new Set<Id>();
    
    public RAMBankAccountVerifyCompQueueable(Set<Id> pBAVIds) {
        this.mBAVIds = pBAVIds;
        if(Test.isRunningTest()){
            process();
        }
    }
    public void execute(QueueableContext context) {
        process();
    }  
    public void process() {

        RAMVerifyBankAccountService bavVerifyCompletion = new RAMVerifyBankAccountService();
        bavVerifyCompletion.verifyAccountBAV(mBAVIds);
    }        
    
}