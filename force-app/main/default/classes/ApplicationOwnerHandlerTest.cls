/*
* Class Name  : ApplicationOwnerHandlerTest
* Description : This class has test method for ApplicationOwnerHandler
*/
@isTest
private class ApplicationOwnerHandlerTest {
    
    @testSetup
    Static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
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
                                                                                            , 'DNL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='DNL';
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        //
        //create contract template
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup('Test Contract Template'
                                                                                                                        , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                                                        , testPaymentAlloc.Id
                                                                                                                        , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');  
        
        //create users
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
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
        UsersList.add(user2);
        
        insert UsersList;
                
                
        //create Stage
        //fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Test Stage1','Lending_Application_Stage', 'Origination', 10);
        //insert testStage;
        List<fsCore__Stage_Setup__c> testStageList = new List<fsCore__Stage_Setup__c>();
        
        fsCore__Stage_Setup__c testStage1 = fsCore.TestHelperWorkflow.getTestStage('Test Stage1','Lending_Application_Stage', 'Origination', 10);
        testStageList.add(testStage1);
        fsCore__Stage_Setup__c testStage2 = fsCore.TestHelperWorkflow.getTestStage('Test Stage2','Lending_Application_Stage', 'Origination', 5);
        testStageList.add(testStage2);
        
        insert testStageList;
        
        //Create Stage Members
        List<Stage_Member_Setup__c> testStageMemberList = new List<Stage_Member_Setup__c>();
        
        Stage_Member_Setup__c testStageMember1 = new Stage_Member_Setup__c();
        testStageMember1.Is_Active__c=true;
        testStageMember1.Stage_Name__c=testStageList[0].id;
        // testStageMember1.Stage_Name__c=testStage.id;
        testStageMember1.User__c=UsersList[0].Id;
        testStageMemberList.add(testStageMember1);
        
        Stage_Member_Setup__c testStageMember2 = new Stage_Member_Setup__c();
        testStageMember2.Is_Active__c=true;
        testStageMember2.Stage_Name__c=testStageList[0].id;
        //testStageMember2.Stage_Name__c=testStage.id;
        testStageMember2.User__c=UsersList[1].Id;
        testStageMemberList.add(testStageMember2);  
        
        Stage_Member_Setup__c testStageMember3 = new Stage_Member_Setup__c();
        testStageMember3.Is_Active__c=true;
        testStageMember3.Stage_Name__c=testStageList[1].id;
        // testStageMember3.Stage_Name__c=testStage.id;
        testStageMember3.User__c=UsersList[1].Id;
        testStageMemberList.add(testStageMember3);
        
        Stage_Member_Setup__c testStageMember4 = new Stage_Member_Setup__c();
        testStageMember4.Is_Active__c=true;
        testStageMember4.Stage_Name__c=testStageList[1].id;
        //testStageMember4.Stage_Name__c=testStage.id;
        testStageMember4.User__c=UsersList[0].Id;
        testStageMemberList.add(testStageMember4);  
        
        insert testStageMemberList;
        //
        //create Lending Application by populating company, branch, product,Contract template
        //
        List<fsCore__Lending_Application__c> testApplicationList = new List<fsCore__Lending_Application__c>();
        testApplicationList.add(fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                   , testBranch
                                                                                                   , testProduct
                                                                                                   , testContractTemplate 
                                                                                                   , 'Test Application 1'));
        testApplicationList.add(fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                   , testBranch
                                                                                                   , testProduct
                                                                                                   , testContractTemplate 
                                                                                                   , 'Test Application 2'));
        testApplicationList.add(fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                   , testBranch
                                                                                                   , testProduct
                                                                                                   , testContractTemplate 
                                                                                                   , 'Test Application 3'));
        for(fsCore__Lending_Application__c testApplication : testApplicationList){
            //testApplication.fsCore__Current_Stage_Name__c = testStage.id;
            if(testApplication.Name == 'Test Application 1'){
                testApplication.fsCore__Current_Stage_Name__c = testStageList[0].id;
            }
            else{
                testApplication.fsCore__Current_Stage_Name__c = testStageList[1].id;    
            }
        }
        
        
        insert testApplicationList;
        System.debug(testApplicationList);
        System.assert(testApplicationList.size()>0, 'Test Lending Applications created assert');        
        
    }
    
    @istest
    static void test1(){
        Test.startTest();
        List<fsCore__Lending_Application__c> applicationList = [Select Id
                                                                , Name
                                                                , fsCore__Company_Name__r.Name
                                                                , fsCore__Branch_Name__r.Name
                                                                , fsCore__Pricing_Name__r.Name
                                                                , fsCore__Contract_Template_Name__r.Name
                                                                , fsCore__Current_Stage_Name__r.Name
                                                                , Application_Owner_Name__c
                                                                , Application_Owner_Assignment_Date__c
                                                                FROM fsCore__Lending_Application__c ];
        
        ApplicationOwnerHandler handler = new ApplicationOwnerHandler();
        handler.updateOwner(applicationList);
        
        Test.stopTest();
    }
    
}