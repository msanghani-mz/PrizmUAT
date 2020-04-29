/*
 * Class   : DTICalculatorWrapper
 * Purpose : This class is used as a structure for DTI calculator component
 * Author  : Financial Spectra
 */
public class DTICalculatorWrapper {

    @AuraEnabled public Id                     applicationId                {get; set;}
    @AuraEnabled public String                 applicationNumber            {get; set;}
    @AuraEnabled public LabelValueType         source                       {get; set;}
    @AuraEnabled public List<LabelValueType>   sourceOptions                {get; set;}
    @AuraEnabled public Decimal                netDebtToIncome              {get; set;}
    
    @AuraEnabled public Id                     applicantId                  {get; set;}
    @AuraEnabled public Id                     applicantContactId           {get; set;}
    @AuraEnabled public String                 applicantName                {get; set;}
    @AuraEnabled public Boolean                applicantExists              {get; set;}
    @AuraEnabled public Decimal                applicantTotalMonthlyDebt    {get; set;}
    @AuraEnabled public Decimal                applicantTotalAnnualIncome   {get; set;}
    @AuraEnabled public Decimal                applicantDebtToIncome        {get; set;}
    
    @AuraEnabled public Id                     coApplicantId                {get; set;}
    @AuraEnabled public Id                     coApplicantContactId         {get; set;}
    @AuraEnabled public String                 coApplicantName              {get; set;}
    @AuraEnabled public Boolean                coApplicantExists            {get; set;}
    @AuraEnabled public Decimal                coApplicantTotalMonthlyDebt  {get; set;}
    @AuraEnabled public Decimal                coApplicantTotalAnnualIncome {get; set;}
    @AuraEnabled public Decimal                coApplicantDebtToIncome      {get; set;}
    
    @AuraEnabled public List<FinancialWrapper> financialDebts               {get; set;}
    @AuraEnabled public List<FinancialWrapper> financialTaxableIncomes      {get; set;}
    @AuraEnabled public List<FinancialWrapper> financialNonTaxableIncomes   {get; set;}

    public DTICalculatorWrapper(){
        applicationId = null;
        applicationNumber = fsCore.Constants.BLANK_STRING;
        source = new LabelValueType();
        sourceOptions = new List<LabelValueType>();
        netDebtToIncome = 0.00;
        
        applicantId = null;
        applicantContactId = null;
        applicantName = Label.Record_Not_Exists;
        applicantExists = false;
        applicantTotalMonthlyDebt = 0.00;
        applicantTotalAnnualIncome = 0.00;
        applicantDebtToIncome = 0.00;

        coApplicantId = null;
        coApplicantContactId = null;
        coApplicantName = Label.Record_Not_Exists;
        coApplicantExists = false;
        coApplicantTotalMonthlyDebt = 0.00;
        coApplicantTotalAnnualIncome = 0.00;
        coApplicantDebtToIncome = 0.00;

        financialDebts = new List<FinancialWrapper>();
        financialTaxableIncomes = new List<FinancialWrapper>();
        financialNonTaxableIncomes = new List<FinancialWrapper>();
    }
}