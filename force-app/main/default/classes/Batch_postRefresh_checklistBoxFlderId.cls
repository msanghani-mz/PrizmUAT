global class Batch_postRefresh_checklistBoxFlderId implements Database.Batchable<sObject>,Database.Stateful,SandboxPostCopy {
    public String query;
    public boolean Sandbx;
    
    public void runApexClass(SandboxContext context) {       
        Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
        if(isSandbx)
            Database.executeBatch(new Batch_postRefresh_checklistBoxFlderId(isSandbx));
        
    }
    public Batch_postRefresh_checklistBoxFlderId(boolean b)
    {
        Sandbx=b; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
            query='Select id,BoxFolderId__c from fsCore__Lending_Application_Checklist__c';
            return Database.getQueryLocator(query); 
       
    }
    global void execute(Database.BatchableContext BC,List<sObject> listSObject){
        
        if(Sandbx){    
            List<fsCore__Lending_Application_Checklist__c> list_checkList = (List<fsCore__Lending_Application_Checklist__c>) listSObject; 
            
            for(fsCore__Lending_Application_Checklist__c tempckList: list_checkList){
                if(tempckList.BoxFolderId__c!=null){
                    tempckList.BoxFolderId__c = 'null';
                }
                
            }               
            update list_checkList;     
        }
    }
    global void finish(Database.BatchableContext BC){
        Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
        Database.executeBatch(new Batch_postRefresh_RootBoxFlderId(isSandbx));
    }
}