/**
*
* Class Name  : OpportunityClosedLostVoidEnvelopeJob (DV-343)
* Description : This batch job mark the envelope as void for the opportunities
*               which were closed lost by the OpportunityClosedLostVoidEnvelopeJob
* Author      : Financial Spectra
*
**/

global with sharing class OpportunityClosedLostVoidEnvelopeJob implements database.Batchable<Sobject>,Schedulable, Database.AllowsCallouts{
    private static final String CLASS_NAME = 'OpportunityClosedLostVoidEnvelopeJob';
    
    global Database.QueryLocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator(getDefaultQuery());
    }    
    
    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }
    
    private fsCore.DynamicQueryBuilder getQuery(){     
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.dsfs__DocuSign_Status__c.getName())
            .addField('Id')
            .addField('Name')    
            .addField('dsfs__Opportunity__c') 
            .addField('dsfs__Opportunity__r.StageName')  
            .addField('Opportunity_Name_Formula__c')   
            .addField('Opportunity_Owner_Email__c')   
            .addField('Opportunity_Owner_Formula__c')
            .addField('dsfs__Envelope_Status__c')    
            .addField('dsfs__DocuSign_Envelope_ID__c')
            .addWhereConditionWithValue(1,'dsfs__Envelope_Status__c','=','Sent')
            .addWhereConditionWithValue(2, 'dsfs__Envelope_Status__c', '=','Delivered')
            .addWhereConditionWithValue(3, 'dsfs__Opportunity__r.StageName', '=','Closed Lost')
            .addWhereConditionWithValue(4, 'dsfs__DocuSign_Envelope_ID__c', '!=',null)
            .setWhereConditionCriteria('(1 OR 2) AND 3 AND 4');
        
        System.debug(loggingLevel.ERROR,'jobQuery getQuery:---'+jobQuery.getQueryString());
        return jobQuery;
    }        
    
    
    global String getClassName(){
        return CLASS_NAME;
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> pScope){
        System.debug(loggingLevel.error, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.error, 'Scope Count : ' + pScope.size());
        DocuSignAPI.VoidEnvelopeStatus vEnvelopeStatus;

        try{
            for (dsfs__DocuSign_Status__c docuSignStatus : (List<dsfs__DocuSign_Status__c>)pScope){
                System.debug(loggingLevel.error,'Opportunity Name :: '+docuSignStatus.Opportunity_Name_Formula__c +
                             '  :: opportunity Stage ==> '+docuSignStatus.dsfs__Opportunity__r.StageName +
                             '  :: Envelope Status ==> '+docuSignStatus.dsfs__Envelope_Status__c +
                             '  :: Docusign EnvelopeId ==> '+docuSignStatus.dsfs__DocuSign_Envelope_ID__c);  
                
                if (docuSignStatus.dsfs__Opportunity__r.StageName == 'Closed Lost'){
                    system.debug(logginglevel.ERROR, 'Inside the StageName if Condition');
                    
                    system.debug(logginglevel.ERROR, 'Voiding the envelope Envelope Id :'+docuSignStatus.dsfs__DocuSign_Envelope_ID__c);
                    try{
                        if(!test.isRunningTest()){
                                    vEnvelopeStatus = DocusignAPIUtil.VoidEnvelope(String.valueOf(docuSignStatus.dsfs__DocuSign_Envelope_ID__c));
                                    system.debug(logginglevel.error,'vEnvelopeStatus.VoidSuccess :'+vEnvelopeStatus.VoidSuccess);  
                                    
                                    if (vEnvelopeStatus.VoidSuccess){
                                        System.debug(logginglevel.Error,'Envelope has been voided successfully!');
                                    }                         
                            //  String message = VoidDocusignEnvelopeController.voidEnvelope(docuSignStatus.id);
                           // system.debug(logginglevel.ERROR, 'Voided the envelope :: '+message);
                        }
                        
                    }catch(Exception e)  {
                        system.debug(logginglevel.error,' EXCEPTION While Voiding the envelope ****   '+e.getStackTraceString() +e);
                    }                                
                }
            }
        }
        catch(Exception e)  {
            system.debug(logginglevel.error,' EXCEPTION ****   '+e.getStackTraceString() +e);
            throw e;
        }
    }
    
    global void finish(Database.BatchableContext pContext){}
    
    global void execute(SchedulableContext SC) {
        OpportunityClosedLostVoidEnvelopeJob testJob = new OpportunityClosedLostVoidEnvelopeJob();
        id batchId = Database.executeBatch(testJob,1);
    }    
    
}