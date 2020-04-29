/*
* Class Name : TILADashboardController
* Purpose    : Controller class for TILA Dashboard page
* Developer  : Financial Spectra
*/
public with sharing class TILADashboardController {
    private static final String CLASS_NAME = 'TILADashboardController';
    
    public String mEnvelopeId {get;set;}
    public String mEnvelopeStatus {get;set;}
    public String mValidationFailureMessage {get;set;}
    public Boolean mApplicationApprovalRequired {get;set;}
    
    private static String mPreTilaDdpLabel;
    private static String mPreTilaFilter;
    private static String mPostTilaFilter = 'PostTila';
    
    
    public Boolean mValidationsPassed {get; private set;}
    public Boolean mEnvelopeAlreadySent {get; private set;}
    
    public TILADashboardObject mTILAObj {get; private set;}
    public fsCore__Lending_Application__c mApplication {get; private set;}
    private List<fsCore__Lending_Application_Customer__c> mApplicationCustomerList {get;set;}
    public static String mPreTilaDocumentType = 'Pre-Tila';
    public Boolean mIsCoapplicantExist {get; private set;}
    
    private String mDedicatedAmountCash = SFS_System_Settings__c.getInstance().DNL_Cash_In_Dedicated_Itm__c;
    private String mDrpOneMonthPayment = SFS_System_Settings__c.getInstance().DNL_One_Mth_Payment_Itm__c;
    private String mRemainingFeeDueDrp = SFS_System_Settings__c.getInstance().DNL_Rem_Fee_Due_DRP_Itm__c;
    private Set<String> resentEligibleMapStatusSet = new Set<String>{'Voided','Declined','Expired'};      
        
        
        private static final String DATE_FORMAT = 'MMM dd, yyyy';
    
    private void queryApplication(){
        
        mApplication = [SELECT id
                        , name
                        , Opportunity_Name__r.DRP_Name__c
                        , Opportunity_Name__r.Program_Type__c 
                        , Payment_Processor_Name__c
                        , Portfolio_Type__c
                        , Opportunity_Name__r.Law_Firm_Name__c
                        , BoxFolderId__c
                        , Opportunity_Name__c
                        , Monthly_Legal_Fee__c
                        , fsCore__Primary_Customer_Account__r.Import_BoxFolderId__c
                        , fsCore__Payment_Amount__c
                        , Monthly_Processor_Fee__c
                        , Monthly_Third_Party_Fees__c
                        , Is_PreTILA_Signed__c
                        , fsCore__Rate__c
                        , fsCore__Annual_Percent_Rate__c
                        , PreTila_Vaulting_Method__c
                        , fsCore__Decision_Updated_On__c
                        , fsCore__Pricing_Name__c
                        , fsCore__Approved_Prepaid_Fee__c
                        , fsCore__Approved_Finance_Fee__c
                        , fsCore__Application_Date__c
                        , fsCore__Financed_Amount__c
                        , fsCore__Approved_Financed_Amount__c
                        , fsCore__Payment_Cycle__c
                        , Primary_Customer_State__c
                        , fsCore__Maturity_Date__c
                        , fsCore__Contract_Date__c
                        , fsCore__Payment_Start_Date__c
                        , fsCore__Requested_Payment_Cycle__c
                        , fsCore__State__c
                        , fsCore__Loan_Amount__c
                        , fsCore__Actual_Prepaid_Fee__c
                        , fsCore__Actual_Finance_Fee__c
                        , Is_Final_Contract_Generated__c
                        , Final_Approval_Date__c
                        , Next_DRP_Draft_Date__c
                        , fsCore__Contract_Template_Name__c
                        , fsCore__Number_Of_Payments__c
                        , fsCore__Payment_Due_Day__c
                        , fsCore__Payment_Due_Day_2__c
                        , fsCore__Pricing_Name__r.fsCore__Financed_Amount_Maximum__c
                        , fsCore__Pricing_Name__r.fsCore__Financed_Amount_Minimum__c
                        , fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Minimum__c
                        , fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Maximum__c
                        , fsCore__Pricing_Name__r.fsCore__Rate_Value_Minimum__c
                        , fsCore__Pricing_Name__r.fsCore__Rate_Value_Maximum__c
                        , Loan_Officer__c
                        , Original_Enrolled_Debt__c
                        , fsCore__Title__c
                        , Underwriter__c
                        , Loan_Officer__r.firstName
                        , Loan_Officer__r.LastName
                        , Prepaid_Fee_Enabled__c
                        , Finance_Fee_Enabled__c
                        , (SELECT id
                           , Name
                           , Opportunity_Name__c
                           , Paid_Accumulation__c
                           , Paid_Admin_Fee__c
                           , Paid_Creditor_Payments__c
                           , Paid_Maintenance_Fee__c
                           , Paid_Processor_Fee__c
                           , Paid_Program_Fee__c
                           , Paid_Retainer_Fee__c
                           , Paid_Service_Fee__c
                           , Paid_Third_Party_Fee__c
                           , Program_ID__c
                           , Remaining_Accumulation__c
                           , Remaining_Admin_Fee__c
                           , Remaining_Creditor_Payments__c
                           , Remaining_Maintenance_Fee__c
                           , Remaining_Processor_Fee__c
                           , Remaining_Program_Fee__c
                           , Remaining_Retainer_Fee__c
                           , Remaining_Service_Fee__c
                           , Remaining_Third_Party_Fee__c
                           , Total_Accumulation__c
                           , Total_Admin_Fee__c
                           , Total_Creditor_Payments__c
                           , Total_Maintenance_Fee__c
                           , Total_Processor_Fee__c
                           , Total_Program_Fee__c
                           , Total_Retainer_Fee__c
                           , Total_Service_Fee__c
                           , Total_Third_Party_Fee__c
                           FROM NuDebt_Draft_Fee__r)
                        , ( SELECT Id
                           , fsCore__Number_Of_Payments__c
                           , fsCore__Payment_Amount__c 
                           FROM fsCore__Lending_Application_Repayment_Schedule__r)
                        , ( SELECT Id
                           , Name
                           , Current_Creditor__c
                           , Original_Creditor__c
                           , DNL_Original_Enrolled_Balance__c
                           , Estimated_Settlement_Balance__c
                           , Estimated_Settlement_Percent__c
                           , fsCore__Actual_Amount_Signed__c
                           , fsCore__Actual_Amount_Unsigned__c
                           , DNL_Funds_to_Client__c
                           , fsCore__Approved_Amount_Signed__c
                           , fsCore__Approved_Amount_Unsigned__c
                           , fsCore__Itemization_Family__c
                           , fsCore__Itemization_Name_Formula__c
                           , fsCore__Itemization_Name__c
                           , fsCore__Lending_Application_Number__c
                           , fsCore__Original_Amount_Signed__c
                           , fsCore__Original_Amount_Unsigned__c
                           , fsCore__Plus_Or_Minus__c
                           , fsCore__Requested_Amount_Signed__c
                           , DNL_Actual_Prepaid_Finance_Charge__c
                           , fsCore__Requested_Amount_Unsigned__c
                           , fsCore__Source__c
                           , Disbursement_Date__c
                           , DNL_Settlement_Fees__c
                           , fsCore__Itemization_Name__r.fsCore__Itemization_Code__c                                 
                           FROM fsCore__Lending_Application_Itemization__r)
                           , fsCore__Total_Financial_Charge__c
                           , fsCore__Total_Of_Payments__c
                        FROM fsCore__Lending_Application__c
                        WHERE id = :mApplication.id];
        System.debug(mApplication.Is_PreTILA_Signed__c);
        mApplicationApprovalRequired = false;
        if (!mApplication.Is_PreTILA_Signed__c){
            if (mApplication.Final_Approval_Date__c == null){
                mApplicationApprovalRequired = true;
            }
            if (mApplication.fsCore__Financed_Amount__c == null){
                mApplicationApprovalRequired = true;
            }else{
                if (mApplication.fsCore__Financed_Amount__c <> mApplication.fsCore__Approved_Financed_Amount__c){
                    mApplicationApprovalRequired = true;
                }
            }
        }
    }
    
    public TILADashboardController(ApexPages.StandardController pStdController){
        mApplication = (fsCore__Lending_Application__c)pStdController.getRecord();
        queryApplication();
        
        mApplicationCustomerList = [SELECT Id, Name
                                    , fsCore__Account_Name__c
                                    , fsCore__Customer_Record_Type__c
                                    , fsCore__Customer_Type__c
                                    , fsCore__Is_Primary__c
                                    , fsCore__Lending_Application_Number__c
                                    , fsCore__Account_Name__r.PersonOtherAddress
                                    , fsCore__Account_Name__r.PersonContactId
                                    , fsCore__Account_Name__r.PersonOtherCity
                                    , fsCore__Account_Name__r.PersonOtherCountry
                                    , fsCore__Account_Name__r.PersonOtherCountryCode
                                    , fsCore__Account_Name__r.PersonOtherGeocodeAccuracy
                                    , fsCore__Account_Name__r.PersonOtherLatitude
                                    , fsCore__Account_Name__r.PersonOtherLongitude
                                    , fsCore__Account_Name__r.PersonOtherPhone
                                    , fsCore__Account_Name__r.PersonOtherPostalCode
                                    , fsCore__Account_Name__r.PersonOtherState
                                    , fsCore__Account_Name__r.PersonOtherStateCode
                                    , fsCore__Account_Name__r.PersonOtherStreet
                                    , fsCore__Account_Name__r.PersonEmail
                                    , fsCore__Account_Name__r.PersonTitle
                                    , fsCore__Account_Name__r.Client_Number__c
                                    , fsCore__Account_Name__r.PersonHomePhone
                                    , fsCore__Account_Name__r.PersonMobilePhone             
                                    , fsCore__Account_Name__r.Name    
                                    FROM fsCore__Lending_Application_Customer__c 
                                    WHERE fsCore__Lending_Application_Number__c = :mApplication.Id];
        
        mTILAObj = new TILADashboardObject();
        mIsCoapplicantExist = false;
        
        if (mApplication.Id != null){
            populateTILAObject();
        }
    }
    
    public PageReference onClose(){
        PageReference appRecPage = new PageReference('/' + String.valueof(mApplication.Id));
        appRecPage.setRedirect(true);
        return appRecPage;
    }
    
    private void populateTILAObject(){
        
        
        //PDI-398 - ALL THE DATE RELATED CHANGES
        
        if (mApplication.Final_Approval_Date__c != null){
            mTILAObj.finalApprovalDate = mApplication.Final_Approval_Date__c;
            mTILAObj.finalApprovalDateStr = getFormattedDate(mTILAObj.finalApprovalDate);
        }else{
            mTILAObj.finalApprovalDate = System.Today();
            mTILAObj.finalApprovalDateStr = getFormattedDate(mTILAObj.finalApprovalDate);
        }
        
        //PDI-398
        if (mApplication.fsCore__Application_Date__c != null){
            mTILAObj.dnlApplicationDate = getFormattedDate(mApplication.fsCore__Application_Date__c);
        }
        
        mTILAObj.loanNumber = mApplication.Name;
        
        system.debug(logginglevel.error,' Primary :'+mApplicationCustomerList.size());
        For (fsCore__Lending_Application_Customer__c customer: mApplicationCustomerList){
            system.debug(logginglevel.error,' Primary :'+customer.fsCore__Customer_Type__c);
            if (customer.fsCore__Customer_Type__c == 'Primary'){
                system.debug(logginglevel.error,' Primary :'+customer.fsCore__Account_Name__r);
                mTILAObj.clientId                                             = customer.fsCore__Account_Name__r.Client_Number__c;
                mTILAObj.applicantInformation                                 = new TILADashboardObject.CustomerInformation();
                mTILAObj.applicantInformation.clientId                        = customer.fsCore__Account_Name__r.Id;
                mTILAObj.applicantInformation.contactId                       = customer.fsCore__Account_Name__r.PersonContactId;
                mTILAObj.applicantInformation.clientName                      = customer.fsCore__Account_Name__r.Name;
                mTILAObj.applicantInformation.clientEmail                     = customer.fsCore__Account_Name__r.PersonEmail;
                mTILAObj.applicantInformation.homeStreet                      = customer.fsCore__Account_Name__r.PersonOtherStreet;
                mTILAObj.applicantInformation.homeCity                        = customer.fsCore__Account_Name__r.PersonOtherCity;
                mTILAObj.applicantInformation.homeState                       = customer.fsCore__Account_Name__r.PersonOtherState;
                mTILAObj.applicantInformation.homeZip                         = customer.fsCore__Account_Name__r.PersonOtherPostalCode;
                mTILAObj.applicantInformation.homePhone                       = customer.fsCore__Account_Name__r.PersonHomePhone;
                mTILAObj.applicantInformation.mobilePhone                     = customer.fsCore__Account_Name__r.PersonMobilePhone;
                
            }else{
                mIsCoapplicantExist = true;
                mTILAObj.coApplicantInformation                               = new TILADashboardObject.CustomerInformation();
                mTILAObj.coApplicantInformation.clientId                      = customer.fsCore__Account_Name__r.Id;
                mTILAObj.coApplicantInformation.contactId                     = customer.fsCore__Account_Name__r.PersonContactId;
                mTILAObj.coApplicantInformation.clientName                    = customer.fsCore__Account_Name__r.Name;
                mTILAObj.coApplicantInformation.clientEmail                   = customer.fsCore__Account_Name__r.PersonEmail;
                mTILAObj.coApplicantInformation.homeStreet                    = customer.fsCore__Account_Name__r.PersonOtherStreet;
                mTILAObj.coApplicantInformation.homeCity                      = customer.fsCore__Account_Name__r.PersonOtherCity;
                mTILAObj.coApplicantInformation.homeState                     = customer.fsCore__Account_Name__r.PersonOtherState;
                mTILAObj.coApplicantInformation.homeZip                       = customer.fsCore__Account_Name__r.PersonOtherPostalCode;
                mTILAObj.coApplicantInformation.homePhone                     = customer.fsCore__Account_Name__r.PersonHomePhone;
                mTILAObj.coApplicantInformation.mobilePhone                   = customer.fsCore__Account_Name__r.PersonMobilePhone;
                
            }
            
            
        }
        
        //SINCE DIRECTLY GETTING THE PICKLIST FIELD WILL GIVE PICKLIST VALUE AND NOT THE LABEL.
        //SO GETTING THE LABEL BY DESCRIBING
        Schema.DescribeFieldResult fieldResult = fsCore__Lending_Application__c.fsCore__Payment_Cycle__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        Map<String,String> paymentCycleMap = new Map<String,String>();
        for( Schema.PicklistEntry v : values) {
            paymentCycleMap.put(v.getValue(),v.getLabel());
        }
        
        mTILAObj.interestRate                  = mApplication.fsCore__Rate__c;
        mTILAObj.apr                           = mApplication.fsCore__Annual_Percent_Rate__c;
        mTILAObj.originationFee                = mApplication.fsCore__Approved_Prepaid_Fee__c;
        mTILAObj.prepaidFinanceCharge          = mApplication.fsCore__Approved_Finance_Fee__c;
        mTILAObj.DRPProgramName                = mApplication.Opportunity_Name__r.Program_Type__c;
        mTILAObj.DRPProgramType                = mApplication.Opportunity_Name__r.DRP_Name__c;
        mTILAObj.estdraftFrequency             = paymentCycleMap.get(mApplication.fsCore__Payment_Cycle__c);
        mTILAObj.estdraftAmount                = mApplication.fsCore__Payment_Amount__c;     
        mTILAObj.paymentProcessor              = mApplication.Payment_Processor_Name__c;
        //updating mTILAObj.finalApprovalDate on Final_Approval_Date__c When the approve application button is pressed
        //PDI-398 - Next DRP Draft Date - It should be the date on which next Draft in DRP is scheduled.
        Integer secondPaymentDueDay = fsCore.Constants.DUMMY_SECOND_DUE_DAY;
        if (mApplication.fsCore__Payment_Cycle__c == fsCore.Constants.CYCLE_TWICE_MONTHLY){
            secondPaymentDueDay = (Integer)mApplication.fsCore__Payment_Due_Day_2__c;
        }         
        if (mApplication.Next_DRP_Draft_Date__c != null){
            mTILAObj.nextDRPDraftDate = mApplication.Next_DRP_Draft_Date__c;
            mTILAObj.nextDRPDraftDateStr = getFormattedDate(mTILAObj.nextDRPDraftDate);
        }else{
            mTILAObj.nextDRPDraftDate = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(System.Today()
                                                                                             , (Integer)mApplication.fsCore__Payment_Due_Day__c
                                                                                             , secondPaymentDueDay
                                                                                             , mApplication.fsCore__Payment_Cycle__c);
            mTILAObj.nextDRPDraftDateStr = getFormattedDate(mTILAObj.nextDRPDraftDate);
        }
        
        
        if (mApplication.Final_Approval_Date__c == null){
            mTILAObj.estDisbursementDateStr  = getFormattedDate(System.Today().addDays(60));    
            mTILAObj.estDisbursementDate  = System.Today().addDays(60);    
            mTILAObj.estFirstRepaymentDate = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(System.Today().addDays(60)
                                                                                                  , (Integer)mApplication.fsCore__Payment_Due_Day__c
                                                                                                  , secondPaymentDueDay
                                                                                                  , mApplication.fsCore__Payment_Cycle__c);
            mTILAObj.estFirstRepaymentDateStr= getFormattedDate(mTILAObj.estFirstRepaymentDate);
        }else{
            mTILAObj.estDisbursementDateStr  = getFormattedDate(mApplication.fsCore__Contract_Date__c);    
            mTILAObj.estDisbursementDate  = mApplication.fsCore__Contract_Date__c;    
            mTILAObj.estFirstRepaymentDate= mApplication.fsCore__Payment_Start_Date__c;
            mTILAObj.estFirstRepaymentDateStr= getFormattedDate(mApplication.fsCore__Payment_Start_Date__c);
            
        }
        
        mTILAObj.estFinalDRPDraftDate          = getFormattedDate(fsCore.DateUtilGlobal.adjustDateBySubtractingBillingCycle(mTILAObj.estDisbursementDate
                                                                                                                            , (Integer)mApplication.fsCore__Payment_Due_Day__c
                                                                                                                            , secondPaymentDueDay
                                                                                                                            , mApplication.fsCore__Payment_Cycle__c));
        
        
        mTILAObj.estOriginationFee             = mApplication.fsCore__Approved_Prepaid_Fee__c; 
        mTILAObj.estPrepaidFinanceCharge       = mApplication.fsCore__Approved_Finance_Fee__c;
        
        mTILAObj.actualFinalDRPDraftDate       = getFormattedDate(fsCore.DateUtilGlobal.adjustDateBySubtractingBillingCycle(System.Today()
                                                                                                                            , (Integer)mApplication.fsCore__Payment_Due_Day__c
                                                                                                                            , secondPaymentDueDay
                                                                                                                            , mApplication.fsCore__Payment_Cycle__c));
        mTILAObj.actualdraftFrequency          = mApplication.fsCore__Payment_Cycle__c;
        mTILAObj.actualdraftAmount             = mApplication.fsCore__Payment_Amount__c;
        mTILAObj.actualOneMonthPaymentToDRP    = 0; 
        mTILAObj.actualCashInDedicatedAccount  = 0;
        mTILAObj.actualRemFeeDueToDRP          = 0; 
        mTILAObj.actualSettlementDisbursements = 0;
        mTILAObj.actualOriginationFee          = mApplication.fsCore__Actual_Prepaid_Fee__c; 
        mTILAObj.actualPrepaidFinanceCharge    = mApplication.fsCore__Actual_Finance_Fee__c;
        mTILAObj.actualLoanAmount = mApplication.fsCore__Loan_Amount__c;     
        mTILAObj.actualTotalSettlementAmount    = 0.00;
        mTILAObj.actualTotalSettlementFee     = 0.00;
        mTILAObj.actualTotalVersaraDisbAmount  = 0.00;
        mTILAObj.actualTotalPrepaidCharge    = 0.00;
        
        
        mTILAObj.estCashInDedicatedAccount = 0;
        mTILAObj.estOneMonthPaymentToDRP = 0;
        mTILAObj.estRemFeeDueToDRP = 0;
        mTILAObj.estTotalOriginalEnrolledBal    = 0.00;
        mTILAObj.estTotalCurrentEnrolledBal     = 0.00;
        mTILAObj.estNetSettlementPercentage     = 0.00;
        mTILAObj.estTotalSettlementBal          = 0.00;   
        
        Integer estimatedSettleCount = 0;     
        Boolean updCashInDedicated = false;
        Date actualFinalDisbDateFromItemization = null;
        For (fsCore__Lending_Application_Repayment_Schedule__c rps: mApplication.fsCore__Lending_Application_Repayment_Schedule__r){
            
            TILADashboardObject.RepaymentSchedule rpsTila = new TILADashboardObject.RepaymentSchedule();
            
            if ((rps.fsCore__Number_Of_Payments__c != null) || (rps.fsCore__Payment_Amount__c != null)){
                rpsTila.numberOfPayments                 = rps.fsCore__Number_Of_Payments__c;
                rpsTila.paymentAmount                    = rps.fsCore__Payment_Amount__c;
            }
            mTILAObj.repaymentScheduleList.add(rpsTila);   
        }
         
        For (fsCore__Lending_Application_Itemization__c itm: mApplication.fsCore__Lending_Application_Itemization__r){
            
            TILADashboardObject.PreSettlementItemizations preTila = new TILADashboardObject.PreSettlementItemizations();
            
            if ((itm.Current_Creditor__c != null) || (itm.Original_Creditor__c != null)){
                preTila.originalCreditor                 = itm.Original_Creditor__c;
                preTila.currentCreditor                  = itm.Current_Creditor__c;
                preTila.originalEnrolledBalance          = (itm.DNL_Original_Enrolled_Balance__c == null)?itm.fsCore__Requested_Amount_Unsigned__c:itm.DNL_Original_Enrolled_Balance__c;
                preTila.estimatedEnrolledBalance         = itm.fsCore__Requested_Amount_Unsigned__c;
                preTila.estimatedSettlementPercentage    = (itm.Estimated_Settlement_Percent__c!= null)?itm.Estimated_Settlement_Percent__c:0.00;
                preTila.estimatedSettlementBalance       = (itm.fsCore__Approved_Amount_Unsigned__c != null)?itm.fsCore__Approved_Amount_Unsigned__c:itm.Estimated_Settlement_Balance__c;
                
                
                mTILAObj.estTotalOriginalEnrolledBal += preTila.originalEnrolledBalance;
                mTILAObj.estTotalCurrentEnrolledBal += preTila.estimatedEnrolledBalance;
                mTILAObj.estNetSettlementPercentage += preTila.estimatedSettlementPercentage;
                mTILAObj.estTotalSettlementBal += preTila.estimatedSettlementBalance;                
                
                estimatedSettleCount += 1;
                mTILAObj.preSettlementItemizationsList.add(preTila);   
                
                TILADashboardObject.PostSettlementItemizations postTila = new TILADashboardObject.PostSettlementItemizations();
                //POST TILA
                postTila.currentCreditor                  = itm.Current_Creditor__c;
                
                if (itm.DNL_Actual_Prepaid_Finance_Charge__c != null){
                    postTila.actualPrepaidCharge  = itm.DNL_Actual_Prepaid_Finance_Charge__c; //PDI-656
                }else{
                    postTila.actualPrepaidCharge  = 0.00;
                }
                
                System.debug(itm.Disbursement_Date__c );
                if (actualFinalDisbDateFromItemization == null){
                    actualFinalDisbDateFromItemization = itm.Disbursement_Date__c   ;
                    
                }else{
                    if (itm.Disbursement_Date__c > actualFinalDisbDateFromItemization){
                        actualFinalDisbDateFromItemization = itm.Disbursement_Date__c   ;  
                    }
                }
                postTila.actualDisbursementDate      = getFormattedDate(itm.Disbursement_Date__c);
                postTila.actualSettlementAmount      = (itm.DNL_Funds_to_Client__c != null)?itm.DNL_Funds_to_Client__c :0;
                postTila.actualSettlementFee         = (itm.DNL_Settlement_Fees__c != null)?itm.DNL_Settlement_Fees__c :0;
                postTila.actualVersaraDisbAmount     = (itm.fsCore__Actual_Amount_Unsigned__c != null)?itm.fsCore__Actual_Amount_Unsigned__c :0;
                
                mTILAObj.actualTotalSettlementAmount += postTila.actualSettlementAmount;
                mTILAObj.actualTotalSettlementFee += postTila.actualSettlementFee;
                mTILAObj.actualTotalVersaraDisbAmount += postTila.actualVersaraDisbAmount;
                mTILAObj.actualTotalPrepaidCharge += postTila.actualPrepaidCharge;
                
                
                
                mTILAObj.postSettlementItemizationsList.add(postTila);  
                
            }else{
                if (itm.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mDedicatedAmountCash)){
                    mTILAObj.estCashInDedicatedAccount += (itm.fsCore__Approved_Amount_Unsigned__c == null ? 0 : itm.fsCore__Approved_Amount_Unsigned__c);
                    mTILAObj.actualCashInDedicatedAccount += (itm.fsCore__Actual_Amount_Unsigned__c == null ? 0 : itm.fsCore__Actual_Amount_Unsigned__c);
                }
                else if (itm.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mDrpOneMonthPayment)){
                    mTILAObj.estOneMonthPaymentToDRP += (itm.fsCore__Approved_Amount_Unsigned__c == null ? 0 : itm.fsCore__Approved_Amount_Unsigned__c);
                    mTILAObj.actualOneMonthPaymentToDRP += (itm.fsCore__Actual_Amount_Unsigned__c == null ? 0 : itm.fsCore__Actual_Amount_Unsigned__c);
                    
                }                
                else if (itm.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mRemainingFeeDueDrp)){
                    mTILAObj.estRemFeeDueToDRP += (itm.fsCore__Approved_Amount_Unsigned__c == null ? 0 : itm.fsCore__Approved_Amount_Unsigned__c);
                    mTILAObj.actualRemFeeDueToDRP+= (itm.fsCore__Actual_Amount_Unsigned__c == null ? 0 : itm.fsCore__Actual_Amount_Unsigned__c);
                }                        
                
            }
        }    
        
        if (actualFinalDisbDateFromItemization != null){
            mTILAObj.actualDisbursementDate        = actualFinalDisbDateFromItemization;
            mTILAObj.actualDisbursementDateStr = getFormattedDate(mTILAObj.actualDisbursementDate);

            mTILAObj.actualFirstRepaymentDate        = fsCore.DateUtilGlobal.adjustDateByBillingCycle(System.Today()
                                                                                                            , (Integer)mApplication.fsCore__Payment_Due_Day__c
                                                                                                            , secondPaymentDueDay
                                                                                                            , mApplication.fsCore__Payment_Cycle__c
                                                                                                            , 0);
            if ((mTILAObj.actualFirstRepaymentDate < mTILAObj.actualDisbursementDate)||(mTILAObj.actualFirstRepaymentDate < System.Today())){
                mTILAObj.actualFirstRepaymentDate        = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(System.Today()
                                                                                                            , (Integer)mApplication.fsCore__Payment_Due_Day__c
                                                                                                            , secondPaymentDueDay
                                                                                                            , mApplication.fsCore__Payment_Cycle__c);
            }

            mTILAObj.actualFirstRepaymentDateStr = getFormattedDate(mTILAObj.actualFirstRepaymentDate);


            mTILAObj.actualSecondRepaymentDate        = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(mTILAObj.actualFirstRepaymentDate
                                                                                                            , (Integer)mApplication.fsCore__Payment_Due_Day__c
                                                                                                            , secondPaymentDueDay
                                                                                                            , mApplication.fsCore__Payment_Cycle__c);

            
        }
        
        if (estimatedSettleCount == 0)   estimatedSettleCount = 1; //TO AVOID DIVIDE BY 0 ERROR
        mTILAObj.estNetSettlementPercentage = (mTILAObj.estNetSettlementPercentage/estimatedSettleCount).SetScale(2);
        mTILAObj.estSettlementDisbursements = mTILAObj.estTotalSettlementBal - (mTILAObj.estCashInDedicatedAccount + mTILAObj.estOneMonthPaymentToDRP) + mTILAObj.estRemFeeDueToDRP;
        mTILAObj.estLoanAmount = mTILAObj.estSettlementDisbursements + mTILAObj.estOriginationFee + mTILAObj.estPrepaidFinanceCharge;
        mTILAObj.plusFinanceCharge = mApplication.fsCore__Total_Financial_Charge__c;
        mTILAObj.totalOfPayments = mApplication.fsCore__Total_Of_Payments__c;
        mTILAObj.actualSettlementDisbursements = mTILAObj.actualTotalVersaraDisbAmount -(mTILAObj.actualCashInDedicatedAccount + mTILAObj.actualOneMonthPaymentToDRP) + mTILAObj.actualRemFeeDueToDRP;
        mTILAObj.actualLoanAmount = mTILAObj.actualSettlementDisbursements + mTILAObj.actualOriginationFee + mTILAObj.actualPrepaidFinanceCharge;
    }
    
    /*
PDI-598 NO NEED FOR THIS METHOD AS THE CALLING METHOD IS COMMENTED
private void updateFeeForPreTila(){


if (mApplication.Opportunity_Name__r.Portfolio_Type__c == 'Attorney'){
if (mApplication.Opportunity_Name__r.Law_Firm_Name__c == 'Royal'){

mApplication.PreTila_DRP_Fee__c = ((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c)+
((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Processor_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Processor_Fee__c);

mApplication.PreTila_DNL_Fee__c = ((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c)+
((mApplication.Monthly_Processor_Fee__c == null)?0:mApplication.Monthly_Processor_Fee__c);


}else{

mApplication.PreTila_DRP_Fee__c = ((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Service_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Service_Fee__c)+
((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Retainer_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Retainer_Fee__c)+
((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Admin_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Admin_Fee__c)+
((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Processor_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Processor_Fee__c);


mApplication.PreTila_DNL_Fee__c = ((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Service_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Service_Fee__c)+
((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Retainer_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Retainer_Fee__c)+
((mApplication.Monthly_Legal_Fee__c == null)?0:mApplication.Monthly_Legal_Fee__c)+
((mApplication.Monthly_Processor_Fee__c == null)?0:mApplication.Monthly_Processor_Fee__c);

}

}else{//default is 'Timberline' 

mApplication.PreTila_DRP_Fee__c = ((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c)+
((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Processor_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Processor_Fee__c)+
((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Third_Party_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Third_Party_Fee__c);

mApplication.PreTila_DNL_Fee__c = ((mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c == null)?0:mApplication.NuDebt_Draft_Fee__r[0].Remaining_Program_Fee__c)+
((mApplication.Monthly_Processor_Fee__c == null)?0:mApplication.Monthly_Processor_Fee__c)+
((mApplication.Monthly_Third_Party_Fees__c == null)?0:mApplication.Monthly_Third_Party_Fees__c);

}

}*/
    
    private string getFormattedDate(Date pDate){
        if (pDate != null){
            return fsCore.TypeUtil.getFormattedDate(date.newInstance(pDate.year(),pDate.month(),pDate.Day()), DATE_FORMAT);
        }
        
        return '';
        
    }

    public PageReference generateFinalContract(){
        validateApplication();
        System.debug(mValidationsPassed);
        mValidationsPassed= true;
        
        if (!mValidationsPassed){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mValidationFailureMessage));           
            return null;
        }
        boolean disbDateNull = false;
        for (fsCore__Lending_Application_Itemization__c itm: mApplication.fsCore__Lending_Application_Itemization__r){
            System.debug(itm);
            if ((itm.Current_Creditor__c != null) || (itm.Original_Creditor__c != null)){
                //If the actual amount signed is 0 that means not paid to third party, so ignore that
                if ((itm.fsCore__Actual_Amount_Signed__c> 0) && itm.Disbursement_Date__c == null){
                    disbDateNull = true;
                    break;
                }
            }
            
        }
        if (disbDateNull){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Disursement Date cannot be null for the funds to creditor itemization(s).'));
            return null;
        }
        
        
        fsCore__Lending_Application__c application = fsCore.LendingApplicationUtil.getApplication(mApplication.Id);
        List<fsCore__Lending_Application_Repayment_Schedule__c> existingRepaySch = fsCore.LendingApplicationRepaymentUtil.getRepaymentSchedule(mApplication.Id);
        List<fsCore__Lending_Application_Repayment__c> existingRepayDetails = fsCore.LendingApplicationRepaymentUtil.getRepaymentDetails(mApplication.Id);

        application.fsCore__Financed_Amount__c = application.fsCore__Actual_Financed_Amount__c ;
        application.fsCore__Prepaid_Fee__c = application.fsCore__Actual_Prepaid_Fee__c ;
        application.fsCore__Finance_Fee__c = application.fsCore__Actual_Finance_Fee__c ;
        application.fsCore__Contract_Date__c = mTILAObj.actualDisbursementDate;
        application.fsCore__Payment_Start_Date__c = mTILAObj.actualFirstRepaymentDate;
        application.fsCore__Payment_Start_Date_2__c = mTILAObj.actualSecondRepaymentDate;    

        
        //FOR TWICE A MONTH LOANS WE STILL NEED TO PASS AS SEMI-MONTHLY
        String paymentCycle = (application.fsCore__Payment_Cycle__c == fsCore.Constants.CYCLE_TWICE_MONTHLY) ? fsCore.Constants.CYCLE_SEMI_MONTHLY : application.fsCore__Payment_Cycle__c;
        logmessage('paymentCycle :'+ paymentCycle);
        logmessage('fsCore__Payment_Start_Date__c :'+ application.fsCore__Payment_Start_Date__c);
        logmessage('fsCore__Payment_Due_Day__c :'+ application.fsCore__Payment_Due_Day__c);
        application.fsCore__Interest_Accrual_Start_Date__c  = fsCore.DateUtilGlobal.adjustDateByBillingCycle
                                                                                   ( application.fsCore__Payment_Start_Date__c
                                                                                   , (Integer)application.fsCore__Payment_Due_Day__c
                                                                                   , fsCore.Constants.DUMMY_SECOND_DUE_DAY 
                                                                                   , paymentCycle
                                                                                   , -1).addDays((Integer)application.fsCore__Interest_Accrual_Start_Days__c);
               
        logmessage('fsCore__Interest_Accrual_Start_Date__c :'+ application.fsCore__Interest_Accrual_Start_Date__c);
        if (application.fsCore__Interest_Accrual_Start_Date__c < application.fsCore__Contract_Date__c){
            application.fsCore__Interest_Accrual_Start_Date__c = application.fsCore__Contract_Date__c;
        }
        logmessage('Final fsCore__Interest_Accrual_Start_Date__c passed to builder :'+ application.fsCore__Interest_Accrual_Start_Date__c);
        fsCore.LendingApplicationCalculatorBuilder calcBuilder = new fsCore.LendingApplicationCalculatorBuilder(application)
                                                                            .setCalculator(fsCore.Constants.CALCULATE_NUMBER_OF_PAYMENTS);
        fsCore.CalculatorObject calcObj = calcBuilder.getCalculatorObject();
        logmessage('calcObj :'+ calcObj);
        calcObj = fsCore.Calculator.calculate(calcObj);

        fsCore.LendingApplicationCalculatorExtractor calcExtract = new fsCore.LendingApplicationCalculatorExtractor(calcObj, application);
        application = calcExtract.getApplicationDetails();
        
        List<fsCore__Lending_Application_Repayment__c> newRepayDtl = calcExtract.getRepaymentDetails();          
        List<fsCore__Lending_Application_Repayment_Schedule__c> newRepaySch = calcExtract.getRepaymentSchedule();

        
        mApplication.fsCore__Loan_Amount__c  = application.fsCore__Loan_Amount__c ;
        mApplication.fsCore__Financed_Amount__c  = application.fsCore__Financed_Amount__c ;
        mApplication.fsCore__Prepaid_Fee__c  = application.fsCore__Prepaid_Fee__c  ;
        mApplication.fsCore__Finance_Fee__c  = application.fsCore__Finance_Fee__c ;
        mApplication.fsCore__Contract_Date__c  = application.fsCore__Contract_Date__c ;
        mApplication.fsCore__Payment_Start_Date__c  = application.fsCore__Payment_Start_Date__c ;
        mApplication.fsCore__Payment_Start_Date_2__c  = application.fsCore__Payment_Start_Date_2__c ;
        mApplication.fsCore__Number_Of_Payments__c  = application.fsCore__Number_Of_Payments__c ; 
        mApplication.fsCore__Payment_Amount__c  = application.fsCore__Payment_Amount__c ; 
        mApplication.fsCore__Payment_Due_Day_2__c = application.fsCore__Payment_Due_Day_2__c ;
        mApplication.fsCore__Payment_Due_Day__c = application.fsCore__Payment_Due_Day__c ;
        mApplication.fsCore__Is_Final_Payment_Different__c = application.fsCore__Is_Final_Payment_Different__c ;
        mApplication.fsCore__Interest_Accrual_Start_Date__c = application.fsCore__Interest_Accrual_Start_Date__c ;
        mApplication.fsCore__First_Period_Days__c = application.fsCore__First_Period_Days__c ;
        mApplication.fsCore__Final_Payment_Amount__c = application.fsCore__Final_Payment_Amount__c ;
        mApplication.fsCore__Balloon_Amount__c = application.fsCore__Balloon_Amount__c ;
        mApplication.fsCore__Balloon_Method__c = application.fsCore__Balloon_Method__c ;
        mApplication.fsCore__Annual_Percent_Rate__c = application.fsCore__Annual_Percent_Rate__c ;
        mApplication.fsCore__Maturity_Date__c = application.fsCore__Maturity_Date__c ;
        mApplication.fsCore__Principal_Balance__c = application.fsCore__Principal_Balance__c ;
        mApplication.fsCore__Total_Of_Payments__c = application.fsCore__Total_Of_Payments__c ;
        mApplication.fsCore__Total_Interest_Amount__c = application.fsCore__Total_Interest_Amount__c ;
        mApplication.fsCore__Number_Of_Payments_Monthly__c = application.fsCore__Number_Of_Payments_Monthly__c ;
        mApplication.fsCore__Total_Financial_Charge__c = application.fsCore__Total_Financial_Charge__c ;
        mApplication.fsCore__Interest_Accrual_Start_Date__c = application.fsCore__Interest_Accrual_Start_Date__c;

        
    

        //IF IT REACHES HERE THEN IT MEANS EVERYTHING IS SUCCESSFULL THEN UPDATE
        //Is_Final_Contract_Generated__c
        mApplication.Is_Final_Contract_Generated__c = true;
        mApplication.fsCore__Annual_Percent_Rate__c = 0.00; // Mark it as 0 and it will update using calculateAPRAsync
        
        update mApplication;

        delete existingRepaySch;
        delete existingRepayDetails;
        
        insert newRepayDtl;
        insert newRepaySch;

        fsCore.APRCalculator.calculateAPRAsync(mApplication.Id);
        
        
        queryApplication();
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Final amortization schedule has been generated sucessfully!'));           
        return null;
    }    
    
    /*public PageReference generateFinalContract(){
        validateApplication();
        System.debug(mValidationsPassed);
        mValidationsPassed= true;
        
        if (!mValidationsPassed){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mValidationFailureMessage));           
            return null;
        }
        boolean disbDateNull = false;
        for (fsCore__Lending_Application_Itemization__c itm: mApplication.fsCore__Lending_Application_Itemization__r){
            System.debug(itm);
            if ((itm.Current_Creditor__c != null) || (itm.Original_Creditor__c != null)){
                //If the actual amount signed is 0 that means not paid to third party, so ignore that
                if ((itm.fsCore__Actual_Amount_Signed__c> 0) && itm.Disbursement_Date__c == null){
                    disbDateNull = true;
                    break;
                }
            }
            
        }
        if (disbDateNull){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Disursement Date cannot be null for the funds to creditor itemization(s).'));
            return null;
        }
        
        
        Set<Id> applicationIdSet = new Set<Id>();
        applicationIdSet.add(mApplication.Id);
        
        fsCore.DynamicQueryBuilder applicationQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
            .addFields()
            .addWhereConditionWithBind(1,'Id','IN','applicationIdSet');
        
        List<fsCore__Lending_Application__c> applicationList = (List<fsCore__Lending_Application__c>)Database.query(applicationQuery.getQueryString());
        
        Set<Id> pricingIdSet = new Set<Id>();
        pricingIdSet.add(mApplication.fsCore__Pricing_Name__c);        
        fsCore.DynamicQueryBuilder pricingSetupQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Pricing_Setup__c.getName())
            .addFields()
            .addWhereConditionWithBind(1,'Id','IN','pricingIdSet');
        
        List<fsCore__Pricing_Setup__c> pricingSetupList = (List<fsCore__Pricing_Setup__c>)Database.query(pricingSetupQuery.getQueryString());
        
        fsCore.PricingOfferGenerator poGen= new fsCore.PricingOfferGenerator(applicationList[0], pricingSetupList[0]);
        poGen.setDefaultInputParameters();
        
        fsCore.PricingOfferInputObject poInputObj = new fsCore.PricingOfferInputObject();
        poInputObj.setBranchCode(applicationList[0].fsCore__Branch_Code_Formula__c);
        poInputObj.financedAmount = applicationList[0].fsCore__Actual_Financed_Amount__c ; 
        poInputObj.prepaidfee = applicationList[0].fsCore__Actual_Prepaid_Fee__c ; 
        poInputObj.financeFee = applicationList[0].fsCore__Actual_Finance_Fee__c ; 
        poInputObj.rate = applicationList[0].fsCore__Rate__c ; 
        poInputObj.numberOfPayments = (Integer)applicationList[0].fsCore__Number_Of_Payments__c ; 
        poInputObj.paymentCycle = applicationList[0].fsCore__Payment_Cycle__c ; 
        poInputObj.paymentAmount = applicationList[0].fsCore__Payment_Amount__c ; 
        poInputObj.contractStartDate = mTILAObj.actualDisbursementDate;
        poInputObj.firstPaymentDate = mTILAObj.actualFirstRepaymentDate;
        poInputObj.secondPaymentDate = mTILAObj.actualSecondRepaymentDate;
        
        
        poGen.setInputParameters(poInputObj);
        poGen.generateOffer();
        
        poGen.saveOffer();
        poGen.acceptOffer();
        poGen.calculateAPR();
        
        //IF IT REACHES HERE THEN IT MEANS EVERYTHING IS SUCCESSFULL THEN UPDATE
        //Is_Final_Contract_Generated__c
        mApplication.Is_Final_Contract_Generated__c = true;
        update mApplication;
        
        queryApplication();
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Final amortization schedule has been generated sucessfully!'));           
        return null;
    }*/
    //PDI-598
    public PageReference approveApplication(){
        validateApplication();
        mValidationsPassed= true;
        if (!mValidationsPassed){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mValidationFailureMessage));           
            return null;
        }
        mApplication.Final_Approval_Date__c = mTILAObj.finalApprovalDate;
        update mApplication;
        queryApplication();
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Application has been approved!'));           
        return null;
    }    
    
    public PageReference approveAppAndGenerateOffer(){
        
        return null;
    }    
    /*
PDI-598 COMMENT OUT THE BELOW CODE
public PageReference approveAppAndGenerateOffer(){


//Need to update the cash in dedicated amount Itemization. it should take care of all prepaid/financed fee
opportunity opp;
if (mApplication.Final_Approval_Date__c == null){
try{
pullOpportunityTradeLinePaymentsClass.getDetails(String.ValueOf(mApplication.Opportunity_Name__c));
}catch(Exception ex){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Couldn\'t refresh NuDebt Information : '+ex.getMessage()+ex.getStackTraceString()));           
return null;
}
}
opp = [select id, Cash_in_Dedicated_Account__c,(select id,Original_Debt__c from Opportunity_Tradelines_Offers__r) from opportunity where id = :mApplication.Opportunity_Name__c];

boolean cashInDedicatedAccountItemExist =false;
For (fsCore__Lending_Application_Itemization__c itm: mApplication.fsCore__Lending_Application_Itemization__r){
if (itm.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mDedicatedAmountCash)){                        
itm.fsCore__Approved_Amount_Unsigned__c = opp.Cash_in_Dedicated_Account__c;
itm.fsCore__Actual_Amount_Unsigned__c = opp.Cash_in_Dedicated_Account__c;
cashInDedicatedAccountItemExist = true;
update itm;
break;
}
}
if (!cashInDedicatedAccountItemExist){
if ((opp.Cash_in_Dedicated_Account__c != null) && (opp.Cash_in_Dedicated_Account__c > 0)){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Missing Cash in Dedicate Account Itemization, contact support.'));           
return null;
}
}

Decimal originalEnrolledDebt =0.00;
for (Opportunity_Tradelines_Offer__c tradelineOffer: opp.Opportunity_Tradelines_Offers__r){
if (tradelineOffer.Original_Debt__c != null){
originalEnrolledDebt += tradelineOffer.Original_Debt__c;
}
}        
mApplication.Original_Enrolled_Debt__c = originalEnrolledDebt; 
//END OF UPDATE OF Cash_in_Dedicated_Account__c ITEMIZATION
try{
updateFeeForPreTila();
update mApplication;

}catch(Exception ex){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Couldn\'t update fee Information : '+ex.getMessage()+ex.getStackTraceString()));           
return null;
}

validateApplication();

if (!mValidationsPassed){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mValidationFailureMessage));           
return null;
}

Set<Id> applicationIdSet = new Set<Id>();
applicationIdSet.add(mApplication.Id);

fsCore.DynamicQueryBuilder applicationQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
.addFields()
.addWhereConditionWithBind(1,'Id','IN','applicationIdSet');

List<fsCore__Lending_Application__c> applicationList = (List<fsCore__Lending_Application__c>)Database.query(applicationQuery.getQueryString());

Set<Id> pricingIdSet = new Set<Id>();
pricingIdSet.add(mApplication.fsCore__Pricing_Name__c);        
fsCore.DynamicQueryBuilder pricingSetupQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Pricing_Setup__c.getName())
.addFields()
.addWhereConditionWithBind(1,'Id','IN','pricingIdSet');

List<fsCore__Pricing_Setup__c> pricingSetupList = (List<fsCore__Pricing_Setup__c>)Database.query(pricingSetupQuery.getQueryString());


logmessage('App Size :'+applicationList.size()+'  Pricing Size :'+pricingSetupList.size());
fsCore.PricingOfferGenerator poGen = new fsCore.PricingOfferGenerator(applicationList[0], pricingSetupList[0]);
try{
poGen.setDefaultInputParameters();

fsCore.PricingOfferInputObject poInputObj = new fsCore.PricingOfferInputObject();
poInputObj.setBranchCode(applicationList[0].fsCore__Branch_Code_Formula__c);
poInputObj.financedAmount = applicationList[0].fsCore__Approved_Financed_Amount__c ; 
poInputObj.prepaidfee = applicationList[0].fsCore__Approved_Prepaid_Fee__c ; 
poInputObj.financeFee = applicationList[0].fsCore__Approved_Finance_Fee__c ; 
poInputObj.rate = applicationList[0].fsCore__Rate__c ; 
poInputObj.numberOfPayments = (Integer)applicationList[0].fsCore__Number_Of_Payments__c ; 
poInputObj.paymentCycle = applicationList[0].fsCore__Payment_Cycle__c ; 
poInputObj.paymentAmount = applicationList[0].fsCore__Payment_Amount__c ; 
poInputObj.contractStartDate = mTILAObj.estDisbursementDate;
poInputObj.firstPaymentDate = mTILAObj.estFirstRepaymentDate;

//fsCore__Approved_Prepaid_Fee__c
//fsCore__Approved_Finance_Fee__c
//poInputObj.secondPaymentDate = poInputObj.getBusinessDate().addMonths(1);        

poGen.setInputParameters(poInputObj);
poGen.generateOffer();

poGen.saveOffer();
poGen.acceptOffer();
poGen.calculateAPR();
}catch(Exception ex){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,' Couldn\'t generate the offer : '+ex.getMessage()+ex.getStackTraceString()));           
return null;
}

//IF IT REACHES HERE THEN IT MEANS EVERYTHING IS SUCCESSFULL THEN UPDATE
//CONTRACT DATE, FIRST PAYMENT DATE AND FINAL APPROVAL DATE
queryApplication();
mApplication.fsCore__Contract_Date__c = mTILAObj.estDisbursementDate ;
mApplication.fsCore__Payment_Start_Date__c = mTILAObj.estFirstRepaymentDate;
mApplication.Final_Approval_Date__c = mTILAObj.finalApprovalDate;
mApplication.Next_DRP_Draft_Date__c = mTILAObj.nextDRPDraftDate;
update mApplication;

ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Amortization Schedule has been generated sucessfully!'));           
return null;

}*/
    private void validateApplication(){
        mValidationFailureMessage = '';
        mValidationsPassed = true;
        mEnvelopeAlreadySent = false;
        
        Boolean tradelineExist = false;
        if (mApplication.fsCore__Lending_Application_Itemization__r.size()> 0){
            for (fsCore__Lending_Application_Itemization__c itm: mApplication.fsCore__Lending_Application_Itemization__r){
                if ((itm.Current_Creditor__c != null) || (itm.Original_Creditor__c != null)){
                    tradelineExist = true;
                }
            }
        }
        if (!tradelineExist){
            mValidationsPassed = false;
            mValidationFailureMessage += 'No tradeline(s) exist, cannot proceed.'+ '</br>' ;
        }
        
        System.debug(mApplication.fsCore__Approved_Financed_Amount__c);
        if ((mApplication.fsCore__Approved_Financed_Amount__c == null)
            ||(mApplication.fsCore__Approved_Financed_Amount__c == 0)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'Financed Amount cannot be 0, the itemizations needs to be approved before pre-tila.'+ '</br>' ;
            }          
        
        if ((mApplication.fsCore__Approved_Financed_Amount__c < mApplication.fsCore__Pricing_Name__r.fsCore__Financed_Amount_Minimum__c)
            ||(mApplication.fsCore__Approved_Financed_Amount__c > mApplication.fsCore__Pricing_Name__r.fsCore__Financed_Amount_Maximum__c)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'The financed amount must be within the allowed pricing range of '+'  Min Amount: '+mApplication.fsCore__Pricing_Name__r.fsCore__Financed_Amount_Minimum__c+'  Max Amount: '+mApplication.fsCore__Pricing_Name__r.fsCore__Financed_Amount_Maximum__c+ '</br>' ;
            } 
        
        if ((mApplication.fsCore__Number_Of_Payments__c < mApplication.fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Minimum__c)
            ||(mApplication.fsCore__Number_Of_Payments__c > mApplication.fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Maximum__c)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'The # of payments must be within the allowed pricing range of '+'  Min #: '+mApplication.fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Minimum__c+'  Max #: '+mApplication.fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Maximum__c+ '</br>' ;
            } 
        
        if ((mApplication.fsCore__Rate__c < mApplication.fsCore__Pricing_Name__r.fsCore__Rate_Value_Minimum__c)
            ||(mApplication.fsCore__Rate__c > mApplication.fsCore__Pricing_Name__r.fsCore__Rate_Value_Maximum__c)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'The rate must be within the allowed pricing range of '+'  Min rate: '+mApplication.fsCore__Pricing_Name__r.fsCore__Rate_Value_Minimum__c+'  Max rate: '+mApplication.fsCore__Pricing_Name__r.fsCore__Rate_Value_Maximum__c+ '</br>' ;
            }                     
        if (mApplication.fsCore__Contract_Template_Name__c == null){   
            mValidationsPassed = false;
            mValidationFailureMessage += String.format(Label.Contract_Template_Not_Applied_Message, 
                                                       new String[]{})+'</br>' ;
        } 
        
        if (mApplication.NuDebt_Draft_Fee__r.size()== 0){   
            mValidationsPassed = false;
            mValidationFailureMessage += 'NuDebt Draft Fee(s) are not pulled from NuDebt.'+ '</br>' ;
        }          
        
        if (mApplication.fsCore__Payment_Cycle__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Payment Cycle Cannot be blank.'+ '</br>' ;
        }  
        if (mApplication.fsCore__Pricing_Name__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Pricing must be applied on the application.'+ '</br>' ;
        }             
        
        if (mApplication.Payment_Processor_Name__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Payment processor(GCS/CFT/RAM) cannot be blank.'+ '</br>' ;
        }    
        if (mApplication.fsCore__Payment_Amount__c == null){
            mValidationsPassed = false;   
            mValidationFailureMessage += 'Payment Amount cannot be blank.</br>';
        }
        if ((mApplication.Primary_Customer_State__c == null)
            ||(mApplication.fsCore__State__c == null)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'Customer home state cannot be blank, please check the state on the application or on the customer account.</br>';   
        }else if ((mApplication.Primary_Customer_State__c == null)
                      &&(mApplication.fsCore__State__c != null)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'Customer home state cannot be blank, please check the state on the customer account.</br>';   
        }else if ((mApplication.fsCore__State__c == null)
                &&(mApplication.Primary_Customer_State__c != null)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'Customer home state cannot be blank, please check the state on the application and regenerate the pricing.</br>';   
        }else if (mApplication.Primary_Customer_State__c <> mApplication.fsCore__State__c){
                mValidationsPassed = false;
                mValidationFailureMessage += 'Discrepancy between Customer home state and the state on the application.</br>';
        }

        
        
    }
    
    public PageReference manageItemizations(){
        //PageReference manageItemizations = new PageReference('/apex/manageItemizationsCustomPage?id='+mApplication.Id);
        //manageItemizations.getParameters().put('source','tila');
        PageReference manageItemizations = new PageReference('/lightning/cmp/c__itemizationEditPage?c__applicationid='+mApplication.Id+'&c__source=tila');
        return manageItemizations;
    }
    public PageReference createPreTILA(){
        mValidationFailureMessage = '';
        mValidationsPassed = true;
        mEnvelopeAlreadySent = false;
        
        System.debug(mApplication.PreTila_Vaulting_Method__c );
        //String retUrl = '/apex/c__tilaDashboard?id='+mApplication.Id;
        
        //String retUrl = '/apex/loop__looplus?&eid='+mApplication.Id+'&retURL=%2FtilaDashboard%3Fid%3D'+mApplication.Id;
        //String retUrl = '/apex/c__tilaDashboard?id='+mApplication.Id;
        String retUrl = '/'+mApplication.Id;
        //String retUrl = '/' + mApplication.Id;
        //string retUrl = '%2Fapex%2Fc__tilaDashboard%3Fid%3D'+mApplication.Id;
        PageReference drawLoopPage = new PageReference('/apex/loop__looplus?eid='+mApplication.Id);
        
        
        boolean isPreTilaDocFound = setPreTilaFilter();

        system.debug(logginglevel.error,'mPreTilaFilter '+mPreTilaFilter);
        system.debug(logginglevel.error,'mPreTilaDdpLabel '+mPreTilaDdpLabel);


        system.debug(logginglevel.error,'applicantInformation.clientName '+mTILAObj.applicantInformation.clientName);
        system.debug(logginglevel.error,'applicantInformation.clientEmail '+mTILAObj.applicantInformation.clientEmail);
        
        drawLoopPage.getParameters().put('hideddp','true');
        //drawLoopPage.getParameters().put('autorun','true');
        drawLoopPage.getParameters().put('header','false');
        drawLoopPage.getParameters().put('ddplabel',mPreTilaDdpLabel);
        drawLoopPage.getParameters().put('filter',mPreTilaFilter);
        drawLoopPage.getParameters().put('applicant_name',mTILAObj.applicantInformation.clientName);
        drawLoopPage.getParameters().put('applicant_email',mTILAObj.applicantInformation.clientEmail);
        drawLoopPage.getParameters().put('retURL',retUrl);
        
        
        if (mIsCoapplicantExist){
            drawLoopPage.getParameters().put('coapplicant_name',mTILAObj.coapplicantInformation.clientName);
            drawLoopPage.getParameters().put('coapplicant_email',mTILAObj.coapplicantInformation.clientEmail);
        }  
        //PDI-536 CC LOAN OFFICER
        if (mApplication.Loan_Officer__c != null){
            User loanOfficerUser = [SELECT Id, Name, Email, Profile.Id, Profile.Name FROM User WHERE Id=:mApplication.Loan_Officer__c];
            drawLoopPage.getParameters().put('LoanOfficer_name',loanOfficerUser.Name);
            drawLoopPage.getParameters().put('LoanOfficer_email',loanOfficerUser.Email);
        }            
        
        //Validations
        validateApplication();
        if (mApplication.fsCore__Rate__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Interest Rate cannot be blank.</br>';
        }         
        if (mApplication.fsCore__Financed_Amount__c <> mApplication.fsCore__Approved_Financed_Amount__c){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Itemizations are modified after last approval. approve the application again and then create pre-tila.</br>';
            
        }
        if (mApplication.Final_Approval_Date__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'The application must be approved before generating the pre-tila.</br>';
        }         
        if (mApplication.BoxFolderId__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Box Folder is not available on application, please contact support.'+ '</br>' ;
        }  
        if (mApplication.fsCore__Primary_Customer_Account__r.Import_BoxFolderId__c  == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'DRP Box Folder is not available on customer account record, please contact support.'+ '</br>' ;
        }
        if (mApplication.PreTila_Vaulting_Method__c  == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Pre Tila Vaulting must be chosen.'+ '</br>' ;
        }          
        
        if(!isPreTilaDocFound){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Unable to find the applicable pre-tila doc gen template for payment processor '+mApplication.Payment_Processor_Name__c+' and  portfolio type '+mApplication.Portfolio_Type__c+'.</br>';
        }        
        
        List<dsfs__DocuSign_Status__c> docusignStatusList = [select id
                                                             , name
                                                             , dsfs__DocuSign_Envelope_ID__c
                                                             , Document_Type__c
                                                             , dsfs__Opportunity__c
                                                             , dsfs__Company__c
                                                             , dsfs__Envelope_Status__c
                                                             FROM dsfs__DocuSign_Status__c
                                                             WHERE Lending_Application_Name__c = :mApplication.Id 
                                                             AND dsfs__Envelope_Status__c != :resentEligibleMapStatusSet
                                                             AND Document_Type__c = :mPreTilaDocumentType Limit 1];
        
        if(docusignStatusList != null && !docusignStatusList.isEmpty()) {
            dsfs__DocuSign_Status__c docusignStatus = docusignStatusList.get(0);
            
            /* No Need to stop Pre-tila
                mEnvelopeAlreadySent = true;
                mValidationFailureMessage += 'Tila Already sent out for this application, please mark the existing one as void and then proceed.';
                mEnvelopeId = docusignStatus.dsfs__DocuSign_Envelope_ID__c;
                mEnvelopeStatus = docusignStatus.dsfs__Envelope_Status__c;*/
            
        }
        
        if (mValidationsPassed && !mEnvelopeAlreadySent){
            return drawLoopPage;
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mValidationFailureMessage));
        return null;
    }
    
    private boolean setPreTilaFilter(){
        //fsCore.BestMatchFinder  bestMatch = new fsCore.BestMatchFinder('DocGen_Template_Mapping');

        map<Id, DocGen_Template_Mapping_Setup__c> tilaMappingSetupMap = new map<Id, DocGen_Template_Mapping_Setup__c>([ select id
                                                                              , name
                                                                              , DocGen_Package_Name__c
                                                                              , DocGen_Package_Name__r.name
                                                                              , DocGen_Package_Name__r.Loop__Filter__c
                                                                              , Payment_Processor_Name__c
                                                                              , Portfolio_Type__c
                                                                              , Product_Name__c
                                                                              , State__c
                                                                              , Document_Type__c
                                                                              , Prepaid_Fee_Enabled__c
                                                                              , Finance_Fee_Enabled__c
                                                                           FROM DocGen_Template_Mapping_Setup__c
                                                                           WHERE Is_Active__c = true
                                                                             AND Document_Type__c = 'Pre-Tila']);


        system.debug(logginglevel.error,'tilaMappingSetupMap  size '+tilaMappingSetupMap.size());

        system.debug(logginglevel.error,'mApplication.Prepaid_Fee_Enabled__c  : '+mApplication.Prepaid_Fee_Enabled__c);
        system.debug(logginglevel.error,'mApplication.Finance_Fee_Enabled__c  : '+mApplication.Finance_Fee_Enabled__c);

        fsCore.ObjectRecordMapper recordMapper = new fsCore.ObjectRecordMapper('DocGen_Template_Mapping');
        SObject matchingRecord = recordMapper.getMatchingTargetRecord(mApplication, tilaMappingSetupMap.Values());

        system.debug(logginglevel.error,'matchingRecord  : '+matchingRecord);
        if (matchingRecord == null){
            return false;
        }
        
        Id templateId = (Id)matchingRecord.get('Id');
        system.debug(logginglevel.error,'templateId  : '+templateId);
        
        mPreTilaDdpLabel = tilaMappingSetupMap.get(templateId).DocGen_Package_Name__r.name;
        mPreTilaFilter = tilaMappingSetupMap.get(templateId).DocGen_Package_Name__r.Loop__Filter__c;

        system.debug(logginglevel.error,'mPreTilaDdpLabel  : '+mPreTilaDdpLabel);
        system.debug(logginglevel.error,'mPreTilaFilter  : '+mPreTilaFilter);
        
        //]]mPreTilaDdpLabel = 'Pre Tila All States - Attorney - GCS';
        //mPreTilaFilter = 'Pre_Tila_All_States_Attorney_GCS';

        /*if (mApplication.Portfolio_Type__c == 'Attorney'){
            if (mApplication.Payment_Processor_Name__c == 'RAM'){
                mPreTilaFilter = 'PreTilaAttorneyRAM-Vaulting-2';
            }else if (mApplication.Payment_Processor_Name__c == 'GCS'){
                mPreTilaFilter = 'PreTilaAttorneyGCS-Vaulting-2';
            }
        }else{//default is 'Timberline' 
            if (mApplication.Payment_Processor_Name__c == 'GCS'){
                mPreTilaFilter = 'PreTilaTimberlineGCS-Vaulting-2';
            }else if (mApplication.Payment_Processor_Name__c == 'CFT'){
                mPreTilaFilter = 'PreTilaTimberlineCFT-Vaulting-2';
            }
        }   
        mPreTilaDdpLabel = mPreTilaFilter;*/

        return true;   
    }
    
    /*public void SendEnvelopeUsingTemplateId(String pEmailSubject,String pEmailBlurb)
{
DocuSignAPI.APIServiceSoap dsApiSend 
= new DocuSignAPI.APIServiceSoap();
dsApiSend.endpoint_x = SFS_System_Settings__c.getInstance().Docusign_SOAP_EndPoint__c;

//Set Authentication
String auth = '<DocuSignCredentials><Username>'+ SFS_System_Settings__c.getInstance().Docusign_User_Id__c 
+'</Username><Password>' + SFS_System_Settings__c.getInstance().Docusign_Password__c 
+ '</Password><IntegratorKey>' + SFS_System_Settings__c.getInstance().Docusign_Integrator_Key__c 
+ '</IntegratorKey></DocuSignCredentials>';
System.debug('Setting authentication to: ' + auth);

dsApiSend.inputHttpHeaders_x = new Map<String, String>();
dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
auth);

DocuSignAPI.EnvelopeInformation envelope = new DocuSignAPI.EnvelopeInformation();
envelope.Subject = pEmailSubject;
envelope.EmailBlurb = pEmailBlurb;
envelope.AccountId  = SFS_System_Settings__c.getInstance().Docusign_Account_Id__c; 




//Attaching the document with contract objects start
DocuSignAPI.CustomField field = new DocuSignAPI.CustomField ();
field.Name = 'DSFSSourceObjectId';
field.Value = mApplication.Id;

envelope.CustomFields = new DocuSignAPI.ArrayOfCustomField();
envelope.CustomFields.CustomField = new DocuSignAPI.CustomField[1];
envelope.CustomFields.CustomField[0] = field;   



// Create object for the Application server-side template
Map<String,Docusign_Documents__c> docusignDocumentsMap = Docusign_Documents__c.getAll();
Docusign_Documents__c documentDetail;

if (mOpportunity.Portfolio_Type__c == 'Timberline'){
documentDetail = docusignDocumentsMap.get('Opp Loan Application T');
}else {
documentDetail = docusignDocumentsMap.get('Opp Loan Application A');
}

DocuSignAPI.TemplateReference applicationTemplate = new DocuSignAPI.TemplateReference();
applicationTemplate.Template = documentDetail.Template_Id__c;
applicationTemplate.TemplateLocation = 'Server';                    



// Recipient
System.debug('getting the contact');
MAP<String,Id> applicantsMap = new MAP<String,Id> ();
if (mOpportunity.AccountId != null){
applicantsMap.put('Applicant',mOpportunity.AccountId);
}
if (mOpportunity.Co_Applicant_Name__c != null){
applicantsMap.put('Co-Applicant',mOpportunity.Co_Applicant_Name__c);
}       

// Recipient Information
DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
recipient.ID = 1;
recipient.Type_x = 'Signer';
recipient.RoutingOrder = 1;
recipient.Email = mApplicant.emailAddress;
recipient.UserName = mApplicant.FirstName + ' ' + mApplicant.LastName;
recipient.RoleName = 'Applicant';

// Role assignments
DocuSignAPI.TemplateReferenceRoleAssignment roleAssignment = new DocuSignAPI.TemplateReferenceRoleAssignment();
roleAssignment.RoleName = recipient.RoleName;
roleAssignment.RecipientID = recipient.ID;       

DocuSignAPI.Recipient recipient2 = new DocuSignAPI.Recipient();
DocuSignAPI.TemplateReferenceRoleAssignment roleAssignment2 = new DocuSignAPI.TemplateReferenceRoleAssignment();
if (applicantsMap.get('Co-Applicant') != null){
recipient2.ID = 2;
recipient2.Type_x = 'Signer';
recipient2.RoutingOrder = 2;
recipient2.Email = mCoApplicant.emailAddress;
recipient2.UserName = mCoApplicant.FirstName + ' ' + mCoApplicant.LastName;       
recipient2.RoleName = 'Co-Applicant';   

// Role assignments
roleAssignment2.RoleName = recipient2.RoleName;
roleAssignment2.RecipientID = recipient2.ID;       


}

DocuSignAPI.ArrayOfRecipient1 signers = new DocuSignAPI.ArrayOfRecipient1();


if (applicantsMap.get('Co-Applicant') != null){
signers.Recipient = new DocuSignAPI.Recipient[2];
signers.Recipient[0] = recipient;
signers.Recipient[1] = recipient2;                  


// Add role assignment
applicationTemplate.RoleAssignments = new DocuSignAPI.ArrayOfTemplateReferenceRoleAssignment();
applicationTemplate.RoleAssignments.RoleAssignment = new DocuSignAPI.TemplateReferenceRoleAssignment[2];
applicationTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;
applicationTemplate.RoleAssignments.RoleAssignment[1] = roleAssignment2;

}else{
signers.Recipient = new DocuSignAPI.Recipient[1];
signers.Recipient[0] = recipient;


// Add role assignment
applicationTemplate.RoleAssignments = new DocuSignAPI.ArrayOfTemplateReferenceRoleAssignment();
applicationTemplate.RoleAssignments.RoleAssignment = new DocuSignAPI.TemplateReferenceRoleAssignment[1];
applicationTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;            
}

setApplicantFields(applicationTemplate);

// create array of template references
DocuSignAPI.ArrayOfTemplateReference templateReferences = new DocuSignAPI.ArrayOfTemplateReference();
templateReferences.TemplateReference = new DocuSignAPI.TemplateReference[1];
templateReferences.TemplateReference[0] = applicationTemplate;     


System.debug('Calling the API');
try {
DocuSignAPI.EnvelopeStatus es 
= dsApiSend.CreateEnvelopeFromTemplates(templateReferences, signers, envelope, true);            
mEnvelopeId = es.EnvelopeID;
sentToDocuSign= true;

} catch ( CalloutException e) {
System.debug('Exception - ' + e );
mEnvelopeId = 'Exception - ' + e;
}

}       
*/
    
    public PageReference createPostTILA(){
        mValidationFailureMessage = '';
        mValidationsPassed = true;
        mEnvelopeAlreadySent = false;
        String retUrl = '/apex/c__tilaDashboard?id='+mApplication.Id;
        PageReference drawLoopPage = new PageReference('/apex/loop__looplus?eid='+mApplication.Id+'&contactId='+mTILAObj.applicantInformation.contactId);
        //PageReference drawLoopPage = new PageReference('/apex/loop__looplus?eid='+mApplication.Id);
        
        
        /* Below are for the docusign
drawLoopPage.getParameters().put('hideddp','true');
drawLoopPage.getParameters().put('header','false');
drawLoopPage.getParameters().put('ddplabel',mPostTilaFilter);
drawLoopPage.getParameters().put('filter',mPostTilaFilter);
drawLoopPage.getParameters().put('applicant_name',mTILAObj.applicantInformation.clientName);
drawLoopPage.getParameters().put('applicant_email',mTILAObj.applicantInformation.clientEmail);
drawLoopPage.getParameters().put('retURL',retUrl);*/
        
        drawLoopPage.getParameters().put('hideddp','true');
        drawLoopPage.getParameters().put('header','false');
        drawLoopPage.getParameters().put('attach','true');
        drawLoopPage.getParameters().put('ddplabel',mPostTilaFilter);
        drawLoopPage.getParameters().put('filter',mPostTilaFilter);
        drawLoopPage.getParameters().put('applicant_name',mTILAObj.applicantInformation.clientName);
        drawLoopPage.getParameters().put('applicant_email',mTILAObj.applicantInformation.clientEmail);
        drawLoopPage.getParameters().put('retURL',retUrl);          
        
        
        
        if (mIsCoapplicantExist){
            drawLoopPage.getParameters().put('coapplicant_name',mTILAObj.coapplicantInformation.clientName);
            drawLoopPage.getParameters().put('coapplicant_email',mTILAObj.coapplicantInformation.clientEmail);
        }            
        //Validations
        if (mApplication.fsCore__Annual_Percent_Rate__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Annual Percent Rate calculation is still in process, please wait and try again in some time. .'+ '\r\n' ;
        }   
        if (mApplication.fsCore__Payment_Cycle__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Payment Cycle Cannot be blank.'+ '\r\n' ;
        }          
        if (mApplication.fsCore__Payment_Amount__c == null){
            mValidationsPassed = false;   
            mValidationFailureMessage += 'Payment Amount cannot be blank.\n';
        }
        if (mApplication.fsCore__Rate__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Interest Rate cannot be blank.\n';
        }
        if ((mApplication.Primary_Customer_State__c == null)
            ||(mApplication.fsCore__State__c == null)){
                mValidationsPassed = false;
                mValidationFailureMessage += 'Customer home state cannot be blank, please check the state on the application or on the customer account.\n';   
            }else if ((mApplication.Primary_Customer_State__c == null)
                      &&(mApplication.fsCore__State__c != null)){
                          mValidationsPassed = false;
                          mValidationFailureMessage += 'Customer home state cannot be blank, please check the state on the customer account.\n';   
                      }else if ((mApplication.fsCore__State__c == null)
                                &&(mApplication.Primary_Customer_State__c != null)){
                                    mValidationsPassed = false;
                                    mValidationFailureMessage += 'Customer home state cannot be blank, please check the state on the application and regenerate the pricing.\n';   
                                }else if (mApplication.Primary_Customer_State__c <> mApplication.fsCore__State__c){
                                    mValidationsPassed = false;
                                    mValidationFailureMessage += 'Discrepancy between Customer home state and the state on the application.\n';
                                }          
        
        
        /* Post Tila can be sent anytime
List<dsfs__DocuSign_Status__c> docusignStatusList = [select id
, name
, dsfs__DocuSign_Envelope_ID__c
, Document_Type__c
, dsfs__Opportunity__c
, dsfs__Company__c
, dsfs__Envelope_Status__c
FROM dsfs__DocuSign_Status__c
WHERE Lending_Application_Name__c = :mApplication.Id 
AND dsfs__Envelope_Status__c != :resentEligibleMapStatusSet
AND Document_Type__c = :mPreTilaDocumentType Limit 1];




if(docusignStatusList != null && !docusignStatusList.isEmpty()) {
dsfs__DocuSign_Status__c docusignStatus = docusignStatusList.get(0);

mEnvelopeAlreadySent = true;
mValidationFailureMessage = 'Tila Already Sent out for this application, please mark the existing one as void and then proceed.';
mEnvelopeId = docusignStatus.dsfs__DocuSign_Envelope_ID__c;
mEnvelopeStatus = docusignStatus.dsfs__Envelope_Status__c;
}*/
        
        if (mValidationsPassed && !mEnvelopeAlreadySent){
            return drawLoopPage;
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mValidationFailureMessage));
        return null;
    }
    private static void logmessage (Object pMessage){
        system.debug(logginglevel.error,pMessage);
    }  
}