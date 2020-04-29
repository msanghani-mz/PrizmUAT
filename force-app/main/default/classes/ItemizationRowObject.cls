/*
 * Class Name   - ItemizationRowObject
 * Description  - Structure for Itemization row
 * Developer(s) - Financial Spectra
 */
public class ItemizationRowObject implements Comparable{
    @AuraEnabled public Boolean isNew                          {get; set;}
    @AuraEnabled public Boolean isDisplayCreditor              {get; set;}
    @AuraEnabled public Integer rowNumber                      {get; set;}
    @AuraEnabled public Id      itemizationId                  {get; set;}
    @AuraEnabled public Id      applicationId                  {get; set;}
    @AuraEnabled public Id      appItemizationId               {get; set;}
    @AuraEnabled public String  itemizationName                {get; set;}
    @AuraEnabled public String  itemizationCode                {get; set;}
    @AuraEnabled public String  itemizationFamily              {get; set;}
    @AuraEnabled public String  itemizationSource              {get; set;}
    @AuraEnabled public String  prodOrCTItemizationId          {get; set;}
    @AuraEnabled public String  plusMinus                      {get; set;}
    @AuraEnabled public String  originalCreditorName           {get; set;}
    @AuraEnabled public Decimal enrolledBalance                {get; set;}
    @AuraEnabled public String  currentCreditorName            {get; set;}
    @AuraEnabled public Decimal currentBalance                 {get; set;}
    @AuraEnabled public String  tradelineStatus                {get; set;}
    @AuraEnabled public String  litigationStatus               {get; set;}
    @AuraEnabled public Decimal estimatePercentage             {get; set;}
    @AuraEnabled public Decimal estimateAmount                 {get; set;}
    @AuraEnabled public String  notes                          {get; set;}
    @AuraEnabled public Decimal actualPercentage               {get; set;} 
    @AuraEnabled public Decimal actualAmount                   {get; set;}
    @AuraEnabled public Date    settledDate                    {get; set;} 
    @AuraEnabled public Boolean isFeeItemization               {get; set;}
    @AuraEnabled public String  feeId                          {get; set;}
    @AuraEnabled public String  feeCategory                    {get; set;}
    @AuraEnabled public Decimal calculatedAmount               {get; set;}
    @AuraEnabled public Boolean isCalculated                   {get; set;}
    @AuraEnabled public Boolean allowFeeOverride               {get; set;}
    @AuraEnabled public String  allowDisbursement              {get; set;}
    @AuraEnabled public List<String> creditNameList            {get; set;}
    @AuraEnabled public List<C_LabelValue> itemizationList     {get; set;}
    @AuraEnabled public List<C_LabelValue> feeList             {get; set;}
    @AuraEnabled public String translatedLitStatus             {get; set;}
    
    public class C_LabelValue{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        
        public C_LabelValue(String pLabel, String pValue){
            label = pLabel;
            value = pValue;
        }
    }
    
    public ItemizationRowObject(){
        isNew = true;
        isDisplayCreditor = false;
        rowNumber = 0;
        itemizationId = null;
        applicationId = null;
        appItemizationId = null;
        itemizationName = fsCore.Constants.BLANK_STRING;
        itemizationCode = fsCore.Constants.BLANK_STRING;
        itemizationFamily = fsCore.Constants.BLANK_STRING;
        itemizationSource = fsCore.Constants.BLANK_STRING;
        prodOrCTItemizationId = fsCore.Constants.BLANK_STRING;
        plusMinus = fsCore.Constants.BLANK_STRING; 
        originalCreditorName = fsCore.Constants.BLANK_STRING;    
        enrolledBalance = null;       
        currentCreditorName = fsCore.Constants.BLANK_STRING;   
        currentBalance = 0.00;       
        tradelineStatus = fsCore.Constants.BLANK_STRING;         
        litigationStatus = fsCore.Constants.BLANK_STRING;                 
        estimatePercentage = 0.00;              
        estimateAmount = 0.00;  
        actualPercentage = 0.00;  
        actualAmount = 0.00;              
        settledDate = null;
        notes = fsCore.Constants.BLANK_STRING;
        creditNameList = new List<String>();
        itemizationList = new List<C_LabelValue>();
        feeId = fsCore.Constants.BLANK_STRING;
        feeCategory = fsCore.Constants.BLANK_STRING;
        feeList = new List<C_LabelValue>();
        allowFeeOverride = false;
        isFeeItemization = false;
        calculatedAmount = 0.00;
        isCalculated = false;
        allowDisbursement = fsCore.Constants.BLANK_STRING;
    }

    public Integer compareTo(Object compareTo) {
        ItemizationRowObject compareToObj = (ItemizationRowObject) compareTo;
        if (settledDate == compareToObj.settledDate) return 0;
        if (settledDate > compareToObj.settledDate) return 1;
        return -1;        
    }

}