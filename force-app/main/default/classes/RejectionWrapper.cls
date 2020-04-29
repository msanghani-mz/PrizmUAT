/*
 * Class Name   - RejectionWrapper
 * Description  - 
 * Developer(s) - Financial Spectra
 */
public class RejectionWrapper {

    @AuraEnabled public LabelValueType rejectionCause {get; set;}
    @AuraEnabled public List<String> rejectionCauses {get; set;}
    @AuraEnabled public List<LabelValueType> rejectionCauseValueSet {get; set;}

    @AuraEnabled public LabelValueType comments {get; set;}
    
    @AuraEnabled public Boolean hasInternalReasons {get; set;}
    @AuraEnabled public String internalReasonsLabel {get; set;}
    @AuraEnabled public List<String> internalReasonCodes {get; set;}
    @AuraEnabled public List<LabelValueType> internalReasonValueSet {get; set;}
    
    @AuraEnabled public Boolean hasExternalReasons {get; set;}
    @AuraEnabled public String externalReasonsLabel {get; set;}
    @AuraEnabled public List<String> externalReasonCodes {get; set;}
    @AuraEnabled public List<LabelValueType> externalReasonValueSet {get; set;}
    
    @AuraEnabled public Boolean isShowCreditBureau {get; set;}
    @AuraEnabled public LabelValueType creditBureau {get; set;}
    @AuraEnabled public List<LabelValueType> creditBureauValueSet {get; set;}
    
    public RejectionWrapper(){
        rejectionCause = new LabelValueType();
        rejectionCauses = new List<String>();
        rejectionCauseValueSet = new List<LabelValueType>();

        comments = new LabelValueType();

        hasInternalReasons = false;
        internalReasonsLabel = null;
        internalReasonCodes = new List<String>();
        internalReasonValueSet = new List<LabelValueType>();

        hasExternalReasons = false;
        externalReasonsLabel = null;
        externalReasonCodes = new List<String>();
        externalReasonValueSet = new List<LabelValueType>();
        
        isShowCreditBureau = false;
        creditBureau = new LabelValueType();
        creditBureauValueSet = new List<LabelValueType>();
    }
    
}