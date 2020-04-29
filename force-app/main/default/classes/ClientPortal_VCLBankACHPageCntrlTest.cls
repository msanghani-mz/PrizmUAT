@isTest
public with sharing class ClientPortal_VCLBankACHPageCntrlTest {
    @TestSetup
    static void makeData(){
        TestHelperData.createTriggerExecutionTestData();

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
        ClientPortal_TestDataFactory.createEmployment(testAcc.PersonContactId);

        fsCore__Employment__c primaryApplicantEmployement = ClientPortal_TestDataFactory.createEmployment(testAcc.PersonContactId);
		fsCore__Employment__c primaryApplicantEmployement2 = ClientPortal_TestDataFactory.createEmployment(testAcc.PersonContactId);
        Id financialRecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c', 'Income');
        List<fsCore__Financial__c> incomeList = new List<fsCore__Financial__c>();
        incomeList.add(ClientPortal_TestDataFactory.buildFinancial('Income', 'Salary', financialRecordTypeId, primaryApplicantEmployement.Id, testAcc.Id, true));
        incomeList.add(ClientPortal_TestDataFactory.buildFinancial('Income', 'Salary', financialRecordTypeId, primaryApplicantEmployement2.Id, testAcc.Id, false));
        
        insert incomeList;
        ClientPortal_TestDataFactory.createApplicationPricingOffer(testApplication.Id, testPricing.Id);
        fsCore__Checklist_Setup__c checkLists = ClientPortal_TestDataFactory.createCheckListSetup();
        fsCore__Lending_Application_Checklist__c checkList = ClientPortal_TestDataFactory.createApplicationChecklist(testAcc.Id, incomeList[0].Id, testApplication.Id, checkLists.Id);
        ClientPortal_TestDataFactory.createBankAccount(testAcc.Id);
        ClientPortal_TestDataFactory.createBankAccount(testAcc2.Id);
    }

    @IsTest static void testGenerateEsignPage(){
        Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account'];
        User primaryApplicantUser = ClientPortal_TestDataFactory.createUser(primary.PersonContactId, 'VCL Customer Community Login User')[0];
        fsCore__Lending_Application_Checklist__c checkList = [Select Id FROM fsCore__Lending_Application_Checklist__c WHERE fsCore__Checklist_Item__c = 'Test Checklist' LIMIT 1];
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c, fsCore__Current_Stage_Name__c
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                WHERE fsCore__Account_Name__c = :primary.Id)
                                                                    LIMIT 1];

        Test.startTest();
            System.runAs(primaryApplicantUser){
                PageReference pageRef = Page.ClientPortal_VCLGenerateEsignPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id',lendingApplicationList[0].id);
                ApexPages.currentPage().getParameters().put('content','eSign');
                ClientPortal_GenerateEsignPDFVCLCntrl controller = new ClientPortal_GenerateEsignPDFVCLCntrl();
            }
        Test.stopTest();
    }
    @IsTest static void testAchPage(){
        Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account'];
        User primaryApplicantUser = ClientPortal_TestDataFactory.createUser(primary.PersonContactId, 'VCL Customer Community Login User')[0];
        fsCore__Lending_Application_Checklist__c checkList = [Select Id FROM fsCore__Lending_Application_Checklist__c WHERE fsCore__Checklist_Item__c = 'Test Checklist' LIMIT 1];
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c, fsCore__Current_Stage_Name__c
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                WHERE fsCore__Account_Name__c = :primary.Id)
                                                                    LIMIT 1];
        fsCore__Bank_Account__c bank = ClientPortal_TestDataFactory.buildBankAccount(primary.Id);

        Test.startTest();
            System.runAs(primaryApplicantUser){
                PageReference pageRef = Page.ClientPortal_VCLBankACHFormPage;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('lendingAppId',lendingApplicationList[0].id);
                ApexPages.currentPage().getParameters().put('bankAccount',JSON.serialize(bank));
                ClientPortal_VCLBankACHPageCntrl controller = new ClientPortal_VCLBankACHPageCntrl();
            }
        Test.stopTest();
    }
}