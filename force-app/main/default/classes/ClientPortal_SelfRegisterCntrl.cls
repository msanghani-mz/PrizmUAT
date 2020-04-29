global without sharing class ClientPortal_SelfRegisterCntrl {
    
    @TestVisible
    private static final String ACCOUNT_NOT_FOUND_MESSAGE =
        'We cannot locate the account based on the information.';
    @TestVisible
    private static final String RESULT_SUCCESS_MESSAGE = 'Success';
    @TestVisible
    private static final String OPP_STAGE_REG_IN_PROGRESS = 'Registration In Progress';
    @TestVisible
    private static final String DNL_PORTFOLIO = 'DNL';
    @TestVisible
    private static final String VCL_PORTFOLIO = 'VCL';
    @TestVisible
    private static final String LENDING_APPLICATION_STATUS = 'Offer Accepted';

    @AuraEnabled
    public static User getUserInstance() {
        User userInstance = new User();
        List<User> userList = [SELECT Id, Name
                               FROM User
                               WHERE Id =: userInfo.getUserId()
                               AND IsPortalEnabled = true];
        if (!userList.isEmpty()) {
            userInstance = userList[0];
        }
        return userInstance;
    }
    
    @AuraEnabled
    public static RegistrationDetailWrapper getRelatedRegistrationDetail(String userEmail,
                                                                         String userDOB,
                                                                         String userSSNLast4Digit,
                                                                         String portfolioName) {
                                                                             
        RegistrationDetailWrapper detailWrapper = new RegistrationDetailWrapper();
        Date birthdayDate;
        Account tempAccount = new Account();
        
        if(!String.isBlank(userEmail) && !String.isBlank(userDOB)
            && !String.isBlank(userSSNLast4Digit)) {
              
            birthdayDate = Date.valueOf(userDOB);
            Account[] accountDetails = [SELECT Id, Name, PersonEmail, PersonBirthdate,
                                        fsCore__National_Identification_Number__pc,
                                        PersonMobilePhone,
                                        FirstName,
                                        LastName,
                                        IsCustomerPortal
                                        FROM Account
                                        WHERE PersonEmail =: userEmail
                                        AND PersonBirthdate =: birthdayDate];
            for(Account acc: accountDetails) {
                if(!String.isBlank(acc.fsCore__National_Identification_Number__pc)){
                    if(acc.fsCore__National_Identification_Number__pc.endsWith(userSSNLast4Digit)){
                        if(acc.IsCustomerPortal) {
                            detailWrapper.result = 'Your account has already been registered. Please login';
                            break;
                        } else {
                            tempAccount = accountDetails[0];
                        }
                    }
                }
            }
            if(!accountDetails.isEmpty()){
                if(tempAccount.Id != null && String.isBlank(detailWrapper.result)) {
                    Opportunity[] oppDetails = [SELECT Id, AccountId
                                                FROM Opportunity
                                                WHERE (AccountId =: tempAccount.Id
                                                OR Co_Applicant_Name__r.Id =: tempAccount.Id)
                                                AND StageName =: OPP_STAGE_REG_IN_PROGRESS
                                                ORDER BY LastModifiedDate DESC
                                                LIMIT 1];
                    if(!oppDetails.isEmpty()) {
                        detailWrapper.accountDetail = tempAccount;
                        detailWrapper.opportunityDetail = oppDetails[0];
                        detailWrapper.result = RESULT_SUCCESS_MESSAGE;
                        detailWrapper.accountPortfolio = DNL_PORTFOLIO;
                    } else {
                        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name
                                                                                    FROM fsCore__Lending_Application__c
                                                                                    WHERE fsCore__Application_Status__c = :LENDING_APPLICATION_STATUS
                                                                                    AND Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                                FROM fsCore__Lending_Application_Customer__c 
                                                                                                WHERE fsCore__Account_Name__c = :tempAccount.Id)
                                                                                    ORDER BY SystemModStamp DESC
                                                                                    LIMIT 1];
                        if(!lendingApplicationList.isEmpty()) {
                            detailWrapper.accountDetail = tempAccount;
                            detailWrapper.lendingApplication = lendingApplicationList[0];
                            detailWrapper.result = RESULT_SUCCESS_MESSAGE;
                            detailWrapper.accountPortfolio = VCL_PORTFOLIO;
                        } else {
                            detailWrapper.result = ACCOUNT_NOT_FOUND_MESSAGE;
                        }
                    }
                }
            } else {
                detailWrapper.result = ACCOUNT_NOT_FOUND_MESSAGE;
            }

            if(String.isBlank(detailWrapper.result)) {
                detailWrapper.result = ACCOUNT_NOT_FOUND_MESSAGE;
            }
        }
        return detailWrapper;
    }
    
    @TestVisible
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @TestVisible
    private static Account populateRelatedApplicantInfoOnAccount(Account customerAccount, Id lendingApplicationId) {

        Map<Id, boolean> applicantIdToTypeMap = new Map<Id, boolean>() ;
        List<fsCore__Lending_Application_Customer__c> coApplicantsForApplicantSet = new List<fsCore__Lending_Application_Customer__c>() ;
        fsCore__Lending_Application_Customer__c applicantAccount ;

        for(fsCore__Lending_Application_Customer__c applicantForLendingAppln : [SELECT Id, Name,fsCore__Account_Name__c, fsCore__Account_Name__r.Person_Email__c, fsCore__Is_Primary__c FROM fsCore__Lending_Application_Customer__c WHERE fsCore__Lending_Application_Number__c = :lendingApplicationId]) {
            
            applicantIdToTypeMap.put(applicantForLendingAppln.fsCore__Account_Name__c , applicantForLendingAppln.fsCore__Is_Primary__c) ;
            if( !applicantForLendingAppln.fsCore__Is_Primary__c ) {
                coApplicantsForApplicantSet.add(applicantForLendingAppln) ;
            } else{
                applicantAccount = applicantForLendingAppln ;
            }
        }

        if(applicantIdToTypeMap.isEmpty()) {
            return customerAccount;
        }

        if( applicantIdToTypeMap.containsKey(customerAccount.Id) && applicantIdToTypeMap.get(customerAccount.Id) && (!coApplicantsForApplicantSet.isEmpty())){
            
            customerAccount.VCL_Related_Portal_Account__c = coApplicantsForApplicantSet[0].fsCore__Account_Name__c ;
            customerAccount.VCL_Related_Person_Email__c = coApplicantsForApplicantSet[0].fsCore__Account_Name__r.Person_Email__c ;

        } else if(applicantIdToTypeMap.containsKey(customerAccount.Id) && (!applicantIdToTypeMap.get(customerAccount.Id))) {
            
            customerAccount.VCL_Related_Portal_Account__c = applicantAccount.fsCore__Account_Name__c ;
            customerAccount.VCL_Related_Person_Email__c = applicantAccount.fsCore__Account_Name__r.Person_Email__c ;
            customerAccount.IS_VCL_Portal_Co_Applicant__c = true ;
            
        }

        return customerAccount ;

    }
    
    @future
    public static void assignPermissionSetForVCL(String userId) {
        PermissionSet docuSignSenderPS = [SELECT Id, Name, Label FROM PermissionSet where Name Like '%Docusign_Sender%' LIMIT 1] ;
        PermissionSetAssignment psa = new PermissionSetAssignment (
            PermissionSetId = docuSignSenderPS.Id,
            AssigneeId = userId
        );
        insert psa;
    }
    
    @AuraEnabled
    public static String selfRegister(String password, String confirmPassword,
                                      String regDetailWrapperStr,
                                      String regConfirmUrl, String startUrl) {
                                          
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            RegistrationDetailWrapper regDetailWrapper = (RegistrationDetailWrapper) JSON.deserialize(regDetailWrapperStr, RegistrationDetailWrapper.class);            
            if (!isValidPassword(password, confirmPassword)) {
                return Label.site.passwords_dont_match;
            }

            String userProfileName = getProfileNameForCommunityUser(regDetailWrapper.accountPortfolio);

            if (String.isBlank(userProfileName)) {
                return 'User Profile is not configured';
            }

            User userInstance = new User();
            List<Profile> profileList = [SELECT Id
                                          FROM Profile
                                          WHERE Name =: userProfileName];
            if (profileList != null && !profileList.isEmpty()) {
                userInstance.ProfileId = profileList[0].Id;
            }
            userInstance.Username = regDetailWrapper.accountDetail.PersonEmail;
            userInstance.put('Email',regDetailWrapper.accountDetail.PersonEmail);
            userInstance.FirstName = regDetailWrapper.accountDetail.FirstName;
            userInstance.LastName = regDetailWrapper.accountDetail.LastName;
            userInstance.MobilePhone = regDetailWrapper.accountDetail.PersonMobilePhone;
            String firstname = regDetailWrapper.accountDetail.firstname;
            String lastName = regDetailWrapper.accountDetail.lastname;
            String networkId = Network.getNetworkId();
            
            if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                userInstance.put('UserPreferencesHideS1BrowserUI',true);
            }
            
            String nickname = ((firstname != null && firstname.length() > 0) ?
                                firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            userInstance.put('CommunityNickname', nickname);
            Id accountId = regDetailWrapper.accountDetail.Id;
            String userId = Site.createPortalUser(userInstance, accountId, password);
            if (!Test.isRunningTest()) {
                if(String.isBlank(userId)) {
                    return 'Error Occured';
                }
            }
            // assigning a permission set related to Docusign for VCL user
            if(!Test.isRunningTest() && regDetailWrapper.accountPortfolio == VCL_PORTFOLIO){
               assignPermissionSetForVCL(userId) ;
            }
            
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';
            }
            Account acc = new Account(Id = regDetailWrapper.accountDetail.Id);
            if(regDetailWrapper.accountPortfolio == VCL_PORTFOLIO){
                acc.Lending_Application_Id__c = regDetailWrapper.lendingApplication.Id;
                acc.Is_VCL_Registration_Completed__c = true;
                acc.VCL_User_Registration_Date__c = System.now();
                acc.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_PORTAL_STATUS_ESIGN_DIS;
                acc.Is_Bank_Info_Added__c = false;
                acc.Is_Income_Added__c = false;
                acc.Is_SSN_Submitted__c = false;
                acc.Is_VCL_Bank_ATD_Accepted__c = false;
                acc.Is_VCL_Bank_ATD_Declined__c = false;
                acc.Is_VCL_ESIGN_Accepted__c = false;
                acc.Is_VCL_ESign_Declined__c = false;
                acc.Is_VCL_Portal_Co_Applicant__c = false;
                acc.Is_VCL_TILA_Accepted__c = false;
                acc.Is_VCL_TILA_Declined__c = false;
                acc = populateRelatedApplicantInfoOnAccount(acc , regDetailWrapper.lendingApplication.Id) ;
            }else if(regDetailWrapper.accountPortfolio == DNL_PORTFOLIO){
                acc.DNL_Portal_Status__c = ClientPortal_Constants.DNL_PORTAL_STATUS_ESIGN_DIS;
                acc.Is_User_Registration_Completed__c = true;
                acc.Is_DNL_Portal_Disclosure_Completed__c = false;
                acc.Is_DNL_Portal_Disclosure_Declined__c = false;
                acc.Is_DNL_Portal_Notice_Completed__c = false;
                acc.Is_Registration_Completed__c = false;
            }
            update acc;
            if (userId != null) {
                if (password != null && password.length() > 1) {
                    startUrl = '/apex/ClientPortal_LoginFlow2FAPage?source=' + ClientPortal_Constants.PORTAL_REG_2FA_SOURCE;
                    ApexPages.PageReference lgn = Site.login(userInstance.Username, password, startUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                    //return 'Success';
                } else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if(!Test.isRunningTest()) {
                        aura.redirect(confirmRef);
                    }
                }
            }
            return 'Success';
         } catch (Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();
        } 
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) {
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
            if (fieldSet != null) {
                for (Schema.FieldSetMember f : fieldSet.getFields()) {
                    Map<String, Object> fieldDetail = new Map<String, Object>();
                    fieldDetail.put('dbRequired', f.getDBRequired());
                    fieldDetail.put('fieldPath', f.getFieldPath());
                    fieldDetail.put('label', f.getLabel());
                    fieldDetail.put('required', f.getRequired());
                    fieldDetail.put('type', f.getType());
                    fieldDetail.put('value', '');
                    extraFields.add(fieldDetail);
                }
            }
        }
        return extraFields;
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    private static String getProfileNameForCommunityUser(String accountPortfolio){
        String profileNameForCommunityUser = '';
        List<Client_Portal_Portfolio__c> portfolioList = [SELECT Id, Name, Profile_Name__c 
                                                            FROM Client_Portal_Portfolio__c 
                                                            WHERE Is_Active__c = True 
                                                            AND Name = :accountPortfolio];
        if(!portfolioList.isEmpty()){
            profileNameForCommunityUser = portfolioList[0].Profile_Name__c;
        }
        return profileNameForCommunityUser;
    }
    
    public class RegistrationDetailWrapper {
        @AuraEnabled
        public Account accountDetail {get; set;}
        @AuraEnabled
        public Opportunity opportunityDetail {get; set;}
        @AuraEnabled
        public fsCore__Lending_Application__c lendingApplication {get; set;}
        @AuraEnabled
        public String result {get; set;}
        @AuraEnabled
        public String accountPortfolio {get; set;}
    }
}