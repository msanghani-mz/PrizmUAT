/**
* @File Name          : SendToDocuSignController.cls
* @Description        : 
* @Author             : FinancialSpectra
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 11/29/2019, 9:26:26 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    6/26/2019, 6:46:40 PM   PDI-744     Initial Version
* 1.1    7/09/2019, 6:46:40 PM   PDI-758 
**/
public class DocusignAPIUtil {

    public static String mDocumentTypeDraftIncreaseATD = 'Draft Increase ATD';
    public static String mDocumentTypeBankAccountChange = 'Bank Account Change';
    public static String mDocumentTypeOppLoanApplication = 'Opportunity Loan Application';
    public static String mDocumentTypePreTila = 'Pre-Tila';
    public static string mDocusignEnvelopeCompleted = 'Completed';
    public static string mDocusignEnvelopeDeclined = 'Declined';
    public static string mDocusignEnvelopeSent = 'Sent';
    

    
    public static DocuSignAPI.APIServiceSoap getSOAPAuthenticationHeader(){
        DocuSignAPI.APIServiceSoap dsApiSend
            = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = SFS_System_Settings__c.getInstance().Docusign_SOAP_EndPoint__c;
        
        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ SFS_System_Settings__c.getInstance().Docusign_User_Id__c
            +'</Username><Password>' + SFS_System_Settings__c.getInstance().Docusign_Password__c
            + '</Password><IntegratorKey>' + SFS_System_Settings__c.getInstance().Docusign_Integrator_Key__c
            + '</IntegratorKey></DocuSignCredentials>';
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',
                                         auth);    
        
        return dsApiSend;
        
    }
    public static DocuSignAPI.VoidEnvelopeStatus voidEnvelope(String pEnvelopeID){

              String voidReason = '';
              if (SFS_System_Settings__c.getInstance().Default_Void_Envelope_Reason__c != null){
                  voidReason = SFS_System_Settings__c.getInstance().Default_Void_Envelope_Reason__c;
              }
              DocuSignAPI.VoidEnvelopeStatus vEnvelopeStatus
              = DocusignAPIUtil.getSOAPAuthenticationHeader().VoidEnvelope(pEnvelopeID, voidReason);

        return vEnvelopeStatus;
    }
    public static DocuSignAPI.VoidEnvelopeStatus voidEnvelope(String pEnvelopeID, String pVoidReason){

              DocuSignAPI.VoidEnvelopeStatus vEnvelopeStatus
              = DocusignAPIUtil.getSOAPAuthenticationHeader().VoidEnvelope(pEnvelopeID, pVoidReason);

        return vEnvelopeStatus;
    }    
    
}