/*
* Class Name   - GenerateFraudFlagActionProcessor
* Description  - Action class to generate fraud flags for lending applications
* Developer(s) - Financial Spectra
*
*/
global with sharing class GenerateFraudFlagActionProcessor extends fsCore.ApplicationActionProcessorBase{
    private static final String CLASS_NAME = 'GenerateFraudFlagActionProcessor';
    
    private Map<String, Set<Id>> mApplicationToAvailableFlagMap;
    private Map<Id, Fraud_Flag_Setup__c> mFraudFlagMap;
    private Map<Id, Set<Id>> mApplicationToExistingFlagMap;
    
    global GenerateFraudFlagActionProcessor(){
        super();
    }
    
    global override void populateAndValidateRelatedData(){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.populateAndValidateRelatedData(+)');
        // get available fraud flags by evaluating mappings
        populateAvailableFraudFlags();
        
        // get existing fraud flag of applications
        populateExistingFraudFlags();
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.populateAndValidateRelatedData(-)');
    }
    
    private void populateAvailableFraudFlags(){
        Map<String, fsCore.MappingEvaluationInputObject> mappingEvalInputMap = new Map<String, fsCore.MappingEvaluationInputObject>();
        String productFamily;
        
        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            fsCore.MappingEvaluationInputObject applMappEvalObj = fsCore.LendingApplicationUtil.getMappingEvalInput(application);
            mappingEvalInputMap.put(String.valueOf(application.Id), applMappEvalObj);
            productFamily = application.fsCore__Product_Family__c;
        }
        System.debug(loggingLevel.ERROR, '-- Mapping Evaluation Input : ' + mappingEvalInputMap);
        System.debug(loggingLevel.ERROR, '-- Product Family : ' + productFamily);
        
        List<Fraud_Flag_Setup__c> fraudFlagSetupRecords = [SELECT Id, Name
                                                           , Fraud_Flag_Code__c
                                                           , Is_Active__c 
                                                           , Default_Company_Availability__c
                                                           , Default_Product_Availability__c 
                                                           , Default_Selection_Rule_Result__c
                                                           , Is_Loan__c
                                                           , Is_Line__c
                                                           , Is_Lease__c
                                                           , Product_Family__c
                                                           , Selection_Order__c
                                                           , Severity__c
                                                           , Start_Date__c
                                                           , End_Date__c 
                                                           FROM Fraud_Flag_Setup__c
                                                           WHERE Is_Active__c = true];
        
        fsCore.SetupMappingEvaluator fraudFlagMappEval = new fsCore.SetupMappingEvaluator(mappingEvalInputMap
                                                                                          , Schema.SObjectType.Fraud_Flag_Setup__c.getName()
                                                                                          , productFamily);
        fraudFlagMappEval.setSetupRecords(fraudFlagSetupRecords);
        mApplicationToAvailableFlagMap = fraudFlagMappEval.evaluate();
        System.debug(loggingLevel.ERROR, '-- available fraud flags : ' + mApplicationToAvailableFlagMap);
    }
    
    private void populateExistingFraudFlags(){
        List<Lending_Application_Fraud_Flag__c> existingFlags = [SELECT Id, Fraud_Flag_Name__c
                                                                 , Lending_Application_Number__c
                                                                 FROM Lending_Application_Fraud_Flag__c
                                                                 WHERE Lending_Application_Number__c IN :mApplicationMap.keySet()
                                                                 ORDER BY Lending_Application_Number__c];
        
        // this is an application id to set of exisitng fraud flag setup Id map
        mApplicationToExistingFlagMap = new Map<Id, Set<Id>>();
        
        for (Lending_Application_Fraud_Flag__c appFF : existingFlags){
            Set<Id> existingFraudFlagIdSet = new Set<Id>();
            if (mApplicationToExistingFlagMap.containsKey(appFF.Lending_Application_Number__c)){
                existingFraudFlagIdSet = mApplicationToExistingFlagMap.get(appFF.Lending_Application_Number__c);
            }
            existingFraudFlagIdSet.add(appFF.Fraud_Flag_Name__c);
            mApplicationToExistingFlagMap.put(appFF.Lending_Application_Number__c, existingFraudFlagIdSet);
        }
        System.debug(loggingLevel.ERROR, '-- existing fraud flags : ' + mApplicationToExistingFlagMap);
    }
    
    global override void doProcess(){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.doProcess(+)');
        List<Lending_Application_Fraud_Flag__c> newFraudFlagsForInsert = new List<Lending_Application_Fraud_Flag__c>();
        
        //create new fraud flags for application
        for(Id applicationId : mApplicationToAvailableFlagMap.keySet()){
            for(Id fraudFlagId : mApplicationToAvailableFlagMap.get(applicationId)){
                
                Set<Id> existingFlagsSet = new Set<Id>();
                if (mApplicationToExistingFlagMap.containsKey(applicationId)){
                    existingFlagsSet = mApplicationToExistingFlagMap.get(applicationId);
                }
                
                //skip if the fraud flag already exists
                if (existingFlagsSet.contains(fraudFlagId)){ continue; }
                
                Lending_Application_Fraud_Flag__c appFraudFlag = new Lending_Application_Fraud_Flag__c();
                appFraudFlag.Lending_Application_Number__c = applicationId;
                appFraudFlag.Fraud_Flag_Name__c = fraudFlagId;
                appFraudFlag.Status__c = 'Pending Review';
                
                newFraudFlagsForInsert.add(appFraudFlag);
            }
        }
        
        System.debug(loggingLevel.ERROR,'--Number of Fraud Flag for insert : ' + String.valueOf(newFraudFlagsForInsert.size()));
        
        //perform dml
        if (newFraudFlagsForInsert.size() > 0){
            Database.SaveResult[] appFraudFlagSR = Database.insert(newFraudFlagsForInsert);
            
            //handler errors
            for (Integer i = 0; i < appFraudFlagSR.size(); i++){
                if (!appFraudFlagSR.get(i).isSuccess()){
                    for(Database.Error err : appFraudFlagSR.get(i).getErrors()){
                        addError(String.valueOf(err.getStatusCode()), err.getMessage() + ' : ' + String.valueOf(err.getFields()), 'process() ... saving records', newFraudFlagsForInsert.get(i).Lending_Application_Number__c, JSON.serialize(newFraudFlagsForInsert.get(i)));
                    }
                }
            }
        }
        if (mActionOutput.getIsSuccess()){
            mActionOutput.setMessage( 'Fraud Flags have been successfully created' );
        }
        
        System.debug(loggingLevel.ERROR, '-- Output : ' + String.valueOf(mActionOutput));
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.doProcess(-)');
    }
    
    global override String getClassName(){
        return CLASS_NAME;
    }
}