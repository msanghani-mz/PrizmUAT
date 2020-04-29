/**
* Class Name  : UnderwriterApprovalDateProcessorTest
* Description : This class has test method for UnderwriterApprovalDateProcessor
* Author      : Financial Spectra
*
*/
@isTest
public with sharing class UnderwriterApprovalDateProcessorTest {
    @testSetup
    static void createTestData(){
        //create layouts
        createCustomLayouts();

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

        Map<String, fsCore__Transaction_Setup__c> testTxnSetupMap = fsCore.TestHelperFinancial.getTestTransactionSetupMap();
        System.assert(testTxnSetupMap.size() > 0, 'Test Transaction setup created assert');        

        Map<String, fsCore__Itemization_Setup__c> testItmzSetupMap = fsCore.TestHelperFinancial.getTestItemizationSetupMap();
        System.assert(testItmzSetupMap.size() > 0, 'Test Itemization setup created assert');        

        //create Checklist Setup
        List<fsCore__Checklist_Setup__c> testCheckList = TestHelperData.createcheckList();
        insert testCheckList;

        //create Checklist Detail Setup
        List<fsCore__Checklist_Detail_Setup__c> testChecklistDetailSetUp = TestHelperData.createcheckListDetail(testCheckList);
        insert testChecklistDetailSetUp;

        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                            , 'DNL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        
 
        //
        //create product itemizations
        // 1 + Funds to Customer
        // 2 - Down Payment
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

        List<Account> accountlist = new List<Account>();
        Account nAccount = TestHelperData.createAccount();
        Account coAppAccount = TestHelperData.createAccount('TEST','LASTNAME');
        accountlist.add(nAccount);
        accountlist.add(coAppAccount);
        Database.insert(accountlist);

        System.assert(nAccount.Id != null, 'Test Account created assert');

        List<Account> testAccountList = [select id, personcontactId from Account where id in (:nAccount.id,:coAppAccount.Id) ];

        Account testAccount = testAccountList[0];
        Account testCoAccount = testAccountList[1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
         //
        //create pricing setup
        //
         fsCore__Pricing_Setup__c testPricing = fsCore.TestHelperProduct.getTestPricingSetup('Test Pricing'
                                                                            , fsCore.Constants.PRICING_METHOD_INTEREST_RATE
                                                                            , 4.00
                                                                            , 12
                                                                            , 1);
        testPricing.Is_Generate_Additional_Pricing__c = true;
        testPricing.Payment_Increase_For_Option_1__c = 10;
        testPricing.Payment_Increase_For_Option_2__c = 20;
        insert testPricing;
        System.assert(testPricing.Id != null, 'Test pricing created assert');        
        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , testContractTemplate
                                                                              , 'Test Application');
        testApplication.fsCore__Pricing_Name__c = testPricing.Id ;

        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                            ,testAccount.Id
                                                                                            ,testAccount.PersonContactId
                                                                                            ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');

        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                            ,testAccount.Id
                                                                                            ,testAccount.PersonContactId
                                                                                            ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');


        //create application checklist
        List<fsCore__Lending_Application_Checklist__c> testAppChklistItems = fsCore.TestHelperLendingApplication.getTestApplicationChecklists(testApplication, testChecklistDetailSetUp);
        insert testAppChklistItems;


        //
        //create Lending Application itemizations
        //
        List<fsCore__Lending_Application_Itemization__c> testAppItemizations = fsCore.TestHelperLendingApplication.getTestApplicationItemizations(
                                                                                                      testApplication
                                                                                                    , testProductItzms);
        integer counter = 1;
        for (fsCore__Lending_Application_Itemization__c itm :testAppItemizations){
            if (counter == 1){
                itm.Current_Creditor__c = 'TTE';
                itm.Original_Creditor__c = 'TTE';
            }
        }
        
        insert testAppItemizations;
        System.assert(testAppItemizations.size() > 0, 'Test Lending Application itemizations created assert');        

    }    

     public static void createCustomLayouts(){
            List<fsCore__Custom_Layout_Setup__c> customLayouts = new List<fsCore__Custom_Layout_Setup__c>();
            customLayouts.add(getApplicationWizardLayout());
            customLayouts.add(getApplicationTabbedLayout());

            insert customLayouts;
    }

    private static fsCore__Custom_Layout_Setup__c getApplicationWizardLayout(){
        Map<String, RecordType> recordTypeMapByName = fsCore.RecordTypeUtil.getInstance()
                                                            .getRecordTypeMapByName(Schema.SObjectType.fsCore__Custom_Layout_Setup__c.getName());
        
        fsCore__Custom_Layout_Setup__c wizardLayout = new fsCore__Custom_Layout_Setup__c();
        wizardLayout.Name = 'Application Wizard Master';
        wizardLayout.RecordTypeId = recordTypeMapByName.get(fsCore.CustomLayoutUtil.LAYOUT_TYPE_WIZARD).Id;
        wizardLayout.fsCore__Is_Active__c = true;
        wizardLayout.fsCore__Is_Master__c = true;
        wizardLayout.fsCore__Is_Full_Screen_Mode__c = false;
        wizardLayout.fsCore__Is_Sidebar_Enabled__c = false;
        wizardLayout.fsCore__Default_Product_Availability__c = fsCOre.Constants.MAPPING_AVAILABLE;
        wizardLayout.fsCore__Object_Name__c = 'fscore__lending_application__c';
        wizardLayout.fsCore__Object_Record_Type_Name__c= null;
        wizardLayout.fsCore__Profile_Name__c = null;
        wizardLayout.fsCore__Profile_Id__c = null;
        wizardLayout.fsCore__Selection_Order__c = 99;
        wizardLayout.fsCore__Section_Title_1__c = 'Application';
        wizardLayout.fsCore__Section_Title_2__c = '';
        wizardLayout.fsCore__Section_Title_3__c = '';
        wizardLayout.fsCore__Page_Name_1__c = 'fsCore__lendingAppDetailWizardPage';
        wizardLayout.fsCore__Page_Name_2__c = '';
        wizardLayout.fsCore__Page_Name_3__c = '';
        wizardLayout.fsCore__Is_Deletable__c = false;
        wizardLayout.fsCore__Is_Updateable__c = true;
        
        return wizardLayout;
    }

    private static fsCore__Custom_Layout_Setup__c getApplicationTabbedLayout(){
        Map<String, RecordType> recordTypeMapByName = fsCOre.RecordTypeUtil.getInstance()
                                                            .getRecordTypeMapByName(Schema.SObjectType.fsCore__Custom_Layout_Setup__c.getName());
        
        fsCore__Custom_Layout_Setup__c tabbedLayout = new fsCore__Custom_Layout_Setup__c();
        tabbedLayout.Name = 'Application Tabbed View Master';
        tabbedLayout.RecordTypeId = recordTypeMapByName.get(fsCore.CustomLayoutUtil.LAYOUT_TYPE_TABBED).Id;
        tabbedLayout.fsCore__Is_Active__c = true;
        tabbedLayout.fsCore__Is_Master__c = true;
        tabbedLayout.fsCore__Is_Full_Screen_Mode__c = false;
        tabbedLayout.fsCore__Is_Sidebar_Enabled__c = true;
        tabbedLayout.fsCore__Default_Product_Availability__c = fsCOre.Constants.MAPPING_AVAILABLE;
        tabbedLayout.fsCore__Object_Name__c = 'fscore__lending_application__c';
        tabbedLayout.fsCore__Object_Record_Type_Name__c= null;
        tabbedLayout.fsCore__Profile_Name__c = null;
        tabbedLayout.fsCore__Profile_Id__c = null;
        tabbedLayout.fsCore__Selection_Order__c = 99;
        tabbedLayout.fsCore__Section_Title_1__c = 'Detail';
        tabbedLayout.fsCore__Section_Title_2__c = 'Related';
        tabbedLayout.fsCore__Section_Title_3__c = 'Underwriting';
        tabbedLayout.fsCore__Section_Title_4__c = 'Schedules';
        tabbedLayout.fsCore__Section_Title_5__c = 'Activities';
        tabbedLayout.fsCore__Sidebar_Title__c = 'Summary';
        tabbedLayout.fsCore__Page_Name_1__c = 'fsCore__lendingAppDetailTabPage';
        tabbedLayout.fsCore__Page_Name_2__c = 'fsCore__lendingAppRelatedTabPage';
        tabbedLayout.fsCore__Page_Name_3__c = 'fsCore__lendingAppUnderwritingTabPage';
        tabbedLayout.fsCore__Page_Name_4__c = 'fsCore__lendingAppSchedulesTabPage';
        tabbedLayout.fsCore__Page_Name_5__c = 'fsCore__lendingAppActivitiesTabPage';
        tabbedLayout.fsCore__Sidebar_Page_Name__c = 'fsCore__lendingAppSidebarTabPage';
        tabbedLayout.fsCore__Highlight_Field_1__c = 'fscore__branch_name_formula__c';
        tabbedLayout.fsCore__Highlight_Field_3__c = 'fscore__product_name_formula__c';
        tabbedLayout.fsCore__Highlight_Field_2__c = 'fscore__record_type_formula__c';
        tabbedLayout.fsCore__Highlight_Field_4__c = 'fscore__application_date__c';
        tabbedLayout.fsCore__Highlight_Field_5__c = 'fscore__loan_amount__c';
        tabbedLayout.fsCore__Highlight_Field_6__c = 'fsCore__Total_Of_Payments__c';
        tabbedLayout.fsCore__Default_Tab__c = '1';
        tabbedLayout.fsCore__Is_Deletable__c = false;
        tabbedLayout.fsCore__Is_Updateable__c = true;
        tabbedLayout.fsCore__Is_Activities_Enabled__c = true;
        tabbedLayout.fsCore__Is_Approval_History_Enabled__c = true;
       
        return tabbedLayout;
    }    
    private static testMethod void testApprovalDateProcessor(){
        fsCore__Lending_Application__c testApplication = [SELECT id, name 
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];   
        
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        acrInput.addRecord(testApplication.Id);
        
        Test.startTest(); 
        UnderwriterApprovalDateProcessor analysisApprovalDate = new UnderwriterApprovalDateProcessor();
        analysisApprovalDate.setInput(acrInput);
        analysisApprovalDate.process();
        analysisApprovalDate.getOutput();
        Test.stopTest();   
    }
    
    private static testMethod void addError(){
        
        fsCore__Lending_Application__c testApplication = [SELECT id, name 
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];  
        
        UnderwriterApprovalDateProcessor analysisApprovalDate = new UnderwriterApprovalDateProcessor();
        analysisApprovalDate.addError('Test','Test','Test',testApplication.Id,' Dummy');
        
    }
    
    
}