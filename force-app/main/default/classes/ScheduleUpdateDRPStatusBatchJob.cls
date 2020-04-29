global class ScheduleUpdateDRPStatusBatchJob implements Schedulable {
   global void execute(SchedulableContext ctx) {
      UpdateDRPStatusBatchJob p = new UpdateDRPStatusBatchJob();
       database.executeBatch(p);
   }   
}