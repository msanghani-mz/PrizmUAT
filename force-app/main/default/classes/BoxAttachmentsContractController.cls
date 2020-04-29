public with sharing class BoxAttachmentsContractController{
    public String mAccessToken{get;set;}
     public fsServ__Lending_Contract__c mContract {get; set;}
     
     public BoxAttachmentsContractController(ApexPages.StandardController pStdController){
        mContract = (fsServ__Lending_Contract__c)pStdController.getRecord();
        
        if (mContract.Id != null){
            mContract = [SELECT Id, Name
                                 , BoxFolderId__c
                              FROM fsServ__Lending_Contract__c
                             WHERE Id = :mContract.Id];
        }
    }     
    
    public void getAccessToken(){
        mAccessToken = BoxUtility.getAccessToken(false).access_token1__c;
    } 
    
  private void logmessage (Object pMessage){
      system.debug(logginglevel.error,pMessage);
  }    
}