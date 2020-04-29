/* **************************************************************************
* Copyright 2020, Strategic Financial Solutions.
* All rights reserved
*
* Controller Class: LendingApplicationTiggerHandler
*
* Test Class : LendingApplicationTiggerHandlerTest
************************************************************************** */
public with sharing class LendingApplicationTiggerHandler {
    private Boolean m_isExecuting = false;
    private Integer BatchSize = 0;
    
 
    public LendingApplicationTiggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /**************************************************************************
       Purpose: This method will be called from lending application trigger, after update
       Parameters: List- new values, Map- old values
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public void OnAfterUpdate(List<fsCore__Lending_Application__c > newLendingApplications, Map<Id, fsCore__Lending_Application__c> oldLendingApplicationsMap){
		
        List<fsCore__Lending_Application__c> lendingApplications = new List<fsCore__Lending_Application__c>();
        for (fsCore__Lending_Application__c newLendingApplication: newLendingApplications) {
            if ((newLendingApplication.Loan_Type__c == 'VCL') &&  (!newLendingApplication.Is_Client_Created__c) &&
                (newLendingApplication.fsCore__Application_Status__c <> oldLendingApplicationsMap.get(newLendingApplication.Id).fsCore__Application_Status__c) &&
                (newLendingApplication.fsCore__Application_Status__c == 'Lead Underwriter Approved')){
                    
                    lendingApplications.add(newLendingApplication);
            }    
        }
        
        if (lendingApplications.size() > 0 ){
            CreateNuDebtClientAndBankAcctQueueable createNuDebtClient = new CreateNuDebtClientAndBankAcctQueueable(lendingApplications);
            ID jobID = System.enqueueJob(createNuDebtClient);
        }
    }
}