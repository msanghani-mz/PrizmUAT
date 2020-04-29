@isTest
private class ClientPortal_CustomRegisterCntrlTest {
    
    @isTest
    static void whenValidProtfolioGetTheUIConfig(){
        ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig uiConfig =
            ClientPortal_CustomRegisterCntrl.getClientPortalUIConfiguration('test', 'DNL');
        
        //System.assert(uiConfig.portfolio != null);
    }
    
    @testSetup
    static void setupTestData() {
        List<Client_Portal_Portfolio__c> portfolios =
            ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'DNL');
        portfolios[0].Name = 'DNL';
        insert portfolios;
        
        Client_Portal_Settings__c portalSettings =
            ClientPortal_TestDataFactory.buildClientPortalSetting(portfolios[0].Id, ClientPortal_TestDataFactory.getRecordTypeId('Client_Portal_Settings__c','Header UI Configuration')); 
        insert portalSettings;
        Client_Portal_Settings__c portalSettings1 =
            ClientPortal_TestDataFactory.buildClientPortalSetting(portfolios[0].Id, ClientPortal_TestDataFactory.getRecordTypeId('Client_Portal_Settings__c','Menu UI Configuration')); 
        insert portalSettings1;
        Client_Portal_Settings__c portalSettings2 =
            ClientPortal_TestDataFactory.buildClientPortalSetting(portfolios[0].Id, ClientPortal_TestDataFactory.getRecordTypeId('Client_Portal_Settings__c','Body UI Configuration')); 
        insert portalSettings2;
        Client_Portal_Settings__c portalSettings3 =
            ClientPortal_TestDataFactory.buildClientPortalSetting(portfolios[0].Id, ClientPortal_TestDataFactory.getRecordTypeId('Client_Portal_Settings__c','Footer UI Configuration')); 
        insert portalSettings3; 
        
        Client_Portal_Org_Setting__c orgSetting = new Client_Portal_Org_Setting__c();
        orgSetting.Portfolio_Id__c = portfolios[0].Id;
        insert orgSetting;
    }
}