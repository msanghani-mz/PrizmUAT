/**
* Class Name  : InboundPaymentRollupAction
* Description : Class update the first and second payment information on the contract
* Author      : Financial Spectra
*/
public with sharing class InboundPaymentRollupAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    
    private List<fsServ__Lending_Contract__c> mContractList;
    private Map<Id,List<fsServ__Inbound_Payment__c>> mContractPaymentsMap;

    public InboundPaymentRollupAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    

    private void queryContracts(Set<Id> pContractIds){
        fsCore.DynamicQueryBuilder contractQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Lending_Contract__c.getName())
                                              .addFields()
                                              .addWhereConditionWithBind(1,'Id','IN','pContractIds');

        mContractList = (List<fsServ__Lending_Contract__c>) Database.query(contractQuery.getQueryString());

    }  
    private void queryInboundPayments(Set<Id> pContractIds){
        mContractPaymentsMap = new Map<Id,List<fsServ__Inbound_Payment__c>>();
        for (Id contractId : pContractIds){
            mContractPaymentsMap.put(contractId, new List<fsServ__Inbound_Payment__c>());
        }          
        fsCore.DynamicQueryBuilder inboundPaymentQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Inbound_Payment__c.getName())
                                              .addFields()
                                              .addWhereConditionWithBind(1,'fsServ__Lending_Contract_Number__c','IN','pContractIds')
                                              .addOrderByField('Name');

        List<fsServ__Inbound_Payment__c> inboundPaymentList = (List<fsServ__Inbound_Payment__c>) Database.query(inboundPaymentQuery.getQueryString());
        
        //Populate mContractPaymentsMap only with first two payments
        String name;
        Integer counter = 0;
        for (fsServ__Inbound_Payment__c pmt : inboundPaymentList){
            if ((name == null)||(name != pmt.fsServ__Lending_Contract_Number__c)){
                counter = 1;
                name = pmt.fsServ__Lending_Contract_Number__c;
                if (mContractPaymentsMap.containsKey(pmt.fsServ__Lending_Contract_Number__c)){
                    mContractPaymentsMap.get(pmt.fsServ__Lending_Contract_Number__c).add(pmt);
                }
            }else{
                counter++;
                if (counter >2){
                    continue;
                }
                if (mContractPaymentsMap.containsKey(pmt.fsServ__Lending_Contract_Number__c)){
                    mContractPaymentsMap.get(pmt.fsServ__Lending_Contract_Number__c).add(pmt);
                }                

            }
        }        


    }        
    //action input has the set of application ids
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
        queryContracts(mActionInput.getRecords());
        queryInboundPayments(mActionInput.getRecords());        
    }
    
    public void process(){

        Integer loopCount = 0;
        for (fsServ__Lending_Contract__c contract : mContractList){
            loopCount = 0;
            for (fsServ__Inbound_Payment__c inboundPayment : mContractPaymentsMap.get(contract.Id)){
                   loopCount ++;
                    if (loopCount == 1){
                        contract.Received_Amount_First_Payment__c = inboundPayment.fsServ__Payment_Amount__c;
                        contract.First_Payment_Received_Date__c = inboundPayment.fsServ__Payment_Date__c;
                        contract.First_Payment_Status__c = inboundPayment.fsServ__Payment_Status__c;
                        contract.Interest_Received_Amount_First_Payment__c = inboundPayment.Allocated_Amount_Interest__c;
                        contract.Principal_Received_Amount_First_Payment__c = inboundPayment.Allocated_Amount_Principal__c;
                    }else{
                        contract.Received_Amount_Second_Payment__c = inboundPayment.fsServ__Payment_Amount__c;
                        contract.Second_Payment_Received_Date__c = inboundPayment.fsServ__Payment_Date__c;
                        contract.Second_Payment_Status__c = inboundPayment.fsServ__Payment_Status__c;
                        contract.Interest_Received_Amount_Second_Payment__c = inboundPayment.Allocated_Amount_Interest__c;
                        contract.Principal_Received_Amount_Second_Payment__c = inboundPayment.Allocated_Amount_Principal__c;
                    }                     
            }

        }


        Savepoint sp = Database.setSavepoint();
            try{                
                fsCore.DMLResult appSaveRslt = fsServ.LendingContractDMLWrapper.getInstance().updateData(mContractList);
            if (appSaveRslt.hasErrors())  { 
                appSaveRslt.throwError();  }   
            }
            catch (Exception e){
                System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
                Database.rollback(sp);
                mActionOutput.addError(e);
            }
        System.debug(loggingLevel.ERROR, '-- InboundPaymentRollupAction.process(-)');
    }
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('InboundPaymentRollupAction', 'process', mActionOutput.getErrors());
        }
    }
    
}