/**
 * Class Name  : ApplicationPricingCustomTriggerManager 
 * Description : This class handles the custom logic for fsCore.LendingApplicationPricingTrigger
 * Author      : Financial Spectra
 * 
 */
global with sharing class ApplicationPricingCustomTriggerManager implements fsCore.TriggerManager {

    global void beforeInsert(List<sObject> pNewRecList){}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        generateAdditionalPricings(pNewRecList, new Map<Id, sObject>());
    }
    
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        generateAdditionalPricings(pNewRecList, pOldRecMap);
    }
    
    private static void generateAdditionalPricings(List<sObject> pNewRecList, Map<Id, sObject> pOldRecMap){
        List<fsCore__Lending_Application_Pricing_Offer__c> acceptedPricingOffers = new List<fsCore__Lending_Application_Pricing_Offer__c>();
        Map<String,Schema.RecordTypeInfo> pricingRecTypeMap = Schema.SObjectType.fsCore__Lending_Application_Pricing_Offer__c.getRecordTypeInfosByDeveloperName();
        Set<Id> pricingSetupIds = new Set<Id>();
        
        if (pricingRecTypeMap.containsKey(fsCore.Constants.PRICING_REC_TYPE_ACCEPTED) && pricingRecTypeMap.get(fsCore.Constants.PRICING_REC_TYPE_ACCEPTED).isActive()){
            Id acceptedPricingRecTpeId = pricingRecTypeMap.get(fsCore.Constants.PRICING_REC_TYPE_ACCEPTED).getRecordTypeId();
            for (fsCore__Lending_Application_Pricing_Offer__c offer : (List<fsCore__Lending_Application_Pricing_Offer__c>)pNewRecList){
                if (pOldRecMap != null && pOldRecMap.containsKey(offer.Id)){
                    fsCore__Lending_Application_Pricing_Offer__c offerOldValue = (fsCore__Lending_Application_Pricing_Offer__c)pOldRecMap.get(offer.Id);
                
                    if (offer.RecordTypeId == acceptedPricingRecTpeId && offerOldValue.RecordTypeId != acceptedPricingRecTpeId){
                        acceptedPricingOffers.add(offer);
                        pricingSetupIds.add(offer.fsCore__Pricing_Name__c);
                    }
                } 
                else {
                    if (offer.RecordTypeId == acceptedPricingRecTpeId){
                        acceptedPricingOffers.add(offer);
                        pricingSetupIds.add(offer.fsCore__Pricing_Name__c);
                    }
                }
            }
        }

        Map<Id, fsCore__Pricing_Setup__c> pricingSetupMap = new Map<Id, fsCore__Pricing_Setup__c>(
            [SELECT Id, Is_Generate_Additional_Pricing__c
                  , Payment_Increase_For_Option_1__c
                  , Payment_Increase_For_Option_2__c
               FROM fsCore__Pricing_Setup__c
              WHERE Id IN :pricingSetupIds]);
        
        Set<Id> offersForOption1 = new Set<Id>();
        Set<Id> offersForOption2 = new Set<Id>();
        for (fsCore__Lending_Application_Pricing_Offer__c offer : acceptedPricingOffers){
            if (pricingSetupMap.containsKey(offer.fsCore__Pricing_Name__c)){
                if (pricingSetupMap.get(offer.fsCore__Pricing_Name__c).Is_Generate_Additional_Pricing__c){
                    if (pricingSetupMap.get(offer.fsCore__Pricing_Name__c).Payment_Increase_For_Option_1__c != null){
                        offersForOption1.add(offer.Id);
                    }    
                    if (pricingSetupMap.get(offer.fsCore__Pricing_Name__c).Payment_Increase_For_Option_2__c != null){
                        offersForOption2.add(offer.Id);
                    }    
                }
            }
        }
        
        if (offersForOption1.size() > 0){
            AdditionalPricingGenerator.generateOption1(offersForOption1);
        }
        if (offersForOption2.size() > 0){
            AdditionalPricingGenerator.generateOption2(offersForOption2);
        }
    }
    
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
    
}