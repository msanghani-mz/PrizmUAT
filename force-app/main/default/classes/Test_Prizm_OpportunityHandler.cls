@isTest
public class Test_Prizm_OpportunityHandler {

    @isTest
    public static void TestMethod1(){
       
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonBirthdate=System.today()-750;
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'New Jersey';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        acc.Phone='7878787878';
        acc.fsCore__National_Identification_Number__pc='272625';
        acc.PersonMailingCity = 'TestCity';
        //acc.PersonMailingPostalCode='65467';
        //acc.PersonMailingStateCode='07002';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert acc;
        
        Account acc1 = new Account();
        acc1.FirstName = 'test1';
        acc1.LastName = 'test1';
        acc1.PersonBirthdate=System.today()-760;
        acc1.NDS_File_Number__c = '12345';
        acc1.PersonMailingState = 'New Jersey';
        acc1.nu_dse__SSN__c = 'ABBHBD6878';
        acc1.Phone='7878787872';
        acc1.fsCore__National_Identification_Number__pc='272621';
        acc1.PersonMailingCity = 'TestCity1';
        //acc.PersonMailingPostalCode='65467';
        //acc.PersonMailingStateCode='07002';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert acc1;
        
                     
        Opportunity op1 = new Opportunity();
        op1.Amount = 1000;
       // o.Additional_months_with_loan__c = 12;
        op1.Name = 'Test Test';
        op1.CloseDate = Date.today()+1;
        //o.Applicant_State__c = 'Joint';
        op1.AccountId = acc.Id;
        op1.Applicant_Name__c=acc.Id; //
        op1.Co_Applicant_Name__c=acc1.Id;
        op1.StageName = 'DNL-Prospecting';
        op1.Import_Id__c = '006m000000B312yAAB';
        op1.Loan_Number_Of_Payments__c=24;
        op1.Addnl_Months_with_Loan__c=2;
        op1.Application_Signed_Date__c=Date.today();
        //op1.Debit_Day_First__c=Date.today();
        op1.DRP_File_Number__c='1234567';
        op1.Debt_Count__c=4;
        op1.Unsettled_Debt__c=2;
        op1.Opportunity_Type__c='DNL Sale';
        //op1.Co_Applicant_Name__c='001L000001B1hDKIAZ';
        op1.Is_Do_Not_Call__c=true;
        op1.Enrolled_Date__c=Date.today();
        op1.Is_Application_Submitted__c=False;
        op1.Import_Program_Id__c='765432';
        op1.Program_Id__c='876543';
        op1.Debit_Day_Second__c=30;
        //op1.Payment_Cycle__c=30;
        op1.Program_Type__c='Test Prg';
        op1.Remaining_Months_DRP_Program__c=5;
        op1.Program_Number_Of_Payments__c=24;
        op1.Payment_Processor_Name__c = 'CFT';
        insert op1;
        
        fsCore__Bank_Account__c fsCoreBankAcctInstance = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance.fsCore__Bank_Account_Holder_Name__c = 'XXXXXXXXXXX';
        fsCoreBankAcctInstance.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance.fsCore__Bank_Identification_Code__c = '1197879687';
        fsCoreBankAcctInstance.fsCore__Account_Name__c = acc1.Id;
        insert fsCoreBankAcctInstance;	
        
        fsCore__Bank_Account__c fsCoreBankAcctInstance1 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Holder_Name__c = 'XXXXXXXXXXX';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance1.fsCore__Bank_Identification_Code__c = '1197879687';
        fsCoreBankAcctInstance1.fsCore__Account_Name__c = acc.Id;
        insert fsCoreBankAcctInstance1;	
        
        op1.StageName = 'Closed Won';
        update op1;
    }
    
}