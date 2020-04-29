@isTest
private class WelcomeLetterEmailJobTest {
    @testSetup
    static void  createTestData(){
          TestHelperData.createTriggerExecutionTestData();
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        //create Payment Allocation Method
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        System.assert(testPaymentAlloc.Id != null, 'Test payment allocation created assert');
        
        //Contract Template 
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate; 
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');   
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        testApplication.fsCore__Is_Funded__c = true;
        testApplication.fsServ__Is_Contracted__c = true;
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId();
        testApplication.RecordTypeId = recTypeId;
        testApplication.Loan_Officer__c = UserInfo.getUserId();
        testApplication.Welcome_Letter_Sent_Date__c = null;
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        
        
    }

    @isTest
    private static void testJob(){
        List<fsCore__Lending_Application__c> testApp = [Select id, Name, Loan_Officer__c, RecordType.DeveloperName,Welcome_Letter_Sent_Date__c  From fsCore__Lending_Application__c Limit 1];
        System.debug('testApp:---'+testApp);
        Test.startTest();
        WelcomeLetterEmailJob testJob  = new WelcomeLetterEmailJob();
        testJob.setParameterizedJobQuery();
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();
        
    }
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('WelcomeLetterEmailJobTest',
                                       CRON_EXP, 
                                       new WelcomeLetterEmailJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
}