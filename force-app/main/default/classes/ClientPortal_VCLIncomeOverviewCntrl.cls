public without sharing class ClientPortal_VCLIncomeOverviewCntrl {
    
    @TestVisible
    private static final String LENDING_APPLICATION_STATUS = 'Offer Accepted';

    @AuraEnabled
    public static ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig getClientPortalUIConfiguration(String domainURL, String portfolioName) {
        ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig ciConfig =  ClientPortal_CustomRegisterCntrl.getClientPortalUIConfiguration(domainURL,  portfolioName);
        return ciConfig;
    }

    @AuraEnabled
    public static ClientPortal_IncomeInformationWrapper getIncomeDetails(){
        //CombinedIncomeWrapper incomeInfo = new CombinedIncomeWrapper();
        ClientPortal_IncomeInformationWrapper incomeInfo = new ClientPortal_IncomeInformationWrapper();
        //ClientPortal_IncomeInformationWrapper secondaryApplicantIncomeInfo = new ClientPortal_IncomeInformationWrapper();

        User userInstance = [SELECT Id, Name, AccountId
                            FROM User
                            WHERE Id =: UserInfo.getUserId()
                            AND IsPortalEnabled = true];
        
        //incomeInfo = getApplicantAccounts(userInstance.AccountId);
        incomeInfo = ClientPortal_VCLHomeCntrl.getIncomeInformation(userInstance.AccountId);
        /* if(incomeInfo.hasCoApplicant){
            incomeInfo.secondaryApplicantIncome = ClientPortal_VCLHomeCntrl.getIncomeInformation(incomeInfo.secondaryApplicantAccount.Id);
        } */
        return incomeInfo;
    }

    @AuraEnabled
    public static void updateIncomeInformation(String primaryIncomeWrapperString, String additionalIncomesString){
        String result;
        User userInstance = [SELECT Id, Name, AccountId
                            FROM User
                            WHERE Id =: UserInfo.getUserId()
                            AND IsPortalEnabled = true];
        Account accountInstance = [Select Id, PersonContactId, VCL_Related_Portal_Account__c FROM Account WHERE Id = :userInstance.AccountId];
        result = ClientPortal_VCLHomeCntrl.updateIncomeInformation(primaryIncomeWrapperString, additionalIncomesString, JSON.serialize(accountInstance), false);
        if(result != 'Success'){
            throw new AurahandledException(result);
        }
    }
    @TestVisible
    private static CombinedIncomeWrapper getApplicantAccounts(Id userAccountId){
        CombinedIncomeWrapper wrapper = new CombinedIncomeWrapper();
        wrapper.hasCoApplicant = false;
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name
                                                                    FROM fsCore__Lending_Application__c
                                                                    WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                WHERE fsCore__Account_Name__c = :userAccountId)
                                                                    ORDER BY SystemModstamp DESC
                                                                    LIMIT 1];
        if(!lendingApplicationList.isEmpty()){
            for(Account accountInstance : [SELECT Id, Name, PersonContactId, Is_VCL_Portal_Co_Applicant__c 
                                            FROM Account
                                            WHERE Id IN (SELECT fsCore__Account_Name__c
                                                        FROM fsCore__Lending_Application_Customer__c
                                                        WHERE fsCore__Lending_Application_Number__c = :lendingApplicationList[0].Id)]){
                if(accountInstance.Is_VCL_Portal_Co_Applicant__c){
                    wrapper.secondaryApplicantAccount = accountInstance;
                    wrapper.hasCoApplicant = true;
                }else{
                    wrapper.primaryApplicantAccount = accountInstance;
                }
            }
        }
        return wrapper;
    }

    @AuraEnabled
    public static ClientPortal_VCLHomeCntrl.IncomeWrapper getIncomeWrapperInstance(){
        return ClientPortal_VCLHomeCntrl.getIncomeWrapperInstance();
    }

    @AuraEnabled
    public static string deleteAdditionalIncomeInformation(Id additionalIncomeId, Id additionalEmploymentId){
        return ClientPortal_VCLHomeCntrl.deleteAdditionalIncomeInformation(additionalIncomeId,additionalEmploymentId);
    }

    public class CombinedIncomeWrapper{
        @AuraEnabled public ClientPortal_IncomeInformationWrapper primaryApplicantIncome {get; set;}
        @AuraEnabled public ClientPortal_IncomeInformationWrapper secondaryApplicantIncome {get; set;}
        @AuraEnabled public Account primaryApplicantAccount {get; set;}
        @AuraEnabled public Account secondaryApplicantAccount {get; set;}
        @AuraEnabled public Boolean hasCoApplicant {get; set;}
    }
}