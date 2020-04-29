@isTest
public class ClientPortal_LoginFlow2FAPageCntrlTest {
    static ClientPortal_LoginFlow2FAPageCntrl LoginFlow2FA;
    static Integer Length=6; 
    @isTest
    public static void updateUserAndRedirectTest(){
        //setupTestData();  
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id, Is_User_Authenticated__c = true,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        // User u2 = [SELECT id from User WHERE Is_User_Authenticated__c = true LIMIT 1];
        
        
        String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(u)
        {
            test.startTest();
            String ownerId = UserInfo.getUserId();
            

            test.stopTest();
            System.debug(u.Id + ':' + ownerId);
            System.assertEquals(u.Id, ownerId);
        
        
        
        Portal_Identity_Service__c port = ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
        port.User__c = u.Id;
        port.Status__c = 'Initiated';
        port.Type__c = 'Email';
        port.Last_Login_Time__c = Date.Today();
        port.Unique_Identifier__c = '123456';      
            
        insert port;
        String sourceIP = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        List<Portal_Identity_Service__c> portList = [SELECT Id, Status__c, Last_Login_Time__c
                                                          FROM Portal_Identity_Service__c
                                                          WHERE RecordTypeId =: port.recordTypeId
                                                          AND User__c = : u.Id
                                                          AND Ip_Address__c = :sourceIP];
        String RandomNo;
        
        Id recordTypeId = ClientPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Login History');
        
        Portal_Identity_Service__c port1 =  ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
        port1.User__c = UserInfo.getUserId();
        port1.Status__c = 'Initiated';
        port1.Type__c = 'Email';
        //port1.RecordTypeId = recordTypeId;
            port1.Last_Login_Time__c = Date.Today() ;
            port1.Ip_Address__c = '9876543210' ;
        port1.Unique_Identifier__c = ClientPortal_LoginFlow2FAPageCntrl.getRandomNumber(Length);
        insert port1;

        
        String selectedMode = ApexPages.currentPage().getParameters().get('selctedMode');
        ApexPages.currentPage().getParameters().put('selctedMode','agentSentCodeVerification');
        Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
        String exceptionText = '';
        String enteredText = null;
       // Test.startTest();
        PageReference pageRef = Page.ClientPortal_LoginFlow2FAPage;     
        pageRef.getParameters().put('pUserEmail' , 'test@testYopmail.com') ;
        pageRef.getParameters().put('pUserMobile' , '9876543210') ;
        pageRef.getParameters().put('sourceIP' , '9876543210') ;
        Test.setCurrentPage(pageRef);   
        LoginFlow2FA = new ClientPortal_LoginFlow2FAPageCntrl();
        LoginFlow2FA.updateUserAndRedirect();
        System.assertNotEquals('agentSentCodeVerification','modeSelection');
        System.assertNotEquals(false,String.isBlank(LoginFlow2FA.exceptionText));
       // Test.stopTest();
        }
        
    }
    
    @isTest
    public static void sendVerificationCodeToClientTest(){
        //setupTestData();  
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        
          String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(u)
        {
            test.startTest();
            String ownerId = UserInfo.getUserId();
            

            test.stopTest();
            System.debug(u.Id + ':' + ownerId);
            System.assertEquals(u.Id, ownerId);
        }
        
        
        EmailMessage email = new EmailMessage();
        Portal_Identity_Service__c port = ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
        port.User__c = UserInfo.getUserId();
        port.Status__c = 'Initiated';
        port.Type__c = 'Email';
        port.Unique_Identifier__c = '123456';        
        insert port;
        String RandomNo;

        PageReference pageRef = Page.ClientPortal_LoginFlow2FAPage;
        
        ClientPortal_LoginFlow2FAPageCntrl LoginFlow2FANew = new ClientPortal_LoginFlow2FAPageCntrl();
        
        pageRef.getParameters().put('selctedMode', 'Email');
        pageRef.getParameters().put('pUserEmail' , 'test@testYopmail.com') ;
        pageRef.getParameters().put('pUserMobile' , '9876543210') ;
        Test.setCurrentPage(pageRef);   
        //LoginFlow2FA.validationCode = 123456;
               

        LoginFlow2FANew.sendVerificationCodeToClient();
       // Test.stopTest();
        
    }
    @isTest
    public static void validateCodeTest(){
        //setupTestData();  
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        EmailMessage email = new EmailMessage();
        // String validationCode = Integer.valueOf(getRandomNumber(6));
        Portal_Identity_Service__c port = ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
        port.User__c = UserInfo.getUserId();
        port.Status__c = 'Initiated';
        port.Type__c = 'Email';
        port.Unique_Identifier__c = '123456';        
        insert port;
        System.runAs(user) {
            
            Test.startTest();
            PageReference pageRef = Page.ClientPortal_LoginFlow2FAPage;     
            Test.setCurrentPage(pageRef);   
            LoginFlow2FA = new ClientPortal_LoginFlow2FAPageCntrl();
            LoginFlow2FA.enteredText = '123456' ;
            LoginFlow2FA.validationCode = 123456 ;
            LoginFlow2FA.loginHistoryInstance = port;
            LoginFlow2FA.sentTime = System.now() ;
            LoginFlow2FA.validateCode();
            Test.stopTest();
        }
        
    }
    
    
    public static testMethod void Testtest() { 
        
         Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user2 = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user2;
        
        System.runAs(user2) {  
            //System.runAs(thisUser) {
            
            ApexPages.currentPage().getParameters().put('selctedMode','Mobile');
            
            Test.startTest();
            ClientPortal_LoginFlow2FAPageCntrl loginFlow2FAInstance = new ClientPortal_LoginFlow2FAPageCntrl();
            loginFlow2FAInstance.sendVerificationCodeToClient();
            loginFlow2FAInstance.enteredText = '459612';
            loginFlow2FAInstance.validateCode();
            
            loginFlow2FAInstance.validateAgentCode();
            
            Test.stopTest();
            System.assertEquals('codeVerification',loginFlow2FAInstance.actionString);
            System.assertEquals(false,String.isBlank(loginFlow2FAInstance.exceptionText));
        }
    }
    
    public static testMethod void loginFlow2FAVerificationCodeCall() { 

         Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        System.runAs(user) {
            //System.runAs(thisUser) {
            
            ApexPages.currentPage().getParameters().put('selctedMode','Phone Call');
            ApexPages.currentPage().getParameters().put('pUserEmail' , 'test@testYopmail.com') ;
            ApexPages.currentPage().getParameters().put('pUserMobile' , '9876543210') ;
            
            Test.startTest();
            
            //  Test.setMock(HttpCalloutMock.class, new SFSPortal_MockHandler());  
            ClientPortal_LoginFlow2FAPageCntrl loginFlow2FAInstance = new ClientPortal_LoginFlow2FAPageCntrl();
            loginFlow2FAInstance.sendVerificationCodeToClient();
            loginFlow2FAInstance.enteredText = '459612';
            loginFlow2FAInstance.validateCode();
            
            Test.stopTest();
            System.assertEquals('codeVerification',loginFlow2FAInstance.actionString);
            System.assertEquals(false,String.isBlank(loginFlow2FAInstance.exceptionText));
        }
        
    }
    public static testMethod void loginFlow2FAException() {

        
         Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        List<Client_Portal_Portfolio__c> portfolios =
            ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'Test');
        insert portfolios;
        
        system.runAs(user){ 
            //system.runAs(thisUser){
            
            Test.startTest();
            ClientPortal_LoginFlow2FAPageCntrl dashboardMetricsInstance = new ClientPortal_LoginFlow2FAPageCntrl();
            dashboardMetricsInstance.validateCode();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRandomNumberTest(){
        setupTestData();  
        EmailMessage email = new EmailMessage();
        // String validationCode = Integer.valueOf(getRandomNumber(6));
        Portal_Identity_Service__c port = ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
        port.User__c = UserInfo.getUserId();
        port.Status__c = 'Initiated';
        port.Type__c = 'Email';
        port.Unique_Identifier__c = '123456';        
        insert port;
        Test.startTest();
        PageReference pageRef = Page.ClientPortal_LoginFlow2FAPage;     
        Test.setCurrentPage(pageRef);   
        //static Integer Length = 6;
        String RandomNo;
        LoginFlow2FA = new ClientPortal_LoginFlow2FAPageCntrl();
        // RandomNo=LoginFlow2FA.getRandomNumber(Length);
        RandomNo=ClientPortal_LoginFlow2FAPageCntrl.getRandomNumber(Length);
        Test.stopTest();
        
    }
    @isTest
    public static void validateAgentCodeTest(){
        setupTestData();  
        EmailMessage email = new EmailMessage();
        // String validationCode = Integer.valueOf(getRandomNumber(6));
        Portal_Identity_Service__c port = ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
        port.User__c = UserInfo.getUserId();
        port.Status__c = 'Initiated';
        port.Type__c = 'Email';
        port.Unique_Identifier__c = '123456';        
        insert port;
        Test.startTest();
        PageReference pageRef = Page.ClientPortal_LoginFlow2FAPage;     
        Test.setCurrentPage(pageRef);   
        LoginFlow2FA = new ClientPortal_LoginFlow2FAPageCntrl();
        LoginFlow2FA.validateAgentCode();
        Test.stopTest();
        
    }
     @isTest
    public static void navigateToLoginTest(){
        setupTestData();  
        EmailMessage email = new EmailMessage();
        // String validationCode = Integer.valueOf(getRandomNumber(6));
        Portal_Identity_Service__c port = ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
        port.User__c = UserInfo.getUserId();
        port.Status__c = 'Initiated';
        port.Type__c = 'Email';
        port.Unique_Identifier__c = '123456';        
        insert port;
        Test.startTest();
        PageReference pageRef = Page.ClientPortal_LoginFlow2FAPage;     
        Test.setCurrentPage(pageRef);   
        LoginFlow2FA = new ClientPortal_LoginFlow2FAPageCntrl();
        LoginFlow2FA.navigateToLogin();
        Test.stopTest();
        
    }
    
    @testSetup
    static void setupTestData() {
        List<Client_Portal_Portfolio__c> portfolios =
            ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'Test');
        insert portfolios;
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        // account1.IsCustomerPortal = true;
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;
        
        list<Contact> conList = ClientPortal_TestDataFactory.buildContact(account1.Id,'Account');
        insert conList;
        
        profile prf = [select id, Name from profile where Name='Customer Community User'];
        //  UserRole r = [select id, Name from UserRole ];
        System.debug('#####prf'+prf);
        
        Client_Portal_Portfolio__c portfolio1 = new Client_Portal_Portfolio__c();
        portfolio1.Name = 'DNL';
        insert portfolio1;
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        insert opp1;
        
        Client_Portal_Portfolio__c portfolio2 = new Client_Portal_Portfolio__c();
        portfolio2.Name = 'DNL';
        insert portfolio2;
        Opportunity opp2 = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp2.StageName = 'Open';
        insert opp2;
        
    }
    
    @isTest
    public static void updateUserAndRedirect2Test(){
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id, Is_User_Authenticated__c = true,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        // User u2 = [SELECT id from User WHERE Is_User_Authenticated__c = true LIMIT 1];
        
        
        String userId = UserInfo.getUserId();
        User u = [SELECT AccountId, CompanyName, ContactId,  Email, FirstName, Name, ProfileId, UserRoleId, Id, Username FROM User Where Id=:userId];
        System.runAs(user)
        {
            test.startTest();
            String ownerId = UserInfo.getUserId();
            

            
            System.debug(user.Id + ':' + ownerId);
            System.assertEquals(user.Id, ownerId);
        
        
        
            Portal_Identity_Service__c port = ClientPortal_TestDataFactory.buildPortalIdentityService(ClientPortal_TestDataFactory.getRecordTypeId('Portal_Identity_Service__c','Identity Verification'));
            port.User__c = user.Id;
            port.Status__c = 'Initiated';
            port.Type__c = 'Email';
            port.Last_Login_Time__c = Date.Today();
            port.Status__c = 'Success';
            port.Unique_Identifier__c = '123456';        
            insert port;
            
            ClientPortal_LoginFlow2FAPageCntrl.updateUserIPAddressOnAccount(String.valueOf(user.Id), '908776655',  true , 'test@testyopmail.com' , '2987654422', port.Id) ;
            test.stopTest();
        }
    }
}