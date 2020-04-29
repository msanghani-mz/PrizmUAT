global class Batch_PostRefresh_Tradeline implements Database.Batchable<sObject>,Database.Stateful,SandboxPostCopy{
    public String query;
    public boolean Sandbx;
    
    public void runApexClass(SandboxContext context) {       //,SandboxPostCopy in first Line
      Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
      if(isSandbx)
          Database.executeBatch(new Batch_PostRefresh_Tradeline(isSandbx));

  }
    public Batch_PostRefresh_Tradeline(boolean b)
    {
       Sandbx=b; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
       
                  query='Select id,nu_dse__Original_Account_Number__c,nu_dse__New_Account_Number__c from nu_dse__TradeLine__c';      
                  return Database.getQueryLocator(query);
       
   }

    global void execute(Database.BatchableContext BC,List<sObject> listSObject){
        if(Sandbx){
           List<nu_dse__TradeLine__c> list_TL = (List<nu_dse__TradeLine__c>) listSObject; 
            for(nu_dse__TradeLine__c tempTL: list_TL){
                tempTL.nu_dse__Original_Account_Number__c = 'TEMP1234';
                tempTL.nu_dse__New_Account_Number__c = 'NEW9876';
            }               
            update list_TL;     
        }
      }
        global void finish(Database.BatchableContext BC){
        }
}