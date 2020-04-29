global class ClientPortal_CustomRegisterCntrl {
    
    @TestVisible private static final String DEFAULT_PORTFOLIO = 'DNL';
    
    @AuraEnabled
    public static ClientPortalUIConfig getClientPortalUIConfiguration(String domainURL,
                                                                      String portfolioName) {
        ClientPortalUIConfig uiConfig = new ClientPortalUIConfig();
        try {
            Organization orgInfo = ClientPortal_Utility.getOrgInfo();
            Map<String, Object> currentUserInfoMap = ClientPortal_Utility.getCurrentUserInformation();
            Client_Portal_Portfolio__c userPortfolio = new Client_Portal_Portfolio__c();
            String portfolioQuery = 'SELECT Id, Name, About_Us_URL__c,' +
                                    ' Contact_Us_URL__c,' +
                                    ' Dispay_Name__c, Domain_URL__c,' +
                                    ' Email_Verification_Site_URL__c, ' +
                                    ' External_Id__c, FAQ_URL__c, Favicon__c,' +
                                    ' Is_Active__c, Login_URL__c,' +
                                    ' Privacy_Policy_URL__c, Profile_Name__c,' +
                                    ' Support_Email__c,' +
                                    ' Support_Phone_Number__c,' +
                                    ' Submit_Feedback_URL__c,' +
                                    ' Footer_Content__c,' +
                                    ' Terms_of_Use__c,' +
                                    ' Footer_Copyright_Content__c,' +
                                    ' Facebook_URL__c,' +
                                    ' LinkedIn_URL__c,' +
                                    ' Forgot_Password_URL__c,' +
                                    ' Register_URL__c,' +
                                    ' Banking_Tab_URL__c, Account_Overview_Tab_URL__c,'+
                                    ' Documents_Tab_URL__c, Income_Tab_URL__c, My_Profile_Tab_URL__c,' +
                                    ' ESGIN_Disclosure_Content__c' +
                                    ' FROM Client_Portal_Portfolio__c' +
                                    ' WHERE Is_Active__c = True';
            if(currentUserInfoMap.ContainsKey('isDisplayChatEnabled') && currentUserInfoMap.get('isDisplayChatEnabled') != null){
                uiConfig.isDisplayChatEnabled = (Boolean)currentUserInfoMap.get('isDisplayChatEnabled');
            }
            if(currentUserInfoMap.ContainsKey('profileName') && currentUserInfoMap.get('profileName') != null){
                String profileName = (String)currentUserInfoMap.get('profileName');
                portfolioQuery += ' AND Profile_Name__c = :profileName';
                uiConfig.isShowingDefaultPortal = false;
            }else{
                portfolioQuery += ' AND Name = :DEFAULT_PORTFOLIO';
                uiConfig.isShowingDefaultPortal = true;
            }
            portfolioQuery += ' LIMIT 1';
            List<Client_Portal_Portfolio__c> userPortfolioList = Database.query(portfolioQuery);
            if(userPortfolioList != null && !userPortfolioList.isEmpty()){
                uiConfig.portfolio = userPortfolioList[0];
                Id portfolioId = uiConfig.portfolio.Id;
                if(String.isNotBlank(domainURL) && portfolioId != null) {
                    Id headerUiConfigId = ClientPortal_Utility.getRecordTypeId('Client_Portal_Settings__c', 'Header UI Configuration');
                    Id menuUiConfigId = ClientPortal_Utility.getRecordTypeId('Client_Portal_Settings__c', 'Menu UI Configuration');
                    Id bodyUiConfigId = ClientPortal_Utility.getRecordTypeId('Client_Portal_Settings__c', 'Body UI Configuration');
                    Id footerUiConfigId = ClientPortal_Utility.getRecordTypeId('Client_Portal_Settings__c', 'Footer UI Configuration');
                    String query = 'SELECT Id, RecordTypeId, Background_Color__c, '+
                                    ' Background_Image_Static_Resource_Name__c, '+
                                    ' Company_Logo_Static_Resource_Name__c, '+
                                    ' Text_Color__c, Text_Hover_Color__c, '+
                                    ' Action_Button_Color__c, Action_Button_Hover_Color__c, '+
                                    ' Client_Portal_Portfolio__c, ' +
                                    ' Client_Portal_Portfolio__r.Domain_URL__c ' +
                                    ' FROM Client_Portal_Settings__c '+
                                    ' WHERE Client_Portal_Portfolio__c != null '+
                                    ' AND Is_Active__c = TRUE ';
                    
                    if (String.isNotBlank(portfolioId)) {
                        query += ' AND Client_Portal_Portfolio__c =: portfolioId';
                    } else {
                        if(orgInfo.isSandbox) {
                            query += ' AND Client_Portal_Portfolio__r.Name =: portfolioName '+
                                ' ORDER BY Lastmodifieddate DESC';
                        } else {
                            query += ' AND Client_Portal_Portfolio__r.Domain_URL__c =: domainURL '+
                                ' ORDER BY Lastmodifieddate DESC';
                        }
                    }
                    
                    List<Client_Portal_Settings__c> clientPortalSettings = Database.query(query);
                    
                    for(Client_Portal_Settings__c cpSetting : clientPortalSettings) {
                        uiConfig.isPortalConfigPresent = true;
                        if(cpSetting.RecordTypeId == headerUiConfigId) {
                            uiConfig.headerUiConfig = cpSetting;
                            uiConfig.headerBackgroundImageURL = getStaticResourceURL(cpSetting.Background_Image_Static_Resource_Name__c, cpSetting.Client_Portal_Portfolio__r.Domain_URL__c);
                            uiConfig.headerCompanyLogoImageURL = getStaticResourceURL(cpSetting.Company_Logo_Static_Resource_Name__c, cpSetting.Client_Portal_Portfolio__r.Domain_URL__c);
                        } else if(cpSetting.RecordTypeId == menuUiConfigId) {
                            uiConfig.menuUiConfig = cpSetting;
                            uiConfig.menuBackgroundImageURL = getStaticResourceURL(cpSetting.Background_Image_Static_Resource_Name__c, cpSetting.Client_Portal_Portfolio__r.Domain_URL__c);
                        } else if(cpSetting.RecordTypeId == bodyUiConfigId) {
                            uiConfig.bodyUiConfig = cpSetting;
                            uiConfig.bodyBackgroundImageURL = getStaticResourceURL(cpSetting.Background_Image_Static_Resource_Name__c, cpSetting.Client_Portal_Portfolio__r.Domain_URL__c);
                        } else if(cpSetting.RecordTypeId == footerUiConfigId) {
                            uiConfig.footerUiConfig = cpSetting;
                            uiConfig.footerBackgroundImageURL = getStaticResourceURL(cpSetting.Background_Image_Static_Resource_Name__c, cpSetting.Client_Portal_Portfolio__r.Domain_URL__c);
                            uiConfig.footerCompanyLogoImageURL = getStaticResourceURL(cpSetting.Company_Logo_Static_Resource_Name__c, cpSetting.Client_Portal_Portfolio__r.Domain_URL__c);
                        }
                    }
                }
            }
        } catch(Exception e) {
            ClientPortal_AuraExceptionUtil.checkAndThrowAuraHandledException(
                new List<String>{e.getMessage()});
        }
        return uiConfig;
    }
    
    private static String getStaticResourceURL(String name, String domainURL) {
        String url = '';
        
        StaticResource[] resources = [SELECT Name, NamespacePrefix, SystemModStamp
                                      FROM StaticResource
                                      WHERE Name =: name
                                      LIMIT 1];
        if(!resources.isEmpty()) {
            url = domainURL + '/resource/' + resources[0].SystemModStamp.getTime() + '/' + name;
        }
        return url;
    }

    @AuraEnabled
    public static User getCurrentUser(){
        return [SELECT Id, Name, AccountId, Account.VCL_Portal_Status1__c, Account.Is_VCL_Portal_Co_Applicant__c, Account.Is_VCL_Application_Submitted__c,Account.Is_Registration_Completed__c FROM User  WHERE Id =: UserInfo.getUserId() AND IsPortalEnabled = true];
    }
    
    public class ClientPortalUIConfig {
        @AuraEnabled
        public Client_Portal_Settings__c headerUiConfig {get; set;}
        @AuraEnabled
        public String headerBackgroundImageURL {get; set;}
        @AuraEnabled
        public String headerCompanyLogoImageURL {get; set;}
        @AuraEnabled
        public Client_Portal_Settings__c menuUiConfig {get; set;}
        @AuraEnabled
        public String menuBackgroundImageURL {get; set;}
        @AuraEnabled
        public Client_Portal_Settings__c bodyUiConfig {get; set;}
        @AuraEnabled
        public String bodyBackgroundImageURL {get; set;}
        @AuraEnabled
        public Client_Portal_Settings__c footerUiConfig {get; set;}
        @AuraEnabled
        public String footerBackgroundImageURL {get; set;}
        @AuraEnabled
        public String footerCompanyLogoImageURL {get; set;}
        @AuraEnabled
        public Client_Portal_Portfolio__c portfolio {get; set;}
        @AuraEnabled
        public Boolean isDisplayChatEnabled {get; set;}
        @AuraEnabled
        public Boolean isSandbox {get; set;}
        @AuraEnabled
        public Boolean isPortalConfigPresent {get; set;}
        @AuraEnabled
        public Boolean isShowingDefaultPortal {get; set;}
    }
}