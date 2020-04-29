global class ClientPortal_MarkOpportunityClosedLost  implements Database.Batchable <Account>{
    
    global Iterable<Account> start(Database.BatchableContext bc) {
        
        List<Account> accountDetails = [SELECT Id, IsCustomerPortal,Is_Registration_Completed__c , Is_User_Registration_Completed__c,
                                        Is_Welcome_Email_Sent__c, Registration_Reminder_Date__c,Application_Submission_Reminder_Date__c FROM Account 
                                        WHERE Is_DNL_Portal_Disclosure_Declined__c = False
                                        AND (Registration_Reminder_Date__c = today
                                               OR Application_Submission_Reminder_Date__c = today  ) 
                                        ] ;
         return accountDetails;
    }
    global void execute(Database.BatchableContext bc, List<Account> records){
        getRelatedUserDetail(records);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
    public static Void getRelatedUserDetail(List<Account> accountDetails) {
                
        List<Account> registeredAccounts = new  List<Account>();
        Set<Id> accountIdToDeactivate = new Set<Id>();
        Id dnlReadOnlyRecordType = ClientPortal_Utility.getRecordTypeId('Opportunity', 'Read Only DNL');
        
        String todaysDate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('yyyy-MM-dd') ;        
        
        
        for(Account applicant :accountDetails){
            String registrationReminderDate = (applicant.Registration_Reminder_Date__c != null) ? DateTime.newInstance(applicant.Registration_Reminder_Date__c.year(), applicant.Registration_Reminder_Date__c.month(), applicant.Registration_Reminder_Date__c.day()).format('yyyy-MM-dd') : null ;
            String applicationReminderDate = (applicant.Application_Submission_Reminder_Date__c != null) ? DateTime.newInstance(applicant.Application_Submission_Reminder_Date__c.year(), applicant.Application_Submission_Reminder_Date__c.month(), applicant.Application_Submission_Reminder_Date__c.day()).format('yyyy-MM-dd') : null ;

            if(todaysDate.equals(registrationReminderDate) && !applicant.IsCustomerPortal) {
                accountIdToDeactivate.add(applicant.Id);
            } else if(todaysDate.equals(applicationReminderDate) 
                      && applicant.IsCustomerPortal && !applicant.Is_Registration_Completed__c){
                applicant.IsCustomerPortal = False;
                registeredAccounts.add(applicant);
                accountIdToDeactivate.add(applicant.Id);
            }
            
        }
        List<Opportunity> oppDetails = new  List<Opportunity>();
        for(Opportunity opportunityObj :[SELECT Id, AccountId, Account.IsCustomerPortal,
                                         Co_Applicant_Name__c, Co_Applicant_Name__r.IsCustomerPortal
                              FROM Opportunity
                              WHERE ((AccountId IN :accountIdToDeactivate
                                      OR Co_Applicant_Name__c IN :accountIdToDeactivate) AND StageName != 'Closed Lost')
                             ] ){
                                 opportunityObj.StageName = 'Closed Lost';
                                 opportunityObj.RecordTypeId =dnlReadOnlyRecordType ;
                                 oppDetails.add(opportunityObj);
                                 if( String.isNotBlank(opportunityObj.AccountId) && !accountIdToDeactivate.contains(opportunityObj.AccountId)
                                    && opportunityObj.Account.IsCustomerPortal) {
                                     registeredAccounts.add( new Account(
                                         Id = opportunityObj.AccountId ,
                                         IsCustomerPortal = false 
                                     )) ;
                                 } 
                                 if( String.isNotBlank(opportunityObj.Co_Applicant_Name__c) && !accountIdToDeactivate.contains(opportunityObj.Co_Applicant_Name__c)
                                    && opportunityObj.Co_Applicant_Name__r.IsCustomerPortal ) {
                                     registeredAccounts.add( new Account(
                                         Id = opportunityObj.Co_Applicant_Name__c ,
                                         IsCustomerPortal = false 
                                     )) ;
                                 }
                             }
        if (!oppDetails.isEmpty()){
            update oppDetails;
        }
        if (!registeredAccounts.isEmpty()){
            update registeredAccounts;
        }
    }
    
}