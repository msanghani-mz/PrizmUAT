public class ClientPortal_DocuSign {
    // Embedded signing of an envelope
    // Copyright (c) 2016 DocuSign, Inc. 
    // LICENSE: The MIT License, see https://opensource.org/licenses/MIT
    
    // SETTINGS
    Private static string integration_key = '' ;
    Private static string account_id =  '' ;
    
    Public string signer_email {get;set;}   // Required
    Public string signer_name {get;set;}    // Required
    Public string email_message {get;set;}  // Required
    Public string signer_user_id {get;set;}    // Required for embedded signing
    Public string signer_return_url {get;set;} // Required. Where DS redirects to after the signing ceremony  
    
    Public string envelope_id {get;set;}
    Public string signer_view_url {get;set;} // Redirect to this url  
    Public string error_code {get;set;} // Null means no error
    Public string error_message {get;set;}
    
    Private static string ds_server = '' ;
    
    Private static string trace_value = 'SFDC_002_SOAP_embedded_signing'; // Used for tracing API calls
    Private static string trace_key = 'X-ray';
    Private DocuSignAPI.APIServiceSoap api_sender = new DocuSignAPI.APIServiceSoap();
    
    Public Blob fileBlobValue ;
    Public String fileNameStr ;
    
    Public ClientPortal_DocuSign(){}
    
    Public void send(){
        Client_Portal_Docusign_Setting__c docusignSetting = Client_Portal_Docusign_Setting__c.getOrgDefaults();
        integration_key = docusignSetting.Integration_Key__c ;
        account_id = docusignSetting.Account_Id__c ;
        ds_server = docusignSetting.Docusign_Server_Name__c ;
        
        configure_sender();
        send_envelope();
        embedded_signing();
    }
    
    Private void configure_sender(){
        Client_Portal_Docusign_Setting__c docusignSetting = Client_Portal_Docusign_Setting__c.getOrgDefaults();
        String username = docusignSetting.Docusign_Username__c ;
        String password = docusignSetting.Docusign_Password__c ;
        
        api_sender.endpoint_x = ds_server;
        api_sender.inputHttpHeaders_x = new Map<String, String>();
        
        
        String auth =   '<DocuSignCredentials><Username>' + username + '</Username>' 
            + '<Password>' + password + '</Password>' 
            + '<IntegratorKey>' + integration_key + '</IntegratorKey></DocuSignCredentials>';
        System.debug('@@Auth ' + auth);
        api_sender.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        api_sender.inputHttpHeaders_x.put(trace_key, trace_value);
        System.debug('@@api_sender.inputHttpHeaders_x ' + api_sender.inputHttpHeaders_x);
    }
    
    @TestVisible
    Private void embedded_signing() {
        // Obtains the embedded Signing Ceremony URL for an envelope's recipient (the signer).
        // To use embedded signing:
        // 1. The signer must have been added to the envelope as a "captive signer"
        // 2. You need the following values:
        //    1. EnvelopeID
        //    2. Signer's Email that was provided when the signer was added to the envelope.
        //    3. Signer's name (UserName field)
        //    4. The Signer's User ID (client id) within your app. Must uniquely identify the signer. 
        // 3. You also need to create an "Assertion" object where you provide information on how
        //    your app authenticated the signer. This information is stored by DocuSign so you can
        //    later use the data in case of a dispute.
        
        // Incoming variables used:
        // envelope_id, signer_user_id, signer_email, signer_name
        
        // Maintaining state: when DocuSign redirects back to your app after the signing ceremony
        // ended, how does your app know what is going on? You can include additional query parameters
        // in the signer_return_url that you supply. Eg the recipient ID, envelope ID, etc.
        // You can include your app's sessionID. You can use the cookie system to store either
        // specific information or your stack's session id for your app.
        
        // Step 1. Create the assertion
        DocuSignAPI.RequestRecipientTokenAuthenticationAssertion assertion = 
            new DocuSignAPI.RequestRecipientTokenAuthenticationAssertion();
        assertion.AssertionID = '1'; // A unique identifier of the authentication 
        
        assertion.AuthenticationInstant = Datetime.now();
        assertion.AuthenticationMethod = 'Password';      
        
        assertion.SecurityDomain = 'DS_Recipe_Signer_View_Controller'; 
        
        DocuSignAPI.RequestRecipientTokenClientURLs urls = new DocuSignAPI.RequestRecipientTokenClientURLs();
        String return_url_base = signer_return_url;
        
        If (return_url_base.contains('?')) {
            return_url_base += '&event=';
        } else {
            return_url_base += '/s/?event=';
        }
        
        urls.OnSigningComplete  = return_url_base + 'signing_complete';
        urls.OnViewingComplete  = return_url_base + 'viewing_complete';
        urls.OnCancel           = return_url_base + 'cancel';
        urls.OnDecline          = return_url_base + 'decline';
        urls.OnSessionTimeout   = return_url_base + 'session_timeout';
        urls.OnTTLExpired       = return_url_base + 'ttl_expired';
        urls.OnException        = return_url_base + 'exception';
        urls.OnAccessCodeFailed = return_url_base + 'failed_access_code';
        urls.OnIdCheckFailed    = return_url_base + 'failed_id_check';
        urls.OnFaxPending       = return_url_base + 'fax_pending';
        
        System.debug('@@envelope_id ' + envelope_id);
        System.debug('@@signer_user_id ' + signer_user_id);
        System.debug('@@signer_name ' + signer_name);
        System.debug('@@signer_email ' + signer_email);
        System.debug('@@assertion ' + assertion);
        System.debug('@@urls ' + urls);
        
        // Step 3. Make the call
        try {
            signer_view_url = api_sender.RequestRecipientToken(
                envelope_id, signer_user_id, signer_name, signer_email, assertion, urls);
            
        } catch ( CalloutException e) {
            System.debug('Exception - ' + e );
            System.debug('Exception Stack - ' + e.getStackTraceString() );
            error_code = 'Problem: ' + e;
            error_message = error_code;
        }      
    }
    
    
    Private void send_envelope() {
        // Sends an envelope. The first signer is "captive," so he can sign embedded
        
        // Check input
        if (String.isBlank(signer_email) || String.isBlank(signer_name) || !signer_email.contains('@')) {
            error_message = 'Please fill in the email and name fields';
            error_code = 'INPUT_PROBLEM';
            return;
        }
        
        String file_contents = '<html><h1>Bank ATD Document</h1>' + fileBlobValue.toString() 
            + '<p>&nbsp;</p>' 
            + '<p>Signature: <span style="color:white;">signer1sig</span></p>' 
            + '<p>Date: <span style="color:white;">signer1date</span></p></html>';
        System.debug('@@fileNameStr ' +  fileNameStr) ;
        System.debug('@@file_contents ' + file_contents) ;
        System.debug('@@signer_email ' + signer_email) ;
        System.debug('@@signer_name ' + signer_name) ;
        System.debug('@@signer_user_id ' + signer_user_id) ;
        try {
            DocuSignAPI.Document document = new DocuSignAPI.Document();
            document.ID = 1;
            document.Name = fileNameStr ;
            document.FileExtension = 'html';
            
            document.pdfBytes = EncodingUtil.base64Encode(Blob.valueOf(file_contents));
            
            DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
            recipient.Email = signer_email; 
            
            recipient.UserName = signer_name;
            recipient.ID = 1;
            recipient.Type_x = 'Signer';
            recipient.RoutingOrder = 1;
            // We want this signer to be "captive" so we can use embedded signing with him
            recipient.CaptiveInfo = new DocuSignAPI.RecipientCaptiveInfo();
            recipient.CaptiveInfo.ClientUserID = signer_user_id; // Must uniquely identify the recipient within your app 
            // The signer tab...
            DocuSignAPI.Tab signHereTab = new DocuSignAPI.Tab();
            signHereTab.Type_x = 'SignHere';
            signHereTab.AnchorTabItem = new DocuSignAPI.AnchorTab();
            signHereTab.AnchorTabItem.AnchorTabString = 'signer1sig'; // Anchored for doc 1
            signHereTab.AnchorTabItem.XOffset = 8;
            signHereTab.RecipientID = 1;
            signHereTab.Name = 'Please sign here';
            signHereTab.ScaleValue = 1;
            signHereTab.TabLabel = 'signer1sig';
            
            // The dateSigned tab
            DocuSignAPI.Tab dateSignedTab = new DocuSignAPI.Tab();
            dateSignedTab.Type_x = 'DateSigned';
            dateSignedTab.AnchorTabItem = new DocuSignAPI.AnchorTab();
            dateSignedTab.AnchorTabItem.AnchorTabString = 'signer1date'; // Anchored for doc 1
            dateSignedTab.AnchorTabItem.YOffset = -6;
            dateSignedTab.FontSize = 'Size12';
            dateSignedTab.RecipientID = 1;
            dateSignedTab.Name = 'Date Signed';
            dateSignedTab.TabLabel = 'date_signed';
            
            // Create an envelope and fill it in
            DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
            envelope.Subject = 'Please sign the Bank ATD Form'; // Make the subject specific to the request
            
            envelope.AccountId  = account_id; 
            envelope.Tabs = new DocuSignAPI.ArrayOfTab();
            envelope.Tabs.Tab = new DocuSignAPI.Tab[2];      
            envelope.Tabs.Tab.add(signHereTab);
            envelope.Tabs.Tab.add(dateSignedTab);
            envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
            envelope.Recipients.Recipient = new DocuSignAPI.Recipient[1];
            envelope.Recipients.Recipient.add(recipient);
            envelope.Documents = new DocuSignAPI.ArrayOfDocument();
            envelope.Documents.Document = new DocuSignAPI.Document[1];
            envelope.Documents.Document.add(document);
            if (String.isNotBlank(email_message)) {
                envelope.EmailBlurb = email_message;
            }
            System.debug('@@before making a call: ');
            // Make the call
            
            DocuSignAPI.EnvelopeStatus result = api_sender.CreateAndSendEnvelope(envelope);
            envelope_id = result.EnvelopeID;
            System.debug('@@envelope_id: ' + envelope_id);
        } catch ( CalloutException e) {
            System.debug('@@Exception Message - ' + e.getMessage() );
            System.debug('@@Exception stack trace- ' + e.getStackTraceString() );
            error_code = 'Problem: ' + e;
            error_message = error_code;
        }      
    }
    
}