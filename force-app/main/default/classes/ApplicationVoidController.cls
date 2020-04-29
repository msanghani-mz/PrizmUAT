/*
* Copyright (c) 2019 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class Name   - ApplicationActionController
*
* Description  - Apex Controller for Calculator Lightning Components
*
* Developer(s) - ASingh
*/
public with sharing class ApplicationVoidController {
    
    /*
* Method to void application
*/
    @AuraEnabled
    public static String voidApplication(id pApplicationId , String pVoidComment){
        System.debug(loggingLevel.ERROR,'voidApplication(+)');
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        actionOP.setIsSuccess(true);
        try
        {    
            fsCore__Lending_Application__c application = fsCore.LendingApplicationUtil.getApplication(pApplicationId);
            if(application.fsCore__Is_Voided__c){
                actionOP.setMessage('Application has already been voided!');
                return actionOP.getJSONString();                
            }
            Map<Id, fsCore__Lending_Application_Stage__c>  mApplicationCurrentStageMap = new Map<Id, fsCore__Lending_Application_Stage__c>();
        
            fsCore.DynamicQueryBuilder applicationStageQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application_Stage__c.getName())
                                                            .addFields()
                                                            .addField('fsCore__Stage_Name__r.fsCore__Selection_Order__c')
                                                            .addWhereConditionWithBind(1,'fsCore__Lending_Application_Number__c','=','pApplicationId')
                                                            .addWhereConditionWithValue(2,'fsCore__Is_Current__c','=',true);
                
            List<fsCore__Lending_Application_Stage__c> applicationStageList = (List<fsCore__Lending_Application_Stage__c>)Database.query(applicationStageQuery.getQueryString());
            for(fsCore__Lending_Application_Stage__c appStage : applicationStageList){
                mApplicationCurrentStageMap.put(appStage.fsCore__Lending_Application_Number__c, appStage);
            }

            Map<Id, fsCore__Lending_Application__c> applicationsToBeVoided = new Map<Id, fsCore__Lending_Application__c>();
            List<fsCore__Lending_Application_Stage__c> currentStages = new List<fsCore__Lending_Application_Stage__c>();


                application.fsCore__Is_Voided__c = true;
                application.fsCore__Is_Application_Read_Only__c = true;
                application.fsCore__Comments__c = pVoidComment;
                applicationsToBeVoided.put(application.id, application);
            
                if (mApplicationCurrentStageMap.containsKey(application.Id)){
                    fsCore__Lending_Application_Stage__c currStage = mApplicationCurrentStageMap.get(application.Id);
                    currStage.fsCore__Stage_Exit_Time__c = Datetime.now();
                    currStage.fsCore__Stage_Status__c = FsCore.Constants.STAGE_STATUS_VOID;
                    currentStages.add(currStage);
                }

            //Update Existing stage 
            if (currentStages.size() > 0){
                fsCore.DMLResult appStageDMLRslt = fsCore.LendingApplicationStageDMLWrapper.getInstance().updateData(currentStages);
                Database.SaveResult[] appStageSR = appStageDMLRslt.getSaveResult();
                for (Integer i = 0; i < appStageSR.size(); i++){
                    if (!appStageSR.get(i).isSuccess()){
                        for(Database.Error err : appStageSR.get(i).getErrors()){
                            System.debug(loggingLevel.ERROR,'err '+err);
                            actionOP.addError(String.valueOf(err.getStatusCode())+ err.getMessage());
                        }
                        applicationsToBeVoided.remove(currentStages.get(i).fsCore__Lending_Application_Number__c);
                    }
                }
            }       

            //save application
            fsCore.DMLResult appDMLRslt = fsCore.LendingApplicationDMLWrapper.getInstance().updateData(applicationsToBeVoided.values());
            if (appDMLRslt.hasErrors()){
                for(fsCore.ErrorObject errObj : appDMLRslt.getErrorList()){
                    actionOP.addError(errObj);
                }
            }
            System.debug(loggingLevel.ERROR,'Final :actionOP '+actionOP);
            if (actionOP.getIsSuccess()){
                actionOP.setMessage(Label.fsCore.Void_Application_Success_Message);
            }            
        }catch(Exception e)
        {
            actionOP.setIsSuccess(false);
            System.debug(loggingLevel.ERROR,e)  ;
            actionOP.addError(e);
        }
        
        
        System.debug(loggingLevel.ERROR,'voidApplication(-)');
        return actionOP.getJSONString();
    }
}