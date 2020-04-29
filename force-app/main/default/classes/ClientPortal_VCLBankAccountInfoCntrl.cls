public without sharing class ClientPortal_VCLBankAccountInfoCntrl {
    
    private static final String COMPLETED_ENVELOPE_STATUS = 'Completed' ;
    private static final String RESULT_SUCCESS_MESSAGE = 'Success';
    private static final String VERIFIED_MESSAGE = 'Verified'; 
    private static final String VERIFICATION_PENDING_STR = 'Verification Pending';
    private static final String BANK_ACCOUNT_VERIFIED = 'BAV Completed';
    private static final String BAV_IN_PROGRESS_STR = 'BAV In Progress';
    private static final String BANK_ACCOUNT_VERIFICATION_FAILED = 'BAV Failed';
    private static final String BANK_ATD_DISCLOSURE = '_BANK_ATD_DISCLOSURE' ;
    private static final String NOT_VERIFIED_MESSAGE_ATTEMPT_1_OR_2 = 'The entered amount does not match the small test credit (less than $1.00) we deposited into your bank account. Please review your transaction history and try again.';
    private static final String NOT_VERIFIED_MESSAGE_ATTEMPT_3 = 'The entered amount does not match the small test credit (less than $1.00) we deposited into your bank account. For assistance, please call customer service at (855) 204-0384';
    private static final String NOT_VERIFIED_MESSAGE_ATTEMPT_4 = 'The entered amount is incorrect. Please re-enter your bank information to restart the bank account verification process. For assistance, please call customer service at (855) 204-0384.';
    
    private static List<fsCore__Bank_Account__c> userBankAccountList = new List<fsCore__Bank_Account__c>() ; 
    @TestVisible private static String userAccountId = null ; 
    private static String userContactId = null ;
    private static Boolean resetCounter = false ;
    private static fsCore__Bank_Account__c userBankAccount = new fsCore__Bank_Account__c () ;
    
    @AuraEnabled
    public static UserBankAccountsWrapper getBankAccountListForUser() {
        String resultString ;
        
        try{
            
            if(String.isBlank(userAccountId)){
                User currentUser = [SELECT Id, Name, AccountId, ContactId
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()
                                    AND IsPortalEnabled = true LIMIT 1] ;
                
                userAccountId = currentUser.AccountId ;
                userContactId = currentUser.ContactId ;
            }
            
            populateUsersBankAccountList() ;
            
            resultString = RESULT_SUCCESS_MESSAGE ;
        } catch(Exception exptn) {
            System.debug('Error: ' + exptn.getMessage());
            resultString = exptn.getMessage() ;
        }
        
        UserBankAccountsWrapper bankAccountWrapper = new UserBankAccountsWrapper() ;
        bankAccountWrapper.resultStr = resultString ;
        bankAccountWrapper.userBankAccountList = userBankAccountList ;
        
        return bankAccountWrapper ;
    }
    
    @AuraEnabled
    public static Boolean isActiveBankAccount() {
        Boolean isActiveBAV = false;
        String lendingAppNo = '';
        try{
            User currentUser = [SELECT Id, Name, AccountId, ContactId, Account.Lending_Application_Id__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                                AND IsPortalEnabled = true LIMIT 1] ;
            
            userAccountId = currentUser.AccountId ;
            userContactId = currentUser.ContactId ;
            
            Application_Bank_Account_Verification__c bAVRecord = [SELECT ID, Verification_Status__c 
                                                                  FROM Application_Bank_Account_Verification__c
                                                                  WHERE Lending_Application_Name__c = :currentUser.Account.Lending_Application_Id__c
                                                                  Order by LastModifiedDate desc LIMIT 1
                                                                 ] ;
            
            if(VERIFIED_MESSAGE.equals(bAVRecord.Verification_Status__c)){
                isActiveBAV = true ;
            }
        } catch (Exception ex){
            System.debug('exception: ' + ex.getMessage());
        }
        
        return isActiveBAV ;
    }
    
    @AuraEnabled
    public static Boolean showVerifyBankLink() {
        Boolean showVerifyBtn = false;
        try{
            User currentUser = [SELECT Id, Name, AccountId, ContactId, Account.Lending_Application_Id__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                                AND IsPortalEnabled = true LIMIT 1] ;
            
            userAccountId = currentUser.AccountId ;
            userContactId = currentUser.ContactId ;
            
            fsCore__Lending_Application__c lendingApp = [SELECT Id, Populate_BAV_initiation_date__c 
                                                         FROM fsCore__Lending_Application__c 
                                                        Where Id = :currentUser.Account.Lending_Application_Id__c LIMIT 1];
            
           
            Date allowedVerificationDate = lendingApp.Populate_BAV_initiation_date__c.addDays(2) ;
            if(Date.today() >= allowedVerificationDate){
                showVerifyBtn = true ;
            }
        } catch (Exception ex){
            System.debug('exception: ' + ex.getMessage());
        }
        
        return showVerifyBtn ;
    }
    
    public static Boolean isDocusignCompleted() {
        Boolean isCompleted = false ;
        try{
            if(String.isBlank(userAccountId)){
                User currentUser = [SELECT Id, Name, AccountId, ContactId
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()
                                    AND IsPortalEnabled = true LIMIT 1] ;
                
                userAccountId = currentUser.AccountId ;
                userContactId = currentUser.ContactId ;
            }

            String enevlopeId = [SELECT Id , VCL_Envelope_Id__c 
                                FROM fsCore__Bank_Account__c 
                                WHERE fsCore__Account_Name__c = :userAccountId 
                                Order by createdDate desc
                                LIMIT 1].VCL_Envelope_Id__c ;

            dsfs__DocuSign_Status__c envelopeStatus = [SELECT Id, dsfs__Envelope_Status__c 
                                                       FROM dsfs__DocuSign_Status__c 
                                                       WHERE dsfs__DocuSign_Envelope_ID__c = :enevlopeId
                                                       LIMIT 1] ;
            
            if(COMPLETED_ENVELOPE_STATUS.equalsIgnoreCase( envelopeStatus.dsfs__Envelope_Status__c) ) {
                isCompleted = true ;
            }
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage()) ;
        }
        return isCompleted ;
    }

    private static void populateUsersBankAccountList() {
        userBankAccountList = [SELECT Id, Name, fsCore__Account_Name__c, 
                               fsCore__Bank_Account_Holder_Name__c, fsCore__Bank_Account_Number__c,
                               fsCore__Bank_Account_Type__c, fsCore__Is_Active__c,
                               fsCore__Bank_Name__c, Routing_Number__c,
                               Is_VCL_Bank_Verification_Locked__c, Number_of_Failure_Verification_Attempts__c,
                               fsCore__Is_Verified__c, fsCore__Is_Primary__c
                               FROM fsCore__Bank_Account__c
                               WHERE fsCore__Account_Name__c =:userAccountId] ;
        
    }
    
    @AuraEnabled
    public static String verifyBankAccountNInitiateBAV(String amountDeposited, Integer numberofAttempts , Id bankAccountId) {
        String resultStr ;
        Boolean isBankAccountVerified = false ;
        
        if(numberofAttempts == 4) {
            return 'NoAttemptLeft' ;
        }
        
        try{
            User currentUser = [SELECT Id, Name, AccountId,Account.Lending_Application_Id__c, ContactId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                                AND IsPortalEnabled = true LIMIT 1] ;
            
            userAccountId = currentUser.AccountId ;
            userContactId = currentUser.ContactId ;
            
            
            /*fsCore__Lending_Application_Customer__c applicantObj = [SELECT fsCore__Lending_Application_Number__c
                                                                    FROM fsCore__Lending_Application_Customer__c
                                                                    WHERE fsCore__Lending_Application_Number__c = :currentUser.Account.Lending_Application_Id__c LIMIT 1] ;*/
            
            Decimal bavAmount = Decimal.valueOf( amountDeposited ) ;
            
            if(String.isNotBlank(currentUser.Account.Lending_Application_Id__c) && String.isNotBlank(amountDeposited)) {
                isBankAccountVerified = BAVUtility.isBAVVerified(currentUser.Account.Lending_Application_Id__c , bavAmount) ;
            }
            
            if( isBankAccountVerified ) {
                resultStr = VERIFIED_MESSAGE ;
                
                fsCore__Lending_Application__c  lendingApplnObj = new fsCore__Lending_Application__c () ;
                lendingApplnObj.Id = currentUser.Account.Lending_Application_Id__c ;
                lendingApplnObj.fsCore__Application_Status__c = BANK_ACCOUNT_VERIFIED ;
                lendingApplnObj.Populate_BAV_initiation_date__c = null ;
                lendingApplnObj.Send_BAV_Initiation_Email__c = false ;
                update lendingApplnObj ;
            } else {
                numberofAttempts = (String.isBlank(String.valueOf(numberofAttempts))) ? 1 : numberofAttempts + 1 ;
                
                fsCore__Bank_Account__c bankAccountObj = new fsCore__Bank_Account__c() ;
                bankAccountObj.Is_VCL_Bank_Verification_Locked__c = (numberofAttempts >= 3) ;
                bankAccountObj.Number_of_Failure_Verification_Attempts__c = numberofAttempts ;
                bankAccountObj.Id = bankAccountId ;
                update bankAccountObj;
                System.debug('numberofAttempts ' + numberofAttempts);
                switch  on numberofAttempts {
                    when 3 { 
                        resultStr = NOT_VERIFIED_MESSAGE_ATTEMPT_3 ;
                        fsCore__Lending_Application__c  lendingApplnObj = new fsCore__Lending_Application__c () ;
                        lendingApplnObj.Id = currentUser.Account.Lending_Application_Id__c ;
                        lendingApplnObj.fsCore__Application_Status__c = BANK_ACCOUNT_VERIFICATION_FAILED ;
                        update lendingApplnObj ;
                    }
                    when 4 { 
                        resultStr = NOT_VERIFIED_MESSAGE_ATTEMPT_4 ;
                        fsCore__Lending_Application__c  lendingApplnObj = new fsCore__Lending_Application__c () ;
                        lendingApplnObj.Id = currentUser.Account.Lending_Application_Id__c ;
                        lendingApplnObj.fsCore__Application_Status__c = BANK_ACCOUNT_VERIFICATION_FAILED ;
                        lendingApplnObj.Populate_BAV_initiation_date__c = null ;
                        lendingApplnObj.Send_BAV_Initiation_Email__c = false ;
                        update lendingApplnObj ;
                    }
                    when else { 
                        resultStr = NOT_VERIFIED_MESSAGE_ATTEMPT_1_OR_2 ;
                    }
                    
                }
                
            }
            //resultStr = VERIFIED_MESSAGE ;  remove in UAT
        } catch(Exception excptn) {
            System.debug('excptn ' + excptn.getMessage());
            resultStr = excptn.getMessage() ;
        }
        
        return resultStr ;
    }
    
    
    @AuraEnabled
    public static String updateBankAccountObj(String bankAccountId) {
        String resultString ;

        if(String.isBlank(bankAccountId)){
            return RESULT_SUCCESS_MESSAGE ;
        }
        
        try{
            if(String.isBlank(userAccountId)){
                User currentUser = [SELECT Id, Name, AccountId, ContactId
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()
                                    AND IsPortalEnabled = true LIMIT 1] ;
                
                userAccountId = currentUser.AccountId ;
                userContactId = currentUser.ContactId ;
            }

            fsCore__Bank_Account__c userBankAccount = new fsCore__Bank_Account__c () ;
            userBankAccount.fsCore__Account_Name__c = userAccountId ;
            userBankAccount.Id = bankAccountId ;
            userBankAccount.Number_of_Failure_Verification_Attempts__c = 0 ;
            userBankAccount.Number_of_Failure_Verification_Attempts__c = 0 ;
            userBankAccount.Is_VCL_Bank_Verification_Locked__c = false ;
            userBankAccount.Is_VCL_Docusign_Sent__c = true; 
            update userBankAccount ;
            
            resultString = RESULT_SUCCESS_MESSAGE ;
        } catch(Exception ex) {
            resultString = ex.getMessage() ;
        }
        
        return resultString ;
    }
    
    @AuraEnabled
    public static String saveBankingInfoCntrl(ClientPortal_VCLHomeCntrl.BankAccountWrapper bankAccountObj) {
        String resultString ;
        
        if(String.isBlank(userAccountId)){
            User currentUser = [SELECT Id, Name, AccountId, ContactId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                                AND IsPortalEnabled = true LIMIT 1] ;
            
            userAccountId = currentUser.AccountId ;
            userContactId = currentUser.ContactId ;
        }
        resetCounter = true ;
        resultString = saveBankAccountInfo( userAccountId , bankAccountObj ) ;
        
        if(resultString.containsIgnoreCase('Error')) {
            return resultString ;
        }
        
        //ClientPortal_VCLHomeCntrl.uploadATDtoBankObj(userAccountId) ;
        
        String bankAccountId = bankAccountObj.bankAccountId ;
        fsCore__Bank_Account__c bankAccountObject ;
        if(bankAccountId == null){
           bankAccountObject = [SELECT Id, Name
                               FROM fsCore__Bank_Account__c
                               WHERE fsCore__Account_Name__c = :userAccountId order by createdDate desc LIMIT 1] ;
            bankAccountId = bankAccountObject.Id ;
        }
        
        
        resultString = RESULT_SUCCESS_MESSAGE ;
        fsCore__Lending_Application_Customer__c applicantObj = getVerificationTaskCreationDetails(userAccountId) ;
        resultString += '-' + applicantObj.fsCore__Lending_Application_Number__c ;
        return resultString ;
    }
    
    
    
    public static String saveBankAccountInfo(String accountId, ClientPortal_VCLHomeCntrl.BankAccountWrapper bankAccountObj) {
        String resultString ;
        
        try{
            userBankAccount = new fsCore__Bank_Account__c () ;
            userBankAccount.fsCore__Account_Name__c = accountId ;
            
            if(String.isBlank(userContactId)) {
                userContactId = [SELECT ID from Contact where AccountId =: accountId Limit 1].Id ;
                userBankAccount.fsCore__Contact_Name__c = userContactId ;
            }
            
            if(String.isBlank(bankAccountObj.bankAccountId) || resetCounter){
                userBankAccount.fsCore__Is_Active__c = false ;
                userBankAccount.fsCore__Is_Primary__c = false ;
            }
            
            if(String.isBlank(bankAccountObj.bankAccountId)){
                userBankAccount.Number_of_Failure_Verification_Attempts__c = 0 ;
                userBankAccount.Is_VCL_Bank_Verification_Locked__c = false ;
            }
            
            userBankAccount.Id = bankAccountObj.bankAccountId ;
            userBankAccount.fsCore__Bank_Account_Holder_Name__c = bankAccountObj.accountHolderName ;
            userBankAccount.fsCore__Bank_Account_Type__c = bankAccountObj.accountType ;
            userBankAccount.fsCore__Bank_Name__c = bankAccountObj.bankName ;
            userBankAccount.Is_VCL_Docusign_Sent__c = false;
            userBankAccount.fsCore__Bank_Account_Number__c = bankAccountObj.accountNumber ;
            userBankAccount.fsCore__Bank_Identification_Code__c = bankAccountObj.routingNumber ;
            userBankAccount.Routing_Number__c = bankAccountObj.routingNumber ;
            
            userBankAccount.Edited_by_Client__c = resetCounter ; // Modified as part of Lp-828
            
            upsert userBankAccount  ; 
            
            /*if(String.isBlank(bankAccountObj.bankAccountId) || resetCounter){
                createTaskForUnderWriter(userBankAccount.Id , userBankAccount.fsCore__Account_Name__c ) ;
            }*/
            
            
            resultString = RESULT_SUCCESS_MESSAGE ;
            
        }  catch(Exception exptn) {
            System.debug('Error: ' + exptn.getMessage());
            resultString = 'Error: ' + exptn.getMessage() ;
        }
        return resultString ;
    }
    
    @AuraEnabled
    public static String redirectToDocuSignURL(String bankAccountId) {
        String resultStr ;
        try{
            fsCore__Bank_Account__c bankAccountObj = [Select Id,VCL_Envelope_Id__c,
                                                      fsCore__Account_Name__r.Name, fsCore__Account_Name__c  
                                                      FROM fsCore__Bank_Account__c 
                                                      WHERE Id = :bankAccountId LIMIT 1] ;
            
            
            Blob fileBodyStr = ClientPortal_VCLHomeCntrl.getContentForATDForm(bankAccountObj.fsCore__Account_Name__c) ;
            String accountName = bankAccountObj.fsCore__Account_Name__r.Name.length() > 20 ? 
                bankAccountObj.fsCore__Account_Name__r.Name.substring(0, 20)  : 
            bankAccountObj.fsCore__Account_Name__r.Name;
            
            String atdFileName = accountName.trim() + BANK_ATD_DISCLOSURE + String.valueOf(System.now()).replace(' ', '').replace('-', '') ;
            
            Client_Portal_Portfolio__c vclPortfolio = [SELECT Id, Banking_Tab_URL__c 
                                                       FROM Client_Portal_Portfolio__c 
                                                       WHERE NAME = 'VCL' LIMIT 1] ;
            
            String redirectionURL = ClientPortal_VCLDocusignServiceClass.getSignerURL(UserInfo.getUserEmail(), 
                                                                                      UserInfo.getName(), 
                                                                                      vclPortfolio.Banking_Tab_URL__c,
                                                                                      UserInfo.getUserId(),
                                                                                      'Bank ATD Form', 
                                                                                      fileBodyStr,
                                                                                      atdFileName,
                                                                                     bankAccountObj.Id);
            
            
            ApexPages.PageReference authPage = new PageReference(redirectionURL) ;
            authPage.setRedirect(true);
            if (!Test.isRunningTest()) {
                aura.redirect(authPage);
            } 
            resultStr = RESULT_SUCCESS_MESSAGE ;
        }catch(Exception excptn) {
            System.debug('@@@excptn ' + excptn.getMessage());
            System.debug('@@@stackTrace ' + excptn.getStackTraceString());
            resultStr = excptn.getMessage() ;
        }
        
        return resultStr ;
    }
    
    private static fsCore__Lending_Application_Customer__c getVerificationTaskCreationDetails(String accountId){
        fsCore__Lending_Application_Customer__c applicantObj = [SELECT fsCore__Lending_Application_Number__c,
                                                                fsCore__Lending_Application_Number__r.OwnerId,
                                                                fsCore__Account_Name__r.Name
                                                                FROM fsCore__Lending_Application_Customer__c
                                                                WHERE fsCore__Account_Name__c = :accountId LIMIT 1] ;
        return applicantObj ;
    }
    
    @AuraEnabled
    public static ClientPortal_VCLHomeCntrl.BankAccountWrapper getBankAccountWrapper() {
        if(String.isBlank(userAccountId)){
            User currentUser = [SELECT Id, Name, AccountId, ContactId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                                AND IsPortalEnabled = true LIMIT 1] ;
            
            userAccountId = currentUser.AccountId ;
            userContactId = currentUser.ContactId ;
        }
        return ClientPortal_VCLHomeCntrl.getBankAccountWrapper(userAccountId) ;
    }
    
    /*private static void createTaskForUnderWriter(String bankAccountId, String accountId) {
        fsCore__Lending_Application_Customer__c applicantObj = getVerificationTaskCreationDetails(accountId) ;
        String subjectActionString = (resetCounter) ? ' updated a bank account' : ' New bank account added';
        String descriptionActionString = (resetCounter) ? ' has updated a bank account please re-initiate a BAV' : ' has added a new bank account please initiate a BAV';
        Task bankVerificationTask = new Task() ;
        bankVerificationTask.Subject = applicantObj.fsCore__Account_Name__r.Name + subjectActionString ;
        bankVerificationTask.Description = applicantObj.fsCore__Account_Name__r.Name +  descriptionActionString ;
        bankVerificationTask.ActivityDate = Date.today() ;
        bankVerificationTask.OwnerId  = applicantObj.fsCore__Lending_Application_Number__r.OwnerId ;
        bankVerificationTask.WhatId = bankAccountId ;  
        bankVerificationTask.RecordTypeId = ClientPortal_Utility.getRecordTypeId('Task', 'VCL Task') ;  
        insert bankVerificationTask ;
    }*/
    
    @AuraEnabled
    public static String updateVCLDisclosureInformation(String lendingAppInstanceIdStr, String disclosureName, Boolean isAccepted) {
        if(String.isBlank(userAccountId)){
            User currentUser = [SELECT Id, Name, AccountId, ContactId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                                AND IsPortalEnabled = true LIMIT 1] ;
            
            userAccountId = currentUser.AccountId ;
            userContactId = currentUser.ContactId ;
        }
        Account userAccount = [Select Id, Name FROM Account WHERE Id = :userAccountId LIMIT 1] ;
        
        return ClientPortal_VCLHomeCntrl.updateVCLDisclosureInformation(JSON.serialize(userAccount), lendingAppInstanceIdStr, disclosureName, isAccepted) ;
    }
    
    @AuraEnabled
    public static List<String> retriveBankNameList() {
        List<String> bankNameList = new List<String>() ; 
        List<PicklistEntry> pickListEntries = fsCore__Bank_Account__c.Bank_Name_List__c.getDescribe().getSObjectField().getDescribe().getPicklistValues();
        for(PicklistEntry entry : pickListEntries) {
            bankNameList.add(entry.getValue()) ;
        }
        return bankNameList ;
    }
    
    // code to change the status of BAV record to verification Pending when client asks for unblocking the final attempt
    public static void updateStatusOfBAVrecordAfterUnblocking(Map<Id, fsCore__Bank_Account__c> bankOldMap,List<fsCore__Bank_Account__c> bankAccountList) {
        Set<Id> accountIdsForBankAccountsUnblocked = new Set<Id> () ;
        for(fsCore__Bank_Account__c updatedBankAccount: bankAccountList) {
            if( (! updatedBankAccount.Is_VCL_Bank_Verification_Locked__c && bankOldMap.get(updatedBankAccount.Id).Is_VCL_Bank_Verification_Locked__c)
               && updatedBankAccount.Number_of_Failure_Verification_Attempts__c == 3) {
                accountIdsForBankAccountsUnblocked.add(updatedBankAccount.fsCore__Account_Name__c) ;
            }
        }
        
        if(accountIdsForBankAccountsUnblocked.isEmpty()){
            return ;
        }
        List<Application_Bank_Account_Verification__c> bavRecordsToUpdate = new List<Application_Bank_Account_Verification__c>() ;
        List<fsCore__Lending_Application__c> applicationsToUpdate = new List<fsCore__Lending_Application__c>() ;
        Application_Bank_Account_Verification__c clonedBAV ;
        for( fsCore__Lending_Application__c lendingAppsToUnblock : [SELECT Id, (SELECT Id, Lending_Application_Name__c, BAV_Withdraw_Date__c, Comments__c, Custom_CreatedDate__c, 
                                                                                Deposit_Amount__c, Deposit_Status__c, Error_Message_Initiate_BAV__c, Error_Message_Verified_BAV__c,
                                                                                External_RAMS_ID_Formula__c, Is_Client_Created__c, Is_Deposit_Complete__c, 
                                                                                Lending_Application_Owner_Id__c, Number_Of_Tries__c, Primary_Customer_Name_Formula__c,
                                                                                Verification_Completed_Update_To_RAMS__c, Verification_Status__c
                                                                                FROM Application_Bank_Account_Verification__r
                                                                                Order by LastModifiedDate desc LIMIT 1)
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE fsCore__Primary_Customer_Account__c IN :accountIdsForBankAccountsUnblocked])
        {
            if(!lendingAppsToUnblock.Application_Bank_Account_Verification__r.isEmpty()) {
                clonedBAV = lendingAppsToUnblock.Application_Bank_Account_Verification__r[0].clone() ;
                clonedBAV.Verification_Status__c = VERIFICATION_PENDING_STR ;
                bavRecordsToUpdate.add(clonedBAV) ;

                applicationsToUpdate.add(
                    new fsCore__Lending_Application__c(
                        Id = lendingAppsToUnblock.Id,
                        fsCore__Application_Status__c = BAV_IN_PROGRESS_STR,
                        Populate_BAV_initiation_date__c = Date.today().addDays(-2)
                    )
                ) ;
            }
        }
        if(!applicationsToUpdate.isEmpty()) {
            update applicationsToUpdate ;
        }
        if(!bavRecordsToUpdate.isEmpty()) {
            insert bavRecordsToUpdate ;
        }
        
    }
    public class UserBankAccountsWrapper {
        @AuraEnabled
        public List<fsCore__Bank_Account__c> userBankAccountList ;
        @AuraEnabled
        public String resultStr ;
    }
    
}