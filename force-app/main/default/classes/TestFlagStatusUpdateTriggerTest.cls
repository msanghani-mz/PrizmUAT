@isTest
private class TestFlagStatusUpdateTriggerTest{

static TestMethod void testFlagStatusUpdate(){
    Flag__c testFlag = new Flag__c();
    testFlag.Name='Test Flag';
   
    testFlag.StatusUpdateNb__c=0;
    testFlag.Flag_Status__c='None';

    insert testFlag;
    test.startTest();

    testFlag.Flag_Status__c='Pending';
    
    update testFlag;
    
    test.stopTest();
    Flag__c updatedTestFlag = [SELECT StatusUpdateNb__c FROM Flag__c WHERE Id= :testFlag.Id];
    //System.assertEquals(1,updatedTestFlag.StatusUpdateNb__c );
    
    
}


}