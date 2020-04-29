@istest
public class TestLeadPaymentUpdateFromNuDebtJob {
 static testmethod void test() {
   Test.startTest();

      // Schedule the test job      

      String jobId = System.schedule('testLeadPaymentUpdate',
      LeadPaymentUpdateFromNuDebtJob.CRON_EXP, 
         new LeadPaymentUpdateFromNuDebtJob());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(LeadPaymentUpdateFromNuDebtJob.CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);


   Test.stopTest();

   }
}