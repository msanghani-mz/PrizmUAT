public without sharing class BankAccountTriggerHandler {
    
    
    public static void TaskForNewBankAccounts(Set<id> pAccountIds){
        
        List<fsCore__Lending_Application_Customer__c> applicants =  [Select id , fsCore__Contact_Name__c,
                                                                     fsCore__Lending_Application_Number__c,
                                                                     fsCore__Lending_Application_Number__r.Loan_Type__c,
                                                                     fsCore__Lending_Application_Number__r.OwnerId,
                                                                     fsCore__Lending_Application_Number__r.Name,
                                                                     fsCore__Lending_Application_Number__r.Docs_Processor_Name__c,
                                                                     fsCore__Lending_Application_Number__r.Loan_Officer__c,
                                                                     fsCore__Lending_Application_Number__r.fsCore__Primary_Customer_Contact__c,
                                                                     fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c
                                                                     from fsCore__Lending_Application_Customer__c
                                                                     where fsCore__Contact_Name__c in :pAccountIds
                                                                     and fsCore__Lending_Application_Number__r.Loan_Type__c = 'VCL'
                                                                     and fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false];
        
        if(applicants.size()>0){
            System.debug(loggingLevel.ERROR,'applicants '+ applicants );
            Map<id,fsCore__Lending_Application__c> mapAccountToApp = new Map<id,fsCore__Lending_Application__c>();
            for(fsCore__Lending_Application_Customer__c applicant : applicants){
                mapAccountToApp.put(applicant.fsCore__Contact_Name__c,applicant.fsCore__Lending_Application_Number__r);
            }
            
            List<AggregateResult> aggResult =  [Select count(id) num  ,
                                                fsCore__Contact_Name__c 
                                                from fsCore__Bank_Account__c 
                                                where fsCore__Contact_Name__c in :mapAccountToApp.KeySet() 
                                                GROUP BY fsCore__Contact_Name__c];
            
            System.debug(loggingLevel.ERROR,'aggResult '+ aggResult );
            
            List<fsCore__Lending_Application__c> applications = new List<fsCore__Lending_Application__c>();
            
            for(AggregateResult agg :aggResult){
                if((Integer)agg.get('num') > 1){
                    System.debug(loggingLevel.ERROR,'inside  '); 
                    applications.add(mapAccountToApp.get((Id)agg.get('fsCore__Contact_Name__c')));
                    System.debug(loggingLevel.ERROR,'applications '+ applications ); 
                }
            }
            if(applications.size()>0){             
                createTask(applications);            
            }                        
        }        
    }
    
    public static void TaskForUpdatedBankAccounts(Set<id> pAccountIds){
        
        List<fsCore__Lending_Application_Customer__c> applicants =  [Select id , fsCore__Contact_Name__c,
                                                                     fsCore__Lending_Application_Number__c,
                                                                     fsCore__Lending_Application_Number__r.Loan_Type__c,
                                                                     fsCore__Lending_Application_Number__r.OwnerId,
                                                                     fsCore__Lending_Application_Number__r.Name,
                                                                     fsCore__Lending_Application_Number__r.Docs_Processor_Name__c,
                                                                     fsCore__Lending_Application_Number__r.Loan_Officer__c,
                                                                     fsCore__Lending_Application_Number__r.fsCore__Primary_Customer_Contact__c,
                                                                     fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c
                                                                     from fsCore__Lending_Application_Customer__c
                                                                     where fsCore__Contact_Name__c in :pAccountIds
                                                                     and fsCore__Lending_Application_Number__r.Loan_Type__c = 'VCL'
                                                                     and fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false];
        
        
        if(applicants.size()>0){
            System.debug(loggingLevel.ERROR,'applicants '+ applicants );
            List<fsCore__Lending_Application__c> applications = new List<fsCore__Lending_Application__c>();
            for(fsCore__Lending_Application_Customer__c applicant : applicants){
                applications.add(applicant.fsCore__Lending_Application_Number__r);
            } 
            createTask(applications);
        }
    }
    
    public static void createTask(List<fsCore__Lending_Application__c> pApplications){
        
        List<Task> taskList = new List<Task>();
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        List<TaskObject> taskObjectList = new List<TaskObject>();
        
        for (fsCore__Lending_Application__c app : pApplications){
            TaskObject tsk =  new TaskObject(app);
            tsk.setTaskDescription('Client has added a new Bank Account , Please Re-Initiate BAV.');
            taskObjectList.add(tsk);
        }
        taskObjectMap.put('RE_INITIATE_BAV',taskObjectList);
        taskList = TaskHandler.getTasks(taskObjectMap);
        
        if(taskList.size()>0){
            System.debug(loggingLevel.ERROR,'taskList '+ taskList ); 
            insert taskList;
        }
        
        
    }
    
}