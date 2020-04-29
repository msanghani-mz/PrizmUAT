/**
 * Class Name  : DNLDocuSignEnvelopeStatusMailerTest
 * Description : This class has test method for DocuSignEnvelopeStatus
 * Author      : Financial Spectra
 *
 */
@isTest
public class DNLDocuSignEnvelopeStatusMailerTest {
    @testSetup
    static void createTestData(){
        Account testAccount = TestHelperData.createAccount();
        Database.insert(testAccount);
        System.assert(testAccount.Id != null, 'Test Account created assert');
        Id DNLRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DNL Sales').getRecordTypeId();
        Opportunity testOpportunity = TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity.RecordTypeId= DNLRecordTypeId;
        Database.insert(testOpportunity);
        System.assert(testOpportunity.Id != null, 'Test Opportunity created assert');
        dsfs__DocuSign_Status__c testDocusignStatus = new dsfs__DocuSign_Status__c();
        testDocusignStatus.dsfs__Opportunity__c= testOpportunity.Id;
        testDocusignStatus.dsfs__Envelope_Status__c = 'Completed';
        Database.insert(testDocusignStatus);
        
    }
    @isTest
    static void testDNLDocusignEnvelopeStatus(){
    dsfs__DocuSign_Status__c testDocusignEnvStatus = [Select Id from dsfs__DocuSign_Status__c Limit 1 ];
        List<Id> DocuSignStatusIds = new List<Id>();
        DocuSignStatusIds.add(testDocusignEnvStatus.Id);
    //DNLDocuSignEnvelopeStatusMailer DMailer = new DNLDocuSignEnvelopeStatusMailer();
    DNLDocuSignEnvelopeStatusMailer.sendStatusEmailUpdate(DocuSignStatusIds);
        
    }
        

}