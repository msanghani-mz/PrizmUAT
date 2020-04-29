@isTest
public class Test_Prizm_CreateNuDebtTask {
	
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
        
        CreateNuDebtTasks.CreateTasks();
    }
    
}