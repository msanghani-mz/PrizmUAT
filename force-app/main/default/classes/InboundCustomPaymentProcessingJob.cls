/*
 * Copyright (c) 2019 FinancialSpectra Pty Ltd
 * All rights reserved.
 *
 * Class Name   - InboundCustomPaymentProcessingJob 
 *
 * Description  - This is the custom class created for SFS to process the ACH payments until the NuPay_Transaction_Status__c
 * is set to completed.
 * For all other Payment Modes (except ACH), as soon as the system date reaches the fsServ__Payment_Date__c the records will be processed.
 *
 *
 */
global with sharing class InboundCustomPaymentProcessingJob extends fsCore.BatchQueryableBase{
    private static final String CLASS_NAME = 'InboundCustomPaymentProcessingJob';
    
    global InboundCustomPaymentProcessingJob(){
        setJobQuery(getDefaultQuery()); // this will set the query without branch code parameter
        System.debug(loggingLevel.ERROR, '-- Default Query : ' + getDefaultQuery());
    }        

    global override void setParameterizedJobQuery(){
        setJobQuery(getParameterizedQuery()); // this will set the query with branch code parameter, if branch code is set
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Inbound_Payment__c.getName())
                                                  .addField('Id')
                                                  .addWhereConditionWithValue(1, 'RecordType.DeveloperName', '=', fsServ.Constants.RECORD_TYPE_OPEN)
                                                  .addWhereConditionWithValue(2, 'fsServ__Payment_Status__c', '=', fsServ.Constants.PAYMENT_STATUS_READY)
                                                  .addWhereConditionWithValue(3, 'fsServ__Payment_Status__c', '=', fsServ.Constants.PAYMENT_STATUS_IN_PROCESS)
                                                  .addWhereConditionWithValue(4, 'fsServ__Payment_Mode__c', '=', fsServ.Constants.PAYMENT_MODE_ACH)
                                                  .addWhereConditionWithValue(5, 'NuPay_Transaction_Status__c', '=', 'Completed')
                                                  .addWhereConditionWithValue(6, 'NuPay_Transaction_Status__c', '=', 'Cleared')
                                                  .addWhereConditionWithValue(7, 'fsServ__Payment_Mode__c', '!=', fsServ.Constants.PAYMENT_MODE_ACH)
                                                  .addOrderByField('fsServ__Payment_Date__c', 'ASC');
        if (String.isBlank(getBranchCode())){
            jobQuery.addWhereConditionWithValue(8, 'fsServ__Payment_Date__c', '<=', System.today());
            //jobQuery.setWhereConditionCriteria('1 AND (2 OR 3) AND ( (4 AND 5) OR ( 6 ) ) AND 7 ');
            jobQuery.setWhereConditionCriteria('1 AND (2 OR 3) AND ( (4 AND (5 OR 6)) OR ( 7 ) ) AND 8 ');
        }  
//        system.debug(logginglevel.error,'-- Query String -- '+jobQuery.getQueryString());
        return jobQuery;
    }        

    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }

    private String getParameterizedQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        
        if (String.isNotBlank(getBranchCode())){
            Date branchDate = fsCore.SpectraCoreUtil.getBusinessDate(getBranchCode());
            branchDate = (branchDate == null) ? System.today() : branchDate;
            
            jobQuery.addWhereConditionWithValue(7,'fsServ__Payment_Date__c ', '<=', branchDate);
            jobQuery.addWhereConditionWithValue(8,'fsServ__Branch_Code__c', '=', getBranchCode());
            jobQuery.setWhereConditionCriteria('1 AND (2 OR 3) AND ( (4 AND 5) OR ( 6 ) ) AND 7 AND 8 ');
        }
  
        return jobQuery.getQueryString();
    }
    
    global override String getClassName(){
        return CLASS_NAME;
    }

    global override void startJob(Database.BatchableContext pContext){}

    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        fsCore.Logger.logMessage('Executing Job ' + CLASS_NAME + '...');
        fsCore.Logger.logMessage('Scope Count : ' + pScope.size());

        if (pScope.size() == 0){ return null; }

        Set<Id> paymentIdBatch = new Set<Id>();
        for (fsServ__Inbound_Payment__c pmt : (List<fsServ__Inbound_Payment__c>) pScope){
            paymentIdBatch.add(pmt.Id);
        }
        
        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        actionIP.addRecords(paymentIdBatch);

        fsServ.InboundPaymentProcessor inPmtAction = new fsServ.InboundPaymentProcessor();
        inPmtAction.setInput(actionIP);
        inPmtAction.process();
            
        fsCore.ActionOutput actionOP = inPmtAction.getOutput();        
        return actionOP.getErrors();
    }

    global override void finishJob(Database.BatchableContext pContext) {}

}