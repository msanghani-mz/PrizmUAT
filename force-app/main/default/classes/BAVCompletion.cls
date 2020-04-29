public class BAVCompletion {
    
    @AuraEnabled
    public static String completeBAV(id pBAVId){
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        actionOP.setIsSuccess(false);
        Application_Bank_Account_Verification__c bav = [Select id ,Deposit_Status__c
                                                        ,Verification_Status__c 
                                                        ,Verification_Completed_Update_To_RAMS__c   
                                                        FROM Application_Bank_Account_Verification__c
                                                        WHERE id =:pBAVId];
        if(bav.Verification_Status__c != 'Verified'){
            actionOP.setMessage('BAV has not been Verified');
           
        }
        if(bav.Verification_Completed_Update_To_RAMS__c == true){
            actionOP.setMessage('BAV already Completed');
           
        }
        else{
            RAMVerifyBankAccountService bavVerifyCompletion = new RAMVerifyBankAccountService();
            Set<id> bavIds = new Set<id>{bav.id};
                bavVerifyCompletion.verifyAccountBAV(bavIds);  
            actionOP.setIsSuccess(true);
            actionOP.setMessage('BAV has been completed successfully!');
            
        } 
        String retMsg = actionOP.getJSONString();
        System.debug(LOGGINGLEVEL.ERROR, retMsg);
        return retMsg;  
    }
}