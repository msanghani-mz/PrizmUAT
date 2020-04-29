public with sharing class DNLDocuSignEnvelopeStatusMailer {
    
    @InvocableMethod(label='sendStatusEmailUpdate')
    public static void sendStatusEmailUpdate(List<Id> DocuSignStatusIds) {
        Id dNLStatusRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DNL Sales').getRecordTypeId();
        List<dsfs__DocuSign_Status__c> DocuSignList =[select id,dsfs__Opportunity__c,dsfs__Opportunity__r.OwnerId,
                                                      Opportunity_Owner_Email__c,dsfs__Envelope_Status__c,Opportunity_Name_Formula__c,Lending_Application_Name__c 
                                                      from dsfs__DocuSign_Status__c
                                                      where Id in :DocuSignStatusIds
                                                      and dsfs__Opportunity__c != null 
                                                      and dsfs__Opportunity__r.RecordTypeId =: dNLStatusRecordTypeId                
                                                      and dsfs__Envelope_Status__c != null];
        
        System.debug('List Size' + DocuSignList );
        for( dsfs__DocuSign_Status__c DocuSignStatus : DocuSignList )
        {
            // Now create a new single email message object
            // that will send out a single email to the addresses in the To list.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<string>();
            toAddresses.add(DocuSignStatus.Opportunity_Owner_Email__c);
            mail.setToAddresses(toAddresses); 
            mail.setSenderDisplayName('Client Lending Application');
            // Specify the subject line for your email address.
            mail.setSubject('Lending Application for '+DocuSignStatus.Opportunity_Name_Formula__c+' has been returned');
            // Specify the text content of the email.
            mail.setPlainTextBody('Lending Application: ' + DocuSignStatus.Lending_Application_Name__c +' has been returned with Status'+ DocuSignStatus.dsfs__Envelope_Status__c);
            mail.setHtmlBody('Lending Application: <b>' + DocuSignStatus.Lending_Application_Name__c +' </b>has been returned with Status: <b> ' + DocuSignStatus.dsfs__Envelope_Status__c +' </b><p>'+
                             'To view your case <a href=https://yourInstance.salesforce.com/'+case.Id+'>click here.</a>');
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}