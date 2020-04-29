global class ClientPortal_SchedulerToMarkClosedLost implements schedulable{
	global void execute(SchedulableContext sc)
    {
    ClientPortal_MarkOpportunityClosedLost b = new ClientPortal_MarkOpportunityClosedLost(); 
      database.executebatch(b);
    }
}