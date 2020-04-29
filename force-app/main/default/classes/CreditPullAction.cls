/*
 * Class   : CreditPullAction
 * Purpose : Action class to pull the credit for the input customer records and save the credit report as PDF
 * Author  : Financial Spectra
 */
public class CreditPullAction implements fsCore.ActionProcessor{

    private static final String SOFT_PULL = 'Soft';
    private static final String HARD_PULL = 'Hard';
    private String mPullType;
    private String mPullSource;
    private String mPullEntity;
    public static final String PULL_ENTITY_APPLICATION = 'Application';
    public static final String PULL_ENTITY_CONTRACT = 'Contract';

    public static final String PULL_SOURCE_EFXHART = 'EFXHART';
    public static final String PULL_SOURCE_TUHART = 'TUHART';

    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;

    private List<CreditPullCustomer> mCustomers;
    
    /* 
     * As of 8-Aug-2018, only Customers with Person Accounts are supported
     */
    private Map<Id, CreditPullCustomer> mCustomerIdToCustomerMap;
    private Map<Id, CreditPullCustomer> mAccountToCustomerMap;
    private Map<String,Id> mCustomerToAccountMap;
    
    
    //private Map<Id, WS_PullCreditResponse> mAccountToWSResponseMap;
    WS_PullCreditResponse mWSResponse;
    private List<Credit_Pull_Report__c> mAccountCPRList;
        
    public CreditPullAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mCustomers = new List<CreditPullCustomer>();
    }
    
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }
    
    public void setCustomers(List<CreditPullCustomer> pCustomers){
        mCustomers = pCustomers;
    }
    
    public void setPullType(String pPullType){
        system.debug(logginglevel.error,'pPullType :'+pPullType);
        mPullType = (pPullType.equalsIgnoreCase('Hard') ? HARD_PULL : SOFT_PULL);
    }

    public void setPullEntity(String pPullEntity){
        mPullEntity = pPullEntity;
    } 
    public void setPullSource(String pPullSource){
        System.debug(loggingLevel.ERROR, '-- setPullSource... ' + pPullSource);
        //PDI-750
        if (pPullSource == null){
            mPullSource = PULL_SOURCE_TUHART;
        }else{
            mPullSource = pPullSource;
        }

        System.debug(loggingLevel.ERROR, '-- mPullSource... ' + mPullSource);
        
    }       

    public void process(){
        System.debug(loggingLevel.ERROR, '-- Start Credit Pull Service call... ' + system.now());
        /* Step 1 : populate maps with required data*/
        populateMaps();
        System.debug(loggingLevel.ERROR, '-- Populated Maps --'+mCustomerIdToCustomerMap.size());
        
        if (mCustomerIdToCustomerMap.size() == 0){ 
            System.debug(loggingLevel.ERROR, 'No Account record found for the request');
            return; 
            
        }
        
        /* Step 2 : call credit pull service and handle response */
        //mAccountToWSResponseMap = new Map<Id, WS_PullCreditResponse>();
        WS_PullCreditRequest wsRequest = new WS_PullCreditRequest();
        for (CreditPullCustomer creditCustomer : mCustomerIdToCustomerMap.values()){
            prepareRequest(creditCustomer,mAccountToCustomerMap.get(creditCustomer.customer_account_id).Customer_Type,wsRequest);
        }
        invokeCreditPullService(wsRequest);
        System.debug(loggingLevel.ERROR, '-- Done invokeCreditPullService  --');
        /* Step 3 : process credit pull response by creation Credit report file */
        //if (mAccountToWSResponseMap.size() > 0){
        System.debug(loggingLevel.ERROR, '-- mActionOutput.getIsSuccess()... ' + mActionOutput.getIsSuccess());
        System.debug(loggingLevel.ERROR, '-- mWSResponse.. ' + mWSResponse);

        if ((mWSResponse != null) && (mActionOutput.getIsSuccess())){
            saveCreditPullReport();
        }
        
        System.debug(loggingLevel.ERROR, '-- Finish Credit Pull Service call... ' + system.now());
    }
    
    private void populateMaps(){
        
        mCustomerIdToCustomerMap = new Map<Id, CreditPullCustomer>();
        mAccountToCustomerMap = new Map<Id, CreditPullCustomer>();
        mCustomerToAccountMap = new Map<String,Id>();
        List<CreditPullCustomer> creditCustomerList;
        System.debug(loggingLevel.ERROR, '-- mPullEntity.. ' + mPullEntity);
        if (mPullEntity == PULL_ENTITY_APPLICATION){
            creditCustomerList = CreditPullUtil.getApplicationCustomers(mActionInput.getRecords());
        }else{
            creditCustomerList = CreditPullUtil.getContractCustomers(mActionInput.getRecords());
        }
                
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

    private void prepareRequest(CreditPullCustomer pCreditCustomer, String customerType,WS_PullCreditRequest pWsRequest){
        /* prepare request */
        String applicantSSN = '';
        if (pCreditCustomer.customer_account_national_identification_number !=  null){
                applicantSSN = pCreditCustomer.customer_account_national_identification_number.replace('-','');//SUP-19
        }
        if (mAccountToCustomerMap.containsKey(pCreditCustomer.customer_account_id)){
            if (mAccountToCustomerMap.get(pCreditCustomer.customer_account_id).is_customer_source_lending_application){
                pWsRequest.application_number = mAccountToCustomerMap.get(pCreditCustomer.customer_account_id).customer_lending_application_number_name;
            }else{
                pWsRequest.application_number = mAccountToCustomerMap.get(pCreditCustomer.customer_account_id).customer_lending_contract_number_name;
            }
        }
        
        if (pCreditCustomer.customer_account_person_other_street == null){
            throw new CreditPullException('The street address must be entered.');
        }        
        if (pCreditCustomer.customer_account_person_other_city == null){
            throw new CreditPullException('The city must be entered.');
        }        
        if (pCreditCustomer.customer_account_person_other_state_code == null){
            throw new CreditPullException('The state code must be entered.');
        }        
        if (pCreditCustomer.customer_account_person_other_postal_code == null){
            throw new CreditPullException('The zip must be entered.');
        }
        if (pCreditCustomer.customer_account_person_birthdate == null){
            throw new CreditPullException('The birth date must be entered.');   
        }
        if (applicantSSN.length() > 0 && applicantSSN.length()<>9){ //This is optional so do not throw.
            throw new CreditPullException('Invalid SSN, the SSN must of nine digits.');    //SUP-19
        }        
        system.debug(logginglevel.error,'customerType :'+customerType);
        if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equalsIgnoreCase(customerType)){
            pWsRequest.url_params.name = pCreditCustomer.customer_account_name;
            pWsRequest.url_params.address = pCreditCustomer.customer_account_person_other_street;
            pWsRequest.url_params.city = pCreditCustomer.customer_account_person_other_city;
            pWsRequest.url_params.state = pCreditCustomer.customer_account_person_other_state_code;
            pWsRequest.url_params.zip = pCreditCustomer.customer_account_person_other_postal_code;
            pWsRequest.url_params.ssn = applicantSSN;//SUP-19
            pWsRequest.url_params.birth_date = pCreditCustomer.customer_account_person_birthdate;
            pWsRequest.url_params.format = 'JSON';
            pWsRequest.url_params.pull_type = mPullType;
            pWsRequest.url_params.source = mPullSource;
        }else{
            pWsRequest.url_params.coName = pCreditCustomer.customer_account_name;
            pWsRequest.url_params.coAddress = pCreditCustomer.customer_account_person_other_street;
            pWsRequest.url_params.coCity = pCreditCustomer.customer_account_person_other_city;
            pWsRequest.url_params.coState = pCreditCustomer.customer_account_person_other_state_code;
            pWsRequest.url_params.coZip = pCreditCustomer.customer_account_person_other_postal_code;
            pWsRequest.url_params.cossn = applicantSSN;//SUP-19
            pWsRequest.url_params.coBirth_date = pCreditCustomer.customer_account_person_birthdate;

        }
        System.debug(logginglevel.error,'-- Request URL params : ' + pWsRequest.url_params);
    }    

    private void invokeCreditPullService(WS_PullCreditRequest pWsRequest){
        
        /* call credit pull webservice and get response */
        WS_PullCredit creditPullAPI = new WS_PullCredit();
        creditPullAPI.setRequest(pWsRequest);
        creditPullAPI.invoke();
        
        logmessage('####creditPullAPI#####'+creditPullAPI.getHttpResponse());
        if (creditPullAPI.getHttpResponse().getStatusCode() == 200){
            WS_PullCreditResponse wsResponse = creditPullAPI.getResponse();
        
            if (wsResponse == null){ return; }
        
            mWSResponse = wsResponse;
        }else{
            //system.debug(logginglevel.error,'********* '+creditPullAPI.getHttpResponse().getBody().message);
            mActionOutput.addError('Http '+creditPullAPI.getHttpResponse().getStatusCode()+' : '+creditPullAPI.getHttpResponse().getStatus());
            mActionOutput.setIsSuccess(false);
        }
        //mAccountToWSResponseMap.put(pAccount.Id, wsResponse);
    }
    
    private void saveCreditPullReport(){
        mAccountCPRList = new List<Credit_Pull_Report__c>();

        //for(Id accountId : mAccountMap.keySet()){
          //  if (mAccountToWSResponseMap.containsKey(accountId)){
                Id accountId = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
                Id coAccountId = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_SECONDARY);
                String hx5TransactionInfoJSON;
                String cohx5TransactionInfoJSON;
                String bureauXMLDataJSON;
                String cobureauXMLDataJSON;
                String reportContent;
                String coreportContent;
                WS_PullCreditResponse wsResponse = mWSResponse;//mAccountToWSResponseMap.get(accountId);

                logmessage('####OUTPUT#####'+wsResponse);
                if (wsResponse != null && ((wsResponse.success != null) && wsResponse.success) && wsResponse.data != null){
                    logmessage('*****1*****');
                    if (wsResponse.data.file != null){
                        if (wsResponse.data.file.hx5 != null){
                            if (wsResponse.data.file.hx5.hx5_transaction_information != null){
                                hx5TransactionInfoJSON = JSON.serialize(wsResponse.data.file.hx5.hx5_transaction_information);
                            }
                            if (wsResponse.data.file.hx5.bureau_xml_data != null){
                                bureauXMLDataJSON = JSON.serialize(wsResponse.data.file.hx5.bureau_xml_data);
                            }
                            if (wsResponse.data.file.hx5.html_reports != null){
                                if (wsResponse.data.file.hx5.html_reports.html_report != null){
                                    if (String.IsNotBlank(wsResponse.data.file.hx5.html_reports.html_report.value)){
                                        reportContent = wsResponse.data.file.hx5.html_reports.html_report.value;
                                    }
                                }
                            }
                        }
                    }

                    if (wsResponse.data.cofile != null){
                        if (wsResponse.data.cofile.hx5 != null){
                            if (wsResponse.data.cofile.hx5.hx5_transaction_information != null){
                                cohx5TransactionInfoJSON = JSON.serialize(wsResponse.data.cofile.hx5.hx5_transaction_information);
                            }
                            if (wsResponse.data.cofile.hx5.bureau_xml_data != null){
                                cobureauXMLDataJSON = JSON.serialize(wsResponse.data.cofile.hx5.bureau_xml_data);
                            }
                            if (wsResponse.data.cofile.hx5.html_reports != null){
                                if (wsResponse.data.cofile.hx5.html_reports.html_report != null){
                                    if (String.IsNotBlank(wsResponse.data.cofile.hx5.html_reports.html_report.value)){
                                        coreportContent = wsResponse.data.cofile.hx5.html_reports.html_report.value;
                                    }
                                }
                            }
                        }
                    }                    
                }      
                logmessage('*****2*****');
                if (String.isBlank(reportContent)){
                    addError(accountId, 'Unable to find credit pull report content');
                    throw new CreditPullException('Unable to find credit pull report content');
                }
                if (mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_SECONDARY) != null){
                    if (String.isBlank(coreportContent)){
                        addError(coAccountId, 'Unable to find credit pull report content for co-applicant');
                        throw new CreditPullException('Unable to find credit pull report content co-applicant');
                    }
                }
logmessage('*****3*****');
                String reportBodyContent = reportContent.substringAfter('<body>').substringBefore('</body>');
                String coreportBodyContent;
                if (mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_SECONDARY) != null){
                    coreportBodyContent = coreportContent.substringAfter('<body>').substringBefore('</body>');
                }

                String accountName = mCustomerIdToCustomerMap.get(accountId).customer_name.normalizeSpace().replace(' ','_').toUpperCase();
                String currentTime = fsCore.TypeUtil.getFormattedDatetime(System.now(), 'YYMMddhhmm');
                String reportName;
logmessage('*****4*****');
                if (mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_SECONDARY) == null){
                    reportName = String.format(Label.Credit_Pull_Report_Name_Format, new String[]{accountName, currentTime});
                }else{
                    String coAccountName = mCustomerIdToCustomerMap.get(coAccountId).customer_name.normalizeSpace().replace(' ','_').toUpperCase();
                    reportName = String.format(Label.Credit_Pull_Report_Name_Format, new String[]{accountName+'_'+coAccountName, currentTime});
                }
                Credit_Pull_Report__c accountCPR = new Credit_Pull_Report__c();
                accountCPR.Name = reportName;
                //THE RECORD TYPE NAME SHOULD MATCH Credit_Pull_Report_Record_Type_Name__c  on PRODUCT VCL-111
        	    accountCPR.RecordTypeId = Schema.SObjectType.Credit_Pull_Report__c.getRecordTypeInfosByName().get(mAccountToCustomerMap.get(accountId).customer_lending_application_number_credit_pull_record_type_name_formula).getRecordTypeId();
                    logmessage('*****5*****');    
                accountCPR.Account_Name__c = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
                accountCPR.Co_Account_Name__c = mCustomerToAccountMap.get(fsCore.Constants.CUSTOMER_TYPE_SECONDARY);
                accountCPR.Pull_Source__c = mPullSource;
                logmessage('*****6*****');
                if (mAccountToCustomerMap.containsKey(accountId)){
                    if (mAccountToCustomerMap.get(accountId).is_customer_source_lending_application){
                        accountCPR.Lending_Application_Number__c = mAccountToCustomerMap.get(accountId).customer_lending_application_number;
                    }else{
                        accountCPR.Lending_Application_Number__c = mAccountToCustomerMap.get(accountId).customer_lending_application_number;
                        accountCPR.Lending_Contract_Number__c = mAccountToCustomerMap.get(accountId).customer_lending_contract_number;
                    }
                }
                logmessage('*****7*****');
                if (String.IsNotBlank(hx5TransactionInfoJSON)){
                    accountCPR.HX5_Transaction_Info_JSON__c = (hx5TransactionInfoJSON.length() > 125000 ? hx5TransactionInfoJSON.substring(0, 125000) : hx5TransactionInfoJSON);
                }
                if (String.IsNotBlank(cohx5TransactionInfoJSON)){
                    accountCPR.HX5_Transaction_Info_JSON_CoApl__c = (cohx5TransactionInfoJSON.length() > 125000 ? cohx5TransactionInfoJSON.substring(0, 125000) : cohx5TransactionInfoJSON);
                }                
                
                if (String.IsNotBlank(bureauXMLDataJSON)){
                    accountCPR.Bureau_XML_Data_JSON__c = (bureauXMLDataJSON.length() > 125000 ? bureauXMLDataJSON.substring(0, 125000) : bureauXMLDataJSON);
                }
                if (String.IsNotBlank(cobureauXMLDataJSON)){
                    accountCPR.Bureau_XML_Data_JSON_CoApl__c = (cobureauXMLDataJSON.length() > 125000 ? cobureauXMLDataJSON.substring(0, 125000) : cobureauXMLDataJSON);
                }                
                logmessage('*****8*****');
                //split report conent into 3 long text area fields (total available character limit 375000)
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
                logmessage('*****9*****');
                if (String.IsNotBlank(coreportBodyContent)){
                    if (coreportBodyContent.length() > 125000){
                        accountCPR.Report_Content_CoApl_1__c = coreportBodyContent.substring(0, 125000);
                        coreportBodyContent = coreportBodyContent.substring(125000);
                        
                        if (coreportBodyContent.length() > 125000){
                            accountCPR.Report_Content_CoApl_2__c = coreportBodyContent.substring(0, 125000);
                            coreportBodyContent = coreportBodyContent.substring(125000);
                            
                            accountCPR.Report_Content_CoApl_3__c = (coreportBodyContent.length() > 125000 ? coreportBodyContent.substring(0, 125000) : coreportBodyContent);
                        } else {
                            accountCPR.Report_Content_CoApl_2__c = coreportBodyContent;
                        }
                    } else {
                        accountCPR.Report_Content_CoApl_1__c = coreportBodyContent;
                    }
                }      
                logmessage('*****10*****');                           
                mAccountCPRList.add(accountCPR);
            //}
            //else {
                //addError(accountId, 'Unable to process the credit pull request');
            //}
        //}
        system.debug(logginglevel.error,'mAccountCPRList :'+mAccountCPRList);
        Database.insert(mAccountCPRList, true);
        Set<Id> newCPRIds = new Set<Id>();
        for (Credit_Pull_Report__c cpReport : mAccountCPRList){
            newCPRIds.add(cpReport.Id);
        }
        mAccountCPRList = [SELECT Id, Name FROM Credit_Pull_Report__c WHERE Id = :newCPRIds];
    }

    private void addError(Id pAccountId, String pErrorMsg){
        fsCore.ErrorObject errObj = new fsCore.ErrorObject();
        if (mAccountToCustomerMap.containsKey(pAccountId)){
            pErrorMsg += (' (Customer # ' + mAccountToCustomerMap.get(pAccountId).customer_name + ')');
            errObj.setErrorRecordId(mAccountToCustomerMap.get(pAccountId).customer_lending_application_number);
            errObj.setErrorRecordName(mAccountToCustomerMap.get(pAccountId).customer_lending_application_number_name);
        }
        errObj.setErrorMessage(pErrorMsg);
        errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
        errObj.setErrorStackTrace('CreditPullAction.process()');
        mActionOutput.addError(errObj);
    }
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('CreditPullAction', 'process', mActionOutput.getErrors());
        }
    }
    
    public List<Credit_Pull_Report__c> getCreditPullReportRecords(){
        return mAccountCPRList;
    }
    private static void logmessage (Object pMessage){
        system.debug(logginglevel.error,pMessage);
    }     
    public class CreditPullException extends Exception{}
}