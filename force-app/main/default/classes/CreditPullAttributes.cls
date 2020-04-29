/*
 * Class   : CreditPullAttributes
 * Purpose : Attributes for Credit Pull action
 * Author  : Financial Spectra
 */
public class CreditPullAttributes {
    
    @AuraEnabled public Boolean isDisplayPullTypeButton {get; set;}
    @AuraEnabled public String  defaultPullType         {get; set;}
    @AuraEnabled public Boolean isDisplayBureauOptions  {get; set;}
    @AuraEnabled public List<LabelValueType> bureaus    {get; set;}
    @AuraEnabled public String  defaultBureau           {get; set;}
    

}