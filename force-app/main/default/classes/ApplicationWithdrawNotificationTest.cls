/**
 * @File Name          : ApplicationWithdrawNotificationTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 3/17/2020, 8:28:07 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/17/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class ApplicationWithdrawNotificationTest {
    @testSetup
    public static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});
        //Account
        Account acc = new Account();
        acc.Name = 'John Smith';
        insert acc;
        system.debug(logginglevel.error,'1');
        //Contact
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.FirstName = 'John';
        con.LastName = 'Smith';
        insert con;
        system.debug(logginglevel.error,'2');
        
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        system.debug(logginglevel.error,'3');
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        system.debug(logginglevel.error,'4');
        
        //Branch data setup in UserBranchUtil
        Map<String, String> branchParams = new Map<String, String>();
        branchParams.put(fsCore.UserBranchUtil.BRANCH_KEY_NAME,testBranch.Name);
        branchParams.put(fsCore.UserBranchUtil.BRANCH_KEY_CODE,testBranch.fsCore__Branch_Code__c);
        fsCore.UserBranchUtil.setDefaultBranch(UserInfo.getUserId(),branchParams);
        system.debug(logginglevel.error,'5');
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Name_Format__c='Account Only';
        testProduct.fsCore__Customer_Type__c= 'Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        system.debug(logginglevel.error,'6');
        
        //Create balance, transaction and itemization setup
        Map<String, fsCore__Balance_Setup__c> testBalanceSetupMap = fsCore.TestHelperFinancial.getTestBalanceSetupMap();
        System.assert(testBalanceSetupMap.size() > 0, 'Test Balance setup created assert');        
        system.debug(logginglevel.error,'7');
        Map<String, fsCore__Transaction_Setup__c> testTxnSetupMap = fsCore.TestHelperFinancial.getTestTransactionSetupMap();
        System.assert(testTxnSetupMap.size() > 0, 'Test Transaction setup created assert');        
        system.debug(logginglevel.error,'8');
        Map<String, fsCore__Itemization_Setup__c> testItmzSetupMap = fsCore.TestHelperFinancial.getTestItemizationSetupMap();
        System.assert(testItmzSetupMap.size() > 0, 'Test Itemization setup created assert');    
        system.debug(logginglevel.error,'9');
        //Create Product Itemization
        List<fsCore__Product_Itemization_Setup__c> testProductItzms = new List<fsCore__Product_Itemization_Setup__c>();
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Funds to Customer')
                                                                                     , 'Yes'
                                                                                     , 1, fsCore.Constants.PLUS));
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Down Payment')
                                                                                     , 'No'
                                                                                     , 2, fsCore.Constants.MINUS));
        fsCore__Product_Itemization_Setup__c testFeeItzm = fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                                                   , testItmzSetupMap.get('Application Fee')
                                                                                                                   , 'No'
                                                                                                                   , 3, fsCore.Constants.PLUS);
        
        testFeeItzm.fsCore__Fee_Category__c = fsCore.Constants.FEE_CATEG_APPLICATION;
        testProductItzms.add(testFeeItzm);
        System.Debug(loggingLevel.ERROR, 'testProductItzms'+testProductItzms);
        insert testProductItzms;
        System.assert(testProductItzms.size() > 0, 'Test product itemizations created assert'); 
        system.debug(logginglevel.error,'10');
        
        //create Payment Allocation Method
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        System.assert(testPaymentAlloc.Id != null, 'Test payment allocation created assert');
        system.debug(logginglevel.error,'11');
        //Contract Template 
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate; 
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');   
        system.debug(logginglevel.error,'11');
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = acc.id;
        testApplication.fsCore__Primary_Customer_Contact__c = con.id;
        insert testApplication;
        system.debug(logginglevel.error,'12');
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
    } 
    @isTest
    private static void test1(){
         fsCore__Lending_Application__c testApplication =[SELECT Id, Withdraw_Reason__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        List<Id> appIds = new List<Id>();
        appIds.add(testApplication.id);
        
        Test.startTest();
        ApplicationWithdrawnNotification.sendNotification(appIds);     
        Test.stopTest(); 
    } 
}