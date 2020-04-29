/*
* Class Name   - ApplicationWithdrawVoidEnvelopeJobTest
* Description  - Test class for ApplicationAutoWithdrawJob
*/
@isTest
private class ApplicationWithdrawVoidEnvelopeJobTest{
    
    @testsetup static void createTestData(){
        
        //create custom settings
        //fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING, fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});
        
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
                                                                                            , 'DNL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');       
        
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
        fsCore__Lending_Application__c testApplication2 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Loan Application');
        testApplication2.Loan_Processing_Letter_Sent_Date__c= System.today().adddays(-35);
        testApplication2.Pre_TILA_Sent_Date__c = Date.Today()-20;
        testApplication2.Pre_Tila_Sent_Date_First__c = testApplication2.Pre_TILA_Sent_Date__c;
        testApplication2.Is_PreTila_Signed__c = false;
        testApplication2.Loan_Type__c='DNL';
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
        insert testPrimaryCustomer;
        System.assert(testPrimaryCustomer.Size()>0, 'Test primary customers created assert'); 
        
    }
    
    private static dsfs__DocuSign_Status__c createDocusignRecord(String pEnvelopeId){
        
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        
        dsStatus.dsfs__DocuSign_Envelope_ID__c = pEnvelopeId;
        //dsStatus.Document_Type__c = pDocumentType;
        dsStatus.dsfs__Envelope_Status__c = 'Sent';
        //dsStatus.Lending_Application_Name__r.fsCore__Application_Status__c = 'Withdrawn';
        
        return  dsStatus;
        
    }    
    
    @isTest
    private static void testJobExecution3(){
        fsCore__Lending_Application__c testApplication3 = [SELECT Id
                                                           , Name
                                                           , Loan_Type__c
                                                           , fsCore__Record_Type_Formula__c
                                                           , RecordType.DeveloperName
                                                           , Incomplete_App_Auto_Withdraw_Date__c
                                                           , Loan_Processing_Letter_Sent_Date__c
                                                           , Is_PreTila_Signed__c
                                                           , fsCore__Product_Name__c
                                                           , fsCore__Is_Application_Read_Only__c
                                                           , Pre_TILA_Sent_Date__c
                                                           , Pre_Tila_Sent_Date_First__c
                                                           FROM fsCore__Lending_Application__c WHERE Loan_Type__c='DNL' Limit 1];
        
        fsCore__Product_Setup__c testProduct = [SELECT ID,fsCore__Active_Application_Record_Type__c From fsCore__Product_Setup__c WHERE ID = :testApplication3.fsCore__Product_Name__c ];
        testProduct.fsCore__Active_Application_Record_Type__c='DNL_Loan'; 
        testProduct.Credit_Pull_Report_Record_Type_Name__c='DNL';
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract'; 
        update testProduct;
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('DNL_Loan').getRecordTypeId();
        testApplication3.RecordTypeId = recTypeId; 
        testApplication3.Pre_TILA_Sent_Date__c = Date.Today()-20;
        testApplication3.Is_PreTila_Signed__c = false;
        testApplication3.fsCore__Application_Status__c = 'Withdrawn';
        update testApplication3;
        
        System.debug(loggingLevel.Debug,'testApplication3'+testApplication3);
        System.debug('testApplication3.Incomplete_App_Auto_Withdraw_Date__c'+testApplication3.Incomplete_App_Auto_Withdraw_Date__c);
        fsCore__Lending_Application__c testApp = [SELECT Id,RecordTypeId,fsCore__Record_Type_Formula__c,RecordType.DeveloperName,Loan_Type__c,Is_PreTila_Signed__c,Incomplete_App_Auto_Withdraw_Date__c,Number_Of_Checklist_Documents_Rejected__c,Pending_Document_Checklist_Count__c from fsCore__Lending_Application__c Where Id =:testApplication3.Id];
        System.Debug('testApp3:--'+testApp);
        
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617');
        dsStatus.Lending_Application_Name__c = testApplication3.id;
        insert dsStatus;
        
        Test.startTest();
        ApplicationWithdrawVoidEnvelopeJob testJob = new ApplicationWithdrawVoidEnvelopeJob();
        //String jobType = testJob.getBatchJobType();
        //System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        
        Test.stopTest();
        fsCore__Lending_Application__c testApplication = [select id, fsCore__Application_Status__c from fsCore__Lending_Application__c where id = :testApplication3.id];
        dsfs__DocuSign_Status__c docStatus = [select id, dsfs__Envelope_Status__c, Lending_Application_Name__c from dsfs__DocuSign_Status__c where id =: dsStatus.id];
        //System.assertEquals('Voided', docStatus.dsfs__Envelope_Status__c, 'App Status Withdrawn assert');
        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ApplicationWithdrawVoidEnvelopeJobTest',
                                       CRON_EXP, 
                                       new ApplicationWithdrawVoidEnvelopeJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
}