public class PushTaskToNudebt
{
    public static InvoiceWrapper wrapper {
        get;
        set;
    } 
   
        
    
    public  String getAccessToken(){
        //String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
        RestIntegrationInformation__mdt restIntegration = [select System_Endpoint__c,EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        deserializeResponse resp1;  
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setHeader('Content-Length', '0');
        req.setEndpoint(restIntegration.AccesstokenURL__c);
        //req.setEndpoint('https://peerform--partial1.cs65.my.salesforce.com/services/oauth2/token');
       if(!test.isRunningTest()){
           try{
              HttpResponse res = h.send(req);
              //deserializeResponse resp1 = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
              resp1 = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
              system.debug('@@@@access_token@@'+resp1 );
              
           }
           catch(Exception e){
               system.debug(e.getMessage());
           }
         return resp1.access_token; 
       }
        else{
          return 'test';  
        }
    
        
    }
    
             
    @future(callout = true)
  public static void pushTasksInNdebt(String jsonString, String Method){
      RestIntegrationInformation__mdt restIntegration = [select System_Endpoint__c,EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
      PushTaskToNudebt obj = new PushTaskToNudebt();
       String accessToken = obj.getAccessToken();
     
        
      String endPoint = restIntegration.System_Endpoint__c +'/'+Method;
      Http h2 = new Http();
      HttpRequest req1 = new HttpRequest();
      req1.setHeader('Authorization','Bearer ' + accessToken);
      req1.setHeader('Content-Type','application/json');
      req1.setHeader('Content-Length', '0');
      req1.setHeader('accept','application/json');
      req1.setBody(jsonString);
      req1.setMethod('POST');
      req1.setEndpoint(endPoint);
      String trimmedResponse;
      if(!test.isRunningTest()){
         HttpResponse res1 = h2.send(req1);
         trimmedResponse = res1.getBody(); 
      }
      else{
          trimmedResponse='{"invoiceList":[{"ImportId":"00T0m00000BjJbzEAF","currentTaskId":"00T22000003MRPvEAO"}]}';
      }
      
      System.debug('trimmedResponse = '+trimmedResponse);
      
       wrapper = (InvoiceWrapper) JSON.deserialize(trimmedResponse, InvoiceWrapper.class);
      
      map<string,string> mapTaskOldNewId=new map<string,string>(); 
      
      for(Invoice invc:wrapper.invoiceList){  
        mapTaskOldNewId.put(invc.ImportId,invc.currentTaskId);  
      }
      
      list<Task> LstNewTask=[select id,Import_Id__c,WhatId,RecordTypeId,status from Task where id in: mapTaskOldNewId.keySet()];
      list<Task> updateTask=new list<Task>();
      System.debug('LstNew Task1:'+LstNewTask);
      Id DNLTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
      if(!LstNewTask.isEmpty()){
          for(task t:LstNewTask){
              String sObjName = t.WhatId.getSObjectType().getDescribe().getName();
              if(DNLTaskRecordTypeId == t.RecordTypeId && sObjName.equalsIgnoreCase('Opportunity')){
                 t.Import_Id__c=mapTaskOldNewId.get(t.id); //
                 updateTask.add(t); 
              }
              
          }
      }
      
      if(updateTask.size()>0)
         update updateTask; 
      
        
      System.debug('LstNew Task2:'+LstNewTask);   
             
    }

     public class deserializeResponse{
        public String id;
        public String access_token;   
        
    }
  }