/*
 * Class   : WS_AnalyzeCreditResponse 
 * Purpose : Structure of the Credit Analysis Web Service Response 
 * Author  : Financial Spectra
 */
public class WS_AnalyzeCreditResponse {

    public String lendingAppId;
    public ApplicantResponse applicant;
    public ApplicantResponse coApplicant;

    public class ApplicantResponse{
        public String firstName;
        public String lastName;
        public Boolean MLAMatch;//DV-68
        //DV-133
        public Decimal Inquiries_last_6m;
        public Decimal Total_Installment_Balance;
        public Decimal Total_Revolving_Balance;
        public Decimal Current_Delinquencies_Revolving;
        public Decimal Current_Delinquencies_Installment;
        public Decimal Public_Records;
        public Decimal FicoScore;
        public Decimal Bankruptcies;
        public Decimal Real_Estate_Balance;
        public Decimal Real_Estate_Payments;
        public Decimal Age_of_the_Credit_Report;       
        public String[] immediateFailure;
        public String[] tobeReviewed;
        public String ssn;
    }
}