/*
 * Class   : CreditReportPDFController
 * Purpose : Controller class to generate credit pull HTML report 
 * Author  : Financial Spectra
 */
public class CreditReportPDFController{

    public String mReportContent {get;set;}
    public String mApplicantType {get;set;}

    public CreditReportPDFController(){
        Id creditPullId = ApexPages.currentPage().getParameters().get('id');
        mApplicantType = ApexPages.currentPage().getParameters().get('applicantType');
        system.debug(logginglevel.error,'CreditReportPDFController 1' );        
        setReportContent(creditPullId);
    }
    
    public CreditReportPDFController(ApexPages.StandardController pStdController){
        system.debug(logginglevel.error,'CreditReportPDFController 2' );
        Credit_Pull_Report__c crPullReport = (Credit_Pull_Report__c)pStdController.getRecord();
        system.debug(logginglevel.error,'crPullReport :'+crPullReport );
        mApplicantType = ApexPages.currentPage().getParameters().get('applicantType');
        system.debug(logginglevel.error,'mApplicantType :'+mApplicantType );
        setReportContent(crPullReport.Id);
    }
    
    private void setReportContent(String pCPReportString){
        mReportContent = pCPReportString;
    }
    private void setReportContent(Id pCPReportId){
        if (pCPReportId != null){
            Credit_Pull_Report__c crPullReport = 
                        [SELECT Id, Report_Content_1__c
                              , Report_Content_2__c
                              , Report_Content_3__c
                              , Report_Content_CoApl_1__c
                              , Report_Content_CoApl_2__c
                              , Report_Content_CoApl_3__c
                              , Pull_Source__c
                              , Account_Name__c
                              , Co_Account_Name__c
                              , Account_Name_Formula__c
                              , Co_Account_Name_Formula__c
                           FROM Credit_Pull_Report__c
                          WHERE Id = :pCPReportId];
            system.debug(logginglevel.error,'Inside setReportContent mApplicantType :'+mApplicantType );
            if (mApplicantType == fsCore.Constants.CUSTOMER_TYPE_PRIMARY){
                mReportContent = (String.IsNotBlank(crPullReport.Report_Content_1__c) ? crPullReport.Report_Content_1__c : '<p>*** No content found ***</p>');
                mReportContent += (String.IsNotBlank(crPullReport.Report_Content_2__c) ? crPullReport.Report_Content_2__c : '');
                mReportContent += (String.IsNotBlank(crPullReport.Report_Content_3__c) ? crPullReport.Report_Content_3__c : '');
            }else{
                mReportContent = (String.IsNotBlank(crPullReport.Report_Content_CoApl_1__c) ? crPullReport.Report_Content_CoApl_1__c : '<p>*** No content found ***</p>');
                mReportContent += (String.IsNotBlank(crPullReport.Report_Content_CoApl_2__c) ? crPullReport.Report_Content_CoApl_2__c : '');
                mReportContent += (String.IsNotBlank(crPullReport.Report_Content_CoApl_3__c) ? crPullReport.Report_Content_CoApl_3__c : '');

            }


        }
        mReportContent = mReportContent.replace('class=badmop', 'style="background-color: #ffb6c1"');
        mReportContent = mReportContent.replace('class=goodmop', 'style="background-color: #FFFFFF"');
        mReportContent = mReportContent.replace('class=alert', 'style="background-color: #ffa07a "');
        mReportContent = mReportContent.replace('class=separator', 'style="background-color: #FFFFCC; font-weight: bold "');
        

        if (String.IsBlank(mReportContent)){
            mReportContent = '<p>*** No content found ***</p>';
        }
    }  

}