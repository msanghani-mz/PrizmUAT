/**
 * @File Name          : CreditAnalysisUtil.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2/27/2020, 1:56:42 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/26/2019, 12:08:54 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class CreditAnalysisUtil {

    public static final String PRIMARY_APPLICANT  = 'Applicant';
    public static final String CO_APPLICANT       = 'Co-Applicant';
    
    public static Map<String, Credit_Pull_Report__c> getCreditReports(Id pApplicationId){
        return getCreditReports(new Set<Id>{pApplicationId}).get(pApplicationId);
    }

    public static Map<Id, Map<String, Credit_Pull_Report__c>> getCreditReports(Set<Id> pApplicationIds){
        List<fsCore__Lending_Application_Customer__c> applicants = 
            [SELECT Id, fsCore__Lending_Application_Number__c
                  , fsCore__Account_Name__c
                  , fsCore__Is_Primary__c
               FROM fsCore__Lending_Application_Customer__c
              WHERE fsCore__Lending_Application_Number__c IN :pApplicationIds
              ORDER BY fsCore__Customer_Record_Type__c DESC, Name ASC];
        
        Set<Id> accountIdSet = new Set<Id>();
        
        for(fsCore__Lending_Application_Customer__c applicant : applicants){
            accountIdSet.add(applicant.fsCore__Account_Name__c);
        }
        System.debug(loggingLevel.ERROR, 'Applicant(s) : ' + accountIdSet);
        
        List<Credit_Pull_Report__c> creditPullReports = [SELECT Id, Account_Name__c
                                                              , Account_Name__r.FirstName
                                                              , Account_Name__r.LastName
                                                              , Account_Name__r.PersonBirthdate
                                                              , Account_Name__r.PersonOtherStreet
                                                              , Account_Name__r.PersonOtherCity
                                                              , Account_Name__r.PersonOtherStateCode
                                                              , Account_Name__r.PersonOtherPostalCode
                                                              , HX5_Transaction_Info_JSON__c
                                                              , Bureau_XML_Data_JSON__c
                                                              , Is_Analyzed__c
                                                              , Analyzed_On__c
                                                              , Applicant_Analysis_Decision__c
                                                              , CoApplicant_Analysis_Decision__c
                                                              , Applicant_Analysis_Response_JSON__c
                                                              , CoApplicant_Analysis_Response_JSON__c
                                                              , Applicant_Analysis_Decision_Reason__c
                                                              , CoApplicant_Analysis_Decision_Reason__c
                                                              , Applicant_MLA_Match__c
                                                              , Applicant_Inquiries_last_6m__c
                                                              , Applicant_Total_Installment_Balance__c
                                                              , Applicant_Total_Revolving_Balance__c
                                                              , App_Current_Delinquencies_Installment__c
                                                              , App_Current_Delinquencies_Revolving__c
                                                              , Applicant_Public_Records__c
                                                              , Applicant_Bankruptcies__c
                                                              , Applicant_Real_Estate_Balance__c
                                                              , Applicant_Real_Estate_Payments__c
                                                              , Applicant_Age_of_the_Credit_report__c
                                                              , Applicant_FICO_Score__c
                                                              , CoApplicant_MLA_Match__c
                                                              , Co_Applicant_Inquiries_last_6m__c
                                                              , Co_Applicant_Total_Installment_Balance__c
                                                              , Co_Applicant_Total_Revolving_Balance__c
                                                              , Co_App_Current_Delinquencies_Installment__c
                                                              , Co_App_Current_Delinquencies_Revolving__c
                                                              , Co_Applicant_Public_Records__c
                                                              , Co_Applicant_Bankruptcies__c
                                                              , Co_Applicant_Real_Estate_Balance__c
                                                              , Co_Applicant_Real_Estate_Payments__c
                                                              , Co_Applicant_Age_of_the_Credit_report__c
                                                              , Co_Applicant_FICO_Score__c
                                                           FROM Credit_Pull_Report__c
                                                          WHERE Account_Name__c IN :accountIdSet
                                                          ORDER BY CreatedDate DESC];
        
        Map<Id, Credit_Pull_Report__c> applicantToCreditReportMap = new Map<Id, Credit_Pull_Report__c>();
        for (Credit_Pull_Report__c report : creditPullReports){
            //only add the latest report to the map
            if (!applicantToCreditReportMap.containsKey(report.Account_Name__c)){
                applicantToCreditReportMap.put(report.Account_Name__c, report);
            }
        }

        Map<Id, Map<String, Credit_Pull_Report__c>> appToApplicantCreditReportsMap
            = new Map<Id, Map<String, Credit_Pull_Report__c>>();

        for(fsCore__Lending_Application_Customer__c applicant : applicants){
            Map<String, Credit_Pull_Report__c> creditReportByApplicantTypeMap = new Map<String, Credit_Pull_Report__c>();
            
            if (appToApplicantCreditReportsMap.containsKey(applicant.fsCore__Lending_Application_Number__c)){
                creditReportByApplicantTypeMap = appToApplicantCreditReportsMap.get(applicant.fsCore__Lending_Application_Number__c);
            }
            
            if (applicant.fsCore__Is_Primary__c && !creditReportByApplicantTypeMap.containsKey(PRIMARY_APPLICANT) 
                    && applicantToCreditReportMap.containsKey(applicant.fsCore__Account_Name__c)){
                creditReportByApplicantTypeMap.put(PRIMARY_APPLICANT, applicantToCreditReportMap.get(applicant.fsCore__Account_Name__c));
            }
            if (!applicant.fsCore__Is_Primary__c && !creditReportByApplicantTypeMap.containsKey(CO_APPLICANT) 
                    && applicantToCreditReportMap.containsKey(applicant.fsCore__Account_Name__c)){
                creditReportByApplicantTypeMap.put(CO_APPLICANT, applicantToCreditReportMap.get(applicant.fsCore__Account_Name__c));
            }
            
            appToApplicantCreditReportsMap.put(applicant.fsCore__Lending_Application_Number__c, creditReportByApplicantTypeMap);
        }

        return appToApplicantCreditReportsMap;
    }
    
    public static final String DECISION_PASS     = 'Pass';
    public static final String DECISION_REVIEW   = 'Judgmental Review';
    public static final String DECISION_DECLINED = 'Hard Decline';
    
    /*
     * Method to get the a combined credit analysis decision 
     * If Applicant is Pass AND Co-Applicant is Pass, Decision is Pass
     * Else If Applicant is Hard Decline OR Co-Applicant is Hard Decline, Decision is Hard Decline
     * Else Decision is Judgmental Review
     */
    public static String getDecision(String pApplicantDecision, String pCoApplicantDecision){
        system.debug(Logginglevel.error,'pApplicantDecision :'+pApplicantDecision) ;
        system.debug(Logginglevel.error,'pCoApplicantDecision :'+pCoApplicantDecision) ;
        String creditAnalysisDecision = '';
        
        if (String.IsBlank(pApplicantDecision)){
            return null;
        }
        else if (String.IsBlank(pCoApplicantDecision)){
            return pApplicantDecision;
        }
        else {
            if (pApplicantDecision == DECISION_PASS && pCoApplicantDecision == DECISION_PASS){
                creditAnalysisDecision = DECISION_PASS;
            } else if (pApplicantDecision == DECISION_DECLINED || pCoApplicantDecision == DECISION_DECLINED){
                creditAnalysisDecision = DECISION_DECLINED;
            } else {
                creditAnalysisDecision = DECISION_REVIEW;
            }
        }

        return creditAnalysisDecision;
    }
}