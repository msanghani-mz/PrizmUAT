/*
 * Class Name : DNLApplicant
 * Purpose    : This class is used as a data structure required to 
 *              populate the details of a DNL Applicant
 * Developer  : Financial Spectra
 */
public class DNLApplicant {
    
    public String     specialOfferCode     {get; set;}
    public String     drpName              {get; set;}
    public String     drpAccount           {get; set;}
    public String     lawFirmName          {get; set;}

    public Id         recordId             {get; set;}
    public String     firstName            {get; set;}
    public String     middleNameInitial    {get; set;}
    public String     lastName             {get; set;}
    public String     dateOfBirth          {get; set;} //in mm/dd/yyyy format
    public String     socialSecurityNumber {get; set;}
    public String     residencyStatus      {get; set;} //US Citizen, Permanent Resident Alien
    public String     emailAddress         {get; set;}
    public String     homePhone            {get; set;}
    public String     mobilePhone          {get; set;}
    public String     workPhone            {get; set;}
    public String     addressSinceDate     {get; set;} //in mm/dd/yyyy format
    public Address    homeAddress          {get; set;}
    public Address    mailingAddress       {get; set;}
    public Address    previousHomeAddress  {get; set;}
    public String     primaryIDType        {get; set;} //Driver License, State Issued Id
    public String     primaryIDNumber      {get; set;}
    public String     primaryIDExpiryDate  {get; set;} //in mm/dd/yyyy format
    public String     primaryIDState       {get; set;}
    public String     motherMaidenName     {get; set;}
    public String     firstSchoolAttended  {get; set;}
    public Financial mainFinancial   {get; set;}
    public Employment previousEmployment   {get; set;}
    public List<Financial> otherFinancials   {get; set;}

    public Financial otherFinancial1   {get; set;}
    public Financial otherFinancial2   {get; set;}
    public Financial otherFinancial3   {get; set;}
    public Financial otherFinancial4   {get; set;}


    public String     housingId            {get; set;}
    public String     housingType          {get; set;} //rent, own, live with parents, other    
    public String     otherHousing         {get; set;}
    public String     monthlyPayment       {get; set;} //rent or mortgage repayment

    public String     maritalStatus   {get; set;}
    public String     spouseName      {get; set;}
    public String     spouseAddress   {get; set;}


    public DNLApplicant(){
        
        specialOfferCode     = '';
        drpName              = '';
        drpAccount           = '';
        
        firstName            = '';
        middleNameInitial    = '';
        lastName             = '';
        dateOfBirth          = '';
        socialSecurityNumber = '';
        residencyStatus      = '';
        emailAddress         = '';
        homePhone            = '';
        mobilePhone          = '';
        workPhone            = '';
        addressSinceDate     = '';
        homeAddress          = new Address();
        mailingAddress       = new Address();
        previousHomeAddress  = new Address();
        primaryIDType        = '';
        primaryIDNumber      = '';
        primaryIDExpiryDate  = '';
        primaryIDState       = '';
        motherMaidenName     = '';
        firstSchoolAttended  = '';

        mainFinancial        = new Financial();
        previousEmployment   = new Employment();

        otherFinancial1        = new Financial();
        otherFinancial2        = new Financial();
        otherFinancial3        = new Financial();
        otherFinancial4        = new Financial();
        housingId  = '';
        housingType          = '';
        otherHousing         = '';
        monthlyPayment       = '';
        maritalStatus       = '';
        spouseName       = '';
        spouseAddress       = '';

    }

    public class Address { 
        public String street        {get; set;}
        public String addressNumber {get; set;}
        public String aptNumber     {get; set;}
        public String city          {get; set;}
        public String state         {get; set;}
        public String zipCode       {get; set;}
        
        public Address(){
            aptNumber     = '';
            addressNumber = '';
            street        = '';
            city          = '';
            state         = '';
            zipCode       = '';
        }
    }

    public class Financial {
        public String incomeType  {get; set;}
        public String startDate     {get; set;} //in mm/dd/yyyy format
        public String annualIncome {get; set;}
        public String occupation{get; set;}
        public String provider      {get; set;}
        public String RecordID       {get; set;}
        public Employment employment    {get; set;}
        
        public Financial(){
            incomeType  = '';
            startDate     = '';
            annualIncome = '';
            occupation    = '';
            provider      = ''; 
            RecordID     = '';
            employment  = new Employment();
        }
    }

    public class Employment {
        public String employerName  {get; set;}
        public String startDate     {get; set;} //in mm/dd/yyyy format
        public String streetAddress {get; set;}
        public String city          {get; set;}
        public String state         {get; set;}
        public String zipCode       {get; set;}
        public String RecordID       {get; set;}
        
        public Employment(){
            employerName  = '';
            startDate     = '';
            streetAddress = '';
            city          = '';
            state         = '';
            zipCode       = '';
            RecordID     = '';
        }
    }

}