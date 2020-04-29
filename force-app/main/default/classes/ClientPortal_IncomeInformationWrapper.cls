public without sharing class ClientPortal_IncomeInformationWrapper {
    @AuraEnabled public ClientPortal_VCLHomeCntrl.IncomeWrapper primaryIncome {get; set;}
    @AuraEnabled public List<ClientPortal_VCLHomeCntrl.IncomeWrapper> additionalIncomes {get; set;}
}