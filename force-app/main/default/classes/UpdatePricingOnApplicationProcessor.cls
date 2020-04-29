/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 *
 * Description  - Action class to get pricing and update on the lending application
 *
 *
 */
global virtual class UpdatePricingOnApplicationProcessor implements fsCore.ActionProcessor{
    private static final String CLASS_NAME = 'UpdatePricingOnApplicationProcessor';
    
    private Map<Id, fsCore__Lending_Application__c> mApplicationMap;
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private Set<Id> mErrorAppIdSet;
    private Set<Id> mAppNotFoundSet;
    private Map<String, List<fsCore__Pricing_Setup__c>> mAvailablePricings;

    
    
    global UpdatePricingOnApplicationProcessor(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
        mErrorAppIdSet = new Set<Id>();
        mAppNotFoundSet = new Set<Id>();        
    }
    global void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }    
    public void getAvailablePricings(){
        System.debug(loggingLevel.ERROR,'getAvailablePricings(+)');
        mAvailablePricings = fsCore.PricingUtil.getAvailablePricingsMap(mApplicationMap.Values(), true);

        System.debug(loggingLevel.ERROR,'getAvailablePricings(-)');
    }
    private void populateAndValidateApplications(){
        mApplicationMap = fsCore.LendingApplicationUtil.getApplications(mActionInput.getRecords());
    }    


    private void updateApplicationWithPricing(){
        for (String appIdString: mAvailablePricings.keySet()){
            fsCore__Pricing_Setup__c pricing = mAvailablePricings.get(appIdString)[0];
            if (mApplicationMap.get(Id.ValueOf(appIdString)).fsCore__Rate__c == null){
                mApplicationMap.get(Id.ValueOf(appIdString)).fsCore__Rate__c  = pricing.fsCore__Rate_Value__c;
            }else{
                mErrorAppIdSet.add(Id.ValueOf(appIdString));
            }
        }
    }     

    global void process(){
        Savepoint processingSP = Database.setSavepoint();
        try{
                populateAndValidateApplications();
                //populate application and validate
                getAvailablePricings();
                
                //populate related data and validate
                if (mApplicationMap.size() > 0){
                    updateApplicationWithPricing();
                    removeErroneousApplications();
                }            
                
                //do processing
                if (mApplicationMap.size() > 0){
                    doProcess();
                }
        } catch (Exception e){
            Database.rollback(processingSP);
            mActionOutput.addError(new fsCore.ErrorObject(e));
        }
    }

    private void removeErroneousApplications(){
        //remove erroneous apps from application map
        for(Id errAppId : mErrorAppIdSet){
            if (mApplicationMap.containsKey(errAppId)){ mApplicationMap.remove(errAppId); }
        }
        logMessage('Applications to be processed after filtering : ' + mApplicationMap.size());
        
        //reset the error application set
        mErrorAppIdSet = new Set<Id>();
    }  

    private void doProcess(){

        logMessage(CLASS_NAME+'.doProcess(+)');
        //perform dml
        fsCore.DMLResult appDMLRslt = fsCore.LendingApplicationDMLWrapper.getInstance().updateData(mApplicationMap.values());

        Database.SaveResult[] chkItemSR = appDMLRslt.getSaveResult();
        if (appDMLRslt.hasErrors()) {
            for (Integer i = 0; i < chkItemSR.size(); i++){
                if (!chkItemSR.get(i).isSuccess()){
                    for(Database.Error err : chkItemSR.get(i).getErrors()){
                        addError(String.valueOf(err.getStatusCode()), err.getMessage() + ' : ' + String.valueOf(err.getFields()), 'process() ... saving records', mApplicationMap.values().get(i).ID, JSON.serialize(mApplicationMap.values().get(i)));
                    }
                }
            }
        }        
        

        logMessage(CLASS_NAME+'.doProcess(-) ');        
        logMessage('-- Output : ' + String.valueOf(mActionOutput));
        
    }
    private void addError(String pErrCode, String pErrMsg, String pTrace, Id pAppId, String pRelatedRecord){
        fsCore.ErrorObject errorObj = new fsCore.ErrorObject();
        errorObj.setErrorCode(pErrCode);
        errorObj.setErrorMessage(pErrMsg);
        
        if (pAppId != null){
            errorObj.setErrorRecordId(pAppId);
            mErrorAppIdSet.add(pAppId);
        }
        if (String.IsNotBlank(pRelatedRecord)){
            errorObj.setErrorRecord(pRelatedRecord);
        }

        addError(errorObj, pTrace);
    }
    private void addError(fsCore.ErrorObject pErrorObj, String pMethod){
        pErrorObj.setErrorStackTrace(getClassName() + '.' + pMethod);
        
        if (pErrorObj.getErrorRecordId() != null && mApplicationMap.containsKey(pErrorObj.getErrorRecordId())){
            pErrorObj.setErrorRecordName(mApplicationMap.get(pErrorObj.getErrorRecordId()).Name);
        }

        if (mActionInput.getRecords().size() == 1){
            mActionOutput.setMessage(pErrorObj.getErrorMessage());    
        }

        mActionOutput.addError(pErrorObj);
    }    

 
    private static void logmessage(Object pMessage){
        system.debug(logginglevel.error, pMessage);
    }     
    public String getClassName(){
        return CLASS_NAME;
    }
    global fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }    
}