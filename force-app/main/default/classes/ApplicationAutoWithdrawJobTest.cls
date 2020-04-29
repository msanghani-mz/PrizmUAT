/*
* Class Name   - ApplicationAutoWithdrawJobTest
* Description  - Test class for ApplicationAutoWithdrawJob
*/
@isTest
private class ApplicationAutoWithdrawJobTest{
    
    @testsetup static void createTestData(){
               
        //create custom settings
        //fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING, fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});
        TestHelperData.createTriggerExecutionTestData();
        //Account and Contact for customer
        Account testAccount = TestHelperData.createAccount();	
        insert testAccount;
        System.assert(testAccount.Id != null, 'Test Account created assert');
        
		fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
            
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        
        
        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                            , 'VCL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c='VCL';
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');      
        
      //
        //create product
        //
        fsCore__Product_Setup__c testProductDNL = fsCore.TestHelperProduct.getTestProductSetup('Test Product1'
                                                                            , 'DNL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);
        testProductDNL.Credit_Pull_Report_Record_Type_Name__c='DNL';
        testProductDNL.fsCore__Customer_Type__c = 'Person Account';
        testProductDNL.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProductDNL.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        
        insert testProductDNL;
        System.assert(testProductDNL.Id != null, 'Test product DNL created assert');                
 
        //
        //create contract template
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        

        //
        //create custom settings
        //
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_SYSTEM_PREFERENCE
                                                              , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE
                                                              , fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                              , fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING
                                                              , fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});

        //
        //create Lending Application by populating company, branch, product, contract template
        //
		List<fsCore__Lending_Application__c> testApplication = new List<fsCore__Lending_Application__c>();
        fsCore__Lending_Application__c testApplication1 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , testContractTemplate
                                                                              , 'Test Loan Application');
        testApplication1.Loan_Processing_Letter_Sent_Date__c= System.today().adddays(-35);
		testApplication1.Pre_TILA_Sent_Date__c = Date.Today()-20;
        testApplication1.Is_PreTila_Signed__c = false;			
        testApplication1.RecordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
		testApplication.add(testApplication1);																	  
        fsCore__Lending_Application__c testApplication2 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                              , testBranch
                                                                              , testProductDNL
                                                                              , testContractTemplate
                                                                              , 'Test Loan Application');
        testApplication2.Loan_Processing_Letter_Sent_Date__c= System.today().adddays(-35);
	    testApplication2.Pre_TILA_Sent_Date__c = Date.Today()-20;
        testApplication2.Is_PreTila_Signed__c = false;
        testApplication.add(testApplication2);		
        insert testApplication;
        System.assert(testApplication.size() >0 , 'Test Lending Applications created assert');        

        //
        //create primary customer
        //
		List<fsCore__Lending_Application_Customer__c> testPrimaryCustomer = new List<fsCore__Lending_Application_Customer__c>();
        fsCore__Lending_Application_Customer__c testPrimaryCustomer1= fsCore.TestHelperLendingApplication.getTestCustomer(testApplication[0]
                                                                            , testAccount.Id
                                                                            , null
                                                                            , fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
		testPrimaryCustomer.add(testPrimaryCustomer1);																	
		fsCore__Lending_Application_Customer__c testPrimaryCustomer2= fsCore.TestHelperLendingApplication.getTestCustomer(testApplication[1]
                                                                            , testAccount.Id
                                                                            , null
                                                                            , fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
        testPrimaryCustomer.add(testPrimaryCustomer2);																			
        insert testPrimaryCustomer;
        System.assert(testPrimaryCustomer.Size()>0, 'Test primary customers created assert'); 
        
		// create Application checklist Record
        // 
        List<fsCore__Checklist_Setup__c> testChecklist = TestHelperData.createcheckList();
        List<fsCore__Checklist_Detail_Setup__c> testcheckListDetail= TestHelperData.createcheckListDetail(testChecklist);
        List<fsCore__Lending_Application_Checklist__c>testAppChklist = fsCore.TestHelperLendingApplication.getTestApplicationChecklists(testApplication[0],testcheckListDetail);
        insert testAppChklist;
		List<fsCore__Lending_Application_Checklist__c>testAppChklist1 = fsCore.TestHelperLendingApplication.getTestApplicationChecklists(testApplication[1],testcheckListDetail);
        insert testAppChkList1;
        System.assert(testAppChklist.size() > 0, 'Test application checklist size assert'); 
		System.assert(testAppChklist1.size() > 0, 'Test application checklist size assert'); 
        
        //create Lending Application repayment schedule and details
        //
        fsCore__Lending_Application_Repayment_Schedule__c testRepaySch = fsCore.TestHelperLendingApplication.getTestRepaymentSchedule(testApplication[0]);
        insert testRepaySch;
        System.assert(testRepaySch.Id != null, 'Test repayment schedule created assert');
       
        fsCore__Lending_Application_Repayment_Schedule__c testRepaySch1 = fsCore.TestHelperLendingApplication.getTestRepaymentSchedule(testApplication[1]);
        insert testRepaySch1;
        System.assert(testRepaySch1.Id != null, 'Test repayment schedule created assert');	   
        
        List<fsCore__Lending_Application_Repayment__c> testRepayDtlList = fsCore.TestHelperLendingApplication.getTestRepaymentDetails(testApplication[0]);
        insert testRepayDtlList;
        System.assert(testRepayDtlList.size() > 0, 'Test repayment schedule size assert'); 
        
		 List<fsCore__Lending_Application_Repayment__c> testRepayDtlList1 = fsCore.TestHelperLendingApplication.getTestRepaymentDetails(testApplication[1]);
        insert testRepayDtlList1;
        System.assert(testRepayDtlList1.size() > 0, 'Test repayment schedule size assert'); 
        
        
		
    }
    
    @isTest
    private static void testJobExecutionVCL1(){
        
        fsCore__Lending_Application__c testApplication1 = [SELECT Id
                                                           , Name
                                                           , Loan_Type__c
                                                           , fsCore__Record_Type_Formula__c
                                                           , RecordType.DeveloperName
                                                           , Incomplete_App_Auto_Withdraw_Date__c
                                                           , Loan_Processing_Letter_Sent_Date__c
                                                           , Is_PreTila_Signed__c
                                                           , Number_Of_Checklist_Documents_Rejected__c
                                                           , Is_Document_Rejection_Email_Sent__c
                                                           , fsCore__Product_Name__c
                                                           , Last_Document_Rejection_Email_Sent_On__c
                                                           , Pending_Document_Checklist_Count__c
                                                           , fsCore__Is_Application_Read_Only__c
                                                           , Pre_TILA_Sent_Date__c
                                                           FROM fsCore__Lending_Application__c 
                                                          WHERE Loan_Type__c='VCL' Limit 1];
     
        testApplication1.Pre_TILA_Sent_Date__c = Date.Today()-20;
        testApplication1.Is_PreTila_Signed__c = true;//false;
        testApplication1.Offer_Accepted_Date__c = Date.Today().addDays(-5);
        update testApplication1;
        
        System.debug(loggingLevel.Debug,'testApplication1'+testApplication1);
        System.debug('testApplication1.Incomplete_App_Auto_Withdraw_Date__c'+testApplication1.Incomplete_App_Auto_Withdraw_Date__c);
        Test.startTest();
        ApplicationAutoWithdrawJob testJob = new ApplicationAutoWithdrawJob();
        String jobType = testJob.getBatchJobType();
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        
        Test.stopTest();
        
        fsCore__Lending_Application__c testApplication = [select id, fsCore__Application_Status__c from fsCore__Lending_Application__c limit 1];
        
        System.assertEquals('Withdrawn', testApplication.fsCore__Application_Status__c, 'App Status Withdrawn assert');
        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobExecutionVCL2(){
        
        fsCore__Lending_Application__c testApplication2 = [SELECT Id
                                                           , Name
                                                           , Loan_Type__c
                                                           , fsCore__Record_Type_Formula__c
                                                           , RecordType.DeveloperName
                                                           , Incomplete_App_Auto_Withdraw_Date__c
                                                           , Loan_Processing_Letter_Sent_Date__c
                                                           , Is_PreTila_Signed__c
                                                           , Number_Of_Checklist_Documents_Rejected__c
                                                           , Is_Document_Rejection_Email_Sent__c
                                                           , fsCore__Product_Name__c
                                                           , Last_Document_Rejection_Email_Sent_On__c
                                                           , Pending_Document_Checklist_Count__c
                                                           , fsCore__Is_Application_Read_Only__c
                                                           , Pre_TILA_Sent_Date__c
                                                           FROM fsCore__Lending_Application__c WHERE Loan_Type__c='VCL' Limit 1];
     
        // testApplication2.Number_Of_Checklist_Documents_Rejected__c (Rollup Summary Field -count)
        List<fsCore__Lending_Application_Checklist__c> AppCheckList = [Select Id,fsCore__Checklist_Item_Type__c,fsCore__Status__c from fsCore__Lending_Application_Checklist__c Where fsCore__Lending_Application_Number__c =: testApplication2.Id];        
        AppCheckList[0].fsCore__Checklist_Item_Type__c='Document';
        AppCheckList[0].fsCore__Status__c = 'Rejected';
        AppChecklist[0].Rejection_Reason__c= 'Other';
        AppCheckList[0].Rejection_Reason_Others__c='Rejection reason ';
        update AppCheckList[0];
        System.debug(loggingLevel.error,'AppCheckList:--'+AppCheckList);
        testApplication2.Pre_TILA_Sent_Date__c =Date.newInstance(2019,6,4);
        testApplication2.Pre_TILA_Sign_Due_Date__c=Date.newInstance(2019,10,5);
        testApplication2.Pre_TILA_Signed_Date__c=Date.newInstance(2019,6,5);
        testApplication2.Is_PreTila_Signed__c=true; 
        testApplication2.Offer_Accepted_Date__c = Date.Today().addDays(-5);
        update testApplication2;        
        System.debug(loggingLevel.error,'testApplication2'+testApplication2); 
        System.debug(loggingLevel.error,'testApplication2 RecordType.DeveloperName  : '+testApplication2.RecordType.DeveloperName   ); 
        
        fsCore__Lending_Application__c testApp = [SELECT Id,Is_PreTila_Signed__c,Incomplete_App_Auto_Withdraw_Date__c,Number_Of_Checklist_Documents_Rejected__c,Pending_Document_Checklist_Count__c from fsCore__Lending_Application__c Where Id =:testApplication2.Id];
        System.debug(loggingLevel.error,'testApplication2.Number_Of_Checklist_Documents_Rejected__c'+testApp.Number_Of_Checklist_Documents_Rejected__c);
        System.debug(loggingLevel.error,'testApplication2.Pending_Document_Checklist_Count__c'+testApp.Pending_Document_Checklist_Count__c);
        System.debug(loggingLevel.error,'testApplication2.Is_PreTila_Signed__c'+testApp.Is_PreTila_Signed__c);  
        System.debug(loggingLevel.error,'testApplication2.Incomplete_App_Auto_Withdraw_Date__c'+testApp.Incomplete_App_Auto_Withdraw_Date__c);  
       
        Test.startTest();
        ApplicationAutoWithdrawJob testJob = new ApplicationAutoWithdrawJob();
        String jobType = testJob.getBatchJobType();
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();
        
        fsCore__Lending_Application__c testApplication = [select id, fsCore__Application_Status__c from fsCore__Lending_Application__c where id = :testApplication2.id];
        
        System.assertEquals('Withdrawn', testApplication.fsCore__Application_Status__c, 'App Status Withdrawn assert');
        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    
    @isTest
    private static void testJobExecutionDNL1(){
            fsCore__Lending_Application__c testApplication3 = [SELECT Id
                                                           , Name
                                                           , Loan_Type__c
                                                           , fsCore__Record_Type_Formula__c
                                                           , RecordType.DeveloperName
                                                           , Incomplete_App_Auto_Withdraw_Date__c
                                                           , Loan_Processing_Letter_Sent_Date__c
                                                           , Is_PreTila_Signed__c
                                                           , Number_Of_Checklist_Documents_Rejected__c
                                                           , Is_Document_Rejection_Email_Sent__c
                                                           , fsCore__Product_Name__c
                                                           , Last_Document_Rejection_Email_Sent_On__c
                                                           , Pending_Document_Checklist_Count__c
                                                           , fsCore__Is_Application_Read_Only__c
                                                           , Pre_TILA_Sent_Date__c
                                                           FROM fsCore__Lending_Application__c WHERE Loan_Type__c='DNL' Limit 1];
        
        fsCore__Product_Setup__c testProduct = [SELECT ID,fsCore__Active_Application_Record_Type__c From fsCore__Product_Setup__c WHERE ID = :testApplication3.fsCore__Product_Name__c ];
        testProduct.fsCore__Active_Application_Record_Type__c='DNL_Loan'; 
		    testProduct.Credit_Pull_Report_Record_Type_Name__c='DNL';
		    testProduct.fsCore__Product_Code__c='DNL';
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract'; 
        update testProduct;
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('DNL_Loan').getRecordTypeId();
        testApplication3.RecordTypeId = recTypeId; 
        testApplication3.Pre_TILA_Sent_Date__c = Date.Today()-20;
        testApplication3.Is_PreTila_Signed__c = false;
        // testApplication3.Loan_Type__c = 'DNL';
        update testApplication3;
       
        System.debug(loggingLevel.Debug,'testApplication3'+testApplication3);
        System.debug('testApplication3.Incomplete_App_Auto_Withdraw_Date__c'+testApplication3.Incomplete_App_Auto_Withdraw_Date__c);
        fsCore__Lending_Application__c testApp = [SELECT Id,RecordTypeId,fsCore__Record_Type_Formula__c,RecordType.DeveloperName,Loan_Type__c,Is_PreTila_Signed__c,Incomplete_App_Auto_Withdraw_Date__c,Number_Of_Checklist_Documents_Rejected__c,Pending_Document_Checklist_Count__c from fsCore__Lending_Application__c Where Id =:testApplication3.Id];
        System.Debug('testApp3:--'+testApp);
        
        Test.startTest();
        ApplicationAutoWithdrawJob testJob = new ApplicationAutoWithdrawJob();
        String jobType = testJob.getBatchJobType();
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        
        Test.stopTest();
        fsCore__Lending_Application__c testApplication = [select id, fsCore__Application_Status__c from fsCore__Lending_Application__c where id = :testApplication3.id];
        
       // System.assertEquals('Withdrawn', testApplication.fsCore__Application_Status__c, 'App Status Withdrawn assert');
        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobExecutionDNL2(){
        
        fsCore__Lending_Application__c testApplication4 = [SELECT Id
                                                           , Name
                                                           , Loan_Type__c
                                                           , fsCore__Record_Type_Formula__c
                                                           , RecordType.DeveloperName
                                                           , Incomplete_App_Auto_Withdraw_Date__c
                                                           , Loan_Processing_Letter_Sent_Date__c
                                                           , Is_PreTila_Signed__c
                                                           , Number_Of_Checklist_Documents_Rejected__c
                                                           , Is_Document_Rejection_Email_Sent__c
                                                           , fsCore__Product_Name__c
                                                           , Last_Document_Rejection_Email_Sent_On__c
                                                           , Pending_Document_Checklist_Count__c
                                                           , fsCore__Is_Application_Read_Only__c
                                                           , Pre_TILA_Sent_Date__c
                                                           , Pre_Tila_Sent_Date_First__c
                                                           FROM fsCore__Lending_Application__c WHERE Loan_Type__c='DNL' Limit 1];
     
        fsCore__Product_Setup__c testProduct = [SELECT ID,fsCore__Active_Application_Record_Type__c From fsCore__Product_Setup__c WHERE ID = :testApplication4.fsCore__Product_Name__c ];
        testProduct.fsCore__Active_Application_Record_Type__c='DNL_Loan'; 
		testProduct.Credit_Pull_Report_Record_Type_Name__c='DNL';
		testProduct.fsCore__Product_Code__c='DNL';
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract'; 
        update testProduct;
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('DNL_Loan').getRecordTypeId();
        testApplication4.RecordTypeId = recTypeId; 
        testApplication4.Pre_TILA_Sent_Date__c = Date.Today()-20;
        system.debug(testApplication4.Pre_TILA_Sent_Date__c);
        testApplication4.Is_PreTila_Signed__c = false; 
        update testApplication4;        
        System.debug(loggingLevel.error,'testApplication4'+testApplication4); 
        System.debug(loggingLevel.error,'testApplication4'+testApplication4.Pre_TILA_Sent_Date__c);
        System.debug(loggingLevel.error,'testApplication4 RecordType.DeveloperName  : '+testApplication4.RecordType.DeveloperName   ); 
        
        fsCore__Lending_Application__c testApp = [SELECT Id,Is_PreTila_Signed__c,Incomplete_App_Auto_Withdraw_Date__c,Number_Of_Checklist_Documents_Rejected__c,Pending_Document_Checklist_Count__c from fsCore__Lending_Application__c Where Id =:testApplication4.Id];
        System.debug(loggingLevel.error,'testApplication4.Number_Of_Checklist_Documents_Rejected__c'+testApp.Number_Of_Checklist_Documents_Rejected__c);
        System.debug(loggingLevel.error,'testApplication4.Pending_Document_Checklist_Count__c'+testApp.Pending_Document_Checklist_Count__c);
        System.debug(loggingLevel.error,'testApplication4.Is_PreTila_Signed__c'+testApp.Is_PreTila_Signed__c);  
        System.debug(loggingLevel.error,'testApplication4.Incomplete_App_Auto_Withdraw_Date__c'+testApp.Incomplete_App_Auto_Withdraw_Date__c);  
       
        Test.startTest();
        ApplicationAutoWithdrawJob testJob = new ApplicationAutoWithdrawJob();
        String jobType = testJob.getBatchJobType();
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();
        
        fsCore__Lending_Application__c testApplication = [select id, fsCore__Application_Status__c, Pre_TILA_Sent_Date_First__c  from fsCore__Lending_Application__c where id =:testApplication4.id];
        System.debug(loggingLevel.error,'testApplication4.Incomplete_App_Auto_Withdraw_Date__c'+testApplication.Pre_TILA_Sent_Date_First__c);  
       
        System.assertEquals('Withdrawn', testApplication.fsCore__Application_Status__c);
        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ApplicationAutoWithdrawJobTest',
                                       CRON_EXP, 
                                       new ApplicationAutoWithdrawJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
    
}