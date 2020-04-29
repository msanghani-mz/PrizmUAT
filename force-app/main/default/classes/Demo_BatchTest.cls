public class Demo_BatchTest {
   
    public static void MyDemobatchTest()
    {
     String status;
    Id dnlTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
        
        status='Uploaded';
        //LAName='DNL190718005112';
       // 
      list<fsCore__Lending_Application_Checklist__c> fsck=[Select id,fsCore__Status__c,Document_uploaded_Date__c,BoxFolderId__c,Lending_Application_Owner_Id__c,Lending_Application_Name_Formula__c,Document_uploaded_notification_sent_date__c from fsCore__Lending_Application_Checklist__c where Document_uploaded_notification_sent_date__c=null AND BoxFolderId__c!=null AND fsCore__Status__c='Uploaded'];
      set<id> setfck=new set<id>();
       for(fsCore__Lending_Application_Checklist__c fg:fsck) 
           setfck.add(fg.id);
        List<Task> ltask=[Select id,whatId,RecordTypeId from Task where RecordTypeId=:dnlTaskRecordTypeId AND whatId in:setfck];
    set<id> whatchkId=new set<id>();
        String str;
        for(Task t:ltask){
          str=t.WhatId;
          if(str.startsWith('a1M'))
              whatchkId.add(t.whatId);  
        }
      

    list<fsCore__Lending_Application_Checklist__c> lstChklistIt=[Select id,fsCore__Status__c,Document_uploaded_Date__c,Lending_Application_Owner_Id__c,Lending_Application_Name_Formula__c,Document_uploaded_notification_sent_date__c from fsCore__Lending_Application_Checklist__c where fsCore__Status__c=:status AND id Not in:whatchkId];
    System.debug('Checklist:'); 
        For(fsCore__Lending_Application_Checklist__c chk:lstChklistIt){
            system.debug(chk.Id +'\n');
        }
    }
}