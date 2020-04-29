global class ClientPortal_BAVAutoWithdrawnSchedular implements schedulable{
    global void execute(SchedulableContext sc) 
    {
        ClientPortal_BAVAutoWithdrawnBatchClass bavBatchClassObj = new ClientPortal_BAVAutoWithdrawnBatchClass(); 
        database.executebatch(bavBatchClassObj); 
        
        ClientPortal_TILAAutoWithdrawnBatchClass tilaBatchClassObj = new ClientPortal_TILAAutoWithdrawnBatchClass(); 
        database.executebatch(tilaBatchClassObj); 
        //System.schedule('Client Portal Auto-Withdrawn Batch', '0 0 1 ? * *', new ClientPortal_BAVAutoWithdrawnSchedular());
    }
}