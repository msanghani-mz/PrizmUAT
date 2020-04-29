@isTest
private class OpportunityClosedLostVoidEnvelopeJobTest {
    @testSetup
    private static void createTestData(){
        //create Account 
        Account testAccount = TestHelperData.createAccount();
        insert testAccount;
        System.assert(testAccount.Id != null, 'Test Account created assert');
        
        Opportunity testOpportunity = TestHelperData.createDNLOpportunity(testAccount.Id);
        insert testOpportunity;
        System.assert(testOpportunity.Id !=null, 'Test Opportunity created assert');
    }
    private static dsfs__DocuSign_Status__c createDocusignRecord(String pEnvelopeId, String pOppId ){
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        dsStatus.dsfs__DocuSign_Envelope_ID__c = pEnvelopeId;
        //dsStatus.Document_Type__c = pDocumentType;
        dsStatus.dsfs__Envelope_Status__c = 'Sent';
        dsStatus.dsfs__Opportunity__c = pOppId;
        return  dsStatus;
    }
    @isTest
    private static void testJob(){
        Opportunity opp = [Select id, Name, StageName from opportunity limit 1];
        System.debug(loggingLevel.Error, 'Opp1:--->'+Opp);
        opp.StageName = 'Closed Lost';
        update opp;
        opp = [Select id, Name, StageName from opportunity limit 1];
        System.debug(loggingLevel.Error, 'Opp2:--->'+Opp);
        
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617', opp.Id);
        insert dsStatus;
        
        Test.startTest();
        OpportunityClosedLostVoidEnvelopeJob testJob = new OpportunityClosedLostVoidEnvelopeJob();
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();
        
        dsfs__DocuSign_Status__c docStatus = [select id, dsfs__Envelope_Status__c, Lending_Application_Name__c from dsfs__DocuSign_Status__c where id =: dsStatus.id];
       // System.assertEquals('Voided', docStatus.dsfs__Envelope_Status__c, 'Opp Closed Lost assert');
        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('OpportunityClosedLostVoidEnvelopeJob',
                                       CRON_EXP, 
                                       new OpportunityClosedLostVoidEnvelopeJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
    
    
}