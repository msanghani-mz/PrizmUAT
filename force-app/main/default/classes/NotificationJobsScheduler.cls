/**
 * Class Name  : NotificationJobsScheduler
 * Description : Apex Scheduler for scheduling notification jobs
 * Author      : Financial Spectra
 *
 */
global class NotificationJobsScheduler implements Schedulable {
   
   global void execute(SchedulableContext SC) {
       fsCore__Batch_Job_Group_Setup__c jobGroup = 
               [SELECT Id, Name, fsCore__Batch_Job_Group_Code__c
                  FROM fsCore__Batch_Job_Group_Setup__c
                 WHERE fsCore__Batch_Job_Group_Code__c = 'NOTIFICATION_JG'];
   
       List<String> submittedJobIds = fsCore.BatchJobUtil.submitBatchJobGroup(jobGroup.Id, 'VLB');
       System.debug(loggingLevel.ERROR, '-- Submitted Job(s) : ' + submittedJobIds);
   }

}