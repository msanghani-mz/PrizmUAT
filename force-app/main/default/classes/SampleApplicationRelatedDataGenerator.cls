/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name   - SampleApplicationRelatedDataGenerator
 *
 * Description  - This class is used to create the related data for sample applications
 *
 * Developer(s) - Financial Spectra Dev
 *
 */
public class SampleApplicationRelatedDataGenerator {

    private Map<Id, fsCore__Lending_Application__c> mApplicationMap;
    private Integer mNumberOfRecords = 0;
    private Id mProductId;
    private Id mTemplateId;
    private fsCore__Stage_Setup__c mFundingStage;
    private static final String  SAMPLE_CURRENCY_CODE = 'USD';
    
    public SampleApplicationRelatedDataGenerator(Integer pNumberOfRecords){
        mNumberOfRecords = pNumberOfRecords;
        init();    
    }
    
    private void init(){
        fsCore.DynamicQueryBuilder appQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName());
        appQuery.addFields();
        appQuery.addWhereConditionWithValue(1,'fsCore__Source__c','=','Other');
        appQuery.addWhereConditionWithValue(2,'fsCore__Number_Of_Repayments__c','=',0);
        appQuery.setRecordLimit(mNumberOfRecords);

        List<fsCore__Lending_Application__c> appList = (List<fsCore__Lending_Application__c>)Database.query(appQuery.getQueryString());
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
        
        for (fsCore__Lending_Application__c app : appList){
            mApplicationMap.put(app.Id, app);
            mProductId = app.fsCore__Product_Name__c;
            mTemplateId = app.fsCore__Contract_Template_Name__c;
        }
    }

    public void setFundingStage(String pStageCode){
        fsCore.DynamicQueryBuilder stageQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Stage_Setup__c.getName());
        stageQuery.addFields();
        stageQuery.addWhereConditionWithBind(1,'fsCore__Stage_Code__c','=','pStageCode');
        
        List<fsCore__Stage_Setup__c> stageQueryResult = (List<fsCore__Stage_Setup__c>)Database.query(stageQuery.getQueryString());
        if (stageQueryResult.size() == 1){
            mFundingStage = stageQueryResult.get(0);
        }
    }
    
    public void generateData(){
        //create itemizations
        List<fsCore__Product_Itemization_Setup__c> prodItemizations = fsCore.ProductUtil.getProductItemizations(mProductId);
        List<fsCore__Contract_Template_Itemization_Setup__c> templateItemizations = fsCore.ContractTemplateUtil.getContractTemplateItemizations(mTemplateId);
        
        List<fsCore__Lending_Application_Itemization__c> allItemizations = new List<fsCore__Lending_Application_Itemization__c>();
        for(fsCore__Lending_Application__c app : mApplicationMap.values()){
            allItemizations.addAll(getItemizations(app, prodItemizations, templateItemizations));
        }
        insert allItemizations;
    
        //create repayment schedule and repayments
        List<fsCore__Lending_Application_Repayment_Schedule__c> repaySchedules = new List<fsCore__Lending_Application_Repayment_Schedule__c>();
        List<fsCore__Lending_Application_Repayment__c> repayments = new List<fsCore__Lending_Application_Repayment__c>();
        for(fsCore__Lending_Application__c app : mApplicationMap.values()){
            repaySchedules.add(getRepaymentSchedule(app));
            repayments.addAll(getRepayments(app));
        }
        insert repaySchedules;
        insert repayments;
        
        //update stages
        if (mFundingStage != null){
            List<fsCore__Lending_Application_Stage__c> appStages = 
                [SELECT Id, fsCore__Stage_Name__c, fsCore__Stage_Status__c
                 FROM fsCore__Lending_Application_Stage__c
                 WHERE fsCore__Lending_Application_Number__c IN :mApplicationMap.keySet()];
            
            for (fsCore__Lending_Application_Stage__c stage : appStages){
                stage.fsCore__Stage_Name__c = mFundingStage.Id;
                stage.fsCore__Stage_Status__c = 'Validated';
            }
            update appStages;
            
            for (fsCore__Lending_Application__c app : mApplicationMap.values()){
                app.fsCore__Current_Stage_Name__c = mFundingStage.Id;
                app.fsCore__Is_Current_Stage_Validated__c = true;
            }
            update mApplicationMap.values(); 
        }
    }    

    private List<fsCore__Lending_Application_Itemization__c> getItemizations(fsCore__Lending_Application__c pApp
                                                                           , List<fsCore__Product_Itemization_Setup__c> pProdItemizations
                                                                           , List<fsCore__Contract_Template_Itemization_Setup__c> pTmpltItemizations){
        List<fsCore__Lending_Application_Itemization__c> appItemizations = new List<fsCore__Lending_Application_Itemization__c>();
        appItemizations = fsCore.LendingApplicationItemizationUtil.getItemizationFromProduct(pApp.Id, SAMPLE_CURRENCY_CODE, pProdItemizations, appItemizations);
        appItemizations = fsCore.LendingApplicationItemizationUtil.getItemizationFromTemplate(pApp.Id, SAMPLE_CURRENCY_CODE, pTmpltItemizations, appItemizations);
        
        Decimal financedAmount = pApp.fsCore__Financed_Amount__c;
        Decimal financeFee = pApp.fsCore__Finance_Fee__c;
        Decimal prepaidFee = pApp.fsCore__Prepaid_Fee__c;
        
        for (fsCore__Lending_Application_Itemization__c itmz : appItemizations){
            if (itmz.fsCore__Itemization_Family__c.equalsIgnoreCase(fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT) 
                && itmz.fsCore__Plus_Or_Minus__c == '+' && financedAmount > 0){
                itmz.fsCore__Requested_Amount_Unsigned__c = financedAmount;
                itmz.fsCore__Approved_Amount_Unsigned__c = financedAmount;
                itmz.fsCore__Actual_Amount_Unsigned__c = financedAmount;
                financedAmount = 0;
            }
            else if (itmz.fsCore__Itemization_Family__c.equalsIgnoreCase(fsCore.Constants.ITMZ_FAMILY_FINANCE_FEE) 
                     && itmz.fsCore__Plus_Or_Minus__c == '+' && financeFee > 0){
                itmz.fsCore__Approved_Amount_Unsigned__c = financeFee;
                itmz.fsCore__Actual_Amount_Unsigned__c = financeFee;
                financeFee = 0;
            }
            else if (itmz.fsCore__Itemization_Family__c.equalsIgnoreCase(fsCore.Constants.ITMZ_FAMILY_PREPAID_FEE) 
                     && itmz.fsCore__Plus_Or_Minus__c == '+' && prepaidFee > 0){
                itmz.fsCore__Approved_Amount_Unsigned__c = prepaidFee;
                itmz.fsCore__Actual_Amount_Unsigned__c = prepaidFee;
                prepaidFee = 0;
           } else {
                itmz.fsCore__Requested_Amount_Unsigned__c = 0;
                itmz.fsCore__Approved_Amount_Unsigned__c = 0;
                itmz.fsCore__Actual_Amount_Unsigned__c = 0;
           }
        }
        return appItemizations;
    }
    
    private fsCore__Lending_Application_Repayment_Schedule__c getRepaymentSchedule(fsCore__Lending_Application__c pApp){
        fsCore__Lending_Application_Repayment_Schedule__c repaySch = new fsCore__Lending_Application_Repayment_Schedule__c();
        repaySch.fsCore__Lending_Application_Number__c = pApp.Id;
        repaySch.fsCore__Start_Date__c = pApp.fsCore__Payment_Start_Date__c;
        repaySch.fsCore__Number_Of_Payments__c = pApp.fsCore__Number_Of_Payments__c;
        repaySch.fsCore__Payment_Amount__c = pApp.fsCore__Payment_Amount__c;
        repaySch.fsCore__Start_Payment_Number__c = null;
        repaySch.fsCore__Is_Predefined_Payment__c = false;
        if (UserInfo.isMultiCurrencyOrganization()){
            repaySch.put(fsCore.Constants.FIELD_NAME_CURRENCY, SAMPLE_CURRENCY_CODE);
        }
        
        return repaySch;
    }
    
    private List<fsCore__Lending_Application_Repayment__c> getRepayments(fsCore__Lending_Application__c pApp){
        List<fsCore__Lending_Application_Repayment__c> repaymentList = new List<fsCore__Lending_Application_Repayment__c>();
        Decimal paymentAmount = pApp.fsCore__Payment_Amount__c;
        Decimal openingBalance = pApp.fsCore__Principal_Balance__c;
        Integer numberOfPayments = (Integer)pApp.fsCore__Number_Of_Payments__c;
        Date interestCalcStartDate = pApp.fsCore__Contract_Date__c;
        Date nextPaymentDate = pApp.fsCore__Payment_Start_Date__c;
        
        for (Integer i = 1; i <= numberOfPayments; i++){
            Decimal interestCalcPeriod = getInterestCalcPeriod(pApp.fsCore__Interest_Accrual_Base_Method__c, pApp.fsCore__Payment_Cycle__c, interestCalcStartDate, nextPaymentDate);
            Decimal interestAmount = openingBalance * (pApp.fsCore__Rate__c/100) * interestCalcPeriod;
            interestAmount = interestAmount.setScale(2);
            
            fsCore__Lending_Application_Repayment__c repayDtl = new fsCore__Lending_Application_Repayment__c();
            repayDtl.fsCore__Lending_Application_Number__c = pApp.Id;
            repayDtl.fsCore__Payment_Number__c = i;
            repayDtl.fsCore__Payment_Date__c = nextPaymentDate;
            repayDtl.fsCore__Payment_Amount__c = paymentAmount;
            repayDtl.fsCore__Opening_Balance_Amount__c = openingBalance;
            repayDtl.fsCore__Fee_Amount__c = 0.00;
            repayDtl.fsCore__Interest_Amount__c = interestAmount;
            repayDtl.fsCore__Principal_Amount__c = paymentAmount - interestAmount;
            repayDtl.fsCore__Closing_Balance_Amount__c = openingBalance - repayDtl.fsCore__Principal_Amount__c;
            if (UserInfo.isMultiCurrencyOrganization()){
                repayDtl.put(fsCore.Constants.FIELD_NAME_CURRENCY, SAMPLE_CURRENCY_CODE);
            }
            repaymentList.add(repayDtl);
            
            interestCalcStartDate = nextPaymentDate;
            nextPaymentDate = fsCore.DateUtilGlobal.adjustDateByBillingCycle(nextPaymentDate, nextPaymentDate.day(), pApp.fsCore__Payment_Cycle__c, 1);
            openingBalance = repayDtl.fsCore__Closing_Balance_Amount__c;
        }
         
        return repaymentList;
    }

    private Decimal getInterestCalcPeriod(String pInterestDayMethod, String pPaymentCycle, Date pFromDate, Date pToDate){
        Decimal interestCalcPeriod;
        if (pInterestDayMethod == '360-360' && pPaymentCycle == fsCore.Constants.CYCLE_MONTHLY){
            interestCalcPeriod = 0.08333333;
        } else {
            Integer daysInYear = Date.isLeapYear(pToDate.year()) ? 366 : 365;
            Integer periodDays = pFromDate.daysBetween(pToDate);
            interestCalcPeriod = ((Decimal) periodDays / (Decimal) daysInYear);
        }

        return interestCalcPeriod;
    }

}