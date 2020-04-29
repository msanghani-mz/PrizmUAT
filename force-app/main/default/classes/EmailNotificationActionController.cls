/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name   - EmailNotificationActionController
 *
 * Description  - Apex Controller for Email Actions
 *
 */
public with sharing class EmailNotificationActionController {
    

    /*
     * Method to get pricing for application
     */
     @AuraEnabled
    public static String reSendEmail(Id pEmailNotificationId){

        fsCore.ActionOutput actionOutput = new fsCore.ActionOutput();
        try{
          Email_Notification_Log__c originalNotificationRecord = getNotificationRecord (pEmailNotificationId);



          Email_Notification_Log__c newNotificationRecord = originalNotificationRecord.clone(false, false, true, false);
          newNotificationRecord.Parent_Record_Name__c = originalNotificationRecord.Id;
          newNotificationRecord.Is_Duplicate_Notification__c = true;

          insert newNotificationRecord;

          originalNotificationRecord.Last_Resent_Date__c = date.today();
          originalNotificationRecord.Resent_counter__c = (originalNotificationRecord.Resent_counter__c == null)?0:originalNotificationRecord.Resent_counter__c;
          originalNotificationRecord.Resent_counter__c += 1;

          update originalNotificationRecord;
          
          actionOutput.setIsSuccess(true);
          actionOutput.setMessage('The email was re-sent successfully!');
        }catch(Exception ex){
            actionOutput.setIsSuccess(false);
            actionOutput.addError(ex.getMessage());
        }

        //actionOutput.setMessageDetails();
        system.debug(logginglevel.error,' JSON :'+actionOutput.getJSONString());
        return actionOutput.getJSONString();        
        

    }

    public static Email_Notification_Log__c getNotificationRecord(Id pEmailNotificationId){
        fsCore.DynamicQueryBuilder emailNotifcationQry = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.Email_Notification_Log__c.getName());
        emailNotifcationQry.addFields();
        emailNotifcationQry.addWhereConditionWithValue(1,'Id', '=', pEmailNotificationId);
        
        List<Email_Notification_Log__c> emailNotificationList = (List<Email_Notification_Log__c>)Database.query(emailNotifcationQry.getQueryString());
        if (emailNotificationList.size() == 0){
            return null;
        }
        return emailNotificationList.get(0);
    }    

    private static void logmessage(Object pMessage){
        system.debug(logginglevel.error, pMessage);
    }      



}