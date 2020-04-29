/*
* Class Name : DNLATDDrawloopRouter
* Purpose    : Controller class for TILA Dashboard page
* Developer  : Financial Spectra
*/
public with sharing class DNLATDDrawloopRouterController {
    private static final String CLASS_NAME = 'DNLATDDrawloopRouter';
    
    public fsCore__Assignment__c mAssignment {get; private set;}
    public fsCore__Lending_Application__c mApplication {get; private set;}
    public fsServ__Lending_Contract__c mContract {get; private set;}

    
    public DNLATDDrawloopRouterController(ApexPages.StandardController pStdController){
        mAssignment = (fsCore__Assignment__c)pStdController.getRecord();
        mAssignment = [select id,fsCore__Lending_Application_Number__c,fsServ__Lending_Contract_Number__c,ATD_Document_Filter__c from fsCore__Assignment__c where id =:mAssignment.id];
        queryRecord();

    }

    public PageReference redirectToDrawloopPage(){
        
        String retUrl = '/'+mAssignment.Id;
        PageReference drawLoopPage = new PageReference('/apex/loop__looplus?eid='+mAssignment.Id);
        drawLoopPage.getParameters().put('hideddp','true');
        drawLoopPage.getParameters().put('header','false');
        drawLoopPage.getParameters().put('ddplabel',(mAssignment.ATD_Document_Filter__c == null)?' Missing Payment Processor on the application':mAssignment.ATD_Document_Filter__c);
        drawLoopPage.getParameters().put('filter',(mAssignment.ATD_Document_Filter__c == null)?' Missing Payment Processor on the application':mAssignment.ATD_Document_Filter__c);
        //drawLoopPage.getParameters().put('filter',(mAssignment.ATD_Document_Filter__c == null)?' Missing Payment Processor on the applicaiton':'RAM-ATD-BANK-MODIFICATION');
        drawLoopPage.getParameters().put('retURL',retUrl);
        
        if (mAssignment.fsCore__Lending_Application_Number__c != null){
            for (fsCore__Lending_Application_Customer__c customer: mApplication.fsCore__Lending_Application_Customer__r){
                if (customer.fsCore__Customer_Type__c == 'Primary'){
                    drawLoopPage.getParameters().put('applicant_name',customer.fsCore__Account_Name__r.Name);
                    drawLoopPage.getParameters().put('applicant_email',customer.fsCore__Account_Name__r.PersonEmail);
                }else{
                    drawLoopPage.getParameters().put('coapplicant_name',customer.fsCore__Account_Name__r.Name);
                    drawLoopPage.getParameters().put('coapplicant_email',customer.fsCore__Account_Name__r.PersonEmail);

                }

            }
            
            if (mApplication.Loan_Officer__c != null){
                User loanOfficerUser = [SELECT Id, Name, Email, Profile.Id, Profile.Name FROM User WHERE Id=:mApplication.Loan_Officer__c];
                drawLoopPage.getParameters().put('LoanOfficer_name',loanOfficerUser.Name);
                drawLoopPage.getParameters().put('LoanOfficer_email',loanOfficerUser.Email);
            }     
        }else{
            for (fsServ__Contract_Customer__c customer: mContract.fsServ__Contract_Customer__r){
                if (customer.fsServ__Customer_Type__c == 'Primary'){
                    drawLoopPage.getParameters().put('applicant_name',customer.fsServ__Account_Name__r.Name);
                    drawLoopPage.getParameters().put('applicant_email',customer.fsServ__Account_Name__r.PersonEmail);
                }else{
                    drawLoopPage.getParameters().put('coapplicant_name',customer.fsServ__Account_Name__r.Name);
                    drawLoopPage.getParameters().put('coapplicant_email',customer.fsServ__Account_Name__r.PersonEmail);

                }

            }
            
            /*if (mContract.Loan_Officer__c != null){
                User loanOfficerUser = [SELECT Id, Name, Email, Profile.Id, Profile.Name FROM User WHERE Id=:mApplication.Loan_Officer__c];
                drawLoopPage.getParameters().put('LoanOfficer_name',loanOfficerUser.Name);
                drawLoopPage.getParameters().put('LoanOfficer_email',loanOfficerUser.Email);
            } */              
        }   

        drawLoopPage.setRedirect(true);

        return drawLoopPage;

    }

private void queryRecord(){

        if (mAssignment.fsCore__Lending_Application_Number__c != null){
        
        mApplication = [SELECT id
                        , name
                        , Opportunity_Name__r.DRP_Name__c
                        , Opportunity_Name__r.Program_Type__c 
                        , Payment_Processor_Name__c
                        , Opportunity_Name__r.Portfolio_Type__c
                        , Opportunity_Name__r.Law_Firm_Name__c
                        , BoxFolderId__c
                        , Opportunity_Name__c
                        , Monthly_Legal_Fee__c
                        , fsCore__Primary_Customer_Account__r.Import_BoxFolderId__c
                        , fsCore__Payment_Amount__c
                        , Monthly_Processor_Fee__c
                        , Monthly_Third_Party_Fees__c
                        , Is_PreTILA_Signed__c
                        , fsCore__Rate__c
                        , fsCore__Annual_Percent_Rate__c
                        , PreTila_Vaulting_Method__c
                        , fsCore__Decision_Updated_On__c
                        , fsCore__Pricing_Name__c
                        , fsCore__Approved_Prepaid_Fee__c
                        , fsCore__Approved_Finance_Fee__c
                        , fsCore__Application_Date__c
                        , fsCore__Financed_Amount__c
                        , fsCore__Approved_Financed_Amount__c
                        , fsCore__Payment_Cycle__c
                        , Primary_Customer_State__c
                        , fsCore__Maturity_Date__c
                        , fsCore__Contract_Date__c
                        , fsCore__Payment_Start_Date__c
                        , fsCore__Requested_Payment_Cycle__c
                        , fsCore__State__c
                        , fsCore__Loan_Amount__c
                        , fsCore__Actual_Prepaid_Fee__c
                        , fsCore__Actual_Finance_Fee__c
                        , Is_Final_Contract_Generated__c
                        , Final_Approval_Date__c
                        , Next_DRP_Draft_Date__c
                        , fsCore__Contract_Template_Name__c
                        , fsCore__Number_Of_Payments__c
                        , fsCore__Payment_Due_Day__c
                        , fsCore__Payment_Due_Day_2__c
                        , fsCore__Pricing_Name__r.fsCore__Financed_Amount_Maximum__c
                        , fsCore__Pricing_Name__r.fsCore__Financed_Amount_Minimum__c
                        , fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Minimum__c
                        , fsCore__Pricing_Name__r.fsCore__Number_Of_Payments_Maximum__c
                        , fsCore__Pricing_Name__r.fsCore__Rate_Value_Minimum__c
                        , fsCore__Pricing_Name__r.fsCore__Rate_Value_Maximum__c
                        , Loan_Officer__c
                        , Original_Enrolled_Debt__c
                        , fsCore__Title__c
                        , Underwriter__c
                        , Loan_Officer__r.firstName
                        , Loan_Officer__r.LastName
                        , ( SELECT Id, Name
                                    , fsCore__Account_Name__c
                                    , fsCore__Customer_Record_Type__c
                                    , fsCore__Customer_Type__c
                                    , fsCore__Is_Primary__c
                                    , fsCore__Lending_Application_Number__c
                                    , fsCore__Account_Name__r.PersonOtherAddress
                                    , fsCore__Account_Name__r.PersonContactId
                                    , fsCore__Account_Name__r.PersonOtherCity
                                    , fsCore__Account_Name__r.PersonOtherCountry
                                    , fsCore__Account_Name__r.PersonOtherCountryCode
                                    , fsCore__Account_Name__r.PersonOtherGeocodeAccuracy
                                    , fsCore__Account_Name__r.PersonOtherLatitude
                                    , fsCore__Account_Name__r.PersonOtherLongitude
                                    , fsCore__Account_Name__r.PersonOtherPhone
                                    , fsCore__Account_Name__r.PersonOtherPostalCode
                                    , fsCore__Account_Name__r.PersonOtherState
                                    , fsCore__Account_Name__r.PersonOtherStateCode
                                    , fsCore__Account_Name__r.PersonOtherStreet
                                    , fsCore__Account_Name__r.PersonEmail
                                    , fsCore__Account_Name__r.PersonTitle
                                    , fsCore__Account_Name__r.Client_Number__c
                                    , fsCore__Account_Name__r.PersonHomePhone
                                    , fsCore__Account_Name__r.PersonMobilePhone             
                                    , fsCore__Account_Name__r.Name    
                                    FROM fsCore__Lending_Application_Customer__r)             
                        FROM fsCore__Lending_Application__c
                        WHERE id = :mAssignment.fsCore__Lending_Application_Number__c];

        }else{
            mContract = [SELECT id
                              , name
                              , ( SELECT Id, Name
                                    , fsServ__Customer_Type__c
                                    , fsServ__Account_Name__r.Name
                                    , fsServ__Account_Name__r.PersonEmail
                                    FROM fsServ__Contract_Customer__r)              
                          from fsServ__Lending_Contract__c 
                         where id = :mAssignment.fsServ__Lending_Contract_Number__c];

        }                        

    }    
    

}