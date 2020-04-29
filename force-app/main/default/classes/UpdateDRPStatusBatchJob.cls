global class UpdateDRPStatusBatchJob implements database.Batchable<Sobject>, Database.AllowsCallouts{
    
    global List<Opportunity> start(Database.BatchableContext bc){
        return [select id
                     , stageName
                     , NuDebt_Program_Status__c
                     , Related_Lending_Application__c
                     , Import_Program_Id__c
                  FROM opportunity
                 WHERE (
                        (Related_Lending_Application__r.fsCore__Is_Application_Read_Only__c = false)
                        OR 
                        (Related_Lending_Application__c = null AND Probability >0)
                       )
                   AND Import_Program_Id__c != null 
                 ORDER BY Import_Program_Id__c];
    }

    /*
        This method expects that multiple opportunities or applications can have the same program id
        So, it updates all the opportunities/applications for the program ID.
    */

    global void execute(Database.BatchableContext BC, List<SObject> pScope){
        
        Map<String, List<Opportunity>> programIdToOppMap = new Map<String, List<Opportunity>>();
        Set<String> programIdSet = new Set<String>();
        Set<ID> applicationIdSet = new Set<ID>();
        
        for(Opportunity opp : (List<Opportunity>)pScope) {
            //IF SOMEONE POPULATED THE opp.Import_Program_Id__c WITH THE INVALID ID OR JUNK VALUE THEN SKIP IT
            if (!(opp.Import_Program_Id__c instanceOf Id)){
                continue;
            }
            
            List<Opportunity> relatedOppList = new List<Opportunity>();
            if (programIdToOppMap.containsKey(opp.Import_Program_Id__c)){
                relatedOppList = programIdToOppMap.get(opp.Import_Program_Id__c);
            }
            relatedOppList.add(opp);
            programIdToOppMap.put(opp.Import_Program_Id__c, relatedOppList);
            
            programIdSet.add(opp.Import_Program_Id__c);
            if (opp.Related_Lending_Application__c != null){
                applicationIdSet.add(opp.Related_Lending_Application__c);
            }
        }

        Map<String, List<fsCore__Lending_Application__c>> programIdToAppMap = new Map<String, List<fsCore__Lending_Application__c>>();
        List<fsCore__Lending_Application__c> applicationList = [SELECT Id, Opp_Import_Id__c
                                                                     , NuDebt_Program_Status__c
                                                                     , Import_Program_Id__c
                                                                  FROM fsCore__Lending_Application__c 
                                                                 WHERE Id = :applicationIdSet];
        
        for(fsCore__Lending_Application__c app : applicationList) {
            if (!(app.Import_Program_Id__c instanceOf Id)){
                continue;
            }
            
            List<fsCore__Lending_Application__c> relatedAppList = new List<fsCore__Lending_Application__c>();
            if (programIdToAppMap.containsKey(app.Import_Program_Id__c)){
                relatedAppList = programIdToAppMap.get(app.Import_Program_Id__c);
            }
            relatedAppList.add(app);
            programIdToAppMap.put(app.Import_Program_Id__c, relatedAppList);
        }

        //prepare API request
        List<WS_GetDRPStatusRequest> wsRequest = new List<WS_GetDRPStatusRequest>();
        for(Id programId : programIdSet){
            WS_GetDRPStatusRequest req = new WS_GetDRPStatusRequest ();
            req.ProgramId = programId;
            wsRequest.add(req);
        }

        //invoke API
        WS_GetDRPStatus getStatusAPI = new WS_GetDRPStatus();
        getStatusAPI.setRequest(wsRequest);
        getStatusAPI.invoke();
        List<WS_GetDRPStatusResponse> wsResponse = getStatusAPI.getResponse();
        
        List<opportunity> oppUpdateList = new List<opportunity>();
        List<fsCore__Lending_Application__c> appUpdateList = new List<fsCore__Lending_Application__c>();
        
        for (WS_GetDRPStatusResponse resp : wsResponse){
            System.debug(logginglevel.error,'-- ProgramId = ' + resp.ProgramId);
            
            if (programIdToOppMap.containsKey(resp.ProgramId)){
                for (Opportunity opp : programIdToOppMap.get(resp.ProgramId)){
                    opp.NuDebt_Program_Status__c = resp.ProgramStatus;    
                    oppUpdateList.add(opp);
                }
            }
            if (programIdToAppMap.containsKey(resp.ProgramId)){
                for (fsCore__Lending_Application__c app : programIdToAppMap.get(resp.ProgramId)){
                    app.NuDebt_Program_Status__c = resp.ProgramStatus;
                    appUpdateList.add(app);
                }
            }
        }

        Database.update(oppUpdateList);
        Database.update(appUpdateList);
    }
    
    global void finish(Database.BatchableContext BC){}
}