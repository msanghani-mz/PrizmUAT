/*
 * Class Name   - LabelValueType
 * Description  - 
 * Developer(s) - Financial Spectra
 */
public class LabelValueType {

    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String value {get; set;}
        
    public LabelValueType(){
        label = null;
        value  = null;
    }

    public LabelValueType(String pLabel, String pValue){
        label = pLabel;
        value = pValue;
    }
}