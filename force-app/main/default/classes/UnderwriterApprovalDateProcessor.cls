/*
* FinancialSpectra Pty Ltd
* 
*
* PDI-672 Description  - Action class to set the approval date and 
* , contract date, first payment date and regenerate the pricing 
*
*
*/
global virtual class UnderwriterApprovalDateProcessor implements fsCore.ActionProcessor{
    private static final String CLASS_NAME = 'UnderwriterApprovalDateProcessor';
    
    private Map<Id, fsCore__Lending_Application__c> mApplicationMap;
    
    private Map<Id, fsCore__Pricing_Setup__c> mAppPricing;
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private Set<Id> mErrorAppIdSet;
    private Set<Id> mAppNotFoundSet;
    
    
    
    global UnderwriterApprovalDateProcessor(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
        mAppPricing = new Map<Id, fsCore__Pricing_Setup__c>();
        mErrorAppIdSet = new Set<Id>();
        mAppNotFoundSet = new Set<Id>();        
    }
    global void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }    
    public void populateAndValidateApplications(){
        fsCore.Logger.enter(CLASS_NAME,'populateAndValidateRelatedData()');
        
        mApplicationMap = fsCore.LendingApplicationUtil.getApplications(mActionInput.getRecords());
        
        fsCore.Logger.exit(CLASS_NAME,'populateAndValidateRelatedData()');
    }
    
    private void populatePricingApplicationMap(){
        
        Set<Id> pricingIdSet = new Set<Id>();
        Map<Id,Id> pricingAppMap = new Map<Id,Id>();
        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            System.debug(application.fsCore__Pricing_Name__c);
            if (application.fsCore__Pricing_Name__c != null){
                pricingIdSet.add(application.fsCore__Pricing_Name__c);
                pricingAppMap.put(application.fsCore__Pricing_Name__c,application.Id);
            }else{
                mErrorAppIdSet.add(application.Id);
            }
            
        }   
        fsCore.DynamicQueryBuilder pricingSetupQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Pricing_Setup__c.getName())
            .addFields()
            .addWhereConditionWithBind(1,'Id','IN','pricingIdSet');
        
        List<fsCore__Pricing_Setup__c> pricingSetupList = (List<fsCore__Pricing_Setup__c>)Database.query(pricingSetupQuery.getQueryString());
        
        for (fsCore__Pricing_Setup__c pricingSetup : pricingSetupList){
            mAppPricing.put(pricingAppMap.get(pricingSetup.Id),pricingSetup);
            
        }
        
    }      
    
        
    global void process(){
        Savepoint processingSP = Database.setSavepoint();
        try{
            //populate application and validate
            populateAndValidateApplications();
            
            populatePricingApplicationMap();
            
            //populate related data and validate
            if (mApplicationMap.size() > 0){
                removeErroneousApplications();
                //do processing
                doProcess();

            }            
            logMessage('mApplicationMap : ' + mApplicationMap.size());
                                
            
        } catch (Exception e){
            Database.rollback(processingSP);
            mActionOutput.addError(new fsCore.ErrorObject(e));
        }
    }
    
    private void removeErroneousApplications(){
        //remove erroneous apps from application map
        for(Id errAppId : mErrorAppIdSet){
            if (mApplicationMap.containsKey(errAppId)){ 
                mApplicationMap.remove(errAppId); 
            }
        }
        logMessage('Applications to be processed after filtering : ' + mApplicationMap.size());
        
        //reset the error application set
        mErrorAppIdSet = new Set<Id>();
    }
    
    
    private void doProcess(){
        
        logMessage(CLASS_NAME+'.doProcess(+)');
        
        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            
            fsCore.PricingOfferGenerator poGen = new fsCore.PricingOfferGenerator(application, mAppPricing.get(application.Id));
            poGen.setDefaultInputParameters();
            

            Integer secondPaymentDueDay = fsCore.Constants.DUMMY_SECOND_DUE_DAY;
            if (application.fsCore__Payment_Cycle__c == fsCore.Constants.CYCLE_TWICE_MONTHLY){
                secondPaymentDueDay = (Integer)application.fsCore__Payment_Due_Day_2__c;
            }            
            fsCore.PricingOfferInputObject poInputObj = new fsCore.PricingOfferInputObject();
            poInputObj.setBranchCode(application.fsCore__Branch_Code_Formula__c);
            poInputObj.financedAmount = application.fsCore__Approved_Financed_Amount__c ; 
            poInputObj.prepaidfee = application.fsCore__Approved_Prepaid_Fee__c ; 
            poInputObj.financeFee = application.fsCore__Approved_Finance_Fee__c ; 
            poInputObj.rate = application.fsCore__Rate__c ; 
            poInputObj.numberOfPayments = (Integer)application.fsCore__Number_Of_Payments__c ; 
            poInputObj.paymentCycle = application.fsCore__Payment_Cycle__c ; 
            poInputObj.paymentAmount = application.fsCore__Payment_Amount__c ; 
            poInputObj.contractStartDate = system.today().addDays(60);
            poInputObj.firstPaymentDate = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(poInputObj.contractStartDate
                                                            , (Integer)application.fsCore__Payment_Due_Day__c
                                                            , secondPaymentDueDay
                                                            , application.fsCore__Payment_Cycle__c);            
            
            //DV-184
            if (application.fsCore__Payment_Cycle__c == fsCore.Constants.CYCLE_TWICE_MONTHLY){
                poInputObj.secondPaymentDate = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(poInputObj.firstPaymentDate
                                                                                        , (Integer)application.fsCore__Payment_Due_Day__c
                                                                                        , secondPaymentDueDay
                                                                                         , application.fsCore__Payment_Cycle__c);     
            }                                                                                            
            system.debug(logginglevel.error,'poInputObj :'+poInputObj);
            poGen.setInputParameters(poInputObj);
            poGen.generateOffer();
            
            poGen.saveOffer();
            poGen.acceptOffer();
            poGen.calculateAPR();
            
        }
        
        
        logMessage(CLASS_NAME+'.doProcess(-) ');        
        logMessage('-- Output : ' + String.valueOf(mActionOutput));
        
    }
    @TestVisible
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
    @TestVisible
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