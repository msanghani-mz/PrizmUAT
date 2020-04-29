@isTest
public class Test_oppoController {

    public static testmethod void TestController(){
         Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'New Jersey';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        //acc.Attorney__c = true;
        //acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        insert acc;
        
        Opportunity op1=new Opportunity();
        op1.AccountId=acc.Id; 
        op1.Name='Test Opp';
        //Set ownerId of Opportunity & it will used while update : Line no.47
        //OppOwnerId=lstop.OwnerId;
        op1.StageName='DNL Prospecting';
        op1.Amount=1000;
        op1.CloseDate=Date.Today()+1;
        op1.Import_Id__c='0060S0000068D7WQAU';
        //lstop.Import_Id__c='';
        //update lstop;  //
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
        insert op1;
        //Opportunity Draft fee
        Opportunity_Draft_Fee__c opdrftfeeOrgNew=new Opportunity_Draft_Fee__c();
        opdrftfeeOrgNew.Total_Accumulation__c=22;
        opdrftfeeOrgNew.Opportunity_Name__c=op1.id;
        opdrftfeeOrgNew.Total_Admin_Fee__c=44;
        insert opdrftfeeOrgNew;
        //TradeLine
      
        Test.startTest();
        String oppId=oppoController.getOpportunity(op1.Id);
        Test.stopTest();
        
       
    }
}