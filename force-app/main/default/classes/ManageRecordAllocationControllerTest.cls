@isTest
private class ManageRecordAllocationControllerTest{

    @isTest
    private static void testControllerMethods(){
        Profile userProf = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        Test.startTest();
        List<User> users = ManageRecordAllocationController.getUsers(userProf.Name);
        System.assert(users.size() != 0);
        
        String retMsgJSONSuccess = ManageRecordAllocationController.toggleRoundRobinStatus(UserInfo.getUserId());
        String retMsgJSONError = ManageRecordAllocationController.toggleRoundRobinStatus(UserInfo.getProfileId());
        Test.stopTest();
    }
}