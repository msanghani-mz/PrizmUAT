@isTest
public class Test_Prizm_CreateOrUpdateRecordService {

    @isTest
    public Static void TestCreatedOpportunity(){
        OpportunityJSONClass jsonClass = new OpportunityJSONClass();
        
        OpportunityJSONClass.cls_Opportunity OpportunityCls =new opportunityJSONClass.cls_Opportunity();
        OpportunityJSONClass.cls_Payments Payments = new OpportunityJSONClass.cls_Payments();
        OpportunityCls.Payments = new List<OpportunityJSONClass.cls_Payments>();
        OpportunityCls.Tradelines = new List<OpportunityJSONClass.cls_Tradelines>();
        OpportunityCls.BankAccounts = new OpportunityJSONClass.cls_BankAccount();
        OpportunityCls.Tasks = new List<Task>();
        
        OpportunityCls.AccountName = 'Test';
        OpportunityCls.Id = '0060S0000068D7WQAU';
        OpportunityCls.FileNumber = '1234567';
        OpportunityCls.Stage = 'Prospecting';
        OpportunityCls.CloseDate = String.valueOf(Date.today());
        OpportunityCls.CoFirstName = 'Test';
        OpportunityCls.CoLastName = 'Test';
        OpportunityCls.DebtCount='1';
       OpportunityCls.RemainingMonths='2';
        OpportunityCls.LoanTerm='2';
        OpportunityCls.LoanAmount='3000';
        OpportunityCls.CashInDedicatedAccount='210';
        OpportunityCls.PortfolioType='TimberLine';
        OpportunityCls.Segment='Segment 1';
        OpportunityCls.CampaignType='CampaignType';
        OpportunityCls.PaymentFrequency='Monthly';
        OpportunityCls.AddnlMonthsWithLoan='2';
        OpportunityCls.UnsettledDebt='120';
        OpportunityCls.ProgramLength='12';
        OpportunityCls.UnpaidProgramFeeWithDNL='150';
        OpportunityCls.UnpaidProgramFeeWODNL='150';
        OpportunityCls.TwiceMonthlyReoccuringDay='3';
        OpportunityCls.ReoccurringDebitDay='4';
        OpportunityCls.DraftAmt='300';
        OpportunityCls.CurrentBalance='160';
        OpportunityCls.ProcessorName='RAM';
        //OpportunityCls.LawFirmName='TimberLine';
        OpportunityCls.EnrollmentDate=String.valueOf(Date.today()+1);
        OpportunityCls.CoDateOfBirth = String.valueOf(Date.today()-1);
         OpportunityCls.PersonBirthDate=String.valueOf(Date.today()-300);
        OpportunityCls.PersonMailingState='GA';
        OpportunityCls.PersonMailingPostalCode='34322';
        OpportunityCls.CoCity='Test1';
        OpportunityCls.CoState='GA';
        OpportunityCls.PaidAccumulation = '1';
            OpportunityCls.PaidAdminFee = '1';
            OpportunityCls.PaidCreditorPayments = '1';
            OpportunityCls.PaidMaintenanceFee = '1';
            OpportunityCls.PaidProcessorFee = '1';
            OpportunityCls.PaidProgramFee = '1';
            OpportunityCls.PaidRetainerFee = '1';
            OpportunityCls.PaidServiceFee= '1';
            OpportunityCls.PaidThirdPartyFee = '1';
            OpportunityCls.TotalAccumulation = '1';
            OpportunityCls.TotalAdminFee = '1';
            OpportunityCls.TotalCreditorPayments = '1';
            OpportunityCls.TotalMaintenanceFee = '1';
            OpportunityCls.TotalProcessorFee='1';
            OpportunityCls.TotalProgramFee = '1';
            OpportunityCls.TotalRetainerFee = '1';
            OpportunityCls.TotalServiceFee = '1';
            OpportunityCls.TotalThirdPartyFee = '1';
            OpportunityCls.RemainingAccumulation = '1';
            OpportunityCls.RemainingAdminFee = '1';
            OpportunityCls.RemainingCreditorPayments = '1';
            OpportunityCls.RemainingMaintenanceFee = '1';
            OpportunityCls.RemainingProcessorFee = '1';
            OpportunityCls.RemainingProgramFee ='1';
            OpportunityCls.RemainingRetainerFee = '1';
            OpportunityCls.RemainingServiceFee = '1';
            OpportunityCls.RemainingThirdPartyFee = '1';
            
        
        OpportunityJSONClass.Cls_Payments Payment = new OpportunityJSONClass.Cls_Payments();
        Payment.FileNumber = '1234567';
        Payment.TotalAmount='12';
        OpportunityCls.Payments.add(Payment);
        
        OpportunityJSONClass.Cls_Tradelines Tradeline = new OpportunityJSONClass.Cls_Tradelines();
        Tradeline.OriginalDebt = '1234';
        Tradeline.FileNumber = '1234567';
        Tradeline.SFSCurrentBalance='12';
        Tradeline.OfferAmount='10';
        Tradeline.OfferProgramFee='9';
        Tradeline.SettlementAmountPaid='8';
        Tradeline.AmountPaid='7';
        Tradeline.DNLEstimatedSettlement='8';
        Tradeline.DNLFundstoClient='8';
        Tradeline.DNLFundsforFees='9';
        Tradeline.DNLDisbursementAmount='9';
        Tradeline.DNLSettlementFees='9';
        Tradeline.DNLfirstSettelment='true';
        Tradeline.NewAccountNumber='33333';
        Tradeline.SettelmentPayments = new List<OpportunityJSONClass.cls_SettelmentPayments>();
        Tradeline.DNLDisbursementDate=String.valueOf(Date.today()+1);
        OpportunityJSONClass.cls_SettelmentPayments SetPayment = new OpportunityJSONClass.cls_SettelmentPayments();
        SetPayment.FileNumber = '1234567';
        
        Tradeline.SettelmentPayments.add(SetPayment);
        
        OpportunityCLs.Tradelines.add(Tradeline);
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Prospecting';
        opp.Description = 'Test';
        opp.Name = 'Test';
        //opp.OwnerId='F0050m000001ccZ';
        opp.CloseDate = Date.Today()+1;
        opp.Import_Id__c = '0060S0000068D7WQAU';
        insert opp;//
         Id DNLTaskId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId(); //PDI-600
 
        Task t = new Task();
        t.Priority = 'Medium';
        t.Status = 'New';
        t.ActivityDate = Date.today();
        t.Subject = 'Test';
        t.RecordTypeId = DNLTaskId; 
        t.ownerId=opp.ownerId;  
        
        OpportunityCls.Tasks = new List<Task>();
        OpportunityCls.Tasks.add(t);
        
        jsonClass.Opportunity = new List<OpportunityJSONClass.cls_Opportunity>();
        jsonClass.Opportunity.add(OpportunityCls);
        try{
           CreateOrUpdateRecordService.CreateopportunityAccount(JSON.serialize(jsonClass),false); 
        }
        catch(Exception e)
        {
            system.debug('ERR'+e.getMessage());
        }
        
    }
    
}