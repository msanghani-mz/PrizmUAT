public with sharing class CreditAnalysisControllerForContract {

    @AuraEnabled
    public static String getCreditReportInfo(Id pConId){
        
        fsServ__Lending_Contract__C mContract = [Select id, fsServ__Lending_Application_Number__c from fsServ__Lending_Contract__C where id = :pConId];
        Map<String, Credit_Pull_Report__c> applicantToCreditReportMap = CreditAnalysisUtil.getCreditReports(mContract.fsServ__Lending_Application_Number__c);
        System.debug(loggingLevel.ERROR, 'Credit Reports Map : ' + applicantToCreditReportMap);
        
        CreditReportInfo crInfo = new CreditReportInfo();
        if (applicantToCreditReportMap != null){
            if (applicantToCreditReportMap.containsKey(CreditAnalysisUtil.PRIMARY_APPLICANT)){
                Credit_Pull_Report__c applicantCPR = applicantToCreditReportMap.get(CreditAnalysisUtil.PRIMARY_APPLICANT);
                crInfo.applicantCreditReportId = String.valueOf(applicantCPR.Id);
                crInfo.applicantCreditReportExists = true;
                crInfo.applicantCreditReportAnalyzed = applicantCPR.Is_Analyzed__c;
            }            
            if (applicantToCreditReportMap.containsKey(CreditAnalysisUtil.CO_APPLICANT)){
                Credit_Pull_Report__c coApplicantCPR = applicantToCreditReportMap.get(CreditAnalysisUtil.CO_APPLICANT);
                crInfo.coApplicantExists = true;
                crInfo.coApplicantCreditReportId = String.valueOf(coApplicantCPR.Id);
                crInfo.coApplicantCreditReportExists = true;
            }
        } 

        return JSON.serialize(crInfo);
    }
    
    public class CreditReportInfo {
        public String  applicantCreditReportId;
        public Boolean applicantCreditReportExists;
        public Boolean applicantCreditReportAnalyzed;
        public Boolean coApplicantExists;
        public String  coApplicantCreditReportId;
        public Boolean coApplicantCreditReportExists;
        
        public CreditReportInfo(){
            applicantCreditReportId = null;
            applicantCreditReportExists = false;
            applicantCreditReportAnalyzed = false;
            coApplicantExists = false;
            coApplicantCreditReportId = null;
            coApplicantCreditReportExists = false;
        }
    }

    @AuraEnabled
    public static String analyzeCreditReport(Id pConId){
        
        fsServ__Lending_Contract__C mContract = [Select id, fsServ__Lending_Application_Number__c from fsServ__Lending_Contract__C where id = :pConId];
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        id pApplicationId = mContract.fsServ__Lending_Application_Number__c;
        acrInput.addRecord(pApplicationId);
        
        CreditAnalysisAction analysisAction = new CreditAnalysisAction();
        analysisAction.setInput(acrInput);
        analysisAction.process();
        
        fsCore.ActionOutput acrOutput = analysisAction.getOutput();
        if (acrOutput.getIsSuccess()){
            fsCore__Lending_Application__c application = [SELECT Credit_Analysis_Decision__c FROM fsCore__Lending_Application__c WHERE Id = :pApplicationId];
            if (String.IsNotBlank(application.Credit_Analysis_Decision__c)){
                acrOutput.setMessage(application.Credit_Analysis_Decision__c);
                acrOutput.setMessageDetails(String.format(Label.Credit_Analysis_Success_For_Contract, new String[]{application.Credit_Analysis_Decision__c}));
            }
        }
        return acrOutput.getJSONString();
    }
        
}