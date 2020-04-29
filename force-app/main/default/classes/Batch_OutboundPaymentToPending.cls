public class Batch_OutboundPaymentToPending implements Database.Batchable<sObject>, Database.stateful {
    Set<Id> outboundPaymentIds = new Set<Id>();
    
    public Batch_OutboundPaymentToPending(Set<Id> outboundPaymentIdSet) {
        if (!outboundPaymentIdSet.isEmpty()) {         
            outboundPaymentIds = outboundPaymentIdSet;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, NuPay_Transaction_Status__c FROM fsCore__Outbound_Payment__c WHERE Id IN :outboundPaymentIds');
    }

    public void execute(Database.BatchableContext bc, List<fsCore__Outbound_Payment__c> outboundPayments) {  
        for (fsCore__Outbound_Payment__c outboundPayment: outboundPayments) {
            outboundPayment.NuPay_Transaction_Status__c = 'Pending'; 
        }
        update outboundPayments;
    }

    public void finish(Database.BatchableContext bc){

    }
}