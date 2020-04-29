@RestResource(urlMapping='/UpdateTotalFees/*')
global class UpdateTotalFeesService {
    
    @HttpPost
    global Static void UpdateTotalFees(){
        String jsonStr = '';
        //String result = '';
        system.debug('###RestContext.request::'+RestContext.request);
        //Checking the type of response based on the keywords
        if (RestContext.request.requestBody != NULL)
            jsonStr = RestContext.request.requestBody.toString();    
        System.debug(jsonStr);
        
        List<ProgramWrapper> ProgramWrapList = (List<ProgramWrapper>)JSON.deserialize(jsonStr,List<ProgramWrapper>.class);
        Map<Id,Decimal> ProgramWrapMap = new Map<Id,Decimal>();
        List<Id> OpportunityIds = new List<Id>();
        
        List<Opportunity_Tradelines_Offer__c> TradeList = new List<Opportunity_Tradelines_Offer__c>();
        for(ProgramWrapper pw : ProgramWrapList){
            OpportunityIds.add(pw.OpportunityId);
            if(pw.TotalFees != null)
            ProgramWrapMap.put(pw.OpportunityId,Decimal.valueOf(pw.TotalFees));
            
            If(pw.TradeOfferList != null){
                for(TradeOffer to : pw.TradeOfferList){
                    Opportunity_Tradelines_Offer__c trade = new Opportunity_Tradelines_Offer__c();
                    trade.import_Id__c = to.TradeId;
                    trade.Offer_Amount__c = Decimal.valueOf(to.OfferAmount);
                    Tradelist.add(trade);
                }
                
            }
        }
        
        Schema.SObjectField importIdTradeField = Opportunity_Tradelines_Offer__c.Import_Id__c;
        Database.UpsertResult[] insTradeResults = Database.upsert(Tradelist, importIdTradeField, false);
        system.debug('###insTradeResults::'+insTradeResults);
        
        List<Opportunity> OppoList = [Select Id,Import_Id__c, Related_Lending_Application__c from Opportunity where import_Id__c =: OpportunityIds];
        
        List<fsCore__Lending_Application__c> LAppList = new List<fsCore__Lending_Application__c>();
        For(Opportunity opp : OppoList){
            if(opp.Related_Lending_Application__c != null){
                fsCore__Lending_Application__c LApp = new fsCore__Lending_Application__c();
                LApp.Id = Opp.Related_Lending_Application__c;
                if(ProgramWrapMap.containsKey(Opp.Id))
                LApp.NuDebt_Total_Actual_Fee__c = ProgramWrapMap.get(Opp.Id);
                LApp.NuDebt_Program_Status__c = 'Versara NDS Graduated';
                //LApp.fsCore__Application_Status__c = 'DRP Graduated';
                LAppList.add(LApp);
            }
        }
        Update LAppList;
    }
    
    public class ProgramWrapper {
        
        String OpportunityId;
        String TotalFees;
        List<TradeOffer> TradeOfferList;
        
        public ProgramWrapper(String OpportunityId,String TotalFees,List<TradeOffer> TradeOfferList){
            this.OpportunityId = OpportunityId;
            this.TotalFees = TotalFees;
            this.TradeOfferlist = TradeOfferList;
        }
        
    }
    
    public Class TradeOffer{
            
        String TradeId;
        String OfferAmount;
        
        public TradeOffer(){
            tradeId = '';
            OfferAmount = '';
        }
        
    }
}