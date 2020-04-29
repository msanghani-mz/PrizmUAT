global class ClientPortal_BAVAutoWithdrawnBatchClass implements Database.Batchable <fsCore__Lending_Application__c>{
    
    private static final String WITHDRAWN_STATUS = ClientPortal_Constants.WITHDRAWN_STATUS;
    private static final String WITHDRAW_REASON = 'No Activity';

    global Iterable<fsCore__Lending_Application__c> start(Database.BatchableContext bc) {
        Date eightDaysOldDate = Date.today().addDays(-8) ;
        List<fsCore__Lending_Application__c> applicationsToProcess = [Select Id From fsCore__Lending_Application__c
                                                                      WHERE (Populate_BAV_initiation_date__c <= :eightDaysOldDate 
                                                                             AND 
                                                                             Populate_BAV_initiation_date__c != null)
                                                                      AND fsCore__Is_Application_Read_Only__c = false
                                                                     ] ;
        return applicationsToProcess;
    }
    
    global void execute(Database.BatchableContext bc, List<fsCore__Lending_Application__c> records){
        autoWithdrawnClient(records) ;
    }   
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }  
    
    public void autoWithdrawnClient(List<fsCore__Lending_Application__c> applicationsToProcess) {

        List<fsCore__Lending_Application_Customer__c> applicantsRecords = [SELECT fsCore__Lending_Application_Number__c, 
                                                                           fsCore__Account_Name__c, fsCore__Account_Name__r.IsCustomerPortal
                                                                           FROM fsCore__Lending_Application_Customer__c
                                                                           WHERE  fsCore__Lending_Application_Number__c IN :applicationsToProcess
                                                                           AND fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false
                                                                           ] ;
        
        List<Account> accountListToUpdate = new List<Account> () ;
        Set<Id> lendingAppIdsToExecute = new Set<Id> () ;
        Set<Id> accountIdsToExecute = new Set<Id> () ;
        List<fsCore__Lending_Application__c> lendingApplnsToUpdate = new List<fsCore__Lending_Application__c> () ;
        for(fsCore__Lending_Application_Customer__c applicant : applicantsRecords) {
            if(applicant.fsCore__Account_Name__r.IsCustomerPortal && !accountIdsToExecute.contains(applicant.fsCore__Account_Name__c )) {
                accountIdsToExecute.add(applicant.fsCore__Account_Name__c ) ;
                accountListToUpdate.add( new Account(
                    Id = applicant.fsCore__Account_Name__c ,
                    IsCustomerPortal = false,
                    VCL_Portal_Status1__c = WITHDRAWN_STATUS,
                    Is_VCL_Application_Withdrawn__c = true
                )) ;
            }
            if(!lendingAppIdsToExecute.contains(applicant.fsCore__Lending_Application_Number__c )) {
                lendingAppIdsToExecute.add(applicant.fsCore__Lending_Application_Number__c ) ;
                lendingApplnsToUpdate.add( new fsCore__Lending_Application__c (
                    Id = applicant.fsCore__Lending_Application_Number__c ,
                    fsCore__Application_Status__c = WITHDRAWN_STATUS,
                    Withdraw_Reason__c = WITHDRAW_REASON,
                    fsCore__Is_Application_Read_Only__c = true
                )) ;
            }
            
        }
        
        if(!accountListToUpdate.isEmpty()) {
            update accountListToUpdate ;
        }
        if(!lendingApplnsToUpdate.isEmpty()) {
            update lendingApplnsToUpdate ;
        }
    }
}