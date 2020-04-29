/*
* Class   : DTICalculationController
* Purpose : Controller class for DTI calculator component
* Author  : Financial Spectra
*/
public class DTICalculationController {
    
    @AuraEnabled
    public static DTICalculatorWrapper getDTICalculatorWrapper(Id pApplicationId){
        System.debug(logginglevel.error,'getDTICalculatorWrapper');
        return getDTICalculatorWrapper(pApplicationId, 'Stated Amount');
    }
    
    @AuraEnabled
    public static DTICalculatorWrapper getDTICalculatorWrapper(Id pApplicationId, String pSource){
        
        System.debug(logginglevel.error,pSource);
        fsCore__Lending_Application__c application = [SELECT Id, Name,
                                                      (SELECT Id, Name
                                                       , fsCore__Account_Name__c
                                                       , fsCore__Account_Name__r.PersonContactId
                                                       , Person_Name_Formula__c
                                                       , fsCore__Is_Primary__c
                                                       FROM fsCore__Lending_Application_Customer__r
                                                       ORDER BY Name ASC) 
                                                      FROM fsCore__Lending_Application__c
                                                      WHERE Id = :pApplicationId];
        
        DTICalculatorWrapper dtiCalcWrapper = new DTICalculatorWrapper();
        dtiCalcWrapper.applicationId = application.Id;
        dtiCalcWrapper.applicationNumber = application.Name;
        
        Schema.DescribeFieldResult dtiCalcSourceFieldDesc = DTI_Calculation__c.Source__c.getDescribe();
        dtiCalcWrapper.source.label = dtiCalcSourceFieldDesc.getLabel();
        dtiCalcWrapper.source.value = pSource;
        dtiCalcWrapper.sourceOptions = new List<LabelValueType>();
        
        for (Schema.PicklistEntry source : dtiCalcSourceFieldDesc.getPicklistValues()){
            if (source.isActive()){
                dtiCalcWrapper.sourceOptions.add(new LabelValueType(source.getLabel(), source.getValue()));
                if (source.isDefaultValue() && String.IsBlank(pSource)){
                    dtiCalcWrapper.source.value = source.getValue();
                }
            }
        }
        
        for (fsCore__Lending_Application_Customer__c applicant : application.fsCore__Lending_Application_Customer__r){
            if (applicant.fsCore__Is_Primary__c){
                dtiCalcWrapper.applicantExists = true;
                dtiCalcWrapper.applicantId = applicant.Id;
                dtiCalcWrapper.applicantContactId = applicant.fsCore__Account_Name__r.PersonContactId;
                dtiCalcWrapper.applicantName = applicant.Person_Name_Formula__c;
                dtiCalcWrapper.applicantTotalMonthlyDebt = 0.00;
                dtiCalcWrapper.applicantTotalAnnualIncome = 0.00;
                dtiCalcWrapper.applicantDebtToIncome = 0.00;
            }
            else {
                if (!dtiCalcWrapper.coApplicantExists){
                    dtiCalcWrapper.coApplicantExists = true;
                    dtiCalcWrapper.coApplicantId = applicant.Id;
                    dtiCalcWrapper.coApplicantContactId = applicant.fsCore__Account_Name__r.PersonContactId;
                    dtiCalcWrapper.coApplicantName = applicant.Person_Name_Formula__c;
                    dtiCalcWrapper.coApplicantTotalMonthlyDebt = 0.00;
                    dtiCalcWrapper.coApplicantTotalAnnualIncome = 0.00;
                    dtiCalcWrapper.coApplicantDebtToIncome = 0.00;
                }
            }
            
            if (dtiCalcWrapper.applicantExists && dtiCalcWrapper.coApplicantExists){
                break;
            }
        }
        
        if (!dtiCalcWrapper.applicantExists){
            return dtiCalcWrapper;
        }
        
        Set<Id> contactIdSet = new Set<Id>();
        if (dtiCalcWrapper.applicantExists){
            contactIdSet.add(dtiCalcWrapper.applicantContactId);
        }
        if (dtiCalcWrapper.coApplicantExists){
            contactIdSet.add(dtiCalcWrapper.coApplicantContactId);
        }
        List<DTI_Calculation__c> dtiCalcList = [Select Lending_Application_Number__c,
                                                Source__c,
                                                Debts__c,
                                                Taxable_Incomes__c,
                                                Non_Taxable_Incomes__c
                                                from DTI_Calculation__c
                                                where Source__c =:pSource 
                                                AND Lending_Application_Number__c = :pApplicationId
                                                AND Is_Most_Recent_DTI_Calculation__c = true];
        System.debug(logginglevel.error,dtiCalcList);
        if(dtiCalcList.size()>0){
            
            List<FinancialWrapper> debtFinancialWrapperList = new List<FinancialWrapper>();
            List<FinancialWrapper> debtFinList = (List<FinancialWrapper>)JSON.deserialize(dtiCalcList[0].Debts__c, List<FinancialWrapper>.class);
            System.debug(logginglevel.error,debtFinList);
            for(FinancialWrapper finWrp : debtFinList) {
                FinancialWrapper finWrapper = new FinancialWrapper();
                finWrapper.financialType               = finWrp.financialType;
                finWrapper.existsForApplicant          = finWrp.existsForApplicant;
                finWrapper.existsForCoApplicant        = finWrp.existsForCoApplicant;
                finWrapper.monthlyAmountApplicant      = finWrp.monthlyAmountApplicant;
                finWrapper.monthlyAmountCoApplicant    = finWrp.monthlyAmountCoApplicant;
                finWrapper.annualAmountApplicant       = finWrp.annualAmountApplicant;
                finWrapper.annualAmountCoApplicant     = finWrp.annualAmountCoApplicant;
                finWrapper.multiplier                  = finWrp.multiplier;
                finWrapper.effectiveAmountApplicant    = finWrp.effectiveAmountApplicant;
                finWrapper.effectiveAmountCoApplicant  = finWrp.effectiveAmountCoApplicant;
                
                debtFinancialWrapperList.add(finWrapper);
            }
            dtiCalcWrapper.financialDebts = debtFinancialWrapperList;
            
            List<FinancialWrapper> taxableFinancialWrapperList = new List<FinancialWrapper>();
            List<FinancialWrapper> taxableFinList = (List<FinancialWrapper>)JSON.deserialize(dtiCalcList[0].Taxable_Incomes__c, List<FinancialWrapper>.class);
            System.debug(logginglevel.error,taxableFinList);
            for(FinancialWrapper finWrp : taxableFinList) {
                FinancialWrapper finWrapper = new FinancialWrapper();
                finWrapper.financialType               = finWrp.financialType;
                finWrapper.existsForApplicant          = finWrp.existsForApplicant;
                finWrapper.existsForCoApplicant        = finWrp.existsForCoApplicant;
                finWrapper.monthlyAmountApplicant      = finWrp.monthlyAmountApplicant;
                finWrapper.monthlyAmountCoApplicant    = finWrp.monthlyAmountCoApplicant;
                finWrapper.annualAmountApplicant       = finWrp.annualAmountApplicant;
                finWrapper.annualAmountCoApplicant     = finWrp.annualAmountCoApplicant;
                finWrapper.multiplier                  = finWrp.multiplier;
                finWrapper.effectiveAmountApplicant    = finWrp.effectiveAmountApplicant;
                finWrapper.effectiveAmountCoApplicant  = finWrp.effectiveAmountCoApplicant;
                
                taxableFinancialWrapperList.add(finWrapper);
            }
            dtiCalcWrapper.financialTaxableIncomes = taxableFinancialWrapperList;
            
            List<FinancialWrapper> nonTaxableFinancialWrapperList = new List<FinancialWrapper>();
            List<FinancialWrapper> nonTaxableFinList = (List<FinancialWrapper>)JSON.deserialize(dtiCalcList[0].Non_Taxable_Incomes__c, List<FinancialWrapper>.class);
            System.debug(logginglevel.error,nonTaxableFinList);
            for(FinancialWrapper finWrp : nonTaxableFinList) {
                FinancialWrapper finWrapper = new FinancialWrapper();
                finWrapper.financialType               = finWrp.financialType;
                finWrapper.existsForApplicant          = finWrp.existsForApplicant;
                finWrapper.existsForCoApplicant        = finWrp.existsForCoApplicant;
                finWrapper.monthlyAmountApplicant      = finWrp.monthlyAmountApplicant;
                finWrapper.monthlyAmountCoApplicant    = finWrp.monthlyAmountCoApplicant;
                finWrapper.annualAmountApplicant       = finWrp.annualAmountApplicant;
                finWrapper.annualAmountCoApplicant     = finWrp.annualAmountCoApplicant;
                finWrapper.multiplier                  = finWrp.multiplier;
                finWrapper.effectiveAmountApplicant    = finWrp.effectiveAmountApplicant;
                finWrapper.effectiveAmountCoApplicant  = finWrp.effectiveAmountCoApplicant;
                
                nonTaxableFinancialWrapperList.add(finWrapper);
            }
            dtiCalcWrapper.financialNonTaxableIncomes = nonTaxableFinancialWrapperList;
            
        } else {
            System.debug(loggingLevel.ERROR, '-- Applicant Contacts : ' + contactIdSet);
            List<fsCore__Financial__c> allFinancials = DTICalculationUtil.getFinancials(contactIdSet);
            DTICalculationUtil.setFinancialsForDTICalculation(dtiCalcWrapper, allFinancials);
            DTICalculationUtil.setDebtToIncomePercentage(dtiCalcWrapper);
        }
        
        
        System.debug(loggingLevel.ERROR, JSON.serializePretty(dtiCalcWrapper));
        return dtiCalcWrapper;
    }
    
    @AuraEnabled
    public static String saveCalculation(String pDTICalcWrapperJSON){
        fsCore.ActionOutput acOutput = new fsCore.ActionOutput();
        
        Savepoint sp = Database.setSavepoint();
        try{
            System.debug(loggingLevel.ERROR, 'saving DTI calculation...');
            DTICalculatorWrapper dtiCalcWrp = (DTICalculatorWrapper)JSON.deserialize(pDTICalcWrapperJSON, DTICalculatorWrapper.class);
            
            fsCore__Lending_Application__c application = [SELECT Id, Name
                                                          , Debt_To_Income_Stated__c 
                                                          , Debt_To_Income_Verified__c 
                                                          , (SELECT Id, Name
                                                             , fsCore__Account_Name__c
                                                             , fsCore__Account_Name__r.PersonContactId
                                                             , fsCore__Is_Primary__c
                                                             , Annual_Stated_Income__c
                                                             , Annual_Verified_Income__c 
                                                             , Monthly_Stated_Debt__c 
                                                             , Monthly_Verified_Debt__c 
                                                             , Debt_To_Income_Stated__c 
                                                             , Debt_To_Income_Verified__c 
                                                             FROM fsCore__Lending_Application_Customer__r
                                                             ORDER BY Name ASC) 
                                                          FROM fsCore__Lending_Application__c
                                                          WHERE Id = :dtiCalcWrp.applicationId];
            
            if (String.IsBlank(dtiCalcWrp.source.value)){
                throw new DTICalculatorException('DTI Calculation source is blank.');
            }
            
            Map<Id, fsCore__Lending_Application_Customer__c> applicantMap = new Map<Id, fsCore__Lending_Application_Customer__c>();
            for (fsCore__Lending_Application_Customer__c applicant : application.fsCore__Lending_Application_Customer__r){
                if ((applicant.Id == dtiCalcWrp.applicantId && applicant.fsCore__Account_Name__r.PersonContactId == dtiCalcWrp.applicantContactId)
                    || (dtiCalcWrp.coApplicantId != null && applicant.Id == dtiCalcWrp.coApplicantId && applicant.fsCore__Account_Name__r.PersonContactId == dtiCalcWrp.coApplicantContactId)){
                        applicantMap.put(applicant.Id, applicant);
                    }
            }
            
            if (dtiCalcWrp.source.value == DTICalculationUtil.DTI_CALC_SOURCE_VERIFIED){
                application.Debt_To_Income_Verified__c = dtiCalcWrp.netDebtToIncome;
                
                if (applicantMap.containsKey(dtiCalcWrp.applicantId)){
                    applicantMap.get(dtiCalcWrp.applicantId).Annual_Verified_Income__c = dtiCalcWrp.applicantTotalAnnualIncome;
                    applicantMap.get(dtiCalcWrp.applicantId).Monthly_Verified_Debt__c = dtiCalcWrp.applicantTotalMonthlyDebt;
                    applicantMap.get(dtiCalcWrp.applicantId).Debt_To_Income_Verified__c = dtiCalcWrp.applicantDebtToIncome;
                }
                
                if (dtiCalcWrp.coApplicantId != null && applicantMap.containsKey(dtiCalcWrp.coApplicantId)){
                    applicantMap.get(dtiCalcWrp.coApplicantId).Annual_Verified_Income__c = dtiCalcWrp.coApplicantTotalAnnualIncome;
                    applicantMap.get(dtiCalcWrp.coApplicantId).Monthly_Verified_Debt__c = dtiCalcWrp.coApplicantTotalMonthlyDebt;
                    applicantMap.get(dtiCalcWrp.coApplicantId).Debt_To_Income_Verified__c = dtiCalcWrp.coApplicantDebtToIncome;
                }
            } 
            else {
                application.Debt_To_Income_Stated__c = dtiCalcWrp.netDebtToIncome;
                
                if (applicantMap.containsKey(dtiCalcWrp.applicantId)){
                    applicantMap.get(dtiCalcWrp.applicantId).Annual_Stated_Income__c = dtiCalcWrp.applicantTotalAnnualIncome;
                    applicantMap.get(dtiCalcWrp.applicantId).Monthly_Stated_Debt__c = dtiCalcWrp.applicantTotalMonthlyDebt;
                    applicantMap.get(dtiCalcWrp.applicantId).Debt_To_Income_Stated__c = dtiCalcWrp.applicantDebtToIncome;
                }
                
                if (dtiCalcWrp.coApplicantId != null && applicantMap.containsKey(dtiCalcWrp.coApplicantId)){
                    applicantMap.get(dtiCalcWrp.coApplicantId).Annual_Stated_Income__c = dtiCalcWrp.coApplicantTotalAnnualIncome;
                    applicantMap.get(dtiCalcWrp.coApplicantId).Monthly_Stated_Debt__c = dtiCalcWrp.coApplicantTotalMonthlyDebt;
                    applicantMap.get(dtiCalcWrp.coApplicantId).Debt_To_Income_Stated__c = dtiCalcWrp.coApplicantDebtToIncome;
                }
            }
            
            List<DTI_Calculation__c> dtiCalcForUpdate = new List<DTI_Calculation__c>();
            List<DTI_Calculation__c> dtiCalcForInsert = new List<DTI_Calculation__c>();
            List<DTI_Calculation__c> dtiCalcList = [select id, 
                                                    Lending_Application_Number__c,
                                                    Source__c,
                                                    Combined_DTI__c,
                                                    Applicant_Reference_Number__c,
                                                    Applicant_Name__c,
                                                    Applicant_Total_Annual_Income__c,
                                                    Applicant_Total_Monthly_Debt__c,
                                                    Applicant_DTI__c,
                                                    Co_Applicant_Reference_Number__c,
                                                    Co_Applicant_Name__c,
                                                    Co_Applicant_Total_Annual_Income__c,
                                                    Co_Applicant_Total_Monthly_Debt__c,
                                                    Co_Applicant_DTI__c,
                                                    Is_Most_Recent_DTI_Calculation__c,
                                                    Debts__c,
                                                    Taxable_Incomes__c,
                                                    Non_Taxable_Incomes__c
                                                    FROM DTI_Calculation__c
                                                    WHERE Lending_Application_Number__c = :dtiCalcWrp.applicationId
                                                    AND Source__c = :dtiCalcWrp.source.value
                                                    AND Is_Most_Recent_DTI_Calculation__c = true];
            
            if(dtiCalcList.size()>0) {
                
                for(DTI_Calculation__c dtiCalc:dtiCalcList){
                    
                    //dtiCalc.Lending_Application_Number__c = dtiCalcWrp.applicationId;
                    dtiCalc.Source__c = dtiCalcWrp.source.value;
                    dtiCalc.Combined_DTI__c = dtiCalcWrp.netDebtToIncome;
                    dtiCalc.Applicant_Reference_Number__c = dtiCalcWrp.applicantId;
                    dtiCalc.Applicant_Name__c = dtiCalcWrp.applicantName;
                    dtiCalc.Applicant_Total_Annual_Income__c = dtiCalcWrp.applicantTotalAnnualIncome;
                    dtiCalc.Applicant_Total_Monthly_Debt__c = dtiCalcWrp.applicantTotalMonthlyDebt;
                    dtiCalc.Applicant_DTI__c = dtiCalcWrp.applicantDebtToIncome;
                    dtiCalc.Co_Applicant_Reference_Number__c = dtiCalcWrp.coApplicantId;
                    dtiCalc.Co_Applicant_Name__c = dtiCalcWrp.coApplicantName;
                    dtiCalc.Co_Applicant_Total_Annual_Income__c = dtiCalcWrp.coApplicantTotalAnnualIncome;
                    dtiCalc.Co_Applicant_Total_Monthly_Debt__c = dtiCalcWrp.coApplicantTotalMonthlyDebt;
                    dtiCalc.Co_Applicant_DTI__c = dtiCalcWrp.coApplicantDebtToIncome;
                    dtiCalc.Is_Most_Recent_DTI_Calculation__c = true;+
                    dtiCalc.Debts__c = JSON.serialize(dtiCalcWrp.financialDebts);
                    dtiCalc.Taxable_Incomes__c = JSON.serialize(dtiCalcWrp.financialTaxableIncomes);
                    dtiCalc.Non_Taxable_Incomes__c = JSON.serialize(dtiCalcWrp.financialNonTaxableIncomes);
                    dtiCalcForUpdate.add(dtiCalc);
                    //existingDti.Is_Most_Recent_DTI_Calculation__c = false;
                }
                
            } else {
                
                DTI_Calculation__c dtiCalc = new DTI_Calculation__c();
                dtiCalc.Lending_Application_Number__c = dtiCalcWrp.applicationId;
                dtiCalc.Source__c = dtiCalcWrp.source.value;
                dtiCalc.Combined_DTI__c = dtiCalcWrp.netDebtToIncome;
                dtiCalc.Applicant_Reference_Number__c = dtiCalcWrp.applicantId;
                dtiCalc.Applicant_Name__c = dtiCalcWrp.applicantName;
                dtiCalc.Applicant_Total_Annual_Income__c = dtiCalcWrp.applicantTotalAnnualIncome;
                dtiCalc.Applicant_Total_Monthly_Debt__c = dtiCalcWrp.applicantTotalMonthlyDebt;
                dtiCalc.Applicant_DTI__c = dtiCalcWrp.applicantDebtToIncome;
                dtiCalc.Co_Applicant_Reference_Number__c = dtiCalcWrp.coApplicantId;
                dtiCalc.Co_Applicant_Name__c = dtiCalcWrp.coApplicantName;
                dtiCalc.Co_Applicant_Total_Annual_Income__c = dtiCalcWrp.coApplicantTotalAnnualIncome;
                dtiCalc.Co_Applicant_Total_Monthly_Debt__c = dtiCalcWrp.coApplicantTotalMonthlyDebt;
                dtiCalc.Co_Applicant_DTI__c = dtiCalcWrp.coApplicantDebtToIncome;
                dtiCalc.Is_Most_Recent_DTI_Calculation__c = true;
                dtiCalc.Debts__c = JSON.serialize(dtiCalcWrp.financialDebts);
                dtiCalc.Taxable_Incomes__c = JSON.serialize(dtiCalcWrp.financialTaxableIncomes);
                dtiCalc.Non_Taxable_Incomes__c = JSON.serialize(dtiCalcWrp.financialNonTaxableIncomes);
                dtiCalcForInsert.add(dtiCalc);
                
            }
            
            
            
            
            //SUP-116 
            //MARK ALL EXISTING DTI AS NOT Is_Most_Recent_DTI_Calculation__c as false
            
            
            
            //dtiCalcList.add(dtiCalc);
            
            Database.update(application);
            Database.update(applicantMap.values());
            //Database.upsert(dtiCalcList);
            if(dtiCalcForUpdate.size()>0) {
                Database.update(dtiCalcForUpdate);
            }
            if(dtiCalcForInsert.size()>0) {
                Database.insert(dtiCalcForInsert);
            }
            
            
        }
        catch (Exception e){
            acOutput.addError(e);
        }
        
        if (!acOutput.getIsSuccess()){
            Database.rollback(sp);            
        } else {
            acOutput.setMessage('Success!');
            acOutput.setMessageDetails('DTI Calculation has been saved successfully.');
        }
        
        return acOutput.getJSONString();
    }
    
    @AuraEnabled
    public static List<FinancialWrapper> getFinancialDebts(Id pDTICalcId){
        DTI_Calculation__c dtiCalc = [SELECT Id, Debts__c FROM DTI_Calculation__c WHERE Id = :pDTICalcId];
        List<FinancialWrapper> financialDebts = new List<FinancialWrapper>();
        if (String.IsNotBlank(dtiCalc.Debts__c)){
            financialDebts = (List<FinancialWrapper>) JSON.deserialize(dtiCalc.Debts__c, List<FinancialWrapper>.class);
        }
        return financialDebts;
    }
    
    @AuraEnabled
    public static List<FinancialWrapper> getFinancialTaxableIncomes(Id pDTICalcId){
        DTI_Calculation__c dtiCalc = [SELECT Id, Taxable_Incomes__c FROM DTI_Calculation__c WHERE Id = :pDTICalcId];
        List<FinancialWrapper> financialTaxableIncomes = new List<FinancialWrapper>();
        if (String.IsNotBlank(dtiCalc.Taxable_Incomes__c)){
            financialTaxableIncomes = (List<FinancialWrapper>) JSON.deserialize(dtiCalc.Taxable_Incomes__c, List<FinancialWrapper>.class);
        }
        return financialTaxableIncomes;
    }
    
    @AuraEnabled
    public static List<FinancialWrapper> getFinancialNonTaxableIncomes(Id pDTICalcId){
        DTI_Calculation__c dtiCalc = [SELECT Id, Non_Taxable_Incomes__c FROM DTI_Calculation__c WHERE Id = :pDTICalcId];
        List<FinancialWrapper> financialNonTaxableIncomes = new List<FinancialWrapper>();
        if (String.IsNotBlank(dtiCalc.Non_Taxable_Incomes__c)){
            financialNonTaxableIncomes = (List<FinancialWrapper>) JSON.deserialize(dtiCalc.Non_Taxable_Incomes__c, List<FinancialWrapper>.class);
        }
        return financialNonTaxableIncomes;
    }
    public class DTICalculatorException extends Exception{}
}