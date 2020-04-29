global class ClientPortal_TILAAutoWithdrawnBatchClass implements Database.Batchable <Account> {
    
    private static final String WITHDRAWN_STATUS = ClientPortal_Constants.WITHDRAWN_STATUS;
    private static final String WITHDRAW_REASON = 'No Activity';
    
    global Iterable<Account> start(Database.BatchableContext bc) {
        String todaysDate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).addDays(-1).format('yyyy-MM-dd') ; 
        List<Account> applicationsToProcess = [Select Id,Is_VCL_TILA_Accepted__c,VCL_Registration_Reminder_Date__c,
                                               VCL_Application_Submission_Reminder_Date__c,Is_VCL_Application_Submitted__c,
                                               VCL_Portal_Status1__c,VCL_Related_Portal_Account__c 
                                               From Account
                                               WHERE (VCL_Registration_Reminder_Date__c <= : todaysDate 
                                                      AND 
                                                      VCL_Registration_Reminder_Date__c  != null )
                                               OR  (VCL_Application_Submission_Reminder_Date__c <= :todaysDate 
                                                    AND 
                                                    VCL_Application_Submission_Reminder_Date__c   != null )
                                              ] ;
        return applicationsToProcess;
    }
    
    global void execute(Database.BatchableContext bc, List<Account> records){
        autoWithdrawnClient(records) ;
    }   
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }  
    
    public void autoWithdrawnClient(List<Account> applicationsToProcess) {
        String todaysDate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).addDays(-1).format('yyyy-MM-dd') ; 
        Map<Id, Id> accountToLendingApplicationMap = new Map<Id, Id> ();
        List<Account> accountListToUpdate = new List<Account> () ;
        Set<Id> lendingAppIdsToExecute = new Set<Id> () ;
        Set<Id> accountIdSet = new Set<Id> () ;
        List<fsCore__Lending_Application__c> lendingApplnsToUpdate = new List<fsCore__Lending_Application__c> () ;
        
        for(fsCore__Lending_Application_Customer__c applicantsRecords : [SELECT fsCore__Lending_Application_Number__c, 
                                                                         fsCore__Account_Name__c, fsCore__Account_Name__r.IsCustomerPortal
                                                                         FROM fsCore__Lending_Application_Customer__c
                                                                         WHERE fsCore__Account_Name__c IN :applicationsToProcess
                                                                         AND fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false
                                                                         AND fsCore__Lending_Application_Number__r.Loan_Type__c = 'VCL'
                                                                        ]) 
        {
            accountToLendingApplicationMap.put(applicantsRecords.fsCore__Account_Name__c, applicantsRecords.fsCore__Lending_Application_Number__c);
        }
        
        for(Account applicant:applicationsToProcess){
            
            if((applicant.VCL_Registration_Reminder_Date__c <= todaysDate && !applicant.Is_VCL_TILA_Accepted__c)
               || (applicant.VCL_Application_Submission_Reminder_Date__c <= todaysDate && !applicant.Is_VCL_Application_Submitted__c)){
                   
                   if(!accountIdSet.contains(applicant.Id)){
                       accountIdSet.add(applicant.Id);
                       accountListToUpdate.add( new Account(
                           Id = applicant.Id ,
                           IsCustomerPortal = false,
                           VCL_Portal_Status1__c = WITHDRAWN_STATUS,
                           Is_VCL_Application_Withdrawn__c = true
                       )) ;
                   }
                   
                   if(String.isNotBlank(applicant.VCL_Related_Portal_Account__c) && !accountIdSet.contains(applicant.VCL_Related_Portal_Account__c)){
                       accountIdSet.add(applicant.VCL_Related_Portal_Account__c);
                       accountListToUpdate.add( new Account(
                           Id = applicant.VCL_Related_Portal_Account__c ,
                           IsCustomerPortal = false,
                           VCL_Portal_Status1__c = WITHDRAWN_STATUS,
                           Is_VCL_Application_Withdrawn__c = true
                       )) ;
                   }
                   
                   if(accountToLendingApplicationMap.get(applicant.Id) != NULL && !lendingAppIdsToExecute.contains(accountToLendingApplicationMap.get(applicant.Id))) {
                       lendingAppIdsToExecute.add(accountToLendingApplicationMap.get(applicant.Id)) ;
                       lendingApplnsToUpdate.add( new fsCore__Lending_Application__c (
                           Id = accountToLendingApplicationMap.get(applicant.Id),
                           fsCore__Application_Status__c = WITHDRAWN_STATUS,
                           Withdraw_Reason__c = WITHDRAW_REASON,
                           fsCore__Is_Application_Read_Only__c = true
                       )) ;
                   }
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