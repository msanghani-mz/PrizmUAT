/*
 * Class Name   - RESTInvestment
 * Description  - Request and Response Structures for 
 *                Investment REST Service
 * Developer(s) - Financial Spectra DEV
 */
public class RESTInvestment {

    public class Request{
        public Id      application_id        {get; set;}
        public Id      investor_account_id   {get; set;}
        public Id      investor_contact_id   {get; set;}
        public Decimal contribution_percent  {get; set;}
        public Decimal contribution_amount   {get; set;}
    }

    public class Response{
        public Id      investment_id         {get; set;}
        public String  investment_number     {get; set;}
        public Id      investor_account_id   {get; set;}
        public String  investor_account_name {get; set;}
        public Id      investor_contact_id   {get; set;}
        public String  investor_contact_name {get; set;}
    //    public Decimal contribution_percent  {get; set;}
        public Decimal contribution_amount   {get; set;}
        public Decimal rate                  {get; set;}
        public String  status                {get; set;}
        
        public Response(){}
        
        public Response(fsCore__Lending_Application_Investment__c pAppInvestment){
            investment_id = pAppInvestment.Id;
            investment_number = pAppInvestment.Name;
            investor_account_id = pAppInvestment.fsCore__Account_Name__c;
            investor_account_name = pAppInvestment.fsCore__Account_Name_Formula__c;
            investor_contact_id = pAppInvestment.fsCore__Contact_Name__c;
            investor_contact_name = pAppInvestment.fsCore__Contact_Name_Formula__c;
          //  contribution_percent = pAppInvestment.fsCore__Contribution_Percent__c;
            contribution_amount = pAppInvestment.fsCore__Contribution_Amount__c;
            rate = pAppInvestment.fsCore__Rate__c;
            status = pAppInvestment.fsCore__Status__c;
        }
    }
        
}