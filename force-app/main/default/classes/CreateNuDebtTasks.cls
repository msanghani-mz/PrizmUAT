@RestResource(urlMapping='/CreateTasks/*')
global class CreateNuDebtTasks{
    
    @HttpPost
    global Static void CreateTasks(){
        String jsonStr = '';
        
        if ( !Test.isRunningTest() && RestContext.request.requestBody != NULL)
            jsonStr = RestContext.request.requestBody.toString();    
        else{
            List<Task> TaskList = new List<Task>();
            Task t = new Task();
            t.Due_Date_Time__c = System.now();
            t.ActivityDate = Date.today();
            t.Status = 'Not Started';
            t.WhatId = '006m000000B312yAAB';
            t.Id = '00Tm000000S53sg';
            t.Priority = 'Normal';
            t.subject = 'Test';
            TaskList.add(t);
            jsonStr = JSON.serialize(TaskList);
        }
        System.debug(jsonStr);
        
        List<Task> TaskList = (List<Task>)JSON.deserialize(jsonStr,List<Task>.class);
        List<Id> OpportunityIds = new List<Id>();
        Map<String,List<Task>> oppTaskMap = new Map<String,List<Task>>();
        List<Task> TaskCreationList = new List<Task>();
        Id DNLTaskId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
        for(Task t : TaskList){
            Task newTsk = new Task();
            //Opportunity opp = new Opportunity(Import_Id__c = t.whatId);
            newTsk.priority = t.priority;
            newTsk.ActivityDate = t.ActivityDate;
            newTsk.Status = t.Status;
            newTsk.Subject = t.Subject;
            newTsk.Description = t.Description;
            newTsk.Import_Id__c = t.Id; 
            newTsk.RecordTypeId = DNLTaskId;
            if (t.Due_Date_Time__c != null){ //FS FOR NULL POINTER
                newTsk.Due_Time__c = t.Due_Date_Time__c.Time();
                newTsk.Due_Date_Time__c=t.Due_Date_Time__c;
            }
            else{
                Date d=t.ActivityDate;
                newTsk.Due_Date_Time__c=DateTime.newInstance(d.Year(), d.month(), d.day(), 9, 0, 0);
            }
            
            if(!oppTaskMap.containsKey(t.whatId)){
                oppTaskMap.put(t.whatId,new List<Task>());
            }
            oppTaskMap.get(t.whatId).add(newTsk);
            //TaskCreationList.add(newTsk);
            OpportunityIds.add(t.WhatId);
            //TaskList.add(newTsk);
        }
        
        Map<String,Opportunity> OpportunityIdMap = new Map<String,Opportunity>();
        for(Opportunity oppo : [Select Id, OwnerId, Import_Id__c from Opportunity where Import_Id__c=:OpportunityIds]){
            OpportunityIdMap.put(oppo.Import_Id__c,oppo);
        }
        System.debug(OpportunityIdMap);
        System.debug(OpportunityIds);
        for(String whatId : oppTaskMap.keySet()){
            Id oppId = opportunityIdMap.get(whatId).Id;
            Id OwnerId = opportunityIdMap.get(whatId).ownerId;
            for(Task t : oppTaskMap.get(whatId)){
                t.whatId = oppId;
                t.OwnerId = OwnerId;
                TaskCreationList.add(t);
            }
        }
        Database.SaveResult[] insTaskResults = Database.insert(TaskCreationList);
        system.debug(logginglevel.error,'****insTaskResults::'+insTaskResults);
    }
}