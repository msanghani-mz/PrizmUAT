/**
* @File Name          : GetVCLCreditReportQueueable.cls
* @Description        : This Job get the Credit Report for the application
* @Author             : financial Spectra
**/
public with sharing class GetVCLCreditReportQueueable implements Queueable ,Database.AllowsCallouts{
    private Id appId;
    private fsCore__Lending_Application__c app;
    private Set<Id> mRecordIds;
    
    public GetVCLCreditReportQueueable(Set<Id> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }
    public void execute(QueueableContext context) {
        try{
            fsCore.ActionInput acInput = new fsCore.ActionInput();
            appId =  (new list<Id>(mRecordIds))[0];
            app = [Select id , Name from fsCore__Lending_Application__c where id =:appId];
            acInput.addRecord(appId);
            
            
            fsCore.ActionOutput acOutput = new fsCore.ActionOutput();
            GetCreditReportAction creditReportAction = new GetCreditReportAction();
            
            
            creditReportAction.setInput(acInput);
            creditReportAction.process();
            acOutput = creditReportAction.getOutput();
            System.debug(loggingLevel.ERROR, 'acOutput '+ acOutput);
            if (!acOutput.getIsSuccess()){
                fsCore.DiagnosticLogUtil.logError('GetVCLCreditReportQueueable', 'execute', appId, app.Name, fsCore.Constants.PROCESSING_ERROR, acOutput.getMessage(),null); 
            }
            
            List<Credit_Pull_Report__c> cpReports = creditReportAction.getCreditPullReportRecords();
            System.debug(loggingLevel.ERROR, 'cpReports-- > '+ cpReports);
            if ( ((cpReports != null) && (!cpReports.isEmpty())) && (acOutput.getIsSuccess())){
                System.debug(loggingLevel.ERROR, 'inside if '); 
                System.debug(loggingLevel.ERROR, 'cpReports Report'+ cpReports.get(0).Id);
                generateReportPDF(cpReports.get(0).Id , appId);
                
            }
            
        }catch(Exception ex){
            
            fsCore.DiagnosticLogUtil.logError('GetVCLCreditReportQueueable', 'execute', appId, app.Name, fsCore.Constants.PROCESSING_ERROR, ex.getMessage(),ex.getStackTraceString());            
            
        }
        
        
    }
    
    @future(callout=true)
    public static void generateReportPDF(Id pReportId , Id appId){
        System.debug(loggingLevel.ERROR, '1 ');
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        
        try{
            System.debug(loggingLevel.ERROR, '2 ');   
            Set<Id> reportIdSet = new Set<Id>();
            reportIdSet.add(pReportId);
            System.debug(loggingLevel.ERROR, '-- Credit Pull Report Ids : ' + reportIdSet);
            System.debug(loggingLevel.ERROR, '3 '); 
            fsCore.ActionInput actionIP = new fsCore.ActionInput();
            actionIP.addRecords(reportIdSet);
            System.debug(loggingLevel.ERROR, '4 '); 
            GenerateCreditReportAction pdfGenAction = new GenerateCreditReportAction();
            pdfGenAction.setInput(actionIP);
            pdfGenAction.process();
            System.debug(loggingLevel.ERROR, '5 '); 
            
            actionOP = pdfGenAction.getOutput();
            
            analyzeCreditReport(appId);                        
        } 
        catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            actionOP.addError(e);
        }
        
        
    }  
    
    public static void analyzeCreditReport(id pApplicationId){
        
        System.debug(loggingLevel.ERROR, 'analyze credit Report');
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        acrInput.addRecord(pApplicationId);
        
        CreditAnalysisAction analysisAction = new CreditAnalysisAction();
        analysisAction.setInput(acrInput);
        analysisAction.process();
        
        fsCore.ActionOutput acrOutput = analysisAction.getOutput();       
        fsCore__Lending_Application__c application = [SELECT id , Name,Credit_Analysis_Decision__c FROM fsCore__Lending_Application__c WHERE Id = :pApplicationId];  
        if (!acrOutput.getIsSuccess()){ 
            
            fsCore.DiagnosticLogUtil.logError('GetVCLCreditReportQueueable', 'analyzeCreditReport', pApplicationId, application.Name, fsCore.Constants.PROCESSING_ERROR, acrOutput.getJSONString(),null); 
        }
        
    }
    
}