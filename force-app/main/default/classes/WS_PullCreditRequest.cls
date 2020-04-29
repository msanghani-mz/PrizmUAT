/*
 * Class   : WS_PullCreditRequest
 * Purpose : Structure of the Credit Pull Web Service Request 
 * Author  : Financial Spectra
 */
public class WS_PullCreditRequest {

    public String application_number;
    public URLParams url_params;

    public WS_PullCreditRequest(){
        application_number = null;
        url_params = new URLParams();
    }
    
    public class URLParams {
        public String name;
        public String address;
        public String city;
        public String state;
        public String zip;
        public Date   birth_date;
        public String format;
        public String pull_type;
        public String source; //PDI-389 SFS added source=versara in query string
        public String ssn;//SUP-19 new parameter
        //PDI-620 NEW PARAMS
        public String coName;
        public String coAddress;
        public String coCity;
        public String coState;
        public String coZip;
        public Date   coBirth_date;   
        public String cossn;    //SUP-19 new parameter
        

    }
    
}