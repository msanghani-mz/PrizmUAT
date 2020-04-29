@isTest
public with sharing class ClientPortal_ForgotPasswordCntrlTest {
    @isTest
    static void getClientPortalUIConfigurationTest(){
        ClientPortal_ForgotPasswordPageCntrl.getClientPortalUIConfiguration('Test', 'Test1');
    }
    @isTest
    static void forgotPasswordTest(){
       // List<User> u2 = [SELECT id,username from User WHERE lastName = 'Account' LIMIT 1];
        
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
        List<Client_Portal_Portfolio__c> Portfolios = [Select Id, Name,Dispay_Name__c, Forgot_Password_URL__c from Client_Portal_Portfolio__c where Name = 'Test1' LIMIT 1];
        try{
        ClientPortal_CustomForgotPasswordCntrl.forgotPassword(user.Username,'http://www.google.com');
        }catch(Exception e){
            System.debug('#### Exception'+e);
        }
        }  
    
    @isTest
    static void setExperienceIdTest(){
        setupTestData();
        List<Account> account1 = [Select Id, Name, LastName From Account Where LastName='Account' LIMIT 1];
        try {
            ClientPortal_CustomForgotPasswordCntrl.setExperienceId(account1[0].Id);
        } catch(Exception e) {
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @testSetup
    static void setupTestData() {
        List<Client_Portal_Portfolio__c> portfolios =
            ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'Test');
        Client_Portal_Portfolio__c port = new Client_Portal_Portfolio__c();
        port.Forgot_Password_URL__c=' ';
        portfolios.add(port);
        insert portfolios;
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;
        
        list<Contact> conList = ClientPortal_TestDataFactory.buildContact(account1.Id,'Account');
        insert conList;
        
        profile prf = [select id, Name from profile where Name='Customer Community User'];
        
        List<User> users =
            ClientPortal_TestDataFactory.buildUser(conList[0].Id,prf.Name);
        test.startTest();
            ClientPortal_CustomForgotPasswordCntrl.forgotPassword('','');
        test.stopTest();
        
    } 
}