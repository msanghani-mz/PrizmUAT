@isTest
public class Test_Prizm_UpdateOppoStageService {
	
    @isTest
    public Static void TestOppoStageService(){
        fsCore__Lending_Application__c LApp = new fsCore__Lending_Application__c();
       
        //insert LApp;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Prospecting';
        opp.Description = 'Test';
        opp.Name = 'Test';
        opp.CloseDate = Date.Today()+1;
        opp.Import_Id__c = '0060S0000068D7WQAU';
        insert opp;
        
        UpdateOpprtunityStageService.UpdateOpprtunityStage();
    }
    
}