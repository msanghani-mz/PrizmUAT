/*
 * Class Name : TILADashboardObject
 * Purpose    : This class is used as a data structure required to 
 *              populate the details on the TILA Dashboard
 * Developer  : Financial Spectra
 */
public class TILADashboardObject {
    
    public Date       finalApprovalDate             {get; set;}
    public String     finalApprovalDateStr          {get; set;}
    public String     dnlApplicationDate            {get; set;}
    public String     loanNumber                    {get; set;}
    public String     clientId                      {get; set;}
    public CustomerInformation     applicantInformation                    {get; set;}  
    public CustomerInformation     coApplicantInformation                    {get; set;}  
    public Decimal    interestRate                  {get; set;}
    public Decimal    apr                           {get; set;}
    public Decimal    originationFee                {get; set;} 
    public Decimal    prepaidFinanceCharge          {get; set;}
    public String     DRPProgramName                {get; set;}
    public String     DRPProgramType                {get; set;}
    public String     paymentProcessor              {get; set;}
    public String     estdraftFrequency             {get; set;}
    public Decimal    estdraftAmount                {get; set;} 
    public Date       nextDRPDraftDate              {get; set;}
    public String     nextDRPDraftDateStr           {get; set;}
    public String     estFinalDRPDraftDate          {get; set;}
    public Date       estDisbursementDate           {get; set;}
    public String     estDisbursementDateStr        {get; set;}
    public String     estFirstRepaymentDateStr      {get; set;}
    public Date       estFirstRepaymentDate         {get; set;}
    public Decimal    estCashInDedicatedAccount     {get; set;} 
    public Decimal    estOneMonthPaymentToDRP       {get; set;} 
    public Decimal    estRemFeeDueToDRP             {get; set;} 
    public Decimal    estSettlementDisbursements    {get; set;} 
    public Decimal    estOriginationFee             {get; set;} 
    public Decimal    estPrepaidFinanceCharge       {get; set;} 
    public Decimal    estLoanAmount                 {get; set;} 
    public Decimal    plusFinanceCharge             {get; set;}
    public Decimal    totalOfPayments               {get; set;} 

    public Decimal    estTotalOriginalEnrolledBal   {get; set;} 
    public Decimal    estTotalCurrentEnrolledBal    {get; set;} 
    public Decimal    estNetSettlementPercentage    {get; set;} 
    public Decimal    estTotalSettlementBal         {get; set;}

    public String     actualFinalDRPDraftDate       {get; set;}
    public String     actualDisbursementDateStr     {get; set;}
    public Date       actualDisbursementDate        {get; set;}
    public String     actualFirstRepaymentDateStr   {get; set;}
    public Date       actualFirstRepaymentDate      {get; set;}
    public Date       actualSecondRepaymentDate      {get; set;}
    public String     actualdraftFrequency          {get; set;}
    public Decimal    actualdraftAmount             {get; set;} 
    public Decimal    actualCashInDedicatedAccount  {get; set;} 
    public Decimal    actualOneMonthPaymentToDRP    {get; set;} 
    public Decimal    actualRemFeeDueToDRP          {get; set;} 
    public Decimal    actualSettlementDisbursements {get; set;} 
    public Decimal    actualOriginationFee          {get; set;} 
    public Decimal    actualPrepaidFinanceCharge    {get; set;} 
    public Decimal    actualLoanAmount              {get; set;} 
    public Decimal    actualTotalSettlementAmount   {get; set;} 
    public Decimal    actualTotalSettlementFee      {get; set;} 
    public Decimal    actualTotalVersaraDisbAmount  {get; set;} 
    public Decimal    actualTotalPrepaidCharge      {get; set;}     
    
    public List<RepaymentSchedule>  repaymentScheduleList {get; set;}
    public List<PreSettlementItemizations>    preSettlementItemizationsList              {get; set;} 
    public List<PostSettlementItemizations>   postSettlementItemizationsList             {get; set;} 

    public TilaDashboardObject(){
        finalApprovalDate              = null;
        finalApprovalDateStr           = '';
        dnlApplicationDate             = '';
        loanNumber                     = '';
        clientId                       = '';
        interestRate                   = 0.00;
        apr                            = null;
        originationFee                 = 0.00; 
        prepaidFinanceCharge           = 0.00;
        DRPProgramName                 = '';
        DRPProgramType                 = '';
        paymentProcessor               = '';
        estdraftFrequency              = '';
        estdraftAmount                 = 0.00; 
        nextDRPDraftDate               = null;
        nextDRPDraftDateStr            = '';
        estFinalDRPDraftDate           = '';
        estDisbursementDate            = null;
        estDisbursementDateStr         = '';
        estFirstRepaymentDate          = null;
        actualSecondRepaymentDate      = null;
        estFirstRepaymentDateStr       = '';
        estCashInDedicatedAccount      = 0.00; 
        estOneMonthPaymentToDRP        = 0.00; 
        estRemFeeDueToDRP              = 0.00; 
        estSettlementDisbursements     = 0.00; 
        estOriginationFee              = 0.00; 
        estPrepaidFinanceCharge        = 0.00; 
        estLoanAmount                  = 0.00; 
        plusFinanceCharge              = 0.00;
        totalOfPayments                = 0.00;
        
        actualFinalDRPDraftDate        = '';
        actualDisbursementDate         = null;
        actualFirstRepaymentDate       = null;
        actualDisbursementDateStr      = '';
        actualFirstRepaymentDateStr    = '';

        actualdraftFrequency           = '';
        actualdraftAmount              = 0.00; 
        actualCashInDedicatedAccount   = 0.00; 
        actualOneMonthPaymentToDRP     = 0.00; 
        actualRemFeeDueToDRP           = 0.00; 
        actualSettlementDisbursements  = 0.00;
        actualOriginationFee           = 0.00;
        actualPrepaidFinanceCharge     = 0.00;
        actualLoanAmount               = 0.00;
        estTotalOriginalEnrolledBal    = 0.00;
        estTotalCurrentEnrolledBal     = 0.00;
        estNetSettlementPercentage     = 0.00;
        estTotalSettlementBal          = 0.00;
        actualTotalSettlementAmount = 0.00;
        actualTotalPrepaidCharge = 0.00;
        actualTotalVersaraDisbAmount = 0.00;
        actualTotalSettlementFee = 0.00;        

        repaymentScheduleList = new List<RepaymentSchedule>();
        preSettlementItemizationsList = new List<PreSettlementItemizations>();
        postSettlementItemizationsList = new List<PostSettlementItemizations>();

    }

    public class CustomerInformation { 
        public String     clientId                      {get; set;}
        public String     contactId                     {get; set;}
        public String     clientName                    {get; set;}
        public String     clientEmail                   {get; set;}
        public String     homeStreet                    {get; set;}
        public String     homeCity                      {get; set;} 
        public String     homeState                     {get; set;}
        public String     homeZip                       {get; set;}
        public String     homePhone                     {get; set;}
        public String     mobilePhone                   {get; set;}

        public CustomerInformation(){
            clientId                       = '';  
            contactId                      = '';  
            clientName                     = '';  
            clientEmail                    = '';  
            homeStreet                     = '';
            homeCity                       = ''; 
            homeState                      = '';
            homeZip                        = '';
            homePhone                      = '';
            mobilePhone                    = '';
        }
    }

    public class RepaymentSchedule {
        public Decimal numberOfPayments {get; set;}
        public Decimal paymentAmount {get; set;}
        
        public RepaymentSchedule(){
           
            numberOfPayments = 0.00;
            paymentAmount    = 0.00;
         
        }
        
    }

    public class PreSettlementItemizations { 
        public String  originalCreditor             {get; set;}
        public String  currentCreditor              {get; set;}
        public Decimal originalEnrolledBalance      {get; set;}
        public Decimal estimatedEnrolledBalance     {get; set;}
        public Decimal estimatedSettlementPercentage{get; set;}
        public Decimal estimatedSettlementBalance   {get; set;}
        
        public PreSettlementItemizations(){
            originalCreditor                 = '';
            currentCreditor                  = '';
            originalEnrolledBalance          = 0.00;
            estimatedEnrolledBalance         = 0.00;
            estimatedSettlementPercentage    = 0.00;
            estimatedSettlementBalance       = 0.00;
        }
    }

    public class PostSettlementItemizations { 
        public String  currentCreditor              {get; set;}
        public String  actualDisbursementDate       {get; set;}
        public Decimal actualSettlementAmount       {get; set;}
        public Decimal actualSettlementFee          {get; set;}
        public Decimal actualVersaraDisbAmount      {get; set;}
        public Decimal actualPrepaidCharge          {get; set;}

        
        public PostSettlementItemizations(){
            currentCreditor             = '';
            actualDisbursementDate      = NULL;
            actualSettlementAmount      = 0.00;
            actualSettlementFee         = 0.00;
            actualVersaraDisbAmount     = 0.00;
            actualPrepaidCharge         = 0.00;
        }
    }

}