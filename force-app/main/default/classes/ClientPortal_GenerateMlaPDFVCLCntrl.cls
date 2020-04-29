public without sharing class ClientPortal_GenerateMlaPDFVCLCntrl {
    
    public VCLMlaWrapper lendingApplnWrapper {get; set;}
    public String currentDate {get;set;}
    
    
    public ClientPortal_GenerateMlaPDFVCLCntrl(){
        currentDate = system.now().format('MM/dd/yyyy HH:mm:ss a','America/New_York');
        Id lendingApplnId = apexpages.currentpage().getparameters().get('id');
        lendingApplnWrapper = getUIWrap(lendingApplnId, true);
    }
    
    public static VCLMlaWrapper getUIWrap(String lendingApplnId, Boolean isController){
        String borrowerAddress;
        String lenderAddress;
        String borrowerName = '' ;
        String borrowerEmail ;
        String noticeDate ;
        String userIpAddress ;
        String primaryApplicantName = '';
        String secondaryApplicantName = '';
        fsCore__Lending_Application__c lendingAppln;

        User currentUser = [SELECT Id, Name, AccountId
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
                        fsCore__Primary_Customer_Account__r.LastName,fsCore__Payment_Cycle__c, Offer_Accepted_Date__c, 
                        fsCore__Number_Of_Repayments__c,fsCore__Total_Of_Payments__c,
                        (select id,name,Person_Name_Formula__c,fsCore__Account_Name__r.PersonEmail,fsCore__Contact_Name__r.fsCore__Other_Address_Formula__c,
                         fsCore__Contact_Name__r.OtherAddress,fsCore__Contact_Name__r.OtherCity,fsCore__Contact_Name__r.OtherState,
                         fsCore__Contact_Name__r.OtherStreet,fsCore__Contact_Name__r.OtherPostalCode,
                         Mailing_City_Formula__c, Mailing_State_Formula__c, Mailing_Street_Address_Formula__c, Mailing_Zip__c,Is_mailing_address_different__c
                         from fsCore__Lending_Application_Customer__r)
                        FROM fsCore__Lending_Application__c WHERE Id =: lendingApplnId LIMIT 1] ;
        
        for(fsCore__Lending_Application_Customer__c applicant : lendingAppln.fsCore__Lending_Application_Customer__r){
            if(applicant.fsCore__Account_Name__c == currentUser.AccountId){
                if(String.isNotBlank(applicant.Mailing_Street_Address_Formula__c )
                && String.isNotBlank(applicant.Mailing_City_Formula__c)
                && String.isNotBlank(applicant.Mailing_State_Formula__c)
                && String.isNotBlank(applicant.Mailing_Zip__c)
                ) {
                    
                    borrowerAddress = (String.isNotBlank(applicant.Mailing_Street_Address_Formula__c)) ? applicant.Mailing_Street_Address_Formula__c + ', ' : '' ;
                    borrowerAddress +=  (String.isNotBlank(applicant.Mailing_City_Formula__c)) ? applicant.Mailing_City_Formula__c + ', '  : '' ;
                    borrowerAddress +=  (String.isNotBlank(applicant.Mailing_State_Formula__c)) ? applicant.Mailing_State_Formula__c + ', '  : '' ;
                    borrowerAddress +=  (String.isNotBlank(applicant.Mailing_Zip__c)) ? applicant.Mailing_Zip__c + '. '  : '' ;
                    
                } else{
                    
                    borrowerAddress = (String.isNotBlank(applicant.fsCore__Contact_Name__r.OtherStreet)) ? applicant.fsCore__Contact_Name__r.OtherStreet + ', ' : '' ;
                    borrowerAddress +=  (String.isNotBlank(applicant.fsCore__Contact_Name__r.OtherCity)) ? applicant.fsCore__Contact_Name__r.OtherCity + ', '  : '' ;
                    borrowerAddress +=  (String.isNotBlank(applicant.fsCore__Contact_Name__r.OtherState)) ? applicant.fsCore__Contact_Name__r.OtherState + ', '  : '' ;
                    borrowerAddress +=  (String.isNotBlank(applicant.fsCore__Contact_Name__r.OtherPostalCode)) ? applicant.fsCore__Contact_Name__r.OtherPostalCode + '. '  : '' ;
                    
                }
                borrowerEmail = applicant.fsCore__Account_Name__r.PersonEmail;
                primaryApplicantName = applicant.Person_Name_Formula__c;
            }else{
                secondaryApplicantName = applicant.Person_Name_Formula__c;
            }
        }
        if(secondaryApplicantName != null && secondaryApplicantName.trim() != ''){
            borrowerName = primaryApplicantName + '<br/>' + secondaryApplicantName;
        }else{
            borrowerName = primaryApplicantName;
        }
        Map<String, String> vclContent = ClientPortal_VCLHomeCntrl.retrieveESignContent() ;
        lenderAddress = vclContent.get('lenderAddress') ;
        if(isController){
            userIpAddress = ClientPortal_Utility.getUserIPAddress();
        }
        noticeDate = String.valueOf(lendingAppln.Offer_Accepted_Date__c);
        VCLMlaWrapper lendingApplnWrap = new VCLMlaWrapper(lendingAppln.Annual_Percent_Rate_Formula__c, lendingAppln.fsCore__Total_Financial_Charge__c, lendingAppln.fsCore__Financed_Amount__c, 
                                                 lendingAppln.fsCore__Total_Of_Payments__c, lendingAppln.fsCore__Payment_Amount__c, lendingAppln.fsCore__Payment_Cycle__c, 
                                                 lendingAppln.fsCore__Payment_Start_Date__c, lendingAppln.fsCore__Number_Of_Repayments__c, lendingAppln.Name, borrowerAddress,
                                                 lenderAddress, borrowerName, borrowerEmail, noticeDate, userIpAddress, lendingAppln) ;
        return lendingApplnWrap;
    }

    public class VCLMlaWrapper {
        @AuraEnabled public Decimal annualPercntgRate {get; set;}
        @AuraEnabled public Decimal financialCharge {get; set;}
        @AuraEnabled public Decimal financedAmount {get; set;}
        @AuraEnabled public Decimal totalOfPayments {get; set;}
        @AuraEnabled public Decimal paymentAmount {get; set;}
        @AuraEnabled public String paymentCycle {get; set;}
        @AuraEnabled public String applicationNumber {get; set;}
        @AuraEnabled public Date paymentStartDate {get; set;}
        @AuraEnabled public Decimal numberOfRepayments {get; set;}
        @AuraEnabled public String borrowerAddress {get;set;}
        @AuraEnabled public String lenderAddress {get;set;}
        @AuraEnabled public String borrowerName {get;set;}
        @AuraEnabled public String borrowerEmail {get;set;}
        @AuraEnabled public String noticeDate {get;set;}
        @AuraEnabled public String userIpAddress {get;set;}
        @AuraEnabled public fsCore__Lending_Application__c lendingAppln{get;set;}
        
        public VCLMlaWrapper (Decimal annualPercntgRate, Decimal financialCharge, Decimal financedAmount, 
                               Decimal totalOfPayments, Decimal paymentAmount, String paymentCycle, 
                               Date paymentStartDate, Decimal numberOfRepayments, String applicationNumber,
                               String borrowerAddress, String lenderAddress, String borrowerName, String borrowerEmail,
                               String noticeDate, String userIpAddress, fsCore__Lending_Application__c lendingAppln) {
            this.annualPercntgRate = annualPercntgRate ;
            this.financialCharge = financialCharge ;
            this.financedAmount = financedAmount ;
            this.totalOfPayments = totalOfPayments ;
            this.paymentAmount = paymentAmount ;
            this.paymentCycle = paymentCycle ;
            this.paymentStartDate = paymentStartDate ;
            this.numberOfRepayments = numberOfRepayments ;
            this.applicationNumber = applicationNumber;
            this.borrowerAddress = borrowerAddress;
            this.lenderAddress = lenderAddress;
            this.borrowerName = borrowerName;
            this.borrowerEmail = borrowerEmail;
            this.noticeDate = noticeDate;
            this.userIpAddress = userIpAddress;
            this.lendingAppln = lendingAppln;
        }
    }
}