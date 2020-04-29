/**
* @File Name          : ContractBalanceTriggerTest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 10/18/2019, 6:40:29 PM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    10/18/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class ContractBalanceTriggerTest {
    
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
    
    @testSetup
    static void createTestData(){
        //Lending Contract
        fsserv.TestHelperGlobal.createSetupData();
        createLendingContracts(true, true);
        
        
        fsCore__Balance_Setup__c testBalance = fsCore.TestHelperFinancial.getTestBalanceSetup('Test Fee Balance Name', 'Fee');
        insert testBalance;
        
        fsCore__Transaction_Setup__c testTransaction = fsCore.TestHelperFinancial.getTestTransactionSetup('Test Transaction Name', testBalance.id, 'Post');
        fsCore__Transaction_Setup__c lateFeeReverseTxn = fsCore.TestHelperFinancial.getTestTransactionSetup('LATE_FEE_PAYMENT_REVERSED', testBalance.id, 'Reverse');
        fsCore__Transaction_Setup__c lateFeeTxn = fsCore.TestHelperFinancial.getTestTransactionSetup('LATE_FEE_PAYMENT_RECEIVED', testBalance.id, 'Post');
        List<fsCore__Transaction_Setup__c> testTxns = new List<fsCore__Transaction_Setup__c>();
        testTxns.add(testTransaction);
        testTxns.add(lateFeeReverseTxn);
        testTxns.add(lateFeeTxn);
        insert testTxns;
        
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAllocMethod = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation Method');
        insert testPaymentAllocMethod;
        
        
    }
    
    @isTest
    private static void testInsertTriggers(){
        fsServ__Lending_Contract__c lendingContract = fsServ.TestQueryHelper.getTestLendingContracts().get('AT1701000001');
        List<fsServ__Inbound_Payment__c> testInboundPaymentList = new List<fsServ__Inbound_Payment__c>();
        
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        
        
        fsServ__Inbound_Payment__c testInboundPayment = fsServ.TestContractDataHelper.getTestInboundPayment(lendingContract, null, 1000, testBranch.fsCore__Business_Date__c);
        
        testInboundPayment.fsServ__Is_Process_Payment_On_Save__c = true;
        testInboundPaymentList.add(testInboundPayment);
        
        test.startTest();
        insert testInboundPaymentList; 
        List<fsServ__Contract_Balance__c> contractBalances = [Select id from fsServ__Contract_Balance__c];
        test.stopTest();
        System.assert(contractBalances.size()>0, 'Contract Balances asserted');
        
    }
    @isTest
    private static void testUpdateTriggers(){
        fsServ__Lending_Contract__c lendingContract = fsServ.TestQueryHelper.getTestLendingContracts().get('AT1701000001');
        List<fsServ__Inbound_Payment__c> testInboundPaymentList = new List<fsServ__Inbound_Payment__c>();
        
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        
        
        fsServ__Inbound_Payment__c testInboundPayment = fsServ.TestContractDataHelper.getTestInboundPayment(lendingContract, null, 1000, testBranch.fsCore__Business_Date__c);
        
        testInboundPayment.fsServ__Is_Process_Payment_On_Save__c = true;
        testInboundPaymentList.add(testInboundPayment);
        
        test.startTest();
        insert testInboundPaymentList; 
        
        List<fsServ__Contract_Balance__c> contractBalances = [Select id from fsServ__Contract_Balance__c];
        contractBalances[0].fsServ__Billed_Amount__c = 100;
        update contractBalances[0];
        
        List<fsServ__Contract_Transaction_Balance_Allocation__c> conTrnxBalAllocation = [Select id from fsServ__Contract_Transaction_Balance_Allocation__c];
        conTrnxBalAllocation[0].fsServ__Allocated_Amount__c = 500;
        update conTrnxBalAllocation[0];
        
        System.assert(contractBalances.size()>0, 'Contract Balances asserted');
        System.assert(conTrnxBalAllocation.size()>0, 'Contract Trnx and Balance Allocation asserted');
        test.stopTest();
    }
    
    @isTest
    private static void testDeleteTriggers(){
        fsServ__Lending_Contract__c lendingContract = fsServ.TestQueryHelper.getTestLendingContracts().get('AT1701000001');
        List<fsServ__Inbound_Payment__c> testInboundPaymentList = new List<fsServ__Inbound_Payment__c>();
        
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        
        
        fsServ__Inbound_Payment__c testInboundPayment = fsServ.TestContractDataHelper.getTestInboundPayment(lendingContract, null, 1000, testBranch.fsCore__Business_Date__c);
        
        testInboundPayment.fsServ__Is_Process_Payment_On_Save__c = true;
        testInboundPaymentList.add(testInboundPayment);
        
        test.startTest();
        insert testInboundPaymentList; 
        
        List<fsServ__Contract_Balance__c> contractBalances = [Select id from fsServ__Contract_Balance__c];
        delete contractBalances[0];
        
        List<fsServ__Contract_Transaction_Balance_Allocation__c> conTrnxBalAllocation = [Select id from fsServ__Contract_Transaction_Balance_Allocation__c];
        delete conTrnxBalAllocation[0];
        
        System.assert(contractBalances.size()>0, 'Contract Balances asserted');
        System.assert(conTrnxBalAllocation.size()>0, 'Contract Trnx and Balance Allocation asserted');
        test.stopTest();
        
    }
    @isTest
    private static void testErrors(){
        fsServ__Lending_Contract__c lendingContract = fsServ.TestQueryHelper.getTestLendingContracts().get('AT1701000001');
        fsServ__Lending_Contract__c lendingContract1 = fsServ.TestQueryHelper.getTestLendingContracts().get('AT1701000002');
        fsServ__Lending_Contract__c lendingContract2 = fsServ.TestQueryHelper.getTestLendingContracts().get('AT1701000003');
        fsServ__Lending_Contract__c lendingContract3 = fsServ.TestQueryHelper.getTestLendingContracts().get('AT1701000004');
        
        
        
        
        List<fsServ__Inbound_Payment__c> testInboundPaymentList = new List<fsServ__Inbound_Payment__c>();
        
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        
        
        fsServ__Inbound_Payment__c testInboundPayment = fsServ.TestContractDataHelper.getTestInboundPayment(lendingContract, null, 1000, testBranch.fsCore__Business_Date__c);
        
        testInboundPayment.fsServ__Is_Process_Payment_On_Save__c = true;
        testInboundPaymentList.add(testInboundPayment);
        
        fsServ__Inbound_Payment__c testInboundPayment1 = fsServ.TestContractDataHelper.getTestInboundPayment(lendingContract1, null, 1000, testBranch.fsCore__Business_Date__c);
        
        testInboundPayment1.fsServ__Is_Process_Payment_On_Save__c = true;
        testInboundPaymentList.add(testInboundPayment1);
        
        fsServ__Inbound_Payment__c testInboundPayment2 = fsServ.TestContractDataHelper.getTestInboundPayment(lendingContract2, null, 1000, testBranch.fsCore__Business_Date__c);
        
        testInboundPayment2.fsServ__Is_Process_Payment_On_Save__c = true;
        testInboundPaymentList.add(testInboundPayment2);
        
        fsServ__Inbound_Payment__c testInboundPayment3 = fsServ.TestContractDataHelper.getTestInboundPayment(lendingContract3, null, 1000, testBranch.fsCore__Business_Date__c);
        
        testInboundPayment3.fsServ__Is_Process_Payment_On_Save__c = true;
        testInboundPaymentList.add(testInboundPayment3);
        
        test.startTest();
        insert testInboundPaymentList; 
        
        List<fsServ__Contract_Balance__c> contractBalances = [Select id from fsServ__Contract_Balance__c];
        
        List<fsServ__Contract_Transaction_Balance_Allocation__c> conTrnxBalAllocation = [Select id from fsServ__Contract_Transaction_Balance_Allocation__c];
        conTrnxBalAllocation[1].fsServ__Transaction_Code__c = 'LATE_FEE_PAYMENT_RECEIVED';
        conTrnxBalAllocation[2].fsServ__Transaction_Code__c = 'LATE_FEE_PAYMENT_REVERSED';
        List<fsServ__Contract_Transaction_Balance_Allocation__c> updateConTrnxBalAllocation = new List<fsServ__Contract_Transaction_Balance_Allocation__c>();
        updateConTrnxBalAllocation.add(conTrnxBalAllocation[1]);
        updateConTrnxBalAllocation.add( conTrnxBalAllocation[2]);
        
        update updateConTrnxBalAllocation;
        
        System.assert(contractBalances.size()>0, 'Contract Balances asserted');
        System.assert(conTrnxBalAllocation.size()>0, 'Contract Trnx and Balance Allocation asserted');
        test.stopTest();
        
    }
}