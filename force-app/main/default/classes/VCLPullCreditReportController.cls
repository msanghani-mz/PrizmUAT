/*
 * Class   : VCLPullCreditReportController
 * Purpose : This is a controller class for lightning component - getCreditReport
 * Author  : Financial Spectra
 */
public with sharing class VCLPullCreditReportController {
    @AuraEnabled
    public static String fetchCreditReport(Id pApplicationId) {
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecord(pApplicationId);
        
        fsCore.ActionOutput acOutput = new fsCore.ActionOutput();
        GetCreditReportAction creditReportAction = new GetCreditReportAction();
        try{
            
            creditReportAction.setInput(acInput);
            creditReportAction.process();
            acOutput = creditReportAction.getOutput();
            if (acOutput.getIsSuccess()){
                acOutput.setMessage(Label.VCL_Credit_Report_Pull_Success_Message);
            }
        } catch (Exception e){
            acOutput.addError(e);
        }
        
        List<Credit_Pull_Report__c> cpReports = creditReportAction.getCreditPullReportRecords();
        System.debug(loggingLevel.ERROR, 'cpReports-- > '+ cpReports);
        if ( ((cpReports != null) && (!cpReports.isEmpty())) && (acOutput.getIsSuccess())){
            System.debug(loggingLevel.ERROR, 'cpReports Report'+ cpReports.get(0).Id);
            acOutput.setRecordId(cpReports.get(0).Id);
        }
        
        System.debug(loggingLevel.ERROR, 'CreditPullController.pullCreditReport(-)'+ acOutput.getJSONString());
                
        return acOutput.getJSONString();
    }
    @AuraEnabled
    public static String generateReportPDF(String pReportId){
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        
        try{
            //List<Credit_Pull_Report__c> creditPullReports =
            //    (List<Credit_Pull_Report__c>)JSON.deserialize(pCreditPullReportsJSON, List<Credit_Pull_Report__c>.class);
            
            Set<Id> reportIdSet = new Set<Id>();
            reportIdSet.add(Id.ValueOf(pReportId));
            //for(Credit_Pull_Report__c cpReport : creditPullReports){
                
            //}
            System.debug(loggingLevel.ERROR, '-- Credit Pull Report Ids : ' + reportIdSet);
            
            fsCore.ActionInput actionIP = new fsCore.ActionInput();
            actionIP.addRecords(reportIdSet);
            
            GenerateCreditReportAction pdfGenAction = new GenerateCreditReportAction();
            pdfGenAction.setInput(actionIP);
            pdfGenAction.process();
            
            actionOP = pdfGenAction.getOutput();
        } 
        catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            actionOP.addError(e);
        }
        
        if (actionOP.getIsSuccess()){
            actionOP.setMessage(Label.Action_Completed_Title);
            actionOP.setMessageDetails(Label.Credit_Pull_Success_Message);
        }
        
        return actionOP.getJSONString();
    }    
}