/*
 * Class   : WS_AnalyzeCreditRequest 
 * Purpose : Structure of the Credit Analysis Web Service Request 
 * Author  : Financial Spectra
 */
public class WS_AnalyzeCreditRequest {

    
    //public ApplicantInfo CreditAnalysis;
    public String application_number;

    public WS_AnalyzeCreditRequest(){
        application_number = null;
    }

    

    /*public class ApplicantInfo{
        public ApplicantRequest coApplicant;
        public ApplicantRequest applicant;
        public String AnalysisID;
    }*/

    /*public class ApplicantRequest{
        public String firstName;
        public String lastName;
        public String homeAddress;
        public String city;
        public String state;
        public String zipCode;
        public String dob; //YYYY-MM-DDT00:00:00 format
        public String creditId; //Salesforce ID
        public String credit; //CREDIT REPORT
    }*/
}