public class Batch_AggregateDraftsAndFees implements Database.batchable<sObject> {
    
    public Set<String> completedStatusSet = new Set<String>{'Completed', 'Cleared'};
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id FROM nu_dse__Program__c LIMIT 100';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c > programList){
        
        /*
            Maintenance Fee - 
            Thirdparty Fee - [New]
            Other Fee - [New]
            Processor Fee - [New]
            Program Fee - 
            Retainer Fee - [New]
            Service Fee - [New]
            Admin Fee - [New]
            Accumulation - 
            Total Program Cost - 
            Creditor Payments - 
        */
        
        Map<Id, AggregateResult> paymentAggregateResultMap = new Map<Id, AggregateResult> ([SELECT nu_dse__Program__c Id,
                                                                SUM(nu_dse__Monthly_Maintenance_Fee__c)maintenance_Fee,
                                                                SUM(nu_dse__Monthly_Other_Fee__c)other_Fee,
                                                                SUM(nu_dse__Monthly_Third_Party_Fees__c)third_Party_Fee,
                                                                SUM(nu_dse__Processor_Fee__c)processor_Fee,
                                                                SUM(nu_dse__Retainer_Fee__c)retainer_Fee,
                                                                SUM(nu_dse__Service_Fee__c)service_Fee,
                                                                SUM(nu_dse__Amount__c)amount
                                                                FROM nu_dse__Payment__c
                                                                WHERE nu_dse__Program__c IN :programList group By nu_dse__Program__c]);
        
        Map<Id, AggregateResult> paymentCompletedResultMap = new Map<Id, AggregateResult> ([SELECT nu_dse__Program__c Id,
                                                                SUM(nu_dse__Monthly_Maintenance_Fee__c)maintenance_Fee,
                                                                SUM(nu_dse__Monthly_Other_Fee__c)other_Fee,
                                                                SUM(nu_dse__Monthly_Third_Party_Fees__c)third_Party_Fee,
                                                                SUM(nu_dse__Processor_Fee__c)processor_Fee,
                                                                SUM(nu_dse__Retainer_Fee__c)retainer_Fee,
                                                                SUM(nu_dse__Service_Fee__c)service_Fee,
                                                                SUM(nu_dse__Amount__c)amount
                                                                FROM nu_dse__Payment__c
                                                                WHERE nu_dse__Program__c IN :programList AND
                                                                nu_dse__Transaction_Status__c IN :completedStatusSet AND
                                                                RecordType.DeveloperName = 'Deposit'
                                                                group By nu_dse__Program__c]);
        
        System.debug('paymentAggregateResultMap-->'+paymentAggregateResultMap);
        System.debug('paymentAggregateResultMap'+paymentAggregateResultMap.keySet());  
        
        List<nu_dse__Program__c> programAggregateList  = new List<nu_dse__Program__c>();
        
        for (nu_dse__Program__c programInst: programList) {
            
            if (paymentAggregateResultMap.get(programInst.Id) != null) {
                
                nu_dse__Program__c programInstance = new nu_dse__Program__c();
                programInstance.Id = programInst.Id;
                programInstance.Total_Maintenance_Fees__c = (Decimal)paymentAggregateResultMap.get(programInst.Id).get('maintenance_Fee');
                
                //This line is for Testing purpose...
                programInstance.Paid_Accumulation__c = 0;
                
                if (paymentCompletedResultMap.get(programInst.Id) != null) {
                    
                    programInstance.Paid_Accumulation__c = (Decimal)paymentCompletedResultMap.get(programInst.Id).get('amount');
                }
                
                programAggregateList.add(programInstance);
            }
        }
        
        /*
        for (AggregateResult aggregateInstance :paymentAggregateResultList.keySet() ) {
            
            nu_dse__Program__c programInstance = new nu_dse__Program__c();
            programInstance.Total_Maintenance_Fees__c = (Decimal)aggregateInstance.get('maintenance_Fee');
            
            programAggregateList.add(programInstance );
        }  
        */
        System.debug('programAggregateList-->'+programAggregateList);
        
    }
    
    public void finish(Database.BatchableContext BC){
        
        
    }
}