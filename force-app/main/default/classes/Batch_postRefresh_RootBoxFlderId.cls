global class Batch_postRefresh_RootBoxFlderId implements Database.Batchable<sObject>,Database.Stateful,SandboxPostCopy{

     public String query;
     public boolean Sandbx;
    
     public void runApexClass(SandboxContext context) {       
      Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
      if(isSandbx)
          Database.executeBatch(new Batch_postRefresh_RootBoxFlderId(isSandbx));
     }
    public Batch_postRefresh_RootBoxFlderId(boolean b)
    {
       Sandbx=b; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
            
                  query='Select id,Box_Folder_Root_Id__c from fsCore__Product_Setup__c';
                  return Database.getQueryLocator(query); 
             
    }
    global void execute(Database.BatchableContext BC,List<sObject> listSObject){

        if(Sandbx){    
             List<fsCore__Product_Setup__c> list_setup = (List<fsCore__Product_Setup__c>) listSObject; 
        
            for(fsCore__Product_Setup__c tempRootList: list_setup){
                if(tempRootList.Box_Folder_Root_Id__c!=null){
                    tempRootList.Box_Folder_Root_Id__c = '69189686932';
                }
                
            }               
            update list_setup;     
        }
    }
   global void finish(Database.BatchableContext BC){
            
        }
}