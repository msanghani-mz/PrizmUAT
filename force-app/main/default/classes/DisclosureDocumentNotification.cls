/* 
 * Class   : DisclosureDocumentNotification 
 * Purpose : This class is invoked from Proces Builder on Lending Application
 *           
 * Author  : Financial Spectra
 */
public class DisclosureDocumentNotification {
    
 @InvocableMethod(label='Disclosure Document Notification' description=' Clients will receive disclosure and loan agreement documents via email')
    public static void sendNotification(List<ID> pRecordIds) {
        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        ApplicationNotificationAction action =  new ApplicationNotificationAction();
        actionIP.addRecords(new Set<Id>(pRecordIds));
        action.setInput(actionIP);
        action.setNotificationType(ApplicationNotificationUtil.DISCLOSURE_DOCUMENT_NOTIFICATION);
        action.process();
}
}