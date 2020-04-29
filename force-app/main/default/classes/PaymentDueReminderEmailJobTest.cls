/*
 * Class Name   - PaymentDueReminderEmailJobTest
 * Description  - Test class for PaymentDueReminderEmailJob
 */
@isTest
private class PaymentDueReminderEmailJobTest{
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
   @testsetup static void createTestData(){
        Boolean exceptionFlag = false;
        String exceptionMsg = '';
        try{        
            //create custom settings
            //fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING
            //                                                           , fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});
            fsServ.TestHelperGlobal.createSetupData();
            createLendingContracts(true, true); //this will create contracts with customers, direct debit and dues
            
            fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
            testBranch.fsCore__Business_Date__c = testBranch.fsCore__Business_Date__c.addDays(30);
            update testBranch;
            // create Inbound Payment
            //List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();
            fsServ__Lending_Contract__c testContract = [SELECT Id,fsServ__Branch_Code__c,fsServ__Branch_Name__c,fsServ__Is_Active__c FROM fsServ__Lending_Contract__c where fsServ__Contract_Status__c='Active' LIMIT 1];
            System.debug(loggingLevel.ERROR, 'Test Contract Is :==> '+ testContract);
            // create Contract Due
            fsServ__Contract_Due__c testConDue = new fsServ__Contract_Due__c();
            testConDue.fsServ__Lending_Contract_Number__c=testContract.Id;
            testConDue.fsServ__Due_Date__c= System.today().adddays(5);
            testConDue.fsServ__Transaction_Date__c = System.today();
            testConDue.Is_Due_Reminder_Email_Sent__c = false;
            insert testConDue;
            System.debug(loggingLevel.ERROR, 'testContractDue :==> '+ testConDue);
        }catch(Exception ex){
            exceptionFlag = true;
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals(false, exceptionFlag, 'Test data success assert ' + exceptionMsg);
    }
    
    @isTest
    private static void testJobExecution(){
        Test.startTest();
        PaymentDueReminderEmailJob testJob = new PaymentDueReminderEmailJob();
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
        String jobId = System.schedule('PaymentDueReminderEmailJobTest',
                                       CRON_EXP, 
                                       new PaymentDueReminderEmailJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
       
}