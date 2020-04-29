@isTest
public class Test_NuDebtProgramWrapper {
    
    @isTest
    public static void Test_SetNuDebtWrapperData(){
        NuDebtPRogramWrapper nuDebtProgramWrapper = new NuDebtProgramWrapper();
        NuDebtProgramWrapper.ProgramWrapper programWrapper = new  NuDebtProgramWrapper.ProgramWrapper ();
        NuDebtProgramWrapper.TradelinesWrapper tradelinesWrapper = new  NuDebtProgramWrapper.TradelinesWrapper ();
        NuDebtProgramWrapper.PaymentsWrapper paymentsWrapper = new  NuDebtProgramWrapper.PaymentsWrapper ();
        NuDebtProgramWrapper.DraftFeesWrapper draftFeesWrapper = new  NuDebtProgramWrapper.DraftFeesWrapper ();
        
        programWrapper.fileNumber = '1234';
        programWrapper.programName = '1234';
        programWrapper.programNameText = 'test name';
        programWrapper.programType = 'test type';
        programWrapper.email = 'testing@123.com';
        programWrapper.applicantState = 'New York' ;
        programWrapper.socialSecurityNumber = '12345678' ;
        programWrapper.coFirstName = 'First Name' ;
        programWrapper.coLastName= 'LastName'  ;
        programWrapper.coPhone= '12345667' ;
        programWrapper.coEmail = 'testingco@123.com' ;
        programWrapper.coApplicantState = 'New York';
        programWrapper.coApplicantSSN = '12345678';
        programWrapper.account = 'Account';
        programWrapper.firstName = 'firstName'; 	
        programWrapper.middleName = 'testing'; 	
        programWrapper.lastName = 'testing'; 	
        programWrapper.paymentFrequency = 'testing'; 	
        programWrapper.lastDraft = 12; 	
        programWrapper.unsettledDebt = 345; 	
        programWrapper.birthDate = Date.today(); 	
        programWrapper.phone = 'testing'; 	
        programWrapper.cellPhone = 'testing'; 	
        programWrapper.bestPhone = 'testing'; 	
        programWrapper.homePhone = 'testing'; 	
        programWrapper.mobilePhone = 'testing'; 	
        programWrapper.personOtherPhone ='testing'; 	
        programWrapper.enrollmentDate = Date.today(); 	
        programWrapper.paymentFrequency = 'testing'; 	
        programWrapper.programLength = 24; 	
        programWrapper.processorName ='testing'; 	
        programWrapper.salesRep ='testing'; 	
        programWrapper.campaignType = 'testing'; 	
        programWrapper.portfolio = 'testing'; 	
        programWrapper.portfolioName = 'testing'; 	
        programWrapper.portfolioSupportEmail = 'testing'; 	
        programWrapper.portfolioRetentionEmail = 'testing'; 	
        programWrapper.portfolioCommunicationTemplateEmail = 'testing'; 	
        programWrapper.portfolioType = 'Attorney'; 
        programWrapper.latestLead = true;
        programWrapper.leadId = '1234';
        programWrapper.leadStatus = 'DNL New Lead';
        List<NuDebtProgramWrapper.ProgramWrapper> programWrpList = new List<NuDebtProgramWrapper.ProgramWrapper>();
        programWrpList.add(programWrapper);
        nuDebtProgramWrapper.programs = programWrpList;
        
        
        paymentsWrapper = new NuDebtProgramWrapper.PaymentsWrapper();
        //paymentsWrapper.paymentsId = '1234';
        //paymentsWrapper.programId = 'testing';
        //paymentsWrapper.leadId = 'testing';
        paymentsWrapper.Name = 'testing';
        paymentsWrapper.FileNumber = 'testing';
        paymentsWrapper.NFSDate = String.ValueOf(Date.today());
        paymentsWrapper.PaymentStatus = 'testing';
        paymentsWrapper.PaymentType = 'testing';
        paymentsWrapper.ScheduleDate = String.ValueOf(Date.today());
        paymentsWrapper.TotalAmount = String.ValueOf(1234);
        paymentsWrapper.TransMethod = 'testing';
        paymentsWrapper.TransactionStatus = 'testing'; 
        
        List<NuDebtProgramWrapper.PaymentsWrapper> paymentWrpList = new List<NuDebtProgramWrapper.PaymentsWrapper>();
        paymentWrpList.add(paymentsWrapper);
        nuDebtProgramWrapper.payments = paymentWrpList;
        
        tradelinesWrapper = new NuDebtProgramWrapper.TradelinesWrapper();
        tradelinesWrapper.tradelinesId = Id.valueOf('0062f00000C8wsgAAB');
        tradelinesWrapper.name = 'testing';
        tradelinesWrapper.OfferAmount = '123';
		tradelinesWrapper.OfferProgramFee = '12';
		tradelinesWrapper.DNLfirstSettelment = '123';
        tradelinesWrapper.programId =  Id.valueOf('0062f00000C8wsgAAC');
        tradelinesWrapper.leadId =  Id.valueOf('0062f00000C8wsgAAD');
        tradelinesWrapper.fileNumber =  'testing';
        tradelinesWrapper.CurrentStage =  'testing';
        tradelinesWrapper.LitigationStage =  'testing';
        tradelinesWrapper.DNLEstimatedSettlement = String.valueOf( 'testing');
        tradelinesWrapper.OriginalAccountNumber =  'testing';        
        tradelinesWrapper.SFSCurrentBalance = String.ValueOf( 'testing');   
        tradelinesWrapper.NewAccountNumber =  'testing';  
        tradelinesWrapper.NewCreditor =  'testing';         
        tradelinesWrapper.OriginalDebt ='testing';
        tradelinesWrapper.DNLFundsForFees = 'testing';
        tradelinesWrapper.DNLFundstoClient = 'testing';
        tradelinesWrapper.DNLDisbursementDate = 'testing';
        tradelinesWrapper.DNLDisbursementAmount = 'testing';
        tradelinesWrapper.DNLSettlementFees = 'testing';   
        tradelinesWrapper.SettlementAmountPaid = 'testing';
        tradelinesWrapper.AmountPaid = 'testing';
        tradelinesWrapper.OfferStatus = 'testing';
        tradelinesWrapper.OriginalCreditorName = 'testing'; 
        
        
        List<NuDebtProgramWrapper.TradelinesWrapper> tradelinesWrpList = new List<NuDebtProgramWrapper.TradelinesWrapper>();
        tradelinesWrpList.add(tradelinesWrapper);
        nuDebtProgramWrapper.tradelines = tradelinesWrpList;
        
        
        paymentsWrapper.paymentsId = Id.valueOf('0062f00000C8wsgAAC');
        paymentsWrapper.programId = Id.valueOf('0062f00000C8wsgAAD');
        paymentsWrapper.leadId = Id.valueOf('0062f00000C8wsgAAE');
        paymentsWrapper.Name = 'testing';
        paymentsWrapper.PaymentStatus = 'testing';
        paymentsWrapper.PaymentType = 'testing';
        paymentsWrapper.TransMethod = 'testing';
        paymentsWrapper.TransactionStatus = 'testing';
        paymentsWrapper.ScheduleDate = 'testing';
        paymentsWrapper.TotalAmount = 'testing'; 
        paymentsWrapper.NFSDate = 'testing';
        paymentsWrapper.PayRecType = 'testing';
        
        draftFeesWrapper.programId = Id.valueOf('0062f00000C8wsgAAD');
        draftFeesWrapper.PaidAccumulation = 123;
        draftFeesWrapper.PaidAdminFee = 123;
        draftFeesWrapper.PaidCreditorPayments = 123;
        draftFeesWrapper.PaidMaintenanceFee = 123;
        draftFeesWrapper.PaidProcessorFee = 123;
        draftFeesWrapper.PaidProgramFee = 123;          
        draftFeesWrapper.PaidRetainerFee = 123;           
        draftFeesWrapper.PaidServiceFee = 123;           
        draftFeesWrapper.PaidThirdPartyFee = 123;           
        draftFeesWrapper.TotalAccumulation = 123;
        draftFeesWrapper.TotalAdminFee = 123;                
        draftFeesWrapper.TotalCreditorPayments = 123;           
        draftFeesWrapper.TotalMaintenanceFee = 123;            
        draftFeesWrapper.TotalProcessorFee = 123;             
        draftFeesWrapper.TotalProgramFee = 123;          
        draftFeesWrapper.TotalRetainerFee = 123;           
        draftFeesWrapper.TotalServiceFee = 123;
        draftFeesWrapper.TotalThirdPartyFee = 123;
        draftFeesWrapper.RemainingAccumulation = 123;                       
        draftFeesWrapper.RemainingAdminFee = 123;                
        draftFeesWrapper.RemainingCreditorPayments = 123;            
        draftFeesWrapper.RemainingMaintenanceFee = 123;            
        draftFeesWrapper.RemainingProcessorFee = 123;             
        draftFeesWrapper.RemainingProgramFee = 123;           
        draftFeesWrapper.RemainingRetainerFee = 123;           
        draftFeesWrapper.RemainingServiceFee = 123;
        draftFeesWrapper.RemainingThirdPartyFee = 123;

    }
}