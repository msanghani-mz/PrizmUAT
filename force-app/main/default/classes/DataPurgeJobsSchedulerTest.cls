/**
 * Class Name  : DataPurgeJobsSchedulerTest
 * Description : Test class for DataPurgeJobsScheduler class 
 * Author      : Financial Spectra
 *
 */
@isTest
private class DataPurgeJobsSchedulerTest{
    
    @isTest
    private static void testDataPurgeJobs(){
        fsCore__Batch_Job_Group_Setup__c testJobGroup = fsCore.TestHelperSystem.getTestBatchJobGroupSetup('DATA_PURGE_JOBS');
        insert testJobGroup;
        System.assert(testJobGroup.Id != null);

        String CRON_EXP = '0 0 4 * * ?'; //All Days at 4AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('DataPurgeJobsSchedulerTest',
                                       CRON_EXP, 
                                       new DataPurgeJobsScheduler());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
    
}