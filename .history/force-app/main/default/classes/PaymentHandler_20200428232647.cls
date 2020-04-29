/**
 * @File Name          : PaymentHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/19/2019, 12:20:21 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/19/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class PaymentHandler {
    
    public static void syncInboundPayments() {
    
        List<nu_dse__Payment__c> nuDebtPaymentTobeUpdated = new List<nu_dse__Payment__c>();
        List<fsServ__Inbound_Payment__c> inbPaymentsList = new List<fsServ__Inbound_Payment__c>();
        List<Id> nuDebtPaymentIdList = new List<Id>();
        List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>();
        List<nu_dse__Payment__c> paymentsToProcessList = new List<nu_dse__Payment__c>();
        
        Map<Id, Id> nuDebtPaymentIdPrizmAcctIdMap = new Map<Id, Id>();
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        try {
        
            if (SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment == TRUE) {
            
                if (SyncBetweenPrizmAndNuDebt.isNuDebtToPrizmFieldMappingQueried == FALSE) {
            
                    SyncBetweenPrizmAndNuDebt.nuDebtToPrizmfieldMappingsList =  [SELECT Id, Name, nu_dse__Source_Field__c, nu_dse__Target_Field__c, 
                                                                                nu_dse__setDefaultValue__c, nu_dse__Default_Value__c, nu_dse__Is_Required__c 
                                                                                FROM nu_dse__Field_mapping__c
                                                                                WHERE nu_dse__Data_Mapping__r.Name IN :SyncBetweenPrizmAndNuDebt.NudebtPaymentToInbPayment_dataMappingNamesList]; 
                    SyncBetweenPrizmAndNuDebt.isNuDebtToPrizmFieldMappingQueried = TRUE;                        
                }
                
                for (nu_dse__Payment__c payment : (List<nu_dse__Payment__c>)Trigger.new) {  
                    if (payment.RecordTypeId == draftRecordTypeId && payment.nu_dse__Payment_Type__c  == 'Deposit') {
                        if (SyncBetweenPrizmAndNuDebt.nuDebtbPaymentIdStaticSet.contains(payment.Id) == FALSE) {
                        
                            for (nu_dse__Field_Mapping__c fieldMapping : SyncBetweenPrizmAndNuDebt.nuDebtToPrizmfieldMappingsList) {
                        
                                if ((Trigger.isUpdate && String.isNotBlank(fieldMapping.nu_dse__Source_Field__c) && payment.get(fieldMapping.nu_dse__Source_Field__c) != Trigger.oldMap.get(payment.Id).get(fieldMapping.nu_dse__Source_Field__c))
                                        || Trigger.isInsert) {
                                    
                                    paymentsToProcessList.add(payment);
                                    SyncBetweenPrizmAndNuDebt.nuDebtbPaymentIdStaticSet.add(payment.Id);
                                    break;
                                }
                            }
                        }
                    }                            
                }
                
                if (paymentsToProcessList.isEmpty() == False) {
                
                    for (nu_dse__Payment__c paymentRec : [SELECT Id, Name, nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c
                                                             FROM nu_dse__Payment__c WHERE Id IN :paymentsToProcessList
                                                             AND nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c != null
                                                             AND nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c != '']) {
                    
                        nuDebtPaymentIdPrizmAcctIdMap.put(paymentRec.Id, paymentRec.nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c);
                    }
                    
                    for (nu_dse__Payment__c payment : paymentsToProcessList) {
                    
                        if (payment.RecordTypeId == draftRecordTypeId && payment.nu_dse__Payment_Type__c  == 'Deposit') {
                            if (nuDebtPaymentIdPrizmAcctIdMap.containsKey(payment.Id)) {
                            
                                fsServ__Inbound_Payment__c inbPayment = new fsServ__Inbound_Payment__c();
                                inbPayment.Id = payment.Prizm_External_Id__c;
                                inbPayment.fsServ__Account_Name__c = nuDebtPaymentIdPrizmAcctIdMap.get(payment.Id);
                                inbPayment.NuDebt_Payment__c = payment.Id; //DV-231
                                nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                                String errMsg = '';
                                Boolean isMapped = FALSE;                    
                                
                                for (nu_dse__Field_Mapping__c fieldMapping : SyncBetweenPrizmAndNuDebt.nuDebtToPrizmfieldMappingsList) {
                            
                                    if (String.isNotBlank(fieldMapping.nu_dse__Target_Field__c)) {
                                    
                                        if (fieldMapping.nu_dse__setDefaultValue__c == TRUE) {
                                            
                                            if (String.isBlank(fieldMapping.nu_dse__Default_Value__c) && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                            
                                                errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                            } else {
                                            
                                                inbPayment.put(fieldMapping.nu_dse__Target_Field__c, fieldMapping.nu_dse__Default_Value__c);
                                                isMapped = TRUE;
                                            }
                                            
                                        } else if (String.isNotBlank(fieldMapping.nu_dse__Source_Field__c)) {
                                            if (payment.get(fieldMapping.nu_dse__Source_Field__c) == null && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                                
                                                errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                            } else {
                                            
                                                inbPayment.put(fieldMapping.nu_dse__Target_Field__c, payment.get(fieldMapping.nu_dse__Source_Field__c));
                                                isMapped = TRUE;
                                            }
                                        }
                                    }
                                }
                                //add to list    
                                if (String.isNotBlank(errMsg)) {
                                
                                    errLog =  createErrorLog('PaymentHandler.syncInboundPayments', errMsg, null );
                                    errLogList.add(errLog);    
                                
                                } else if (isMapped == TRUE) {
                                    inbPaymentsList.add(inbPayment);
                                    nuDebtPaymentIdList.add(payment.Id);                    
                                }
                            }
                        }
                    }
                }
                
                 /*  Toggling executeNuDebtPaymentToPrizmPayment static variable 
                     to skip the execution of NuDebtPaymentToPrizmPayment trigger 
                     within this context
                 */
                
                system.debug('inbPaymentsList--->'+inbPaymentsList);
                
                SyncBetweenPrizmAndNuDebt.executePrizmPaymentToNuDebtPayment = FALSE;
                List<Database.UpsertResult> upsertResult = Database.upsert(inbPaymentsList, FALSE);
                SyncBetweenPrizmAndNuDebt.executePrizmPaymentToNuDebtPayment = TRUE;
                
                Integer counter = 0;   
                
                for (Database.UpsertResult result : upsertResult) {
                
                    System.debug('result--->'+result);
                    if(result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                    
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        errLog =  createErrorLog('PaymentHandler.syncInboundPayments', String.join(errMsgs, '\n'), null );
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLogList.add(errLog);
                    } else if (result.isSuccess() == TRUE && result.isCreated() == TRUE) {
                    
                        nu_dse__Payment__c payment = new nu_dse__Payment__c();
                        payment.Id = nuDebtPaymentIdList[counter];
                        payment.Prizm_External_Id__c = result.getId();
                        nuDebtPaymentTobeUpdated.add(payment);
                    }
                    counter++;
                }
                List<Database.SaveResult> updateResult = Database.update(nuDebtPaymentTobeUpdated, false);
                
                Integer updateListCounter = 0;
                
                for (Database.SaveResult result : updateResult) {
                    
                    System.debug('result--->'+result);
                    if(result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                    
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        errLog =  createErrorLog('PaymentHandler.syncInboundPayments',
                                                 String.join(errMsgs, '\n') + 'Prizm External Id: '+nuDebtPaymentTobeUpdated[updateListCounter].Prizm_External_Id__c , 
                                                 null );
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLogList.add(errLog);
                    }
                    updateListCounter++;
                }
                insert errLogList;    
            }             
        } catch (Exception e) {
            
            insert createErrorLog('PaymentHandler.syncInboundPayments', null, e);
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

    //VF-11
    public static void updatePaymentStatus(List<nu_dse__Payment__c> newPayments, Map<Id, nu_dse__Payment__c> oldPaymentMap) {
        List<nu_dse__Payment__c> paymentToUpdate = new List<nu_dse__Payment__c>();
        Set<Id> updatedPaymentId = new Set<Id>();
        Id loanRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        Id loanRefundRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Customer Withdrawal').getRecordTypeId();
        for (nu_dse__Payment__c newPayment: newPayments) {
            if (newPayment.nu_dse__Transaction_Status__c == 'Completed' && newPayment.nu_dse__Transaction_Status__c != oldPaymentMap.get(newPayment.Id).nu_dse__Transaction_Status__c 
                && newPayment.RecordTypeId == loanRecordTypeId) {
                updatedPaymentId.add(newPayment.Id);    
            }
        }

        if (!updatedPaymentId.isEmpty()) {
            for (nu_dse__Payment__c payment: [Select Id, Name, nu_dse__Schedule_Date__c, nu_dse__Transaction_Status__c From nu_dse__Payment__c where nu_dse__Advance_Payment__c IN:updatedPaymentId and nu_dse__Transaction_Status__c = 'Tentative' and RecordTypeId = :loanRefundRecordTypeId]) {
                payment.nu_dse__Transaction_Status__c = 'Pending';
                payment.nu_dse__Schedule_Date__c = system.today().addDays(1);
                paymentToUpdate.add(payment);
            }

            if (!paymentToUpdate.isEmpty()) {
                List<Database.SaveResult> updateResult = Database.update(paymentToUpdate, false);
                List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>();
                for (Database.SaveResult result : updateResult) {
                    
                    System.debug('result--->'+result);
                    if(result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                    
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        errLog =  createErrorLog('PaymentHandler.updatePaymentStatus',String.join(errMsgs, '\n'), null );
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLogList.add(errLog);
                    }
                }
                insert errLogList;
            }
        }
    }

    //SUP-547 - Create payment records to sweep funds from CFT accounts into Versara accounts
    public static void createPaymentRecordToPullAmount(List<nu_dse__Payment__c> newPayments, Map<Id, nu_dse__Payment__c> oldPaymentMap) {
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        for (nu_dse__Payment__c newPayment: newPayments) {
            nu_dse__Payment__c oldPayment = oldPaymentMap.get(newPayment.Id);
            if (newPayment.nu_dse__Payment_Type__c == 'Deposit' && newPayment.RecordTypeId == draftRecordTypeId
               && newPayment.nu_dse__Transaction_Status__c != oldPayment.nu_dse__Transaction_Status__c
               && newPayment.nu_dse__Transaction_Status__c == 'Completed') {
               
				paymentList.add(newPayment);              
            }
        }
        
        if (!paymentList.isEmpty()) {
            Id refundLoadnRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Refund Loan').getRecordTypeId();
            List<nu_dse__Payment__c> paymentsToInsert = new List<nu_dse__Payment__c>();
            for (nu_dse__Payment__c payment: paymentList) {
                nu_dse__Payment__c refundLoanPayment = new nu_dse__Payment__c();
                refundLoanPayment.RecordTypeId = refundLoadnRecordTypeId;
                refundLoanPayment.nu_dse__Payment_Type__c = 'Refund';
                refundLoanPayment.nu_dse__Schedule_Date__c = system.today().addDays(1);
                refundLoanPayment.nu_dse__Transaction_Method__c = 'RL_ACH';
                refundLoanPayment.nu_dse__Advance_Payment__c = payment.Id;
                refundLoanPayment.nu_dse__Amount__c = payment.nu_dse__Amount__c;
                refundLoanPayment.nu_dse__Program__c = payment.nu_dse__Program__c;
                paymentsToInsert.add(refundLoanPayment);
            }
            if (!paymentsToInsert.isEmpty()) {
                system.debug('+++++paymentsToInsert++++'+paymentsToInsert);
                SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = FALSE;
                List<Database.UpsertResult> upsertResult = Database.upsert(paymentsToInsert, false);
                SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = TRUE;
                List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>();
                for (Database.UpsertResult result : upsertResult) {
                    system.debug('+++++result++++'+result);
                    if(result.isSuccess() == FALSE) {
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                        
                        for (Database.Error err: result.getErrors()) {
                            
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        errLog =  createErrorLog('PaymentHandler.createPaymentRecordToPullAmount', String.join(errMsgs, '\n'), null );
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLogList.add(errLog);
                    }
                }
            }
        }
    }
}