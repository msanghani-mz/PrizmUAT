/*
* Class   : CreditAnalysisAction
* Purpose : Action class to invoke the credit analysis service for the input customer credit pull records
* Author  : Financial Spectra
*/
public class CreditAnalysisAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    
    public CreditAnalysisAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    
    //set the ids of the applications 
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }
    
    public void process(){
        Map<Id, Map<String, Credit_Pull_Report__c>> appToApplicantCreditReportsMap
            = CreditAnalysisUtil.getCreditReports(mActionInput.getRecords());
        
        Map<Id, fsCore__Lending_Application__c> applicationMap 
            = new Map<Id, fsCore__Lending_Application__c>([SELECT Id
                                                                , name
                                                                , Credit_Analysis_Decision__c 
                                                                , MLA_Match__c
                                                           FROM fsCore__Lending_Application__c
                                                           WHERE Id IN :mActionInput.getRecords()]);
        
        List<Credit_Pull_Report__c> creditReportsForUpdate = new List<Credit_Pull_Report__c>();
        List<fsCore__Lending_Application__c> applicationsForUpdate = new List<fsCore__Lending_Application__c>();
        
        //instantiate the web service
        WS_AnalyzeCredit creditAnalysisAPI = new WS_AnalyzeCredit();
        
        if (creditAnalysisAPI.mIsAccessTokenSucess){
            
            for(Id applicationId : mActionInput.getRecords()){
                if (applicationMap.containsKey(applicationId) && appToApplicantCreditReportsMap.containsKey(applicationId)){
                    
                    Map<String, Credit_Pull_Report__c> creditReportByApplicantTypeMap = appToApplicantCreditReportsMap.get(applicationId);
                    
                    Credit_Pull_Report__c creditReport = creditReportByApplicantTypeMap.get(CreditAnalysisUtil.PRIMARY_APPLICANT);
                    
                    Boolean mlaMatch = false; //(DV-425)
                    creditAnalysisAPI.setRequest(getWSRequest(applicationMap.get(applicationId).name));
                    creditAnalysisAPI.invoke();
                    if (creditAnalysisAPI.mIsCreditAnalysisSucess){
                        WS_AnalyzeCreditResponse wsResponse = creditAnalysisAPI.getResponse();
                        
                        String primaryApplicantDecision;
                        String coApplicantDecision;
                        
                        String primaryApplicantDecisionReason;
                        String coApplicantDecisionReason;
                        
                        
                        if (wsResponse != null){
                            if (wsResponse.applicant != null){
                                primaryApplicantDecision = getDecision(wsResponse.applicant);
                                primaryApplicantDecisionReason = getDecisionReason(wsResponse.applicant);
                                creditReport.Is_Analyzed__c = true;
                                creditReport.Analyzed_On__c = System.now();
                                creditReport.Applicant_Analysis_Decision__c = primaryApplicantDecision;
                                creditReport.Applicant_Analysis_Decision_Reason__c = primaryApplicantDecisionReason;
                                creditReport.Applicant_Analysis_Response_JSON__c = JSON.serialize(wsResponse.applicant, true);
                                creditReport.Applicant_MLA_Match__c = wsResponse.applicant.MLAMatch;//DV-68
                                creditReport.Applicant_Inquiries_last_6m__c = wsResponse.applicant.Inquiries_last_6m;
                                creditReport.Applicant_Total_Installment_Balance__c = wsResponse.applicant.Total_Installment_Balance;
                                creditReport.Applicant_Total_Revolving_Balance__c = wsResponse.applicant.Total_Revolving_Balance;
                                creditReport.App_Current_Delinquencies_Installment__c = wsResponse.applicant.Current_Delinquencies_Installment;
                                creditReport.App_Current_Delinquencies_Revolving__c = wsResponse.applicant.Current_Delinquencies_Revolving;
                                creditReport.Applicant_Public_Records__c = wsResponse.applicant.Public_Records;
                                creditReport.Applicant_Bankruptcies__c = wsResponse.applicant.Bankruptcies;
                                creditReport.Applicant_Real_Estate_Balance__c = wsResponse.applicant.Real_Estate_Balance;
                                creditReport.Applicant_Real_Estate_Payments__c = wsResponse.applicant.Real_Estate_Payments;
                                creditReport.Applicant_Age_of_the_Credit_report__c = wsResponse.applicant.Age_of_the_Credit_Report;
                                creditReport.Applicant_FICO_Score__c = wsResponse.applicant.FicoScore;
                                
                                System.debug(loggingLevel.ERROR, 'creditReport.Applicant_MLA_Match__c : ' + creditReport.Applicant_MLA_Match__c);
                                if (creditReport.Applicant_MLA_Match__c == null){
                                    System.debug(loggingLevel.ERROR, 'Setting it to false');
                                    creditReport.Applicant_MLA_Match__c = false;
                                }
                                System.debug(loggingLevel.ERROR, 'Final creditReport.Applicant_MLA_Match__c : ' + creditReport.Applicant_MLA_Match__c);
                            }
                            if (wsResponse.coApplicant != null){
                                coApplicantDecision = getDecision(wsResponse.coApplicant);
                                coApplicantDecisionReason = getDecisionReason(wsResponse.coApplicant);
                                creditReport.CoApplicant_Analysis_Decision__c = coApplicantDecision;
                                creditReport.CoApplicant_Analysis_Decision_Reason__c = coApplicantDecisionReason;
                                creditReport.CoApplicant_Analysis_Response_JSON__c = JSON.serialize(wsResponse.coApplicant, true);
                                creditReport.CoApplicant_MLA_Match__c = wsResponse.coApplicant.MLAMatch;//DV-68
                                creditReport.Co_Applicant_Inquiries_last_6m__c = wsResponse.coApplicant.Inquiries_last_6m;
                                creditReport.Co_Applicant_Total_Installment_Balance__c = wsResponse.coApplicant.Total_Installment_Balance;
                                creditReport.Co_Applicant_Total_Revolving_Balance__c = wsResponse.coApplicant.Total_Revolving_Balance;
                                creditReport.Co_App_Current_Delinquencies_Installment__c = wsResponse.coApplicant.Current_Delinquencies_Installment;
                                creditReport.Co_App_Current_Delinquencies_Revolving__c = wsResponse.coApplicant.Current_Delinquencies_Revolving;
                                creditReport.Co_Applicant_Public_Records__c = wsResponse.coApplicant.Public_Records;
                                creditReport.Co_Applicant_Bankruptcies__c = wsResponse.coApplicant.Bankruptcies;
                                creditReport.Co_Applicant_Real_Estate_Balance__c = wsResponse.coApplicant.Real_Estate_Balance;
                                creditReport.Co_Applicant_Real_Estate_Payments__c = wsResponse.coApplicant.Real_Estate_Payments;
                                creditReport.Co_Applicant_Age_of_the_Credit_report__c = wsResponse.coApplicant.Age_of_the_Credit_Report;
                                creditReport.Co_Applicant_FICO_Score__c = wsResponse.coApplicant.FicoScore;

                                System.debug(loggingLevel.ERROR, 'creditReport.CoApplicant_MLA_Match__c : ' + creditReport.CoApplicant_MLA_Match__c);
                                if (creditReport.CoApplicant_MLA_Match__c == null){
                                    System.debug(loggingLevel.ERROR, 'Setting it to false');
                                    creditReport.CoApplicant_MLA_Match__c = false;
                                }
                                System.debug(loggingLevel.ERROR, 'Final creditReport.CoApplicant_MLA_Match__c : ' + creditReport.CoApplicant_MLA_Match__c);
                            }
                            System.debug(loggingLevel.ERROR, 'creditReport : ' + creditReport);

                            //(DV-425)
                            if (creditReport.Applicant_MLA_Match__c || creditReport.CoApplicant_MLA_Match__c){
                                mlaMatch = true;
                            }
                            
                            creditReportsForUpdate.add(creditReport);
                        }
                        String decisionForApplication = CreditAnalysisUtil.getDecision(primaryApplicantDecision, coApplicantDecision);
                        
                        fsCore__Lending_Application__c application = applicationMap.get(applicationId);
                        System.debug(loggingLevel.ERROR, 'mlaMatch : ' + mlaMatch);

                        application.MLA_Match__c = mlaMatch;
                        
                        application.Credit_Analysis_Decision__c = decisionForApplication;
                        applicationsForUpdate.add(application);
                    }else{
                        mActionOutput.addError('Error while invoking credit analysis service Response : '+creditAnalysisAPI.mCreditAnalysisResponseStatus);
                    }
                    //}
                } 
                else {
                    mActionOutput.addError('Unable to find the Credit Report(s) for the Application (Id: ' + String.valueOf(applicationId) + ').');
                }
            }
        }else{
            mActionOutput.addError('Cannot get access token, please check credentials. Response : '+creditAnalysisAPI.mAccessTokeResponseStatus);
        }
        
        if (mActionOutput.getIsSuccess()){
            Savepoint sp = Database.setSavepoint();
            try{
                if (creditReportsForUpdate.size() > 0){
                    Database.update(creditReportsForUpdate);
                }
                if (applicationsForUpdate.size() > 0){
                    Database.update(applicationsForUpdate);
                }
            }
            catch (Exception e){
                System.debug(loggingLevel.ERROR, 'EXCEPTION : CreditAnalysisAction.process() : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                Database.rollback(sp);
                mActionOutput.addError(e);
            }
        }
    }
    
    private WS_AnalyzeCreditRequest getWSRequest(String pApplicationName){
        WS_AnalyzeCreditRequest wsRequest = new WS_AnalyzeCreditRequest();
        wsRequest.application_number = pApplicationName;
        return wsRequest;
    }
    
    private String getDecision(WS_AnalyzeCreditResponse.ApplicantResponse pApplicantResponse){
        system.debug(logginglevel.error,'immediateFailure :'+pApplicantResponse.immediateFailure);
        system.debug(logginglevel.error,'tobeReviewed :'+pApplicantResponse.tobeReviewed);
        if (pApplicantResponse.immediateFailure != null && pApplicantResponse.immediateFailure.size() > 0){
            return CreditAnalysisUtil.DECISION_DECLINED;
        } else if (pApplicantResponse.tobeReviewed != null && pApplicantResponse.tobeReviewed.size() > 0){
            return CreditAnalysisUtil.DECISION_REVIEW;
        } else {
            return CreditAnalysisUtil.DECISION_PASS;
        }
    }
    
    private String getDecisionReason(WS_AnalyzeCreditResponse.ApplicantResponse pApplicantResponse){
        if (pApplicantResponse.immediateFailure != null && pApplicantResponse.immediateFailure.size() > 0){
            return getAppendedString(pApplicantResponse.immediateFailure);
        } else if (pApplicantResponse.tobeReviewed != null && pApplicantResponse.tobeReviewed.size() > 0){
            return getAppendedString(pApplicantResponse.tobeReviewed);
        } else {
            return '';
        }
    }
    private String getAppendedString(String[] pInputArray){
        system.debug(logginglevel.error,'pInputArray :> '+pInputArray);
        return string.join(pInputArray,';');
    }
    
    
    
    private String getDateOfBirthString(Date pBirthDate){
        //YYYY-MM-DDT00:00:00 format
        String yearStr = String.valueOf(pBirthDate.year());
        Integer month = pBirthDate.month();
        String monthStr = (month >= 10 ? String.valueOf(month) : '0' + String.valueOf(month));
        Integer day = pBirthDate.day();
        String dayStr = (day >= 10 ? String.valueOf(day) : '0' + String.valueOf(day));
        
        String dobStr = yearStr + '-' + monthStr + '-' + dayStr + 'T00:00:00';
        return dobStr;
    }
    
    private String getXMLDataString(Credit_Pull_Report__c pCRPData){
        XmlSerializer serializer = new XmlSerializer();
        String hx5TxnInfoXMLString = serializer.JSONToXML(pCRPData.HX5_Transaction_Info_JSON__c);
        
        WS_PullCreditResponse.BureauXMLData bureauXMLData = (WS_PullCreditResponse.BureauXMLData)JSON.deserialize(pCRPData.Bureau_XML_Data_JSON__c, WS_PullCreditResponse.BureauXMLData.class);
        
        String bureauDataXMLString = serializer.serialize(bureauXMLData);
        
        
        //String xmlDataString = '<?xml version=\\"1.0\\"?><HX5 version=\\"5.4\\">'; 
        //String xmlDataString = '<HX5 version=\\"5.4\\">'; 
        String xmlDataString = '<HX5>'; 
        xmlDataString += '<HX5_transaction_information>' + hx5TxnInfoXMLString + '</HX5_transaction_information>';
        xmlDataString += '<bureau_xml_data>' + bureauDataXMLString + '</bureau_xml_data >';
        xmlDataString += '</HX5>';
        
        System.debug(loggingLevel.ERROR, '-- XML Data String : ' + xmlDataString);        
        return xmlDataString;
    }
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('CreditAnalysisAction', 'process', mActionOutput.getErrors());
        }
    }
    
}