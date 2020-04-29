@isTest
public with sharing class ClientPortal_DNLGenericAgrmntPageTest {
    @TestSetup
    static void makeData(){
        List<Client_Portal_Portfolio__c> portfolios = ClientPortal_TestDataFactory.buildClientPortalPortfolios(1, 'DNL');
        portfolios[0].Name = 'DNL';
        portfolios[0].Profile_Name__c = 'DNL Customer Community Login User';
        portfolios[0].RDA_Content__c = 'Test Content';
        insert portfolios;
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        insert opp1;
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='testDNL@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
    }

    @IsTest
    static void testPageControllerForAllParams(){
        User contextuser = [Select Id, name FROM User WHERE email = 'testDNL@noemail.com'];
        Test.startTest();
        PageReference pageRef = Page.ClientPortal_DNLGenericShowAgrmntPage;
        pageRef.getParameters().put(ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM, ClientPortal_Constants.DNL_ESIGN_PARAM);
        Test.setCurrentPage(pageRef);
        System.runAs(contextuser){
            ClientPortal_DNLGenericAgrmntPageCntrl controller = new ClientPortal_DNLGenericAgrmntPageCntrl();
            pageRef.getParameters().put(ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM, ClientPortal_Constants.DNL_CPA_PARAM);
            ClientPortal_DNLGenericAgrmntPageCntrl controller2 = new ClientPortal_DNLGenericAgrmntPageCntrl();
            pageRef.getParameters().put(ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM, ClientPortal_Constants.DNL_TCPA_PARAM);
            ClientPortal_DNLGenericAgrmntPageCntrl controller3 = new ClientPortal_DNLGenericAgrmntPageCntrl();
            pageRef.getParameters().put(ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM, ClientPortal_Constants.DNL_REF_DIS_AUTH);
            ClientPortal_DNLGenericAgrmntPageCntrl controller4 = new ClientPortal_DNLGenericAgrmntPageCntrl();
        }
        Test.stopTest();
        
    }
}