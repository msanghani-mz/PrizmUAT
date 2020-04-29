/*
 * Class Name   - FinancialWrapper
 * Description  - 
 * Developer(s) - Financial Spectra
 */
public class FinancialWrapper{

    @AuraEnabled public String  financialType              {get; set;}
    @AuraEnabled public Boolean existsForApplicant         {get; set;}
    @AuraEnabled public Boolean existsForCoApplicant       {get; set;}
    @AuraEnabled public Decimal monthlyAmountApplicant     {get; set;}
    @AuraEnabled public Decimal monthlyAmountCoApplicant   {get; set;}
    @AuraEnabled public Decimal annualAmountApplicant      {get; set;}
    @AuraEnabled public Decimal annualAmountCoApplicant    {get; set;}
    @AuraEnabled public Decimal multiplier                 {get; set;}
    @AuraEnabled public Decimal effectiveAmountApplicant   {get; set;} 
    @AuraEnabled public Decimal effectiveAmountCoApplicant {get; set;} 
    /* Note : effective amount is used for DTI calculation and is calculated as Monthly or Annual Amount x Multiplier */
    
    public FinancialWrapper(){
        financialType = fsCore.Constants.BLANK_STRING;
        existsForApplicant = false;
        existsForCoApplicant = false;
        monthlyAmountApplicant = 0.00;
        monthlyAmountCoApplicant = 0.00;
        annualAmountApplicant = 0.00;
        annualAmountCoApplicant = 0.00;
        multiplier = 1.00;
        effectiveAmountApplicant = 0.00;
        effectiveAmountCoApplicant = 0.00;
    }
}