@isTest
public class Test_PrizmLeadTriggerHandler {
 public static testMethod void testmethod1(){
     Test.startTest();
     Lead l = new Lead();
     l.NDS_File_Number__c = '0011K000021P3OX';
     l.lastName = 'test';
     l.Cash_in_Dedicated_Account__c = 1234;
     l.Addnl_Months_with_Loan__c = 1234;
     l.Loan_Amount__c = 1234;
     l.Loan_Term__c = 123;
     l.Status = 'DNL New Lead';
     l.Sub_Status__c = 'New Lead';
     l.Origination_Fee_Amount__c = 200;
     l.Unpaid_Program_Fees__c = 200;
     insert l;
     
     l.loan_term__c = 12;
     
     update l;
     
     List<Lead> leadList = [Select Id, loan_term__c, NDS_File_Number__c from Lead where NDS_File_Number__c = '0011K000021P3OX'];
     System.assertEquals(leadList[0].loan_term__c, 12, 'True');
     System.debug('leadList = ' + leadList);
     Test.stopTest();
 }
    
}