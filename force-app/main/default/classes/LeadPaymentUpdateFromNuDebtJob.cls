/**
* Class Name  			: LeadPaymentUpdateFromNuDebtJob
* Description 			: We need to get all the updates happening on Payments under client's program from NuDebt to Prizm daily around 5 AM. 
* Acceptance Criteria 	: If any of the draft payment is skipped, failed or cancelled in NuDebt, it should change the Lead status to 'DNL ineligible' 
* 						  next day after the execution of this job.  
* Author      			: Financial Spectra
* 
* Creation Date			: March 23, 2020
*
*/

global class LeadPaymentUpdateFromNuDebtJob implements Schedulable{
    private static final String CLASS_NAME = 'LeadPaymentUpdateFromNuDebtJob';
    // This test runs a scheduled job at 18:15 March 23rd. 2020

	 public static String CRON_EXP = '18 15 0 23 9 ? 2020';
    
  	// Execute batch at scheduled time
    global void execute(SchedulableContext ctx){
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('DNL Lead').getRecordTypeId();
        System.debug(loggingLevel.ERROR ,'leadRecordTypeId = ' + leadRecordTypeId);
        List<Lead> selectedLeads = [Select Id, RecordTypeId, Lead_Record_Type_txt_del__c , NDS_File_Number__c,ProgramName__c, Applicant_State__c, Social_Security_Number__c, Co_Applicant_State__c, Co_Applicant_SSN__c, NuDebtAccount__c, MiddleName, Payment_Frequency__c,
        				            Last_Draft__c, Latest_Lead__c, Status,Lead_Status_Text__c, Unsettled_Debt__c, Birth_Date__c, Phone, Cell_phone__c, Best_Phone__c, Home_Phone__c, MobilePhone, 
                                    PersonOtherPhone__c from Lead where RecordTypeId = :leadRecordTypeId];
        System.debug(loggingLevel.ERROR ,'selectedLeads = ' + selectedLeads);
        List<String> listOfFileNumbers = new List<String>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Set<Id> leadIds = new Set<Id>();
        if(selectedLeads != null) {
             for(Lead lead:selectedLeads){
                listOfFileNumbers.add(lead.NDS_File_Number__c);
                leadMap.put(lead.Id, lead);
                leadIds.add(lead.Id);
            }
        }
        // Fetch Lead and Account details from NuDebt
           // PrizmLeadPullServiceQueueable queueableService = new PrizmLeadPullServiceQueueable(leadMap, leadIds);
             if(leadIds != null && leadMap != null || test.isRunningTest()){
                // Fetch Lead and Account details from NuDebt               
                PrizmLeadPullServiceSchedulable scheduledService = new PrizmLeadPullServiceSchedulable(leadMap, leadIds );
                if(Limits.getQueueableJobs() == 1 || test.isRunningTest()){
                    String hour = String.valueOf(Datetime.now().hour());
                    String min = String.valueOf(Datetime.now().minute()); 
                    String ss = String.valueOf(Datetime.now().second() + 5);
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, scheduledService);
                }else{
                    PrizmLeadPullServiceQueueable queueableService = new PrizmLeadPullServiceQueueable(leadMap, leadIds);
                    if(!Test.isRunningTest()){  
                        ID jobID = System.enqueueJob(queueableService); 
                        //PrizmLeadTriggerHandler.isTriggerExecuted = false;
                    }
                }	
            }
    }
    
}