@isTest
public class ClientPortal_FAQsControllerTest {
    
    @isTest
    static void getClientPortalUIConfigurationTest(){
        ClientPortal_FAQsController.getClientPortalUIConfiguration('Test', 'DNL');
    }
    @isTest
    static void ClientPortal_FAQsControllerTest(){
        Test.startTest();
        ClientPortal_FAQsController.getAllFrequentQuestions('Test', 'DNL');
        Test.stopTest() ;
    }
    
    @testSetup
    static void setupTestData() {
        List<Client_Portal_Portfolio__c> portfolios =
            ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'Test');
        portfolios[0].Name = 'DNL';
        insert portfolios;
        
        Client_Portal_Settings__c portalSettings =
            ClientPortal_TestDataFactory.buildClientPortalSetting(portfolios[0].Id, ClientPortal_TestDataFactory.getRecordTypeId('Client_Portal_Settings__c','Frequently Asked Question Configuration')); 
        portalSettings.Is_Active__c = true;
        portalSettings.Client_Portal_Portfolio__c = portfolios[0].Id;
        insert portalSettings;
        
        Client_Portal_Org_Setting__c orgSetting = new Client_Portal_Org_Setting__c();
        orgSetting.Portfolio_Id__c = portfolios[0].Id;
        insert orgSetting;
    }    
    
}