@isTest
public class LeadUtilityTest {
    
    @isTest
    public Static void testSendEmail(){

        
        
        Lead l = new Lead();
        l.NDS_File_Number__c = '1234';
        l.lastName = 'test';
        l.Cash_in_Dedicated_Account__c = 1234;
        l.Addnl_Months_with_Loan__c = 1234;
        l.Loan_Amount__c = 1234;
        l.Loan_Term__c = 123;
        l.Status = 'DNL New Lead';
        l.Sub_Status__c = 'New Lead';
        l.Origination_Fee__c = 20;
        l.Origination_Fee_Amount__c = 20;
        l.Unpaid_Program_Fees__c = 200;
        l.Email = 'test@123.com';
        insert l;
        
        PrizmLeadTriggerHandler.isTriggerExecuted = false;
        
        
        Lead leadRec = LeadUtility.leadRec(l.Id);
        System.assertNotEquals(null, leadRec);
        
        OrgWideEmailAddress[] addresses = [SELECT Id,address FROM OrgWideEmailAddress LIMIT 1];
        
        string result = LeadUtility.sendEmail(l.id);
        
        System.assertNotEquals(null, result);
        l.Last_Email_Sent_Time__c = Datetime.now();
        update l;
        
        result = LeadUtility.sendEmail(l.id);
        
        System.assertNotEquals(null, result);
        
    }
    
    
}