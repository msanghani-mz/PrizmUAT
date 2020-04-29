/**
 * @File Name          : CreditPullUtil.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/21/2019, 6:41:55 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/26/2019, 12:08:54 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class CreditPullUtil {
    /* Method to get the list of applicants by passing the application Id */
    public static List<CreditPullCustomer> getApplicationCustomers(Id pApplicationId){  
            List<CreditPullCustomer> creditCustomerList = new  List<CreditPullCustomer>();
            List<fsCore__Lending_Application_Customer__c> applicationCustomerList = [SELECT Id, Person_Name_Formula__c
                                                                                     , toLabel(fsCore__Customer_Type__c)
                                                                                     , fsCore__Lending_Application_Number__r.Id
                                                                                     , fsCore__Lending_Application_Number__r.Name
                                                                                     , fsCore__Lending_Application_Number__r.fsCore__Record_Sequence_Number__c
                                                                                     , fsCore__Account_Name__r.Id
                                                                                     , fsCore__Account_Name__r.Name
                                                                                     , fsCore__Account_Name__r.PersonBirthdate
                                                                                     , fsCore__Account_Name__r.PersonOtherStreet
                                                                                     , fsCore__Account_Name__r.PersonOtherCity
                                                                                     , fsCore__Account_Name__r.PersonOtherStateCode
                                                                                     , fsCore__Account_Name__r.fsCore__National_Identification_Number__pc
                                                                                     , fsCore__Account_Name__r.PersonOtherPostalCode    
                                                                                     , fsCore__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c
                                                                                     FROM fsCore__Lending_Application_Customer__c
                                                                                     WHERE fsCore__Lending_Application_Number__c = :pApplicationId
                                                                                     ORDER BY Id];
            
            for(fsCore__Lending_Application_Customer__c app: applicationCustomerList){

                CreditPullCustomer customer = new CreditPullCustomer();
                customer.customer_id = app.Id;
                customer.customer_name = app.Person_Name_Formula__c;
                customer.customer_account_id = app.fsCore__Account_Name__r.Id;
                customer.customer_account_name = app.fsCore__Account_Name__r.Name;
                customer.customer_account_person_birthdate = app.fsCore__Account_Name__r.PersonBirthdate;
                customer.customer_account_person_other_street = app.fsCore__Account_Name__r.PersonOtherStreet;
                customer.customer_account_person_other_city = app.fsCore__Account_Name__r.PersonOtherCity;
                customer.customer_account_person_other_state_code = app.fsCore__Account_Name__r.PersonOtherStateCode;
                customer.customer_account_national_identification_number = app.fsCore__Account_Name__r.fsCore__National_Identification_Number__pc;
                customer.customer_account_person_other_postal_code = app.fsCore__Account_Name__r.PersonOtherPostalCode;
                customer.customer_type = app.fsCore__Customer_Type__c;
                customer.customer_lending_application_number = app.fsCore__Lending_Application_Number__r.Id;
                customer.customer_lending_application_number_name = app.fsCore__Lending_Application_Number__r.Name;
                customer.customer_lending_application_number_record_sequence_number = app.fsCore__Lending_Application_Number__r.fsCore__Record_Sequence_Number__c;
                customer.customer_lending_application_number_credit_pull_record_type_name_formula = app.fsCore__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c;
                customer.is_customer_source_lending_application = true;
                creditCustomerList.add(customer);
            }        
        return creditCustomerList;
    
    }
    public static List<CreditPullCustomer> getApplicationCustomers(Set<Id> pApplicantsIds){  
            List<CreditPullCustomer> creditCustomerList = new  List<CreditPullCustomer>();
            List<fsCore__Lending_Application_Customer__c> applicationCustomerList = [SELECT Id
                                                                                          , Name
                                                                                          , Person_Name_Formula__c
                                                                                          , fsCore__Customer_Type__c
                                                                                          , fsCore__Lending_Application_Number__r.Id
                                                                                          , fsCore__Lending_Application_Number__r.Name                                                                                           , fsCore__Lending_Application_Number__r.fsCore__Record_Sequence_Number__c
                                                                                          , fsCore__Account_Name__r.Id
                                                                                          , fsCore__Account_Name__r.Name
                                                                                          , fsCore__Account_Name__r.PersonBirthdate
                                                                                          , fsCore__Account_Name__r.PersonOtherStreet
                                                                                          , fsCore__Account_Name__r.PersonOtherCity
                                                                                          , fsCore__Account_Name__r.PersonOtherStateCode
                                                                                          , fsCore__Account_Name__r.fsCore__National_Identification_Number__pc
                                                                                          , fsCore__Account_Name__r.PersonOtherPostalCode
                                                                                          , fsCore__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c
                                                                                       FROM fsCore__Lending_Application_Customer__c
                                                                                      WHERE Id IN :pApplicantsIds
                                                                                      ORDER BY Id];
            
            for(fsCore__Lending_Application_Customer__c app: applicationCustomerList){

                CreditPullCustomer customer = new CreditPullCustomer();
                customer.customer_id = app.Id;
                customer.customer_name = app.Person_Name_Formula__c;
                customer.customer_account_id = app.fsCore__Account_Name__r.Id;
                customer.customer_account_name = app.fsCore__Account_Name__r.Name;
                customer.customer_account_person_birthdate = app.fsCore__Account_Name__r.PersonBirthdate;
                customer.customer_account_person_other_street = app.fsCore__Account_Name__r.PersonOtherStreet;
                customer.customer_account_person_other_city = app.fsCore__Account_Name__r.PersonOtherCity;
                customer.customer_account_person_other_state_code = app.fsCore__Account_Name__r.PersonOtherStateCode;
                customer.customer_account_national_identification_number = app.fsCore__Account_Name__r.fsCore__National_Identification_Number__pc;
                customer.customer_account_person_other_postal_code = app.fsCore__Account_Name__r.PersonOtherPostalCode;
                customer.customer_type = app.fsCore__Customer_Type__c;
                customer.customer_lending_application_number = app.fsCore__Lending_Application_Number__r.Id;
                customer.customer_lending_application_number_name = app.fsCore__Lending_Application_Number__r.Name;
                customer.customer_lending_application_number_record_sequence_number = app.fsCore__Lending_Application_Number__r.fsCore__Record_Sequence_Number__c;
                customer.customer_lending_application_number_credit_pull_record_type_name_formula = app.fsCore__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c;
                customer.is_customer_source_lending_application = true;
                creditCustomerList.add(customer);
            }        
        return creditCustomerList;
    
    }   
    public static List<CreditPullCustomer> getContractCustomers(Id pContractId){  
            List<CreditPullCustomer> creditCustomerList = new  List<CreditPullCustomer>();
            List<fsServ__Contract_Customer__c> contractCustomerList = [SELECT Id, Person_Name_Formula__c
                                                                       , toLabel(fsServ__Customer_Type__c)
                                                                       , fsServ__Lending_Contract_Number__r.Id
                                                                       , fsServ__Lending_Contract_Number__r.Name
                                                                       , fsServ__Lending_Contract_Number__r.fsServ__Record_Sequence_Number__c
                                                                       , fsServ__Account_Name__r.Id
                                                                       , fsServ__Account_Name__r.Name
                                                                       , fsServ__Account_Name__r.PersonBirthdate
                                                                       , fsServ__Account_Name__r.PersonOtherStreet
                                                                       , fsServ__Account_Name__r.PersonOtherCity
                                                                       , fsServ__Account_Name__r.PersonOtherStateCode
                                                                       , fsServ__Account_Name__r.fsCore__National_Identification_Number__pc
                                                                       , fsServ__Account_Name__r.PersonOtherPostalCode  
                                                                       , fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c
                                                                       , fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__c
                                                                       FROM fsServ__Contract_Customer__c
                                                                       WHERE fsServ__Lending_Contract_Number__c = :pContractId
                                                                       ORDER BY Id];
            
            for(fsServ__Contract_Customer__c contract: contractCustomerList){
                CreditPullCustomer customer = new CreditPullCustomer();
                customer.customer_id = contract.Id;
                customer.customer_name = contract.Person_Name_Formula__c;
                customer.customer_account_id = contract.fsServ__Account_Name__r.Id;
                customer.customer_account_name = contract.fsServ__Account_Name__r.Name;
                customer.customer_account_person_birthdate = contract.fsServ__Account_Name__r.PersonBirthdate;
                customer.customer_account_person_other_street = contract.fsServ__Account_Name__r.PersonOtherStreet;
                customer.customer_account_person_other_city = contract.fsServ__Account_Name__r.PersonOtherCity;
                customer.customer_account_person_other_state_code = contract.fsServ__Account_Name__r.PersonOtherStateCode;
                customer.customer_account_national_identification_number = contract.fsServ__Account_Name__r.fsCore__National_Identification_Number__pc;
                customer.customer_account_person_other_postal_code = contract.fsServ__Account_Name__r.PersonOtherPostalCode;
                customer.customer_type = contract.fsServ__Customer_Type__c;
                customer.customer_lending_application_number = contract.fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__c;
                customer.customer_lending_contract_number = contract.fsServ__Lending_Contract_Number__r.Id;
                customer.customer_lending_contract_number_name = contract.fsServ__Lending_Contract_Number__r.Name;
                customer.customer_lending_contract_number_record_sequence_number = contract.fsServ__Lending_Contract_Number__r.fsServ__Record_Sequence_Number__c;
                customer.customer_lending_application_number_credit_pull_record_type_name_formula = contract.fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c;
                customer.is_customer_source_lending_application = false;
                creditCustomerList.add(customer);
                
            }            
        return creditCustomerList;
    
    }    
   public static List<CreditPullCustomer> getContractCustomers(Set<Id> pCustomerIds){  
            List<CreditPullCustomer> creditCustomerList = new  List<CreditPullCustomer>();
            List<fsServ__Contract_Customer__c> contractCustomerList = [SELECT Id, Person_Name_Formula__c
                                                                       , fsServ__Customer_Type__c
                                                                       , fsServ__Lending_Contract_Number__r.Id
                                                                       , fsServ__Lending_Contract_Number__r.Name
                                                                       , fsServ__Lending_Contract_Number__r.fsServ__Record_Sequence_Number__c
                                                                       , fsServ__Account_Name__r.Id
                                                                       , fsServ__Account_Name__r.Name
                                                                       , fsServ__Account_Name__r.PersonBirthdate
                                                                       , fsServ__Account_Name__r.PersonOtherStreet
                                                                       , fsServ__Account_Name__r.PersonOtherCity
                                                                       , fsServ__Account_Name__r.PersonOtherStateCode
                                                                       , fsServ__Account_Name__r.fsCore__National_Identification_Number__pc
                                                                       , fsServ__Account_Name__r.PersonOtherPostalCode  
                                                                       , fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c
                                                                       , fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__c
                                                                       FROM fsServ__Contract_Customer__c
                                                                       WHERE Id = :pCustomerIds
                                                                       ORDER BY Id];
            
            for(fsServ__Contract_Customer__c contract: contractCustomerList){
                CreditPullCustomer customer = new CreditPullCustomer();
                customer.customer_id = contract.Id;
                customer.customer_name = contract.Person_Name_Formula__c;
                customer.customer_account_id = contract.fsServ__Account_Name__r.Id;
                customer.customer_account_name = contract.fsServ__Account_Name__r.Name;
                customer.customer_account_person_birthdate = contract.fsServ__Account_Name__r.PersonBirthdate;
                customer.customer_account_person_other_street = contract.fsServ__Account_Name__r.PersonOtherStreet;
                customer.customer_account_person_other_city = contract.fsServ__Account_Name__r.PersonOtherCity;
                customer.customer_account_person_other_state_code = contract.fsServ__Account_Name__r.PersonOtherStateCode;
                customer.customer_account_national_identification_number = contract.fsServ__Account_Name__r.fsCore__National_Identification_Number__pc;
                customer.customer_account_person_other_postal_code = contract.fsServ__Account_Name__r.PersonOtherPostalCode;
                customer.customer_type = contract.fsServ__Customer_Type__c;
                customer.customer_lending_application_number = contract.fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__c;
                customer.customer_lending_contract_number = contract.fsServ__Lending_Contract_Number__r.Id;
                customer.customer_lending_contract_number_name = contract.fsServ__Lending_Contract_Number__r.Name;
                customer.customer_lending_contract_number_record_sequence_number = contract.fsServ__Lending_Contract_Number__r.fsServ__Record_Sequence_Number__c;
                customer.customer_lending_application_number_credit_pull_record_type_name_formula = contract.fsServ__Lending_Contract_Number__r.fsServ__Lending_Application_Number__r.Credit_Pull_Record_Type_Name_Formula__c;
                customer.is_customer_source_lending_application = false;
                creditCustomerList.add(customer);
                
            }            
        return creditCustomerList;
    
    }         
}