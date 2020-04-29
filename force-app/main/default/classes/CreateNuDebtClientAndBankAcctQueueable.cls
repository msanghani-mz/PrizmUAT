/**
 * @File Name          : CreateNuDebtClientAndBankAcctQueueable.cls
 * @Description        : This class is called from the application trigger
 *                     : to create the NuDebt Client
 * @Author             : fSpectra
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/10/2019, 11:28:33 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/22/2019   fSpectra     Initial Version
**/
public class CreateNuDebtClientAndBankAcctQueueable implements Queueable{
    
    private List<fsCore__Lending_Application__c> mLendingApplicationList = new List<fsCore__Lending_Application__c>();
    
    public CreateNuDebtClientAndBankAcctQueueable(List<fsCore__Lending_Application__c> pLendingApplicationList) {
        this.mLendingApplicationList = pLendingApplicationList;
    }
    public CreateNuDebtClientAndBankAcctQueueable(Set<Id> pLendingApplicationIds) {
        Map<Id, fsCore__Lending_Application__c> applicationMap = fsCore.LendingApplicationUtil.getApplications(pLendingApplicationIds);
        this.mLendingApplicationList = applicationMap.values();
    }    
    public void execute(QueueableContext context) {
        Map<String, List<nu_dse__Field_mapping__c>> dataFieldMappingMap  = AccountHandler.returnFieldMappingMap();
        CreateNuDebtClientAndBankAcctHandler handler = new CreateNuDebtClientAndBankAcctHandler(mLendingApplicationList,dataFieldMappingMap);
        handler.process();
        
        if (handler.getProgramIds().size() >0){
            Database.executeBatch(new Batch_UpdateProgramProcessorStatus(handler.getProgramIds()), 1);
        }
    }
    
}