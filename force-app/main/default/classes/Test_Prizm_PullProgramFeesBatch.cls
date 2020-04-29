/**
 * @File Name          : Test_Prizm_PullProgramFeesBatch.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 7/27/2019, 10:52:27 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/27/2019, 10:51:41 AM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class Test_Prizm_PullProgramFeesBatch{

    @isTest
    public static void testMethod1(){
        
        Opportunity_Draft_Fee__c df = new Opportunity_Draft_Fee__c();
        df.Program_Id__c = Id.ValueOf('a0L4100000F4IuwEAF');
        insert df;
        
        Test.setMock (HttpCalloutMock.class, new Test_Prizm_PullProgramFeesBatch.webserviceProgramFeesMock ());
        Prizm_PullProgramFeesSchedular obj= new Prizm_PullProgramFeesSchedular();
        obj.execute(null);
        
        
    }

    @isTest
    public static void testMethodCoverage(){
        
        Prizm_PullProgramFeesBatch.DraftFees batchJobDraftFee = new Prizm_PullProgramFeesBatch.DraftFees();
        
    }    

    public class webserviceProgramFeesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            List<Prizm_PullProgramFeesBatch.DraftFees> dfList = new List<Prizm_PullProgramFeesBatch.DraftFees>();
                Prizm_PullProgramFeesBatch.DraftFees df1 = new Prizm_PullProgramFeesBatch.DraftFees();
            df1.PaidAccumulation = '123';
            df1.PaidAdminFee = '123';
            df1.PaidCreditorPayments = '123';
            df1.PaidMaintenanceFee = '123';
            df1.PaidProcessorFee = '123';
            dfList.add(df1);
            HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(dfList));
        res.setStatusCode(200);
        return res;

        }
    }
    
}