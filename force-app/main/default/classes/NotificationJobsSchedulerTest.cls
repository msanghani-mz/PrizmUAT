/**
 * Class Name  : NotificationJobsSchedulerTest
 * Description : Test class for NotificationJobsScheduler class 
 * Author      : Financial Spectra
 *
 */
@isTest
private class NotificationJobsSchedulerTest{
    
    @isTest
    private static void testNotificationJG(){
        fsCore__Batch_Job_Group_Setup__c testJobGroup = fsCore.TestHelperSystem.getTestBatchJobGroupSetup('NOTIFICATION_JG');
        insert testJobGroup;
        System.assert(testJobGroup.Id != null);

        String CRON_EXP = '0 0 2 * * ?'; //All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('NotificationJobsSchedulerTest',
                                       CRON_EXP, 
                                       new NotificationJobsScheduler());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
    
}