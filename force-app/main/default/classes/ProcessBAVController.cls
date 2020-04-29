/**
* @File Name          : ProcessBAVController.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 11/7/2019, 12:24:15 AM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    11/7/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class ProcessBAVController {
    
    @AuraEnabled
    public static String process(id pBAVId){
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        actionOP.setIsSuccess(false);
        
        Application_Bank_Account_Verification__c bav = [Select id ,Deposit_Status__c
                                                        ,Verification_Status__c 
                                                        , deposit_amount__c
                                                        ,External_RAMS_ID_Formula__c  
                                                        FROM Application_Bank_Account_Verification__c
                                                        WHERE id =:pBAVId];
        System.debug(LOGGINGLEVEL.ERROR, bav);
        
        if(bav.Verification_Status__c != 'New'){
            actionOP.addError('BAV status not applicable to process');
            
        }
        
        if(bav.External_RAMS_ID_Formula__c != null){
            actionOP.addError('External RAM ID cannot be blank');
            
        }
        System.debug(loggingLevel.ERROR , bav.Deposit_Status__c);
        if((bav.Deposit_Status__c == 'Not Sent To Processor') || (bav.Deposit_Status__c =='Error')){
            RAMVerifyBankAccountService verifyService = new RAMVerifyBankAccountService();
            Set<id> bavIds = new Set<id>{bav.id};
            verifyService.initiateBAV(bavIds);
            
            actionOP.setIsSuccess(true);
            actionOP.setMessage('BAV has been initiated successfully!');
           
        }else{
            actionOP.addError('Deposit Status not applicable to process');
            
        }
        String retMsg = actionOP.getJSONString();
        System.debug(LOGGINGLEVEL.ERROR, retMsg);
        return retMsg;
    }
    
}