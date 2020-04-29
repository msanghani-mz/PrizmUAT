/**
* Class Name  : ApplicationWithdrawVoidEnvelopeJob (DV-47)
* Description : This batch job mark the envelope as void for the applications
*               which were withdrawn by the ApplicationWithdrawVoidEnvelopeJob
* Author      : Financial Spectra
*
*/
global with sharing class ApplicationWithdrawVoidEnvelopeJob implements database.Batchable<Sobject>,Schedulable, Database.AllowsCallouts{
    private static final String CLASS_NAME = 'ApplicationWithdrawVoidEnvelopeJob';
    
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
            .addField('Lending_Application_Name_Formula__c')    
            .addField('Lending_Application_Name__r.Loan_Type__c')   
            .addField('Lending_Application_Name__r.Is_PreTila_Signed__c')   
            .addField('Lending_Application_Name__r.Pre_Tila_Sent_Date_First__c')
            .addField('Lending_Application_Status_Formula__c')    
            .addField('dsfs__Envelope_Status__c')    
            .addField('dsfs__DocuSign_Envelope_ID__c')
            .addWhereConditionWithValue(1,'dsfs__Envelope_Status__c','=','Sent')
            .addWhereConditionWithValue(2, 'dsfs__Envelope_Status__c', '=','Delivered')
            .addWhereConditionWithValue(3, 'Lending_Application_Status_Formula__c', '=','Withdrawn')
            .addWhereConditionWithValue(4, 'Lending_Application_Status_Formula__c', '=','Pre-TILA Withdrawn')
            .addWhereConditionWithValue(5, 'Lending_Application_Status_Formula__c', '=','COVID-Cancelled')
            .addWhereConditionWithValue(6, 'dsfs__DocuSign_Envelope_ID__c', '!=',null)
            .setWhereConditionCriteria('(1 OR 2) AND (3 OR 4 OR 5) AND 6');
        
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
                
                System.debug(loggingLevel.error,'Lending App Name :: '+docuSignStatus.Lending_Application_Name_Formula__c +
                             '  :: lending App Sttaus ==> '+docuSignStatus.Lending_Application_Status_Formula__c +
                             '  :: Envelope Status ==> '+docuSignStatus.dsfs__Envelope_Status__c +
                             '  :: Loan Type ==> '+docuSignStatus.Lending_Application_Name__r.Loan_Type__c +
                             '  :: Docusign EnvelopeId ==> '+docuSignStatus.dsfs__DocuSign_Envelope_ID__c);  
                
                
                
                if (docuSignStatus.Lending_Application_Name__r.Loan_Type__c == 'DNL'){
                    system.debug(logginglevel.ERROR, 'Inside the DNL if Condition'+ docuSignStatus.Lending_Application_Status_Formula__c);
                    
                    Boolean voidEnvelope = false;
                    if ((docuSignStatus.Lending_Application_Name__r.Pre_Tila_Sent_Date_First__c != null ) 
                        && (!docuSignStatus.Lending_Application_Name__r.Is_PreTila_Signed__c)
                        && (docuSignStatus.Lending_Application_Status_Formula__c.contains('Withdrawn'))
                        && (docuSignStatus.Lending_Application_Name__r.Pre_Tila_Sent_Date_First__c.addDays(15) <= Date.Today())){
                            voidEnvelope = true;
                            system.debug(logginglevel.ERROR, 'Setting voidEnvelope True 1 '+ docuSignStatus.Lending_Application_Status_Formula__c);
                    }
                    if (docuSignStatus.Lending_Application_Status_Formula__c == 'COVID-Cancelled' ){
                        voidEnvelope = true;
                        system.debug(logginglevel.ERROR, 'Setting voidEnvelope True 2 '+ docuSignStatus.Lending_Application_Status_Formula__c);
                    }
                    if (voidEnvelope){
                            system.debug(logginglevel.ERROR, 'Voiding the envelope Envelope Id :'+docuSignStatus.dsfs__DocuSign_Envelope_ID__c);
                            try{
                                if(!test.isRunningTest()){
                                    vEnvelopeStatus = DocusignAPIUtil.VoidEnvelope(String.valueOf(docuSignStatus.dsfs__DocuSign_Envelope_ID__c));
                                    system.debug(logginglevel.error,'vEnvelopeStatus.VoidSuccess :'+vEnvelopeStatus.VoidSuccess);  
                                    
                                    if (vEnvelopeStatus.VoidSuccess){
                                        System.debug(logginglevel.Error,'Envelope has been voided successfully!');
                                    }
                                    // String message = VoidDocusignEnvelopeController.voidEnvelope(docuSignStatus.id);
                                    // system.debug(logginglevel.ERROR, 'Voided the envelope :: '+message);
    
                                }
                                
                            }catch(Exception e)  {
                                system.debug(logginglevel.error,' EXCEPTION While Voiding the envelope ****   '+e.getStackTraceString() +e);
                            }                                
                        }
                }
            }
            
            
        }catch(Exception e)  {
            system.debug(logginglevel.error,' EXCEPTION ****   '+e.getStackTraceString() +e);
            Throw e;
        }
        
    }
    
    global void finish(Database.BatchableContext pContext){
        
    }
    
    global void execute(SchedulableContext SC) {
        ApplicationWithdrawVoidEnvelopeJob testJob = new ApplicationWithdrawVoidEnvelopeJob();
        id batchId = Database.executeBatch(testJob,1);
    }    
    
}