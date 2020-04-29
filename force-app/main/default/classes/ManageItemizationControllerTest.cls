/*
* Class Name   - ManageItemizationControllerTest
* Description  - Controller to edit/delete the Lending Application Itemizations
* Developer(s) - Financial Spectra
*
*/
public with sharing class ManageItemizationControllerTest{
    private static final String CLASS_NAME = 'ManageItemizationControllerTest';

    public fsCore__Lending_Application__c mApplication {get; private set;}

    public Boolean mIsManualItmzAllowed {get; private set;}
    public Integer mSelectedRecordNumber {get; set;}
    public List<LendingApplicationItemizationObject> mItemizationObjectList {get; set;}
    private List<fsCore__Lending_Application_Itemization__c> mRemovedItemizationList;
    public Boolean pageOpenedFromTILA {get; private set;}
    
    private Map<String, List<DNL_Settlement_Rates__c>> mDnlSettlementRatesMap  {get; set;}
    
    public Decimal mApprovedFinancedAmount {get; private set;}
    public Decimal mApprovedFinanceFee {get; private set;}
    public Decimal mApprovedPrepaidFee {get; private set;}
    public Decimal mActualFinancedAmount {get; private set;}
    public Decimal mActualFinanceFee {get; private set;}
    public Decimal mActualPrepaidFee {get; private set;}

    private Boolean mRecalcRequired;
    
    public ManageItemizationControllerTest(ApexPages.StandardController pStdController){
        mApplication = (fsCore__Lending_Application__c)pStdController.getRecord();
        if (mApplication.Id == null){
            throw new CustomException('This page cannot be displayed for a new unsaved application.');
        }
        init();  
    }
    
    private void init(){
        if (mApplication.id != null){
            mApplication = getApplicationRecord(mApplication.Id);
            mIsManualItmzAllowed = mApplication.fsCore__Is_Manual_Itemizations_Allowed__c;
            mDnlSettlementRatesMap = new MAP<String, List<DNL_Settlement_Rates__c>>();//PDI-713
            populateItemizations();
            setItemizedAmounts();
            
            pageOpenedFromTILA = false;
            if (apexpages.currentpage().getparameters().get('source') != null){
                pageOpenedFromTILA = true;
            }
            mRecalcRequired = false;
        }
    }
    

    public static fsCore__Lending_Application__c getApplicationRecord(Id pApplicationId){
        fsCore.DynamicQueryBuilder applicationQry = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName());
        applicationQry.addFields();
        applicationQry.addField('Loan_Officer__r.firstName');
        applicationQry.addField('Loan_Officer__r.LastName');
        applicationQry.addWhereConditionWithValue(1,'Id', '=', pApplicationId);
        
        List<fsCore__Lending_Application__c> applicationList = (List<fsCore__Lending_Application__c>)Database.query(applicationQry.getQueryString());
        if (applicationList.size() == 0){
            return null;
        }
        return applicationList.get(0);
    }       
    private void addError(String pMessage){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, pMessage));
    }

    public PageReference tilaDashboard(){
        PageReference tilaDashboard = new PageReference('/apex/tilaDashboard?id='+mApplication.Id);
        return tilaDashboard;
    }
    
    private void populateItemizations(){
        List<fsCore__Lending_Application_Itemization__c> appItmzList = getItemizations(mApplication.id);
        mItemizationObjectList = new List<LendingApplicationItemizationObject>();
        setItemizationObjectList(appItmzList);
        
        mRemovedItemizationList = new List<fsCore__Lending_Application_Itemization__c>();
    }
    
    private void setItemizationObjectList(List<fsCore__Lending_Application_Itemization__c> pAppItemizationList){
        Set<Id> itmzIdSet = new Set<Id>();
        Set<String> feeCategorySet = new Set<String>();
        Set<Id> feeIdSet = new Set<Id>();
        
        for(fsCore__Lending_Application_Itemization__c appItmz : pAppItemizationList){
            itmzIdSet.add(appItmz.fsCore__Itemization_Name__c);
            if (String.isNotBlank(appItmz.fsCore__Fee_Category__c)){ feeCategorySet.add(appItmz.fsCore__Fee_Category__c); }
            if (appItmz.fsCore__Fee_Name__c != null){ feeIdSet.add(appItmz.fsCore__Fee_Name__c); }
        }

        Map<Id, fsCore__Itemization_Setup__c> itemizationMap = new Map<Id, fsCore__Itemization_Setup__c>([
                                            SELECT Id, Name FROM fsCore__Itemization_Setup__c
                                             WHERE Id IN : itmzIdSet]);
        
        Map<String, List<fsCore__Fee_Setup__c>> categoryToFeesMap = new Map<String, List<fsCore__Fee_Setup__c>>();
        
        if (feeCategorySet.size() > 0){
            categoryToFeesMap = fsCore.OriginationFeeUtil.getAvailableFeesByCategory(feeCategorySet, mApplication, true);
        }
        System.debug(loggingLevel.ERROR, 'Category-To-Fee Map : ' + categoryToFeesMap);
        
        if (categoryToFeesMap.size() > 0){
            for (String feeCateg : categoryToFeesMap.keySet()){
                for(fsCore__Fee_Setup__c fee : categoryToFeesMap.get(feeCateg)){
                    feeIdSet.add(fee.Id);
                }
            }
        }
            
        Map<Id, fsCore__Fee_Setup__c> feeSetupMap = fsCore.FeeCalculationUtil.getFeeSetupMap(feeIdSet, mApplication.fsCore__Application_Date__c, mApplication.fsCore__Product_Family__c);
        System.debug(loggingLevel.ERROR, 'Fee Setup map size : ' + feeSetupMap.size());

        Integer recNumber = fsCore.SpectraCoreUtil.getRandomInteger();
        for(fsCore__Lending_Application_Itemization__c appItmz : pAppItemizationList){
            LendingApplicationItemizationObject itmzObj = new LendingApplicationItemizationObject(appItmz);
            itmzObj.setRecordNumber(recNumber);
            itmzObj.setItemizationName(itemizationMap.get(appItmz.fsCore__Itemization_Name__c).Name);

            //SFS DON'T WANT TO DISPLAY CREDIOR NAME WITH THOSE ITEMIZATIONS
            if ((itmzObj.getItemizationName()=='One month of payment to DRP')            
                ||(itmzObj.getItemizationName()=='Dedicated Account Cash')
                ||(itmzObj.getItemizationName()=='Remaining Fees due to DRP')){
               
                 itmzObj.setIsCreditorNameDisplayedType(false);
            }            

            Map<Id, fsCore__Fee_Setup__c> availableFeeMap = new Map<Id, fsCore__Fee_Setup__c>();
            
            if (String.isNotBlank(appItmz.fsCore__Fee_Category__c) && categoryToFeesMap.containsKey(appItmz.fsCore__Fee_Category__c)){
                for(fsCore__Fee_Setup__c origFee : categoryToFeesMap.get(appItmz.fsCore__Fee_Category__c)){
                    if (origFee.fsCore__Record_Type_Name__c == appItmz.fsCore__Itemization_Family__c){
                        availableFeeMap.put(origFee.Id, origFee);
                    }
                }
            }
                
            itmzObj.setFeeSelectList(availableFeeMap.values());
            
            if (appItmz.fsCore__Fee_Name__c == null && availableFeeMap.size() > 0){
                appItmz.fsCore__Fee_Name__c = availableFeeMap.values().get(0).Id;
            }
                
            if (appItmz.fsCore__Fee_Name__c != null && availableFeeMap.containsKey(appItmz.fsCore__Fee_Name__c)){
                itmzObj.setFeeSetup(feeSetupMap.get(appItmz.fsCore__Fee_Name__c));
            } 
            else {
                appItmz.fsCore__Fee_Name__c = null;
                itmzObj.setFeeSetup(null);
            }
            
            //PDI-713 Start
            List <DNL_Settlement_Rates__c> dnlSettlementRateList;
            if (SFS_System_Settings__c.getInstance().Is_DNL_Settlement_Active_Rates_Only__c){
                dnlSettlementRateList = [SELECT id, Original_Creditor__c,Current_Creditor__c,Average_of_Adjusted_Settlement__c,Type__c FROM DNL_Settlement_Rates__c where IsActive__c = true order by Current_Creditor__c];
            } else{
                dnlSettlementRateList = [SELECT id, Original_Creditor__c,Current_Creditor__c,Average_of_Adjusted_Settlement__c,Type__c FROM DNL_Settlement_Rates__c order by Current_Creditor__c];
            }
            string currentCreditor;
            List<DNL_Settlement_Rates__c> creditorList = new List<DNL_Settlement_Rates__c>();
            for(DNL_Settlement_Rates__c dsr : dnlSettlementRateList){
                if ((currentCreditor == null)
                    ||currentCreditor != dsr.Current_Creditor__c){
                     if (currentCreditor == null){
                        currentCreditor = dsr.Current_Creditor__c;
                        creditorList = new List<DNL_Settlement_Rates__c>();
                     }else{
                         mDnlSettlementRatesMap.put(currentCreditor,creditorList);
                         currentCreditor = dsr.Current_Creditor__c;
                         creditorList = new List<DNL_Settlement_Rates__c>();
                     }
                     creditorList.add(dsr);
                }
                if (creditorList.size()>0){
                    mDnlSettlementRatesMap.put(currentCreditor,creditorList);
                }
            }
            itmzObj.mCurrentCreditorLov = new List<String>(mDnlSettlementRatesMap.keySet());
            //PDI-713 End
            mItemizationObjectList.add(itmzObj);
            recNumber++;
        }
    }  

    /*
     * Method to get application itemizations
     */
    private static List<fsCore__Lending_Application_Itemization__c> getItemizations(Id pApplicationId){
        return getItemizationsMap(new Set<Id>{pApplicationId}).get(pApplicationId);
    }

    private static Map<Id, List<fsCore__Lending_Application_Itemization__c>> getItemizationsMap(Set<Id> pApplicationIdSet){
        Map<Id, List<fsCore__Lending_Application_Itemization__c>> applicationToItmzListMap = new Map<Id, List<fsCore__Lending_Application_Itemization__c>>();
        
        if (pApplicationIdSet == null || pApplicationIdSet.size() == 0) return applicationToItmzListMap;
        
        for (Id applicationId : pApplicationIdSet){
            applicationToItmzListMap.put(applicationId, new List<fsCore__Lending_Application_Itemization__c>());
        }

        fsCore.DynamicQueryBuilder itmzQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application_Itemization__c.getName())
                                                        .addFields()
                                                        .addField('Tradeline_Name__r.name')
                                                        .addField('Tradeline_Name__r.Estimated_Settlement__c')
                                                        .addField('Tradeline_Name__r.Current_Stage__c')
                                                        .addField('Tradeline_Name__r.Litigation_Stage__c')
                                                        .addWhereConditionWithBind(1,'fsCore__Lending_Application_Number__c', 'IN', 'pApplicationIdSet')
                                                        .addOrderByField('fsCore__Lending_Application_Number__c')
                                                        .addOrderByField('fsCore__Itemization_Family__c')
                                                        .addOrderByField('Name');
                                                
        List<fsCore__Lending_Application_Itemization__c> itmzList = (List<fsCore__Lending_Application_Itemization__c>)Database.query(itmzQuery.getQueryString());

        for (fsCore__Lending_Application_Itemization__c itmz : itmzList){
            if (applicationToItmzListMap.containsKey(itmz.fsCore__Lending_Application_Number__c)){
                applicationToItmzListMap.get(itmz.fsCore__Lending_Application_Number__c).add(itmz);
            }
        }
         
        return applicationToItmzListMap;
    }    

    private void setItemizedAmounts(){
        mApprovedFinancedAmount = 0.00;
        mActualFinancedAmount = 0.00;
        
        mApprovedFinanceFee = 0.00;
        mActualFinanceFee = 0.00;
        
        mApprovedPrepaidFee = 0.00;
        mActualPrepaidFee = 0.00;
    
        for (LendingApplicationItemizationObject appItmzObj : mItemizationObjectList){
            Decimal approvedAmount = (appItmzObj.getItemization().fsCore__Approved_Amount_Unsigned__c == null ? 0.00 : appItmzObj.getItemization().fsCore__Approved_Amount_Unsigned__c);
            Decimal signedApprovedAmount = (appItmzObj.getItemization().fsCore__Plus_Or_Minus__c.equals(fsCore.Constants.MINUS) ? (-1 * approvedAmount) : approvedAmount);
            
            Decimal actualAmount = (appItmzObj.getItemization().fsCore__Actual_Amount_Unsigned__c == null ? 0.00 : appItmzObj.getItemization().fsCore__Actual_Amount_Unsigned__c);
            Decimal signedActualAmount = (appItmzObj.getItemization().fsCore__Plus_Or_Minus__c.equals(fsCore.Constants.MINUS) ? (-1 * actualAmount) : actualAmount);
                    
            if (appItmzObj.getItemization().fsCore__Itemization_Family__c == fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT){
                mApprovedFinancedAmount += signedApprovedAmount;
                mActualFinancedAmount += signedActualAmount;
            }
            else if (appItmzObj.getItemization().fsCore__Itemization_Family__c == fsCore.Constants.ITMZ_FAMILY_FINANCE_FEE){
                mApprovedFinanceFee += signedApprovedAmount;
                mActualFinanceFee += signedActualAmount;
            } 
            else if (appItmzObj.getItemization().fsCore__Itemization_Family__c == fsCore.Constants.ITMZ_FAMILY_PREPAID_FEE){
                mApprovedPrepaidFee += signedApprovedAmount;
                mActualPrepaidFee += signedActualAmount;
            }
        }    
    }
        
    /*
     * Action methods
     */
    public PageReference onDeleteItemization(){
        if (mSelectedRecordNumber != null){
            Integer indexToRemove;
            for(Integer i=0; i < mItemizationObjectList.size(); i++){
                if (mItemizationObjectList.get(i).getRecordNumber() == mSelectedRecordNumber){
                    indexToRemove = i;
                    break;
                }
            }
            
            if (indexToRemove != null){
                LendingApplicationItemizationObject removedItmz = mItemizationObjectList.remove(indexToRemove);
                System.debug(removedItmz.getItemization().id);
                if (removeditmz.getItemization().Id != null){
                    mRemovedItemizationList.add(removeditmz.getItemization());
                }
            }
        }
        setItemizedAmounts();
        return null;
    }
    
    public PageReference onAddItemization(){
        fsCore__Lending_Application_Itemization__c newItemization = new fsCore__Lending_Application_Itemization__c();
        newItemization.fsCore__Lending_Application_Number__c = mApplication.id;
        newItemization.fsCore__Itemization_Family__c = fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT;
        newItemization.fsCore__Source__c = fsCore.Constants.ITMZ_SOURCE_MANUAL;
        if (UserInfo.isMultiCurrencyOrganization()){
            newItemization.put(fsCore.Constants.FIELD_NAME_CURRENCY, mApplication.get(fsCore.Constants.FIELD_NAME_CURRENCY));
        }
        
        LendingApplicationItemizationObject itmzObj = new LendingApplicationItemizationObject(newItemization);
        itmzObj.setItemizationSelectList(mApplication.fsCore__Product_Name__c, mApplication.fsCore__Contract_Template_Name__c);
        itmzObj.setRecordNumber(fsCore.SpectraCoreUtil.getRandomInteger());
        mItemizationObjectList.add(itmzObj);
        
        setItemizedAmounts();
        mRecalcRequired = true;
        return null;
    }
    
    private Map<Integer, LendingApplicationItemizationObject> getItemizationObjectMap(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = new Map<Integer, LendingApplicationItemizationObject>();
        for(LendingApplicationItemizationObject itmzObj : mItemizationObjectList){
            itemizationObjMap.put(itmzObj.getRecordNumber(), itmzObj);
        }
        return itemizationObjMap;
    }
    
    public PageReference onSelectItemization(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        System.debug(loggingLevel.ERROR, '-- Selected Row : ' +  mSelectedRecordNumber);
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            itmzObj.setItemizationDetails();
            
            if (!itmzObj.getIsFinancedAmountType() && String.isNotBlank(itmzObj.getItemization().fsCore__Fee_Category__c)){
                itmzObj.setAvailableFees(fsCore.OriginationFeeUtil.getAvailableFees(itmzObj.getItemization().fsCore__Fee_Category__c, mApplication));
                setFeeTypeItemization(itmzObj);
            }
        }
        return null;
    }
    
    public PageReference onSelectFee(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        System.debug(loggingLevel.ERROR, '-- Selected Row : ' +  mSelectedRecordNumber);
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            setFeeTypeItemization(itmzObj);
        }
        return null;
    }
    
    private void setFeeTypeItemization(LendingApplicationItemizationObject pItmzObj){
        if (pItmzObj.getItemization().fsCore__Fee_Name__c != null){
            if (pItmzObj.getFeeSetup() == null || (pItmzObj.getFeeSetup() != null && pItmzObj.getItemization().fsCore__Fee_Name__c != pItmzObj.getFeeSetup().Id)){
                pItmzObj.setFeeSetup(fsCore.FeeCalculationUtil.getFeeSetup(pItmzObj.getItemization().fsCore__Fee_Name__c, mApplication.fsCore__Application_Date__c, mApplication.fsCore__Product_Family__c));
            }
        }
        
        if (pItmzObj.getIsCalculable()){
            List<String> errors = new List<String>();
            
            if (fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned(fsCore.Constants.APPROVED_AMOUNT_EDIT_PERMISSION)){
                System.debug(loggingLevel.ERROR, '-- Calculating Approved ... ');
                errors.addAll(pItmzObj.calculateApproved(mApprovedFinancedAmount,mApplication,mItemizationObjectList));
            }
            if (fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Allow_Access_To_Edit_Actual_Amounts')){
                System.debug(loggingLevel.ERROR, '-- Calculating Actual ... ');
                errors.addAll(pItmzObj.calculateActual(mActualFinancedAmount,mApplication,mItemizationObjectList));
            }
            
            if (errors.size() > 0){
                addError(errors.get(0));
            } else {
                setItemizedAmounts();
            }
        }            
    }
    
    public PageReference onCalculateFee(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        System.debug(loggingLevel.ERROR, '-- Selected Row : ' +  mSelectedRecordNumber);
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            setItemizedAmounts();
            List<String> errors = new List<String>();
            
            if (fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned(fsCore.Constants.APPROVED_AMOUNT_EDIT_PERMISSION)){
                System.debug(loggingLevel.ERROR, '-- Calculating Approved ... ');
                errors.addAll(itmzObj.calculateApproved(mApprovedFinancedAmount,mApplication,mItemizationObjectList));
            }
            if (fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Allow_Access_To_Edit_Actual_Amounts')){
                System.debug(loggingLevel.ERROR, '-- Calculating Actual ... ');
                errors.addAll(itmzObj.calculateActual(mActualFinancedAmount,mApplication,mItemizationObjectList));
            }
            
            if (errors.size() > 0){
                for (String errMsg : errors){ addError(errMsg); }
            } else {
                setItemizedAmounts();
            }
        }
        //PDI-656
        calculatePrepaidFinanceChargeForEachItm();
        return null;
    }

    //PDI-713 
    public PageReference onChangeOfCurrentCreditor(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);

            if (itmzObj.getItemization().Current_Creditor__c != null){
                //JUST IF THE ORIGINAL AND CURRENT CREDITOR MATCH
                Boolean matched = false;
                if (mDnlSettlementRatesMap.get(itmzObj.getItemization().Current_Creditor__c) != null){
                    List<DNL_Settlement_Rates__c> dnlSettlementRateList = mDnlSettlementRatesMap.get(itmzObj.getItemization().Current_Creditor__c);
                    for (DNL_Settlement_Rates__c dnlSettlementRate: dnlSettlementRateList){
                    if (dnlSettlementRate.Current_Creditor__c == itmzObj.getItemization().Current_Creditor__c
                        && dnlSettlementRate.Original_Creditor__c == itmzObj.getItemization().Original_Creditor__c
                        && dnlSettlementRate.type__c == itmzObj.getItemization().Litigation_Stage_Formula__c){
                        if (dnlSettlementRate.Average_of_Adjusted_Settlement__c != null){
                                itmzObj.setEstimatedSettlementPercent(dnlSettlementRate.Average_of_Adjusted_Settlement__c);
                                matched = true;
                                break;
                            }                            
                        }
                    }
                }
                if (!matched){
                    // IF NO MATCH THEN SET TO 50% AS MENTIONED IN THE TICKET PDI-713
                    if (SFS_System_Settings__c.getInstance().Is_DNL_Settle_Unmatched_Default_Allowed__c){
                        if (SFS_System_Settings__c.getInstance().DNL_Settlement_Unmatched_Rate__c != null){
                            itmzObj.setEstimatedSettlementPercent(SFS_System_Settings__c.getInstance().DNL_Settlement_Unmatched_Rate__c);
                        }else{
                            itmzObj.setEstimatedSettlementPercent(50);
                        }
                    }
                }
                
            }
        }
        mRecalcRequired = true;
        return null;
    }   


    //PDI-656
    private void calculatePrepaidFinanceChargeForEachItm(){
        System.debug(fsCore.Constants.END_DATE);
        Date maxItemizationDate = fsCore.Constants.END_DATE;
        Boolean isPrepaidChargeAllowed = false;
        System.debug(mItemizationObjectList);
        
        for (LendingApplicationItemizationObject appItmzObj : mItemizationObjectList){
            if ((appItmzObj.getItemization().Disbursement_Date__c != null) &&
                (fsCore.Constants.END_DATE == maxItemizationDate)||
                (appItmzObj.getItemization().Disbursement_Date__c > maxItemizationDate)){
                    
                maxItemizationDate = appItmzObj.getItemization().Disbursement_Date__c;
            }
            
            if (appItmzObj.getItemization().fsCore__Fee_Category__c == 'Prepaid Finance Charge'){
                if (appItmzObj.getItemization().fsCore__Fee_Name__c != null){
                    isPrepaidChargeAllowed = true;
                }
            }
        }
        
        if (maxItemizationDate != fsCore.Constants.END_DATE){ // THIS MEANS ITEMZIATIONS HAVE NULL DISBURSEMENT DATE SO NO PREPAID FINANCE CHARGE
            
            for (LendingApplicationItemizationObject appItmzObj : mItemizationObjectList){
                if ((appItmzObj.getItemization().Disbursement_Date__c != null)&&
                    (appItmzObj.getItemization().fsCore__Actual_Amount_Unsigned__c != null)&&
                    (isPrepaidChargeAllowed) &&
                    ((appItmzObj.getItemization().Rate__c != null) &&(appItmzObj.getItemization().Rate__c > 0))){
                        
                        //calculate prepaidFin charge
                        //disbursementDate to itm.getDisbursementDate(); on disbursementAmount
                        
                        System.RoundingMode roundingMode = fsCore.FinancialUtil.getRoundingMode();
                        fsCore.InterestCalculationObject interestParams = new fsCore.InterestCalculationObject();
                        
                        interestParams.setAmount(appItmzObj.getItemization().fsCore__Actual_Amount_Unsigned__c);
                        interestParams.setFromDate(appItmzObj.getItemization().Disbursement_Date__c);
                        interestParams.setToDate(maxItemizationDate);
                        interestParams.setRate(appItmzObj.getItemization().Rate__c);
                        interestParams.setFrequency(fsCore.Constants.CYCLE_MONTHLY);
                        
                        interestParams.setFirstPeriodDayCountMethod(null);
                        interestParams.setDayCalendarMethod360(fsCore.Constants.ACCRUAL_METHOD_360_EU);
                        interestParams.setDaysBasis(fsCore.Constants.ACCRUAL_DAYS_COUNT_METHOD_360);
                        interestParams.setDaysInYear(fsCore.Constants.ACCRUAL_DAYS_COUNT_METHOD_360);
                        interestParams.setRoundingMode(roundingMode);
                        interestParams.setFirstPeriodFlag(false);
                        interestParams.setCalculationPrecision(fsCore.FinancialUtil.getInterestRoundingScale());
                        
                        interestParams = fsCore.InterestCalculationUtil.calculateInterest(interestParams);   
                        appItmzObj.getItemization().DNL_Actual_Prepaid_Finance_Charge__c= interestParams.getInterestAmount();
                        
                        
                        
                    }else{
                        appItmzObj.getItemization().DNL_Actual_Prepaid_Finance_Charge__c= 0.00;
                    }                
            }         
        }
        
    }    
    
    public PageReference onCalculateAll(){
        if (isItemizationValid()){
            setItemizedAmounts();
            
            List<String> errorList = new List<String>();
            
            for (LendingApplicationItemizationObject appItmzObj : mItemizationObjectList){
                System.debug(loggingLevel.ERROR, 'appItmzObj. '+appItmzObj);
                System.debug(loggingLevel.ERROR, 'appItmzObj.getIsCalculable() '+appItmzObj.getIsCalculable());
                if (appItmzObj.getIsCalculable() && !appItmzObj.getItemization().fsCore__Is_Override_Allowed__c){
                    if (fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned(fsCore.Constants.APPROVED_AMOUNT_EDIT_PERMISSION)){
                        System.debug(loggingLevel.ERROR, '-- Calculating Approved ... ');
                        errorList.addAll(appItmzObj.calculateApproved(mApprovedFinancedAmount,mApplication,mItemizationObjectList));
                    }
                    if (fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Allow_Access_To_Edit_Actual_Amounts')){
                        System.debug(loggingLevel.ERROR, '-- Calculating Actual ... ');
                        errorList.addAll(appItmzObj.calculateActual(mActualFinancedAmount,mApplication,mItemizationObjectList));
                    }
                }
            }
            //PDI-656
            calculatePrepaidFinanceChargeForEachItm();

            if (errorList.size() > 0){
                for (String errMsg : errorList){ addError(errMsg); }
            } else {
                setItemizedAmounts();
            }
            mRecalcRequired = false;
        }
        return null;
    }
    
    private Boolean isItemizationValid(){
        Boolean isValid = true;
        if (mItemizationObjectList.size() > 0){
            Integer rowNumber = 0;
            for(LendingApplicationItemizationObject itmzObj : mItemizationObjectList){
                rowNumber++;
                fsCore__Lending_Application_Itemization__c itmz = itmzObj.getItemization();
                if (itmz.fsCore__Itemization_Name__c == null || String.IsBlank(itmz.fsCore__Itemization_Family__c) || String.IsBlank(itmz.fsCore__Plus_Or_Minus__c)){
                    addError(String.format(Label.fsCore.Row_Number, new List<String>{String.valueOf(rowNumber)}) + ' - ' + Label.fsCore.Required_Itemization_Field_Missing);
                    isValid = false;
                }
                if (itmz.fsCore__Approved_Amount_Unsigned__c != null && itmz.fsCore__Approved_Amount_Unsigned__c < 0){
                    addError(String.format(Label.fsCore.Row_Number, new List<String>{String.valueOf(rowNumber)}) + ' - ' + Label.fsCore.Itemization_Approved_Amount_Less_Than_Zero);
                    isValid = false;
                }
                
                //set default values
                itmz.fsCore__Actual_Amount_Unsigned__c = (itmz.fsCore__Actual_Amount_Unsigned__c == null) ? 0 : itmz.fsCore__Actual_Amount_Unsigned__c;
                if (itmz.fsCore__Actual_Amount_Unsigned__c < 0){
                    addError(String.format(Label.fsCore.Row_Number, new List<String>{String.valueOf(rowNumber)}) + ' - ' + Label.fsCore.Itemization_Actual_Amount_Less_Than_Zero);
                    isValid = false;
                }
            }
        }
        System.debug(loggingLevel.ERROR, 'isValid. '+isValid);
        return isValid;
    }
    
    public PageReference onChangeSettlementApprovedPercent(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            itmzObj.setItemizationAttributesApprovedPercent();
            setItemizedAmounts();
            isItemizationValid();
            mRecalcRequired = true;
        }
        return null;
    }   
    public PageReference onChangeSettlementActualPercent(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            itmzObj.setItemizationAttributesActualPercent();
            setItemizedAmounts();
            isItemizationValid();
            mRecalcRequired = true;
        }
        return null;
    }   
    
    
    public PageReference onChangeSettlementApprovedAmount(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            itmzObj.setItemizationAttributesApprovedAmount();
            setItemizedAmounts();
            isItemizationValid();
            mRecalcRequired = true;
        }
        return null;
    }    
    public PageReference onChangeSettlementActualAmount(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            itmzObj.setItemizationAttributesActualAmount();
            setItemizedAmounts();
            isItemizationValid();
            mRecalcRequired = true;
        }
        return null;
    }

    public PageReference onChangeCurrentBalanceAmount(){
        Map<Integer, LendingApplicationItemizationObject> itemizationObjMap = getItemizationObjectMap();
        if (mSelectedRecordNumber != null && itemizationObjMap.containsKey(mSelectedRecordNumber)){
            LendingApplicationItemizationObject itmzObj = itemizationObjMap.get(mSelectedRecordNumber);
            itmzObj.setEstimatedSettlementAmount();
            setItemizedAmounts();
            isItemizationValid();
            mRecalcRequired = true;
        }
        return null;
    }    
    private void syncItemizedAmounts(){
        if (mItemizationObjectList != null && mItemizationObjectList.size() > 0){
            List<fsCore__Lending_Application_Itemization__c> appItmzList = new List<fsCore__Lending_Application_Itemization__c>();
            for (LendingApplicationItemizationObject appItmzObj : mItemizationObjectList){
                appItmzList.add(appItmzObj.getItemization());
            }
            
            fsCore.LendingApplicationItemizationUtil.syncItemizationAmountToApplication(mApplication, appItmzList);
        }
    }
    
    public PageReference onSaveItemizationsButton(){

        if (onSaveItemizations()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Itemizations have been saved successfully.'));
            init();
        }
        
        return null;

    }

    public PageReference onApplyItemizationsButton(){
        if (onSaveItemizations()){
            return new PageReference('/' + mApplication.Id);
        }

        return null;
    }    

    /*
     * Save action related methods
     */    
    private boolean onSaveItemizations(){
        if (!isItemizationValid()){
            return false;
        }
        
        if (mRecalcRequired){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'Financed Amount itemization(s) have been modified. Please click Calculate button to recalculate the fees/charges and sync the itemized amounts before saving the changes.'));
            return false;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            //sync net itemization amount to application and save application
            syncItemizedAmounts();
            fsCore.DMLResult appSaveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().updateData(new List<fsCore__Lending_Application__c>{mApplication});
            if (appSaveRslt.hasErrors())  { appSaveRslt.throwError();  }
            
            //save itemizations
            List<fsCore__Lending_Application_Itemization__c> appItemizationForInsert = new List<fsCore__Lending_Application_Itemization__c>();
            List<fsCore__Lending_Application_Itemization__c> appItemizationForUpdate = new List<fsCore__Lending_Application_Itemization__c>();
            
            for (LendingApplicationItemizationObject appItmzObj : mItemizationObjectList){
                fsCore__Lending_Application_Itemization__c appItmz = appItmzObj.getItemization();
                System.debug(loggingLevel.ERROR, '-- ITMZ : ' + appItmz);
                if (appitmz.fsCore__Lending_Application_Number__c == null) { appitmz.fsCore__Lending_Application_Number__c = mApplication.id; }
                if (appitmz.Id == null) { appItemizationForInsert.add(appItmz); }
                else { appItemizationForUpdate.add(appItmz); }
            }    
            
            fsCore.DMLResult appItmzDeleteRslt = fsCore.LendingApplicationItemizationDMLWrapper.getInstance().deleteData(mRemovedItemizationList);
            if (appItmzDeleteRslt.hasErrors()) { appItmzDeleteRslt.throwError();}
            
            fsCore.DMLResult appItmzUpdateRslt = fsCore.LendingApplicationItemizationDMLWrapper.getInstance().updateData(appItemizationForUpdate);
            if (appItmzUpdateRslt.hasErrors()) { appItmzUpdateRslt.throwError();}
            
            fsCore.DMLResult appItmzInsertRslt = fsCore.LendingApplicationItemizationDMLWrapper.getInstance().insertData(appItemizationForInsert, true);
            if (appItmzInsertRslt.hasErrors()) { appItmzInsertRslt.throwError(); }
        } 
        catch (Exception e){
            Database.rollback(sp);
            System.debug(loggingLevel.ERROR, 'Exception when creating lending application : ' + e.getMessage() + ' ' + e.getStackTraceString());
            addError(e.getMessage());
            return false;
        }

        return true;
        
    }
    
}