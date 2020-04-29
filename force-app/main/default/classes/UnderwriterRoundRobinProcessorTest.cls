/**
* Class Name  : UnderwriterRoundRobinProcessorTest
* Description :Test Class for Action class to updates the OwnerId on the lending application (DV-65)
* Author      : Financial Spectra
*             
*                           
*/
@isTest
public class UnderwriterRoundRobinProcessorTest {
    
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

        
        List<Account> testAccountList = [select id, personcontactId from Account where id in (:nAccount.id,:coAppAccount.Id) ];
        
        Account testAccount = testAccountList[0];
        testAccount.nu_dse__External_RAMS_ID__c = '167';
        update testAccount;
        Account testCoAccount = testAccountList[1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        
        //Create Lending Applications
        List<fsCore__Lending_Application__c> applicationList = new List<fsCore__Lending_Application__c>();
        fsCore__Lending_Application__c testApplication1 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application');
          applicationList.add(testApplication1);
       // System.assert(testApplication1.Id != null, 'Test Lending Application created assert'); 
        
        fsCore__Lending_Application__c testApplication2 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 2');
      //  insert testApplication2;
       // System.assert(testApplication2.Id != null, 'Test Lending Application created assert'); 
        applicationList.add(testApplication2);
        
        fsCore__Lending_Application__c testApplication3 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 3');
       // insert testApplication3;
       // System.assert(testApplication3.Id != null, 'Test Lending Application created assert');
        applicationList.add(testApplication3); 
        
        fsCore__Lending_Application__c testApplication4 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 4');
       // insert testApplication4;
       // System.assert(testApplication4.Id != null, 'Test Lending Application created assert'); 
         applicationList.add(testApplication4);
        
        fsCore__Lending_Application__c testApplication5 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 5');
       // insert testApplication5;
       // System.assert(testApplication5.Id != null, 'Test Lending Application created assert'); 
          applicationList.add(testApplication5);
        
        fsCore__Lending_Application__c testApplication6 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 6');
         applicationList.add(testApplication6);
       // insert testApplication6;
       // System.assert(testApplication6.Id != null, 'Test Lending Application created assert'); 
        
        fsCore__Lending_Application__c testApplication7 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 7');
         applicationList.add(testApplication7);
       // insert testApplication7;
       // System.assert(testApplication7.Id != null, 'Test Lending Application created assert'); 
        
         fsCore__Lending_Application__c testApplication8 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 8');
         applicationList.add(testApplication8);
       // insert testApplication8;
       // System.assert(testApplication8.Id != null, 'Test Lending Application created assert'); 
        
          fsCore__Lending_Application__c testApplication9 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application 9');
         applicationList.add(testApplication9);
       // insert testApplication9;
       // System.assert(testApplication9.Id != null, 'Test Lending Application created assert');
       insert applicationList;   
               
    }
    @isTest
    public static void test(){
        
        List<fsCore__Lending_Application__c> appList = [Select id from fsCore__Lending_Application__c];
        Profile p = [SELECT Id FROM Profile WHERE Name='Underwriter']; 
        List<User> underwriterList = new List<User>();
        
       
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User u1 = new User(Alias = uid, Email= uid + '@aniket.com', 
                              EmailEncodingKey='UTF-8', FirstName = 'Test1', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/New_York', UserName= uid + '@aniket.com',
                              IsActive = true , IsRoundRobinAllocationEnabled__c=true, Round_Robin_Allocation_percent__c = null);      
            underwriterList.add(u1);
        
           
        insert(underwriterList);
        System.debug(loggingLevel.ERROR,'List Size'+ underwriterList.size());
        System.debug(loggingLevel.ERROR,'App List Size'+ appList.size());
        Set<Id> appIds = new Set<Id>();
        for(fsCore__Lending_Application__c app : appList){
         appIds.add(app.id);   
        }
        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        actionIP.addRecords(appIds);
        test.startTest();
        UnderwriterRoundRobinProcessor uw = new UnderwriterRoundRobinProcessor();
        uw.setInput(actionIP);
        uw.Process(); 
        test.stopTest();
        
    }
    
}