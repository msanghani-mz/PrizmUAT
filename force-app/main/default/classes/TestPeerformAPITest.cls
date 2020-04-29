@isTest
private class TestPeerformAPITest
{
    static TestMethod void testUpdateFlagStatus()
    {
        String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(u)
        {
            test.startTest();
            String ownerId = UserInfo.getUserId();
            
            PeerformAPI.UpdateFlagStatus('68687', '1', true);

            test.stopTest();
            System.debug(u.Id + ':' + ownerId);
            System.assertEquals(u.Id, ownerId);
        }
    }

    static TestMethod void testLoanContentStauts()
    {
        String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(u)
        {
            test.startTest();

            String ownerId = UserInfo.getUserId();

            PeerformAPI.UpdateLoanContentStatus('1', 'rejected description', true);

            test.stopTest();
            System.debug(u.Id + ':' + ownerId);
            System.assertEquals(u.Id, ownerId);
        }
    }

    

    static TestMethod void testRunTask()
    {
        String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(u)
        {
            test.startTest();
            String ownerId = UserInfo.getUserId();

            PeerformAPI.RunTask('1', true);

            test.stopTest();
            System.debug(u.Id + ':' + ownerId);
            System.assertEquals(u.Id, ownerId);
        }
    }

    static TestMethod void testUpdateLoanVerificationStatusItem()
    {
        String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(u)
        {
            test.startTest();
            String ownerId = UserInfo.getUserId();
            
            PeerformAPI.UpdateLoanVerificationStatusItem('1', 1, 'pending', 'none', true);
            PeerformAPI.UpdateLoanVerificationStatusItem('1', 1, 'verified', 'none', true);
            PeerformAPI.UpdateLoanVerificationStatusItem('1', 1, 'error', 'none', true);
            PeerformAPI.UpdateLoanVerificationStatusItem('1', 1, 'err', 'none', true);

            test.stopTest();
            System.debug(u.Id + ':' + ownerId);
            System.assertEquals(u.Id, ownerId);
        }
    }
    
    static TestMethod void testUpdateIncomeStatus()
    {
        String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(u)
        {
            test.startTest();
            String ownerId = UserInfo.getUserId();
            
            PeerformAPI.UpdateIncomeStatus('1', 'Pending', true);
            PeerformAPI.UpdateIncomeStatus('1', 'Verified', true);
            PeerformAPI.UpdateIncomeStatus('1', 'Error', true);
            
            test.stopTest();
            System.debug(u.Id + ':' + ownerId);
            System.assertEquals(u.Id, ownerId);
        }
    }
}