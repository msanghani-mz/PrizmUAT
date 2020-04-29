/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - LendingApplicationItemizationObject
 * 
 * Description   - Class type for Application Itemization
 * 
 * Developer(s)  - SSingh
 * 
 */
public with sharing class LendingApplicationItemizationObject extends ItemizationObjectBase implements Comparable{

    private fsCore__Lending_Application_Itemization__c mItemization;
    private Date mDisbursementDate; //THIS IS JUST FOR SORTING
    private Decimal mDisbursementAmount; //THIS IS JUST FOR SORTING
    private Map<Id, fsCore__Fee_Setup__c> mAvailableFeeMap;
    public List<String> mCurrentCreditorLov {get; set;} //PDI-713
    
    public LendingApplicationItemizationObject(fsCore__Lending_Application_Itemization__c pItemization){
        super();
        mItemization = pItemization;
        setItemizationAttributes();
    }

    public void setDisbursementDate(Date pDisbursementDate){
        mDisbursementDate = pDisbursementDate;
    } 
    public void setDisbursementAmount(Decimal pDisbursementAmount){
        mDisbursementAmount = pDisbursementAmount;
    }        
    
    public Date getDisbursementDate(){
        return mDisbursementDate;
    }

    public Decimal getDisbursementAmount(){
        return mDisbursementAmount;
    }    

    private void setItemizationAttributes(){
        if (String.IsNotBlank(mItemization.fsCore__Itemization_Family__c)){
            setIsFinancedAmountType(mItemization.fsCore__Itemization_Family__c.equalsIgnoreCase(fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT));
        } else {
            setIsFinancedAmountType(false);
        }
        setDisbursementAmount(mItemization.fsCore__Actual_Amount_Unsigned__c);
        setDisbursementDate(mItemization.Disbursement_Date__c);

        if (String.IsBlank(mItemization.fsCore__Plus_Or_Minus__c)){
            mItemization.fsCore__Plus_Or_Minus__c = fsCore.Constants.PLUS;
        }
    }
    
    /* setters */
    public void setItemizationDetails(){
        ItemizationSetup itmzSetup = getItemizationSetup(mItemization.fsCore__Itemization_Name__c);
        System.debug(loggingLevel.ERROR, '-- Selected Itemization : ' +  itmzSetup);
        mItemization.fsCore__Itemization_Family__c = (itmzSetup == null) ? null : itmzSetup.mItemizationFamily;
        mItemization.fsCore__Plus_Or_Minus__c = (itmzSetup == null) ? null : itmzSetup.mPlusOrMinus; 
        mItemization.fsCore__Disbursement_Allowed__c = (itmzSetup == null) ? null : itmzSetup.mDisbursementAllowed;
        mItemization.fsCore__Fee_Category__c = (itmzSetup == null) ? null : itmzSetup.mFeeCategory;
        mItemization.fsCore__Is_Override_Allowed__c = (itmzSetup == null) ? false : itmzSetup.mIsOverrideAllowed;
        setItemizationAttributes();
    }
    
    public void setAvailableFees(List<fsCore__Fee_Setup__c> pFeeList){
        mAvailableFeeMap = new Map<Id, fsCore__Fee_Setup__c>();
        for(fsCore__Fee_Setup__c origFee : pFeeList){
            if (origFee.fsCore__Record_Type_Name__c == mItemization.fsCore__Itemization_Family__c){
                mAvailableFeeMap.put(origFee.Id, origFee);
            }
        }
        
        setFeeSelectList(mAvailableFeeMap.values());
        if (mItemization.fsCore__Fee_Name__c == null && mAvailableFeeMap.size() > 0){
            mItemization.fsCore__Fee_Name__c = mAvailableFeeMap.values().get(0).Id;
        }
        if (mItemization.fsCore__Fee_Name__c != null && !mAvailableFeeMap.containsKey(mItemization.fsCore__Fee_Name__c)){
            mItemization.fsCore__Fee_Name__c = null;
            setFeeSetup(null);
        }
    }

    public void setItemizationAttributesApprovedAmount(){
        setItemizationAttributes();
        setApprovedAmount(true);
    }
    public void setItemizationAttributesApprovedPercent(){
        setItemizationAttributes();
        setApprovedAmount(false);
    }    
    //PDI-710
    public void setItemizationAttributesEstSetAmount(){
        setItemizationAttributes();
        setEstimatedSettlementAmount();
    }  
    public void setItemizationAttributesActualAmount(){
        setItemizationAttributes();
        setActualAmount(true);
    }
    public void setItemizationAttributesActualPercent(){
        setItemizationAttributes();
        setActualAmount(false);
    }    

    /*
    Basically I am setting ESTIMATED SETTLEMENT BALANCE
    */
    public void setActualAmount(Boolean pAmountFlag){
        if (pAmountFlag){
            if (mItemization.Current_Creditor__c != null){
                if ((mItemization.fsCore__Actual_Amount_Unsigned__c == null)
                    ||(mItemization.fsCore__Actual_Amount_Unsigned__c == 0.00)){
                    mItemization.Actual_Settlement_Percentage__c = 0.00;    
                }else{
                    mItemization.Actual_Settlement_Percentage__c = (mItemization.fsCore__Actual_Amount_Unsigned__c/mItemization.fsCore__Requested_Amount_Unsigned__c)*100;
                }
            }
        }else{
            if (mItemization.Current_Creditor__c != null){
                if (mItemization.Actual_Settlement_Percentage__c == null){
                    mItemization.fsCore__Actual_Amount_Unsigned__c = 0.00;    
                }else{
                    mItemization.fsCore__Actual_Amount_Unsigned__c = mItemization.fsCore__Requested_Amount_Unsigned__c * (mItemization.Actual_Settlement_Percentage__c/100);
                }
            }
        }
    } 
    /*
PDI-713
*/
    public void setEstimatedSettlementPercent(Decimal pSettlementPercent){
        
        
        if (pSettlementPercent != null){
            mItemization.Estimated_Settlement_Percent__c = pSettlementPercent;
            setEstimatedSettlementAmount();
        }
        
    }     

    /*
    PDI-710
    */
    public void setEstimatedSettlementAmount(){
       
        if (mItemization.fsCore__Requested_Amount_Unsigned__c != null && mItemization.Estimated_Settlement_Percent__c != NULL){
              if (mItemization.Estimated_Settlement_Percent__c == 0){
                mItemization.fsCore__Approved_Amount_Unsigned__c = 0.00;
              }else{
                mItemization.fsCore__Approved_Amount_Unsigned__c = mItemization.fsCore__Requested_Amount_Unsigned__c * (mItemization.Estimated_Settlement_Percent__c/100);
              }
        }
    
    } 
    /*
    Basically I am setting ESTIMATED SETTLEMENT BALANCE
    */
    public void setApprovedAmount(Boolean pAmountFlag){
        if (pAmountFlag){
            if (mItemization.Current_Creditor__c != null){
                if ((mItemization.fsCore__Approved_Amount_Unsigned__c == null)
                    ||(mItemization.fsCore__Approved_Amount_Unsigned__c == 0.00)){
                    mItemization.Estimated_Settlement_Percent__c = 0.00;    
                }else{
                    mItemization.Estimated_Settlement_Percent__c = (mItemization.fsCore__Approved_Amount_Unsigned__c/mItemization.fsCore__Requested_Amount_Unsigned__c)*100;
                }
            }
        }else{
            if (mItemization.Current_Creditor__c != null){
                if (mItemization.Estimated_Settlement_Percent__c == null){
                    mItemization.fsCore__Approved_Amount_Unsigned__c = 0.00;    
                }else{
                    mItemization.fsCore__Approved_Amount_Unsigned__c = mItemization.fsCore__Requested_Amount_Unsigned__c * (mItemization.Estimated_Settlement_Percent__c/100);
                }
            }
        }
    }     
    /* getters */
    public fsCore__Lending_Application_Itemization__c getItemization(){
        return mItemization;
    }

    public Boolean getIsCalculable(){
        //return (String.IsNotBlank(mItemization.fsCore__Itemization_Family__c) && mItemization.fsCore__Fee_Name__c != null
        return (String.IsNotBlank(mItemization.fsCore__Itemization_Family__c) 
                && (mItemization.fsCore__Itemization_Family__c == fsCore.Constants.ITMZ_FAMILY_FINANCE_FEE || mItemization.fsCore__Itemization_Family__c == fsCore.Constants.ITMZ_FAMILY_PREPAID_FEE));
    }
    
    public Boolean getIsManual(){
        return (String.IsNotBlank(mItemization.fsCore__Source__c) && mItemization.fsCore__Source__c.equalsIgnoreCase(fsCore.Constants.ITMZ_SOURCE_MANUAL));
    }

    public Boolean getIsNew(){
        return (mItemization.Id == null && getIsManual());
    }

    public List<String> calculateApproved(Decimal pApprovedFinancedAmount, fsCore__Lending_Application__c pLendingApplication, List<LendingApplicationItemizationObject> pItemizationObjectList){
        List<String> errorList = new List<String>();
        mItemization.fsCore__Approved_Amount_Unsigned__c = 0.00; //DEFAULT IT 0 AND MAY GET OVERWRITTEN LATER
        mItemization.fsCore__Original_Amount_Unsigned__c = 0.00; //DEFAULT IT 0 AND MAY GET OVERWRITTEN LATER
        //calculate fee
        if (mItemization.fsCore__Fee_Name__c != null){
            fsCore.FeeCalculationObject feeCalcObj = super.calculateFee(pApprovedFinancedAmount,pLendingApplication,'APPROVED',pItemizationObjectList);
            if (feeCalcObj != null){
                System.debug(loggingLevel.ERROR, '-- feeCalcObj.mIsSuccess : ' +  feeCalcObj.mIsSuccess);
                if (feeCalcObj.mIsSuccess){
                    System.debug(loggingLevel.ERROR, '-- Approved Calculated Amount : ' +  feeCalcObj.mCalculatedFeeAmount);
                    mItemization.fsCore__Approved_Amount_Unsigned__c = feeCalcObj.mCalculatedFeeAmount;
                    mItemization.fsCore__Original_Amount_Unsigned__c = feeCalcObj.mCalculatedFeeAmount;
                    mItemization.fsCore__Is_Calculated__c = true;
                } else {
                    errorList.addAll(feeCalcObj.mErrorStack);
                }
            }
        }
        
        return errorList;
    }    

    public Integer compareTo(Object compareTo) {
        LendingApplicationItemizationObject compareToObj = (LendingApplicationItemizationObject) compareTo;
        if (mDisbursementDate == compareToObj.getDisbursementDate()) return 0;
        if (mDisbursementDate > compareToObj.getDisbursementDate()) return 1;
        return -1;        
    }

    public List<String> calculateActual(Decimal pActualFinancedAmount, fsCore__Lending_Application__c pLendingApplication, List<LendingApplicationItemizationObject> pItemizationObjectList){
        List<String> errorList = new List<String>();

       mItemization.fsCore__Actual_Amount_Unsigned__c = 0.00; //DEFAULT IT 0 AND MAY GET OVERWRITTEN LATER
       if (mItemization.fsCore__Fee_Name__c != null){
            fsCore.FeeCalculationObject feeCalcObj = super.calculateFee(pActualFinancedAmount,pLendingApplication,'ACTUAL',pItemizationObjectList);
            if (feeCalcObj != null){
                System.debug(loggingLevel.ERROR, '-- feeCalcObj.mIsSuccess : ' +  feeCalcObj.mIsSuccess);
                if (feeCalcObj.mIsSuccess){
                    System.debug(loggingLevel.ERROR, '-- Actual Calculated Amount : ' +  feeCalcObj.mCalculatedFeeAmount);
                    mItemization.fsCore__Actual_Amount_Unsigned__c = feeCalcObj.mCalculatedFeeAmount;
                    mItemization.fsCore__Is_Calculated__c = true;
                } else {
                    errorList.addAll(feeCalcObj.mErrorStack);
                }
            }  
        }      
        System.debug(loggingLevel.ERROR, '-- Errors (if any) : ' +  errorList);
        return errorList;
    }

}