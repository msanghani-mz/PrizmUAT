/**
* Class Name  : ApplicationAutoWithdrawJob (PDI-665,VCL-183,VCL-174)
* Description : This batch job will autowithdraw the application
*               if the borrower has not uploaded all the required 
*               documents within 30 days of receiving a Loan Processing Letter (DNL)
*               Does not upload all docs in 15 days (VCL)
* 				 Does not sign the pre-tila in 15 days (VCL)
* Author      : Financial Spectra
*
*/
global with sharing class ApplicationAutoWithdrawJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'ApplicationAutoWithdrawJob';
    
    global ApplicationAutoWithdrawJob(){
        setJobQuery(getDefaultQuery());
    }
    
    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
            .addField('Id')
            .addField('Name')
            .addField('RecordType.DeveloperName')
            .addField('Incomplete_App_Auto_Withdraw_Date__c')
            .addField('Loan_Processing_Letter_Sent_Date__c')         
            .addField('fsCore__Application_Status__c')         
            .addField('Is_PreTila_Signed__c')
            .addField('Withdraw_Reason__c')
            .addField('Number_Of_Checklist_Documents_Rejected__c')
            .addField('Pending_Document_Checklist_Count__c')         
            .addField('fsCore__Is_Application_Read_Only__c')
            .addField('Pre_TILA_Sent_Date__c')
            .addField('Pre_Tila_Sent_Date_First__c')
            .addField('Auto_Withdrawn_Date__c')            
            .addField('Loan_Type__c')            
            .addWhereConditionWithValue(1, 'fsCore__Is_Application_Read_Only__c', '=',false)
            .addWhereConditionWithValue(2, 'fsCore__Application_Status__c', '!=','Withdrawn')  //IGNORE THE APPLICATIONS WHICH ARE ALREADY WITHDRAWN          
            .addWhereConditionWithValue(3, 'Incomplete_App_Auto_Withdraw_Date__c', '<=', System.today());
            //.addWhereConditionWithValue(4, 'Name', '=', 'DNL190711004825');
        System.debug(loggingLevel.ERROR,'jobQuery getQuery:---'+jobQuery);
        return jobQuery;
    }        
    
    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }
    
    global override void setParameterizedJobQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        setJobQuery(jobQuery.getQueryString());
    }
    
    global override String getClassName(){
        return CLASS_NAME;
    }
    
    global override void startJob(Database.BatchableContext pContext){ 
        System.debug(loggingLevel.ERROR,'Start Method:---');
    }
    
    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug(loggingLevel.error, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.error, 'Scope Count : ' + pScope.size());
        try{
            if (pScope.size() == 0){ return null; }
            
            Set<ID> appIds = new Set<ID>();
            for (fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pScope){
                appIds.add(app.id);
            }
            System.debug(loggingLevel.error, appIds);
            Map<Id, dsfs__DocuSign_Status__c> appIdToDocuSignMap = new Map<Id, dsfs__DocuSign_Status__c>();
            
            for (dsfs__DocuSign_Status__c docuSign : [SELECT Id
                                                      , Lending_Application_Name__c
                                                      FROM dsfs__DocuSign_Status__c 
                                                      WHERE Lending_Application_Name__c in :appIds]){
                                                          appIdToDocuSignMap.put(docuSign.Lending_Application_Name__c, docuSign);
                                                      }
            
            for (fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pScope){
                
                System.debug(loggingLevel.error,app.Name +'  '+
                             ':: Before Update Number_Of_Checklist_Documents_Rejected__c ==> '+app.Number_Of_Checklist_Documents_Rejected__c +
                             '  :: Pending_Document_Checklist_Count__c ==> '+app.Pending_Document_Checklist_Count__c +
                             '  :: Is_PreTila_Signed__c ==> '+app.Is_PreTila_Signed__c +
                             '  :: fsCore__Application_Status__c ==> '+app.fsCore__Application_Status__c +
                             '  :: Withdraw_Reason__c ==> '+app.Withdraw_Reason__c +
                             ' :: Incomplete_App_Auto_Withdraw_Date__c ==> '+app.Incomplete_App_Auto_Withdraw_Date__c);  
                
                
                //Although this should never happen but just in case
                //never update anything on read only application
                if (app.fsCore__Is_Application_Read_Only__c){
                    continue;
                }
                //DNL-47
                if (app.Loan_Type__c == 'DNL'){
                    //DV-170
                    //SFS also change the app status to Pre-TILA Withdrawn
                    // In case of the status is Pre-TILA Withdrawn Skip the record.
                    if (app.fsCore__Application_Status__c != null) {
                        if((app.fsCore__Application_Status__c.equalsIgnoreCase('Pre-TILA Withdrawn'))
                            ||(app.fsCore__Application_Status__c.equalsIgnoreCase('Pending Decline'))){

                            continue;
                        }
                    }
                    if ((app.Pre_Tila_Sent_Date_First__c != null ) 
                        && (!app.Is_PreTila_Signed__c)
                        && (app.fsCore__Application_Status__c == 'Pre-TILA Sent')
                        && (app.Pre_Tila_Sent_Date_First__c.addDays(15) <= Date.Today())){

                            app.fsCore__Application_Status__c = 'Pre-TILA Withdrawn';

                    }else{
                        app.fsCore__Application_Status__c = 'Withdrawn';
                    }
                    app.Auto_Withdrawn_Date__c = Date.Today();
                    app.Withdraw_Reason__c = 'No Reason/Unresponsive';  
                    app.fsCore__Is_Application_Read_Only__c  = true;
                    system.debug(logginglevel.ERROR, 'Inside the DNL If Condition..');                    
                    
                    //This will get the callout limit error, Created new Job ApplicationWithdrawVoidEnvelopeJob which 
                    //needs to run in batchsize 1
                    /*if ((app.Pre_Tila_Sent_Date_First__c != null ) 
                        && (!app.Is_PreTila_Signed__c)
                        && (app.Pre_Tila_Sent_Date_First__c.addDays(15) <= Date.Today())){
                            
                            VoidDocusignEnvelopeController.voidEnvelope(appIdToDocuSignMap.get(app.Id).id);
                            
                            system.debug(logginglevel.ERROR, 'Inside the Void Envelope condition..');
                            system.debug(logginglevel.ERROR, appIdToDocuSignMap);
                        }*/
                    
                }else if (app.Loan_Type__c == 'VCL'){
                    //VCL-183   
                    if ( (app.Is_PreTila_Signed__c) && (app.Pending_Document_Checklist_Count__c > 0)
                       // && (app.Number_Of_Checklist_Documents_Rejected__c > 0)
                       ){
                        app.fsCore__Application_Status__c = 'Withdrawn';
                        app.Withdraw_Reason__c = 'No Activity';  
                        app.Auto_Withdrawn_Date__c = Date.Today();            
                        app.fsCore__Is_Application_Read_Only__c  = true;  
                        
                    }
                    //VCL-174
                    if ((!app.Is_PreTila_Signed__c) && (app.Pre_TILA_Sent_Date__c != null)){
                        app.fsCore__Application_Status__c = 'Withdrawn';
                        app.Withdraw_Reason__c = 'No Reason/Unresponsive';
                        app.Auto_Withdrawn_Date__c = Date.Today();
                        app.fsCore__Is_Application_Read_Only__c  = true;
                        
                    }
                /*    if ((app.Pre_TILA_Signed_Date__c +15 <= System.today()) && (app.Pending_Document_Checklist_Count__c > 0)){
                        app.fsCore__Application_Status__c = 'Withdrawn';
                        app.Withdraw_Reason__c = 'No Activity';
                        app.Auto_Withdrawn_Date__c = Date.Today();
                        app.fsCore__Is_Application_Read_Only__c  = true;
                        
                    }
*/
                }
                System.debug(loggingLevel.error,app.Name +'  '+
                             '::  After Update Number_Of_Checklist_Documents_Rejected__c ==> '+app.Number_Of_Checklist_Documents_Rejected__c +
                             '  :: Pending_Document_Checklist_Count__c ==> '+app.Pending_Document_Checklist_Count__c +
                             '  :: Is_PreTila_Signed__c ==> '+app.Is_PreTila_Signed__c +
                             '  :: fsCore__Application_Status__c ==> '+app.fsCore__Application_Status__c +
                             '  :: Withdraw_Reason__c ==> '+app.Withdraw_Reason__c +
                             ' :: Incomplete_App_Auto_Withdraw_Date__c ==> '+app.Incomplete_App_Auto_Withdraw_Date__c);  
            }
            
            update pScope;      
        }catch(Exception e)  {
            system.debug(logginglevel.error,' EXCEPTION ****   '+e.getStackTraceString() +e);
            Throw e;
        }
        
        return new List<fsCore.ErrorObject>();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}
    
    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Application_Auto_Withdraw_Job');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    
    
}