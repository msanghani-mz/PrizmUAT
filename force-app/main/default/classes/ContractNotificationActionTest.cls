/*
 * Class Name   - ContractNotificationActionTest
 * Description  - Test class for ContractNotificationAction and ContractNotificationUtil
 */
@isTest(seeAllData=false)
private class ContractNotificationActionTest{
  
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
    @testSetup static void createTestData(){
        fsServ.TestHelperGlobal.createSetupData();
        //fsServ.TestHelperGlobal.createLendingContracts(true, true); //this will create contracts with customers, direct debit and dues  
        createLendingContracts(true, true);
        fsCore__Bank_Account__c testacc= new fsCore__Bank_Account__c();
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        testBranch.fsCore__Business_Date__c = testBranch.fsCore__Business_Date__c.addDays(30);
        update testBranch;
    }
        
     @isTest
     private static void testContractNotification(){
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();

        Map<String, Schema.RecordTypeInfo> paymentRecTypeMap = Schema.SObjectType.fsServ__Inbound_Payment__c.getRecordTypeInfosByDeveloperName();
        
        List<fsServ__Inbound_Payment__c> testPayments = new List<fsServ__Inbound_Payment__c>();
        for(fsServ__Lending_Contract__c contract : contractList){
            fsServ__Inbound_Payment__c inPmt = fsServ.TestHelperGlobal.getInboundPayment(contract,contract.fsServ__Current_Payment_Amount__c, testBranch.fsCore__Business_Date__c);
            inPmt.fsServ__Payment_Status__c = 'Processed';
            inPmt.fsServ__Payment_Creation_Method__c = 'Apex Job';
            inPmt.RecordTypeId = paymentRecTypeMap.get(fsServ.Constants.RECORD_TYPE_PROCESSED).getRecordTypeId();
            inPmt.Is_Success_Notification_Sent__c = false;
            testPayments.add(inPmt);
        }
        
        fsCore.DMLResult saveRslt = fsServ.InboundPaymentDMLWrapper.getInstance().insertData(testPayments);
        Set<Id> paymentIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(paymentIds);

        Test.startTest();
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAYMENT_SUCCESS);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
        System.assertEquals(paymentIds.size(), [SELECT count() FROM fsServ__Inbound_Payment__c WHERE Id IN :paymentIds AND Is_Success_Notification_Sent__c = true]);
    }
   
     @isTest
    private static void testContractNotificationPmtFailure(){
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();

        Map<String, Schema.RecordTypeInfo> paymentRecTypeMap = Schema.SObjectType.fsServ__Inbound_Payment__c.getRecordTypeInfosByDeveloperName();
        
        List<fsServ__Inbound_Payment__c> testPayments = new List<fsServ__Inbound_Payment__c>();
        for(fsServ__Lending_Contract__c contract : contractList){
            fsServ__Inbound_Payment__c inPmt = fsServ.TestHelperGlobal.getInboundPayment(contract,contract.fsServ__Current_Payment_Amount__c, testBranch.fsCore__Business_Date__c);
            inPmt.fsServ__Payment_Status__c = 'Reversed';
            inPmt.fsServ__Payment_Creation_Method__c = 'Apex Job';
            inPmt.RecordTypeId = paymentRecTypeMap.get(fsServ.Constants.RECORD_TYPE_PROCESSED).getRecordTypeId();
            inPmt.Is_Reject_Notification_Sent__c = false;
            testPayments.add(inPmt);
        }
        
        fsCore.DMLResult saveRslt = fsServ.InboundPaymentDMLWrapper.getInstance().insertData(testPayments);
        Set<Id> paymentIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(paymentIds);

        Test.startTest();
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAYMENT_FAILURE);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
        System.assertEquals(paymentIds.size(), [SELECT count() FROM fsServ__Inbound_Payment__c WHERE Id IN :paymentIds AND Is_Reject_Notification_Sent__c = true]);
    }
   
    @isTest
    private static void testContractNotificationPayoffPmt(){
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();
        //Create a record in that fsServ__Contract_Payoff_Quote__c 
         List<fsServ__Contract_Payoff_Quote__c> payoffQuotes = new List<fsServ__Contract_Payoff_Quote__c>();

           for (fsServ__Lending_Contract__c contract : contractList){
                fsServ__Contract_Payoff_Quote__c quote =TestContractNotificationHelperData.getTestPayoffQuotes(contract,testBranch.fsCore__Business_Date__c);
                payoffQuotes.add(quote);
            }
        
        fsCore.DMLResult saveQRslt = fsServ.PayoffQuoteDMLWrapper.getInstance().insertData(payoffQuotes);



        Map<Id,fsCore__Bank_Account__c> contractBankAccountMap = TestContractNotificationHelperData.getBankAccounts(contractList);
        Map<Id,fsServ__Contract_Customer__c> contractCustomerMap = TestContractNotificationHelperData.getContractCustomer(contractList);

         //create Record in Direct Debit      
        List<fsServ__Contract_Direct_Debit__c> testDirectDebitPayments = new List<fsServ__Contract_Direct_Debit__c>();
        for(fsServ__Lending_Contract__c contract : contractList){
            fsServ__Contract_Direct_Debit__c payoffDirectDebitPmt = TestContractNotificationHelperData.getDirectDebit(contract,contractCustomerMap,contractBankAccountMap,contract.fsServ__Payoff_Amount_Today__c);
            payoffDirectDebitPmt.fsServ__Payoff_Quote_Number__c  =  payoffQuotes[0].Id;
            payoffDirectDebitPmt.fsServ__Direct_Debit_Type__c = 'One-Time';
            testDirectDebitPayments.add(payoffDirectDebitPmt);
        }
            
        fsCore.DMLResult saveRslt = fsServ.ContractDirectDebitDMLWrapper.getInstance().insertData(testDirectDebitPayments);
        
        
        Set<Id> payoffIds = saveRslt.getSuccessRecordSet();

        system.debug(logginglevel.error,'getErrorList() :'+saveRslt.getErrorList());

        System.assertEquals(true, (payoffIds.size() > 0));
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(payoffIds);

        Test.startTest();
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAYOFF_NOTIFICATION);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
        System.assertEquals(payoffIds.size(), [SELECT count() FROM fsServ__Contract_Direct_Debit__c WHERE Id IN :payoffIds AND fsServ__Direct_Debit_Type__c = 'One-Time']);
    }
    
      @isTest
    private static void testContractNotificationPaidoffPmt(){
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();
         List<fsServ__Contract_Payoff_Quote__c> payoffQuotes = new List<fsServ__Contract_Payoff_Quote__c>();      
        List<fsServ__Lending_Contract__c> contracts = new List<fsServ__Lending_Contract__c>();


           for (fsServ__Lending_Contract__c contract : contractList){
                fsServ__Contract_Payoff_Quote__c quote =TestContractNotificationHelperData.getTestPayoffQuotes(contract,testBranch.fsCore__Business_Date__c);
                contract.fsServ__Contract_Status__c = 'Paid In Full';
               contracts.add(contract);
                payoffQuotes.add(quote);
            }
        update contracts;
        fsCore.DMLResult saveQRslt = fsServ.PayoffQuoteDMLWrapper.getInstance().insertData(payoffQuotes);



        Map<Id,fsCore__Bank_Account__c> contractBankAccountMap = TestContractNotificationHelperData.getBankAccounts(contractList);
        Map<Id,fsServ__Contract_Customer__c> contractCustomerMap = TestContractNotificationHelperData.getContractCustomer(contractList);

        List<fsServ__Contract_Direct_Debit__c> testDirectDebitPayments = new List<fsServ__Contract_Direct_Debit__c>();
        for(fsServ__Lending_Contract__c contract : contractList){
            fsServ__Contract_Direct_Debit__c payoffDirectDebitPmt = TestContractNotificationHelperData.getDirectDebit(contract,contractCustomerMap,contractBankAccountMap,contract.fsServ__Payoff_Amount_Today__c);
            payoffDirectDebitPmt.fsServ__Payoff_Quote_Number__c  =  payoffQuotes[0].Id;
            payoffDirectDebitPmt.fsServ__Direct_Debit_Type__c = 'One-Time';
            testDirectDebitPayments.add(payoffDirectDebitPmt);
        }
            
        fsCore.DMLResult saveRslt = fsServ.ContractDirectDebitDMLWrapper.getInstance().insertData(testDirectDebitPayments);
        
        
        Set<Id> payoffIds = saveRslt.getSuccessRecordSet();

        system.debug(logginglevel.error,'getErrorList() :'+saveRslt.getErrorList());

        System.assertEquals(true, (payoffIds.size() > 0));
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(payoffIds);

        Test.startTest();
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAID_OFF_NOTIFICATION );
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
        System.assertEquals(payoffIds.size(), [SELECT count() FROM fsServ__Contract_Direct_Debit__c WHERE Id IN :payoffIds AND fsServ__Direct_Debit_Type__c = 'One-Time']);
    }
    
    @isTest
    private static void testContractNotificationPmtDue(){
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();

        Map<String, Schema.RecordTypeInfo> paymentRecTypeMap = Schema.SObjectType.fsServ__Contract_Direct_Debit__c.getRecordTypeInfosByDeveloperName();
        List<fsServ__Contract_Due__c> duePayments = new List<fsServ__Contract_Due__c>();
        for(fsServ__Lending_Contract__c contract : contractList){
            fsServ__Contract_Due__c paymentDue=TestContractNotificationHelperData.getDuePayment(contract,testBranch.fsCore__Business_Date__c);
            duePayments.add(paymentDue);
        }    
        fsCore.DMLResult saveQRslt = fsServ.ContractDueDMLWrapper.getInstance().insertData(duePayments);
        Set<Id> dueIds = saveQRslt.getSuccessRecordSet();
        system.debug(logginglevel.error,'dueIds Size :'+dueIds.size());

        /*Map<Id,fsCore__Bank_Account__c> contractBankAccountMap = TestContractNotificationHelperData.getBankAccounts(contractList);
        Map<Id,fsServ__Contract_Customer__c> contractCustomerMap = TestContractNotificationHelperData.getContractCustomer(contractList);
        
        List<fsServ__Contract_Direct_Debit__c> testPayments = new List<fsServ__Contract_Direct_Debit__c>();
        for(fsServ__Lending_Contract__c contract : contractList){
            fsServ__Contract_Direct_Debit__c duePmt = TestContractNotificationHelperData.getDirectDebit(contract,contractCustomerMap,contractBankAccountMap,contract.fsServ__Current_Payment_Amount__c);
             duePmt.fsServ__Direct_Debit_Type__c = 'Recurring';
             testPayments.add(duePmt);
        }
        
        fsCore.DMLResult saveRslt = fsServ.ContractDirectDebitDMLWrapper.getInstance().insertData(testPayments);
        Set<Id> paymentIds = saveRslt.getSuccessRecordSet();
         system.debug(logginglevel.error,'getErrorList() :'+saveRslt.getErrorList());*/
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(dueIds);

        Test.startTest();
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAYMENT_DUE_REMINDER);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
        //System.assertEquals(paymentIds.size(),[SELECT count() FROM fsServ__Contract_Direct_Debit__c WHERE Id IN :paymentIds AND fsServ__Direct_Debit_Type__c = 'Recurring']);
    }
     @isTest
    private static void testContractNotificationPmtPlan(){
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();

        Map<String, Schema.RecordTypeInfo> paymentRecTypeMap = Schema.SObjectType.fsServ__Contract_Direct_Debit__c.getRecordTypeInfosByDeveloperName();
        

        Map<Id,fsCore__Bank_Account__c> contractBankAccountMap = TestContractNotificationHelperData.getBankAccounts(contractList);
        Map<Id,fsServ__Contract_Customer__c> contractCustomerMap = TestContractNotificationHelperData.getContractCustomer(contractList);

        List<fsServ__Contract_Direct_Debit__c> testPayments = new List<fsServ__Contract_Direct_Debit__c>();
        for(fsServ__Lending_Contract__c contract : contractList){
            fsServ__Contract_Direct_Debit__c pmtPlan = TestContractNotificationHelperData.getDirectDebit(contract,contractCustomerMap,contractBankAccountMap,contract.fsServ__Current_Payment_Amount__c);
             pmtPlan.fsServ__Direct_Debit_Type__c = 'Payment Plan';
             testPayments.add(pmtPlan);
        }
        
        fsCore.DMLResult saveRslt = fsServ.ContractDirectDebitDMLWrapper.getInstance().insertData(testPayments);
        Set<Id> paymentIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(paymentIds);

        Test.startTest();
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAYMENT_PLAN_SETUP);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
        System.assertEquals(paymentIds.size(), [SELECT count() FROM fsServ__Contract_Direct_Debit__c WHERE Id IN :paymentIds AND fsServ__Direct_Debit_Type__c = 'Payment Plan']);
    }
         
         
    @isTest
    private static void testContractNotificationErrors(){
        Map<Id, fsServ__Lending_Contract__c> contractsMap = new Map<Id, fsServ__Lending_Contract__c>(fsServ.TestQueryHelper.getTestLendingContracts().values());
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(contractsMap.keySet());

        Test.startTest();
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
         
        Boolean hasError = false;
        try{
            notifyAction.process();
        }
        catch (Exception e){
            hasError = true;
        }
        System.assertEquals(true, hasError);
        

        hasError = false;
        try{
            notifyAction.setNotificationType('DUMMY');
            notifyAction.process();
        }
        catch (Exception e){
            hasError = true;
        }
        System.assertEquals(true, hasError);
        Test.stopTest();
    }
}