/**
 * @File Name          : AccountHandler_Test.cls
 * @Description        : 
 * @Author             : selas
 * @Group              :
 * @Last Modified By   : fsDev
 * @Last Modified On   : 4/23/2020, 8:23:51 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/23/2020   selas   Initial Version
**/
@isTest
public class AccountHandler_Test {

    @TestSetup
    public static void setup() {
		TestHelperData.createTriggerExecutionTestData();
          
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');  
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = new nu_dse__Data_Mapping__c();
        dataMappingInstance1.Name = 'PrizmAccountToNuDebtAccount';
        dataMappingInstance1.nu_dse__Source_sObject__c = 'Account';
        dataMappingInstance1.nu_dse__Target_sObject__c = 'Account';
        dataMappingList.add(dataMappingInstance1);
        
        nu_dse__Data_Mapping__c dataMappingInstance2 = new nu_dse__Data_Mapping__c();
        dataMappingInstance2.Name = 'PrizmAccountToNuDebtProgram';
        dataMappingInstance2.nu_dse__Source_sObject__c = 'Account';
        dataMappingInstance2.nu_dse__Target_sObject__c = 'Program';
        dataMappingList.add(dataMappingInstance2);
        
        nu_dse__Data_Mapping__c dataMappingInstance3 = new nu_dse__Data_Mapping__c();
        dataMappingInstance3.Name = 'NuDebtAccountToPrizmAccount';
        dataMappingInstance3.nu_dse__Source_sObject__c = 'Account';
        dataMappingInstance3.nu_dse__Target_sObject__c = 'Account';
        dataMappingList.add(dataMappingInstance3);
        
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
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = null;
        fieldMappingInstance4.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        fieldMappingList.add(fieldMappingInstance4);
        
        nu_dse__Field_mapping__c fieldMappingInstance6 = new nu_dse__Field_mapping__c();
        fieldMappingInstance6.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance6.nu_dse__Source_Field__c = 'Id';
        fieldMappingInstance6.nu_dse__setDefaultValue__c = FALSE;
        fieldMappingInstance6.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        fieldMappingList.add(fieldMappingInstance6);
        
        nu_dse__Field_mapping__c fieldMappingInstance7 = new nu_dse__Field_mapping__c();
        fieldMappingInstance7.nu_dse__Data_Mapping__c = dataMappingInstance2.Id;
        fieldMappingInstance7.nu_dse__Default_Value__c = 'Monthly';
        fieldMappingInstance7.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance7.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingList.add(fieldMappingInstance7);
        
        nu_dse__Field_mapping__c fieldMappingInstance11 = new nu_dse__Field_mapping__c();
        fieldMappingInstance11.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance11.nu_dse__Source_Field__c = 'LastName';
        fieldMappingInstance11.nu_dse__Target_Field__c = 'LastName';
        fieldMappingList.add(fieldMappingInstance11);
        
        nu_dse__Field_mapping__c fieldMappingInstance12 = new nu_dse__Field_mapping__c();
        fieldMappingInstance12.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance12.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance12.nu_dse__Default_Value__c = '(321) 654-0091';
        fieldMappingInstance12.nu_dse__Target_Field__c = 'Phone';
        fieldMappingList.add(fieldMappingInstance12);
        
        insert fieldMappingList;
        
        //create Account
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
        List<Account> accList = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 1';
        accInstance1.Phone = '(321) 654-1';
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       // accInstance1.personcontactId = con.id;
        accList.add(accInstance1);
        
        Account accInstance2 = new Account();
        accInstance2.LastName = 'test 2';
        accInstance2.Phone = '(321) 654-2';
        accInstance2.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        accList.add(accInstance2);
        
        Test.startTest();
        insert accList;
        Test.stopTest();
        
       /* Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = accList[0].id;
        insert con;
*/
        
        List<Account> accUpdateList = [SELECT Id, Phone FROM Account];
        
        Account accInstance4 = new Account();
        accInstance4.Prizm_External_Id__c = accUpdateList[0].Id;
        accInstance4.LastName = 'test 6';
        accInstance4.Phone = '(321) 623-1';
        
        insert accInstance4;
        
        Account accInstance3 = new Account();
        accInstance3.Id = accUpdateList[0].Id;
        accInstance3.LastName = 'test 5';
        accInstance3.Phone = '(321) 623-1';
        
        update accInstance3;
        
        
        //create lending application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                                               , testBranch
                                                                                               , testProduct
                                                                                               , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test application created assert');
        
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
        testApplication.RecordTypeId = recTypeId;
        update testApplication;
        
        //create Lending Application Customers
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert'); 
        
        
    }

    @isTest
    static void updatingAccount() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance8 = new nu_dse__Field_mapping__c();
        fieldMappingInstance8.nu_dse__Data_Mapping__c = dataMappingList[1].Id;
        fieldMappingInstance8.nu_dse__Source_Field__c = 'Id';
        fieldMappingInstance8.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        fieldMappingList.add(fieldMappingInstance8);
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance5.nu_dse__Target_Field__c = 'PersonEmail';
        fieldMappingList.add(fieldMappingInstance5);
        
        insert fieldMappingList;
    
        List<Account> accQueryList = [SELECT Id,name, phone FROM Account];
        
        List<Account> accList = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.Id = accQueryList[0].Id;
        accInstance1.Phone = '(321) 654-0000';
        accList.add(accInstance1);
        
        Account accInstance2 = new Account();
        accInstance2.Id = accQueryList[1].Id;
        accInstance2.Phone = '(321) 654-0001';
        accList.add(accInstance2);  
        
        Test.startTest();
        update accList;
        Test.stopTest();
        
        List<Account> accUpdateList = [SELECT id, Phone FROM Account];
        
        system.assertEquals('(321) 654-0000',accUpdateList[0].Phone);
    }
    
    @isTest
    static void InvalidFieldMapping() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance9 = new nu_dse__Field_mapping__c();
        fieldMappingInstance9.nu_dse__Data_Mapping__c = dataMappingList[1].Id;
        fieldMappingInstance9.nu_dse__Default_Value__c = '';
        fieldMappingInstance9.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance9.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingInstance9.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance9);
        
        nu_dse__Field_mapping__c fieldMappingInstance10 = new nu_dse__Field_mapping__c();
        fieldMappingInstance10.nu_dse__Data_Mapping__c = dataMappingList[1].Id;
        fieldMappingInstance10.nu_dse__Source_Field__c = '';
        fieldMappingInstance10.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        fieldMappingInstance10.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance10);
        
        nu_dse__Field_mapping__c fieldMappingInstance13 = new nu_dse__Field_mapping__c();
        fieldMappingInstance13.nu_dse__Data_Mapping__c = dataMappingList[2].Id;
        fieldMappingInstance13.nu_dse__Default_Value__c = '';
        fieldMappingInstance13.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance13.nu_dse__Target_Field__c = 'Phone';
        fieldMappingInstance13.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance13);
        
        insert fieldMappingList;
        
        List<Account> accList = [SELECT Id FROM Account];
        
        List<Account> accList1 = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 1';
        accInstance1.Phone = '(321) 654-0002';
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        accList1.add(accInstance1);
        
        Account accInstance2 = new Account();
        accInstance2.LastName = 'test 2';
        accInstance2.Phone = '(321) 654-0003';
        accInstance2.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        accList1.add(accInstance2);
        
        test.startTest();
        insert accList1;
        test.stopTest();
        
        List<Account> accInsertList = [SELECT id, Phone FROM Account];
        
       // system.assertEquals('(321) 654-0002',accInsertList[4].Phone);
    }
    
    @isTest
    static void ResultSuccessTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[1].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__CIP_CFT_Id__c';
        fieldMappingInstance4.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance4.nu_dse__Default_Value__c = 'qwertyuioplkjhgfdsazxcljhktkgjhvbnmkjgfrtyujhgfytyuuy';
        fieldMappingList.add(fieldMappingInstance4);
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[2].Id;
        fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance5.nu_dse__Target_Field__c = 'PersonEmail';
        fieldMappingList.add(fieldMappingInstance5);
        
        insert fieldMappingList;
        
        List<Account> accQueryList = [SELECT Id,name, phone FROM Account];
        system.debug('acccccc:::'+accQueryList);
        
        List<Account> accList = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.Id = accQueryList[0].Id;
        accInstance1.Phone = '(321) 654-0004';
        accList.add(accInstance1);
        
        Account accInstance2 = new Account();
        accInstance2.Id = accQueryList[1].Id;
        accInstance2.Phone = '(321) 654-0005';
        accList.add(accInstance2);  
        
        Test.startTest();
        update accList;
        Test.stopTest();
        
        List<Account> accUpdateList = [SELECT id, Phone FROM Account];
        
        system.assertEquals('(321) 654-0004',accUpdateList[0].Phone);
    }
   
    @isTest
    static void CatchBlockTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[2].Id;
        fieldMappingInstance5.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
        fieldMappingList.add(fieldMappingInstance5);
        
        insert fieldMappingList;
        
        List<Account> accList = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 5';
        accInstance1.Phone = '(321) 654-0002';
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        accList.add(accInstance1);
        
        test.startTest();
        insert accList;
        test.stopTest();
        
        List<Account> accList1 = [SELECT id, name, Phone FROM Account];
        
     //   system.assertEquals('(321) 623-1',accList1[3].Phone);
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT id FROM nu_dse__Error_Log__c];
        
        //system.assertEquals(1,errorLogList.size());
    }
    
    @isTest
    static void invalidfield(){
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance9 = new nu_dse__Field_mapping__c();
        fieldMappingInstance9.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance9.nu_dse__Default_Value__c = '';
        fieldMappingInstance9.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance9.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingInstance9.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance9);
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance5.nu_dse__Target_Field__c = 'PersonEmail';
        fieldMappingList.add(fieldMappingInstance5);
        
       nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'Phone';
        fieldMappingInstance4.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance4.nu_dse__Default_Value__c = 'qwertyuioplkjhgfdsazxcljhktkgjhvbnmkjgfrtyujhgfytyuuy';
        fieldMappingList.add(fieldMappingInstance4);
        insert fieldMappingList;
        
        List<Account> accList1 = [SELECT id, name, Phone FROM Account];
        
        Account accInstance1 = new Account();
        accInstance1.Id = accList1[0].Id;
        accInstance1.Phone = '(321) 654-1235';
        
        update accInstance1;
    }
    @isTest
    static void invalidDefaultValue(){
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'Phone';
        fieldMappingInstance4.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance4.nu_dse__Default_Value__c = 'qwertyuioplkjhgfdsazxcljhktkgjhvbnmkjgfrtyujhgfytyuuy';
        fieldMappingList.add(fieldMappingInstance4);
        insert fieldMappingList;
        
        List<Account> accList1 = [SELECT id, name, Phone FROM Account];
        
        Account accInstance1 = new Account();
        accInstance1.Id = accList1[0].Id;
        accInstance1.Phone = '(321) 654-1035';
        
        update accInstance1;
    }
    @isTest
    static void updateUserRegistration(){
        List<Account> accList1 = [SELECT id, name, Phone FROM Account];
        FsCore__Lending_Application__c app = [Select id , fsCore__Is_Application_Read_Only__c,Loan_Type__c from FsCore__Lending_Application__c];
        system.debug(loggingLevel.Error , app);
        Account acc = new Account();
        acc.Id = accList1[0].Id;
        acc.Is_VCL_TILA_Accepted__c = true;
        test.startTest();
        update acc;
        test.StopTest();
        
        
    }
    
}