/**
* @File Name          : RAMVerifyBankAccountService.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 11/10/2019, 2:39:59 PM
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    11/2/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class RAMVerifyBankAccountService{
    
    
    public string mSessionId;
    RAMServiceGateway.RAMSGatewayVer2Soap mRamAPI;
    
    public RAMVerifyBankAccountService(){

        this.mRamAPI = new RAMServiceGateway.RAMSGatewayVer2Soap();
        if (Test.isRunningTest()){
            this.mSessionId = 'DUMMYSESSIONID';
        }else{
        	this.mSessionId = mRamAPI.StartSession();
        }
        logMessage('Started sessionId : '+mSessionId);

    }
    //nu_dse__External_RAMS_ID__c
    public void initiateBAV(Set<ID> pBavRecordIds){

        List<Application_Bank_Account_Verification__c> BAVList = [SELECT id
                                                                       , External_RAMS_ID_Formula__c
                                                                       , Error_Message_Initiate_BAV__c
                                                                       , Deposit_Amount__c
                                                                       , Deposit_Status__c
                                                                       , Verification_Status__c
                                                                    FROM Application_Bank_Account_Verification__c 
                                                                   WHERE Deposit_Status__c IN ('Not Sent To Processor','Error')
                                                                     AND Verification_Status__c = 'New'
                                                                     AND Id in :pBavRecordIds];
        
        List<Application_Bank_Account_Verification__c> clientCreatedList = new List<Application_Bank_Account_Verification__c>();
        List<Application_Bank_Account_Verification__c> clientNotCreatedList = new List<Application_Bank_Account_Verification__c>();
        
        Id recordTypeDepositedId = SFSUtil.getRecordTypeId('Application_Bank_Account_Verification__c', 'Deposited');

        for (Application_Bank_Account_Verification__c bav : BAVList){
            if (bav.External_RAMS_ID_Formula__c == null){
                clientNotCreatedList.add(bav);
            }else{
                clientCreatedList.add(bav);
            }
        }    
        for (Application_Bank_Account_Verification__c bav: clientNotCreatedList){
            bav.Deposit_Status__c = 'Error';
            bav.Error_Message_Initiate_BAV__c = 'Client Not Created in RAMS';
        }                                                                 

        if (mSessionId != null){
            
            try{
                for (Application_Bank_Account_Verification__c bav: clientCreatedList){
                    try{
                        string depositAmt = '0';
                        if (Test.isRunningTest()){
                            depositAmt = '0.02';
                        }else{    
                        	depositAmt = mRamAPI.BAV_VerifyAccount(mSessionId, bav.External_RAMS_ID_Formula__c); 
                        }
                        logMessage('depositAmt :'+depositAmt);
                        
                        bav.Deposit_Amount__c = Decimal.ValueOf(depositAmt);
                        bav.Deposit_Status__c = 'Sent To Processor';
                        bav.Verification_Status__c = 'Verification Pending';	
                        bav.Is_Deposit_Complete__c = true;
                        bav.Error_Message_Initiate_BAV__c = null;
                        bav.recordTypeId = recordTypeDepositedId;
                        
                    }catch (CalloutException calloutEx){
                        bav.Deposit_Status__c = 'Error';
                        bav.Error_Message_Initiate_BAV__c = calloutEx.getMessage();
                    }
                }
                //this verifies the account on file for client 167. 
                //You can use a DSCID for the Funding Payee ID or use '1' to specify the parent company on the account as the funding source.
                
            }finally{
                logMessage('Ending Session');
                if (Test.isRunningTest()){
                    //DO NOTHING
                }else{
                	mRamAPI.EndSession(mSessionId);
                }
                logMessage('Session Ended updating BAV Records');
                update clientCreatedList;
                update clientNotCreatedList;
                
            }
            
        }
        
    }
    public void verifyAccountBAV(Set<ID> pBavRecordIds){
        List<Application_Bank_Account_Verification__c> BAVList = [SELECT id
                                                                       , External_RAMS_ID_Formula__c
                                                                       , Error_Message_Verified_BAV__c
                                                                       , Deposit_Amount__c
                                                                       , Deposit_Status__c
                                                                       , Verification_Status__c
                                                                       , Verification_Completed_Update_To_RAMS__c
                                                                    FROM Application_Bank_Account_Verification__c 
                                                                   WHERE Verification_Completed_Update_To_RAMS__c = false
                                                                     AND Verification_Status__c = 'Verified'
                                                                     AND Id in :pBavRecordIds];
        
        Id recordTypeVerifiedId = SFSUtil.getRecordTypeId('Application_Bank_Account_Verification__c', 'Verified_Completed');
        if (mSessionId != null){
            try{
                for (Application_Bank_Account_Verification__c bav: BAVList){
                    try{
                        string resp = '';
                        //sample call to verify an account after the deposit has been received and confirmed:
                        //this only needs to be called on a successful verification, not on failures, this releases the account for use/funding
                        resp = mRamAPI.BAV_VerifyAccount_Update(mSessionId, bav.External_RAMS_ID_Formula__c);
                        bav.Verification_Completed_Update_To_RAMS__c = true;
                        bav.Error_Message_Verified_BAV__c = null;
                        bav.recordTypeId = recordTypeVerifiedId;
                        logMessage('resp :'+resp);
                    }catch (CalloutException calloutEx){
                        bav.Error_Message_Verified_BAV__c = calloutEx.getMessage();
                    }
                }                
            }
            finally{
                logMessage('Ending Session');
                mRamAPI.EndSession(mSessionId);
                logMessage('Session Ended');
                update BAVList;
            }    
        }
        
    }    
    private void logMessage(String pMessage){
        system.debug(logginglevel.error,pMessage);
    }   
    
}