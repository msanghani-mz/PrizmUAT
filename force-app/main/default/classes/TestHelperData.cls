/**
 * Class Name  : TestHelperData
 * Description : This class has helper methods for data creation.   
 * Author      : Financial Spectra
 *
 */       
public without sharing class TestHelperData {

    /*method to create opportunity data*/
    public static Opportunity createDNLOpportunity(Id pAccountID){

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'DNL Prospecting';
        opp.Amount = 1000;
        opp.CloseDate = Date.today();
        opp.Application_Signed_Date__c = Date.today();
        opp.Payment_Cycle__c = 'Monthly';
        opp.Debit_Day_First__c = opp.Application_Signed_Date__c.Day();
        opp.Opportunity_Type__c = 'DNL';
        opp.Loan_Number_Of_Payments__c = 12;
        opp.AccountId = pAccountID;
        opp.Co_Applicant_Name__c = pAccountID;
        opp.Program_Id__c = 'test';
        opp.Program_Type__c = 'test';
        opp.Program_Number_Of_Payments__c = 12;
        opp.Debt_Count__c = 1 ;
        opp.Remaining_Months_DRP_Program__c = 2;
        opp.Enrolled_Date__c = Date.today();
        opp.Unsettled_Debt__c = 200;
        opp.Cash_in_Dedicated_Account__c = 1000;
        opp.Unpaid_Program_Fee_WO_DNL__c = 300;
        opp.Unpaid_Program_Fee_W_DNL__c = 200;
        opp.Addnl_Months_with_Loan__c = 6;
        opp.DRP_Name__c = 'DRP121';
        opp.DRP_Account_Number__c = '2376376';
        opp.Portfolio_Type__c = 'Timberline';
        return opp;
    }

    /*method to create Docusign_Documents__c data*/
    public static void  createDocusignDocumentSettings(){

        List<Docusign_Documents__c> docList = new List<Docusign_Documents__c>();

        Docusign_Documents__c doc = new Docusign_Documents__c();
        doc.Document_Type__c='Opportunity Loan Application';
        doc.Name = 'Opp Loan Application T';
        doc.Object_Name__c = 'Opportunity';
        doc.Portfolio_Type__c = 'Timberline';
        doc.Template_Id__c = '9efbff04-67e3-4013-9fbc-83e2e6dd1bfa';

        docList.add(doc);

        Docusign_Documents__c doc1 = new Docusign_Documents__c();
        doc1.Document_Type__c='Opportunity Loan Application';
        doc1.Name = 'Opp Loan Application A';
        doc1.Object_Name__c = 'Opportunity';
        doc1.Portfolio_Type__c = 'Attorney';
        doc1.Template_Id__c = 'b9ccb1ca-e68e-4184-8a38-90f10d1b2a43';

        docList.add(doc1);

        insert docList;
    }    

    public static void createNuPayDataMappingTestData(){
    List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
        
    nu_dse__Data_Mapping__c dataMappingInstance1 = new nu_dse__Data_Mapping__c();
    dataMappingInstance1.Name = 'PrizmAccountToNuDebtAccount';
    dataMappingInstance1.nu_dse__Source_sObject__c = 'Account';
    dataMappingInstance1.nu_dse__Target_sObject__c = 'Account';
    dataMappingList.add(dataMappingInstance1);
    
    nu_dse__Data_Mapping__c dataMappingInstance2 = new nu_dse__Data_Mapping__c();
    dataMappingInstance2.Name = 'PrizmCoClientAccountToNuDebtAccount';
    dataMappingInstance2.nu_dse__Source_sObject__c = 'Account';
    dataMappingInstance2.nu_dse__Target_sObject__c = 'Account';
    dataMappingList.add(dataMappingInstance2);
    
    nu_dse__Data_Mapping__c dataMappingInstance3 = new nu_dse__Data_Mapping__c();
    dataMappingInstance3.Name = 'PrizmBankAccountToNuDebtBankAccount';
    dataMappingInstance3.nu_dse__Source_sObject__c = 'PrizmBankAccount';
    dataMappingInstance3.nu_dse__Target_sObject__c = 'NuDebtBankAccount';
    dataMappingList.add(dataMappingInstance3);
    
    nu_dse__Data_Mapping__c dataMappingInstance4 = new nu_dse__Data_Mapping__c();
    dataMappingInstance4.Name = 'PrizmAccountToNuDebtProgram';
    dataMappingInstance4.nu_dse__Source_sObject__c = 'Account';
    dataMappingInstance4.nu_dse__Target_sObject__c = 'Program';
    dataMappingList.add(dataMappingInstance4);

    // Added field mappping for Nudebt Program to Prizm Account (DV-423)
    nu_dse__Data_Mapping__c dataMappingInstance5 = new nu_dse__Data_Mapping__c();
    dataMappingInstance5.Name = 'NuDebtProgramToPrizmAccount';
    dataMappingInstance5.nu_dse__Source_sObject__c = 'Program';
    dataMappingInstance5.nu_dse__Target_sObject__c = 'Account';
    dataMappingList.add(dataMappingInstance5);
    
    insert dataMappingList;
    
    List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();

    nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
    fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
    fieldMappingInstance1.nu_dse__Source_Field__c = 'LastName';
    fieldMappingInstance1.nu_dse__Target_Field__c = 'LastName';
    fieldMappingList.add(fieldMappingInstance1);
    
    nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
    fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
    fieldMappingInstance2.nu_dse__setDefaultValue__c = TRUE;
    fieldMappingInstance2.nu_dse__Default_Value__c = '(321) 654-00';
    fieldMappingInstance2.nu_dse__Target_Field__c = 'nu_dse__Work_Phone__c';
    fieldMappingList.add(fieldMappingInstance2);
    
    nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
    fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
    fieldMappingInstance3.nu_dse__Source_Field__c = 'Id';
    fieldMappingInstance3.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
    fieldMappingList.add(fieldMappingInstance3);
    
    nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
    fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingInstance2.Id;
    fieldMappingInstance4.nu_dse__Source_Field__c = 'LastName';
    fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__Co_Last_Name__c';
    fieldMappingList.add(fieldMappingInstance4);
    
    nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
    fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingInstance2.Id;
    fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
    fieldMappingInstance5.nu_dse__Target_Field__c = 'nu_dse__Cell_phone__c';
    fieldMappingList.add(fieldMappingInstance5);
    
    nu_dse__Field_mapping__c fieldMappingInstance51 = new nu_dse__Field_mapping__c();
    fieldMappingInstance51.nu_dse__Data_Mapping__c = dataMappingInstance2.Id;
    fieldMappingInstance51.nu_dse__setDefaultValue__c = TRUE;
    fieldMappingInstance51.nu_dse__Default_Value__c = '(321) 654-00';
    fieldMappingInstance51.nu_dse__Target_Field__c = 'nu_dse__Cell_phone__c';
    fieldMappingList.add(fieldMappingInstance51);
    
    nu_dse__Field_mapping__c fieldMappingInstance6 = new nu_dse__Field_mapping__c();
    fieldMappingInstance6.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
    fieldMappingInstance6.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Number__c';
    fieldMappingInstance6.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
    fieldMappingList.add(fieldMappingInstance6);
    
    nu_dse__Field_mapping__c fieldMappingInstance61 = new nu_dse__Field_mapping__c();
    fieldMappingInstance61.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
    fieldMappingInstance61.nu_dse__setDefaultValue__c = TRUE;
    fieldMappingInstance61.nu_dse__Default_Value__c = '123123344';
    fieldMappingInstance61.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
    fieldMappingList.add(fieldMappingInstance61);
    
    nu_dse__Field_mapping__c fieldMappingInstance7 = new nu_dse__Field_mapping__c();
    fieldMappingInstance7.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
    fieldMappingInstance7.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Holder_Name__c';
    fieldMappingInstance7.nu_dse__Target_Field__c = 'nu_dse__Holder_s_Name__c';
    fieldMappingList.add(fieldMappingInstance7);

    nu_dse__Field_mapping__c fieldMappingInstance71 = new nu_dse__Field_mapping__c();
    fieldMappingInstance71.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
    fieldMappingInstance71.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.PersonMailingCity';
    fieldMappingInstance71.nu_dse__Target_Field__c = 'nu_dse__City__c';
    fieldMappingList.add(fieldMappingInstance71);

    nu_dse__Field_mapping__c fieldMappingInstance72 = new nu_dse__Field_mapping__c();
    fieldMappingInstance72.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
    fieldMappingInstance72.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.PersonMailingStateCode';
    fieldMappingInstance72.nu_dse__Target_Field__c = 'nu_dse__State__c';
    fieldMappingList.add(fieldMappingInstance72);

    nu_dse__Field_mapping__c fieldMappingInstance73 = new nu_dse__Field_mapping__c();
    fieldMappingInstance73.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
    fieldMappingInstance73.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.PersonMailingPostalCode';
    fieldMappingInstance73.nu_dse__Target_Field__c = 'nu_dse__Zip__c';
    fieldMappingList.add(fieldMappingInstance73); 

    nu_dse__Field_mapping__c fieldMappingInstance74 = new nu_dse__Field_mapping__c();
    fieldMappingInstance74.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
    fieldMappingInstance74.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.Phone';
    fieldMappingInstance74.nu_dse__Target_Field__c = 'nu_dse__Telephone__c';
    fieldMappingList.add(fieldMappingInstance74);                        
    
    nu_dse__Field_mapping__c fieldMappingInstance8 = new nu_dse__Field_mapping__c();
    fieldMappingInstance8.nu_dse__Data_Mapping__c = dataMappingInstance4.Id;
    fieldMappingInstance8.nu_dse__Default_Value__c = 'Monthly';
    fieldMappingInstance8.nu_dse__setDefaultValue__c = TRUE;
    fieldMappingInstance8.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
    fieldMappingList.add(fieldMappingInstance8);
    
    nu_dse__Field_mapping__c fieldMappingInstance9 = new nu_dse__Field_mapping__c();
    fieldMappingInstance9.nu_dse__Data_Mapping__c = dataMappingInstance4.Id;
    fieldMappingInstance9.nu_dse__Source_Field__c = 'Phone';
    fieldMappingInstance9.nu_dse__Target_Field__c = 'nu_dse__CIP_CFT_Id__c';
    fieldMappingList.add(fieldMappingInstance9);

    // Added field mappping for Nudebt Program to Prizm Account (DV-423)
    nu_dse__Field_mapping__c fieldMappingInstance11 = new nu_dse__Field_mapping__c(); //DV-423
    fieldMappingInstance11.nu_dse__Data_Mapping__c = dataMappingInstance5.Id;
    fieldMappingInstance11.nu_dse__Source_Field__c = 'nu_dse__Last_Disposition__c';
    fieldMappingInstance11.nu_dse__Target_Field__c = 'nu_dse__Auth_RAMS_Id__c';
    fieldMappingList.add(fieldMappingInstance11);
    
    nu_dse__Field_mapping__c fieldMappingInstance12 = new nu_dse__Field_mapping__c();
    fieldMappingInstance12.nu_dse__Data_Mapping__c = dataMappingInstance5.Id;
    fieldMappingInstance12.nu_dse__Default_Value__c = 'nu_dse__CFT_Rule_Set_Id__c';
    fieldMappingInstance12.nu_dse__setDefaultValue__c = TRUE;
    fieldMappingInstance12.nu_dse__Target_Field__c = 'AccountNumber';
    fieldMappingList.add(fieldMappingInstance12);
    
    insert fieldMappingList;
    }

    public static void createTriggerExecutionTestData(){
        
        List<fsCOre__Trigger_Execution_Settings__c> triExecSettingsList = new List<fsCOre__Trigger_Execution_Settings__c>();

        fsCOre__Trigger_Execution_Settings__c testAppCheckTrgSettings = new fsCOre__Trigger_Execution_Settings__c();
        testAppCheckTrgSettings.Name = 'ApplicationChecklistTrigger';
        testAppCheckTrgSettings.fsCore__Custom_Trigger_Manager_Class__c = 'ApplicationChecklistCustomTriggerManager';
        testAppCheckTrgSettings.fsCore__Number_Of_Trigger_Executions__c = 1;

        fsCOre__Trigger_Execution_Settings__c testPricingCheckTrgSettings = new fsCOre__Trigger_Execution_Settings__c();
        testPricingCheckTrgSettings.Name = 'LendingApplicationPricingTrigger';
        testPricingCheckTrgSettings.fsCore__Custom_Trigger_Manager_Class__c = 'ApplicationPricingCustomTriggerManager';
        testPricingCheckTrgSettings.fsCore__Number_Of_Trigger_Executions__c = 1;

        fsCOre__Trigger_Execution_Settings__c testAppTrgSettings = new fsCOre__Trigger_Execution_Settings__c();
        testAppTrgSettings.Name = 'LendingApplicationTrigger';
        testAppTrgSettings.fsCore__Custom_Trigger_Manager_Class__c = 'ApplicationCustomTriggerManager';
        testAppTrgSettings.fsCore__Number_Of_Trigger_Executions__c = 1;    

        fsCOre__Trigger_Execution_Settings__c testFinTrgSettings = new fsCOre__Trigger_Execution_Settings__c();
        testFinTrgSettings.Name = 'FinancialTrigger';
        testFinTrgSettings.fsCore__Custom_Trigger_Manager_Class__c = 'FinancialCustomTriggerManager';
        testFinTrgSettings.fsCore__Number_Of_Trigger_Executions__c = 1;    

        fsCOre__Trigger_Execution_Settings__c testInbPmtTrgSettings = new fsCOre__Trigger_Execution_Settings__c();
        testInbPmtTrgSettings.Name = 'InboundPaymentTrigger';
        testInbPmtTrgSettings.fsCore__Custom_Trigger_Manager_Class__c = 'InboundPaymentCustomTriggerManager';
        testInbPmtTrgSettings.fsCore__Number_Of_Trigger_Executions__c = 1;          

        fsCOre__Trigger_Execution_Settings__c testConTrgSettings = new fsCOre__Trigger_Execution_Settings__c();
        testConTrgSettings.Name = 'LendingContractTrigger';
        testConTrgSettings.fsCore__Custom_Trigger_Manager_Class__c = 'ContractCustomTriggerManager';
        testConTrgSettings.fsCore__Number_Of_Trigger_Executions__c = 1;                   

        
        triExecSettingsList.add(testAppCheckTrgSettings);
        triExecSettingsList.add(testPricingCheckTrgSettings);
        triExecSettingsList.add(testAppTrgSettings);
        triExecSettingsList.add(testFinTrgSettings);
        triExecSettingsList.add(testInbPmtTrgSettings);
        triExecSettingsList.add(testConTrgSettings);

        insert triExecSettingsList;


        
    }

    /*method to create account data*/
    public static Account createAccount(){

        Id RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID=RecTypeId;
        acc.FirstName = 'Mike';
        acc.LastName = 'Shaw';
        acc.personEmail = 'Mike@yyy.com';
        acc.PersonOtherStreet = 'Right Dr';
        acc.PersonOtherCity= 'Jersey City';
        acc.PersonOtherStateCode = 'NJ';
        acc.PersonOtherPostalCode= '00998';
        acc.PersonOtherCountryCode= 'US';
        acc.PersonOtherCountry= 'United States';
        acc.PersonHomePhone = '9087654321';
        acc.PersonMobilePhone = '9102345678';
        acc.Work_Phone__c = '7890654321';
        acc.PersonBirthdate = Date.today().addYears(-30);
        acc.Less_than_2yrs_Zip_Code__c = '99817';
        return acc;
    }


    public static Account createAccount(String pFirstName,String pLastName){

        Id RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID=RecTypeId;
        acc.FirstName = pFirstName;
        acc.LastName = pLastName;
        acc.personEmail = 'Mike@yyy.com';
        acc.Less_than_2yrs_Zip_Code__c = '99817';
        acc.PersonHomePhone = '9087654321';
        acc.PersonMobilePhone = '9102345678';
        acc.Work_Phone__c = '7890654321';
        return acc;
    }

    /*method to create Contact data*/
    public static Contact createContact(Id pAccountID){

        Contact con = new Contact();
        con.FirstName = 'Mike';
        con.LastName = 'Shaw';
        con.AccountId = pAccountID;
        return con;
    }

    /*method to create ContentDocumentLink data*/
    public static ContentDocumentLink createContentDocumentLink(Id pOppId ){

        Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content ';      
        cv.PathOnClient = 'test';           
        cv.VersionData = beforeblob;          
        insert cv; 
        //ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = pOppId;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = documents[0].Id;//testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        return contentlink;
    }

    /*method to create  SFS System Settings data*/
    public static SFS_System_Settings__c createSFSSystemSettings(){
        SFS_System_Settings__c sysSetting = SFS_System_Settings__c.getInstance();
        sysSetting.Default_Company_Code_DNL__c = 'VLC';
        sysSetting.Default_Company_ID_DNL__c = null;
        sysSetting.Default_Branch_Code_DNL__c = 'VLB';
        sysSetting.Default_Branch_ID_DNL__c = null;
        sysSetting.Default_Product_Code_DNL__c = 'DNL';
        sysSetting.Default_Product_ID_DNL__c = null;
        sysSetting.DNL_Cash_In_Dedicated_Itm__c = 'DEDICATED_AMOUNT_CASH';
        sysSetting.DNL_Funds_To_Creditor_Itm__c = 'FUNDS_TO_CREDITOR';
        sysSetting.DNL_One_Mth_Payment_Itm__c = 'DRP_PAYMENT_ONE_MTH';
        sysSetting.DNL_Rem_Fee_Due_DRP_Itm__c = 'REM_FEE_DUE_DRP';
        sysSetting.Is_DNL_Settlement_Active_Rates_Only__c = true;
        sysSetting.Is_DNL_Settle_Unmatched_Default_Allowed__c = true;
        sysSetting.DNL_Settlement_Unmatched_Rate__c = 40.00;
        
        return sysSetting;
    }

    /*method to create  List  of fsCore__Checklist_Setup__c*/
    public static List<fsCore__Checklist_Setup__c> createcheckList(){

        List<fsCore__Checklist_Setup__c> testChecklistSetUpList = new List<fsCore__Checklist_Setup__c>();
        Set<String> checkListNameSet = new Set<String>();
        checkListNameSet.add('DNL APL INC DOC CHK SAL LESS 60');
        checkListNameSet.add('DNL APL INC DOC CHK OTH RENTAL INCOME');
        checkListNameSet.add('DNL_APL_INC_DOC_CHK_OTH');
        checkListNameSet.add('DNL_APL_INC_DOC_CHK_RET_SOCIAL_SEC');
        checkListNameSet.add('DNL_APL_INC_DOC_CHK_OTH_CHILD_SUPPORT');
        checkListNameSet.add('DNL_APL_INC_DOC_CHK_SE_SOLE_PROP');
        checkListNameSet.add('DNL_APL_INC_DOC_CHK_OTH_ALIMONY');
        /*checkListNameSet.add('DNL_APL_INC_DOC_CHK_OTH_DISB_BENEFITS');
        checkListNameSet.add('DNL_APL_INC_DOC_CHK_RET_PENSION');
        checkListNameSet.add('DNL COAPL INC DOC CHK SAL LESS 60');
        checkListNameSet.add('DNL COAPL INC DOC CHK OTH RENTAL INCOME');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_OTH');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_OTH_RENTAL_INCOME');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_RET_SOCIAL_SEC');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_OTH_CHILD_SUPPORT');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_SE_SOLE_PROP');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_OTH_ALIMONY');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_OTH_DISB_BENEFITS');
        checkListNameSet.add('DNL_COAPL_INC_DOC_CHK_RET_PENSION');*/
        for (String checkListName : checkListNameSet){
            testChecklistSetUpList.add(fsCore.TestHelperProduct.getTestChecklistSetup(checkListName
                                                                                            ,'Servicing'
                                                                                            , UserInfo.getUserId()
                                                                                            ,1));
        }
        return testChecklistSetUpList;
    }

    /*method to create  List  of fsCore__Checklist_Detail_Setup__c*/
    public static List<fsCore__Checklist_Detail_Setup__c> createcheckListDetail(List<fsCore__Checklist_Setup__c> pCheckList){

        List<fsCore__Checklist_Detail_Setup__c> testChecklistDetailSetUp = new List<fsCore__Checklist_Detail_Setup__c>();

        for (fsCore__Checklist_Setup__c checkList : pCheckList){
            testChecklistDetailSetUp.add(fsCore.TestHelperProduct.getTestDocumentChecklistItem(checkList.Id
                                                                                                        ,'TEST'
                                                                                                        ,'Bank Statement'));
        }
        return testChecklistDetailSetUp;
    }

    /*
     * Method to create a 10K 12-month Lending Application with repayments
     *  - Customers
     *  - Repayment Schedule
     *  - Repayment Details
     */
    public static fsCore__Lending_Application__c createLendingApplicationWithRepayments(Account pPersonAccount){
        //
        //create company and branch
        //
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
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

        //
        //create primary customer
        //
        fsCore__Lending_Application_Customer__c testPrimaryCustomer = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                            , pPersonAccount.Id
                                                                            , null
                                                                            , fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
        insert testPrimaryCustomer;
        System.assert(testPrimaryCustomer.Id != null, 'Test primary customer created assert'); 
        // create Application checklist Record
        // 
        List<fsCore__Checklist_Setup__c> testChecklist = createcheckList();
        List<fsCore__Checklist_Detail_Setup__c> testcheckListDetail= createcheckListDetail(testChecklist);
        List<fsCore__Lending_Application_Checklist__c>testAppChklist = fsCore.TestHelperLendingApplication.getTestApplicationChecklists(testApplication,testcheckListDetail);
        insert testAppChklist;
        System.assert(testappchklist.size() > 0, 'Test application checklist size assert'); 
        
        //create Lending Application repayment schedule and details
        //
        fsCore__Lending_Application_Repayment_Schedule__c testRepaySch = fsCore.TestHelperLendingApplication.getTestRepaymentSchedule(testApplication);
        insert testRepaySch;
        System.assert(testRepaySch.Id != null, 'Test repayment schedule created assert');        
        
        List<fsCore__Lending_Application_Repayment__c> testRepayDtlList = fsCore.TestHelperLendingApplication.getTestRepaymentDetails(testApplication);
        insert testRepayDtlList;
        System.assert(testRepayDtlList.size() > 0, 'Test repayment schedule size assert'); 
        
        return testApplication;
    }    
    
    public static Map<String, fsCore__Lending_Application__c> getTestLendingApplications(){
        fsCore.DynamicQueryBuilder applicationQuery = fsCore.DynamicQueryFactory.createQuery(
                                                       Schema.SObjectType.fsCore__Lending_Application__c.getName()).addFields();

        List<fsCore__Lending_Application__c> applicationList = (List<fsCore__Lending_Application__c>)Database.query(applicationQuery.getQueryString());
        Map<String, fsCore__Lending_Application__c> applicationMap = new Map<String, fsCore__Lending_Application__c>();
        for(fsCore__Lending_Application__c application : applicationList){
            applicationMap.put(application.Name, application);
        }
        
        return applicationMap;
    } 

    /*method to create  List  of Financial Setup*/
    public static List<fsCore__Financial__c> createFinancials(Id pAccID, Id pContactId, Id pEmpId){

        List<fsCore__Financial__c> testFinancialSetUp = new List<fsCore__Financial__c>();
        Set<String> financialTypes = new Set<String>();
        financialTypes.add('Salary');
        financialTypes.add('Rental');
        financialTypes.add('Disability');
        //financialTypes.add('Alimony');
        financialTypes.add('Child Support');
        //financialTypes.add('Sole Proprietor');
        financialTypes.add('Other');
        
        for (String financialType : financialTypes){
            fsCore__Financial__c testFinancial = new fsCore__Financial__c();
            testFinancial = fsCore.TestHelperMaster.getTestFinancial(pAccID
                                                                                ,pContactId
                                                                                ,'Income'
                                                                                ,financialType
                                                                                ,10);
            if (financialType == 'Salary'){
            	testFinancial.Employment_Name__c = pEmpId;
            }
            testFinancialSetUp.add(testFinancial);
        }
        return testFinancialSetUp;
    }  
}