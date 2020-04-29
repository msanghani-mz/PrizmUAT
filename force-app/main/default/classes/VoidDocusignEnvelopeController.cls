/**
 * @File Name          : VoidDocusignEnvelopeController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/24/2020, 3:20:53 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/28/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class VoidDocusignEnvelopeController {
    
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
}