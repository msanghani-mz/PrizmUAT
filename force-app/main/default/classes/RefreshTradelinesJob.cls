/**
 * Class Name  : RefreshTradelinesJob
 * Description : This batch job refresh the tradelines data on lending application
 *               by fetching the information fro NuDebt 
 * Author      : Financial Spectra
 */
 global class RefreshTradelinesJob implements database.Batchable<Sobject>,Schedulable, Database.AllowsCallouts{
    private static final String CLASS_NAME = 'RefreshTradelinesJob';


    global Database.QueryLocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator(getDefaultQuery());
    }    
    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
                                                  .addField('Id')
                                                  .addWhereConditionWithValue(1, 'fsCore__Is_Application_Read_Only__c', '=',false)
                                                  .addWhereConditionWithValue(2, 'Opp_Import_Id__c', '!=', null)
                                                  .addWhereConditionWithValue(3, 'fsCore__Is_Funded__c', '=', false)
                                                  .addWhereConditionWithValue(4, 'fsCore__Is_Voided__c', '=', false);
        return jobQuery;
    }      

    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }
    

    global void execute(Database.BatchableContext BC, List<SObject> pScope){
        System.debug(loggingLevel.DEBUG, 'Executing RefreshTradelinesJob... ');
        System.debug(loggingLevel.DEBUG, 'Scope Count : ' + pScope.size());
        
        if (pScope.size() == 0){ return ; }
        
        Set<Id> applicationIds = new Set<Id>();
        for (fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pScope){
            applicationIds.add(app.Id);
        }
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);
        
        RefreshTradelinesAction refreshTrdlines = new RefreshTradelinesAction();
        refreshTrdlines.setInput(acInput);
        refreshTrdlines.setIsCalledFromUI(false); //DV-161
        refreshTrdlines.process();
        refreshTrdlines.saveErrors();

        //return refreshTrdlines.getOutput().getErrors();
    }

    global void finish(Database.BatchableContext BC){}

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new RefreshTradelinesJob());
    }       


}