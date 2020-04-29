public without sharing class ClientPortal_DNLIncomeWrapper {
    @AuraEnabled
    public Account acc {get; set;}
    @AuraEnabled
    public Opportunity opty {get;set;}
    @AuraEnabled
    public IncomeWrapper primaryIncome {get; set;}
    @AuraEnabled
    public List<IncomeWrapper> additionalIncomes {get; set;}
    
    public class IncomeWrapper {
        @AuraEnabled
        public fsCore__Financial__c income {get; set;}
        @AuraEnabled
        public fsCore__Employment__c employment {get; set;}
        @AuraEnabled
        public fsCore__Employment__c previousEmployment {get; set;}
    }
}