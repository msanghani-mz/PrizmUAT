/*
 * Class Name   - ReasonLookupValue
 * Description  - 
 * Developer(s) - Financial Spectra
 */
public class ReasonLookupValue {

    @AuraEnabled public String  code       {get; set;}
    @AuraEnabled public String  label      {get; set;}
    @AuraEnabled public Boolean isSelected {get; set;}
        
    public ReasonLookupValue(){
        code  = null;
        label = null;
        isSelected = false;
    }
}