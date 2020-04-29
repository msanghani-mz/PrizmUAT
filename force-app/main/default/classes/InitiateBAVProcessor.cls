/*
* Class Name   - InitiateBAVProcessor
* Description  - Action class to Initiate BAV process
* Developer(s) - Financial Spectra
*
*/
global with sharing class InitiateBAVProcessor extends fsCore.ApplicationActionProcessorBase{
    private static final String CLASS_NAME = 'InitiateBAVProcessor';
    private List<fsCore__Lending_Application__c> appList = new List<fsCore__Lending_Application__c>();
    private Map<Id,List<fsCore__Lending_Application_Customer__c>> mapApplicationToApplicant = new Map<Id,List<fsCore__Lending_Application_Customer__c>>();
    private Map<Id,String> mapApplicationToAccountNumber = new Map<Id,String>();
    
    global InitiateBAVProcessor(){
        super();
    }
    
    global override void populateAndValidateRelatedData(){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.populateAndValidateRelatedData(+)');
        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            appList.add(application);
        }  
        
        List<fsCore__Lending_Application__c> applications = [Select id ,
                                                             fsCore__Primary_Customer_Contact__r.fsCore__Primary_Bank_Account__r.fsCore__Bank_Account_Number__c
                                                             from fsCore__Lending_Application__c where id in :appList];
        System.debug(applications);
        
        for(fsCore__Lending_Application__c application : applications){
                if(application.fsCore__Primary_Customer_Contact__r.fsCore__Primary_Bank_Account__r.fsCore__Bank_Account_Number__c == null){
                    
                }
                else{
                     mapApplicationToAccountNumber.put(application.id , application.fsCore__Primary_Customer_Contact__r.fsCore__Primary_Bank_Account__r.fsCore__Bank_Account_Number__c);
                }
        }  
               
        List<fsCore__Lending_Application_Customer__c> applicantList = [ Select id , fsCore__Customer_Type__c 
                                                                       , fsCore__Contact_Name__c 
                                                                       , fsCore__Lending_Application_Number__c 
                                                                       from fsCore__Lending_Application_Customer__c 
                                                                       where fsCore__Lending_Application_Number__c in :appList];
       
            
        for(fsCore__Lending_Application_Customer__c applicant : applicantList){
            if(mapApplicationToApplicant.containsKey(applicant.fsCore__Lending_Application_Number__c)){
                List<fsCore__Lending_Application_Customer__c> applicants = mapApplicationToApplicant.get(applicant.fsCore__Lending_Application_Number__c);
                applicants.add(applicant);
                mapApplicationToApplicant.put(applicant.fsCore__Lending_Application_Number__c,applicants);
            }
            else{
                List<fsCore__Lending_Application_Customer__c> applicants = new List<fsCore__Lending_Application_Customer__c>();
                applicants.add(applicant);
                mapApplicationToApplicant.put(applicant.fsCore__Lending_Application_Number__c,applicants);
            }  
        }
       
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.populateAndValidateRelatedData(-)');
    }
    
    global override void doProcess(){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.doProcess(+)');
        List<Application_Bank_Account_Verification__c>  appBAVList = new List<Application_Bank_Account_Verification__c>();
        List<fsCore__Lending_Application__c> updateApplicationList = new List<fsCore__Lending_Application__c>();
        List<Email_Notification_Log__c> emailList = new List<Email_Notification_Log__c>();
        Id recordTypeNewRecordId = SFSUtil.getRecordTypeId('Application_Bank_Account_Verification__c', 'New_Record');
        try{
            for(fsCore__Lending_Application__c app :appList){
                if(app.Underwriting_Status__c == 'Approved'){
                Application_Bank_Account_Verification__c appBAV = new Application_Bank_Account_Verification__c();
                appBAV.Lending_Application_Name__c = app.id;
                appBAV.Deposit_Amount__c = 0;
                appBAV.Is_Deposit_Complete__c = false;
                appBAV.Is_Client_Created__c = false;
                appBAV.Deposit_Status__c = 'Not Sent To Processor';
                appBAV.recordTypeId = recordTypeNewRecordId;
                appBAV.Custom_CreatedDate__c = System.today();
                app.fsCore__Application_Status__c = 'BAV In Progress';
                updateApplicationList.add(app);    
                appBAVList.add(appBAV);
                Email_Notification_Log__c emailRecord = new Email_Notification_Log__c();
                emailRecord.Notification_Type__c = 'Initiate BAV';
                String accountNumber;
                if(mapApplicationToAccountNumber.get(app.id) != null){
                    accountNumber = mapApplicationToAccountNumber.get(app.id);
                    accountNumber = getEncryptedAccountNumber(accountNumber);
                }
                emailRecord.Placeholder_1__c = 'On ' + Date.today().format() + ' we initiated a small deposit to your bank account on file ('+accountNumber+'). Please verify this amount by logging into your Versara account and providing the value deposited.'; 
                List<fsCore__Lending_Application_Customer__c> customerList = mapApplicationToApplicant.get(app.id);
                emailRecord.Recipient_Contact_Name_1__c = customerList[0].fsCore__Contact_Name__c;
                if(customerList.size()>1){
                    emailRecord.Recipient_Contact_Name_2__c = customerList[1].fsCore__Contact_Name__c;
                }    
                emailList.add(emailRecord);
                }
                else{
                  mActionOutput.addError ('Please submit for Lead Underwriter approval prior to verifying bank account.');
                }
            }
            Database.update(updateApplicationList);
            Database.insert(appBAVList);
            Database.insert(emailList); 
        }
        catch(Exception e){
            System.debug(e.getMessage() + e.getStackTraceString());
        }
        
        //perform dml
        if (mActionOutput.getIsSuccess()){
            mActionOutput.setMessage( 'BAV Processing Initiated' );
        }else{
            mActionOutput.setMessage( 'Please submit for Lead Underwriter approval prior to verifying bank account.');
        }
        
        System.debug(loggingLevel.ERROR, '-- Output : ' + String.valueOf(mActionOutput));
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.doProcess(-)');
    }
    global  String getEncryptedAccountNumber(String accNumber){
        if(accNumber != null){
            Integer length = accNumber.length();
            accNumber = accNumber.right(4);
            accNumber = accNumber.leftPad(length, 'x');
        }
        return accNumber;
    } 
    global override String getClassName(){
        return CLASS_NAME;
    }
}