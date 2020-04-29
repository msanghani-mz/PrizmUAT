/*
 * Class Name   - DocumentRejectionEmailJobTest
 * Description  - Test class for DocumentRejectionEmailJob
 */
@isTest
private class DocumentRejectionEmailJobTest{
    
    @testsetup static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        Boolean exceptionFlag = false;
        String exceptionMsg = '';
        try{        
            //create custom settings
            //fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING
            //                                                             , fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});
           //Account and Contact for customer
            Account testAccount = TestHelperData.createAccount();
            insert testAccount;
            System.assert(testAccount.Id != null, 'Test Account created assert');
            
            //create Lending Application with repayments
            //
            fsCore__Lending_Application__c testApplication = TestHelperData.createLendingApplicationWithRepayments(testAccount);
            System.assert(testApplication.Id != null, 'Test Lending Application created assert');      
             testApplication = [SELECT Id, fsCore__Record_Type_Formula__c,RecordType.DeveloperName,Number_Of_Checklist_Documents_Rejected__c,Is_Document_Rejection_Email_Sent__c,Last_Document_Rejection_Email_Sent_On__c
                                 FROM fsCore__Lending_Application__c WHERE Id = :testApplication.Id];
            testApplication.Is_Document_Rejection_Email_Sent__c = false;
            update testApplication; 
            fsCore__Lending_Application_Checklist__c testChkList = new fsCore__Lending_Application_Checklist__c();
            testChkList= [select Id, fsCore__Checklist_Item__c from fsCore__Lending_Application_Checklist__c where fsCore__Lending_Application_Number__c = :testApplication.Id limit 1];
            testChkList.fsCore__Status__c = 'Rejected';
            testChkList.Rejection_Reason__c = 'We received a copy of this document however it was illegible/unclear and will need to be resubmitted for review.';
            update testChkList;
        }catch(Exception ex){
            exceptionFlag = true;
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals(false, exceptionFlag, 'Test data success assert ' + exceptionMsg);
    }
    
    @isTest
    private static void testJobExecution(){
        fsCore__Lending_Application__c testApp = [SELECT Id, fsCore__Record_Type_Formula__c, RecordType.DeveloperName,Number_Of_Checklist_Documents_Rejected__c,Is_Document_Rejection_Email_Sent__c,Last_Document_Rejection_Email_Sent_On__c
                                 FROM fsCore__Lending_Application__c  LIMIT 1];
        
        System.debug(loggingLevel.DEBUG, testApp);
        Test.startTest();
        DocumentRejectionEmailJob testJob = new DocumentRejectionEmailJob();
        String jobType = testJob.getBatchJobType();
        
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();

        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('DocumentRejectionEmailJobTest',
                                       CRON_EXP, 
                                       new DocumentRejectionEmailJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
       
}