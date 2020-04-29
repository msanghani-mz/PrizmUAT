@isTest
public class Test_RegAccountController {

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
        op1.Import_Id__c='0060S0000068D7WQAD';
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
        //TradeLine
        Opportunity_Tradelines_Offer__c cloneOT=new Opportunity_Tradelines_Offer__c();
                cloneOT.Opportunity_Name__c=op1.Id;
                //cloneOT.Current_Stage__c=OT.Current_Stage__c;
                
                cloneOT.DNL_Disbursement_Amount__c=2000;
                cloneOT.DNL_Disbursement_Date__c=Date.today()+20;
                cloneOT.DNL_Funds_for_Fees__c=600; 
                cloneOT.DNL_Settlement_Fees__c=200;
                cloneOT.Estimated_Settlement__c=50;
                cloneOT.FileNumber__c='34567';
                //cloneOT.Import_Id__c=OT.Import_Id__c;
                cloneOT.Litigation_Stage__c='Stage1';
                //cloneOT.Name=OT.Name;
                cloneOT.New_Account_Number__c ='12345678';
                cloneOT.New_Creditor__c='Bank of America';
                cloneOT.Offer_Amount__c=3000;
                cloneOT.Offer_Program_Fee__c=2000;
                cloneOT.Offer_Status__c='Pending';
                cloneOT.Original_Account_Number__c='9876543';
                cloneOT.Original_Creditor__c='Bank of America';
                cloneOT.Original_Debt__c=2000;
                //cloneOT.Settlement__c=OT.Settlement__c;
                cloneOT.Settlement_Amount_Paid__c=1500;
                cloneOT.SFS_Current_Balance__c=1500;
                insert cloneOT;
                
        
        Test.startTest();
        //String oppId=RegAccountController.SendMailToClient(op1.Id);
        Test.stopTest();
    }
}