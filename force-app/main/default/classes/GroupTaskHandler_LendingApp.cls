public class GroupTaskHandler_LendingApp {

    public static void createNegotiatorGroupTask(list<fsCore__Lending_Application__c> pListApp,String pSubject, String pDescription)
    {
        list<nu_dse__Group_Task__c> lTsk=new list<nu_dse__Group_Task__c>();
        set<id> GTId=new set<id>();
        System.debug('##createNegotiatorGroupTask');
        for(fsCore__Lending_Application__c la:pListApp)
        {
            
            nu_dse__Group_Task__c t=new nu_dse__Group_Task__c();
            String str='DNL Underwriter has requested a review of tradelines for client '+ la.fsCore__Title__c+'-Program id:- '+la.Import_Program_Id__c+'\n'+' Underwriter comments: '+la.fsCore__Comments__c;
            t.nu_dse__Type__c='Negotiations Review';
            t.nu_dse__Subject__c='DNL Review for Negotiations';
            
            t.nu_dse__Description__c=str;
            t.nu_dse__Related_To__c=la.id;
            t.Program_Import_ID__c=la.Import_Program_Id__c;
            t.nu_dse__Status__c='In Progress';
            t.nu_dse__ActivityDate__c = Date.today()+5;
            //t.Applicant_Name__c=la.fsCore__Primary_Customer_Contact__r.name;
            lTsk.add(t);
            
        }
        if(lTsk.size()>0)
            insert lTsk;
        for(nu_dse__Group_Task__c gt:lTsk)
            GTId.add(gt.Id);
        List<Task> taskList=[SELECT Subject,type,WhatId,nu_dse__Group_Task__c,fsServ__Activity_Type__c, ActivityDate, Status FROM Task where nu_dse__Group_Task__c in :GTId];
        for(Task t1:taskList)
        {
            t1.Subject='DNL Review for Negotiations';
            t1.fsServ__Activity_Type__c='Negotiations Review';
        }
        if(taskList.size()>0)
            update taskList;
    }
    
    
    public static void ApplicationGroupTaskToNudebt(List<nu_dse__Group_Task__c> listGT){
        String jsonString;
        set<id> laIdsSet=new set<id>(); 
        list<nu_dse__Group_Task__c> lendTask=new list<nu_dse__Group_Task__c>(); 
        list<nu_dse__Group_Task__c> NewLendTask=new list<nu_dse__Group_Task__c>(); 
        Id objId;
        for(nu_dse__Group_Task__c eachTask : listGT){
            objId = eachTask.nu_dse__Related_To__c;
            String sObjName = objId.getSObjectType().getDescribe().getName();
            if(objId!=null && sObjName.equalsIgnoreCase('fsCore__Lending_Application__c')){  
                lendTask.add(eachTask);
                objId=eachTask.nu_dse__Related_To__c;
                system.debug(logginglevel.error,'objId ************************'+objId);
                laIdsSet.add(objId);
            } 
        }
        
        list<fsCore__Lending_Application__c> lstApp=[select id,fsCore__Application_Status__c from fsCore__Lending_Application__c
                                                     where fsCore__Application_Status__c='Negotiations Review' AND id in:laIdsSet];
        if(lstApp.size()>0){
            for(fsCore__Lending_Application__c la:lstApp) 
            { 
                for(nu_dse__Group_Task__c eachTask1:lendTask){
                    if(eachTask1.nu_dse__Related_To__c==la.id)
                        NewLendTask.add(eachTask1);
                     system.debug(logginglevel.error,'Send Request ************************'+eachTask1);
                }
            }
        }
        
        if(NewLendTask.size() > 0){
            try{
                jsonString = JSON.serialize(NewLendTask);
                //PushGroupTaskInNudebt.pushGTInNdebt(jsonString,'CreateLendAppTask');
                pushGTInNdebt(jsonString,'CreateLendAppTask');
            }
            catch(Exception e){
                system.debug('Exception'+e.getMessage());
            }
            
        }
        
    }
    //PushGroupTask
    public class deserializeResponse{
        public String id;
        public String access_token;   
        
    }
    public String getAccessToken(){
        //String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
        RestIntegrationInformation__mdt restIntegration = [select System_Endpoint__c,EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        deserializeResponse resp1;  //@
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setHeader('Content-Length', '0');
        req.setEndpoint(restIntegration.AccesstokenURL__c);
        if(!test.isRunningTest()){  
            //try{
            HttpResponse res = h.send(req);
            resp1 = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
            system.debug(logginglevel.error,'resp1 ************************'+resp1);
            
            //}
            // catch(Exception e){
            //    system.debug(e.getMessage());
            //}
            
            return resp1.access_token; 
            
        }  
        else{ 
            
            return 'test'; 
            
        }
        
        
    }
    
    @future(callout = true)
    public static void pushGTInNdebt(String jsonString, String Method){ 
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
            System.debug('##send request '+res1);
            trimmedResponse = res1.getBody(); 
        } 
        else{  
            trimmedResponse='{"invoiceList":[{"ImportId":"00T0m00000BjJbzEAF","currentTaskId":"00T22000003MRPvEAO"}]}'; 
        } 
        
        System.debug('trimmedResponse = '+trimmedResponse); 
        
    } 
    
}