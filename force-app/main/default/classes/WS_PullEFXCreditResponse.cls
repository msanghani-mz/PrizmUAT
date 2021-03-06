/**
 * @File Name          : WS_PullEFXCreditResponse.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 8/23/2019, 8:11:11 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/21/2019, 8:48:28 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class WS_PullEFXCreditResponse {

    public class Paymentpattern_Z {
        public String StartDate;
        public String EndDate;
        public String pattern;
        public Months months;
    }

    public class Ficoscores {
        public Ficoscore ficoscore;
    }

    public class Address {
        public String Uid;
        public Multiplereportindicator addrtype;
        public String streetnumber;
        public String streetname;
        public String city;
        public String state;
        public String zip;
        public String datefirstreported;
        public String datelastreported;
        public Multiplereportindicator source;
        public String streettypedirectionapt;
    }

    public class Addresses_Z {
        public List<Address_Z> address;
    }

    public class Trade_Z {
        public String Uid;
        public String DateOpened;
        public String AccountName;
        public String DateReported;
        public String accountnumber;
        public String dla;
        public Multiplereportindicator recordcode;
        public String customernumber;
        //public Hitindicator industry;
        //public Hitindicator ratingorstatus;
        public String automatedupdateindicator;
        public Previoushigh1 previoushigh1;
        public Previoushigh1 previoushigh2;
        public Previoushigh1 previoushigh3;
        public Narrative1 narrative1;
        public Narrative1 narrative2;
        public Paymentpattern paymentpattern;
        public String iscollection;
        public String ismortgage;
        public String highororig;
        public String highorlimit;
        public String monthlypayment;
        public String balance;
        public Multiplereportindicator ecoa;
        public Terms terms;
        public String highcredit;
        public Multiplereportindicator accounttype;
        public String monthsreviewed;
    }

    public class Transactioninfo {
        public String Utc;
        public String Transid;
        public String Token;
        public String xmlns;
    }

    public class Creditreport {
        public Transactioninfo transactioninfo;
        public Printimage printimage;
        public Printimage reportdate;
        //public Subjects subjects;
    }

    public class Inquiries {
        public List<Inquiry> inquiry;
    }

    public class Addresses {
        public List<Address> address;
    }

    public class Trade {
        public String Uid;
        public String DateOpened;
        public String AccountName;
        public String DateReported;
        public String accountnumber;
        public String highororig;
        public String highorlimit;
        public String monthlypayment;
        public String balance;
        public String dla;
        public Multiplereportindicator recordcode;
        public Multiplereportindicator ecoa;
        public String customernumber;
        //public Hitindicator industry;
        public Terms terms;
        public String highcredit;
        public Multiplereportindicator accounttype;
        //public Hitindicator ratingorstatus;
        public String automatedupdateindicator;
        public Previoushigh1 previoushigh1;
        public Previoushigh1 previoushigh2;
        public Previoushigh1 previoushigh3;
        public Narrative1 narrative1;
        public Paymentpattern paymentpattern;
        public String iscollection;
        public String ismortgage;
        public String monthsreviewed;
        public Narrative1 narrative2;
        public String pastdue;
        public String late30;
        public String late60;
        public String late90plus;
        public String datefirstdelinquency;
    }

    public class Month {
        public String Code;
        public String Value;
        //public String Date;
    }

    public class Ficoscore_Z {
        public String Uid;
        public String ModelCode;
        public String NotScored;
        public String Score;
        public String InquiriesImpactedScore;
        public String modelname;
        public Factors factors;
    }

    public Boolean success;
    public Integer status;
    public Data data;

    public class Stratfsefxreport {
        public Creditreport creditreport;
        //public Factors_Z factors;
    }

    public class Factor {
        public String value;
        public String order;
        public String code;
    }

    public class Identificationssn {
        public String Uid;
        public String creditreportage;
        public String creditreportssn;
    }

    public class Subjects {
        public String xmlns;
        public Subject subject;
    }

    public class Subjects_Z {
        public String xmlns;
        public Subject_Z subject;
    }

    public class Multiplereportindicator {
        public String Code;
        public String Value;
    }

    public class Months {
        public List<Month> month;
    }

    public class Terms {
        public String monthlypayment;
    }

    public class Cofile {
        public Stratfsefxreport_Z stratfsefxreport;
    }

    public class Narrative1 {
        public String value;
        public String Code;
    }

    public class Previoushigh1 {
        public String value;
    }

    public class Employments {
        public Employment employment;
    }

    public class Subject_Z {
        public String Uid;
        public String IsHit;
        public String IsFrozen;
        public String IsNotReturned;
        public String customersubcode;
        public Multiplereportindicator multiplereportindicator;
        public Multiplereportindicator ecoa;
        public String outputformatcode;
        //public Hitindicator hitindicator;
        public String filesince;
        public String dla;
        public String lastname;
        public String firstname;
        public String middlename;
        public String ssn;
        public String dob;
        public String numofadditionalmultiples;
        //public Hitindicator addrdiscrepancyindicator;
        public Identityscancodes identityscancodes;
        public Addresses_Z addresses;
        public Trades_Z trades;
        public Inquiries inquiries;
        public Ficoscores_Z ficoscores;
        public Identificationssn_Z identificationssn;
        public Militarylendingcoveredborrower militarylendingcoveredborrower;
    }

    public class File {
        public Stratfsefxreport stratfsefxreport;
    }

    public class Address_Z {
        public String Uid;
        public Multiplereportindicator addrtype;
        public String streetnumber;
        public String streetname;
        public String city;
        public String state;
        public String zip;
        public String datefirstreported;
        public String datelastreported;
        public Multiplereportindicator source;
    }

    public class Factors {
        public List<Factor> factor;
    }

    public class Ficoscores_Z {
        public Ficoscore_Z ficoscore;
    }

    public class Printimage {
        public String value;
        public String xmlns;
    }

    public class Employment {
        public String Uid;
        public Multiplereportindicator employmenttype;
        public String employer;
    }

    public class Creditreport_Z {
        public Transactioninfo transactioninfo;
        public Printimage printimage;
        public Printimage reportdate;
        //public Subjects_Z subjects;
    }

    public class Terms_Z {
        public Narrative1 paymentfrequency;
        public String duration;
    }

    public class Paymentpattern {
        public String StartDate;
    }

    public class Trades {
        public List<Trade> trade;
    }

    public class Ficoscore {
        public String Uid;
        public String ModelCode;
        public String NotScored;
        public String Score;
        public String InquiriesImpactedScore;
        public String modelname;
        public Factors factors;
        public Narrative1 factactindicator;
    }

    public class Hitindicator {
        public String value;
        public String Code;
    }

    public class Factors_Z {
        public String mlaflag;
        public Creditscore creditscore;
        public String firstcreditline;
        public String currentopencreditlines;
        public String revolvingcreditbalance;
        public String bankcardutilization;
        public String numberofdelinquenciesinlastyear;
        public String amountdelinquent;
        public String isnowdelinquent;
        public String numberofinquiriesinlast6months;
        public String totalcreditline;
        public String allcreditlines;
        public String monthlydebtpayment;
        public Creditscore dob;
        public Creditscore collections;
        public String ofac;
        public Creditscore numberofbankruptcypublicrecords;
        public String numberoftotalinquiries;
        public String monthlydebtpaymentoffer;
        public String acc_now_delinq;
        public String acc_open_past_24mths;
        public String ave_cur_bal;
        public String bc_open_to_buy;
        public String bc_util;
        public String chargeoff_within_12_mths;
        public Creditscore collections_12_mths_ex_med;
        public String delinq_2yrs;
        public String delinq_amnt;
        public String earliest_cr_line;
        public String mo_sin_old_il_acct;
        public String mo_sin_old_rev_tl_op;
        public String mo_sin_rcnt_rev_tl_op;
        public String mo_sin_rcnt_tl;
        public String mort_acc;
        public String mths_since_last_delinq;
        public String mths_since_last_major_derog;
        public Creditscore mths_since_last_record;
        public Creditscore mths_since_oldest_il_open;
        public String mths_since_recent_bc;
        public String mths_since_recent_bc_dlq;
        public String mths_since_recent_inq;
        public String mths_since_recent_revolv_delinq;
        public String num_accts_ever_120_pd;
        public String num_actv_rev_tl;
        public String num_bc_sats;
        public String num_bc_tl;
        public String num_il_tl;
        public String num_op_rev_tl;
        public String num_sats;
        public String num_tl_120dpd_2m;
        public String num_tl_30dpd;
        public String num_tl_90g_dpd_24m;
        public String num_tl_op_past_12m;
        public String pct_tl_nvr_dlq;
        public String percent_bc_gt_75;
        public Creditscore tot_coll_amt;
        public String tot_cur_bal;
        public String tot_hi_cred_lim;
        public String total_bal_ex_mort;
        public String total_bc_limit;
        public String total_il_high_credit_limit;
        public String total_rev_hi_lim;
        public String installment_balance;
        public String real_estate_balance;
        public String num_accts_ever_30_pd;
        public String num_accts_ever_60_pd;
        public String acc_open_past_6mths;
        public String delinq_90g_7yrs;
        public String rev_acc_open_past_7yrs;
        public String unsecured_cc_debt;
        public String unsecured_loan_balance;
        public String repossessions;
        public String collections_chargeoff_exmedic_24m;
        public String num_active_accts_6m;
        public String num_30dpd_mort_12m;
        public String num_30dpd_accts_6m;
        public String num_open_il_24m;
        public String mort_acc_open;
        public String mortgagebalance;
        public Creditscore collections_over500;
        public Creditscore coll_amt_ex_med_36m;
        public Creditscore student_loans_non_fed;
        public Creditscore auto_loans_repossessed;
        public Creditscore mort_foreclosed;
        public String il_util;
        public String num_rev_tl_bal_gt_0;
        public String open_il_12m;
        public String open_il_6m;
        public String open_rv_12m;
        public String open_rv_24m;
        public String all_util;
        public String max_bal_bc;
        public String total_acc;
        public Creditscore coll_amt_ex_med_84m;
        public String inq_last_12m;
        public String num_actv_bc_tl;
        public String total_cu_tl;
        public String mths_since_rcnt_il;
    }

    public class Trades_Z {
        public List<Trade_Z> trade;
    }

    public class Data {
        public String pullType;
        public File file;
        public Cofile cofile;
        public String parserError;
    }

    public class Factors_Y {
        public String mlaflag;
        public Creditscore creditscore;
        public String firstcreditline;
        public String currentopencreditlines;
        public String revolvingcreditbalance;
        public String bankcardutilization;
        public String numberofdelinquenciesinlastyear;
        public String amountdelinquent;
        public String isnowdelinquent;
        public String numberofinquiriesinlast6months;
        public String totalcreditline;
        public String allcreditlines;
        public String monthlydebtpayment;
        public String dob;
        public Creditscore collections;
        public String ofac;
        public Creditscore numberofbankruptcypublicrecords;
        public String numberoftotalinquiries;
        public String monthlydebtpaymentoffer;
        public String acc_now_delinq;
        public String acc_open_past_24mths;
        public String ave_cur_bal;
        public String bc_open_to_buy;
        public String bc_util;
        public String chargeoff_within_12_mths;
        public Creditscore collections_12_mths_ex_med;
        public Creditscore delinq_2yrs;
        public Creditscore delinq_amnt;
        public String earliest_cr_line;
        public String mo_sin_old_il_acct;
        public String mo_sin_old_rev_tl_op;
        public String mo_sin_rcnt_rev_tl_op;
        public String mo_sin_rcnt_tl;
        public String mort_acc;
        public Creditscore mths_since_last_delinq;
        public Creditscore mths_since_last_major_derog;
        public Creditscore mths_since_last_record;
        public String mths_since_oldest_il_open;
        public String mths_since_recent_bc;
        public Creditscore mths_since_recent_bc_dlq;
        public String mths_since_recent_inq;
        public Creditscore mths_since_recent_revolv_delinq;
        public String num_accts_ever_120_pd;
        public String num_actv_rev_tl;
        public String num_bc_sats;
        public String num_bc_tl;
        public String num_il_tl;
        public String num_op_rev_tl;
        public String num_sats;
        public String num_tl_120dpd_2m;
        public String num_tl_30dpd;
        public String num_tl_90g_dpd_24m;
        public String num_tl_op_past_12m;
        public String pct_tl_nvr_dlq;
        public String percent_bc_gt_75;
        public Creditscore tot_coll_amt;
        public String tot_cur_bal;
        public String tot_hi_cred_lim;
        public String total_bal_ex_mort;
        public String total_bc_limit;
        public String total_il_high_credit_limit;
        public String total_rev_hi_lim;
        public String installment_balance;
        public String real_estate_balance;
        public String num_accts_ever_30_pd;
        public String num_accts_ever_60_pd;
        public String acc_open_past_6mths;
        public Creditscore delinq_90g_7yrs;
        public String rev_acc_open_past_7yrs;
        public String unsecured_cc_debt;
        public Creditscore unsecured_loan_balance;
        public String repossessions;
        public String collections_chargeoff_exmedic_24m;
        public String num_active_accts_6m;
        public String num_30dpd_mort_12m;
        public String num_30dpd_accts_6m;
        public String num_open_il_24m;
        public String mort_acc_open;
        public String mortgagebalance;
        public Creditscore collections_over500;
        public Creditscore coll_amt_ex_med_36m;
        public Creditscore student_loans_non_fed;
        public Creditscore auto_loans_repossessed;
        public Creditscore mort_foreclosed;
        public String il_util;
        public String num_rev_tl_bal_gt_0;
        public String open_il_12m;
        public String open_il_6m;
        public String open_rv_12m;
        public String open_rv_24m;
        public String all_util;
        public Creditscore max_bal_bc;
        public String total_acc;
        public Creditscore coll_amt_ex_med_84m;
        public String inq_last_12m;
        public String num_actv_bc_tl;
        public String total_cu_tl;
        public String mths_since_rcnt_il;
    }

    public class Inquiry {
        public String Uid;
        //public String Date;
        public String CustomerNumberAndOrAbbrev;
        public String CustomerName;
        public Multiplereportindicator recordcode;
    }

    public class Identityscancodes {
        //public Hitindicator code;
    }

    public class Subject {
        public String Uid;
        public String IsHit;
        public String IsFrozen;
        public String IsNotReturned;
        public String customersubcode;
        public Multiplereportindicator multiplereportindicator;
        public Multiplereportindicator ecoa;
        public String outputformatcode;
        //public Hitindicator hitindicator;
        public String filesince;
        public String dla;
        public String lastname;
        public String firstname;
        public String middlename;
        public String ssn;
        public String age;
        public String numofadditionalmultiples;
        //public Hitindicator addrdiscrepancyindicator;
        public Identityscancodes identityscancodes;
        public Addresses addresses;
        public Employments employments;
        public Trades trades;
        public Inquiries inquiries;
        public Ficoscores ficoscores;
        public Identificationssn identificationssn;
        public Militarylendingcoveredborrower militarylendingcoveredborrower;
    }

    public class Stratfsefxreport_Z {
        public Creditreport_Z creditreport;
        //public Factors_Y factors;
    }

    public class Militarylendingcoveredborrower {
        public String Uid;
        public String CoveredBorrower;
        public String regnonregidentifier;
        public String disclaimer;
        public String referralcontactphone;
    }

    public class Creditscore {
        //public String xsi:nil;
    }

    public class Identificationssn_Z {
        public String Uid;
        public String creditreportssn;
    }

    public class Previoushigh1_Z {
        public String value;
        public String Code;
        //public String Date;
    }

    
    public static WS_PullEFXCreditResponse parse(String json) {
        return (WS_PullEFXCreditResponse) System.JSON.deserialize(json, WS_PullEFXCreditResponse.class);
    }
}