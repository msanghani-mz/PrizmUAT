@isTest
public class GenerateFraudFlagActionProcessorTest {
    @testSetup
    private static void createTestData(){
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
        testAccount.nu_dse__External_RAMS_ID__c = '167';
        update testAccount;
        Account testCoAccount = testAccountList[1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        
        //Contract Template 
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate; 
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');   
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
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
        
        //create Fraud_Slag_Setup
        List<Fraud_Flag_Setup__c> fraudFlagSetupList= new List<Fraud_Flag_Setup__c>();
        
        Fraud_Flag_Setup__c fraudFlagSetup= new Fraud_Flag_Setup__c();
        fraudFlagSetup.Name='Test Fraud Flag1';
        fraudFlagSetup.Fraud_Flag_Code__c='TFF1';
        fraudFlagSetup.Is_Active__c= true;
        fraudFlagSetup.Is_Loan__c= true;
        fraudFlagSetup.Is_Lease__c= false;
        fraudFlagSetup.Is_Line__c= false;
        fraudFlagSetup.Default_Company_Availability__c='Available';
        fraudFlagSetup.Default_Product_Availability__c='Available';
        fraudFlagSetup.Default_Selection_Rule_Result__c='Available';
        //    fraudFlagSetup.Product_Family__c='Loan';   //FormulaField 
        fraudFlagSetup.Selection_Order__c= 1;
        fraudFlagSetup.Severity__c= 'Medium';
        fraudFlagSetup.Start_Date__c=Date.newInstance(2019,06,11);
        fraudFlagSetup.End_Date__c=Date.newInstance(2019,08,11);
        fraudFlagSetup.Line_Of_Business__c='Origination';
        fraudFlagSetupList.add(fraudFlagSetup);
        
        Fraud_Flag_Setup__c fraudFlagSetup1= new Fraud_Flag_Setup__c();
        fraudFlagSetup1.Name='Test Fraud Flag2';
        fraudFlagSetup1.Fraud_Flag_Code__c='TFF2';
        fraudFlagSetup1.Is_Active__c= true;
        fraudFlagSetup1.Is_Loan__c= true;
        fraudFlagSetup1.Is_Lease__c= false;
        fraudFlagSetup1.Is_Line__c= false;
        fraudFlagSetup1.Default_Company_Availability__c='Available';
        fraudFlagSetup1.Default_Product_Availability__c='Available';
        fraudFlagSetup1.Default_Selection_Rule_Result__c='Available';
        //    fraudFlagSetup.Product_Family__c='Loan';    //FormulaField 
        fraudFlagSetup1.Selection_Order__c= 1;
        fraudFlagSetup1.Severity__c= 'Medium';
        fraudFlagSetup1.Start_Date__c=Date.newInstance(2019,06,11);
        fraudFlagSetup1.End_Date__c=Date.newInstance(2019,08,11);
        fraudFlagSetup1.Line_Of_Business__c='Origination';
        fraudFlagSetupList.add(fraudFlagSetup1);
        
        insert fraudFlagSetupList;
        System.Assert(fraudFlagSetupList.Size()>0,'List is not null');
        
        //create Lending_Application_Fraud_Flag__c
        List<Lending_Application_Fraud_Flag__c> lendingApplicationFraudFlagList = new List<Lending_Application_Fraud_Flag__c>();
        
        Lending_Application_Fraud_Flag__c lendingApplicationFraudFlagObj = new Lending_Application_Fraud_Flag__c();
        lendingApplicationFraudFlagObj.Fraud_Flag_Name__c= fraudFlagSetupList[0].id;
        lendingApplicationFraudFlagObj.Lending_Application_Number__c= testApplication.Id;
        lendingApplicationFraudFlagObj.Status__c='Pending Review';
        lendingApplicationFraudFlagObj.Applicant_Name__c = testAppCustomer1.id;
        lendingApplicationFraudFlagList.add(lendingApplicationFraudFlagObj);
        
        Lending_Application_Fraud_Flag__c lendingApplicationFraudFlagObj1 = new Lending_Application_Fraud_Flag__c();
        lendingApplicationFraudFlagObj1.Fraud_Flag_Name__c= fraudFlagSetupList[1].id;
        lendingApplicationFraudFlagObj1.Lending_Application_Number__c= testApplication.Id;
        lendingApplicationFraudFlagObj1.Status__c='Under Review';
        lendingApplicationFraudFlagObj1.Applicant_Name__c = testAppCustomer2.id;
        lendingApplicationFraudFlagList.add(lendingApplicationFraudFlagObj1);
        
        insert lendingApplicationFraudFlagList;
        System.Assert(lendingApplicationFraudFlagList.Size()>0,'List is not null');
    }
    
    @isTest
    private static void testFraudFLagActinProcessor1(){
        
        GenerateFraudFlagActionProcessor generateFraudFlagActionProcessorObj =new GenerateFraudFlagActionProcessor();
        fsCore__Lending_Application__c lendingApplication = [Select Id
                                                             , fsCore__Application_Date__c
                                                             , fsCore__Branch_Name__c
                                                             , fsCore__Company_Name__c
                                                             , fsCore__Product_Name__c
                                                             , fsCore__Product_Family__c 
                                                             FROM fsCore__Lending_Application__c 
                                                            ];
        
        //  Map<Id,fsCore__Lending_Application__c> mApplicationMap;  //in ApplicationActionProcessorBase Class 
        generateFraudFlagActionProcessorObj.mApplicationMap.put(lendingApplication.Id , lendingApplication);
        
        List<Fraud_Flag_Setup__c> fraudFlagSetupRecords = [SELECT Id
                                                           , Name
                                                           , Fraud_Flag_Code__c
                                                           , Is_Active__c 
                                                           , Default_Company_Availability__c
                                                           , Default_Product_Availability__c 
                                                           , Default_Selection_Rule_Result__c
                                                           , Is_Loan__c
                                                           , Is_Line__c
                                                           , Is_Lease__c
                                                           , Product_Family__c
                                                           , Selection_Order__c
                                                           , Severity__c
                                                           , Start_Date__c
                                                           , End_Date__c 
                                                           FROM Fraud_Flag_Setup__c
                                                           WHERE Is_Active__c = true];
        
        List<Lending_Application_Fraud_Flag__c> existingFlags = [SELECT Id
                                                                 , Fraud_Flag_Name__c
                                                                 , Lending_Application_Number__c
                                                                 FROM Lending_Application_Fraud_Flag__c
                                                                ];
        
        Test.startTest();
        generateFraudFlagActionProcessorObj.populateAndValidateRelatedData();
        generateFraudFlagActionProcessorObj.doProcess();
        System.assert(existingFlags.size()>0,'Lending Application Fraud Flags exist');
        Test.stopTest();
    } 
    
    @isTest
    private static void testFraudFLagActinProcessor2(){
        
        GenerateFraudFlagActionProcessor generateFraudFlagActionProcessorObj =new GenerateFraudFlagActionProcessor();
        fsCore__Lending_Application__c lendingApplication = [Select Id
                                                             , fsCore__Application_Date__c
                                                             , fsCore__Branch_Name__c
                                                             , fsCore__Company_Name__c
                                                             , fsCore__Product_Name__c
                                                             , fsCore__Product_Family__c 
                                                             FROM fsCore__Lending_Application__c 
                                                            ];
        
        //  Map<Id,fsCore__Lending_Application__c> mApplicationMap;  //in ApplicationActionProcessorBase Class 
        generateFraudFlagActionProcessorObj.mApplicationMap.put(lendingApplication.Id , lendingApplication);
        
        List<Fraud_Flag_Setup__c> fraudFlagSetupRecords= [SELECT Id
                                                          , Name
                                                          , Fraud_Flag_Code__c
                                                          , Is_Active__c 
                                                          , Default_Company_Availability__c
                                                          , Default_Product_Availability__c 
                                                          , Default_Selection_Rule_Result__c
                                                          , Is_Loan__c
                                                          , Is_Line__c
                                                          , Is_Lease__c
                                                          , Product_Family__c
                                                          , Selection_Order__c
                                                          , Severity__c
                                                          , Start_Date__c
                                                          , End_Date__c 
                                                          FROM Fraud_Flag_Setup__c
                                                          WHERE Is_Active__c = true];
        
        List<Lending_Application_Fraud_Flag__c> existingFlags = [SELECT Id
                                                                 , Fraud_Flag_Name__c
                                                                 , Lending_Application_Number__c
                                                                 FROM Lending_Application_Fraud_Flag__c
                                                                ];
        delete existingFlags;
        List<Lending_Application_Fraud_Flag__c> existingFlagsAfterDelete = [SELECT Id
                                                                            , Fraud_Flag_Name__c
                                                                            , Lending_Application_Number__c
                                                                            FROM Lending_Application_Fraud_Flag__c
                                                                           ];
        System.debug(loggingLevel.ERROR,'Size of existingFlagsAfterDelete:--'+existingFlagsAfterDelete.size());
        
        Test.startTest();
        generateFraudFlagActionProcessorObj.populateAndValidateRelatedData();
        generateFraudFlagActionProcessorObj.doProcess();
        System.assert(existingFlagsAfterDelete.size()==0,'Lending Application Fraud Flag does not exist');

        Test.stopTest();
    } 
}