/**
 * @File Name          : BankAccountVerificationTriggerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/2/2019, 11:22:24 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/2/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@istest
public class BankAccountVerificationTriggerTest {
    
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
        
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication2 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application2');
        insert testApplication2;
        System.assert(testApplication2.Id != null,  'Test Lending Application created assert'); 
        
        //create Employment
        fsCore__Employment__c   testEmployment = fsCore.TestHelperMaster.getTestEmployment(testAccount.PersonContactId
                                                                                           ,'Test Employment'
                                                                                           , Date.today()
                                                                                           ,100000);
        testEmployment.fsCore__End_Date__c = null;
        insert testEmployment;
        System.assert(testEmployment.Id != null, 'Test Employment  created assert');
        
        //create Financials
        List<fsCore__Financial__c> testFinancialSetUp = TestHelperData.createFinancials(testAccount.Id, testAccount.PersonContactId, testEmployment.Id);
        insert testFinancialSetUp;
        System.assert(testFinancialSetUp[0].Id != null, 'Test Financials  created assert');
        
        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication2
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        
    }
    @istest
    public static void test1(){
        fsCore__Lending_Application__c testApplication = [Select id , Name from fsCore__Lending_Application__c limit 1];
        
        Application_Bank_Account_Verification__c bav = new Application_Bank_Account_Verification__c();
        bav.Lending_Application_Name__c = testApplication.id;
        bav.Deposit_Amount__c = 5 ;
        insert bav;
        test.startTest();
        bav.Verification_Status__c = 'Verified';
        update bav;
        try{
            List<task> taskList = [Select id , Subject from Task];
            if(taskList.size()>0){
                System.debug('Success');
            }
        }
        catch(Exception e){
            System.debug(e.getMessage()); 
        }
        test.stopTest(); 
        
    }
}