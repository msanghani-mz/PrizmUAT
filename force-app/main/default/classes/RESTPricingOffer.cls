/*
 * Class Name   - RESTPricingOffer
 * Description  - Request and Response Structure for 
 *                Pricing Offer REST Service
 * Developer(s) - Financial Spectra DEV
 */
public class RESTPricingOffer {

    public class Request{
        public Id      application_id             {get; set;}
        public Date    start_date                 {get; set;}
        public Date    payment_start_date         {get; set;}
        public Integer number_of_payments         {get; set;}
        public Decimal approved_amount            {get; set;}
        public Decimal rate                       {get; set;}
        public Decimal origination_fee            {get; set;}
        public Boolean include_origination_fee    {get; set;}
        public Boolean origination_fee_in_percent {get; set;}
        public String  grade                      {get; set;}
        public String  pull_type                  {get; set;}
        public Boolean auto_accept_Offer          {get; set;}
        public Decimal model_payment_amount       {get; set;}
        public Decimal model_annual_percent_rate  {get; set;} //SUP-285
        public Decimal model_soft_pull_score      {get; set;} //SUP-285
        public Decimal model_hard_pull_score      {get; set;} //SUP-285
        public String  model_hard_decline_reason  {get; set;} //SUP-285
        public Boolean hard_pull_pricing_offer    {get; set;}
        public Integer versara_offer_id           {get; set;}//SUP-411
        public List<String>  apl_credit_score_factors      {get; set;}//SUP-452 
        public List<String>  coapl_credit_score_factors      {get; set;}//SUP-452 

    }
    
    public class AcceptOfferRequest{
        public Id      offer_id           {get; set;}
    }  

    public class Response{
        public Decimal loan_amount        {get; set;}
        public Decimal financed_amount    {get; set;}
        public Decimal rate               {get; set;}
        public Decimal number_of_payments {get; set;}
        public String  payment_cycle      {get; set;}
        public Decimal payment_amount     {get; set;}
        public Decimal final_payment_amount     {get; set;}
        public Decimal annual_percent_rate   {get; set;}
        public Boolean mismatch_in_payment_amount {get; set;}
    }
    
}