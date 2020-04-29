/*
 * Class   : CreditAnalysisAction
 * Purpose : Action class to invoke the credit analysis service for the input customer credit pull records
 * Author  : Financial Spectra
 */
public class GetCreditReportAction implements fsCore.ActionProcessor{

    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private List<Credit_Pull_Report__c> mAccountCPRList;
    WS_GetCreditReportResponse mWSResponse;
    private Map<Id, CreditPullCustomer> mCustomerIdToCustomerMap;
    private Map<Id, CreditPullCustomer> mAccountToCustomerMap;
    private Map<String,Id> mCustomerToAccountMap;    

    public GetCreditReportAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    
    //set the ids of the applications 
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }

    private void populateMaps(){
        
        mCustomerIdToCustomerMap = new Map<Id, CreditPullCustomer>();
        mAccountToCustomerMap = new Map<Id, CreditPullCustomer>();
        mCustomerToAccountMap = new Map<String,Id>();
        Set<ID> applicationIds = mActionInput.getRecords();
        ID applicationId;
        for(Id applId: applicationIds){
            applicationId  = applId;
            break;
        }
        List<CreditPullCustomer> creditCustomerList = CreditPullUtil.getApplicationCustomers(applicationId);
                
        for(CreditPullCustomer appl : creditCustomerList){
            
            mCustomerIdToCustomerMap.put(appl.customer_account_id, appl);
            mAccountToCustomerMap.put(appl.customer_account_id, appl);

            if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equalsIgnoreCase(appl.Customer_Type)){
                mCustomerToAccountMap.put(appl.Customer_Type, appl.customer_account_id);
            }else{
                mCustomerToAccountMap.put(fsCore.Constants.CUSTOMER_TYPE_SECONDARY, appl.customer_account_id);
            }
        }

    }    
    
    public void process(){
        populateMaps();
        Map<String,Blob> creditReportMap = new Map<String,Blob>();
        Map<Id, fsCore__Lending_Application__c> applicationMap 
            = new Map<Id, fsCore__Lending_Application__c>([SELECT Id,name, Velocify_ID__c , BoxFolderId__c
                                                           FROM fsCore__Lending_Application__c
                                                           WHERE Id IN :mActionInput.getRecords()
                                                             and Velocify_ID__c != null
                                                             AND BoxFolderId__c != null]);
        
        
        //instantiate the web service
        WS_GetCreditReport creditReportAPI = new WS_GetCreditReport();

        if (creditReportAPI.mIsAccessTokenSucess){
        
            for(Id applicationId : mActionInput.getRecords()){
                if (applicationMap.containsKey(applicationId)){
                    String boxFolderId = applicationMap.get(applicationId).BoxFolderId__c;

                    WS_GetCreditReportRequest creditReportRequest = new WS_GetCreditReportRequest();
                    creditReportRequest.velocifyId  = applicationMap.get(applicationId).Velocify_ID__c;
                    creditReportRequest.offerId  = applicationMap.get(applicationId).Velocify_ID__c;//'1773';
                    creditReportRequest.boxFolderId  = applicationMap.get(applicationId).BoxFolderId__c;
                    creditReportRequest.applicationName  = applicationMap.get(applicationId).Name;
                    creditReportRequest.applicationId  = applicationId;



                    creditReportAPI.setRequest(creditReportRequest);
                    System.debug(loggingLevel.ERROR, 'credit request - '+creditReportRequest);
                    creditReportAPI.invoke();
                    mWSResponse = creditReportAPI.getResponse();

                    

                    if (creditReportAPI.mIsGetCreditReportSucess){
                        saveCreditPullReport();
                        WS_GetCreditReportResponse wsResponse = creditReportAPI.getResponse();

                    }else{
                            mActionOutput.addError('Error while invoking get credit report service Response : '+creditReportAPI.mGetCreditResponseStatus);
                    }
                } 
                else {
                    mActionOutput.addError('Unable to find the Velocify Id(s) Or Box Folder Ids for the Application (Id: ' + String.valueOf(applicationId) + ').');
                }
            }
        }else{
            mActionOutput.addError('Cannot get access token, please check credentials. Response : '+creditReportAPI.mAccessTokeResponseStatus);
        }
    }

    private void saveCreditPullReport(){
        try{
        mAccountCPRList = new List<Credit_Pull_Report__c>();
        system.debug(logginglevel.error,'1');
        WS_GetCreditReportResponse wsResponse = mWSResponse;
        
        Id accountId = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
        Id coAccountId = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_SECONDARY);

        String currentTime = fsCore.TypeUtil.getFormattedDatetime(System.now(), 'YYMMddhhmm');
        Credit_Pull_Report__c accountCPR = new Credit_Pull_Report__c();
        System.debug(logginglevel.error,'mCustomerIdToCustomerMap.get(accountId):--'+mCustomerIdToCustomerMap.get(accountId));
        System.debug(logginglevel.error,'mCustomerIdToCustomerMap:--'+mCustomerIdToCustomerMap.get(accountId).customer_name.normalizeSpace().replace(' ','_').toUpperCase());

        String accountName = mCustomerIdToCustomerMap.get(accountId).customer_name.normalizeSpace().replace(' ','_').toUpperCase();
        String reportName = String.format(Label.Credit_Pull_Report_Name_Format, new String[]{accountName, currentTime});


        accountCPR.Name = reportName;
        accountCPR.RecordTypeId = Schema.SObjectType.Credit_Pull_Report__c.getRecordTypeInfosByName().get(mAccountToCustomerMap.get(accountId).customer_lending_application_number_credit_pull_record_type_name_formula).getRecordTypeId();
        accountCPR.Pull_Source__c = 'EFX';
        accountCPR.Account_Name__c = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
        accountCPR.Co_Account_Name__c = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_SECONDARY);
        accountCPR.Lending_Application_Number__c = mAccountToCustomerMap.get(accountId).customer_lending_application_number;

        //split report conent into 3 long text area fields (total available character limit 375000)
        String reportBodyContent = wsResponse.htmlCreditReport;
        if (String.IsNotBlank(reportBodyContent)){
            if (reportBodyContent.length() > 125000){
                accountCPR.Report_Content_1__c = reportBodyContent.substring(0, 125000);
                reportBodyContent = reportBodyContent.substring(125000);
                
                if (reportBodyContent.length() > 125000){
                    accountCPR.Report_Content_2__c = reportBodyContent.substring(0, 125000);
                    reportBodyContent = reportBodyContent.substring(125000);
                    
                    accountCPR.Report_Content_3__c = (reportBodyContent.length() > 125000 ? reportBodyContent.substring(0, 125000) : reportBodyContent);
                } else {
                    accountCPR.Report_Content_2__c = reportBodyContent;
                }
            } else {
                accountCPR.Report_Content_1__c = reportBodyContent;
            }
        }        


        mAccountCPRList.add(accountCPR);

        system.debug(logginglevel.error,'mAccountCPRList :'+mAccountCPRList);
        Database.insert(mAccountCPRList, true);
        Set<Id> newCPRIds = new Set<Id>();
        for (Credit_Pull_Report__c cpReport : mAccountCPRList){
            newCPRIds.add(cpReport.Id);
        }
        mAccountCPRList = [SELECT Id, Name FROM Credit_Pull_Report__c WHERE Id = :newCPRIds];        
        }catch(Exception e){
            system.debug(logginglevel.error, e);
            throw e;
        }
    }

    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
    public List<Credit_Pull_Report__c> getCreditPullReportRecords(){
        return mAccountCPRList;
    }

    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('GetCreditReportAction', 'process', mActionOutput.getErrors());
        }
    }
    
}