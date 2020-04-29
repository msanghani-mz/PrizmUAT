/*
 * Class Name   - EmailNotificationLogPurgeJobTest
 * Description  - Test class for EmailNotificationLogPurgeJob
 */
@isTest
private class EmailNotificationLogPurgeJobTest{
    
    @testsetup static void createTestData(){
        Boolean exceptionFlag = false;
        String exceptionMsg = '';
        try{        
            //create custom settings
            fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING
                                                                         , fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});

            List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();

            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Notification_Type__c = ApplicationNotificationUtil.ADVERSE_ACTION_NOTICE);


            Email_Notification_Log__c newEmail1 
                = new Email_Notification_Log__c(Notification_Type__c = ApplicationNotificationUtil.CHECKLIST_DOCUMENT_REJECTION);


            Email_Notification_Log__c newEmail2 
                = new Email_Notification_Log__c(Notification_Type__c = ApplicationNotificationUtil.PRE_TILA_NOI);

            newEmailNotifications.add(newEmail);
            newEmailNotifications.add(newEmail1);
            newEmailNotifications.add(newEmail2);
            insert newEmailNotifications;    
            
        }catch(Exception ex){
            exceptionFlag = true;
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals(false, exceptionFlag, 'Apex Job Detail test data success assert ' + exceptionMsg);
    }
    
    @isTest
    private static void testJobExecution(){
        Integer purgeDays = 0;
        Date purgeFromDate = Date.today().addDays(-1 * purgeDays);

        
        System.assertEquals(0, purgeDays, 'Email Notification Purge days assert');
        
        List<Email_Notification_Log__c> apexJobList = [SELECT Id FROM Email_Notification_Log__c
                                                       WHERE Record_Creation_Date__c <= :purgeFromDate];
        
        System.assertEquals(3, apexJobList.size(), 'Email Notification size assert (before job execution)');
        
        Test.startTest();
        EmailNotificationLogPurgeJob testJob = new EmailNotificationLogPurgeJob(purgeDays);
        String jobType = testJob.getBatchJobType();
        
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();

        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
        
        apexJobList = [SELECT Id FROM Email_Notification_Log__c
                        WHERE Record_Creation_Date__c <= :purgeFromDate];
        
        System.assertEquals(0, apexJobList.size(), 'Email Notification size assert (after job execution)');

    }
    
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('EmailNotificationLogPurgeJobTest',
                                       CRON_EXP, 
                                       new EmailNotificationLogPurgeJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
       
}