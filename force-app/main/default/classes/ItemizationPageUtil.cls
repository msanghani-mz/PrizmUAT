/*
 * Class Name   - ItemizationPageUtil
 * Description  - Utility methods related to Itemization processing
 * Developer(s) - Financial Spectra
 */
public with sharing class ItemizationPageUtil {

    public static fsCore__Lending_Application__c getApplication(Id pApplicationId){
        fsCore.DynamicQueryBuilder appQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
                                              .addFields()
                                              .addField('Loan_Officer__r.Name')
                                              .addField('fsCore__Primary_Customer_Account__r.Name')
                                              .addWhereConditionWithBind(1,'Id','=','pApplicationId');
        fsCore__Lending_Application__c application = ((List<fsCore__Lending_Application__c>)Database.query(appQuery.getQueryString())).get(0);
        return application;
    }
    
    public static List<fsCore__Lending_Application_Itemization__c> getApplicationItemizations(Id pApplicationId){
        List<fsCore__Lending_Application_Itemization__c> appItemizations
            = [SELECT Id, Name 
               , fsCore__Lending_Application_Number__c
               , fsCore__Plus_Or_Minus__c
               , fsCore__Itemization_Name__c	
               , fsCore__Itemization_Code__c	
               , fsCore__Itemization_Name__r.Name
               , fsCore__Itemization_Name__r.fsCore__Itemization_Code__c
               , fsCore__Itemization_Family__c
               , fsCore__Source__c
               , Original_Creditor__c
               , DNL_Original_Enrolled_Balance__c
               , Current_Creditor__c
               , fsCore__Requested_Amount_Unsigned__c
               , Estimated_Settlement_Percent__c
               , fsCore__Approved_Amount_Unsigned__c
               , Tradeline_Current_Stage_Formula__c
               , Litigation_Stage_Formula__c
               , Actual_Settlement_Percentage__c
               , fsCore__Actual_Amount_Unsigned__c
               , Disbursement_Date__c
               , fsCore__Fee_Name__c
               , fsCore__Fee_Category__c
               , fsCore__Is_Override_Allowed__c
               , fsCore__Original_Amount_Unsigned__c
               , fsCore__Is_Calculated__c
               , fsCore__Disbursement_Allowed__c
               , Notes__c
               , Translated_Litigation_Status__c
               FROM fsCore__Lending_Application_Itemization__c 
               WHERE fsCore__Lending_Application_Number__c = :pApplicationId
               ORDER BY fsCore__Itemization_Family__c, Original_Creditor__c NULLS LAST, Current_Creditor__c NULLS LAST, Name];
        
        return appItemizations;
    }
    
    public static void setCreditorLists(ItemizationWrapper pItmzWrp){
        List<AggregateResult> creditorNamesResult;
        if (SFS_System_Settings__c.getInstance().Is_DNL_Settlement_Active_Rates_Only__c){
            creditorNamesResult = [SELECT Original_Creditor__c, Current_Creditor__c, count(Id) number_of_records
                                     FROM DNL_Settlement_Rates__c 
                                    WHERE Original_Creditor__c != null
                                      AND Current_Creditor__c != null 
                                      AND IsActive__c = true
                                    GROUP BY Original_Creditor__c, Current_Creditor__c];
        } else{
            creditorNamesResult = [SELECT Original_Creditor__c, Current_Creditor__c, count(Id) number_of_records
                                     FROM DNL_Settlement_Rates__c 
                                    WHERE Original_Creditor__c != null
                                      AND Current_Creditor__c != null
                                    GROUP BY Original_Creditor__c, Current_Creditor__c];
        }
            
        Set<String> originalCreditors = new Set<String>();
        Set<String> currentCreditors = new Set<String>();
        for(AggregateResult crdNames : creditorNamesResult){
            originalCreditors.add(String.valueOf(crdNames.get('Original_Creditor__c')));
            currentCreditors.add(String.valueOf(crdNames.get('Current_Creditor__c')));
        }
        
        pItmzWrp.originalCreditors = new List<String>(originalCreditors);
        pItmzWrp.originalCreditors.sort();
        pItmzWrp.currentCreditors = new List<String>(currentCreditors);
        pItmzWrp.currentCreditors.sort();
    }
    
    public class Itemization{
        public String  itemizationSetupId;
        public Id      itemizationId;
        public String  itemizationName;
        public String  itemizationCode;
        public String  itemizationFamily;
        public String  plusOrMinus;
        public String  disbursementAllowed;
        public String  feeCategory;
        public Boolean isOverrideAllowed;
    }

    public static List<fsCore__Product_Itemization_Setup__c> getProductItemizations(Id pProductId){
        List<fsCore__Product_Itemization_Setup__c> prodItemizations = new List<fsCore__Product_Itemization_Setup__c>();
        if (pProductId != null){
            System.debug(loggingLevel.ERROR, '-- fetching itemizations for the product');
            prodItemizations = [SELECT Id, fsCore__Itemization_Name__c
                                    , fsCore__Itemization_Name__r.Name
                                    , fsCore__Itemization_Name__r.fsCore__Itemization_Code__c
                                    , fsCore__Itemization_Family__c
                                    , fsCore__Disbursement_Allowed__c
                                    , fsCore__Fee_Category__c
                                    , fsCore__Is_Override_Allowed__c
                                    , fsCore__Plus_Or_Minus__c
                                    , fsCore__Display_Order__c
                                    FROM fsCore__Product_Itemization_Setup__c
                                    WHERE fsCore__Product_Name__c = :pProductId
                                    AND fsCore__Is_Active__c = true
                                    ORDER BY fsCore__Display_Order__c];
        }
        return prodItemizations;
    }
    
    public static Itemization getProductItemization(Id pProductItemizationId){
        List<fsCore__Product_Itemization_Setup__c> prodItemizations = new List<fsCore__Product_Itemization_Setup__c>();
        if (pProductItemizationId != null){
            prodItemizations = [SELECT Id, fsCore__Itemization_Name__c
                                    , fsCore__Itemization_Name__r.Name
                                    , fsCore__Itemization_Name__r.fsCore__Itemization_Code__c
                                    , fsCore__Itemization_Family__c
                                    , fsCore__Disbursement_Allowed__c
                                    , fsCore__Fee_Category__c
                                    , fsCore__Is_Override_Allowed__c
                                    , fsCore__Plus_Or_Minus__c
                                    , fsCore__Display_Order__c
                                    FROM fsCore__Product_Itemization_Setup__c
                                    WHERE Id = :pProductItemizationId];
        }
        
        if (prodItemizations.size() == 1){
            Itemization itmzSetup = new Itemization();
            itmzSetup.itemizationSetupId = String.valueOf(prodItemizations.get(0).Id);
            itmzSetup.itemizationId = prodItemizations.get(0).fsCore__Itemization_Name__c;
            itmzSetup.itemizationName = prodItemizations.get(0).fsCore__Itemization_Name__r.Name;
            itmzSetup.itemizationCode = prodItemizations.get(0).fsCore__Itemization_Name__r.fsCore__Itemization_Code__c;
            itmzSetup.itemizationFamily = prodItemizations.get(0).fsCore__Itemization_Family__c;
            itmzSetup.disbursementAllowed = prodItemizations.get(0).fsCore__Disbursement_Allowed__c;
            itmzSetup.feeCategory = prodItemizations.get(0).fsCore__Fee_Category__c;
            itmzSetup.isOverrideAllowed = prodItemizations.get(0).fsCore__Is_Override_Allowed__c;
            itmzSetup.plusOrMinus = prodItemizations.get(0).fsCore__Plus_Or_Minus__c;
            return itmzSetup;
        }
        return null;
    }

    public static List<fsCore__Contract_Template_Itemization_Setup__c> getContractTemplateItemizations(Id pContractTemplateId){
        List<fsCore__Contract_Template_Itemization_Setup__c> templateItemizations = new List<fsCore__Contract_Template_Itemization_Setup__c>();
        if (pContractTemplateId != null){
            System.debug(loggingLevel.ERROR, '-- fetching itemizations for the contract template');
            templateItemizations = [SELECT Id, fsCore__Itemization_Name__c
                                     , fsCore__Itemization_Name__r.Name
                                     , fsCore__Itemization_Name__r.fsCore__Itemization_Code__c
                                     , fsCore__Itemization_Family__c
                                     , fsCore__Disbursement_Allowed__c
                                     , fsCore__Fee_Category__c
                                     , fsCore__Is_Override_Allowed__c
                                     , fsCore__Plus_Or_Minus__c
                                     , fsCore__Display_Order__c
                                     FROM fsCore__Contract_Template_Itemization_Setup__c
                                     WHERE fsCore__Contract_Template_Name__c = :pContractTemplateId
                                     AND fsCore__Is_Active__c = true
                                     ORDER BY fsCore__Display_Order__c];
        }
        return templateItemizations;
    }
    
    public static Itemization getContractTemplateItemization(Id pTemplateItemizationId){
        List<fsCore__Contract_Template_Itemization_Setup__c> templateItemizations = new List<fsCore__Contract_Template_Itemization_Setup__c>();
        if (pTemplateItemizationId != null){
            System.debug(loggingLevel.ERROR, '-- fetching itemizations for the contract template');
            templateItemizations = [SELECT Id, fsCore__Itemization_Name__c
                                     , fsCore__Itemization_Name__r.Name
                                     , fsCore__Itemization_Name__r.fsCore__Itemization_Code__c
                                     , fsCore__Itemization_Family__c
                                     , fsCore__Disbursement_Allowed__c
                                     , fsCore__Fee_Category__c
                                     , fsCore__Is_Override_Allowed__c
                                     , fsCore__Plus_Or_Minus__c
                                     , fsCore__Display_Order__c
                                     FROM fsCore__Contract_Template_Itemization_Setup__c
                                     WHERE Id = :pTemplateItemizationId];
        }
        
        if (templateItemizations.size() == 1){
            Itemization itmzSetup = new Itemization();
            itmzSetup.itemizationSetupId = String.valueOf(templateItemizations.get(0).Id);
            itmzSetup.itemizationId = templateItemizations.get(0).fsCore__Itemization_Name__c;
            itmzSetup.itemizationName = templateItemizations.get(0).fsCore__Itemization_Name__r.Name;
            itmzSetup.itemizationCode = templateItemizations.get(0).fsCore__Itemization_Name__r.fsCore__Itemization_Code__c;
            itmzSetup.itemizationFamily = templateItemizations.get(0).fsCore__Itemization_Family__c;
            itmzSetup.disbursementAllowed = templateItemizations.get(0).fsCore__Disbursement_Allowed__c;
            itmzSetup.feeCategory = templateItemizations.get(0).fsCore__Fee_Category__c;
            itmzSetup.isOverrideAllowed = templateItemizations.get(0).fsCore__Is_Override_Allowed__c;
            itmzSetup.plusOrMinus = templateItemizations.get(0).fsCore__Plus_Or_Minus__c;
            return itmzSetup;
        }
        return null;
    }

    public static Map<String, Itemization> getSetupItemizations(Id pProductId, Id pContractTemplateId){
        List<fsCore__Product_Itemization_Setup__c> prodItemizations = getProductItemizations(pProductId);
        List<fsCore__Contract_Template_Itemization_Setup__c> templateItemizations = getContractTemplateItemizations(pContractTemplateId);
        
        Map<String, Itemization> itemizationSetupMap = new Map<String, Itemization>();
        Set<String> itemizationCodes = new Set<String>();
        for(fsCore__Product_Itemization_Setup__c prodItmz : prodItemizations){
            Itemization itmzSetup = new Itemization();
            itmzSetup.itemizationSetupId = String.valueOf(prodItmz.Id);
            itmzSetup.itemizationId = prodItmz.fsCore__Itemization_Name__c;
            itmzSetup.itemizationName = prodItmz.fsCore__Itemization_Name__r.Name;
            itmzSetup.itemizationCode = prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c;
            itmzSetup.itemizationFamily = prodItmz.fsCore__Itemization_Family__c;
            itmzSetup.disbursementAllowed = prodItmz.fsCore__Disbursement_Allowed__c;
            itmzSetup.feeCategory = prodItmz.fsCore__Fee_Category__c;
            itmzSetup.isOverrideAllowed = prodItmz.fsCore__Is_Override_Allowed__c;
            itmzSetup.plusOrMinus = prodItmz.fsCore__Plus_Or_Minus__c;
            itemizationSetupMap.put(itmzSetup.itemizationSetupId, itmzSetup);
            itemizationCodes.add(itmzSetup.itemizationCode);
        }
        for(fsCore__Contract_Template_Itemization_Setup__c ctItmz : templateItemizations){
            if(!itemizationCodes.contains(ctItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c)){
                Itemization itmzSetup = new Itemization();
                itmzSetup.itemizationSetupId = String.valueOf(ctItmz.Id);
                itmzSetup.itemizationId = ctItmz.fsCore__Itemization_Name__c;
                itmzSetup.itemizationName = ctItmz.fsCore__Itemization_Name__r.Name;
                itmzSetup.itemizationCode = ctItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c;
                itmzSetup.itemizationFamily = ctItmz.fsCore__Itemization_Family__c;
                itmzSetup.disbursementAllowed = ctItmz.fsCore__Disbursement_Allowed__c;
                itmzSetup.feeCategory = ctItmz.fsCore__Fee_Category__c;
                itmzSetup.isOverrideAllowed = ctItmz.fsCore__Is_Override_Allowed__c;
                itmzSetup.plusOrMinus = ctItmz.fsCore__Plus_Or_Minus__c;
                itemizationSetupMap.put(itmzSetup.itemizationSetupId, itmzSetup);
            }
        }
        return itemizationSetupMap;
    }

    public static fsCore.FeeCalculationObject calculateOriginationFee(fsCore__Fee_Setup__c pFee, Decimal pFinancedAmount){
        fsCore.FeeCalculationObject feeCalcObj = fsCore.FeeCalculationUtil.calculateFeeForFinancedAmount(pFee, pFinancedAmount);
        system.debug(logginglevel.error,'-- Orig Fee calc result : ' + feeCalcObj);
        return feeCalcObj;
    }

    public static fsCore.FeeCalculationObject calculatePrepaidFinanceCharge(
              fsCore__Fee_Setup__c pFee
            , fsCore__Lending_Application__c pApplication
            , Decimal pFinancedAmount
            , Decimal pRate
            , String pType
            , List<ItemizationRowObject> pItemizations){
        fsCore.FeeCalculationObject feeCalcObj = new fsCore.FeeCalculationObject();
        if (pType == 'APPROVED'){
            if (pFinancedAmount != null && pRate != null){
                Integer numOfDays = 30; //pApplication.fsCore__Requested_Payment_Start_Date__c.daysBetween(pApplication.fsCore__Requested_Contract_Start_Date__c);
                feeCalcObj.mCalculatedFeeAmount = fsCore.FinancialUtil.round(numOfDays * (pRate/36000) * pFinancedAmount);
                feeCalcObj.mIsSuccess = true;
            }
        } 
        else {
            List<ItemizationRowObject> sortedItemizations = new List<ItemizationRowObject>();
            //calculate fee
            for (ItemizationRowObject itmz : pItemizations){
                if (!itmz.isFeeItemization){
                    if (String.isNotBlank(itmz.currentCreditorName) || String.isNotBlank(itmz.originalCreditorName)){
                        if (itmz.settledDate != null && itmz.actualAmount != null){
                            sortedItemizations.add(itmz); 
                        }
                    }
                }
            }
            
            feeCalcObj = new fsCore.FeeCalculationObject();
            if (sortedItemizations.size() < 2){ //MEANS 0 or 1 then NO SORTING
                feeCalcObj.mCalculatedFeeAmount = 0;
                feeCalcObj.mIsSuccess = true;
            }
            else{
                sortedItemizations.sort();
                Decimal disbursementAmount = 0.00;
                Decimal prepaidFinCharge = 0.00;
                Date disbursementDate;
                Boolean firstLoop = false;
                
                if (pRate != null && pRate > 0){
                    for (ItemizationRowObject itmz : sortedItemizations){
                        if (!firstLoop){
                            firstLoop = true;
                            disbursementAmount = itmz.actualAmount;
                            disbursementDate = itmz.settledDate;
                        }
                        else{
                            System.RoundingMode roundingMode = fsCore.FinancialUtil.getRoundingMode();
                            fsCore.InterestCalculationObject interestParams = new fsCore.InterestCalculationObject();
                            
                            interestParams.setAmount(disbursementAmount);
                            interestParams.setFromDate(disbursementDate);
                            interestParams.setToDate(itmz.settledDate);
                            interestParams.setRate(pRate);
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

                            disbursementAmount += itmz.actualAmount;
                            disbursementDate = itmz.settledDate;
                        }
                    }
                }
                feeCalcObj.mCalculatedFeeAmount = prepaidFinCharge;
                feeCalcObj.mIsSuccess = true;
            }
        }
        system.debug(logginglevel.error,'-- Prepaid Finance Fee calc result : '+ feeCalcObj);
        return feeCalcObj;
    }

    public static Decimal getRateForPrepaidFinanceCharge(fsCore__Lending_Application__c pApplication){
        Decimal rateForPFC = pApplication.fsCore__Rate__c;
        if (rateForPFC == null){
            System.debug(loggingLevel.ERROR, 'Rate is null... get available pricings to set the rate value');
            List<fsCore__Pricing_Setup__c> availablePricings = fsCore.PricingUtil.getAvailablePricings(pApplication, false);
            if (availablePricings.size() > 0){ rateForPFC = availablePricings.get(0).fsCore__Rate_Value__c; }
        }
        System.debug(loggingLevel.ERROR, '-- Rate for PFC : ' + rateForPFC);
        return rateForPFC;
    }

}