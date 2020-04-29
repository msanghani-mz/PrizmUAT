/*
* Class   : GenerateCreditReportAction
* Purpose : Action class to generate credit pull PDF report
* Author  : Financial Spectra
*/
public class GenerateCreditReportAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private Map<Id, Credit_Pull_Report__c> mCreditPullReportsMap;
    
    public GenerateCreditReportAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }
    
    public void process(){
        System.debug(loggingLevel.ERROR, '-- Start credit report generation... ' + system.now());
        mCreditPullReportsMap = new Map<Id, Credit_Pull_Report__c>(
            [SELECT Id, Name
             , Account_Name__c
             , Co_Account_Name__c
             , Pull_Source__c
             , Account_Name_Formula__c
             , Co_Account_Name_Formula__c
             , Lending_Application_Number__c
             , Lending_Application_Number__r.BoxFolderId__c
             , Lending_Contract_Number__c
             , Lending_Contract_Number__r.BoxFolderId__c
             , Report_Content_1__c
             , Report_Content_2__c
             , Report_Content_3__c
             FROM Credit_Pull_Report__c
             WHERE Id IN :mActionInput.getRecords()]);
        
        if (mCreditPullReportsMap.size() == 0){ return; }
        
        createPDFReportsInBox();
        
        System.debug(loggingLevel.ERROR, '-- Finish credit report generation... ' + system.now());
    }
    
    private void createPDFReportsInBox(){
        
        Map<Id, ContentVersion> reportIdToReportFileMap = new Map<Id, ContentVersion>();
        
        for(Credit_Pull_Report__c cpReport : mCreditPullReportsMap.values()){
            Map<String,Blob> creditReportMap = new Map<String,Blob>();
            String boxFolderId = cpReport.Lending_Application_Number__r.BoxFolderId__c;
            if (cpReport.Lending_Contract_Number__c != null){
                boxFolderId = cpReport.Lending_Contract_Number__r.BoxFolderId__c;
            }
            
            if ((cpReport.Lending_Contract_Number__c == null) && (cpReport.Lending_Application_Number__r.BoxFolderId__c == null)){
                System.debug(loggingLevel.ERROR, '-- BOX FOLDER IS NULL ON APPLICATION CANNOT MOVE IT TO BOX.COM ');
                continue;
            }
            if ((cpReport.Lending_Contract_Number__c != null) && (cpReport.Lending_Contract_Number__r.BoxFolderId__c == null)){
                System.debug(loggingLevel.ERROR, '-- BOX FOLDER IS NULL ON CONTRACT CANNOT MOVE IT TO BOX.COM ');
                continue;
            }
            PageReference applicantCreditReportPDF = Page.creditReportPage;
            applicantCreditReportPDF.getParameters().put('id', cpReport.Id);
            applicantCreditReportPDF.getParameters().put('applicantType', fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
            
            String currentTime = fsCore.TypeUtil.getFormattedDatetime(System.now(), 'YYMMddhhmm');
            Blob applicantPdfReport;
            if(Test.isRunningTest()){
                applicantPdfReport = blob.valueOf('Unit.Test');
            }else{
                applicantPdfReport = applicantCreditReportPDF.getContent();
            }
            String accountName = cpReport.Account_Name_Formula__c.normalizeSpace().replace(' ','_').toUpperCase();
            
            creditReportMap.put(String.format(Label.Credit_Pull_Report_Name_Format, new String[]{accountName, cpReport.Pull_Source__c,currentTime}),applicantPdfReport);
            
            if (cpReport.Co_Account_Name__c != null){
                PageReference coapplicantCreditReportPDF = Page.creditReportPage;
                coapplicantCreditReportPDF.getParameters().put('id', cpReport.Id);
                coapplicantCreditReportPDF.getParameters().put('applicantType', fsCore.Constants.CUSTOMER_TYPE_SECONDARY);
                Blob coApplicantPdfReport;
                if(Test.isRunningTest()){
                   coApplicantPdfReport = blob.valueOf('Unit.Test');
                }else{
                   coApplicantPdfReport = coapplicantCreditReportPDF.getContent(); 
                }
                String coaccountName = cpReport.Co_Account_Name_Formula__c.normalizeSpace().replace(' ','_').toUpperCase();
                
                creditReportMap.put(String.format(Label.Credit_Pull_Report_Name_Format, new String[]{coaccountName, cpReport.Pull_Source__c,currentTime}),coApplicantPdfReport);
            }
            
            //Blob pdfDoc = System.EncodingUtil.base64Decode(res2.getBody());
            
            //NOW MOVE THE DOCUMENT TO THE BOX.COM
            createPDFReportsInBox(creditReportMap,boxFolderId);
        }
    }
    private void createPDFReportsInBox(Map<String,Blob> pCreditReportMap, String pBoxFolderId){
        Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
        System.debug('objBoxsettings:==='+objBoxsettings);
        if(objBoxsettings.id !=null){
        BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
        api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
        api.setAccessToken(objBoxsettings.access_token1__c);
        api.setExpires(long.valueOf(objBoxsettings.expires__c));
        
        BoxFolder box = new BoxFolder(api, pBoxFolderId);//'54555930164');
        for(String creditReportName : pCreditReportMap.KeySet()){
            BoxFile.Info bxInfo = box.uploadFile(pCreditReportMap.get(creditReportName),creditReportName+'.pdf');
            
        }
        }
    }
    
    // WE ARE NOT USING THIS METHOD CURRENTLY, WE ARE SIMPLY USING createPDFReportsInBox
    /*private void createPDFReportsInFile(){
Map<Id, ContentVersion> reportIdToReportFileMap = new Map<Id, ContentVersion>();
for(Credit_Pull_Report__c cpReport : mCreditPullReportsMap.values()){
PageReference creditReportPDF = Page.creditReportPage;
creditReportPDF.getParameters().put('id', cpReport.Id);

Blob pdfReport = creditReportPDF.getContent();
String encodedFileContent = EncodingUtil.base64Encode(pdfReport);

ContentVersion contentVersion = new ContentVersion();
contentVersion.ContentLocation = 'S';
contentVersion.VersionData = EncodingUtil.base64Decode(encodedFileContent);
contentVersion.Title = cpReport.Name;
contentVersion.PathOnClient = cpReport.Name + '.pdf';
reportIdToReportFileMap.put(cpReport.Id, contentVersion);
}
Database.insert(reportIdToReportFileMap.values(), true); // if the insert fails it will raise an exception

Set<Id> fileIdSet = new Set<Id>();
Map<Id, Id> fileIdToReportIdMap = new Map<Id, Id>();
for (Id reportId : reportIdToReportFileMap.keySet()){
ContentVersion crFile = reportIdToReportFileMap.get(reportId);
fileIdSet.add(crFile.Id);
fileIdToReportIdMap.put(crFile.Id, reportId);
}


//create the content document links with account, customer and application record

List<ContentDocumentLink> reportFileLinks = new List<ContentDocumentLink>();

for (ContentVersion crFile : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :fileIdSet]){
Credit_Pull_Report__c cpReport = mCreditPullReportsMap.get(fileIdToReportIdMap.get(crFile.Id));

//Link with account record
ContentDocumentLink docLinkWithAccount = new ContentDocumentLink();
docLinkWithAccount.ContentDocumentId = crFile.ContentDocumentId;
docLinkWithAccount.LinkedEntityId = cpReport.Account_Name__c;
docLinkWithAccount.ShareType = 'I';
reportFileLinks.add(docLinkWithAccount);

if (cpReport.Lending_Application_Number__c != null){
//Link with application record
ContentDocumentLink docLinkWithApp = new ContentDocumentLink();
docLinkWithApp.ContentDocumentId = crFile.ContentDocumentId;
docLinkWithApp.LinkedEntityId = cpReport.Lending_Application_Number__c;
docLinkWithApp.ShareType = 'I';
reportFileLinks.add(docLinkWithApp);
}

//Link with report record
ContentDocumentLink docLinkWithReport = new ContentDocumentLink();
docLinkWithReport.ContentDocumentId = crFile.ContentDocumentId;
docLinkWithReport.LinkedEntityId = cpReport.Id;
docLinkWithReport.ShareType = 'I';
reportFileLinks.add(docLinkWithReport);
}

Database.insert(reportFileLinks, true);
}*/
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
}