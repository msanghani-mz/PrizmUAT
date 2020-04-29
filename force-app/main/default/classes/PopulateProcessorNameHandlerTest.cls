@isTest
public class PopulateProcessorNameHandlerTest {
    
	@isTest
    public static void appendOpportunityCommentTest() {
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account2; 
        
        Opportunity opp = ClientPortal_TestDataFactory.buildOpportunity(account2.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp.StageName = 'Registration In Progress';
        insert opp;
        
        List<Opportunity> oppList = new List<Opportunity>() ;
        Map<Id, Opportunity> oppOldMap = new Map<Id, Opportunity>() ;
        oppOldMap.put(opp.Id , opp) ;
        
        Test.startTest();
        oppList.add(new Opportunity(
            Id = opp.Id,
            StageName = 'Closed Lost' 
        )) ;
        PopulateProcessorNameHandler.appendOpportunityComment(oppList , oppOldMap) ;
        Test.stopTest();
        
        opp = [Select Id, Comments__c FROM Opportunity WHERE Id = :opp.Id] ;
        system.debug('opp-> ' + opp);
        System.assert(String.isNotBlank(opp.Comments__c)) ;
        
    }
}