global class Batch_PostRefresh_BankAcc implements Database.Batchable<sObject>,Database.Stateful,SandboxPostCopy {
    public String query;
    public boolean Sandbx;
    
   public void runApexClass(SandboxContext context) {       //,SandboxPostCopy in first Line
      Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
      if(isSandbx)
          Database.executeBatch(new Batch_PostRefresh_BankAcc(isSandbx));

  }
    public Batch_PostRefresh_BankAcc(boolean b)
    {
       Sandbx=b; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
                
               query='Select id,nu_dse__Bank_Account_Number__c,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c from nu_dse__Bank_Account__c';      
               return Database.getQueryLocator(query);
            
   }

    global void execute(Database.BatchableContext BC,List<sObject> listSObject){
        if(Sandbx){
            List<nu_dse__Bank_Account__c> list_BA = (List<nu_dse__Bank_Account__c>) listSObject; 
        
            for(nu_dse__Bank_Account__c tempBA: list_BA){
                tempBA.nu_dse__Bank_Account_Number__c = 'B326782';
            }               
            update list_BA;  
        }
    }
        global void finish(Database.BatchableContext BC){
            Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
            Database.executeBatch(new Batch_PostRefresh_Contact(isSandbx));
        }
}