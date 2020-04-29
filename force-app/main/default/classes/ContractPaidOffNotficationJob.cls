/**
* Class Name  : ContractPaidOffNotficationJob (DV-141)
* Description : This batch job will send out the email notification
*               once the loan is paid off
* Author      : Financial Spectra
*
*/
global with sharing class ContractPaidOffNotficationJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'ContractPaidOffNotficationJob';
    
    global ContractPaidOffNotficationJob(){
        setJobQuery(getDefaultQuery());
    }
    
    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Lending_Contract__c.getName())
            .addField('Id')
            .addField('Name')
            .addField('RecordType.DeveloperName')
            .addField('fsServ__Paid_in_Full_Date__c')
            .addField('Is_Paid_Off_Notification_Sent__c')         
            .addField('Paid_Off_Notification_Sent_Date__c')         
            .addField('fsServ__Total_Outstanding_Amount__c') 
            .addWhereConditionWithValue(1, 'Is_Paid_Off_Notification_Sent__c', '=',false)
            .addWhereConditionWithValue(2, 'fsServ__Paid_in_Full_Date__c', '!=',null)
            .addWhereConditionWithValue(3, 'fsServ__Total_Outstanding_Amount__c', '<=', 0);
        System.debug(loggingLevel.ERROR,'jobQuery getQuery:---'+jobQuery.getQueryString());
        return jobQuery;

    }        
    
    
    
    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }
    
    global override void setParameterizedJobQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        setJobQuery(jobQuery.getQueryString());
    }
    
    global override String getClassName(){
        return CLASS_NAME;
    }
    
    global override void startJob(Database.BatchableContext pContext){ 
        System.debug(loggingLevel.ERROR,'Start Method:---');
    }
    
    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug(loggingLevel.error, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.error, 'Scope Count : ' + pScope.size());
        try{
            if (pScope.size() == 0){ return null; }
            
            Set<Id> contractIds = new Set<Id>();
            for (fsServ__Lending_Contract__c contract : (List<fsServ__Lending_Contract__c>)pScope){
                contractIds.add(contract.Id);
            }
            
            fsCore.ActionInput acInput = new fsCore.ActionInput();
            acInput.addRecords(contractIds);
            
            ContractNotificationAction notifyAction = new ContractNotificationAction();
            notifyAction.setInput(acInput);
            notifyAction.setNotificationType(ContractNotificationUtil.PAID_OFF_NOTIFICATION);
            notifyAction.process();            
            
            
        }catch(Exception e)  {
            system.debug(logginglevel.error,' EXCEPTION ****   '+e.getStackTraceString() +e);
            Throw e;
        }
        
        return new List<fsCore.ErrorObject>();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}
    
    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Contract_PaidOff_Notfication_Job');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    
    
}