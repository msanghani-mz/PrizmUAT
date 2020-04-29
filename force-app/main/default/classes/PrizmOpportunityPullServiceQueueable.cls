/**
* @File Name          : PrizmOpportunityPullServiceQueueable.cls
* @Description        : This class is called from the PrizmLeadTriggerHandler
*                     : to fetch opportunity data from NuDebt and update the same in Prizm Lead and related objects
* @Author             : fSpectra
* @Group              : 
**/
public class PrizmOpportunityPullServiceQueueable implements Queueable,Database.AllowsCallouts{
    
    private String importId;    
    public PrizmOpportunityPullServiceQueueable(String importId) {
        
        this.importId = importId;
        if(Test.isRunningTest()){
            process();
        }
    }
    
    public void execute(QueueableContext context) {
        process();        
    }  
    public void process() {           
        if(importId != null){
           pullOpportunityTradeLinePaymentsClass.pullProgramDetailsFromNuDebt(importId );
            
        }
        
    }  
}