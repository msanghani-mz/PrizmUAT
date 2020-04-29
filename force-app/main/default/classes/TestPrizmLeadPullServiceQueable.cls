@isTest
public class TestPrizmLeadPullServiceQueable {
 public static testMethod void testmethod1(){
     Test.startTest();
     List<String> listOfIds = new List<String>();
     
     listOfIds.add('0011K000021P3OX');
     listOfIds.add('0011K000021P3cy');
     listOfIds.add('00Q2f0000025bBZEAY');
     listOfIds.add('00Q2f0000025bBaEAI');
     List<Lead> leads = [Select Id, NDS_File_Number__c from Lead 
                         where NDS_File_Number__c = :listOfIds ];
     System.debug(leads);
     PrizmLeadPullServiceQueueable queableService = new 
         PrizmLeadPullServiceQueueable(null, leads);
     Test.stopTest();
 }
}