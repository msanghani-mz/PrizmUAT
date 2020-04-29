@isTest
public class DynamicTemplateControllerTest {
    
    static testMethod void testDynamicTemplate() {
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'New York';
        acc.PersonEmail = 'test@test.com';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        insert acc;
        
       
        Lead l = new Lead();
        l.NDS_File_Number__c = '1234';
        l.lastName = 'test';
        l.Cash_in_Dedicated_Account__c = 1234;
        l.Addnl_Months_with_Loan__c = 1234;
        l.Loan_Amount__c = 1234;
        l.Loan_Term__c = 123;
        l.Status = 'DNL New Lead';
        l.Sub_Status__c = 'New Lead';
        l.Origination_Fee__c = 10;
        l.Origination_Fee_Amount__c = 10;
        l.Unpaid_Program_Fees__c = 200;
        l.Account__c = acc.Id;
        //insert l;
        
        PrizmLeadTriggerHandler.isTriggerExecuted = false;

        
        
        DynamicTemplateController d= new DynamicTemplateController();
        d.LeadId = Id.valueOf('0062f00000C8wsgAAB');
        d.AccountId =l.Account__c;
        d.UserId = UserInfo.getUserId();
        d.ProgramId = l.Program_Name__c;
        //d.PortfolioId = l.Program_Name__r.Portfolio__c;
        d.vfTemplateName = 'Lead_On_Time_Payment_Notification';
        string emailBody = null;
        string subject = null;
        
        if(d.getTemplateContent().contains('::Split::'))
        {
            List<string> emailcontent = d.getTemplateContent().split('::Split::');
            subject = emailcontent[0];
            emailBody = emailcontent[1];
        }
        
        System.assertNotEquals(null, subject);
        System.assertNotEquals(null, emailBody);
    }

    
}