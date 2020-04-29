@isTest(seeAllData=false)
public without sharing class TestCustomDataLoader{
     /*
     * Accounts
     */
    public static Map<String, Account> loadAccounts(){
        List<Account> testAccountList = (List<Account>)Test.loadData(Account.sObjectType, 'Test_Custom_Accounts');
        Map<String, Account> testAccountMap = new Map<String, Account>();

        for(Account acct : testAccountList){
            testAccountMap.put(acct.Name, acct);
        }
        System.assertEquals(5, testAccountMap.size(), 'Test Accounts load assert ');          

        return testAccountMap;
    }

    /*
     * Contacts
     */
    public static Map<String, Contact> loadContacts(){
        List<Contact> testContactList = (List<Contact>)Test.loadData(Contact.sObjectType, 'Test_Custom_Contacts');
        Map<String, Contact> testContactMap = new Map<String, Contact>();

        for(Contact cont : testContactList){
            testContactMap.put(cont.LastName, cont);
        }
        System.assertEquals(13, testContactMap.size(), 'Test Contacts load assert ');          

        return testContactMap;
    }


    /*
     * Lending Contracts in Active status
     */
    public static Map<String, fsServ__Lending_Contract__c> loadLendingContractsActive(){
        deactivateTrigger('LendingContractTrigger');
        
        Test.loadData(fsServ__Lending_Contract__c.sObjectType, 'Test_Custom_LendingContractsActive');

        Schema.RecordTypeInfo activeRecType 
                = Schema.SObjectType.fsServ__Lending_Contract__c.getRecordTypeInfosByDeveloperName().get('Active');
        
        List<fsServ__Lending_Contract__c> contractForUpdate = new List<fsServ__Lending_Contract__c>();
        for(fsServ__Lending_Contract__c contract : [SELECT Id, RecordTypeId FROM fsServ__Lending_Contract__c]){
            contract.RecordTypeId = activeRecType.getRecordTypeId();
            contractForUpdate.add(contract);
        }
        
        if (contractForUpdate.size() > 0){ fsServ.LendingContractDMLWrapper.getInstance().updateData(contractForUpdate); }

        Map<String, fsServ__Lending_Contract__c> testContractMap = fsServ.TestQueryHelper.getTestLendingContracts();
        System.assertEquals(8, testContractMap.size(), 'Test Lending Contracts load assert ');          
        System.assert(testContractMap.containsKey('AT1701000001'), 'Contract AT1701000001 created assert');
        System.assert(testContractMap.containsKey('AT1701000002'), 'Contract AT1701000002 created assert');
        System.assert(testContractMap.containsKey('AT1701000003'), 'Contract AT1701000003 created assert');
        System.assert(testContractMap.containsKey('AT1701000004'), 'Contract AT1701000004 created assert');
        System.assert(testContractMap.containsKey('AT1701000005'), 'Contract AT1701000005 created assert');
        System.assert(testContractMap.containsKey('UB1701000006'), 'Contract UB1701000006 created assert');
        System.assert(testContractMap.containsKey('UB1701000007'), 'Contract UB1701000007 created assert');
        System.assert(testContractMap.containsKey('UB1701000008'), 'Contract UB1701000008 created assert');

        activateTrigger('LendingContractTrigger');
        return testContractMap;
    }     
    
     /*
     * Contract Balances for the loan contract in active status
     */
    public static Map<Id, List<fsServ__Contract_Balance__c>> loadContractBalancesActive(){
        List<fsServ__Contract_Balance__c> testContractBlncList = (List<fsServ__Contract_Balance__c>)Test.loadData(fsServ__Contract_Balance__c.sObjectType, 'Test_Custom_ContractBalancesActive');
        Map<Id, List<fsServ__Contract_Balance__c>> testContractBlncMap = new Map<Id, List<fsServ__Contract_Balance__c>>();

        for(fsServ__Contract_Balance__c conBlnc : testContractBlncList){
            List<fsServ__Contract_Balance__c> balances = new List<fsServ__Contract_Balance__c>();
            if (testContractBlncMap.containsKey(conBlnc.fsServ__Lending_Contract_Number__c)){
                balances = testContractBlncMap.get(conBlnc.fsServ__Lending_Contract_Number__c);
            }
            balances.add(conBlnc);
            testContractBlncMap.put(conBlnc.fsServ__Lending_Contract_Number__c, balances);
        }
        System.assertEquals(32, testContractBlncList.size(), 'Test Contract Balances load assert ');          
        System.assertEquals(8, testContractBlncMap.size(), 'Test Contract Balances Map assert ');          

        return testContractBlncMap;
    }
    
     /*
     * Contract Dues
     */
    public static Map<Id, List<fsServ__Contract_Due__c>> loadContractDues(){
        List<fsServ__Contract_Due__c> testContractDueList = (List<fsServ__Contract_Due__c>)Test.loadData(fsServ__Contract_Due__c.sObjectType, 'Test_Custom_ContractDues');
        Map<Id, List<fsServ__Contract_Due__c>> testContractDueMap = new Map<Id, List<fsServ__Contract_Due__c>>();

        for(fsServ__Contract_Due__c due : testContractDueList){
            List<fsServ__Contract_Due__c> dues = new List<fsServ__Contract_Due__c>();
            if (testContractDueMap.containsKey(due.fsServ__Lending_Contract_Number__c)){
                dues = testContractDueMap.get(due.fsServ__Lending_Contract_Number__c);
            }
            dues.add(due);
            testContractDueMap.put(due.fsServ__Lending_Contract_Number__c, dues);
        }
        
        System.assertEquals(21, testContractDueList.size(), 'Test Contract Dues load assert ');               
        System.assertEquals(8, testContractDueMap.size(), 'Test Contract Dues Map assert ');          

        return testContractDueMap;
    }
    
     /*
     * Contract Repayments
     */
    public static Map<Id, List<fsServ__Contract_Repayment__c>> loadContractRepayments(){
        List<fsServ__Contract_Repayment__c> testContractRepayList = (List<fsServ__Contract_Repayment__c>)Test.loadData(fsServ__Contract_Repayment__c.sObjectType, 'Test_Custom_ContractRepayments');
        Map<Id, List<fsServ__Contract_Repayment__c>> testContractRepayMap = new Map<Id, List<fsServ__Contract_Repayment__c>>();

        for(fsServ__Contract_Repayment__c repay : testContractRepayList){
            List<fsServ__Contract_Repayment__c> repayments = new List<fsServ__Contract_Repayment__c>();
            if (testContractRepayMap.containsKey(repay.fsServ__Lending_Contract_Number__c)){
                repayments = testContractRepayMap.get(repay.fsServ__Lending_Contract_Number__c);
            }
            repayments.add(repay);
            testContractRepayMap.put(repay.fsServ__Lending_Contract_Number__c, repayments);
        }
        System.assertEquals(342, testContractRepayList.size(), 'Test Contract Repayments load assert ');          
        System.assertEquals(8, testContractRepayMap.size(), 'Test Contract Reapyments Map assert ');          

        return testContractRepayMap;
    }

 /*
     * Contract Repayment Schedules
     */
    public static Map<Id, List<fsServ__Contract_Repayment_Schedule__c>> loadContractRepaySchedules(){
        List<fsServ__Contract_Repayment_Schedule__c> testContractRepaySchList = (List<fsServ__Contract_Repayment_Schedule__c>)Test.loadData(fsServ__Contract_Repayment_Schedule__c.sObjectType, 'Test_Custom_ContractRepaymentSchedules');
        Map<Id, List<fsServ__Contract_Repayment_Schedule__c>> testContractRepaySchMap = new Map<Id, List<fsServ__Contract_Repayment_Schedule__c>>();

        for(fsServ__Contract_Repayment_Schedule__c repaySch : testContractRepaySchList){
            List<fsServ__Contract_Repayment_Schedule__c> repaySchedules = new List<fsServ__Contract_Repayment_Schedule__c>();
            if (testContractRepaySchMap.containsKey(repaySch.fsServ__Lending_Contract_Number__c)){
                repaySchedules = testContractRepaySchMap.get(repaySch.fsServ__Lending_Contract_Number__c);
            }
            repaySchedules.add(repaySch);
            testContractRepaySchMap.put(repaySch.fsServ__Lending_Contract_Number__c, repaySchedules);
        }
        
        System.assertEquals(16, testContractRepaySchList.size(), 'Test Contract Repayment Schedules load assert ');          
        System.assertEquals(8, testContractRepaySchMap.size(), 'Test Contract Reapyment Schedules Map assert ');          

        return testContractRepaySchMap;
    }

 /*
     * This method create the lending contract in pending status
     * Do not call this method with loadLendingContractsActive
     */     
    public static Map<String, fsServ__Lending_Contract__c> loadLendingContractsPending(){
        deactivateTrigger('LendingContractTrigger');
        
        List<fsServ__Lending_Contract__c> testContractList = (List<fsServ__Lending_Contract__c>)Test.loadData(fsServ__Lending_Contract__c.sObjectType, 'Test_Custom_LendingContractsPending');
        Map<String, fsServ__Lending_Contract__c> testContractMap = new Map<String, fsServ__Lending_Contract__c>();

        for(fsServ__Lending_Contract__c contract : testContractList){
            testContractMap.put(contract.Name, contract);
        }
        System.assertEquals(8, testContractMap.size(), 'Test Lending Contracts load assert ');          

        System.assert(testContractMap.containsKey('AT1701000001'), 'Contract AT1701000001 created assert');
        System.assert(testContractMap.containsKey('AT1701000002'), 'Contract AT1701000002 created assert');
        System.assert(testContractMap.containsKey('AT1701000003'), 'Contract AT1701000003 created assert');
        System.assert(testContractMap.containsKey('AT1701000004'), 'Contract AT1701000004 created assert');
        System.assert(testContractMap.containsKey('AT1701000005'), 'Contract AT1701000005 created assert');
        System.assert(testContractMap.containsKey('UB1701000006'), 'Contract UB1701000006 created assert');
        System.assert(testContractMap.containsKey('UB1701000007'), 'Contract UB1701000007 created assert');
        System.assert(testContractMap.containsKey('UB1701000008'), 'Contract UB1701000008 created assert');

        activateTrigger('LendingContractTrigger');
        return testContractMap;
    }         
    
    /*
     * Contract Balances for the contracts which are in pending status
     * Do not call this method with loadContractBalancesActive
     */    
    public static Map<Id, List<fsServ__Contract_Balance__c>> loadContractBalancesPending(){
        List<fsServ__Contract_Balance__c> testContractBlncList = (List<fsServ__Contract_Balance__c>)Test.loadData(fsServ__Contract_Balance__c.sObjectType, 'Test_Custom_ContractBalancesPending');
        Map<Id, List<fsServ__Contract_Balance__c>> testContractBlncMap = new Map<Id, List<fsServ__Contract_Balance__c>>();

        for(fsServ__Contract_Balance__c conBlnc : testContractBlncList){
            List<fsServ__Contract_Balance__c> balances = new List<fsServ__Contract_Balance__c>();
            if (testContractBlncMap.containsKey(conBlnc.fsServ__Lending_Contract_Number__c)){
                balances = testContractBlncMap.get(conBlnc.fsServ__Lending_Contract_Number__c);
            }
            balances.add(conBlnc);
            testContractBlncMap.put(conBlnc.fsServ__Lending_Contract_Number__c, balances);
        }
        System.assertEquals(24, testContractBlncList.size(), 'Test Contract Balances load assert ');          
        System.assertEquals(8, testContractBlncMap.size(), 'Test Contract Balances Map assert ');          

        return testContractBlncMap;
    }    


 /*
     * Bank Accounts
     */
    public static Map<String, fsCore__Bank_Account__c> loadBankAccounts(){
        List<fsCore__Bank_Account__c> testBankAcctList = (List<fsCore__Bank_Account__c>)Test.loadData(fsCore__Bank_Account__c.sObjectType, 'Test_Custom_BankAccounts');
        Map<String, fsCore__Bank_Account__c> testBankAcctMap = new Map<String, fsCore__Bank_Account__c>();

        for(fsCore__Bank_Account__c bankAcct : testBankAcctList){
            testBankAcctMap.put(bankAcct.Name, bankAcct);
        }
        System.assertEquals(13, testBankAcctMap.size(), 'Test Bank Accounts load assert ');          

        return testBankAcctMap;
    }

/*
     * Contract Customers
     */
    public static Map<Id, List<fsServ__Contract_Customer__c>> loadContractCustomers(){
        Test.loadData(fsServ__Contract_Customer__c.sObjectType, 'Test_Custom_ContractCustomers');

        Schema.RecordTypeInfo primaryRecType 
                = Schema.SObjectType.fsServ__Contract_Customer__c.getRecordTypeInfosByDeveloperName().get('Primary');
        
        List<fsServ__Contract_Customer__c> customerForUpdate = new List<fsServ__Contract_Customer__c>();

        for(fsServ__Contract_Customer__c customer : [SELECT Id, fsServ__Customer_Type__c, RecordTypeId FROM fsServ__Contract_Customer__c]){
            if (customer.fsServ__Customer_Type__c == 'Primary' && customer.RecordTypeId != primaryRecType.getRecordTypeId()){
                customer.RecordTypeId = primaryRecType.getRecordTypeId();
                customerForUpdate.add(customer);
            }
        }
        if (customerForUpdate.size() > 0){ fsServ.ContractCustomerDMLWrapper.getInstance().updateData(customerForUpdate); }
        
        Map<Id, List<fsServ__Contract_Customer__c>> testContractCustomerMap = fsServ.TestQueryHelper.getTestContractCustomers();
        System.assertEquals(8, testContractCustomerMap.size(), 'Test Contract Customers Map assert ');          

        return testContractCustomerMap;
    }

 /*
     * Contract Fees
     */
    public static Map<Id, List<fsServ__Contract_Fee__c>> loadContractFees(){
        List<fsServ__Contract_Fee__c> testContractFeeList = (List<fsServ__Contract_Fee__c>)Test.loadData(fsServ__Contract_Fee__c.sObjectType, 'Test_Custom_ContractFees');
        Map<Id, List<fsServ__Contract_Fee__c>> testContractFeeMap = new Map<Id, List<fsServ__Contract_Fee__c>>();

        for(fsServ__Contract_Fee__c conFee : testContractFeeList){
            List<fsServ__Contract_Fee__c> fees = new List<fsServ__Contract_Fee__c>();
            if (testContractFeeMap.containsKey(conFee.fsServ__Lending_Contract_Number__c)){
                fees = testContractFeeMap.get(conFee.fsServ__Lending_Contract_Number__c);
            }
            fees.add(conFee);
            testContractFeeMap.put(conFee.fsServ__Lending_Contract_Number__c, fees);
        }
        System.assertEquals(8, testContractFeeList.size(), 'Test Contract Fees load assert ');          
        System.assertEquals(8, testContractFeeMap.size(), 'Test Contract Fees Map assert ');          

        return testContractFeeMap;
    }
    
     /*
     * Contract Itemizations
     */
    public static Map<Id, List<fsServ__Contract_Itemization__c>> loadContractItemizations(){
        List<fsServ__Contract_Itemization__c> testContractItmzList = (List<fsServ__Contract_Itemization__c>)Test.loadData(fsServ__Contract_Itemization__c.sObjectType, 'Test_Custom_ContractItemizations');
        Map<Id, List<fsServ__Contract_Itemization__c>> testContractItmzMap = new Map<Id, List<fsServ__Contract_Itemization__c>>();

        for(fsServ__Contract_Itemization__c conItmz : testContractItmzList){
            List<fsServ__Contract_Itemization__c> itemizations = new List<fsServ__Contract_Itemization__c>();
            if (testContractItmzMap.containsKey(conItmz.fsServ__Lending_Contract_Number__c)){
                itemizations = testContractItmzMap.get(conItmz.fsServ__Lending_Contract_Number__c);
            }
            itemizations.add(conItmz);
            testContractItmzMap.put(conItmz.fsServ__Lending_Contract_Number__c, itemizations);
        }
        System.assertEquals(26, testContractItmzList.size(), 'Test Contract Itemizations load assert ');          
        System.assertEquals(8, testContractItmzMap.size(), 'Test Contract Itemizations Map assert ');          

        return testContractItmzMap;
    }

    
    /*
     * Contract Direct Debits
     */
    public static Map<Id, List<fsServ__Contract_Direct_Debit__c>> loadContractDirectDebits(){
        Test.loadData(fsServ__Contract_Direct_Debit__c.sObjectType, 'Test_Custom_ContractDirectDebits');
        
        Schema.RecordTypeInfo activeRecType 
                = Schema.SObjectType.fsServ__Contract_Direct_Debit__c.getRecordTypeInfosByDeveloperName().get('Active');
        
        List<fsServ__Contract_Direct_Debit__c> directDebitForUpdate = new List<fsServ__Contract_Direct_Debit__c>();

        for(fsServ__Contract_Direct_Debit__c directDebit : [SELECT Id, RecordTypeId FROM fsServ__Contract_Direct_Debit__c]){
            if (directDebit.RecordTypeId != activeRecType.getRecordTypeId()){
                directDebit.RecordTypeId = activeRecType.getRecordTypeId();
                directDebitForUpdate.add(directDebit);
            }
        }
        if (directDebitForUpdate.size() > 0){ fsServ.ContractDirectDebitDMLWrapper.getInstance().updateData(directDebitForUpdate); }
        
        Map<Id, List<fsServ__Contract_Direct_Debit__c>> testDirectDebitMap = fsServ.TestQueryHelper.getTestContractDirectDebits();
        System.assertEquals(8, testDirectDebitMap.size(), 'Test Contract Direct Debit Map assert ');          

        return testDirectDebitMap;
    }

/*
     * Contract Disbursements
     */
    public static Map<Id, List<fsServ__Contract_Disbursement__c>> loadContractDisbursements(){
        Test.loadData(fsServ__Contract_Disbursement__c.sObjectType, 'Test_Custom_ContractDisbursements');

        Schema.RecordTypeInfo newDisbRecType 
                = Schema.SObjectType.fsServ__Contract_Disbursement__c.getRecordTypeInfosByDeveloperName().get('Open');
        
        List<fsServ__Contract_Disbursement__c> disbForUpdate = new List<fsServ__Contract_Disbursement__c>();

        for(fsServ__Contract_Disbursement__c disb : [SELECT Id, RecordTypeId FROM fsServ__Contract_Disbursement__c]){
            if (disb.RecordTypeId != newDisbRecType.getRecordTypeId()){
                disb.RecordTypeId = newDisbRecType.getRecordTypeId();
                disbForUpdate.add(disb);
            }
        }
        if (disbForUpdate.size() > 0){ fsServ.ContractDisbursementDMLWrapper.getInstance().updateData(disbForUpdate); }

        Map<Id, List<fsServ__Contract_Disbursement__c>> testDisbursementMap = fsServ.TestQueryHelper.getTestContractDisbursements();
        System.assertEquals(8, testDisbursementMap.size(), 'Test Contract Disbursement Map assert ');          

        return testDisbursementMap;
    }
    
    /*
     * Helper methods to activate and deactivate triggers during test data load
     */
    private static void activateTrigger(String pTriggerName){
        Map<String, fsCore__Trigger_Execution_Settings__c> trgExeSettingMap = fsCore__Trigger_Execution_Settings__c.getAll();

        fsCore__Trigger_Execution_Settings__c trgExeSetting = new fsCore__Trigger_Execution_Settings__c();
        if(trgExeSettingMap.containsKey(pTriggerName)){
            trgExeSetting = trgExeSettingMap.get(pTriggerName);
        }
        
        trgExeSetting.Name = pTriggerName;
        trgExeSetting.fsCore__Is_Before_Event_Deactivated__c = false;
        trgExeSetting.fsCore__Is_After_Event_Deactivated__c = false;
        upsert trgExeSetting;
    }
    
     private static void deactivateTrigger(String pTriggerName){
        Map<String, fsCore__Trigger_Execution_Settings__c> trgExeSettingMap = fsCore__Trigger_Execution_Settings__c.getAll();

        fsCore__Trigger_Execution_Settings__c trgExeSetting = new fsCore__Trigger_Execution_Settings__c();
        if(trgExeSettingMap.containsKey(pTriggerName)){
            trgExeSetting = trgExeSettingMap.get(pTriggerName);
        }
        
        trgExeSetting.Name = pTriggerName;
        trgExeSetting.fsCore__Is_Before_Event_Deactivated__c = true;
        trgExeSetting.fsCore__Is_After_Event_Deactivated__c = true;
        upsert trgExeSetting;
    }

}