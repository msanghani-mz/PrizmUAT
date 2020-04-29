@isTest
public class ClientPortal_MarkOppClosedLostTest {
    
    @isTest
    private static void testOpportunityCloseLost() {
        
        Date olderDate = Date.today() ;
        olderDate = olderDate.addDays(-15) ;
        Test.startTest() ;
        
        List<Account> accountsToInsert = new List<Account>() ;
        Account applicantRecRegister = ClientPortal_TestDataFactory.buildAccount('applicantRegister',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        applicantRecRegister.Welcome_Email_Sent_Date__c  = olderDate ;
        accountsToInsert.add(applicantRecRegister) ;
        
        Account appSubmission = ClientPortal_TestDataFactory.buildAccount('appSubmission',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        appSubmission.Registration_Date__c  = olderDate ;
        accountsToInsert.add(appSubmission) ;
        
        insert accountsToInsert ;
        
        
        List<Opportunity> oppsToInsert = new List<Opportunity>() ;
        Opportunity oppoRegistration = ClientPortal_TestDataFactory.buildOpportunity(accountsToInsert[0].Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        oppoRegistration.StageName = 'Registration In Progress';
        oppsToInsert.add(oppoRegistration) ;
        Opportunity oppoSubmission = ClientPortal_TestDataFactory.buildOpportunity(accountsToInsert[1].Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        oppoSubmission.StageName = 'Registration In Progress';
        oppsToInsert.add(oppoSubmission) ;
        
        insert oppsToInsert ;
        
        Contact contactRec = [SELECT Id FROM Contact WHERE AccountId =: accountsToInsert[1].Id];
        String dnlProfileId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = dnlProfileId, country='United States',IsActive =true,
                             ContactId = contactRec.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        ClientPortal_SchedulerToMarkClosedLost oppCloseLostBatch = new ClientPortal_SchedulerToMarkClosedLost();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test oppCloseLostBatch', sch, oppCloseLostBatch); 
        
        ClientPortal_MarkOpportunityClosedLost.getRelatedUserDetail(accountsToInsert) ;
        
        LIST<Opportunity> opportunityList = [SELECT Id, StageName
                              FROM Opportunity
                              WHERE (AccountId = :accountsToInsert[0].Id OR AccountId = :accountsToInsert[1].Id) ];
        System.assert(!opportunityList.IsEmpty()) ;
        Test.stopTest() ;
        
    }
    
}