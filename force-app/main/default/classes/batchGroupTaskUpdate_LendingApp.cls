global class batchGroupTaskUpdate_LendingApp implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //query on Group Task
        String query = 'SELECT id,nu_dse__Subject__c,nu_dse__Type__c FROM nu_dse__Group_Task__c WHERE nu_dse__Subject__c = \'DNL_REVIEW_FOR_NEGOTIATIONS\'';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<nu_dse__Group_Task__c> scope)
    {
         for(nu_dse__Group_Task__c a : scope)
         {   
             //Updating Task subject and Task Type
            a.nu_dse__Subject__c='DNL Review for Negotiations';
             a.nu_dse__Type__c = 'Negotiations Review';
         }
         update scope;
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}