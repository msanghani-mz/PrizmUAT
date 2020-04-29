/**
* @File Name          : VCLBAVFailedJobTest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 11/2/2019, 11:21:56 PM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    11/2/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class VCLBAVFailedJobTest {
    
    @isTest 
    public static void test1(){
        
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
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        testApplication.Loan_Type__c = 'VCL'; 
       // Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
       // testApplication.RecordTypeId = recTypeId;
        
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        
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
        
        
        Application_Bank_Account_Verification__c bav = new Application_Bank_Account_Verification__c();
        bav.Lending_Application_Name__c = testApplication.id;
        bav.Custom_CreatedDate__c = Date.newInstance(2019,10,22);
        bav.Verification_Status__c = 'New';
        insert bav;
        test.startTest();
        VCLBAVFailedJob obj = new VCLBAVFailedJob();
        DataBase.executeBatch(obj);
        test.stopTest();
        Application_Bank_Account_Verification__c bav1 = [Select id , Verification_Status__c,BAV_Withdraw_Date__c from Application_Bank_Account_Verification__c where id =:bav.id];
        System.debug(bav1);
        System.debug(bav1.BAV_Withdraw_Date__c);
        fsCore__Lending_Application__c testApplication1 = [Select id ,fsCore__Application_Status__c,Withdraw_Reason__c from fsCore__Lending_Application__c where id =:testApplication.id];
        System.assertEquals('Failed',bav1.Verification_Status__c);
        System.assertEquals('Withdrawn',testApplication1.fsCore__Application_Status__c);
        
        
        
    }
    
}