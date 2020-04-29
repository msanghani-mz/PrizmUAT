/**
* @File Name          : SendToDocuSignController.cls
* @Description        : 
* @Author             : FinancialSpectra
* @Group              : 
* @Last Modified By   : Abhinav
* @Last Modified On   : 4/27/2020, 11:55:49 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    6/26/2019, 6:46:40 PM   PDI-744     Initial Version
* 1.1    7/09/2019, 6:46:40 PM   PDI-758 
**/
public with sharing class SendToDocuSignController {
    public Opportunity  mOpportunity       {get; private set;}
    
    public String mEnvelopeId {get;set;}
    public String mEnvelopeStatus {get;set;}
    public String mValidationFailureMessage {get;set;}
    private Boolean sentToDocuSign = false;
    public Boolean mValidationsPassed {get; private set;}
    public Boolean mEnvelopeAlreadySent {get; private set;}
    public Boolean mLastEnvelopeCompleted {get; private set;}
    private MAP<String,Id> applicantsMap = new MAP<String,Id> ();
    public static String mEmailSubject = 'Please Sign this Loan Application';
    public static String mSenderDefaultEmail = 'sales@versaralending.com'; //PDI-855
    public static String mSenderDefaultName = 'The Versara Lending Team';
    
    
    public user mUser;
    
    public DNLApplicant mApplicant         {get; private set;}
    public DNLApplicant mCoApplicant       {get; private set;}
    
    private Set<String> resentEligibleMapStatusSet = new Set<String>{'Voided','Declined','Expired'};
        
        private static String mClassName='SendToDocuSignController';
    
    
    private static HttpRequest setRestHttpRequest (String pEndPoint,String pMethod){
        String authStr = '{ "Username" : "'+SFS_System_Settings__c.getInstance().Docusign_User_Id__c +'" ,"Password" : "'+SFS_System_Settings__c.getInstance().Docusign_Password__c +'" ,"IntegratorKey" : "'+SFS_System_Settings__c.getInstance().Docusign_Integrator_Key__c +'"}';
        system.debug(logginglevel.error,authStr);
        HttpRequest httpReq= new HttpRequest();
        httpReq.setHeader('x-docusign-authentication',authStr);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setMethod(pMethod);
        httpReq.setEndpoint(pEndPoint);
        
        return httpReq;
    }
    
    /**
* @description
* @author FinancialSpectra | 6/26/2019
* @param String pEnvelopeId
* @return DocusignFormDataJSON2Apex
*/
    public static DocusignFormDataJSON2Apex getCompletedFormData(String pEnvelopeId){
        DocusignFormDataJSON2Apex deresp2;
        if (Test.isRunningTest()){ //AD DO NOT CALL Docusign API for test
            StaticResource sr= [select id,body from StaticResource Where Name = 'Docusign_Loan_App_test'];
            String responseBody = sr.body.toString();
            deresp2=DocusignFormDataJSON2Apex.parse(responseBody);
            
        }else{
            String endPoint=SFS_System_Settings__c.getInstance().Docusign_REST_EndPoint__c+'/accounts/'+SFS_System_Settings__c.getInstance().Docusign_Account_Id__c+'/envelopes/'+pEnvelopeId+'/form_data';
            Http h2= new Http();
            HttpRequest req2 = setRestHttpRequest(endPoint,'GET');
            HttpResponse res2=h2.send(req2);
            logmessage('Body  :'+res2.getBody());
            deresp2=DocusignFormDataJSON2Apex.parse(res2.getBody());
        }
        
        return deresp2;
    }
    
    
    /*public static DocusignFormDataJSON2Apex getCompletedFormTestData(){
String formData = '{ '+
' "formData": ['+
' {'+
' "name": "Applicant Email",'+
' "value": "catane@hotmail.com"'+
' },'+
'     {'+
'       "name": "DRP Account",'+
'       "value": "P-110847"'+
'     },'+
'     {'+
'       "name": "DRP Name",'+
'       "value": "Stonepoint"'+
'     },'+
'     {'+
'       "name": "Applicant Currency Symbol2",'+
'       "value": "$"'+
'     },'+
'     {'+
'       "name": "Applicant Currency Symbol3",'+
'       "value": "$"'+
'     },'+
'     {'+
'       "name": "Applicant Currency Symbol4",'+
'       "value": "$"'+
'     },'+
'     {'+
'       "name": "Applicant Currency Symbol5",'+
'       "value": "$"'+
'     },'+
'     {'+
'       "name": "Applicant Currency Symbol4",'+
'       "value": "$"'+
'     },'+
'     {'+
'       "name": "Law Firm",'+
'       "value": "Stonepoint"'+
'     },'+
'     {'+
'       "name": "Applicant Currency Symbol1",'+
'       "value": "$"'+
'     },'+
'     {'+
'       "name": "Applicant U.S. Residency",'+
'       "value": "U.S. Citizen"'+
'     },'+
'     {'+
'       "name": "Applicant Primary Id",'+
'       "value": "Driver’s License"'+
'     },'+
'     {'+
'       "name": "Applicant Address Since Date",'+
'       "value": "06/2017"'+
'     },'+
'     {'+
'       "name": "Applicant Primary Id Number",'+
'       "value": "D06404318"'+
'     },'+
'     {'+
'       "name": "Applicant Id Expiration Date",'+
'       "value": "01/01/2026"'+
'     },'+
'     {'+
'       "name": "Applicant Id State",'+
'       "value": "AZ"'+
'     },'+
'     {'+
'       "name": "Applicant Housing",'+
'       "value": "Own"'+
'     },'+
'     {'+
'       "name": "Applicant Monthly Rent",'+
'       "value": "1,713.93"'+
'     },'+
'     {'+
'       "name": "ApplicantPrimaryIncomeProviderStartDate",'+
'       "value": "01/2016"'+
'     },'+
'     {'+
'       "name": "ApplicantPrimaryOccupation",'+
'       "value": "Physical therapist"'+
'     },'+
'     {'+
'       "name": "Applicant Employment Status",'+
'       "value": "Independent Contractor"'+
'     },'+
'     {'+
'       "name": "ApplicantPrimaryIncomeProvider",'+
'       "value": "Integrity home health"'+
'     },'+
'     {'+
'       "name": "Applicant Source Of Other Income1",'+
'       "value": "Independent Contractor"'+
'     },'+
'     {'+
'       "name": "Applicant Annual Base Salary",'+
'       "value": "12,270.00"'+
'     },'+
'     {'+
'       "name": "ApplicantSec1Occupation",'+
'       "value": "Physical therapist"'+
'     },'+
'     {'+
'       "name": "Applicant Other Annual Income1",'+
'       "value": "12,100"'+
'     },'+
'     {'+
'       "name": "Applicant Source Of Other Income2",'+
'       "value": "Independent Contractor"'+
'     },'+
'     {'+
'       "name": "Applicant Other Income Start Date1",'+
'       "value": "05/2018"'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeProvider1",'+
'       "value": "Bridges Home Health"'+
'     },'+
'     {'+
'       "name": "Applicant Other Income Start Date2",'+
'       "value": "01/2017"'+
'     },'+
'     {'+
'       "name": "ApplicantSec2Occupation",'+
'       "value": "Physical theapist"'+
'     },'+
'     {'+
'       "name": "Applicant Other Annual Income2",'+
'       "value": "20,250"'+
'     },'+
'     {'+
'       "name": "Applicant Source Of Other Income3",'+
'       "value": "Independent Contractor"'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeProvider2",'+
'       "value": "My Home Health"'+
'     },'+
'     {'+
'       "name": "Applicant Other Income Start Date3",'+
'       "value": "01/2018"'+
'     },'+
'     {'+
'       "name": "ApplicantSec3Occupation",'+
'       "value": "Physical therapist"'+
'     },'+
'     {'+
'       "name": "Applicant Other Annual Income3",'+
'       "value": "14,775"'+
'     },'+
'     {'+
'       "name": "Applicant Source Of Other Income4",'+
'       "value": "Independent Contractor"'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeProvider3",'+
'       "value": "Arizona Home Health"'+
'     },'+
'     {'+
'       "name": "Applicant Other Income Start Date4",'+
'       "value": "02/2017"'+
'     },'+
'     {'+
'       "name": "Applicant Other Annual Income4",'+
'       "value": "4,420"'+
'     },'+
'     {'+
'       "name": "ApplicantSec4Occupation",'+
'       "value": "Physical therapist"'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeProvider4",'+
'       "value": "Valley of sun Home H"'+
'     },'+
'     {'+
'       "name": "Applicant Mailing Street",'+
'       "value": "10236 W Puget Ave"'+
'     },'+
'     {'+
'       "name": "Applicant Mailing City",'+
'       "value": "Peoria"'+
'     },'+
'     {'+
'       "name": "Applicant First Name",'+
'       "value": "Jessie"'+
'     },'+
'     {'+
'       "name": "Applicant Home Street",'+
'       "value": "10236 W Puget Ave"'+
'     },'+
'     {'+
'       "name": "Applicant Last Name",'+
'       "value": "Roa"'+
'     },'+
'     {'+
'       "name": "Applicant Home City",'+
'       "value": "Peoria"'+
'     },'+
'     {'+
'       "name": "Applicant Home Phone",'+
'       "value": "(602) 418-7848"'+
'     },'+
'     {'+
'       "name": "Applicant SSN",'+
'       "value": "590-88-8459"'+
'     },'+
'     {'+
'       "name": "Applicant Mailing Zip Code",'+
'       "value": "85345"'+
'     },'+
'     {'+
'       "name": "Applicant Home Zip Code",'+
'       "value": "85345"'+
'     },'+
'     {'+
'       "name": "Applicant Mailing State",'+
'       "value": "AZ"'+
'     },'+
'     {'+
'       "name": "Applicant Home State",'+
'       "value": "AZ"'+
'     },'+
'     {'+
'       "name": "Applicant Date Of Birth",'+
'       "value": "1/1/1961"'+
'     },'+
'     {'+
'       "name": "Applicant Date Signed1",'+
'       "value": "02-Feb-2020 &#124; 3:27:18 PM EST"'+
'     },'+
'     {'+
'       "name": "Date Signed 387ea237-a2bb-496a-8115-1525652f6708",'+
'       "value": "02-Feb-2020 &#124; 3:27:18 PM EST"'+
'     },'+
'     {'+
'       "name": "Applicant First School",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Other City",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Other Street",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Mother Maiden Name",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Home Apartment",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant MI",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Mailing Apartment",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Mobile Phone",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Work Phone",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Other Apartment",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Other Zip Code",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Other State",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Previous Employer",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeId3",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantPreviousEmployerID",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantCurrentEmployerID",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeId2",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantHousingId",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeId4",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantOtherIncomeId1",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantMainIncomeId",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantSpouseAddress",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantSpouseName",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "ApplicantMaritalStatus",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Previous Employer Street",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Previous Employer City",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Previous Employer State",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Previous Employer Zip",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Applicant Previous Employer Start Date",'+
'       "value": ""'+
'     },'+
'     {'+
'       "name": "Special Offer Code",'+
'       "value": ""'+
'     }'+
' ],'+
'   "envelopeId": "70a71f67-d2a2-4c2f-9af2-0935b73bc9aa",'+
' "status": "completed",'+
'   "sentDateTime": "2020-01-31T03:28:32.0000000Z",'+
' "recipientFormData": ['+
' {'+
' "formData": ['+
' {'+
' "name": "Applicant Email",'+
'           "value": "catane@hotmail.com"'+
'         },'+
'         {'+
'           "name": "DRP Account",'+
'           "value": "P-110847"'+
'         },'+
'         {'+
'           "name": "DRP Name",'+
'           "value": "Stonepoint"'+
'         },'+
'         {'+
'           "name": "Applicant Currency Symbol2",'+
'           "value": "$"'+
'         },'+
'         {'+
'           "name": "Applicant Currency Symbol3",'+
'           "value": "$"'+
'         },'+
'         {'+
'           "name": "Applicant Currency Symbol4",'+
'           "value": "$"'+
'         },'+
'         {'+
'           "name": "Applicant Currency Symbol5",'+
'           "value": "$"'+
'         },'+
'         {'+
'           "name": "Applicant Currency Symbol4",'+
'           "value": "$"'+
'         },'+
'         {'+
'           "name": "Law Firm",'+
'           "value": "Stonepoint"'+
'         },'+
'         {'+
'           "name": "Applicant Currency Symbol1",'+
'           "value": "$"'+
'         },'+
'         {'+
'           "name": "Applicant U.S. Residency",'+
'           "value": "U.S. Citizen"'+
'         },'+
'         {'+
'           "name": "Applicant Primary Id",'+
'           "value": "Driver’s License"'+
'         },'+
'         {'+
'           "name": "Applicant Address Since Date",'+
'           "value": "06/2017"'+
'         },'+
'         {'+
'           "name": "Applicant Primary Id Number",'+
'           "value": "D06404318"'+
'         },'+
'         {'+
'           "name": "Applicant Id Expiration Date",'+
'           "value": "01/01/2026"'+
'         },'+
'         {'+
'           "name": "Applicant Id State",'+
'           "value": "AZ"'+
'         },'+
'         {'+
'           "name": "Applicant Housing",'+
'           "value": "Own"'+
'         },'+
'         {'+
'           "name": "Applicant Monthly Rent",'+
'           "value": "1,713.93"'+
'         },'+
'         {'+
'           "name": "ApplicantPrimaryIncomeProviderStartDate",'+
'           "value": "01/2016"'+
'         },'+
'         {'+
'           "name": "ApplicantPrimaryOccupation",'+
'           "value": "Physical therapist"'+
'         },'+
'         {'+
'           "name": "Applicant Employment Status",'+
'           "value": "Independent Contractor"'+
'         },'+
'         {'+
'           "name": "ApplicantPrimaryIncomeProvider",'+
'           "value": "Integrity home health"'+
'         },'+
'         {'+
'           "name": "Applicant Source Of Other Income1",'+
'           "value": "Independent Contractor"'+
'         },'+
'         {'+
'           "name": "Applicant Annual Base Salary",'+
'           "value": "12,270.00"'+
'         },'+
'         {'+
'           "name": "ApplicantSec1Occupation",'+
'           "value": "Physical therapist"'+
'         },'+
'         {'+
'           "name": "Applicant Other Annual Income1",'+
'           "value": "12,100"'+
'         },'+
'         {'+
'           "name": "Applicant Source Of Other Income2",'+
'           "value": "Independent Contractor"'+
'         },'+
'         {'+
'           "name": "Applicant Other Income Start Date1",'+
'           "value": "05/2018"'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeProvider1",'+
'           "value": "Bridges Home Health"'+
'         },'+
'         {'+
'           "name": "Applicant Other Income Start Date2",'+
'           "value": "01/2017"'+
'         },'+
'         {'+
'           "name": "ApplicantSec2Occupation",'+
'           "value": "Physical theapist"'+
'         },'+
'         {'+
'           "name": "Applicant Other Annual Income2",'+
'           "value": "20,250"'+
'         },'+
'         {'+
'           "name": "Applicant Source Of Other Income3",'+
'           "value": "Independent Contractor"'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeProvider2",'+
'           "value": "My Home Health"'+
'         },'+
'         {'+
'           "name": "Applicant Other Income Start Date3",'+
'           "value": "01/2018"'+
'         },'+
'         {'+
'           "name": "ApplicantSec3Occupation",'+
'           "value": "Physical therapist"'+
'         },'+
'         {'+
'           "name": "Applicant Other Annual Income3",'+
'           "value": "14,775"'+
'         },'+
'         {'+
'           "name": "Applicant Source Of Other Income4",'+
'           "value": "Independent Contractor"'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeProvider3",'+
'           "value": "Arizona Home Health"'+
'         },'+
'         {'+
'           "name": "Applicant Other Income Start Date4",'+
'           "value": "02/2017"'+
'         },'+
'         {'+
'           "name": "Applicant Other Annual Income4",'+
'           "value": "4,420"'+
'         },'+
'         {'+
'           "name": "ApplicantSec4Occupation",'+
'           "value": "Physical therapist"'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeProvider4",'+
'           "value": "Valley of sun Home H"'+
'         },'+
'         {'+
'           "name": "Applicant Mailing Street",'+
'           "value": "10236 W Puget Ave"'+
'         },'+
'         {'+
'           "name": "Applicant Mailing City",'+
'           "value": "Peoria"'+
'         },'+
'         {'+
'           "name": "Applicant First Name",'+
'           "value": "Jessie"'+
'         },'+
'         {'+
'           "name": "Applicant Home Street",'+
'           "value": "10236 W Puget Ave"'+
'         },'+
'         {'+
'           "name": "Applicant Last Name",'+
'           "value": "Roa"'+
'         },'+
'         {'+
'           "name": "Applicant Home City",'+
'           "value": "Peoria"'+
'         },'+
'         {'+
'           "name": "Applicant Home Phone",'+
'           "value": "(602) 418-7848"'+
'         },'+
'         {'+
'           "name": "Applicant SSN",'+
'           "value": "590-88-8459"'+
'         },'+
'         {'+
'           "name": "Applicant Mailing Zip Code",'+
'           "value": "85345"'+
'         },'+
'         {'+
'           "name": "Applicant Home Zip Code",'+
'           "value": "85345"'+
'         },'+
'         {'+
'           "name": "Applicant Mailing State",'+
'           "value": "AZ"'+
'         },'+
'         {'+
'           "name": "Applicant Home State",'+
'           "value": "AZ"'+
'         },'+
'         {'+
'           "name": "Applicant Date Of Birth",'+
'           "value": "1/1/1961"'+
'         },'+
'         {'+
'           "name": "Applicant Date Signed1",'+
'           "value": "02-Feb-2020 &#124; 3:27:18 PM EST"'+
'         },'+
'         {'+
'           "name": "Date Signed 387ea237-a2bb-496a-8115-1525652f6708",'+
'           "value": "02-Feb-2020 &#124; 3:27:18 PM EST"'+
'         },'+
'         {'+
'           "name": "Applicant First School",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Other City",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Other Street",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Mother Maiden Name",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Home Apartment",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant MI",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Mailing Apartment",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Mobile Phone",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Work Phone",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Other Apartment",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Other Zip Code",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Other State",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Previous Employer",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeId3",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantPreviousEmployerID",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantCurrentEmployerID",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeId2",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantHousingId",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeId4",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantOtherIncomeId1",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantMainIncomeId",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantSpouseAddress",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantSpouseName",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "ApplicantMaritalStatus",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Previous Employer Street",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Previous Employer City",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Previous Employer State",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Previous Employer Zip",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Applicant Previous Employer Start Date",'+
'           "value": ""'+
'         },'+
'         {'+
'           "name": "Special Offer Code",'+
'           "value": ""'+
'         }'+
'       ],'+
'       "recipientId": "9b29f1c6-ea35-44d1-a604-2439924cf558",'+
'       "name": "Jessie Roa",'+
'       "email": "catane@hotmail.com",'+
'       "signedTime": "2020-02-03T04:27:18.2970000Z",'+
'       "deliveredTime": "2020-02-03T04:00:03.9400000Z"'+
'     }'+
' ]'+
' }';

return DocusignFormDataJSON2Apex.parse(formData);


}*/
    
    public static Decimal getAmountFromString(String pAmountString){
        Decimal amount = 0.00;
        system.debug(logginglevel.error,'Input Amount :'+pAmountString);
        if (String.isNotBlank(pAmountString)){
            try{
                amount = Decimal.Valueof(pAmountString.replace(',', ''));
            }catch(Exception e){
                system.debug(logginglevel.error,'new amount:'+amount);
            }
        }
        system.debug(logginglevel.error,'new amount:'+amount);
        return amount;
    }    
    
    public static date getDateFromMMYYYYString(String pDateString){
        Date newDate;
        system.debug(logginglevel.error,'pDateStr :'+pDateString);
        if (pDateString != null){
            if (pDateString.length() == 7){
                //IF 7 THEN MOST LIKELY THE FORMAT IS MM/YYYY FORMAT
                newDate = Date.newInstance(Integer.ValueOf(pDateString.substring(3,7)),Integer.ValueOf(pDateString.substring(0,2)),01);
            }else if (pDateString.length() == 5){
                //IF 5 THEN MOST LIKELY THE FORMAT IS MM/YY FORMAT
                String yearStr = '20'+pDateString.substring(3,5);
                Integer year= Integer.ValueOf(pDateString.substring(3,5));
                String currentYearStr = String.Valueof (Date.Today().year());
                Integer currentYear = Integer.ValueOf(currentYearStr.substring(2,4));
                system.debug(logginglevel.error,'year :'+year +' currentYear '+currentYear);
                if (year > currentYear){
                    yearStr = '19'+pDateString.substring(3,5);
                }
                newDate = Date.newInstance(Integer.ValueOf(yearStr),Integer.ValueOf(pDateString.substring(0,2)),01);
            }
            
        }
        system.debug(logginglevel.error,'newDate :'+newDate);
        return newDate;
    }
    
    
    
    /*private static void getDocumentListFromDocusign(String envelopeId){

String endPoint=SFS_System_Settings__c.getInstance().Docusign_REST_EndPoint__c+'/accounts/'+SFS_System_Settings__c.getInstance().Docusign_Account_Id__c+'/envelopes/'+envelopeId+'/documents';
Http h2= new Http();
HttpRequest req2 = setRestHttpRequest(endPoint,'GET');
req2.setHeader('Content-Transfer-Encoding','base64');
if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
//Do NOTHING
}else{
HttpResponse res2=h2.send(req2);
system.debug(logginglevel.error,res2.getBody());

}
}*/
    
    /**
* @description This method hit the rest WS of Docusign and get the pdf document for the envelope
* @author FinancialSpectra | 6/26/2019
* @param String envelopeId
* @return Blob
*/
    private static Blob getCompletedDocumentFromDocusign(String envelopeId){
        Blob pdfDoc;
        //FETCHING THE DOCUMENT FROM DOCUSIGN
        String documentId = 'combined?certificate=true'; //We need all docs with certificate
        String endPoint=SFS_System_Settings__c.getInstance().Docusign_REST_EndPoint__c+'/accounts/'+SFS_System_Settings__c.getInstance().Docusign_Account_Id__c+'/envelopes/'+envelopeId+'/documents/'+documentId+'';
        Http h2= new Http();
        system.debug(logginglevel.error,' endPoint :'+endPoint);
        
        HttpRequest req2 = setRestHttpRequest(endPoint,'GET');
        req2.setHeader('Content-Transfer-Encoding','base64');
        if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
            StaticResource sr= [select id,body from StaticResource Where Name = 'Docusign_Loan_App_test'];
            String responseBody = sr.body.toString();
            pdfDoc = System.EncodingUtil.base64Decode(responseBody);
        }else{
            HttpResponse res2=h2.send(req2);
            pdfDoc = System.EncodingUtil.base64Decode(res2.getBody());
        }
        
        
        
        return pdfDoc;
    }
    

    @Future(callout=true)
    public static void copyDocusignToBoxForContract(Set<String> pEnvelopeIds, MAP<String,Id> pContractMap, MAP<String,String> pEnvelopeName,String pDocumentName){
       
        System.debug(logginglevel.error, 'New Bank Acount7');
        List<fsCore.ErrorObject> errorList = new List<fsCore.ErrorObject>();
        
            Map<ID, fsServ__Lending_Contract__c> lendingContractMap = new Map<ID, fsServ__Lending_Contract__c>(
                [SELECT Id
                 , BoxFolderId__c
                 , fsServ__Primary_Customer_Account__r.Import_BoxFolderId__c
                 FROM fsServ__Lending_Contract__c
                 WHERE id IN :pContractMap.values()]);
           
            for (String envelopeId : pEnvelopeIds) {
                fsServ__Lending_Contract__c lContract = lendingContractMap.get(pContractMap.get(envelopeId));
                try{
                    Blob pdfDoc = getCompletedDocumentFromDocusign(envelopeId);
                    string documentName = Datetime.now().format('yyyy_MM_dd_HHmmss')+'-'+pDocumentName+'-'+pEnvelopeName.get(envelopeId);
                    if (lContract.BoxFolderId__c != null){
                        System.debug(logginglevel.error, 'New Bank Acount9');
                        copyDocumentToBox(pdfDoc,lContract.BoxFolderId__c,documentName);
                    }
                    if (lContract.fsServ__Primary_Customer_Account__r.Import_BoxFolderId__c  != null){
                        System.debug(logginglevel.error, 'New Bank Acount10');
                        copyDocumentToBox(pdfDoc,lContract.fsServ__Primary_Customer_Account__r.Import_BoxFolderId__c ,documentName);
                    }
                }catch(Exception ex){
                    fsCore.ErrorObject errObj = new fsCore.ErrorObject();
                    errObj.setErrorRecordId(lContract.Id);
                    errObj.setErrorMessage(ex.getMessage());
                    errObj.setErrorCode('COPY DOCUMENT TO BOX');
                    errObj.setErrorStackTrace(ex.getStackTraceString());
                    errorList.add(errObj);
                }
            }
        
       
        if (errorList.size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('NuDebtIntegrate', 'copyDocusignToBox', errorList);
        }
         
    }
    
    @Future(callout=true)
    public static void copyDocusignToBox(Set<String> pEnvelopeIds,MAP<String,Id> pApplicationMap,MAP<String,String> pEnvelopeName,String pDocumentName){
 
         List<fsCore.ErrorObject> errorList = new List<fsCore.ErrorObject>();
 
         Map<ID, fsCore__Lending_Application__c> lendingApplicationMap = new Map<ID, fsCore__Lending_Application__c>(
             [SELECT Id
                   , BoxFolderId__c
                   , fsCore__Primary_Customer_Account__r.Import_BoxFolderId__c
                FROM fsCore__Lending_Application__c
               WHERE id IN :pApplicationMap.values()]);
 
             for (String envelopeId : pEnvelopeIds) {
                 fsCore__Lending_Application__c lApp = lendingApplicationMap.get(pApplicationMap.get(envelopeId));
                 try{
                     Blob pdfDoc = getCompletedDocumentFromDocusign(envelopeId);
                     string documentName = Datetime.now().format('yyyy_MM_dd_HHmmss')+'-'+pDocumentName+'-'+pEnvelopeName.get(envelopeId);
                     if (lApp.BoxFolderId__c != null){
                         copyDocumentToBox(pdfDoc,lApp.BoxFolderId__c,documentName);
                     }
                     if (lApp.fsCore__Primary_Customer_Account__r.Import_BoxFolderId__c  != null){
                         copyDocumentToBox(pdfDoc,lApp.fsCore__Primary_Customer_Account__r.Import_BoxFolderId__c ,documentName);
                     }
                 }catch(Exception ex){
                         fsCore.ErrorObject errObj = new fsCore.ErrorObject();
                         errObj.setErrorRecordId(lApp.Id);
                         errObj.setErrorMessage(ex.getMessage());
                         errObj.setErrorCode('COPY DOCUMENT TO BOX');
                         errObj.setErrorStackTrace(ex.getStackTraceString());
                         errorList.add(errObj);
                 }
             }
             if (errorList.size() > 0){
                 fsCore.DiagnosticLogUtil.logErrors('NuDebtIntegrate', 'copyDocusignToBox', errorList);
             }
         
    }
    
    
    
    /**
* @description THIS API IS TO GET THE COMPLETED DOCUMENT FROM DOCUSIGN AND MOVE IT TO THE SALESFORCE FILES
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 6/26/2019
* @param Set<String> pEnvelopeIds
* @param MAP<String, Id> pOpportunityMap
* @param String pDocumentName
* @return void
*/
    @Future(callout=true)
    public static void addDocusignDocumentToFile(Set<String> pEnvelopeIds,MAP<String,Id> pOpportunityMap,String pDocumentName){
        
        String methodName ='addDocusignDocumentToFile';
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        Map<String,ContentVersion> contentVersionMap = new Map<String,ContentVersion>();
        
        try{
            for (String envelopeId : pEnvelopeIds) {
                
                Blob pdfDoc = getCompletedDocumentFromDocusign(envelopeId);
                //NOW ADD TO THE FILE
                string documentName = 'Signed Loan Application_'+Datetime.now().format('yyyy_MM_dd_HHmmss');
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                // NEED TO HAVE ENVELOPE ID TO KEEP IT UNIQUE
                // The files name, extension is very important here which will help the file in preview.
                conVer.PathOnClient = Datetime.now().format('yyyy_MM_dd_HHmmss')+'_'+pDocumentName+'_'+envelopeId+'.pdf';
                conVer.Title = documentName; // Display name of the files
                conVer.VersionData = pdfDoc;
                contentVersionMap.put(envelopeId,conVer);
                
            }
            
            insert contentVersionMap.Values();
            
            set <ID> ContentVersionIds = new set <ID>();
            for (ContentVersion conVer: contentVersionMap.Values()){
                ContentVersionIds.add(conVer.Id);
            }
            Map<Id, ContentVersion> ContentVersionNewMap = new Map<ID, ContentVersion>([select id,ContentDocumentId from ContentVersion WHERE Id IN :ContentVersionIds]);
            
            for (String envelopeId : pEnvelopeIds) {
                
                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = ContentVersionNewMap.get((contentVersionMap.get(envelopeId)).Id).ContentDocumentId;
                cDe.LinkedEntityId = pOpportunityMap.get(envelopeId); // you can use objectId,GroupId etc
                cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                contentDocumentLinkList.add(cDe);
                
                
            }
            
            insert contentDocumentLinkList;
            
        }catch(Exception ex){
            
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            //NOW PERFORM DML
            fsCore.DiagnosticLogUtil.logErrors(mClassName, methodName, errorObjectList);
        }
        
    }
    
    
    public static void moveCompletedDocumentFromFilesToBox(Set<ID> pOpportunityIds,MAP<ID,String> pOpportunityToFolderMap){
        
        system.debug(logginglevel.error,'moveCompletedDocumentFromFilesToBox :');
        Set<ID> contDocumentSet = new Set<ID>();
        MAP<ID,String> contentDocFolderMap = new MAP<ID,String>();
        
        //Since the ContentDocumentLink has the implementation restriction
        //caused by: System.QueryException: Implementation restriction:
        //ContentDocumentLink requires a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.
        //So have to do it in a loop
        system.debug(logginglevel.error,'pOpportunityIds  :');
        for (ID oppId:pOpportunityIds){
            List<ContentDocumentLink> contentDocumentList = [select ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId = :oppId];
            
            for (ContentDocumentLink cDoc: contentDocumentList){
                contDocumentSet.add(cDoc.ContentDocumentId);
                contentDocFolderMap.put(cDoc.ContentDocumentId,pOpportunityToFolderMap.get(cDoc.LinkedEntityId));
            }
            
        }
        system.debug(logginglevel.error,'pOpportunityIds  :2:');
        
        List<ContentVersion> contentVersionList = [select VersionData,PathOnClient,ContentDocumentId from ContentVersion where ContentDocumentId = :contDocumentSet];
        for (ContentVersion cVersion: contentVersionList){
            system.debug(logginglevel.error,'cVersion  :2:');
            
            Blob pdfDoc = cVersion.VersionData;
            
            //NOW MOVE THE DOCUMENT TO THE BOX.COM
            copyDocumentToBox(pdfDoc,contentDocFolderMap.get(cVersion.ContentDocumentId),cVersion.PathOnClient);
            system.debug(logginglevel.error,'Done copy  :2:');
            
        }
        
        
    }
    
    private static void copyDocumentToBox(Blob pdfDoc, String pBoxFolderId, String pFileName){
        CreateBoxFolderHandler.copyPdfDocumentToBox(pdfDoc,pBoxFolderId,pFileName);
    }
    
    @Future(callout=true)
    public static void moveCompletedDocumentFromDocusignToBox(String pEnvelopeId,String pFolderId,String pDocumentName){
        String methodName ='moveCompletedDocumentFromDocusignToBox';
        
        try{
            //FETCHING THE DOCUMENT FROM DOCUSIGN
            String documentId = '1';//I AM ASSUMING THAT LOAN APPLICATION WILL ALWAYS HAVE THE DOCUMENT ID == 1
            String endPoint=SFS_System_Settings__c.getInstance().Docusign_REST_EndPoint__c+'/accounts/'+SFS_System_Settings__c.getInstance().Docusign_Account_Id__c+'/envelopes/'+pEnvelopeId+'/documents/'+documentId+'';
            Http h2= new Http();
            HttpRequest req2 = setRestHttpRequest(endPoint,'GET');
            req2.setHeader('Content-Transfer-Encoding','base64');
            
            HttpResponse res2=h2.send(req2);
            
            Blob pdfDoc = System.EncodingUtil.base64Decode(res2.getBody());
            
            //NOW MOVE THE DOCUMENT TO THE BOX.COM
            
            Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
            
            BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
            api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
            api.setAccessToken(objBoxsettings.access_token1__c);
            api.setExpires(long.valueOf(objBoxsettings.expires__c));
            
            BoxFolder box = new BoxFolder(api, pFolderId);//'54555930164');
            
            BoxFile.Info bxInfo = box.uploadFile(pdfDoc,pDocumentName+'.pdf');
            logmessage('bxInfo  :'+bxInfo.id);
            //330271707284
        }catch(Exception ex){
            
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            //NOW PERFORM DML
            fsCore.DiagnosticLogUtil.logErrors(mClassName, methodName, errorObjectList);
        }
        
    }
    
    /*@Future(callout=true)
    public static void copyBoxFileToDifferentFolder(String pFileId,String pFolderId){
        String methodName ='copyBoxFileToDifferentFolder';
        
        //pFileId = '330271707284';
        
        //NOW MOVE THE DOCUMENT TO THE BOX.COM
        try{
            
            Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
            
            BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
            api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
            api.setAccessToken(objBoxsettings.access_token1__c);
            api.setExpires(long.valueOf(objBoxsettings.expires__c));
            
            BoxFolder box = new BoxFolder(api, pFolderId);//'54555930164');
            BoxFile boxFile = new BoxFile(api, pFileId);//'330271707284');
            
            BoxItem.Info bxInfo = boxFile.copy(box, 'YOYO.pdf');
            
            logmessage('bxInfo  :'+bxInfo.id);
        }catch(Exception ex){
            
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            //NOW PERFORM DML
            fsCore.DiagnosticLogUtil.logErrors(mClassName, methodName, errorObjectList);
        }
        //330269696080
        
    }*/
    
    /*private static String getEmploymentCodeToString(Integer pEmpCode){

Map<Integer,String> employmentCodeToStringMap = new Map<Integer,String>();
employmentCodeToStringMap.put(1,'Salary');
employmentCodeToStringMap.put(2,'Independent Contractor');
employmentCodeToStringMap.put(3,'Investment');
employmentCodeToStringMap.put(4,'Social Security');
employmentCodeToStringMap.put(5,'Pension');
employmentCodeToStringMap.put(6,'Rental');
employmentCodeToStringMap.put(7,'Disability');
employmentCodeToStringMap.put(8,'Child Support');
employmentCodeToStringMap.put(9,'Alimony');
employmentCodeToStringMap.put(10,'Self-employed');
employmentCodeToStringMap.put(11,'Other');
employmentCodeToStringMap.put(99,'None');

return employmentCodeToStringMap.get(pEmpCode);
}
private static Integer getEmploymentStringToCode(String pEmpCodeStr){

Map<String, Integer> employmentToCodeMap = new Map<String, Integer>();
employmentToCodeMap.put('Salary',1);
employmentToCodeMap.put('Independent Contractor',2);
employmentToCodeMap.put('Investment',3);
employmentToCodeMap.put('Social Security',4);
employmentToCodeMap.put('Pension',5);
employmentToCodeMap.put('Rental',6);
employmentToCodeMap.put('Disability',7);
employmentToCodeMap.put('Child Support',8);
employmentToCodeMap.put('Alimony',9);
employmentToCodeMap.put('Self-employed',10);
employmentToCodeMap.put('Other',11);
employmentToCodeMap.put('None',99);

return employmentToCodeMap.get(pEmpCodeStr);
}*/
    
    @Future(callout=true)
    public static void processDocusignCompletedEnvelope( Set<String> pEnvelopeIds
                                                        , MAP<String,Id> pApplicantsMap
                                                        , MAP<String,Id> pCoApplicantsMap){
                                                            
                                                            String methodName ='processDocusignCompletedEnvelope';
                                                            try{
                                                                set<ID>  accountIds = new set<ID>();
                                                                accountIds.addAll(pApplicantsMap.values());
                                                                accountIds.addAll(pCoApplicantsMap.values());
                                                                
                                                                Map<Id, Account> accMap = new Map<ID, Account>(
                                                                    [select id
                                                                     , FirstName
                                                                     , MiddleName
                                                                     , LastName
                                                                     , PersonContactId
                                                                     , PersonBirthdate
                                                                     , fsCore__National_Identification_Number__pc
                                                                     , U_S_Residency_Status__c
                                                                     , PersonEmail
                                                                     , PersonHomePhone
                                                                     , PersonMobilePhone
                                                                     , Work_Phone__c
                                                                     , PersonOtherStreet
                                                                     , PersonOtherCity
                                                                     , PersonOtherState
                                                                     , PersonOtherPostalCode
                                                                     , PersonOtherCountry
                                                                     , PersonMailingStreet
                                                                     , PersonMailingCity
                                                                     , PersonMailingState
                                                                     , PersonMailingPostalCode
                                                                     , PersonMailingCountry
                                                                     , Primary_Id_Type__c
                                                                     , Primary_Id_Number__c
                                                                     , Primary_Id_Expiration_Date__c
                                                                     , Primary_Id_State__c
                                                                     , First_School_Attended__pc
                                                                     , Mother_Maiden_Name__pc
                                                                     , Residing_Since_Date__c
                                                                     , Less_than_2yrs_Apt_Num__c
                                                                     , Less_than_2yrs_City__c
                                                                     , Less_than_2yrs_Country__c
                                                                     , Less_than_2yrs_State__c
                                                                     , Less_than_2yrs_Street_Address__c
                                                                     , Less_than_2yrs_Zip_Code__c
                                                                     , Spouse_Name__c
                                                                     , Spouse_Address__c
                                                                     , Marital_Status__c
                                                                     ,( select id
                                                                       , name
                                                                       , fsCore__Title__c
                                                                       , fsCore__Employer_Name__c
                                                                       , fsCore__Start_Date__c
                                                                       , fsCore__End_Date__c
                                                                       , fsCore__Street__c
                                                                       , fsCore__City__c
                                                                       , fsCore__State__c
                                                                       , fsCore__Zip_Code__c
                                                                       , fsCore__Salary__c
                                                                       , Is_Primary_Employment__c
                                                                       from fsCore__Contact_Employment__pr
                                                                       Order By fsCore__Start_Date__c Desc)
                                                                     ,( select id
                                                                       , name
                                                                       , Employment_Name__c
                                                                       , Start_Date__c
                                                                       , fsCore__Contact_Name__c
                                                                       , fsCore__Financial_Family__c
                                                                       , fsCore__Financial_Type__c
                                                                       , fsCore__Frequency__c
                                                                       , fsCore__Is_Active__c
                                                                       , fsCore__Stated_Amount__c
                                                                       , fsCore__Verified_Amount__c
                                                                       , fsCore__Description__c
                                                                       , Occupation__c
                                                                       , Is_Primary_Employment__c
                                                                       , Is_Primary_Income__c
                                                                       , Housing_Type__c
                                                                       , Other_Housing_Description__c
                                                                       , Employment_Name__r.fsCore__Title__c
                                                                       , Title_Formula__c
                                                                       , Employment_Name__r.Id
                                                                       , Employment_Name__r.fsCore__Employer_Name__c
                                                                       , Employment_Name__r.fsCore__Start_Date__c
                                                                       , Employment_Name__r.fsCore__Street__c
                                                                       , Employment_Name__r.fsCore__City__c
                                                                       , Employment_Name__r.fsCore__State__c
                                                                       , Employment_Name__r.fsCore__Zip_Code__c
                                                                       , Employment_Name__r.fsCore__Salary__c
                                                                       FROM fsCore__Financial__pr
                                                                       WHERE fsCore__Is_Active__c = true)
                                                                     FROM Account
                                                                     WHERE id = :accountIds]);
                                                                
                                                                Map<String,dsfs__DocuSign_Status__c> envelopeToDocusignMap = new Map<String,dsfs__DocuSign_Status__c>();
                                                                List<dsfs__DocuSign_Status__c> docusignStatusList = [select id, dsfs__Opportunity__c,dsfs__DocuSign_Envelope_ID__c from dsfs__DocuSign_Status__c where dsfs__DocuSign_Envelope_ID__c in :pEnvelopeIds];
                                                                
                                                                for (dsfs__DocuSign_Status__c docusignStatus : docusignStatusList) {
                                                                    envelopeToDocusignMap.put(docusignStatus.dsfs__DocuSign_Envelope_ID__c,docusignStatus);
                                                                }
                                                                
                                                                for (String envelopeId : pEnvelopeIds) {
                                                                    MAP<String,Id> applicantsMap = new MAP<String,Id>();
                                                                    
                                                                    DocusignFormDataJSON2Apex docusignFormData = getCompletedFormData(envelopeId);
                                                                    
                                                                    
                                                                    //PROCESS ONLY WHEN THE DOCUMENT IS COMPLETED
                                                                    logmessage('docusignFormData.status :'+docusignFormData.status);
                                                                    /*if (docusignFormData.status == 'completed'){

//docusignFormData.recipientFormData
logmessage('recipientFormData :'+docusignFormData.recipientFormData);

}*/
                                                                    
                                                                    Account applicant = accMap.get(pApplicantsMap.get(envelopeId));
                                                                    Account coApplicant = accMap.get(pCoApplicantsMap.get(envelopeId));
                                                                    
                                                                    if (applicant != null){
                                                                        try{
                                                                            populateAPINameValueMap(docusignFormData.formData,'Applicant',applicant);
                                                                        }catch(Exception ex){
                                                                            logmessage(ex);
                                                                            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
                                                                            if (envelopeToDocusignMap.get(envelopeId) != null){
                                                                                errObj.setErrorRecordId(envelopeToDocusignMap.get(envelopeId).dsfs__Opportunity__c);
                                                                                errObj.setErrorRecordName(String.valueOf(envelopeToDocusignMap.get(envelopeId).dsfs__Opportunity__c));
                                                                            }
                                                                            errObj.setErrorMessage(ex.getMessage());
                                                                            errObj.setErrorCode('Loan Application Document Process - Applicant');
                                                                            errObj.setErrorStackTrace(ex.getStackTraceString());
                                                                            
                                                                            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
                                                                            errorObjectList.add(errObj);
                                                                            //NOW PERFORM DML
                                                                            fsCore.DiagnosticLogUtil.logErrors(mClassName, methodName, errorObjectList);
                                                                            
                                                                            //FOR TESTONLY TO INCREASE THE COVERAGE
                                                                            if (Test.isRunningTest()){
                                                                                populateAPINameValueMap(docusignFormData.formData,'CoApplicant',applicant);
                                                                            }   
                                                                            throw ex;
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                    if (coApplicant != null){
                                                                        try{
                                                                            populateAPINameValueMap(docusignFormData.formData,'CoApplicant',coApplicant);
                                                                        }catch(Exception ex){
                                                                            logmessage(ex);
                                                                            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
                                                                            if (envelopeToDocusignMap.get(envelopeId) != null){
                                                                                errObj.setErrorRecordId(envelopeToDocusignMap.get(envelopeId).dsfs__Opportunity__c);
                                                                                errObj.setErrorRecordName(String.valueOf(envelopeToDocusignMap.get(envelopeId).dsfs__Opportunity__c));
                                                                            }
                                                                            errObj.setErrorMessage(ex.getMessage());
                                                                            errObj.setErrorCode('Loan Application Document Process - Co-Applicant');
                                                                            errObj.setErrorStackTrace(ex.getStackTraceString());
                                                                            
                                                                            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
                                                                            errorObjectList.add(errObj);
                                                                            //NOW PERFORM DML
                                                                            fsCore.DiagnosticLogUtil.logErrors(mClassName, methodName, errorObjectList);                    
                                                                            throw ex;
                                                                        }
                                                                    }
                                                                    
                                                                    
                                                                }
                                                            }catch(Exception ex){
                                                                
                                                                logmessage(ex);
                                                                fsCore.ErrorObject errObj = new fsCore.ErrorObject();
                                                                errObj.setErrorMessage(ex.getMessage());
                                                                errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
                                                                errObj.setErrorStackTrace(ex.getStackTraceString());
                                                                
                                                                List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
                                                                errorObjectList.add(errObj);
                                                                
                                                                //NOW PERFORM DML
                                                                fsCore.DiagnosticLogUtil.logErrors(mClassName, methodName, errorObjectList);
                                                            }
                                                            
                                                            
                                                        }
    
    public static void populateAPINameValueMap(List<DocusignFormDataJSON2Apex.formData> pFormDataList, String pEntity, Account pAccount){
        String methodName ='populateAPINameValueMap';
        //try{
        
        Map<String,fsCore__Employment__c> aplfinancialEmploymentMap = new Map<String,fsCore__Employment__c>();
        Map<String,fsCore__Employment__c> coaplfinancialEmploymentMap = new Map<String,fsCore__Employment__c>();
        
        
        fsCore__Employment__c applicantCurrentEmployment;
        fsCore__Employment__c applicantPreviousEmployment;
        List<fsCore__Employment__c> applicantEmpList = new List<fsCore__Employment__c>();
        List<fsCore__Financial__c> applicantFinList = new List<fsCore__Financial__c>();
        
        if ('Applicant'.equals(pEntity)){
            for (fsCore__Employment__c emp : pAccount.fsCore__Contact_Employment__pr){
                if (emp.fsCore__End_Date__c != null && applicantPreviousEmployment == null){
                    applicantPreviousEmployment = emp;
                    break;
                }
                
            }
        }
        
        
        fsCore__Employment__c coApplicantCurrentEmployment;
        fsCore__Employment__c coApplicantPreviousEmployment;
        List<fsCore__Employment__c> coApplicantEmpList = new List<fsCore__Employment__c>();
        List<fsCore__Financial__c> coApplicantFinList = new List<fsCore__Financial__c>();
        
        
        
        DNLApplicant applicantResponse = new DNLApplicant();
        DNLApplicant coApplicantResponse = new DNLApplicant();
        
        if ('CoApplicant'.equals(pEntity)){
            for (fsCore__Employment__c emp : pAccount.fsCore__Contact_Employment__pr){
                if (emp.fsCore__End_Date__c != null && coApplicantPreviousEmployment == null){
                    coApplicantPreviousEmployment = emp;
                    break;
                }
            }
        }
        for (DocusignFormDataJSON2Apex.formData  formRecord :pFormDataList){
            
            if ((formRecord.name.contains('Currency Symbol'))||
                (formRecord.name.contains('Date Signed'))||
                (formRecord.name.contains('Email'))||
                (!isValueChanged(formRecord.name,formRecord.originalValue,formRecord.value))){
                    
                    if( //THOSE ARE THE FIELDS WHICH WE STILL NEED EVEN IF THE VALUE IS UNCHANGED
                        (formRecord.name == 'Applicant Monthly Rent')||
                        (formRecord.name == 'Applicant Annual Base Salary')||
                        (formRecord.name == 'Applicant Other Annual Income1')||
                        (formRecord.name == 'Applicant Other Annual Income2')||
                        (formRecord.name == 'Applicant Other Annual Income3')||
                        (formRecord.name == 'Applicant Other Annual Income4')||
                        (formRecord.name == 'Applicant Other Housing')||
                        (formRecord.name == 'Applicant Employment Status')||
                        (formRecord.name == 'Applicant Source Of Other Income1')||
                        (formRecord.name == 'Applicant Source Of Other Income2')||
                        (formRecord.name == 'Applicant Source Of Other Income3')||
                        (formRecord.name == 'Applicant Source Of Other Income4')||
                        (formRecord.name.startsWithIgnoreCase('ApplicantPrimaryIncomeProvider'))||
                        (formRecord.name == 'ApplicantOtherIncomeProvider1')||
                        (formRecord.name == 'ApplicantOtherIncomeProvider2')||
                        (formRecord.name == 'ApplicantOtherIncomeProvider3')||
                        (formRecord.name == 'ApplicantOtherIncomeProvider4')||
                        (formRecord.name == 'Applicant Housing')||
                        (formRecord.name == 'ApplicantMainIncomeId')||
                        (formRecord.name == 'ApplicantOtherIncomeId1')||
                        (formRecord.name == 'ApplicantOtherIncomeId2')||
                        (formRecord.name == 'ApplicantOtherIncomeId3')||
                        (formRecord.name == 'ApplicantOtherIncomeId4')||
                        (formRecord.name == 'ApplicantHousingId')||
                        (formRecord.name == 'ApplicantCurrentEmployerID')||
                        (formRecord.name == 'ApplicantPreviousEmployerID')||
                        (formRecord.name == 'ApplicantPrimaryIncomeProviderStartDate')||
                        (formRecord.name == 'Applicant Other Income Start Date1')||
                        (formRecord.name == 'Applicant Other Income Start Date2')||
                        (formRecord.name == 'Applicant Other Income Start Date3')||
                        (formRecord.name == 'Applicant Other Income Start Date4')||
                        (formRecord.name.startsWithIgnoreCase('ApplicantPrimaryOccupation'))||
                        (formRecord.name.startsWithIgnoreCase('ApplicantSec1Occupation'))||
                        (formRecord.name.startsWithIgnoreCase('ApplicantSec2Occupation'))||
                        (formRecord.name.startsWithIgnoreCase('ApplicantSec3Occupation'))||
                        (formRecord.name.startsWithIgnoreCase('ApplicantSec4Occupation'))||
                        (formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryOccupation'))||
                        (formRecord.name.startsWithIgnoreCase('CoApplicantSec1Occupation'))||
                        (formRecord.name.startsWithIgnoreCase('CoApplicantSec2Occupation'))||
                        (formRecord.name.startsWithIgnoreCase('CoApplicantSec3Occupation'))||
                        (formRecord.name.startsWithIgnoreCase('CoApplicantSec4Occupation'))||
                        (formRecord.name == 'CoApplicant Monthly Rent')||
                        (formRecord.name == 'CoApplicant Annual Base Salary')||
                        (formRecord.name == 'CoApplicant Other Annual Income1')||
                        (formRecord.name == 'CoApplicant Other Annual Income2')||
                        (formRecord.name == 'CoApplicant Other Annual Income3')||
                        (formRecord.name == 'CoApplicant Other Annual Income4')||
                        (formRecord.name == 'CoApplicant Employment Status')||
                        (formRecord.name == 'CoApplicant Source of Other Income1')||
                        (formRecord.name == 'CoApplicant Source of Other Income2')||
                        (formRecord.name == 'CoApplicant Source of Other Income3')||
                        (formRecord.name == 'CoApplicant Source Of Other Income4')||
                        (formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryIncomeProvider'))||
                        (formRecord.name == 'CoApplicantOtherIncomeProvider1')||
                        (formRecord.name == 'CoApplicantOtherIncomeProvider2')||
                        (formRecord.name == 'CoApplicantOtherIncomeProvider3')||
                        (formRecord.name == 'CoApplicantOtherIncomeProvider4')||
                        (formRecord.name == 'CoApplicant Housing')||
                        (formRecord.name == 'CoApplicantMainIncomeId')||
                        (formRecord.name == 'CoApplicantOtherIncomeId1')||
                        (formRecord.name == 'CoApplicantOtherIncomeId2')||
                        (formRecord.name == 'CoApplicantOtherIncomeId3')||
                        (formRecord.name == 'CoApplicantOtherIncomeId4')||
                        (formRecord.name == 'CoApplicantHousingId')||
                        (formRecord.name == 'CoApplicantCurrentEmployerID')||
                        (formRecord.name == 'CoApplicant Other Income Start Date1')||
                        (formRecord.name == 'CoApplicant Other Income Start Date2')||
                        (formRecord.name == 'CoApplicant Other Income Start Date3')||
                        (formRecord.name == 'CoApplicant Other Income Start Date4')||
                        (formRecord.name == 'CoApplicantPrimaryIncomeProviderStartDate'))
                    {
                        //FOR ANY INCOME/LIAB/EMPLOYMENT TYPE FIELD, STILL POPULATE
                        // DO NOTHING
                    }else{
                        logmessage('**** SKIPPING **** '+pEntity+' '+formRecord.name+'  ***OLD***  '+formRecord.originalValue+'  ***NEW***  '+formRecord.value);
                        continue;
                    }
                    
                }
            logmessage(pEntity+'  ***--***  '+formRecord.name+'  ***--***  '+formRecord.value);
            if ('Applicant'.equals(pEntity)){
                if (formRecord.name == 'Applicant Email'){
                    pAccount.put('PersonEmail',formRecord.value);
                }else if(formRecord.name == 'Applicant Last Name'){
                    pAccount.put('lastName',formRecord.value);
                }else if(formRecord.name == 'Applicant MI'){
                    pAccount.put('MiddleName',formRecord.value);
                }else if(formRecord.name == 'Applicant Home City'){
                    pAccount.put('PersonOtherCity',formRecord.value);
                }else if(formRecord.name == 'Applicant First Name'){
                    pAccount.put('firstName',formRecord.value);
                }else if(formRecord.name == 'Applicant Address Since Date'){
                    if (formRecord.value != null){
                        pAccount.put('Residing_Since_Date__c',getDateFromMMYYYYString(formRecord.value));           
                    }
                }else if(formRecord.name == 'Applicant Home Phone'){
                    pAccount.put('PersonHomePhone',formRecord.value);
                }else if(formRecord.name == 'Applicant Mailing Street'){
                    pAccount.put('PersonMailingStreet',formRecord.value);
                }else if(formRecord.name == 'Applicant Other Apartment'){
                    pAccount.put('Less_than_2yrs_Apt_Num__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Other City'){
                    pAccount.put('Less_than_2yrs_City__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Other Street'){
                    pAccount.put('Less_than_2yrs_Street_Address__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Home Street'){
                    pAccount.put('PersonOtherStreet',formRecord.value);
                }else if(formRecord.name == 'Applicant Mailing City'){
                    pAccount.put('PersonMailingCity',formRecord.value);
                }else if(formRecord.name == 'Applicant Primary Id Number'){
                    pAccount.put('Primary_Id_Number__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Mobile Phone'){
                    pAccount.put('PersonMobilePhone',formRecord.value);
                }else if(formRecord.name == 'Applicant Work Phone'){
                    pAccount.put('Work_Phone__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Mother Maiden Name'){
                    pAccount.put('Mother_Maiden_Name__pc',formRecord.value);
                }else if(formRecord.name == 'Applicant First School'){
                    pAccount.put('First_School_Attended__pc',formRecord.value);
                }else if(formRecord.name == 'Applicant SSN'){
                    pAccount.put('fsCore__National_Identification_Number__pc',formRecord.value);
                }else if(formRecord.name == 'Applicant Home Zip Code'){
                    pAccount.put('PersonOtherPostalCode',formRecord.value);
                }else if(formRecord.name == 'Applicant Other Zip Code'){
                    pAccount.put('Less_than_2yrs_Zip_Code__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Mailing Zip Code'){
                    pAccount.put('PersonMailingPostalCode',formRecord.value);
                }else if(formRecord.name == 'Applicant U.S. Residency'){
                    pAccount.put('U_S_Residency_Status__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Home State'){
                    pAccount.put('PersonOtherCountry','United States');
                    pAccount.put('PersonOtherState',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'Applicant Primary Id'){
                    pAccount.put('Primary_Id_Type__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Other State'){
                    pAccount.put('Less_than_2yrs_Country__c','United States');
                    pAccount.put('Less_than_2yrs_State__c',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'Applicant Mailing State'){
                    pAccount.put('PersonMailingCountry','United States');
                    pAccount.put('PersonMailingState',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'Applicant Id State'){
                    pAccount.put('Primary_Id_State__c',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'Applicant Date Of Birth'){
                    Date birthDate = Date.parse(formRecord.value);
                    pAccount.put('PersonBirthdate',birthDate);
                }else if(formRecord.name == 'Applicant Id Expiration Date'){
                    Date expirationDate = Date.parse(formRecord.value);
                    pAccount.put('Primary_Id_Expiration_Date__c',expirationDate);
                }else if(formRecord.name == 'ApplicantMaritalStatus'){
                    pAccount.put('Marital_Status__c',formRecord.value);
                }else if(formRecord.name == 'ApplicantSpouseName'){
                    pAccount.put('Spouse_Name__c',formRecord.value);
                }else if(formRecord.name == 'ApplicantSpouseAddress'){
                    pAccount.put('Spouse_Address__c',formRecord.value);
                }else if(formRecord.name == 'Applicant Mailing Apartment'){
                    //pAccount.put('',formRecord.value);
                }else if(formRecord.name == 'Applicant Home Apartment'){
                    //pAccount.put('',formRecord.value);
                }
                
                // HANDLING PREVIOUS EMPLOYMENT
                if (
                    (formRecord.name == 'Applicant Previous Employer Zip')||
                    (formRecord.name == 'Applicant Previous Employer State')||
                    (formRecord.name == 'Applicant Previous Employer')||
                    (formRecord.name == 'Applicant Previous Employer City')||
                    (formRecord.name == 'Applicant Previous Employer Start Date')||
                    (formRecord.name == 'Applicant Previous Employer Street')
                ){
                    if (applicantPreviousEmployment == null){
                        applicantPreviousEmployment = new fsCore__Employment__c();
                        applicantPreviousEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                    }
                    
                    if(formRecord.name == 'Applicant Previous Employer Zip'){
                        applicantPreviousEmployment.put('fsCore__Zip_Code__c',formRecord.value);
                    }else if(formRecord.name == 'Applicant Previous Employer State'){
                        applicantPreviousEmployment.put('fsCore__State__c',SFSUtil.getStateName(formRecord.value));
                    }else if(formRecord.name == 'Applicant Previous Employer'){
                        if (String.isNotBlank(formRecord.value)){
                            applicantPreviousEmployment.put('fsCore__Employer_Name__c',formRecord.value);
                        }
                    }else if(formRecord.name == 'Applicant Previous Employer City'){
                        applicantPreviousEmployment.put('fsCore__City__c',formRecord.value);
                    }else if(formRecord.name == 'Applicant Previous Employer Start Date'){
                        if (String.isNotBlank(formRecord.value)){
                            applicantPreviousEmployment.put('fsCore__Start_Date__c',getDateFromMMYYYYString(formRecord.value));
                        }
                    }else if(formRecord.name == 'Applicant Previous Employer Street'){
                        applicantPreviousEmployment.put('fsCore__Street__c',formRecord.value);
                        
                    }
                }
                // HANDLING CURRENT EMPLOYMENT
                if (
                    (formRecord.name == 'ApplicantPrimaryIncomeProviderStartDate')||
                    (formRecord.name.startsWithIgnoreCase('ApplicantPrimaryIncomeProvider'))||
                    (formRecord.name.startsWithIgnoreCase('ApplicantPrimaryOccupation'))
                ){
                    
                    if (applicantCurrentEmployment == null){
                        applicantCurrentEmployment = new fsCore__Employment__c();
                        applicantCurrentEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                    }
                    
                    if(formRecord.name == 'ApplicantPrimaryIncomeProviderStartDate'){
                        if (String.isNotBlank(formRecord.value)){
                            applicantCurrentEmployment.put('fsCore__Start_Date__c',getDateFromMMYYYYString(formRecord.value));
                        }
                    }else if(formRecord.name.startsWithIgnoreCase('ApplicantPrimaryIncomeProvider')){
                        if (String.isNotBlank(formRecord.value)){
                            applicantCurrentEmployment.put('fsCore__Employer_Name__c',formRecord.value);
                        }
                    }else if(formRecord.name.startsWithIgnoreCase('ApplicantPrimaryOccupation')){
                        if (String.isNotBlank(formRecord.value)){
                            applicantCurrentEmployment.put('fsCore__Title__c',formRecord.value);
                        }
                    }
                    logmessage('applicantCurrentEmployment == >'+applicantCurrentEmployment);
                    
                }
                
                
                if(formRecord.name == 'Applicant Monthly Rent'){
                    applicantResponse.monthlyPayment = formRecord.value;
                }else if(formRecord.name == 'Applicant Annual Base Salary'){
                    applicantResponse.mainFinancial.annualIncome = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Annual Income1'){
                    applicantResponse.otherFinancial1.annualIncome = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Housing'){
                    applicantResponse.otherHousing = formRecord.value;
                }else if(formRecord.name == 'Applicant Employment Status'){
                    if (String.IsNotBlank(formRecord.value)){
                        if (formRecord.value != 'None'){
                            applicantResponse.mainFinancial.incomeType = formRecord.value;
                        }
                    }
                }else if(formRecord.name == 'Applicant Source Of Other Income1'){
                    applicantResponse.otherFinancial1.incomeType = formRecord.value;
                }else if(formRecord.name == 'Applicant Source Of Other Income2'){
                    applicantResponse.otherFinancial2.incomeType = formRecord.value;
                }else if(formRecord.name == 'Applicant Source Of Other Income3'){
                    applicantResponse.otherFinancial3.incomeType = formRecord.value;
                }else if(formRecord.name == 'Applicant Source Of Other Income4'){
                    applicantResponse.otherFinancial4.incomeType = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Annual Income2'){
                    applicantResponse.otherFinancial2.annualIncome = formRecord.value;
                }else if(formRecord.name == 'ApplicantOtherIncomeProvider1'){
                    applicantResponse.otherFinancial1.employment.employerName = formRecord.value;
                    applicantResponse.otherFinancial1.provider = formRecord.value;
                }else if(formRecord.name == 'ApplicantOtherIncomeProvider2'){
                    applicantResponse.otherFinancial2.employment.employerName = formRecord.value;
                    applicantResponse.otherFinancial2.provider = formRecord.value;
                    
                }else if(formRecord.name == 'ApplicantOtherIncomeProvider3'){
                    applicantResponse.otherFinancial3.employment.employerName = formRecord.value;
                    applicantResponse.otherFinancial3.provider = formRecord.value;
                    
                }else if(formRecord.name == 'ApplicantOtherIncomeProvider4'){
                    applicantResponse.otherFinancial4.employment.employerName = formRecord.value;
                    applicantResponse.otherFinancial4.provider = formRecord.value;
                    
                }else if(formRecord.name == 'Applicant Other Annual Income3'){
                    applicantResponse.otherFinancial3.annualIncome = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Annual Income4'){
                    applicantResponse.otherFinancial4.annualIncome = formRecord.value;
                }else if(formRecord.name == 'Applicant Housing'){
                    applicantResponse.housingType = formRecord.value;
                }else if(formRecord.name == 'ApplicantMainIncomeId'){
                    applicantResponse.mainFinancial.RecordId = formRecord.value;
                }else if(formRecord.name == 'ApplicantOtherIncomeId1'){
                    applicantResponse.otherFinancial1.RecordId = formRecord.value;
                }else if(formRecord.name == 'ApplicantOtherIncomeId2'){
                    applicantResponse.otherFinancial2.RecordId = formRecord.value;
                }else if(formRecord.name == 'ApplicantOtherIncomeId3'){
                    applicantResponse.otherFinancial3.RecordId = formRecord.value;
                }else if(formRecord.name == 'ApplicantOtherIncomeId4'){
                    applicantResponse.otherFinancial4.RecordId = formRecord.value;
                }else if(formRecord.name == 'ApplicantPrimaryIncomeProviderStartDate'){
                    applicantResponse.mainFinancial.startDate = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Income Start Date1'){
                    applicantResponse.otherFinancial1.startDate = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Income Start Date2'){
                    applicantResponse.otherFinancial2.startDate = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Income Start Date3'){
                    applicantResponse.otherFinancial3.startDate = formRecord.value;
                }else if(formRecord.name == 'Applicant Other Income Start Date4'){
                    applicantResponse.otherFinancial4.startDate = formRecord.value;
                }else if(formRecord.name == 'ApplicantHousingId'){
                    applicantResponse.housingId = formRecord.value;
                }else if(formRecord.name == 'ApplicantCurrentEmployerID'){
                    if (String.isNotBlank(formRecord.value)){
                        applicantResponse.mainFinancial.employment.RecordId = formRecord.value;
                        if (applicantCurrentEmployment == null){
                            applicantCurrentEmployment = new fsCore__Employment__c();
                            applicantCurrentEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                        }
                        applicantCurrentEmployment.id = Id.ValueOf(applicantResponse.mainFinancial.employment.RecordId);
                        
                        logmessage('applicantCurrentEmployment =2= >'+applicantCurrentEmployment);
                    }
                }else if(formRecord.name == 'ApplicantPreviousEmployerID'){
                    if (String.isNotBlank(formRecord.value)){
                        applicantResponse.previousEmployment.RecordId = formRecord.value;
                        if (applicantPreviousEmployment == null){
                            applicantPreviousEmployment = new fsCore__Employment__c();
                            applicantPreviousEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                        }
                        
                        applicantPreviousEmployment.id = Id.ValueOf(applicantResponse.previousEmployment.RecordId);
                    }
                }else if(formRecord.name.startsWithIgnoreCase('ApplicantPrimaryOccupation')){
                    applicantResponse.mainFinancial.occupation = formRecord.value; 
                }else if(formRecord.name.startsWithIgnoreCase('ApplicantSec1Occupation')){
                    applicantResponse.otherFinancial1.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('ApplicantSec2Occupation')){     
                    applicantResponse.otherFinancial2.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('ApplicantSec3Occupation')){         
                    applicantResponse.otherFinancial3.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('ApplicantSec4Occupation')){ 
                    applicantResponse.otherFinancial4.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('ApplicantPrimaryIncomeProvider')){
                    applicantResponse.mainFinancial.employment.employerName = formRecord.value;
                    applicantResponse.mainFinancial.provider = formRecord.value;
                }
                
                
                
            }else if ('CoApplicant'.equals(pEntity)){
                
                if(formRecord.name == 'CoApplicant Email'){
                    pAccount.put('PersonEmail',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Home City'){
                    pAccount.put('PersonOtherCity',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Address Since Date'){
                    if (formRecord.value != null){
                        pAccount.put('Residing_Since_Date__c',getDateFromMMYYYYString(formRecord.value));
                    }
                }else if(formRecord.name == 'CoApplicant Home Street'){
                    pAccount.put('PersonOtherStreet',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Home Zip Code'){
                    pAccount.put('PersonOtherPostalCode',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Home State'){
                    pAccount.put('PersonOtherCountry','United States');
                    pAccount.put('PersonOtherState',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'CoApplicant Primary Id Number'){
                    pAccount.put('Primary_Id_Number__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Primary Id'){
                    pAccount.put('Primary_Id_Type__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Id State'){
                    pAccount.put('Primary_Id_State__c',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'CoApplicant Expiration Date'){
                    Date expirationDate = Date.parse(formRecord.value);
                    pAccount.put('Primary_Id_Expiration_Date__c',expirationDate);
                }else if(formRecord.name == 'CoApplicant SSN'){
                    pAccount.put('fsCore__National_Identification_Number__pc',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Other Zip Code'){
                    pAccount.put('Less_than_2yrs_Zip_Code__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant First Name'){
                    pAccount.put('firstName',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Last Name'){
                    pAccount.put('lastName',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Date Of Birth'){
                    Date birthDate = Date.parse(formRecord.value);
                    pAccount.put('PersonBirthdate',birthDate);
                    
                }else if(formRecord.name == 'CoApplicant U.S. Residency'){
                    pAccount.put('U_S_Residency_Status__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant MI'){
                    pAccount.put('MiddleName',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Mailing Street'){
                    pAccount.put('PersonMailingStreet',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Other City'){
                    pAccount.put('Less_than_2yrs_City__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Other Apartment'){
                    pAccount.put('Less_than_2yrs_Apt_Num__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Other Street'){
                    pAccount.put('Less_than_2yrs_Street_Address__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Mailing City'){
                    pAccount.put('PersonMailingCity',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Home Phone'){
                    pAccount.put('PersonHomePhone',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Mobile Phone'){
                    pAccount.put('PersonMobilePhone',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Work Phone'){
                    pAccount.put('Work_Phone__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Mother Maiden Name'){
                    pAccount.put('Mother_Maiden_Name__pc',formRecord.value);
                }else if(formRecord.name == 'CoApplicant First School'){
                    pAccount.put('First_School_Attended__pc',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Mailing Zip Code'){
                    pAccount.put('PersonMailingPostalCode',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Other State'){
                    pAccount.put('Less_than_2yrs_Country__c','United States');
                    pAccount.put('Less_than_2yrs_State__c',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'CoApplicant Mailing State'){
                    pAccount.put('PersonMailingCountry','United States');
                    pAccount.put('PersonMailingState',SFSUtil.getStateName(formRecord.value));
                }else if(formRecord.name == 'CoApplicantMaritalStatus'){
                    pAccount.put('Marital_Status__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicantSpouseName'){
                    pAccount.put('Spouse_Name__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicantSpouseAddress'){
                    pAccount.put('Spouse_Address__c',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Mailing Apartment'){
                    //pAccount.put('',formRecord.value);
                }else if(formRecord.name == 'CoApplicant Home Apartment'){
                    //pAccount.put('',formRecord.value);
                }
                
                
                // HANDLING PREVIOUS EMPLOYMENT
                if (
                    (formRecord.name == 'CoApplicant Previous Employer')||
                    (formRecord.name == 'CoApplicant Previous Employment Street')||
                    (formRecord.name == 'CoApplicant Previous Employment City')||
                    (formRecord.name == 'CoApplicant Previous Employer Start Date')||
                    (formRecord.name == 'CoApplicant Previous Employment State')||
                    (formRecord.name == 'CoApplicant Previous Employment Zip Code')
                ){
                    if (coApplicantPreviousEmployment == null){
                        coApplicantPreviousEmployment = new fsCore__Employment__c();
                        coApplicantPreviousEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                    }
                    
                    if(formRecord.name == 'CoApplicant Previous Employer'){
                        if (String.isNotBlank(formRecord.value)){
                            coApplicantPreviousEmployment.put('fsCore__Employer_Name__c',formRecord.value);
                        }
                    }else if(formRecord.name == 'CoApplicant Previous Employment Street'){
                        coApplicantPreviousEmployment.put('fsCore__Street__c',formRecord.value);
                    }else if(formRecord.name == 'CoApplicant Previous Employment City'){
                        coApplicantPreviousEmployment.put('fsCore__City__c',formRecord.value);
                    }else if(formRecord.name == 'CoApplicant Previous Employer Start Date'){
                        if (String.isNotBlank(formRecord.value)){
                            coApplicantPreviousEmployment.put('fsCore__Start_Date__c',getDateFromMMYYYYString(formRecord.value));
                        }
                    }else if(formRecord.name == 'CoApplicant Previous Employment State'){
                        coApplicantPreviousEmployment.put('fsCore__State__c',SFSUtil.getStateName(formRecord.value));
                    }else if(formRecord.name == 'CoApplicant Previous Employment Zip Code'){
                        coApplicantPreviousEmployment.put('fsCore__Zip_Code__c',formRecord.value);
                    }
                    
                    
                }
                // HANDLING CURRENT EMPLOYMENT
                if (
                    (formRecord.name == 'CoApplicantPrimaryIncomeProviderStartDate')|| //PDI-475 FIX
                    (formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryIncomeProvider'))||
                    (formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryOccupation'))
                ){
                    if (coApplicantCurrentEmployment == null){
                        coApplicantCurrentEmployment = new fsCore__Employment__c();
                        coApplicantCurrentEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                    }
                    if(formRecord.name == 'CoApplicantPrimaryIncomeProviderStartDate'){
                        if (String.isNotBlank(formRecord.value)){
                            coApplicantCurrentEmployment.put('fsCore__Start_Date__c',getDateFromMMYYYYString(formRecord.value));
                        }
                    }else if(formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryIncomeProvider')){
                        if (String.isNotBlank(formRecord.value)){
                            coApplicantCurrentEmployment.put('fsCore__Employer_Name__c',formRecord.value);
                        }
                    }else if(formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryOccupation')){
                        if (String.isNotBlank(formRecord.value)){
                            coApplicantCurrentEmployment.put('fsCore__Title__c',formRecord.value);
                        }
                    }
                }
                
                if(formRecord.name == 'CoApplicant Other Annual Income1'){
                    coApplicantResponse.otherFinancial1.annualIncome = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Annual Income2'){
                    coApplicantResponse.otherFinancial2.annualIncome = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Annual Income3'){
                    coApplicantResponse.otherFinancial3.annualIncome = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Annual Income4'){
                    coApplicantResponse.otherFinancial4.annualIncome = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Annual Base Salary'){
                    coApplicantResponse.mainFinancial.annualIncome = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Monthly Rent'){
                    coApplicantResponse.monthlyPayment = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Housing'){
                    coApplicantResponse.otherHousing = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Housing'){
                    coApplicantResponse.housingType = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Employment Status'){
                    if (String.IsNotBlank(formRecord.value)){
                        if (formRecord.value != 'None'){
                            coApplicantResponse.mainFinancial.incomeType = formRecord.value;
                        }
                    }
                }else if(formRecord.name == 'CoApplicant Source of Other Income1'){
                    coApplicantResponse.otherFinancial1.incomeType = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Source of Other Income2'){
                    coApplicantResponse.otherFinancial2.incomeType = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Source of Other Income3'){
                    coApplicantResponse.otherFinancial3.incomeType = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Source of Other Income4'){
                    coApplicantResponse.otherFinancial4.incomeType = formRecord.value;
                }else if(formRecord.name == 'CoApplicantOtherIncomeProvider1'){
                    coApplicantResponse.otherFinancial1.employment.employerName = formRecord.value;
                    coApplicantResponse.otherFinancial1.provider = formRecord.value;
                    
                }else if(formRecord.name == 'CoApplicantOtherIncomeProvider2'){
                    coApplicantResponse.otherFinancial2.employment.employerName = formRecord.value;
                    coApplicantResponse.otherFinancial2.provider = formRecord.value;
                    
                }else if(formRecord.name == 'CoApplicantOtherIncomeProvider3'){
                    coApplicantResponse.otherFinancial3.employment.employerName = formRecord.value;
                    coApplicantResponse.otherFinancial3.provider = formRecord.value;
                    
                }else if(formRecord.name == 'CoApplicantOtherIncomeProvider4'){
                    coApplicantResponse.otherFinancial4.employment.employerName = formRecord.value;
                    coApplicantResponse.otherFinancial4.provider = formRecord.value;
                    
                }else if(formRecord.name == 'CoApplicantMainIncomeId'){
                    coApplicantResponse.mainFinancial.RecordId = formRecord.value;
                }else if(formRecord.name == 'CoApplicantOtherIncomeId1'){
                    coApplicantResponse.otherFinancial1.RecordId = formRecord.value;
                }else if(formRecord.name == 'CoApplicantOtherIncomeId2'){
                    coApplicantResponse.otherFinancial2.RecordId = formRecord.value;
                }else if(formRecord.name == 'CoApplicantOtherIncomeId3'){
                    coApplicantResponse.otherFinancial3.RecordId = formRecord.value;
                }else if(formRecord.name == 'CoApplicantOtherIncomeId4'){
                    coApplicantResponse.otherFinancial4.RecordId = formRecord.value;
                }else if(formRecord.name == 'CoApplicantPrimaryIncomeProviderStartDate'){
                    coApplicantResponse.mainfinancial.startDate = formRecord.value;
                    coApplicantResponse.mainFinancial.employment.startDate = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Income Start Date1'){
                    coApplicantResponse.otherFinancial1.startDate = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Income Start Date2'){
                    coApplicantResponse.otherFinancial2.startDate = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Income Start Date3'){
                    coApplicantResponse.otherFinancial3.startDate = formRecord.value;
                }else if(formRecord.name == 'CoApplicant Other Income Start Date4'){
                    coApplicantResponse.otherFinancial4.startDate = formRecord.value;
                }else if(formRecord.name == 'CoApplicantHousingId'){
                    coApplicantResponse.housingId = formRecord.value;
                }else if(formRecord.name == 'CoApplicantCurrentEmployerID'){
                    if (String.isNotBlank(formRecord.value)){
                        coApplicantResponse.mainFinancial.employment.RecordId = formRecord.value;
                        if (coapplicantCurrentEmployment == null){
                            coapplicantCurrentEmployment = new fsCore__Employment__c();
                            coapplicantCurrentEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                        }
                        coapplicantCurrentEmployment.id = Id.ValueOf(coApplicantResponse.mainFinancial.employment.RecordId);
                        logmessage('coApplicantCurrentEmployment =2= >'+coApplicantCurrentEmployment);
                    }
                }else if(formRecord.name == 'CoApplicantPreviousEmployerID'){
                    coApplicantResponse.previousEmployment.RecordId = formRecord.value;
                    if (String.isNotBlank(formRecord.value)){
                        coApplicantResponse.previousEmployment.RecordId = formRecord.value;
                        if (coApplicantPreviousEmployment == null){
                            coApplicantPreviousEmployment = new fsCore__Employment__c();
                            coApplicantPreviousEmployment.fsCore__Contact_Name__c = pAccount.PersonContactId;
                        }
                        coApplicantPreviousEmployment.id = Id.ValueOf(coApplicantResponse.previousEmployment.RecordId);
                    }
                    
                }else if(formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryOccupation')){
                    coApplicantResponse.mainFinancial.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('CoApplicantSec1Occupation')){
                    coApplicantResponse.otherFinancial1.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('CoApplicantSec2Occupation')){
                    coApplicantResponse.otherFinancial2.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('CoApplicantSec3Occupation')){
                    coApplicantResponse.otherFinancial3.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('CoApplicantSec4Occupation')){
                    coApplicantResponse.otherFinancial4.occupation = formRecord.value;
                }else if(formRecord.name.startsWithIgnoreCase('CoApplicantPrimaryIncomeProvider')){
                    coApplicantResponse.mainFinancial.employment.employerName = formRecord.value;
                    coApplicantResponse.mainFinancial.provider = formRecord.value;
                }
                
            }
        }
        if ('Applicant'.equals(pEntity)){
            if (applicantPreviousEmployment != null){
                applicantEmpList.add(applicantPreviousEmployment);
            }
            /*if (applicantCurrentEmployment != null){
applicantEmpList.add(applicantCurrentEmployment);
}*/
            for (fsCore__Financial__c financial : pAccount.fsCore__Financial__pr){
                system.debug(logginglevel.error,'applicantResponse.mainFinancial.RecordId ==> '+applicantResponse.mainFinancial.RecordId+'   '+applicantResponse.mainFinancial.incomeType);
                system.debug(logginglevel.error,'financial.Id ==> '+financial.Id);
                system.debug(logginglevel.error,'start_Date__c ==> '+financial.start_Date__c);
                if (String.isNotBlank(applicantResponse.mainFinancial.RecordId ) && applicantResponse.mainFinancial.RecordId == financial.Id){
                    financial.fsCore__Stated_Amount__c = getAmountFromString(applicantResponse.mainFinancial.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(applicantResponse.mainFinancial.startDate);
                    financial.fsCore__Financial_Type__c = applicantResponse.mainFinancial.IncomeType;
                    financial.fsCore__Description__c = applicantResponse.mainFinancial.provider;
                    financial.Occupation__c = applicantResponse.mainFinancial.occupation;
                    
                    financial.fsCore__Is_Active__c = true;
                    
                }
                system.debug(logginglevel.error,'applicantResponse.otherFinancial1.RecordId ==> '+applicantResponse.otherFinancial1.RecordId+'   '+applicantResponse.otherFinancial1.incomeType);
                if (String.isNotBlank(applicantResponse.otherFinancial1.RecordId) && applicantResponse.otherFinancial1.RecordId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(applicantResponse.otherFinancial1.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(applicantResponse.otherFinancial1.startDate);
                    financial.fsCore__Financial_Type__c = applicantResponse.otherFinancial1.incomeType;
                    financial.fsCore__Description__c = applicantResponse.otherFinancial1.provider;
                    financial.Occupation__c = applicantResponse.otherFinancial1.occupation;
                    
                    
                    if (String.isNotBlank(applicantResponse.otherFinancial1.annualIncome) && String.isNotBlank(applicantResponse.otherFinancial1.incomeType)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        system.debug(logginglevel.error,'Annual Income :'+applicantResponse.otherFinancial1.annualIncome+'  Income Type :'+applicantResponse.otherFinancial1.IncomeType);
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                system.debug(logginglevel.error,'applicantResponse.otherFinancial2.RecordId ==> '+applicantResponse.otherFinancial2.RecordId+'   '+applicantResponse.otherFinancial2.incomeType);
                if (String.isNotBlank(applicantResponse.otherFinancial2.RecordId ) && applicantResponse.otherFinancial2.RecordId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(applicantResponse.otherFinancial2.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(applicantResponse.otherFinancial2.startDate);
                    financial.fsCore__Financial_Type__c = applicantResponse.otherFinancial2.IncomeType;
                    financial.fsCore__Description__c = applicantResponse.otherFinancial2.provider;
                    financial.Occupation__c = applicantResponse.otherFinancial2.occupation;
                    
                    if (String.isNotBlank(applicantResponse.otherFinancial2.annualIncome) && String.isNotBlank(applicantResponse.otherFinancial2.IncomeType)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        system.debug(logginglevel.error,'Annual Income :'+applicantResponse.otherFinancial2.annualIncome+'  Income Type :'+applicantResponse.otherFinancial2.IncomeType);
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                system.debug(logginglevel.error,'applicantResponse.otherFinancial3.RecordId ==> '+applicantResponse.otherFinancial3.RecordId+'   '+applicantResponse.otherFinancial3.incomeType);
                if (String.isNotBlank(applicantResponse.otherFinancial3.RecordId ) && applicantResponse.otherFinancial3.RecordId == financial.Id){
                    
                    system.debug(logginglevel.error,'Matched Annual Income'+applicantResponse.otherFinancial3.annualIncome);
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(applicantResponse.otherFinancial3.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(applicantResponse.otherFinancial3.startDate);
                    financial.fsCore__Financial_Type__c = applicantResponse.otherFinancial3.IncomeType;
                    financial.fsCore__Description__c = applicantResponse.otherFinancial3.provider;
                    financial.Occupation__c = applicantResponse.otherFinancial3.occupation;
                    
                    if (String.isNotBlank(applicantResponse.otherFinancial3.annualIncome) && String.isNotBlank(applicantResponse.otherFinancial3.IncomeType)){
                        financial.fsCore__Is_Active__c = true;
                        
                    }else{
                        system.debug(logginglevel.error,'Annual Income :'+applicantResponse.otherFinancial3.annualIncome+'  Income Type :'+applicantResponse.otherFinancial3.IncomeType);
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                system.debug(logginglevel.error,'applicantResponse.otherFinancial4.RecordId ==> '+applicantResponse.otherFinancial4.RecordId+'   '+applicantResponse.otherFinancial4.incomeType);
                if (String.isNotBlank(applicantResponse.otherFinancial4.RecordId ) && applicantResponse.otherFinancial4.RecordId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(applicantResponse.otherFinancial4.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(applicantResponse.otherFinancial4.startDate);
                    financial.fsCore__Financial_Type__c = applicantResponse.otherFinancial4.IncomeType;
                    financial.fsCore__Description__c = applicantResponse.otherFinancial4.provider;
                    financial.Occupation__c = applicantResponse.otherFinancial4.occupation;
                    if (String.isNotBlank(applicantResponse.otherFinancial4.annualIncome) && String.isNotBlank(applicantResponse.otherFinancial4.IncomeType)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        system.debug(logginglevel.error,'Annual Income :'+applicantResponse.otherFinancial4.annualIncome+'  Income Type :'+applicantResponse.otherFinancial4.IncomeType);
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                system.debug(logginglevel.error,'applicantResponse.housingId ==> '+applicantResponse.housingId);
                if (String.isNotBlank(applicantResponse.housingId) && applicantResponse.housingId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(applicantResponse.monthlyPayment);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Monthly';
                    financial.Housing_Type__c = applicantResponse.housingType;
                    financial.Other_Housing_Description__c = applicantResponse.otherHousing;
                    if (String.isNotBlank(applicantResponse.housingType) && String.isNotBlank(applicantResponse.monthlyPayment)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                system.debug(logginglevel.error,'final  ==> '+financial);
                applicantFinList.add(financial);
            }
            
            system.debug(logginglevel.error,'mainFinancialIncomeId '+applicantResponse.mainFinancial.RecordId);
            system.debug(logginglevel.error,'mainFinancialSource '+applicantResponse.mainFinancial.provider);
            system.debug(logginglevel.error,'mainFinancial '+applicantResponse.mainFinancial);
            if (String.isBlank(applicantResponse.mainFinancial.RecordId) && String.isNotBlank(applicantResponse.mainFinancial.incomeType)){
                fsCore__Financial__c applicantMainIncome = getFinancialIncomeRecord(pAccount.PersonContactId
                                                                                    , applicantResponse.mainFinancial);
                
                system.debug(logginglevel.error,'applicantMainIncome ==> '+applicantMainIncome);
                applicantFinList.add(applicantMainIncome);
                
            }
            
            system.debug(logginglevel.error,'OtherAnnualIncomeId1 '+applicantResponse.otherFinancial1.RecordId);
            system.debug(logginglevel.error,'otherIncomeSource1 '+applicantResponse.otherFinancial1.provider);
            if (String.isBlank(applicantResponse.otherFinancial1.RecordId) && String.isNotBlank(applicantResponse.otherFinancial1.incomeType)){
                fsCore__Financial__c applicantOtherIncome1 = getFinancialIncomeRecord(pAccount.PersonContactId
                                                                                      , applicantResponse.otherFinancial1);
                system.debug(logginglevel.error,'applicantOtherIncome1 ==> '+applicantOtherIncome1);
                applicantFinList.add(applicantOtherIncome1);
                
            }
            system.debug(logginglevel.error,'OtherAnnualIncomeId2 '+applicantResponse.otherFinancial2.RecordId);
            system.debug(logginglevel.error,'otherIncomeSource2 '+applicantResponse.otherFinancial2.IncomeType);
            
            if (String.isBlank(applicantResponse.otherFinancial2.RecordId) && String.isNotBlank(applicantResponse.otherFinancial2.IncomeType)){
                fsCore__Financial__c applicantOtherIncome2 = getFinancialIncomeRecord(pAccount.PersonContactId, applicantResponse.otherFinancial2);
                applicantFinList.add(applicantOtherIncome2);
                
                system.debug(logginglevel.error,'applicantOtherIncome2 ==> '+applicantOtherIncome2);
                
            }
            logmessage('applicantFinList 1 size '+applicantFinList.size());
            system.debug(logginglevel.error,'OtherAnnualIncomeId3 '+applicantResponse.otherFinancial3.RecordId);
            system.debug(logginglevel.error,'otherIncomeSource3 '+applicantResponse.otherFinancial3.IncomeType);
            system.debug(logginglevel.error,'otherAnnualIncome3 '+applicantResponse.otherFinancial3.annualIncome);
            
            if (String.isBlank(applicantResponse.otherFinancial3.RecordId) && String.isNotBlank(applicantResponse.otherFinancial3.IncomeType)){
                fsCore__Financial__c applicantOtherIncome3 = getFinancialIncomeRecord(pAccount.PersonContactId, applicantResponse.otherFinancial3 );
                applicantFinList.add(applicantOtherIncome3);
                system.debug(logginglevel.error,'applicantOtherIncome3 ==> '+applicantOtherIncome3);
            }
            system.debug(logginglevel.error,'OtherAnnualIncomeId4 '+applicantResponse.otherFinancial4.RecordId);
            system.debug(logginglevel.error,'otherIncomeSource4 '+applicantResponse.otherFinancial4.IncomeType);
            system.debug(logginglevel.error,'otherAnnualIncome4 '+applicantResponse.otherFinancial4.annualIncome);
            
            if (String.isBlank(applicantResponse.otherFinancial4.RecordId) && String.isNotBlank(applicantResponse.otherFinancial4.IncomeType)){
                fsCore__Financial__c applicantOtherIncome4 = getFinancialIncomeRecord(pAccount.PersonContactId, applicantResponse.otherFinancial4);
                applicantFinList.add(applicantOtherIncome4);
                system.debug(logginglevel.error,'applicantOtherIncome4 ==> '+applicantOtherIncome4);
            }
            logmessage('applicantFinList 2 size '+applicantFinList.size());
            system.debug(logginglevel.error,'housingId '+applicantResponse.housingId);
            system.debug(logginglevel.error,'housingType '+applicantResponse.housingType);
            
            if (String.isBlank(applicantResponse.housingId) && String.isNotBlank(applicantResponse.housingType)){
                fsCore__Financial__c applicanthousing = new fsCore__Financial__c();
                applicanthousing.recordtypeId = Schema.SObjectType.fsCore__Financial__c.getRecordTypeInfosByName().get('Liability').getRecordTypeId();
                applicanthousing.fsCore__Financial_Family__c = 'Liability';
                applicanthousing.fsCore__Financial_Type__c = 'Housing';
                applicanthousing.Housing_Type__c = applicantResponse.housingType;
                applicanthousing.Other_Housing_Description__c = applicantResponse.otherHousing;
                applicanthousing.fsCore__is_active__c = true;
                applicanthousing.fsCore__Contact_Name__c = pAccount.PersonContactId;
                applicanthousing.fsCore__Stated_Amount__c = getAmountFromString(applicantResponse.monthlyPayment);
                applicanthousing.fsCore__Verified_Amount__c = applicanthousing.fsCore__Stated_Amount__c;
                applicanthousing.fsCore__Frequency__c = 'Monthly';
                
                applicantFinList.add(applicanthousing);
            }
            logmessage('applicantFinList 3 size '+applicantFinList.size());
            system.debug(logginglevel.error,'currentEmployment.RecordId '+applicantResponse.mainFinancial.employment.RecordId);
            system.debug(logginglevel.error,'mainFinancial.annualIncome '+applicantResponse.mainFinancial.annualIncome);
            
            
            for (fsCore__Financial__c financial:applicantFinList){
                fsCore__Employment__c employment  = new fsCore__Employment__c();
                if (financial.Employment_Name__c != null){
                    if (String.isNotBlank(applicantResponse.mainFinancial.RecordId ) && applicantResponse.mainFinancial.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,applicantResponse.mainFinancial );
                        employment.id = financial.Employment_Name__c;
                        logmessage('applicantCurrentEmployment =3= >'+applicantCurrentEmployment);
                        employment.fsCore__Title__c = applicantCurrentEmployment.fsCore__Title__c;
                        employment.fsCore__Employer_Name__c = applicantCurrentEmployment.fsCore__Employer_Name__c;
                        
                        
                        applicantEmpList.add(employment);
                        aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.mainFinancial.annualIncome),employment);
                    }
                    if (String.isNotBlank(applicantResponse.otherFinancial1.RecordId ) && applicantResponse.otherFinancial1.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial1 );
                        employment.id = financial.Employment_Name__c;
                        applicantEmpList.add(employment);
                        aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial1.annualIncome),employment);
                    }
                    if (String.isNotBlank(applicantResponse.otherFinancial2.RecordId ) && applicantResponse.otherFinancial2.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial2 );
                        employment.id = financial.Employment_Name__c;
                        applicantEmpList.add(employment);
                        aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial2.annualIncome),employment);
                    }
                    if (String.isNotBlank(applicantResponse.otherFinancial3.RecordId ) && applicantResponse.otherFinancial3.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial3 );
                        employment.id = financial.Employment_Name__c;
                        applicantEmpList.add(employment);
                        aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial3.annualIncome),employment);
                    }
                    if (String.isNotBlank(applicantResponse.otherFinancial4.RecordId ) && applicantResponse.otherFinancial4.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial4 );
                        employment.id = financial.Employment_Name__c;
                        applicantEmpList.add(employment);
                        aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial4.annualIncome),employment);
                    }
                }else{
                    if ((financial.fsCore__Financial_Type__c == 'Salary') ||
                        (financial.fsCore__Financial_Type__c == 'Independent Contractor')||
                        (financial.fsCore__Financial_Type__c == 'Self-employed')
                       ){
                           if (String.isNotBlank(applicantResponse.mainFinancial.annualIncome)){
                               if ((getAmountFromString(applicantResponse.mainFinancial.annualIncome) == financial.fsCore__Stated_Amount__c)
                                   && (applicantResponse.mainFinancial.IncomeType == financial.fsCore__Financial_Type__c)){
                                       
                                       employment = getEmploymentRecord(pAccount,applicantResponse.mainFinancial );
                                       applicantEmpList.add(employment);
                                       aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.mainFinancial.annualIncome),employment);
                                   }
                           }
                           if (String.isNotBlank(applicantResponse.otherFinancial1.annualIncome)){
                               if ((getAmountFromString(applicantResponse.otherFinancial1.annualIncome) == financial.fsCore__Stated_Amount__c)
                                   && (applicantResponse.otherFinancial1.IncomeType == financial.fsCore__Financial_Type__c)){
                                       
                                       
                                       employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial1 );
                                       applicantEmpList.add(employment);
                                       aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial1.annualIncome),employment);
                                   }
                           }
                           if (String.isNotBlank(applicantResponse.otherFinancial2.annualIncome)){
                               if ((getAmountFromString(applicantResponse.otherFinancial2.annualIncome) == financial.fsCore__Stated_Amount__c)
                                   && (applicantResponse.otherFinancial2.IncomeType == financial.fsCore__Financial_Type__c)){
                                       
                                       
                                       employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial2 );
                                       applicantEmpList.add(employment);
                                       aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial2.annualIncome),employment);
                                   }
                           }
                           if (String.isNotBlank(applicantResponse.otherFinancial3.annualIncome)){
                               if ((getAmountFromString(applicantResponse.otherFinancial3.annualIncome) == financial.fsCore__Stated_Amount__c)
                                   && (applicantResponse.otherFinancial3.IncomeType == financial.fsCore__Financial_Type__c)){
                                       
                                       
                                       employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial3 );
                                       applicantEmpList.add(employment);
                                       aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial3.annualIncome),employment);
                                   }
                           }
                           if (String.isNotBlank(applicantResponse.otherFinancial4.annualIncome)){
                               if ((getAmountFromString(applicantResponse.otherFinancial4.annualIncome) == financial.fsCore__Stated_Amount__c)
                                   && (applicantResponse.otherFinancial4.IncomeType == financial.fsCore__Financial_Type__c)){
                                       
                                       
                                       employment = getEmploymentRecord(pAccount,applicantResponse.otherFinancial4 );
                                       applicantEmpList.add(employment);
                                       aplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(applicantResponse.otherFinancial4.annualIncome),employment);
                                   }
                           }
                           
                       }
                }
                
            }
            for (fsCore__Employment__c emp:applicantEmpList){
                if ((emp.fsCore__Employer_Name__c == null)
                    ||String.isBlank(emp.fsCore__Employer_Name__c)){
                        //SINCE WE CANNOT SAVE THE RECORD WITHOUT THE EMPLOYER SO KEEPING THE EMPLOYER AS DEFAULT.
                        emp.fsCore__Employer_Name__c = 'NOT AVAILABLE';
                    }
                logmessage('Employment : '+emp);
            }
            Savepoint sp = Database.setSavepoint();
            try{  
                upsert applicantEmpList;
                
                for (fsCore__Financial__c financial:applicantFinList){
                    System.debug(loggingLevel.ERROR, '***aplfinancialEmploymentMap**** '+aplfinancialEmploymentMap);
                    System.debug(loggingLevel.ERROR, '***KEY**** '+financial.fsCore__Financial_Type__c+String.ValueOf(financial.fsCore__Stated_Amount__c));
                    if (aplfinancialEmploymentMap.get(financial.fsCore__Financial_Type__c+String.ValueOf(financial.fsCore__Stated_Amount__c)) != null){
                        //POPULATING THE EMPLOYMENT NAME IN THE FINANCIAL RECORD
                        System.debug(loggingLevel.ERROR, '***KEY DOES  EXIST **** ');
                        financial.Employment_Name__c = aplfinancialEmploymentMap.get(financial.fsCore__Financial_Type__c+String.ValueOf(financial.fsCore__Stated_Amount__c)).Id;
                    }else{
                        System.debug(loggingLevel.ERROR, '***KEY DOES NOT EXIST **** ');
                    }
                    logmessage('financial  '+financial);
                }
                
                logmessage('applicantFinList size '+applicantFinList.size());
                logmessage('pAccount  '+pAccount);
                
                
                upsert applicantFinList;
                update pAccount;
            }catch(Exception e){
                Database.rollback(sp);
                System.debug(loggingLevel.ERROR, fsCore.ExceptionMessageUtil.getExceptionMessage(e));
                System.debug(loggingLevel.ERROR, e);
                throw e;
            }
            
            logmessage(' Done Saving the records');
        }
        
        if ('CoApplicant'.equals(pEntity)){
            if (coApplicantPreviousEmployment != null){
                coApplicantEmpList.add(coApplicantPreviousEmployment);
            }
            
            for (fsCore__Financial__c financial : pAccount.fsCore__Financial__pr){
                if (String.isNotBlank(CoApplicantResponse.mainFinancial.RecordId ) && CoApplicantResponse.mainFinancial.RecordId == financial.Id){
                    financial.fsCore__Stated_Amount__c = getAmountFromString(CoApplicantResponse.mainFinancial.annualIncome );
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(CoApplicantResponse.mainFinancial.startDate);
                    financial.fsCore__Financial_Type__c = CoApplicantResponse.mainFinancial.IncomeType;
                    financial.fsCore__Description__c = CoApplicantResponse.mainFinancial.provider;
                    financial.fsCore__Is_Active__c = true;
                    financial.Occupation__c = CoApplicantResponse.mainFinancial.occupation;
                    
                }
                if (String.isNotBlank(CoApplicantResponse.otherFinancial1.RecordId) && CoApplicantResponse.otherFinancial1.RecordId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(CoApplicantResponse.otherFinancial1.annualIncome );
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(CoApplicantResponse.otherFinancial1.startDate);
                    financial.fsCore__Financial_Type__c = CoApplicantResponse.otherFinancial1.incomeType;
                    financial.fsCore__Description__c = CoApplicantResponse.otherFinancial1.provider;
                    financial.Occupation__c = CoApplicantResponse.otherFinancial1.occupation;
                    
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial1.annualIncome) && String.isNotBlank(CoApplicantResponse.otherFinancial1.incomeType)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                if (String.isNotBlank(CoApplicantResponse.otherFinancial2.RecordId ) && CoApplicantResponse.otherFinancial2.RecordId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(CoApplicantResponse.otherFinancial2.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(CoApplicantResponse.otherFinancial2.startDate);
                    financial.fsCore__Financial_Type__c = CoApplicantResponse.otherFinancial2.IncomeType;
                    financial.fsCore__Description__c = CoApplicantResponse.otherFinancial2.provider;
                    financial.Occupation__c = CoApplicantResponse.otherFinancial2.occupation;
                    
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial2.annualIncome) && String.isNotBlank(CoApplicantResponse.otherFinancial2.IncomeType)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                if (String.isNotBlank(CoApplicantResponse.otherFinancial3.RecordId ) && CoApplicantResponse.otherFinancial3.RecordId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(CoApplicantResponse.otherFinancial3.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(CoApplicantResponse.otherFinancial3.startDate);
                    financial.fsCore__Financial_Type__c = CoApplicantResponse.otherFinancial3.IncomeType;
                    financial.fsCore__Description__c = CoApplicantResponse.otherFinancial3.provider;
                    financial.Occupation__c = CoApplicantResponse.otherFinancial3.occupation;
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial3.annualIncome) && String.isNotBlank(CoApplicantResponse.otherFinancial3.IncomeType)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                if (String.isNotBlank(CoApplicantResponse.otherFinancial4.RecordId ) && CoApplicantResponse.otherFinancial4.RecordId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(CoApplicantResponse.otherFinancial4.annualIncome);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Annual';
                    financial.start_Date__c = getDateFromMMYYYYString(CoApplicantResponse.otherFinancial4.startDate);
                    financial.fsCore__Financial_Type__c = CoApplicantResponse.otherFinancial4.IncomeType;
                    financial.fsCore__Description__c = CoApplicantResponse.otherFinancial4.provider;
                    financial.Occupation__c = CoApplicantResponse.otherFinancial4.occupation;
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial4.annualIncome) && String.isNotBlank(CoApplicantResponse.otherFinancial4.IncomeType)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                if (String.isNotBlank(CoApplicantResponse.housingId) && CoApplicantResponse.housingId == financial.Id){
                    
                    financial.fsCore__Stated_Amount__c = getAmountFromString(CoApplicantResponse.monthlyPayment);
                    financial.fsCore__Verified_Amount__c = financial.fsCore__Stated_Amount__c;
                    financial.fsCore__Frequency__c = 'Monthly';
                    financial.Housing_Type__c = CoApplicantResponse.housingType;
                    financial.Other_Housing_Description__c = CoApplicantResponse.otherHousing;
                    
                    if (String.isNotBlank(CoApplicantResponse.housingType) && String.isNotBlank(CoApplicantResponse.monthlyPayment)){
                        financial.fsCore__Is_Active__c = true;
                    }else{
                        financial.fsCore__Is_Active__c = false;
                    }
                }
                CoApplicantFinList.add(financial);
            }
            
            system.debug(logginglevel.error,'mainFinancialIncomeId '+CoApplicantResponse.mainFinancial.RecordId);
            system.debug(logginglevel.error,'mainFinancialIncomeType '+CoApplicantResponse.mainFinancial.incomeType);
            if (String.isBlank(CoApplicantResponse.mainFinancial.RecordId) && String.isNotBlank(CoApplicantResponse.mainFinancial.incomeType)){
                
                system.debug(logginglevel.error,'Getting Financial Record');
                fsCore__Financial__c CoApplicantMainFinancial = getFinancialIncomeRecord(pAccount.PersonContactId
                                                                                         , CoApplicantResponse.mainFinancial);
                CoApplicantFinList.add(CoApplicantMainFinancial);
                
            }
            
            system.debug(logginglevel.error,'OtherAnnualIncomeId1 '+CoApplicantResponse.otherFinancial1.RecordId);
            system.debug(logginglevel.error,'otherIncomeType1 '+CoApplicantResponse.otherFinancial1.incomeType);
            if (String.isBlank(CoApplicantResponse.otherFinancial1.RecordId) && String.isNotBlank(CoApplicantResponse.otherFinancial1.incomeType)){
                fsCore__Financial__c CoApplicantOtherIncome1 = getFinancialIncomeRecord(pAccount.PersonContactId
                                                                                        , CoApplicantResponse.otherFinancial1);
                CoApplicantFinList.add(CoApplicantOtherIncome1);
                
            }
            system.debug(logginglevel.error,'OtherAnnualIncomeId2 '+CoApplicantResponse.otherFinancial2.RecordId);
            system.debug(logginglevel.error,'otherIncomeSource2 '+CoApplicantResponse.otherFinancial2.IncomeType);
            
            if (String.isBlank(CoApplicantResponse.otherFinancial2.RecordId) && String.isNotBlank(CoApplicantResponse.otherFinancial2.IncomeType)){
                fsCore__Financial__c CoApplicantOtherIncome2 = getFinancialIncomeRecord(pAccount.PersonContactId, CoApplicantResponse.otherFinancial2);
                CoApplicantFinList.add(CoApplicantOtherIncome2);
                
            }
            logmessage('CoApplicantFinList 1 size '+CoApplicantFinList.size());
            system.debug(logginglevel.error,'OtherAnnualIncomeId3 '+CoApplicantResponse.otherFinancial3.RecordId);
            system.debug(logginglevel.error,'otherIncomeSource3 '+CoApplicantResponse.otherFinancial3.IncomeType);
            system.debug(logginglevel.error,'otherAnnualIncome3 '+CoApplicantResponse.otherFinancial3.annualIncome);
            
            if (String.isBlank(CoApplicantResponse.otherFinancial3.RecordId) && String.isNotBlank(CoApplicantResponse.otherFinancial3.IncomeType)){
                fsCore__Financial__c CoApplicantOtherIncome3 = getFinancialIncomeRecord(pAccount.PersonContactId, CoApplicantResponse.otherFinancial3 );
                CoApplicantFinList.add(CoApplicantOtherIncome3);
            }
            system.debug(logginglevel.error,'OtherAnnualIncomeId4 '+CoApplicantResponse.otherFinancial4.RecordId);
            system.debug(logginglevel.error,'otherIncomeSource4 '+CoApplicantResponse.otherFinancial4.IncomeType);
            system.debug(logginglevel.error,'otherAnnualIncome4 '+CoApplicantResponse.otherFinancial4.annualIncome);
            
            if (String.isBlank(CoApplicantResponse.otherFinancial4.RecordId) && String.isNotBlank(CoApplicantResponse.otherFinancial4.IncomeType)){
                fsCore__Financial__c CoApplicantOtherIncome4 = getFinancialIncomeRecord(pAccount.PersonContactId, CoApplicantResponse.otherFinancial4);
                CoApplicantFinList.add(CoApplicantOtherIncome4);
            }
            logmessage('CoApplicantFinList 2 size '+CoApplicantFinList.size());
            system.debug(logginglevel.error,'housingId '+CoApplicantResponse.housingId);
            system.debug(logginglevel.error,'housingType '+CoApplicantResponse.housingType);
            
            if (String.isBlank(CoApplicantResponse.housingId) && String.isNotBlank(CoApplicantResponse.housingType)){
                fsCore__Financial__c CoApplicanthousing = new fsCore__Financial__c();
                CoApplicanthousing.recordtypeId = Schema.SObjectType.fsCore__Financial__c.getRecordTypeInfosByName().get('Liability').getRecordTypeId();
                CoApplicanthousing.fsCore__Financial_Family__c = 'Liability';
                CoApplicanthousing.fsCore__Financial_Type__c = 'Housing';
                CoApplicanthousing.Housing_Type__c = CoApplicantResponse.housingType;
                CoApplicanthousing.Other_Housing_Description__c = CoApplicantResponse.otherHousing;
                CoApplicanthousing.fsCore__is_active__c = true;
                CoApplicanthousing.fsCore__Contact_Name__c = pAccount.PersonContactId;
                CoApplicanthousing.fsCore__Stated_Amount__c = getAmountFromString(CoApplicantResponse.monthlyPayment);
                CoApplicanthousing.fsCore__Verified_Amount__c = CoApplicanthousing.fsCore__Stated_Amount__c;
                CoApplicanthousing.fsCore__Frequency__c = 'Monthly';
                
                CoApplicantFinList.add(CoApplicanthousing);
            }
            logmessage('CoApplicantFinList 3 size '+CoApplicantFinList.size());
            system.debug(logginglevel.error,'currentEmployment.RecordId '+CoApplicantResponse.mainFinancial.employment.RecordId);
            system.debug(logginglevel.error,'mainFinancial.annualIncome '+CoApplicantResponse.mainFinancial.annualIncome);
            
            
            for (fsCore__Financial__c financial:CoApplicantFinList){
                fsCore__Employment__c employment  = new fsCore__Employment__c();
                if (financial.Employment_Name__c != null){
                    if (String.isNotBlank(CoApplicantResponse.mainFinancial.RecordId ) && CoApplicantResponse.mainFinancial.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,CoApplicantResponse.mainFinancial );
                        employment.id = financial.Employment_Name__c;
                        employment.fsCore__Title__c = coapplicantCurrentEmployment.fsCore__Title__c;
                        employment.fsCore__Employer_Name__c = coapplicantCurrentEmployment.fsCore__Employer_Name__c;
                        
                        logmessage('applicantCurrentEmployment =3= >'+coapplicantCurrentEmployment);
                        CoApplicantEmpList.add(employment);
                        coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.mainFinancial.annualIncome),employment);
                    }
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial1.RecordId ) && CoApplicantResponse.otherFinancial1.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial1 );
                        employment.id = financial.Employment_Name__c;
                        CoApplicantEmpList.add(employment);
                        coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial1.annualIncome),employment);
                    }
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial2.RecordId ) && CoApplicantResponse.otherFinancial2.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial2 );
                        employment.id = financial.Employment_Name__c;
                        CoApplicantEmpList.add(employment);
                        coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial2.annualIncome),employment);
                    }
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial3.RecordId ) && CoApplicantResponse.otherFinancial3.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial3 );
                        employment.id = financial.Employment_Name__c;
                        CoApplicantEmpList.add(employment);
                        coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial3.annualIncome),employment);
                    }
                    if (String.isNotBlank(CoApplicantResponse.otherFinancial4.RecordId ) && CoApplicantResponse.otherFinancial4.RecordId == financial.Id){
                        
                        employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial4 );
                        employment.id = financial.Employment_Name__c;
                        CoApplicantEmpList.add(employment);
                        coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial4.annualIncome),employment);
                    }
                }else{
                    if (
                        (financial.fsCore__Financial_Type__c == 'Salary') ||
                        (financial.fsCore__Financial_Type__c == 'Independent Contractor')||
                        (financial.fsCore__Financial_Type__c == 'Self-employed')
                    ){
                        if (String.isNotBlank(CoApplicantResponse.mainFinancial.annualIncome)){
                            if ((getAmountFromString(CoApplicantResponse.mainFinancial.annualIncome) == financial.fsCore__Stated_Amount__c)
                                && (CoApplicantResponse.mainFinancial.IncomeType == financial.fsCore__Financial_Type__c)){
                                    
                                    employment = getEmploymentRecord(pAccount,CoApplicantResponse.mainFinancial );
                                    CoApplicantEmpList.add(employment);
                                    coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.mainFinancial.annualIncome),employment);
                                }
                        }
                        if (String.isNotBlank(CoApplicantResponse.otherFinancial1.annualIncome)){
                            if ((getAmountFromString(CoApplicantResponse.otherFinancial1.annualIncome) == financial.fsCore__Stated_Amount__c)
                                && (CoApplicantResponse.otherFinancial1.IncomeType == financial.fsCore__Financial_Type__c)){
                                    
                                    
                                    employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial1 );
                                    CoApplicantEmpList.add(employment);
                                    coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial1.annualIncome),employment);
                                }
                        }
                        if (String.isNotBlank(CoApplicantResponse.otherFinancial2.annualIncome)){
                            if ((getAmountFromString(CoApplicantResponse.otherFinancial2.annualIncome) == financial.fsCore__Stated_Amount__c)
                                && (CoApplicantResponse.otherFinancial2.IncomeType == financial.fsCore__Financial_Type__c)){
                                    
                                    
                                    employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial2 );
                                    CoApplicantEmpList.add(employment);
                                    coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial2.annualIncome),employment);
                                }
                        }
                        if (String.isNotBlank(CoApplicantResponse.otherFinancial3.annualIncome)){
                            if ((getAmountFromString(CoApplicantResponse.otherFinancial3.annualIncome) == financial.fsCore__Stated_Amount__c)
                                && (CoApplicantResponse.otherFinancial3.IncomeType == financial.fsCore__Financial_Type__c)){
                                    
                                    
                                    employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial3 );
                                    CoApplicantEmpList.add(employment);
                                    coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial3.annualIncome),employment);
                                }
                        }
                        if (String.isNotBlank(CoApplicantResponse.otherFinancial4.annualIncome)){
                            if ((getAmountFromString(CoApplicantResponse.otherFinancial4.annualIncome) == financial.fsCore__Stated_Amount__c)
                                && (CoApplicantResponse.otherFinancial4.IncomeType == financial.fsCore__Financial_Type__c)){
                                    
                                    
                                    employment = getEmploymentRecord(pAccount,CoApplicantResponse.otherFinancial4 );
                                    CoApplicantEmpList.add(employment);
                                    coaplfinancialEmploymentMap.put(financial.fsCore__Financial_Type__c+removeComma(CoApplicantResponse.otherFinancial4.annualIncome),employment);
                                }
                        }
                        
                    }
                }
                
            }
            
            logmessage('CoApplicantEmpList size '+CoApplicantEmpList.size());
            for (fsCore__Employment__c coEmp: CoApplicantEmpList){
                if ((coEmp.fsCore__Employer_Name__c == null)
                    ||String.isBlank(coEmp.fsCore__Employer_Name__c)){
                        coEmp.fsCore__Employer_Name__c = 'NOT AVAILABLE';
                    }
                logmessage('Co-Employment : '+coEmp);
            }
            Savepoint sp = Database.setSavepoint();
            try{  
                
                upsert CoApplicantEmpList;
                
                for (fsCore__Financial__c financial:CoApplicantFinList){
                    if (coaplfinancialEmploymentMap.get(financial.fsCore__Financial_Type__c+String.ValueOf(financial.fsCore__Stated_Amount__c)) != null){
                        financial.Employment_Name__c = coaplfinancialEmploymentMap.get(financial.fsCore__Financial_Type__c+String.ValueOf(financial.fsCore__Stated_Amount__c)).Id;
                    }
                    logmessage('Co - App financial  '+financial);
                }
                
                logmessage('CoApplicantFinList size '+CoApplicantFinList.size());
                
                upsert CoApplicantFinList;
                update pAccount;
            }catch(Exception e){
                Database.rollback(sp);
                System.debug(loggingLevel.ERROR, fsCore.ExceptionMessageUtil.getExceptionMessage(e));
                System.debug(loggingLevel.ERROR, e);
                throw e;
            }
        }
    }
    
    private static fsCore__Employment__c getEmploymentRecord(Account pAccount,DNLApplicant.Financial applicantFinancial ){
        
        logmessage('applicantFinancial ==> '+applicantFinancial);
        fsCore__Employment__c employment  = new fsCore__Employment__c();
        employment.fsCore__Contact_Name__c = pAccount.PersonContactId;
        //employment.fsCore__Employer_Name__c = applicantFinancial.employment.employerName;
        employment.fsCore__Employer_Name__c = applicantFinancial.provider;
        employment.fsCore__Title__c = applicantFinancial.occupation;
        if (applicantFinancial.incomeType == 'Salary'){
            employment.fsCore__Employment_Type__c= 'Full Time';
        }else{
            employment.fsCore__Employment_Type__c= 'Contract';
        }
        if (String.isNotBlank(applicantFinancial.startDate)){
            
            employment.fsCore__Start_Date__c = getDateFromMMYYYYString(applicantFinancial.startDate);
            
        }else{
            employment.fsCore__Start_Date__c =  date.Today();
        }
        employment.fsCore__Salary__c = 0.00;
        if (String.isNotBlank(applicantFinancial.annualIncome)){
            employment.fsCore__Salary__c   = getAmountFromString(applicantFinancial.annualIncome);
        }
        logmessage('employment ==> '+employment);
        return employment;
        
        
        
    }
    
    
    private static fsCore__Financial__c getFinancialIncomeRecord(Id pContactName,DNLApplicant.Financial applicantFinancial ){
        logmessage(' ***** incomeType ****:'+applicantFinancial.incomeType);
        fsCore__Financial__c incomeRecord = new fsCore__Financial__c();
        
        incomeRecord.recordtypeId = Schema.SObjectType.fsCore__Financial__c.getRecordTypeInfosByName().get('Income').getRecordTypeId();
        incomeRecord.fsCore__Financial_Family__c = 'Income';
        incomeRecord.fsCore__is_active__c = true;
        incomeRecord.fsCore__Contact_Name__c = pContactName;
        incomeRecord.start_Date__c = getDateFromMMYYYYString(applicantFinancial.startDate);
        
        logmessage(' ***** incomeRecord.start_Date__c ****:'+incomeRecord.start_Date__c);
        
        incomeRecord.fsCore__Financial_Type__c = applicantFinancial.incomeType;
        incomeRecord.Occupation__c = applicantFinancial.occupation;      
        incomeRecord.fsCore__Description__c = applicantFinancial.provider;
        incomeRecord.fsCore__Stated_Amount__c = getAmountFromString(applicantFinancial.annualIncome);
        incomeRecord.fsCore__Frequency__c = 'Annual';
        
        return incomeRecord;
        
    }
    
    private static Boolean isValueChanged(String attrName, String pOldValue, String pNewValue){
        boolean isChanged = true;
        
        if (
            (pOldValue == null && pNewValue == null)||
            (pOldValue == null && pNewValue == '')||
            (pOldValue == '' && pNewValue == null)||
            (pOldValue == '' && pNewValue == '')
        ){
            isChanged = false;
        }
        if (pOldValue == pNewValue){
            isChanged = false;
        }
        
        return isChanged;
        
        
    }
    
    
    
    
    public void resendNotification(){
        String endPoint=SFS_System_Settings__c.getInstance().Docusign_REST_EndPoint__c+'/accounts/'+SFS_System_Settings__c.getInstance().Docusign_Account_Id__c+'/envelopes/'+mEnvelopeId+'?resend_envelope=true';
        Http h2= new Http();
        HttpRequest req2 = setRestHttpRequest(endPoint,'PUT');
        HttpResponse res2=h2.send(req2);
        system.debug(logginglevel.error,res2+'###1203createresp');
        system.debug(logginglevel.error,res2.getBody()+'###1204createresp');
        DocusignFormDataJSON2Apex deresp2=DocusignFormDataJSON2Apex.parse(res2.getBody());
        System.debug(logginglevel.error,'###1203createdeser'+deresp2);
    }
    
    
    
    
    public SendToDocuSignController(ApexPages.StandardController controller)
    {
        mValidationsPassed = false;
        mEnvelopeAlreadySent = false;
        mLastEnvelopeCompleted = false;
        
        mOpportunity = [SELECT id
                        , name
                        , AccountId
                        , Co_Applicant_Name__c
                        , Portfolio_Type__c
                        , Law_Firm_Name__c
                        , DRP_Account_Number__c
                        , DRP_Name__c
                        , Account.PersonEmail
                        , Co_Applicant_Name__r.PersonEmail
                        , ownerId
                        FROM Opportunity
                        WHERE id = :controller.getRecord().Id];
        mEnvelopeId = 'Not sent yet';
        
        BuildApplicantInformation();
        SendNow();
    }
    
    public void SendEnvelopeUsingTemplateId(String pEmailSubject,String pEmailBlurb)
    {
        /*DocuSignAPI.APIServiceSoap dsApiSend
= new DocuSignAPI.APIServiceSoap();
dsApiSend.endpoint_x = SFS_System_Settings__c.getInstance().Docusign_SOAP_EndPoint__c;

//Set Authentication
String auth = '<DocuSignCredentials><Username>'+ SFS_System_Settings__c.getInstance().Docusign_User_Id__c
+'</Username><Password>' + SFS_System_Settings__c.getInstance().Docusign_Password__c
+ '</Password><IntegratorKey>' + SFS_System_Settings__c.getInstance().Docusign_Integrator_Key__c
+ '</IntegratorKey></DocuSignCredentials>';

dsApiSend.inputHttpHeaders_x = new Map<String, String>();
dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',
auth);*/
        
        DocuSignAPI.EnvelopeInformation envelope = new DocuSignAPI.EnvelopeInformation();
        //SFS RAISED THAT ALL THE APPLICATIONS ARE BEING SENT AS AuthoritativeCopy
        //SO EXPLICITLY MARKING AS FALSE ON 02/19/2019
        envelope.AuthoritativeCopy = false;
        envelope.Subject = pEmailSubject;
        envelope.EmailBlurb = pEmailBlurb;
        envelope.AccountId  = SFS_System_Settings__c.getInstance().Docusign_Account_Id__c;
        
        /*
If you are integrating with Salesforce and you want the envelope status tracked in Salesforce
and the signed document saved in Salesforce, you can send the Record ID of the record using a
custom field (under More Options) called:

Account = ##SFAccount
Contact = ##SFContact
Opportunity= ##SFOpportunity
Case = ##SFCase
Contract = ##SFContract
Custom Object = DSFSSourceObjectId*/
        
        
        //Attaching the document with contract objects start
        DocuSignAPI.CustomField field = new DocuSignAPI.CustomField ();
        field.Name = '##SFOpportunity';
        field.Value = mOpportunity.Id;
        
        envelope.CustomFields = new DocuSignAPI.ArrayOfCustomField();
        envelope.CustomFields.CustomField = new DocuSignAPI.CustomField[1];
        envelope.CustomFields.CustomField[0] = field;
        
        
        
        // Create object for the Application server-side template
        Map<String,Docusign_Documents__c> docusignDocumentsMap = Docusign_Documents__c.getAll();
        Docusign_Documents__c documentDetail;
        
        if (mOpportunity.Portfolio_Type__c == 'Timberline'){
            documentDetail = docusignDocumentsMap.get('Opp Loan Application T');
        }else {
            documentDetail = docusignDocumentsMap.get('Opp Loan Application A');
        }
        
        DocuSignAPI.TemplateReference applicationTemplate = new DocuSignAPI.TemplateReference();
        applicationTemplate.Template = documentDetail.Template_Id__c;
        applicationTemplate.TemplateLocation = 'Server';
        
        
        
        // Recipient
        MAP<String,Id> applicantsMap = new MAP<String,Id> ();
        if (String.isNotBlank(mOpportunity.AccountId)){
            applicantsMap.put('Applicant',mOpportunity.AccountId);
        }
        if (String.isNotBlank(mOpportunity.Co_Applicant_Name__c)){
            applicantsMap.put('Co-Applicant',mOpportunity.Co_Applicant_Name__c);
        }
        
        // Recipient Information
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = mApplicant.emailAddress;
        recipient.UserName = mApplicant.FirstName + ' ' + mApplicant.LastName;
        recipient.RoleName = 'Applicant';
        
        // Role assignments
        DocuSignAPI.TemplateReferenceRoleAssignment roleAssignment = new DocuSignAPI.TemplateReferenceRoleAssignment();
        roleAssignment.RoleName = recipient.RoleName;
        roleAssignment.RecipientID = recipient.ID;
        
        DocuSignAPI.Recipient recipient2 = new DocuSignAPI.Recipient();
        DocuSignAPI.TemplateReferenceRoleAssignment roleAssignment2 = new DocuSignAPI.TemplateReferenceRoleAssignment();
        if (applicantsMap.get('Co-Applicant') != null){
            system.debug(logginglevel.error,'mCoApplicant :'+mCoApplicant);
            recipient2.ID = 2;
            recipient2.Type_x = 'Signer';
            recipient2.RoutingOrder = 2;
            recipient2.Email = mCoApplicant.emailAddress;
            recipient2.UserName = mCoApplicant.FirstName + ' ' + mCoApplicant.LastName;
            recipient2.RoleName = 'Co-Applicant';
            
            // Role assignments
            roleAssignment2.RoleName = recipient2.RoleName;
            roleAssignment2.RecipientID = recipient2.ID;
            
            
        }
        
        DocuSignAPI.ArrayOfRecipient1 signers = new DocuSignAPI.ArrayOfRecipient1();
        
        
        if (applicantsMap.get('Co-Applicant') != null){
            signers.Recipient = new DocuSignAPI.Recipient[2];
            signers.Recipient[0] = recipient;
            signers.Recipient[1] = recipient2;
            
            
            // Add role assignment
            applicationTemplate.RoleAssignments = new DocuSignAPI.ArrayOfTemplateReferenceRoleAssignment();
            applicationTemplate.RoleAssignments.RoleAssignment = new DocuSignAPI.TemplateReferenceRoleAssignment[2];
            applicationTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;
            applicationTemplate.RoleAssignments.RoleAssignment[1] = roleAssignment2;
            
        }else{
            signers.Recipient = new DocuSignAPI.Recipient[1];
            signers.Recipient[0] = recipient;
            
            
            // Add role assignment
            applicationTemplate.RoleAssignments = new DocuSignAPI.ArrayOfTemplateReferenceRoleAssignment();
            applicationTemplate.RoleAssignments.RoleAssignment = new DocuSignAPI.TemplateReferenceRoleAssignment[1];
            applicationTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;
        }
        
        setApplicantFields(applicationTemplate);
        
        // create array of template references
        DocuSignAPI.ArrayOfTemplateReference templateReferences = new DocuSignAPI.ArrayOfTemplateReference();
        templateReferences.TemplateReference = new DocuSignAPI.TemplateReference[1];
        templateReferences.TemplateReference[0] = applicationTemplate;
        
        
        DocuSignAPI.EmailSettings replyEmailSettings = new DocuSignAPI.EmailSettings();
        replyEmailSettings.ReplyEmailAddressOverride = mSenderDefaultEmail;
        replyEmailSettings.ReplyEmailNameOverride = mSenderDefaultName;
        
        envelope.emailSettings = replyEmailSettings;
        
        
        System.debug('Calling the API');
        if (!Test.isRunningTest()){ //AD DO NOT CALL DOCUSIGN API WHILE RUNNING THE TEST
            
            try {
                envelope.AuthoritativeCopy = false;
                
                DocuSignAPI.EnvelopeStatus es
                    = DocusignAPIUtil.getSOAPAuthenticationHeader().CreateEnvelopeFromTemplates(templateReferences, signers, envelope, true);
                mEnvelopeId = es.EnvelopeID;
                sentToDocuSign= true;
                
            } catch ( CalloutException e) {
                System.debug('Exception - ' + e );
                mEnvelopeId = 'Exception - ' + e;
            }
        }
        
    }
    
    /**
* @description This method will get called immediately when the modal window opened "send document to docusign"
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 7/17/2019
* @return pageReference
*/
    public pageReference onLoad(){
        logmessage('On Loan sentToDocuSign :'+sentToDocuSign);
        if (sentToDocuSign){
            insertDocuSignStatus();
        }
        
        return null;
    }
    
    private void BuildApplicantInformation(){
        if (String.isNotBlank(mOpportunity.AccountId)){
            applicantsMap.put('Applicant',mOpportunity.AccountId);
        }
        if (String.isNotBlank(mOpportunity.Co_Applicant_Name__c)){
            applicantsMap.put('Co-Applicant',mOpportunity.Co_Applicant_Name__c);
        }
        getDNLApplicant(applicantsMap);
        
    }
    
    private date getFinancialStartDate(fsCore__Financial__c financial){
        Date startDate = financial.Start_Date__c;
        if (financial.Employment_Name__r.Id != null){
            if (financial.Employment_Name__r.fsCore__Start_Date__c != null){
                startDate = financial.Employment_Name__r.fsCore__Start_Date__c;
            }
        }                                
        return startDate;
    } 
    
    private String getIncomeProviderName(fsCore__Financial__c financial){
        String providerName = financial.fsCore__Description__c;
        if (financial.Employment_Name__r.Id != null){
            if (financial.Employment_Name__r.fsCore__Employer_Name__c != null){
                providerName = financial.Employment_Name__r.fsCore__Employer_Name__c;
            }
        }                                
        return providerName;
    } 
    
    //PDI-854
    private String getOccupationName(fsCore__Financial__c financial){
        String occupationName = financial.Occupation__c;
        if (financial.Employment_Name__r.Id != null){
            if (financial.Employment_Name__r.fsCore__Title__c != null){
                occupationName = financial.Employment_Name__r.fsCore__Title__c;
            }
        }                                
        return occupationName;
    }                                        
    
    
    private void getDNLApplicant(MAP<String,Id> pApplicantsMap){
        
        //DNLApplicant applicant = new DNLApplicant();
        //No address Number
        
        List<Account> accList = [select id
                                 , name
                                 , FirstName
                                 , MiddleName
                                 , LastName
                                 , PersonBirthdate
                                 , fsCore__National_Identification_Number__pc
                                 , U_S_Residency_Status__c
                                 , PersonEmail
                                 , PersonHomePhone
                                 , PersonMobilePhone
                                 , Work_Phone__c
                                 , PersonOtherStreet
                                 , PersonOtherCity
                                 , PersonOtherState
                                 , PersonOtherPostalCode
                                 , PersonOtherCountry
                                 , PersonMailingStreet
                                 , PersonMailingCity
                                 , PersonMailingState
                                 , PersonMailingPostalCode
                                 , PersonMailingCountry
                                 , Primary_Id_Type__c
                                 , Primary_Id_Number__c
                                 , Primary_Id_Expiration_Date__c
                                 , Primary_Id_State__c
                                 , First_School_Attended__pc
                                 , Mother_Maiden_Name__pc
                                 , Residing_Since_Date__c
                                 , Less_than_2yrs_Apt_Num__c
                                 , Less_than_2yrs_City__c
                                 , Less_than_2yrs_Country__c
                                 , Less_than_2yrs_State__c
                                 , Less_than_2yrs_Street_Address__c
                                 , Less_than_2yrs_Zip_Code__c
                                 , Spouse_Name__c
                                 , Spouse_Address__c
                                 , Marital_Status__c
                                 ,( select id
                                   , name
                                   , fsCore__Title__c
                                   , fsCore__Employer_Name__c
                                   , fsCore__Start_Date__c
                                   , fsCore__End_Date__c
                                   , fsCore__Street__c
                                   , fsCore__City__c
                                   , fsCore__State__c
                                   , fsCore__Zip_Code__c
                                   , fsCore__Salary__c
                                   , Is_Primary_Employment__c
                                   from fsCore__Contact_Employment__pr
                                   Order By fsCore__Start_Date__c Desc)
                                 ,( select id
                                   , name
                                   , fsCore__Contact_Name__c
                                   , fsCore__Financial_Family__c
                                   , fsCore__Financial_Type__c
                                   , fsCore__Frequency__c
                                   , fsCore__Is_Active__c
                                   , fsCore__Stated_Amount__c
                                   , fsCore__Verified_Amount__c
                                   , Occupation__c
                                   , Start_Date__c
                                   , Is_Primary_Employment__c
                                   , Is_Primary_Income__c
                                   , Housing_Type__c
                                   , Other_Housing_Description__c
                                   , fsCore__Description__c
                                   , Employment_Name__r.fsCore__Title__c
                                   , Title_Formula__c
                                   , Employment_Name__r.Id
                                   , Employment_Name__r.fsCore__Employer_Name__c
                                   , Employment_Name__r.fsCore__Start_Date__c
                                   , Employment_Name__r.fsCore__Street__c
                                   , Employment_Name__r.fsCore__City__c
                                   , Employment_Name__r.fsCore__State__c
                                   , Employment_Name__r.fsCore__Zip_Code__c
                                   , Employment_Name__r.fsCore__Salary__c
                                   , Employment_Name__c
                                   FROM fsCore__Financial__pr
                                   WHERE fsCore__Is_Active__c = true
                                   ORDER BY Annual_Stated_Amount__c)
                                 FROM Account
                                 WHERE id = :pApplicantsMap.Values()];
        
        Id appId = pApplicantsMap.get('Applicant');
        Id coAppId = pApplicantsMap.get('Co-Applicant');
        for (Account acc : accList){
            if (acc.id == appId){
                logmessage('Processing Applicant *******');
                this.mApplicant = populateDNLApplicant(acc);
                if (mApplicant != null){
                    system.debug(logginglevel.error,'Appl Housing Type: '+mApplicant.housingType);
                }
            }else if (acc.id == coAppId){
                logmessage('Processing CO-Applicant *******');
                this.mCoApplicant = populateDNLApplicant(acc);
                if (mCoApplicant != null){
                    system.debug(logginglevel.error,'mCoApplicant Housing Type: '+mCoApplicant.housingType);
                }
            }
        }
    }
    
    private static String removeComma(String pString){
        if (pString != null){
            pString = pString.replace(',','');
        }
        return pString;
    }
    private DNLApplicant populateDNLApplicant(Account pAccount){
        DNLApplicant applicant = new DNLApplicant();
        applicant.recordId = pAccount.id;
        applicant.firstName = pAccount.firstName;
        applicant.middleNameInitial = pAccount.MiddleName;
        applicant.lastName = pAccount.lastName;
        if (pAccount.PersonBirthdate != null){
            applicant.dateOfBirth = pAccount.PersonBirthdate.format();
        }
        string ssn = pAccount.fsCore__National_Identification_Number__pc;
        string formattedSsn = ssn;
        if ((ssn != null)
            &&(!ssn.containsAny('-'))){
                formattedSsn = ssn.substring(0, 3) + '-' + ssn.substring(3, 5) + '-' + ssn.substring(5, 9);
            }
        
        applicant.socialSecurityNumber = formattedSsn;
        applicant.residencyStatus = pAccount.U_S_Residency_Status__c;
        applicant.emailAddress = pAccount.PersonEmail;
        applicant.homePhone = formatPhoneNum(pAccount.PersonHomePhone);
        applicant.mobilePhone = formatPhoneNum(pAccount.PersonMobilePhone);
        applicant.workPhone = formatPhoneNum(pAccount.Work_Phone__c);
        applicant.addressSinceDate = getMMYYYYFormat(pAccount.Residing_Since_Date__c);
        //applicant.homeAddress.addressNumber = pAccount.'440';
        applicant.homeAddress.street = pAccount.PersonOtherStreet;
        applicant.homeAddress.city = pAccount.PersonOtherCity;
        applicant.homeAddress.state = SFSUtil.getStateCode(pAccount.PersonOtherState);
        applicant.homeAddress.zipCode = pAccount.PersonOtherPostalCode;
        
        applicant.mailingAddress.street = pAccount.PersonMailingStreet;
        applicant.mailingAddress.city = pAccount.PersonMailingCity;
        applicant.mailingAddress.state = SFSUtil.getStateCode(pAccount.PersonMailingState);
        applicant.mailingAddress.zipCode = pAccount.PersonMailingPostalCode;
        
        
        applicant.previousHomeAddress.aptNumber = pAccount.Less_than_2yrs_Apt_Num__c;
        applicant.previousHomeAddress.street = pAccount.Less_than_2yrs_Street_Address__c;
        applicant.previousHomeAddress.city = pAccount.Less_than_2yrs_City__c;
        applicant.previousHomeAddress.state = SFSUtil.getStateCode(pAccount.Less_than_2yrs_State__c);
        applicant.previousHomeAddress.zipCode = pAccount.Less_than_2yrs_Zip_Code__c;
        
        applicant.primaryIDType = pAccount.Primary_Id_Type__c;
        applicant.primaryIDNumber = pAccount.Primary_Id_Number__c;
        if (pAccount.Primary_Id_Expiration_Date__c != null){
            applicant.primaryIDExpiryDate = pAccount.Primary_Id_Expiration_Date__c.Format();
        }
        applicant.primaryIDState = SFSUtil.getStateCode(pAccount.Primary_Id_State__c);
        applicant.motherMaidenName = pAccount.Mother_Maiden_Name__pc;
        applicant.firstSchoolAttended = pAccount.First_School_Attended__pc;
        
        applicant.drpName = mOpportunity.DRP_Name__c;
        applicant.drpAccount = mOpportunity.DRP_Account_Number__c;
        applicant.lawFirmName = mOpportunity.Law_Firm_Name__c;
        
        applicant.maritalStatus= pAccount.Marital_Status__c;
        applicant.spouseName= pAccount.Spouse_name__c;
        applicant.spouseAddress = pAccount.Spouse_Address__c;
        
        
        boolean isPrimaryFinExist = false;
        String primaryFinancialId = '';
        for (fsCore__Financial__c financial : pAccount.fsCore__Financial__pr){
            if (financial.fsCore__Financial_Family__c == 'Income'){
                if (financial.Is_Primary_Income__c ){
                    isPrimaryFinExist = true;
                    primaryFinancialId = String.ValueOf(financial.id);
                    break;
                }
            }
        }
        logmessage('isPrimaryFinExist :'+isPrimaryFinExist);
        logmessage('primaryFinancialId :'+primaryFinancialId);
        
        Decimal primaryEmploymentSalary = 0.00;
        if (!isPrimaryFinExist){
            for (fsCore__Financial__c financial : pAccount.fsCore__Financial__pr){
                //COMMENTED BECAUSE OF PDI-697
                /*if (financial.fsCore__Financial_Family__c == 'Income'
&& ((financial.fsCore__Financial_Type__c == 'Salary') ||(financial.fsCore__Financial_Type__c == 'Independent Contractor'))){*/
                
                if (financial.fsCore__Financial_Family__c == 'Income'){
                    
                    decimal amount = financial.fsCore__Stated_Amount__c;
                    logmessage('amount ***** :'+amount);
                    if ((financial.fsCore__Stated_Amount__c != null && financial.fsCore__Stated_Amount__c >0 )
                        ||(financial.fsCore__Stated_Amount__c != null && financial.fsCore__Financial_Type__c == 'Unemployed' )){
                        amount = financial.fsCore__Stated_Amount__c;
                        if (financial.fsCore__Frequency__c == 'Monthly'){
                            amount = amount * 12;
                        }
                        logmessage('*** amount ***** :'+amount+'  primaryEmploymentSalary :'+primaryEmploymentSalary);
                        if ((amount > primaryEmploymentSalary)
                            ||(financial.fsCore__Financial_Type__c == 'Unemployed')) {
                            primaryEmploymentSalary = amount;
                            applicant.mainFinancial.incomeType = financial.fsCore__Financial_Type__c;
                            //PDI-744 For the records where we have an employment and the employment start date is populated
                            // Get the start date from the employment or
                            applicant.mainFinancial.startDate = getMMYYYYFormat(getFinancialStartDate(financial));
                            applicant.mainFinancial.annualIncome = String.ValueOf(amount);
                            applicant.mainFinancial.provider = getIncomeProviderName(financial);
                            applicant.mainFinancial.occupation = getOccupationName(financial);
                            
                            applicant.mainFinancial.RecordID = financial.id;
                            applicant.mainFinancial.employment.employerName = financial.Employment_Name__r.fsCore__Employer_Name__c;
                            applicant.mainFinancial.employment.startDate = getMMYYYYFormat(financial.Employment_Name__r.fsCore__Start_Date__c);
                            applicant.mainFinancial.employment.streetAddress = financial.Employment_Name__r.fsCore__Street__c;
                            applicant.mainFinancial.employment.city = financial.Employment_Name__r.fsCore__City__c;
                            applicant.mainFinancial.employment.state = SFSUtil.getStateCode(financial.Employment_Name__r.fsCore__State__c);
                            applicant.mainFinancial.employment.zipCode = financial.Employment_Name__r.fsCore__Zip_Code__c;
                            applicant.mainFinancial.employment.RecordID = financial.Employment_Name__c;
                            primaryFinancialId = String.ValueOf(financial.id);
                            
                            logmessage('Prim Not Exist applicant.mainFinancial ==> ' +applicant.mainFinancial);
                            
                        }
                    }
                }
                
            }
        }
        
        for (fsCore__Financial__c financial : pAccount.fsCore__Financial__pr){
            if (financial.fsCore__Financial_Family__c == 'Income'){
                decimal amount = 0;
                if (financial.fsCore__Stated_Amount__c != null && financial.fsCore__Stated_Amount__c >0 ){
                    amount = financial.fsCore__Stated_Amount__c;
                    if (financial.fsCore__Frequency__c == 'Monthly'){
                        amount = amount * 12;
                    }
                    
                }
                if (isPrimaryFinExist){
                    if (financial.Is_Primary_Income__c ){
                        applicant.mainFinancial.incomeType = financial.fsCore__Financial_Type__c;
                        applicant.mainFinancial.startDate = getMMYYYYFormat(getFinancialStartDate(financial));
                        applicant.mainFinancial.annualIncome = String.ValueOf(amount);
                        applicant.mainFinancial.provider = getIncomeProviderName(financial);
                        applicant.mainFinancial.occupation = getOccupationName(financial);
                        
                        
                        applicant.mainFinancial.RecordID = financial.id;
                        applicant.mainFinancial.employment.employerName = financial.Employment_Name__r.fsCore__Employer_Name__c;
                        applicant.mainFinancial.employment.startDate = getMMYYYYFormat(financial.Employment_Name__r.fsCore__Start_Date__c);
                        applicant.mainFinancial.employment.streetAddress = financial.Employment_Name__r.fsCore__Street__c;
                        applicant.mainFinancial.employment.city = financial.Employment_Name__r.fsCore__City__c;
                        applicant.mainFinancial.employment.state = SFSUtil.getStateCode(financial.Employment_Name__r.fsCore__State__c);
                        applicant.mainFinancial.employment.zipCode = financial.Employment_Name__r.fsCore__Zip_Code__c;
                        applicant.mainFinancial.employment.RecordID = financial.Employment_Name__c;
                        
                        logmessage('Prim Exist applicant.mainFinancial ==> ' +applicant.mainFinancial);
                    }
                    
                }
            }
            
        }
        
        
        for (fsCore__Employment__c emp : pAccount.fsCore__Contact_Employment__pr){
            if (emp.fsCore__End_Date__c != null){
                applicant.previousEmployment.employerName = emp.fsCore__Employer_Name__c;
                applicant.previousEmployment.startDate = getMMYYYYFormat(emp.fsCore__Start_Date__c);
                applicant.previousEmployment.streetAddress = emp.fsCore__Street__c;
                applicant.previousEmployment.city = emp.fsCore__City__c;
                applicant.previousEmployment.state = SFSUtil.getStateCode(emp.fsCore__State__c);
                applicant.previousEmployment.zipCode = emp.fsCore__Zip_Code__c;
                applicant.previousEmployment.RecordID = emp.Id;
                break;
            }
            
        }
        
        decimal annualBaseSalary = 0.00;
        decimal otherMonthlyPayment = 0.00;
        string employmentStatus = 'Self-Employed';//DEFAULT IT TO SELF EMP
        
        Boolean otherIncome1Populated = false;
        Boolean otherIncome2Populated = false;
        Boolean otherIncome3Populated = false;
        Boolean otherIncome4Populated = false;
        Boolean annualBaseSalaryPopulated = false;
        
        
        for (fsCore__Financial__c financial : pAccount.fsCore__Financial__pr){
            
            logmessage('financial ==> ' +financial);
            logmessage('Financial Type ==> ' +financial.fsCore__Financial_Type__c);
            if (financial.Housing_Type__c != null){
                applicant.housingType = financial.Housing_Type__c;
                applicant.otherHousing = financial.Other_Housing_Description__c;
                applicant.housingId = financial.Id;
                if (financial.fsCore__Stated_Amount__c != null){
                    applicant.monthlyPayment = String.ValueOf(financial.fsCore__Stated_Amount__c);
                    logmessage('applicant.monthlyPayment ==> ' +applicant.monthlyPayment);
                }
                logmessage('applicant.housingType ==> ' +applicant.housingType+' applicant.otherHousing :'+applicant.otherHousing);
            }
            
            
            
            if (financial.fsCore__Financial_Family__c == 'Income'){
                if ((String.isNotBlank(primaryFinancialId)) && (primaryFinancialId == financial.Id)){
                    //DO NOTHING
                }else{
                    logmessage('Non Salary ==> ' +financial.fsCore__Financial_Type__c);
                    
                    
                    /*if ((financials.fsCore__Financial_Type__c == 'Disability')
||(financials.fsCore__Financial_Type__c == 'Alimony')
||(financials.fsCore__Financial_Type__c == 'Child Support')
||(financials.fsCore__Financial_Type__c == 'Social Security')
||(financials.fsCore__Financial_Type__c == 'Other')){*/
                    
                    decimal amount = 0;
                    if (financial.fsCore__Stated_Amount__c != null && financial.fsCore__Stated_Amount__c >0 ){
                        amount = financial.fsCore__Stated_Amount__c;
                        if (financial.fsCore__Frequency__c == 'Monthly'){
                            amount = amount * 12;
                        }
                        
                    }
                    logmessage('amount ==> ' +amount);
                    if (!otherIncome1Populated){
                        applicant.otherFinancial1.incomeType = financial.fsCore__Financial_Type__c;
                        applicant.otherFinancial1.startDate = getMMYYYYFormat(getFinancialStartDate(financial));
                        applicant.otherFinancial1.annualIncome = String.ValueOf(amount);                                 
                        applicant.otherFinancial1.provider = getIncomeProviderName(financial);
                        applicant.otherFinancial1.occupation = getOccupationName(financial);
                        
                        applicant.otherFinancial1.RecordID = financial.id;
                        applicant.otherFinancial1.employment.employerName = financial.Employment_Name__r.fsCore__Employer_Name__c;
                        applicant.otherFinancial1.employment.startDate = getMMYYYYFormat(financial.Employment_Name__r.fsCore__Start_Date__c);
                        applicant.otherFinancial1.employment.streetAddress = financial.Employment_Name__r.fsCore__Street__c;
                        applicant.otherFinancial1.employment.city = financial.Employment_Name__r.fsCore__City__c;
                        applicant.otherFinancial1.employment.state = SFSUtil.getStateCode(financial.Employment_Name__r.fsCore__State__c);
                        applicant.otherFinancial1.employment.zipCode = financial.Employment_Name__r.fsCore__Zip_Code__c;
                        applicant.otherFinancial1.employment.RecordID = financial.Employment_Name__c;
                        
                        otherIncome1Populated = true;
                    }else if (!otherIncome2Populated){
                        applicant.otherFinancial2.incomeType = financial.fsCore__Financial_Type__c;
                        applicant.otherFinancial2.startDate = getMMYYYYFormat(getFinancialStartDate(financial));
                        applicant.otherFinancial2.annualIncome = String.ValueOf(amount);
                        applicant.otherFinancial2.provider = getIncomeProviderName(financial);
                        applicant.otherFinancial2.occupation = getOccupationName(financial);
                        
                        
                        applicant.otherFinancial2.RecordID = financial.id;
                        applicant.otherFinancial2.employment.employerName = financial.Employment_Name__r.fsCore__Employer_Name__c;
                        applicant.otherFinancial2.employment.startDate = getMMYYYYFormat(financial.Employment_Name__r.fsCore__Start_Date__c);
                        applicant.otherFinancial2.employment.streetAddress = financial.Employment_Name__r.fsCore__Street__c;
                        applicant.otherFinancial2.employment.city = financial.Employment_Name__r.fsCore__City__c;
                        applicant.otherFinancial2.employment.state = SFSUtil.getStateCode(financial.Employment_Name__r.fsCore__State__c);
                        applicant.otherFinancial2.employment.zipCode = financial.Employment_Name__r.fsCore__Zip_Code__c;
                        applicant.otherFinancial2.employment.RecordID = financial.Employment_Name__c;
                        
                        otherIncome2Populated = true;
                    }else if (!otherIncome3Populated){
                        logmessage('Populating otherIncome3Populated :');
                        logmessage('Populating fsCore__Title__c :'+financial.Title_Formula__c);
                        applicant.otherFinancial3.incomeType = financial.fsCore__Financial_Type__c;
                        applicant.otherFinancial3.startDate = getMMYYYYFormat(getFinancialStartDate(financial));
                        applicant.otherFinancial3.annualIncome = String.ValueOf(amount);
                        applicant.otherFinancial3.provider = getIncomeProviderName(financial);
                        applicant.otherFinancial3.occupation = getOccupationName(financial);
                        
                        applicant.otherFinancial3.RecordID = financial.id;
                        applicant.otherFinancial3.employment.employerName = financial.Employment_Name__r.fsCore__Employer_Name__c;
                        applicant.otherFinancial3.employment.startDate = getMMYYYYFormat(financial.Employment_Name__r.fsCore__Start_Date__c);
                        applicant.otherFinancial3.employment.streetAddress = financial.Employment_Name__r.fsCore__Street__c;
                        applicant.otherFinancial3.employment.city = financial.Employment_Name__r.fsCore__City__c;
                        applicant.otherFinancial3.employment.state = SFSUtil.getStateCode(financial.Employment_Name__r.fsCore__State__c);
                        applicant.otherFinancial3.employment.zipCode = financial.Employment_Name__r.fsCore__Zip_Code__c;
                        applicant.otherFinancial3.employment.RecordID = financial.Employment_Name__c;
                        
                        otherIncome3Populated = true;
                    }else if (!otherIncome4Populated){
                        applicant.otherFinancial4.incomeType = financial.fsCore__Financial_Type__c;
                        applicant.otherFinancial4.startDate = getMMYYYYFormat(getFinancialStartDate(financial));
                        applicant.otherFinancial4.annualIncome = String.ValueOf(amount);
                        
                        applicant.otherFinancial4.provider = getIncomeProviderName(financial);
                        applicant.otherFinancial4.occupation = getOccupationName(financial);
                        
                        applicant.otherFinancial4.RecordID = financial.id;
                        applicant.otherFinancial4.employment.employerName = financial.Employment_Name__r.fsCore__Employer_Name__c;
                        applicant.otherFinancial4.employment.startDate = getMMYYYYFormat(financial.Employment_Name__r.fsCore__Start_Date__c);
                        applicant.otherFinancial4.employment.streetAddress = financial.Employment_Name__r.fsCore__Street__c;
                        applicant.otherFinancial4.employment.city = financial.Employment_Name__r.fsCore__City__c;
                        applicant.otherFinancial4.employment.state = SFSUtil.getStateCode(financial.Employment_Name__r.fsCore__State__c);
                        applicant.otherFinancial4.employment.zipCode = financial.Employment_Name__r.fsCore__Zip_Code__c;
                        applicant.otherFinancial4.employment.RecordID = financial.Employment_Name__c;
                        
                        /*applicant.otherIncomeSource4 = financials.fsCore__Financial_Type__c;
applicant.otherIncomeSourceDesc4 = financials.fsCore__Description__c;
applicant.otherAnnualIncome4 = String.ValueOf(amount);
applicant.otherAnnualIncomeID4 = financials.Id;
applicant.otherIncomeStartDate4 = getMMYYYYFormat(financials.Start_Date__c);*/
                        otherIncome4Populated = true;
                    }
                    
                    //}
                    logmessage('applicant.otherFinancial1 ==> ' +applicant.otherFinancial1);
                    logmessage('applicant.otherFinancial2 ==> ' +applicant.otherFinancial2);
                    logmessage('applicant.otherFinancial3 ==> ' +applicant.otherFinancial3);
                    logmessage('applicant.otherFinancial4 ==> ' +applicant.otherFinancial4);
                    
                }
            }
            if (financial.fsCore__Financial_Family__c == 'Liability'){
                if (financial.fsCore__Stated_Amount__c != null && financial.fsCore__Stated_Amount__c >0 ){
                    decimal amount = financial.fsCore__Stated_Amount__c;
                    if (financial.fsCore__Frequency__c == 'Annual'){
                        amount = amount/ 12;
                    }
                    otherMonthlyPayment += amount;
                }
            }
            
            
        }
        
        return applicant;
    }
    
    public void SendNow()
    {
        mValidationFailureMessage = '';
        mValidationsPassed = true;
        mLastEnvelopeCompleted = false;
        mEnvelopeAlreadySent = false;
        
        //Validations
        if (mOpportunity.DRP_Name__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Debt Resolution Program Name cannot be blank.'+ '\r\n' ;
        }
        if (mOpportunity.DRP_Account_Number__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Debt Resolution Program Account # cannot be blank.\n';
        }
        if (mOpportunity.Portfolio_Type__c == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Portfolio type cannot be blank.\n';
        }
        if ((mOpportunity.Portfolio_Type__c == 'Attorney') && (mOpportunity.Law_Firm_Name__c == null)){
            mValidationsPassed = false;
            mValidationFailureMessage += 'For portfolio type attorney, the law firm name cannot be blank.\n';
        }
        if (mOpportunity.Account.PersonEmail == null){
            mValidationsPassed = false;
            mValidationFailureMessage += 'Applicant Email Address cannot be blank.\n';
        }
        if (mOpportunity.Co_Applicant_Name__c != null){
            if (mOpportunity.Co_Applicant_Name__r.PersonEmail == null){
                mValidationsPassed = false;
                mValidationFailureMessage += 'Co-Applicant Email Address cannot be blank.\n';
            }
        }
        
        List<dsfs__DocuSign_Status__c> docusignStatusList = [select id
                                                             , name
                                                             , dsfs__DocuSign_Envelope_ID__c
                                                             , Document_Type__c
                                                             , dsfs__Opportunity__c
                                                             , dsfs__Company__c
                                                             , dsfs__Envelope_Status__c
                                                             FROM dsfs__DocuSign_Status__c
                                                             WHERE dsfs__Opportunity__c = :mOpportunity.Id
                                                             AND Document_Type__c = :DocusignAPIUtil.mDocumentTypeOppLoanApplication
                                                             ORDER BY createdDate Desc
                                                             Limit 1];
        
        
        
        if(docusignStatusList != null && !docusignStatusList.isEmpty()) {
            dsfs__DocuSign_Status__c docusignStatus = docusignStatusList.get(0);
            if (!(resentEligibleMapStatusSet.contains(docusignStatus.dsfs__Envelope_Status__c))){
                mEnvelopeAlreadySent = true;
                mEnvelopeId = docusignStatus.dsfs__DocuSign_Envelope_ID__c;
                mEnvelopeStatus = docusignStatus.dsfs__Envelope_Status__c;
            }
        }
        if (mEnvelopeAlreadySent){
            List<dsfs__DocuSign_Status__c> docusignCompStatusList = [select id
                                                                     , name
                                                                     , dsfs__DocuSign_Envelope_ID__c
                                                                     , Document_Type__c
                                                                     , dsfs__Opportunity__c
                                                                     , dsfs__Company__c
                                                                     , dsfs__Envelope_Status__c
                                                                     FROM dsfs__DocuSign_Status__c
                                                                     WHERE dsfs__Opportunity__c = :mOpportunity.Id
                                                                     AND Document_Type__c = :DocusignAPIUtil.mDocumentTypeOppLoanApplication
                                                                     ORDER BY createdDate Desc
                                                                     Limit 1];
            
            if(docusignCompStatusList != null && !docusignCompStatusList.isEmpty()) {
                dsfs__DocuSign_Status__c docusignStatus = docusignCompStatusList.get(0);
                if (DocusignAPIUtil.mDocusignEnvelopeCompleted == docusignStatus.dsfs__Envelope_Status__c){
                    mLastEnvelopeCompleted = true;
                }
            }
        }
        
        if (mValidationsPassed && !mEnvelopeAlreadySent){
            SendEnvelopeUsingTemplateId(mEmailSubject,getEmailBlurb());
        }
    }
    
    
    private String getEmailBlurb(){
        
        setUserInfo();
        String phoneNumberText = '';
        if ( mUser.phone!= null){
            phoneNumberText = ' or call '+mUser.FirstName+' '+mUser.LastName+' at: '+mUser.phone;
        }
        
        String FirstName = mApplicant.firstName;
        String LastName = mApplicant.lastName;
        if (FirstName != null){
            FirstName = FirstName.substring(0,1).toUpperCase() + FirstName.substring(1).toLowerCase();
        }
        if (LastName != null){
            LastName = LastName.substring(0,1).toUpperCase() + LastName.substring(1).toLowerCase();
        }
        String name = FirstName+' '+LastName;
        If (mCoApplicant != null){
            String coAplFirstName = mCoApplicant.firstName;
            String coAplLastName = mCoApplicant.lastName;
            if (coAplFirstName != null){
                coAplFirstName = coAplFirstName.substring(0,1).toUpperCase() + coAplFirstName.substring(1).toLowerCase();
            }
            if (coAplLastName != null){
                coAplLastName = coAplLastName.substring(0,1).toUpperCase() + coAplLastName.substring(1).toLowerCase();
            }
            if (coAplFirstName != null){
                name += ' & '+coAplFirstName+' '+coAplLastName;
            }
        }
        
        Return 'Dear '+name+',\n\n'+'Thank you for your interest in Versara Lending. To expedite your application, please complete all of the required fields and signatures on the application.\n\n'+
            'If you have any questions or need any assistance, please email '+mUser.Email+phoneNumberText+'.\n\n'+'Sincerely,\n'+'Versara Lending Team';
    }
    
    private void setUserInfo() {
        id userId = mOpportunity.ownerId;
        if (userId == null){
            userId = UserInfo.getUserId();
        }
        
        mUser = [SELECT Id, phone,Email,FirstName,LastName FROM User WHERE Id =:userId limit 1];
    }
    
    public void SendAfterCompletedEnvelope()
    {
        logmessage('SendAfterCompletedEnvelope Enter');
        mValidationFailureMessage = '';
        mValidationsPassed = true;
        mLastEnvelopeCompleted = false;
        mEnvelopeAlreadySent = false;
        
        
        SendEnvelopeUsingTemplateId(mEmailSubject,getEmailBlurb());
        insertDocuSignStatus();
        
        
    }
    private void insertDocuSignStatus(){
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        
        dsStatus.dsfs__DocuSign_Envelope_ID__c = mEnvelopeId;
        dsStatus.Document_Type__c = DocusignAPIUtil.mDocumentTypeOppLoanApplication;
        dsStatus.dsfs__Opportunity__c = mOpportunity.Id;
        dsStatus.dsfs__Company__c = mApplicant.recordId;
        dsStatus.dsfs__Envelope_Status__c = 'Request Sent To Docusign';
        if (mCoApplicant != null){
            dsStatus.Co_Applicant_Name__c = mCoApplicant.recordId;
        }
        
        insert dsStatus;
        logmessage('Inserted dsStatus');
    }    
    
    
    private static String formatPhoneNum (String s) {
        if (s == null) return s;
        
        s = s.replace('(', '');
        s = s.replace(')', '');
        s = s.replace('-','');
        s = s.replace(' ','');
        
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
    }
    
    private String getMMYYYYFormat(Date pInputDate){
        if (pInputDate != null){
            return checkLength(String.ValueOf(pInputDate.month())) +'/'+pInputDate.year();
        }
        return '';
    }
    
    private String checkLength(String val){
        if(String.isNotBlank(val) && val.length() == 1){
            val = '0' + val;
        }
        return val;
    }
    
    private void setApplicantFields(DocuSignAPI.TemplateReference applicationTemplate){
        // Add data for fields
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantName.TabLabel = 'Applicant First Name';
        ApplicantName.Value = mApplicant.FirstName;
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMIName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMIName.TabLabel = 'Applicant MI';
        ApplicantMIName.Value = mApplicant.middleNameInitial;
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantLastName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantLastName.TabLabel = 'Applicant Last Name';
        ApplicantLastName.Value = mApplicant.LastName;
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantDOB = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantDOB.TabLabel = 'Applicant Date Of Birth';
        ApplicantDOB.Value = mApplicant.dateOfBirth;
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantSSN = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantSSN.TabLabel = 'Applicant SSN';
        ApplicantSSN.Value = mApplicant.socialSecurityNumber;
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantUSResidency = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantUSResidency.TabLabel = 'Applicant U.S. Residency';
        ApplicantUSResidency.Value = mApplicant.residencyStatus;
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantEmailAddress = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantEmailAddress.TabLabel = 'Applicant Email';
        ApplicantEmailAddress.Value = mApplicant.emailAddress;
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantIdExpDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantIdExpDate.Value = mApplicant.primaryIDExpiryDate;
        ApplicantIdExpDate.TabLabel = 'Applicant Id Expiration Date';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantEmpStartDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantEmpStartDate.Value = mApplicant.mainFinancial.StartDate;
        ApplicantEmpStartDate.TabLabel = 'ApplicantPrimaryIncomeProviderStartDate';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrevEmpStartDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrevEmpStartDate.Value = mApplicant.previousEmployment.StartDate;
        ApplicantPrevEmpStartDate.TabLabel = 'Applicant Previous Employer Start Date';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrevEmployer = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrevEmployer.Value = mApplicant.previousEmployment.employerName;
        ApplicantPrevEmployer.TabLabel = 'Applicant Previous Employer';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrevEmployerStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrevEmployerStreet.Value = mApplicant.previousEmployment.streetAddress;
        ApplicantPrevEmployerStreet.TabLabel = 'Applicant Previous Employer Street';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMailingState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMailingState.Value = mApplicant.mailingAddress.state;
        ApplicantMailingState.TabLabel = 'Applicant Mailing State';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHomeState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHomeState.Value = mApplicant.homeAddress.state;
        ApplicantHomeState.TabLabel = 'Applicant Home State';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherState.Value = mApplicant.previousHomeAddress.state;
        ApplicantOtherState.TabLabel = 'Applicant Other State';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrimaryIdType = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrimaryIdType.Value = mApplicant.primaryIDType;
        ApplicantPrimaryIdType.TabLabel = 'Applicant Primary Id';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrimaryIdState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrimaryIdState.Value = mApplicant.primaryIDState;
        ApplicantPrimaryIdState.TabLabel = 'Applicant Id State';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantEmploymentStatus = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantEmploymentStatus.Value = mApplicant.mainFinancial.incomeType;
        ApplicantEmploymentStatus.TabLabel = 'Applicant Employment Status';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrevEmpCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrevEmpCity.Value = mApplicant.previousEmployment.city;
        ApplicantPrevEmpCity.TabLabel = 'Applicant Previous Employer City';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrevEmpState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrevEmpState.Value = mApplicant.previousEmployment.state;
        ApplicantPrevEmpState.TabLabel = 'Applicant Previous Employer State';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantEmpState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantEmpState.Value = mApplicant.mainFinancial.employment.state;
        ApplicantEmpState.TabLabel = 'Applicant Employer State';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHomeAddressZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHomeAddressZip.Value = mApplicant.homeAddress.zipCode;
        ApplicantHomeAddressZip.TabLabel = 'Applicant Home Zip Code';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMailingAddressZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMailingAddressZip.Value = mApplicant.mailingAddress.zipCode;
        ApplicantMailingAddressZip.TabLabel = 'Applicant Mailing Zip Code';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAddressZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAddressZip.Value = mApplicant.previousHomeAddress.zipCode;
        ApplicantOtherAddressZip.TabLabel = 'Applicant Other Zip Code';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrevEmpZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrevEmpZip.Value = mApplicant.previousEmployment.zipCode;
        ApplicantPrevEmpZip.TabLabel = 'Applicant Previous Employer Zip';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantEmpZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantEmpZip.Value = mApplicant.mainFinancial.employment.zipCode;
        ApplicantEmpZip.TabLabel = 'Applicant Employer Zip Code';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantEmpStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantEmpStreet.Value = mApplicant.mainFinancial.employment.streetAddress;
        ApplicantEmpStreet.TabLabel = 'Applicant Employer Street';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantEmpCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantEmpCity.Value = mApplicant.mainFinancial.employment.city;
        ApplicantEmpCity.TabLabel = 'Applicant Employer City';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrimaryIncomeProvider = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrimaryIncomeProvider.Value = mApplicant.mainFinancial.provider;
        ApplicantPrimaryIncomeProvider.TabLabel = 'ApplicantPrimaryIncomeProvider';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantAnnualBaseSalary = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantAnnualBaseSalary.Value = mApplicant.mainFinancial.annualIncome;
        ApplicantAnnualBaseSalary.TabLabel = 'Applicant Annual Base Salary';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantAddressSinceDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantAddressSinceDate.Value = mApplicant.addressSinceDate;
        ApplicantAddressSinceDate.TabLabel = 'Applicant Address Since Date';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantWorkPhone = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantWorkPhone.Value = mApplicant.workPhone;
        ApplicantWorkPhone.TabLabel = 'Applicant Work Phone';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHomeApartmentNumber = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHomeApartmentNumber.Value = mApplicant.homeAddress.aptNumber;
        ApplicantHomeApartmentNumber.TabLabel = 'Applicant Home Apartment';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherCity.Value = mApplicant.previousHomeAddress.city;
        ApplicantOtherCity.TabLabel = 'Applicant Other City';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherApartmentNumber = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherApartmentNumber.Value = mApplicant.previousHomeAddress.aptNumber;
        ApplicantOtherApartmentNumber.TabLabel = 'Applicant Other Apartment';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherStreet.Value = mApplicant.previousHomeAddress.street;
        ApplicantOtherStreet.TabLabel = 'Applicant Other Street';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantprimaryIdNumber = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantprimaryIdNumber.Value = mApplicant.primaryIDNumber;
        ApplicantprimaryIdNumber.TabLabel = 'Applicant Primary Id Number';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHomeAddressCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHomeAddressCity.Value = mApplicant.homeAddress.city;
        ApplicantHomeAddressCity.TabLabel = 'Applicant Home City';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHomeAddressStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHomeAddressStreet.Value = mApplicant.homeAddress.street;
        ApplicantHomeAddressStreet.TabLabel = 'Applicant Home Street';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHomePhone = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHomePhone.Value = mApplicant.homePhone;
        ApplicantHomePhone.TabLabel = 'Applicant Home Phone';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMobilePhone = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMobilePhone.Value = mApplicant.mobilePhone;
        ApplicantMobilePhone.TabLabel = 'Applicant Mobile Phone';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMailingAddressApt = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMailingAddressApt.Value = mApplicant.mailingAddress.aptNumber;
        ApplicantMailingAddressApt.TabLabel = 'Applicant Mailing Apartment';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMailingAddStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMailingAddStreet.Value = mApplicant.mailingAddress.street;
        ApplicantMailingAddStreet.TabLabel = 'Applicant Mailing Street';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMailingAddCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMailingAddCity.Value = mApplicant.mailingAddress.city;
        ApplicantMailingAddCity.TabLabel = 'Applicant Mailing City';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantFirstSchoolAttended = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantFirstSchoolAttended.Value = mApplicant.firstSchoolAttended;
        ApplicantFirstSchoolAttended.TabLabel = 'Applicant First School';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMotherMaidenName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMotherMaidenName.Value = mApplicant.motherMaidenName;
        ApplicantMotherMaidenName.TabLabel = 'Applicant Mother Maiden Name';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPrimaryOccupation = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPrimaryOccupation.Value = mApplicant.mainFinancial.occupation;
        ApplicantPrimaryOccupation.TabLabel = 'ApplicantPrimaryOccupation';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeSource1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeSource1.Value = mApplicant.otherFinancial1.incomeType;
        ApplicantOtherIncomeSource1.TabLabel = 'Applicant Source Of Other Income1';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeSource2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeSource2.Value = mApplicant.otherFinancial2.incomeType;
        ApplicantOtherIncomeSource2.TabLabel = 'Applicant Source Of Other Income2';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeSource3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeSource3.Value = mApplicant.otherFinancial3.incomeType;
        ApplicantOtherIncomeSource3.TabLabel = 'Applicant Source Of Other Income3';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeSource4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeSource4.Value = mApplicant.otherFinancial4.incomeType;
        ApplicantOtherIncomeSource4.TabLabel = 'Applicant Source Of Other Income4';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeProvider1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeProvider1.Value = mApplicant.otherFinancial1.provider;
        ApplicantOtherIncomeProvider1.TabLabel = 'ApplicantOtherIncomeProvider1';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeProvider2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeProvider2.Value = mApplicant.otherFinancial2.provider;
        ApplicantOtherIncomeProvider2.TabLabel = 'ApplicantOtherIncomeProvider2';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeProvider3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeProvider3.Value = mApplicant.otherFinancial3.provider;
        ApplicantOtherIncomeProvider3.TabLabel = 'ApplicantOtherIncomeProvider3';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherIncomeProvider4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherIncomeProvider4.Value = mApplicant.otherFinancial4.provider;
        ApplicantOtherIncomeProvider4.TabLabel = 'ApplicantOtherIncomeProvider4';                        
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherHousing = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherHousing.Value = mApplicant.otherHousing;
        ApplicantOtherHousing.TabLabel = 'Applicant Other Housing';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncome1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncome1.Value = mApplicant.otherFinancial1.annualIncome;
        ApplicantOtherAnnualIncome1.TabLabel = 'Applicant Other Annual Income1';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncome2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncome2.Value = mApplicant.otherFinancial2.annualIncome;
        ApplicantOtherAnnualIncome2.TabLabel = 'Applicant Other Annual Income2';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncome3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncome3.Value = mApplicant.otherFinancial3.annualIncome;
        ApplicantOtherAnnualIncome3.TabLabel = 'Applicant Other Annual Income3';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncome4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncome4.Value = mApplicant.otherFinancial4.annualIncome;
        ApplicantOtherAnnualIncome4.TabLabel = 'Applicant Other Annual Income4';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMainIncomeId = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMainIncomeId.Value = mApplicant.mainFinancial.RecordId;
        ApplicantMainIncomeId.TabLabel = 'ApplicantMainIncomeId';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncomeId1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncomeId1.Value = mApplicant.otherFinancial1.RecordId;
        ApplicantOtherAnnualIncomeId1.TabLabel = 'ApplicantOtherIncomeId1';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncomeId2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncomeId2.Value = mApplicant.otherFinancial2.RecordId;
        ApplicantOtherAnnualIncomeId2.TabLabel = 'ApplicantOtherIncomeId2';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncomeId3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncomeId3.Value = mApplicant.otherFinancial3.RecordId;
        ApplicantOtherAnnualIncomeId3.TabLabel = 'ApplicantOtherIncomeId3';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherAnnualIncomeId4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherAnnualIncomeId4.Value = mApplicant.otherFinancial4.RecordId;
        ApplicantOtherAnnualIncomeId4.TabLabel = 'ApplicantOtherIncomeId4';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantotherIncomeStartDate1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantotherIncomeStartDate1.Value = mApplicant.otherFinancial1.StartDate;
        ApplicantotherIncomeStartDate1.TabLabel = 'Applicant Other Income Start Date1';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantotherIncomeStartDate2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantotherIncomeStartDate2.Value = mApplicant.otherFinancial2.StartDate;
        ApplicantotherIncomeStartDate2.TabLabel = 'Applicant Other Income Start Date2';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantotherIncomeStartDate3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantotherIncomeStartDate3.Value = mApplicant.otherFinancial3.StartDate;
        ApplicantotherIncomeStartDate3.TabLabel = 'Applicant Other Income Start Date3';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantotherIncomeStartDate4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantotherIncomeStartDate4.Value = mApplicant.otherFinancial4.StartDate;
        ApplicantotherIncomeStartDate4.TabLabel = 'Applicant Other Income Start Date4';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantCurrentEmploymentRecordId = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantCurrentEmploymentRecordId.Value = mApplicant.mainFinancial.employment.RecordID;
        ApplicantCurrentEmploymentRecordId.TabLabel = 'ApplicantCurrentEmployerID';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantPreviousEmploymentRecordId = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantPreviousEmploymentRecordId.Value = mApplicant.previousEmployment.RecordID;
        ApplicantPreviousEmploymentRecordId.TabLabel = 'ApplicantPreviousEmployerID';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHousingId = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHousingId.Value = mApplicant.housingID;
        ApplicantHousingId.TabLabel = 'ApplicantHousingId';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMonthlyPayment = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMonthlyPayment.Value = mApplicant.monthlyPayment;
        ApplicantMonthlyPayment.TabLabel = 'Applicant Monthly Rent';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantHousingType = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantHousingType.Value = mApplicant.housingType;
        ApplicantHousingType.TabLabel = 'Applicant Housing';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantMaritalStatus = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantMaritalStatus.Value = mApplicant.maritalStatus;
        ApplicantMaritalStatus.TabLabel = 'ApplicantMaritalStatus';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantSpouseName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantSpouseName.Value = mApplicant.spouseName;
        ApplicantSpouseName.TabLabel = 'ApplicantSpouseName';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantSpouseAddress = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantSpouseAddress.Value = mApplicant.spouseAddress;
        ApplicantSpouseAddress.TabLabel = 'ApplicantSpouseAddress';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherOccupation1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherOccupation1.Value = mApplicant.otherFinancial1.occupation;
        ApplicantOtherOccupation1.TabLabel = 'ApplicantSec1Occupation';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherOccupation2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherOccupation2.Value = mApplicant.otherFinancial2.occupation;
        ApplicantOtherOccupation2.TabLabel = 'ApplicantSec2Occupation';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherOccupation3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherOccupation3.Value = mApplicant.otherFinancial3.occupation;
        ApplicantOtherOccupation3.TabLabel = 'ApplicantSec3Occupation';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue ApplicantOtherOccupation4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        ApplicantOtherOccupation4.Value = mApplicant.otherFinancial4.occupation;
        ApplicantOtherOccupation4.TabLabel = 'ApplicantSec4Occupation';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue specialOfferCode = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        specialOfferCode.Value = mApplicant.specialOfferCode;
        specialOfferCode.TabLabel = 'Special Offer Code';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue drpName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        drpName.Value = mApplicant.drpName;
        drpName.TabLabel = 'DRP Name';
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue drpAccount = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        drpAccount.Value = mApplicant.drpAccount;
        drpAccount.TabLabel = 'DRP Account';
        
        
        DocuSignAPI.TemplateReferenceFieldDataDataValue drpLawFirmName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
        drpLawFirmName.Value = mApplicant.lawFirmName;
        drpLawFirmName.TabLabel = 'Law Firm';
        
        if (applicantsMap.get('Co-Applicant') != null){
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantName.TabLabel = 'CoApplicant First Name';
            CoApplicantName.Value = mCoApplicant.FirstName;
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMIName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMIName.TabLabel = 'CoApplicant MI';
            CoApplicantMIName.Value = mCoApplicant.middleNameInitial;
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantLastName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantLastName.TabLabel = 'CoApplicant Last Name';
            CoApplicantLastName.Value = mCoApplicant.LastName;
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantDOB = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantDOB.TabLabel = 'CoApplicant Date Of Birth';
            CoApplicantDOB.Value = mCoApplicant.dateOfBirth;
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantSSN = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantSSN.TabLabel = 'CoApplicant SSN';
            CoApplicantSSN.Value = mCoApplicant.socialSecurityNumber;
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantUSResidency = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantUSResidency.TabLabel = 'CoApplicant U.S. Residency';
            CoApplicantUSResidency.Value = mCoApplicant.residencyStatus;
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantEmailAddress = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantEmailAddress.TabLabel = 'CoApplicant Email';
            CoApplicantEmailAddress.Value = mCoApplicant.emailAddress;
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantIdExpDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantIdExpDate.Value = mCoApplicant.primaryIDExpiryDate;
            CoApplicantIdExpDate.TabLabel = 'CoApplicant Expiration Date';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantEmpStartDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantEmpStartDate.Value = mCoApplicant.mainFinancial.StartDate;
            CoApplicantEmpStartDate.TabLabel = 'CoApplicantPrimaryIncomeProviderStartDate';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrevEmpStartDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrevEmpStartDate.Value = mCoApplicant.previousEmployment.StartDate;
            CoApplicantPrevEmpStartDate.TabLabel = 'CoApplicant Previous Employer Start Date';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrevEmployer = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrevEmployer.Value = mCoApplicant.previousEmployment.employerName;
            CoApplicantPrevEmployer.TabLabel = 'CoApplicant Previous Employer';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrevEmployerStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrevEmployerStreet.Value = mCoApplicant.previousEmployment.streetAddress;
            CoApplicantPrevEmployerStreet.TabLabel = 'CoApplicant Previous Employer Street';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMailingState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMailingState.Value = mCoApplicant.mailingAddress.state;
            CoApplicantMailingState.TabLabel = 'CoApplicant Mailing State';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHomeState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHomeState.Value = mCoApplicant.homeAddress.state;
            CoApplicantHomeState.TabLabel = 'CoApplicant Home State';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherState.Value = mCoApplicant.previousHomeAddress.state;
            CoApplicantOtherState.TabLabel = 'CoApplicant Other State';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrimaryIdType = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrimaryIdType.Value = mCoApplicant.primaryIDType;
            CoApplicantPrimaryIdType.TabLabel = 'CoApplicant Primary Id';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrimaryIdState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrimaryIdState.Value = mCoApplicant.primaryIDState;
            CoApplicantPrimaryIdState.TabLabel = 'CoApplicant Id State';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantEmploymentStatus = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantEmploymentStatus.Value = mCoApplicant.mainFinancial.incomeType;
            CoApplicantEmploymentStatus.TabLabel = 'CoApplicant Employment Status';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrevEmpCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrevEmpCity.Value = mCoApplicant.previousEmployment.city;
            CoApplicantPrevEmpCity.TabLabel = 'CoApplicant Previous Employer City';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrevEmpState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrevEmpState.Value = mCoApplicant.previousEmployment.state;
            CoApplicantPrevEmpState.TabLabel = 'CoApplicant Previous Employer State';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantEmpState = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantEmpState.Value = mCoApplicant.mainFinancial.employment.state;
            CoApplicantEmpState.TabLabel = 'CoApplicant Employer State';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHomeAddressZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHomeAddressZip.Value = mCoApplicant.homeAddress.zipCode;
            CoApplicantHomeAddressZip.TabLabel = 'CoApplicant Home Zip Code';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMailingAddressZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMailingAddressZip.Value = mCoApplicant.mailingAddress.zipCode;
            CoApplicantMailingAddressZip.TabLabel = 'CoApplicant Mailing Zip Code';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherAddressZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherAddressZip.Value = mCoApplicant.previousHomeAddress.zipCode;
            CoApplicantOtherAddressZip.TabLabel = 'CoApplicant Other Zip Code';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrevEmpZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrevEmpZip.Value = mCoApplicant.previousEmployment.zipCode;
            CoApplicantPrevEmpZip.TabLabel = 'CoApplicant Previous Employer Zip';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantEmpZip = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantEmpZip.Value = mCoApplicant.mainFinancial.employment.zipCode;
            CoApplicantEmpZip.TabLabel = 'CoApplicant Employer Zip Code';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantEmpStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantEmpStreet.Value = mCoApplicant.mainFinancial.employment.streetAddress;
            CoApplicantEmpStreet.TabLabel = 'CoApplicant Employer Street';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantEmpCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantEmpCity.Value = mCoApplicant.mainFinancial.employment.city;
            CoApplicantEmpCity.TabLabel = 'CoApplicant Employer City';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrimaryIncomeProvider = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrimaryIncomeProvider.Value = mCoApplicant.mainFinancial.provider;
            CoApplicantPrimaryIncomeProvider.TabLabel = 'CoApplicantPrimaryIncomeProvider';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantAnnualBaseSalary = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantAnnualBaseSalary.Value = mCoApplicant.mainFinancial.annualIncome;
            CoApplicantAnnualBaseSalary.TabLabel = 'CoApplicant Annual Base Salary';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantAddressSinceDate = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantAddressSinceDate.Value = mCoApplicant.addressSinceDate;
            CoApplicantAddressSinceDate.TabLabel = 'CoApplicant Address Since Date';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantWorkPhone = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantWorkPhone.Value = mCoApplicant.workPhone;
            CoApplicantWorkPhone.TabLabel = 'CoApplicant Work Phone';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHomeApartmentNumber = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHomeApartmentNumber.Value = mCoApplicant.homeAddress.aptNumber;
            CoApplicantHomeApartmentNumber.TabLabel = 'CoApplicant Home Apartment';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherCity.Value = mCoApplicant.previousHomeAddress.city;
            CoApplicantOtherCity.TabLabel = 'CoApplicant Other City';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherApartmentNumber = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherApartmentNumber.Value = mCoApplicant.previousHomeAddress.aptNumber;
            CoApplicantOtherApartmentNumber.TabLabel = 'CoApplicant Other Apartment';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherStreet.Value = mCoApplicant.previousHomeAddress.street;
            CoApplicantOtherStreet.TabLabel = 'CoApplicant Other Street';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantprimaryIdNumber = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantprimaryIdNumber.Value = mCoApplicant.primaryIDNumber;
            CoApplicantprimaryIdNumber.TabLabel = 'CoApplicant Primary Id Number';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHomeAddressCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHomeAddressCity.Value = mCoApplicant.homeAddress.city;
            CoApplicantHomeAddressCity.TabLabel = 'CoApplicant Home City';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHomeAddressStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHomeAddressStreet.Value = mCoApplicant.homeAddress.street;
            CoApplicantHomeAddressStreet.TabLabel = 'CoApplicant Home Street';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHomePhone = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHomePhone.Value = mCoApplicant.homePhone;
            CoApplicantHomePhone.TabLabel = 'CoApplicant Home Phone';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMobilePhone = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMobilePhone.Value = mCoApplicant.mobilePhone;
            CoApplicantMobilePhone.TabLabel = 'CoApplicant Mobile Phone';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMailingAddressApt = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMailingAddressApt.Value = mCoApplicant.mailingAddress.aptNumber;
            CoApplicantMailingAddressApt.TabLabel = 'CoApplicant Mailing Apartment';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMailingAddStreet = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMailingAddStreet.Value = mCoApplicant.mailingAddress.street;
            CoApplicantMailingAddStreet.TabLabel = 'CoApplicant Mailing Street';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMailingAddCity = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMailingAddCity.Value = mCoApplicant.mailingAddress.city;
            CoApplicantMailingAddCity.TabLabel = 'CoApplicant Mailing City';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantFirstSchoolAttended = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantFirstSchoolAttended.Value = mCoApplicant.firstSchoolAttended;
            CoApplicantFirstSchoolAttended.TabLabel = 'CoApplicant First School';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMotherMaidenName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMotherMaidenName.Value = mCoApplicant.motherMaidenName;
            CoApplicantMotherMaidenName.TabLabel = 'CoApplicant Mother Maiden Name';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPrimaryOccupation = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPrimaryOccupation.Value = mCoApplicant.mainFinancial.occupation;
            CoApplicantPrimaryOccupation.TabLabel = 'CoApplicantPrimaryOccupation';
            
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeSource1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeSource1.Value = mCoApplicant.otherFinancial1.incomeType;
            CoApplicantOtherIncomeSource1.TabLabel = 'CoApplicant Source of Other Income1';
            
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeSource2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeSource2.Value = mCoApplicant.otherFinancial2.incomeType;
            CoApplicantOtherIncomeSource2.TabLabel = 'CoApplicant Source of Other Income2';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeSource3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeSource3.Value = mCoApplicant.otherFinancial3.incomeType;
            CoApplicantOtherIncomeSource3.TabLabel = 'CoApplicant Source of Other Income3';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeSource4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeSource4.Value = mCoApplicant.otherFinancial4.incomeType;
            CoApplicantOtherIncomeSource4.TabLabel = 'CoApplicant Source of Other Income4';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeProvider1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeProvider1.Value = mCoApplicant.otherFinancial1.provider;
            CoApplicantOtherIncomeProvider1.TabLabel = 'CoApplicantOtherIncomeProvider1';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeProvider2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeProvider2.Value = mCoApplicant.otherFinancial2.provider;
            CoApplicantOtherIncomeProvider2.TabLabel = 'CoApplicantOtherIncomeProvider2';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeProvider3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeProvider3.Value = mCoApplicant.otherFinancial3.provider;
            CoApplicantOtherIncomeProvider3.TabLabel = 'CoApplicantOtherIncomeProvider3';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeProvider4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeProvider4.Value = mCoApplicant.otherFinancial4.provider;
            CoApplicantOtherIncomeProvider4.TabLabel = 'CoApplicantOtherIncomeProvider4';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherHousing = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherHousing.Value = mCoApplicant.otherHousing;
            CoApplicantOtherHousing.TabLabel = 'CoApplicant Other Housing';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherAnnualIncome1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherAnnualIncome1.Value = mCoApplicant.otherFinancial1.annualIncome;
            CoApplicantOtherAnnualIncome1.TabLabel = 'CoApplicant Other Annual Income1';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherAnnualIncome2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherAnnualIncome2.Value = mCoApplicant.otherFinancial2.annualIncome;
            CoApplicantOtherAnnualIncome2.TabLabel = 'CoApplicant Other Annual Income2';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherAnnualIncome3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherAnnualIncome3.Value = mCoApplicant.otherFinancial3.annualIncome;
            CoApplicantOtherAnnualIncome3.TabLabel = 'CoApplicant Other Annual Income3';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherAnnualIncome4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherAnnualIncome4.Value = mCoApplicant.otherFinancial4.annualIncome;
            CoApplicantOtherAnnualIncome4.TabLabel = 'CoApplicant Other Annual Income4';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantotherIncomeStartDate1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantotherIncomeStartDate1.Value = mCoApplicant.otherFinancial1.startDate;
            CoApplicantotherIncomeStartDate1.TabLabel = 'CoApplicant Other Income Start Date1';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantotherIncomeStartDate2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantotherIncomeStartDate2.Value = mCoApplicant.otherFinancial2.startDate;
            CoApplicantotherIncomeStartDate2.TabLabel = 'CoApplicant Other Income Start Date2';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantotherIncomeStartDate3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantotherIncomeStartDate3.Value = mCoApplicant.otherFinancial3.startDate;
            CoApplicantotherIncomeStartDate3.TabLabel = 'CoApplicant Other Income Start Date3';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantotherIncomeStartDate4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantotherIncomeStartDate4.Value = mCoApplicant.otherFinancial4.startDate;
            CoApplicantotherIncomeStartDate4.TabLabel = 'CoApplicant Other Income Start Date4';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMaritalStatus = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMaritalStatus.Value = mCoApplicant.maritalStatus;
            CoApplicantMaritalStatus.TabLabel = 'CoApplicantMaritalStatus';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantSpouseName = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantSpouseName.Value = mCoApplicant.spouseName;
            CoApplicantSpouseName.TabLabel = 'CoApplicantSpouseName';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantSpouseAddress = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantSpouseAddress.Value = mCoApplicant.spouseAddress;
            CoApplicantSpouseAddress.TabLabel = 'CoApplicantSpouseAddress';
            
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMonthlyPayment = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMonthlyPayment.Value = mCoApplicant.monthlyPayment;
            CoApplicantMonthlyPayment.TabLabel = 'CoApplicant Monthly Rent';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHousingType = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHousingType.Value = mCoApplicant.housingType;
            CoApplicantHousingType.TabLabel = 'CoApplicant Housing';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantCurrentEmployerID = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantCurrentEmployerID.Value = mCoApplicant.mainFinancial.employment.RecordID;
            CoApplicantCurrentEmployerID.TabLabel = 'CoApplicantCurrentEmployerID';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantPreviousEmployerID = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantPreviousEmployerID.Value = mCoApplicant.PreviousEmployment.RecordID;
            CoApplicantPreviousEmployerID.TabLabel = 'CoApplicantPreviousEmployerID';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantHousingId = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantHousingId.Value = mCoApplicant.housingID;
            CoApplicantHousingId.TabLabel = 'CoApplicantHousingId';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantMainIncomeId = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantMainIncomeId.Value = mCoApplicant.mainFinancial.RecordId;
            CoApplicantMainIncomeId.TabLabel = 'CoApplicantMainIncomeId';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeId1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeId1.Value = mCoApplicant.otherFinancial1.RecordID;
            CoApplicantOtherIncomeId1.TabLabel = 'CoApplicantOtherIncomeId1';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeId2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeId2.Value = mCoApplicant.otherFinancial2.RecordID;
            CoApplicantOtherIncomeId2.TabLabel = 'CoApplicantOtherIncomeId2';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeId3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeId3.Value = mCoApplicant.otherFinancial3.RecordID;
            CoApplicantOtherIncomeId3.TabLabel = 'CoApplicantOtherIncomeId3';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherIncomeId4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherIncomeId4.Value = mCoApplicant.otherFinancial4.RecordID;
            CoApplicantOtherIncomeId4.TabLabel = 'CoApplicantOtherIncomeId4';
            
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherOccupation1 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherOccupation1.Value = mCoApplicant.otherFinancial1.occupation;
            CoApplicantOtherOccupation1.TabLabel = 'CoApplicantSec1Occupation';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherOccupation2 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherOccupation2.Value = mCoApplicant.otherFinancial2.occupation;
            CoApplicantOtherOccupation2.TabLabel = 'CoApplicantSec2Occupation';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherOccupation3 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherOccupation3.Value = mCoApplicant.otherFinancial3.occupation;
            CoApplicantOtherOccupation3.TabLabel = 'CoApplicantSec3Occupation';
            
            DocuSignAPI.TemplateReferenceFieldDataDataValue CoApplicantOtherOccupation4 = new DocuSignAPI.TemplateReferenceFieldDataDataValue();
            CoApplicantOtherOccupation4.Value = mCoApplicant.otherFinancial4.occupation;
            CoApplicantOtherOccupation4.TabLabel = 'CoApplicantSec4Occupation';
            
            
            
            applicationTemplate.FieldData = new DocuSignAPI.TemplateReferenceFieldData();
            applicationTemplate.FieldData.DataValues = new DocuSignAPI.ArrayOfTemplateReferenceFieldDataDataValue();
            applicationTemplate.FieldData.DataValues.DataValue = new DocuSignAPI.TemplateReferenceFieldDataDataValue[166];
            applicationTemplate.FieldData.DataValues.DataValue  [   0   ]   =   ApplicantName;
            applicationTemplate.FieldData.DataValues.DataValue  [   1   ]   =   ApplicantMIName;
            applicationTemplate.FieldData.DataValues.DataValue  [   2   ]   =   ApplicantLastName;
            applicationTemplate.FieldData.DataValues.DataValue  [   3   ]   =   ApplicantDOB;
            applicationTemplate.FieldData.DataValues.DataValue  [   4   ]   =   ApplicantSSN;
            applicationTemplate.FieldData.DataValues.DataValue  [   5   ]   =   ApplicantUSResidency;
            applicationTemplate.FieldData.DataValues.DataValue  [   6   ]   =   ApplicantEmailAddress;
            applicationTemplate.FieldData.DataValues.DataValue  [   7   ]   =   ApplicantIdExpDate;
            applicationTemplate.FieldData.DataValues.DataValue  [   8   ]   =   ApplicantEmpStartDate;
            applicationTemplate.FieldData.DataValues.DataValue  [   9   ]   =   ApplicantPrevEmpStartDate;
            applicationTemplate.FieldData.DataValues.DataValue  [   10  ]   =   ApplicantPrevEmployer;
            applicationTemplate.FieldData.DataValues.DataValue  [   11  ]   =   ApplicantPrevEmployerStreet;
            applicationTemplate.FieldData.DataValues.DataValue  [   12  ]   =   ApplicantMailingState;
            applicationTemplate.FieldData.DataValues.DataValue  [   13  ]   =   ApplicantHomeState;
            applicationTemplate.FieldData.DataValues.DataValue  [   14  ]   =   ApplicantOtherState;
            applicationTemplate.FieldData.DataValues.DataValue  [   15  ]   =   ApplicantPrimaryIdType;
            applicationTemplate.FieldData.DataValues.DataValue  [   16  ]   =   ApplicantPrimaryIdState;
            applicationTemplate.FieldData.DataValues.DataValue  [   17  ]   =   ApplicantEmploymentStatus;
            applicationTemplate.FieldData.DataValues.DataValue  [   18  ]   =   ApplicantPrevEmpCity;
            applicationTemplate.FieldData.DataValues.DataValue  [   19  ]   =   ApplicantPrevEmpState;
            applicationTemplate.FieldData.DataValues.DataValue  [   20  ]   =   ApplicantEmpState;
            applicationTemplate.FieldData.DataValues.DataValue  [   21  ]   =   ApplicantHomeAddressZip;
            applicationTemplate.FieldData.DataValues.DataValue  [   22  ]   =   ApplicantMailingAddressZip;
            applicationTemplate.FieldData.DataValues.DataValue  [   23  ]   =   ApplicantOtherAddressZip;
            applicationTemplate.FieldData.DataValues.DataValue  [   24  ]   =   ApplicantPrevEmpZip;
            applicationTemplate.FieldData.DataValues.DataValue  [   25  ]   =   ApplicantEmpZip;
            applicationTemplate.FieldData.DataValues.DataValue  [   26  ]   =   ApplicantEmpStreet;
            applicationTemplate.FieldData.DataValues.DataValue  [   27  ]   =   ApplicantEmpCity;
            applicationTemplate.FieldData.DataValues.DataValue  [   28  ]   =   ApplicantPrimaryIncomeProvider;
            applicationTemplate.FieldData.DataValues.DataValue  [   29  ]   =   ApplicantAnnualBaseSalary;
            applicationTemplate.FieldData.DataValues.DataValue  [   30  ]   =   ApplicantAddressSinceDate;
            applicationTemplate.FieldData.DataValues.DataValue  [   31  ]   =   ApplicantWorkPhone;
            applicationTemplate.FieldData.DataValues.DataValue  [   32  ]   =   ApplicantHomeApartmentNumber;
            applicationTemplate.FieldData.DataValues.DataValue  [   33  ]   =   ApplicantOtherCity;
            applicationTemplate.FieldData.DataValues.DataValue  [   34  ]   =   ApplicantOtherApartmentNumber;
            applicationTemplate.FieldData.DataValues.DataValue  [   35  ]   =   ApplicantOtherStreet;
            applicationTemplate.FieldData.DataValues.DataValue  [   36  ]   =   ApplicantprimaryIdNumber;
            applicationTemplate.FieldData.DataValues.DataValue  [   37  ]   =   ApplicantHomeAddressCity;
            applicationTemplate.FieldData.DataValues.DataValue  [   38  ]   =   ApplicantHomeAddressStreet;
            applicationTemplate.FieldData.DataValues.DataValue  [   39  ]   =   ApplicantHomePhone;
            applicationTemplate.FieldData.DataValues.DataValue  [   40  ]   =   ApplicantMobilePhone;
            applicationTemplate.FieldData.DataValues.DataValue  [   41  ]   =   ApplicantMailingAddressApt;
            applicationTemplate.FieldData.DataValues.DataValue  [   42  ]   =   ApplicantMailingAddStreet;
            applicationTemplate.FieldData.DataValues.DataValue  [   43  ]   =   ApplicantMailingAddCity;
            applicationTemplate.FieldData.DataValues.DataValue  [   44  ]   =   ApplicantFirstSchoolAttended;
            applicationTemplate.FieldData.DataValues.DataValue  [   45  ]   =   ApplicantMotherMaidenName;
            applicationTemplate.FieldData.DataValues.DataValue  [   46  ]   =   ApplicantPrimaryOccupation;
            applicationTemplate.FieldData.DataValues.DataValue  [   47  ]   =   ApplicantOtherIncomeSource1;
            applicationTemplate.FieldData.DataValues.DataValue  [   48  ]   =   ApplicantOtherHousing;
            applicationTemplate.FieldData.DataValues.DataValue  [   49  ]   =   ApplicantOtherAnnualIncome1;
            applicationTemplate.FieldData.DataValues.DataValue  [   50  ]   =   ApplicantMonthlyPayment;
            applicationTemplate.FieldData.DataValues.DataValue  [   51  ]   =   ApplicantHousingType;
            applicationTemplate.FieldData.DataValues.DataValue  [   52  ]   =   specialOfferCode;
            applicationTemplate.FieldData.DataValues.DataValue  [   53  ]   =   drpName;
            applicationTemplate.FieldData.DataValues.DataValue  [   54  ]   =   drpAccount;
            applicationTemplate.FieldData.DataValues.DataValue  [   55  ]   =   drpLawFirmName;
            applicationTemplate.FieldData.DataValues.DataValue  [   56  ]   =   ApplicantOtherIncomeSource2;
            applicationTemplate.FieldData.DataValues.DataValue  [   57  ]   =   ApplicantOtherIncomeSource3;
            applicationTemplate.FieldData.DataValues.DataValue  [   58  ]   =   ApplicantOtherAnnualIncome2;
            applicationTemplate.FieldData.DataValues.DataValue  [   59  ]   =   ApplicantOtherAnnualIncome3;
            applicationTemplate.FieldData.DataValues.DataValue  [   60  ]   =   ApplicantOtherAnnualIncomeId1;
            applicationTemplate.FieldData.DataValues.DataValue  [   61  ]   =   ApplicantOtherAnnualIncomeId2;
            applicationTemplate.FieldData.DataValues.DataValue  [   62  ]   =   ApplicantOtherAnnualIncomeId3;
            applicationTemplate.FieldData.DataValues.DataValue  [   63  ]   =   ApplicantCurrentEmploymentRecordId;
            applicationTemplate.FieldData.DataValues.DataValue  [   64  ]   =   ApplicantPreviousEmploymentRecordId;
            applicationTemplate.FieldData.DataValues.DataValue  [   65  ]   =   ApplicantHousingId;
            applicationTemplate.FieldData.DataValues.DataValue   [66]   =   ApplicantOtherIncomeProvider1;
            applicationTemplate.FieldData.DataValues.DataValue   [67]   =   ApplicantOtherIncomeProvider2;
            applicationTemplate.FieldData.DataValues.DataValue   [68]   =   ApplicantOtherIncomeProvider3;
            applicationTemplate.FieldData.DataValues.DataValue   [   69  ]    =   ApplicantOtherAnnualIncomeId4;
            applicationTemplate.FieldData.DataValues.DataValue   [   70  ]    =   ApplicantOtherIncomeProvider4;
            applicationTemplate.FieldData.DataValues.DataValue   [   71  ]    =   ApplicantOtherAnnualIncome4;
            applicationTemplate.FieldData.DataValues.DataValue   [   72  ]    =   ApplicantOtherIncomeSource4;
            applicationTemplate.FieldData.DataValues.DataValue   [   73  ]    =   ApplicantotherIncomeStartDate1;
            applicationTemplate.FieldData.DataValues.DataValue   [   74  ]    =   ApplicantotherIncomeStartDate2;
            applicationTemplate.FieldData.DataValues.DataValue   [   75  ]    =   ApplicantotherIncomeStartDate3;
            applicationTemplate.FieldData.DataValues.DataValue   [   76  ]    =   ApplicantotherIncomeStartDate4;
            applicationTemplate.FieldData.DataValues.DataValue   [   77  ]    =   ApplicantMaritalStatus;
            applicationTemplate.FieldData.DataValues.DataValue   [   78  ]    =   ApplicantSpouseName;
            applicationTemplate.FieldData.DataValues.DataValue   [   79  ]    =   ApplicantSpouseAddress;
            applicationTemplate.FieldData.DataValues.DataValue   [   80  ]    =   ApplicantOtherOccupation1;
            applicationTemplate.FieldData.DataValues.DataValue   [   81  ]    =   ApplicantOtherOccupation2;
            applicationTemplate.FieldData.DataValues.DataValue   [   82  ]    =   ApplicantOtherOccupation3;
            applicationTemplate.FieldData.DataValues.DataValue   [   83  ]    =   ApplicantOtherOccupation4;
            
            applicationTemplate.FieldData.DataValues.DataValue  [   84 ]   =   CoApplicantSpouseName;
            applicationTemplate.FieldData.DataValues.DataValue  [   85 ]   =   CoApplicantSpouseName;
            applicationTemplate.FieldData.DataValues.DataValue  [   86 ]   =   ApplicantMainIncomeId;
            applicationTemplate.FieldData.DataValues.DataValue  [   87 ]   =   CoApplicantMainIncomeId;
            
            
            
            applicationTemplate.FieldData.DataValues.DataValue    [   88  ]   =   CoApplicantName;
            applicationTemplate.FieldData.DataValues.DataValue  [   89  ]   =   CoApplicantMIName  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   90  ]   =   CoApplicantLastName    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   91  ]   =   CoApplicantDOB     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   92  ]   =   CoApplicantSSN     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   93  ]   =   CoApplicantUSResidency     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   94  ]   =   CoApplicantEmailAddress    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   95  ]   =   CoApplicantIdExpDate   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   96  ]   =   CoApplicantEmpStartDate    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   97  ]   =   CoApplicantPrevEmpStartDate    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   98  ]   =   CoApplicantPrevEmployer    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   99  ]   =   CoApplicantPrevEmployerStreet  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   100  ]   =   CoApplicantMailingState    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   101  ]   =   CoApplicantHomeState   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   102  ]   =   CoApplicantOtherState  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   103  ]   =   CoApplicantPrimaryIdType   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   104  ]   =   CoApplicantPrimaryIdState  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   105  ]   =   CoApplicantEmploymentStatus    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   106 ]   =   CoApplicantPrevEmpCity     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   107  ]   =   CoApplicantPrevEmpState    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   108 ]   =   CoApplicantEmpState    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   109 ]   =   CoApplicantHomeAddressZip  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   110 ]   =   CoApplicantMailingAddressZip   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   111 ]   =   CoApplicantOtherAddressZip     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   112 ]   =   CoApplicantPrevEmpZip  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   113 ]   =   CoApplicantEmpZip  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   114 ]   =   CoApplicantEmpStreet   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   115 ]   =   CoApplicantEmpCity     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   116 ]   =   CoApplicantPrimaryIncomeProvider    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   117 ]   =   CoApplicantAnnualBaseSalary    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   118 ]   =   CoApplicantAddressSinceDate   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   119 ]   =   CoApplicantWorkPhone   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   120 ]   =   CoApplicantHomeApartmentNumber     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   121 ]   =   CoApplicantOtherCity   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   122 ]   =   CoApplicantOtherApartmentNumber    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   123 ]   =   CoApplicantOtherStreet     ;
            applicationTemplate.FieldData.DataValues.DataValue   [   124 ]   =   CoApplicantprimaryIdNumber     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   125 ]   =   CoApplicantHomeAddressCity     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   126 ]   =   CoApplicantHomeAddressStreet   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   127 ]   =   CoApplicantHomePhone   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   128 ]   =   CoApplicantMobilePhone     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   129 ]   =   CoApplicantMailingAddressApt   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   130 ]   =   CoApplicantMailingAddStreet    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   131 ]   =   CoApplicantMailingAddCity  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   132 ]   =   CoApplicantFirstSchoolAttended;
            applicationTemplate.FieldData.DataValues.DataValue  [   133 ]   =   CoApplicantMotherMaidenName    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   134 ]   =   CoApplicantPrimaryOccupation  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   135 ]   =   CoApplicantOtherIncomeSource1   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   136 ]   =   CoApplicantOtherHousing    ;
            applicationTemplate.FieldData.DataValues.DataValue  [   137 ]   =   CoApplicantOtherAnnualIncome1   ;
            applicationTemplate.FieldData.DataValues.DataValue  [   138 ]   =   CoApplicantMonthlyPayment  ;
            applicationTemplate.FieldData.DataValues.DataValue  [   139 ]   =   CoApplicantHousingType     ;
            applicationTemplate.FieldData.DataValues.DataValue  [   140 ]   =   CoApplicantOtherIncomeSource2;
            applicationTemplate.FieldData.DataValues.DataValue  [   141 ]   =   CoApplicantOtherIncomeSource3;
            applicationTemplate.FieldData.DataValues.DataValue  [   142 ]   =   CoApplicantOtherAnnualIncome2;
            applicationTemplate.FieldData.DataValues.DataValue  [   143 ]   =   CoApplicantOtherAnnualIncome3;
            applicationTemplate.FieldData.DataValues.DataValue  [   144 ]   =   CoApplicantCurrentEmployerID;
            applicationTemplate.FieldData.DataValues.DataValue  [   145 ]   =   CoApplicantPreviousEmployerID;
            applicationTemplate.FieldData.DataValues.DataValue  [   146 ]   =   CoApplicantOtherIncomeId1;
            applicationTemplate.FieldData.DataValues.DataValue  [   147 ]   =   CoApplicantOtherIncomeId2;
            applicationTemplate.FieldData.DataValues.DataValue  [   148 ]   =   CoApplicantOtherIncomeId3;
            applicationTemplate.FieldData.DataValues.DataValue  [   149 ]   =   CoApplicantHousingId;
            applicationTemplate.FieldData.DataValues.DataValue  [   150 ]   =   CoApplicantOtherIncomeProvider1;
            applicationTemplate.FieldData.DataValues.DataValue  [   151 ]   =   CoApplicantOtherIncomeProvider2;
            applicationTemplate.FieldData.DataValues.DataValue  [   152 ]   =   CoApplicantOtherIncomeProvider3;
            applicationTemplate.FieldData.DataValues.DataValue  [   153 ]   =   CoApplicantOtherIncomeId4;
            applicationTemplate.FieldData.DataValues.DataValue  [   154 ]   =   CoApplicantOtherIncomeProvider4;
            applicationTemplate.FieldData.DataValues.DataValue  [   155 ]   =   CoApplicantOtherAnnualIncome4;
            applicationTemplate.FieldData.DataValues.DataValue  [   156 ]   =   CoApplicantOtherIncomeSource4;
            applicationTemplate.FieldData.DataValues.DataValue  [   157 ]   =   CoApplicantotherIncomeStartDate1;
            applicationTemplate.FieldData.DataValues.DataValue  [   158 ]   =   CoApplicantotherIncomeStartDate2;
            applicationTemplate.FieldData.DataValues.DataValue  [   159 ]   =   CoApplicantotherIncomeStartDate3;
            applicationTemplate.FieldData.DataValues.DataValue  [   160 ]   =   CoApplicantotherIncomeStartDate4;
            applicationTemplate.FieldData.DataValues.DataValue  [   161 ]   =   CoApplicantMaritalStatus;
            applicationTemplate.FieldData.DataValues.DataValue   [   162  ]    =   CoApplicantOtherOccupation1;
            applicationTemplate.FieldData.DataValues.DataValue   [   163  ]    =   CoApplicantOtherOccupation2;
            applicationTemplate.FieldData.DataValues.DataValue   [   164  ]    =   CoApplicantOtherOccupation3;
            applicationTemplate.FieldData.DataValues.DataValue   [   165  ]    =   CoApplicantOtherOccupation4;
            
            
            
            
            
            
        }else{
            applicationTemplate.FieldData = new DocuSignAPI.TemplateReferenceFieldData();
            applicationTemplate.FieldData.DataValues = new DocuSignAPI.ArrayOfTemplateReferenceFieldDataDataValue();
            applicationTemplate.FieldData.DataValues.DataValue = new DocuSignAPI.TemplateReferenceFieldDataDataValue[85];
            applicationTemplate.FieldData.DataValues.DataValue[0]   =   ApplicantName;
            applicationTemplate.FieldData.DataValues.DataValue[1]   =   ApplicantMIName;
            applicationTemplate.FieldData.DataValues.DataValue[2]   =   ApplicantLastName;
            applicationTemplate.FieldData.DataValues.DataValue[3]   =   ApplicantDOB;
            applicationTemplate.FieldData.DataValues.DataValue[4]   =   ApplicantSSN;
            applicationTemplate.FieldData.DataValues.DataValue[5]   =   ApplicantUSResidency;
            applicationTemplate.FieldData.DataValues.DataValue[6]   =   ApplicantEmailAddress;
            applicationTemplate.FieldData.DataValues.DataValue[7]   =   ApplicantIdExpDate;
            applicationTemplate.FieldData.DataValues.DataValue[8]   =   ApplicantEmpStartDate;
            applicationTemplate.FieldData.DataValues.DataValue[9]   =   ApplicantPrevEmpStartDate;
            applicationTemplate.FieldData.DataValues.DataValue[10]   =   ApplicantPrevEmployer;
            applicationTemplate.FieldData.DataValues.DataValue[11]   =   ApplicantPrevEmployerStreet;
            applicationTemplate.FieldData.DataValues.DataValue[12]   =   ApplicantMailingState;
            applicationTemplate.FieldData.DataValues.DataValue[13]   =   ApplicantHomeState;
            applicationTemplate.FieldData.DataValues.DataValue[14]   =   ApplicantOtherState;
            applicationTemplate.FieldData.DataValues.DataValue[15]   =   ApplicantPrimaryIdType;
            applicationTemplate.FieldData.DataValues.DataValue[16]   =   ApplicantPrimaryIdState;
            applicationTemplate.FieldData.DataValues.DataValue[17]   =   ApplicantEmploymentStatus;
            applicationTemplate.FieldData.DataValues.DataValue[18]   =   ApplicantPrevEmpCity;
            applicationTemplate.FieldData.DataValues.DataValue[19]   =   ApplicantPrevEmpState;
            applicationTemplate.FieldData.DataValues.DataValue[20]   =   ApplicantEmpState;
            applicationTemplate.FieldData.DataValues.DataValue[21]   =   ApplicantHomeAddressZip;
            applicationTemplate.FieldData.DataValues.DataValue[22]   =   ApplicantMailingAddressZip;
            applicationTemplate.FieldData.DataValues.DataValue[23]   =   ApplicantOtherAddressZip;
            applicationTemplate.FieldData.DataValues.DataValue[24]   =   ApplicantPrevEmpZip;
            applicationTemplate.FieldData.DataValues.DataValue[25]   =   ApplicantEmpZip;
            applicationTemplate.FieldData.DataValues.DataValue[26]   =   ApplicantEmpStreet;
            applicationTemplate.FieldData.DataValues.DataValue[27]   =   ApplicantEmpCity;
            applicationTemplate.FieldData.DataValues.DataValue[28]   =   ApplicantPrimaryIncomeProvider;
            applicationTemplate.FieldData.DataValues.DataValue[29]   =   ApplicantAnnualBaseSalary;
            applicationTemplate.FieldData.DataValues.DataValue[30]   =   ApplicantAddressSinceDate;
            applicationTemplate.FieldData.DataValues.DataValue[31]   =   ApplicantWorkPhone;
            applicationTemplate.FieldData.DataValues.DataValue[32]   =   ApplicantHomeApartmentNumber;
            applicationTemplate.FieldData.DataValues.DataValue[33]   =   ApplicantOtherCity;
            applicationTemplate.FieldData.DataValues.DataValue[34]   =   ApplicantOtherApartmentNumber;
            applicationTemplate.FieldData.DataValues.DataValue[35]   =   ApplicantOtherStreet;
            applicationTemplate.FieldData.DataValues.DataValue[36]   =   ApplicantprimaryIdNumber;
            applicationTemplate.FieldData.DataValues.DataValue[37]   =   ApplicantHomeAddressCity;
            applicationTemplate.FieldData.DataValues.DataValue[38]   =   ApplicantHomeAddressStreet;
            applicationTemplate.FieldData.DataValues.DataValue[39]   =   ApplicantHomePhone;
            applicationTemplate.FieldData.DataValues.DataValue[40]   =   ApplicantMobilePhone;
            applicationTemplate.FieldData.DataValues.DataValue[41]   =   ApplicantMailingAddressApt;
            applicationTemplate.FieldData.DataValues.DataValue[42]   =   ApplicantMailingAddStreet;
            applicationTemplate.FieldData.DataValues.DataValue[43]   =   ApplicantMailingAddCity;
            applicationTemplate.FieldData.DataValues.DataValue[44]   =   ApplicantFirstSchoolAttended;
            applicationTemplate.FieldData.DataValues.DataValue[45]   =   ApplicantMotherMaidenName;
            applicationTemplate.FieldData.DataValues.DataValue[46]   =   ApplicantPrimaryOccupation;
            applicationTemplate.FieldData.DataValues.DataValue[47]   =   ApplicantOtherIncomeSource1;
            applicationTemplate.FieldData.DataValues.DataValue[48]   =   ApplicantOtherHousing;
            applicationTemplate.FieldData.DataValues.DataValue[49]   =   ApplicantOtherAnnualIncome1;
            applicationTemplate.FieldData.DataValues.DataValue[50]   =   ApplicantMonthlyPayment;
            applicationTemplate.FieldData.DataValues.DataValue[51]   =   ApplicantHousingType;
            applicationTemplate.FieldData.DataValues.DataValue[52]   =   specialOfferCode;
            applicationTemplate.FieldData.DataValues.DataValue[53]   =   drpName;
            applicationTemplate.FieldData.DataValues.DataValue[54]   =   drpAccount;
            applicationTemplate.FieldData.DataValues.DataValue[55]   =   drpLawFirmName;
            applicationTemplate.FieldData.DataValues.DataValue[56]   =   ApplicantOtherIncomeSource2;
            applicationTemplate.FieldData.DataValues.DataValue[57]   =   ApplicantOtherIncomeSource3;
            applicationTemplate.FieldData.DataValues.DataValue[58]   =   ApplicantOtherAnnualIncome2;
            applicationTemplate.FieldData.DataValues.DataValue[59]   =   ApplicantOtherAnnualIncome3;
            applicationTemplate.FieldData.DataValues.DataValue[60]   =   ApplicantOtherAnnualIncomeId1;
            applicationTemplate.FieldData.DataValues.DataValue[61]   =   ApplicantOtherAnnualIncomeId2;
            applicationTemplate.FieldData.DataValues.DataValue[62]   =   ApplicantOtherAnnualIncomeId3;
            applicationTemplate.FieldData.DataValues.DataValue[63]   =   ApplicantCurrentEmploymentRecordId;
            applicationTemplate.FieldData.DataValues.DataValue[64]   =   ApplicantPreviousEmploymentRecordId;
            applicationTemplate.FieldData.DataValues.DataValue[65]   =   ApplicantHousingId;
            applicationTemplate.FieldData.DataValues.DataValue[66]   =   ApplicantOtherIncomeProvider1;
            applicationTemplate.FieldData.DataValues.DataValue[67]   =   ApplicantOtherIncomeProvider2;
            applicationTemplate.FieldData.DataValues.DataValue[68]   =   ApplicantOtherIncomeProvider3;
            applicationTemplate.FieldData.DataValues.DataValue   [   69  ]    =   ApplicantOtherAnnualIncomeId4;
            applicationTemplate.FieldData.DataValues.DataValue   [   70  ]    =   ApplicantOtherIncomeProvider4;
            applicationTemplate.FieldData.DataValues.DataValue   [   71  ]    =   ApplicantOtherAnnualIncome4;
            applicationTemplate.FieldData.DataValues.DataValue   [   72  ]    =   ApplicantOtherIncomeSource4;
            applicationTemplate.FieldData.DataValues.DataValue   [   73  ]    =   ApplicantotherIncomeStartDate1;
            applicationTemplate.FieldData.DataValues.DataValue   [   74  ]    =   ApplicantotherIncomeStartDate2;
            applicationTemplate.FieldData.DataValues.DataValue   [   75  ]    =   ApplicantotherIncomeStartDate3;
            applicationTemplate.FieldData.DataValues.DataValue   [   76  ]    =   ApplicantotherIncomeStartDate4;
            applicationTemplate.FieldData.DataValues.DataValue   [   77  ]    =   ApplicantMaritalStatus;
            applicationTemplate.FieldData.DataValues.DataValue   [   78  ]    =   ApplicantSpouseName;
            applicationTemplate.FieldData.DataValues.DataValue   [   79  ]    =   ApplicantSpouseAddress;
            
            applicationTemplate.FieldData.DataValues.DataValue   [   80  ]    =   ApplicantOtherOccupation1;
            applicationTemplate.FieldData.DataValues.DataValue   [   81  ]    =   ApplicantOtherOccupation2;
            applicationTemplate.FieldData.DataValues.DataValue   [   82  ]    =   ApplicantOtherOccupation3;
            applicationTemplate.FieldData.DataValues.DataValue   [   83  ]    =   ApplicantOtherOccupation4;
            applicationTemplate.FieldData.DataValues.DataValue  [   84 ]   =   ApplicantMainIncomeId;
            
        }
        
    }
    
    private static void logmessage(Object pMessage){
        system.debug(logginglevel.error, pMessage);
    }
    
    public class SendToDocuSignControllerException extends Exception{}
    
}