public class LobSchemaNew {
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
public class Merge_variables {
		public String ADATE {get;set;} 
		public String isdecline {get;set;} 
		public String reason {get;set;} 
		public String name1 {get;set;} 
		public String address_line {get;set;} 
		public String address_city1 {get;set;} 
		public String address_state1 {get;set;} 
		public String address_zip1 {get;set;} 
		public String phone1 {get;set;} 
		public String weburl {get;set;} 
		public String company {get;set;} 
		public String address_line1 {get;set;} 
		public String address_city {get;set;} 
		public String address_state {get;set;} 
		public String address_zip {get;set;} 
		public String address_country {get;set;} 
		public String phone2 {get;set;} 
		public String weburl1 {get;set;} 
		public String credit_pulldate {get;set;} 
		public String name {get;set;} 
		public String fico {get;set;} 
		public String phone {get;set;} 
		public String scoring {get;set;} 
		public String decline_cause {get;set;} 
		public String loanamount {get;set;} 
}
		
     public class LobResponse{
        
        public Message message               	{get;set;}
        public Boolean status               	{get;set;}
        public String error 					{get;set;}
        
    }
    
	public class Message {
		public String id {get;set;} 
		public String description {get;set;} 
		public Metadata metadata {get;set;} 
		public To to {get;set;} 
		public From_Z from_Z {get;set;} // in json: from
		public String color {get;set;} 
		public String double_sided {get;set;} 
		public String address_placement {get;set;} 
		public String return_envelope {get;set;} 
		public String perforated_page {get;set;} 
		public String custom_envelope {get;set;} 
		public String extra_service {get;set;} 
		public String mail_type {get;set;} 
		public String url {get;set;} 
		public Merge_variables merge_variables {get;set;} 
		public String template_id {get;set;} 
		public String template_version_id {get;set;} 
		public String carrier {get;set;} 
		public String tracking_number {get;set;} 
		public List<Metadata> tracking_events {get;set;} 
		public List<Thumbnails> thumbnails {get;set;} 
		public String expected_delivery_date {get;set;} 
		public String date_created {get;set;} 
		public String date_modified {get;set;} 
		public String send_date {get;set;} 
		public String object_Z {get;set;} // in json: object

		
	}
	public class Metadata {
    }
	
	public class From_Z {
		public String id {get;set;} 
		public String description {get;set;} 
		public String name {get;set;} 
		public String company {get;set;} 
		public String phone {get;set;} 
		public Object email {get;set;} 
		public String address_line1 {get;set;} 
		public Object address_line2 {get;set;} 
		public String address_city {get;set;} 
		public String address_state {get;set;} 
		public String address_zip {get;set;} 
		public String address_country {get;set;} 
		public Metadata metadata {get;set;} 
		public String date_created {get;set;} 
		public String date_modified {get;set;} 
		public Boolean deleted {get;set;} 
		public String object_Z {get;set;} // in json: object

    }	
	public class Thumbnails {
		public String small {get;set;} 
		public String medium {get;set;} 
		public String large {get;set;} 
    }
			
	public class To {
		public String id {get;set;} 
		public String description {get;set;} 
		public String name {get;set;} 
		public String company {get;set;} 
		public String phone {get;set;} 
		public String email {get;set;} 
		public String address_line1 {get;set;} 
		public String address_line2 {get;set;} 
		public String address_city {get;set;} 
		public String address_state {get;set;} 
		public String address_zip {get;set;} 
		public String address_country {get;set;} 
		public Metadata metadata {get;set;} 
		public String date_created {get;set;} 
		public String date_modified {get;set;} 
		public Boolean deleted {get;set;} 
		public String object_Z {get;set;} // in json: object

		}	

}