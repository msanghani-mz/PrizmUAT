/**
* @File Name          : PullNuDebtDataForLeadController.cls
* @Description        : 
* @Author             : Kimi Shrivastava
* @Group              : 
* @Last Modified By   : Kimi Shrivastava
* @Last Modified On   : 03/17/2020, 10:35:52 AM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    03/17/2020   Kimi Shrivastava     	Initial Version
**/

public class PullNuDebtDataForLeadController {
    public class deserializeResponse{
        public String id;
        public String access_token;   
    }
    @AuraEnabled
    public static string getNuDebtLeadData(string ids){
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        actionOP.setIsSuccess(false);
        try
        {
            
            List<Lead> leads = [Select Id, NDS_File_Number__c,ProgramName__c, Applicant_State__c, Social_Security_Number__c, Co_Applicant_State__c, Co_Applicant_SSN__c, Account__c, MiddleName, Payment_Frequency__c,
                                Last_Draft__c, Unsettled_Debt__c,Status, Birth_Date__c, Phone, Cell_phone__c, Best_Phone__c, Home_Phone__c, MobilePhone, PersonOtherPhone__c from Lead 
                                where Id = :ids ];
            System.debug(leads);
            List<String> listOfFileNumbers = new List<String>();
            Map<Id, Lead> leadMap = new Map<Id, Lead>();
            Set<Id> leadIds = new Set<Id>();
            for(Lead lead:leads){
                listOfFileNumbers.add(lead.NDS_File_Number__c);
                leadMap.put(lead.Id, lead);
                leadIds.add(lead.Id);
            }
                
             if (listOfFileNumbers == null){
                actionOP.addError('The import id is null on the Lead, cannot proceed with the data refresh.');
                return actionOP.getJSONString();
            }
            	//PrizmLeadPullService.pullLeadAccountDetailsFromNuDebt(leadMap,leads, listOfFileNumbers, false);
            	 //PrizmLeadPullServiceQueueable queableService = new PrizmLeadPullServiceQueueable(leadMap, leadIds);
            if(!Test.isRunningTest()){ 
                
                // Fetch Lead and Account details from NuDebt               
                PrizmLeadPullServiceSchedulable scheduledService = new PrizmLeadPullServiceSchedulable(leadMap, leadIds );
                if(Limits.getQueueableJobs() == 1){
                    String hour = String.valueOf(Datetime.now().hour());
                    String min = String.valueOf(Datetime.now().minute()); 
                    String ss = String.valueOf(Datetime.now().second() + 5);
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    ID jobID = System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, scheduledService);
                    if(jobId != null)
                        actionOP.setIsSuccess(true);
                }else{
                    PrizmLeadPullServiceQueueable queueableService = new PrizmLeadPullServiceQueueable(leadMap, leadIds);
                    if(!Test.isRunningTest()){  
                        ID jobID = System.enqueueJob(queueableService); 
                        if(jobId != null)
                            actionOP.setIsSuccess(true);
                        //PrizmLeadTriggerHandler.isTriggerExecuted = false;
                    }
                }	
                
            }        
            
        }catch(Exception e)
        {
            actionOP.addError(e.getMessage());
        }
        
        return actionOP.getJSONString();
        
    }
    
    // Function to inject some delay to wait for the processing
    
    private static void setDelay(){
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds = 20000; // ten-second delay
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
}
    }
    
}