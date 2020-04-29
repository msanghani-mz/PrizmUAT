/**
* Class Name  : ApplicationAutoPurgeTestDataJob (SUP-521)
* Description : This batch job deleted the test Data
* Author      : Financial Spectra
*
*/
global with sharing class ApplicationAutoPurgeTestDataJob implements database.Batchable<Sobject>,Schedulable, Database.AllowsCallouts{
    private static final String CLASS_NAME = 'ApplicationAutoPurgeTestDataJob';
    
    global Database.QueryLocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator(getDefaultQuery());
    }    
    
    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }
    
    private fsCore.DynamicQueryBuilder getQuery(){     
        
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
            .addField('Id')
            .addField('fsCore__Is_Test__c')   
            .addWhereConditionWithValue(1,'fsCore__Is_Test__c','=',true);
        
        System.debug(loggingLevel.ERROR,'jobQuery getQuery:---'+jobQuery.getQueryString());
        return jobQuery;
    }        
    
    
    global String getClassName(){
        return CLASS_NAME;
    }
    
    
    global void execute(Database.BatchableContext BC, List<SObject> pScope){
        System.debug(loggingLevel.error, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.error, 'Scope Count : ' + pScope.size());
        
        try{
            if(pScope.size()>0){
                
                Set<id> testApps = new Set<id>();
                for(fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pScope){
                    testApps.add(app.id);
                }
                
                List<fsserv__lending_contract__c> conList = [select id from fsserv__lending_contract__c where fsServ__Lending_Application_Number__c in :testApps];
                Set<id> testContracts = new Set<id>();
                for(fsserv__lending_contract__c con : conList){
                    testContracts.add(con.id);
                }
                
                
                delete [select id from fscore__outbound_payment__c where fsCore__Lending_Application_Number__c in :testApps OR fsServ__Lending_Contract_Number__c in : testContracts];
                if(testContracts.size()>0){
                    delete [select id from fsserv__contract_transaction_balance_allocation__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_transaction__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    //delete [select id from fsserv__transaction_processing_parameter__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__transaction_processing_queue__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_stage__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_draw_preference__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_holiday_preference__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_payment_preference__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_rate_preference__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_repayment_schedule__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_repayment__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_payoff_quote_detail__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_payoff_quote__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_itemization__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_due__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_balance__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_fee_tier__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_fee__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_insurance__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    //delete [select id from fsserv__payment_batch__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__inbound_payment__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    //delete [select id from fsserv__contract_investment_charge__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_investment_balance__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_investment_transaction__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_investment__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_collateral__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_direct_debit__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_disbursement__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete [select id from fsserv__contract_customer__c where fsServ__Lending_Contract_Number__c in : testContracts];
                    delete conList;
                }
                
                
                delete [select id from fscore__assignment__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_document_record__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id,fsCore__Lending_Application_Number__c from fscore__calculator__c where fsCore__Lending_Application_Number__c in :testApps];
                //delete [select id from fscore__calculator_draw_preference__c ];
                //delete [select id from fscore__calculator_payment_holiday_preference__c];
                //delete [select id from fscore__calculator_payment_preference__c];
                //delete [select id from fscore__calculator_rate_preference__c];
                //delete [select id from fscore__calculator_repayment_schedule__c];
                //delete [select id from fscore__calculator_repayment_detail__c];
                delete [select id from fscore__rule_result__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_stage__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_draw_preference__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_holiday_preference__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_payment_preference__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_rate_preference__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_repayment_schedule__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_repayment__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_checklist__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_covenant__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_scorecard_detail__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_scorecard__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_direct_debit__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_disbursement__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_insurance__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_investment__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_collateral__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_fee_tier__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_fee__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_decision_itemization__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_decision_stipulation__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_decision__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application_pricing_offer__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from Lending_Application_Fraud_Flag__c where Lending_Application_Number__c in :testApps];
                delete [select id from Opportunity_Payment__c where Lending_Application_Number__c in :testApps];
                delete [select id from Opportunity_Tradelines_Offer__c where Lending_Application_Number__c in :testApps];
                
                
                List<fscore__lending_application_customer__c> applicants = [select id ,  fsCore__Account_Name__c from fscore__lending_application_customer__c where fsCore__Lending_Application_Number__c in :testApps];
                
                Set<id> accountIds = new Set<id>();
                for(fscore__lending_application_customer__c customer :applicants){
                    accountIds.add(customer.fsCore__Account_Name__c);
                }
                
                List<fscore__lending_application_customer__c> otherApplicants = [ select id ,  fsCore__Account_Name__c from fscore__lending_application_customer__c where fsCore__Account_Name__c in :accountIds and id Not In :applicants ];
                if(otherApplicants.size()>0){
                    for(fscore__lending_application_customer__c customer :otherApplicants){
                        accountIds.remove(customer.fsCore__Account_Name__c);
                    }
                }
                delete applicants;
                List<fsServ__Contract_Customer__c> contractCustomers = [select id ,  fsServ__Account_Name__c from fsServ__Contract_Customer__c where fsServ__Account_Name__c in :accountIds];
                
                if(contractCustomers.size()>0){
                    for(fsServ__Contract_Customer__c customer :contractCustomers){
                        accountIds.remove(customer.fsServ__Account_Name__c);
                    }
                }
                
                
                delete [select id from fscore__lending_application_itemization__c where fsCore__Lending_Application_Number__c in :testApps];
                delete [select id from fscore__lending_application__c where id in :testApps];
                if(accountIds.size()>0){
                    
                    delete [Select id from fsCore__Financial__c where  fsCore__Account_Name__c in :accountIds AND fsCore__Contact_Name__c in :accountIds];
                    delete [Select id from Email_Notification_Log__c where  Recipient_Contact_Name_1__c in :accountIds OR Recipient_Contact_Name_2__c in :accountIds OR Recipient_Contact_Name_3__c in :accountIds];
                   // delete [Select id from Account where id in :accountIds ];
                }
                delete [select id from fscore__diagnostic_log__c where fsCore__Related_Record_Id__c in :testApps];
                //delete [select id from fscore__apex_batch_job_detail__c];
                //delete [select id from fscore__file_data_dump_detail__c];
                //delete [select id from fscore__file_data_dump__c];
                
                
            } 
            
        }catch(Exception e)  {
            system.debug(logginglevel.error,' EXCEPTION ****   '+e.getStackTraceString() +e);
            Throw e;
        }
        
    }
    
    global void finish(Database.BatchableContext pContext){
        
    }
    
    global void execute(SchedulableContext SC) {
        ApplicationAutoPurgeTestDataJob testJob = new ApplicationAutoPurgeTestDataJob();
        id batchId = Database.executeBatch(testJob,1);
    }    
    
}