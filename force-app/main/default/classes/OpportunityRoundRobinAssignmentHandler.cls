/**
 * @File Name          : OpportunityRoundRobinAssignmentHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 8/17/2019, 4:09:49 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/17/2019, 4:08:32 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class OpportunityRoundRobinAssignmentHandler{
    public static Boolean ownerflag=false;
    public static void roundRobinAssignment(){
    
        List<Opportunity> OpportunityList = (List<Opportunity>)Trigger.new;
        
        List<Profile> ProfileList = [Select Id from Profile where Name = 'DNL Sales'];
        
        if(ProfileList != null && !ProfileList.isEmpty()){
            List<User> UserList = [Select Id from User where ProfileId =: ProfileList.get(0).Id and IsRoundRobinAllocationEnabled__c = true and isActive = true ];  //First name order
        
            Integer totalMembers = UserList.size();
            List<Opportunity> OpportunityUpdate = new List<Opportunity>();
            for(Opportunity o : OpportunityList){ 
                //if(o.Opportunity_Number_NuDebt__c != null && totalMembers != 0 && Trigger.isInsert && O.Import_Id__c != null){
                if(totalMembers != 0 && Trigger.isInsert){
                    //isTriggerExecuted=true; 
                    System.debug('**** Owner Assign');
                    Opportunity newOpportunity = new Opportunity();
                    newOpportunity.id = o.id;
                    Integer indexToAssign = Math.mod(Integer.valueOf(o.Opportunity_Number_NuDebt__c),totalMembers);
                    newOpportunity.ownerId = UserList[indexToAssign].Id;
                    OpportunityUpdate.add(newOpportunity);
                    ownerflag=true;   //
                }
                System.debug('****'+o.ownerId);
            }
            
            Update OpportunityUpdate;
    
        }
    }
     //PDI-691
     public static void BeforeUpdtNudebtOpp(){
         List<Opportunity> OpportunityList = (List<Opportunity>)Trigger.new;
        Map<Id, Opportunity> OpportunityOldMap = (Map<Id,Opportunity>)Trigger.oldMap;
        //Assign owner of opportunity at sales rep
        profile p=[select id,name from Profile where name='DNL Sales'];
        map<id,User> mapIdUser=new map<id,user>([select id,name,profileId from User where profileId=:p.id]);
        
       for(opportunity op:OpportunityList){
           if(op.OwnerId!=OpportunityOldMap.get(Op.Id).OwnerId && mapIdUser.containskey(op.OwnerId)){
              op.Sales_Rep__c=mapIdUser.get(op.OwnerId).name;
             
           }
            
        }
        
     }
    
    public static void UpdateNuDebtOpportunity(){
        List<Opportunity> OpportunityList = (List<Opportunity>)Trigger.new;
        Map<Id, Opportunity> OpportunityOldMap = (Map<Id,Opportunity>)Trigger.oldMap;
        
        List<OpportunityStatusWrapper> OpportunityStatusWrapperList = new List<OpportunityStatusWrapper>();
        OpportunityStatusWrapper OppoWrap = new OpportunityStatusWrapper();
        for(Opportunity oppo : OpportunityList){
            //Need to remove owner ID condition or replace other logic: Flag use
            if((oppo.StageName != OpportunityOldMap.get(Oppo.Id).StageName && Oppo.Import_Id__c != null)||(oppo.OwnerId!=OpportunityOldMap.get(Oppo.Id).OwnerId && ownerflag==false)){ //&& ownerflag==false
                System.debug('oppo.OwnerId:'+oppo.OwnerId + 'OpportunityOldMap.get(Oppo.Id).OwnerId:'+OpportunityOldMap.get(Oppo.Id).OwnerId);
               System.debug('oppo.StageName:'+oppo.StageName + 'OpportunityOldMap.get(Oppo.Id).StageName:'+OpportunityOldMap.get(Oppo.Id).StageName);
                OppoWrap.OpportunityId = Oppo.import_Id__c;
                OppoWrap.Status = Oppo.StageName;
                OppoWrap.SalesRep = Oppo.Sales_Rep__c; //@ 691
                OpportunityStatusWrapperList.add(OppoWrap);
                
            }
            
        }
        System.debug('OpportunityStatusWrapperList:'+OpportunityStatusWrapperList);
        
        if(!OpportunityStatusWrapperList.isEmpty()){
            
             OpportunityNuDebtStatusUpdateQueueable updateRequest = new OpportunityNuDebtStatusUpdateQueueable(JSON.serialize(OpportunityStatusWrapperList));
                ID jobID = System.enqueueJob(updateRequest);
           // UpdateOpportunityStatus(JSON.serialize(OpportunityStatusWrapperList));
            system.debug('OpportunityStatusWrapperList'+OpportunityStatusWrapperList);
        }
    }
    
     public class deserializeResponse{
        public String id;
        public String access_token;   
    }
    
   
    public static void UpdateOpportunityStatus(String OpportunityList){
        RestIntegrationInformation__mdt restIntegration = [select System_Endpoint__c,EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(restIntegration.AccesstokenURL__c); //Change "ap4" in url to your Target Org Instance 
        String accessToken;
        if(!test.isRunningTest()){
            try{
               HttpResponse res=h.send(req);
               deserializeResponse resp1=(deserializeResponse)JSON.deserialize(res.getBody(),deserializeResponse.class);
               accessToken=resp1.access_token;  
             }
            catch(Exception e){
                System.debug(e.getMessage());
            }
            
        } else {
            accessToken='Test';
        }
        
        
        
        //Making a callout
        if(accessToken!=null){
            String endPoint=restIntegration.System_Endpoint__c+'/updateOpportunityStatus';//+'?oppId='+ids; 
            //String jsonstr= getOppDataJSON(oppLst);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(OpportunityList);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            if(!Test.isRunningTest()){
            HttpResponse res2=h2.send(req2);
            
            System.debug(res2+'###1203createresp');
            System.debug('###Body::'+res2.getBody());
            }
        }
     }
    
    public class OpportunityStatusWrapper{
        public string OpportunityId;
        public String Status;
        public String SalesRep;  //@
        public OpportunityStatusWrapper(){
            OpportunityId = '';
            Status = '';
            SalesRep='';  //@
        }
    }
}