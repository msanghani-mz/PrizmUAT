public with sharing class AANPDFController extends SFSPDFControllerBase{
    
    public fsCore__Lending_Application__c mApplication {get; private set;}
    public fsCore__Branch_Setup__c mBranch {get; private set;}
    public String mReportContent{get; private set;}
    private String mCompanyLogoURL;
    private Boolean mIsDownload;
    
    public AANPDFController (ApexPages.StandardController pStdController){
        super();
        this.mApplication = (fsCore__Lending_Application__c)pStdController.getRecord();
        mCompanyLogoURL = fsCore.Constants.BLANK_STRING;
        mIsDownload = false;
        
        setPDFContents();
    }
    
    private void setPDFContents(){
        if (mApplication.Id != null){
            mApplication = fsCore.LendingApplicationUtil.getApplicationForPDF(mApplication.Id);
            fsCore__Lending_Application_Customer__c customer = [Select id , fsCore__Account_Name__r.Name
                                                                from fsCore__Lending_Application_Customer__c
                                                                where fsCore__Lending_Application_Number__c =:mApplication.Id 
                                                                and fsCore__Customer_Type__c ='Primary'];
            fsCore__Lending_Application__c app = [Select id, Rejection_Reasons__c from fsCore__Lending_Application__c where id =:mApplication.Id];
            String reason;
            if(app.Rejection_Reasons__c != null){
                reason = app.Rejection_Reasons__c;
                String substring = '<p><strong>External Reason(s)</strong></p>';
                Integer length = substring.length();
                Integer num = reason.lastIndexOfIgnoreCase('<p><strong>External Reason(s)</strong></p>');
                reason = reason.substring(num + length);
                System.debug(loggingLevel.ERROR, reason);  
            }
            
            mBranch = fsCore.UserBranchUtil.getBranchForPDF(mApplication.fsCore__Branch_Name__c);
            mReportContent = '<p>Dear '+customer.fsCore__Account_Name__r.Name +',</p>'+
                '<p>Thank you for your recent application. Your request for a loan was carefully considered, and we regret that we are unable to approve your application at this time, for the following reason(s):</p>'+
                '<ul>'+ reason +
                '</ul>'+
                '<p>&nbsp;</p>'+
                '<p>Our credit decision was based in whole or in part on information obtained in a report from the consumer reporting agency listed below. You have a right under the Fair Credit Reporting Act to know the information contained in your credit file at the consumer reporting agency. The reporting agency played no part in our decision and is unable to supply specific reasons why we have denied credit to you. You also have a right to a free copy of your report from the reporting agency, if you request it no later than 60 days after you receive this notice. In addition, if you find that any information contained in the report you receive is inaccurate or incomplete, you have the right to dispute the matter with the reporting agency.</p>'+
                '<p>&nbsp;</p>'+
                '<p><strong>TransUnion LLC<br /> P.O. Box 2000<br /> Chester, PA 19016-2000</strong></p>'+
                '<p><strong>1-833-395-6938</strong></p>'+
                '<p><a href="https://www.transunion.com%0d">https://www.transunion.com</a></p>'+
                '<p><strong>&nbsp;</strong></p>'+
                '<p>If you have any questions regarding this letter, you should contact us at Versara Lending, LLC&nbsp; 711 Third Avenue, Suite 600, New York, New York 10017.</p>'+
                '<p>Notice: The Federal Equal Credit Opportunity Act prohibits creditors from discriminating against credit applicants on the basis of race, color, religion, national origin, sex, marital status, age (provided the applicant has the capacity to enter into a binding contract); because all or part of the applicant\'s income derives from any public assistance program; or because the applicant has in good faith exercised any right under the Consumer Credit Protection Act. The Federal agency that administers compliance with this law concerning this creditor is the Federal Trade Commission, Equal Credit Opportunity, Washington, DC 20580.</p>';
            if (mBranch.fsCore__Company_Name__r.fsCore__Company_Logo_File_Id__c != null){
                mCompanyLogoURL = mBranch.fsCore__Company_Name__r.fsCore__Company_Logo_File_Id__c;
            }
            
            String pdfFileName = 'AAN_'+ mApplication.Name + '.pdf' ;
            
            if (mIsDownload) { downloadPDF(pdfFileName); }
        }
    }
    
    public String getCompanyLogoURL(){
        return mCompanyLogoURL;
    }
    
}