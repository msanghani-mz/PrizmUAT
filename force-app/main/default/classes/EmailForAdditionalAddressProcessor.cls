/*
* Class Name   - EmailForAdditionalAddressProcessor
* Description  - Action class to generate Email notification Log
* Developer(s) - Financial Spectra
*
*/
global with sharing class EmailForAdditionalAddressProcessor extends fsCore.ApplicationActionProcessorBase{
    private static final String CLASS_NAME = '   EmailForAdditionalAddressProcessor';
    private Map<Id, List<fsCore__Lending_Application_Customer__c>> mApplicationToContactMap = new Map<Id, List<fsCore__Lending_Application_Customer__c>>();
    
    global  EmailForAdditionalAddressProcessor(){
        super();
    }
    
    global override void populateAndValidateRelatedData(){
        /*System.debug(loggingLevel.ERROR, CLASS_NAME + '.populateAndValidateRelatedData(+)');
        Set<ID> appIds = new Set<ID>();
        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            appIds.add(application.id);
        }
        
        List<fsCore__Lending_Application_Customer__c> applicantListPrimary = [SELECT Id
                                                                              ,fsCore__Account_Name__r.personcontactid     
                                                                              ,fsCore__Lending_Application_Number__c
                                                                              ,fsCore__Customer_Type__c
                                                                              FROM fsCore__Lending_Application_Customer__c 
                                                                              WHERE fsCore__Lending_Application_Number__c in :appIds
                                                                              AND fsCore__Customer_Type__c ='Primary'
                                                                              ORDER BY fsCore__Lending_Application_Number__c];  
        
        for(fsCore__Lending_Application_Customer__c customer : applicantListPrimary){
            List<fsCore__Lending_Application_Customer__c> customerList = new List<fsCore__Lending_Application_Customer__c>();
            customerList.add(customer);
            mApplicationToContactMap.put(customer.fsCore__Lending_Application_Number__c,customerList);
        }
        System.debug(mApplicationToContactMap);
        try{ 
            List<fsCore__Lending_Application_Customer__c> applicantListSecondary = [SELECT Id
                                                                                    ,fsCore__Account_Name__r.personcontactid     
                                                                                    ,fsCore__Lending_Application_Number__c
                                                                                    ,fsCore__Customer_Type__c
                                                                                    FROM fsCore__Lending_Application_Customer__c 
                                                                                    WHERE fsCore__Lending_Application_Number__c in :appIds
                                                                                    AND fsCore__Customer_Type__c ='Secondary'
                                                                                    ORDER BY fsCore__Lending_Application_Number__c ];
            
            for(fsCore__Lending_Application_Customer__c customer : applicantListSecondary){
                List<fsCore__Lending_Application_Customer__c> customerList = mApplicationToContactMap.get(customer.fsCore__Lending_Application_Number__c);
                if(customerList.size()==1){
                    customerList.add(customer);
                    mApplicationToContactMap.put(customer.fsCore__Lending_Application_Number__c,customerList);
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.populateAndValidateRelatedData(-)');*/
    }
    
    global override void doProcess(){

        Set<ID> appIds = new Set<ID>();
        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            appIds.add(application.id);
        }        
        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        ApplicationNotificationAction action =  new ApplicationNotificationAction();
        actionIP.addRecords(appIds);
        action.setInput(actionIP);
        action.setNotificationType(ApplicationNotificationUtil.VCL_EXTRA_ADDRESS_PROOF_NOTIFICATION);
        action.process();


        /*System.debug(loggingLevel.ERROR, CLASS_NAME + '.doProcess(+)');
        List<Email_Notification_Log__c> emailList = new List<Email_Notification_Log__c>();
        for(id appid : mApplicationToContactMap.keySet()){
            Email_Notification_Log__c newEmail  = new Email_Notification_Log__c();
            System.debug('3');
            if(mApplicationToContactMap.get(appid).size()==2){
                newEmail.Lending_Application_Number__c = appid;
                newEmail.Notification_Type__c = 'VCL Request for address proof';
                newEmail.Recipient_Contact_Name_1__c = mApplicationToContactMap.get(appid)[0].fsCore__Account_Name__r.personcontactid;
                newEmail.Recipient_Contact_Name_2__c = mApplicationToContactMap.get(appid)[1].fsCore__Account_Name__r.personcontactid;
            }
            else{
                newEmail.Lending_Application_Number__c = appid;
                newEmail.Notification_Type__c = 'VCL Request for address proof';
                newEmail.Recipient_Contact_Name_1__c = mApplicationToContactMap.get(appid)[0].fsCore__Account_Name__r.personcontactid;
            }
            emailList.add(newEmail);
        }
        insert emailList;*/
        
        //perform dml
        if (mActionOutput.getIsSuccess()){
            mActionOutput.setMessage( 'Email for Additional Address Sent' );
        }
        
        System.debug(loggingLevel.ERROR, '-- Output : ' + String.valueOf(mActionOutput));
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.doProcess(-)');
    }
    
    global override String getClassName(){
        return CLASS_NAME;
    }
}