public without sharing class ClientPortal_VCLBankACHPageCntrl {
    
    private static final String VCL_PORTFOLIO_NAME = 'VCL';
    public Account applicantRecord {get;set;}
    public Account coApplicantRecord {get;set;}
    public BankACHWrapper userBankAccount {get;set;}
    // public Boolean isCoApplicantExists {get;set;}
    public Map<String, String> bankAddressMap {get;set;}
    public Map<String, String> appAddressMap {get;set;}
    // public Map<String, String> coAppAddressMap {get;set;}
    //public fsCore__Lending_Application_Pricing_Offer__c pricingOffer {get; set;}
    private static String userAccountId ;
    private static String bankAccountSTR ;
    
    public ClientPortal_VCLBankACHPageCntrl() {
        Id lendingApplnId = apexpages.currentpage().getparameters().get('lendingAppId');
        bankAccountSTR = apexpages.currentpage().getparameters().get('bankAccount');
        userBankAccount = new BankACHWrapper() ;
        
        //lendingApplnId = 'a1k1D000000LxkFQAS' ;
        User currentUser = [SELECT Id, Name, AccountId, ContactId
                            FROM User
                            WHERE Id = :UserInfo.getUserId()
                            AND IsPortalEnabled = true LIMIT 1] ;
        
        userAccountId = currentUser.AccountId ;

        //isCoApplicantExists = false ; 

        fetchApplicantsDetails(lendingApplnId) ;
        populatePricingDetails(lendingApplnId) ;
        
        /*if( isCoApplicantExists && coApplicantRecord != null && userAccountId.equalsIgnoreCase(coApplicantRecord.Id) ) {
            bankAddressMap = populateAddressValues(coApplicantRecord) ;
        } else{
            bankAddressMap = populateAddressValues(applicantRecord) ;
        }*/
        appAddressMap = populateAddressValues(applicantRecord) ;
        bankAddressMap = populateAddressValues(applicantRecord) ;
        
    }
    
    private MAP<String, String> populateAddressValues(Account userAccount){
        
        String city = '', state = '', zip = '', street = '' ;
        if(userAccount != null && String.isNotBlank(userAccount.PersonMailingStreet) && String.isNotBlank(userAccount.PersonMailingCity) && String.isNotBlank(userAccount.PersonMailingState) && String.isNotBlank(userAccount.PersonMailingPostalCode)){
            city = userAccount.PersonMailingCity ;
            state = userAccount.PersonMailingState ;
            zip = userAccount.PersonMailingPostalCode ;
            street = userAccount.PersonMailingStreet ;
        } else if(userAccount != null){
            city = userAccount.PersonOtherCity ;
            state = userAccount.PersonOtherState ;
            zip = userAccount.PersonOtherPostalCode ;
            street = userAccount.PersonOtherStreet ;
        }
        Map<String, String> addressMap = new Map<String, String> () ;
        addressMap.put('city', city) ;
        addressMap.put('state', state) ;
        addressMap.put('zip', zip) ;
        addressMap.put('street', street) ;
        
        if(addressMap.get('state') == null){
            addressMap.put('state', '') ;
        }
        if(addressMap.get('city') == null){
            addressMap.put('city', '') ;
        }
        if(addressMap.get('zip') == null){
            addressMap.put('zip', '') ;
        }
        if(addressMap.get('street') == null){
            addressMap.put('street', '') ;
        }
        return addressMap ;
    }
    
    private void fetchApplicantsDetails(Id lendingApplnId){
        List<Account> applicantsList = [SELECT PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode,
                                        Id, Name, PersonBirthdate, PersonEmail, Phone, Is_VCL_Portal_Co_Applicant__c,
                                        PersonOtherStreet, PersonOtherCity, PersonOtherState, PersonOtherPostalCode 
                                        FROM Account
                                        WHERE Id in (SELECT fsCore__Account_Name__c
                                                     FROM fsCore__Lending_Application_Customer__c
                                                     WHERE fsCore__Lending_Application_Number__c = :lendingApplnId)
                                       ] ;

        if(applicantsList.isEmpty()) {
            return ;
        } 
        for(Account customer : applicantsList ) {
            if(userAccountId.equalsIgnoreCase(customer.Id) ) {
                applicantRecord = customer ;
                
            } 
            /*else{
                coApplicantRecord = customer ;
                isCoApplicantExists = true ;
                coAppAddressMap = populateAddressValues(coApplicantRecord) ;
            }*/
        }
        populateBankingInfo(); 
    }
    
    public String getCommunityURL() {
        List<Client_Portal_Portfolio__c> vclPortfolioList  = [ SELECT Id, Login_URL__c
                                                                    FROM Client_Portal_Portfolio__c 
                                                                    WHERE Name = :VCL_PORTFOLIO_NAME] ;
        if(! vclPortfolioList.isEmpty()) {
            return vclPortfolioList[0].Login_URL__c ;
        }
        return null ;
    }
    
    private void populateBankingInfo() {
        try{
            fsCore__Bank_Account__c userBankDetails = (fsCore__Bank_Account__c) JSON.deserialize(bankAccountSTR, fsCore__Bank_Account__c.class) ;
            System.debug('userBankDetails ' + userBankDetails);
            userBankAccount.bankName = userBankDetails.fsCore__Bank_Name__c ;
            userBankAccount.routingNumber = userBankDetails.Routing_Number__c ;
            userBankAccount.bankAccountNumber = userBankDetails.fsCore__Bank_Account_Number__c ;
            userBankAccount.bankAccountType = userBankDetails.fsCore__Bank_Account_Type__c ;
            userBankAccount.bankAccountHolderName = userBankDetails.fsCore__Bank_Account_Holder_Name__c ;
            
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            throw ex;
        }
        
    }
    
    private void populatePricingDetails(Id lendingAppId) {
        try{
            System.debug('@@lendingAppId ' + lendingAppId) ;
            fsCore__Lending_Application_Pricing_Offer__c pricingOffer = [ SELECT Id, fsCore__Payment_Start_Date__c, fsCore__Payment_Amount__c 
                                                                         FROM fsCore__Lending_Application_Pricing_Offer__c 
                                                                         WHERE fsCore__Lending_Application_Number__c = :lendingAppId AND fsCore__Is_Accepted__c = true
                                                                         ORDER BY CreatedDate DESC LIMIT 1] ;
            
            userBankAccount.paymentAmount = pricingOffer.fsCore__Payment_Amount__c ;
            userBankAccount.paymentStartDate = pricingOffer.fsCore__Payment_Start_Date__c ;
                
        } catch(Exception exptn) {
            System.debug('@@Error: ' + exptn.getMessage());
        }
    }
    
    public class BankACHWrapper {
        public String bankName {get; set;}
        public Decimal paymentAmount {get; set;}
        public String routingNumber {get; set;}
        public String bankAccountNumber {get; set;}
        public String bankAccountType {get; set;}
        public String bankAccountHolderName {get; set;}
        public Date paymentStartDate {get; set;}
    }
    

}