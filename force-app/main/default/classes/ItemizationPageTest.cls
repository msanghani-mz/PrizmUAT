/*
 * Class Name   - ItemizationPageTest
 * Description  - Test class for ItemizationPageController and ItemizationPageUtil
 * Developer(s) - Financial Spectra
 */
@isTest(seeAllData=false)
private class ItemizationPageTest{
    
    @testSetup
    static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
            , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
        //create company and branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        
        
        //
        //create balance, transaction and itemization setup
        //
        Map<String, fsCore__Balance_Setup__c> testBalanceSetupMap = fsCore.TestHelperFinancial.getTestBalanceSetupMap();
        System.assert(testBalanceSetupMap.size() > 0, 'Test Balance setup created assert');  
        System.debug(testBalanceSetupMap);
        
        Map<String, fsCore__Transaction_Setup__c> testTxnSetupMap = fsCore.TestHelperFinancial.getTestTransactionSetupMap();
        System.assert(testTxnSetupMap.size() > 0, 'Test Transaction setup created assert');        
        System.debug('txn'+testTxnSetupMap);
        
        
        Map<String, fsCore__Itemization_Setup__c> testItmzSetupMap = fsCore.TestHelperFinancial.getTestItemizationSetupMap();
        System.assert(testItmzSetupMap.size() > 0, 'Test Itemization setup created assert');  
        
        //
        //create prepaid fee with tiers
        //
        fsCore__Fee_setup__c testAppFee = fsCore.TestHelperProduct.getTestFeeSetup('Test Prepaid Fee', null
                                                                                   , fsCore.Constants.FEE_REC_TYPE_PREPAID
                                                                                   , 'Origination Fee'
                                                                                   , 100, 1);
        insert testAppFee;
        System.assert(testAppFee.Id != null, 'Test Prepaid Fee created assert');
        
        fsCore__Fee_setup__c testAppFinanceFee = fsCore.TestHelperProduct.getTestFeeSetup('Test Finance Fee', null
                                                                                          , fsCore.Constants.FEE_REC_TYPE_FINANCE
                                                                                          , 'Prepaid Finance Charge'
                                                                                          , 100, 1);
        insert testAppFinanceFee;
        System.debug(testAppFinanceFee);
        System.assert(testAppFinanceFee.Id != null, 'Test Financed Fee created assert');
        
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
        //create product itemizations
        //
        List<fsCore__Product_Itemization_Setup__c> testProductItzms = new List<fsCore__Product_Itemization_Setup__c>();
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Funds to Customer')
                                                                                     , 'Yes'
                                                                                     , 1, fsCore.Constants.PLUS));
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Down Payment')
                                                                                     , 'No'
                                                                                     , 2, fsCore.Constants.MINUS));
        
        fsCore__Product_Itemization_Setup__c testPpdFeeItzm = fsCore.TestHelperProduct.getTestProductItemizationSetup(
            testProduct.Id
            , testItmzSetupMap.get('Application Fee')
            , 'No'
            , 3, fsCore.Constants.PLUS);
        testPpdFeeItzm.fsCore__Fee_Category__c = 'Origination Fee';
        testProductItzms.add(testPpdFeeItzm);
        
        fsCore__Product_Itemization_Setup__c testFinFeeItzm = fsCore.TestHelperProduct.getTestProductItemizationSetup(
            testProduct.Id
            , testItmzSetupMap.get('Financed Fee')
            , 'No'
            , 4, fsCore.Constants.PLUS);
        testFinFeeItzm.fsCore__Fee_Category__c = 'Prepaid Finance Charge';
        testProductItzms.add(testFinFeeItzm);

        insert testProductItzms;
        System.assert(testProductItzms.size() > 0, 'Test product itemizations created assert');        
        
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
        
        fsCore__Contract_Template_Itemization_Setup__c testCTItmz = fsCore.TestHelperProduct.getTestContractTemplateItemizationSetup(
            testContractTemplate.Id
            , testItmzSetupMap.get('Funds to Customer')
            , 'Yes'
            , 1, fsCore.Constants.PLUS);
        insert testCTItmz;
        System.assert(testCTItmz.Id != null, 'Test contract template itemization created assert');        
        
        
        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication 
            = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                               , testBranch
                                                                               , testProduct
                                                                               , testContractTemplate
                                                                               , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        
        
        //
        //create Lending Application itemizations
        //
        List<fsCore__Lending_Application_Itemization__c> testAppItemizations 
            = fsCore.TestHelperLendingApplication.getTestApplicationItemizations(testApplication, testProductItzms);
        insert testAppItemizations;
        System.assert(testAppItemizations.size() > 0, 'Test Lending Application itemizations created assert');
        
        //
        //create settlement rates
        //
        DNL_Settlement_Rates__c rate1 = new DNL_Settlement_Rates__c(Original_Creditor__c='Test Creditor 1',Current_Creditor__c='Test Creditor 1');
        DNL_Settlement_Rates__c rate2 = new DNL_Settlement_Rates__c(Original_Creditor__c='Test Creditor 2',Current_Creditor__c='Test Creditor 2');
        DNL_Settlement_Rates__c rate3 = new DNL_Settlement_Rates__c(Original_Creditor__c='Test Creditor 3',Current_Creditor__c='Test Creditor 3');
        DNL_Settlement_Rates__c rate4 = new DNL_Settlement_Rates__c(Original_Creditor__c='Test Creditor 4',Current_Creditor__c='Test Creditor 4');
        List<DNL_Settlement_Rates__c> rates = new List<DNL_Settlement_Rates__c>{rate1, rate2, rate3, rate4};
        for(DNL_Settlement_Rates__c rt : rates){
            rt.Start_Date__c = System.today();
            rt.Average_Of_Adjusted_Settlement__c = 48.00;
            rt.IsActive__c = true;
            rt.Type__c = 'Legal';
        }
        insert rates;
        System.assert(rate1.Id != null);
        System.assert(rate2.Id != null);
        System.assert(rate3.Id != null);
        System.assert(rate4.Id != null);
        
        //SFS Settings
        SFS_System_Settings__c sfsSettings = TestHelperData.createSFSSystemSettings();
        sfsSettings.Default_Branch_Code_DNL__c = testBranch.fsCore__Branch_Code__c;
        sfsSettings.Default_Branch_ID_DNL__c = testBranch.Id;
        sfsSettings.Default_Product_Code_DNL__c = testProduct.fsCore__Product_Code__c;
        sfsSettings.Default_Product_ID_DNL__c = testProduct.Id;
        sfsSettings.Default_Company_Code_DNL__c = testCompany.fsCore__Company_Code__c;
        sfsSettings.Default_Company_ID_DNL__c = testCompany.Id;
        upsert sfsSettings;
        System.assert(sfsSettings.Id != null);
    }
    
    @isTest
    private static void testGetItemizations(){
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperData.getApplication('Test Application');
        System.assert(testApplication != null);
        
        Test.startTest();
        ItemizationWrapper itmzWrp = ItemizationPageController.getItemizationWrapper(testApplication.Id);
        System.assertEquals(testApplication.Id, itmzWrp.applicationId);
        System.assertEquals(4, itmzWrp.itemizations.size());
        
        itmzWrp.itemizations[0].settledDate = System.today().addDays(-1);
        itmzWrp.itemizations[1].settledDate = System.today();
        itmzWrp.itemizations[2].settledDate = System.today().addDays(-3);
        itmzWrp.itemizations[3].settledDate = System.today().addDays(-2);
        itmzWrp.itemizations.sort();
        
        System.assertEquals(System.today().addDays(-3), itmzWrp.itemizations[0].settledDate);
        System.assertEquals(System.today().addDays(-2), itmzWrp.itemizations[1].settledDate);
        System.assertEquals(System.today().addDays(-1), itmzWrp.itemizations[2].settledDate);
        System.assertEquals(System.today(), itmzWrp.itemizations[3].settledDate);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testAddItemizations(){
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperData.getApplication('Test Application');
        System.assert(testApplication != null);
        
        ItemizationWrapper itmzWrp = ItemizationPageController.getItemizationWrapper(testApplication.Id);
        String itmzWrpJSON = JSON.serialize(itmzWrp);
        
        Test.startTest();
        itmzWrp = ItemizationPageController.addNewItemization(itmzWrpJSON);
        System.assertEquals(false, itmzWrp.hasError);
        System.assertEquals(5, itmzWrp.itemizations.size());
        System.assertEquals(null, itmzWrp.itemizations[0].appItemizationId);
        System.assertEquals(null, itmzWrp.itemizations[0].itemizationId);
        System.assertEquals(fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT, itmzWrp.itemizations[0].itemizationFamily);
        System.assertEquals(fsCore.Constants.ITMZ_SOURCE_MANUAL, itmzWrp.itemizations[0].itemizationSource);
        System.assertEquals(5, itmzWrp.itemizations[0].itemizationList.size());
        
        ItemizationRowObject itmzRow = ItemizationPageController.getItemizationDetails(itmzWrp.itemizations[0].itemizationList[1].value, itmzWrp.applicationId);
        System.assertNotEquals(null, itmzRow.itemizationId);
        Test.stopTest();
    }

    @isTest
    private static void testCalcAndSaveItemizations(){
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperData.getApplication('Test Application');
        System.assert(testApplication != null);
        
        ItemizationWrapper itmzWrp = ItemizationPageController.getItemizationWrapper(testApplication.Id);
        itmzWrp.itemizations[0].settledDate = System.today().addDays(-1);
        itmzWrp.itemizations[0].actualAmount = 1000;
        itmzWrp.itemizations[0].currentCreditorName = 'Test Creditor 1';
        
        itmzWrp.itemizations[1].settledDate = System.today();
        itmzWrp.itemizations[1].actualAmount = 2000;
        itmzWrp.itemizations[1].currentCreditorName = 'Test Creditor 2';

        itmzWrp.itemizations[2].settledDate = System.today().addDays(-3);
        itmzWrp.itemizations[2].actualAmount = 3000;
        itmzWrp.itemizations[2].currentCreditorName = 'Test Creditor 3';

        itmzWrp.itemizations[3].settledDate = System.today().addDays(-2);
        itmzWrp.itemizations[3].actualAmount = 4000;
        itmzWrp.itemizations[3].currentCreditorName = 'Test Creditor 4';
        
        String itmzWrpJSON = JSON.serialize(itmzWrp);
        
        Test.startTest();
        itmzWrp = ItemizationPageController.calculateItemizations(itmzWrpJSON);
        System.assertEquals(false, itmzWrp.hasError);
        
        itmzWrpJSON = JSON.serialize(itmzWrp);
        itmzWrp = ItemizationPageController.saveItemizations(itmzWrpJSON);
        System.assertEquals(false, itmzWrp.hasError);
        Test.stopTest();
    }
    
    @isTest
    private static void testItemizationUtilMethods(){
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperData.getApplication('Test Application');
        System.assert(testApplication != null);
        
        ItemizationWrapper itmzWrp = ItemizationPageController.getItemizationWrapper(testApplication.Id);
        
        Test.startTest();
        testApplication.fsCore__Rate__c = null;
        Decimal rate = ItemizationPageUtil.getRateForPrepaidFinanceCharge(testApplication);
        System.assertEquals(null, rate);
        
        testApplication.fsCore__Rate__c = 4.50;
        rate = ItemizationPageUtil.getRateForPrepaidFinanceCharge(testApplication);
        System.assertEquals(4.50, rate);
        
        List<fsCore__Product_Itemization_Setup__c> prodItmzList = ItemizationPageUtil.getProductItemizations(itmzWrp.productId);
        System.assertEquals(4, prodItmzList.size());
        ItemizationPageUtil.Itemization prodItmz = ItemizationPageUtil.getProductItemization(prodItmzList.get(0).Id);
        System.assertNotEquals(null, prodItmz);

        List<fsCore__Contract_Template_Itemization_Setup__c> ctItmzList = ItemizationPageUtil.getContractTemplateItemizations(itmzWrp.contractTemplateId);
        System.assertEquals(1, ctItmzList.size());
        ItemizationPageUtil.Itemization ctItmz = ItemizationPageUtil.getContractTemplateItemization(ctItmzList.get(0).Id);
        System.assertNotEquals(null, ctItmz);
        
        Map<String, ItemizationPageUtil.Itemization> itmzSetupMap = ItemizationPageUtil.getSetupItemizations(itmzWrp.productId, null);
        System.assertEquals(4, itmzSetupMap.size());
        itmzSetupMap = ItemizationPageUtil.getSetupItemizations(null, itmzWrp.contractTemplateId);
        System.assertEquals(1, itmzSetupMap.size());
        
        Test.stopTest();
    }
    
    @isTest
    private static void testSettlementRates(){
        Test.startTest();
        Decimal rate = ItemizationPageController.getEstimatedSettlementPercentage('Test Creditor 1', 'Test Creditor 1', 'Legal');
        System.assertEquals(48.00, rate);
        
        rate = ItemizationPageController.getEstimatedSettlementPercentage('Test Creditor 1', 'Test Creditor 1', 'Non-Legal');
        System.assertEquals(40.00, rate);
        
        SFS_System_Settings__c sfsSettings = SFS_System_Settings__c.getInstance();
        sfsSettings.Is_DNL_Settlement_Active_Rates_Only__c = false;
        sfsSettings.DNL_Settlement_Unmatched_Rate__c = null;
        update sfsSettings;
        
        rate = ItemizationPageController.getEstimatedSettlementPercentage('Test Creditor 1', 'Test Creditor 1', 'Non-Legal');
        System.assertEquals(50.00, rate);
        Test.stopTest();
    }
}