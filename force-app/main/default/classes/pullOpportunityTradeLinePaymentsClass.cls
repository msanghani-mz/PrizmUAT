/**
 * @File Name          : pullOpportunityTradeLinePaymentsClass.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/29/2019, 11:11:52 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/29/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class pullOpportunityTradeLinePaymentsClass{
     public class deserializeResponse{
        public String id;
        public String access_token;   
     }
    @AuraEnabled
    public static string getDetails(string ids){
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        actionOP.setIsSuccess(false);
        try
        {
        
            Opportunity opp = [Select id, import_id__c, Import_Program_Id__c  from Opportunity where Id =: ids];
            if (opp.import_id__c == null){
                if(opp.Import_Program_Id__c  == null){
                    actionOP.addError('The import id is null on the Opportunity, cannot proceed with the data refresh.');
                	return actionOP.getJSONString();
                }else{
                    pullOpportunityTradeLinePaymentsClass.pullProgramDetailsFromNuDebt(opp.Import_Program_Id__c );
                    actionOP.setIsSuccess(true);
                	actionOP.setMessage('Data from NuDebt has been refreshed successfully!');
                    return actionOP.getJSONString();
                }
                
            }else{
                pullOpportunityTradeLinePaymentsClass.getOppDetails(opp.import_Id__c,UserInfo.getUserId());
                
                actionOP.setIsSuccess(true);
                actionOP.setMessage('Data from NuDebt has been refreshed successfully!');
            }

        }catch(Exception e)
          {
              actionOP.addError(e.getMessage());
          }
        
        return actionOP.getJSONString();

    }
    @AuraEnabled
     WebService static void getOppDetails(string ids, string ownerIds) {
        system.debug(logginglevel.error,'####ids::'+ids);
        system.debug(logginglevel.error,'####ownerIds::'+ownerIds);
        
        List<Id> OppoIds = new List<Id>{ids};
        
        //Logic For getting Access Token
        RestIntegrationInformation__mdt restIntegration = [select EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        // String reqbody='{"grant_type":"password","client_id":clientId,"client_secret":clientSecret,"username":username,"password":password}';
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(restIntegration.AccesstokenURL__c); //Change "ap4" in url to your Target Org Instance 
        HttpResponse res=h.send(req);
        system.debug(logginglevel.error,res.getBody()+'###1203res');
        deserializeResponse resp1=(deserializeResponse)JSON.deserialize(res.getBody(),deserializeResponse.class);
        system.debug(logginglevel.error,resp1+'###1203deserializeresponse');
        String accessToken=resp1.access_token;
        system.debug(logginglevel.error,accessToken+'###0012');
        
        
        String jsonstr = JSON.serialize(OppoIds,true);
        //Making a callout
        if(accessToken!=null){
            String endPoint=restIntegration.EndPointURL__C;//+'?oppId='+ids; 
            //String jsonstr= getOppDataJSON(oppLst);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(jsonstr);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            HttpResponse res2=h2.send(req2);
            
            /*Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setMethod('GET');
            req2.setEndpoint(endPoint);
            HttpResponse res2=h2.send(req2);*/
            system.debug(logginglevel.error,res2+'###1203createresp');
            system.debug(logginglevel.error,'###Body::'+res2.getBody());
            String jsonResStr = res2.getBody();
            string str = jsonResStr.replace('\\','');
            system.debug(logginglevel.error,str.removeStart('"').removeEnd('"'));
            
            CreateOrUpdateRecordService.CreateopportunityAccount(str.removeStart('"').removeEnd('"'),true);
            
            //deserializeResponse deresp2=(deserializeResponse)System.JSON.deserialize(res2.getBody(),deserializeResponse.class);
            //System.debug('###1203createdeser'+deresp2);
        }
        
    } 
     @AuraEnabled
     WebService static void pullProgramDetailsFromNuDebt(Id importProgramId){
        
         String accessToken;
         String instanceURL; 
         List<Id> listOfIds = new List<Id>();
         listOfIds.add(importProgramId);
         System.debug('listOfIds = ' + listOfIds);
         if(listOfIds == null || listOfIds.size() == 0){
             System.debug('listOfIds null = ' + listOfIds);
         }
         if(!test.isRunningTest()){
             Map<String, Object> resultMap = PrizmLeadPullService.getConnectionResponse();
             accessToken = (String)resultMap.get('access_token');
             instanceURL = (String)resultMap.get('instance_url'); 
         }else
             accessToken = 'Test';
         
         System.debug('accessToken = ' + accessToken);
         if(accessToken !=null){
             String endPoint=instanceURL +'/services/apexrest/pullProgramDetailsForPrizmOpportunity';
             System.debug('endPoint = ' + endPoint);
             JSONGenerator gen = JSON.createGenerator(true); 
            gen.writeObject(listOfIds);
            String jsonS = gen.getAsString();
            System.debug(loggingLevel.ERROR, 'jsonS = ' + jsonS);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            req2.setTimeout(60000);
            req2.setBody(jsonS);
            HttpResponse res2=h2.send(req2);
            
            system.debug(logginglevel.error,res2+'###1203createresp');
            system.debug(logginglevel.error,'###Body::'+res2.getBody());
            String jsonResStr = res2.getBody();
            string str = jsonResStr.replace('\\','');
            system.debug(logginglevel.error,str.removeStart('"').removeEnd('"'));
            
            CreateOrUpdateRecordService.CreateopportunityAccount(str.removeStart('"').removeEnd('"'),true);   

        }
    }
}