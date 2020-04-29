/*
* Copyright (c) 2017-2019 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class Name   - DirectDebitScheduleCreatorTest
*
* Description  - Test class for DirectDebitScheduleCreator
*
* Developer(s) - FS Dev
*
*/
@isTest 
private class DirectDebitScheduleCreatorTest {
    
    static void createLendingContracts(Boolean pActiveContracts, Boolean pWithRelatedData){
        TestCustomDataLoader.loadAccounts();
        TestCustomDataLoader.loadContacts();
        
        if (pActiveContracts){
            TestCustomDataLoader.loadLendingContractsActive();
            TestCustomDataLoader.loadContractBalancesActive();
            TestCustomDataLoader.loadContractDues();
            TestCustomDataLoader.loadContractRepayments();
            TestCustomDataLoader.loadContractRepaySchedules();
        } else {
            TestCustomDataLoader.loadLendingContractsPending();
            TestCustomDataLoader.loadContractBalancesPending();
        }
        
        if (pWithRelatedData){
            TestCustomDataLoader.loadBankAccounts();
            TestCustomDataLoader.loadContractCustomers();
            TestCustomDataLoader.loadContractItemizations();
            TestCustomDataLoader.loadContractFees();
            TestCustomDataLoader.loadContractDirectDebits();
            TestCustomDataLoader.loadContractDisbursements();
        }
        
        System.assertEquals(8, [SELECT count() FROM fsServ__Lending_Contract__c]);
    }
    
    @testSetup static void createData(){
        TestHelperData.createTriggerExecutionTestData();
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
       
        
        //Lending Contract and setup
        fsserv.TestHelperGlobal.createSetupData();
        createLendingContracts(true, false);
        
        //company
        fsCore__Company_Setup__c testCompany = [Select Id,Name from fsCore__Company_Setup__c Limit 1];
        System.assert(testCompany.Id != null);
        
        // Branch
        fsCore__Branch_Setup__c testBranch = [Select Id,Name,fsCore__Business_Date__c,fsCore__Country__c,fsCore__State__c FROM fsCore__Branch_Setup__c LIMIT 1];
        System.assert(testBranch.Id != null);
        //Product
        fsCore__Product_Setup__c testProduct = [Select id,fsCore__Product_Family__c
                                                , fsCore__Collateral_Family__c
                                                , fsCore__Collateral_Sub_Family__c
                                                , fsCore__Is_Funding_In_Tranches_Allowed__c
                                                , fsCore__Is_Billing_Cycle_Flexible__c
                                                , fsCore__Is_Secured__c
                                                , fsCore__Is_Syndication_Allowed__c
                                                , fsCore__Billing_Cycle__c
                                                from fsCore__Product_Setup__c Limit 1];
        
testProduct.fsCore__Customer_Type__c = 'Person Account';
                testProduct.fsCore__Product_code__c = 'DNL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        
        
        update testProduct;
        
        System.assert(testProduct.Id != null);
        
        //Contract Template
        fsCore__Contract_Template_Setup__c testContractTemplate = [Select id from fsCore__Contract_Template_Setup__c Limit 1];
        System.assert(testContractTemplate.Id != null);
        

        
        
        //Lending Application
        fsCore__Lending_Application__c testApp = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                                                        , testBranch
                                                                                                        , testProduct
                                                                                                        ,'testApplication');
        //testApp.fsCore__Primary_Customer_Contact__c = con.id;
        testApp.fsCore__Payment_Cycle__c = 'Twice-a-Month';
        testApp.fsCore__Payment_Amount__c = 100;
        testApp.fsCore__Payment_Start_Date__c= date.newInstance(2019,8,12);
        testApp.fsCore__Maturity_Date__c = Date.newInstance(2019,9,30);
        testApp.fsCore__Payment_Start_Date_2__c = Date.newInstance(2019,8,29);
        insert testApp;
        System.debug('testApp:-'+testApp);
        System.assert(testApp.Id != null);
        
        
        
        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');
        
        
        //create Lending Contract
        
        fsServ__Lending_Contract__c testLendingContract = new fsServ__Lending_Contract__c();
        testLendingContract.fsServ__Contract_Status__c = 'Active';
        testLendingContract.fsServ__Branch_Name__c = testBranch.Id;
        testLendingContract.fsServ__Company_Name__c = testCompany.Id;
        testLendingContract.fsServ__Product_Name__c = testProduct.Id;
        testLendingContract.fsServ__Contract_Template_Name__c = testContractTemplate.id;
        testLendingContract.fsServ__Financed_Amount__c = 1000;
        testLendingContract.fsServ__Contract_Date__c = Date.today();
        testLendingContract.fsServ__Current_Payment_Amount__c = 1000;
        testLendingContract.fsServ__Next_Payment_Due_Date__c = Date.today().addDays(30);
        testLendingContract.fsServ__Current_Payment_Cycle__c = 'Monthly';
        testLendingContract.fsServ__Lending_Application_Number__c = testApp.id;
        insert testLendingContract;
        
        //Bank Account
        fsCore__Bank_Account__c bankAccount = new fsCore__Bank_Account__c();
        
        bankAccount.fsCore__Contact_Name__c = testAppCustomer1.fsCore__Contact_Name__c;
        bankAccount.fsCore__Account_Name__c = testAccount.id;
        bankAccount.fsCore__Bank_Account_Holder_Name__c = 'John';
        bankAccount.fsCore__Bank_Account_Number__c = '123451234512345';
        bankAccount.fsCore__Bank_Identification_Code__c = 'CODE';
        insert bankAccount;
        
        
    }
    @isTest
    private static void testProcessor(){
        fsCore__Lending_Application__c testApp = [Select Id,fsCore__Payment_Cycle__c,fsCore__Primary_Customer_Contact__c,fsCore__Payment_Amount__c,fsCore__Payment_Start_Date__c,fsCore__Maturity_Date__c from fsCore__Lending_Application__c Limit 1];
        System.debug('testApp:--'+testApp);
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecord(testApp.Id);
        Test.startTest();
        DirectDebitScheduleCreator spltProcessor = new DirectDebitScheduleCreator();
        spltProcessor.SetInput(acInput);
        spltProcessor.process();
        Test.stopTest();
        List<fsCore__Lending_Application_Direct_Debit__c> directDebitRec = [Select Id from fsCore__Lending_Application_Direct_Debit__c];
        System.assertEquals(1, directDebitRec.size());
        
    }
    @isTest
    private static void testProcessor_Error(){
        fsCore__Lending_Application__c testApp = [Select Id,fsCore__Payment_Cycle__c,fsCore__Primary_Customer_Contact__c,fsCore__Payment_Amount__c,fsCore__Payment_Start_Date__c,fsCore__Maturity_Date__c from fsCore__Lending_Application__c Limit 1];
        System.debug('testApp:--'+testApp);
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecord(testApp.Id);
        Test.startTest();
        DirectDebitScheduleCreator spltProcessor = new DirectDebitScheduleCreator();
        spltProcessor.SetInput(acInput);
        spltProcessor.process();
        spltProcessor.addError(testApp.id , null , 'test', 'test');
        spltProcessor.getClassName();
        spltProcessor.getOutput();
        Test.stopTest();
        List<fsCore__Lending_Application_Direct_Debit__c> directDebitRec = [Select Id from fsCore__Lending_Application_Direct_Debit__c];
        System.assertEquals(1, directDebitRec.size());
        
    }
    @isTest
    private static void testProcessor_Error1(){
        fsCore__Lending_Application__c testApp = [Select Id,fsCore__Payment_Cycle__c,fsCore__Primary_Customer_Contact__c,fsCore__Payment_Amount__c,fsCore__Payment_Start_Date__c,fsCore__Maturity_Date__c from fsCore__Lending_Application__c Limit 1];
        System.debug('testApp:--'+testApp);
        fsCore__Lending_Application_Customer__c applicant =[Select Id,Name ,fsCore__Lending_Application_Number__c from fsCore__Lending_Application_Customer__c where fsCore__Lending_Application_Number__c  =:testApp.id limit 1];
        List<fsCore__Bank_Account__c>bankAccountList = [Select Id From fsCore__Bank_Account__c where fsCore__Contact_Name__c =: testApp.fsCore__Primary_Customer_Contact__c order by Name];
        fsCore__Lending_Application_Direct_Debit__c appDirectDebit = new fsCore__Lending_Application_Direct_Debit__c();
        appDirectDebit.fsCore__Direct_Debit_Type__c = 'Recurring';
        appDirectDebit.fsCore__Debit_Cycle__c = testApp.fsCore__Payment_Cycle__c;       
        appDirectDebit.fsCore__Debit_Amount_Source__c = 'Repayment Schedule';
        appDirectDebit.fsCore__Debit_Amount__c = testApp.fsCore__Payment_Amount__c;
        appDirectDebit.fsCore__Debit_Start_Date__c = testApp.fsCore__Payment_Start_Date__c;
        appDirectDebit.fsCore__Debit_End_Date__c = testApp.fsCore__Maturity_Date__c; 
        appDirectDebit.fsCore__Bank_Account_Name__c = bankAccountList[0].id;
        appDirectDebit.fsCore__Lending_Application_Number__c = testApp.id;
        appDirectDebit.fsCore__Customer_Reference_Number__c = applicant.id;
        insert appDirectDebit;
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecord(testApp.Id);
        Test.startTest();
        DirectDebitScheduleCreator spltProcessor = new DirectDebitScheduleCreator();
        spltProcessor.SetInput(acInput);
        spltProcessor.process();
        Test.stopTest();
        List<fsCore__Lending_Application_Direct_Debit__c> directDebitRec = [Select Id from fsCore__Lending_Application_Direct_Debit__c];
        System.assertEquals(1, directDebitRec.size());
        
    }
}