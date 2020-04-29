@isTest
public class ClientPortal_SelfRegisterCntrlTest {
    @isTest
    static void getUserDetails(){
        setupTestData();
        List<Client_Portal_Portfolio__c> portfolios = ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'VCL');
        portfolios[0].Name = 'VCL';
        insert portfolios;

        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;

        list<Contact> conList = ClientPortal_TestDataFactory.buildContact(account1.Id,'Account');
        insert conList;

        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                                        , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});

        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'VCL', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        

        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'VCL', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        

        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        

        //
        //create contract template (required for PricingOfferAcceptAction)
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;

        //create stage
        fsCore__Stage_Setup__c testStage1 = fsCore.TestHelperWorkflow.createTestStageWithValidationRules('Application Entry'
                                                                                                        , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                                        , fsCore.Constants.LOB_ORIGINATION
                                                                                                        , 1);
        System.assert(testStage1.Id != null, 'Test stage 1 created assert');

        fsCore__Stage_Setup__c testStage2 = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                    , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                    , fsCore.Constants.LOB_ORIGINATION
                                                                                    , 2);
        testStage2.fsCore__Stage_Code__c ='DNL_DOC_PROCESSING';
        testStage2.fsCore__Line_Of_Business__c = 'Origination';
        testStage2.fsCore__Object_Name__c = 'fscore__lending_application__c';
        insert testStage2;
        System.assert(testStage2.Id != null, 'Test stage 2 created assert');


        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup('Test Contract Template'
                                                                                                                        , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                                                        , testPaymentAlloc.Id
                                                                                                                        , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        

        //
        //create pricing setup
        //
        fsCore__Pricing_Setup__c testPricing = fsCore.TestHelperProduct.getTestPricingSetup('Test Pricing'
                                                                                            , fsCore.Constants.PRICING_METHOD_INTEREST_RATE
                                                                                            , 4.00
                                                                                            , 12
                                                                                            , 1);
        testPricing.Is_Generate_Additional_Pricing__c = true;
        testPricing.Payment_Increase_For_Option_1__c = 10;
        testPricing.Payment_Increase_For_Option_2__c = 20;
        insert testPricing;
        System.assert(testPricing.Id != null, 'Test pricing created assert');        

        //Account and Contact for customer
        List<Account> accountToInsert = new List<Account>() ;
        Account testAccount = new Account(FirstName = 'Stark',
        LastName = 'Primary Applicant Account',
        RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),
        PersonEmail = 'agTest@123.com',
        Person_Email__c = 'agTest@123.com',
        PersonBirthdate = system.today().AddDays(-10000),
        nu_dse__Home_Phone__c = '0909080707',
        fsCore__National_Identification_Number__pc = '909080707');
        accountToInsert.add(testAccount);

        //Account for customer co-applicant
        Account testCoAccount = new Account(FirstName = 'Stark',
        LastName = 'Secondary Applicant Account',
        RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),
        PersonEmail = 'agcoTest@123.com',
        Person_Email__c = 'agcoTest@123.com',
        PersonBirthdate = system.today().AddDays(-10000),
        nu_dse__Home_Phone__c = '0909000707',
        fsCore__National_Identification_Number__pc = '909080700');
        accountToInsert.add(testCoAccount);
        insert accountToInsert;
        System.assert(accountToInsert[0].Id != null, 'Test Account created assert');

        Account testAcc = [SELECT Id, PersonContactId FROM Account where Id = :accountToInsert[0].Id] ;
        Account testAcc2 = [SELECT Id, PersonContactId FROM Account where Id = :accountToInsert[1].Id] ;
        //
        //create Lending Application by populating company, branch, product
        //
        list<fsCore__Lending_Application__c> lstLendApp =new list<fsCore__Lending_Application__c>();
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                                                                , testBranch
                                                                                                                , testProduct
                                                                                                                , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = accountToInsert[0].Id;
        testApplication.fsCore__Primary_Customer_Contact__c = testAcc.PersonContactId;
        testApplication.fsCore__Application_Status__c = 'New';
        testApplication.Loan_Type__c = 'VCL';
        lstLendApp.add(testApplication);
        insert lstLendApp;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        List<fsCore__Lending_Application_Customer__c> testApplicantsRecord = new List<fsCore__Lending_Application_Customer__c>() ;
        testApplicantsRecord.add(
                                new fsCore__Lending_Application_Customer__c(
                                                                            fsCore__Lending_Application_Number__c = lstLendApp[0].Id ,
                                                                            fsCore__Account_Name__c = accountToInsert[0].Id,
                                                                            RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Lending_Application_Customer__c','Primary'),
                                                                            fsCore__Contact_Name__c = testAcc.PersonContactId
                                                                            ) 
                                ) ;
        testApplicantsRecord.add(new fsCore__Lending_Application_Customer__c(
                                                                            fsCore__Lending_Application_Number__c = lstLendApp[0].Id ,
                                                                            fsCore__Account_Name__c = accountToInsert[1].Id,
                                                                            fsCore__Contact_Name__c = testAcc2.PersonContactId 
                                                                            ) 
                                ) ;
        insert testApplicantsRecord ;
        ClientPortal_SelfRegisterCntrl.getUserInstance();
        ClientPortal_SelfRegisterCntrl.RegistrationDetailWrapper detailWrapDNL =
            ClientPortal_SelfRegisterCntrl.getRelatedRegistrationDetail('test@test.com', String.valueof(system.today().AddDays(-10000)), '9658', 'DNL');
        ClientPortal_SelfRegisterCntrl.RegistrationDetailWrapper detailWrapVCL =
            ClientPortal_SelfRegisterCntrl.getRelatedRegistrationDetail('test@test.com', String.valueof(system.today().AddDays(-10000)), '9658', 'VCL');
            Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account'];
        User primaryApplicantUser = ClientPortal_TestDataFactory.createUser(primary.PersonContactId, 'VCL Customer Community Login User')[0];
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c, fsCore__Current_Stage_Name__c
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                WHERE fsCore__Account_Name__c = :primary.Id)
                                                                    LIMIT 1];
        ClientPortal_SelfRegisterCntrl.populateRelatedApplicantInfoOnAccount(primary,lendingApplicationList[0].Id);
        ClientPortal_SelfRegisterCntrl.assignPermissionSetForVCL(primaryApplicantUser.Id);
    }
    
    @isTest
    static void isValidPasswordTest(){
        setupTestData();
        ClientPortal_SelfRegisterCntrl.isValidPassword('test@123','test@1234');
        
    }
    
    @isTest
    static void validatePasswordTest(){
        setupTestData();
        User u1 = [SELECT id from User WHERE IsActive = true LIMIT 1];  
        ClientPortal_SelfRegisterCntrl.validatePassword(u1,'test@123','test@123');
        
    }
    @isTest
    static void selfRegisterTest(){
        setupTestData();
        try {
            
          ClientPortal_SelfRegisterCntrl.selfRegister('test@123','test@123', JSON.serialize(ClientPortal_SelfRegisterCntrl.getRelatedRegistrationDetail('test@test.com', String.valueof(system.today().AddDays(-10000)), '9658', 'DNL')), '/test','/apex/ClientPortal_LoginFlow2FAPage?source=userRegistration');
        } catch(Exception e) {
            
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    static void setExperienceIdTest(){
        setupTestData();
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        // account1.IsCustomerPortal = true;
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;
        try {
            
            ClientPortal_SelfRegisterCntrl.setExperienceId(account1.Id);
        } catch(Exception e) {
            
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    static void testSelfRegisterWithProperCredentialsDNL() {
        Client_Portal_Portfolio__c dnlPortfolio = new Client_Portal_Portfolio__c(Name = ClientPortal_SelfRegisterCntrl.DNL_PORTFOLIO , Dispay_Name__c= ClientPortal_SelfRegisterCntrl.DNL_PORTFOLIO, Is_Active__c = true, Profile_Name__c = 'DNL Customer Community Login User');
        insert dnlPortfolio ;
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User dnlUser = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert dnlUser;
        system.runAs(dnlUser) {
            try{
                ClientPortal_SelfRegisterCntrl.selfRegister('test@123','test@123',  JSON.serialize(ClientPortal_SelfRegisterCntrl.getRelatedRegistrationDetail('test@test.com', String.valueof(system.today().AddDays(-10000)), '9658', 'DNL')), '/test','/apex/ClientPortal_LoginFlow2FAPage?source=userRegistration');
            }catch(Exception exp){
                System.debug(exp);
            }
        }
    }
    
    @isTest
    static void testSelfRegisterWithProperCredentialsVCL() {
        createVCLTestData() ;
        
        Client_Portal_Portfolio__c vclPortfolio = new Client_Portal_Portfolio__c(Name = ClientPortal_SelfRegisterCntrl.VCL_PORTFOLIO , Dispay_Name__c= ClientPortal_SelfRegisterCntrl.VCL_PORTFOLIO, Is_Active__c = true, Profile_Name__c = 'VCL Customer Community Login User');
        insert vclPortfolio ;
        
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.LastName = 'Stark Corporation AG1'];
        
        Account acc = [SELECT Id, FirstName, LastName FROM Account WHERE LastName = 'Stark Corporation AG1'];
        
        fsCore__Lending_Application__c testApplication = [Select Id from fsCore__Lending_Application__c 
                                                          where fsCore__Primary_Customer_Contact__c = :con.Id] ;
        
        
        String pId = [SELECT Id FROM Profile WHERE Name = 'VCL Customer Community Login User'].Id; 
        /*User vclUser = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert vclUser;
        system.runAs(vclUser) {*/
            ClientPortal_SelfRegisterCntrl.RegistrationDetailWrapper wrapperObj = ClientPortal_SelfRegisterCntrl.getRelatedRegistrationDetail('agTest@123.com', String.valueof(system.today().AddDays(-10000)), '0707', 'DNL') ;
            wrapperObj.accountPortfolio = ClientPortal_SelfRegisterCntrl.VCL_PORTFOLIO ;
        	wrapperObj.lendingApplication = testApplication ;
        	wrapperObj.accountDetail = acc;
            try{
                ClientPortal_SelfRegisterCntrl.selfRegister('test@123','test@123',  JSON.serialize(wrapperObj), '/test','/apex/ClientPortal_LoginFlow2FAPage?source=userRegistration');
            }catch(Exception e){
                System.debug('Error:' + e);
            }
            
        //}
    }
    
    private static void createVCLTestData(){
      try{
      TestHelperData.createTriggerExecutionTestData();

        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                              , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
            
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        
        
        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                            , 'VCL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);

        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        

        //
        //create contract template (required for PricingOfferAcceptAction)
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;

        //create stage
        fsCore__Stage_Setup__c testStage1 = fsCore.TestHelperWorkflow.createTestStageWithValidationRules('Application Entry'
                                                                                        , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                        , fsCore.Constants.LOB_ORIGINATION
                                                                                        , 1);
        System.assert(testStage1.Id != null, 'Test stage 1 created assert');
        
        fsCore__Stage_Setup__c testStage2 = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                  , 2);
        testStage2.fsCore__Stage_Code__c ='DNL_DOC_PROCESSING';
        testStage2.fsCore__Line_Of_Business__c = 'Origination';
        testStage2.fsCore__Object_Name__c = 'fscore__lending_application__c';
        insert testStage2;
        System.assert(testStage2.Id != null, 'Test stage 2 created assert');


        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
                                                                                ('Test Contract Template'
                                                                               , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                               , testPaymentAlloc.Id
                                                                               , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        

        //
        //create pricing setup
        //
        fsCore__Pricing_Setup__c testPricing = fsCore.TestHelperProduct.getTestPricingSetup('Test Pricing'
                                                                            , fsCore.Constants.PRICING_METHOD_INTEREST_RATE
                                                                            , 4.00
                                                                            , 12
                                                                            , 1);
        testPricing.Is_Generate_Additional_Pricing__c = true;
        testPricing.Payment_Increase_For_Option_1__c = 10;
        testPricing.Payment_Increase_For_Option_2__c = 20;
        insert testPricing;
        System.assert(testPricing.Id != null, 'Test pricing created assert');        

        //Account and Contact for customer
        List<Account> accountToInsert = new List<Account>() ;
        Account testAccount = new Account(FirstName = 'Stark',
                              LastName = 'Stark Corporation AG1',
                              RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),
                                         PersonEmail = 'agTest@123.com',
                                         PersonBirthdate = system.today().AddDays(-10000),
                                         nu_dse__Home_Phone__c = '0909080707',
                                         fsCore__National_Identification_Number__pc = '909080707');
        accountToInsert.add(testAccount);
          
          //Account for customer co-applicant
        Account testCoAccount = new Account(FirstName = 'Stark',
                              LastName = 'Stark CoCorporation AG1',
                              RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),
                                         PersonEmail = 'agcoTest@123.com',
                                         PersonBirthdate = system.today().AddDays(-10000),
                                         nu_dse__Home_Phone__c = '0909000707',
                                         fsCore__National_Identification_Number__pc = '909080700');
        accountToInsert.add(testCoAccount);
        insert accountToInsert;
        System.assert(accountToInsert[0].Id != null, 'Test Account created assert');
          
        Account testAcc = [SELECT Id, PersonContactId FROM Account where Id = :accountToInsert[0].Id] ;

        //
        //create Lending Application by populating company, branch, product
        //
        list<fsCore__Lending_Application__c> lstLendApp =new list<fsCore__Lending_Application__c>();
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = accountToInsert[0].Id;
        testApplication.fsCore__Primary_Customer_Contact__c = testAcc.PersonContactId;
        
        lstLendApp.add(testApplication);
        insert lstLendApp;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
          
          List<fsCore__Lending_Application_Customer__c> testApplicantsRecord = new List<fsCore__Lending_Application_Customer__c>() ;
          testApplicantsRecord.add(
                                    new fsCore__Lending_Application_Customer__c(
                                                    fsCore__Lending_Application_Number__c = lstLendApp[0].Id ,
                                                    fsCore__Account_Name__c = accountToInsert[0].Id,
                                        RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Lending_Application_Customer__c','Primary')
                                    ) 
          ) ;
          testApplicantsRecord.add(
                                    new fsCore__Lending_Application_Customer__c(
                                                    fsCore__Lending_Application_Number__c = lstLendApp[0].Id ,
                                                    fsCore__Account_Name__c = accountToInsert[1].Id 
                                    ) 
          ) ;
          insert testApplicantsRecord ;

      }
      catch(Exception e)
     {
         system.debug('Exception:'+e+e.getLineNumber());
     }
      
  }
    
    @isTest
    static void testGetNullExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), ClientPortal_SelfRegisterCntrl.getExtraFields(null));
    }
    
    @isTest
    static void testGetNonEmptyExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), ClientPortal_SelfRegisterCntrl.getExtraFields('field1'));
    }
    
    /* Verifies validation of extraFields within the Self Registration flow */
    @isTest
    static void testGetExtraFieldsInSelfRegistration() {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > paramsMap = initializeParams();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        //System.assertNotEquals(null, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
    }
    
    private static Map < String, String > initializeParams() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        Date dob = system.today().AddDays(-9000);
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('dob', String.ValueOf(dob));
        paramsMap.put('ssn', '859478598');
        
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
    
    
    
    
    @testSetup
    static void setupTestData() {
        List<Client_Portal_Portfolio__c> portfolios =
            ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'Test');
        insert portfolios;
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;
        
        list<Contact> conList = ClientPortal_TestDataFactory.buildContact(account1.Id,'Account');
        insert conList;
        
        profile prf = [select id, Name from profile where Name='Customer Community User'];
        System.debug('#####prf'+prf);
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        if(account2.IsCustomerPortal)
            account2.PersonBirthdate = system.today().AddDays(-10000);
        account2.nu_dse__SSN__c = '254789658';
        account2.PersonEmail = 'test@test.com';
        account2.fsCore__National_Identification_Number__pc='254789658';
        insert account2;
        
        Client_Portal_Portfolio__c portfolio1 = new Client_Portal_Portfolio__c();
        portfolio1.Name = 'DNL';
        insert portfolio1;
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        insert opp1;
        
        Client_Portal_Portfolio__c portfolio2 = new Client_Portal_Portfolio__c();
        portfolio2.Name = 'DNL';
        insert portfolio2;
        /* Opportunity opp2 = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp2.StageName = 'Open';
        insert opp2; */
    }
    
    @isTest
    private static void testSiteAsContainerEnabled() {
        Boolean isAuthSite = ClientPortal_SelfRegisterCntrl.siteAsContainerEnabled('https://test-versaralending.cs68.force.com/') ;
        System.assertEquals(isAuthSite, true) ;
    }
    
    @isTest
    private static void testGetRelatedRegistrationDetailWithoutOppElse() {
        Account account1 = ClientPortal_TestDataFactory.buildAccount('TestAccount', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '101010101';
        account1.PersonEmail = 'test@test1.com';
        account1.fsCore__National_Identification_Number__pc='101010101';
        insert account1;
        
        ClientPortal_SelfRegisterCntrl.RegistrationDetailWrapper wrapperTest = ClientPortal_SelfRegisterCntrl.getRelatedRegistrationDetail(account1.PersonEmail,String.valueOf(account1.PersonBirthdate),'0101','test') ;
    }
    @isTest
    private static void testConstantsClass() {
        String testStr = '';
        ClientPortal_Constants test = new ClientPortal_Constants();
        testStr = ClientPortal_Constants.DNL_ESIGN_PARAM ;
        testStr = ClientPortal_Constants.DNL_TCPA_PARAM ;
        testStr = ClientPortal_Constants.DNL_CPA_PARAM ;
        testStr = ClientPortal_Constants.DNL_REF_DIS_AUTH ;
        testStr = ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM ;
        testStr = ClientPortal_Constants.DNL_GENERATE_AGREEMENT_LTNG_APP ;
        testStr = ClientPortal_Constants.DNL_GENERIC_AGREEMENT_CMP ;
        testStr = ClientPortal_Constants.DNL_SHOW_AGREEMENT_URI ;
        testStr = ClientPortal_Constants.DNL_DOWNLOAD_AGREEMENT_URI ;
        testStr = ClientPortal_Constants.DNL_OPP_STAGE_REG_IN_PROGRESS ;
        testStr = ClientPortal_Constants.VCL_APPLICANT_INCOME_SCREEN_STATUS ;
        testStr = ClientPortal_Constants.DNL_SUMMARY_PAGE_URL ;
        System.assert(testStr.contains('ClientPortal_DNLHomeSummaryPage')) ;
    }
}