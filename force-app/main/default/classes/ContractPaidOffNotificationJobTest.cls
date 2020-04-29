/* 
 * Class   : ContractPaidOffNotificationJobTest
 * Purpose : Test class for ContractPaidOffNotificationJob       
 * Author  : Financial Spectra
 */

@isTest(seeAllData = false)
private class ContractPaidOffNotificationJobTest {
static void createLendingContracts(Boolean pActiveContracts, Boolean pWithRelatedData){
        TestCustomDataLoader.loadAccounts();
        TestCustomDataLoader.loadContacts();
        
        if (pActiveContracts){
            TestCustomDataLoader.loadLendingContractsActive();
            TestCustomDataLoader.loadContractBalancesActive();
            TestCustomDataLoader.loadContractDues();
            TestCustomDataLoader.loadContractRepayments();
            TestCustomDataLoader.loadContractRepaySchedules();
        } else {
            TestCustomDataLoader.loadLendingContractsPending();
            TestCustomDataLoader.loadContractBalancesPending();
        }
        
        if (pWithRelatedData){
            TestCustomDataLoader.loadBankAccounts();
            TestCustomDataLoader.loadContractCustomers();
            TestCustomDataLoader.loadContractItemizations();
            TestCustomDataLoader.loadContractFees();
            TestCustomDataLoader.loadContractDirectDebits();
            TestCustomDataLoader.loadContractDisbursements();
        }
        
        System.assertEquals(8, [SELECT count() FROM fsServ__Lending_Contract__c]);
    }
    @testSetup static void createTestData(){
        fsServ.TestHelperGlobal.createSetupData();
        //fsServ.TestHelperGlobal.createLendingContracts(true, true); //this will create contracts with customers, direct debit and dues  
        createLendingContracts(true, true);
        fsCore__Bank_Account__c testacc= new fsCore__Bank_Account__c();
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        testBranch.fsCore__Business_Date__c = testBranch.fsCore__Business_Date__c.addDays(30);
        update testBranch;
        
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();
       
    }
    
      @isTest
    private static void testJobExecution(){
         fsServ__Lending_Contract__c  testContract = [SELECT Id, Name
                                                      ,fsServ__Paid_in_Full_Date__c
                                                      ,Is_Paid_Off_Notification_Sent__c
                                                      ,Paid_Off_Notification_Sent_Date__c
                                                      , fsServ__Contract_Status__c
                                                      ,fsServ__Total_Outstanding_Amount__c
                                                      FROM fsServ__Lending_Contract__c 
                                                      Limit 1
                                                     ];
        testContract.fsServ__Contract_Status__c = 'Paid In Full';
        testContract.Is_Paid_Off_Notification_Sent__c = false;
        testContract.fsServ__Total_Outstanding_Amount__c = 0;
        testContract.fsServ__Paid_in_Full_Date__c = Date.today();
        update testContract;
        
        Test.startTest();
        ContractPaidOffNotficationJob testJob = new ContractPaidOffNotficationJob();
        String jobType = testJob.getBatchJobType();
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();
    }
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ContractPaidOffNotficationJobTest',
                                       CRON_EXP, 
                                       new ContractPaidOffNotficationJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
}