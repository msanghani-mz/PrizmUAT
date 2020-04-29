public class OutboundPaymentHandler {
    public static void initiateNuPay(List<fsCore__Outbound_Payment__c > newOutboundPayments){
        Set<Id> markOutboundPaymentToPendingIds = new Set<Id>();
        for (fsCore__Outbound_Payment__c outboundRec : newOutboundPayments){
            if (outboundRec.NuPay_Transaction_Status__c == 'Tentative'){
                markOutboundPaymentToPendingIds.add(outboundRec.Id);
            }
        }

        Batch_OutboundPaymentToPending paymentToPendingInstance = new Batch_OutboundPaymentToPending(markOutboundPaymentToPendingIds); 
        database.executebatch(paymentToPendingInstance, 1);
    }
    
    public static void syncNudebtPayment(List<fsCore__Outbound_Payment__c > newOutboundPayments, Map<Id, fsCore__Outbound_Payment__c > oldOutBoundPaymentMap){
        Set<Id> applicantAccountIdSet = new Set<Id>();
        Map<Id, Id> applicantIdProgramIdMap = new Map<Id, Id>();
        Set<Id> paymentOutboundIdSet = new Set<Id>();
        
        List<fsCore__Outbound_Payment__c> outbPaymentsTobeProcessed = new List<fsCore__Outbound_Payment__c>();
        List<nu_dse__Payment__c> firstnuDebtPaymentList = new List<nu_dse__Payment__c>();
        List<nu_dse__Payment__c> secondnuDebtPaymentList = new List<nu_dse__Payment__c>();
        List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>();
        
        try {
        
            if (SyncBetweenPrizmAndNuDebt.executePrizmOutbPaymentToNuDebtPayment == TRUE) {
            
                if (SyncBetweenPrizmAndNuDebt.isPrizmOutbPaymentToNuDebtFieldMappingQueried  == FALSE) {
        
                    SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList = [SELECT Id, Name, nu_dse__Source_Field__c, nu_dse__Target_Field__c, 
                                                                                nu_dse__setDefaultValue__c, nu_dse__Default_Value__c, nu_dse__Is_Required__c 
                                                                                FROM nu_dse__Field_mapping__c
                                                                                WHERE nu_dse__Data_Mapping__r.Name IN : SyncBetweenPrizmAndNuDebt.OutbPaymentToNudebtPayment_dataMappingNamesList ];  
                    System.debug('fieldMap::::::'+SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList );  
                    SyncBetweenPrizmAndNuDebt.isPrizmOutbPaymentToNuDebtFieldMappingQueried  = TRUE;
                }
                                                                        
                System.debug('fieldMap:'+SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList );

                Set<Id> contractIds = new Set<Id>();
                Set<Id> accountIds = new Set<Id>();
                for (fsCore__Outbound_Payment__c outbPayment : newOutboundPayments) {
                    if (!String.isEmpty(outbPayment.fsServ__Lending_Contract_Number__c)) {
                        contractIds.add(outbPayment.fsServ__Lending_Contract_Number__c);
                    }
                    if (!String.isEmpty(outbPayment.fsCore__Account_Name__c)) {
                        accountIds.add(outbPayment.fsCore__Account_Name__c);
                    }
                }
                
                Map<Id, fsServ__Lending_Contract__c> contractMap = new Map<Id, fsServ__Lending_Contract__c>([Select Id, fsServ__Product_Code__c from fsServ__Lending_Contract__c where Id IN :contractIds]);
                Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, nu_dse__External_RAMS_ID__c from account where Id IN :accountIds]);
        
                for (fsCore__Outbound_Payment__c outbPayment : newOutboundPayments) {
                    
                    if (outbPayment.fsCore__Payment_Source__c == 'Disbursement' && outbPayment.fsCore__Payment_Amount__c > 0
                        && contractMap.get(outbPayment.fsServ__Lending_Contract_Number__c).fsServ__Product_Code__c == 'VCL'
                        && !String.isEmpty(accountMap.get(outbPayment.fsCore__Account_Name__c).nu_dse__External_RAMS_ID__c)) {

                        if (SyncBetweenPrizmAndNuDebt.outbPaymentIdStaticSet.contains(outbPayment.Id) == FALSE) {
                        
                            System.debug('outbPayment'+outbPayment);  
                            if (String.isNotBlank(outbPayment.fsCore__Account_Name__c)) {
                                for (nu_dse__Field_Mapping__c fieldMapping : SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList ) {
                                    system.debug('++++++fieldMapping.nu_dse__Source_Field__c++++++'+fieldMapping.nu_dse__Source_Field__c);
                                    
                                    if ((String.isNotBlank(fieldMapping.nu_dse__Source_Field__c) 
                                            && outbPayment.get(fieldMapping.nu_dse__Source_Field__c) != oldOutBoundPaymentMap.get(outbPayment.Id).get(fieldMapping.nu_dse__Source_Field__c)) 
                                            || (oldOutBoundPaymentMap.get(outbPayment.Id).get('NuPay_Transaction_Status__c') != outbPayment.NuPay_Transaction_Status__c)) {
                                            
                                        
                                        System.debug('++++++++update++++++');
                                        applicantAccountIdSet.add(outbPayment.fsCore__Account_Name__c);
                                        outbPaymentsTobeProcessed.add(outbPayment);
                                        SyncBetweenPrizmAndNuDebt.outbPaymentIdStaticSet.add(outbPayment.Id);
                                        paymentOutboundIdSet.add(outbPayment.Id);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                System.debug('++++++++applicantAccountIdSet++++++'+applicantAccountIdSet);
                System.debug('++++++++outbPaymentsTobeProcessed++++++'+outbPaymentsTobeProcessed);
                System.debug('++++++++SyncBetweenPrizmAndNuDebt.outbPaymentIdStaticSet++++++'+SyncBetweenPrizmAndNuDebt.outbPaymentIdStaticSet);
                System.debug('++++++++paymentOutboundIdSet++++++'+paymentOutboundIdSet);
                if (applicantAccountIdSet.isEmpty() == FALSE) {
                    
                    Set<Id> alreadySyncedPaymentIdSet = new Set<Id>();
                    
                    for (nu_dse__Payment__c paymentInst : [SELECT Id, Prizm_External_Id__c FROM nu_dse__Payment__c WHERE Prizm_External_Id__c IN :paymentOutboundIdSet]) {
                        system.debug('++++++paymentInst+++++++'+paymentInst);
                        alreadySyncedPaymentIdSet.add(paymentInst.Prizm_External_Id__c);
                    }
                    
                    for (nu_dse__Program__c program : [SELECT Id, Name, nu_dse__Account__r.Name,nu_dse__Account__r.Prizm_External_Id__c
                                                      FROM nu_dse__Program__c
                                                      WHERE nu_dse__Account__r.Prizm_External_Id__c IN :applicantAccountIdSet]) {
                        system.debug('++++++program+++++++'+program);                                    
                        applicantIdProgramIdMap.put(program.nu_dse__Account__r.Prizm_External_Id__c, program.Id);
                    }
                                                                                                                                                                                                                     
                    for (fsCore__Outbound_Payment__c outbPayment : outbPaymentsTobeProcessed) {
                        for (Integer i = 0; i < 2; i++) {
                            if (alreadySyncedPaymentIdSet.contains(outbPayment.Id) == True || outbPayment.NuPay_Transaction_Status__c == 'Pending') {
                                
                                if (applicantIdProgramIdMap.containsKey(outbPayment.fsCore__Account_Name__c)) {
                                
                                    nu_dse__Payment__c nuDebtPayment = new nu_dse__Payment__c();
                                    nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                                    String errMsg = '';
                                    
                                    if (i == 0) {
                                        nuDebtPayment.put('nu_dse__Schedule_Date__c', system.today().addDays(1));
                                        nuDebtPayment.put('nu_dse__Transaction_Status__c', 'Tentative'); 
                                        nuDebtPayment.RecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
                                        nuDebtPayment.nu_dse__Payment_Type__c = 'Loan';
                                        nuDebtPayment.nu_dse__Transaction_Method__c = 'L_ACH';
                                    } else if (i == 1) {
                                        nuDebtPayment.put('nu_dse__Transaction_Status__c', 'Tentative');
                                       // nuDebtPayment.put('nu_dse__Schedule_Date__c', system.today().addDays(10));
                                        nuDebtPayment.RecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Customer Withdrawal').getRecordTypeId();
                                        nuDebtPayment.nu_dse__Payment_Type__c = 'CUST Withdrawal';
                                        nuDebtPayment.nu_dse__Transaction_Method__c = 'CHECK_OVERNIGHT';   
                                    }

                                    for (nu_dse__Field_Mapping__c fieldMapping: SyncBetweenPrizmAndNuDebt.prizmToNuDebtfieldMappingsList ) {
                                    
                                        if (String.isNotBlank(fieldMapping.nu_dse__Target_Field__c)) {
                                        
                                            if (fieldMapping.nu_dse__setDefaultValue__c == TRUE) {
                                                if (String.isBlank(fieldMapping.nu_dse__Default_Value__c) && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                                
                                                    errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                                } else {
                                                
                                                    nuDebtPayment.put(fieldMapping.nu_dse__Target_Field__c, fieldMapping.nu_dse__Default_Value__c);
                                                }
                                                
                                            } else if (String.isNotBlank(fieldMapping.nu_dse__Source_Field__c)) {
                                                if (outbPayment.get(fieldMapping.nu_dse__Source_Field__c) == null && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                                    
                                                    errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                                } else {
                                                
                                                    nuDebtPayment.put(fieldMapping.nu_dse__Target_Field__c, outbPayment.get(fieldMapping.nu_dse__Source_Field__c));
                                                }
                                            }
                                        }
                                    }
                                    
                                    if (String.isNotBlank(errMsg)) {
                                    
                                        errLog =  createErrorLog('OutboundPaymentHandler.syncNudebtPayment', errMsg, null );
                                        errLogList.add(errLog);    
                                    } else {                                       
                                        nuDebtPayment.nu_dse__Program__c = applicantIdProgramIdMap.get(outbPayment.fsCore__Account_Name__c); //clientProgramList[0].Id;
                                        if (i == 0) {
                                            nuDebtPayment.Prizm_External_Id__c = outbPayment.Id;
                                            firstnuDebtPaymentList.add(nuDebtPayment);
                                        } else if (i == 1) {
                                            secondnuDebtPaymentList.add(nuDebtPayment);
                                        }  
                                    }
                                }
                            }
                        }
                    }
                    
                    System.debug('firstnuDebtPaymentList'+firstnuDebtPaymentList);
                    System.debug('secondnuDebtPaymentList'+secondnuDebtPaymentList);
                    
                    /*  Toggling executeNuDebtPaymentToPrizmPayment static variable 
                        to skip the execution of NuDebtPaymentToPrizmPayment trigger 
                        within this context
                    
                    */
                    SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = FALSE;
                    List<Database.UpsertResult> firstUpsertResult = Database.upsert(firstnuDebtPaymentList, nu_dse__Payment__c.Prizm_External_Id__c, false);
                    SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = TRUE;

                    for (Database.UpsertResult result : firstUpsertResult) {
                        if(result.isSuccess() == TRUE) {
                            secondnuDebtPaymentList[0].nu_dse__Advance_Payment__c = result.getId();
                            secondnuDebtPaymentList[0].Prizm_External_Id__c = result.getId();
                        } else if(result.isSuccess() == FALSE) {
                            nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                            List<String> errMsgs = new List<String>();
                                                
                            for (Database.Error err: result.getErrors()) {
                        
                                errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                            }
                            errLog =  createErrorLog('OutboundPaymentHandler.syncNudebtPayment', String.join(errMsgs, '\n'), null );
                            errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                            errLogList.add(errLog);
                        }
                    }
                    SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = FALSE;
                    List<Database.UpsertResult> secondUpsertResult = Database.upsert(secondnuDebtPaymentList, nu_dse__Payment__c.Prizm_External_Id__c, false);
                    SyncBetweenPrizmAndNuDebt.executeNuDebtPaymentToPrizmPayment = TRUE;
                    
                    for (Database.UpsertResult result : secondUpsertResult) {
                    
                        System.debug('result--->'+result);
                        if(result.isSuccess() == FALSE) {
                            
                            nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                            List<String> errMsgs = new List<String>();
                                                
                            for (Database.Error err: result.getErrors()) {
                        
                                errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                            }
                            errLog =  createErrorLog('OutboundPaymentHandler.syncNudebtPayment', String.join(errMsgs, '\n'), null );
                            errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                            errLogList.add(errLog);
                        } else {
                            PaymentToPendingQueueable pendingJob = new PaymentToPendingQueueable(new Set<Id>{firstnuDebtPaymentList[0].Id});
                            ID jobID = System.enqueueJob(pendingJob);                                    
                        }
                    }
                    insert errLogList;
                }
            }
        
            
        } catch(Exception e) {
        
            insert createErrorLog('OutboundPaymentHandler.syncNudebtPayment', null, e);
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