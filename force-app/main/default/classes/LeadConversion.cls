public class LeadConversion 
{ 
    /*public static void leadConvert(Set<Lead>leadIds)
    {
        List<Opportunity>oppLst= new List<Opportunity>();
       // List<Account> actList= new List<Account>();
        Map<Id,Id>oppToLeadMap= new Map<Id,Id>();
        Map<Id,Account>accMap= new Map<Id,Account>();
        Set<Id> accSet= new Set<Id>();
        List<Lead>leadToConv=[Select id,NuDebtAccount__c,RecordTypeId,Status,IsConverted From Lead Where Id IN:leadIds AND IsConverted=false];
        for(lead l:leadToConv)
        {
            accSet.add(l.NuDebtAccount__c);
            System.debug('AccSet records are'+ accSet);
            
        }
        List<Account> accList=[Select id From Account where Id IN:accSet];
        for(Account acc: accList)
        {
            accMap.put(acc.Id,acc);
        }
        List<Opportunity> oppList=[Select id,Lead_Id__c From Opportunity where Lead_Id__c IN:leadIds];
        for(Opportunity opp: oppList)
        {
            oppToLeadMap.put(opp.Id,opp.Lead_Id__c);   
            
        }
        
        List<Database.LeadConvert> leadConv= new List<Database.LeadConvert>();
         Id recordTypeIdLead=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('DNL Lead').getRecordTypeId();
        System.debug('recordTypeIdLead is '+recordTypeIdLead);
        for(Lead l:leadToConv)
        {
            if((l.Status!='DNL-Converted'&&l.IsConverted==false)&& l.RecordTypeId==recordTypeIdLead)
            {
                Database.LeadConvert lc=new Database.LeadConvert();
                lc.setConvertedStatus('Closed - Converted');
                lc.setLeadId(l.id);
                if(accMap.containsKey(l.NuDebtAccount__c))
                {
                    lc.setAccountId(accMap.get(l.NuDebtAccount__c).Id);
                }
               
              /*  else
                {
                    Id recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                    Account act= new Account();
                    act.Name=l.FirstName;
                    act.RecordTypeId= recordTypeId; 
                    actList.add(act);    
                }
                // if existing opp set its add 
                if(oppToLeadMap.containsKey(l.id))
                {
                    Opportunity o=[Select id From Opportunity Where Lead_Id__c=:l.id];
                    lc.setOpportunityId(o.id);
                }
                
                 if not existing then create new
                else
                {
                    Opportunity opp = new Opportunity();
                    opp.Name=l.FirstName;
                    opp.CloseDate=date.today();
                    opp.StageName='Prospecting';
                    oppLst.add(opp);
                                    
                }    
            }     
            
        }
       if(actList!=null)
        {
        insert actList;
            System.debug('New List of Account inserted'+ actList);
        }
        for(Account acc: actList)
        {
            Database.LeadConvert leadConAcc= new Database.LeadConvert();
            leadConAcc.setAccountId(acc.id);
        }
        if(oppList!=null)
        {
         insert oppLst;
            System.debug('Opp created'+ oppLst);
        }
        for(Opportunity opp:oppLst)
        {
            Database.LeadConvert leadConOpp = new Database.LeadConvert();
            leadConOpp.setOpportunityId(opp.id);     
        }
        
        
    }*/
}