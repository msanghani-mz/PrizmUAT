public without sharing class ClientPortal_EmailMessageTriggerHandler {
    public ClientPortal_EmailMessageTriggerHandler() {
        //do any pre-execution work
    }

    public static void handleTriggerExecution(Map<Id, EmailMessage> newMap, Map<Id, EmailMessage> oldMap, System.TriggerOperation triggerEvent){
        ClientPortal_EmailMessageTriggerHandler handler = new ClientPortal_EmailMessageTriggerHandler();
        switch on triggerEvent {
            when AFTER_INSERT {
                handler.afterInsert(newMap);
            }
            when else {
                //doing nothing for BEFORE_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }

    private void afterInsert(Map<Id, EmailMessage> newMap){
        List<EmailMessage> msgListToCopyParentFromAccount = new List<EmailMessage>();
        List<EmailMessage> msgListToCopyParentFromOpty = new List<EmailMessage>();
        List<EmailMessage> msgListToCopyParentFromLendAp = new List<EmailMessage>();
        List<EmailMessage> msgListUpdate = new List<EmailMessage>();
        for(EmailMessage msg : newMap.values()){
            if(msg.RelatedToId != null && msg.Related_Account__c == null){
                String parent = ClientPortal_Utility.getSobjectNameFromId(msg.RelatedToId);
                if(!String.isBlank(parent)){
                    if(parent == ClientPortal_Constants.LEND_APP_OBJ_NAME){
                        msgListToCopyParentFromLendAp.add(msg);
                    } else if(parent == ClientPortal_Constants.OPPORTUNITY_OBJ_NAME){
                        msgListToCopyParentFromOpty.add(msg);
                    } else if(parent == ClientPortal_Constants.ACCOUNT_OBJ_NAME){
                        msgListToCopyParentFromAccount.add(msg);
                    }
                }
            }
        }
        if(!msgListToCopyParentFromAccount.isEmpty()){
            msgListUpdate.addAll(copyParentToRelatedAccount(msgListToCopyParentFromAccount));
        }
        if(!msgListToCopyParentFromOpty.isEmpty()){
            msgListUpdate.addAll(pushRelatedValueFromParentOpty(msgListToCopyParentFromOpty));
        }
        if(!msgListToCopyParentFromLendAp.isEmpty()){
            msgListUpdate.addAll(pushRelatedValueFromParentLendApp(msgListToCopyParentFromLendAp));
        }
        if(!msgListUpdate.isEmpty()){
            update msgListUpdate;
        }
    }

    private static List<EmailMessage> copyParentToRelatedAccount(List<EmailMessage> msgToProcess){
        List<EmailMessage> processedMsgList = new List<EmailMessage>();
        for(EmailMessage msgObj : msgToProcess){
            EmailMessage tempMsgObj = new EmailMessage(Id = msgObj.Id);
            tempMsgObj.Related_Account__c = msgObj.RelatedToId;
            processedMsgList.add(tempMsgObj);
        }
        return processedMsgList;
    }

    private static List<EmailMessage> pushRelatedValueFromParentOpty(List<EmailMessage> msgToProcess){
        List<EmailMessage> processedMsgList = new List<EmailMessage>();
        Set<Id> parentOptyIdSet = new Set<Id>();
        Set<String> emailIdSet = new Set<String>();
        Map<String, String> emailVsAccountIdMap = new Map<String, String>();
        for(EmailMessage msgObj : msgToProcess){
            parentOptyIdSet.add(msgObj.RelatedToId);
            emailIdSet.add(msgObj.ToAddress);
        }
        For(Opportunity optyObj : [Select Id, AccountId, Co_Applicant_Name__c, Co_Applicant_Name__r.Person_Email__c, Account.Person_Email__c FROM Opportunity 
                                    WHERE Id IN :parentOptyIdSet 
                                    ORDER BY SystemModStamp ASC]){
            if(optyObj.AccountId != null && emailIdSet.contains(optyObj.Account.Person_Email__c)){
                emailVsAccountIdMap.put(optyObj.Account.Person_Email__c, optyObj.AccountId);
            }
            if(optyObj.Co_Applicant_Name__c != null && emailIdSet.contains(optyObj.Co_Applicant_Name__r.Person_Email__c)){
                emailVsAccountIdMap.put(optyObj.Co_Applicant_Name__r.Person_Email__c, optyObj.Co_Applicant_Name__c);
            }
        }
        for(EmailMessage tempMsg : msgToProcess){
            if(emailVsAccountIdMap.containsKey(tempMsg.ToAddress)){
                EmailMessage processedMsg = new EmailMessage(Id = tempMsg.Id);
                processedMsg.Related_Account__c = emailVsAccountIdMap.get(tempMsg.ToAddress);
                processedMsgList.add(processedMsg);
            }
        }
        return processedMsgList;
    }

    private static List<EmailMessage> pushRelatedValueFromParentLendApp(List<EmailMessage> msgToProcess){
        List<EmailMessage> processedMsgList = new List<EmailMessage>();
        Set<Id> parentLendingAppIdSet = new Set<Id>();
        Set<String> emailIdSet = new Set<String>();
        Map<String, String> emailVsAccountIdMap = new Map<String, String>();
        for(EmailMessage msgObj : msgToProcess){
            parentLendingAppIdSet.add(msgObj.RelatedToId);
            emailIdSet.add(msgObj.ToAddress);
        }
        for(fsCore__Lending_Application_Customer__c applicant : [SELECT Id, fsCore__Account_Name__c, fsCore__Account_Name__r.Person_Email__c 
                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                WHERE fsCore__Lending_Application_Number__c IN : parentLendingAppIdSet 
                                                                ORDER BY SystemModStamp ASC]){
            if(applicant.fsCore__Account_Name__c != null && emailIdSet.contains(applicant.fsCore__Account_Name__r.Person_Email__c)){
                emailVsAccountIdMap.put(applicant.fsCore__Account_Name__r.Person_Email__c, applicant.fsCore__Account_Name__c);
            }
        }
        for(EmailMessage tempMsg : msgToProcess){
            if(emailVsAccountIdMap.containsKey(tempMsg.ToAddress)){
                EmailMessage processedMsg = new EmailMessage(Id = tempMsg.Id);
                processedMsg.Related_Account__c = emailVsAccountIdMap.get(tempMsg.ToAddress);
                processedMsgList.add(processedMsg);
            }
        }
        return processedMsgList;
    }
}