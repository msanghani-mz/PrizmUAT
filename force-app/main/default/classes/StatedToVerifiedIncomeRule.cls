/*------------------------------------------------------------
Author:         Financial Spectra DEV
Description:    Custom rule for to check stated to verified income ratio
History
<Date>      <Authors Name>      <Brief Description of Change>
20-Aug-19   FS Dev              Created
------------------------------------------------------------*/
global class StatedToVerifiedIncomeRule implements fsCore.CustomRuleEvaluator{

    private fsCore__Rule_Setup__c ruleToBeEvaluated;
    private Map<Id, fsCore.RuleResultObject> sourceRecToResultMap;
    
    global StatedToVerifiedIncomeRule(){
        sourceRecToResultMap = new Map<Id, fsCore.RuleResultObject>();
    }
    
    global void setRule(fsCore__Rule_Setup__c pRule){
        ruleToBeEvaluated = pRule;
    }
    
    global void evaluate(List<SObject> pSourceRecordList){
        Set<Id> appIdSet = new Set<Id>();
        for(fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pSourceRecordList){
            appIdSet.add(app.Id);
        }
        
        Map<Id, List<fsCore__Lending_Application_Customer__c>> applicantsMap = fscore.LendingApplicationCustomerUtil.getCustomersMap(appIdSet);
        
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, Set<Id>> applicationToContactIdSet = new Map<Id, Set<Id>>();
        Map<Id, fsCore__Lending_Application_Customer__c> contactToApplicantMap = new Map<Id, fsCore__Lending_Application_Customer__c>();//AD
        for(Id appId : applicantsMap.keySet()){
            Set<Id> appContactIDs = new Set<Id>();
            for(fsCore__Lending_Application_Customer__c applicant : applicantsMap.get(appId)){
                contactIdSet.add(applicant.fsCore__Contact_Name__c);
                appContactIDs.add(applicant.fsCore__Contact_Name__c);
                contactToApplicantMap.put(applicant.fsCore__Contact_Name__c,applicant);
            }
            applicationToContactIdSet.put(appId, appContactIDs);
        }
        
        List<fsCore__Financial__c> applicantIncomes = 
                [SELECT Id, fsCore__Contact_Name__c
                      , Stated_to_Verified_Percent__c
                      , fsCore__Monthly_Stated_Amount__c 
                      , fsCore__Monthly_Verified_Amount__c 
                   FROM fsCore__Financial__c 
                  WHERE fsCore__Contact_Name__c IN :contactIdSet
                    AND fsCore__Financial_Family__c = 'Income'
                    AND fsCore__Is_Active__c = true];
        
        Map<Id,List<fsCore__Financial__c>> financialAplIncomeMap = new Map<Id,List<fsCore__Financial__c>> ();
        for(fsCore__Financial__c finIncome : applicantIncomes){
            financialAplIncomeMap.put(finIncome.fsCore__Contact_Name__c, new List<fsCore__Financial__c>());
        }
        for(fsCore__Financial__c finIncome : applicantIncomes){
            if (financialAplIncomeMap.containsKey(finIncome.fsCore__Contact_Name__c)){
                financialAplIncomeMap.get(finIncome.fsCore__Contact_Name__c).add(finIncome);
            }
        }        

        Map<Id, Boolean> contactIdToIncomeVerificationMap = new Map<Id, Boolean>();
        Map<Id, Decimal> contactIdToIncomeVerificationPercentMap = new Map<Id, Decimal>();
        for (Id contact : financialAplIncomeMap.keySet()){
            //Decimal totalPercent = 0;
            //Decimal IncomeCounter = 0; 
            Decimal totalMonthlyStated = contactToApplicantMap.get(contact).Monthly_Stated_Income_Formula__c; 
            Decimal totalMonthlyVerified = 0;
            Decimal totalStatedToVerifiedPercent = 0;

            for(fsCore__Financial__c finIncome : financialAplIncomeMap.get(contact)){
                //totalMonthlyStated +=  finIncome.fsCore__Monthly_Stated_Amount__c;
                totalMonthlyVerified +=  finIncome.fsCore__Monthly_Verified_Amount__c;                
                //totalPercent +=  finIncome.Stated_to_Verified_Percent__c;
                //IncomeCounter += 1; 
            }
            //totalStatedToVerifiedPercent = totalPercent/IncomeCounter;
            if ((totalMonthlyVerified == 0 )||(totalMonthlyStated == 0)){
                totalStatedToVerifiedPercent = 0;
            }else{
                system.debug(logginglevel.error,'  **totalMonthlyStated** '+totalMonthlyStated);
	            totalStatedToVerifiedPercent = (totalMonthlyVerified/totalMonthlyStated) * 100;
            }
            system.debug(logginglevel.error,'  **totalMonthlyVerified** '+totalMonthlyVerified);
            system.debug(logginglevel.error,'  **totalStatedToVerifiedPercent** '+totalStatedToVerifiedPercent);
            
            Boolean thisSTVValid = (totalStatedToVerifiedPercent >= 85);
            contactIdToIncomeVerificationMap.put(contact, thisSTVValid);
            contactIdToIncomeVerificationPercentMap.put(contact, ((totalStatedToVerifiedPercent != null)?totalStatedToVerifiedPercent.round():0.00));
        }
        
        
        for(fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pSourceRecordList){
            fsCore.RuleResultObject resultObj = new fsCore.RuleResultObject();
            Boolean isAnyApplicantFailed = false;
            String failuremessage = '';
            if (applicationToContactIdSet.containsKey(app.Id)){
                for (Id contactId : applicationToContactIdSet.get(app.Id)){
                    if (contactIdToIncomeVerificationMap.containsKey(contactId)){
                        resultObj.setApplicable(true);
                        resultObj.setResult(contactIdToIncomeVerificationMap.get(contactId));
                        if (!contactIdToIncomeVerificationMap.get(contactId)){
                            isAnyApplicantFailed = true;
                        }
                        
                        if (!resultObj.getResult()){
                            failuremessage += '. '+contactToApplicantMap.get(contactId).fsCore__Customer_Name_Formula__c  +' Expected: 85, Actual: '+contactIdToIncomeVerificationPercentMap.get(contactId);
                            resultObj.setResultMessage(ruleToBeEvaluated.fsCore__Failure_Message__c);
                        }
                    }
                }
            } 
            //IF THE RULE FAILS FOR ANY OF THE APPLICANT THEN MARK AS FAILED
            if (isAnyApplicantFailed){
                resultObj.setResult(false);
                resultObj.setResultMessage(resultObj.getResultMessage()+failuremessage);
            }
            sourceRecToResultMap.put(app.Id, resultObj);
        }
    }
    
    global Map<Id, fsCore.RuleResultObject> getResults(){
        return sourceRecToResultMap;
    }
    
    global fsCore.RuleResultObject getResult(Id pSourceRecordId){
        return sourceRecToResultMap.get(pSourceRecordId);
    }
}