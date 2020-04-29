/**
 * Class Name  : RefreshDraftFeesAction
 * Description : Refactored Class to refresh the draft fee object from NuDebt
 *             : This class will be accessed from the Prizm_PullProgramFeesBatch and from the RefreshTradelinesAction
 * Author      : Financial Spectra
 */
public with sharing class RefreshDraftFeesAction implements fsCore.ActionProcessor{

    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;

 
    public class RefreshDraftFeesException extends Exception{}
    
    public RefreshDraftFeesAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    
    //action input has the set of application ids
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }
    
    public void process(){
        System.debug(loggingLevel.ERROR, '-- RefreshDraftFeesAction.process(+)');
        
        RestIntegrationInformation__mdt restIntegration = [select System_Endpoint__c,EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(restIntegration.AccesstokenURL__c); //Change "ap4" in url to your Target Org Instance 
        String accessToken;
        if(!test.isRunningTest()){
            HttpResponse res=h.send(req);
            Prizm_PullProgramFeesBatch.deserializeResponse resp1=(Prizm_PullProgramFeesBatch.deserializeResponse)JSON.deserialize(res.getBody(),Prizm_PullProgramFeesBatch.deserializeResponse.class);
            accessToken=resp1.access_token;
        } else {
            accessToken='Test';
        }
        
        
        String jsonstr = JSON.serialize(mActionInput.getRecords(),true);

        List<Prizm_PullProgramFeesBatch.DraftFees> DraftFeesList = new List<Prizm_PullProgramFeesBatch.DraftFees>();
        //Making a callout
        if(test.isRunningTest()){
            
            String dummyResp = '[{"TotalThirdPartyFee":"0.00","TotalServiceFee":"1490.61","TotalRetainerFee":"995.00","TotalProgramFee":"0.00","TotalProcessorFee":"262.80","TotalMaintenanceFee":"0.00","TotalCreditorPayments":null,"TotalAdminFee":"1430.00","TotalAccumulation":"5691.42","RemainingThirdPartyFee":"0.00","RemainingServiceFee":"1490.61","RemainingRetainerFee":"995.00","RemainingProgramFee":"0.00","RemainingProcessorFee":"251.85","RemainingMaintenanceFee":"0.00","RemainingCreditorPayments":"0.00","RemainingAdminFee":"1430.00","RemainingAccumulation":"5544.82","ProgramId":"a0L1K00000G5IgXUAV","PaidThirdPartyFee":null,"PaidServiceFee":null,"PaidRetainerFee":null,"PaidProgramFee":null,"PaidProcessorFee":"10.95","PaidMaintenanceFee":null,"PaidCreditorPayments":null,"PaidAdminFee":null,"PaidAccumulation":"146.60"}]';            

            DraftFeesList = (List<Prizm_PullProgramFeesBatch.DraftFees>)json.deserialize(dummyResp, List<Prizm_PullProgramFeesBatch.DraftFees>.class);
            
        }else{
            if(accessToken!=null){
                String endPoint=restIntegration.System_Endpoint__c+'/pullProgramFees';//+'?oppId='+ids; 
                //String jsonstr= getOppDataJSON(oppLst);
                Http h2= new Http();
                HttpRequest req2= new HttpRequest();
                req2.setHeader('Authorization','Bearer ' + accessToken);
                req2.setHeader('Content-Type','application/json');
                req2.setHeader('accept','application/json');
                req2.setBody(jsonstr);
                req2.setMethod('POST');
                req2.setEndpoint(endPoint);
                HttpResponse res2=h2.send(req2);
                
                System.debug(res2+'###1203createresp');
                System.debug('###Body::'+res2.getBody());
                String jsonResStr = res2.getBody();
                string str = jsonResStr.replace('\\','');
                //System.debug(json.deserialize(jsonResStr, List<DraftFees>.class));
                DraftFeesList = (List<Prizm_PullProgramFeesBatch.DraftFees>)json.deserialize(str.removeStart('"').removeEnd('"'), List<Prizm_PullProgramFeesBatch.DraftFees>.class);
                
            }
        }
        List<Opportunity_Draft_Fee__c> UpdatedDraftFees = new List<Opportunity_Draft_Fee__c>();
        For(Prizm_PullProgramFeesBatch.DraftFees df1 : DraftFeesList){
            
            Opportunity_Draft_Fee__c df = new Opportunity_Draft_Fee__c();
            df.Program_Id__c = df1.programId;
            //DV-129
           /* if(df1.PaidAccumulation != null && df1.PaidAccumulation != '')
                df.Paid_Accumulation__c = Decimal.valueOf(df1.PaidAccumulation);
            if(df1.PaidAdminFee != null && df1.PaidAdminFee != '')
                df.Paid_Admin_Fee__c = Decimal.valueOf(df1.PaidAdminFee);
            if(df1.PaidCreditorPayments != null && df1.PaidCreditorPayments != '')
                df.Paid_Creditor_Payments__c = Decimal.valueOf(df1.PaidCreditorPayments);
            if(df1.PaidMaintenanceFee != null && df1.PaidMaintenanceFee != '')
                df.Paid_Maintenance_Fee__c = Decimal.valueOf(df1.PaidMaintenanceFee);
            if(df1.PaidProcessorFee != null && df1.PaidProcessorFee != '')
                df.Paid_Processor_Fee__c = Decimal.valueOf(df1.PaidProcessorFee);
            if(df1.PaidProgramFee != null && df1.PaidProgramFee != '')
                df.Paid_Program_Fee__c = Decimal.valueOf(df1.PaidProgramFee);            
            if(df1.PaidRetainerFee != null && df1.PaidRetainerFee != '')
                df.Paid_Retainer_Fee__c = Decimal.valueOf(df1.PaidRetainerFee);            
            if(df1.PaidServiceFee != null && df1.PaidServiceFee != '')
                df.Paid_Service_Fee__c= Decimal.valueOf(df1.PaidServiceFee);            
            if(df1.PaidThirdPartyFee != null && df1.PaidThirdPartyFee != '')
                df.Paid_Third_Party_Fee__c = Decimal.valueOf(df1.PaidThirdPartyFee);            
            if(df1.TotalAccumulation != null && df1.TotalAccumulation != '')
                df.Total_Accumulation__c = Decimal.valueOf(df1.TotalAccumulation);                        
            if(df1.TotalAdminFee != null && df1.TotalAdminFee != '')
                df.Total_Admin_Fee__c = Decimal.valueOf(df1.TotalAdminFee);                
            if(df1.TotalCreditorPayments != null && df1.TotalCreditorPayments != '')
                df.Total_Creditor_Payments__c = Decimal.valueOf(df1.TotalCreditorPayments);            
            if(df1.TotalMaintenanceFee != null && df1.TotalMaintenanceFee != '')
                df.Total_Maintenance_Fee__c = Decimal.valueOf(df1.TotalMaintenanceFee);            
            if(df1.TotalProcessorFee != null && df1.TotalProcessorFee != '')
                df.Total_Processor_Fee__c = Decimal.valueOf(df1.TotalProcessorFee);             
            if(df1.TotalProgramFee != null && df1.TotalProgramFee != '')
                df.Total_Program_Fee__c = Decimal.valueOf(df1.TotalProgramFee);            
            if(df1.TotalRetainerFee != null && df1.TotalRetainerFee != '')
                df.Total_Retainer_Fee__c = Decimal.valueOf(df1.TotalRetainerFee);            
            if(df1.TotalServiceFee != null && df1.TotalServiceFee != '')
                df.Total_Service_Fee__c = Decimal.valueOf(df1.TotalServiceFee);
            if(df1.TotalThirdPartyFee != null && df1.TotalThirdPartyFee != '')
                df.Total_Third_Party_Fee__c = Decimal.valueOf(df1.TotalThirdPartyFee);
            if(df1.RemainingAccumulation != null && df1.RemainingAccumulation != '')
                df.Remaining_Accumulation__c = Decimal.valueOf(df1.RemainingAccumulation);                        
            if(df1.RemainingAdminFee != null && df1.RemainingAdminFee != '')
                df.Remaining_Admin_Fee__c = Decimal.valueOf(df1.RemainingAdminFee);                
            if(df1.RemainingCreditorPayments != null && df1.RemainingCreditorPayments != '')
                df.Remaining_Creditor_Payments__c = Decimal.valueOf(df1.RemainingCreditorPayments);            
            if(df1.RemainingMaintenanceFee != null && df1.RemainingMaintenanceFee != '')
                df.Remaining_Maintenance_Fee__c = Decimal.valueOf(df1.RemainingMaintenanceFee);            
            if(df1.RemainingProcessorFee != null && df1.RemainingProcessorFee != '')
                df.Remaining_Processor_Fee__c = Decimal.valueOf(df1.RemainingProcessorFee);             
            if(df1.RemainingProgramFee != null && df1.RemainingProgramFee != '')
                df.Remaining_Program_Fee__c = Decimal.valueOf(df1.RemainingProgramFee);            
            if(df1.RemainingRetainerFee != null && df1.RemainingRetainerFee != '')
                df.Remaining_Retainer_Fee__c = Decimal.valueOf(df1.RemainingRetainerFee);            
            if(df1.RemainingServiceFee != null && df1.RemainingServiceFee != '')
                df.Remaining_Service_Fee__c = Decimal.valueOf(df1.RemainingServiceFee);
            if(df1.RemainingThirdPartyFee != null && df1.RemainingThirdPartyFee != '')
                df.Remaining_Third_Party_Fee__c = Decimal.valueOf(df1.RemainingThirdPartyFee);*/
            
            UpdatedDraftFees.add(df);
            
            
        }
            
        //perform DMLs
        Savepoint sp = Database.setSavepoint();
        if (UpdatedDraftFees.size() > 0){
            System.debug(loggingLevel.ERROR, '-- savings changes ... ');
            try{                
                Schema.SObjectField ProgramIdField = Opportunity_Draft_Fee__c.Program_Id__c;
                List<Database.UpsertResult>  urList = Database.upsert(UpdatedDraftFees, ProgramIdField , False);

                
                upsert LendingApplicationCreator.appItemizationsWithDraftFeeUpdateList(UpdatedDraftFees);


            }
            catch (Exception e){
                System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
                Database.rollback(sp);
                mActionOutput.addError(e);
            }
        }
        System.debug(loggingLevel.ERROR, '-- RefreshDraftFeesAction.process(-)');
    }
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }

    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('RefreshDraftFeesAction', 'process', mActionOutput.getErrors());
        }
    }
    
}