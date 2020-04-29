@isTest
public class ClientPortal_CustomLoginCntrlTest {

    
     @isTest
    static void getUserDetails(){
        setupTestData();
            ClientPortal_CustomLoginCntrl.getClientPortalUIConfiguration('Test', 'Test1');
   
        //  System.assert(uiConfig.portfolio != null);
    }     
     @isTest
    static void loginTest(){
        setupTestData();
        ClientPortal_CustomLoginCntrl.login('test123@test.com', 'test@123', '/apex/ClientPortal_LoginFlow2FAPage', '');
        ClientPortal_CustomLoginCntrl.getUserInstance();
        //  System.assert(uiConfig.portfolio != null);
    }   
     @isTest
    static void getIsUsernamePasswordEnabledTest(){
        setupTestData();
            ClientPortal_CustomLoginCntrl.getIsUsernamePasswordEnabled();
   
        //  System.assert(uiConfig.portfolio != null);
    } 
     @isTest
    static void getIsSelfRegistrationEnabledTest(){
        setupTestData();
            ClientPortal_CustomLoginCntrl.getIsSelfRegistrationEnabled();
   
        //  System.assert(uiConfig.portfolio != null);
    } 
     @isTest
    static void getSelfRegistrationUrlTest(){
        setupTestData();
            ClientPortal_CustomLoginCntrl.getSelfRegistrationUrl();
   
        //  System.assert(uiConfig.portfolio != null);
    } 
     @isTest
    static void getForgotPasswordUrlTest(){
        setupTestData();
            ClientPortal_CustomLoginCntrl.getForgotPasswordUrl();
   
        //  System.assert(uiConfig.portfolio != null);
    } 
    @isTest
    static void setExperienceIdTest(){
        setupTestData();
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        // account1.IsCustomerPortal = true;
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;
        try {
            
            ClientPortal_CustomLoginCntrl.setExperienceId(account1.Id);
        } catch(Exception e) {
            
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
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
}