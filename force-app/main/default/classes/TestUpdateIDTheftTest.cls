@isTest
private class TestUpdateIDTheftTest{
    static TestMethod void testUpdateIDTheft(){
        Account testAcc = new Account();
        testAcc.LastName = 'Test Account';
        testAcc.RecordTypeId = '012d0000000WUAmAAO';
        testAcc.ID_Theft__c = false;
       
        insert testAcc;
        test.startTest();
    
        testAcc.ID_Theft__c = true;
        
        update testAcc;
        
        test.stopTest();
        Account updatedTestAcc = [SELECT ID_Theft__c FROM Account WHERE Id= :testAcc.Id];
        System.assertEquals(true, updatedTestAcc .ID_Theft__c );
    }
}