@isTest
public class Demo2ControllerTest {
    
    @isTest
    public static void test(){ 
        
        
        dsfs__DocuSign_Status__c doc1 = new dsfs__DocuSign_Status__c();
        doc1.dsfs__DocuSign_Envelope_ID__c='8G846007-7E2F-494B-8A48-7E805D9A660D';
        doc1.dsfs__Envelope_Status__c='Voided';
        insert doc1;
        
        dsfs__DocuSign_Status__c doc = Demo2Controller.getRecord(doc1.id);
        dsfs__DocuSign_Status__c doc2 = Demo2Controller.updateRecordWithComment(doc1.id , 'hello');
        String reason = Demo2Controller.voidEnvelopeWithReason(doc1.id,'test');
        String reason2 = Demo2Controller.getEnvelopeStatus(doc1.id );
        String reason3 = Demo2Controller.voidEnvelope(doc1.id);
        
    }

}