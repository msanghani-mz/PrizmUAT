/**
 * Class Name  : SampleApplicantGeneratorTest
 * Description : This class has test method for SampleApplicationGenerator
 * Author      : Financial Spectra
 *
 */
@isTest
private class SampleApplicationGeneratorTest{
    
    @testSetup
    static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();

        //create company and branch

        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});
       
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company'
                                                                                            , 'TESTCO'
                                                                                            , '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch'
                                                                                         , 'VLB'
                                                                                         , testCompany.Id
                                                                                         , null
                                                                                         , null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 

        //create product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'DNL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='DNL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');
         
        //create contract template
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;

        //create Contract Template
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
                                                                                ('Test Contract Template'
                                                                               , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                               , testPaymentAlloc.Id
                                                                               , 1);
        insert testContractTemplate;   
        System.debug(LoggingLevel.ERROR, testContractTemplate.fsCore__Contract_Template_Code__c);
         
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert'); 

        //create Account
        Account nAccount = TestHelperData.createAccount();
        nAccount.fsCore__Email__c = 'test@example.com.sample';
        Database.insert(nAccount);
        System.assert(nAccount.Id != null, 'Test Account created assert');      


        
        fsCore__Stage_Setup__c testStage2 = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                  , 2);

        testStage2.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage2.fsCore__Stage_Code__c = 'DNL_FUNDING';
        
        insert testStage2;
        
        System.assert(testStage2.Id != null, 'Test stage 2 created assert');         
        
    }

    private static testMethod void testSampleApplicationGenerator(){
        
        Test.startTest(); 
        SampleApplicationGenerator appGen = new SampleApplicationGenerator(1);
        appGen.setBranch('VLB');
        appGen.setProduct('DNL');
        appGen.setContractTemplate('TEST_CONTRACT_TEMPLATE');
        appGen.setAsTest(True);
        appGen.setApplicationRecordType('Active');
        appGen.setStage('DNL_FUNDING');
        appGen.setApplicationStartDate(Date.newInstance(2017, 6, 19));
        appGen.setApplicationStatus('Approved for TILA');
        appGen.generateData();

        SampleApplicationRelatedDataGenerator sampleRelatedDataGen = new SampleApplicationRelatedDataGenerator(1);

        sampleRelatedDataGen.setFundingStage('DNL_FUNDING');

        sampleRelatedDataGen.generateData();

        Test.stopTest();      





    }



}