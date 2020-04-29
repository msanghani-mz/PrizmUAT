global class Schedule_CreateNuDebtClientAndBankAcct implements Schedulable {
   
   public Integer batchSize;
   
   public Schedule_CreateNuDebtClientAndBankAcct () {
       
       batchSize = 200;
   }
   
   public Schedule_CreateNuDebtClientAndBankAcct (Integer bSize) {
       
       if (bSize != null && bSize > 0) {
           
           batchSize = bSize;
       
       } else {
           
           batchSize = 200;
       }
   }
   
   global void execute(SchedulableContext sc) {
      
      Batch_CreateNuDebtClientAndBankAcct syncBatchInstance = new Batch_CreateNuDebtClientAndBankAcct(); 
      database.executebatch(syncBatchInstance, batchSize);
   }
}