/**
* Class Name  : NuDebtProgramWrapper
* 
* 
* Description : Wrapper class for NuDebt-Program
* 
* 
* Author      : Kimi Shrivastava
* 
*/
public class NuDebtProgramWrapper {
    public List<ProgramWrapper> programs {get;set;}
    public class ProgramWrapper {
        public String programName{get;set;}
        public String programNameText{get;set;}
        public Decimal programLength {get;set;}
        public String processorName{get;set;}
        public String portfolioType {get;set;}	        
        public String campaignType {get;set;}
        public String programType{get;set;}
        public String salesRep{get;set;}
        public String applicantState{get;set;}
        public String email{get;set;}
        public String socialSecurityNumber {get;set;}
        public String coFirstName {get;set;}
        public String coLastName {get;set;}
        public String coPhone {get;set;}
        public String coEmail {get;set;}
        public String coApplicantState {get;set;}
        public String coApplicantSSN {get;set;}
        public String account	{get;set;}
        public String firstName {get;set;}
        public String middleName 	{get;set;}
        public String lastName {get;set;}
        public String paymentFrequency {get;set;}
        public Decimal lastDraft 	{get;set;}
        public Decimal unsettledDebt 	{get;set;}
        public Date birthDate 	{get;set;}
        public String Phone 		{get;set;}
        public String cellPhone	{get;set;}
        public String bestPhone	{get;set;}
        public String homePhone	{get;set;}
        public String mobilePhone 	{get;set;}
        public String personOtherPhone {get;set;}
        public Boolean latestLead {get;set;}
        public String fileNumber {get;set;}   
        public String leadId {get;set;} 
        public String leadStatus {get;set;} 
        public date enrollmentDate {get;set;}
        public String portfolio {get;set;}
        public String portfolioName {get;set;}
        public String portfolioSupportEmail {get; set;}
        public String portfolioRetentionEmail {get;set;}
        public String portfolioCommunicationTemplateEmail {get; set;}
        
        // public String leadNumber{get;set;}
        
        
    } 
    public List<TradelinesWrapper> tradelines {get;set;}
    public class TradelinesWrapper{
        
        public Id tradelinesId {get;set;}  
        public String name {get;set;}  
        public Id programId {get;set;}   
        public String fileNumber {get;set;}   
        public String leadId {get;set;}   
        public String OfferAmount{get;set;}
        public String OfferProgramFee{get;set;}
        public String SettlementAmountPaid{get;set;}
        public String AmountPaid{get;set;}
        public String DNLEstimatedSettlement{get;set;}
        public String DNLFundstoClient{get;set;}
        public String DNLFundsforFees{get;set;}
        public String DNLDisbursementAmount{get;set;}
        public String DNLSettlementFees{get;set;}
        public String DNLDisbursementDate{get;set;}
        public String DNLfirstSettelment{get;set;}
        public String SFSCurrentBalance{get;set;}
        public String NewAccountNumber{get;set;}
        public String NewCreditor{get;set;}
        public String OfferStatus{get;set;}
        public String CurrentStage{get;set;}
        public String LitigationStage{get;set;}
        public String OriginalAccountNumber{get;set;}
        public String OriginalCreditorName{get;set;}
        public String OriginalDebt{get;set;}
        public List<PaymentsWrapper> settlementPayments {get;set;}
    }
    public List<PaymentsWrapper> payments {get;set;}
    public class PaymentsWrapper{
        
        public Id paymentsId {get;set;}  
        public String name {get;set;}  
        public Id programId {get;set;}   
        public String fileNumber {get;set;}   
        public String leadId {get;set;}  
        public String NFSDate {get;set;} 
        public String TransactionStatus {get;set;} 
        public String PaymentType {get;set;} 
        public String ScheduleDate {get;set;} 
        public String TotalAmount {get;set;} 
        public String TransMethod {get;set;} 
        public String PayRecType {get;set;} 
        public String PaymentStatus {get;set;} 
    }
    public List<DraftFeesWrapper> draftFeesList {get;set;}
    public class DraftFeesWrapper{           
        
        public Id programId {get;set;}   
        public Decimal paidAccumulation {get;set;}  
        public Decimal paidAdminFee {get;set;}  
        public Decimal paidCreditorPayments {get;set;}  
        public Decimal paidMaintenanceFee {get;set;}  
        public Decimal paidProcessorFee {get;set;}  
        public Decimal paidProgramFee {get;set;}  
        public Decimal paidRetainerFee {get;set;}  
        public Decimal paidServiceFee {get;set;}  
        public Decimal paidThirdPartyFee {get;set;}  
        public Decimal remainingAccumulation {get;set;}  
        public Decimal remainingAdminFee {get;set;}  
        public Decimal remainingCreditorPayments {get;set;}  
        public Decimal remainingMaintenanceFee {get;set;}  
        public Decimal remainingProcessorFee {get;set;}  
        public Decimal remainingProgramFee {get;set;}  
        public Decimal remainingRetainerFee {get;set;}  
        public Decimal remainingServiceFee {get;set;}  
        public Decimal remainingThirdPartyFee {get;set;}  
        public Decimal totalAccumulation {get;set;}  
        public Decimal totalAdminFee {get;set;}  
        public Decimal totalCreditorPayments {get;set;}  
        public Decimal totalMaintenanceFee {get;set;}  
        public Decimal totalProcessorFee {get;set;}  
        public Decimal totalProgramFee {get;set;}  
        public Decimal totalRetainerFee {get;set;}  
        public Decimal totalServiceFee {get;set;}  
        public Decimal totalThirdPartyFee {get;set;} 
    }
}