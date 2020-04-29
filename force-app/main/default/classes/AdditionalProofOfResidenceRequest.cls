/**
* @File Name          : AdditionalProofOfResidenceRequest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 10/6/2019, 11:04:18 PM
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    10/6/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class AdditionalProofOfResidenceRequest {
    
    @AuraEnabled
    public static List<fsCore__Lending_Application_Customer__c> getCustomers(Id pId){
        List<fsCore__Lending_Application_Customer__c> customer = [Select Person_Name_Formula__c, 
                                                                  fsCore__Customer_Type__c,
                                                                  fsCore__Contact_Name__c
                                                                  
                                                                  from fsCore__Lending_Application_Customer__c where fsCore__Lending_Application_Number__c =:pId];
        
        
        return customer;        
    }
    
    @AuraEnabled
    public static void requestAdditionalAddressProof(String pSelectedCustomersJSON, Id applicationId){
        
        List<fsCore__Lending_Application_Customer__c> selectedCustomers =
            (List<fsCore__Lending_Application_Customer__c>)JSON.deserialize(pSelectedCustomersJSON, List<fsCore__Lending_Application_Customer__c>.class);
        
        //Map<Id, fsCore__Lending_Application_Customer__c> customerMap = new Map<Id, fsCore__Lending_Application_Customer__c>(selectedCustomers);
        
        id primaryApplicantId;
        id secondaryApplicantId;
        
        for(fsCore__Lending_Application_Customer__c customer : selectedCustomers){
            if (customer.fsCore__customer_type__c == 'Primary'){
                primaryApplicantId = customer.fsCore__Contact_Name__c;
            }else{
                secondaryApplicantId = customer.fsCore__Contact_Name__c;
            }
            
        }
        
        List<Email_Notification_Log__c> emailList = new List<Email_Notification_Log__c>();  
        Email_Notification_Log__c emailRecord = new Email_Notification_Log__c();
        emailRecord.Notification_Type__c = 'More Proof Of Residence';
        
        if (primaryApplicantId != null && secondaryApplicantId != null){
            emailRecord.Recipient_Contact_Name_1__c = primaryApplicantId;
            emailRecord.Recipient_Contact_Name_2__c = secondaryApplicantId;
        }
        if (secondaryApplicantId != null && primaryApplicantId == null){
            emailRecord.Recipient_Contact_Name_1__c = secondaryApplicantId;
        }if(primaryApplicantId != null && secondaryApplicantId == null){
            emailRecord.Recipient_Contact_Name_1__c = primaryApplicantId; 
        }
        emailList.add(emailRecord);         
        
        insert emailList;
        
        Set<Id> accList = new Set<Id>();
        
        //System.debug(accList);
        List<fsCore__Lending_Application_Checklist__c> appCheckList = [Select id,
                                                                       name,
                                                                       Applicant_Name__c
                                                                       , fsCore__Checklist_Code__c
                                                                       from fsCore__Lending_Application_Checklist__c
                                                                       where fsCore__Lending_Application_Number__c =:applicationId
                                                                       and fsCore__Checklist_Code__c IN ('VCL_APL_DOC_CHK_STD','VCL_COAPL_DOC_CHK_STD')
                                                                       and fsCore__Document_Classification__c = 'Proof of Address'];
        
        
        
        for(fsCore__Lending_Application_Checklist__c checklist : appCheckList){
            if ((primaryApplicantId != null) && (checklist.fsCore__Checklist_Code__c == 'VCL_APL_DOC_CHK_STD')){
                checkList.fsCore__Is_Required__c = true;
            }
            if ((secondaryApplicantId != null) && (checklist.fsCore__Checklist_Code__c == 'VCL_COAPL_DOC_CHK_STD')){
                checkList.fsCore__Is_Required__c = true;
            }            
        }
        update appCheckList;
    }
}