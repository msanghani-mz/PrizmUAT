/* 
 * Class   : AppCancelVoidEnvelopeQueueableTest
 * Purpose : Test class for ApplicationCancelVoidEnvelopeQueueable       
 * Author  : Financial Spectra
 */
@isTest 
private class AppCancelVoidEnvelopeQueueableTest {
  @testsetup 
    static void createTestData(){
        
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
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Loan Application');
      
        testApplication.Loan_Type__c='DNL';
        insert testApplication;
        System.assert(testApplication.Id != null , 'Test Lending Application created assert');        
        
        //
        //create primary customer
        //
        List<fsCore__Lending_Application_Customer__c> testPrimaryCustomer = new List<fsCore__Lending_Application_Customer__c>();
        fsCore__Lending_Application_Customer__c testPrimaryCustomer1= fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
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
    private static void testQueueable(){
        fsCore__Lending_Application__c testApplication = [SELECT Id
                                                           , Name
                                                           , Loan_Type__c
                                                           , fsCore__Record_Type_Formula__c
                                                           , RecordType.DeveloperName
                                                           , fsCore__Is_Application_Read_Only__c
                                                           , fsCore__Application_Status__c
                                                           FROM fsCore__Lending_Application__c WHERE Loan_Type__c='DNL' Limit 1];
        
       
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('DNL_Loan').getRecordTypeId();
        testApplication.RecordTypeId = recTypeId; 
      
        testApplication.fsCore__Application_Status__c = 'COVID-Cancelled';
        update testApplication;
        
        System.debug(loggingLevel.Debug,'testApplication'+testApplication);
        fsCore__Lending_Application__c testApp = [SELECT Id,RecordTypeId,fsCore__Record_Type_Formula__c,RecordType.DeveloperName,Loan_Type__c,fsCore__Application_Status__c from fsCore__Lending_Application__c Where Id =:testApplication.Id];
        System.Debug('testApp:--'+testApp);
        
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617');
        dsStatus.Lending_Application_Name__c = testApplication.id;
        insert dsStatus;
        
        Set<id> appIds = new Set<Id>();
       appIds.add(testApp.Id);
       
        Test.startTest();
      	ApplicationCancelVoidEnvelopeQueueable queueableObj = new ApplicationCancelVoidEnvelopeQueueable(appIds);
        ID jobID = System.enqueueJob(queueableObj);
        Test.stopTest();
        testApp = [select id, fsCore__Application_Status__c from fsCore__Lending_Application__c where id = :testApplication.id];
        dsfs__DocuSign_Status__c docStatus = [select id, dsfs__Envelope_Status__c, Lending_Application_Name__c from dsfs__DocuSign_Status__c where id =: dsStatus.id];
        
    }

    
}