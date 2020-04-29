public class LobSchema {
    
    public class LobRequest{
        
        public String application_date 	{get;set;}
        
        public String name 				{get;set;}
        public String loanamount		{get;set;}
        public String credit_pulldate	{get;set;}
        public String fico				{get;set;}
        public String decline_cause		{get;set;}
        public String creditscore		{get;set;}
        public String external_reasons	{get;set;}
        
        public String phone				{get;set;}
        public String mailing_street	{get;set;}
        public String mailing_city		{get;set;}
        public String mailing_state		{get;set;}
        public String mailing_country	{get;set;}
        public String mailing_postal_code{get;set;}
        
    }
    
    public class LobResponse{
        
        public String message               	{get;set;}
        public Boolean status               	{get;set;}
        public String error 					{get;set;}
        
    }
    
    
}