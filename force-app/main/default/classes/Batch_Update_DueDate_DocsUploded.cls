global class Batch_Update_DueDate_DocsUploded implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String TaskSubject='Documents have been uploaded, please review';
        String query = 'SELECT ActivityDate,Status,Subject,whatId,createdDate,Due_Date_Time__c FROM Task where Subject=:TaskSubject AND (createdDate > ActivityDate) ';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Task> scope)
    {
         set<id> setWhatId=new set<id>();
        for(Task t : scope){
            setWhatId.add(t.whatId);
        }
         map<id,fsCore__Lending_Application__c> mapLendApp=new map<id,fsCore__Lending_Application__c>([Select id,Name from fsCore__Lending_Application__c where id in :setWhatId]);
         for(Task t : scope)
         {   
             
             if(mapLendApp.containsKey(t.WhatId) && mapLendApp.get(t.whatId).fsCore__Current_Stage_Name_Formula__c=='Pre-Screening'){
                    //t.ActivityDate= tempckList.Application_Received_Date__c + 4; 
                    t.ActivityDate= Date.valueOf(t.CreatedDate) + 4;
                    t.Due_Date_Time__c = DateTime.newInstance(t.ActivityDate.year(),t.ActivityDate.month(),t.ActivityDate.day(),System.now().hour(),System.now().minute(),System.now().second());
                } 
             else{
                    t.ActivityDate= Date.valueOf(t.CreatedDate) + 1;
                    t.Due_Date_Time__c = DateTime.newInstance(t.ActivityDate.year(),t.ActivityDate.month(),t.ActivityDate.day(),System.now().hour(),System.now().minute(),System.now().second());
             }
         }
         update scope;
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}