/**
 * @File Name          : InboundPaymentHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/14/2019, 3:02:01 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/14/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class InboundPaymentHandler {
    
    public static void syncNudebtPayment(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        
        Set<Id> applicantAccountIdSet = new Set<Id>();
        Map<Id, Id> applicantIdProgramIdMap = new Map<Id, Id>();
        Set<Id> paymentInboundIdSet = new Set<Id>();
        
        List<fsServ__Inbound_Payment__c> inbPaymentsTobeProcessed = new List<fsServ__Inbound_Payment__c>();
        List<nu_dse__Payment__c> nuDebtPaymentList = new List<nu_dse__Payment__c>();
        List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>();
        
        try {
        
            if (SyncBetweenPrizmAndNuDebt.executePrizmPaymentToNuDebtPayment == TRUE) {
            
                if (SyncBetweenPrizmAndNuDebt.isPrizmToNuDebtFieldMappingQueried  == FALSE) {
        
                    SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList = [SELECT Id, Name, nu_dse__Source_Field__c, nu_dse__Target_Field__c, 
                                                                                nu_dse__setDefaultValue__c, nu_dse__Default_Value__c, nu_dse__Is_Required__c 
                                                                                FROM nu_dse__Field_mapping__c
                                                                                WHERE nu_dse__Data_Mapping__r.Name IN : SyncBetweenPrizmAndNuDebt.InbPaymentToNudebtPayment_dataMappingNamesList ];  
                    System.debug('fieldMap::::::'+SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList );  
                    SyncBetweenPrizmAndNuDebt.isPrizmToNuDebtFieldMappingQueried  = TRUE;
                }
                                                                        
                System.debug('fieldMap:'+SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList );                                                        
        
                for (fsServ__Inbound_Payment__c inbPayment : (List<fsServ__Inbound_Payment__c>)pNewRecList) {
                    
                    if (SyncBetweenPrizmAndNuDebt.inbPaymentIdStaticSet.contains(inbPayment.Id) == FALSE) {
                    
                        System.debug('inbPayment'+inbPayment);  
                        if (String.isNotBlank(inbPayment.fsServ__Account_Name__c)) {
                        
                            //if (Trigger.isUpdate) {
                            //This code is called on the update    
                    
                                for (nu_dse__Field_Mapping__c fieldMapping : SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList ) {
            
                                    if ((String.isNotBlank(fieldMapping.nu_dse__Source_Field__c) 
                                        && inbPayment.get(fieldMapping.nu_dse__Source_Field__c) != pOldRecMap.get(inbPayment.Id).get(fieldMapping.nu_dse__Source_Field__c)) 
                                        || (pOldRecMap.get(inbPayment.Id).get('NuPay_Transaction_Status__c') != inbPayment.NuPay_Transaction_Status__c)) {
                                        
                                        System.debug('update');
                                        applicantAccountIdSet.add(inbPayment.fsServ__Account_Name__c);
                                        inbPaymentsTobeProcessed.add(inbPayment);
                                        SyncBetweenPrizmAndNuDebt.inbPaymentIdStaticSet.add(inbPayment.Id);
                                        paymentInboundIdSet.add(inbPayment.Id);
                                        break;
                                    }
                                }
                            //}    /* else if (Trigger.isInsert){
                            /*
                                System.debug('insert');
                                applicantAccountIdSet.add(inbPayment.fsServ__Account_Name__c);
                                inbPaymentsTobeProcessed.add(inbPayment);
                                SyncBetweenPrizmAndNuDebt.inbPaymentIdStaticSet.add(inbPayment.Id);
                            }    */
                        }
                    }
                }
                
                if (applicantAccountIdSet.isEmpty() == FALSE) {
                    
                    Set<Id> alreadySyncedPaymentIdSet = new Set<Id>();
                    
                    for (nu_dse__Payment__c paymentInst : [SELECT Id, Prizm_External_Id__c FROM nu_dse__Payment__c WHERE Prizm_External_Id__c IN :paymentInboundIdSet]) {
                        
                        alreadySyncedPaymentIdSet.add(paymentInst.Prizm_External_Id__c);
                    }
                    
                    for (nu_dse__Program__c program : [SELECT Id, Name, nu_dse__Account__r.Name,nu_dse__Account__r.Prizm_External_Id__c
                                                      FROM nu_dse__Program__c
                                                      WHERE nu_dse__Account__r.Prizm_External_Id__c IN :applicantAccountIdSet]) {
                    
                        applicantIdProgramIdMap.put(program.nu_dse__Account__r.Prizm_External_Id__c, program.Id);
                    }
                                                                                                                                                                                                                     
                    for (fsServ__Inbound_Payment__c inbPayment : inbPaymentsTobeProcessed) {
                        
                        if (alreadySyncedPaymentIdSet.contains(inbPayment.Id) == True || inbPayment.NuPay_Transaction_Status__c == 'Pending') {
                            
                            if (applicantIdProgramIdMap.containsKey(inbPayment.fsServ__Account_Name__c)) {
                            
                                nu_dse__Payment__c nuDebtPayment = new nu_dse__Payment__c();
                                nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                                String errMsg = '';
                                
                                for (nu_dse__Field_Mapping__c fieldMapping: SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList ) {
                                
                                    if (String.isNotBlank(fieldMapping.nu_dse__Target_Field__c)) {
                                    
                                        if (fieldMapping.nu_dse__setDefaultValue__c == TRUE) {
                                            if (String.isBlank(fieldMapping.nu_dse__Default_Value__c) && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                            
                                                errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                            } else {
                                            
                                                 nuDebtPayment.put(fieldMapping.nu_dse__Target_Field__c, fieldMapping.nu_dse__Default_Value__c);
                                            }
                                            
                                        } else if (String.isNotBlank(fieldMapping.nu_dse__Source_Field__c)) {
                                            if (inbPayment.get(fieldMapping.nu_dse__Source_Field__c) == null && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                                
                                                errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                            } else {
                                            
                                                nuDebtPayment.put(fieldMapping.nu_dse__Target_Field__c, inbPayment.get(fieldMapping.nu_dse__Source_Field__c));
                                            }
                                        }
                                    }
                                }
                                
                                if (String.isNotBlank(errMsg)) {
                                
                                    errLog =  createErrorLog('InboundPaymentHandler.syncNudebtPayment', errMsg, null );
                                    errLogList.add(errLog);    
                                } else {
                                
                                    nuDebtPayment.Prizm_External_Id__c = inbPayment.Id;
                                    nuDebtPayment.nu_dse__Program__c = applicantIdProgramIdMap.get(inbPayment.fsServ__Account_Name__c); //clientProgramList[0].Id;
                                    nuDebtPaymentList.add(nuDebtPayment);
                                }
                            }
                        }
                    }
                    
                    System.debug('paymentsToUpsert'+nuDebtPaymentList);
                    
                    /*  Toggling executeNuDebtPaymentToPrizmPayment static variable 
                        to skip the execution of NuDebtPaymentToPrizmPayment trigger 
                        within this context
                    
                    */
                    SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = FALSE;
                    List<Database.UpsertResult> upsertResult = Database.upsert(nuDebtPaymentList, nu_dse__Payment__c.Prizm_External_Id__c, false);
                    SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = TRUE;
                    
                    for (Database.UpsertResult result : upsertResult) {
                    
                        System.debug('result--->'+result);
                        if(result.isSuccess() == FALSE) {
                            
                            nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                            List<String> errMsgs = new List<String>();
                                                
                            for (Database.Error err: result.getErrors()) {
                        
                                errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                            }
                            errLog =  createErrorLog('InboundPaymentHandler.syncNudebtPayment', String.join(errMsgs, '\n'), null );
                            errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                            errLogList.add(errLog);
                        }
                    }
                    insert errLogList;
                }
            }
        
            
        } catch(Exception e) {
        
            insert createErrorLog('InboundPaymentHandler.syncNudebtPayment', null, e);
        }
    }
    
    public static nu_dse__Error_log__c createErrorLog(String classMethod, String message, Exception e) {
    
        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
        
        errLog.nu_dse__Class_Method__c = classMethod;
        errLog.nu_dse__User_Context__c = UserInfo.getUserName();
        if (e != null) {
        
            errLog.nu_dse__Message__c = e.getMessage();
            errLog.nu_dse__Stack_Trace__c = e.getStackTraceString();
        } else if (String.isNotBlank(message)) {
        
            errLog.nu_dse__Message__c = message;
        }
        return errLog;
    }
}