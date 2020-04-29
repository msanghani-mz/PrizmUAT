global without sharing class ClientPortal_CustomLoginCntrl {

    @AuraEnabled
    public static ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig getClientPortalUIConfiguration(String domainURL,
                                                                                                        String portfolioName) {
        return ClientPortal_CustomRegisterCntrl.getClientPortalUIConfiguration(domainURL, portfolioName);
    }

    @AuraEnabled
    public static User getUserInstance(){
        return ClientPortal_SelfRegisterCntrl.getUserInstance();
    }

    @AuraEnabled
    public static String login(String username, String password, String startUrl, String portfolioProfile) {
        try{

            List<User> users = new List<User>();
            String inactiveUserName;
            if(String.isNotBlank(username)){
                inactiveUserName = '_'+username;
            }
            users = [SELECT Id, IsActive, Profile.Name FROM USER WHERE (UserName =: inactiveUserName OR UserName =: username)];
            
            if(!users.isEmpty()){
                boolean IsActiveUser = false;
                for(user currentuser: users){
                    if (currentuser.IsActive){
                        IsActiveUser = true;
                    }
                    /*
                    if(currentuser.Profile.Name != portfolioProfile.trim() && !currentuser.IsActive){
                        String errorMessage = 'This is an invalid account, please contact us at (855)-219-5338 for assistance';
                        return errorMessage;
                    }*/
                }
                if(!IsActiveUser) {
                    String errorMessage = 'Your account is not active, please contact us at (855)-219-5338 for assistance';
                    return errorMessage;
                }
            }
            startUrl = '/apex/ClientPortal_LoginFlow2FAPage?source=login';
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }


     @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }   
}