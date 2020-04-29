/**
 * @File Name          : RESTApplicant.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/7/2019, 1:43:07 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/7/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class RESTApplicant {
    
    public class Request{
        public String  first_name              {get; set;}
        public String  last_name               {get; set;}
        public Date    date_of_birth           {get; set;}
        public String  relationship            {get; set;} //Primary/Secondary
        public String  email                   {get; set;}
        public String  phone_number            {get; set;}
        public String  mobile_number           {get; set;}
        public String  mailing_street          {get; set;}
        public String  mailing_city            {get; set;}
        public String  mailing_state           {get; set;}
        public String  mailing_country         {get; set;}
        public String  mailing_postal_code     {get; set;}
        public String  home_street             {get; set;}
        public String  home_city               {get; set;}
        public String  home_state              {get; set;}
        public String  home_country            {get; set;}
        public String  home_postal_code        {get; set;}        
        public String  transunion_ssn          {get; set;}  
        public String  social_security_number  {get; set;}
        public Decimal annual_stated_Income    {get; set;}
    }
    
    public class Response{
        public Id      applicant_id            {get; set;}
        public Id      applicant_account_id    {get; set;}
        public String  applicant_name          {get; set;}
        public String  relationship            {get; set;}
    }

}