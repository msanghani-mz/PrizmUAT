/**
 * Class Name  : ApplicationUtil
 * Description : This class has common utility methods related to 
 *               application processing
 * Author      : Financial Spectra
 *
 */
public class ApplicationUtil {

    /* Method to get a map of Opportunity records */
    public static Map<Id, Opportunity> getSourceOpportunityMap(Set<Id> pSourceOppIds){
        Map<Id, Opportunity> sourceOppMap = new Map<Id, Opportunity>(
                        (List<Opportunity>)fsCore.SObjectQueryUtil.getSObjectRecordListById(Schema.SObjectType.Opportunity.getName()
                                                                                           , pSourceOppIds));
        //TO DO EVALUATE IF WE CAN PASS Set<String> pFieldSet) in THIRD PARAM
    
        return sourceOppMap;
    }

    /* Method to get a map of fsCore__Lending_Application__c records */
    public static Map<Id, fscore__Lending_Application__c> getLendingApplicationMap(Set<Id> pLendingAppIds){
        return fsCore.LendingApplicationUtil.getApplications(pLendingAppIds);
    }

    /* Method to get a map of Account records */
    public static Map<Id, Account> getApplicantContactMap(Set<Id> pAccountIds){
        Map<Id, Account> contactMap = new Map<Id, Account>(
                        (List<Account>)fsCore.SObjectQueryUtil.getSObjectRecordListById(Schema.SObjectType.Account.getName(), pAccountIds));
    
        return contactMap;
    }

    /* Method to get map of Lending Application Id to Loan Amount Itemization */
    public static Map<Id, fsCore__Lending_Application_Itemization__c> getLoanAmountItemizationMap(Set<Id> pLendingAppIds){
        List<fsCore__Lending_Application_Itemization__c> appItemizations = 
                    [SELECT Id, fsCore__Lending_Application_Number__c
                          , fsCore__Requested_Amount_Unsigned__c
                       FROM fsCore__Lending_Application_Itemization__c
                      WHERE fsCore__Lending_Application_Number__c IN :pLendingAppIds
                        AND fsCore__Itemization_Name__r.fsCore__Itemization_Code__c = :SFSConstants.AMOUNT_DISBURSED_ITEMIZATION];
        
        Map<Id, fsCore__Lending_Application_Itemization__c> loanAmtItmzMap = new Map<Id, fsCore__Lending_Application_Itemization__c>();
        for(fsCore__Lending_Application_Itemization__c appItmz : appItemizations){
            loanAmtItmzMap.put(appItmz.fsCore__Lending_Application_Number__c , appItmz);
        }
    
        return loanAmtItmzMap;
    }

    public static void generateApplicationRecordTitle(Set<Id> pApplicationIds){

        List<fsCore__Lending_Application__c> applicationList = [SELECT id
                                                               , name
                                                               , fsCore__Product_Name__c
                                                               , fsCore__Title__c
                                                            FROM fsCore__Lending_Application__c
                                                          WHERE Id in :pApplicationIds];
    
        Map<Id, List<fsCore__Lending_Application_Customer__c>> applicationCustomerMap
                                                = new Map<Id, List<fsCore__Lending_Application_Customer__c>>();
        
        Set<Id> productIdSet = new Set<Id>();
        for (fsCore__Lending_Application__c application : applicationList){
            applicationCustomerMap.put(application.Id, new List<fsCore__Lending_Application_Customer__c>());
            productIdSet.add(application.fsCore__Product_Name__c);
        }
        
        //get customers list
        List<fsCore__Lending_Application_Customer__c> customerList = [SELECT Id, Name
                                                                     , fsCore__Lending_Application_Number__c
                                                                     , fsCore__Customer_Type__c
                                                                     , Person_Name_Formula__c
                                                                FROM fsCore__Lending_Application_Customer__c
                                                               WHERE fsCore__Lending_Application_Number__c IN :pApplicationIds
                                                               ORDER BY fsCore__Lending_Application_Number__c, Name];

        for (fsCore__Lending_Application_Customer__c customer : customerList){
            List<fsCore__Lending_Application_Customer__c> applicationCustomerList = applicationCustomerMap.get(customer.fsCore__Lending_Application_Number__c);
            applicationCustomerList.add(customer);
            applicationCustomerMap.put(customer.fsCore__Lending_Application_Number__c, applicationCustomerList);
        }

        //prepare product map
        Map<Id, fsCore__Product_Setup__c> productMap = new Map<Id, fsCore__Product_Setup__c>(
                                                     [SELECT Id, Name
                                                           , fsCore__Title_Format__c
                                                           , fsCore__Custom_Title_Format_Class__c
                                                        FROM fsCore__Product_Setup__c
                                                       WHERE Id IN :productIdSet]);
        
        //
        //set application title
        Map<Id, String> applicationRecordTitleMap = new Map<Id, String>();

        for (fsCore__Lending_Application__c application : applicationList){
            //if there is no customer attached to application, set title to null
            if (applicationCustomerMap.get(application.Id).size() == 0){
                applicationRecordTitleMap.put(application.Id, fsCore.Constants.BLANK_STRING);
                continue;
            }
            
            //instantiate record title generation class using interface
            fsCore.RecordTitleGeneratorImpl appTitleGenImpl = new fsCore.RecordTitleGeneratorImpl();
            fsCore__Product_Setup__c applicationProduct = productMap.get(application.fsCore__Product_Name__c);
        
                
            appTitleGenImpl.resetParams();
            appTitleGenImpl.setFormat(applicationProduct.fsCore__Title_Format__c);
            appTitleGenImpl.setSObjectRecord(application);
            
            for (fsCore__Lending_Application_Customer__c customer : applicationCustomerMap.get(application.Id)){
                if (String.IsNotBlank(customer.fsCore__Customer_Type__c)
                        && String.IsNotBlank(customer.Person_Name_Formula__c)){
                    appTitleGenImpl.addParameter(customer.fsCore__Customer_Type__c, customer.Person_Name_Formula__c);
                }
            }
            
            String recordTitle = appTitleGenImpl.getRecordTitle();
            recordTitle = String.IsNotBlank(recordTitle) ? recordTitle : application.fsCore__Title__c;
            
            application.fsCore__Title__c = recordTitle;
        }
        fsCore.LendingApplicationDMLWrapper.getInstance().updateData(applicationList);
    }       

}