/*
 * Class   : DTICalculationUtil
 * Purpose : Utility class for DTI calculation
 * Author  : Financial Spectra
 */
public class DTICalculationUtil {

    public static final Decimal NON_TAXABLE_INCOME_MULTIPLIER = 1.25;
    
    public static final String  DTI_CALC_SOURCE_STATED        = 'Stated Amount';
    public static final String  DTI_CALC_SOURCE_APPROVED      = 'Approved Amount'; //PDI-449
    public static final String  DTI_CALC_SOURCE_VERIFIED      = 'Verified Amount';

    public static final String  FINANCIAL_DEBT                = 'Debt';
    public static final String  FINANCIAL_TAXABLE_INCOME      = 'Taxable Income';
    public static final String  FINANCIAL_NON_TAXABLE_INCOME  = 'Non-Taxable Income';
    
    public static List<fsCore__Financial__c> getFinancials(Set<Id> pContactIdSet){
        List<fsCore__Financial__c> financials = [SELECT Id, fsCore__Contact_Name__c
                                                      , fsCore__Financial_Family__c
                                                      , toLabel(fsCore__Financial_Type__c)
                                                      , fsCore__Monthly_Stated_Amount__c
                                                      , fsCore__Monthly_Verified_Amount__c
                                                      , DNL_Monthly_Eligible_Amount__c
                                                      , fsCore__Is_Non_Taxable__c
                                                      , Annual_Stated_Amount__c
                                                      , Annual_Verified_Amount__c
                                                      , Annual_DNL_Eligible_Amount__c
                                                   FROM fsCore__Financial__c 
                                                  WHERE fsCore__Contact_Name__c IN :pContactIdSet
                                                    AND fsCore__Is_Include_For_Ratio_Calculation__c = true
                                                    AND fsCore__Is_Active__c = true
                                                  ORDER BY fsCore__Contact_Name__c
                                                      , fsCore__Financial_Type__c
                                                      , Name
                                                      , fsCore__Is_Non_Taxable__c];
        System.debug(loggingLevel.ERROR, '-- Financials : ' + financials);
        return financials;
    }

    private static String getFinancialFamily(fsCore__Financial__c pFinancial){
        String finanicalFamily;
        if (pFinancial.fsCore__Financial_Family__c == 'Income'){
            finanicalFamily = (pFinancial.fsCore__Is_Non_Taxable__c) ? FINANCIAL_NON_TAXABLE_INCOME : FINANCIAL_TAXABLE_INCOME;
        } 
        else if (pFinancial.fsCore__Financial_Family__c == 'Liability'){
            finanicalFamily = FINANCIAL_DEBT;
        }
        return finanicalFamily;
    }
    
    private static Map<String, Set<String>> getFinancialTypesByFamily(List<fsCore__Financial__c> pFinancials){
        Map<String, Set<String>> financialTypesByFamilyMap = new Map<String, Set<String>>();
        for (fsCore__Financial__c finn : pFinancials){
            String finanicalFamily = getFinancialFamily(finn);

            if (String.IsBlank(finanicalFamily)) { continue; }
            
            Set<String> financialTypes = new Set<String>();
            
            if (financialTypesByFamilyMap.containsKey(finanicalFamily)){
                financialTypes = financialTypesByFamilyMap.get(finanicalFamily);
            }
            
            financialTypes.add(finn.fsCore__Financial_Type__c);
            financialTypesByFamilyMap.put(finanicalFamily, financialTypes);
        }        
        System.debug(loggingLevel.ERROR, '-- Financial Family to Types map : ' + financialTypesByFamilyMap);
        return financialTypesByFamilyMap;
    }
    
    private static Map<String, Map<Id, List<fsCore__Financial__c>>> getApplicantFinancialsByFamily(List<fsCore__Financial__c> pFinancials){
        Map<String, Map<Id, List<fsCore__Financial__c>>> applicantFinancialsByFamilyMap = new Map<String, Map<Id, List<fsCore__Financial__c>>>();
    
        for (fsCore__Financial__c finn : pFinancials){
            String finanicalFamily = getFinancialFamily(finn);

            if (String.IsBlank(finanicalFamily)) { continue; }
            
            Map<Id, List<fsCore__Financial__c>> financialsByContactIdMap = new Map<Id, List<fsCore__Financial__c>>();
            List<fsCore__Financial__c> applicantFinancials = new List<fsCore__Financial__c>();

            if (applicantFinancialsByFamilyMap.containsKey(finanicalFamily)){
                financialsByContactIdMap = applicantFinancialsByFamilyMap.get(finanicalFamily);
                if (financialsByContactIdMap.containsKey(finn.fsCore__Contact_Name__c)){
                    applicantFinancials = financialsByContactIdMap.get(finn.fsCore__Contact_Name__c);
                }
            }
            
            applicantFinancials.add(finn);
            financialsByContactIdMap.put(finn.fsCore__Contact_Name__c, applicantFinancials);
            applicantFinancialsByFamilyMap.put(finanicalFamily, financialsByContactIdMap);
        }
        
        System.debug(loggingLevel.ERROR, '-- Financial Family to Account financials map : ' + applicantFinancialsByFamilyMap);
        return applicantFinancialsByFamilyMap;
    }
    
    public static void setFinancialsForDTICalculation(DTICalculatorWrapper pDTICalcWrapper, List<fsCore__Financial__c> pFinancials){
        Map<String, Set<String>> financialTypesByFamilyMap = getFinancialTypesByFamily(pFinancials);
        Map<String, Map<Id, List<fsCore__Financial__c>>> applicantFinancialsByFamilyMap = getApplicantFinancialsByFamily(pFinancials);
        
        pDTICalcWrapper.financialDebts = new List<FinancialWrapper>();
        if (financialTypesByFamilyMap.containsKey(FINANCIAL_DEBT)){
            pDTICalcWrapper.financialDebts 
                = getFinancialWrapperList(pDTICalcWrapper
                                        , FINANCIAL_DEBT
                                        , financialTypesByFamilyMap.get(FINANCIAL_DEBT)
                                        , applicantFinancialsByFamilyMap.get(FINANCIAL_DEBT));
        }
        
        pDTICalcWrapper.financialTaxableIncomes = new List<FinancialWrapper>();
        if (financialTypesByFamilyMap.containsKey(FINANCIAL_TAXABLE_INCOME)){
            pDTICalcWrapper.financialTaxableIncomes 
                = getFinancialWrapperList(pDTICalcWrapper
                                        , FINANCIAL_TAXABLE_INCOME
                                        , financialTypesByFamilyMap.get(FINANCIAL_TAXABLE_INCOME)
                                        , applicantFinancialsByFamilyMap.get(FINANCIAL_TAXABLE_INCOME));
        }

        pDTICalcWrapper.financialNonTaxableIncomes = new List<FinancialWrapper>();
        if (financialTypesByFamilyMap.containsKey(FINANCIAL_NON_TAXABLE_INCOME)){
            pDTICalcWrapper.financialNonTaxableIncomes 
                = getFinancialWrapperList(pDTICalcWrapper
                                        , FINANCIAL_NON_TAXABLE_INCOME
                                        , financialTypesByFamilyMap.get(FINANCIAL_NON_TAXABLE_INCOME)
                                        , applicantFinancialsByFamilyMap.get(FINANCIAL_NON_TAXABLE_INCOME));
        }
    }
    
    private static List<FinancialWrapper> getFinancialWrapperList(DTICalculatorWrapper pDTICalcWrapper, String pFinancialFamily, Set<String> pFinancialTypes, Map<Id, List<fsCore__Financial__c>> pAccountFinancials){
        List<FinancialWrapper> financialWrapperList = new List<FinancialWrapper>();
        
        Map<String, List<fsCore__Financial__c>> applicantFinancialsByType = new Map<String, List<fsCore__Financial__c>>();
        if (pAccountFinancials.containsKey(pDTICalcWrapper.applicantContactId)){
            applicantFinancialsByType = getFinancialsByFinancialType(pAccountFinancials.get(pDTICalcWrapper.applicantContactId));
        }
        
        Map<String, List<fsCore__Financial__c>> coApplicantFinancialsByType = new Map<String, List<fsCore__Financial__c>>();
        if (pAccountFinancials.containsKey(pDTICalcWrapper.coApplicantContactId)){
            coApplicantFinancialsByType = getFinancialsByFinancialType(pAccountFinancials.get(pDTICalcWrapper.coApplicantContactId));
        }
        
        for (String financialType : pFinancialTypes){
            FinancialWrapper finnWrapper = new FinancialWrapper();
            finnWrapper.financialType = ((pFinancialFamily == FINANCIAL_DEBT) ? 'Monthly' : 'Annual') + ' ' + financialType;
            finnWrapper.multiplier = ((pFinancialFamily == FINANCIAL_NON_TAXABLE_INCOME) ? NON_TAXABLE_INCOME_MULTIPLIER : 1);
            
            if (applicantFinancialsByType.containsKey(financialType)){
                finnWrapper.existsForApplicant = true;
                finnWrapper.monthlyAmountApplicant = 0.00;
                finnWrapper.annualAmountApplicant = 0.00;

                for (fsCore__Financial__c finn : applicantFinancialsByType.get(financialType)){
                    if (pDTICalcWrapper.source.value == DTI_CALC_SOURCE_STATED){
                        finnWrapper.monthlyAmountApplicant = finnWrapper.monthlyAmountApplicant + ((finn.fsCore__Monthly_Stated_Amount__c == null) ? 0.00 : finn.fsCore__Monthly_Stated_Amount__c);
                        finnWrapper.annualAmountApplicant = finnWrapper.annualAmountApplicant + ((finn.Annual_Stated_Amount__c == null) ? 0.00 : finn.Annual_Stated_Amount__c);
                    } else if (pDTICalcWrapper.source.value == DTI_CALC_SOURCE_APPROVED){
                        finnWrapper.monthlyAmountApplicant = finnWrapper.monthlyAmountApplicant + ((finn.DNL_Monthly_Eligible_Amount__c == null) ? 0.00 : finn.DNL_Monthly_Eligible_Amount__c);
                        finnWrapper.annualAmountApplicant = finnWrapper.annualAmountApplicant + ((finn.Annual_DNL_Eligible_Amount__c == null) ? 0.00 : finn.Annual_DNL_Eligible_Amount__c);
                    } else {
                        finnWrapper.monthlyAmountApplicant = finnWrapper.monthlyAmountApplicant + ((finn.fsCore__Monthly_Verified_Amount__c == null) ? 0.00 : finn.fsCore__Monthly_Verified_Amount__c);
                        finnWrapper.annualAmountApplicant = finnWrapper.annualAmountApplicant + ((finn.Annual_Verified_Amount__c == null) ? 0.00 : finn.Annual_Verified_Amount__c);
                    }
                }
                
                finnWrapper.effectiveAmountApplicant = finnWrapper.multiplier * ((pFinancialFamily == FINANCIAL_DEBT) ? finnWrapper.monthlyAmountApplicant : finnWrapper.annualAmountApplicant);
            } 
            
            if (coApplicantFinancialsByType.containsKey(financialType)){
                finnWrapper.existsForCoApplicant = true;
                finnWrapper.monthlyAmountCoApplicant = 0.00;
                finnWrapper.annualAmountCoApplicant = 0.00;

                for (fsCore__Financial__c finn : coApplicantFinancialsByType.get(financialType)){
                    if (pDTICalcWrapper.source.value == DTI_CALC_SOURCE_STATED){
                        finnWrapper.monthlyAmountCoApplicant = finnWrapper.monthlyAmountCoApplicant + ((finn.fsCore__Monthly_Stated_Amount__c == null) ? 0.00 : finn.fsCore__Monthly_Stated_Amount__c);
                        finnWrapper.annualAmountCoApplicant = finnWrapper.annualAmountCoApplicant + ((finn.Annual_Stated_Amount__c == null) ? 0.00 : finn.Annual_Stated_Amount__c);
                    } else if (pDTICalcWrapper.source.value == DTI_CALC_SOURCE_APPROVED){
                        finnWrapper.monthlyAmountCoApplicant = finnWrapper.monthlyAmountCoApplicant + ((finn.DNL_Monthly_Eligible_Amount__c == null) ? 0.00 : finn.DNL_Monthly_Eligible_Amount__c);
                        finnWrapper.annualAmountCoApplicant = finnWrapper.annualAmountCoApplicant + ((finn.Annual_DNL_Eligible_Amount__c == null) ? 0.00 : finn.Annual_DNL_Eligible_Amount__c);
                    } else {
                        finnWrapper.monthlyAmountCoApplicant = finnWrapper.monthlyAmountCoApplicant + ((finn.fsCore__Monthly_Verified_Amount__c == null) ? 0.00 : finn.fsCore__Monthly_Verified_Amount__c);
                        finnWrapper.annualAmountCoApplicant = finnWrapper.annualAmountCoApplicant + ((finn.Annual_Verified_Amount__c == null) ? 0.00 : finn.Annual_Verified_Amount__c);
                    }
                }
                
                finnWrapper.effectiveAmountCoApplicant = finnWrapper.multiplier * ((pFinancialFamily == FINANCIAL_DEBT) ? finnWrapper.monthlyAmountCoApplicant : finnWrapper.annualAmountCoApplicant);
            } 
            System.debug(loggingLevel.ERROR, '-- Financial Wrapper : ' + finnWrapper);
            financialWrapperList.add(finnWrapper);
        }
        
        return financialWrapperList;
    }

    private static Map<String, List<fsCore__Financial__c>> getFinancialsByFinancialType(List<fsCore__Financial__c> pFinancials){
        Map<String, List<fsCore__Financial__c>> financialsByTypeMap = new Map<String, List<fsCore__Financial__c>>();

        for (fsCore__Financial__c finn : pFinancials){
            List<fsCore__Financial__c> financialsByType = new List<fsCore__Financial__c>();
            if (financialsByTypeMap.containsKey(finn.fsCore__Financial_Type__c)){
                financialsByType = financialsByTypeMap.get(finn.fsCore__Financial_Type__c);
            }
            financialsByType.add(finn);
            financialsByTypeMap.put(finn.fsCore__Financial_Type__c, financialsByType);
        }
        
        return financialsByTypeMap;
    }

    public static void setDebtToIncomePercentage(DTICalculatorWrapper pDTICalcWrapper){
        pDTICalcWrapper.applicantTotalMonthlyDebt = 0.00;
        pDTICalcWrapper.coApplicantTotalMonthlyDebt = 0.00;
        
        for (FinancialWrapper finnWrapper : pDTICalcWrapper.financialDebts){
            pDTICalcWrapper.applicantTotalMonthlyDebt += finnWrapper.effectiveAmountApplicant;
            pDTICalcWrapper.coApplicantTotalMonthlyDebt += finnWrapper.effectiveAmountCoApplicant;
        }
        
        pDTICalcWrapper.applicantTotalAnnualIncome = 0.00;
        pDTICalcWrapper.coApplicantTotalAnnualIncome = 0.00;

        for (FinancialWrapper finnWrapper : pDTICalcWrapper.financialTaxableIncomes){
            pDTICalcWrapper.applicantTotalAnnualIncome += finnWrapper.effectiveAmountApplicant;
            pDTICalcWrapper.coApplicantTotalAnnualIncome += finnWrapper.effectiveAmountCoApplicant;
        }
        for (FinancialWrapper finnWrapper : pDTICalcWrapper.financialNonTaxableIncomes){
            pDTICalcWrapper.applicantTotalAnnualIncome += finnWrapper.effectiveAmountApplicant;
            pDTICalcWrapper.coApplicantTotalAnnualIncome += finnWrapper.effectiveAmountCoApplicant;
        }
        
        pDTICalcWrapper.applicantDebtToIncome = 0.00;
        pDTICalcWrapper.coApplicantDebtToIncome = 0.00;
        
        if (pDTICalcWrapper.applicantTotalAnnualIncome > 0){
            pDTICalcWrapper.applicantDebtToIncome = ((pDTICalcWrapper.applicantTotalMonthlyDebt * 12 * 100) / pDTICalcWrapper.applicantTotalAnnualIncome).setScale(2);
        }
        if (pDTICalcWrapper.coApplicantTotalAnnualIncome > 0){
            pDTICalcWrapper.coApplicantDebtToIncome = ((pDTICalcWrapper.coApplicantTotalMonthlyDebt * 12 * 100) / pDTICalcWrapper.coApplicantTotalAnnualIncome).setScale(2);
        }
        
        Decimal totalMonthlyDebt = pDTICalcWrapper.applicantTotalMonthlyDebt + pDTICalcWrapper.coApplicantTotalMonthlyDebt;
        Decimal totalAnnualIncome = pDTICalcWrapper.applicantTotalAnnualIncome + pDTICalcWrapper.coApplicantTotalAnnualIncome;
        
        pDTICalcWrapper.netDebtToIncome = 0.00;
        if (totalAnnualIncome > 0){
            pDTICalcWrapper.netDebtToIncome = ((totalMonthlyDebt * 12 * 100) / totalAnnualIncome).setScale(2);
        }
    }
}