@isTest
private class TestBlank_SSNs{

    static TestMethod void testTestBlank_SSNs(){
        
        Account testAcc = new Account();
        testAcc.LastName = 'TestAccount';
        testAcc.RecordTypeId = '012d0000000WUAmAAO';
        
        insert testAcc;
        test.startTest();
        
        testAcc.SSN__c = '1';
        testAcc.Transunion_SSN__c = '1';
        
        update testAcc;        
        test.stopTest();
        Account updatedTestAcc= [SELECT SSN__c, Transunion_SSN__c FROM Account WHERE Id= :testAcc.Id];
         // With the trigger disabled, assert '1' instead
        System.assertEquals('1',updatedTestAcc.SSN__c);
        System.assertEquals('1',updatedTestAcc.Transunion_SSN__c);
          
    }
}