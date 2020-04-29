/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - ItemizationObjectBase
 * 
 * Description   - Class type for transaction Itemization record. This class is extended by 
 *                 Decision Itemization and Application Itemization object class.
 * 
 * 
 */
public virtual with sharing class ItemizationObjectBase {

    private Integer mRecordNumber;
    private String  mItemizationName;
    private fsCore__Fee_Setup__c mOrigFee;
    private Boolean mIsFinnAmtType;
    private Boolean mIsCreditorNameDisplayedType;
    private List<SelectOption> mItemizationSelectList;
    private List<SelectOption> mOrigFeeSelectList;
    private Map<Id, ItemizationSetup> mItemizationSetupMap;
    private Decimal mRateForPFC; //rate for calculating Prepaid Finance Charge
    
    public ItemizationObjectBase(){
        mRecordNumber = null;
        mItemizationName = fsCore.Constants.BLANK_STRING;
        mOrigFee = null;
        mIsFinnAmtType = false;
        mRateForPFC = null;
        mIsCreditorNameDisplayedType = true;
        mItemizationSelectList = new List<SelectOption>();
        mOrigFeeSelectList = new List<SelectOption>();
        mItemizationSetupMap = new Map<Id, ItemizationSetup>();
    }
    
    /* setters */
    public void setRecordNumber(Integer pRecordNumber){
        mRecordNumber = pRecordNumber;
    }

    public void setItemizationName(String pItmzName){
        mItemizationName = pItmzName;
    }

    public void setFeeSetup(fsCore__Fee_Setup__c pOrigFee){
        mOrigFee = pOrigFee;
    }

    public void setFeeSelectList(List<fsCore__Fee_Setup__c> pFeeList){
        mOrigFeeSelectList = new List<SelectOption>();
        mOrigFeeSelectList.add(new SelectOption(fsCore.Constants.BLANK_STRING, Label.fsCore.List_Option_None));
        for (fsCore__Fee_Setup__c origFee : pFeeList){
            mOrigFeeSelectList.add(new SelectOption(String.valueOf(origFee.Id), origFee.Name));
        }
    }

    public void setIsFinancedAmountType(Boolean pIsFinnAmtType){
        mIsFinnAmtType = pIsFinnAmtType;
    }

    public void setIsCreditorNameDisplayedType(Boolean pIsCreditorNameDisplayedType){
        mIsCreditorNameDisplayedType = pIsCreditorNameDisplayedType;
    }    

    public void setItemizationSelectList(Id pProductId){
        setItemizationSetupListFromProduct(pProductId);
        setItemizationSelectList();
    }

    public void setItemizationSelectList(Id pProductId, Id pContractTemplateId){
        setItemizationSetupListFromProduct(pProductId);
        setItemizationSetupListFromContractTemplate(pContractTemplateId);
        setItemizationSelectList();
    }

    private void setItemizationSetupListFromProduct(Id pProductId){
        List<fsCore__Product_Itemization_Setup__c> prodItemizations = [SELECT fsCore__Itemization_Name__c
                                                                    , fsCore__Itemization_Name__r.Name
                                                                    , fsCore__Itemization_Family__c
                                                                    , fsCore__Disbursement_Allowed__c
                                                                    , fsCore__Fee_Category__c
                                                                    , fsCore__Is_Override_Allowed__c
                                                                    , fsCore__Plus_Or_Minus__c
                                                                 FROM fsCore__Product_Itemization_Setup__c
                                                                WHERE fsCore__Product_Name__c = :pProductId
                                                                  AND fsCore__Is_Active__c = true];
        
        for(fsCore__Product_Itemization_Setup__c prodItmz : prodItemizations){
            ItemizationSetup itmzSetup = new ItemizationSetup();
            itmzSetup.mItemizationSetupId = prodItmz.fsCore__Itemization_Name__c;
            itmzSetup.mItemizationName = prodItmz.fsCore__Itemization_Name__r.Name;
            itmzSetup.mItemizationFamily = prodItmz.fsCore__Itemization_Family__c;
            itmzSetup.mDisbursementAllowed = prodItmz.fsCore__Disbursement_Allowed__c;
            itmzSetup.mFeeCategory = prodItmz.fsCore__Fee_Category__c;
            itmzSetup.mIsOverrideAllowed = prodItmz.fsCore__Is_Override_Allowed__c;
            itmzSetup.mPlusOrMinus = prodItmz.fsCore__Plus_Or_Minus__c;
            mItemizationSetupMap.put(itmzSetup.mItemizationSetupId, itmzSetup);
        }
    }

    private void setItemizationSetupListFromContractTemplate(Id pContractTemplateId){
        List<fsCore__Contract_Template_Itemization_Setup__c> ctItemizations = [SELECT fsCore__Itemization_Name__c
                                                                            , fsCore__Itemization_Name__r.Name
                                                                            , fsCore__Itemization_Family__c
                                                                            , fsCore__Disbursement_Allowed__c
                                                                            , fsCore__Fee_Category__c
                                                                            , fsCore__Is_Override_Allowed__c
                                                                            , fsCore__Plus_Or_Minus__c
                                                                         FROM fsCore__Contract_Template_Itemization_Setup__c
                                                                        WHERE fsCore__Contract_Template_Name__c = :pContractTemplateId
                                                                          AND fsCore__Is_Active__c = true];
        
        for(fsCore__Contract_Template_Itemization_Setup__c ctItmz : ctItemizations){
            ItemizationSetup itmzSetup = new ItemizationSetup();
            itmzSetup.mItemizationSetupId = ctItmz.fsCore__Itemization_Name__c;
            itmzSetup.mItemizationName = ctItmz.fsCore__Itemization_Name__r.Name;
            itmzSetup.mItemizationFamily = ctItmz.fsCore__Itemization_Family__c;
            itmzSetup.mDisbursementAllowed = ctItmz.fsCore__Disbursement_Allowed__c;
            itmzSetup.mFeeCategory = ctItmz.fsCore__Fee_Category__c;
            itmzSetup.mIsOverrideAllowed = ctItmz.fsCore__Is_Override_Allowed__c;
            itmzSetup.mPlusOrMinus = ctItmz.fsCore__Plus_Or_Minus__c;
            mItemizationSetupMap.put(itmzSetup.mItemizationSetupId, itmzSetup);
        }
    }

    private void setItemizationSelectList(){
        mItemizationSelectList = new List<SelectOption>();
        
        if (mItemizationSetupMap != null && mItemizationSetupMap.size() > 0){
            mItemizationSelectList.add(new SelectOption(fsCore.Constants.BLANK_STRING, Label.fsCore.List_Option_Select_Value));
            for(ItemizationSetup itmzSetup : mItemizationSetupMap.values()){
                mItemizationSelectList.add(new SelectOption(itmzSetup.mItemizationSetupId, itmzSetup.mItemizationName));
            }
        }
    }
    
    /* getters */
    public Integer getRecordNumber(){
        return mRecordNumber;
    }

    public String getItemizationName(){
        return mItemizationName;
    }

    public fsCore__Fee_Setup__c getFeeSetup(){
        return mOrigFee;
    }

    public List<SelectOption> getFeeSelectList(){
        return mOrigFeeSelectList;
    }

    public Boolean getIsFinancedAmountType(){
        return mIsFinnAmtType;
    } 

    public Boolean getIsCreditorNameDisplayedType(){
        return mIsCreditorNameDisplayedType;
    }        

    public List<SelectOption> getItemizationSelectList(){
        if (mItemizationSelectList.isEmpty()){
            mItemizationSelectList = fsCore.SpectraCoreUtil.getBlankList();
        }
        return mItemizationSelectList;
    }    

    public ItemizationSetup getItemizationSetup(Id pItemizationSetupId){
        if (pItemizationSetupId != null && mItemizationSetupMap.containsKey(pItemizationSetupId)){
            return mItemizationSetupMap.get(pItemizationSetupId);
        }
        return null;
    }    

    private void setRateForPrepaidFinanceCharge(fsCore__Lending_Application__c pLendingApplication){
        if (mRateForPFC == null){
            mRateForPFC = pLendingApplication.fsCore__Rate__c;
            if (mRateForPFC == null){
                System.debug(loggingLevel.ERROR, 'Rate is null... get available pricings to set the rate value');
                List<fsCore__Pricing_Setup__c> availablePricings = fsCore.PricingUtil.getAvailablePricings(pLendingApplication, false);
                if (availablePricings.size() > 0){ mRateForPFC = availablePricings.get(0).fsCore__Rate_Value__c; }
            }
        }
        System.debug(loggingLevel.ERROR, '-- Rate : ' + mRateForPFC);
    }
    
    private Decimal getRateForPrepaidFinanceCharge(){
        return mRateForPFC;
    }
    
    /*
     * Method to calculate the calculable fee itemization
     */
    public virtual fsCore.FeeCalculationObject calculateFee(Decimal pFinancedAmount
                                                           ,fsCore__Lending_Application__c pLendingApplication
                                                           ,String pFeeType //ACTUAL/APPROVED
                                                           , List<LendingApplicationItemizationObject> pItemizationObjectList){
        system.debug(logginglevel.error,'mOrigFee :'+mOrigFee);
        if (mOrigFee != null){
            //calculate fee
            if (mOrigFee.fsCore__Fee_Category__c == 'Origination Fee'){
                fsCore.FeeCalculationObject feeCalcObj = fsCore.FeeCalculationUtil.calculateFeeForFinancedAmount(mOrigFee, pFinancedAmount);
                system.debug(logginglevel.error,'Orig feeCalcObj :'+feeCalcObj);
                return feeCalcObj;
            }
            else if (mOrigFee.fsCore__Fee_Category__c == 'Prepaid Finance Charge'){
                setRateForPrepaidFinanceCharge(pLendingApplication);
                //Use Custom Logic by SFS
                //Estimated Pre-paid finance charge. = {(Estimated First Repayment Date) – (Estimated Final Disbursement Date)} * (Interest rate/360) * Estimated Financed Amount
                system.debug(logginglevel.error,'Financed Amount : '+ pFinancedAmount
                                                +' Contract Date : '+ pLendingApplication.fsCore__Requested_Contract_Start_Date__c 
                                                +' Payment Start Date : '+ pLendingApplication.fsCore__Requested_Payment_Start_Date__c 
                                                +' Rate : '+ mRateForPFC);

                //THERE IS NO POINT OF COMPARING THE DATES HERE. THIS IS ANYWAYS INDICATIONAL AND SEEMS THEY ONLY WANT 30 DAYS TO BE CONSIDERED.

                if (pFeeType == 'APPROVED'){
                    if (pFinancedAmount != null && mRateForPFC != null){
                        fsCore.FeeCalculationObject feeCalcObj = new fsCore.FeeCalculationObject();
                        
                        Integer numOfDays = 30; //pLendingApplication.fsCore__Requested_Payment_Start_Date__c.daysBetween(pLendingApplication.fsCore__Requested_Contract_Start_Date__c);

                        feeCalcObj.mCalculatedFeeAmount = fsCore.FinancialUtil.round(numOfDays * (mRateForPFC/36000) * pFinancedAmount);
                        feeCalcObj.mIsSuccess = true;
                        system.debug(logginglevel.error,'Financed Fee feeCalcObj :'+feeCalcObj);
                        return feeCalcObj;
                    }
                }
                else{
                    List<LendingApplicationItemizationObject> sortedItemization = new List<LendingApplicationItemizationObject>();
                    //calculate fee
                    for (LendingApplicationItemizationObject itm : pItemizationObjectList){
                        if ((itm.getItemization().Current_Creditor__c != null) || (itm.getItemization().Original_Creditor__c != null)){

                            if ((itm.getItemization().Disbursement_Date__c != null)
                                &&(itm.getItemization().fsCore__Actual_Amount_Unsigned__c != null)){
                                LendingApplicationItemizationObject  itemization = new LendingApplicationItemizationObject(itm.getItemization());   
                                sortedItemization.add(itemization); 
                            }

                            System.debug(loggingLevel.ERROR, '-- itm : ' +  itm.getItemization().Disbursement_Date__c);
                        }
                    }
                    
                    if (sortedItemization.size() <2){ //MEANS 0 or 1 then NO SORTING
                        fsCore.FeeCalculationObject feeCalcObj = new fsCore.FeeCalculationObject();
                        feeCalcObj.mCalculatedFeeAmount = 0;
                        feeCalcObj.mIsSuccess = true;
                        return feeCalcObj;
                    }
                    else{
                        sortedItemization.sort();
                        decimal disbursementAmount = 0.00;
                        decimal prepaidFinCharge = 0.00;
                        Date disbursementDate;
                        Boolean firstLoop = false;
                        if (mRateForPFC != null && mRateForPFC > 0){
                            for (LendingApplicationItemizationObject itm: sortedItemization){
                                if (!firstLoop){
                                    firstLoop = true;
                                    disbursementAmount = itm.getDisbursementAmount();
                                    disbursementDate = itm.getDisbursementDate();
                                }else{
                                    //calculate prepaidFin charge
                                    //disbursementDate to itm.getDisbursementDate(); on disbursementAmount

                                    System.RoundingMode roundingMode = fsCore.FinancialUtil.getRoundingMode();
                                    fsCore.InterestCalculationObject interestParams = new fsCore.InterestCalculationObject();
                                    
                                    interestParams.setAmount(disbursementAmount);
                                    interestParams.setFromDate(disbursementDate);
                                    interestParams.setToDate(itm.getDisbursementDate());
                                    interestParams.setRate(mRateForPFC);
                                    interestParams.setFrequency(fsCore.Constants.CYCLE_MONTHLY);
                                    
                                    interestParams.setFirstPeriodDayCountMethod(null);
                                    interestParams.setDayCalendarMethod360(fsCore.Constants.ACCRUAL_METHOD_360_EU);
                                    interestParams.setDaysBasis(fsCore.Constants.ACCRUAL_DAYS_COUNT_METHOD_360);
                                    interestParams.setDaysInYear(fsCore.Constants.ACCRUAL_DAYS_COUNT_METHOD_360);
                                    interestParams.setRoundingMode(roundingMode);
                                    interestParams.setFirstPeriodFlag(false);
                                    interestParams.setCalculationPrecision(fsCore.FinancialUtil.getInterestRoundingScale());

                                    interestParams = fsCore.InterestCalculationUtil.calculateInterest(interestParams);   
                                    prepaidFinCharge += interestParams.getInterestAmount();


                                    disbursementDate = itm.getDisbursementDate();
                                    disbursementAmount += itm.getDisbursementAmount();

                                }

                            }
                        }
                        fsCore.FeeCalculationObject feeCalcObj = new fsCore.FeeCalculationObject();
                        feeCalcObj.mCalculatedFeeAmount = prepaidFinCharge;
                        feeCalcObj.mIsSuccess = true;
                        return feeCalcObj;                    

                    }           
                }     
            }
        }
        return null;
    }
    
    public class ItemizationSetup{
        public Id      mItemizationSetupId;
        public String  mItemizationName;
        public String  mItemizationFamily;
        public String  mPlusOrMinus;
        public String  mDisbursementAllowed;
        public String  mFeeCategory;
        public Boolean mIsOverrideAllowed;
    }
}