/**
* Class Name  : FinancialCustomTriggerManager (PDI-699)
* Description : This class handles the custom logic for fsCore.FinancialTrigger
* Author      : Financial Spectra
* 
*/
global with sharing class FinancialCustomTriggerManager implements fsCore.TriggerManager {
    
    global void beforeInsert(List<sObject> pNewRecList){
        populateMissingContactOrAccountId(pNewRecList); //DV-99
        populateInformationFromEmployment(pNewRecList); //DV-99
        System.debug(loggingLevel.Error, 'BEFORE INSERTING');
        populateMonthlyStatedAmount(pNewRecList);//SUP-358
    }
    //SUP-358
    private void populateMonthlyStatedAmount(List<sObject> pNewRecList){
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            System.debug(loggingLevel.Error, 'financial INSERTING'+financial);
            if (financial.Annual_Stated_Amount__c != null && financial.fsCore__Monthly_Stated_Amount__c ==null && financial.Annual_Stated_Amount__c > 0 ){
                System.debug(loggingLevel.Error, 'financial Inside if '+financial);
                financial.fsCore__Monthly_Stated_Amount__c = financial.Annual_Stated_Amount__c/12;
            }
        }
        
    }
    private void populateInformationFromEmployment(List<sObject> pNewRecList){
        Set<Id> empIds = new Set<Id>();
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.Employment_Name__c != null){
                empIds.add(financial.Employment_Name__c);
            }
        }
        Map<ID, fsCore__Employment__c> employmentMap = new Map<ID, fsCore__Employment__c>([SELECT Id, fsCore__Start_Date__c,fsCore__Salary__c FROM fsCore__Employment__c where id in :empIds]);
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.Employment_Name__c != null){
                financial.Start_Date__c = (employmentMap.get(financial.Employment_Name__c)).fsCore__Start_Date__c;
                financial.fsCore__Stated_Amount__c = (employmentMap.get(financial.Employment_Name__c)).fsCore__Salary__c;
                //financial.fsCore__Frequency__c = 'Annual';
            }
        }
    }
    
    //DV-99
    private void populateMissingContactOrAccountId(List<sObject> pNewRecList){
        populateAccountId(pNewRecList);
        populateContactId(pNewRecList); 
    }
    
    //DV-99
    private void populateContactId(List<sObject> pNewRecList){
        Set<Id> accountIds = new Set<Id>();
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.fsCore__Contact_Name__c == null && financial.fsCore__Account_Name__c != null){
                accountIds.add(financial.fsCore__Account_Name__c);
            }
        }
        Map<ID, Account> accountMap = new Map<ID, Account>([SELECT Id, personContactId FROM Account where id in :accountIds]);
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.fsCore__Contact_Name__c == null && financial.fsCore__Account_Name__c != null){
                financial.fsCore__Contact_Name__c = accountMap.get(financial.fsCore__Account_Name__c).personContactId;
            }
        }
    }
    
    //DV-99
    private void populateAccountId(List<sObject> pNewRecList){
        Set<Id> contactIds = new Set<Id>();
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.fsCore__Account_Name__c == null && financial.fsCore__Contact_Name__c != null){
                contactIds.add(financial.fsCore__Contact_Name__c);
            }
        }
        List<Account> accountList = [SELECT Id, personContactId FROM Account where personContactId in :contactIds];
        Map<ID, ID> contactToAccountMap = new Map<ID, ID>();
        for (Account acc: accountList){
            contactToAccountMap.put(acc.personContactId,acc.Id);
        }
        
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.fsCore__Account_Name__c == null && financial.fsCore__Contact_Name__c != null){
                financial.fsCore__Account_Name__c = contactToAccountMap.get(financial.fsCore__Contact_Name__c);
            }
        }
    }    
    
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    
    //custom implementation of after trigger events
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        System.debug(loggingLevel.ERROR,'afterinsert:--');
        validatePrimaryIncomeRecord(pNewRecList); 
        validateFinancialToIncomeRecord(pNewRecList); 
        generateChecklists(pNewRecList);  //PDI-808
        //SUP-410
        updateApplicantAnnualIncomeForVCL((List<fsCore__Financial__c>)pNewRecList,null,false);
    }
    /*
* @description- This method generates a set of Application ids for the
applicants having a lending application loan type as DNL 
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 8/5/2019
* @param List<sObject> pNewRecList
* @return void
*/
    private void generateChecklists(List<sObject> pNewRecList){
        Set<ID> contactIds = getContactIdForIncomeRecs(pNewRecList);
        //Set<ID> dnlApplicationIds = new Set<ID>();
        Set<ID> applicationIds = new Set<ID>();
        List<fsCore__Lending_Application_Customer__c> applicationCustomerList = [SELECT id
                                                                                 , name
                                                                                 , fsCore__Lending_Application_Number__c
                                                                                 , fsCore__Contact_Name__c
                                                                                 , fsCore__Lending_Application_Number__r.RecordType.DeveloperName
                                                                                 FROM fsCore__Lending_Application_Customer__c
                                                                                 where fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false
                                                                                 and fsCore__Contact_Name__c in :contactIds];
        
        System.debug(loggingLevel.ERROR,'applicationCustomerList size() '+applicationCustomerList.size());
        for (fsCore__Lending_Application_Customer__c appCust :applicationCustomerList ){
            applicationIds.add (appCust.fsCore__Lending_Application_Number__c);
            
        }
        
        generateChecklist(applicationIds);
    }  
    /**
* @description-This method calls a process to generate a checklist for the applicant
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 8/5/2019
* @param Set<ID> pApplicationIds
* @return void
*/
    //PDI-808
    private  void generateChecklist(Set<ID> pApplicationIds){
        System.debug(loggingLevel.ERROR,' -->  Inside Trigger generateChecklist '+pApplicationIds);
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        acrInput.addRecords(pApplicationIds);
        GenerateCustomChkLstActionProcessor checklistActionProcessor = new GenerateCustomChkLstActionProcessor();
        checklistActionProcessor.setInput(acrInput);
        checklistActionProcessor.process();
        
    }       
    private Set<ID> getContactIdForIncomeRecs(List<sObject> pNewRecList){
        System.debug(loggingLevel.ERROR,' -->  getContactIdForIncomeRecs ');
        Set<ID> contactIds = new Set<ID>();
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            System.debug(loggingLevel.ERROR,'Financial Family  '+financial.fsCore__Financial_Family__c);
            if (financial.fsCore__Financial_Family__c == 'Income'){
                if (financial.fsCore__Contact_Name__c != null){
                    contactIds.add(financial.fsCore__Contact_Name__c);
                }
            }
        }
        System.debug(loggingLevel.ERROR,'contactIds '+contactIds.size());
        return contactIds;
        
    }
    
    private Set<ID> getContactIds(List<sObject> pNewRecList){
        Set<ID> contactIds = new Set<ID>();
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.fsCore__Contact_Name__c != null){
                contactIds.add(financial.fsCore__Contact_Name__c);
            }
        }
        
        return contactIds;
        
    }
    
    /**
* @description This method ensure that the single employment record 
*              cannot be mapped to multiple financial Records
* @author 
* @param List<sObject> pNewRecList
* @return void
*/
    private void validateFinancialToIncomeRecord(List<sObject> pNewRecList){
        Set<ID> contactIds = getContactIds(pNewRecList);
        
        List<AggregateResult> aggResult = [SELECT count(Id) num
                                           , fsCore__Contact_Name__c contactName
                                           , Employment_Name__c employmentName
                                           FROM fsCore__Financial__c
                                           where Employment_Name__c != null
                                           and fsCore__Is_Active__c = true
                                           and fsCore__Contact_Name__c in :contactIds
                                           group by fsCore__Contact_Name__c,Employment_Name__c
                                           HAVING COUNT(Id) > 1];
        System.debug(loggingLevel.ERROR,aggResult);                                   
        Map<Id,Integer> failedRecordsMap = new Map<Id,Integer>();
        for(AggregateResult agg :aggResult){
            failedRecordsMap.put((Id)agg.get('contactName'),(Integer)agg.get('num'));
        }                          
        
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (failedRecordsMap.get(financial.fsCore__Contact_Name__c) != null){
                financial.addError('Single Employment record cannot be mapped with multiple financial Records.');
            }
        }      
        
    }    
    private void validatePrimaryIncomeRecord(List<sObject> pNewRecList){
        Set<ID> contactIds = new Set<ID>();
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.fsCore__Financial_Family__c == 'Income'){
                if (financial.fsCore__Contact_Name__c != null){
                    contactIds.add(financial.fsCore__Contact_Name__c);
                }
            }
        }
        
        List<AggregateResult> aggResult = [SELECT count(Id) num
                                           , fsCore__Contact_Name__c contactName
                                           FROM fsCore__Financial__c
                                           where fsCore__Financial_Family__c = 'Income'
                                           and Is_Primary_Income__c = true
                                           and fsCore__Is_Active__c = true
                                           and fsCore__Contact_Name__c in :contactIds
                                           group by fsCore__Contact_Name__c
                                           HAVING COUNT(Id) > 1];
        System.debug(loggingLevel.ERROR,aggResult);                                   
        Map<Id,Integer> failedRecordsMap = new Map<Id,Integer>();
        for(AggregateResult agg :aggResult){
            failedRecordsMap.put((Id)agg.get('contactName'),(Integer)agg.get('num'));
            System.debug(loggingLevel.ERROR,'agg--'+agg);                                   
            
        }                          
        System.debug(loggingLevel.ERROR,failedRecordsMap);                                   
        
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (failedRecordsMap.get(financial.fsCore__Contact_Name__c) != null){
                financial.addError('At most, one financial record can be marked as primary.');
            }
        }      
        
    }
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){   
        System.debug(loggingLevel.Error, 'after update');
        validatePrimaryIncomeRecord(pNewRecList);    
        validateFinancialToIncomeRecord(pNewRecList); 
        generateUpdatedChecklists(pNewRecList,pOldRecList,pNewRecMap,pOldRecMap); 
       // SUP-410
       updateApplicantAnnualIncomeForVCL((List<fsCore__Financial__c>)pNewRecList,(Map<Id, fsCore__Financial__c>)pOldRecMap,true);
    }
    private void generateUpdatedChecklists(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        List<fsCore__Financial__c> financialList = new List<fsCore__Financial__c>();
        for (fsCore__Financial__c financial: (List<fsCore__Financial__c>)pNewRecList){
            if (financial.fsCore__Financial_Type__c <> ((fsCore__Financial__c)pOldRecMap.get(financial.Id)).fsCore__Financial_Type__c){
                financialList.add(financial);
            }
        }
        generateChecklists(financialList); 
    } 
    //SUP-410
    private void  updateApplicantAnnualIncomeForVCL(List<fsCore__Financial__c> pNewAppList, Map<Id, fsCore__Financial__c> pOldAppMap , Boolean IsUpdate){
        System.debug(loggingLevel.ERROR,'updateApplicantAnnualIncomeForVCL');
        Set<ID> contactIds = new Set<ID>();

        List<fsCore__Financial__c> eligibleFinancials = new List<fsCore__Financial__c>();    
        if(!IsUpdate){
            System.debug(loggingLevel.ERROR,'Insert or Delete');
            for (fsCore__Financial__c financial: pNewAppList){
                contactIds.add(financial.fsCore__Contact_Name__c);
            }
        }
        else{
            System.debug(loggingLevel.ERROR,'Update');
            for(fsCore__Financial__c financial : pNewAppList){        
                if((financial.Annual_Stated_Amount__c != pOldAppMap.get(financial.id).Annual_Stated_Amount__c)||
                   (financial.Annual_Verified_Amount__c != pOldAppMap.get(financial.id).Annual_Verified_Amount__c)){
                       contactIds.add(financial.fsCore__Contact_Name__c);
                   }
            }
        }
        Map<Id, Decimal > contactToStatedMap = new Map<Id, Decimal >();
        List<AggregateResult> aggResultStated = [SELECT sum(Annual_Stated_Amount__c) annualStatedAmount
                                           , fsCore__Contact_Name__c contactName
                                           FROM fsCore__Financial__c
                                           where fsCore__Financial_Family__c = 'Income'
                                           and fsCore__Is_Active__c = true
                                           and fsCore__Contact_Name__c in :contactIds
                                           group by fsCore__Contact_Name__c];
        System.debug(loggingLevel.ERROR,aggResultStated);
        for(AggregateResult agg :aggResultStated){
            contactToStatedMap.put((Id)agg.get('contactName'),(Decimal)agg.get('annualStatedAmount'));
        }

        Map<Id, Decimal > contactToVerifiedMap = new Map<Id, Decimal >();
        List<AggregateResult> aggResultVerified = [SELECT sum(Annual_Verified_Amount__c) annualVerifiedAmount
                                           , fsCore__Contact_Name__c contactName
                                           FROM fsCore__Financial__c
                                           where fsCore__Financial_Family__c = 'Income'
                                           and fsCore__Is_Active__c = true
                                           and fsCore__Contact_Name__c in :contactIds
                                           group by fsCore__Contact_Name__c];
        System.debug(loggingLevel.ERROR,aggResultVerified);
        for(AggregateResult agg :aggResultVerified){
            contactToVerifiedMap.put((Id)agg.get('contactName'),(Decimal)agg.get('annualVerifiedAmount'));
        }  
        System.debug(loggingLevel.ERROR,'contactToStatedMap'+contactToStatedMap);
        System.debug(loggingLevel.ERROR,'contactToVerifiedMap'+contactToVerifiedMap);
        
        if (contactIds.size() >0){
            System.debug(loggingLevel.ERROR,'Inside');
                List<fsCore__Lending_Application_Customer__c> applicants = [Select id
                                                                                , fsCore__Account_Name__c
                                                                                , fsCore__Contact_Name__c
                                                                                , Annual_Stated_Income__c
                                                                                , Annual_Verified_Income__c
                                                                             from fsCore__Lending_Application_Customer__c 
                                                                            where fsCore__Contact_Name__c in :contactIds
                                                                              and fsCore__Lending_Application_Number__r.Loan_Type__c = 'VCL' 
                                                                              and fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false];
              System.debug(loggingLevel.ERROR,'Applicants'+applicants);
            for(fsCore__Lending_Application_Customer__c applicant : applicants){
                applicant.Annual_Stated_Income__c = contactToStatedMap.get(applicant.fsCore__Contact_Name__c);
                applicant.Annual_Verified_Income__c = contactToVerifiedMap.get(applicant.fsCore__Contact_Name__c);
            }
             System.debug(loggingLevel.ERROR,'Applicants'+applicants);
             Database.update(applicants);
        
        }
    }
    
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){
        //PDI-808
        generateChecklists(pOldRecList); 
        //SUP-410
        updateApplicantAnnualIncomeForVCL((List<fsCore__Financial__c>)pOldRecList,null,false);
    }
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        //PDI-808
        generateChecklists(pNewRecList); 
    }
}