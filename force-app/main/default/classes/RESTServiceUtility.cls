/*
 * Class Name   - RESTServiceUtility
 * Description  - Common Methods used in the REST Services
 * Developer(s) - Financial Spectra DEV
 */
public with sharing class RESTServiceUtility {
    
    public static Map<String, String> getDefaultBranchInfo(){
        Map<String, String> defaultBranchMap = fsCore.UserBranchUtil.getDefaultBranchInfo();
         System.debug(loggingLevel.ERROR,'Branch'+ defaultBranchMap);
        return defaultBranchMap;
    }
            
    public static fsCore__Branch_Setup__c getBranch(String pBranchCode){
        fsCore__Branch_Setup__c branch;
        try{
             branch = [SELECT Id, fsCore__Company_Name__c, fscore__Business_Date__c 
                         FROM fsCore__Branch_Setup__c 
                        WHERE fsCore__Branch_Code__c = :pBranchCode];
        }
        catch (Exception e){
            System.debug(loggingLevel.ERROR, '-- Error when fetching branch : ' + e);
        }
        return branch;
    }
    
    public static fsCore__Product_Setup__c getProduct(String pProductCode){
        fsCore.DynamicQueryBuilder productQry = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Product_Setup__c.getName());
        productQry.addFields();
        productQry.addWhereConditionWithValue(1,'fsCore__Product_Code__c', '=', pProductCode);
        
        List<fsCore__Product_Setup__c> productList = (List<fsCore__Product_Setup__c>)Database.query(productQry.getQueryString());
        if (productList.size() == 0){
            return null;
        }
        return productList.get(0);
    }

    public static fsCore__Lending_Application__c getApplicationInfo(String pApplicationId){
        fsCore.DynamicQueryBuilder applicationQry = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName());
        applicationQry.addFields();
        applicationQry.addWhereConditionWithValue(1,'Id', '=', pApplicationId);
        
        List<fsCore__Lending_Application__c> appList = (List<fsCore__Lending_Application__c>)Database.query(applicationQry.getQueryString());
        if (appList.size() == 0){
            return null;
        }
        return appList.get(0);
    }    

    public static List<String> validateApplicationForAction(fsCore__Lending_Application__c pApplication){
        List<String> validationErrors = new List<String>();
        
        if (pApplication != null && pApplication.fsCore__Is_Funded__c){
            validationErrors.add(Label.fsCore.Action_Not_Allowed_For_Funded_Application);
        }
        else if (pApplication != null && pApplication.fsCore__Is_Voided__c){
            validationErrors.add(Label.fsCore.Action_Not_Allowed_For_Voided_Application);
        }
        else if (pApplication != null && pApplication.fsCore__Is_Application_Read_Only__c){
            validationErrors.add(Label.fsCore.Action_Not_Allowed_For_Read_Only_Application);
        }
        
        return validationErrors;
    }
}