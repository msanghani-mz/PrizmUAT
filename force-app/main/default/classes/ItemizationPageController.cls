/*
* Class Name   - ItemizationPageController
* Description  - Apex Controller for itemizationEditPage lightning component
* Developer(s) - Financial Spectra
*/
public with sharing class ItemizationPageController {
    
    public class ItemizationPageException extends Exception{}
    
    @AuraEnabled
    public static ItemizationWrapper getItemizationWrapper(Id pApplicationId){
        fsCore__Lending_Application__c application = ItemizationPageUtil.getApplication(pApplicationId);
        if (application == null){
            throw new ItemizationPageException('Unable to find the application for the Id ' + pApplicationId);
        }
        ItemizationWrapper itmzWrp = new ItemizationWrapper();
        List<fsCore__Lending_Application_Customer__c> applicantList = [Select name, fsCore__Is_Primary__c, 
                                                                       fsCore__Lending_Application_Number__c, 
                                                                       fsCore__Account_Name__r.Name,
                                                                       fsCore__customer_Type__c
                                                                       From fsCore__Lending_Application_Customer__c
                                                                       Where fsCore__Lending_Application_Number__c =:application.Id
                                                                       Order By fsCore__customer_Type__c LIMIT 2];
        System.debug(applicantList);
        if(applicantList.size()>0) {
            for(fsCore__Lending_Application_Customer__c applicant : applicantList) {
                if(applicant.fsCore__Is_Primary__c == true) {
                    itmzWrp.applicantName = applicant.fsCore__Account_Name__r.Name;
                    itmzWrp.applicantAccountId = applicant.fsCore__Account_Name__c;
                } else {
                    itmzWrp.coApplicantName = applicant.fsCore__Account_Name__r.Name;
                    itmzWrp.coApplicantAccountId = applicant.fsCore__Account_Name__c;
                }
                
            }
        }
        itmzWrp.applicationId = application.Id;
        itmzWrp.applicationNumber = application.Name;
        //itmzWrp.applicantName = application.fsCore__Primary_Customer_Account__r.Name;
        itmzWrp.underwriter = application.Underwriter__c;
        itmzWrp.loanOfficer = application.Loan_Officer__r.Name;
        itmzWrp.productId = application.fsCore__Product_Name__c;
        itmzWrp.contractTemplateId = application.fsCore__Contract_Template_Name__c;
        itmzWrp.isContractTemplateApplied = (application.fsCore__Contract_Template_Name__c != null);
        itmzWrp.state = application.fsCore__State__c;
        //itmzWrp.coApplicantName = application.CoApplicant_Account__c;
        itmzWrp.portfolioType = application.Portfolio_Type__c;
        itmzWrp.paymentProcessor = application.Payment_Processor_Name__c;
        itmzWrp.ndsNumber = application.NDS_File_Number__c;
        itmzWrp.drpNumber = application.DRP_Account_Number__c;
        //itmzWrp.applicantAccountId = application.fsCore__Primary_Customer_Account__c;
        //itmzWrp.coApplicantAccountId = application.CoApplicant_Account__c;
        itmzWrp.status = application.Application_Status_Formula__c;
        itmzWrp.allowApprovedAmountEdit = fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Allow_Access_to_Edit_Approved_Amounts');
        itmzWrp.allowActualAmountEdit = fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Allow_Access_To_Edit_Actual_Amounts');
        ItemizationPageUtil.setCreditorLists(itmzWrp);
        
        itmzWrp.itemizations = new List<ItemizationRowObject>();
        List<fsCore__Lending_Application_Itemization__c> appItemizations = ItemizationPageUtil.getApplicationItemizations(pApplicationId);
        system.debug('------'+appItemizations);
        
        Set<String> feeCategorySet = new Set<String>();
        
        for(fsCore__Lending_Application_Itemization__c appItmz : appItemizations){
            if (String.isNotBlank(appItmz.fsCore__Fee_Category__c)){ feeCategorySet.add(appItmz.fsCore__Fee_Category__c); }
        }
        
        Map<String, List<fsCore__Fee_Setup__c>> categoryToFeesMap = new Map<String, List<fsCore__Fee_Setup__c>>();
        
        if (feeCategorySet.size() > 0){
            System.debug(loggingLevel.ERROR, 'fetching available fees for categories : ' + feeCategorySet);
            categoryToFeesMap = fsCore.OriginationFeeUtil.getAvailableFeesByCategory(feeCategorySet, application, true);
        }
        
        for(fsCore__Lending_Application_Itemization__c appItmz : appItemizations){
            ItemizationRowObject itmzRow = new ItemizationRowObject();
            itmzRow.isNew = false;
            itmzRow.isDisplayCreditor = isDisplayCreditorFields(appItmz.fsCore__Itemization_Family__c, appItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c);
            itmzRow.rowNumber = fsCore.SpectraCoreUtil.getRandomInteger();
            itmzRow.appItemizationId = appItmz.Id;
            itmzRow.applicationId = appItmz.fsCore__Lending_Application_Number__c;
            itmzRow.itemizationId = appItmz.fsCore__Itemization_Name__c;
            itmzRow.itemizationName = appItmz.fsCore__Itemization_Name__r.Name;
            itmzRow.itemizationCode = appItmz.fsCore__Itemization_Code__c;
            itmzRow.itemizationFamily = appItmz.fsCore__Itemization_Family__c;
            itmzRow.itemizationSource = appItmz.fsCore__Source__c;
            itmzRow.plusMinus = appItmz.fsCore__Plus_Or_Minus__c;        
            itmzRow.originalCreditorName = appItmz.Original_Creditor__c;    
            itmzRow.enrolledBalance = appItmz.DNL_Original_Enrolled_Balance__c;       
            itmzRow.currentCreditorName = appItmz.Current_Creditor__c;   
            itmzRow.currentBalance = appItmz.fsCore__Requested_Amount_Unsigned__c;       
            itmzRow.tradelineStatus = appItmz.Tradeline_Current_Stage_Formula__c;         
            itmzRow.litigationStatus = appItmz.Litigation_Stage_Formula__c;                 
            itmzRow.estimateAmount = appItmz.fsCore__Approved_Amount_Unsigned__c;                  
            itmzRow.estimatePercentage = appItmz.Estimated_Settlement_Percent__c;
            if (itmzRow.estimatePercentage == null && itmzRow.estimateAmount != null && itmzRow.currentBalance != null && itmzRow.currentBalance != 0){
                itmzRow.estimatePercentage = ((itmzRow.estimateAmount / itmzRow.currentBalance) * 100).setScale(2);
            }
            itmzRow.actualAmount = appItmz.fsCore__Actual_Amount_Unsigned__c; 
            itmzRow.actualPercentage = appItmz.Actual_Settlement_Percentage__c;              
            if (itmzRow.actualPercentage == null && itmzRow.actualAmount != null && itmzRow.currentBalance != null && itmzRow.currentBalance != 0){
                itmzRow.actualPercentage = ((itmzRow.actualAmount / itmzRow.currentBalance) * 100).setScale(2);
            }
            itmzRow.settledDate = appItmz.Disbursement_Date__c;
            itmzRow.notes = appItmz.Notes__c;
            itmzRow.isFeeItemization = (appItmz.fsCore__Itemization_Family__c != fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT);
            itmzRow.feeId = (appItmz.fsCore__Fee_Name__c != null ? String.valueOf(appItmz.fsCore__Fee_Name__c) : fsCore.Constants.BLANK_STRING);
            itmzRow.feeCategory = appItmz.fsCore__Fee_Category__c;
            itmzRow.allowFeeOverride = appItmz.fsCore__Is_Override_Allowed__c;
            itmzRow.allowDisbursement = appItmz.fsCore__Disbursement_Allowed__c;
            itmzRow.calculatedAmount = appItmz.fsCore__Original_Amount_Unsigned__c;
            itmzRow.isCalculated = appItmz.fsCore__Is_Calculated__c;
            itmzRow.translatedLitStatus = appItmz.Translated_Litigation_Status__c;
            
            
            List<fsCore__Fee_Setup__c> availableFees = new List<fsCore__Fee_Setup__c>();
            if (String.isNotBlank(appItmz.fsCore__Fee_Category__c) && categoryToFeesMap.containsKey(appItmz.fsCore__Fee_Category__c)){
                for(fsCore__Fee_Setup__c origFee : categoryToFeesMap.get(appItmz.fsCore__Fee_Category__c)){
                    if (origFee.fsCore__Record_Type_Label__c == appItmz.fsCore__Itemization_Family__c){
                        availableFees.add(origFee);
                    }
                }
            }
            
            itmzRow.feeList.addAll(getFeeList(availableFees));
            
            if (String.IsBlank(itmzRow.feeId) && availableFees.size() > 0){
                itmzRow.feeId = String.valueOf(availableFees.get(0).Id);
            }
            
            itmzWrp.itemizations.add(itmzRow);
        }
        
        setSummarizedAmountFields(itmzWrp);
        return itmzWrp;
    }
    
    private static List<ItemizationRowObject.C_LabelValue> getItemizationList(Id pProductId, Id pContractTemplateId){
        Map<String, ItemizationPageUtil.Itemization> itmzMap = ItemizationPageUtil.getSetupItemizations(pProductId, pContractTemplateId);
        List<ItemizationRowObject.C_LabelValue> itmzList = new List<ItemizationRowObject.C_LabelValue>();
        itmzList.add(new ItemizationRowObject.C_LabelValue('-- Select an itemization --', ''));
        for(String itmzSetupId : itmzMap.keySet()){
            String itmzName = '(' + itmzMap.get(itmzSetupId).plusOrMinus + ') ' + itmzMap.get(itmzSetupId).itemizationName;
            itmzList.add(new ItemizationRowObject.C_LabelValue(itmzName, itmzSetupId));
        }
        return itmzList;
    }
    
    private static List<ItemizationRowObject.C_LabelValue> getFeeList(List<fsCore__Fee_Setup__c> pFeeSetupList){
        List<ItemizationRowObject.C_LabelValue> feeList = new List<ItemizationRowObject.C_LabelValue>();
        feeList.add(new ItemizationRowObject.C_LabelValue('-- None --', ''));
        for(fsCore__Fee_Setup__c fee : pFeeSetupList){
            feeList.add(new ItemizationRowObject.C_LabelValue(fee.Name, String.valueOf(fee.Id)));
        }
        return feeList;
    }
    
    private static Boolean isCalculatePercent(String pItemizationFamily, String pItemizationCode){
        system.debug(logginglevel.error,' pItemizationFamily :'+ pItemizationFamily+'  pItemizationCode :'+ pItemizationCode);
        Boolean isCalculate = false;
        if (String.IsNotBlank(pItemizationFamily) && pItemizationFamily == fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT){
            if (!(String.IsNotBlank(pItemizationCode) 
                  && (( pItemizationCode == 'DEDICATED_AMOUNT_CASH')
                      || (pItemizationCode == 'DRP_PAYMENT_ONE_MTH') 
                      || (pItemizationCode == 'REM_FEE_DUE_DRP')))){
                          isCalculate = true;
                      }
        }
        system.debug(logginglevel.error,' isCalculate :'+ isCalculate);
        return isCalculate;
    }
    
    private static Boolean isDisplayCreditorFields(String pItemizationFamily, String pItemizationCode){
        Boolean isDisplay = false;
        if (String.IsNotBlank(pItemizationFamily) && pItemizationFamily == fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT){
            if (String.IsNotBlank(pItemizationCode) && pItemizationCode != 'DEDICATED_AMOUNT_CASH' 
                && pItemizationCode != 'DRP_PAYMENT_ONE_MTH' && pItemizationCode != 'REM_FEE_DUE_DRP'){
                    isDisplay = true;
                }
        }
        return isDisplay;
    }
    
    @AuraEnabled
    public static ItemizationWrapper addNewItemization(String pItmzWrapperJSON){
        ItemizationWrapper itmzWrp = (ItemizationWrapper)JSON.deserialize(pItmzWrapperJSON, ItemizationWrapper.class);
        ItemizationRowObject itmzRow = new ItemizationRowObject();
        itmzRow.isNew = true;
        itmzRow.rowNumber = fsCore.SpectraCoreUtil.getRandomInteger();
        itmzRow.isDisplayCreditor = true;
        itmzRow.applicationId = itmzWrp.applicationId;
        itmzRow.itemizationFamily = fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT;
        itmzRow.itemizationSource = fsCore.Constants.ITMZ_SOURCE_MANUAL;
        itmzRow.itemizationList = getItemizationList(itmzWrp.productId, itmzWrp.contractTemplateId); 
        
        List<ItemizationRowObject> itemizationList = new List<ItemizationRowObject>();
        itemizationList.add(itmzRow);        
        
        if (itmzWrp.itemizations != null && itmzWrp.itemizations.size() > 0){
            for (ItemizationRowObject itmz : itmzWrp.itemizations){
                itemizationList.add(itmz);
            }
        }
        itmzWrp.itemizations = itemizationList;
        itmzWrp.enforceCalculation = true;
        return itmzWrp;
    }
    
    @AuraEnabled
    public static ItemizationRowObject getItemizationDetails(String pProdOrCTItemizationId, Id pApplicationId){
        ItemizationRowObject itmzRow = new ItemizationRowObject();
        
        Id itmzSetupId = Id.valueOf(pProdOrCTItemizationId);
        ItemizationPageUtil.Itemization itmzSetup;
        if (itmzSetupId.getSobjectType().getDescribe().getName() == Schema.SObjectType.fsCore__Product_Itemization_Setup__c.getName()){
            itmzSetup = ItemizationPageUtil.getProductItemization(itmzSetupId);
        }
        else if (itmzSetupId.getSobjectType().getDescribe().getName() == Schema.SObjectType.fsCore__Contract_Template_Itemization_Setup__c.getName()){
            itmzSetup = ItemizationPageUtil.getContractTemplateItemization(itmzSetupId);
        }
        
        if (itmzSetup != null){
            itmzRow.isDisplayCreditor = isDisplayCreditorFields(itmzSetup.itemizationFamily, itmzSetup.itemizationCode);
            itmzRow.isFeeItemization = (itmzSetup.itemizationFamily != fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT);
            itmzRow.prodOrCTItemizationId = String.valueOf(itmzSetup.itemizationSetupId);
            itmzRow.itemizationId = itmzSetup.itemizationId;
            itmzRow.itemizationName = itmzSetup.itemizationName;
            itmzRow.itemizationCode = itmzSetup.itemizationCode;
            itmzRow.itemizationFamily = itmzSetup.itemizationFamily;
            itmzRow.plusMinus = itmzSetup.plusOrMinus;        
            itmzRow.feeCategory = itmzSetup.feeCategory;
            itmzRow.allowDisbursement = itmzSetup.disbursementAllowed;
            itmzRow.allowFeeOverride = itmzSetup.isOverrideAllowed;        
        }
        
        if (itmzRow.isFeeItemization && String.IsNotBlank(itmzRow.feeCategory)){
            System.debug(loggingLevel.ERROR, '-- prepare fee list for category ' + itmzRow.feeCategory);
            fsCore__Lending_Application__c application = ItemizationPageUtil.getApplication(pApplicationId);
            Map<String, List<fsCore__Fee_Setup__c>> categoryToFeesMap
                = fsCore.OriginationFeeUtil.getAvailableFeesByCategory(new Set<String>{itmzRow.feeCategory}, application, true);
            System.debug(loggingLevel.ERROR, '-- category ro fee setup : ' + categoryToFeesMap);
            
            List<fsCore__Fee_Setup__c> availableFees = new List<fsCore__Fee_Setup__c>();
            if (categoryToFeesMap.containsKey(itmzRow.feeCategory)){
                for(fsCore__Fee_Setup__c origFee : categoryToFeesMap.get(itmzRow.feeCategory)){
                    if (origFee.fsCore__Record_Type_Name__c == itmzRow.itemizationFamily){
                        availableFees.add(origFee);
                    }
                }
                System.debug(loggingLevel.ERROR, '-- available fees : ' + availableFees);
            }
            itmzRow.feeList.addAll(getFeeList(availableFees));
            System.debug(loggingLevel.ERROR, '-- fee list : ' + itmzRow.feeList);
            
            if (String.IsBlank(itmzRow.feeId) && availableFees.size() > 0){
                itmzRow.feeId = String.valueOf(availableFees.get(0).Id);
            }
        }
        itmzRow.allowFeeOverride = true;
        System.debug(loggingLevel.ERROR, '-- itmzRow : ' + itmzRow);
        return itmzRow;
    }
    
    //@AuraEnabled
    //public static ItemizationRowObject calculateFee(String pFeeId, Id pApplicationId, Decimal pApprovedFinancedAmount, Decimal pActualFinancedAmount){
    //    fsCore__Lending_Application__c application = ItemizationPageUtil.getApplication(pApplicationId);
    //    Boolean allowApprovedAmountEdit = fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Allow_Access_to_Edit_Approved_Amounts');
    //    Boolean allowActualAmountEdit = fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Allow_Access_To_Edit_Actual_Amounts');
    //    ItemizationRowObject itmzRow = new ItemizationRowObject();
    //    
    //    if (String.IsNotBlank(pFeeId)){
    //        fsCore__Fee_Setup__c feeSetup = fsCore.FeeCalculationUtil.getFeeSetup(Id.valueOf(pFeeId), application.fsCore__Application_Date__c, application.fsCore__Product_Family__c);
    //        // add logic to calculate fee
    //    }
    //    else {
    //        itmzRow.actualAmount = 0.00;
    //        itmzRow.estimateAmount = 0.00;
    //    }
    //
    //    return itmzRow;
    //}
    
    @AuraEnabled
    public static ItemizationWrapper calculateItemizations(String pItmzWrapperJSON){
        ItemizationWrapper itmzWrp = (ItemizationWrapper)JSON.deserialize(pItmzWrapperJSON, ItemizationWrapper.class);
        Set<Id> feeIdSet = new Set<Id>();
        List<ItemizationRowObject> finnAmtItemizations = new List<ItemizationRowObject>();
        Boolean hasPrepaidCharge = false;
        if (itmzWrp.itemizations != null && itmzWrp.itemizations.size() > 0){
            for (ItemizationRowObject itmz : itmzWrp.itemizations){
                if (itmz.isFeeItemization && String.IsNotBlank(itmz.feeId)){
                    feeIdSet.add(Id.valueOf(itmz.feeId));
                    if (String.IsNotBlank(itmz.feeCategory) && itmz.feeCategory == 'Prepaid Finance Charge'){
                        hasPrepaidCharge = true;
                    }
                }
                if (!itmz.isFeeItemization){
                    finnAmtItemizations.add(itmz);
                }
            }
        }
        
        fsCore__Lending_Application__c application = ItemizationPageUtil.getApplication(itmzWrp.applicationId);
        Map<Id, fsCore__Fee_Setup__c> feeSetupMap = new Map<Id, fsCore__Fee_Setup__c>();
        if (feeIdSet.size() > 0){
            feeSetupMap = fsCore.FeeCalculationUtil.getFeeSetupMap(feeIdSet, application.fsCore__Application_Date__c, application.fsCore__Product_Family__c);
        }
        
        Decimal rateForPFC = 0.00;
        if (hasPrepaidCharge){
            rateForPFC = ItemizationPageUtil.getRateForPrepaidFinanceCharge(application);
            System.debug(loggingLevel.ERROR, '-- Prepaid Finance Charge Rate : ' + rateForPFC);
        }
        
        Decimal approvedFinancedAmount = (itmzWrp.approvedFinancedAmount == null ? 0.00 : itmzWrp.approvedFinancedAmount);
        Decimal actualFinancedAmount = (itmzWrp.actualFinancedAmount == null ? 0.00 : itmzWrp.actualFinancedAmount);
        
        if (itmzWrp.itemizations != null && itmzWrp.itemizations.size() > 0){
            for (ItemizationRowObject itmz : itmzWrp.itemizations){
                if (itmz.isFeeItemization){
                    if (String.IsNotBlank(itmz.feeId)){
                        Id feeId = Id.valueOf(itmz.feeId);
                        if (!feeSetupMap.containsKey(feeId)){ continue; }
                        
                        fsCore__Fee_Setup__c fee = feeSetupMap.get(feeId);
                        if (fee.fsCore__Fee_Category__c == 'Origination Fee'){
                            if (itmzWrp.allowApprovedAmountEdit){
                                fsCore.FeeCalculationObject feeCalcObj = ItemizationPageUtil.calculateOriginationFee(fee, approvedFinancedAmount);
                                itmz.estimateAmount = feeCalcObj.mCalculatedFeeAmount;
                                itmz.calculatedAmount = feeCalcObj.mCalculatedFeeAmount;
                                itmz.isCalculated = true;
                            }
                            if (itmzWrp.allowActualAmountEdit){
                                fsCore.FeeCalculationObject feeCalcObj = ItemizationPageUtil.calculateOriginationFee(fee, actualFinancedAmount);
                                itmz.actualAmount = feeCalcObj.mCalculatedFeeAmount;
                            }
                        }
                        else if (fee.fsCore__Fee_Category__c == 'Prepaid Finance Charge'){
                            if (itmzWrp.allowApprovedAmountEdit){
                                fsCore.FeeCalculationObject feeCalcObj = ItemizationPageUtil.calculatePrepaidFinanceCharge(fee, application, approvedFinancedAmount, rateForPFC, 'APPROVED', finnAmtItemizations);
                                itmz.estimateAmount = feeCalcObj.mCalculatedFeeAmount;
                                itmz.calculatedAmount = feeCalcObj.mCalculatedFeeAmount;
                                itmz.isCalculated = true;
                            }
                            if (itmzWrp.allowActualAmountEdit){
                                fsCore.FeeCalculationObject feeCalcObj = ItemizationPageUtil.calculatePrepaidFinanceCharge(fee, application, actualFinancedAmount, rateForPFC, 'ACTUAL', finnAmtItemizations);
                                itmz.actualAmount = feeCalcObj.mCalculatedFeeAmount;
                            }
                        }
                        
                    }
                    else {
                        itmz.estimateAmount = 0.00;
                        itmz.actualAmount = 0.00;
                        itmz.calculatedAmount = 0.00;
                        itmz.isCalculated = true;
                    }
                }
            }
        }
        
        setSummarizedAmountFields(itmzWrp);
        return itmzWrp;
    }
    
    private static void setSummarizedAmountFields(ItemizationWrapper pItmzWrp){
        if (pItmzWrp.itemizations != null && pItmzWrp.itemizations.size() > 0){
            pItmzWrp.approvedFinancedAmount = 0.00;
            pItmzWrp.approvedFinanceFee = 0.00;
            pItmzWrp.approvedPrepaidFee = 0.00;
            pItmzWrp.actualFinancedAmount = 0.00;
            pItmzWrp.actualFinanceFee = 0.00;
            pItmzWrp.actualPrepaidFee = 0.00;
            for (ItemizationRowObject itmz : pItmzWrp.itemizations){
                Decimal approvedAmount = (itmz.estimateAmount == null ? 0.00 : itmz.estimateAmount);
                Decimal actualAmount = (itmz.actualAmount == null ? 0.00 : itmz.actualAmount);
                if (itmz.plusMinus == '-'){
                    approvedAmount = -1 * approvedAmount;
                    actualAmount = -1 * actualAmount;
                }
                
                if (itmz.itemizationFamily == 'Financed Amount'){
                    pItmzWrp.approvedFinancedAmount += approvedAmount;
                    pItmzWrp.actualFinancedAmount += actualAmount;
                } else if (itmz.itemizationFamily == 'Finance Fee'){
                    pItmzWrp.approvedFinanceFee += approvedAmount;
                    pItmzWrp.actualFinanceFee += actualAmount;
                } else if (itmz.itemizationFamily == 'Prepaid Fee'){
                    pItmzWrp.approvedPrepaidFee += approvedAmount;
                    pItmzWrp.actualPrepaidFee += actualAmount;
                }
            }
            pItmzWrp.totalApprovedAmount = pItmzWrp.approvedFinancedAmount + pItmzWrp.approvedFinanceFee + pItmzWrp.approvedPrepaidFee;
            pItmzWrp.totalActualAmount = pItmzWrp.actualFinancedAmount + pItmzWrp.actualFinanceFee + pItmzWrp.actualPrepaidFee;
        }
    }
    
    @AuraEnabled
    public static ItemizationWrapper saveItemizations(String pItmzWrapperJSON){
        System.debug(loggingLevel.ERROR, 'saveItemizations(+)');
        ItemizationWrapper itmzWrp = (ItemizationWrapper)JSON.deserialize(pItmzWrapperJSON, ItemizationWrapper.class);
        Set<Id> itmzIdSet = new Set<Id>();
        if (itmzWrp.itemizations != null && itmzWrp.itemizations.size() > 0){
            for (ItemizationRowObject itmz : itmzWrp.itemizations){
                if (itmz.appItemizationId != null){
                    itmzIdSet.add(itmz.appItemizationId);
                }
            }
        }
        
        Map<Id, fsCore__Lending_Application_Itemization__c> appItemizationMap = new Map<Id, fsCore__Lending_Application_Itemization__c>();
        if (itmzIdSet.size() > 0){
            fsCore.DynamicQueryBuilder appItmzQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application_Itemization__c.getName())
                .addFields()
                .addWhereConditionWithBind(1,'Id','IN','itmzIdSet');
            
            for (fsCore__Lending_Application_Itemization__c appItmz : (List<fsCore__Lending_Application_Itemization__c>)Database.query(appItmzQuery.getQueryString())){
                appItemizationMap.put(appItmz.Id, appItmz);
            }
        }
        
        List<fsCore__Lending_Application_Itemization__c> itemizationsToSave = new List<fsCore__Lending_Application_Itemization__c>();
        if (itmzWrp.itemizations != null && itmzWrp.itemizations.size() > 0){
            for (ItemizationRowObject itmz : itmzWrp.itemizations){
                fsCore__Lending_Application_Itemization__c appItmz;
                if (itmz.appItemizationId != null && appItemizationMap.containsKey(itmz.appItemizationId)){
                    appItmz = appItemizationMap.get(itmz.appItemizationId);
                } else {
                    appItmz = new fsCore__Lending_Application_Itemization__c();
                    appItmz.fsCore__Lending_Application_Number__c = itmz.applicationId;
                }
                
                appItmz.fsCore__Itemization_Name__c = itmz.itemizationId;
                appItmz.fsCore__Itemization_Code__c = itmz.itemizationCode;
                appItmz.fsCore__Itemization_Family__c = itmz.itemizationFamily;
                appItmz.fsCore__Source__c = itmz.itemizationSource;
                appItmz.fsCore__Plus_Or_Minus__c = itmz.plusMinus;        
                appItmz.Original_Creditor__c = itmz.originalCreditorName;    
                appItmz.DNL_Original_Enrolled_Balance__c = itmz.enrolledBalance;       
                appItmz.Current_Creditor__c = itmz.currentCreditorName;   
                appItmz.fsCore__Requested_Amount_Unsigned__c = itmz.currentBalance;       
                appItmz.fsCore__Approved_Amount_Unsigned__c = itmz.estimateAmount;
                appItmz.fsCore__Actual_Amount_Unsigned__c = itmz.actualAmount; 
                
                //DV-489 The isDisplayCreditorFields should take care of fee itemization too and will return false for them
                system.debug(logginglevel.error,' estimatePercentage '+itmz.estimatePercentage);
                system.debug(logginglevel.error,' actualPercentage '+itmz.actualPercentage);
                if (isCalculatePercent(itmz.itemizationFamily, itmz.itemizationCode)){
                    system.debug(logginglevel.error,' Making it not null ');
                    appItmz.Estimated_Settlement_Percent__c = itmz.estimatePercentage;              
                    appItmz.Actual_Settlement_Percentage__c = itmz.actualPercentage;              
                } else {
                    system.debug(logginglevel.error,' Making it null ');
                    appItmz.Estimated_Settlement_Percent__c = null;              
                    appItmz.Actual_Settlement_Percentage__c = null;              
                }
                
                appItmz.Disbursement_Date__c = itmz.settledDate;
                appItmz.fsCore__Disbursement_Allowed__c = itmz.allowDisbursement;
                appItmz.Notes__c = itmz.notes;
                appItmz.fsCore__Fee_Name__c = (String.IsBlank(itmz.feeId) ? null : Id.valueOf(itmz.feeId));
                appItmz.fsCore__Fee_Category__c = itmz.feeCategory;
                appItmz.fsCore__Original_Amount_Unsigned__c = itmz.calculatedAmount;
                appItmz.fsCore__Is_Calculated__c = itmz.isCalculated;
                itemizationsToSave.add(appItmz);
            }
        }
        
        try{
            upsert itemizationsToSave;
            itmzWrp = getItemizationWrapper(itmzWrp.applicationId);
        }
        catch (Exception e){
            itmzWrp.hasError = true;
            itmzWrp.errorMessage = e.getMessage();
            System.debug(loggingLevel.ERROR, 'Exception : ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        
        System.debug(loggingLevel.ERROR, 'saveItemizations(-)');
        return itmzWrp;
    }
    
    @AuraEnabled
    public static Decimal getEstimatedSettlementPercentage(String pCurrentCreditor, String pOriginalCreditor, String pTranslatedLitStatus){
        List<DNL_Settlement_Rates__c> dnlSettlementRateList;
        system.debug('------'+pCurrentCreditor);
        system.debug('------'+pOriginalCreditor);
        system.debug('------'+pTranslatedLitStatus);
        if (SFS_System_Settings__c.getInstance().Is_DNL_Settlement_Active_Rates_Only__c){
            dnlSettlementRateList = [SELECT Id, Original_Creditor__c, Current_Creditor__c, Average_of_Adjusted_Settlement__c, Type__c
                                     FROM DNL_Settlement_Rates__c 
                                     WHERE IsActive__c = true 
                                     AND Type__c = :pTranslatedLitStatus
                                     AND Average_of_Adjusted_Settlement__c != null
                                     ORDER BY Current_Creditor__c];
        } else {
            dnlSettlementRateList = [SELECT Id, Original_Creditor__c, Current_Creditor__c, Average_of_Adjusted_Settlement__c, Type__c
                                     FROM DNL_Settlement_Rates__c
                                     WHERE Type__c = :pTranslatedLitStatus
                                     AND Average_of_Adjusted_Settlement__c != null
                                     ORDER BY Current_Creditor__c];
        }
        
        System.debug(logginglevel.error, dnlSettlementRateList);
        Decimal estimatePercentage;
        for(DNL_Settlement_Rates__c dnlRate : dnlSettlementRateList){
            
            if(dnlRate.Original_Creditor__c == pOriginalCreditor && dnlRate.Current_Creditor__c == pCurrentCreditor) {
                System.debug(dnlRate.Average_of_Adjusted_Settlement__c);
                estimatePercentage = dnlRate.Average_of_Adjusted_Settlement__c;
                break;
            } 
        }
        if(estimatePercentage == null) {
            for(DNL_Settlement_Rates__c dnlRate : dnlSettlementRateList){
                
                if(dnlRate.Current_Creditor__c == pCurrentCreditor) {
                    System.debug(dnlRate.Average_of_Adjusted_Settlement__c);
                    estimatePercentage = dnlRate.Average_of_Adjusted_Settlement__c;
                    break;
                } 
            }
        }
        if(estimatePercentage == null) {
            for(DNL_Settlement_Rates__c dnlRate : dnlSettlementRateList){
                
                if(dnlRate.Original_Creditor__c == pOriginalCreditor) {
                    System.debug(dnlRate.Average_of_Adjusted_Settlement__c);
                    estimatePercentage = dnlRate.Average_of_Adjusted_Settlement__c;
                    break;
                }
            }
        }
        
        if (estimatePercentage == null){
            // IF NO MATCH THEN SET TO 50% AS MENTIONED IN THE TICKET PDI-713
            
            if (SFS_System_Settings__c.getInstance().Is_DNL_Settle_Unmatched_Default_Allowed__c){
                if (SFS_System_Settings__c.getInstance().DNL_Settlement_Unmatched_Rate__c != null){
                    System.debug(logginglevel.error,'SFS_System_Settings__c');
                    estimatePercentage = SFS_System_Settings__c.getInstance().DNL_Settlement_Unmatched_Rate__c;
                } else {
                    estimatePercentage = 52.00;
                }
            }
            
            //estimatePercentage = 52.00;
        }
        System.debug(logginglevel.error, estimatePercentage);
        return estimatePercentage;
    }
    
    @AuraEnabled
    public static String refreshDataFromNuDebt(Id pApplicationId) {
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecord(pApplicationId);
        
        fsCore.ActionOutput acOutput = new fsCore.ActionOutput();
        try{
            RefreshTradelinesAction refreshTL = new RefreshTradelinesAction();
            refreshTL.setInput(acInput);
            refreshTL.setIsCalledFromUI(true);//DV-161
            refreshTL.process();
            acOutput = refreshTL.getOutput();
            if (acOutput.getIsSuccess()){
                acOutput.setMessage(Label.NuDebt_Refresh_Success_Message);
            }
        } catch (Exception e){
            acOutput.addError(e);
        }
        
        return acOutput.getJSONString();
    }
    
}