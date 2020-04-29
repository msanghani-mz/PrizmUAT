public class ClientPortal_VCLDocusignServiceClass {
    
    public static String getSignerURL(String userEmail , String userName , 
                                      String returnURL, String userId, 
                                      String emailMessage, Blob fileSTRValue, 
                                      String atdFileName , String sourceId) 
    {
        String signerUrl = '' ;
        try{
            System.debug('@@Service userEmail ' + userEmail);
            System.debug('@@Service userName ' + userName);
            System.debug('@@Service returnURL ' + returnURL);
            System.debug('@@Service userId ' + userId);
            System.debug('@@Service emailMessage ' + emailMessage);
            System.debug('@@Service fileSTRValue ' + fileSTRValue);
            System.debug('@@Service atdFileName ' + atdFileName);
            System.debug('@@Service sourceId ' + sourceId);
            
            ClientPortal_DocuSign docusignClass = new ClientPortal_DocuSign() ;
            docusignClass.signer_email = userEmail ;
            docusignClass.signer_name = userName ;
            docusignClass.signer_user_id = userId ;
            docusignClass.email_message = emailMessage ;
            docusignClass.fileBlobValue = fileSTRValue ;
            docusignClass.fileNameStr = atdFileName ;
            docusignClass.signer_return_url = returnURL ;
            
            docusignClass.send() ;
            
            ClientPortal_VCLHomeCntrl.storeEnvelopeIdonBank( sourceId , String.valueOf(docusignClass.envelope_id)) ;
            signerUrl = docusignClass.signer_view_url ;
            System.debug('@@signerUrl ' + signerUrl);
        } catch(Exception ex) {
            System.debug('@@Docusign Error: ' + ex.getMessage());
            System.debug('@@Docusign Error: ' + ex.getStackTraceString());
        }
        return signerUrl;
    }
    
}