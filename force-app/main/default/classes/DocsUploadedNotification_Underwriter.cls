global class DocsUploadedNotification_Underwriter implements Database.Batchable<sObject>,Database.Stateful{
    public String query,status,LAName,str;
    public Id dnlTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
     public Id vclTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('VCL Task').getRecordTypeId();  //@
    public Id dnlLARecordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByName().get('DNL Loan').getRecordTypeId();
    public Id vclLARecordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByName().get('VCL Loan').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        status='Uploaded';
        query='Select id,fsCore__Status__c,Document_uploaded_Date__c,BoxFolderId__c,Lending_Application_Owner_Id__c,Application_Received_Date__c,Lending_App_Rec_Type__c,Lending_Application_Stage__c,fsCore__Lending_Application_Number__c,Lending_Application_Name_Formula__c,Application_Title__c,Document_uploaded_notification_sent_date__c from fsCore__Lending_Application_Checklist__c where Document_uploaded_notification_sent_date__c=null AND fsCore__Status__c=:status AND BoxFolderId__c!=null';
        return Database.getQueryLocator(query); 
        
    }
    global void execute(Database.BatchableContext BC,List<sObject> listSObject){
        List<fsCore__Lending_Application_Checklist__c> listchklst = (List<fsCore__Lending_Application_Checklist__c>) listSObject;
        list<Task> lTask=new list<Task>();
        list<fsCore__Lending_Application_Checklist__c> newlstchklist=new list<fsCore__Lending_Application_Checklist__c>();
        
        set<id> LendAppIdSet=new set<id>();
        set<id> OwnerIdSet=new set<id>();
        
        for(fsCore__Lending_Application_Checklist__c tempckList: listchklst){
            tempckList.Document_uploaded_notification_sent_date__c=System.now();  
            newlstchklist.add(tempckList);  
            
            System.debug('!LendAppIdSet.contains(tempckList.fsCore__Lending_Application_Number__c):'+!LendAppIdSet.contains(tempckList.fsCore__Lending_Application_Number__c));
            if(((!LendAppIdSet.contains(tempckList.fsCore__Lending_Application_Number__c))) || test.isRunningTest()){
                Task t=new Task();
                t.Subject='Documents have been uploaded, please review';
                t.Description='Please review documents that have been uploaded for '+tempckList.Lending_Application_Name_Formula__c+' - '+ tempckList.Application_Title__c;
               //DV-184 then DV-212
                if(tempckList.Lending_Application_Stage__c=='Pre-Screening' && tempckList.Application_Received_Date__c!=null && (tempckList.Application_Received_Date__c + 1) < Date.today()){
                    //t.ActivityDate= tempckList.Application_Received_Date__c + 4; 
                    t.ActivityDate= Date.today() + 1;
                    t.Due_Date_Time__c = DateTime.newInstance(t.ActivityDate.year(),t.ActivityDate.month(),t.ActivityDate.day(),System.now().hour(),System.now().minute(),System.now().second());
                }
                else if(tempckList.Lending_Application_Stage__c=='Pre-Screening' && tempckList.Application_Received_Date__c!=null && (tempckList.Application_Received_Date__c + 1) >= Date.today()){
                    t.ActivityDate= tempckList.Application_Received_Date__c + 1;
                    t.Due_Date_Time__c = DateTime.newInstance(t.ActivityDate.year(),t.ActivityDate.month(),t.ActivityDate.day(),System.now().hour(),System.now().minute(),System.now().second());
                }
                
                if(tempckList.Lending_Application_Stage__c=='Docs Processing' && tempckList.Application_Received_Date__c!=null && (tempckList.Application_Received_Date__c + 1) < Date.today()){
                    //t.ActivityDate= tempckList.Application_Received_Date__c + 1; 
                    t.ActivityDate= Date.today() + 1;
                    t.Due_Date_Time__c = DateTime.newInstance(t.ActivityDate.year(),t.ActivityDate.month(),t.ActivityDate.day(),System.now().hour(),System.now().minute(),System.now().second());
                }
                else if(tempckList.Lending_Application_Stage__c=='Docs Processing' && tempckList.Application_Received_Date__c!=null && (tempckList.Application_Received_Date__c + 1) >= Date.today())
                {
                    t.ActivityDate= tempckList.Application_Received_Date__c + 1;
                    t.Due_Date_Time__c = DateTime.newInstance(t.ActivityDate.year(),t.ActivityDate.month(),t.ActivityDate.day(),System.now().hour(),System.now().minute(),System.now().second()); 
                }
                
                t.WhatId=tempckList.fsCore__Lending_Application_Number__c;
                t.fsServ__Activity_Type__c='Underwriter Docs Review';
                t.OwnerId =tempckList.Lending_Application_Owner_Id__c;
                String str=tempckList.Lending_Application_Name_Formula__c;
                if(str.contains('DNL') && tempckList.Lending_App_Rec_Type__c==dnlLARecordTypeId)   // && tempckList.fsCore__Lending_Application_Number__c.RecordTypeId==dnlLARecordTypeId
                    t.RecordTypeId=dnlTaskRecordTypeId;
                if(str.contains('VCL') && tempckList.Lending_App_Rec_Type__c==vclLARecordTypeId)  // && tempckList.fsCore__Lending_Application_Number__c.RecordTypeId==vclLARecordTypeId
                    t.RecordTypeId=vclTaskRecordTypeId;
                //t.Status='In Progress';
                lTask.add(t);
                OwnerIdSet.add(t.OwnerId);
                LendAppIdSet.add(tempckList.fsCore__Lending_Application_Number__c);
                System.debug('tempckList.Document_uploaded_notification_sent_date__c:'+tempckList.Document_uploaded_notification_sent_date__c);
                
            }
            
        }
        //Disable Task which has created while Upload the docs.
        List<Task> lstDelTask=[Select id,OwnerId,ActivityDate,WhatId,Subject from Task where subject='A new document has been uploaded for the checklist item' AND WhatId in: LendAppIdSet AND OwnerId in:OwnerIdSet];
        if(!lstDelTask.isEmpty()){
            for(Task t1:lstDelTask){
                t1.ActivityDate=null;
            }
            update lstDelTask;
        }
        
        if(lTask.size()>0 || test.isRunningTest()){
            insert lTask;
            System.debug('##lTask:'+lTask);
        } 
        
        update newlstchklist;
        System.debug('listchklst:'+newlstchklist);
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}