/**
 * Class Name  : DailyContractProcessingSchedulerTest
 * Description : Test class for all batch job group apex scheduler classes 
 * Author      : Financial Spectra
 *
 */
@isTest
private class DailyContractProcessingSchedulerTest{
    
    @isTest
    private static void testDailyProcessingJG(){
        fsCore__Batch_Job_Group_Setup__c testJobGroup = fsCore.TestHelperSystem.getTestBatchJobGroupSetup('DAILY_CONTRACT_PROCESSSING_JG');
        insert testJobGroup;
        System.assert(testJobGroup.Id != null);

        String CRON_EXP = '0 0 1 * * ?'; //All Days at 1AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('DailyContractProcessingScheduleTest',
                                       CRON_EXP, 
                                       new DailyContractProcessingScheduler());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
    
}