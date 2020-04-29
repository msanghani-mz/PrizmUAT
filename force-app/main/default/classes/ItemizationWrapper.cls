/*
 * Class Name   - ItemizationWrapper
 * Description  - Wrapper object for Itemization page
 * Developer(s) - Financial Spectra
 */
public class ItemizationWrapper {
    @AuraEnabled public Id      applicationId                {get; set;}
    @AuraEnabled public String  applicationNumber            {get; set;}
    @AuraEnabled public String 	applicantName                {get; set;}
    @AuraEnabled public String 	coApplicantName              {get; set;}
    @AuraEnabled public String 	portfolioType                {get; set;}
    @AuraEnabled public String 	paymentProcessor             {get; set;}
    @AuraEnabled public String 	ndsNumber                    {get; set;}
    @AuraEnabled public String 	drpNumber                    {get; set;}
    @AuraEnabled public String 	drpFileNumber                {get; set;}
    @AuraEnabled public String 	status                       {get; set;}
    @AuraEnabled public String 	applicantAccountId           {get; set;}
    @AuraEnabled public String 	coApplicantAccountId         {get; set;}
    @AuraEnabled public String  underwriter                  {get; set;}
    @AuraEnabled public String  loanOfficer                  {get; set;}
    @AuraEnabled public Id      productId                    {get; set;}
    @AuraEnabled public Id      contractTemplateId           {get; set;}
    @AuraEnabled public Decimal approvedFinancedAmount       {get; set;}
    @AuraEnabled public Decimal	approvedFinanceFee           {get; set;}
    @AuraEnabled public Decimal approvedPrepaidFee           {get; set;}
    @AuraEnabled public Decimal actualFinancedAmount         {get; set;}
    @AuraEnabled public Decimal actualFinanceFee             {get; set;}
    @AuraEnabled public Decimal actualPrepaidFee         	 {get; set;}
    @AuraEnabled public Decimal totalApprovedAmount          {get; set;}
    @AuraEnabled public Decimal totalActualAmount            {get; set;}
    @AuraEnabled public Boolean isContractTemplateApplied    {get; set;}
    @AuraEnabled public Boolean allowManualItemizations      {get; set;}
    @AuraEnabled public Boolean allowApprovedAmountEdit      {get; set;}
    @AuraEnabled public Boolean allowActualAmountEdit        {get; set;}
    @AuraEnabled public Boolean enforceCalculation           {get; set;}
    @AuraEnabled public List<String> originalCreditors       {get; set;}
    @AuraEnabled public List<String> currentCreditors        {get; set;}
    @AuraEnabled public List<ItemizationRowObject> itemizations {get; set;}
    @AuraEnabled public Boolean hasError                     {get; set;}
    @AuraEnabled public String  errorMessage                 {get; set;}
    @AuraEnabled public String  state                        {get; set;}
    
    public ItemizationWrapper(){
        applicationId = null;
        applicationNumber = fsCore.Constants.BLANK_STRING; 
        applicantName = fsCore.Constants.BLANK_STRING; 
        underwriter = fsCore.Constants.BLANK_STRING;    
        loanOfficer = fsCore.Constants.BLANK_STRING;
        productId = null;
        contractTemplateId = null;
        approvedFinancedAmount = 0.00;       
        approvedFinanceFee = 0.00;       
        approvedPrepaidFee = 0.00;         
        actualFinancedAmount = 0.00;                 
        actualFinanceFee = 0.00;              
        actualPrepaidFee = 0.00;  
        totalApprovedAmount = 0.00;
        totalActualAmount = 0.00;              
        isContractTemplateApplied = false;
        allowManualItemizations = false;
        allowApprovedAmountEdit = false;
        allowActualAmountEdit = false;
        enforceCalculation = false;
        originalCreditors = new List<String>();
        currentCreditors = new List<String>();
        itemizations = new List<ItemizationRowObject>();
        hasError = false;
        errorMessage = fsCore.Constants.BLANK_STRING;
    }
}