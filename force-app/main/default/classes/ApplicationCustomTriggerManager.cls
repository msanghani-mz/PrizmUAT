/**
* Class Name  : ApplicationCustomTriggerManager
* Description : This class handles the custom logic for fsCore.LendingApplicationTrigger
* Author      : Financial Spectra
* 
*/
global with sharing class ApplicationCustomTriggerManager implements fsCore.TriggerManager {
    
    
    global void beforeInsert(List<sObject> pNewRecList){
        system.debug(logginglevel.error,'ApplicationCustomTriggerManager before insert');
        set<Id> productIds = new set<Id>();
        for(fsCore__Lending_Application__c newLendingApp : (List<fsCore__Lending_Application__c>)pNewRecList){
            productIds.add(newLendingApp.fsCore__Product_Name__c);
        }
        MAP<Id,fsCore__Product_Setup__c> productMap = new MAP<Id,fsCore__Product_Setup__c>([select id,fsCore__Product_Code__c from fsCore__Product_Setup__c where id in :productIds]);
        
        for(fsCore__Lending_Application__c newLendingApp : (List<fsCore__Lending_Application__c>)pNewRecList){
            newLendingApp.loan_type__c = productMap.get(newLendingApp.fsCore__Product_Name__c).fsCore__Product_Code__c;
        }
    }   
    
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        
        for(fsCore__Lending_Application__c newLendingApp : (List<fsCore__Lending_Application__c>)pNewRecList){
            
            fsCore__Lending_Application__c oldLendingApp = (fsCore__Lending_Application__c)pOldRecMap.get(newLendingApp.Id);
            
            //Added the following logic to handle the requirement to move the application to previous status in case
            //Withdraw action rejection and Decline request rejection
            //if restore status flag is true then copy the previous status to status field and clear the previous status field
            if (newLendingApp.Is_Restore_Status__c){
                if(String.IsNotBlank(newLendingApp.Previous_Status__c)){
                    newLendingApp.fsCore__Application_Status__c = newLendingApp.Previous_Status__c;
                    newLendingApp.Previous_Status__c = null;
                    newLendingApp.Is_Restore_Status__c = false;
                }
            } 
            else {
                //when the status changes, stores the previous value in Previous Status field
                if (newLendingApp.fsCore__Application_Status__c != oldLendingApp.fsCore__Application_Status__c){
                    newLendingApp.Previous_Status__c = oldLendingApp.fsCore__Application_Status__c;
                }
            }
            
            
        }
        //SUP-292
        updateOfferAcceptedDate((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        //DV-500
        updateFinalSettlementDate((List<fsCore__Lending_Application__c>) pNewRecList,(Map<Id, fsCore__Lending_Application__c>) pNewRecMap, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        
        //vf-12
        updateInvestorName((List<fsCore__Lending_Application__c>) pNewRecList,(Map<Id, fsCore__Lending_Application__c>) pNewRecMap, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        
         //DV-523, On Status update to COVID-Cancelled , Application to be marked as read only and update DocuSign Status to void
        markAppReadOnlyOnCancellationAction((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        
        markAppReadOnlyOnBookedInLeadtrac((Map<Id, fsCore__Lending_Application__c>) pNewRecMap, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        
        
    }
    
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    
    //custom implementation of after trigger event
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
    
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        updateDoNotCall((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);  
        
        updateApplicationDeclined((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);  
        
        //DV-268, Re-assign open UW tasks when lending application owner is changed
        updateTaskOwnerOnUWChange((List<fsCore__Lending_Application__c>)pNewRecList, (List<fsCore__Lending_Application__c>)pOldRecList, (Map<Id, fsCore__Lending_Application__c>)pNewRecMap, (Map<Id, fsCore__Lending_Application__c>)pOldRecMap);
        //REMOVED THE CALL BECAUSE I WILL CALL THE PROCESS IN ONE GO. PDI-772
        //createBoxFolder((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        createTasks((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        System.debug(logginglevel.error,'Calling triggerNuDebtClientCreationProcess');
        triggerNuDebtClientCreationProcess((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        
        initiateSocureRequest((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        System.debug(logginglevel.error,'Trigger3');
        
        //VF-3, VCL FUNDING Approval process
        ValidateAndcompleteStage((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);    
        createTaskOnFundingRejection((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        //SW-108
        sendUpdateToVelocify((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap); 
        //SUP-458
        //serviceRequestonDecline((List<fsCore__Lending_Application__c>) pNewRecList, (Map<Id, fsCore__Lending_Application__c>) pOldRecMap);
        //DV-574
        createPricingWithAcceptedDraftAmount((List<fsCore__Lending_Application__c>)pNewRecList, (List<fsCore__Lending_Application__c>)pOldRecList, (Map<Id, fsCore__Lending_Application__c>)pNewRecMap, (Map<Id, fsCore__Lending_Application__c>)pOldRecMap);
               
        
      }
    private void createPricingWithAcceptedDraftAmount(List<fsCore__Lending_Application__c> pNewRecList, List<fsCore__Lending_Application__c> pOldRecList, Map<Id, fsCore__Lending_Application__c> pNewRecMap, Map<Id, fsCore__Lending_Application__c> pOldRecMap){
        for(fsCore__Lending_Application__c app : pNewRecMap.values()){
              if(app.Loan_Type__c == 'DNL' && 
               app.fsCore__Application_Status__c == 'Draft Increase Accepted' && 
               app.Requested_Draft_Amount__c != null &&
               pOldRecMap.get(app.Id).fsCore__Application_Status__c != app.fsCore__Application_Status__c &&
               pOldRecMap.get(app.Id).Accepted_Draft_Amount__c == null &&
               pOldRecMap.get(app.Id).Accepted_Draft_Amount__c != app.Accepted_Draft_Amount__c){
                PricingOfferCreation.createPricingOffer(app.Id,app.Accepted_Draft_Amount__c);
        }
    }
    }
    
    private void markAppReadOnlyOnCancellationAction(List<fsCore__Lending_Application__c> pNewAppList,Map<Id, fsCore__Lending_Application__c> pOldAppMap){
        
        System.debug(loggingLevel.Error,'markAppReadOnlyOnCancellationAction:---- +');
        
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('DNL_Read_Only').getRecordTypeId();
        
        Set<ID> appIds = new Set<ID>();
         for(fsCore__Lending_Application__c app : pNewAppList){
             System.debug(loggingLevel.Error,'app.Loan_Type__c+'+app.Loan_Type__c);
             System.debug(loggingLevel.Error,'app.fsCore__Application_Status__c+'+app.fsCore__Application_Status__c);
             System.debug(loggingLevel.Error,' pOldAppMap.get(app.Id).fsCore__Is_Application_Read_Only__c+'+ pOldAppMap.get(app.Id).fsCore__Is_Application_Read_Only__c);
             System.debug(loggingLevel.Error,' pOldAppMap.get(app.Id).fsCore__Application_Status__c+'+ pOldAppMap.get(app.Id).fsCore__Application_Status__c);
             
            if(app.Loan_Type__c == 'DNL' && 
               app.fsCore__Application_Status__c == 'COVID-Cancelled' && 
               pOldAppMap.get(app.Id).fsCore__Is_Application_Read_Only__c == false && 
               pOldAppMap.get(app.Id).fsCore__Application_Status__c != app.fsCore__Application_Status__c ){
                
               System.debug(loggingLevel.Error,'Inside App Cancel --If');
               app.fsCore__Is_Application_Read_Only__c = true;
               app.RecordTypeId = recTypeId;
               appIds.add(app.Id);

            }
        }
        if(!appIds.isEmpty() && appIds.size() >0 ){
            System.debug(loggingLevel.Error,'AppCancelTrigger + appIds:----'+appIds);
            database.executeBatch(new ApplicationWithdrawVoidEnvelopeJob(),5);
        }
        System.debug(loggingLevel.Error,'markAppReadOnlyOnCancellationAction:---- -');
 
    }
    
    private void markAppReadOnlyOnBookedInLeadtrac(Map<Id, fsCore__Lending_Application__c> pNewRecMap,Map<Id, fsCore__Lending_Application__c> pOldAppMap){
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('DNL_Read_Only').getRecordTypeId();
        
        List<fsCore__Lending_Application__c> appList = new List<fsCore__Lending_Application__c>();
         for(fsCore__Lending_Application__c app : pNewRecMap.values()){
             System.debug(loggingLevel.Error,'app.Loan_Type__c+'+app.Loan_Type__c);
             System.debug(loggingLevel.Error,'app.fsCore__Application_Status__c+'+app.fsCore__Application_Status__c);
             System.debug(loggingLevel.Error,' pOldAppMap.get(app.Id).fsCore__Is_Application_Read_Only__c+'+ pOldAppMap.get(app.Id).fsCore__Is_Application_Read_Only__c);
             System.debug(loggingLevel.Error,' pOldAppMap.get(app.Id).fsCore__Application_Status__c+'+ pOldAppMap.get(app.Id).fsCore__Application_Status__c);
             
            if(app.Loan_Type__c == 'DNL' && 
                app.fsCore__Application_Status__c == 'Booked in Leadtrac' && 
                pNewRecMap.get(app.Id).fsCore__Is_Application_Read_Only__c == false && 
                pOldAppMap.get(app.Id).fsCore__Application_Status__c!= app.fsCore__Application_Status__c){

                System.debug(loggingLevel.Error,'Inside App Cancel --If');
                app.fsCore__Is_Application_Read_Only__c = true;
                app.RecordTypeId = recTypeId;
                //appList.add(app);
            }
        }        
         
 
    }
    private void  updateInvestorName(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pNewRecMap, Map<Id, fsCore__Lending_Application__c> pOldAppMap){
        List<fsCore__Lending_Application_Investment__c> investmentRecs = [Select id, Name, fsCore__Account_Name_Formula__c, fsCore__Lending_Application_Number__c from fsCore__Lending_Application_Investment__c where fsCore__Lending_Application_Number__c In :pNewRecMap.keySet()];
        System.debug(loggingLevel.Error, 'investmentRecs:---'+investmentRecs );
        System.debug(loggingLevel.Error, 'investmentRecs:---'+investmentRecs.size());
        Map<Id , String> appIdToInvestAccMap = new Map<Id, String>();
        if(investmentRecs.size()>0){
            for(fsCore__Lending_Application_Investment__c investmentRec : investmentRecs){
                appIdToInvestAccMap.put(investmentRec.fsCore__Lending_Application_Number__c,investmentRec.fsCore__Account_Name_Formula__c);
            }
            System.debug(loggingLevel.Error,'/***************************************************/');
            // Set<ID> appIds = new Set<ID>();
            for(fsCore__Lending_Application__c app : pNewAppList){
                if(appIdToInvestAccMap.containsKey(app.id) && app.Investor_Name__c == null && app.Loan_Type__c == 'VCL'){
                    app.Investor_Name__c = appIdToInvestAccMap.get(app.id); 
                    System.debug(loggingLevel.Error, ' app.Investor_Name__c:---'+ app.Investor_Name__c);
                }
            }
        }
        
    }
    
    private void  updateFinalSettlementDate(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pNewRecMap, Map<Id, fsCore__Lending_Application__c> pOldAppMap){
        System.debug(loggingLevel.Error,'/***************************************************/');
        Set<ID> appIds = new Set<ID>();
        for(fsCore__Lending_Application__c lendingApp : pNewAppList){
            System.debug(loggingLevel.Error,'lendingApp.Final_Settlement_Date__c---'+lendingApp.Final_Settlement_Date__c);
            System.debug(loggingLevel.Error,' lendingApp.Current_Stage_Code_Formula__c---'+ lendingApp.Current_Stage_Code_Formula__c);
            System.debug(loggingLevel.Error,'lendingApp.Loan_Type__c---'+lendingApp.Loan_Type__c);
            System.debug(loggingLevel.Error,' lendingApp.fsCore__Is_Current_Stage_Validated__c---'+lendingApp.fsCore__Is_Current_Stage_Validated__c);
            if(lendingApp.fsCore__Current_Stage_Name_Formula__c == 'Funding' && lendingApp.Current_Stage_Code_Formula__c == 'DNL_FUNDING' && lendingApp.fsCore__Is_Current_Stage_Validated__c == true && lendingApp.Loan_Type__c == 'DNL'){
                appIds.add(lendingApp.Id);
            }
        }
        
        if(appIds.size()>0){
            List<fsCore__Lending_Application_Itemization__c> appItemizations = [Select Id, Name, fsCore__Lending_Application_Number__c, Disbursement_Date__c from fsCore__Lending_Application_Itemization__c where fsCore__Lending_Application_Number__c IN :appIds];
            
            Map<Id, List<fsCore__Lending_Application_Itemization__c>> appIdToAppItemsMap = new Map<Id, List<fsCore__Lending_Application_Itemization__c>>();
            if(appItemizations.size()>0){
                for(fsCore__Lending_Application_Itemization__c appItem : appItemizations){
                    if(appIdToAppItemsMap.KeySet().contains(appItem.fsCore__Lending_Application_Number__c)){
                        List<fsCore__Lending_Application_Itemization__c> appItemList = appIdToAppItemsMap.get(appItem.fsCore__Lending_Application_Number__c);
                        appItemList.add(appItem);
                        appIdToAppItemsMap.put(appItem.fsCore__Lending_Application_Number__c,appItemList);     
                    }
                    else{
                        List<fsCore__Lending_Application_Itemization__c> appItemList = new List<fsCore__Lending_Application_Itemization__c>();
                        appItemList.add(appItem);
                        appIdToAppItemsMap.put(appItem.fsCore__Lending_Application_Number__c,appItemList);  
                    }
                }
                for(Id appId : appIdToAppItemsMap.keySet()){
                    List<fsCore__Lending_Application_Itemization__c> appItems = appIdToAppItemsMap.get(appId);
                    List<date> disbursementDates = new List<date>();
                    for(fsCore__Lending_Application_Itemization__c itemz : appItems){
                        disbursementDates.add(itemz.Disbursement_Date__c);
                    }
                    disbursementDates.sort();
                    fsCore__Lending_Application__c app  = pNewRecMap.get(appId);
                    app.Final_Settlement_Date__c  =  disbursementDates[disbursementDates.size()-1];
                    System.debug(loggingLevel.Error, 'app:--'+ app );
                    System.debug(loggingLevel.Error, 'app:--'+ app.Final_Settlement_Date__c );
                }
            }
            
        }
        
    }
    
    private void sendUpdateToVelocify(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){  
        
        Set<ID> appIds = new Set<ID>();
        
        Map<Id,fsCore__Lending_Application__c> appMap = new Map<Id,fsCore__Lending_Application__c>();
        
        for(fsCore__Lending_Application__c lendingApp : pNewAppList){
            if (((lendingApp.fsCore__Application_Status__c <> pOldAppMap.get(lendingApp.Id).fsCore__Application_Status__c)
                 ||(lendingApp.fsCore__Is_Funded__c <> pOldAppMap.get(lendingApp.Id).fsCore__Is_Funded__c))
                && (lendingApp.Loan_Type__c == 'VCL')
                && ( (lendingApp.fsCore__Application_Status__c == 'Declined')
                    ||(lendingApp.fsCore__Application_Status__c == 'Withdrawn')
                    ||((lendingApp.fsCore__Application_Status__c == 'Funded') || (lendingApp.fsCore__Is_Funded__c)))){
                        
                        appIds.add(lendingApp.Id);
                    }
        }        
        if(!appIds.isEmpty() && appIds.size() >0 ){
            UpdateVelocifyQueueable velocifyReq = new UpdateVelocifyQueueable(appIds);
            ID jobID = System.enqueueJob(velocifyReq);
        }   
    }    
    private void updateTaskOwnerOnUWChange(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        try{
            
            Map<Id,List<Task>>  appIdToTasksMap = new Map<Id,List<Task>>();
            
            Set<Id> appIds = new Set<Id>();
            for(fsCore__Lending_Application__c app: (List<fsCore__Lending_Application__c>)pNewRecList){
                if(app.OwnerId != ((fsCore__Lending_Application__c)pOldRecMap.get(app.Id)).OwnerId){
                    appIds.add(app.Id);
                    appIdToTasksMap.put(app.Id,new List<Task>());
                }
            }
            System.debug(logginglevel.error,'appIds appIds :'+appIds.size());
            if (appIds.size() >0){
                Profile uwProfile  = [SELECT ID
                                      , Name 
                                      FROM Profile 
                                      WHERE Name = 'Underwriter' 
                                      LIMIT 1];
                
                if (uwProfile != null){
                    
                    List<User> userList = [Select id, Name from User where  ProfileId = :uwProfile.Id limit 1];
                    
                    Set<Id> userIdSet = new Set<Id>();
                    for(User usr : userList){
                        userIdSet.add(usr.Id);
                    }
                    if (userIdSet.size() >0 ){
                        
                        List<Task> appOpenTaskToBeUpdated = [SELECT Id
                                                             , Subject
                                                             , OwnerId 
                                                             FROM Task 
                                                             WHERE WhatId IN :appIds 
                                                             AND Status != 'Completed' 
                                                             AND OwnerId In :userIdSet];        
                        
                        
                        for (Task t: appOpenTaskToBeUpdated){
                            if (appIdToTasksMap.containsKey(t.WhatId)){
                                appIdToTasksMap.get(t.WhatId).add(t);
                            }
                        }
                        List<Task> openTaskToBeUpdated = new List<Task>();
                        for(fsCore__Lending_Application__c app: (List<fsCore__Lending_Application__c>)pNewRecList){
                            System.debug(logginglevel.error,'list Size :--'+appIdToTasksMap.get(app.id).size());
                            if(appIdToTasksMap.get(app.id).size()>0){
                                for(Task existingTask : appIdToTasksMap.get(app.id)){
                                    existingTask.OwnerId = app.OwnerId;
                                    openTaskToBeUpdated.add(existingTask);
                                }
                            }
                        }     
                        System.debug(logginglevel.error,' Open Task To Be Updated :'+openTaskToBeUpdated);
                        if(openTaskToBeUpdated.size()>0){
                            update openTaskToBeUpdated;
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug(logginglevel.error,'Exception :'+e);
        }
    }
    
    private void triggerNuDebtClientCreationProcess(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){  
        List<fsCore__Lending_Application__c> appIdList = new List<fsCore__Lending_Application__c>();
        
        for(fsCore__Lending_Application__c lendingApp : pNewAppList){
            
            System.debug(logginglevel.error,' Loan_Type__c :'+lendingApp.Loan_Type__c);
            System.debug(logginglevel.error,' Is_Client_Created__c :'+lendingApp.Is_Client_Created__c);
            System.debug(logginglevel.error,' fsCore__Application_Status__c :'+lendingApp.fsCore__Application_Status__c);
            System.debug(logginglevel.error,' Old fsCore__Application_Status__c :'+(pOldAppMap.get(lendingApp.Id)).fsCore__Application_Status__c);
            
            if ((lendingApp.Loan_Type__c == 'DNL') && 
                (!lendingApp.Is_Client_Created__c) &&
                (lendingApp.fsCore__Application_Status__c <> (pOldAppMap.get(lendingApp.Id)).fsCore__Application_Status__c) &&
                (lendingApp.fsCore__Application_Status__c == SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED)){
                    appIdList.add(lendingApp);
                }
            
            if ((lendingApp.Loan_Type__c == 'VCL') && 
                (!lendingApp.Is_Client_Created__c) &&
                (lendingApp.fsCore__Application_Status__c <> pOldAppMap.get(lendingApp.Id).fsCore__Application_Status__c) &&
                (lendingApp.fsCore__Application_Status__c == SFSConstants.VCL_STATUS_LEAD_UW_APPROVED)){
                    appIdList.add(lendingApp);
                }         
        }  
        
        System.debug(logginglevel.error,' appIdList.size() :'+appIdList.size());
        
        if (appIdList.size() > 0 ){
            System.debug(logginglevel.error,' Calling CreateNuDebtClientAndBankAcctQueueable ' );
            CreateNuDebtClientAndBankAcctQueueable createNuDebtClient = new CreateNuDebtClientAndBankAcctQueueable(appIdList);
            ID jobID = System.enqueueJob(createNuDebtClient);
        }
        
    }
    
    private void createTasks(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){  
        List<fsCore__Lending_Application__c> graduatedApplications = new List<fsCore__Lending_Application__c>();
        List<fsCore__Lending_Application__c> voidedApplications = new List<fsCore__Lending_Application__c>();
        //List<fsCore__Lending_Application__c> NegotiatorsApplications = new List<fsCore__Lending_Application__c>();  //PDI-396
        List<fsCore__Lending_Application__c> draftIncreaseApplications = new List<fsCore__Lending_Application__c>();
        List<fsCore__Lending_Application__c> draftIncreaseAcceptedApplications = new List<fsCore__Lending_Application__c>();
        List<fsCore__Lending_Application__c> draftIncreaseRejectedApplications = new List<fsCore__Lending_Application__c>();
        List<fsCore__Lending_Application__c> contactLoanOfficerApplications = new List<fsCore__Lending_Application__c>();
        //List<fsCore__Lending_Application__c> enterDnlDocProcessing = new List<fsCore__Lending_Application__c>();
        List<fsCore__Lending_Application__c> NSFprogramStatus = new List<fsCore__Lending_Application__c>();//PDI-736
        List<fsCore__Lending_Application__c> UnrespNSFprogramStatus = new List<fsCore__Lending_Application__c>();//PDI-736
        List<fsCore__Lending_Application__c> pendingCancelprogramStatus = new List<fsCore__Lending_Application__c>();//PDI-736
        List<fsCore__Lending_Application__c> ClientCancelledStatus = new List<fsCore__Lending_Application__c>();//PDI-736
        List<fsCore__Lending_Application__c> applicationWithdrawRequest = new List<fsCore__Lending_Application__c>();//DV-72
        list<Task> taskList = new list<Task>();
        
        // List<fsCore__Lending_Application__c> RemindLnOfcrApplications = new List<fsCore__Lending_Application__c>();//PDI-542
        
        
        Map<Id,fsCore__Lending_Application__c> appMap = new Map<Id,fsCore__Lending_Application__c>();
        system.debug(logginglevel.error,'pNewAppList ************************'+pNewAppList.size());
        for(fsCore__Lending_Application__c lendingApp : pNewAppList){
            system.debug(logginglevel.error,'lendingApp ************************'+lendingApp);
            if (lendingApp.Loan_Type__c == 'DNL'){
                
                //DV-119
                if ((lendingApp.fsCore__Is_Voided__c)&&
                    (lendingApp.fsCore__Is_Voided__c <> pOldAppMap.get(lendingApp.Id).fsCore__Is_Voided__c)){
                        voidedApplications.add(lendingApp); 
                    }
                
                //DV-72
                if ((lendingApp.Is_Withdraw_Requested__c)&&
                    (!lendingApp.fsCore__Is_Funded__c)&&
                    (lendingApp.Is_Withdraw_Requested__c <> pOldAppMap.get(lendingApp.Id).Is_Withdraw_Requested__c)){
                        applicationWithdrawRequest.add(lendingApp); 
                    }
                
                if (lendingApp.fsCore__Application_Status__c <> pOldAppMap.get(lendingApp.Id).fsCore__Application_Status__c){
                    //PDI-633 & PDI-419 
                    if (lendingApp.fsCore__Application_Status__c == 'DRP Graduated'){
                        graduatedApplications.add(lendingApp);
                    }                    
                    //PDI-519
                    if (lendingApp.fsCore__Application_Status__c == 'Contact Loan Officer'){
                        contactLoanOfficerApplications.add(lendingApp);
                    }
                    //PDI-519
                    if (lendingApp.fsCore__Application_Status__c =='Draft Increase Requested'){
                        system.debug(logginglevel.error,'Adding to Draft Inc ************************');
                        draftIncreaseApplications.add(lendingApp);
                    }  
                    //DV-158
                    if (lendingApp.fsCore__Application_Status__c =='Draft Increase Accepted'){
                        system.debug(logginglevel.error,'Adding to Draft Inc ************************');
                        draftIncreaseAcceptedApplications.add(lendingApp);
                    } 
                    //DV-158
                    if (lendingApp.fsCore__Application_Status__c =='Draft Increase Rejected'){
                        system.debug(logginglevel.error,'Adding to Draft Inc ************************');
                        draftIncreaseRejectedApplications.add(lendingApp);
                    }  
                    //PDI-396
                    /*   if (lendingApp.fsCore__Application_Status__c =='Negotiations Review'){
system.debug(logginglevel.error,'Negotiations Review ************************');
NegotiatorsApplications.add(lendingApp);
}   */                
                    
                    
                }
                //PDI-736
                if (lendingApp.NuDebt_Program_Status__c <> pOldAppMap.get(lendingApp.Id).NuDebt_Program_Status__c){
                    if (lendingApp.NuDebt_Program_Status__c =='NSF'){
                        NSFprogramStatus.add(lendingApp);
                    }else if (lendingApp.NuDebt_Program_Status__c == 'UnResponsive NSF'){
                        UnrespNSFprogramStatus.add(lendingApp);
                    }else if (lendingApp.NuDebt_Program_Status__c == 'Pending Cancellation'){
                        pendingCancelprogramStatus.add(lendingApp);                            
                    }else if (lendingApp.NuDebt_Program_Status__c == 'Client Cancelled'){
                        ClientCancelledStatus.add(lendingApp);                        
                    }
                }
                
                //PDI-517
                //THE Docs_Processor_Name__c IS POPULATED USING ROUND ROBIN
                //SO WE NEED TO MAKE THIS CHANGE ACCORDINGLY
                /*if ((lendingApp.Docs_Processor_Name__c <> pOldAppMap.get(lendingApp.Id).Docs_Processor_Name__c)
||((lendingApp.Docs_Processor_Name__c != null)<> (pOldAppMap.get(lendingApp.Id).Docs_Processor_Name__c == null))){
if ((lendingApp.Current_Stage_Code_Formula__c =='DNL_DOC_PROCESSING')
&& (lendingApp.Docs_Processor_Name__c != null)){
enterDnlDocProcessing.add(lendingApp);
}
}*/
            }
        }
        
        
        if (voidedApplications.size() > 0){
            system.debug(logginglevel.error,'lendingApp 4 ');
            taskList.addAll(getTaskList(voidedApplications,'DNL_VOIDED_APPLICATION'));
        }        
        //PDI-633 & PDI-419 
        //REMOVED THIS CALL FROM THE TRIGGER
        if (graduatedApplications.size() > 0 || Test.isRunningTest()){ //MZ added Test.isRunningTest
            taskList.addAll(getGraduatedAppTaskList(graduatedApplications,'DNL_CLIENT_GRADUATED_FROM_DRP'));
        }
        //PDI-519
        if (contactLoanOfficerApplications.size() > 0 || Test.isRunningTest()){ //MZ added Test.isRunningTest
            //'Additional information is needed on '
            taskList.addAll(getTaskList(contactLoanOfficerApplications,'DNL_CONTACT_SALES_REP_MORE_INFO'));
        }
        //PDI-519
        system.debug(logginglevel.error,'draftIncreaseApplications ************************'+draftIncreaseApplications.size());
        if (draftIncreaseApplications.size() > 0){
            //'Draft increase required for 
            taskList.addAll(getTaskList(draftIncreaseApplications,'DNL_DRAFT_INCREASE_REQ'));
            system.debug(logginglevel.error,'taskList ************************'+taskList);
        } 
        if (draftIncreaseAcceptedApplications.size() > 0){
            taskList.addAll(getTaskList(draftIncreaseAcceptedApplications,'DNL_DRAFT_INCREASE_ACCEPTED'));
            system.debug(logginglevel.error,'taskList ************************'+taskList);
        } 
        if (draftIncreaseRejectedApplications.size() > 0){
            taskList.addAll(getTaskList(draftIncreaseRejectedApplications,'DNL_DRAFT_INCREASE_DECLINED'));
            system.debug(logginglevel.error,'taskList ************************'+taskList);
        } 
        //PDI-396/723
        /* if (NegotiatorsApplications.size() > 0){
GroupTaskHandler_LendingApp.createNegotiatorGroupTask(NegotiatorsApplications,'DNL_REVIEW_FOR_NEGOTIATIONS','DNL Negotiations Reviews');
} */ 
        //PDI-517 MOVED THIS CODE TO DocProcessorRoundRobinProcessor
        //BECAUSE THE Docs_Processor_Name__c IS POPULATED USING ROUND ROBIN
        // SO THE ASSIGNMENT OF TASK SHOULD BE DONE ONLY ONCE THE Docs_Processor_Name__c IS POPULATED
        //if (enterDnlDocProcessing.size() > 0){
        //    taskList.addAll(getTaskList(enterDnlDocProcessing,'DNL_APP_IN_DOC_PROCESSING'));
        //}          
        /*//PDI-542
if (RemindLnOfcrApplications.size() > 0){
NegotiatorsScheduledClass nsh=New NegotiatorsScheduledClass(RemindLnOfcrApplications);

} */  
        //PDI-736
        if (NSFprogramStatus.size() > 0){
            taskList.addAll(getTaskList(NSFprogramStatus,'DNL_PROGRAM_STATUS_NSF'));
        } 
        if (UnrespNSFprogramStatus.size() > 0){
            taskList.addAll(getTaskList(UnrespNSFprogramStatus,'DNL_PROGRAM_STATUS_UNRESP_NSF'));
        } 
        if (pendingCancelprogramStatus.size() > 0){
            taskList.addAll(getTaskList(pendingCancelprogramStatus,'DNL_PROGRAM_STATUS_PENDING_DRP_CANCEL'));
        } 
        if (ClientCancelledStatus.size() > 0){
            taskList.addAll(getTaskList(ClientCancelledStatus,'DNL_PROGRAM_STATUS_CLIENT_CANCEL'));
        } 
        //DV-72
        if (applicationWithdrawRequest.size() > 0){
            taskList.addAll(getTaskList(applicationWithdrawRequest,'DNL_APP_WITHDRAW_REQUEST'));
        }        
        
        system.debug(logginglevel.error,'taskList SIZE ************************'+taskList.size());
        if (taskList.size()>0){
            system.debug(logginglevel.error,'taskList ************************'+taskList);
            insert taskList;
            system.debug(logginglevel.error,'taskList ***************DONE *********'+taskList);
        }
        
    }
    
    private List<Task> getGraduatedAppTaskList(List<fsCore__Lending_Application__c> pRecList, String pTaskCode){
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        list<user> luser=[SELECT Id FROM User WHERE Profile.Name = 'DNL UnderWriting Manager' and isActive = true];
        for (fsCore__Lending_Application__c lApp: pRecList){
            for(user u:luser){
                TaskObject tsk =  new TaskObject(lApp);
                tsk.setUserId(u.id);
                taskObjectList.add(tsk);
            }
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        return TaskHandler.getTasks(taskObjectMap);
        
    }   
    private List<Task> getTaskList(List<fsCore__Lending_Application__c> pRecList, String pTaskCode){
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        for (fsCore__Lending_Application__c lApp: pRecList){
            TaskObject tsk =  new TaskObject(lApp);
            if ((pTaskCode  == 'DNL_CONTACT_SALES_REP_MORE_INFO')
                ||(pTaskCode  == 'DNL_VOIDED_APPLICATION')
                ||(pTaskCode  == 'DNL_DRAFT_INCREASE_REQ')
                ||(pTaskCode == 'DNL_DRAFT_INCREASE_ACCEPTED')
               ){
                   tsk.setTaskDescription(lApp); //SETTING THIS WILL PUT THE FSCORE__COMMENTS__C TO DESCRIPTION
               }
            
            //Special Handling of WithDraw Request
            if (pTaskCode  == 'DNL_APP_WITHDRAW_REQUEST'){
                String description = 'Withdraw Reason: '+lApp.Withdraw_Reason__c;
                if (lApp.Withdraw_Comments__c != null){
                    description = description+'('+lApp.Withdraw_Comments__c+')';
                }
                tsk.setTaskDescription(description);
            }
            //Special Handling of Draft Increase Request
            if (pTaskCode  == 'DNL_DRAFT_INCREASE_REQ'){
                if (lApp.Draft_Increase_Request_Comments__c != null){
                    tsk.setTaskDescription('Requested Draft Amount:'+lApp.Requested_Draft_Amount__c+'\n Underwriter Comments: '+lApp.Draft_Increase_Request_Comments__c);
                }
                
            }            
            
            //Special Handling of Draft Increase Accepted
            if (pTaskCode  == 'DNL_DRAFT_INCREASE_ACCEPTED'){
                if (lApp.Draft_Increase_Request_Comments__c != null){
                    tsk.setTaskDescription('Applicant has accepted a higher draft amount of '+ lApp.Accepted_Draft_Amount__c+'. A new pricing offer has been created, please proceed with this application. ');
                }
                
            }  
            
            taskObjectList.add(tsk);
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        return TaskHandler.getTasks(taskObjectMap);
        
    }
    private void updateDoNotCall(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){  
        
        
        Map<Id,fsCore__Lending_Application__c> appMap = new Map<Id,fsCore__Lending_Application__c>();
        Set<ID> programIds = new Set<ID>();
        MAP<ID,ID> programIdToAppMap = new Map <ID,ID>();
        List<fsCore__Lending_Application_Customer__c> customerForUpdate = new List<fsCore__Lending_Application_Customer__c>();
        
        for(fsCore__Lending_Application__c lendingApp : pNewAppList){
            if (lendingApp.Is_Client_Not_Interested__c <> pOldAppMap.get(lendingApp.Id).Is_Client_Not_Interested__c){
                if (lendingApp.Is_Client_Not_Interested__c){
                    appMap.put(lendingApp.Id, lendingApp);
                    if (lendingApp.Import_Program_Id__c != null){
                        programIds.add(Id.valueOf(lendingApp.Import_Program_Id__c));
                        programIdToAppMap.put(Id.valueOf(lendingApp.Import_Program_Id__c),lendingApp.Id);
                    }                
                }
            }
        }
        
        for(fsCore__Lending_Application_Customer__c customer : [SELECT Id, fsCore__Lending_Application_Number__c
                                                                , fsCore__Do_Not_Call__c
                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                WHERE fsCore__Lending_Application_Number__c IN : appMap.keySet()]){
                                                                    customer.fsCore__Do_Not_Call__c = appMap.get(customer.fsCore__Lending_Application_Number__c).Is_Do_Not_Call__c;
                                                                    customerForUpdate.add(customer);
                                                                }
        
        if(!customerForUpdate.isEmpty()){
            update customerForUpdate; 
            //Call Third Party
            NuDebtIntegrate.updateDNLStatusNotInterested(programIds,programIdToAppMap); 
        }   
    }
    
    private void updateApplicationDeclined(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){  
        
        Set<ID> programIds = new Set<ID>();
        Set<ID> appIds = new Set<ID>();
        Set<ID> appIdsForAANGeneration = new Set<ID>();
        MAP<ID,ID> programIdToAppMap = new Map <ID,ID>();
        
        Map<Id,fsCore__Lending_Application__c> appMap = new Map<Id,fsCore__Lending_Application__c>();
        
        for(fsCore__Lending_Application__c lendingApp : pNewAppList){
            if (lendingApp.fsCore__Application_Status__c <> pOldAppMap.get(lendingApp.Id).fsCore__Application_Status__c){
                system.debug(logginglevel.error,' Status : '+lendingApp.fsCore__Application_Status__c);
                if (lendingApp.fsCore__Application_Status__c == 'Declined'){
                    if (lendingApp.Loan_Type__c == 'DNL'){
                        appMap.put(lendingApp.Id, lendingApp);
                    }
                    //SUP-354
                    if (lendingApp.Loan_Type__c == 'VCL'){
                        appIdsForAANGeneration.add(lendingApp.Id);
                    }
                    appIds.add(lendingApp.Id);
                    if (lendingApp.Import_Program_Id__c != null){
                        programIds.add(Id.valueOf(lendingApp.Import_Program_Id__c));
                        programIdToAppMap.put(Id.valueOf(lendingApp.Import_Program_Id__c),lendingApp.Id);
                    }                     
                }
                
            }
        }
        //SUP-354
        if(appIdsForAANGeneration.size()>0){
            
            //generateAAN(appIdsForAANGeneration);              
        }
        if (appIds.size() >0){
            sendAdverseActionEmail(appIds);
        }
        
        if(!appMap.isEmpty() && appMap.size() >0 ){
            //Call Third Party
            NuDebtIntegrate.updateDNLStatusDeclined(programIds,programIdToAppMap); 
        }   
    }
    //SUP-354
    /*@future(callout=true)
private static void generateAAN(Set<id> appIds){
if(appIds.size()>0){
fsCore.ActionInput actionIP = new fsCore.ActionInput();
actionIP.addRecords(appIds);
GenerateAANAction action = new GenerateAANAction();
action.setInput(actionIP);
action.process();

}              
}   */ 
    
    private static void sendAdverseActionEmail(Set<ID> applicationIDs) {
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIDs);
        
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.ADVERSE_ACTION_NOTICE);
        notifyAction.process();
        fsCore.ActionOutput acOutput = notifyAction.getOutput();
        
        system.debug(logginglevel.error,' acOutput.getIsSuccess() : '+acOutput.getIsSuccess());
        
        if (!acOutput.getIsSuccess()){ acOutput.throwError(); }
    }    
    
    //PDI-772 Commented Box FOLDER CREATION LOGIC
    /*private void createBoxFolder(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){  
Set<Id> appIdSet = new Set<Id>();

for(fsCore__Lending_Application__c lendingApp : pNewAppList){
if (String.IsBlank(lendingApp.BoxFolderId__c)
&& lendingApp.Name != pOldAppMap.get(lendingApp.Id).Name){
appIdSet.add(lendingApp.Id);
}
}

if (appIdSet.size() > 0){
CreateBoxFolderHandler.createFolderAsync(appIdSet);
}
}*/
    
    private static void initiateSocureRequest(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap) {
        //InitiateSocureQueueable socureRequest = new InitiateSocureQueueable(pNewRecMap.keySet());
        //ID jobID = System.enqueueJob(socureRequest);
        System.debug(logginglevel.error,'Trigger1');
        Set<id> appIds = new Set<id>();
        for(fsCore__Lending_Application__c app : pNewAppList){
            if((app.Loan_Type__c == 'VCL') && (app.Is_User_Registration_Completed__c) && (!pOldAppMap.get(app.Id).Is_User_Registration_Completed__c)){
                appIds.add(app.id);
                break;// through trigger , I can only submit for one application , If there are more than one 1 application ... We will have to create a batch job to handle more than one application.
            }
        }
        if(appIds.size()>0){
            System.debug(logginglevel.error,'Trigger2');
            
            List<fsCore__Lending_Application_Customer__c> applicantList = [Select id ,
                                                                           fsCore__Customer_Type__c,
                                                                           fsCore__Lending_Application_Number__c
                                                                           from fsCore__Lending_Application_Customer__c
                                                                           where fsCore__Lending_Application_Number__c in :appIds
                                                                           Order By fsCore__Customer_Type__c];
            
            Map<id,Set<id>> mapApplicationToApplicantIds = new Map<id,Set<id>>();
            
            for(fsCore__Lending_Application_Customer__c applicant : applicantList){
                
                if(mapApplicationToApplicantIds.keySet().contains(applicant.fsCore__Lending_Application_Number__c)){
                    Set<id> applicantIds = mapApplicationToApplicantIds.get(applicant.fsCore__Lending_Application_Number__c);
                    if(applicantIds.size()==1){
                        applicantIds.add(applicant.id);
                        mapApplicationToApplicantIds.put(applicant.fsCore__Lending_Application_Number__c,applicantIds);
                    }
                    
                }
                else{
                    Set<id> applicantIds = new Set<id>{applicant.id};
                        mapApplicationToApplicantIds.put(applicant.fsCore__Lending_Application_Number__c,applicantIds);
                }
            }
            Set<id> customerIds = new Set<id>();
            for(id applicationId : mapApplicationToApplicantIds.KeySet()){
                customerIds.addAll(mapApplicationToApplicantIds.get(applicationId));
            }
            
            for(id applicantId : customerIds){
                Set<id> applicant = new Set<id>{applicantId};
                    InitiateSocureQueueable socureRequest = new InitiateSocureQueueable(applicant);
                ID jobID = System.enqueueJob(socureRequest);   
            }
            
        }
        
    }
    private static void updateOfferAcceptedDate(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){
        Set<id> appIds = new Set<id>();
        for(fsCore__Lending_Application__c app : pNewAppList){
            if((app.fsCore__Record_Type_Formula__c == 'VCL_Loan') && (app.fsCore__Application_Status__c == 'Offer Accepted') && (pOldAppMap.get(app.Id).fsCore__Application_Status__c != 'Offer Accepted')){
                app.Offer_Accepted_Date__c = System.today();
                appIds.add(app.id);
            }
        }
        if(appIds.size()>0){
            GetVCLCreditReportQueueable obj = new GetVCLCreditReportQueueable(appIds);
            ID jobID = System.enqueueJob(obj);  
        }
        
    }
    private static void ValidateAndcompleteStage(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap) {
        system.debug(logginglevel.error,'inside ValidateAndcompleteStage');
        Set<id> lendingApplicationIds = new Set<id>();
        for(fsCore__Lending_Application__c app : pNewAppList){
            system.debug(logginglevel.error,'app.Loan_Type__c :'+app.Loan_Type__c);
            system.debug(logginglevel.error,'app.Is_Doc_Processing__c :'+app.Is_Doc_Processing__c);
            system.debug(logginglevel.error,'app.Current_Stage_Code_Formula__c :'+app.Current_Stage_Code_Formula__c);
            System.debug(loggingLevel.ERROR,'app:---'+app);
            System.debug(loggingLevel.ERROR,'appLoantype:---'+app.Loan_Type__c);
            System.debug(loggingLevel.ERROR,'appStageValidated:---'+app.fsCore__Is_Current_Stage_Validated__c);
            System.debug(loggingLevel.ERROR,'appApproved:---'+app.Is_Funding_Approved__c);
            // System.debug(loggingLevel.ERROR,'appDueDate:---'+app.Funding_Approval_Due_Date__c);
            System.debug(loggingLevel.ERROR,'appContractTemplate:---'+app.fsCore__Is_Contract_Template_Applied__c);
            System.debug(loggingLevel.ERROR,'appFunded--'+app.fsCore__Is_Funded__c);
            
            //THIS IS FOR THE CASES WHERE THE Is_Doc_Processing__c IS UPDATED TO TRUE BY PORTAL
            //WE NEED TO VALIDATE AND MOVE SUCH APPLICATIONS
            if((app.Loan_Type__c == 'VCL') && 
               (app.Is_Doc_Processing__c && !app.fsCore__Is_Application_Read_Only__c) && 
               (!pOldAppMap.get(app.Id).Is_Doc_Processing__c) &&
               (app.Current_Stage_Code_Formula__c == 'PL_PRE_SCREEN')){
                   
                   lendingApplicationIds.add(app.id);
               }
            if((app.Loan_Type__c == 'VCL') && 
               (app.Funding_Approval_Due_Date__c != null) && 
               (app.fsCore__Is_Contract_Template_Applied__c) && 
               ((app.Is_Funding_Approved__c) && (!pOldAppMap.get(app.Id).Is_Funding_Approved__c)) &&
               (!app.fsCore__Is_Funded__c) &&
               (app.Current_Stage_Code_Formula__c == 'PL_FUNDING')){
                   
                   lendingApplicationIds.add(app.id);
               }            
        }    
        system.debug(logginglevel.error,'lendingApplicationIds :'+lendingApplicationIds.size());
        if (lendingApplicationIds.size()>0){
            system.debug(logginglevel.error,'Enque');
            try{
                //execute the logic to validate and complete the stage using Platform Event
                List<Complete_Stage__e> completeStageEvents = new List<Complete_Stage__e>();
                for (Id appId : lendingApplicationIds){
                    completeStageEvents.add(new Complete_Stage__e(Lending_Application_ID__c=String.valueOf(appId)));
                }
                if (completeStageEvents.size() > 0){
                    System.debug(loggingLevel.ERROR, '-- raising Complete Stage events : ' + completeStageEvents);
                    EventBus.publish(completeStageEvents);
                    
                }
                //moving the logic to platform event to overcome system permissions for portal user  
                //System.enqueueJob(new ValidateStageAndMoveNextStageQueueable(lendingApplicationIds));
            }catch(exception e){
                system.debug(logginglevel.error,'except :'+e);
                throw e;
            }
        }         
    }
    
    private static void createTaskOnFundingRejection (List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){
        List<Task> taskList = new List<Task>();
        for(fsCore__Lending_Application__c app : pNewAppList){
            if((app.Is_Funding_Rejected__c) && (!pOldAppMap.get(app.Id).Is_Funding_Rejected__c)){
                Task t = new Task();
                t.OwnerId = app.OwnerId;
                t.WhatId = app.id;
                t.ActivityDate = Date.Today().addDays(1);
                t.Subject = 'Loan not funded';
                t.Status = 'Open';
                t.Priority = 'High';
                t.Description = 'Consolidation loan '+app.Name+' has not been funded. Please contact the finance team for next steps.';
                taskList.add(t);
            }
        }
        if(taskList.size()>0){
            insert taskList;   
        }        
    }
    //ticket Number-458
     /*private void serviceRequestonDecline(List<fsCore__Lending_Application__c> pNewAppList, Map<Id, fsCore__Lending_Application__c> pOldAppMap){  
        
        Set<ID> appIds = new Set<ID>();
        
        Map<Id,fsCore__Lending_Application__c> appMap = new Map<Id,fsCore__Lending_Application__c>();
        
        for(fsCore__Lending_Application__c lendingApp : pNewAppList){
            if ((lendingApp.fsCore__Application_Status__c <> pOldAppMap.get(lendingApp.Id).fsCore__Application_Status__c) && (lendingApp.Loan_Type__c == 'VCL') && (lendingApp.fsCore__Application_Status__c == 'Declined') && (lendingApp.fsCore__Current_Stage_Name_Formula__c == 'Pre-Screening')){
                
                appIds.add(lendingApp.Id);
            }
        }        
        if(!appIds.isEmpty() && appIds.size() >0 ){
            System.enqueueJob(new InitiateLobQueueable(appIds));  
        }
    }  */ 
    
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
    
}