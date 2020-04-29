/*
 * Class Name   - DocumentSubmissionNOIEmailJobTest
 * Description  - Test class for DocumentSubmissionNOIEmailJob
 */
@isTest
private class DocumentSubmissionNOIEmailJobTest{
    
    @testsetup static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        Boolean exceptionFlag = false;
        String exceptionMsg = '';
        try{        
            //create custom settings
            //fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING
            //
            //                                                                                                                        , fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});
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
           testApplication.Document_Submission_Due_Date__c= System.today().adddays(-10);
            update testApplication; 
        }catch(Exception ex){
            exceptionFlag = true;
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals(false, exceptionFlag, 'Test data success assert ' + exceptionMsg);
    }
    
    @isTest
    private static void testJobExecution(){
        Test.startTest();
        DocumentSubmissionNOIEmailJob testJob = new DocumentSubmissionNOIEmailJob();
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
        String jobId = System.schedule('DocumentSubmissionNOIEmailJobTest',
                                       CRON_EXP, 
                                       new DocumentSubmissionNOIEmailJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
       
}