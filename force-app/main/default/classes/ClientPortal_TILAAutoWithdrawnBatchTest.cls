@isTest
public class ClientPortal_TILAAutoWithdrawnBatchTest {
    
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
                
        //Account and Contact for customer
        List<Account> accountToInsert = new List<Account>() ;
        Account testAccount = new Account(FirstName = 'Stark',
                                          LastName = 'Primary Applicant Account',
                                          RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),
                                          PersonEmail = 'agTest@123.com',
                                          Person_Email__c = 'agTest@123.com',
                                          PersonBirthdate = system.today().AddDays(-10000),
                                          nu_dse__Home_Phone__c = '0909080707',
                                          Welcome_Email_Sent_Date__c = Date.today().addDays(-3),
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
                                            TILA_Signed_Date__c = Date.today().addDays(-15),
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
        testApplication.fsCore__Application_Status__c = 'Withdrawn';
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
    }
    @isTest
    private static void testTILAAutoWithdrawn() {
        ClientPortal_TILAAutoWithdrawnBatchClass batch = new ClientPortal_TILAAutoWithdrawnBatchClass();
        Database.executebatch(batch);
        
       
    }
}