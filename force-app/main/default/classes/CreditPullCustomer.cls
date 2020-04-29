public class CreditPullCustomer {
    
    @AuraEnabled public id     customer_id{get;set;}
    @AuraEnabled public Account customer_account {get;set;}
    @AuraEnabled public id     customer_account_id{get;set;}
    @AuraEnabled public String customer_type{get;set;}
    @AuraEnabled public String customer_name{get;set;}
    @AuraEnabled public String customer_account_name{get;set;}
    @AuraEnabled public String customer_account_number{get;set;}
    @AuraEnabled public Date   customer_account_person_birthdate{get;set;}
    @AuraEnabled public String customer_account_person_other_street{get;set;}
    @AuraEnabled public String customer_account_person_other_city{get;set;}
    @AuraEnabled public String customer_account_person_other_state_code{get;set;}
    @AuraEnabled public String customer_account_national_identification_number{get;set;}
    @AuraEnabled public String customer_account_person_other_postal_code{get;set;}
    @AuraEnabled public id     customer_lending_application_number{get;set;}
    @AuraEnabled public String customer_lending_application_number_name{get;set;}
    @AuraEnabled public String customer_lending_application_number_record_sequence_number{get;set;}
    @AuraEnabled public String customer_lending_application_number_credit_pull_record_type_name_formula{get;set;} 
    @AuraEnabled public id     customer_lending_contract_number{get;set;}
    @AuraEnabled public String customer_lending_contract_number_name{get;set;}
    @AuraEnabled public String customer_lending_contract_number_record_sequence_number{get;set;}
    @AuraEnabled public boolean is_customer_source_lending_application {get;set;}  

}