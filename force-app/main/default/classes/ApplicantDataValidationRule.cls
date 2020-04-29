/*------------------------------------------------------------
Author:         Financial Spectra DEV
Description:    Custom rule validate the required applicant fields 
                for CFT client record creation
History
<Date>      <Authors Name>      <Brief Description of Change>
06-Aug-19   FS Dev              Created
------------------------------------------------------------*/
global class ApplicantDataValidationRule implements fsCore.CustomRuleEvaluator{

    private fsCore__Rule_Setup__c mRuleToBeEvaluated;
    private Map<Id, fsCore.RuleResultObject> mSourceRecToResultMap;
    private Map<Id, List<fsCore__Bank_Account__c>> mAccountToBankAccountMap;
    
    global ApplicantDataValidationRule(){
        mSourceRecToResultMap = new Map<Id, fsCore.RuleResultObject>();
        mAccountToBankAccountMap = new Map<Id, List<fsCore__Bank_Account__c>>();
    }
    
    global void setRule(fsCore__Rule_Setup__c pRule){
        mRuleToBeEvaluated = pRule;
    }
    
    global void evaluate(List<SObject> pSourceRecordList){
        Set<Id> appIdSet = new Set<Id>();
        for(fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pSourceRecordList){
            appIdSet.add(app.Id);
        }
        
        List<fsCore__Lending_Application_Customer__c> allApplicants 
                = [SELECT Id, Name
                        , fsCore__Is_Primary__c 
                        , fsCore__Lending_Application_Number__c
                        , fsCore__Account_Name__r.FirstName 
                        , fsCore__Account_Name__r.LastName 
                        , fsCore__Account_Name__r.PersonBirthDate
                        , fsCore__Account_Name__r.fsCore__National_Identification_Number__pc
                        , fsCore__Account_Name__r.PersonMailingCity
                        , fsCore__Account_Name__r.PersonMailingStateCode
                        , fsCore__Account_Name__r.PersonMailingPostalCode
                     FROM fsCore__Lending_Application_Customer__c 
                    WHERE fsCore__Lending_Application_Number__c IN :appIdSet
                    ORDER BY fsCore__Lending_Application_Number__c, Name];
        
        Map<Id, List<fsCore__Lending_Application_Customer__c>> applicantsMap = new Map<Id, List<fsCore__Lending_Application_Customer__c>>();
        Set<Id> primaryAccountIDs = new Set<Id>();
        for(fsCore__Lending_Application_Customer__c applicant : allApplicants){
            List<fsCore__Lending_Application_Customer__c> appApplicants = new List<fsCore__Lending_Application_Customer__c>();
            if (applicantsMap.containsKey(applicant.fsCore__Lending_Application_Number__c)){
                appApplicants = applicantsMap.get(applicant.fsCore__Lending_Application_Number__c);
            }
            appApplicants.add(applicant);
            applicantsMap.put(applicant.fsCore__Lending_Application_Number__c, appApplicants);
            if (applicant.fsCore__Is_Primary__c){ primaryAccountIDs.add(applicant.fsCore__Account_Name__c); }
        }
        
        mAccountToBankAccountMap = fsCore.BankAccountUtil.getAccountBankAccountListMap(primaryAccountIDs);
        
        for(fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pSourceRecordList){
            fsCore.RuleResultObject ruleResult = new fsCore.RuleResultObject();
            ruleResult.setApplicable(true);
            
            if (applicantsMap.containsKey(app.Id)){
                List<fsCore__Lending_Application_Customer__c> appApplicants = applicantsMap.get(app.Id);
                List<String> valErrors = validateApplicants(appApplicants);
                ruleResult.setResult(valErrors.isEmpty());
                ruleResult.setResultMessage(valErrors.isEmpty() ? 'All required data attributes are available' : String.join(valErrors, ';'));
            } 
            else {
                ruleResult.setResult(false);
                ruleResult.setResultMessage('No applicant record found for the Application to validate the required data attributes.');
            }
            
            mSourceRecToResultMap.put(app.Id, ruleResult);
        }
    }
    
    private List<String> validateApplicants(List<fsCore__Lending_Application_Customer__c> pApplicants){
        List<String> valErrors = new List<String>();
        for(fsCore__Lending_Application_Customer__c applicant : pApplicants){
            if (String.IsBlank(applicant.fsCore__Account_Name__r.FirstName)){
                valErrors.add('First Name is blank for Applicant # ' + applicant.Name);
            }
            if (applicant.fsCore__Account_Name__r.PersonBirthDate == null){
                valErrors.add('Birthdate is blank for Applicant # ' + applicant.Name);
            }
            if (String.IsBlank(applicant.fsCore__Account_Name__r.fsCore__National_Identification_Number__pc)){
                valErrors.add('SSN is blank for Applicant # ' + applicant.Name);
            }
            if (applicant.fsCore__Is_Primary__c && !mAccountToBankAccountMap.containsKey(applicant.fsCore__Account_Name__c)){
                valErrors.add('Bank Account is not defined for Applicant # ' + applicant.Name);
            }
            if (applicant.fsCore__Is_Primary__c && mAccountToBankAccountMap.containsKey(applicant.fsCore__Account_Name__c)){
                if (String.IsBlank(applicant.fsCore__Account_Name__r.PersonMailingCity)){
                    valErrors.add('Mailing Address City is blank for Applicant # ' + applicant.Name);
                }
                if (String.IsBlank(applicant.fsCore__Account_Name__r.PersonMailingStateCode)){
                    valErrors.add('Mailing Address State is blank for Applicant # ' + applicant.Name);
                }
                if (String.IsBlank(applicant.fsCore__Account_Name__r.PersonMailingPostalCode)){
                    valErrors.add('Mailing Address Postal Code is blank for Applicant # ' + applicant.Name);
                }
                
                for (fsCore__Bank_Account__c bankAcct : mAccountToBankAccountMap.get(applicant.fsCore__Account_Name__c)){
                    if (String.IsBlank(bankAcct.fsCore__Bank_Identification_Code__c)){
                        valErrors.add('Routing Number is blank for Bank Account ' + bankAcct.Name);
                    }
                    if (String.IsBlank(bankAcct.fsCore__Bank_Account_Type__c)){
                        valErrors.add('Account Type is blank for Bank Account ' + bankAcct.Name);
                    }
                }
            }
        }
        return valErrors;
    }
    
    global Map<Id, fsCore.RuleResultObject> getResults(){
        return mSourceRecToResultMap;
    }
    
    global fsCore.RuleResultObject getResult(Id pSourceRecordId){
        return mSourceRecToResultMap.get(pSourceRecordId);
    }
}