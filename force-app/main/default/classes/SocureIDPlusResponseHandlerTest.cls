@isTest
public class SocureIDPlusResponseHandlerTest {
    
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
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        
        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');
        
    }
    @isTest
    public static void test(){
        List<fsCore__Lending_Application_Customer__c> lcustomerList = [select id,name from fsCore__Lending_Application_Customer__c];
        
        List<Fraud_Flag_Setup__c> fraudFlagList = new List<Fraud_Flag_Setup__c>();
        Fraud_Flag_Setup__c fraudFlagSetup1 = new Fraud_Flag_Setup__c();
        fraudFlagSetup1.Name = 'Address Risk';
        fraudFlagSetup1.Fraud_Flag_Code__c = 'ADDRESS_RISK';
        fraudFlagSetup1.Line_Of_Business__c = 'Origination';
        fraudFlagSetup1.Severity__c = 'High';
        fraudFlagSetup1.Default_Company_Availability__c = 'Available';
        fraudFlagSetup1.Default_Product_Availability__c  = 'Available';
        fraudFlagSetup1.Default_Selection_Rule_Result__c  = 'Available';
        fraudFlagSetup1.Selection_Order__c = 1;
        fraudFlagSetup1.Is_Active__c = true;
        fraudFlagSetup1.Start_Date__c = Date.newInstance(2019,11,11);
        fraudFlagSetup1.End_Date__c = Date.newInstance(2020,11,11);
        fraudFlagSetup1.Is_Loan__c = true;
        fraudFlagList.add(fraudFlagSetup1);
        // insert fraudFlagSetup1;
        
        Fraud_Flag_Setup__c fraudFlagSetup2 = new Fraud_Flag_Setup__c();
        fraudFlagSetup2.Name = 'Phone Risk';
        fraudFlagSetup2.Fraud_Flag_Code__c = 'PHONE_RISK';
        fraudFlagSetup2.Line_Of_Business__c = 'Origination';
        fraudFlagSetup2.Severity__c = 'High';
        fraudFlagSetup2.Default_Company_Availability__c = 'Available';
        fraudFlagSetup2.Default_Product_Availability__c  = 'Available';
        fraudFlagSetup2.Default_Selection_Rule_Result__c  = 'Available';
        fraudFlagSetup2.Selection_Order__c = 2;
        fraudFlagSetup2.Is_Active__c = true;
        fraudFlagSetup2.Start_Date__c = Date.newInstance(2019,11,11);
        fraudFlagSetup2.End_Date__c = Date.newInstance(2020,11,11);
        fraudFlagSetup2.Is_Loan__c = true;
        fraudFlagList.add(fraudFlagSetup2);
        
        Fraud_Flag_Setup__c fraudFlagSetup3 = new Fraud_Flag_Setup__c();
        fraudFlagSetup3.Name = 'Fraud';
        fraudFlagSetup3.Fraud_Flag_Code__c = 'FRAUD';
        fraudFlagSetup3.Line_Of_Business__c = 'Origination';
        fraudFlagSetup3.Severity__c = 'High';
        fraudFlagSetup3.Default_Company_Availability__c = 'Available';
        fraudFlagSetup3.Default_Product_Availability__c  = 'Available';
        fraudFlagSetup3.Default_Selection_Rule_Result__c  = 'Available';
        fraudFlagSetup3.Selection_Order__c = 3;
        fraudFlagSetup3.Is_Active__c = true;
        fraudFlagSetup3.Start_Date__c = Date.newInstance(2019,11,11);
        fraudFlagSetup3.End_Date__c = Date.newInstance(2020,11,11);
        fraudFlagSetup3.Is_Loan__c = true;
        fraudFlagList.add(fraudFlagSetup3);
        
        Fraud_Flag_Setup__c fraudFlagSetup4 = new Fraud_Flag_Setup__c();
        fraudFlagSetup4.Name = 'KYC';
        fraudFlagSetup4.Fraud_Flag_Code__c = 'KYC';
        fraudFlagSetup4.Line_Of_Business__c = 'Origination';
        fraudFlagSetup4.Severity__c = 'High';
        fraudFlagSetup4.Default_Company_Availability__c = 'Available';
        fraudFlagSetup4.Default_Product_Availability__c  = 'Available';
        fraudFlagSetup4.Default_Selection_Rule_Result__c  = 'Available';
        fraudFlagSetup4.Selection_Order__c = 4;
        fraudFlagSetup4.Is_Active__c = true;
        fraudFlagSetup4.Start_Date__c = Date.newInstance(2019,11,11);
        fraudFlagSetup4.End_Date__c = Date.newInstance(2020,11,11);
        fraudFlagSetup4.Is_Loan__c = true;
        fraudFlagList.add(fraudFlagSetup4);
        
        Fraud_Flag_Setup__c fraudFlagSetup5 = new Fraud_Flag_Setup__c();
        fraudFlagSetup5.Name = 'Email Risk';
        fraudFlagSetup5.Fraud_Flag_Code__c = 'EMAIL_RISK';
        fraudFlagSetup5.Line_Of_Business__c = 'Origination';
        fraudFlagSetup5.Severity__c = 'High';
        fraudFlagSetup5.Default_Company_Availability__c = 'Available';
        fraudFlagSetup5.Default_Product_Availability__c  = 'Available';
        fraudFlagSetup5.Default_Selection_Rule_Result__c  = 'Available';
        fraudFlagSetup5.Selection_Order__c = 5;
        fraudFlagSetup5.Is_Active__c = true;
        fraudFlagSetup5.Start_Date__c = Date.newInstance(2019,11,11);
        fraudFlagSetup5.End_Date__c = Date.newInstance(2020,11,11);
        fraudFlagSetup5.Is_Loan__c = true;
        fraudFlagList.add(fraudFlagSetup5);
        
        Fraud_Flag_Setup__c fraudFlagSetup6 = new Fraud_Flag_Setup__c();
        fraudFlagSetup6.Name = 'Alert List';
        fraudFlagSetup6.Fraud_Flag_Code__c = 'ALERT_LIST';
        fraudFlagSetup6.Line_Of_Business__c = 'Origination';
        fraudFlagSetup6.Severity__c = 'High';
        fraudFlagSetup6.Default_Company_Availability__c = 'Available';
        fraudFlagSetup6.Default_Product_Availability__c  = 'Available';
        fraudFlagSetup6.Default_Selection_Rule_Result__c  = 'Available';
        fraudFlagSetup6.Selection_Order__c = 6;
        fraudFlagSetup6.Is_Active__c = true;
        fraudFlagSetup6.Start_Date__c = Date.newInstance(2019,11,11);
        fraudFlagSetup6.End_Date__c = Date.newInstance(2020,11,11);
        fraudFlagSetup6.Is_Loan__c = true;
        fraudFlagList.add(fraudFlagSetup6);
        insert fraudFlagList;
        /*  List<fsSocr__Socure_Reason_Code__mdt> socureMetaList = new List<fsSocr__Socure_Reason_Code__mdt>();
fsSocr__Socure_Reason_Code__mdt socureMeta = new fsSocr__Socure_Reason_Code__mdt();
socureMeta.MasterLabel = 'R703';
socureMeta.fsSocr__Description__c = 'R703';
socureMeta.fsSocr__Type__c = 'Risk';
socureMetaList.add(socureMeta);

fsSocr__Socure_Reason_Code__mdt socureMeta2 = new fsSocr__Socure_Reason_Code__mdt();
socureMeta2.MasterLabel = 'R944';
socureMeta2.fsSocr__Description__c = 'R944';
socureMeta2.fsSocr__Type__c = 'Risk';
socureMetaList.add(socureMeta2);

fsSocr__Socure_Reason_Code__mdt socureMeta3 = new fsSocr__Socure_Reason_Code__mdt();
socureMeta3.MasterLabel = 'I555';
socureMeta3.fsSocr__Description__c = 'I555';
socureMeta3.fsSocr__Type__c = 'Information';
socureMetaList.add(socureMeta3);

fsSocr__Socure_Reason_Code__mdt socureMeta4 = new fsSocr__Socure_Reason_Code__mdt();
socureMeta4.MasterLabel = 'R903';
socureMeta4.fsSocr__Description__c = 'R903';
socureMeta4.fsSocr__Type__c = 'Risk';
socureMetaList.add(socureMeta4);
insert socureMetaList;
*/
        
        HttpResponse response = new HttpResponse(); 
        response.setBody('{"referenceId":"d8fbf1aa-019e-44fb-b32e-af14d067f2ff","nameAddressCorrelation":{"reasonCodes":["V120","R705","R703"],"score":0.01},"nameEmailCorrelation":{"reasonCodes":["V120","R557"],"score":0.5291},"namePhoneCorrelation":{"reasonCodes":["R608","V120","R603"],"score":0.01},"fraud":{"reasonCodes":["R606","R608","V120","R705","R561","R703","R603","R557","I555","R611"],"scores":[{"name":"sigma","version":"1.0","score":0.989}]},"kyc":{"reasonCodes":["R944","R903","R922","V120","R919","R957","R913"],"fieldValidations":{"firstName":0.99,"surName":0.99,"streetAddress":0.01,"city":0.99,"state":0.99,"zip":0.99,"mobileNumber":0.01,"dob":0.01,"ssn":0.99}},"addressRisk":{"reasonCodes":["V120","R705","R703"],"score":0.963},"emailRisk":{"reasonCodes":["V120","R561","R557","I555"],"score":0.913},"phoneRisk":{"reasonCodes":["R606","R608","R620","V120","R603","R611"],"score":0.999},"alertList":{"reasonCodes": ["R44"],"matches":[]}}' ); 
        SocureIDPlusResponseHandler obj = new SocureIDPlusResponseHandler();
        response.setStatusCode(200);
        obj.setResponse(response);
        obj.setRecords(lcustomerList);
        obj.process();
    }
    
}