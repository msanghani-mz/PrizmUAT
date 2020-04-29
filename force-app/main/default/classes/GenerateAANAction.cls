/*
* Class   : GenerateAAN
* Purpose : Action class to generate AAN PDFin Box
* Author  : Financial Spectra
*/

public class GenerateAANAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    
    
    public GenerateAANAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }
    
    public void process(){
        System.debug(loggingLevel.ERROR, '-- Start aan generation... ' + system.now());
        fsCore__Lending_Application__c app  =  [SELECT Id, BoxFolderId__c
                                                FROM fsCore__Lending_Application__c
                                                WHERE Id IN :mActionInput.getRecords()];
        
        
        PageReference AANPDF = Page.aanPDFPage;
        AANPDF.getParameters().put('id', app.Id);
        Blob AANReport;
        if(test.isRunningTest()){
            
        }
        else{
            AANReport = AANPDF.getContent(); 
        }
        
        //NOW MOVE THE DOCUMENT TO THE BOX.COM
        createPDFReportsInBox(AANReport,app.BoxFolderId__c);
        
        System.debug(loggingLevel.ERROR, '-- Finish credit report generation... ' + system.now());
    }
    
    
    private void createPDFReportsInBox( Blob AANReport, String pBoxFolderId){
        Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
        System.debug('objBoxsettings:==='+objBoxsettings);
        if(objBoxsettings.id !=null){
            BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
            api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
            api.setAccessToken(objBoxsettings.access_token1__c);
            api.setExpires(long.valueOf(objBoxsettings.expires__c));
            
            BoxFolder box = new BoxFolder(api, pBoxFolderId);//'54555930164');
            BoxFile.Info bxInfo = box.uploadFile(AANReport, 'AAN.pdf');
            
        }        
    }
    
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
}