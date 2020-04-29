global class Batch_PostRefresh_Contact implements Database.Batchable<sObject>,Database.Stateful,SandboxPostCopy{
    public String query;
    public boolean Sandbx;
    
    public void runApexClass(SandboxContext context) {      
      Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
      if(isSandbx)
         Database.executeBatch(new Batch_PostRefresh_Contact(isSandbx));

  }
    public Batch_PostRefresh_Contact(boolean b)
    {
       Sandbx=b; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
       
                  query='Select id,nu_dse__CFT_Payee_Contact_Id__c,nu_dse__GCS_Payee_Contact_Id__c,nu_dse__RAMS_Payee_Contact_Id__c,fsCore__National_Identification_Number__c from Contact';      
                  return Database.getQueryLocator(query);
       
   }

    global void execute(Database.BatchableContext BC,List<sObject> listSObject){
        if(Sandbx){
            List<contact> list_contact = (List<contact>) listSObject; 
            for(contact tempcon: list_contact){
                if(tempcon.nu_dse__CFT_Payee_Contact_Id__c!=null)
                    tempcon.nu_dse__CFT_Payee_Contact_Id__c = tempcon.nu_dse__CFT_Payee_Contact_Id__c+'11';
                if(tempcon.nu_dse__GCS_Payee_Contact_Id__c!=null)
                    tempcon.nu_dse__GCS_Payee_Contact_Id__c = tempcon.nu_dse__GCS_Payee_Contact_Id__c+'01';
                if(tempcon.nu_dse__RAMS_Payee_Contact_Id__c!=null)
                    tempcon.nu_dse__RAMS_Payee_Contact_Id__c = tempcon.nu_dse__RAMS_Payee_Contact_Id__c+'09';
                if(tempcon.fsCore__National_Identification_Number__c!=null)
                    tempcon.fsCore__National_Identification_Number__c = tempcon.fsCore__National_Identification_Number__c+'08';
            }               
            update list_contact;   
        }
    }
      
        global void finish(Database.BatchableContext BC){
          Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
          Database.executeBatch(new Batch_PostRefresh_Tradeline(isSandbx));  
        }
}