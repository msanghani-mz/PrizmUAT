/*
* Class   : ApplicationNotificationUtil
* Purpose : Utility methods related to lending Application notification processing
* Author  : Financial Spectra
*/
public class ApplicationNotificationUtil {
    
    public static final String ADVERSE_ACTION_NOTICE        = 'Adverse Action Notice';
    public static final String CHECKLIST_DOCUMENT_REJECTION = 'Checklist Document Rejection';
    // public static final String VCL_CHECKLIST_DOCUMENT_REJECTION = 'VCL Checklist Document Rejection';
    public static final String LOAN_PROCESSING_LETTER       = 'Loan Processing Letter';
    public static final String DOCUMENT_SUBMISSION_NOI      = 'NOI : Document Submission';
    public static final String PRE_TILA_NOI                 = 'NOI : Pre-TILA';
    public static final String WELCOME_LETTER               = 'Welcome Letter';
    public Static final String DISCLOSURE_DOCUMENT_NOTIFICATION    = 'Disclosure Document Notification';
    public Static final String APPLICATION_WITHDRAWN_NOTIFICATION  = 'Application Withdrawn Notification';
    public static final String VCL_EXTRA_ADDRESS_PROOF_NOTIFICATION  = 'VCL Request for address proof';
    public static final String VCL_WELCOME_LETTER  = 'VCL Welcome Letter';
    public static final String VCL_BANK_ACCOUNT_REMINDER  = 'VCL Bank Account Reminder';
    public static final String VCL_USER_REGISTRATION_REMINDER  = 'VCL User Registration Reminder';
    
    /*
* Method to check whether the notification type is supported or not
*/
    public static Boolean isNotificationTypeSupported(String pNotificationType){
        return (String.IsNotBlank(pNotificationType) && getSupportedNotificationTypes().contains(pNotificationType));
    }
    
    private static Set<String> getSupportedNotificationTypes(){
        Set<String> supportedNotificationTypes = new Set<String>();
        supportedNotificationTypes.add(ADVERSE_ACTION_NOTICE);
        supportedNotificationTypes.add(CHECKLIST_DOCUMENT_REJECTION);
        //  supportedNotificationTypes.add(VCL_CHECKLIST_DOCUMENT_REJECTION);
        supportedNotificationTypes.add(LOAN_PROCESSING_LETTER);
        supportedNotificationTypes.add(DOCUMENT_SUBMISSION_NOI);
        supportedNotificationTypes.add(PRE_TILA_NOI);
        supportedNotificationTypes.add(WELCOME_LETTER);
        supportedNotificationTypes.add(DISCLOSURE_DOCUMENT_NOTIFICATION);
        supportedNotificationTypes.add(APPLICATION_WITHDRAWN_NOTIFICATION);
        supportedNotificationTypes.add(VCL_EXTRA_ADDRESS_PROOF_NOTIFICATION);
        supportedNotificationTypes.add(VCL_WELCOME_LETTER);
        supportedNotificationTypes.add(VCL_BANK_ACCOUNT_REMINDER);
        supportedNotificationTypes.add(VCL_USER_REGISTRATION_REMINDER);        
        
        return supportedNotificationTypes;
    }
    
    /*
* Method to get the lending application map as per the notification type
* Different fields are required for different notification types
*/
    public static Map<Id, fsCore__Lending_Application__c> getApplicationForNotificationType(Set<Id> pApplicationIds, String pNotificationType){
        fsCore.DynamicQueryBuilder applicationQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
            .addField('Id')
            .addField('Name')
            .addField('Loan_Officer__c')
            .addField('Loan_Type__c')
            .addField('RecordType.DeveloperName')
            .addWhereConditionWithBind(1,'Id','IN','pApplicationIds');
        
        if (pNotificationType == ADVERSE_ACTION_NOTICE){
            applicationQuery.addField('Rejection_Cause__c');
            applicationQuery.addField('Credit_Bureau_Used__c');
            applicationQuery.addField('External_Rejection_Reasons__c');
            applicationQuery.addField('AAN_Sent_Date__c');
            applicationQuery.addField('Rejection_Causes__c');
            applicationQuery.addWhereConditionWithValue(2, 'RecordType.DeveloperName', '!=', fsCore.Constants.RECORD_TYPE_INACTIVE);
            applicationQuery.addWhereConditionWithValue(3, 'fsCore__Application_Status__c', '=', 'Declined');
            //applicationQuery.addWhereConditionWithValue(4, 'Rejection_Cause__c', '!=', null);
        }
        else if(pNotificationType == LOAN_PROCESSING_LETTER){
            applicationQuery.addField('Is_Loan_Processing_Letter_Sent__c');
            applicationQuery.addField('Loan_Processing_Letter_Sent_Date__c');
            applicationQuery.addWhereConditionWithValue(2, 'RecordType.DeveloperName', '!=', fsCore.Constants.RECORD_TYPE_INACTIVE);
            applicationQuery.addWhereConditionWithValue(3, 'Is_Loan_Processing_Letter_Sent__c', '=', false);
        }
        else if (pNotificationType == CHECKLIST_DOCUMENT_REJECTION){
            applicationQuery.addField('Is_Document_Rejection_Email_Sent__c');
            applicationQuery.addField('Last_Document_Rejection_Email_Sent_On__c');
            applicationQuery.addField('FsCore__Record_Type_Formula__c');
            applicationQuery.addWhereConditionWithValue(2, 'RecordType.DeveloperName', '!=', fsCore.Constants.RECORD_TYPE_INACTIVE);
            applicationQuery.addWhereConditionWithValue(3, 'Number_Of_Checklist_Documents_Rejected__c', '>', 0);
            applicationQuery.addWhereConditionWithValue(4, 'Is_Document_Rejection_Email_Sent__c', '=', false);
        }
        /*    else if (pNotificationType == VCL_CHECKLIST_DOCUMENT_REJECTION){
applicationQuery.addField('Is_Document_Rejection_Email_Sent__c');
applicationQuery.addField('Last_Document_Rejection_Email_Sent_On__c');
applicationQuery.addWhereConditionWithValue(2, 'RecordType.DeveloperName', '!=', fsCore.Constants.RECORD_TYPE_INACTIVE);
applicationQuery.addWhereConditionWithValue(3, 'Number_Of_Checklist_Documents_Rejected__c', '>', 0);
applicationQuery.addWhereConditionWithValue(4, 'Is_Document_Rejection_Email_Sent__c', '=', false);
}
*/
        else if(pNotificationType == DOCUMENT_SUBMISSION_NOI){
            applicationQuery.addField('Document_Submission_Due_Date__c');
            applicationQuery.addField('Document_NOI_Sent_Date__c');
            applicationQuery.addWhereConditionWithValue(2, 'RecordType.DeveloperName', '!=', fsCore.Constants.RECORD_TYPE_INACTIVE);
            applicationQuery.addWhereConditionWithValue(3, 'Pending_Document_Checklist_Count__c', '>', 0);
            applicationQuery.addWhereConditionWithValue(4, 'Document_Submission_Due_Date__c', '<=', System.today());
        }
        else if(pNotificationType == PRE_TILA_NOI){
            applicationQuery.addField('Pre_TILA_Sent_Date__c');
            applicationQuery.addField('Pre_TILA_Sign_Due_Date__c');
            applicationQuery.addField('Pre_Tila_NOI_Sent_Date__c');
            applicationQuery.addWhereConditionWithValue(2, 'RecordType.DeveloperName', '!=', fsCore.Constants.RECORD_TYPE_INACTIVE);
            applicationQuery.addWhereConditionWithValue(3, 'Pre_TILA_Sent_Date__c', '!=', null);
            applicationQuery.addWhereConditionWithValue(4, 'Pre_TILA_Sign_Due_Date__c', '<=', System.today());
            applicationQuery.addWhereConditionWithValue(5, 'Is_PreTILA_Signed__c', '=', false);
        }
        else if(pNotificationType == WELCOME_LETTER){
            applicationQuery.addField('Welcome_Letter_Sent_Date__c');
            applicationQuery.addWhereConditionWithValue(2, 'RecordType.DeveloperName', '=', fsCore.Constants.RECORD_TYPE_INACTIVE);
            applicationQuery.addWhereConditionWithValue(3, 'fsCore__Is_Funded__c', '=', true);
            applicationQuery.addWhereConditionWithValue(4, 'fsServ__Is_Contracted__c', '=', true);
            applicationQuery.addWhereConditionWithValue(5, 'Welcome_Letter_Sent_Date__c', '=', null);
        }
        else if (pNotificationType == DISCLOSURE_DOCUMENT_NOTIFICATION)  {
            applicationQuery.addField('Is_PreTILA_Signed__c');
            applicationQuery.addField('Is_Disclosure_Document_Sent__c');
            applicationQuery.addField('Current_Stage_Code_Formula__c');
            applicationQuery.addWhereConditionWithValue(2, 'Is_PreTILA_Signed__c', '=', true);
            applicationQuery.addWhereConditionWithValue(3, 'Is_Disclosure_Document_Sent__c', '=', false);
            applicationQuery.addWhereConditionWithValue(4, 'Current_Stage_Code_Formula__c', '=','PL_PRE_SCREEN');
        } 
        else if (pNotificationType == APPLICATION_WITHDRAWN_NOTIFICATION)  {
            applicationQuery.addField('fsCore__Application_Status__c');
            applicationQuery.addField('fsCore__Is_Application_Read_Only__c');
            //applicationQuery.addWhereConditionWithValue(2,'RecordType.DeveloperName','=','Read_Only');
            applicationQuery.addWhereConditionWithValue(2, 'fsCore__Application_Status__c', '=', 'Withdrawn');
            applicationQuery.addWhereConditionWithValue(3, 'fsCore__Is_Application_Read_Only__c', '=',true);
        } else if (pNotificationType == VCL_EXTRA_ADDRESS_PROOF_NOTIFICATION)  {
            //TODO
            //MOST LIKELY NOTHING
        }else if (pNotificationType == VCL_USER_REGISTRATION_REMINDER)  {
            applicationQuery.addField('Welcome_Letter_Sent_Date__c');
            applicationQuery.addField('VCL_User_Registration_Reminder_Sent__c');
            applicationQuery.addWhereConditionWithValue(2, 'Welcome_Letter_Sent_Date__c', '!=', null);
            //applicationQuery.addWhereConditionWithValue(3,'RecordType.DeveloperName','!=','Read_Only');
            applicationQuery.addWhereConditionWithValue(3, 'fsCore__Is_Application_Read_Only__c', '=',false);
            applicationQuery.addWhereConditionWithValue(4, 'Loan_Type__c', '=', 'VCL');       
          //  applicationQuery.addWhereConditionWithValue(5, 'Account_Registered__c', '=',false);
            
        }
        else if (pNotificationType == VCL_WELCOME_LETTER)  {
            applicationQuery.addField('Welcome_Letter_Sent_Date__c');
            applicationQuery.addWhereConditionWithValue(2, 'Welcome_Letter_Sent_Date__c', '=', null);
            applicationQuery.addWhereConditionWithValue(3, 'Loan_Type__c', '=', 'VCL');       
            applicationQuery.addWhereConditionWithValue(4, 'fsCore__Accepted_Pricing_Offer_Number__c', '!=',null);   
            
            
        }else if (pNotificationType == VCL_BANK_ACCOUNT_REMINDER)  {
            //TODO
            //applicationQuery.addWhereConditionWithValue(2,'RecordType.DeveloperName','=','Read_Only');
            applicationQuery.addWhereConditionWithValue(2, 'fsCore__Is_Application_Read_Only__c', '=',true);   
        }          
        
        
        system.debug(logginglevel.error,'**** applicationQuery.getQueryString() *** '+applicationQuery.getQueryString());
        Map<Id, fsCore__Lending_Application__c> applicationMap = new Map<Id, fsCore__Lending_Application__c>
            ((List<fsCore__Lending_Application__c>)Database.query(applicationQuery.getQueryString()));
        
        return applicationMap;
    }
    
    /*
* Method to get the lending application recipient emails map as per the notification type
* and the record type of the lending application
*/
    public class ReceipientsClass{
        Id recipientContactID;
        String recipientType;
        String recipientFullName;
        String residencyStatus;
    }
    
    private static Map<Id, Set<ReceipientsClass>> getApplicationRecipientsMap(Map<Id, fsCore__Lending_Application__c> pApplicationMap){
        Map<Id, Set<ReceipientsClass>> applicationRecipientsMap = new Map<Id, Set<ReceipientsClass>>();
        
        List<fsCore__Lending_application_Customer__c> applicants = 
            [SELECT Id, fsCore__Lending_application_Number__c
             , fsCore__Lending_application_Number__r.RecordType.DeveloperName
             , fsCore__Lending_application_Number__r.fsCore__Original_Record_Type_ID__c
             , fsCore__Lending_application_Number__r.fsCore__Is_Application_Read_Only__c
             , fsCore__Account_Name__c
             , fsCore__Account_Name__r.PersonContactId
             , fsCore__Account_Name__r.PersonEmail
             , fsCore__Account_Name__r.FirstName 
             , fsCore__Account_Name__r.LastName
             , fsCore__Account_Name__r.U_S_Residency_Status__c
             , fsCore__Contact_Name__c
             , fsCore__Contact_Name__r.Email
             , fsCore__Customer_Type__c
             FROM fsCore__Lending_application_Customer__c
             WHERE fsCore__Lending_application_Number__c IN :pApplicationMap.keySet()
             AND fsCore__Customer_Type__c IN ('Primary','Secondary')
             ORDER BY fsCore__Lending_application_Number__c, fsCore__Customer_Type__c];
        
        for (fsCore__Lending_application_Customer__c applicant : applicants){
            Set<ReceipientsClass> recipients = new Set<ReceipientsClass>();
            
            if (applicationRecipientsMap.containsKey(applicant.fsCore__Lending_application_Number__c)){
                recipients = applicationRecipientsMap.get(applicant.fsCore__Lending_application_Number__c);
            }
            
            String previousRecordTypeDevName = 'None';
            
            system.debug('**** fsCore__Original_Record_Type_ID__c *** '+applicant.fsCore__Lending_application_Number__r.fsCore__Original_Record_Type_ID__c);
            if (applicant.fsCore__Lending_application_Number__r.fsCore__Original_Record_Type_ID__c != null){
                previousRecordTypeDevName = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosById().get(applicant.fsCore__Lending_application_Number__r.fsCore__Original_Record_Type_ID__c).getDeveloperName();
            }
            system.debug('**** previousRecordTypeDevName *** '+previousRecordTypeDevName);
            system.debug('**** CurrentRecordTypeDevName *** '+applicant.fsCore__Lending_application_Number__r.RecordType.DeveloperName);
            
            //set recipients for DNL Loans as the Person Email of the Account
            if ((applicant.fsCore__Lending_application_Number__r.RecordType.DeveloperName == 'DNL_Loan')||(applicant.fsCore__Lending_application_Number__r.RecordType.DeveloperName == 'VCL_Loan')
                ||((applicant.fsCore__Lending_application_Number__r.fsCore__Is_Application_Read_Only__c)
                   && (previousRecordTypeDevName ==  'DNL_Loan'))){ //FOR DNL ADVERSE ACTION THE DEVLOPER NAME IS READONLY ALREADY
                       
                       if (applicant.fsCore__Account_Name__r.PersonEmail != null){
                           ReceipientsClass rec = new ReceipientsClass();
                           rec.recipientContactID = applicant.fsCore__Account_Name__r.PersonContactId;
                           rec.recipientType = applicant.fsCore__Customer_Type__c;
                           rec.residencyStatus = applicant.fsCore__Account_Name__r.U_S_Residency_Status__c;
                           rec.recipientFullName = applicant.fsCore__Account_Name__r.FirstName + ' ' + applicant.fsCore__Account_Name__r.LastName;
                           recipients.add(rec);
                       }
                   }
            
            if (recipients.size() > 0){
                applicationRecipientsMap.put(applicant.fsCore__Lending_application_Number__c, recipients);
            }
        }
        
        return applicationRecipientsMap;
    }    
    
    /*
* Method to get email notification records for the notification type
*/
    public static List<Email_Notification_Log__c> getEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, String pNotificationType){
        Map<Id, Set<ReceipientsClass>> applicationRecipientsMap = getApplicationRecipientsMap(pApplicationMap);
        System.debug(loggingLevel.ERROR, '-- application recipients size : ' + applicationRecipientsMap.size());
        
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        if (pNotificationType == ADVERSE_ACTION_NOTICE){
            newEmailNotifications = getAdverseActionEmailNotifications(pApplicationMap, applicationRecipientsMap);
        } 
        else if (pNotificationType == LOAN_PROCESSING_LETTER){
            newEmailNotifications = getLoanProcessingEmailNotifications(pApplicationMap, applicationRecipientsMap);
        }
        else if (pNotificationType == CHECKLIST_DOCUMENT_REJECTION){
            newEmailNotifications = getDocumentRejectionEmailNotifications(pApplicationMap, applicationRecipientsMap);
        }
        /*    else if (pNotificationType == VCL_CHECKLIST_DOCUMENT_REJECTION){
newEmailNotifications = getVCLDocumentRejectionEmailNotifications(pApplicationMap, applicationRecipientsMap);
}
*/
        else if (pNotificationType == DOCUMENT_SUBMISSION_NOI){
            newEmailNotifications = getDocumentSubmissionNOIEmailNotifications(pApplicationMap, applicationRecipientsMap);
        }
        else if (pNotificationType == PRE_TILA_NOI){
            newEmailNotifications = getPreTILANOIEmailNotifications(pApplicationMap, applicationRecipientsMap);
        }
        else if (pNotificationType == WELCOME_LETTER){
            newEmailNotifications = getWelcomeEmailNotifications(pApplicationMap, applicationRecipientsMap);
        }
        else if (pNotificationType == DISCLOSURE_DOCUMENT_NOTIFICATION){
            newEmailNotifications = getDisclosureDocumentEmailNotifications(pApplicationMap, applicationRecipientsMap);
        }
        else if (pNotificationType == APPLICATION_WITHDRAWN_NOTIFICATION){
            newEmailNotifications = getApplicationWithdrawnEmailNotifications(pApplicationMap, applicationRecipientsMap);
        }else if (pNotificationType == VCL_EXTRA_ADDRESS_PROOF_NOTIFICATION){
            newEmailNotifications = getVclRequestAddressProofNotifications(pApplicationMap, applicationRecipientsMap);
        }else if (pNotificationType == VCL_WELCOME_LETTER){
            newEmailNotifications = getVclWelcomeLetterNotifications(pApplicationMap, applicationRecipientsMap);
        }else if (pNotificationType == VCL_BANK_ACCOUNT_REMINDER){
            newEmailNotifications = getBankAccountReminderNotifications(pApplicationMap, applicationRecipientsMap);
        }
        
        return newEmailNotifications;
    }
    
    private static void setRecipients(Email_Notification_Log__c pNewEmail, List<ReceipientsClass> pRecipients){
        for (Integer i = 0; i < pRecipients.size(); i++){
            if (i == 0) { 
                pNewEmail.Recipient_Contact_Name_1__c = pRecipients[i].recipientContactID;
            } else if (i == 1) { 
                pNewEmail.Recipient_Contact_Name_2__c = pRecipients[i].recipientContactID;
            } else if (i == 2) {
                pNewEmail.Recipient_Contact_Name_3__c = pRecipients[i].recipientContactID;
            }
        }
    }
    
    /*
* Method to get email notification records for the notification type ADVERSE_ACTION_NOTICE
*/
    private static List<Email_Notification_Log__c> getAdverseActionEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (fsCore__Lending_Application__c application : pApplicationMap.values()){
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(application.Id));
            if (recipients.size() == 0){ continue; }
            if (String.IsBlank(application.External_Rejection_Reasons__c)){ continue; }


            if (String.IsBlank(application.Rejection_Causes__c))
            { 
                System.debug(loggingLevel.ERROR, '-- Rejection_Causes__c IS NULL, CANNOT SEND AAN' );
                continue; 
            }
            
            

            if (String.IsBlank(application.External_Rejection_Reasons__c)){ continue; }
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id,Loan_Officer__c = application.Loan_Officer__c, Notification_Type__c = ADVERSE_ACTION_NOTICE);
            
            setRecipients(newEmail, recipients);
            
            //Placeholder #1 --- decline reasons
            List<String> externalReasons = application.External_Rejection_Reasons__c.split(';');
            newEmail.Placeholder_1__c = '<ul>';
            for(String reason : externalReasons){
                newEmail.Placeholder_1__c += ('<li>' + reason + '</li>');
            }
            newEmail.Placeholder_1__c += '</ul>';
            
            //Placeholder #2 --- decline cause dependent text
            if (application.Rejection_Cause__c == 'Credit Report'){
                newEmail.Placeholder_2__c = '<p>' + Label.Adverse_Action_Due_To_Credit_Report + '</p>';
                newEmail.Placeholder_2__c += '<br>';
                if (application.Credit_Bureau_Used__c == 'Equifax'){
                    newEmail.Placeholder_2__c += ('<strong>'  + Label.Equifax_Details.replace('\n','<br>') + '</strong>');
                    newEmail.Placeholder_2__c += ('<br>' + Label.Equifax_Web_Address);
                } else {
                    newEmail.Placeholder_2__c += ('<strong>'  + Label.TransUnion_Details.replace('\n','<br>') + '</strong>');
                    newEmail.Placeholder_2__c += ('<br>' + Label.TransUnion_Web_Address);
                }
            } 
            else if (application.Rejection_Cause__c == 'Non-Sufficient Funds'){
                newEmail.Placeholder_2__c = '<p>' + Label.Adverse_Action_Due_To_NSF.replace('\n','<br>') + '</p>';
            } 
            else {
                newEmail.Placeholder_2__c = '';
            }
            
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }
    
    /*
* Method to get email notification records for the notification type LOAN_PROCESSING_LETTER
*/
    private static List<Email_Notification_Log__c> getLoanProcessingEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        Map<Id, List<fsCore__Financial__c>> recipientFinancialMap = getRecipientFinancialMap(pApplicationRecipientsMap);
        Map<String, fsCore__Lookup_Value__c> IncomeDocumentsMap = getLoanProcessingIncomeDocuments();
        
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            String emailPlaceHolder;
            String IdPlaceHolder;
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            if (recipients.size() == 0){ 
                continue; 
            }
            else if (recipients.size() == 1){
                List<fsCore__Financial__c> financialList = recipientFinancialMap.get(recipients.get(0).recipientContactID);
                
                if (String.IsNotBlank(recipients.get(0).residencyStatus)){
                    if ('Permanent Resident Alien'.equalsIgnoreCase(recipients.get(0).residencyStatus)){
                        IdPlaceHolder = getEmailPlaceHolder(IdPlaceHolder,String.format(IncomeDocumentsMap.get('GREEN_CARD').Income_Document__c,new String[] {''}));
                    }
                }
                
                for (fsCore__Financial__c financial : financialList){
                    if (financial.fsCore__Financial_Type__c == 'Salary'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SALARY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                        if ((financial.Employment_Name__r.fsCore__Start_Date__c != null) &&
                            ( financial.Employment_Name__r.fsCore__Start_Date__c > (date.today().addDays(-60)))){
                                emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SALARY_60').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                            }
                    }else if (financial.fsCore__Financial_Type__c == 'Independent Contractor'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('INDEPENDENT_CONTRACTOR').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                    }else if (financial.fsCore__Financial_Type__c == 'Other'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('OTHER').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                    }else if (financial.fsCore__Financial_Type__c == 'Rental'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('RENTAL').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                    }else if (financial.fsCore__Financial_Type__c == 'Social Security'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SOCIAL_SECURITY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                    }else if (financial.fsCore__Financial_Type__c == 'Child Support'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('CHILD_SUPPORT').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                    }else if (financial.fsCore__Financial_Type__c == 'Self-employed'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SELF-EMPLOYED').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                    }else if (financial.fsCore__Financial_Type__c == 'Alimony'){
                        emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('ALIMONY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                    }else if ((financial.fsCore__Financial_Type__c == 'Disability')
                              || (financial.fsCore__Financial_Type__c == 'VA Disability')){ //PDI-1029
                                  emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('DISABILITY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                              }else if (financial.fsCore__Financial_Type__c == 'Pension'){
                                  emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('PENSION').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),''}));
                              } 
                    System.debug(loggingLevel.ERROR,emailPlaceHolder);
                } 
            }
            else { //CASES WITH MORE THAN 1 RECEIPENT
                for (ReceipientsClass receip : recipients){
                    
                    if (String.IsNotBlank(receip.residencyStatus)){
                        if ('Permanent Resident Alien'.equalsIgnoreCase(receip.residencyStatus)){
                            IdPlaceHolder = getEmailPlaceHolder(IdPlaceHolder,String.format(IncomeDocumentsMap.get('GREEN_CARD').Income_Document__c,new String[] {' for '+receip.recipientFullName}));
                        }
                    }                    
                    List<fsCore__Financial__c> financialList = recipientFinancialMap.get(receip.recipientContactID);
                    for (fsCore__Financial__c financial : financialList){
                        if (financial.fsCore__Financial_Type__c == 'Salary'){
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SALARY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                            if ((financial.Employment_Name__r.fsCore__Start_Date__c != null) &&
                                ( financial.Employment_Name__r.fsCore__Start_Date__c > (date.today().addDays(-60)))){
                                    emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SALARY_60').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                                }
                        }else if (financial.fsCore__Financial_Type__c == 'Independent Contractor'){
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('INDEPENDENT_CONTRACTOR').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                        }else if (financial.fsCore__Financial_Type__c == 'Other'){
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('OTHER').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                        }else if (financial.fsCore__Financial_Type__c == 'Rental'){
                            system.debug(logginglevel.error,'IncomeDocumentsMap :'+IncomeDocumentsMap);
                            system.debug(logginglevel.error,'receip :'+receip);
                            system.debug(logginglevel.error,'financial :'+financial);
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('RENTAL').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                        }else if (financial.fsCore__Financial_Type__c == 'Social Security'){
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SOCIAL_SECURITY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                        }else if (financial.fsCore__Financial_Type__c == 'Child Support'){
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('CHILD_SUPPORT').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                        }else if (financial.fsCore__Financial_Type__c == 'Self-employed'){
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('SELF-EMPLOYED').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                        }else if (financial.fsCore__Financial_Type__c == 'Alimony'){
                            emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('ALIMONY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                        }else if ((financial.fsCore__Financial_Type__c == 'Disability')
                                  || (financial.fsCore__Financial_Type__c == 'VA Disability')){//PDI-1029
                                      emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('DISABILITY').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                                  }else if (financial.fsCore__Financial_Type__c == 'Pension'){
                                      emailPlaceHolder = getEmailPlaceHolder(emailPlaceHolder,String.format(IncomeDocumentsMap.get('PENSION').Income_Document__c,new String[] {String.ValueOf(financial.fsCore__Stated_Amount__c),' for '+receip.recipientFullName}));
                                  }  
                    } 
                    System.debug(loggingLevel.ERROR,emailPlaceHolder);
                }
            }
            
            if (emailPlaceHolder  == null){ continue; }
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Loan_Officer__c = application.Loan_Officer__c, Notification_Type__c = LOAN_PROCESSING_LETTER);
            
            setRecipients(newEmail, recipients);
            emailPlaceHolder = emailPlaceHolder.replace('<ul>','');
            emailPlaceHolder = emailPlaceHolder.replace('</ul>','');
            system.debug(logginglevel.error,'emailPlaceHolder :>'+emailPlaceHolder);
            newEmail.Placeholder_1__c = emailPlaceHolder; //THIS IS TO REMOVE LINE BREAKS
            if (IdPlaceHolder != null){
                string htmlStrStart = '<ul><li><p><strong>Proof of US Residency Status.</strong> For proof of current US Residency status please forward the following.</p><ul>';
                string htmlStrEnd = '</ul></li></ul>';
                IdPlaceHolder = htmlStrStart+IdPlaceHolder+htmlStrEnd;
                system.debug(logginglevel.error,' IdPlaceHolder :'+IdPlaceHolder);
                newEmail.Placeholder_2__c = IdPlaceHolder;
            }
            
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }   
    
    private static string getEmailPlaceHolder(String emailPlaceHolder, String pText){
        if (String.isBlank(emailPlaceHolder)){
            emailPlaceHolder = pText;
        } else {
            emailPlaceHolder += pText;
        }
        return emailPlaceHolder;
    }
    
    private static Map<String,fsCore__Lookup_Value__c> getLoanProcessingIncomeDocuments(){
        Map<String, fsCore__Lookup_Value__c> IncomeDocumentsMap = new Map<String, fsCore__Lookup_Value__c>();        
        
        List<fsCore__Lookup_Value__c> IncomeDocumentsList = [SELECT Id, Name
                                                             , fsCore__Lookup_Name__c
                                                             , fsCore__Default_Product_Availability__c
                                                             , fsCore__Is_Active__c
                                                             , Income_Document__c
                                                             FROM fsCore__Lookup_Value__c
                                                             WHERE fsCore__Is_Active__c = true
                                                             AND RecordType.DeveloperName = 'Income_Document_Type'
                                                             ORDER BY fsCore__Lookup_Name__c ASC];
        
        for (fsCore__Lookup_Value__c incomeDoc : IncomeDocumentsList){
            IncomeDocumentsMap.put(incomeDoc.Name,incomeDoc);
        }
        return IncomeDocumentsMap;
    }
    
    private static Map<Id, List<fsCore__Financial__c>> getRecipientFinancialMap(Map<Id, Set<ReceipientsClass>> pReceipentMap){
        Map<Id, Set<ReceipientsClass>> applicationRecipientsMap = new Map<Id, Set<ReceipientsClass>>();
        Map<Id, List<fsCore__Financial__c>> applicantToFinancialMap = new Map<Id, List<fsCore__Financial__c>>();
        
        Set<Id> contactIds = new Set<Id>();
        for (Id appId : pReceipentMap.keySet()){
            for (ReceipientsClass receipent : pReceipentMap.get(appId)){
                contactIds.add(receipent.recipientContactID);
                system.debug('selected contacts'+contactIds);
                applicantToFinancialMap.put(receipent.recipientContactID, new List<fsCore__Financial__c>());
            }
        }  
        
        List<fsCore__Financial__c> financialList = [SELECT Id, fsCore__Contact_Name__c
                                                    , fsCore__Financial_Type__c 
                                                    , fsCore__Stated_Amount__c
                                                    , Employment_Name__r.fsCore__Start_Date__c
                                                    FROM fsCore__Financial__c 
                                                    WHERE fsCore__Financial_Family__c = 'Income'
                                                    AND fsCore__Contact_Name__c IN :contactIds];
        
        for (fsCore__Financial__c fin : financialList){
            if (applicantToFinancialMap.containsKey(fin.fsCore__Contact_Name__c)){
                applicantToFinancialMap.get(fin.fsCore__Contact_Name__c).add(fin);
            }       
        }
        
        return applicantToFinancialMap;
    }    
    
    /*
* Method to get email notification records for the notification type CHECKLIST_DOCUMENT_REJECTION
*/
    private static List<Email_Notification_Log__c> getDocumentRejectionEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
          System.debug(LoggingLevel.ERROR , 'Inside method');
        Map<Id, List<fsCore__Lending_Application_Checklist__c>> rejectedDocumentsMap = getRejectedChecklistDocuments(pApplicationMap.keySet());
        
        for (Id applicationId : rejectedDocumentsMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            List<fsCore__Lending_Application_Checklist__c> rejectedDocuments = rejectedDocumentsMap.get(applicationId);
            
            if (recipients.size() == 0){ continue; }
            if (rejectedDocuments.size() == 0){ continue; }
            
            //PDI-244 SFS REQUESTED THAT THE CO-APPLICANT AND THE APPLICANT NAME NEEDS TO BE POPULATED IN THE EMAIL.
            String primaryCustomerName; 
            String secondaryCustomerName;
            for(ReceipientsClass customer:recipients){
                if (customer.recipientType == 'Primary'){
                    primaryCustomerName = customer.recipientFullName;
                }else{
                    secondaryCustomerName = customer.recipientFullName;
                }
                
            }
            Email_Notification_Log__c newEmail;
            if(application.fsCore__Record_Type_Formula__c == 'DNL_Loan'){
                System.debug(LoggingLevel.ERROR , 'DNL email');
               
                 newEmail = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Loan_Officer__c = application.Loan_Officer__c,Notification_Type__c = CHECKLIST_DOCUMENT_REJECTION);
                
            }
            if(application.fsCore__Record_Type_Formula__c == 'VCL_Loan'){
                System.debug(LoggingLevel.ERROR , 'VCL email');
                
                 newEmail = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Loan_Officer__c = application.Loan_Officer__c,Notification_Type__c = 'VCL Checklist Document Rejection');
               
            }
            
            setRecipients(newEmail, recipients);
            
            newEmail.Placeholder_1__c = '<ul>';
            for(fsCore__Lending_Application_Checklist__c doc : rejectedDocuments){
                if (doc.fsCore__Status__c == 'Rejected'){
                    
                    //PDI-244 SFS REQUESTED THAT THE CO-APPLICANT AND THE APPLICANT NAME NEEDS TO BE POPULATED IN THE EMAIL.
                    String checklistItem = doc.fsCore__Checklist_Item__c;
                    if ((checklistItem.contains('Co-Applicant'))
                        ||(checklistItem.contains('CoApplicant'))){
                            checklistItem = checklistItem.replace('Co-Applicant', secondaryCustomerName);
                            
                            //REPLACING IT AGAIN, JUST IN CASE IF THE CoApplicant IS WITHOUT THE '-'
                            checklistItem = checklistItem.replace('CoApplicant', secondaryCustomerName);
                            
                        }else{
                            checklistItem = checklistItem.replace('Applicant', primaryCustomerName);                        
                        }
                    if (doc.Rejection_Reason__c == 'Other'){
                        newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - '+doc.Rejection_Reason_Others__c + '</li>');
                    }else{
                        newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - '+doc.Rejection_Reason__c + '</li>');
                    }
                }
            }
            newEmail.Placeholder_1__c += '</ul>';
            
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }
    /*    private static List<Email_Notification_Log__c> getVCLDocumentRejectionEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();

Map<Id, List<fsCore__Lending_Application_Checklist__c>> rejectedDocumentsMap = getRejectedChecklistDocuments(pApplicationMap.keySet());

for (Id applicationId : rejectedDocumentsMap.keySet()){
fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
List<fsCore__Lending_Application_Checklist__c> rejectedDocuments = rejectedDocumentsMap.get(applicationId);

if (recipients.size() == 0){ continue; }
if (rejectedDocuments.size() == 0){ continue; }

//PDI-244 SFS REQUESTED THAT THE CO-APPLICANT AND THE APPLICANT NAME NEEDS TO BE POPULATED IN THE EMAIL.
String primaryCustomerName; 
String secondaryCustomerName;
for(ReceipientsClass customer:recipients){
if (customer.recipientType == 'Primary'){
primaryCustomerName = customer.recipientFullName;
}else{
secondaryCustomerName = customer.recipientFullName;
}

}


Email_Notification_Log__c newEmail 
= new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Loan_Officer__c = application.Loan_Officer__c,Notification_Type__c = VCL_CHECKLIST_DOCUMENT_REJECTION);

setRecipients(newEmail, recipients);

newEmail.Placeholder_1__c = '<ul>';
for(fsCore__Lending_Application_Checklist__c doc : rejectedDocuments){
if (doc.fsCore__Status__c == 'Rejected'){

//PDI-244 SFS REQUESTED THAT THE CO-APPLICANT AND THE APPLICANT NAME NEEDS TO BE POPULATED IN THE EMAIL.
String checklistItem = doc.fsCore__Checklist_Item__c;
if ((checklistItem.contains('Co-Applicant'))
||(checklistItem.contains('CoApplicant'))){
checklistItem = checklistItem.replace('Co-Applicant', secondaryCustomerName);

//REPLACING IT AGAIN, JUST IN CASE IF THE CoApplicant IS WITHOUT THE '-'
checklistItem = checklistItem.replace('CoApplicant', secondaryCustomerName);

}else{
checklistItem = checklistItem.replace('Applicant', primaryCustomerName);                        
}
if (doc.Rejection_Reason__c == 'Other'){
newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - '+doc.Rejection_Reason_Others__c + '</li>');
}else{
newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - '+doc.Rejection_Reason__c + '</li>');
}
}
}
newEmail.Placeholder_1__c += '</ul>';

newEmailNotifications.add(newEmail);
}

return newEmailNotifications;
}
*/   
    private static Map<Id, List<fsCore__Lending_Application_Checklist__c>> getRejectedChecklistDocuments(Set<Id> pApplicationIdSet){
        List<fsCore__Lending_Application_Checklist__c> rejectedChkDocuments 
            = [SELECT Id, Name, fsCore__Lending_Application_Number__c
               , fsCore__Checklist_Name_Formula__c
               , fsCore__Checklist_Item__c
               , Rejection_Reason__c
               , Rejection_Reason_Others__c
               , fsCore__Status__c
               , fsCore__Document_Classification__c
               FROM fsCore__Lending_Application_Checklist__c
               WHERE fsCore__Lending_Application_Number__c IN :pApplicationIdSet
               AND fsCore__Checklist_Item_Type__c = 'Document'
               AND fsCore__Status__c = 'Rejected'
               ORDER BY fsCore__Lending_Application_Number__c, fsCore__Checklist_Item__c];
        
        Map<Id, List<fsCore__Lending_Application_Checklist__c>> rejectedChkDocumentsMap
            = new Map<Id, List<fsCore__Lending_Application_Checklist__c>>();
        
        for (fsCore__Lending_Application_Checklist__c chkDoc : rejectedChkDocuments){
            List<fsCore__Lending_Application_Checklist__c> appRejectedChkDocs = new List<fsCore__Lending_Application_Checklist__c>();
            
            if (rejectedChkDocumentsMap.containsKey(chkDoc.fsCore__Lending_Application_Number__c)){
                appRejectedChkDocs = rejectedChkDocumentsMap.get(chkDoc.fsCore__Lending_Application_Number__c);
            }
            
            appRejectedChkDocs.add(chkDoc);
            rejectedChkDocumentsMap.put(chkDoc.fsCore__Lending_Application_Number__c , appRejectedChkDocs);
        }
        
        return rejectedChkDocumentsMap;
    }
    
    /*
* Method to get email notification records for the notification type DOCUMENT_SUBMISSION_NOI
*/
    private static List<Email_Notification_Log__c> getDocumentSubmissionNOIEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        Map<Id, List<fsCore__Lending_Application_Checklist__c>> pendingDocumentsMap = getPendingChecklistDocuments(pApplicationMap.keySet());
        
        for (Id applicationId : pendingDocumentsMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            List<fsCore__Lending_Application_Checklist__c> pendingDocuments = pendingDocumentsMap.get(applicationId);
            
            if (recipients.size() == 0){ continue; }
            if (pendingDocuments.size() == 0){ continue; }
            
            //PDI-244 SFS REQUESTED THAT THE CO-APPLICANT AND THE APPLICANT NAME NEEDS TO BE POPULATED IN THE EMAIL.
            String primaryCustomerName; 
            String secondaryCustomerName;
            for(ReceipientsClass customer:recipients){
                if (customer.recipientType == 'Primary'){
                    primaryCustomerName = customer.recipientFullName;
                }else{
                    secondaryCustomerName = customer.recipientFullName;
                }
                
            }            
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id,Loan_Officer__c = application.Loan_Officer__c, Notification_Type__c = DOCUMENT_SUBMISSION_NOI);
            
            setRecipients(newEmail, recipients);
            
            newEmail.Placeholder_1__c = '<ul>';
            for(fsCore__Lending_Application_Checklist__c doc : pendingDocuments){
                
                //PDI-244 SFS REQUESTED THAT THE CO-APPLICANT AND THE APPLICANT NAME NEEDS TO BE POPULATED IN THE EMAIL.
                String checklistItem = doc.fsCore__Checklist_Item__c;
                if ((checklistItem.contains('Co-Applicant'))
                    ||(checklistItem.contains('CoApplicant'))){
                        checklistItem = checklistItem.replace('Co-Applicant', secondaryCustomerName);
                        
                        //REPLACING IT AGAIN, JUST IN CASE IF THE CoApplicant IS WITHOUT THE '-'
                        checklistItem = checklistItem.replace('CoApplicant', secondaryCustomerName);
                        
                    }else{
                        checklistItem = checklistItem.replace('Applicant', primaryCustomerName);                        
                    }
                
                if (doc.fsCore__Status__c == 'Rejected'){
                    //newEmail.Placeholder_1__c += ('<li>' + checklistItem +' - '+doc.Rejection_Reason__c + '</li>');
                    
                    if (doc.Rejection_Reason__c == 'Other'){
                        newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - '+doc.Rejection_Reason_Others__c + '</li>');
                    }else{
                        newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - '+doc.Rejection_Reason__c + '</li>');
                    }
                    
                }else if   (doc.fsCore__Status__c == 'Pending'){
                    newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - Not Received </li>');
                }else if   (doc.fsCore__Status__c == 'Uploaded'){
                    newEmail.Placeholder_1__c += ('<li>' + checklistItem + ' - Pending Review </li>');
                }
                
            }
            newEmail.Placeholder_1__c += '</ul>';
            
            
            String noticeDueDate = fsCore.TypeUtil.getFormattedDate(application.Document_Submission_Due_Date__c.addDays(15) , 'EEEE, MMMM dd, yyyy');
            newEmail.Placeholder_2__c = '<span>' + noticeDueDate + '</span>';
            
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }
    
    private static Map<Id, List<fsCore__Lending_Application_Checklist__c>> getPendingChecklistDocuments(Set<Id> pApplicationIdSet){
        List<fsCore__Lending_Application_Checklist__c> pendingDocuments 
            = [SELECT Id, Name, fsCore__Lending_Application_Number__c
               , fsCore__Checklist_Name_Formula__c
               , fsCore__Checklist_Item__c
               , fsCore__Status__c
               , Rejection_Reason__c
               , Rejection_Reason_Others__c
               , fsCore__Document_Classification__c
               FROM fsCore__Lending_Application_Checklist__c
               WHERE fsCore__Lending_Application_Number__c IN :pApplicationIdSet
               AND fsCore__Checklist_Item_Type__c = 'Document'
               AND fsCore__Status__c IN ('Rejected','Pending','Uploaded')
               ORDER BY fsCore__Lending_Application_Number__c, fsCore__Checklist_Item__c];
        
        Map<Id, List<fsCore__Lending_Application_Checklist__c>> pendingDocumentsMap
            = new Map<Id, List<fsCore__Lending_Application_Checklist__c>>();
        
        for (fsCore__Lending_Application_Checklist__c chkDoc : pendingDocuments){
            List<fsCore__Lending_Application_Checklist__c> appPendingDocs = new List<fsCore__Lending_Application_Checklist__c>();
            
            if (pendingDocumentsMap.containsKey(chkDoc.fsCore__Lending_Application_Number__c)){
                appPendingDocs = pendingDocumentsMap.get(chkDoc.fsCore__Lending_Application_Number__c);
            }
            
            appPendingDocs.add(chkDoc);
            pendingDocumentsMap.put(chkDoc.fsCore__Lending_Application_Number__c , appPendingDocs);
        }
        
        return pendingDocumentsMap;
    }
    
    /*
* Method to get email notification records for the notification type PRE_TILA_NOI
*/
    private static List<Email_Notification_Log__c> getPreTILANOIEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            
            if (recipients.size() == 0){ continue; }
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id,Loan_Officer__c = application.Loan_Officer__c, Notification_Type__c = PRE_TILA_NOI);
            
            setRecipients(newEmail, recipients);
            String noticeDueDate = fsCore.TypeUtil.getFormattedDate(application.Pre_TILA_Sign_Due_Date__c.addDays(7) , 'EEEE, MMMM dd, yyyy');
            newEmail.Placeholder_1__c = '<span>' + noticeDueDate + '</span>';
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }
    
    /*
* Method to get email notification records for the notification type WELCOME_LETTER
*/
    private static List<Email_Notification_Log__c> getWelcomeEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            
            if (recipients.size() == 0){ continue; }
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id,Loan_Officer__c = application.Loan_Officer__c, Notification_Type__c = WELCOME_LETTER);
            
            setRecipients(newEmail, recipients);
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }
    /*
* Method to get email notification records for the notification type DISCLOSURE_DOCUMENT_NOTIFICATION
*/
    private static List<Email_Notification_Log__c> getDisclosureDocumentEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            if (recipients.size() == 0){ continue; }
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Notification_Type__c = DISCLOSURE_DOCUMENT_NOTIFICATION);
            setRecipients(newEmail, recipients);
            newEmailNotifications.add(newEmail);
        }
        return newEmailNotifications;
    }
    /*
* Method to get email notification records for the notification type APPLICATION_WITHDRAWN_NOTIFICATION
*/
    private static List<Email_Notification_Log__c> getApplicationWithdrawnEmailNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            if (recipients.size() == 0){ continue; }
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Notification_Type__c = APPLICATION_WITHDRAWN_NOTIFICATION);
            setRecipients(newEmail, recipients);
            newEmailNotifications.add(newEmail);
        }
        return newEmailNotifications;
    }
    private static List<Email_Notification_Log__c> getVclRequestAddressProofNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            
            if (recipients.size() == 0){ continue; }
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Notification_Type__c = VCL_EXTRA_ADDRESS_PROOF_NOTIFICATION);
            
            setRecipients(newEmail, recipients);
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }  
    private static List<Email_Notification_Log__c> getVclWelcomeLetterNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            
            if (recipients.size() == 0){ continue; }
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Notification_Type__c = VCL_WELCOME_LETTER);
            
            setRecipients(newEmail, recipients);
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }
    private static List<Email_Notification_Log__c> getBankAccountReminderNotifications(Map<Id, fsCore__Lending_Application__c> pApplicationMap, Map<Id, Set<ReceipientsClass>> pApplicationRecipientsMap){
        List<Email_Notification_Log__c> newEmailNotifications = new List<Email_Notification_Log__c>();
        
        for (Id applicationId : pApplicationMap.keySet()){
            fsCore__Lending_Application__c application = pApplicationMap.get(applicationId);
            List<ReceipientsClass> recipients = new List<ReceipientsClass>(pApplicationRecipientsMap.get(applicationId));
            
            if (recipients.size() == 0){ continue; }
            
            Email_Notification_Log__c newEmail 
                = new Email_Notification_Log__c(Lending_Application_Number__c = application.Id, Notification_Type__c = VCL_BANK_ACCOUNT_REMINDER);
            
            //newEmail.Placeholder_1__c = 'On '+<!BAVInitiationDate>+' we initiated a small deposit to your bank account on file '+(<!BankAccountName>);
            
            setRecipients(newEmail, recipients);
            newEmailNotifications.add(newEmail);
        }
        
        return newEmailNotifications;
    }      
}