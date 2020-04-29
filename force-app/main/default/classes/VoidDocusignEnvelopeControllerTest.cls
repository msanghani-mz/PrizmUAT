@isTest
public class VoidDocusignEnvelopeControllerTest {
    
    @isTest static void testVoidDocusignEnvelopeControllerStatusVoided()
    {
        dsfs__DocuSign_Status__c doc1 = new dsfs__DocuSign_Status__c();
        doc1.dsfs__DocuSign_Envelope_ID__c='8G846007-7E2F-494B-8A48-7E805D9A660D';
        doc1.dsfs__Envelope_Status__c='Voided';
        insert doc1;
        VoidDocusignEnvelopeController.voidEnvelope(doc1.Id);
        
        
        
        
    }
    
    @isTest static void testVoidDocusignEnvelopeControllerStatusSent()
    {
        dsfs__DocuSign_Status__c doc2 = new dsfs__DocuSign_Status__c();
        doc2.dsfs__DocuSign_Envelope_ID__c='7C746007-7E2F-494B-8A48-7E805D9A660D';
        doc2.dsfs__Envelope_Status__c='Sent';
        insert doc2;
        VoidDocusignEnvelopeController.voidEnvelope(doc2.Id);
    }
}