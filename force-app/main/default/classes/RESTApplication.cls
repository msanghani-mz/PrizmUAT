/*
 * Class Name   - RESTApplication
 * Description  - Request and Response Structures for 
 *                Lending Application REST Service
 * Developer(s) - Financial Spectra DEV
 */
public class RESTApplication {

    public class Request{
        public String  reference_number        {get; set;}  //unique key of external system
        public Date    application_date        {get; set;}
        public String  product_code            {get; set;}
        public Decimal requested_loan_amount   {get; set;}
        public Decimal requested_loan_term     {get; set;}
        public String  requested_payment_cycle {get; set;}
        public String  loan_purpose            {get; set;}
        public String  velocify_id             {get; set;}
        public List<RESTApplicant.Request> applicants {get; set;}
    }

    public class Response {
        public Id      application_id             {get; set;}
        public String  application_number         {get; set;}
        public String  reference_number           {get; set;}
        public List<RESTApplicant.Response> applicants {get; set;}
    }

    public class StatusChangeRequest{
        public Id      application_id          {get; set;}
        public String  status                  {get; set;}
    }    
    public class HardPullScoreUpdateRequest{
        public Id      application_id          {get; set;}
        public Decimal model_hard_pull_score   {get; set;} //SUP-285
    }      

    public class WithdrawRequest{
        public Id      application_id          {get; set;}
        public String  withdraw_reason         {get; set;}
    }    

    public class DeclineRequest{
        public String  application_id          {get; set;}
        public String  decline_cause           {get; set;}
        public String  decline_comments        {get; set;}
        public String  credit_bureau_used      {get; set;}
        public Integer  apl_credit_score           {get; set;}
        public Integer  coapl_credit_score           {get; set;}
        public List<String>  apl_credit_score_factors      {get; set;}
        public List<String>  coapl_credit_score_factors      {get; set;}
        //public List<Reason> internal_reasons   {get; set;}
        public List<String> external_reasons   {get; set;}
    }
    
    /*public class Reason{
        public String reason_code              {get; set;}
        public String reason_description       {get; set;}
    }*/

}