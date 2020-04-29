public class Batch_UpdateProgramProcessorStatus implements Database.Batchable<sObject>, Queueable {

    Set<Id> programIds = new Set<Id>();
    
    public Batch_UpdateProgramProcessorStatus(Set<Id> programIdSet) {
        
        if (programIdSet != null && programIdSet.isEmpty() == FALSE) {
            
            programIds = programIdSet;
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator('SELECT Id, nu_dse__Fee_Template__c, nu_dse__Account__c, nu_dse__Processor__c, nu_dse__GCS_Fee_Group_Id__c FROM nu_dse__Program__c WHERE Id IN :programIds');
    }
    
    public void execute(Database.BatchableContext bc, List<nu_dse__Program__c> programs) {
        
        if (programs != null && programs.isEmpty() == FALSE) {
            
            List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
            
            for (nu_dse__Program__c pgm : programs) {
                nu_dse__Program__c prgmRecord = new nu_dse__Program__c();
                prgmRecord.Id = pgm.Id;
                prgmRecord.nu_dse__Processor_Status__c = 'No Account';
                prgmRecord.nu_dse__Account__c = pgm.nu_dse__Account__c;
                prgmRecord.nu_dse__Fee_Template__c = pgm.nu_dse__Fee_Template__c;
                prgmRecord.nu_dse__Processor__c = pgm.nu_dse__Processor__c;
                prgmRecord.nu_dse__GCS_Fee_Group_Id__c = pgm.nu_dse__GCS_Fee_Group_Id__c;
                programList.add(prgmRecord);
            }
            update programList;
            
            for (nu_dse__Program__c pgm : programList) {
                pgm.nu_dse__Processor_Status__c = 'Pending Creation';
                System.enqueueJob(new Batch_UpdateProgramProcessorStatus(new List<nu_dse__Program__c> {pgm}));
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    
        
    }
    
    public List<nu_dse__Program__c> programsList = new List<nu_dse__Program__c>();
    
    public Batch_UpdateProgramProcessorStatus(List<nu_dse__Program__c> prgmList) {
    
        if (prgmList != null && prgmList.isEmpty() == False) {
        
            programsList = prgmList;
        }
    }
    
    public void execute(QueueableContext context) {
    
        if (programsList != null && programsList.isEmpty() == False) {
        
            update programsList;
        }
    }
    
}