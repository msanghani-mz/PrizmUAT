/* 
 * Class   : ApplicationWithdrawnNotification 
 * Purpose : This class is invoked from Proces Builder on Lending Application
 *           
 * Author  : Financial Spectra
 */
public class ApplicationWithdrawnNotification {
    
    @InvocableMethod(label='Application Withdrawn Notification' description=' Clients will receive Withdrawn Notification via email')
    public static void sendNotification(List<ID> pRecordIds) {
        System.debug(loggingLevel.ERROR,'**********************Inside SendNotification*********************');
        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        ApplicationNotificationAction action =  new ApplicationNotificationAction();
        actionIP.addRecords(new Set<Id>(pRecordIds));
        action.setInput(actionIP);
        action.setNotificationType(ApplicationNotificationUtil.APPLICATION_WITHDRAWN_NOTIFICATION);
        action.process();
        System.debug(loggingLevel.Error,'Errors:-----'+action.getOutput().getErrors());
    }
}