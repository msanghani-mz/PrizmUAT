/**
* Class Name  : DocProcessorRoundRobinProcessorTest
* Description : This class has test method for DocProcessorRoundRobinProcessor
*
*/
@isTest
public class DocProcessorRoundRobinProcessorTest {
    
    @testSetup
    static void createTestData(){
        
        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company'
                                                                                            , 'TESTCO'
                                                                                            , '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch'
                                                                                         , 'VLB'
                                                                                         , testCompany.Id
                                                                                         , null
                                                                                         , null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 
        
        //create product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'DNL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');
        
        //create contract template
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        
        //create Contract Template
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        
        
        //create Account
        Account nAccount = TestHelperData.createAccount();
        Database.insert(nAccount);
        System.assert(nAccount.Id != null, 'Test Account created assert');
        
        Account testAccount = [select id, personcontactId from Account where id = :nAccount.id limit 1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        
        //create users
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'DNL Doc Collector' LIMIT 1];
        System.debug(profileId);
        List<User> UsersList= new List<User>();
        User user1 = new User(LastName = 'User1',
                              FirstName='Test',
                              Alias = 'tUser1',
                              Email = 'test@gmail.com',
                              Username = 'test_User1@testUser1.com',
                              ProfileId = profileId.id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US'
                             );
        user1.IsActive=true;
        UsersList.add(user1);
        
        User user2 = new User(LastName = 'User2',
                              FirstName='Test',
                              Alias = 'tUser2',
                              Email = 'test@gmail.com',
                              Username = 'test_User2@testUser2.com',
                              ProfileId = profileId.id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US'
                             );
        user2.IsActive=true;
        UsersList.add(user2);
        
        insert UsersList;
        
        //create Stage
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Docs Processing','Lending_Application_Stage', 'Origination', 10);
        testStage.fsCore__Stage_Code__c= 'DNL_DOC_PROCESSING';
        testStage.fsCore__Is_Active__c=true;
        insert testStage;
        System.debug(testStage);
        
        //Create Lending Application
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                                                                       , testBranch
                                                                                                                       , testProduct
                                                                                                                       , testContractTemplate
                                                                                                                       , 200);
        
        fsCore__Lending_Application__c testApp = testAppsList[0];
        testApp.Docs_Processor_Name__c= UsersList[0].id;
        testApp.fsCore__Current_Stage_Name__c=testStage.id;
        testApp.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApp.Loan_Type__c ='DNL';
        testApp.fsCore__Is_Application_Read_Only__c= false;
        Database.insert(testApp);
        
        fsCore__Lending_Application__c testApp1 = testAppsList[1];
        testApp1.Docs_Processor_Name__c= UsersList[1].id;
        testApp1.fsCore__Current_Stage_Name__c=testStage.id;
        testApp1.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApp1.Loan_Type__c ='DNL';
        testApp.fsCore__Is_Application_Read_Only__c= false;
        Database.insert(testApp1);
        
        System.assert(testApp.Id != null, 'Test Lending Application created assert');   
        System.Debug(testApp.Current_Stage_Code_Formula__c);
        System.Debug(testApp.Docs_Processor_Name__r.isActive);
    }
/**
* 
*/
    private static testMethod void testRoundRobinProcessor1(){
        
        fsCore__Lending_Application__c testApplication = [SELECT id, name, Docs_Processor_Name__c, fsCore__Current_Stage_Name__c, Loan_Type__c, fsCore__Is_Application_Read_Only__c, Current_Stage_Code_Formula__c
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];   
        
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        acrInput.addRecord(testApplication.Id);
        
        Test.startTest(); 
        DocProcessorRoundRobinProcessor analysisRoundRobin = new DocProcessorRoundRobinProcessor();
        analysisRoundRobin.setInput(acrInput);
        System.assertEquals(acrInput, analysisRoundRobin.mActionInput, 'Action Input values match on load assert');
        analysisRoundRobin.process();
        System.debug(analysisRoundRobin.mApplicationMap.size());
        System.assertEquals(0, analysisRoundRobin.mApplicationMap.size(),'Test Application Size on load assert');
        Test.stopTest();        
    }
    
    private static testMethod void testRoundRobinProcessor2(){
        
        fsCore__Lending_Application__c testApplication = [SELECT id, name, Docs_Processor_Name__c, fsCore__Current_Stage_Name__c, Loan_Type__c, fsCore__Is_Application_Read_Only__c, Current_Stage_Code_Formula__c
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];  
        id docsProcessorNameId=testApplication.Docs_Processor_Name__c;
        System.debug(docsProcessorNameId);
        testApplication.Docs_Processor_Name__c=Null;
        Update testApplication;
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        acrInput.addRecord(testApplication.Id);
        
        Test.startTest(); 
        DocProcessorRoundRobinProcessor analysisRoundRobin = new DocProcessorRoundRobinProcessor();
        analysisRoundRobin.setInput(acrInput);
         System.assertEquals(acrInput, analysisRoundRobin.mActionInput, 'Action Input values match on load assert'); 
        analysisRoundRobin.process();
        System.debug(analysisRoundRobin.mApplicationMap.size());
        System.assertEquals(1, analysisRoundRobin.mApplicationMap.size(),'Test Application Size on load assert');
         fsCore__Lending_Application__c testApplication1 = [SELECT id, name, Docs_Processor_Name__c, fsCore__Current_Stage_Name__c, Loan_Type__c, fsCore__Is_Application_Read_Only__c, Current_Stage_Code_Formula__c
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];  
        System.assert((testApplication1.Docs_Processor_Name__c != null), 'Docs_Processor_Name__c is not null');
        Test.stopTest();        
    }
    
    private static testMethod void addError(){
        
        fsCore__Lending_Application__c testApplication = [SELECT id, name, Docs_Processor_Name__c, fsCore__Current_Stage_Name__c, Loan_Type__c, fsCore__Is_Application_Read_Only__c,Current_Stage_Code_Formula__c 
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];  
        
        DocProcessorRoundRobinProcessor analysisRoundRobin = new DocProcessorRoundRobinProcessor();
        analysisRoundRobin.addError('Test','Test','Test',testApplication.Id,' Dummy');
        analysisRoundRobin.getOutput();
        
    }
}