/**
 * Class Name  : ContentDocumentLinkTriggerManager (PDI-409)
 * Description : This class handles the custom logic for fsCore.ContentDocumentLinkTrigger
 * Author      : Financial Spectra
 * 
 */
global with sharing class ContentDocumentLinkTriggerManager implements fsCore.TriggerManager {
    private static final String CLASS_NAME = 'ContentDocumentLinkTriggerManager';
    public static boolean mIsExecuting = false;

    global void beforeInsert(List<sObject> pNewRecList){}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){

        List<ContentDocumentLink> lendingAppRelatedLinks = getLendingAppRelatedLinks((List<ContentDocumentLink>)pNewRecList);
        if (lendingAppRelatedLinks.size() > 0){
            System.enqueueJob(new CopyPostTilaToBoxQueueable(lendingAppRelatedLinks));   
        }
    }

    private List<ContentDocumentLink> getLendingAppRelatedLinks(List<ContentDocumentLink> pContentDocLinks){
        String lendingAppObjectName = Schema.SObjectType.fsCore__Lending_Application__c.getName();
        String lendingAppKeyPrefix = Schema.SObjectType.fsCore__Lending_Application__c.getKeyPrefix();
        System.debug(loggingLevel.ERROR, '-- Lending App KeyPrefix : ' + lendingAppKeyPrefix);
        
        List<ContentDocumentLink> lendingDocRelatedLinks = new List<ContentDocumentLink>();
        for(ContentDocumentLink cdLink : pContentDocLinks){
            System.debug(loggingLevel.ERROR, '-- LinkedEntityId : ' + cdLink.LinkedEntityId);
            if (cdLink.LinkedEntityId.getSobjectType().getDescribe().getName() == lendingAppObjectName
                && String.valueOf(cdLink.LinkedEntityId).startsWith(lendingAppKeyPrefix)){
                lendingDocRelatedLinks.add(cdLink);
            }
        }
        
        return lendingDocRelatedLinks;
    }    


    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
}