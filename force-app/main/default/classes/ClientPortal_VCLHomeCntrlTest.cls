@isTest
public without sharing class ClientPortal_VCLHomeCntrlTest {

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
        testApplication.Loan_Type__c = 'VCL';
        testApplication.RecordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Lending_Application__c', 'VCL Loan');
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
        fsCore__Bank_Account__c bankInfo = ClientPortal_TestDataFactory.createBankAccount(testAcc.Id);
        ContentVersion docContent = ClientPortal_TestDataFactory.createContentVersion();
        insert docContent;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:docContent.Id].ContentDocumentId;
        ContentDocumentLink link2 = ClientPortal_TestDataFactory.createContentDocumentLink(conDoc, bankInfo.Id);
        insert link2;
        ClientPortal_TestDataFactory.createBankAccount(testAcc2.Id);
    }

    @IsTest static void testFlowWithPrimary(){
        Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account'];
        User primaryApplicantUser = ClientPortal_TestDataFactory.createUser(primary.PersonContactId, 'VCL Customer Community Login User')[0];
        fsCore__Lending_Application_Checklist__c checkList = [Select Id FROM fsCore__Lending_Application_Checklist__c WHERE fsCore__Checklist_Item__c = 'Test Checklist' LIMIT 1];
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c, fsCore__Current_Stage_Name__c
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                WHERE fsCore__Account_Name__c = :primary.Id)
                                                                    LIMIT 1];

        ContentVersion docContent = ClientPortal_TestDataFactory.createContentVersion();
        insert docContent;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:docContent.Id].ContentDocumentId;

        ContentVersion docContent2 = ClientPortal_TestDataFactory.createContentVersion();
        insert docContent2;
        Id conDoc2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:docContent.Id].ContentDocumentId;
        ContentDocumentLink link2 = ClientPortal_TestDataFactory.createContentDocumentLink(conDoc2, lendingApplicationList[0].Id);
        insert link2;

        ClientPortal_VCLHomeCntrl.DocumentWrapper docWrapper = new ClientPortal_VCLHomeCntrl.DocumentWrapper();
        docWrapper.Name = 'Test';
        docWrapper.documentId = conDoc;
        List<ClientPortal_VCLHomeCntrl.DocumentWrapper> docWrapperList = new List<ClientPortal_VCLHomeCntrl.DocumentWrapper>();
        docWrapperList.add(docWrapper);

        fsCore__Financial__c income = [SELECT Id FROM fsCore__Financial__c WHERE Is_Primary_Income__c = false LIMIT 1];
        fsCore__Employment__c employment = [SELECT Id FROM fsCore__Employment__c WHERE fsCore__Contact_Name__c = :primary.PersonContactId LIMIT 1]; 
        
        ClientPortal_VCLHomeCntrl.BankAccountWrapper bank = new ClientPortal_VCLHomeCntrl.BankAccountWrapper();
        bank.accountHolderName = 'Test Bank Account';
        bank.accountType = 'Saving';
        bank.bankName = 'Test Bank';
        bank.accountNumber = '1234567';
        bank.reAccountNumber = '1234567';
        bank.routingNumber = '98';

        Test.startTest();
            System.runAs(primaryApplicantUser){
                ClientPortal_VCLHomeCntrl.getDefaultValue();
                ClientPortal_VCLHomeCntrl.uploadDocumentToCheckList(checkList.Id, JSON.serialize(docWrapperList), JSON.serialize(primary), false);
                ClientPortal_VCLHomeCntrl.getDocumentsByChecklist(JSON.serialize(checkList));
                ClientPortal_VCLHomeCntrl.deleteAdditionalIncomeInformation(income.Id, employment.Id);
                ClientPortal_VCLHomeCntrl.deleteDocumentFromChecklist(conDoc2, true);
                ClientPortal_VCLHomeCntrl.getBankAccountWrapper(primary.Id);
                ClientPortal_VCLHomeCntrl.redirectToDocuSignURL(primary.Id);
                ClientPortal_VCLHomeCntrl.getCheckLists(lendingApplicationList[0].Id);
                ClientPortal_VCLHomeCntrl.saveBankAccountInfo(primary.Id, bank);
                ClientPortal_VCLHomeCntrl.initiateChecklistCreation(primary);
            }
        Test.stopTest();
    }

    @IsTest static void testFlowWithSecondary(){
        Account secondary = [Select Id, PersonContactId,Person_Email__c, Name FROM Account WHERE LastName = 'Secondary Applicant Account'];
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c, fsCore__Current_Stage_Name__c
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                WHERE fsCore__Account_Name__c = :secondary.Id)
                                                                    LIMIT 1];
        User secondaryApplicantUser = ClientPortal_TestDataFactory.createUser(secondary.PersonContactId, 'VCL Customer Community Login User')[0];
        Id financialRecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c', 'Income');
        
        ClientPortal_VCLHomeCntrl.IncomeWrapper primaryIncomeWrapper = new ClientPortal_VCLHomeCntrl.IncomeWrapper();
        primaryIncomeWrapper.income = ClientPortal_TestDataFactory.buildFinancial('Income', 'Salary', null, null, null, true);
        primaryIncomeWrapper.employment = ClientPortal_TestDataFactory.buildEmployment(null);
        primaryIncomeWrapper.previousEmployment = ClientPortal_TestDataFactory.buildEmployment(null);

        List<ClientPortal_VCLHomeCntrl.IncomeWrapper> secondaryIncomeList = new List<ClientPortal_VCLHomeCntrl.IncomeWrapper>();
		
        ClientPortal_VCLHomeCntrl.IncomeWrapper secondaryIncome = new ClientPortal_VCLHomeCntrl.IncomeWrapper();
        secondaryIncome.income = ClientPortal_TestDataFactory.buildFinancial('Income', 'Salary', null, null, null, false);
        secondaryIncome.employment = ClientPortal_TestDataFactory.buildEmployment(null);
        secondaryIncome.previousEmployment = ClientPortal_TestDataFactory.buildEmployment(null);
        secondaryIncomeList.add(secondaryIncome);

        ContentVersion docContent = ClientPortal_TestDataFactory.createContentVersion();
        insert docContent;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:docContent.Id].ContentDocumentId;
        ContentDocumentLink link = ClientPortal_TestDataFactory.createContentDocumentLink(conDoc, secondary.Id);
        insert link;
        ClientPortal_VCLHomeCntrl.DocumentWrapper docWrapper = new ClientPortal_VCLHomeCntrl.DocumentWrapper();
        docWrapper.Name = 'Test';
        docWrapper.documentId = conDoc;
        List<ClientPortal_VCLHomeCntrl.DocumentWrapper> docWrapperList = new List<ClientPortal_VCLHomeCntrl.DocumentWrapper>();
        docWrapperList.add(docWrapper);

        Test.startTest();
            System.runAs(secondaryApplicantUser){
                ClientPortal_VCLHomeCntrl.deleteDocuments(JSON.serialize(docWrapperList));
                ClientPortal_VCLHomeCntrl.retrieveESignContent();
                ClientPortal_VCLHomeCntrl.attachLoanAgreement(lendingApplicationList[0] , secondary);
                ClientPortal_VCLHomeCntrl.attachMLAAgreement(lendingApplicationList[0] , secondary);
                ClientPortal_VCLHomeCntrl.sendMailWithAttachmentToUser(secondary.PersonContactId, secondary.Id, new List<String> { secondary.Person_Email__c }, 'TestName', Blob.valueof('Some random String')) ;
                ClientPortal_VCLHomeCntrl.updateVCLDisclosureInformation(
                    JSON.serialize(secondary),
                    String.valueOf(lendingApplicationList[0].Id),
                    'TILA',
                    true
                );
                ClientPortal_VCLHomeCntrl.updateVCLDisclosureInformation(
                    JSON.serialize(secondary),
                    String.valueOf(lendingApplicationList[0].Id),
                    'TILA',
                    false
                );
                ClientPortal_VCLHomeCntrl.updateVCLDisclosureInformation(
                    JSON.serialize(secondary),
                    String.valueOf(lendingApplicationList[0].Id),
                    'BankATD',
                    true
                );
                ClientPortal_VCLHomeCntrl.updateVCLDisclosureInformation(
                    JSON.serialize(secondary),
                    String.valueOf(lendingApplicationList[0].Id),
                    'BankATD',
                    false
                );
                ClientPortal_VCLHomeCntrl.updateVCLDisclosureInformation(
                    JSON.serialize(secondary),
                    String.valueOf(lendingApplicationList[0].Id),
                    'ESign',
                    true
                );
                ClientPortal_VCLHomeCntrl.updateVCLDisclosureInformation(
                    JSON.serialize(secondary),
                    String.valueOf(lendingApplicationList[0].Id),
                    'ESign',
                    false
                );
                ClientPortal_VCLHomeCntrl.updateIncomeInformation(
                    JSON.serialize(primaryIncomeWrapper),
                    JSON.serialize(secondaryIncomeList),
                    JSON.serialize(secondary),
                    true
                );
                ClientPortal_VCLHomeCntrl.checkIfUserCanProceed();
                ClientPortal_VCLHomeCntrl.retrieveSocialSecurityNumber();
                ClientPortal_VCLHomeCntrl.savePortalSSN(secondary.Id, '123412123');
                ClientPortal_VCLHomeCntrl.verifyPortalSSN(secondary.Id, '909080700');
                ClientPortal_VCLHomeCntrl.verifyPortalSSN(secondary.Id, '123412122');
                ClientPortal_VCLHomeCntrl.verifyPortalSSN(null, '123412122');
                ClientPortal_VCLHomeCntrl.updateVCLPortalStatusOnAccout(secondary.Id, 'List Document');
                ClientPortal_VCLHomeCntrl.updateAccountStateCheckboxes(JSON.serialize(secondary),'Income Added');
                ClientPortal_VCLHomeCntrl.updateAccountStateCheckboxes(JSON.serialize(secondary),'SSN Submitted');
                ClientPortal_VCLHomeCntrl.updateAccountStateCheckboxes(JSON.serialize(secondary),'Bank Added');
                ClientPortal_VCLHomeCntrl.getIncomeWrapperInstance();
                ClientPortal_VCLHomeCntrl.getBankAccountWrapper(secondary.Id);
                ClientPortal_VCLHomeCntrl.getDocumentsByLendingApplication(lendingApplicationList[0].Id);
                ClientPortal_VCLHomeCntrl.uploadFileToBoxTilaEsign(Blob.valueOf('Test String'), lendingApplicationList[0].Id, 'TestDoc');
            }
        Test.stopTest();
    }

    @IsTest static void testAdditionalMethod(){
        List<ClientPortal_VCLHomeCntrl.LendingApplicationCheckListWrapper> wrapList = new List<ClientPortal_VCLHomeCntrl.LendingApplicationCheckListWrapper>();
        ClientPortal_VCLHomeCntrl.LendingApplicationCheckListWrapper wrappper = new ClientPortal_VCLHomeCntrl.LendingApplicationCheckListWrapper();
        wrappper.isPending = true;
        wrappper.checklist = [Select Id FROM fsCore__Lending_Application_Checklist__c WHERE fsCore__Checklist_Item__c = 'Test Checklist' LIMIT 1];
        wrapList.add(wrappper);
        Test.startTest();
        ClientPortal_VCLHomeCntrl.createOptionList(JSON.serialize(wrapList));
        Test.stopTest();
    }
    
    @isTest private static void markLendingAppInProgressTest() {
        Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account'];
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c, fsCore__Current_Stage_Name__c
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                WHERE fsCore__Account_Name__c = :primary.Id)
                                                                    LIMIT 1];
        fsCore__Pricing_Setup__c testPricing = fsCore.TestHelperProduct.getTestPricingSetup('Test Pricing1'
                                                                                            , fsCore.Constants.PRICING_METHOD_INTEREST_RATE
                                                                                            , 4.00
                                                                                            , 12
                                                                                            , 1);
        testPricing.Is_Generate_Additional_Pricing__c = true;
        testPricing.Payment_Increase_For_Option_1__c = 10;
        testPricing.Payment_Increase_For_Option_2__c = 20;
        insert testPricing;
        
        fsCore__Lending_Application_Pricing_Offer__c pricingOffer = new fsCore__Lending_Application_Pricing_Offer__c() ;
        pricingOffer.fsCore__Lending_Application_Number__c = lendingApplicationList[0].Id ;
        pricingOffer.fsCore__Factor_Rate__c = 2 ;
        pricingOffer.fsCore__Financed_Amount__c = 20 ;
        pricingOffer.fsCore__Number_Of_Payments__c = 20 ;
        pricingOffer.fsCore__Pricing_Date__c = date.today() ;
        pricingOffer.fsCore__Rate__c = 2;
        pricingOffer.fsCore__Pricing_Name__c = testPricing.Id;
        pricingOffer.RecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType where DeveloperName = 'Accepted' LIMIT 1].Id ;
        insert pricingOffer ;
        
        fsCore__Bank_Account__c bankInfo = [Select Id,Is_VCL_Bank_Verification_Locked__c,Number_of_Failure_Verification_Attempts__c FROM fsCore__Bank_Account__c WHERE fsCore__Account_Name__c = :primary.Id];

        
        Test.startTest();
       
        ClientPortal_VCLHomeCntrl.LendingApplicationDocument docWrapper = new ClientPortal_VCLHomeCntrl.LendingApplicationDocument() ;
        docWrapper.documentName = 'documentName' ;
        docWrapper.documentType = 'documentType' ;
        docWrapper.isRecieved = true ;
        docWrapper.canUserDelete = true ;
        docWrapper.isoTimeStamp = 0 ;
        docWrapper.fileSize = 'documentType'  ;
        docWrapper.document = null;
        
        try{
             ClientPortal_VCLHomeCntrl.getAccountOverview(lendingApplicationList[0].Id);
        } catch(Exception ex) {
            System.debug(ex.getMessage()) ;
        }
        Test.stopTest(); 
    }
    
    @isTest private static void generateDocuSignEnvolopeTest() {
        Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account' LIMIT 1];
        fsCore__Bank_Account__c bankInfo = [Select Id FROM fsCore__Bank_Account__c WHERE fsCore__Account_Name__c = :primary.Id LIMIT 1];
        
        ContentDocumentLink link2 =  [Select contentDocumentId from ContentDocumentLink where LinkedEntityId = :bankInfo.Id LIMIT 1];
        Id conVersionId = [Select Id from ContentVersion where contentDocumentId  = :link2.contentDocumentId LIMIT 1].Id ;
        
        Test.startTest() ;
        User primaryApplicantUser = ClientPortal_TestDataFactory.createUser(primary.PersonContactId, 'VCL Customer Community Login User')[0];
        PermissionSet docuSignSenderPS = [SELECT Id, Name, Label FROM PermissionSet where Name Like '%Docusign_Sender%' LIMIT 1] ;
        PermissionSetAssignment psa = new PermissionSetAssignment (
            PermissionSetId = docuSignSenderPS.Id,
            AssigneeId = primaryApplicantUser.Id
        );
        insert psa;
        System.runAs(primaryApplicantUser){
            ClientPortal_VCLHomeCntrl.retriveBankNameList() ;
            ClientPortal_VCLHomeCntrl.getContentForATDForm(primary.Id) ;
            ClientPortal_VCLHomeCntrl.storeEnvelopeIdonBank(bankInfo.Id , 'testEnvelopeId') ;
            ClientPortal_VCLHomeCntrl.updateVCLPortalStatusForATDOnAccout(primary.Id) ; 
            ClientPortal_VCLHomeCntrl.getAgreementURI('MLA', primary.Id) ;
            ClientPortal_VCLHomeCntrl.getAgreementDownloadURI('MLA', primary.Id) ;
            
        }
        
        Test.stopTest() ;
    }
    
    @isTest private static void redirectToDocuSignURLTest() {
        Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account' LIMIT 1];
        fsCore__Bank_Account__c bankInfo = [Select Id FROM fsCore__Bank_Account__c WHERE fsCore__Account_Name__c = :primary.Id LIMIT 1];
        bankInfo.VCL_Envelope_Id__c = 'TestId' ;
        update bankInfo ;
        Test.startTest() ;
        ClientPortal_VCLHomeCntrl.redirectToDocuSignURL(primary.Id) ;
        Test.stopTest() ;
    }
    
     @isTest private static void docusignEmbeddedSignTest() {
        
         Test.startTest() ;
         try{
             ClientPortal_DocuSign embededSignObj = new ClientPortal_DocuSign() ;
             embededSignObj.signer_return_url = 'www.testGoogle.com' ;
             embededSignObj.embedded_signing() ; 
         } catch(exception ex){
             system.debug(ex.getMessage());
         }
         
         Test.stopTest() ;
    }
}