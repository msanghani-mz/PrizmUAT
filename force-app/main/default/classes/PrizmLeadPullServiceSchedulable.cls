public class PrizmLeadPullServiceSchedulable implements Schedulable{
    private NuDebtProgramWrapper nuDebtProgramWrapper ; 
    private Map<Id,Lead> leadMap;
    private Set<Id> newLeadIds;
    public PrizmLeadPullServiceSchedulable(Map<Id, Lead> leadMap, Set<Id> newLeadIds){
        this.leadMap = leadMap;
        this.newLeadIds = newLeadIds;
        System.debug(loggingLevel.ERROR , 'LeadUpdateSchedulable = '  + nuDebtProgramWrapper);
    }
    public void execute(SchedulableContext sc) {
        PrizmLeadPullServiceQueueable queableService = new PrizmLeadPullServiceQueueable(leadMap, newLeadIds );
        System.enqueueJob(queableService);
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}