public without sharing class ClientPortal_VCLLoanAgreementPageCntrl {
    
    public String userAccountName {get;set;}
    public Map<String, String> borrowerAddressMap {get; set;}
    
    public ClientPortal_VCLLoanAgreementPageCntrl() {
       User currentUser = [SELECT Id, Name, AccountId, Account.Name, ContactId
                            FROM User
                            WHERE Id = :UserInfo.getUserId()
                            AND IsPortalEnabled = true LIMIT 1] ;
        
        userAccountName = currentUser.Account.Name ;
    }
    
    @AuraEnabled
    public static String fetchUserAccountName() {
        User currentUser = [SELECT Id, Name, AccountId, Account.Name, ContactId
                            FROM User
                            WHERE Id = :UserInfo.getUserId()
                            AND IsPortalEnabled = true LIMIT 1] ;
        
        return currentUser.Account.Name ;
    }
}