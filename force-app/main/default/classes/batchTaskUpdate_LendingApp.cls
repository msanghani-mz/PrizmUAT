global class batchTaskUpdate_LendingApp implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //query on Group Task
        /*Set<Id> taskIds = new Set<Id>();
        for(nu_dse__Group_Task__c g : taskIds){
            taskIds.add(g.Id);
        }*/
        String query = 'SELECT Id,nu_dse__Type__c,nu_dse__Subject__c FROM nu_dse__Group_Task__c WHERE nu_dse__Subject__c = \'DNL_REVIEW_FOR_NEGOTIATIONS\' LIMIT 3';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Group_Task__c > scope)
    { 
        set<id> GTId=new set<id>();
        List<Task> NewTask=new  list<Task>();
        for(nu_dse__Group_Task__c t1:scope)
        {
           GTId.add(t1.id);            
        }
        for(Task  a : [SELECT Subject, WhatId,nu_dse__Group_Task__c, ActivityDate, fsServ__Activity_Type__c, Status FROM Task where nu_dse__Group_Task__c in: GTId])
        {   
            //Updating Task subject and Task Type
            a.Subject ='DNL Review for Negotiations';
            a.fsServ__Activity_Type__c  = 'Negotiations Review';
            NewTask.add(a);
        }
        if(NewTask.size()>0){
           update NewTask;
        }
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}