public abstract with sharing class CFTPayServiceBase extends fsCore.WebServiceBase {
    public CFTPayServiceBase(String pServiceName){
        super(pServiceName);
        setCFTPayAttributes();
    }
    private void setCFTPayAttributes(){
        System.debug(loggingLevel.ERROR, 'setCFTPayAttributes(+)');
        String settingName = getOrgType();
        System.debug(loggingLevel.ERROR, '-- setting name : ' + settingName);
        CFTPay_Settings__mdt cftpaySettings;
        try{
            cftpaySettings = [SELECT API_Bearer_Key__c, Instance_URL__c, Is_Exception_Logging_Enabled__c, MasterLabel from CFTPay_Settings__mdt where MasterLabel=:settingName];
        }
        catch(Exception e){
            system.debug('--Exception:'+e);
        }
        System.debug('cftpaySettings:--'+cftpaySettings);
        if (cftpaySettings == null){
            throw new CFTPayServiceException(String.format(Label.CFTPay_Setting_Not_Found, new List<String>{settingName}));
        }
        System.debug(loggingLevel.ERROR, '-- CFTPay Settings : ' + cftpaySettings);
        /* add mandatory headers */
        addHeader('Authorization', 'Bearer ' + cftpaySettings.API_Bearer_Key__c);
        addHeader('Content-Type', 'application/json');
        addHeader('PromiseMode', 'NEVER');
        addHeader('Accept', 'application/json');
        /* set service instance or host URL */
        setInstanceURL(cftpaySettings.Instance_URL__c);
        /* set exception logging flag */
        setErrorLoggingFlag(cftpaySettings.Is_Exception_Logging_Enabled__c);
        System.debug(loggingLevel.ERROR, 'setCFTPayAttributes(-)');
    }
    public class CFTPayServiceException extends Exception{}
}