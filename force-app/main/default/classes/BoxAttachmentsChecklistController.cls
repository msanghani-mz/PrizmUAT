public with sharing class BoxAttachmentsChecklistController{
    public String mAccessToken{get;set;}
     public fsCore__Lending_Application_Checklist__c mApplicationChecklist {get; set;}
     
     public BoxAttachmentsChecklistController(ApexPages.StandardController pStdController){
        mApplicationChecklist = (fsCore__Lending_Application_Checklist__c)pStdController.getRecord();
        
        if (mApplicationChecklist.Id != null){
            mApplicationChecklist = [SELECT Id, Name
                                 , BoxFolderId__c
                              FROM fsCore__Lending_Application_Checklist__c
                             WHERE Id = :mApplicationChecklist.Id];
        }
        
    }     
    public void getAccessToken(){
        mAccessToken = BoxUtility.getAccessToken(true).access_token1__c;
    } 

  private void logmessage (Object pMessage){
      system.debug(logginglevel.error,pMessage);
  }   
}