@isTest
private class TestBlank_SSNs_L{

    static TestMethod void testBlank_SSNs_L(){
        
        Lead testLead = new Lead();
        testLead.LastName = 'TestLead';
        
        insert testLead;
        test.startTest();
        
        testLead.Social_Security_Number__c = '1';
        testLead.Transunion_SSN__c = '1';
        
        update testLead;        
        test.stopTest();
        Lead updatedTestLead= [SELECT Social_Security_Number__c, Transunion_SSN__c FROM Lead WHERE Id= :testLead.Id];
        // With the trigger disabled, this should pass
        System.assertEquals('1',updatedTestLead.Social_Security_Number__c);
        System.assertEquals('1',updatedTestLead.Transunion_SSN__c);
          
    }
}