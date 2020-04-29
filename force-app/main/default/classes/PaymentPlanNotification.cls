/* 
 * Class   : PaymentPlanNotification
 * Purpose : This class is invoked from Proces Builder on Contract Direct Debit object
 *           when the direct debit record is created for Payment Plan
 * Author  : Financial Spectra
 */
public class PaymentPlanNotification {
    
    @InvocableMethod(label='Payment Plan Notification'description='Sends the notification to contract customers when the direct debit record is created for Payment Plan')
    public static void sendNotification(List<ID> pRecordIds) {
        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        actionIP.addRecords(new Set<Id>(pRecordIds));
        ContractNotificationAction action = new ContractNotificationAction();
        action.setInput(actionIP);
        action.setNotificationType(ContractNotificationUtil.PAYMENT_PLAN_SETUP);
        action.process();
    }
}