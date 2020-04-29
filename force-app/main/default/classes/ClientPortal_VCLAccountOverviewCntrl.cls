public without sharing class ClientPortal_VCLAccountOverviewCntrl {
    
    @AuraEnabled
    public static Boolean checkForPendingDocument() {
        return ClientPortal_VCLDocumentInformationCntrl.isCheckListPending();
    }
    
    @AuraEnabled
    public static String showVerifyBankLink() {
        String showVerifyBtn = '';
        Set<String> bavStatusAllowed = new Set<String>() ;
        bavStatusAllowed.add('Verification Pending') ;
        bavStatusAllowed.add('New') ;
        try{
            User currentUser = [SELECT Id, Name, AccountId, Account.Lending_Application_Id__c, Account.Is_VCL_Portal_Co_Applicant__c, ContactId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                                AND IsPortalEnabled = true LIMIT 1] ;
            
            if(currentUser.Account.Is_VCL_Portal_Co_Applicant__c) {
                return showVerifyBtn;
            }
            
            fsCore__Lending_Application_Customer__c applicantObj = [SELECT fsCore__Lending_Application_Number__c ,fsCore__Lending_Application_Number__r.Populate_BAV_initiation_date__c
                                                                    FROM fsCore__Lending_Application_Customer__c
                                                                    WHERE fsCore__Lending_Application_Number__c = :currentUser.Account.Lending_Application_Id__c LIMIT 1] ;
            Application_Bank_Account_Verification__c bAVRecord = [SELECT ID, Verification_Status__c 
                                                                  FROM Application_Bank_Account_Verification__c
                                                                  WHERE Lending_Application_Name__c = :currentUser.Account.Lending_Application_Id__c
                                                                  Order by LastModifiedDate desc LIMIT 1
                                                                 ] ;
            Date allowedVerificationDate = Date.today().addDays(2) ;
            
            if(String.isNotBlank(String.valueOf(applicantObj.fsCore__Lending_Application_Number__r.Populate_BAV_initiation_date__c))) {
                allowedVerificationDate = applicantObj.fsCore__Lending_Application_Number__r.Populate_BAV_initiation_date__c.addDays(2) ;
            }

            if(Date.today() >= allowedVerificationDate
               && bAVRecord != null
               && bavStatusAllowed.contains(bAVRecord.Verification_Status__c)  
              ){
                showVerifyBtn = 'ShowBAVTask' ;
            }
            else if(bAVRecord.Verification_Status__c.equalsIgnoreCase('Verified')) {
                showVerifyBtn = 'Verified' ;
            }
        } catch (Exception ex){
            System.debug('exception: ' + ex.getMessage());
        }
        
        return showVerifyBtn ;
    }
    
    @AuraEnabled
    public static object getAccountOverview(){
        Id userAccountId;
        fsCore__Lending_Application_Pricing_Offer__c overview = new fsCore__Lending_Application_Pricing_Offer__c();
        List<User> userList = new List<User>();
        try{
            userList = [SELECT Id, Name, AccountId
                        FROM User
                        WHERE Id =: UserInfo.getUserId()
                        AND IsPortalEnabled = true];
            if (!userList.isEmpty()) {
                userAccountId = userList[0].accountId;
                List<fsCore__Lending_Application__c> appList = [SELECT Id,  (SELECT Id
                                                                            FROM fsCore__Lending_Application_Customer__r 
                                                                            WHERE fsCore__Account_Name__c = :userAccountId LIMIT 1)
                                                                            FROM fsCore__Lending_Application__c 
                                                                            WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                        FROM fsCore__Lending_Application_Customer__c 
                                                                                        WHERE fsCore__Account_Name__c = :userAccountId)
                                                                LIMIT 1];
                if(!appList.isEmpty()){
                    overview = [SELECT Id, fsCore__Rate__c, fsCore__Annual_Percent_Rate__c, fsCore__Payment_Amount__c, fsCore__Number_Of_Months__c, fsCore__Is_Accepted__c, fsCore__Total_Finance_Charge__c, 
                                fsCore__Maturity_Date__c, fsCore__Total_Interest_Amount__c, fsCore__Finance_Fee__c, fsCore__Loan_Amount__c, fsCore__Prepaid_Fee__c, fsCore__Number_Of_Payments_Monthly__c, fsCore__Financed_Amount__c
                                FROM fsCore__Lending_Application_Pricing_Offer__c 
                                WHERE fsCore__Lending_Application_Number__c = :appList[0].Id
                                AND fsCore__Is_Accepted__c = true
                                ORDER BY SystemModstamp Desc
                                LIMIT 1];
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return overview;
    }
}