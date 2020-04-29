/**
* Contains reusable methods to generate test data
* build - instantiates an object without persisting it
* create - builds and persists
*/
@isTest
public with sharing class ClientPortal_TestDataFactory {
    
    public static fsCore__Bank_Account__c buildBankAccount(Id accountId){
        fsCore__Bank_Account__c bankAccount = new fsCore__Bank_Account__c(
            Name = 'Test Bank Account',
            fsCore__Account_Name__c = accountId,
            fsCore__Bank_Account_Holder_Name__c = 'Test Account Holder',
            fsCore__Bank_Account_Number__c = '1234',
            fsCore__Bank_Account_Type__c = 'Saving',
            fsCore__Is_Active__c = true,
            fsCore__Bank_Name__c = 'Test Account',
            Routing_Number__c = '123',
            VCL_Envelope_Id__c = '12345432',
            fsCore__Bank_Identification_Code__c = '1234'
        );
        return bankAccount;
    }

    public static fsCore__Bank_Account__c createBankAccount(Id accountId){
        fsCore__Bank_Account__c bankAccount = buildBankAccount(accountId);
        insert bankAccount;
        return bankAccount;
    }
    
    public static Application_Bank_Account_Verification__c buildAccountVerification(Id lendingAppId){
        Application_Bank_Account_Verification__c verfication = new Application_Bank_Account_Verification__c(
            Verification_Status__c = 'Verified',
            Lending_Application_Name__c = lendingAppId
        );
        return verfication;
    }

    public static Application_Bank_Account_Verification__c createAccountVerification(Id lendingAppId){
        Application_Bank_Account_Verification__c ver = buildAccountVerification(lendingAppId);
        insert ver;
        return ver;
    }

    public static fsCore__Lending_Application_Checklist__c buildApplicationChecklist(Id accountId, Id financeId, Id lendingAppId, Id setupId){
        fsCore__Lending_Application_Checklist__c checkList = new fsCore__Lending_Application_Checklist__c(
            Applicant_Name__c = accountId,
            fsCore__Lending_Application_Number__c = lendingAppId,
            BoxFolderId__c = '34567',
            fsCore__Checklist_Item__c = 'Test Checklist',
            fsCore__Comment__c = 'Test Comment',
            fsCore__Document_Classification__c = 'Identification Document',
            Financial_Name__c = financeId,
            fsCore__Checklist_Item_Type__c = 'Document',
            fsCore__Status__c = 'Pending',
            fsCore__Checklist_Name__c = setupId
        );
        return checkList;
    }

    public static fsCore__Lending_Application_Checklist__c createApplicationChecklist(Id accountId, Id financeId, Id lendingAppId, Id setupId){
        fsCore__Lending_Application_Checklist__c checkList = buildApplicationChecklist(accountId, financeId, lendingAppId, setupId);
        insert checkList;
        return checkList;
    }

    public static fsCore__Checklist_Setup__c buildCheckListSetup(){
        fsCore__Checklist_Setup__c setup = new fsCore__Checklist_Setup__c(
            fsCore__Is_Active__c = true,
            fsCore__Checklist_Code__c = 'Test Code',
            Name = 'Test Setup',
            fsCore__Default_Company_Availability__c = 'Available',
            fsCore__Default_Product_Availability__c = 'Available',
            fsCore__Line_Of_Business__c = 'Origination',
            fsCore__Selection_Order__c = 123
        );
        return setup;
    }

    public static fsCore__Checklist_Setup__c createCheckListSetup(){
        fsCore__Checklist_Setup__c setup = buildCheckListSetup();
        insert setup;
        return setup;
    }

    public static List<Client_Portal_Portfolio__c> buildClientPortalPortfolios(Integer iSize,
                                                                               String name) {
                                                                                   
                                                                                   List<Client_Portal_Portfolio__c> portfolios = new List<Client_Portal_Portfolio__c>();
                                                                                   
                                                                                   for(Integer i = 0; i < iSize; i++){
                                                                                       portfolios.add(new Client_Portal_Portfolio__c(
                                                                                           Name = name + i, Dispay_Name__c= name + i, Is_Active__c = true));
                                                                                   }
                                                                                   return portfolios;
                                                                               }
    
    public static List<Client_Portal_Portfolio__c> createClientPortalPortfolios(Integer iSize,
                                                                                String name) {
                                                                                    
                                                                                    List<Client_Portal_Portfolio__c> portfolios = buildClientPortalPortfolios(iSize, name);
                                                                                    insert portfolios;
                                                                                    return portfolios;
                                                                                }
    
    //TODO - Create Portal Setting Build Method
    
    public static Client_Portal_Settings__c buildClientPortalSetting(Id portfolioId, String recordTypeName) {
        
        Client_Portal_Settings__c portalSettings = new Client_Portal_Settings__c(Is_Active__c = true, 
                                                                                 Client_Portal_Portfolio__c = portfolioId, 
                                                                                 recordTypeId= recordTypeName);
        return portalSettings;
    }
    
    public static fsCore__Lending_Application_Pricing_Offer__c buildApplicationPricingOffer(Id lendingAppId, Id pricingSetupid){
        fsCore__Lending_Application_Pricing_Offer__c offer = new fsCore__Lending_Application_Pricing_Offer__c(
                                                                                                                fsCore__Lending_Application_Number__c = lendingAppId,
                                                                                                                fsCore__Rate__c = 7,
                                                                                                                fsCore__Annual_Percent_Rate__c = 9,
                                                                                                                fsCore__Payment_Amount__c = 87654,
                                                                                                                fsCore__Number_Of_Months__c = 36,
                                                                                                                fsCore__Total_Finance_Charge__c = 2354,
                                                                                                                fsCore__Maturity_Date__c = System.today().addDays(100),
                                                                                                                fsCore__Total_Interest_Amount__c = 234,
                                                                                                                fsCore__Finance_Fee__c = 12,
                                                                                                                fsCore__Loan_Amount__c = 123212,
                                                                                                                fsCore__Prepaid_Fee__c = 1234,
                                                                                                                fsCore__Number_Of_Payments_Monthly__c = 36,
                                                                                                                fsCore__Financed_Amount__c = 76546,
                                                                                                                fsCore__Number_Of_Payments__c = 36,
                                                                                                                fsCore__Pricing_Date__c = System.today().addDays(5),
                                                                                                                fsCore__Pricing_Name__c = pricingSetupid
                                                                                                            );
        return offer;
    }

    public static fsCore__Lending_Application_Pricing_Offer__c createApplicationPricingOffer(Id lendingAppId, Id pricingSetupid){
        fsCore__Lending_Application_Pricing_Offer__c offer = buildApplicationPricingOffer(lendingAppId,pricingSetupid);
        insert offer;
        return offer;
    }

    //TODO - Create Portal Setting Create Method
    public static Client_Portal_Settings__c createClientPortalSetting(Id portfolioId, Id recordTypeName) {
        
        Client_Portal_Settings__c portalSettings = buildClientPortalSetting(portfolioId, recordTypeName);
        insert portalSettings;
        return portalSettings;
    }
    
   //TODO - Create Portal_Identity_Service__c Build Method   
    public static Portal_Identity_Service__c buildPortalIdentityService(String recordTypeName) {
        
        Portal_Identity_Service__c portalIdentityService = new Portal_Identity_Service__c(recordTypeId= recordTypeName);
        return portalIdentityService;
    }
    
    //TODO - Create Portal_Identity_Service__c Create Method
    public static Portal_Identity_Service__c createClientPortalSetting(String recordTypeName) {
        
        Portal_Identity_Service__c portalIdentityService = buildPortalIdentityService(recordTypeName);
        insert portalIdentityService;
        return portalIdentityService;
    }
    
    //TODO - Account Build Method
    public static Account buildAccount(String lastName, String recordTypeName, String homeNumber) {
        Account acc;
        for(Integer i = 1; i < 10; i++){
            acc = new Account(FirstName = 'Test'+i,
                              LastName = lastName,
                              RecordTypeId = recordTypeName,
                              nu_dse__Home_Phone__c = homeNumber);
        }
        return acc;
    }
    
    //TODO - Acccount Create Method
    
    public static Account createAccount(String lastName, String recordTypeName, String homeNumber) {
        
        Account acc = buildAccount(lastName, recordTypeName, homeNumber);
        insert acc;
        return acc;
    }
    //TODO - Opportunity Build Method
    // public static Opportunity buildOpportunity (Id accountId, String recordTypeName, Id importProgramId, Id programId) {
    public static Opportunity buildOpportunity (Id accountId, String recordTypeName) {
        
        Opportunity oppList = new Opportunity(Name = 'Test1',
                                              AccountId = accountId,
                                              RecordTypeId = recordTypeName,
                                              Amount = 1000,
                                              CloseDate = Date.Today()+1,
                                              Import_Id__c='',
                                              Loan_Number_Of_Payments__c=24,
                                              Addnl_Months_with_Loan__c=2,
                                              Application_Signed_Date__c=Date.today(),
                                              DRP_File_Number__c='1234567',
                                              Debt_Count__c=4,
                                              Unsettled_Debt__c=2,
                                              Opportunity_Type__c='DNL',
                                              Is_Do_Not_Call__c=true,
                                              Enrolled_Date__c=Date.today(),
                                              Is_Application_Submitted__c=False,
                                              Import_Program_Id__c = '',
                                              Program_Id__c = '',
                                              Debit_Day_Second__c=30,
                                              Program_Type__c='Test Prg',
                                              Remaining_Months_DRP_Program__c=5,
                                              Program_Number_Of_Payments__c=24
                                             );
        return oppList;
    }
    //TODO - Opportunity Create Method
    
    public static Opportunity createOpportunity(Id accountId, String recordTypeName) {
        
        Opportunity oppList = buildOpportunity(accountId, recordTypeName);
        insert oppList;
        return oppList;
    }
    //TODO - Contact Build Method
    public static List<Contact> buildContact(Id accountId, String lstName) {
        
        List<Contact> conList = new List<Contact>();
        conList.add(new Contact(LastName = lstName));
        return conList;
    }
    //TODO - Contact Create Method
    public static List<Contact> createContact(Id accountId, String lstName) {
        
        List<Contact> conList = buildContact(accountId, lstName);
        insert conList;
        return conList;
    }
    //TODO - fsCore__Financial__c Build Method
    public static fsCore__Financial__c buildFinancial(String financialFamily, String financialType, Id recordTypeId, Id employmentName, Id accountId, Boolean isPrimaryIncome) {
        
        fsCore__Financial__c fnclList = new fsCore__Financial__c(fsCore__Financial_Family__c = financialFamily,
                                              fsCore__Financial_Type__c = financialType,
                                              RecordTypeId = recordTypeId,
                                              Employment_Name__c = employmentName,
                                              fsCore__Frequency__c = 'Monthly',
                                              fsCore__Stated_Amount__c = 1000,
                                              fsCore__Account_Name__c = accountId,
                                              fsCore__Is_Verified__c = true,
                                              fsCore__Verified_Amount__c = 1000,
                                              fsCore__Is_Active__c = true,
                                              fsCore__Is_Include_For_Ratio_Calculation__c = true,
                                              Is_Primary_Income__c = isPrimaryIncome,
                                              Start_Date__c = System.today().addDays(-10)
                                             );
        return fnclList;
    }
    //TODO - fsCore__Financial__c Create Method
    public static fsCore__Financial__c createFinancial(String financialFamily, String financialType, Id recordTypeId, Id employmentName, Id accountId, Boolean isPrimaryIncome) {
        
        fsCore__Financial__c fnclList = buildFinancial(financialFamily, financialType, recordTypeId, employmentName, accountId, isPrimaryIncome);
        insert fnclList;
        return fnclList;
    }

    public static fsCore__Financial__c buildFinancial(String financialFamily, String financialType, Id recordTypeId, Id employmentName, Id accountId) {
        
        fsCore__Financial__c fnclList = new fsCore__Financial__c(fsCore__Financial_Family__c = financialFamily,
                                              fsCore__Financial_Type__c = financialType,
                                              RecordTypeId = recordTypeId,
                                              Employment_Name__c = employmentName,
                                              fsCore__Frequency__c = 'Monthly',
                                              fsCore__Stated_Amount__c = 1000,
                                              fsCore__Account_Name__c = accountId,
                                              fsCore__Is_Verified__c = true,
                                              fsCore__Verified_Amount__c = 1000,
                                              fsCore__Is_Active__c = true,
                                              fsCore__Is_Include_For_Ratio_Calculation__c = true
                                             );
        return fnclList;
    }
    public static fsCore__Financial__c createFinancial(String financialFamily, String financialType, Id recordTypeId, Id employmentName, Id accountId) {
        
        fsCore__Financial__c fnclList = buildFinancial(financialFamily, financialType, recordTypeId, employmentName, accountId);
        insert fnclList;
        return fnclList;
    }

    //TODO - fsCore__Employment__c Build Method
    public static fsCore__Employment__c buildEmployment(Id contactId) {
        
        fsCore__Employment__c employList = new fsCore__Employment__c(fsCore__Contact_Name__c = contactId,
                                                 fsCore__Employer_Name__c = 'Employer',
                                                 fsCore__Title__c = 'dev',
                                                 fsCore__Employment_Type__c = 'Full Time',
                                                 fsCore__Start_Date__c = Date.today(),
                                                 fsCore__End_Date__c = Date.today()+200,
                                                 fsCore__Salary__c = 10000,
                                                 Is_Primary_Employment__c = true
                                                );
        return employList;
    }
    //TODO - fsCore__Employment__c Create Method
    public static fsCore__Employment__c createEmployment(Id contactId) {
        
        fsCore__Employment__c EmployList = buildEmployment(contactId);
        insert EmployList;
        return EmployList;
    }
    //TODO - User Build Method
    //
    public static User buildUser1(Id contactId) {
        Id proflieId = [select id from profile where name='Customer Community User'].id;
        
        User user1 = new User(alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = proflieId, PostalCode = '54896', country='United States',IsActive =true,
                              ContactId = contactId,MobilePhone = '8529637415', State = 'AL',
                              timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        return user1;
    }
    //
    //
    //
    public static List<User> buildUser(Id contactId, String profileName) {
        List<profile> proflieId = [select id from profile where name =: profileName];
        //UserRole userRole = [select Id,DeveloperName, Name from UserRole where Name = 'IT Support'];
        // UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        //  insert r;
        List<User> userList = new List<User>();
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString + randomInt; 
        if(proflieId!=null || proflieId.isEmpty()==false){
            userList.add(new User(alias = 'test123',
                                  email='test@yopmail.com',
                                  emailencodingkey='UTF-8',
                                  lastname='Testing',
                                  languagelocalekey='en_US',
                                  localesidkey='en_US',
                                  profileid = proflieId[0].id,
                                  PostalCode = '54896',
                                  country='United States',
                                  IsActive =true,
                                  ContactId = contactId,
                                  MobilePhone = '8529637415',
                                  timezonesidkey='America/Los_Angeles',
                                  username= uniqueName + '@test' + orgId + '.org'
                                  //UserRoleId = userRole.Id
                                  ));
            return userList;
            
        }
        return null;
    }
    //TODO - User Create Method
    public static List<User> createUser(Id contactId, String profileName) {
        
        List<User> userList = buildUser(contactId, profileName);
        insert userList;
        return userList;
    }
    // to get recordId
    public static Id getRecordTypeId (String objectApi, String recordTypeName) {
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectApi).getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        Id recordTypeId;
        if (recordTypeMap.containsKey(recordTypeName)) {
            
            recordTypeId = recordTypeMap.get(recordTypeName).getRecordTypeId();
            System.debug('**recordTypeId'+recordTypeId);
        }
        return recordTypeId;
    }
    public static User createCommunityUser(Id contactId) {
        
        Id proflieId = [select id from profile where name='Customer Community User'].id;
        
        User user1 = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = proflieId, PostalCode = '54896', country='United States',IsActive =true,
                ContactId = contactId,MobilePhone = '8529637415', State = 'TN',
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        return user1;
    
    }
    public static ContentVersion createContentVersion() {
    
        ContentVersion contentVersionInstance = new ContentVersion(Title = 'xxxx',PathOnClient='image.jpg',VersionData = EncodingUtil.base64Decode('Test'));
        return contentVersionInstance;
    }
    
    public static ContentDocumentLink createContentDocumentLink(Id documentId, Id linkedEntityId) {
    
        ContentDocumentLink contentLink = new ContentDocumentLink(ContentDocumentId = documentId, LinkedEntityId = linkedEntityId, ShareType = 'V', Visibility = 'AllUsers');
        return contentLink;
    }
     public static Task createTask(Id whatId) {
        
        Task taskInstance = new Task( Subject = 'Testing ', 
                                      Description = 'to use it in test class', 
                                      WhatId = whatId, 
                                      Status = 'In Progress',
                                      ActivityDate = System.today() );
        return taskInstance;
    }
}