@isTest
public class ClientPortal_UtilityTest {
    
    @isTest
    static void getCurrentUserInformationTest(){
        ClientPortal_Utility.getCurrentUserInformation();
    }
    
    @isTest
    static void getEmailTemplateTest(){
        ClientPortal_Utility.getEmailTemplate('Test');
    }
    
    @isTest
    static void getOrgInfoTest(){
        ClientPortal_Utility.getOrgInfo();
    }
    @isTest
    static void getAccountIdFromCurrentUserTest(){
        ClientPortal_Utility.getAccountIdFromCurrentUser();
    }
    @isTest
    static void getRecordTypeIdTest(){
        ClientPortal_Utility.getRecordTypeId('Account','Client');
    }
    @isTest
    static void getOrgWideEmailIdTest(){
        //OrgWideEmailAddress orgEmailAdd = new OrgWideEmailAddress();
        // orgEmailAdd.DisplayName = 'test@test.com';
        List<OrgWideEmailAddress> emailAddressList = [SELECT Id, DisplayName
                                                      FROM OrgWideEmailAddress
                                                      ORDER BY LastModifiedDate
                                                      DESC LIMIT 1];
        ClientPortal_Utility.getOrgWideEmailId(emailAddressList[0].DisplayName);
    }
    @isTest
    static void getUserIPAddressTest(){

        ClientPortal_Utility.getUserIPAddress();
    }   
    
    @isTest
    static void checkIfUserCanProceedTest(){
        /* create test application and applicant */
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
        fsCore__National_Identification_Number__pc = '909080707');
        accountToInsert.add(testAccount);

        //Account for customer co-applicant
        Account testCoAccount = new Account(FirstName = 'Stark',
        LastName = 'Secondary Applicant Account',
        RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),
        PersonEmail = 'agcoTest@123.com',
        Person_Email__c = 'agcoTest@123.com',
        PersonBirthdate = system.today().AddDays(-10000),
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
        /* Test the code now */
        Account primary = [Select Id, PersonContactId FROM Account WHERE LastName = 'Primary Applicant Account'];
        Account secondary = [Select Id, PersonContactId,Person_Email__c, Name FROM Account WHERE LastName = 'Secondary Applicant Account'];
        User primaryApplicantUser = ClientPortal_TestDataFactory.createUser(primary.PersonContactId, 'VCL Customer Community Login User')[0];
        primary.VCL_Related_Portal_Account__c = secondary.id;
        primary.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_ADD_INCOME_STATUS;
        primary.VCL_User_Registration_Date__c = System.today().addDays(-15);
        update primary;
        System.runAs(primaryApplicantUser){
            ClientPortal_Utility.checkIfUserCanProceed();
        }
        primary.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_LIST_DOCUMENT_STATUS;
        primary.TILA_Signed_Date__c = System.today().addDays(-15);
        update primary;
        System.runAs(primaryApplicantUser){
            ClientPortal_Utility.checkIfUserCanProceed();
        }
    }

    @isTest
    static void getApplicantNameListTestForDNL(){
        List<Client_Portal_Portfolio__c> portfolios = ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'DNL');
        portfolios[0].Name = 'DNL';
        portfolios[0].Profile_Name__c = 'DNL Customer Community Login User';
        insert portfolios;
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        insert opp1;
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        System.runAs(user){
            ClientPortal_Utility.getApplicantNameList();
        }
    }

    @testSetup
    static void setupTestData() {
        EmailMessage emailInstance = new EmailMessage(); 
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;
        
        list<Contact> conList = ClientPortal_TestDataFactory.buildContact(account1.Id,'Account');
        insert conList;
    }
}