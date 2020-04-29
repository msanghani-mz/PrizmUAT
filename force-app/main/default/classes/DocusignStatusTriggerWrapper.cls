/*
* Copyright (c) 2017 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class Name    - DocusignStatusTriggerWrapper
* 
* Description   - This is a wrapper class for all the trigger events of 
*                 DocusignStatusTrigger (Object : dsfs__DocuSign_Status__c)
* 
* Developer(s)  - System Generated
* 
*/
global with sharing class DocusignStatusTriggerWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'DocusignStatusTriggerWrapper';
    private static final String TRIGGER_NAME = 'DocusignStatusTrigger';
    
    private DocusignStatusTriggerWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }
    
    private static DocusignStatusTriggerWrapper mInstance = null;
    
    /* Method to get the only instance available */
    global static DocusignStatusTriggerWrapper getInstance(){
        if (mInstance == null) mInstance = new DocusignStatusTriggerWrapper();
        return mInstance;
    }
    
    global override void beforeInsert(List<sObject> pNewRecList) {}
    
    global override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {}
    
    global override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    
    global override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        Set<String> preTilaCompletedEnvelopeIds = new Set<String>();
        Set<String> preTilaSentEnvelopeIds = new Set<String>();
        List<dsfs__DocuSign_Status__c> preTilaSentDocsList = new List<dsfs__DocuSign_Status__c>();
        MAP<String,Id> applicationMap = new MAP<String,Id>();
        MAP<String,String> envelopeName = new MAP<String,String>();
        List<Task> taskList = new List<Task>();
        
        
        for (dsfs__DocuSign_Status__c newAppRec : (List<dsfs__DocuSign_Status__c>)pNewRecList){
            //THIS IS FOR PRE-TILA
            if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeCompleted) &&
                (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypePreTila)){
                    preTilaCompletedEnvelopeIds.add(newAppRec.dsfs__DocuSign_Envelope_ID__c);
                    applicationMap.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Lending_Application_Name__c);
                    envelopeName.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Name);
                }  
            //PDI-518
            if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeSent) &&
                (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypePreTila)){
                    
                    //PDI-587
                    preTilaSentEnvelopeIds.add(newAppRec.dsfs__DocuSign_Envelope_ID__c);
                    applicationMap.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Lending_Application_Name__c);
                    envelopeName.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Name);
                    
                    if (newAppRec.Loan_Officer__c != null){
                        preTilaSentDocsList.add(newAppRec);
                    }
                }                        
            
        }
        
        if (preTilaCompletedEnvelopeIds.size() >0 ){
            SendToDocuSignController.copyDocusignToBox(preTilaCompletedEnvelopeIds,applicationMap,envelopeName,'Pre-Tila Document');
        }
        //PDI-587
        if (preTilaSentEnvelopeIds.size() >0 ){
            SendToDocuSignController.copyDocusignToBox(preTilaSentEnvelopeIds,applicationMap,envelopeName,'Pre-Tila Document Unsigned');
        }        
        //PDI-518
        if (preTilaSentDocsList.size()>0){
            taskList = getTaskList(preTilaSentDocsList,'DNL_PRE_TILA_SENT');
            insert taskList;
        }        
        
        
    }
    
    global override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        
        Set<id> assignmentIdsForContract = new Set<id>();
        
        for(dsfs__DocuSign_Status__c newRec : (List<dsfs__DocuSign_Status__c>)pNewRecList) {
            assignmentIdsForContract.add(newRec.Assignment_Name__c);
        }
        Map<id,fsCore__Assignment__c> assignmentMap = new Map<id,fsCore__Assignment__c>([Select id, fsServ__Lending_Contract_Number__c 
                                                                                         from fsCore__Assignment__c
                                                                                         where id in :assignmentIdsForContract and fsServ__Lending_Contract_Number__c != null]);
        if(assignmentMap.KeySet().size()>0){
            contractDocuSign( pNewRecList, pNewRecMap , assignmentMap);
        }
        
        Set<String> oppLoanAppEnvelopeIds = new Set<String>();
        Set<String> preTilaEnvelopeIds = new Set<String>();
        List<dsfs__DocuSign_Status__c> preTilaSignedDocuSign = new List<dsfs__DocuSign_Status__c>();
        MAP<String,Id> opportunityMap = new MAP<String,Id>();
        MAP<Id,Date> opportunitySignedDateMap = new MAP<Id,Date>();
        MAP<String,Id> applicationMap = new MAP<String,Id>();
        MAP<String,Id> applicantsMap = new MAP<String,Id>();
        MAP<String,Id> coApplicantsMap = new MAP<String,Id>();
        MAP<String,String> envelopeName = new MAP<String,String>();
        Set<ID> programIds = new Set<ID>();
        MAP<ID,ID> programIdToAppMap = new Map <ID,ID>();
        Set<String> atdEnvelopeIds = new Set<String>();
        Set<ID> assignmentIds = new Set<ID>();
        
        
        for (dsfs__DocuSign_Status__c newAppRec : (List<dsfs__DocuSign_Status__c>)pNewRecList){
            //THIS CODE IS TO ONLY HANDLE OPP LOAN APPLICATION 
            if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeCompleted) &&
                (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypeOppLoanApplication) &&
                (newAppRec.dsfs__Envelope_Status__c != ((dsfs__DocuSign_Status__c)pOldRecMap.get(newAppRec.id)).dsfs__Envelope_Status__c)){
                    
                    if (newAppRec.dsfs__Company__c != null){ //IF THE ACCOUNT ID IS NULL THEN WHY TO SEND UPDATE BACK
                        oppLoanAppEnvelopeIds.add(newAppRec.dsfs__DocuSign_Envelope_ID__c);
                        
                        applicantsMap.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.dsfs__Company__c);
                        if (newAppRec.Co_Applicant_Name__c != null){ //POPULATE MAP ONLY IF CO-APPLICANT EXIST
                            coApplicantsMap.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Co_Applicant_Name__c);
                        }
                    }
                    if (newAppRec.dsfs__Completed_Date_Time__c != null){
                        opportunitySignedDateMap.put(newAppRec.dsfs__Opportunity__c,newAppRec.dsfs__Completed_Date_Time__c.date());
                    }
                    opportunityMap.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.dsfs__Opportunity__c);
                }
            //THIS IS FOR PRE-TILA
            if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeCompleted) &&
                (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypePreTila) &&
                (newAppRec.dsfs__Envelope_Status__c != ((dsfs__DocuSign_Status__c)pOldRecMap.get(newAppRec.id)).dsfs__Envelope_Status__c)){
                    preTilaEnvelopeIds.add(newAppRec.dsfs__DocuSign_Envelope_ID__c);
                    preTilaSignedDocuSign.add(newAppRec);
                    applicationMap.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Lending_Application_Name__c);
                    envelopeName.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Name);
                    
                    //programIds ARE BEING POPULATED BECAUSE I NEED TO CALL NUDEBT TO UPDATE STATUS
                    if (newAppRec.Import_Program_Id__c != null){
                        programIds.add(Id.valueOf(newAppRec.Import_Program_Id__c));
                        programIdToAppMap.put(Id.valueOf(newAppRec.Import_Program_Id__c),newAppRec.Lending_Application_Name__c);
                    }                
                }
            if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeCompleted) &&
                (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypeDraftIncreaseATD) &&
                (newAppRec.dsfs__Envelope_Status__c != ((dsfs__DocuSign_Status__c)pOldRecMap.get(newAppRec.id)).dsfs__Envelope_Status__c)){
                    
                    atdEnvelopeIds.add(newAppRec.dsfs__DocuSign_Envelope_ID__c);
                    envelopeName.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Name);
                    applicationMap.put(newAppRec.dsfs__DocuSign_Envelope_ID__c,newAppRec.Lending_Application_Name__c);
                    if (newAppRec.Assignment_Name__c != null){
                        assignmentIds.add(newAppRec.Assignment_Name__c);
                    }
                }            
            
        }
        //THIS CODE IS TO UPDATE Application_Signed_Date__c ON THE OPPORTUNITY USING DOCUSIGN dsfs__Completed_Date_Time__c
        if (opportunitySignedDateMap.size()>0){
            Id dnlOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DNL Sales').getRecordTypeId();
            //opportunitySignedDateMap
            List<opportunity> oppList = [select id,Application_Signed_Date__c from opportunity where id IN :opportunitySignedDateMap.keyset() and recordTypeId = :dnlOppRecordTypeId];
            for (opportunity opp: oppList){
                opp.Application_Signed_Date__c = opportunitySignedDateMap.get(opp.ID);
            }   
            
            update oppList;
            
        }
        if (oppLoanAppEnvelopeIds.size() >0 ){
            SendToDocuSignController.processDocusignCompletedEnvelope(oppLoanAppEnvelopeIds,applicantsMap,coApplicantsMap);
            SendToDocuSignController.addDocusignDocumentToFile(oppLoanAppEnvelopeIds,opportunityMap,'Loan Application Document');
        }
        if (preTilaEnvelopeIds.size() >0 ){
            SendToDocuSignController.copyDocusignToBox(preTilaEnvelopeIds,applicationMap,envelopeName,'Pre-Tila Document');
            
            //Call Third Party PDI-420
            if (programIds.size() >0 ){
                NuDebtIntegrate.updateDNLStatusPreTilaSigned(programIds,programIdToAppMap); 
            }
            
        }
        if (atdEnvelopeIds.size() >0 ){
            SendToDocuSignController.copyDocusignToBox(atdEnvelopeIds,applicationMap,envelopeName,'Draft Increase ATD Document');
        }
        if (preTilaSignedDocuSign.size() >0 ){
            validatePreSettlementUponPreTILASign(preTilaSignedDocuSign);
        }
        
        
        system.debug(logginglevel.error,' before createTaskOnDocumentComplete');
        //PDI-479
        createTaskOnDocumentComplete(pNewRecList,pOldRecList,pNewRecMap,pOldRecMap);
        system.debug(logginglevel.error,' after createTaskOnDocumentComplete');
        closeAssignments(assignmentIds);
        system.debug(logginglevel.error,' after closeAssignments');
        
        
    }
    
    private void validatePreSettlementUponPreTILASign(List<dsfs__DocuSign_Status__c> pDocuSignStatusList){
        
        Set<Id> lendingApplicationIds = new Set<Id>();
        for(dsfs__DocuSign_Status__c docuSignStatus:pDocuSignStatusList ){
            if (docuSignStatus.Lending_Application_Name__c != null){
                lendingApplicationIds.add(docuSignStatus.Lending_Application_Name__c);
            }
        }        
        if (lendingApplicationIds.size()>0){
            System.enqueueJob(new ValidateStageAndMoveNextStageQueueable(lendingApplicationIds));
        }        
    }
    //PDI-479
    private void createTaskOnDocumentComplete(List<sObject> pNewRecList
                                              , List<sObject> pOldRecList
                                              , Map<Id, sObject> pNewRecMap
                                              , Map<Id, sObject> pOldRecMap) {
                                                  
                                                  List<Task> taskList = new List<Task>();
                                                  List<dsfs__DocuSign_Status__c> preTilaSentDocsList = new List<dsfs__DocuSign_Status__c>();
                                                  List<dsfs__DocuSign_Status__c> preTilaSignedAndReturnedList = new List<dsfs__DocuSign_Status__c>();
                                                  List<dsfs__DocuSign_Status__c> atdDocumentSignedAndReturnedList = new List<dsfs__DocuSign_Status__c>();
                                                  List<dsfs__DocuSign_Status__c> atdDocumentDeclinedList = new List<dsfs__DocuSign_Status__c>();
                                                  List<dsfs__DocuSign_Status__c> newAppReturnedList = new List<dsfs__DocuSign_Status__c>();
                                                  //PDI-600
                                                  for (dsfs__DocuSign_Status__c newAppRec : (List<dsfs__DocuSign_Status__c>)pNewRecList){
                                                      system.debug(logginglevel.error,'newAppRec.dsfs__Envelope_Status__c :'+newAppRec.dsfs__Envelope_Status__c
                                                                   +' newAppRec.Document_Type__c :'+newAppRec.Document_Type__c
                                                                   +' NEW dsfs__Envelope_Status__c :'+newAppRec.dsfs__Envelope_Status__c
                                                                   +' OLD dsfs__Envelope_Status__c :'+((dsfs__DocuSign_Status__c)pOldRecMap.get(newAppRec.id)).dsfs__Envelope_Status__c);
                                                      //PRE-TILA & LOAN DOC COMPLETION
                                                      if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeCompleted) &&
                                                          (newAppRec.dsfs__Envelope_Status__c != ((dsfs__DocuSign_Status__c)pOldRecMap.get(newAppRec.id)).dsfs__Envelope_Status__c)){
                                                              
                                                              
                                                              if ((newAppRec.Loan_Officer__c != null) && 
                                                                  (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypePreTila)){
                                                                      preTilaSignedAndReturnedList.add(newAppRec);
                                                                  }
                                                              
                                                              if ((newAppRec.Opportunity_Owner_Formula__c != null) 
                                                                  && (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypeOppLoanApplication)){    
                                                                      //PDI-520, Loan officer.
                                                                      newAppReturnedList.add(newAppRec);
                                                                  }
                                                              
                                                              if (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypeDraftIncreaseATD){
                                                                  atdDocumentSignedAndReturnedList.add(newAppRec);
                                                              }                
                                                              
                                                          }
                                                      
                                                      if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeSent) &&
                                                          (newAppRec.dsfs__Envelope_Status__c != ((dsfs__DocuSign_Status__c)pOldRecMap.get(newAppRec.id)).dsfs__Envelope_Status__c)){
                                                              
                                                              if ((newAppRec.Loan_Officer__c != null) && 
                                                                  (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypePreTila)){
                                                                      preTilaSentDocsList.add(newAppRec);
                                                                  }
                                                              
                                                          }
                                                      //Declined Documents  //DV-158 
                                                      if ((newAppRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeDeclined) &&
                                                          (newAppRec.dsfs__Envelope_Status__c != ((dsfs__DocuSign_Status__c)pOldRecMap.get(newAppRec.id)).dsfs__Envelope_Status__c)){
                                                              
                                                              if (newAppRec.Document_Type__c == DocusignAPIUtil.mDocumentTypeDraftIncreaseATD){
                                                                  atdDocumentDeclinedList.add(newAppRec);
                                                              }
                                                              
                                                          }                
                                                  }
                                                  //DV-158 
                                                  if (atdDocumentSignedAndReturnedList.size()>0){
                                                      taskList.addAll(getTaskList(atdDocumentSignedAndReturnedList,'DOCUSIGN_DRAFT_INCREASE_ATD_COMPLETED'));
                                                  }
                                                  //DV-158 
                                                  if (atdDocumentDeclinedList.size()>0){
                                                      taskList.addAll(getTaskList(atdDocumentDeclinedList,'DOCUSIGN_DRAFT_INCREASE_ATD_DECLINED'));
                                                  }        
                                                  
                                                  if (newAppReturnedList.size()>0){
                                                      taskList.addAll(getTaskList(newAppReturnedList,'DNL_NEW_APP_RETURNED'));
                                                  } 
                                                  if (preTilaSignedAndReturnedList.size()>0){
                                                      taskList.addAll(getTaskList(preTilaSignedAndReturnedList,'DNL_PRE_TILA_SIGNED_RETURNED'));
                                                  } 
                                                  if (preTilaSentDocsList.size()>0){
                                                      taskList.addAll(getTaskList(preTilaSentDocsList,'DNL_PRE_TILA_SENT'));
                                                  }                
                                                  
                                                  if (taskList.size()>0){
                                                      insert taskList;
                                                  }
                                              }
    private void closeAssignments(Set<Id> pAssignmentIds){
        system.debug(logginglevel.error,'INSIDE closeAssignments :'+pAssignmentIds.size());
        List<fsCore__Assignment__c> assignmentList = [select id 
                                                      , name
                                                      , fsCore__Completed_Datetime__c
                                                      , fsCore__Status__c 
                                                      from fsCore__Assignment__c 
                                                      where id in :pAssignmentIds
                                                      AND fsCore__Status__c != :fsCore.Constants.ASSIGNMENT_STATUS_COMPLETED];
        
        system.debug(logginglevel.error,'assignmentList size :'+assignmentList .size());
        for (fsCore__Assignment__c assgn: assignmentList){
            system.debug(logginglevel.error,'assgn :'+assgn);
            assgn.fsCore__Status__c = fsCore.Constants.ASSIGNMENT_STATUS_COMPLETED;
        }
        update assignmentList;
        system.debug(logginglevel.error,'done assignmentList update ');
    }
    private list<task> getTaskList(List<dsfs__DocuSign_Status__c> pRecList, String pTaskCode){
        //PDI-600
        //String taskCode = 'DNL_PRE_TILA_SENT';
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        for (dsfs__DocuSign_Status__c docSignStatus: pRecList){
            TaskObject tsk =  new TaskObject(docSignStatus);
            if (pTaskCode  == 'DNL_NEW_APP_RETURNED'){
                tsk.setOwnerId(Id.valueOf(docSignStatus.Opportunity_Owner_Formula__c));
            }
            taskObjectList.add(tsk);
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        return TaskHandler.getTasks(taskObjectMap);
        
    }
    
    global override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    
    global override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}
    
    private void contractDocuSign(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap , Map<id,fsCore__Assignment__c> assignmentMap) {
        
        Map<String,id> docusignIDToContractIdMap = new Map<String,id>();        
        Set<String> bankAccountChangeCompletedEnvelopeIds = new Set<String>();
        Set<String> bankAccountChangeSentEnvelopeIds = new Set<String>();
        List<dsfs__DocuSign_Status__c> bankAccountChangeSentDocsList = new List<dsfs__DocuSign_Status__c>();
        //MAP<String,Id> contractMap = new MAP<String,Id>();
        MAP<String,String> envelopeName = new MAP<String,String>();
        List<Task> taskList = new List<Task>();
        
        Set<Id> contractIdSet = new Set<Id>();
        
        for(fsCore__Assignment__c assignment : assignmentMap.values()) {
            contractIdSet.add(assignment.fsServ__Lending_Contract_Number__c);
        }
        
        Map<id, fsServ__Lending_Contract__c> contractMap = new Map<id, fsServ__Lending_Contract__c>([Select id, 
                                                                                                     fsServ__Title__c, fsServ__Product_Code__c, 
                                                                                                     Name, 
                                                                                                     OwnerId, 
                                                                                                     fsServ__Primary_Customer_Contact__c
                                                                                                     from fsServ__Lending_Contract__c 
                                                                                                     where Id IN :contractIdSet]);
        
        List<fsServ__Lending_Contract__c> DNLContractList = new List<fsServ__Lending_Contract__c>();
        List<fsServ__Lending_Contract__c> VCLContractList = new List<fsServ__Lending_Contract__c>();
        
        
        for (dsfs__DocuSign_Status__c newContractRec : (List<dsfs__DocuSign_Status__c>)pNewRecList){
            //THIS IS FOR Bank-Account-Change
            if ((newContractRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeCompleted) &&
                (newContractRec.Document_Type__c == DocusignAPIUtil.mDocumentTypeBankAccountChange)){
                    System.debug(logginglevel.error,newContractRec.dsfs__Envelope_Status__c);
                    
                    if(contractMap.get(assignmentMap.get(newContractRec.Assignment_Name__c).fsServ__Lending_Contract_Number__c).fsServ__Product_Code__c == 'DNL') {
                        DNLContractList.add(contractMap.get(assignmentMap.get(newContractRec.Assignment_Name__c).fsServ__Lending_Contract_Number__c));
                    }
                    if(contractMap.get(assignmentMap.get(newContractRec.Assignment_Name__c).fsServ__Lending_Contract_Number__c).fsServ__Product_Code__c == 'VCL') {
                        VCLContractList.add(contractMap.get(assignmentMap.get(newContractRec.Assignment_Name__c).fsServ__Lending_Contract_Number__c));
                    }
                    
                    //getTaskList(DNLContractList, 'DNL_Bank_Account_Change_Request');
                    //getTaskList(VCLContractList, 'VCL_Bank_Account_Change_Request');
                    
                    fsCore.ActionInput acInput = new fsCore.ActionInput();
                    acInput.addRecords(assignmentMap.keySet());
                    BankAccountChangeAction action = new BankAccountChangeAction();
                    action.setInput(acInput);
                    action.process();
                    fsCore.ActionOutput acOutput = action.getOutput();
                    
                    bankAccountChangeCompletedEnvelopeIds.add(newContractRec.dsfs__DocuSign_Envelope_ID__c);
                    docusignIDToContractIdMap.put(newContractRec.dsfs__DocuSign_Envelope_ID__c , assignmentMap.get(newContractRec.Assignment_Name__c).fsServ__Lending_Contract_Number__c);
                    // contractMap.put(newContractRec.dsfs__DocuSign_Envelope_ID__c,newContractRec.Lending_Contract__c);
                    envelopeName.put(newContractRec.dsfs__DocuSign_Envelope_ID__c,newContractRec.Name);
                }  
            if ((newContractRec.dsfs__Envelope_Status__c == DocusignAPIUtil.mDocusignEnvelopeSent) &&
                (newContractRec.Document_Type__c == DocusignAPIUtil.mDocumentTypeBankAccountChange)){
                    System.debug(logginglevel.error,newContractRec.dsfs__Envelope_Status__c);
                    bankAccountChangeSentEnvelopeIds.add(newContractRec.dsfs__DocuSign_Envelope_ID__c);
                    docusignIDToContractIdMap.put(newContractRec.dsfs__DocuSign_Envelope_ID__c , assignmentMap.get(newContractRec.Assignment_Name__c).fsServ__Lending_Contract_Number__c);
                    //  contractMap.put(newContractRec.dsfs__DocuSign_Envelope_ID__c,newContractRec.Lending_Contract__c);
                    envelopeName.put(newContractRec.dsfs__DocuSign_Envelope_ID__c,newContractRec.Name);
                    
                    if (newContractRec.Loan_Officer__c != null){
                        bankAccountChangeSentDocsList.add(newContractRec);
                    }
                }   
            
        }
        
        
        if (bankAccountChangeCompletedEnvelopeIds.size() >0 ){
            SendToDocuSignController.copyDocusignToBoxForContract(bankAccountChangeCompletedEnvelopeIds,docusignIDToContractIdMap,envelopeName,'BANK-Account-Change Document');
        }
        if (bankAccountChangeSentEnvelopeIds.size() >0 ){
            SendToDocuSignController.copyDocusignToBoxForContract(bankAccountChangeSentEnvelopeIds,docusignIDToContractIdMap,envelopeName,'BANK-Account-Change Document Unsigned');
        }        
        
        if(DNLContractList.size()>0) {
            taskList.addAll(getTaskList(DNLContractList , 'DNL_Bank_Account_Change_Request'));
        }
        if(VCLContractList.size()>0) {
            taskList.addAll(getTaskList(VCLContractList , 'VCL_Bank_Account_Change_Request'));
        }
        
        if(taskList.size()>0){
            insert taskList;
        }
    }
    
    private List<Task> getTaskList(List<fsServ__Lending_Contract__c> pRecList, String pTaskCode){
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        
        for (fsServ__Lending_Contract__c lcontract: pRecList){
            TaskObject tsk =  new TaskObject(lcontract);
            
            tsk.setTaskDescription('Client ' + lcontract.fsServ__Title__c +' has returned their ATD/ACH form. Please upload it to the appropriate processor.');
            tsk.setTaskDueDateTime(System.now());
            taskObjectList.add(tsk);
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        
        return TaskHandler.updateDueDateToBusinessDate(TaskHandler.getTasks(taskObjectMap),true);
        
    }
    
    
}