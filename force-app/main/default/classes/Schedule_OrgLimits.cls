global class Schedule_OrgLimits implements Schedulable, Database.AllowsCallouts {
   
   
   global void execute(SchedulableContext SC) {
       
      RESTLimitResource.limitExceeded();
   }
}