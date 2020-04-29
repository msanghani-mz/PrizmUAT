@isTest
public class Test_Prizm_TaskHandler {
	
    @isTest
    public static void TestMethod1(){
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'New Jersey';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        //acc.Attorney__c = true;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert acc;
        
        Opportunity o = new Opportunity();
        o.Amount = 1000;
       // o.Additional_months_with_loan__c = 12;
        o.Name = 'Test Test';
        o.CloseDate = Date.today()+1;
        //o.Applicant_State__c = 'Joint';
        o.AccountId = acc.Id;
        o.StageName = 'DNL-Prospecting';
        o.Import_Id__c = '006m000000B312yAAB';
        insert o;
        
        Task t = new Task();
            t.Due_Date_Time__c = System.now();
            t.ActivityDate = Date.today();
            t.Status = 'Not Started';
            t.subject='Test Subject';
            t.WhatId = o.Id;
            t.Import_Id__c = '00Tm000000S53sg';
            t.Priority = 'Normal';
            insert t;
        
        t.Status = 'Completed';
        update t;
    }
    
    @isTest
    public static void testMethodForLead(){
        
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
       	insert l;
        
        Task t = new Task();
        t.Due_Date_Time__c = System.now();
        t.ActivityDate = Date.today();
        t.Status = 'Not Started';
        t.subject='Test Subject';
        t.WhatId = l.Id;
		t.Call_Result__c = 'Not Available';
        insert t;
        System.assertEquals('Not Available', l.Sub_Status__c);
 
    }
   
    
}