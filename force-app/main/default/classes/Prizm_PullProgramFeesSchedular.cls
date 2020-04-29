global class Prizm_PullProgramFeesSchedular implements Schedulable{

    global void execute(SchedulableContext sc) {
     	
        Database.executeBatch(new Prizm_PullProgramFeesBatch());
        
    }
    
}