/*
 * Class   : ApplicationNotificationAction
 * Purpose : Action class to create notification records for Lending Applications
 * Author  : Financial Spectra
 */
global virtual class ApplicationNotificationAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private String mNotificationType;
    
    private Map<Id, fsCore__Lending_Application__c> mApplicationMap;
        
    global class ApplicationNotificationException extends Exception{}
    
    global ApplicationNotificationAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
    }

    global void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }

    global void setApplicationMap(Map<Id, fsCore__Lending_Application__c> pApplicationMap){
        mApplicationMap = pApplicationMap;
    }

    global void setNotificationType(String pNotificationType){
        mNotificationType = pNotificationType;
    }

    global void process(){
        System.debug(loggingLevel.ERROR, '-- Start processing ... ' + system.now());
        if (String.IsBlank(mNotificationType)){
            throw new ApplicationNotificationException('Notification Type is blank');
        }
        if (!ApplicationNotificationUtil.isNotificationTypeSupported(mNotificationType)){
            throw new ApplicationNotificationException('Notification Type ' + mNotificationType + ' is not supported');
        }
        
        if (mApplicationMap.size() == 0){
            mApplicationMap = ApplicationNotificationUtil.getApplicationForNotificationType(mActionInput.getRecords(), mNotificationType);
        }
        System.debug(loggingLevel.ERROR, '-- application map size ... ' + mApplicationMap.size());
        System.debug(loggingLevel.ERROR, '-- application map size ... ' + mApplicationMap);
        
        List<Email_Notification_Log__c> emailNotificationsForInsert
            = ApplicationNotificationUtil.getEmailNotifications(mApplicationMap, mNotificationType);
        
        System.debug(loggingLevel.ERROR, '-- email notifications for insert size ... ' + emailNotificationsForInsert.size());    
        
        List<fsCore__Lending_Application__c> applicationForUpdate = new List<fsCore__Lending_Application__c>();
        
        for (Email_Notification_Log__c emailNotif : emailNotificationsForInsert){
            if (emailNotif.Lending_Application_Number__c != null){
                fsCore__Lending_Application__c application = mApplicationMap.get(emailNotif.Lending_Application_Number__c);
                if (application.Loan_Type__c == 'DNL'){
                    if (mNotificationType == ApplicationNotificationUtil.CHECKLIST_DOCUMENT_REJECTION){
                        application.Is_Document_Rejection_Email_Sent__c = true;
                        application.Last_Document_Rejection_Email_Sent_On__c = System.now();
                    } 
                    else if(mNotificationType == ApplicationNotificationUtil.LOAN_PROCESSING_LETTER){
                        application.Is_Loan_Processing_Letter_Sent__c = true;
                        application.Loan_Processing_Letter_Sent_Date__c = System.now();
                        application.Document_Submission_Due_Date__c = application.Loan_Processing_Letter_Sent_Date__c.date().addDays(15);
                    }
                    else if(mNotificationType == ApplicationNotificationUtil.DOCUMENT_SUBMISSION_NOI){
                        application.Document_Submission_Due_Date__c = fsCore.Constants.END_DATE;
                        application.Document_NOI_Sent_Date__c = Date.today();
                    }
                    else if(mNotificationType == ApplicationNotificationUtil.PRE_TILA_NOI){
                        application.Pre_TILA_Sign_Due_Date__c = fsCore.Constants.END_DATE;
                        application.Pre_Tila_NOI_Sent_Date__c = Date.today();
                    }
                    else if(mNotificationType == ApplicationNotificationUtil.WELCOME_LETTER){
                        application.Welcome_Letter_Sent_Date__c = System.today();
                    }else if(mNotificationType == ApplicationNotificationUtil.ADVERSE_ACTION_NOTICE){
                        if (application.AAN_Sent_Date__c == null){
                            application.AAN_Sent_Date__c = System.today();
                        }
                    }

                }
                if (application.Loan_Type__c == 'VCL'){
                    if (mNotificationType == ApplicationNotificationUtil.CHECKLIST_DOCUMENT_REJECTION){
                        application.Is_Document_Rejection_Email_Sent__c = true;
                        application.Last_Document_Rejection_Email_Sent_On__c = System.now();
                    } 
                }
                applicationForUpdate.add(application);
            }
        }
        
        //perform DMLs
        if (emailNotificationsForInsert.size() > 0) { Database.insert(emailNotificationsForInsert); }
        if (applicationForUpdate.size() > 0) { Database.update(applicationForUpdate); }
        
        mActionOutput.setIsSuccess(true);
        System.debug(loggingLevel.ERROR, '-- Finish processing ... ' + system.now());
    }

    global fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
}