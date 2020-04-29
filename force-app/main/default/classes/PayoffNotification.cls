/* 
 * Class   : PayoffNotification
 * Purpose : This class is invoked from Proces Builder on Contract Direct Debit object
 *           when the direct debit record is created for Loan Payoff
 * Author  : Financial Spectra
 */
public class PayoffNotification {

    @InvocableMethod(label='Payoff Notification' description='Sends the notification to contract customers when the direct debit record is created for Loan Payoff')
    public static void sendNotification(List<ID> pRecordIds) {
        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        actionIP.addRecords(new Set<Id>(pRecordIds));
        ContractNotificationAction action = new ContractNotificationAction();
        action.setInput(actionIP);
        action.setNotificationType(ContractNotificationUtil.PAYOFF_NOTIFICATION);
        action.process();
    }

}