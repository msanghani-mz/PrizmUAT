public without sharing class ClientPortal_CommunityUserDetailCntrl {
    private static Map<String, List<String>> countryToStateMap = new Map<String, List<String>>() ;
    
    /*private static List<String> getStatePicklist(String country){
	countryToStateMap = ClientPortal_FieldDescribeUtil.getDependentOptionsImpl(User.stateCode, User.countryCode) ;
        return countryToStateMap.get(country) ;
    }*/
    
    @AuraEnabled
    public static UserWrapper getCurrentUser() {
        
        try {
            UserWrapper userWrapper = new UserWrapper();
            userWrapper.userInstance = [SELECT Id, LastName, FirstName, PersonMailingStreet, PersonMailingCity, 
                                        PersonMailingState, PersonMailingPostalCode, PersonMailingCountry, PersonEmail, 
                                        PersonHomePhone, PersonMobilePhone, PersonOtherStreet, PersonOtherPostalCode, 
                                        PersonOtherCity, PersonOtherState
                                        FROM Account
                                        WHERE ID In (SELECT AccountId FROM User 
                                        WHERE Id = :userinfo.getUserId() 
                                        ) LIMIT 1];
            if(String.isNotBlank(userWrapper.userInstance.PersonMailingStreet) && 
               String.isNotBlank(userWrapper.userInstance.PersonMailingCity) && 
               String.isNotBlank(userWrapper.userInstance.PersonMailingState) && 
               String.isNotBlank(userWrapper.userInstance.PersonMailingPostalCode)
              ) {
                userWrapper.showMailingAddress = true ;
            }
            //userWrapper.stateListValues = getStatePicklist(userWrapper.userInstance.PersonMailingCountry) ;
            
            return userWrapper;  
                          
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* To reset password */
    @AuraEnabled
    public static boolean resetpassword() {
       
        String currentUserName = [SELECT Id, Username FROM User 
                            WHERE Id = :userinfo.getUserId()].Username ;
        Site.forgotPassword(currentUserName);
        return true;
    }
    
    /*@future
    public static void updateUserDetails(String userId, String emailStr, String phoneStr) {
        User currentUser = new User() ;
        currentUser.Id = userId ;
        currentUser.Username = emailStr ;
        currentUser.Email = emailStr ;
        currentUser.MobilePhone = phoneStr ;
        currentUser.Is_User_Authenticated__c = false ;
        update currentUser ;
    }*/
    
    
    @AuraEnabled
    public static String saveProfileDetails(Account userAccount, Boolean updateUser) {
        String resultStr = 'Success' ;
        try {
            /*if(updateUser) {
                updateUserDetails(Userinfo.getUserId() , userAccount.personEmail, userAccount.PersonMobilePhone) ;
            }
            
            update userAccount ;*/

            if(updateUser) {
                
                Portal_Identity_Service__c portalIdentityService = new Portal_Identity_Service__c();
                portalIdentityService.User__c = Userinfo.getUserId();
                portalIdentityService.Status__c = 'Initiated';
                portalIdentityService.RecordTypeId = ClientPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Login History');
                if(Test.isRunningTest()){
                    portalIdentityService.Ip_Address__c = '192.168.0.1';
                }else{
                    portalIdentityService.Ip_Address__c = Auth.SessionManagement.getCurrentSession().get('SourceIp'); 
                }
                portalIdentityService.Last_Login_Time__c = System.now() ;
                insert portalIdentityService ;
                
                ApexPages.PageReference authPage = Page.ClientPortal_LoginFlow2FAPage ;
                //authPage.setRedirect(true);
                if(updateUser) {
                   authPage.getParameters().put('pUserEmail' , userAccount.personEmail) ; 
                   authPage.getParameters().put('pUserMobile' , userAccount.PersonMobilePhone) ; 
                }
                if (!Test.isRunningTest()) {
                   aura.redirect(authPage);
                }
            }
            
        }catch (Exception ex) {
            System.debug('Error::' + ex.getStackTraceString()) ;
            System.debug('Error::' + ex.getMessage()) ;
            resultStr = ex.getMessage() ;
        }
        return resultStr ;
    }
    
    
    public class UserWrapper {
        
        @AuraEnabled
        public Account userInstance;
         @AuraEnabled
        public Boolean showMailingAddress;
        
        @AuraEnabled
        public String phoneVerificationStatus;
        
        @AuraEnabled
        public String emailVerificationStatus;
         @AuraEnabled
        public List<String> stateListValues;
        
        public UserWrapper() {
        
            this.userInstance = new Account();
            this.phoneVerificationStatus = '';
            this.emailVerificationStatus = '';
            stateListValues = new List<String>() ;
            showMailingAddress = false ;
        }
    }    
}