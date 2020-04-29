/**
 * Class Name  : ContractDirectDebitCustomTriggerManager (PDI-341)
 * Description : This class handles the custom logic for fsServ.ContractDirectDebitTrigger
 * Author      : Financial Spectra
 * 
 */
global with sharing class ContractDirectDebitCustomTriggerManager implements fsCore.TriggerManager {
    global void beforeInsert(List<sObject> pNewRecList){}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        //PDI-341 send emails for the payoff Payments and for the payment plan setup
        List<Id> payOffDirectDebitIds = new List<Id>();
        List<Id> paymentPlanDirectDebitIds = new List<Id>();
        for(fsServ__Contract_Direct_Debit__c newContractDirectDebit : (List<fsServ__Contract_Direct_Debit__c>)pNewRecList){
            if ((newContractDirectDebit.fsServ__Payoff_Quote_Number__c != null)
                && (newContractDirectDebit.fsServ__Direct_Debit_Type__c == fsServ.Constants.DIRECT_DEBIT_TYPE_ONE_TIME)){
                    payOffDirectDebitIds.add(newContractDirectDebit.Id);
            }

            if (newContractDirectDebit.fsServ__Direct_Debit_Type__c == fsServ.Constants.DIRECT_DEBIT_TYPE_PAYMENT_PLAN){
                paymentPlanDirectDebitIds.add(newContractDirectDebit.Id);
            }
        }
        if (payOffDirectDebitIds.size()>0){
            PayoffNotification.sendNotification(payOffDirectDebitIds);
        }
        if (paymentPlanDirectDebitIds.size()>0){
            PaymentPlanNotification.sendNotification(payOffDirectDebitIds);
        }

    }
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}    
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
}