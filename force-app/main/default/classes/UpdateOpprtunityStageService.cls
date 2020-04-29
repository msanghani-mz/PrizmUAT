@RestResource(urlMapping='/UpdateOpprtunityStage/*')
global class UpdateOpprtunityStageService {
    
    @HttpPost
    global Static void UpdateOpprtunityStage(){
        String jsonStr = '';
        //String result = '';
        if(!Test.isRunningTest()){
        	system.debug('###RestContext.request::'+RestContext.request);
        //Checking the type of response based on the keywords
            if (RestContext.request.requestBody != NULL){
            	jsonStr = RestContext.request.requestBody.toString();
            }
        } else {
            List<Id> OppoId = new List<Id>{'0060S0000068D7WQAU'};
                OpportunityWrapper owrap = new OpportunityWrapper();
            	owrap.OpportunityIds=OppoId;
                jsonStr = JSON.serialize(owrap);
        }
        System.debug(jsonStr);
        OpportunityWrapper oppWrapList = (OpportunityWrapper)JSON.deserialize(jsonStr, OpportunityWrapper.class);
        
        List<Id> OppExtIds = oppWrapList.OpportunityIds;
        List<Opportunity> OppoList = new List<Opportunity>();
        /*for(Id OppId : OppExtIds){
            Opportunity opp = new Opportunity();
            opp.Import_Id__c = OppId;
            opp.StageName = 'Closed Lost';
            OppoList.add(opp);
        }
        Database.upsert(OppoList, Opportunity.Import_Id__c, False);
        */
        List<Opportunity> OpportunityList = [Select Id,StageName,Related_Lending_Application__c, import_id__c from Opportunity where import_Id__c =: OppExtIds];
        
        List<fsCore__Lending_Application__c> LendingAppList = new List<fsCore__Lending_Application__c>();
        for(Opportunity opp : OpportunityList){
            if(Opp.stageName != 'Closed Won'){
                Opp.StageName = 'Closed Lost';
                Opp.Closed_Lost_Reason__c = 'NSF/Skip';
                OppoList.add(opp);
                if(opp.Related_Lending_Application__c != null){
                    fsCore__Lending_Application__c la = new fsCore__Lending_Application__c();
                    la.Id = opp.Related_Lending_Application__c;
                    la.nudebt_program_status__c = 'NSF';
                    LendingAppList.add(la);
                }
            }
        }
        List<Database.UpsertResult> ur = Database.upsert(OppoList, False);
        System.debug(ur);
           Update LendingAppList;
    }
    
    public Class OpportunityWrapper{
        
        List<Id> OpportunityIds;
        
    }
}