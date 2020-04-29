/*PDI-862: Its excecute batches for replacing Box Folder Id of Lending Application first, then Checklist Items, then Finally 
Root box Folder Id of Product setUp by Job Chainning*/

global class Batch_postRefresh_ApplicationBoxFlderId implements Database.Batchable<sObject>,Database.Stateful,SandboxPostCopy{
    
    public String query;
    public boolean Sandbx;
    
    public void runApexClass(SandboxContext context) {       
        Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
        if(isSandbx)
            Database.executeBatch(new Batch_postRefresh_ApplicationBoxFlderId(isSandbx));
    }
    public Batch_postRefresh_ApplicationBoxFlderId(boolean b)
    {
        Sandbx=b; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
            query='Select id,BoxFolderId__c from fsCore__Lending_Application__c';
            return Database.getQueryLocator(query); 
        
    }
    global void execute(Database.BatchableContext BC,List<sObject> listSObject){
        
        if(Sandbx){    
            List<fsCore__Lending_Application__c> list_LendApp = (List<fsCore__Lending_Application__c>) listSObject; 
            
            for(fsCore__Lending_Application__c tempAppList: list_LendApp){
                if(tempAppList.BoxFolderId__c!=null){
                    tempAppList.BoxFolderId__c = 'null';
                }
                
            }               
            update list_LendApp;     
        }
    }
    global void finish(Database.BatchableContext BC){
        Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
        Database.executeBatch(new Batch_postRefresh_checklistBoxFlderId(isSandbx));
    }
}