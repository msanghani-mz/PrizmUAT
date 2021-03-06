@isTest
public class VCLBankAccountTriggerTest {
    
    @testSetup
    public static void create(){
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
        
        //create Payment Allocation Method
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        System.assert(testPaymentAlloc.Id != null, 'Test payment allocation created assert');
        
        //Contract Template 
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate; 
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');  
        
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
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        
        fsCore__Bank_Account__c bankAcc = new fsCore__Bank_Account__c();
        bankAcc.fsCore__Contact_Name__c = testAccount.PersonContactId;
        bankAcc.Name = 'Bank Account Name';
        bankAcc.fsCore__Bank_Account_Holder_Name__c = 'test Account';
        bankAcc.fsCore__Bank_Account_Number__c = '1234567';
        bankAcc.fsCore__Bank_Identification_Code__c = '565656';
        insert bankAcc;
        
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        testApplication.Is_User_Registration_Completed__c = false;
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
        testApplication.RecordTypeId = recTypeId;
        update testApplication;
        
        //create Lending Application Customer Secondary
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
    public static void test(){
        
        fsCore__Bank_Account__c bankAcc = [Select id from fsCore__Bank_Account__c limit 1];
        System.debug(LoggingLevel.Error , bankAcc);
        bankAcc.Edited_by_Client__c = true;
        update bankAcc;
        
    }
    @isTest
    public static void test2(){
        
        fsCore__Bank_Account__c bankAcc1 = [Select id, fsCore__Contact_Name__c from fsCore__Bank_Account__c limit 1];
        System.debug(LoggingLevel.Error , bankAcc1);
        
        fsCore__Bank_Account__c bankAcc = new fsCore__Bank_Account__c();
        bankAcc.fsCore__Contact_Name__c = bankAcc1.fsCore__Contact_Name__c;
        bankAcc.Name = 'Bank Account Name';
        bankAcc.fsCore__Bank_Account_Holder_Name__c = 'test Account';
        bankAcc.fsCore__Bank_Account_Number__c = '1234567';
        bankAcc.fsCore__Bank_Identification_Code__c = '565656';
        insert bankAcc;
       
    }
    
}