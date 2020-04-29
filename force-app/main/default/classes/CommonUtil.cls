/**
 * Class Name  : CommonUtil
 * Description : This class has common utility methods 
 * Author      : Financial Spectra
 *
 */
public class CommonUtil {

    /*
     * Method to get default branch details set the custom setting
     */
    public static fsCore__Branch_Setup__c getDefaultBranchDNL(){
        String defaultBranchCode = SFS_System_Settings__c.getInstance().Default_Branch_Code_DNL__c;
        if (String.IsNotBlank(defaultBranchCode)){
            fsCore__Branch_Setup__c defaultBrch = [SELECT Id, Name, fsCore__Company_Name__c 
                                                     FROM fsCore__Branch_Setup__c
                                                    WHERE fsCore__Branch_Code__c = :defaultBranchCode];
            return defaultBrch;
        }
        return null;
    }

    /*
     * Method to get product setup with itemizations
     */
    public static fsCore__Product_Setup__c getProductWithItemizations(String pProductNames){
        if (String.IsNotBlank(pProductNames)){
          fsCore__Product_Setup__c defProduct = [SELECT Id, Name
                  , fsCore__Billing_Cycle__c
                  , fsCore__Is_Billing_Cycle_Flexible__c
                  , fsCore__Collateral_Family__c
                  , fsCore__Collateral_Sub_Family__c
                  , fsCore__Product_Family__c
                  , fsCore__Is_Secured__c
                  , fsCore__Is_Funding_In_Tranches_Allowed__c
                  , fsCore__Is_Syndication_Allowed__c
                  , fsCore__Custom_Title_Format_Class__c
                  , fsCore__Customer_Name_Format__c
                  , fsCore__Title_Format__c
                  , (SELECT Id, Name
                          , fsCore__Itemization_Name__c
                          , fsCore__Itemization_Name__r.fsCore__Itemization_Code__c
                          , fsCore__Itemization_Family__c
                          , fsCore__Plus_Or_Minus__c
                          , fsCore__Disbursement_Allowed__c
                          , fsCore__Fee_Category__c
                          , fsCore__Is_Override_Allowed__c
                       FROM fsCore__Product_Itemization_Setup__r
                      WHERE fsCore__Is_Active__c = true
                      ORDER BY fsCore__Display_Order__c)
               FROM fsCore__Product_Setup__c
              WHERE fsCore__Product_Code__c = : pProductNames];

              return defProduct;
        }
        return null;
    }
    
}