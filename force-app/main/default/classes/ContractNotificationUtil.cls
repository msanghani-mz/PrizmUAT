/*
* Class   : ContractNotificationUtil
* Purpose : Utility methods related to lending Contract notification processing
* Author  : Financial Spectra
*/
public with sharing class ContractNotificationUtil {    
    
    public static final String PAYMENT_DUE_REMINDER  = 'Payment Due Reminder'; 
    public static final String PAYMENT_SUCCESS       = 'Payment Success'; 
    public static final String PAYMENT_FAILURE       = 'Payment Failure'; 
    public static final String PAYMENT_PLAN_SETUP    = 'Payment Plan Setup';
    public static final String PAYOFF_NOTIFICATION   = 'Payoff Notification';
    public static final String PAID_OFF_NOTIFICATION   = 'Paid Off Notification';
    
    /*
* Method to check whether the notification type is supported or not
*/
    public static Boolean isNotificationTypeSupported(String pNotificationType){
        return (String.IsNotBlank(pNotificationType) && getSupportedNotificationTypes().contains(pNotificationType));
    }    
    private static Set<String> getSupportedNotificationTypes(){
        Set<String> supportedNotificationTypes = new Set<String>();
        supportedNotificationTypes.add(PAYMENT_DUE_REMINDER);
        supportedNotificationTypes.add(PAYMENT_SUCCESS);
        supportedNotificationTypes.add(PAYMENT_FAILURE);
        supportedNotificationTypes.add(PAYMENT_PLAN_SETUP);
        supportedNotificationTypes.add(PAYOFF_NOTIFICATION);
        supportedNotificationTypes.add(PAID_OFF_NOTIFICATION);
        return supportedNotificationTypes;
    }
    
    /*
* Method to get the list of Email Notification Log records populated with the required details 
* for the input set of records and notification type
*/
    public static List<fsCore.ErrorObject> sendEmailNotifications(Set<Id> pRecordIds, String pNotificationType){
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        if (pNotificationType == PAYMENT_DUE_REMINDER) {
            errors = sendDueReminderEmailNotifications(pRecordIds);
        }
        else if (pNotificationType == PAYMENT_SUCCESS) {
            errors = sendPaymentSuccessEmailNotifications(pRecordIds);
        }
        else if (pNotificationType == PAYMENT_FAILURE) {
            errors = sendPaymentFailureEmailNotifications(pRecordIds);
        }
        else if (pNotificationType == PAYMENT_PLAN_SETUP) {
            errors = sendPaymentPlanEmailNotifications(pRecordIds);
        }
        else if (pNotificationType == PAYOFF_NOTIFICATION)  {
            errors = sendPayoffEmailNotifications(pRecordIds);
        } 
        else if (pNotificationType == PAID_OFF_NOTIFICATION)  {
            errors = sendPaidOffEmailNotifications(pRecordIds);
        } 
        return errors;
    }
    
    private static List<fsCore.ErrorObject> sendDueReminderEmailNotifications(Set<Id> pRecordIds){
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        List<fsServ__Contract_Due__c> contractDueList = [SELECT Id,fsServ__Lending_Contract_Number__c
                                                         ,fsServ__Due_Date__c
                                                         ,fsServ__Due_Amount__c
                                                         ,Is_Due_Reminder_Email_Sent__c
                                                         ,fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name
                                                         FROM fsServ__Contract_Due__c
                                                         WHERE Id IN: pRecordIds];
        
        Set<Id> lendingContractIdSet = new Set<Id>();
        for (fsServ__Contract_Due__c contractDue : contractDueList){
            lendingContractIdSet.add(contractDue.fsServ__Lending_Contract_Number__c);
        }
        system.debug(logginglevel.error,'lendingContractIdSet :'+lendingContractIdSet);
        List<fsServ__Contract_Direct_Debit__c> contractDDs = [SELECT Id, fsServ__Lending_Contract_Number__c
                                                              , fsServ__Customer_Reference_Number__c 
                                                              , fsServ__Bank_Account_Name__r.fsCore__Bank_Name__c 
                                                              , fsServ__Bank_Account_Name__r.fsCore__Bank_Account_Number__c 
                                                              , fsServ__Debit_Amount__c
                                                              , fsServ__Debit_Start_Date__c
                                                              , fsServ__Debit_End_Date__c
                                                              , fsServ__Next_Debit_Date__c
                                                              FROM fsServ__Contract_Direct_Debit__c
                                                              WHERE fsServ__Lending_Contract_Number__c IN :lendingContractIdSet
                                                              AND fsServ__Direct_Debit_Type__c = :fsCore.Constants.DIRECT_DEBIT_TYPE_RECURRING
                                                              AND fsServ__Customer_Reference_Number__c != null
                                                              AND fsServ__Bank_Account_Name__c != null
                                                              AND fsServ__Is_Active__c = true
                                                              ORDER BY fsServ__Lending_Contract_Number__c, fsServ__Debit_Amount__c];
        
        Map<Id, List<fsServ__Contract_Direct_Debit__c>> contractDDMap = new Map<Id, List<fsServ__Contract_Direct_Debit__c>>();
        system.debug(logginglevel.error,'contractDDs :'+contractDDs.size());
        for(fsServ__Contract_Direct_Debit__c dd : contractDDs){
            system.debug(logginglevel.error,'dd :'+dd);
            List<fsServ__Contract_Direct_Debit__c> directDebits = new List<fsServ__Contract_Direct_Debit__c>();
            if (contractDDMap.containsKey(dd.fsServ__Lending_Contract_Number__c)){
                directDebits = contractDDMap.get(dd.fsServ__Lending_Contract_Number__c);
            }
            directDebits.add(dd);
            contractDDMap.put(dd.fsServ__Lending_Contract_Number__c, directDebits);
        }
        
        Map<Id, List<fsServ__Contract_Customer__c>> contractIdToCustomerMap =  getCustomersForContractIds(lendingContractIdSet);
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (fsServ__Contract_Due__c contractDue : contractDueList){
            system.debug(logginglevel.error,'contractDue :'+contractDue);
            if(contractIdToCustomerMap.containsKey(contractDue.fsServ__Lending_Contract_Number__c)){
                
                Map<Id, fsServ__Contract_Customer__c> customerMap = new Map<Id, fsServ__Contract_Customer__c>(contractIdToCustomerMap.get(contractDue.fsServ__Lending_Contract_Number__c));
                Email_Notification_Log__c newEmail  = new Email_Notification_Log__c(Lending_Contract_Number__c=contractDue.fsServ__Lending_Contract_Number__c, Notification_Type__c=PAYMENT_DUE_REMINDER);
                setRecipients(newEmail, customerMap.values());
                
                //subject
                newEmail.Subject__c = String.format(Label.Payment_Due_Reminder_Subject, new String[]{contractDue.fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name});
                
                //Placeholder #1 -- Payment Due Details
                
                if (contractDDMap.containsKey(contractDue.fsServ__Lending_Contract_Number__c)){
                    fsServ__Contract_Direct_Debit__c relatedDD;
                    
                    for (fsServ__Contract_Direct_Debit__c contractDD : contractDDMap.get(contractDue.fsServ__Lending_Contract_Number__c)){
                        system.debug(logginglevel.error,'contractDD :'+contractDD);
                        if (contractDue.fsServ__Due_Date__c >= contractDD.fsServ__Debit_Start_Date__c 
                            && (contractDD.fsServ__Debit_End_Date__c == null || (contractDD.fsServ__Debit_End_Date__c != null && contractDue.fsServ__Due_Date__c <= contractDD.fsServ__Debit_End_Date__c))
                            && customerMap.containsKey(contractDD.fsServ__Customer_Reference_Number__c)){
                                relatedDD = contractDD;
                                break;
                            }
                    }
                    system.debug(logginglevel.error,'relatedDD :'+relatedDD);
                    if (relatedDD != null){
                        String paymentAmount =  String.valueOf(relatedDD.fsServ__Debit_Amount__c);
                        String bankName = relatedDD.fsServ__Bank_Account_Name__r.fsCore__Bank_Name__c;
                        String bankAccountNumber = relatedDD.fsServ__Bank_Account_Name__r.fsCore__Bank_Account_Number__c.right(4); //last 4 digits of bank account
                        String dueDate = fsCore.TypeUtil.getFormattedDate(relatedDD.fsServ__Next_Debit_Date__c, 'EEEE, MMMM dd, yyyy');
                        newEmail.Placeholder_1__c = '<P>'+String.format(Label.Payment_Due_Reminder_Text, new String[]{paymentAmount, bankName, bankAccountNumber, dueDate})+'</P>';
                    }
                }
                
                newEmailNotifications.add(newEmail);
                contractDue.Is_Due_Reminder_Email_Sent__c = true;
            }
        }
        
        errors = saveNotifications(newEmailNotifications);
        fsServ.ContractDueDMLWrapper.getInstance().updateData(contractDueList);
        return errors;
    }
    
    private static List<fsCore.ErrorObject> sendPaymentSuccessEmailNotifications(Set<Id> pRecordIds){
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList = 
            [SELECT Id,fsServ__Lending_Contract_Number__c
             ,fsServ__Payment_Amount__c
             ,fsServ__Payment_Date__c 
             ,fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name
             ,fsServ__Lending_Contract_Number__r.fsServ__Next_Payment_Due_Amount__c                                                                      
             ,fsServ__Lending_Contract_Number__r.fsServ__Next_Payment_Due_Date__c
             ,fsServ__Lending_Contract_Number__r.fsServ__Outstanding_Principal_Amount__c
             ,Is_Success_Notification_Sent__c 
             FROM fsServ__Inbound_Payment__c
             WHERE id IN: pRecordIds
             AND fsServ__Payment_Status__c = 'Processed'
             AND fsServ__Is_Processed__c = true
             AND Is_Success_Notification_Sent__c = false];                                                                           
        
        Set<Id> lendingContractIdSet = new Set<Id>();
        for (fsServ__Inbound_Payment__c conInboundPayment : inboundPaymentList){
            lendingContractIdSet.add(conInboundPayment.fsServ__Lending_Contract_Number__c);
        }   
        
        Map<Id, List<fsServ__Contract_Customer__c>> contractIdToCustomerMap =  getCustomersForContractIds(lendingContractIdSet);
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (fsServ__Inbound_Payment__c payment : inboundPaymentList){
            If(contractIdToCustomerMap.containsKey(payment.fsServ__Lending_Contract_Number__c)){
                List<fsServ__Contract_Customer__c> customerList = contractIdToCustomerMap.get(payment.fsServ__Lending_Contract_Number__c);
                Email_Notification_Log__c newEmail  = new Email_Notification_Log__c(Lending_Contract_Number__c=payment.fsServ__Lending_Contract_Number__c, Notification_Type__c=PAYMENT_SUCCESS);
                setRecipients(newEmail, customerList);
                
                //Subject
                String companyName = payment.fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name;
                newEmail.Subject__c = String.format(Label.Payment_Success_Email_Subject, new String[]{companyName});
                
                //Placeholder #1 -- Payment Amount
                //newEmail.Placeholder_1__c = '<span>' + String.valueOf(payment.fsServ__Payment_Amount__c) + '</span>'; Commented DV-148
                
                //DV-148 
                String paymentDateString = fsCore.TypeUtil.getFormattedDate(payment.fsServ__Payment_Date__c, 'MMM dd, yyyy');
                String nextDueDateString = fsCore.TypeUtil.getFormattedDate(payment.fsServ__Lending_Contract_Number__r.fsServ__Next_Payment_Due_Date__c, 'MMM dd, yyyy');
                newEmail.Placeholder_1__c = 'A payment of $'+String.valueOf(payment.fsServ__Payment_Amount__c)+' was received and applied to your Versara Lending account on '+paymentDateString+'.';
                newEmail.Placeholder_2__c = 'The outstanding principal balance on your loan is $'+payment.fsServ__Lending_Contract_Number__r.fsServ__Outstanding_Principal_Amount__c+'. Outstanding balance represents the principal balance still owed on your loan. This is not the amount required to pay the loan in full.';
                newEmail.Placeholder_3__c = 'Your next scheduled payment is on '+nextDueDateString+'.';
                
                
                newEmailNotifications.add(newEmail);
                payment.Is_Success_Notification_Sent__c = true;
            }
        }
        
        errors = saveNotifications(newEmailNotifications);
        fsServ.InboundPaymentDMLWrapper.getInstance().updateData(inboundPaymentList);
        return errors;
    } 
    
    private static List<fsCore.ErrorObject> sendPaymentFailureEmailNotifications(Set<Id> pRecordIds){
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList = 
            [SELECT Id,fsServ__Lending_Contract_Number__c
             ,fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name
             ,fsServ__Bank_Account_Name__r.fsCore__Bank_Name__c
             ,fsServ__Bank_Account_Name__r.fsCore__Bank_Account_Number__c
             ,fsServ__Payment_Amount__c
             ,fsServ__Payment_Date__c
             ,Rejection_Reason__c
             ,Is_Reject_Notification_Sent__c 
             FROM fsServ__Inbound_Payment__c
             WHERE id IN: pRecordIds
             AND fsServ__Payment_Status__c = 'Reversed'
             AND fsServ__Is_Processed__c = true
             AND Is_Reject_Notification_Sent__c = false];
        
        Set<Id> lendingContractIdSet = new Set<Id>();
        
        for (fsServ__Inbound_Payment__c payment : inboundPaymentList){
            lendingContractIdSet.add(payment.fsServ__Lending_Contract_Number__c);
        }
        
        Map<Id, List<fsServ__Contract_Customer__c>> contractIdToCustomerMap =  getCustomersForContractIds(lendingContractIdSet);
        
        
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (fsServ__Inbound_Payment__c payment : inboundPaymentList){
            If(contractIdToCustomerMap.containsKey(payment.fsServ__Lending_Contract_Number__c)){
                List<fsServ__Contract_Customer__c> customerList = contractIdToCustomerMap.get(payment.fsServ__Lending_Contract_Number__c);
                Email_Notification_Log__c newEmail  = new Email_Notification_Log__c(Lending_Contract_Number__c = payment.fsServ__Lending_Contract_Number__c, Notification_Type__c=PAYMENT_FAILURE);
                setRecipients(newEmail, customerList);
                
                //Subject
                String companyName = payment.fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name;
                newEmail.Subject__c = String.format(Label.Payment_Failure_Subject, new String[]{companyName});
                
                //Placeholder #1 -- Payment Amount
                newEmail.Placeholder_1__c = '<span>' + String.valueOf(payment.fsServ__Payment_Amount__c) + '</span>';
                newEmail.Lending_Contract_Number__c = payment.fsServ__Lending_Contract_Number__c;
                newEmailNotifications.add(newEmail);
                payment.Is_Reject_Notification_Sent__c = true;
            }
        }
        
        errors = saveNotifications(newEmailNotifications);
        fsServ.InboundPaymentDMLWrapper.getInstance().updateData(inboundPaymentList);
        return errors;
    }    
    
    private static List<fsCore.ErrorObject> sendPayoffEmailNotifications(Set<Id> pRecordIds){
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        
        
        List<fsServ__Contract_Direct_Debit__c> contractDirectDebitList = 
            [SELECT Id,fsServ__Lending_Contract_Number__c 
             ,fsServ__Debit_Amount__c
             ,fsServ__Next_Debit_Date__c
             ,fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name                                                                      
             FROM fsServ__Contract_Direct_Debit__c
             WHERE Id IN: pRecordIds
             AND fsServ__Payoff_Quote_Number__c != null
             AND fsServ__Direct_Debit_Type__c = 'One-Time'];
        
        
        Set<Id> lendingContractIdSet = new Set<Id>();
        for (fsServ__Contract_Direct_Debit__c conDirectDebit : contractDirectDebitList){
            lendingContractIdSet.add(conDirectDebit.fsServ__Lending_Contract_Number__c);
        }
        
        Map<Id, List<fsServ__Contract_Customer__c>> contractIdToCustomerMap = getCustomersForContractIds(lendingContractIdSet);        
        
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (fsServ__Contract_Direct_Debit__c conDirectDebit : contractDirectDebitList){
            if(contractIdToCustomerMap.containsKey(conDirectDebit.fsServ__Lending_Contract_Number__c)){
                List<fsServ__Contract_Customer__c> customerList = contractIdToCustomerMap.get(conDirectDebit.fsServ__Lending_Contract_Number__c);
                Email_Notification_Log__c newEmail  = new Email_Notification_Log__c(Lending_Contract_Number__c = conDirectDebit.fsServ__Lending_Contract_Number__c, Notification_Type__c=PAYOFF_NOTIFICATION);
                setRecipients(newEmail, customerList);
                //Subject
                String companyName = conDirectDebit.fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name  ;
                newEmail.Subject__c = String.format(Label.Payoff_Reminder_Subject, new String[]{companyName});
                
                //Placeholder #1 -- Payment Amount
                String paymentamount =  String.valueOf(conDirectDebit.fsServ__Debit_Amount__c);
                newEmail.Placeholder_1__c = '<span>' + paymentamount + '</span>';
                
                //Placeholder #2 -- Payment Date
                String paymentDate = fsCore.TypeUtil.getFormattedDate(conDirectDebit.fsServ__Next_Debit_Date__c, 'EEEE, MMMM dd, yyyy');
                newEmail.Placeholder_2__c = '<span>' + paymentDate + '</span>';
                
                newEmailNotifications.add(newEmail);
            }
        }
        
        errors = saveNotifications(newEmailNotifications);
        return errors;
    }    
    
    private static List<fsCore.ErrorObject> sendPaidOffEmailNotifications(Set<Id> pRecordIds){
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        List<fsServ__Lending_Contract__c> lContractList = [select id,
                                                                  name,
                                                                  fsServ__Lending_Application_Number__c,
                                                                  Is_Paid_Off_Notification_Sent__c,
                                                                  Paid_Off_Notification_Sent_Date__c
                                                             from fsServ__Lending_Contract__c WHERE id IN :pRecordIds];
        //Set<Id> lendingContractIdSet = new Set<Id>();
        Map<Id,fsServ__Lending_Contract__c> lContractMap = new Map<Id,fsServ__Lending_Contract__c>();
        for (fsServ__Lending_Contract__c lc : lContractList){
            //lendingContractIdSet.add(lc.Id);
            lContractMap.put(lc.Id,lc);
        }        
        Map<Id, List<fsServ__Contract_Customer__c>> contractIdToCustomerMap =  getCustomersForContractIds(lContractMap.KeySet()); 
        
        for (fsServ__Lending_Contract__c contract : lContractList){
            List<fsServ__Contract_Customer__c> customerList = contractIdToCustomerMap.get(contract.Id);
            Email_Notification_Log__c newEmail  = new Email_Notification_Log__c(Lending_Contract_Number__c = contract.Id, Notification_Type__c=PAID_OFF_NOTIFICATION);
            newEmail.Placeholder_1__c = 'Account Number: '+contract.Name;
            newEmail.Subject__c = 'Completion of Loan Repayment';
            newEmail.Lending_Application_Number__c  = contract.fsServ__Lending_Application_Number__c ;
            setRecipients(newEmail, customerList);
            
            newEmailNotifications.add(newEmail);
        }
        
        errors = saveNotifications(newEmailNotifications,PAID_OFF_NOTIFICATION,lContractMap);
        return errors;
    }        
    
    private static List<fsCore.ErrorObject> sendPaymentPlanEmailNotifications(Set<Id> pRecordIds){
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        
        List<fsServ__Contract_Direct_Debit__c> contractPaymentPlanList = 
            [SELECT Id,fsServ__Lending_Contract_Number__c 
             ,fsServ__Debit_Amount__c
             ,fsServ__Debit_Start_Date__c
             ,fsServ__Number_Of_Payments__c
             ,fsServ__Debit_Day__c
             ,fsServ__Debit_Day_2__c
             ,fsServ__Debit_Cycle__c
             ,fsServ__Lending_Contract_Number__r.fsServ__Company_Name__r.Name                                                                      
             ,fsServ__Lending_Contract_Number__r.fsServ__Next_Payment_Due_Amount__c                                                                      
             ,fsServ__Lending_Contract_Number__r.fsServ__Next_Payment_Due_Date__c                                                                      
             ,fsServ__Lending_Contract_Number__r.fsServ__Delinquent_Days__c                                                                       
             FROM fsServ__Contract_Direct_Debit__c
             WHERE Id IN: pRecordIds
             AND fsServ__Direct_Debit_Type__c = 'Payment Plan'];
        
        Set<Id> lendingContractIdSet = new Set<Id>();
        for (fsServ__Contract_Direct_Debit__c pmtPlan : contractPaymentPlanList){
            lendingContractIdSet.add(pmtPlan.fsServ__Lending_Contract_Number__c);
        }        
        
        Map<Id, List<fsServ__Contract_Customer__c>> contractIdToCustomerMap =  getCustomersForContractIds(lendingContractIdSet);        
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (fsServ__Contract_Direct_Debit__c pmtPlan : contractPaymentPlanList){
            If(contractIdToCustomerMap.containsKey(pmtPlan.fsServ__Lending_Contract_Number__c)){
                List<fsServ__Contract_Customer__c> customerList = contractIdToCustomerMap.get(pmtPlan.fsServ__Lending_Contract_Number__c);
                Email_Notification_Log__c newEmail  = new Email_Notification_Log__c(Lending_Contract_Number__c=pmtPlan.fsServ__Lending_Contract_Number__c, Notification_Type__c=PAYMENT_PLAN_SETUP);
                setRecipients(newEmail, customerList);
                
                //Placeholder #1 -- Payment plan details
                String paymentPlanDetail = '<table style="border: 0px !important;"><tbody>';
                String paymentAmt = String.valueOf(pmtPlan.fsServ__Debit_Amount__c);
                Date paymentDate = pmtPlan.fsServ__Debit_Start_Date__c;
                for(Integer i = 0; i < pmtPlan.fsServ__Number_Of_Payments__c; i++){
                    if (i > 0){
                        paymentDate = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(paymentDate
                                                                                           , (Integer)pmtPlan.fsServ__Debit_Day__c
                                                                                           , (pmtPlan.fsServ__Debit_Day_2__c == null ? 1 : (Integer)pmtPlan.fsServ__Debit_Day_2__c)
                                                                                           , pmtPlan.fsServ__Debit_Cycle__c);
                    }
                    String paymentDateString = fsCore.TypeUtil.getFormattedDate(paymentDate, 'MMM dd, yyyy');
                    paymentPlanDetail += ('<tr><td>' + paymentDateString + '&nbsp;</td><td>$' + paymentAmt + '&nbsp;</td></tr>');
                }
                paymentPlanDetail += '</tbody></table>';
                newEmail.Placeholder_1__c = paymentPlanDetail;
                
                
                //Placeholder #2 -- next payment amount and due date
                String nextPmtAmt = String.valueOf(pmtPlan.fsServ__Lending_Contract_Number__r.fsServ__Next_Payment_Due_Amount__c);
                String nextPmtDate = fsCore.TypeUtil.getFormattedDate(pmtPlan.fsServ__Lending_Contract_Number__r.fsServ__Next_Payment_Due_Date__c, 'EEEE, MMMM dd, yyyy');
                newEmail.Placeholder_2__c = '<span>' + String.format(Label.Payment_Plan_Setup_Text_1, new String[]{nextPmtAmt,nextPmtDate}) + '</span>';
                
                //Placeholder #3 -- delinquent days
                String delinquentDays = String.valueOf(pmtPlan.fsServ__Lending_Contract_Number__r.fsServ__Delinquent_Days__c);
                newEmail.Placeholder_3__c = '<span>' + String.format(Label.Payment_Plan_Setup_Text_2, new String[]{delinquentDays})+ '</span>';
                
                newEmailNotifications.add(newEmail);
            }
        }
        
        errors = saveNotifications(newEmailNotifications);
        return errors;
    }
    
    private static Map<Id, List<fsServ__Contract_Customer__c>> getCustomersForContractIds(Set<Id> pcontractids){
        Map<Id, List<fsServ__Contract_Customer__c>> contractIdToCustomerMap = new Map<Id, List<fsServ__Contract_Customer__c>>();
        List<fsServ__Contract_Customer__c> contractCustomerList =   [SELECT Id,fsServ__Contact_Name__c,fsServ__Lending_Contract_Number__c 
                                                                     FROM fsServ__Contract_Customer__c
                                                                     Where fsServ__Lending_Contract_Number__c IN: pcontractids];        
        for (fsServ__Contract_Customer__c conCustomer : contractCustomerList){
            if(contractIdToCustomerMap.containsKey(conCustomer.fsServ__Lending_Contract_Number__c)) {
                List<fsServ__Contract_Customer__c> customerList = contractIdToCustomerMap.get(conCustomer.fsServ__Lending_Contract_Number__c);
                customerList.add(conCustomer);
                contractIdToCustomerMap.put(conCustomer.fsServ__Lending_Contract_Number__c, customerList);
            } else { 
                contractIdToCustomerMap.put(conCustomer.fsServ__Lending_Contract_Number__c, new List<fsServ__Contract_Customer__c> {conCustomer });
            }
        }        
        return contractIdToCustomerMap;
    }    
    
    private static void setRecipients(Email_Notification_Log__c pNewEmail, List<fsServ__Contract_Customer__c> customerList){
        for (Integer i = 0; i < customerList.size(); i++){
            if (i == 0) { 
                pNewEmail.Recipient_Contact_Name_1__c = customerList[i].fsServ__Contact_Name__c;
            } else if (i == 1) { 
                pNewEmail.Recipient_Contact_Name_2__c = customerList[i].fsServ__Contact_Name__c;
            } else if (i == 2) {
                pNewEmail.Recipient_Contact_Name_3__c = customerList[i].fsServ__Contact_Name__c;
            }
        }
    }
    
    private static List<fsCore.ErrorObject> saveNotifications(List<Email_Notification_Log__c> pNotifications){
        Database.SaveResult[] saveResult = Database.insert(pNotifications);
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        
        for (Integer i = 0; i < saveResult.size() ; i++){
            if (!saveResult.get(i).isSuccess()){
                for (Database.Error dbError : saveResult.get(i).getErrors())
                    errors.add(getErrorObjectInstance(pNotifications.get(i).Lending_Contract_Number__c, dbError.getMessage()));
            }
        }
        return errors;
    }
    
    private static List<fsCore.ErrorObject> saveNotifications(List<Email_Notification_Log__c> pNotifications
                                                             ,String pNotificationType
                                                             ,Map<Id,fsServ__Lending_Contract__c> pContractMap){
        Database.SaveResult[] saveResult = Database.insert(pNotifications);
        
        List<fsServ__Lending_Contract__c> lContractToBeUpdated = new List<fsServ__Lending_Contract__c>();
        
        List<fsCore.ErrorObject> errors = new List<fsCore.ErrorObject>();
        
        for (Integer i = 0; i < saveResult.size() ; i++){
            if (!saveResult.get(i).isSuccess()){
                for (Database.Error dbError : saveResult.get(i).getErrors())
                    errors.add(getErrorObjectInstance(pNotifications.get(i).Lending_Contract_Number__c, dbError.getMessage()));
            }else{
                fsServ__Lending_Contract__c lContract = pContractMap.get(pNotifications.get(i).Lending_Contract_Number__c);
                if (pNotificationType == PAID_OFF_NOTIFICATION)  {
                    lContract.Is_Paid_Off_Notification_Sent__c = true;
                    lContract.Paid_Off_Notification_Sent_Date__c = Date.today();
                }   
                lContractToBeUpdated.add(lContract);
            }
        }
        Database.SaveResult[] updateResult = Database.update(lContractToBeUpdated);
        return errors;
    }

    
    
    private static fsCore.ErrorObject getErrorObjectInstance(Id pContractId, String pErrorMessage){
        fsCore.ErrorObject errObj = new fsCore.ErrorObject();
        errObj.setErrorRecordId(pContractId);
        errObj.setErrorRecordName(String.valueOf(pContractId));
        errObj.setErrorStackTrace('ContractNotificationUtil.saveNotifications()');
        errObj.setErrorCode('PROCESSING_ERROR');
        errObj.setErrorMessage(pErrorMessage);
        return errObj;
    }
}