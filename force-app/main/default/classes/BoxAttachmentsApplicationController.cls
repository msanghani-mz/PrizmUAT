public with sharing class BoxAttachmentsApplicationController{
    public String mAccessToken{get;set;}
     public fsCore__Lending_Application__c mApplication {get; set;}
     
     public BoxAttachmentsApplicationController(ApexPages.StandardController pStdController){
        mApplication = (fsCore__Lending_Application__c)pStdController.getRecord();
        
        if (mApplication.Id != null){
            mApplication = [SELECT Id, Name
                                 , BoxFolderId__c
                              FROM fsCore__Lending_Application__c
                             WHERE Id = :mApplication.Id];
        }
    }     
    
    public void getAccessToken(){
        mAccessToken = BoxUtility.getAccessToken(true).access_token1__c;
    } 
    
  private void logmessage (Object pMessage){
      system.debug(logginglevel.error,pMessage);
  }    
}