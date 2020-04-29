/**
 * Class Name  : ApplicationOwnerHandler
 * Description : This class updates the owner of the lending application
 * Author      : Financial Spectra
 *  DEPRECATED AFTER UnderwriterRoundRobinProcessor IS CREATED.
 */

public with sharing class ApplicationOwnerHandler {
    
    public void updateOwner(List<fsCore__Lending_Application__c> pAppsList) {
    
        Map<Id,Integer> userToCountMap = new Map<Id,Integer>();
        Map<Id,Map<Id,Integer>> stageTouserToCountMap = new Map<Id,Map<Id,Integer>>();
        Map<Id,List<Id>> stageToUserIdsMap = new Map<Id,List<Id>>();
        
        Set<Id> stageIds = new Set<Id> ();
        Set<Id> UserIds = new Set<Id> ();
        Set<Id> currentAppIds = new Set<Id> ();
        for(fsCore__Lending_Application__c app : pAppsList){
            stageIds.add(app.fsCore__Current_Stage_Name__c);
            currentAppIds.add(app.id);
        }
        
        List<AggregateResult> aggResult = [SELECT ownerId //ON ALL DNL APP, IDEALLY Application_Owner_Name__c SHOULD BE SAME AS OWNER ID 
                                                , fsCore__Current_Stage_Name__c stage
                                                , count(Id) num 
                                             FROM fsCore__Lending_Application__c 
                                             where Application_Owner_Assignment_Date__c = :Date.today() //PDI-711 CONSIDER ONLY TODAY'S APPS
                                              AND Application_Owner_Name__c != null //THIS SHOULD NEVER HAPPEN BUT JUST IN CASE.
                                            GROUP BY ownerId, fsCore__Current_Stage_Name__c];

        
        for(AggregateResult agg :aggResult){
            Map<Id,Integer> userToCountMapTemp = new Map<Id,Integer>();

            if (stageTouserToCountMap.containsKey((Id)agg.get('stage'))){
                userToCountMapTemp = stageTouserToCountMap.get((Id)agg.get('stage'));
                userToCountMapTemp.put((Id)agg.get('ownerId'),(Integer)agg.get('num'));
                stageTouserToCountMap.put((Id)agg.get('stage'),userToCountMapTemp);
            }
            else{
                userToCountMapTemp.put((Id)agg.get('ownerId'),(Integer)agg.get('num'));
                stageTouserToCountMap.put((Id)agg.get('stage'),userToCountMapTemp);
            }
        }
        
        for(Stage_Member_Setup__c stage: [SELECT Name, User__c, Stage_Name__c
                                            FROM Stage_Member_Setup__c
                                           WHERE Stage_Name__c in :stageIds
                                             AND Is_Active__c = true //PDI-618
                                             AND User__c != null]){
            if (stageToUserIdsMap.containsKey(stage.Stage_Name__c)) {
                stageToUserIdsMap.get(stage.Stage_Name__c).add(Stage.User__c);
            } 
            else{
                stageToUserIdsMap.put(stage.Stage_Name__c, new List<Id>{Stage.User__c});
            }

            Map<Id,Integer> userToCountMapTemp = new Map<Id,Integer>();

            if (stageToUserToCountMap.containsKey(stage.Stage_Name__c)){
                userToCountMapTemp = stageToUserToCountMap.get(stage.Stage_Name__c);
                if (!userToCountMapTemp.containsKey(Stage.User__c)){
                    //THIS MEANS THE USER IS NOT ASSIGNED TO THE STAGE IN ANY RECORDS 
                    //SET THE DEFAULT COUNT TO 0                    
                    userToCountMapTemp.put(Stage.User__c,0);
                    stageTouserToCountMap.put(stage.Stage_Name__c,userToCountMapTemp);
                }
            }
            else{
                //THIS MEANS THE USER IS NOT ASSIGNED TO THE STAGE IN ANY RECORDS 
                //SET THE DEFAULT COUNT TO 0                
                userToCountMapTemp.put(Stage.User__c,0);
                stageTouserToCountMap.put(stage.Stage_Name__c,userToCountMapTemp);
            }
        }
        
        logmessage('userToCountMap map - '+userToCountMap);
        logmessage('stageToUserIdsMap'+stageToUserIdsMap);
    
        for(fsCore__Lending_Application__c app : pAppsList){
            Integer minCount = 99999;
            Integer maxCount = 0;
            Id minCountUser;
            Id maxCountUser;
            if (app.Application_Owner_Name__c != null){ //PDI-711 IGNORE THE APP WHERE OWNER IS ALREADY POPULATED
                continue;
            }
            if ((stageToUserIdsMap != null)
                && (stageToUserIdsMap.get(app.fsCore__Current_Stage_Name__c) != null)) {
                for(Id usr : stageToUserIdsMap.get(app.fsCore__Current_Stage_Name__c)){
                    userToCountMap = stageTouserToCountMap.get(app.fsCore__Current_Stage_Name__c);
                    //logmessage('MIN COUNT '+minCount+ ' In For '+usr+' '+app.fsCore__Current_Stage_Name_Formula__c+'  For userToCountMap.get(usr) '+userToCountMap.get(usr));
                    
                    
                    if (userToCountMap.get(usr) < minCount){
                        //logmessage('MIN COUNT ASSIGNING'); 
                        minCountUser = usr;
                        minCount = userToCountMap.get(usr);
                    } else if (userToCountMap.get(usr) > maxCount){
                         //logmessage('MAX COUNT USER'); 
                        maxCountUser = usr;
                        maxCount = userToCountMap.get(usr);
                    } else {
                        //logmessage('CONTINUE'); 
                        continue;
                    }
                }
                logmessage('-- minCountUser : ' + minCountUser+' Name: '+app.Name);
                app.Application_Owner_Name__c = minCountUser;
                app.Application_Owner_Assignment_Date__c = Date.today();
                app.ownerId = app.Application_Owner_Name__c;
                userToCountMap.put(minCountUser, userToCountMap.get(minCountUser) + 1);
            }
        }
    }
    
    private void logmessage (Object pMessage){
        system.debug(logginglevel.error,pMessage);
    }

}