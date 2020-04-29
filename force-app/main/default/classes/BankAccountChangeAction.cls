public with sharing class BankAccountChangeAction implements fsCore.ActionProcessor{
    private fsCore.ActionInput mInput;
    private fsCore.ActionOutput mOutput;
    
    public BankAccountChangeAction(){
        mInput = new fsCore.ActionInput();
        mOutput = new fsCore.ActionOutput();
    }
    
    public void setInput(fsCore.ActionInput pInput){
        mInput = pInput;
    }
    
    public fsCore.ActionOutput getOutput(){
        return mOutput;
    }
    
    public void process(){
        Set<Id> assignmentIds = mInput.getRecords();
        fsCore.DynamicQueryBuilder asgmtQuery = fsCore.DynamicQueryFactory.createQuery('fsCore__Assignment__c')
                                               .addFields()
                                               .addWhereConditionWithBind(1,'Id','IN','assignmentIds')
                                               .addWhereConditionWithValue(2,'fsCore__Status__c','=','Completed');

        List<fsCore__Assignment__c> assignmentList = (List<fsCore__Assignment__c>)Database.query(asgmtQuery.getQueryString());
        
        Map<Id, fsCore__Bank_Account__c> contractToNewBankAccountMap = new Map<Id, fsCore__Bank_Account__c>();
        
        for(fsCore__Assignment__c assignment : assignmentList) {
            //Creating Bank Account
            fsCore__Bank_Account__c bankAcc = new fsCore__Bank_Account__c();
            bankAcc.fsCore__Account_Name__c             = assignment.fsCore__Account_Name__c;
            bankAcc.fsCore__Contact_Name__c             = assignment.fsCore__Contact_Name__c;
            bankAcc.fsCore__Bank_Account_Holder_Name__c = assignment.Account_Holder_Name__c;
            bankAcc.Name                                = assignment.Bank_Account_Name__c;
            bankAcc.fsCore__Bank_Account_Number__c      = assignment.Bank_Account_Number__c;
            bankAcc.fsCore__Bank_Name__c                = assignment.Bank_Name__c;
            bankAcc.Routing_Number__c                   = assignment.Routing_Number__c;
            bankAcc.fsCore__Bank_Account_Type__c        = assignment.Account_type__c;
            bankAcc.fsCore__Bank_Identification_Code__c = assignment.Routing_Number__c;
            bankAcc.fsCore__Is_Primary__c               = true; 
            
            contractToNewBankAccountMap.put(assignment.fsServ__Lending_Contract_Number__c, bankAcc);
        }
        
        Database.insert(contractToNewBankAccountMap.values());

        //Updating Direct Debit
        Set<Id> contractIds = contractToNewBankAccountMap.keySet();
        
        fsCore.DynamicQueryBuilder dataQuery = fsCore.DynamicQueryFactory.createQuery('fsServ__Contract_Direct_Debit__c')
                                               .addFields()
                                               .addWhereConditionWithBind(1,'fsServ__Lending_Contract_Number__c','IN','contractIds')
                                               .addWhereConditionWithValue(2,'fsServ__Bank_Account_Name__c', '!=', null)
                                               .addWhereConditionWithValue(3,'fsServ__Bank_Account_Name__r.fsCore__Is_Primary__c', '=', false)
                                               .addWhereConditionWithValue(4,'fsServ__Is_Active__c', '=', true);

        Id inactiveDirectDebitRecordTypeId = Schema.SObjectType.fsServ__Contract_Direct_Debit__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
        Id activeDirectDebitRecordTypeId = Schema.SObjectType.fsServ__Contract_Direct_Debit__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();

        List<fsServ__Contract_Direct_Debit__c> existingDirectDebitList = (List<fsServ__Contract_Direct_Debit__c>)Database.query(dataQuery.getQueryString());
        List<fsServ__Contract_Direct_Debit__c> directDebitToBeCreated = new List<fsServ__Contract_Direct_Debit__c>();
        List<fsServ__Contract_Direct_Debit__c> directDebitToBeDeactivated = new List<fsServ__Contract_Direct_Debit__c>();
        
        for(fsServ__Contract_Direct_Debit__c currDirectDebit : existingDirectDebitList) {
            if (contractToNewBankAccountMap.get(currDirectDebit.fsServ__Lending_Contract_Number__c).Id != null){
                //create new direct debit
                fsServ__Contract_Direct_Debit__c newDirectDebit = currDirectDebit.clone(false, true, false, false);
                newDirectDebit.recordTypeId = activeDirectDebitRecordTypeId;
                newDirectDebit.fsServ__Debit_Start_Date__c = newDirectDebit.fsServ__Next_Debit_Date__c;
                newDirectDebit.fsServ__Bank_Account_Name__c = contractToNewBankAccountMap.get(currDirectDebit.fsServ__Lending_Contract_Number__c).Id;
                
                directDebitToBeCreated.add(newDirectDebit);
                
                //deactivate current direct debit
                currDirectDebit.RecordTypeId = inactiveDirectDebitRecordTypeId;
                currDirectDebit.fsServ__Next_Debit_Date__c = fsCore.Constants.END_DATE;
                currDirectDebit.fsServ__Next_Debit_Date_Adjusted__c = fsCore.Constants.END_DATE;
                currDirectDebit.fsServ__Next_DD_Payment_Creation_Date__c = fsCore.Constants.END_DATE;
                currDirectDebit.fsServ__Debit_End_Date__c = System.today();
                directDebitToBeDeactivated.add(currDirectDebit);
            }
        }

        Database.update(directDebitToBeDeactivated);
        Database.insert(directDebitToBeCreated);
        
    }
}