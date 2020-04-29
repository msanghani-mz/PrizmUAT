@isTest
public class ClientPortal_CommunityUserCntrlTest {
    @isTest
    private static void testGetCurrentUser() {
        Test.startTest() ;
        List<Account> accountsToInsert = new List<Account> () ;
        
        Account userAccount = ClientPortal_TestDataFactory.buildAccount('MyProfile UserAccount',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        userAccount.PersonEmail = 'testPerson@email.com' ;
        userAccount.PersonHomePhone = '7897898768' ;
        userAccount.PersonMobilePhone = '7897898768' ;
        accountsToInsert.add(userAccount) ;
        
        insert accountsToInsert ;
        
        Contact contactRec = [SELECT Id FROM Contact WHERE AccountId =: accountsToInsert[0].Id];
        String vclProfileId = [SELECT Id FROM Profile WHERE Name = 'VCL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = vclProfileId, country='United States',IsActive =true,
                             ContactId = contactRec.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        System.runAs(user){
            ClientPortal_CommunityUserDetailCntrl.UserWrapper userInstanceWrapper = ClientPortal_CommunityUserDetailCntrl.getCurrentUser() ;
            System.assertEquals(accountsToInsert[0].Id , userInstanceWrapper.userInstance.Id) ;
            ClientPortal_CommunityUserDetailCntrl.resetpassword() ;
        }
        Test.stopTest() ;
    }
    
    
    @isTest
    private static void testGetCurrentUserForException() {
        try{
            ClientPortal_CommunityUserDetailCntrl.UserWrapper userInstanceWrapper = ClientPortal_CommunityUserDetailCntrl.getCurrentUser() ;
            
        } catch(Exception ex) {
            System.assert(ex.getMessage() != null) ;
        }
    }
    
    @isTest
    private static void testSaveProfileDetails() {
        Test.startTest() ;
        List<Account> accountsToInsert = new List<Account> () ;
        
        Account userAccount = ClientPortal_TestDataFactory.buildAccount('MyProfile UserAccount',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        userAccount.PersonEmail = 'testPerson@email.com' ;
        userAccount.PersonHomePhone = '7897898768' ;
        userAccount.PersonMobilePhone = '7897898768' ;
        accountsToInsert.add(userAccount) ;
        
        insert accountsToInsert ;
        
        Contact contactRec = [SELECT Id FROM Contact WHERE AccountId =: accountsToInsert[0].Id];
        String vclProfileId = [SELECT Id FROM Profile WHERE Name = 'VCL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = vclProfileId, country='United States',IsActive =true,
                             ContactId = contactRec.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        System.runAs(user){
            userAccount = accountsToInsert[0] ;
            userAccount.PersonEmail = 'testPerson1@email.com' ;
            String resultStr = ClientPortal_CommunityUserDetailCntrl.saveProfileDetails(userAccount , true) ;
            System.assertEquals(resultStr, 'Success') ;
        }
        Test.stopTest() ;
    }
        
        
}