public without sharing class ClientPortal_GenerateEsignPDFVCLCntrl {
    
    public fsCore__Lending_Application__c lendingAppln{get;set;}
    public VCLTilaWrapper lendingApplnWrapper {get; set;}
    public Map<String, String> vclContentToShowMap{get;set;}
    public String userIpAddress {get;set;}
    public String currentDate {get;set;}
    public String borrowerAddress {get;set;}
    public String lenderAddress {get;set;}
    public String borrowerName {get;set;}
    public String borrowerEmail {get;set;}
   
    private static final String ESIGN_CONTENT_NAME = 'eSign';
    private static final String BANK_ATD_CONTENT_NAME = 'bankAtd';
    private static final String ESIGN_HEADER_CONTENT_NAME = 'E-SIGN DISCLOSURE AND CONSENT';
    private static final String BANK_ATD_HEADER_CONTENT_NAME = 'ATD Bank Account Esign';
    
    public ClientPortal_GenerateEsignPDFVCLCntrl(){
        currentDate = String.valueOf(system.now());
        Id lendingApplnId = apexpages.currentpage().getparameters().get('id');
        String contentToShow = apexpages.currentpage().getparameters().get('content');
        
        User currentUser =[SELECT Id, Name, AccountId
                        FROM User
                        WHERE Id =: UserInfo.getUserId()
                        AND IsPortalEnabled = true LIMIT 1] ;
        
        lendingAppln = [SELECT Id, Name, fsCore__Primary_Customer_Account__c,fsCore__Rate__c,
                        Annual_Percent_Rate_Formula__c,fsCore__Payment_Start_Date__c,fsCore__Payment_Amount__c,
                        fsCore__Number_Of_Months__c, fsCore__Maturity_Date__c,fsCore__Total_Interest_Amount__c,
                        fsCore__Total_Financial_Charge__c,fsCore__Finance_Fee__c, fsCore__Loan_Amount__c,
                        fsCore__Financed_Amount__c,Rate_Formula__c,fsCore__Primary_Customer_Account__r.fsCore__Email__c,
                        fsCore__Primary_Customer_Account__r.PersonEmail,fsCore__Primary_Customer_Account__r.PersonMailingAddress,
                        fsCore__Primary_Customer_Account__r.PersonMailingCity,fsCore__Primary_Customer_Account__r.PersonMailingState,
                        fsCore__Primary_Customer_Account__r.PersonMailingStreet,fsCore__Primary_Customer_Account__r.FirstName,
                        fsCore__Primary_Customer_Account__r.LastName,fsCore__Payment_Cycle__c,
                        fsCore__Number_Of_Repayments__c,fsCore__Total_Of_Payments__c,
                        (select id,name,Person_Name_Formula__c,fsCore__Account_Name__r.PersonEmail,fsCore__Contact_Name__r.fsCore__Other_Address_Formula__c,
                         fsCore__Contact_Name__r.OtherAddress,fsCore__Contact_Name__r.OtherCity,fsCore__Contact_Name__r.OtherState,
                         fsCore__Contact_Name__r.OtherStreet,fsCore__Contact_Name__r.OtherPostalCode,
                         Mailing_City_Formula__c, Mailing_State_Formula__c, Mailing_Street_Address_Formula__c, Mailing_Zip__c,Is_mailing_address_different__c
                         from fsCore__Lending_Application_Customer__r WHERE fsCore__Account_Name__c = :currentUser.AccountId LIMIT 1)
                        FROM fsCore__Lending_Application__c WHERE Id =: lendingApplnId LIMIT 1] ;
        
        if(String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_Street_Address_Formula__c )
           && String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_City_Formula__c)
           && String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_State_Formula__c)
           && String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_Zip__c)
          ) {
            
            borrowerAddress = (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_Street_Address_Formula__c)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_Street_Address_Formula__c + ', ' : '' ;
            borrowerAddress +=  (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_City_Formula__c)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_City_Formula__c + ', '  : '' ;
            borrowerAddress +=  (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_State_Formula__c)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_State_Formula__c + ', '  : '' ;
            borrowerAddress +=  (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_Zip__c)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].Mailing_Zip__c + '. '  : '' ;
            
        } else{
            
            borrowerAddress = (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherStreet)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherStreet + ', ' : '' ;
            borrowerAddress +=  (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherCity)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherCity + ', '  : '' ;
            borrowerAddress +=  (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherState)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherState + ', '  : '' ;
            borrowerAddress +=  (String.isNotBlank(lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherPostalCode)) ? lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Contact_Name__r.OtherPostalCode + '. '  : '' ;
            
        }
        
        borrowerEmail = lendingAppln.fsCore__Lending_Application_Customer__r[0].fsCore__Account_Name__r.PersonEmail;
        borrowerName = lendingAppln.fsCore__Lending_Application_Customer__r[0].Person_Name_Formula__c;
        
        lendingApplnWrapper = new VCLTilaWrapper(lendingAppln.Annual_Percent_Rate_Formula__c, lendingAppln.fsCore__Total_Financial_Charge__c,
                                                 lendingAppln.fsCore__Financed_Amount__c, 
                                                 lendingAppln.fsCore__Total_Of_Payments__c, lendingAppln.fsCore__Payment_Amount__c, lendingAppln.fsCore__Payment_Cycle__c, 
                                                 lendingAppln.fsCore__Payment_Start_Date__c, lendingAppln.fsCore__Number_Of_Repayments__c) ;
        
        vclContentToShowMap = retrieveESignContent(contentToShow) ;
        userIpAddress = getUserIPAddress() ;
        
    }
    
    private Map<String, String> retrieveESignContent(String contentToShow) {
        Map<String, String> vclContent = ClientPortal_VCLHomeCntrl.retrieveESignContent() ;
        Map<String, String> contentToShowMap = new Map<String, String>() ;
        if(ESIGN_CONTENT_NAME.equals(contentToShow)) {
            contentToShowMap.put('header', ESIGN_HEADER_CONTENT_NAME) ;
            contentToShowMap.put('body', vclContent.get('ESignDisclosure')) ;
        } else if(BANK_ATD_CONTENT_NAME.equals(contentToShow)){
            contentToShowMap.put('header', BANK_ATD_HEADER_CONTENT_NAME) ;
            contentToShowMap.put('body', vclContent.get('BankATDESignDisclosure')) ;
        }
        lenderAddress = vclContent.get('lenderAddress') ;
        return contentToShowMap ;
    }
    
    private String getUserIPAddress() {
        String userIpAddress = '';
        
        userIpAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if(String.isBlank(userIpAddress) && userIpAddress == null){
            userIpAddress=  ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }        
        return userIpAddress;
        
    }
    
    public class VCLTilaWrapper {
        public Decimal annualPercntgRate {get; set;}
        public Decimal financialCharge {get; set;}
        public Decimal financedAmount {get; set;}
        public Decimal totalOfPayments {get; set;}
        public Decimal paymentAmount {get; set;}
        public String paymentCycle {get; set;}
        public Date paymentStartDate {get; set;}
        public Decimal numberOfRepayments {get; set;}
        
        public VCLTilaWrapper (Decimal annualPercntgRate, Decimal financialCharge, Decimal financedAmount, 
                               Decimal totalOfPayments, Decimal paymentAmount, String paymentCycle, 
                               Date paymentStartDate, Decimal numberOfRepayments) {
            this.annualPercntgRate = annualPercntgRate ;
            this.financialCharge = financialCharge ;
            this.financedAmount = financedAmount ;
            this.totalOfPayments = totalOfPayments ;
            this.paymentAmount = paymentAmount ;
            this.paymentCycle = paymentCycle ;
            this.paymentStartDate = paymentStartDate ;
            this.numberOfRepayments = numberOfRepayments ;
        }
    }
    
}