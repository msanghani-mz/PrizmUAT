public without sharing class ClientPortal_DNLHomeCntrl {
    
    @TestVisible
    private static final String OPP_STAGE_REG_IN_PROGRESS = 'Registration In Progress';
    private static final String FINANCIAL_FMAILY_DEFAULT_STR = 'Liability';
    private static final String FINANCIAL_TYPE_DEFAULT_STR = 'Housing';
    private static final String FREQUENCY_DEFAULT_STR = 'Monthly';
    
    @AuraEnabled
    public static ClientPortal_DNLIncomeWrapper getAccountAndIncomeDetails() {
        
        Account acc = new Account();
        ClientPortal_DNLIncomeWrapper.IncomeWrapper primaryIncomeWrapper =
            new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
        
        List<ClientPortal_DNLIncomeWrapper.IncomeWrapper> additionalIncomes =
            new List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>();
        
        Id recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
        User userInstance = new User();
        List<User> userList = new List<User>();
        
        userList = [SELECT Id, Name, AccountId
                    FROM User
                    WHERE Id =: userInfo.getUserId()
                    AND IsPortalEnabled = true];
        
        if (!userList.isEmpty()) {
            userInstance = userList[0];
        }
        
        if(userInstance.accountId != null) {
            acc = [SELECT Id, PersonEmail, FirstName, MiddleName, LastName,
                   PersonBirthdate, fsCore__National_Identification_Number__pc,
                   U_S_Residency_Status__c, Primary_Id_Type__c, Primary_Id_Expiration_Date__c,
                   Primary_Id_Number__c, Primary_Id_State__c, DNL_Portal_Status__c,
                   PersonOtherStreet, Person_Other_Appartment__c,
                   PersonOtherCity, PersonOtherPostalCode, PersonOtherState,
                   Lived_in_Home_Address_2_Year_or_Less__c, Is_Mailing_Home_Address_Different__c,
                   Monthly_Mortgage_or_Rent_Payment__c, Housing_Type__c,
                   Less_than_2yrs_Street_Address__c, Less_than_2yrs_Apt_Num__c,
                   Less_than_2yrs_City__c, Less_than_2yrs_State__c, Less_than_2yrs_Zip_Code__c,
                   PersonMailingStreet, PersonMailing_Apt__c, PersonMailingCity,
                   PersonMailingPostalCode, PersonMailingState, Marital_Status__c,
                   Spouse_Name__c, Spouse_Address__c, Is_Co_Applicant_Spouse__c,
                   PersonContactId, Is_Registration_Completed__c, Client_Portal_US_State__c,
                   Is_DNL_Portal_Disclosure_Completed__c, Is_DNL_Portal_Disclosure_Declined__c,
                   IsCustomerPortal, Is_DNL_Portal_Notice_Completed__c
                   FROM Account
                   WHERE Id=: userInstance.accountId];
        }
        
        if(acc.Id != null) {
            for(fsCore__Financial__c income : [SELECT Id, fsCore__Financial_Type__c,
                                               fsCore__Stated_Amount__c,
                                               Employment_Less_Than_1_Year__c,
                                               Is_Primary_Income__c,
                                               fsCore__Contact_Name__c,
                                               fsCore__Account_Name__c,
                                               Employment_Name__c, fsCore__Frequency__c,
                                               Previous_Employment_Name__c,
                                               Start_Date__c, fsCore__Is_Active__c
                                               FROM fsCore__Financial__c
                                               WHERE (fsCore__Account_Name__c =: acc.Id OR
                                                      fsCore__Contact_Name__c =: acc.Id)
                                               AND recordTypeId =: recordTypeId
                                               AND fsCore__Is_Active__c = true
                                               ORDER BY CreatedDate DESC
                                               LIMIT 5]) {
                                                   
                ClientPortal_DNLIncomeWrapper.IncomeWrapper incomewrapper =
                    new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
                if(income.Is_Primary_Income__c) {
                    incomewrapper.income = income;
                    if(income.Employment_Name__c != null) {
                        incomewrapper.employment = [SELECT Id, fsCore__Employer_Name__c, fsCore__Title__c,
                                                    fsCore__Start_Date__c, Is_Primary_Employment__c,
                                                    fsCore__Salary__c
                                                    FROM fsCore__Employment__c
                                                    WHERE Id =: income.Employment_Name__c];
                        
                    } else {
                        incomewrapper.employment = new fsCore__Employment__c();
                    }
                    if(income.Previous_Employment_Name__c != null) {
                        incomewrapper.previousEmployment = [SELECT Id, fsCore__Employer_Name__c,
                                                            fsCore__Title__c, fsCore__Salary__c,
                                                            fsCore__Start_Date__c,
                                                            fsCore__End_Date__c, fsCore__Street__c,
                                                            fsCore__City__c, fsCore__State__c
                                                            FROM fsCore__Employment__c
                                                            WHERE Id =: income.Previous_Employment_Name__c];
                    } else {
                        incomewrapper.previousEmployment = new fsCore__Employment__c();
                    }
                    primaryIncomeWrapper = incomewrapper;
                } else {
                    incomewrapper.income = income;
                    if(income.Employment_Name__c != null) {
                        incomewrapper.employment = [SELECT Id, fsCore__Employer_Name__c, fsCore__Title__c,
                                                    fsCore__Start_Date__c, fsCore__Salary__c
                                                    FROM fsCore__Employment__c
                                                    WHERE Id =: income.Employment_Name__c];
                    } else {
                        incomewrapper.employment = new fsCore__Employment__c();
                    }
                    if(income.Previous_Employment_Name__c != null) {
                        incomewrapper.previousEmployment = [SELECT Id, fsCore__Employer_Name__c,
                                                            fsCore__Title__c, fsCore__Salary__c,
                                                            fsCore__Start_Date__c,
                                                            fsCore__End_Date__c, fsCore__Street__c,
                                                            fsCore__City__c, fsCore__State__c
                                                            FROM fsCore__Employment__c
                                                            WHERE Id =: income.Previous_Employment_Name__c];
                    } else {
                        incomewrapper.previousEmployment = new fsCore__Employment__c();
                    }
                    additionalIncomes.add(incomewrapper);
                }
            }
        }
        ClientPortal_DNLIncomeWrapper dnlIncomeWrapper = new ClientPortal_DNLIncomeWrapper();
        Opportunity[] oppDetails = [SELECT Id, AccountId, Co_Applicant_Name__c, Portfolio_Type__c, Applicant_Phone__c
                                    FROM Opportunity
                                    WHERE 
                                        (AccountId =: acc.Id
                                            OR 
                                        Co_Applicant_Name__r.Id =: acc.Id)
                                    AND StageName =: ClientPortal_Constants.DNL_OPP_STAGE_REG_IN_PROGRESS
                                    ORDER BY LastModifiedDate DESC
                                    LIMIT 1];
        if(oppDetails.size() > 0){
            dnlIncomeWrapper.opty = oppDetails[0];
        }
        
        // get Liabilities details 
        Id liabilityRecordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Liability') ;
        Id contactId = getContactForAccount(acc.Id) ;
        List<fsCore__Financial__c> getLiabilitiesForAccount = getLiabilitiesListForAccount(acc.Id, contactId, liabilityRecordTypeId) ;
        
        if(!getLiabilitiesForAccount.isEmpty()) {
            acc.Housing_Type__c = getLiabilitiesForAccount[0].Housing_Type__c ;
            acc.Monthly_Mortgage_or_Rent_Payment__c = getLiabilitiesForAccount[0].fsCore__Stated_Amount__c  ;
        } else{
            acc.Housing_Type__c = '';
            acc.Monthly_Mortgage_or_Rent_Payment__c = null ;
        } 
        
        dnlIncomeWrapper.acc = acc;
        if(primaryIncomeWrapper.income == null){
            primaryIncomeWrapper.income = new fsCore__Financial__c();
            primaryIncomeWrapper.employment = new fsCore__Employment__c();
            primaryIncomeWrapper.previousEmployment = new fsCore__Employment__c();
        }
        dnlIncomeWrapper.primaryIncome = primaryIncomeWrapper;
        dnlIncomeWrapper.additionalIncomes = additionalIncomes;
        return dnlIncomeWrapper;
    }
    
    public static Id getContactForAccount(Id accountId) {
        try {
            Contact contactForAccount = [SELECT Id, Name FROM Contact WHERE AccountId = :accountId] ;
            return contactForAccount.Id ;
        } catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
        }
        return null ;
        
    }
    
    public static List<fsCore__Financial__c> getLiabilitiesListForAccount (Id accountId, Id contactId , Id liabilityRecordTypeId) {
        
        
        List<fsCore__Financial__c> getLiabilitiesForAccount = [SELECT Id, RecordTypeId,fsCore__Account_Name__c, Name, Housing_Type__c, fsCore__Verified_Amount__c, fsCore__Stated_Amount__c 
                                                               FROM fsCore__Financial__c
                                                               WHERE RecordTypeId = :liabilityRecordTypeId AND (fsCore__Account_Name__c = :accountId OR fsCore__Contact_Name__c = :contactId)
                                                               AND fsCore__Financial_Type__c =: FINANCIAL_TYPE_DEFAULT_STR] ;
        return getLiabilitiesForAccount ;
    }
    
    private static void handleMortagePaymentScenario(Account accountDetails) {
        Id liabilityRecordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Liability') ;
        Id contactId = getContactForAccount(accountDetails.Id) ;
        fsCore__Financial__c newLiabilityForAccount ;
        
        List<fsCore__Financial__c> getLiabilitiesForAccount = getLiabilitiesListForAccount(accountDetails.Id, contactId, liabilityRecordTypeId) ;
        
        if(getLiabilitiesForAccount.isEmpty()) {
            // if list is empty create a new record for lianility
            newLiabilityForAccount = new fsCore__Financial__c();
            newLiabilityForAccount.RecordTypeId = liabilityRecordTypeId ;
            newLiabilityForAccount.fsCore__Account_Name__c = accountDetails.Id ;
            newLiabilityForAccount.fsCore__Contact_Name__c= contactId ;
            newLiabilityForAccount.fsCore__Financial_Family__c = FINANCIAL_FMAILY_DEFAULT_STR ;
            newLiabilityForAccount.fsCore__Financial_Type__c = FINANCIAL_TYPE_DEFAULT_STR ;
            newLiabilityForAccount.fsCore__Frequency__c = FREQUENCY_DEFAULT_STR ;
        } else{
            // update the existing record
            newLiabilityForAccount = getLiabilitiesForAccount[0] ; 
        }
        
        newLiabilityForAccount.Housing_Type__c = accountDetails.Housing_Type__c  ;
        newLiabilityForAccount.fsCore__Stated_Amount__c   = accountDetails.Monthly_Mortgage_or_Rent_Payment__c ;
        
        upsert newLiabilityForAccount ;
    }
    
    @AuraEnabled
    public static String updateAccountPersonalInformation(Account accountDetails) {
        String result = 'Success';
        try{

            Account IsValidCustomer = [SELECT Id , IsCustomerPortal FROM Account WHERE Id = :accountDetails.Id limit 1];
            if (!IsValidCustomer.IsCustomerPortal){
                String errorMessage = 'Your account is not active, please contact us at (855)-219-5338 for assistance';
                 return errorMessage;
            }
            // handle Monthly Rent/Mortgage Payment
            if(String.isNotBlank(String.valueOf(accountDetails.Monthly_Mortgage_or_Rent_Payment__c)) && String.isNotBlank(accountDetails.Housing_Type__c) ){
                handleMortagePaymentScenario(accountDetails) ;
            }
            
            // handle Person Other Appartment update
            if(String.isNotBlank(accountDetails.Person_Other_Appartment__c) && String.isNotBlank(accountDetails.PersonOtherStreet) ){
                
                if(accountDetails.PersonOtherStreet.contains('APT') && (!accountDetails.PersonOtherStreet.contains(accountDetails.Person_Other_Appartment__c))){
                    
                    accountDetails.PersonOtherStreet = accountDetails.PersonOtherStreet.split(',  APT ')[0] + ',  APT  ' + accountDetails.Person_Other_Appartment__c;
                    
                }else if(! (accountDetails.PersonOtherStreet.contains('APT'))) {
                    
                    accountDetails.PersonOtherStreet = accountDetails.PersonOtherStreet + ',  APT  ' + accountDetails.Person_Other_Appartment__c;
                    
                }
            } else if(String.isBlank(accountDetails.Person_Other_Appartment__c) && String.isNotBlank(accountDetails.PersonOtherStreet)  && accountDetails.PersonOtherStreet.contains(',  APT  ' + accountDetails.Person_Other_Appartment__c)){
                
                accountDetails.PersonOtherStreet = accountDetails.PersonOtherStreet.split(',  APT ')[0];
                
            }
            
            // handle Less than 2yrs Appartment update
            if(String.isNotBlank(accountDetails.Less_than_2yrs_Apt_Num__c) && String.isNotBlank(accountDetails.Less_than_2yrs_Street_Address__c) ){
                
                if(accountDetails.Less_than_2yrs_Street_Address__c.contains('APT') && (!accountDetails.Less_than_2yrs_Street_Address__c.contains(accountDetails.Less_than_2yrs_Apt_Num__c))){
                    
                    accountDetails.Less_than_2yrs_Street_Address__c = accountDetails.Less_than_2yrs_Street_Address__c.split(',  APT ')[0] + ',  APT  ' + accountDetails.Less_than_2yrs_Apt_Num__c;
                    
                }else if(! (accountDetails.Less_than_2yrs_Street_Address__c.contains('APT'))) {
                    
                    accountDetails.Less_than_2yrs_Street_Address__c = accountDetails.Less_than_2yrs_Street_Address__c + ',  APT  ' + accountDetails.Less_than_2yrs_Apt_Num__c;
                    
                }
            } else if(String.isBlank(accountDetails.Less_than_2yrs_Apt_Num__c) && String.isNotBlank(accountDetails.Less_than_2yrs_Street_Address__c)  && accountDetails.Less_than_2yrs_Street_Address__c.contains(',  APT  ' + accountDetails.Less_than_2yrs_Apt_Num__c)){
                
                accountDetails.Less_than_2yrs_Street_Address__c = accountDetails.Less_than_2yrs_Street_Address__c.split(',  APT ')[0];
                
            }
            
            // handle Person Mailing Appartment update
            if(String.isNotBlank(accountDetails.PersonMailing_Apt__c) && String.isNotBlank(accountDetails.PersonMailingStreet) ){
                
                if(accountDetails.PersonMailingStreet.contains('APT') && (!accountDetails.PersonMailingStreet.contains(accountDetails.PersonMailing_Apt__c))){
                    
                    accountDetails.PersonMailingStreet = accountDetails.PersonMailingStreet.split(',  APT ')[0] + ',  APT  ' + accountDetails.PersonMailing_Apt__c;
                    
                }else if(! (accountDetails.PersonMailingStreet.contains('APT'))) {
                    
                    accountDetails.PersonMailingStreet = accountDetails.PersonMailingStreet + ',  APT  ' + accountDetails.PersonMailing_Apt__c;
                    
                }
            } else if(String.isBlank(accountDetails.PersonMailing_Apt__c) && String.isNotBlank(accountDetails.PersonMailingStreet)  && accountDetails.PersonMailingStreet.contains(',  APT  ' + accountDetails.PersonMailing_Apt__c)){
                
                accountDetails.PersonMailingStreet = accountDetails.PersonMailingStreet.split(',  APT ')[0];
                
            }
            
            update accountDetails;
        }catch(Exception e) {
            result = e.getMessage();
        }
        return result;
    }
    
    @AuraEnabled
    public static String updateIncomeInformation(String dnlIncomeWrapperString,
                                                 String additionalIncomesString) {
                                                     
                                                     User currentUser = [SELECT Id , Account.IsCustomerPortal 
                                                                                FROM User WHERE Id = :UserInfo.getUserId() 
                                                                                limit 1];
                                                     if (!currentUser.Account.IsCustomerPortal){
                                                         String errorMessage = 'Your account is not active, please contact us at (855)-219-5338 for assistance';
                                                         return errorMessage;
                                                     }
                                                     
                                                     
                                                     String result = 'Success';
                                                     
                                                     Savepoint sp = Database.setSavepoint();
                                                     
                                                     System.debug('@@dnlIncomeWrapperString'+dnlIncomeWrapperString);
                                                     System.debug('@@additionalIncomesString'+additionalIncomesString);
                                                     
                                                     ClientPortal_DNLIncomeWrapper dnlIncomeWrapper = new ClientPortal_DNLIncomeWrapper();
                                                     List<ClientPortal_DNLIncomeWrapper.IncomeWrapper> additionalIncomes = new List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>();
                                                     
                                                     if(String.isNotBlank(dnlIncomeWrapperString)) {
                                                         dnlIncomeWrapper =
                                                             (ClientPortal_DNLIncomeWrapper)JSON.deserialize(dnlIncomeWrapperString, ClientPortal_DNLIncomeWrapper.class);
                                                     }
                                                     if(String.isNotBlank(additionalIncomesString)) {
                                                         additionalIncomes =
                                                             (List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>)JSON.deserialize(additionalIncomesString,
                                                                                                                                 List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>.class);
                                                     }
                                                     
                                                     
                                                     fsCore__Financial__c primaryIncome = new fsCore__Financial__c();
                                                     fsCore__Employment__c primaryEmployment = new fsCore__Employment__c();
                                                     fsCore__Employment__c primaryPreviousEmployment = new fsCore__Employment__c();
                                                     List<fsCore__Financial__c> incomeListToInsert = new List<fsCore__Financial__c>();
                                                     //List<fsCore__Financial__c> additionalIncomeList = new List<fsCore__Financial__c>();
                                                     try {
                                                         if(dnlIncomeWrapper.primaryIncome != null) {
                                                             if(String.isNotBlank(dnlIncomeWrapper.primaryIncome.income.fsCore__Financial_Type__c)) {
                                                                 primaryIncome = dnlIncomeWrapper.primaryIncome.income;
                                                                 primaryIncome.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
                                                                 primaryIncome.Is_Primary_Income__c = true;
                                                                 if(dnlIncomeWrapper.primaryIncome.income.fsCore__Frequency__c != null && dnlIncomeWrapper.primaryIncome.income.fsCore__Frequency__c.trim() != ''){
                                                                    primaryIncome.fsCore__Frequency__c = dnlIncomeWrapper.primaryIncome.income.fsCore__Frequency__c;
                                                                 }else{
                                                                    primaryIncome.fsCore__Frequency__c = 'Annual';
                                                                 }
                                                                 primaryIncome.fsCore__Account_Name__c = dnlIncomeWrapper.acc.Id;
                                                                 primaryIncome.fsCore__Contact_Name__c = dnlIncomeWrapper.acc.PersonContactId;
                                                                 primaryIncome.fsCore__Is_Active__c = true;
                                                             }
                                                             if(String.isNotBlank(dnlIncomeWrapper.primaryIncome.employment.fsCore__Employer_Name__c)) {
                                                                 primaryEmployment = dnlIncomeWrapper.primaryIncome.employment;
                                                                 primaryEmployment.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Employment__c', 'Employed');
                                                                 primaryEmployment.fsCore__Start_Date__c = dnlIncomeWrapper.primaryIncome.income.Start_Date__c;
                                                                 primaryEmployment.fsCore__Salary__c = primaryIncome.fsCore__Stated_Amount__c;
                                                                 primaryEmployment.Is_Primary_Employment__c = true;
                                                                 if(String.isBlank(primaryEmployment.Id)) {
                                                                     primaryEmployment.fsCore__Contact_Name__c = dnlIncomeWrapper.acc.PersonContactId;
                                                                 }
                                                                 System.debug('@@primaryEmployment'+primaryEmployment);
                                                                 upsert primaryEmployment;
                                                                 primaryIncome.Employment_Name__c = primaryEmployment.Id;
                                                             } else {
                                                                 primaryIncome.Employment_Name__c = null;
                                                             }
                                                             if(String.isNotBlank(dnlIncomeWrapper.primaryIncome.previousEmployment.fsCore__Employer_Name__c)) {
                                                                 primaryPreviousEmployment = dnlIncomeWrapper.primaryIncome.previousEmployment;
                                                                 primaryPreviousEmployment.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Employment__c', 'Employed');
                                                                 if(String.isBlank(primaryPreviousEmployment.Id)) {
                                                                     primaryPreviousEmployment.fsCore__Contact_Name__c = dnlIncomeWrapper.acc.PersonContactId;
                                                                 }
                                                                 System.debug('@@primaryPreviousEmployment'+primaryPreviousEmployment);
                                                                 upsert primaryPreviousEmployment;
                                                                 primaryIncome.Previous_Employment_Name__c = primaryPreviousEmployment.Id;
                                                             } else {
                                                                 primaryIncome.Previous_Employment_Name__c = null;
                                                             }
                                                             System.debug('@@primaryIncome'+primaryIncome);
                                                             //upsert primaryIncome;
                                                             incomeListToInsert.add(primaryIncome);
                                                         }
                                                         
                                                         for(ClientPortal_DNLIncomeWrapper.IncomeWrapper incomeWrapper : additionalIncomes) {
                                                             fsCore__Financial__c additionalIncome = new fsCore__Financial__c();
                                                             fsCore__Employment__c additionalEmployment = new fsCore__Employment__c();
                                                             if(String.isNotBlank(incomeWrapper.income.fsCore__Financial_Type__c)) {
                                                                 additionalIncome = incomeWrapper.income;
                                                                 additionalIncome.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
                                                                 if(incomeWrapper.income.fsCore__Frequency__c != null &&  incomeWrapper.income.fsCore__Frequency__c != ''){
                                                                    additionalIncome.fsCore__Frequency__c = incomeWrapper.income.fsCore__Frequency__c;
                                                                 }else{
                                                                    additionalIncome.fsCore__Frequency__c = 'Annual';
                                                                 }
                                                                 
                                                                 additionalIncome.fsCore__Account_Name__c = dnlIncomeWrapper.acc.Id;
                                                                 additionalIncome.fsCore__Contact_Name__c = dnlIncomeWrapper.acc.PersonContactId;
                                                                 additionalIncome.fsCore__Is_Active__c = true;
                                                             }
                                                             if(String.isNotBlank(incomeWrapper.employment.fsCore__Employer_Name__c)) {
                                                                 additionalEmployment = incomeWrapper.employment;
                                                                 additionalEmployment.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Employment__c', 'Employed');
                                                                 additionalEmployment.fsCore__Start_Date__c = incomeWrapper.income.Start_Date__c;
                                                                 if(String.isBlank(additionalEmployment.Id)) {
                                                                     additionalEmployment.fsCore__Contact_Name__c = dnlIncomeWrapper.acc.PersonContactId;
                                                                 }
                                                                 additionalEmployment.fsCore__Salary__c = incomeWrapper.income.fsCore__Stated_Amount__c;
                                                                 upsert additionalEmployment;
                                                                 additionalIncome.Employment_Name__c = additionalEmployment.Id;
                                                             } else {
                                                                 additionalIncome.Employment_Name__c = null;
                                                             }
                                                             incomeListToInsert.add(additionalIncome);
                                                         }
                                                         System.debug('@@additionalIncomeListUpsert'+ incomeListToInsert);
                                                         if(!incomeListToInsert.isEmpty()){
                                                            upsert incomeListToInsert;
                                                         }                                                         
                                                     } catch (Exception e) {
                                                         Database.rollback(sp);
                                                         result = e.getMessage();
                                                     }
                                                     return result;
                                                 }
    
    @AuraEnabled
    public static String deleteAdditionalIncomeInformation(Id additionalIncomeId,
                                                           Id additionalEmploymentId) {
                                                               String result = 'Success';
                                                               try {
                                                                   if(additionalIncomeId != null ) {
                                                                       fsCore__Financial__c income = new fsCore__Financial__c(Id = additionalIncomeId);
                                                                       delete income;
                                                                   }
                                                                   if(additionalEmploymentId != null){
                                                                       fsCore__Employment__c employment = new fsCore__Employment__c(Id = additionalEmploymentId);
                                                                       delete employment;
                                                                   }
                                                               }catch(Exception e){
                                                                   result = e.getMessage();
                                                               }
                                                               return result;
                                                           }
    
    
    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id accountId) {
        
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId
                                          FROM ContentDocumentLink
                                          WHERE LinkedEntityId = :accountId];
        if (CDLs.size() < 1) return new List<ContentDocument>();
        
        // Make a List of ContentDocument IDs
        List <Id> CDIdList = new List <Id> ();
        for (ContentDocumentLink nextCDL : CDLs) {
            CDIdList.add(nextCDL.ContentDocumentId);
        }
        
        List<ContentDocument> entries = [SELECT Id, Title, FileType, ContentModifiedDate
                                         FROM ContentDocument
                                         WHERE ContentDocument.Id IN :CDIdList];
        return entries;
    }
	
	
        
    private static void deleteAttchmentsForApplicant(Id opportunityId, String fileName) {

        String fileNameLikeStr = '%'+fileName+'%' ;
        List<ContentDocumentLink> contentDocLinkList = [SELECT Id, ContentDocumentId, ContentDocument.Title, LinkedEntityId 
                                                        FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId = :opportunityId
                                                        AND ContentDocument.Title LIKE : fileNameLikeStr
                                                       ] ;
		System.debug('@@contentDocLinkList' + contentDocLinkList.size());
        if(contentDocLinkList.isEmpty()) {
            return ;
        }
		System.debug('@@after return');
        List<ContentDocument> contentDocumentListToDelete = new List <ContentDocument> () ;
        for(ContentDocumentLink cdlObj : contentDocLinkList) {
            contentDocumentListToDelete.add(new ContentDocument(Id = cdlObj.ContentDocumentId)) ;
        }
        if(! contentDocumentListToDelete.isEmpty()){
            delete contentDocumentListToDelete ;
        }
    }
        
    public static void attachAgreementsToOpportunity(Id opportunityId, String accountName, String oppNumber, String portfolio){
        String dnlSummaryPagefileName = accountName +'_'+ oppNumber + '_Summary' ;
        String dnlCPAPagefileName = accountName +'_'+ oppNumber + '_CPA';
        String dnlESIGNPagefileName = accountName +'_'+ oppNumber + '_ESIGN';
        String dnlTCPAPagefileName = accountName +'_'+ oppNumber + '_TCPA';
        String dnlRDAPagefileName = accountName +'_'+ oppNumber + '_RDA';
        String fileExtesion = '.pdf' ;

        deleteAttchmentsForApplicant( opportunityId , accountName +'_'+ oppNumber) ;

        List<ContentVersion> contentVersionList = new List<ContentVersion>() ;
        Blob dnlFilePageBody;
        PageReference dnlPageReference = new PageReference (ClientPortal_Constants.DNL_SUMMARY_PAGE_URL);

        if(Test.isRunningTest()){
            String tempString = 'Test content';
            dnlFilePageBody = Blob.valueOf(tempString);
        }else{
            dnlFilePageBody = dnlPageReference.getContentAsPDF();
        }
        // create DNL Summary file
        contentVersion obj = createContentVersionObj(dnlSummaryPagefileName, fileExtesion, dnlFilePageBody) ;

        contentVersionList.add(obj) ;
        
        
        dnlPageReference = new PageReference (getDownloadAgreementURI('CPA',portfolio));

        if(Test.isRunningTest()){
            String tempString = 'Test content';
            dnlFilePageBody = Blob.valueOf(tempString);
        }else{
            dnlFilePageBody = dnlPageReference.getContentAsPDF();
        }
        // create DNL CPA file
        contentVersionList.add(createContentVersionObj(dnlCPAPagefileName, fileExtesion, dnlFilePageBody)) ;
        
        dnlPageReference = new PageReference (getDownloadAgreementURI('ESIGN',portfolio));

        if(Test.isRunningTest()){
            String tempString = 'Test content';
            dnlFilePageBody = Blob.valueOf(tempString);
        }else{
            dnlFilePageBody = dnlPageReference.getContentAsPDF();
        }
        // create DNL ESIGN file
        contentVersionList.add(createContentVersionObj(dnlESIGNPagefileName, fileExtesion, dnlFilePageBody)) ;
        
        dnlPageReference = new PageReference (getDownloadAgreementURI('TCPA',portfolio));

        if(Test.isRunningTest()){
            String tempString = 'Test content';
            dnlFilePageBody = Blob.valueOf(tempString);
        }else{
            dnlFilePageBody = dnlPageReference.getContentAsPDF();
        }
        // create DNL ESIGN file
        contentVersionList.add(createContentVersionObj(dnlTCPAPagefileName, fileExtesion, dnlFilePageBody)) ;
        if(portfolio != 'Timberline'){
            dnlPageReference = new PageReference (getDownloadAgreementURI('RDA',portfolio));
            if(Test.isRunningTest()){
                String tempString = 'Test content';
                dnlFilePageBody = Blob.valueOf(tempString);
            }else{
                dnlFilePageBody = dnlPageReference.getContentAsPDF();
            }
            // create DNL ESIGN file
            contentVersionList.add(createContentVersionObj(dnlRDAPagefileName, fileExtesion, dnlFilePageBody)) ;
            //insert documents
        }
        if(contentVersionList.isEmpty()){
            return ;
        }
        insert contentVersionList ;
        
        // attach files to parent
        attachFiletoParent(contentVersionList , opportunityId) ;
    }
    
    private static ContentVersion createContentVersionObj(String fileName, String fileExtension, Blob disclosureBody){
        ContentVersion contentVersnObj = new ContentVersion();
        contentVersnObj.ContentLocation = 'S';
        contentVersnObj.PathOnClient = fileName + fileExtension + '.pdf';
        contentVersnObj.Title = fileName; 
        contentVersnObj.VersionData = disclosureBody;
        //insert contentVersnObj;
        
        return contentVersnObj ;
    }
    
    @TestVisible
    private static void attachFiletoParent(List<ContentVersion> contentVersionList , Id parentId) {
        //Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersnObj.Id].ContentDocumentId;
        List<ContentDocumentLink> conDocLinkToInsert = new List<ContentDocumentLink>() ;
        ContentDocumentLink disclosureLink ;
        
        for(ContentVersion conVerObj : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionList]) {
            
            disclosureLink = new ContentDocumentLink();
            disclosureLink.ContentDocumentId = conVerObj.ContentDocumentId;
            disclosureLink.LinkedEntityId = parentId; 
            disclosureLink.ShareType = 'I';
            
            conDocLinkToInsert.add(disclosureLink) ;
        }
        
        if(!conDocLinkToInsert.isEmpty()) {
            insert conDocLinkToInsert;
        }
        
    }
    
    
    @AuraEnabled
    public static String updateFinalInformation(Account accountDetails) {
        String result = 'Success';
        Savepoint sp = Database.setSavepoint();
        
        try {

            Account isValidCustomer = [SELECT Id , IsCustomerPortal, Name FROM Account WHERE Id = :accountDetails.Id limit 1];
            if (!isValidCustomer.IsCustomerPortal){
                String errorMessage = 'Your account is not active, please contact us at (855)-219-5338 for assistance';
                 return errorMessage;
            }
            accountDetails.Is_Registration_Completed__c = true;
            update accountDetails;
            
            Opportunity[] opp = [SELECT Id, Name, StageName, OwnerId, Opportunity_Number__c,
                                 Co_Applicant_Name__c, Portfolio_Type__c,
                                 Co_Applicant_Name__r.Is_Registration_Completed__c,
                                 Account.Is_Registration_Completed__c
                                 FROM Opportunity
                                 WHERE (AccountId =: accountDetails.Id OR
                                        Co_Applicant_Name__c =: accountDetails.Id)
                                 AND StageName = 'Registration In Progress'];

            
            
            if(!opp.isEmpty()) {
                if(opp[0].Co_Applicant_Name__c != null) {
                    if(opp[0].Co_Applicant_Name__r.Is_Registration_Completed__c &&
                       opp[0].Account.Is_Registration_Completed__c) {
                           opp[0].StageName = 'Portal Verification Complete';
                           update opp;
                           
                           Task taskInstance = new Task();
                           taskInstance.Subject = opp[0].Name +' has completed their application';
                           taskInstance.WhatId = opp[0].Id;
                           taskInstance.Status = 'Not Started';
                           taskInstance.OwnerId = opp[0].OwnerId;
                           taskInstance.Description = 'DNL Portal Application Submission';
                           taskInstance.ActivityDate = System.today();
                           taskInstance.Priority = 'Normal';
                           insert taskInstance;
                       }
                } else {
                    opp[0].StageName = 'Portal Verification Complete';
                    update opp;
                    
                    Task taskInstance = new Task();
                    taskInstance.Subject = opp[0].Name +' has completed their application';
                    taskInstance.WhatId = opp[0].Id;
                    taskInstance.Status = 'Not Started';
                    taskInstance.OwnerId = opp[0].OwnerId;
                    taskInstance.Description = 'DNL Portal Application Submission';
                    taskInstance.ActivityDate = System.today();
                    taskInstance.Priority = 'Normal';
                    insert taskInstance;
                }
                attachAgreementsToOpportunity(opp[0].Id, isValidCustomer.Name, opp[0].Opportunity_Number__c, opp[0].Portfolio_Type__c) ;
            }
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('Error: ' + e.getMessage());
            System.debug('Error: ' + e.getStackTraceString());
            result = e.getMessage();
        }
        return result;
    }
    
    @AuraEnabled
    public static String updateUserDisclosureResponse(Account accountDetails, Boolean isAccepted) {
        String result = 'Success';
        try {
            if(isAccepted) {
                accountDetails.Is_DNL_Portal_Disclosure_Completed__c = true;
            } else {
                accountDetails.Is_DNL_Portal_Disclosure_Completed__c = true;
                accountDetails.Is_DNL_Portal_Disclosure_Declined__c = true;
            }
            
            List<Account> accountsToUpdate = new List<Account>();
            Id dnlReadOnlyRecordType = ClientPortal_Utility.getRecordTypeId('Opportunity', 'Read Only DNL');
            
            if(accountDetails.Id != null && !isAccepted ) {
                Opportunity[] oppDetails = [SELECT Id, AccountId, StageName, Co_Applicant_Name__c
                                            FROM Opportunity
                                            WHERE (AccountId =: accountDetails.Id OR
                                                   Co_Applicant_Name__c =: accountDetails.Id)
                                            AND StageName =: OPP_STAGE_REG_IN_PROGRESS
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1];
                if(!oppDetails.isEmpty()) {
                    oppDetails[0].StageName = 'Closed Lost';
                    oppDetails[0].RecordTypeId = dnlReadOnlyRecordType ;
                    update oppDetails[0];
                    if(String.isNotBlank(oppDetails[0].AccountId)){
                        Account[] primaryAccount = [SELECT Id, IsCustomerPortal
                                                    FROM Account
                                                    WHERE Id =: oppDetails[0].accountId];
                        if(!primaryAccount.isEmpty()){
                            if(primaryAccount[0].IsCustomerPortal){
                                primaryAccount[0].IsCustomerPortal = false;
                                accountsToUpdate.add(primaryAccount[0]);
                            }
                        }
                    }
                    if(String.isNotBlank(oppDetails[0].Co_Applicant_Name__c)){
                        Account[] coAppAccount = [SELECT Id, IsCustomerPortal
                                                  FROM Account
                                                  WHERE Id =: oppDetails[0].Co_Applicant_Name__c];
                        if(!coAppAccount.isEmpty()){
                            if(coAppAccount[0].IsCustomerPortal){
                                coAppAccount[0].IsCustomerPortal = false;
                                accountsToUpdate.add(coAppAccount[0]);
                            }
                        }
                    }
                }
            }
            update accountDetails;
            update accountsToUpdate;
        }catch(Exception e) {
            result = e.getMessage();
        }
        return result;
    }
    
    @AuraEnabled
    public static ClientPortal_DNLIncomeWrapper.IncomeWrapper getIncomeWrapperInstance() {
        
        ClientPortal_DNLIncomeWrapper.IncomeWrapper incomeWrapper = new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
        incomeWrapper.income = new fsCore__Financial__c();
        incomeWrapper.employment = new fsCore__Employment__c();
        incomeWrapper.previousEmployment = new fsCore__Employment__c();
        return incomeWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static string getAgreementURI(String agreementName, String portfolioType){
        String response = 'Error';
        String baseURI = ClientPortal_Constants.DNL_SHOW_AGREEMENT_URI + '?' + ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM + '=';
        if(agreementName != null && agreementName.trim() != ''){
            if(agreementName == 'CPA'){
                response = baseURI + ClientPortal_Constants.DNL_CPA_PARAM;
            }else if(agreementName == 'ESIGN'){
                response = baseURI + ClientPortal_Constants.DNL_ESIGN_PARAM;
            }else if(agreementName == 'TCPA'){
                response = baseURI + ClientPortal_Constants.DNL_TCPA_PARAM;
            }else if(agreementName == 'RDA'){
                response = baseURI + ClientPortal_Constants.DNL_REF_DIS_AUTH + '&' + ClientPortal_Constants.DNL_GEN_AGR_PAGE_PORTFOLIO_TYPE_URI_PARAM + '=' + portfolioType;
            }
        }
        return response;
    }    
    
    public static string getDownloadAgreementURI(String agreementName, String portfolioType){
        String response = 'Error';
        String baseURI = ClientPortal_Constants.DNL_DOWNLOAD_AGREEMENT_URI + '?' + ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM + '=';
        if(agreementName != null && agreementName.trim() != ''){
            if(agreementName == 'CPA'){
                response = baseURI + ClientPortal_Constants.DNL_CPA_PARAM;
            }else if(agreementName == 'ESIGN'){
                response = baseURI + ClientPortal_Constants.DNL_ESIGN_PARAM;
            }else if(agreementName == 'TCPA'){
                response = baseURI + ClientPortal_Constants.DNL_TCPA_PARAM;
            }else if(agreementName == 'RDA'){
                response = baseURI + ClientPortal_Constants.DNL_REF_DIS_AUTH + '&' + ClientPortal_Constants.DNL_GEN_AGR_PAGE_PORTFOLIO_TYPE_URI_PARAM + '=' + portfolioType;
            }
        }
        return response;
    } 
    
    @AuraEnabled
    public static String updateDNLPortalStatusOnAccount(String status, String accountId){
        String returnMessage = 'Error';
        if(accountId != null && accountId.trim() != ''){
            Account accObj = new Account(Id = accountId);
            accObj.DNL_Portal_Status__c = status;
            try{
                update accObj;
                returnMessage = 'Success';
            }catch(Exception e){
                returnMessage = e.getMessage();
            }
        }
        return returnMessage;
    }
}