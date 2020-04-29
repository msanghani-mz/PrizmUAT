/**
* @File Name          : PrizmLeadPullServiceQueueable.cls
* @Description        : This class is called from the PrizmLeadTriggerHandler
*                     : to fetch data from NuDebt and update the same in Prizm Lead and related objects
* @Author             : fSpectra
* @Group              : 
**/
public class PrizmLeadPullServiceQueueable implements Queueable,Database.AllowsCallouts{
    
    private List<String> listOfFileNumbers = new List<String>();
    private List<Lead> leads;
    private Map<Id,Lead> leadMap;
    private Set<Id> newLeadIds;
    public NuDebtProgramWrapper nuDebtProgramWrapper;    
    public PrizmLeadPullServiceQueueable(Map<Id, Lead> leadMap, Set<Id> newLeadIds) {
        
        this.leadMap = leadMap;
        this.newLeadIds = newLeadIds;
        this.leads = [Select Id, NDS_File_Number__c,ProgramName__c, Applicant_State__c, Social_Security_Number__c, Co_Applicant_State__c, Co_Applicant_SSN__c, NuDebtAccount__c, MiddleName, Payment_Frequency__c,
                    Last_Draft__c, Latest_Lead__c, Status, Unsettled_Debt__c, Birth_Date__c, Phone, Cell_phone__c, Best_Phone__c, Home_Phone__c, MobilePhone, PersonOtherPhone__c, Lead_Status_Text__c from Lead 
                    where Id = :newLeadIds] ;
        if(Test.isRunningTest()){
            process();
        }
    }
    
    public void execute(QueueableContext context) {
        process();
        System.debug(loggingLevel.ERROR , 'After processing+++++');
        LeadUpdateSchedulable scheduledService = new LeadUpdateSchedulable(nuDebtProgramWrapper, leads,leadMap );
        if(Limits.getQueueableJobs() == 1){
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second() + 5);
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, scheduledService);
        }else{
            LeadUpdateQueueable queableService = new LeadUpdateQueueable(nuDebtProgramWrapper, leads,leadMap );
        	System.enqueueJob(queableService);
        }	
        
            /*if (nuDebtProgramWrapper != null){
//PrizmLeadPullService.leadUpdate(nuDebtProgramWrapper, leads, leadOldMap, true);   
LeadUpdateQueueable queableService = new LeadUpdateQueueable(nuDebtProgramWrapper, leads,leadOldMap );
System.debug(loggingLevel.ERROR , 'queableService = ' + queableService);
if(!Test.isRunningTest()){  System.enqueueJob(queableService); }
}*/
        
    }  
    public void process() {           
        //testMe();
        if(leads != null){
            for(Lead lead:leads)
                if(lead.NDS_File_Number__c != null && lead.NDS_File_Number__c != '')
                listOfFileNumbers.add(lead.NDS_File_Number__c);
            
            System.debug(loggingLevel.ERROR , 'Inside PrizmLeadPullServiceQueueable = ' + listOfFileNumbers);
            nuDebtProgramWrapper = PrizmLeadPullService.pullLeadAccountDetailsFromNuDebt( listOfFileNumbers);     
            System.debug(loggingLevel.ERROR , 'NuDebtProgramWrapper nuDebtProgramWrapper = ' + nuDebtProgramWrapper);
            
        }
        
    }  
    
    public class LeadUpdateQueueable implements Queueable {
        private NuDebtProgramWrapper nuDebtProgramWrapper ; 
        private List<Lead>  leads ; 
        private Map<Id,Lead> leadMap ; 
        public LeadUpdateQueueable(NuDebtProgramWrapper nuDebtProgramWrapper, List<Lead> leads, Map<Id,Lead> leadMap){
            this.nuDebtProgramWrapper = nuDebtProgramWrapper ;  
            this.leads = leads;
            this.leadMap = leadMap;
            System.debug(loggingLevel.ERROR , 'LeadUpdateQueueable = '  + nuDebtProgramWrapper);
        }
        public void execute(QueueableContext context) {       
            
            if (nuDebtProgramWrapper != null)
                PrizmLeadPullService.leadUpdate(nuDebtProgramWrapper, leads, leadMap, true);             
            
        }
    }
    public class LeadUpdateSchedulable implements Schedulable {
        private NuDebtProgramWrapper nuDebtProgramWrapper ; 
        private List<Lead>  leads ; 
        private Map<Id,Lead> leadMap ; 
        public LeadUpdateSchedulable(NuDebtProgramWrapper nuDebtProgramWrapper, List<Lead> leads, Map<Id,Lead> leadMap){
            this.nuDebtProgramWrapper = nuDebtProgramWrapper ;  
            this.leads = leads;
            this.leadMap = leadMap;
            System.debug(loggingLevel.ERROR , 'LeadUpdateSchedulable = '  + nuDebtProgramWrapper);
        }
    public void execute(SchedulableContext sc) {
        LeadUpdateQueueable queableService = new LeadUpdateQueueable(nuDebtProgramWrapper, leads,leadMap );
        System.enqueueJob(queableService);
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}
        
    public static void testMe() {
        List<String> listOfFileIds = new List<String>();
        listOfFileIds.add('0011K000021P3OX');
        listOfFileIds.add('0011K000021P3cy');
        List<Lead> leads = [Select Id, NDS_File_Number__c,ProgramName__c, Applicant_State__c, Social_Security_Number__c, Co_Applicant_State__c, Co_Applicant_SSN__c, Account__c, MiddleName, Payment_Frequency__c,
                            Last_Draft__c, Unsettled_Debt__c, Birth_Date__c, Phone, Cell_phone__c, Best_Phone__c, Home_Phone__c, MobilePhone, PersonOtherPhone__c from Lead 
                            where NDS_File_Number__c = :listOfFileIds ];
        System.debug(leads);
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        for(Lead lead:leads){
            leadMap.put(lead.Id, lead);
        }
        PrizmLeadPullService.pullLeadAccountDetailsFromNuDebt(listOfFileIds);
        
    }
}