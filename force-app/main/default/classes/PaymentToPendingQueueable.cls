public class PaymentToPendingQueueable  implements Queueable {
    private Set<Id> mRecordIds;
    public PaymentToPendingQueueable(Set<Id> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }

    public void execute(QueueableContext context) {
        List<nu_dse__Payment__c> payments = [Select Id, nu_dse__Transaction_Status__c from nu_dse__Payment__c where Id = :mRecordIds limit 1];
         if (!payments.isEmpty()) {
            payments[0].nu_dse__Transaction_Status__c = 'Pending';
            update payments[0];
         }
    }
}