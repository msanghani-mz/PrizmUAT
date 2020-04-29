public class Demo2Controller {

    @AuraEnabled
    public static dsfs__DocuSign_Status__c getRecord(Id docuSignStatusid)
    {
        dsfs__DocuSign_Status__c doc = [Select id, dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c where id =:docuSignStatusid];
        return doc;
    }
                                                         
    @AuraEnabled
    public static dsfs__DocuSign_Status__c updateRecordWithComment(id docSignId, String reason)
    {
        dsfs__DocuSign_Status__c doc = [Select id, dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c where id =:docSignId];
        doc.dsfs__Voided_Reason__c = reason;
        update doc;
        return doc;
    } 
    
    
    @AuraEnabled
    public static String voidEnvelopeWithReason(Id pDocSignStatusId, String voidedReason){
          fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
          actionOP.setIsSuccess(false);
          DocuSignAPI.VoidEnvelopeStatus vEnvelopeStatus;
          dsfs__DocuSign_Status__c doc =  [Select id , dsfs__DocuSign_Envelope_ID__c from dsfs__DocuSign_Status__c where id = :pDocSignStatusId];
          String s = doc.dsfs__DocuSign_Envelope_ID__c;
          try
          {
              if(voidedReason == null)
              {
                  vEnvelopeStatus = DocusignAPIUtil.VoidEnvelope(s);
                  
              }
              else
              {
                  vEnvelopeStatus = DocusignAPIUtil.VoidEnvelope(s,voidedReason);
              }
              system.debug(logginglevel.error,'vEnvelopeStatus.VoidSuccess :'+vEnvelopeStatus.VoidSuccess);  
                
              if (vEnvelopeStatus.VoidSuccess){
                actionOP.setIsSuccess(true);
                actionOP.setMessage('Envelope has been voided successfully!');
              }
          }catch(Exception e)
          {
              actionOP.addError(e.getMessage());
          }
        return actionOP.getJSONString();
            
    }
    
    @AuraEnabled
    public static String getEnvelopeStatus(Id docSignId)
    {
        dsfs__DocuSign_Status__c doc = [Select dsfs__Envelope_Status__c, id from dsfs__DocuSign_Status__c where id =:docSignId];
        String status = doc.dsfs__Envelope_Status__c;
        
        return status;
    }
    
    
    @AuraEnabled
    public static String voidEnvelope(Id pDocSignStatusId){
          fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
          actionOP.setIsSuccess(false);
          DocuSignAPI.VoidEnvelopeStatus vEnvelopeStatus;
          dsfs__DocuSign_Status__c doc =  [Select id , dsfs__DocuSign_Envelope_ID__c from dsfs__DocuSign_Status__c where id = :pDocSignStatusId];
          String s = doc.dsfs__DocuSign_Envelope_ID__c;
          try
          {
              vEnvelopeStatus = DocusignAPIUtil.VoidEnvelope(s);
              system.debug(logginglevel.error,'vEnvelopeStatus.VoidSuccess :'+vEnvelopeStatus.VoidSuccess);  
                
              if (vEnvelopeStatus.VoidSuccess){
                actionOP.setIsSuccess(true);
                actionOP.setMessage('Envelope has been voided successfully!');
              }
          }catch(Exception e)
          {
              actionOP.addError(e.getMessage());
          }
        return actionOP.getJSONString();
            
    }
    
    /*
     <div aura:id="waitSpinner" role="status" class="slds-spinner slds-spinner_brand slds-spinner_medium">
        <span class="slds-assistive-text">{!$Label.fsCore.Please_Wait_Message}</span>
        <div class="slds-spinner__dot-a"></div>
        <div class="slds-spinner__dot-b"></div>
    </div>*/
                                                  
                                                  
}