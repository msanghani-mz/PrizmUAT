global class Batch_pstRefresh_Account implements Database.Batchable<sObject>,Database.Stateful,SandboxPostCopy {
    public String query;
    public boolean Sandbx;
    
    public void runApexClass(SandboxContext context) {       //,SandboxPostCopy in first Line
      Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
      if(isSandbx)
          Database.executeBatch(new Batch_pstRefresh_Account(isSandbx));

  }
    public Batch_pstRefresh_Account(boolean b)
    {
       Sandbx=b; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
              
                  query='Select id,PersonEmail,SSN__c,Transunion_SSN__c,nu_dse__SSN__c,nu_dse__Co_SSN__c,nu_dse__Home_Phone__c,fsCore__Email__c,nu_dse__CO_Email_Address__c,nu_dse__External_GCS_ID__c,nu_dse__External_CFT_ID__c,nu_dse__External_RAMS_ID__c from Account';
                  return Database.getQueryLocator(query); 
             
                 
   }

    global void execute(Database.BatchableContext BC,List<sObject> listSObject){

        if(Sandbx){    
             List<Account> list_Accounts = (List<Account>) listSObject; 
        
            for(Account tempAccount: list_Accounts){
                if(tempAccount.nu_dse__CO_Email_Address__c!=null){
                    tempAccount.nu_dse__CO_Email_Address__c = 'asd'+'.'+ tempAccount.nu_dse__CO_Email_Address__c;
                }
                if(tempAccount.fsCore__Email__c!=null){
                   tempAccount.fsCore__Email__c = 'hjg'+'.'+ tempAccount.fsCore__Email__c;
                }
                
                if(tempAccount.PersonEmail!=null)
                   tempAccount.PersonEmail = 'mail'+'.'+ tempAccount.PersonEmail;
                if(tempAccount.SSN__c!=null)
                   tempAccount.SSN__c = 'TMP1234'; 
                if(tempAccount.Transunion_SSN__c!=null)
                   tempAccount.Transunion_SSN__c = 'ASCV7864';
                if(tempAccount.nu_dse__SSN__c!=null)
                   tempAccount.nu_dse__SSN__c = 'S768564';
                if(tempAccount.nu_dse__Co_SSN__c!=null)
                   tempAccount.nu_dse__Co_SSN__c = 'S6023579';
                if(tempAccount.nu_dse__Home_Phone__c!=null)
                   tempAccount.nu_dse__Home_Phone__c = '02784352';
                if(tempAccount.nu_dse__External_RAMS_ID__c!=null)
                   tempAccount.nu_dse__External_RAMS_ID__c = tempAccount.nu_dse__External_RAMS_ID__c+'S';
                if(tempAccount.nu_dse__External_CFT_ID__c!=null)
                   tempAccount.nu_dse__External_CFT_ID__c = tempAccount.nu_dse__External_CFT_ID__c+'M';
                if(tempAccount.nu_dse__External_GCS_ID__c!=null)
                   tempAccount.nu_dse__External_GCS_ID__c = tempAccount.nu_dse__External_GCS_ID__c+'G';
            }               
            update list_Accounts;     
        }
    }
        global void finish(Database.BatchableContext BC){
            Boolean isSandbx=[SELECT IsSandbox FROM Organization LIMIT 1].isSandBox;
            Database.executeBatch(new Batch_PostRefresh_BankAcc(isSandbx));
        }
}