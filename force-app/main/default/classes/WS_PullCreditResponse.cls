/*
 * Class   : WS_PullCreditResponse
 * Purpose : Structure of the Credit Pull Web Service JSON response 
 * Author  : Financial Spectra
 */
public class WS_PullCreditResponse{
    
    public boolean success;
    public CreditPullData data;
    
    public class CreditPullData {
        public String pullType;
        public CreditPullFile file;
        public CreditPullFile cofile;
    }

    public class CreditPullFile {
        public HX5 hx5;
    }
    public class HX5 {
        public String version;
        public HTMLReports html_reports;
        public TTYReports tty_reports;
        public BureauXMLData bureau_xml_data;
        public HX5TransactionInfo hx5_transaction_information;
    }
    
    public class HTMLReports {
        public HTMLReport html_report;
    }
    
    public class HTMLReport {
        public String value;
        public String fmt_type;
    }
    
    public class TTYReports {
        public TTYReport tty_report;
    }
    
    public class TTYReport {
        public String value;
        public String id;
    }
    
    public class HX5TransactionInfo {
        public String transid;
        public String token;
    }

    public class BureauXMLData {
        public TUReport tu_report;
    }
    
    public class CodeValueType{
        public String value;
        public String code;
    }

    public class DateValueType{
        public String value;
        public String fmt;
    }

    public class TUReport {
        public TransactionControl transaction_control;
        public ConsumerData consumer_data;
        public BureauProductHeader bureau_product_header;
        public SubjectSegments subject_segments;
        public TransactionEnding transaction_ending;
    }
    
    public class TransactionControl {
        public String id;
        public CodeValueType version_switch;
        public CodeValueType country_code;
        public CodeValueType language_indicator;
        public String user_reference;
        public String market;
        public String submarket;
        public String industry_code;
        public String member_code;
        public DateValueType trans_date;
        public DateValueType trans_time;
    }
    
    public class ConsumerData {
        public String id;
        public String customer_identifier_qualifier;
        public String customer_identifier;
        public String password;
    }
    
    public class BureauProductHeader {
        public String value;
        public String id;
        public String code;
    }

    public class SubjectSegments {
        public String id;
        public String num;
        public SubjectHeader subject_header;
        public List<NameInfo> name_information; //FOR APP DNL180720001292 IT IS COMING AS LIST
        public PersonalInfo personal_information;
        public List<IdMismatchAlert> id_mismatch_alert{get;set;} //FOR APP 170619004919 issue with the list
        public List<AddressInfo> address_information; //FOR ONE APP IT IS COMING AS LIST
        public list<EmploymentSegments> employment_segments{get;set;} //NOT CONSISTENT APP DNL180720000158 RETURN ONLY 1
        public CreditSummary credit_summary;
        public list<CreditSummaryDescription> credit_summary_description;
        public TradeSegments trade_segments;
        public InquirySegments inquiry_segments;
        public ScoringSegments scoring_segments;
        public OFACNameScreenSegments ofac_name_screen_segments;
        public MilitaryLendingActSearch military_lending_act_search;
    }
    public class InquirySegments {
        public String id;   //IN01
        public String product;  //07000
        public Inquiry[] inquiry; //NOT CONSISTENT TEMP FOR DNL180720000225 IT NEEDS THE ARRAY
    }
    public class Inquiry {
        public String id;   //IN01
        public String bureau_market;    //06
        public String bureau_submarket; //TR
        public IndustryCode industry_code;
        public String member_code;  //03419421
        public String subscriber_name;  //PEERFORM INC
        public Inquirytype Inquiry_type;
        public LoanType loan_type;
        public String loan_amount;  //
            
        public DateOfInquiry date_of_inquiry;
    }

    class IndustryCode {
        public String value;    //Finance, personal
        public String code; //F
    }
    class Inquirytype {
        public String value;    //Individual
        public String code; //I
    }
    class DateOfInquiry {
        public String value;    //20181220
        public String fmt;  //CCYYMMDD
    }        

    public class TradeSegments {
        public String id;   //TR01
        public String product;  //07000
        public Trade[] trade;
    }
    public class Trade {
        public String id;   //TR01
        public String industry_code;    //D
        public String member_code;  //01249003
        public String subscriber_name;  //RNB-MERVYN
        public AccountType account_type;
        public String account_number;   //1111187
        public accountDesignator account_designator;
        public dateOpened date_opened;
        public dateVerified date_verified;
        public tradeVerificationIndicator trade_verification_indicator;
        public dateClosed date_closed;
        public dateClosedIndicator date_closed_indicator;
        public datePaidOut date_paid_out;
        public dateOfLastActivity date_of_last_activity;
        public currentMannerOfPayment current_manner_of_payment;
        //public cls_currency currency;
        public String balance;  //000000192
        public String high_credit;  //000000192
        public String credit_limit; //
        public termsDuration terms_duration;
        public termsFrequency terms_frequency;
        public String amount_of_payment;    //
        public String collateral;   //
        public loanType loan_type;
        public remarksCode remarks_code;
        public String amount_past_due;  //000000192
        public String number_payments_past_due; //00
        public maxDelinquencyAmount max_delinquency_amount;
        public maxDelinquencyDate max_delinquency_date;
        public String max_delinquency_mop;  //
        public paymentPatternStartDate payment_pattern_start_date;
        public paymentPattern payment_pattern;
        public String number_months_reviewed;   //00
        public String times_30_days_late;   //
        public String times_60_days_late;   //
        public String times_90_days_late;   //
        public historicalCountersVerificationIndicator historical_counters_verification_indicator;
    }
    class TradeVerificationIndicator {
        public String value;    //Automated account
        public String code; //A
    }    

    class MaxDelinquencyAmount {
        public String date_del; //
    }
    class MaxDelinquencyDate {
        public String fmt;  //CCYYMMDD
    }
    class PaymentPatternStartDate {
        public String fmt;  //CCYYMMDD
    }
    class PaymentPattern {
        public String start_date;   //
    }
    class HistoricalCountersVerificationIndicator {
        public String code; //
    }    

    class RemarksCode {
        public String value;    //Profit and loss writeoff
        public String code; //PRL
    }    
     class TermsDuration {
        public String frequency;    //
    }
    class TermsFrequency {
        public String code; //
    }
    class LoanType {
        public String code; //
    }
    class CurrentMannerOfPayment {
        public String value;    //Charged off as bad debt
        public String code; //09
    }    
    class DateOfLastActivity {
        public String fmt;  //CCYYMMDD
    }
    class cls_currency {
        public String value;    //United States currency
        public String code; //1
    }
    class AccountDesignator {
        public String value;    //Individual account
        public String code; //I
    }
    class DateOpened {
        public String value;    //20111226
        public String fmt;  //CCYYMMDD
    }
    class DateVerified {
        public String value;    //20180719
        public String fmt;  //CCYYMMDD
    }
    class VerificationIndicator {
        public String value;    //Automated account
        public String code; //A
    }
    class DateClosed {
        public String value;    //20120616
        public String fmt;  //CCYYMMDD
    }
    class DateClosedIndicator {
        public String value;    //Account was closed because of charge-off or repossession
        public String code; //F
    }
    class DatePaidOut {
        public String fmt;  //CCYYMMDD
    }    
    class AccountType {
        public String value;    //Revolving account
        public String code; //R
    }

    public class CreditSummaryDescription {
        public String id;   //SD01
        public SummaryType summary_type;
        public String high_credit;  //000019367
        public String credit_limit; //000048100
        public String balance;  //000004095
        public String amount_past_due;  //000000000
        public String monthly_payment;  //000000229
        public String percent_credit_available; //091
    }   
    class SummaryType {
        public String value;    //Revolving or check credit account
        public String code; //R
    }     
    class CreditSummary {
        public String id;   //SM01
        public ReportingPeriod reporting_period;
        public String public_records;   //000
        public String collections;  //001
        public String negative_trades;  //001
        public String trades_with_any_historical_negative;  //001
        public String occurrence_of_historical_negative;    //001
        public String trades;   //020
        public String revolving_and_check_credit_trades;    //013
        public String installments; //001
        public String mortgages;    //004
        public String open_accounts;    //002
        public String inquiries;    //002
    }
    class ReportingPeriod {
        public String value;    //Total history
        public String code; //1
    }    

    public class EmploymentSegments {
        public String id;   //EM01
        public String product;  //07000
        public EmploymentInformation employment_information;
    }
    class EmploymentInformation {
        public String id;   //EM01
        public String employer_name;    //ZOOTLAND
        public SourceIndicator source_indicator;
        public String occupation;   //GARDENER
        public DateHired date_hired;
        public DateSeparated date_separated;
        public DateVerifiedOrReported date_verified_or_reported;
        public DateVerifiedOrReportedCode date_verified_or_reported_code;
        public String income;   //
        public PayBasis pay_basis;
    }   
    /*class SourceIndicator {
        public String code; //F
    }*/
    class DateHired {
        public String value;    //20131201
        public String fmt;  //CCYYMMDD
    } 
    class DateSeparated {
        public String fmt;  //CCYYMMDD
    }   
    class DateVerifiedOrReported {
        public String value;    //20181110
        public String fmt;  //CCYYMMDD
    }
    class DateVerifiedOrReportedCode {
        public String value;    //Date Verified is displayed
        public String code; //V
    }
    class PayBasis {
        public String code; //
    }        
    public class IdMismatchAlert{
        public String id{get;set;}
        public addressType address_type{get;set;}
        public messageType message_type{get;set;}
        public alertCondition alert_condition{get;set;}
        public String number_inquiries_last_60_days{get;set;}
    } 
    public class alertCondition{
        public String value{get;set;}
        public String code{get;set;}
    }

    public class messageType{
        public String value{get;set;}
        public String code{get;set;}
    }       
    public class addressType{
        public String code{get;set;}
        public String value{get;set;}
    }    
    public class PersonalInfo{
        public String dob{get;set;}
        public String ssn{get;set;}
        public String age{get;set;}
        public sourceIndicator source_indicator{get;set;}
        public gender gender{get;set;}
        public String id{get;set;}
    }    
    
    public class sourceIndicator{
        public String code{get;set;}
        public String value{get;set;}
    }
    public class gender{
        public String code{get;set;}
    }

    public class SubjectHeader {
        public String id;
        public CodeValueType subject_id;
        public String file_number;
        public CodeValueType file_hit;
        public CodeValueType ssn_match_ind;
        public CodeValueType consumer_statement_ind;
        public String bur_market_file_control; 
        public String bur_submarket_file_control;
        public CodeValueType suppression_ind;
        public String infile_since_date;
    }

    public class NameInfo {
        public String id;
        public String type;
        public CodeValueType source_indicator;
        public CodeValueType name_indicator;
        public String lname;
        public String fname;
        public String mname;
        public String prefix;
        public String suffix;
    }

    public class AddressInfo {
        public String id;
        public CodeValueType source_indicator;
        public CodeValueType addr_qualifier;
        public String house_number;
        public String predirectional;
        public String street_name;
        public String postdirectional;
        public String street_type;
        public String apt_unit_number; 
        public String city;
        public String state;
        public String zip;
        public String date_reported;
    }
    
    public class ScoringSegments {
        public String id;
        public String product;
        public ProductInfo product_information;
    }

    public class OFACNameScreenSegments {
        public String id;
        public String product;
        public ProductInfo product_information;
    }

    public class MilitaryLendingActSearch {
        public String id;
        public String product;
        public ProductInfo product_information;
    }

    public class ProductInfo {
        public String id;
        public CodeValueType product_status;
        public CodeValueType search_status;
    }

    public class TransactionEnding {
        public String id;
        public String segments_returned;
    }

}