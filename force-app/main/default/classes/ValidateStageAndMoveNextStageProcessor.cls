/**
 * @File Name          : ValidateStageAndMoveNextStageProcessor.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 3/31/2020, 8:11:35 AM
 * @Modification Log   : 
 * Ver       Date            Author             Modification
 * 1.0    11/12/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class ValidateStageAndMoveNextStageProcessor {
    
    public static void process(Set<Id> pLendingApplicationIds){
        

        fsCore.ActionInput actionIP = new fsCore.ActionInput();
        actionIP.addRecords(pLendingApplicationIds);
        fsCore.ApplicationValidateStageActionProcessor action = new fsCore.ApplicationValidateStageActionProcessor();
        action.setInput(actionIP);
        action.process();

        fsCore.LendingApplicationStageTriggerWrapper.getInstance().reset();
        
        system.debug(logginglevel.ERROR,'ApplicationValidateStageActionProcessor :' +action.getOutput());
        
        Set<Id> stageValidatedApplicationIds = new Set<Id>();
        List<fsCore__Lending_Application__c> stageValidatedApplicationRecords 
            = [Select id, Name
               , fsCore__Is_Current_Stage_Validated__c
               , fsCore__Title__c
               , OwnerId
               from fsCore__Lending_Application__c 
               where id in :pLendingApplicationIds];
        
        System.debug(loggingLevel.Error , 'ValidateStageAndMoveNextStageProcessor 8');
        System.debug(loggingLevel.Error , 'stageValidatedApplicationRecords '+ stageValidatedApplicationRecords);
        
        for(fsCore__Lending_Application__c lendingApplication : stageValidatedApplicationRecords){
            if(lendingApplication.fsCore__Is_Current_Stage_Validated__c){
                stageValidatedApplicationIds.add(lendingApplication.id);
            }
        }
        
        system.debug(logginglevel.ERROR,'validated applications' +stageValidatedApplicationIds);
        
        if(stageValidatedApplicationIds.size() > 0){
            System.debug(loggingLevel.Error , 'ValidateStageAndMoveNextStageProcessor 9');
            fsCore.ActionInput actionIP2 = new fsCore.ActionInput();
            actionIP2.addRecords(stageValidatedApplicationIds);
            fsCore.ApplicationCompleteStageActionProcessor action2 = new fsCore.ApplicationCompleteStageActionProcessor();
            action2.setInput(actionIP2);
            action2.process();

            system.debug(logginglevel.ERROR,'ApplicationCompleteStageActionProcessor :' +action2.getOutput());
        }
        system.debug(logginglevel.ERROR,'done' +stageValidatedApplicationIds);
    }    
}