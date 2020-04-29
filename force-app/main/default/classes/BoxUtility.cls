public class BoxUtility {

    private static final String boxCredentialFolderName = 'Box Cred';
    private static BoxJwtEncryptionPreferences.EncryptionAlgorithm algorithm = BoxJwtEncryptionPreferences.EncryptionAlgorithm.RSA_SHA_256;
    

    private  static String clientId = 'clientid';
    private  static String clientSecret = 'clientsecret';
    private  static String authCode = 'authcode';
    private  static String entityId = 'entityid';
    private  static String userId = 'userid';
    private  static String enterpriseId = 'enterpriseid';
    private  static String publicKeyId = 'publicKeyId';
    private  static String privateKey = BoxTestJsonResponseFactory.AUTH_PRIVATE_KEY;
    private  static String privateKeyPassword = 'privateKeyPassword';    



    private static BoxJwtEncryptionPreferences constructEncryptionPrefs() {
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setEncryptionAlgorithm(algorithm);
        prefs.setPrivateKey(privateKey);
        prefs.setPrivateKeyPassword(privateKeyPassword);
        prefs.setPublicKeyId(publicKeyId);
        return prefs;
    }    
    public static Integration_Settings__c getAccessToken(Boolean pUpdateSettings) {
        Map<String, String> credential = getBoxCredential();
    
        privatekey = credential.get('privatekey'); 
        enterpriseId = credential.get('enterpriseId');
        publicKeyId = credential.get('publicKeyId');
        clientId = credential.get('clientId');
        clientSecret = credential.get('clientSecret');
        privateKeyPassword = credential.get('privateKeyPassword');
        Integration_Settings__c boxSettings = Integration_Settings__c.getValues('box');

        if (Test.isRunningTest()){ //AD DO NOT CALL CREDIT SERVICE WHILE RUNNING THE TEST
            //Do NOTHING
            return new Integration_Settings__c();
        }else{
            String userId = boxSettings.User_Id__c;//'3890558392' ; // THIS IS NOT THE enterpriseId IT IS THE USERID WHICH WE GET FROM BOX CONFIGURATION GENERAL TAB WITH USER ID
			
             if(boxSettings !=null && boxSettings.access_token1__c != null && boxSettings.Last_Refresh_Date__c != null && pUpdateSettings){
              Integer lifetimeMinutes = boxSettings.Access_Token_Lifetime__c != null ? Integer.valueOf(boxSettings.Access_Token_Lifetime__c) : 30;
                DateTime tokenLifeTime = boxSettings.Last_Refresh_Date__c.addMinutes(lifetimeMinutes);
                if (tokenLifeTime > system.now()){
                    logmessage('No Need to get the access token returing'+boxSettings.access_token1__c);
                    //ACCESS CODE IS NOT EXPIRED AND ALREADY SET NO NEED TO CALL API CONNECTION
                    return boxSettings;
                }
            }
            
            logmessage('Getting the access token');
            //IF HERE THIS MEANS I NEED TO GET THE ACCESS CODE.
            
            BoxJwtEncryptionPreferences preferences = constructEncryptionPrefs();
            try {
                //DO NOT USE getAppEnterpriseConnection THEN THE FOLDERS WILL NOT BE VISIBLE IN BOX.COM ACCOUNT
                //BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(enterpriseId, clientId, clientSecret, preferences);
                logmessage('enterpriseId: ' + enterpriseId+
                           '  userId: ' + userId+
                           '  clientId: ' + clientId+
                           '  clientSecret: ' + clientSecret+
                           '  privateKey: ' + privateKey+
                           '  privateKeyPassword: ' + privateKeyPassword+
                           '  publicKeyId: ' + publicKeyId);

                BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppUserConnection(userId, clientId, clientSecret, preferences);

                logmessage('api.accessToken: ' + api.accessToken);
                logmessage('lastRefresh: ' + api.lastRefresh);
                logmessage('expires: ' + api.expires);
                logmessage('autoRefresh: ' + api.autoRefresh);
                logmessage('timeout: ' + api.timeout);
                logmessage('maxRequestAttempts: ' + api.maxRequestAttempts);
                logmessage('API: ' + api);


                boxSettings.access_token1__c=api.accessToken;
                boxSettings.lastRefresh__c=String.valueOf(api.lastRefresh);
                boxSettings.expires__c=String.valueOf(api.expires);
                boxSettings.Last_Refresh_Date__c = system.now();
                if (pUpdateSettings){
                    update boxSettings;
                }

                logmessage('accessToken##'+ api.accessToken);
            } catch(Exception e) {
                logmessage('exception: ' + e);
            }
        }
        return boxSettings;

    }
    public static Integration_Settings__c getAccessToken() {
        return getAccessToken(true);
       
    }
    
    public static Map<String, String> getBoxCredential() {
        List<Document> docs = [SELECT Body, BodyLength, ContentType, Url from Document WHERE Name LIKE :boxCredentialFolderName];
        if(docs.isEmpty() == false) {
            return getMapFromDocument(docs[0]);
        }
        return new Map<String, String>();
    }
    
    public static String getFolderId(String responseBody){
        String folderId=null;
        JSONParser parser = JSON.createParser(responseBody);
        while((parser.nextToken()) != null) {
            if(parser.getCurrentName() == 'id'){
                parser.nextToken();
                folderId = parser.getText();
                break;
            }
        }
        return folderId;
    }
        
    private static Map<String, String> getMapFromDocument(Document doc) {
        String[] lineList = (doc.Body.toString()).split('\n');
        Map<String, String> pairMap = new Map<String, String>();
        for(String line : lineList) {
            logmessage('line-->'+line);
            String[] split = line.split('=', 2);
            logmessage('split-->'+split);
            if(split.size() == 2) {
                pairMap.put(split[0].trim(), split[1].trim());
            }
        }
        
        return pairMap;
    }
    private static void logmessage (Object pMessage){
      system.debug(logginglevel.error,pMessage);
    }        
    
}