/**
 * @File Name          : BAVUtility.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/10/2019, 2:40:49 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/6/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class BAVUtility {
    
    public static boolean isBAVVerified(Id pApplicationId , Decimal pBavAmount){
        boolean result = false;

        if (pBavAmount == 0){
            //BAV AMOUNT HAS TO BE NON ZERO
            return result;
        }
        Id recordTypeVerifiedId = SFSUtil.getRecordTypeId('Application_Bank_Account_Verification__c', 'Verified');
        try{
            List<Application_Bank_Account_Verification__c> bavList = [Select id
                                                                 , Verification_Status__c 
                                                                 , Deposit_Amount__c
                                                              FROM Application_Bank_Account_Verification__c 
                                                              WHERE Lending_Application_Name__c = :pApplicationId
                                                                AND Verification_Status__c = 'Verification Pending'];
                                                             
            if (bavList.size() == 0){
                //Nothing to verify
                return result;
            }
            if (bavList.size() > 1){
                //There shouldn't be more than 1 records in Verification Pending status 
                // FAIL IT.
                return result;
            }            
            
            Application_Bank_Account_Verification__c bav = bavList[0];
            
            if (bav.Deposit_Amount__c == 0){
                //BAV hasn't been initiated yet, cannot verify
                return result;
            }
            if(bav.Deposit_Amount__c == pBavAmount){
                result = true; 
                bav.Verification_Status__c = 'Verified';
                bav.recordTypeId = recordTypeVerifiedId;
            }
            else{
                
                bav.Verification_Status__c = 'Failed';   
            }
            update bav;
        }catch(Exception e){
            System.debug(LOGGINGLEVEL.ERROR +'error' +e.getMessage() + e.getStackTraceString());
            throw e;
        }
        return result;  
    }
    
}