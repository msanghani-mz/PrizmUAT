public class ClientPortal_DocusignSchedularClass implements Schedulable{
    public Set<String> bankAccountIdSet ;
    
    public ClientPortal_DocusignSchedularClass(Set<String> bankAccountIdSet) {
        this.bankAccountIdSet = bankAccountIdSet ;
    }
    private List<fsCore__Bank_Account__c> fetchBankAccounts(Set<String> bankAccountIdSet) {
        List<fsCore__Bank_Account__c> bankAccountList = [Select Id, fsCore__Account_Name__c, Docusign_Status__c
                                                        From fsCore__Bank_Account__c where Id In :bankAccountIdSet ] ;
        return bankAccountList ;
    }
    public void execute(SchedulableContext SC) {
        List<fsCore__Bank_Account__c> bankAccountList = fetchBankAccounts(bankAccountIdSet) ;
        
        System.debug('@@bankAccountIdSet ' + bankAccountIdSet);
        ClientPortal_DocuSignTriggerHndlr.processBankAccountData(bankAccountList) ;
    }
    
    public static String GetCRONExpression(Datetime dt) {
        return (dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }
}