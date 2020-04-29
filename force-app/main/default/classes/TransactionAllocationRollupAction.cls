/**
* Class Name  : TransactionAllocationRollupAction
* Description : Class to refresh the tradelines on lending application
*               by fetching the information fro NuDebt 
* Author      : Financial Spectra
*/
public with sharing class TransactionAllocationRollupAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    
    private List<fsServ__Lending_Contract__c> mContractList;
    private Set<Id> mContractIds;
    private List<fsServ__Inbound_Payment__c> mInboundPaymentList;
    private Map<Id,List<fsServ__Contract_Transaction_Balance_Allocation__c>> mPaymentAllocationMap;
    

    public class TransactionAllocationRollupException extends Exception{}
    
    public TransactionAllocationRollupAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    

    private void queryContracts(Set<Id> pContractIds){
        fsCore.DynamicQueryBuilder contractQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Lending_Contract__c.getName())
                                              .addField('id')
                                              .addField('First_Payment_Received_Date__c')
                                              .addField('First_Payment_Status__c')
                                              .addField('Principal_Received_Amount_First_Payment__c')
                                              .addField('Interest_Received_Amount_First_Payment__c')
                                              .addField('Received_Amount_First_Payment__c')
                                              .addField('Second_Payment_Received_Date__c')
                                              .addField('Second_Payment_Status__c')
                                              .addField('Principal_Received_Amount_Second_Payment__c')
                                              .addField('Interest_Received_Amount_Second_Payment__c')
                                              .addField('Received_Amount_Second_Payment__c')
                                              .addWhereConditionWithBind(1,'Id','IN','pContractIds')
                                              .addWhereConditionWithValue(2, 'Received_Amount_First_Payment__c', '=', null)
                                              .addWhereConditionWithValue(3, 'Received_Amount_Second_Payment__c', '=', null)
                                              .setWhereConditionCriteria('1 AND (2 OR 3) ');
                                              
                                              

        mContractList = (List<fsServ__Lending_Contract__c>) Database.query(contractQuery.getQueryString());
        
        mContractIds = new Set<Id>();
        for (fsServ__Lending_Contract__c contract : mContractList){
            mContractIds.add(contract.Id);
        }        
    }  

    private void queryInboundPayments(Set<Id> pInboundPaymentIds){
        fsCore.DynamicQueryBuilder inboundPaymentQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Inbound_Payment__c.getName())
                                              .addFields()
                                              .addWhereConditionWithBind(1,'Id','IN','pInboundPaymentIds');

        mInboundPaymentList = (List<fsServ__Inbound_Payment__c>) Database.query(inboundPaymentQuery.getQueryString());
        
        Set<Id> contractIds = new Set<Id>();
        for (fsServ__Inbound_Payment__c pmt : mInboundPaymentList){
            contractIds.add(pmt.fsServ__Lending_Contract_Number__c);
        }
        queryContracts(contractIds);

    }  
    private void queryInboundPaymentAllocations(Set<Id> pInboundPaymentIds){
        mPaymentAllocationMap = new Map<Id,List<fsServ__Contract_Transaction_Balance_Allocation__c>>();

        for (Id inboundPaymentId : pInboundPaymentIds){
            mPaymentAllocationMap.put(inboundPaymentId, new List<fsServ__Contract_Transaction_Balance_Allocation__c>());
        }        

        fsCore.DynamicQueryBuilder paymentAllocationQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Contract_Transaction_Balance_Allocation__c.getName())
                                              .addFields()
                                              .addWhereConditionWithBind(1,'fsServ__Inbound_Payment_Number__c','IN','pInboundPaymentIds');

        List<fsServ__Contract_Transaction_Balance_Allocation__c> paymentAllocationList = (List<fsServ__Contract_Transaction_Balance_Allocation__c>) Database.query(paymentAllocationQuery.getQueryString());
        for (fsServ__Contract_Transaction_Balance_Allocation__c alloc : paymentAllocationList){
            if (mPaymentAllocationMap.containsKey(alloc.fsServ__Inbound_Payment_Number__c)){ mPaymentAllocationMap.get(alloc.fsServ__Inbound_Payment_Number__c).add(alloc);  }
        }

    }        
    //action input has the set of application ids
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
        queryInboundPayments(mActionInput.getRecords());
        queryInboundPaymentAllocations(mActionInput.getRecords());        
    }
    
    public void process(){

        for (fsServ__Inbound_Payment__c inboundPayment : mInboundPaymentList){
                inboundPayment.Allocated_Amount_Interest__c = 0.00;
                inboundPayment.Allocated_Amount_Late_Fee__c = 0.00;
                inboundPayment.Allocated_Amount_Other_Fee__c = 0.00;
                inboundPayment.Allocated_Amount_Principal__c = 0.00;

            for (fsServ__Contract_Transaction_Balance_Allocation__c paymentAllocation : mPaymentAllocationMap.get(inboundPayment.Id)){
                if (paymentAllocation.fsServ__Transaction_Code__c == 'INTEREST_PAYMENT_RECEIVED'){
                    inboundPayment.Allocated_Amount_Interest__c += paymentAllocation.fsServ__Allocated_Amount__c;
                }else if (paymentAllocation.fsServ__Transaction_Code__c == 'INTEREST_PAYMENT_REVERSED'){
                    inboundPayment.Allocated_Amount_Interest__c -= paymentAllocation.fsServ__Allocated_Amount__c;
                    if (inboundPayment.Allocated_Amount_Interest__c < 0){
                        inboundPayment.Allocated_Amount_Interest__c = 0.00;
                    }                                                                           
                }else if (paymentAllocation.fsServ__Transaction_Code__c == 'PRINCIPAL_PAYMENT_RECEIVED'){
                    inboundPayment.Allocated_Amount_Principal__c += paymentAllocation.fsServ__Allocated_Amount__c;
                }else if (paymentAllocation.fsServ__Transaction_Code__c == 'PRINCIPAL_PAYMENT_REVERSED'){
                    inboundPayment.Allocated_Amount_Principal__c -= paymentAllocation.fsServ__Allocated_Amount__c;
                    if (inboundPayment.Allocated_Amount_Principal__c < 0){
                        inboundPayment.Allocated_Amount_Principal__c = 0.00;
                    }
                }else if (paymentAllocation.fsServ__Transaction_Code__c == 'LATE_FEE_PAYMENT_RECEIVED'){
                    inboundPayment.Allocated_Amount_Late_Fee__c += paymentAllocation.fsServ__Allocated_Amount__c;
                }else if (paymentAllocation.fsServ__Transaction_Code__c == 'LATE_FEE_PAYMENT_REVERSED'){
                    inboundPayment.Allocated_Amount_Late_Fee__c -= paymentAllocation.fsServ__Allocated_Amount__c;
                    if (inboundPayment.Allocated_Amount_Late_Fee__c < 0){
                        inboundPayment.Allocated_Amount_Late_Fee__c = 0.00;
                    }                                   
                //ANYTHING ELSE MOVE IT TO THE OTHER FEE BUCKET
                }else if  (paymentAllocation.fsServ__Transaction_Code__c.contains('RECEIVED')){
                    inboundPayment.Allocated_Amount_Other_Fee__c += paymentAllocation.fsServ__Allocated_Amount__c;
                }else if (paymentAllocation.fsServ__Transaction_Code__c.contains('REVERSED')){
                    inboundPayment.Allocated_Amount_Other_Fee__c -= paymentAllocation.fsServ__Allocated_Amount__c;
                    if (inboundPayment.Allocated_Amount_Other_Fee__c < 0){
                        inboundPayment.Allocated_Amount_Other_Fee__c = 0.00;
                    }                                                       
                }                                                
                
            }
        }


        Savepoint sp = Database.setSavepoint();
            try{                
                fsCore.DMLResult appSaveRslt = fsServ.InboundPaymentDMLWrapper.getInstance().updateData(mInboundPaymentList);
            if (appSaveRslt.hasErrors())  {  appSaveRslt.throwError();  }   
            
                submitPaymentUpdateOnContract();
            }
            
            catch (Exception e){
                System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
                Database.rollback(sp);
                mActionOutput.addError(e);
            }
            
        System.debug(loggingLevel.ERROR, '-- TransactionAllocationRollupAction.process(-)');
    }
    
    private void submitPaymentUpdateOnContract(){
        if (mContractIds.size() > 0 ){
            Boolean submitQueuableBatchJob = true;
            if (system.IsBatch() || System.isFuture()||System.isQueueable()){
                submitQueuableBatchJob = false;
            }
            if (submitQueuableBatchJob){
                InboundPaymentRollupQueueable inboundPaymentRollupQueueable = new InboundPaymentRollupQueueable(mContractIds);
                if(!Test.isRunningTest()){  ID jobID = System.enqueueJob(inboundPaymentRollupQueueable); }
            }else{
                fsCore.ActionInput acInput = new fsCore.ActionInput();
                acInput.addRecords(mContractIds);
        
                InboundPaymentRollupAction paymentRollupAction = new InboundPaymentRollupAction();
                paymentRollupAction.setInput(acInput);
                paymentRollupAction.process();
                fsCore.ActionOutput acOutput = paymentRollupAction.getOutput();                
            }
        }
    }
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
           fsCore.DiagnosticLogUtil.logErrors('TransactionAllocationRollupAction', 'process', mActionOutput.getErrors());
        }
    }
    
}