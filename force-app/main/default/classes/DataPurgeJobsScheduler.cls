/**
 * Class Name  : DataPurgeJobsScheduler
 * Description : Apex Scheduler for scheduling data purge jobs
 * Author      : Financial Spectra
 *
 */
global class DataPurgeJobsScheduler implements Schedulable {
   
   global void execute(SchedulableContext SC) {
       fsCore__Batch_Job_Group_Setup__c jobGroup = 
               [SELECT Id, Name, fsCore__Batch_Job_Group_Code__c
                  FROM fsCore__Batch_Job_Group_Setup__c
                 WHERE fsCore__Batch_Job_Group_Code__c = 'DATA_PURGE_JOBS'];
   
       List<String> submittedJobIds = fsCore.BatchJobUtil.submitBatchJobGroup(jobGroup.Id, 'VLB');
       System.debug(loggingLevel.ERROR, '-- Submitted Job(s) : ' + submittedJobIds);
   }

}