global class BatchLead implements Database.Batchable<sobject>{
     global string query;
     global database.QueryLocator start(Database.batchablecontext bc)
     {
       string br='Borrower';
       query='select id,name,RecordType.Name,Lead_Record_Type_txt_del__c from Lead WHERE RecordType.Name=:br';
       return(Database.getQueryLocator(query));
     }
     global void execute(Database.BatchableContext bc,list<Lead> lstLead)
     {
        list<Lead> lupdateLead=new list<Lead>();
         for(Lead l:lstLead)
        {
            if(l.RecordType.Name=='Borrower'){
            l.Lead_Record_Type_txt_del__c=l.RecordType.Name;
            lupdateLead.add(l);
            }
        }
         dataBase.update(lupdateLead,false);
     }
    global void finish(Database.BatchableContext bc)
    {
       
    }
}