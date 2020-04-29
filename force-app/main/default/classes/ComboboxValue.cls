/*
 * Class Name   - ComboboxValue
 * Description  - 
 * Developer(s) - Financial Spectra
 */
public class ComboboxValue {

    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String value {get; set;}
        
    public ComboboxValue(){
        label = null;
        value  = null;
    }

    public ComboboxValue(String pLabel, String pValue){
        label = pLabel;
        value = pValue;
    }
}