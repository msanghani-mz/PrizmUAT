public without sharing class ClientPortal_LoginFlow2FAPageCntrl {

    public Integer validationCode {
        get;
        set;
    }
    public String actionString {
        get;
        set;
    }
    public String enteredText {
        get;
        set;
    }
    public String exceptionText {
        get;
        set;
    }
    public DateTime sentTime {
        get;
        set;
    }
    public ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig uiConfiguration {
        get;
        set;
    }
    public User userInstance {
        get;
        set;
    }
    public Portal_Identity_Service__c loginHistoryInstance {
        get;
        set;
    }
    public Portal_Identity_Service__c identityVerificationInstance {
        get;
        set;
    }
    public String encryptedMobileNumber {
        get;
        set;
    }
    public String encryptedEmail {
        get;
        set;
    }
    public String pageSource {
        get;
        set;
    }
    private static String pUserEmail {
        get;
        set;
    }
    private static String pUserMobile {
        get;
        set;
    }
    private static Boolean updateUserNAccount {
        get;
        set;
    }
    public static String phoneNumberToUser {
        get;
        set;
    }
    @TestVisible private static final String LENDING_APPLICATION_STATUS = 'Offer Accepted';
    @TestVisible private static final String LENDAPP_REG_PROG = 'Registration in Progress';


    public ClientPortal_LoginFlow2FAPageCntrl() {
        updateUserNAccount = false;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserEmail')) || String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserMobile'))) {
            updateUserNAccount = true;
            pUserEmail = ApexPages.currentPage().getParameters().get('pUserEmail');
            pUserMobile = ApexPages.currentPage().getParameters().get('pUserMobile');
        }

        this.actionString = 'modeSelection';
        List < User > userList = [SELECT Id, contact.AccountId, Name, FirstName, LastName,
            MobilePhone, Email
            FROM User
            WHERE Id =: UserInfo.getUserId()
            AND contact.AccountId != null
        ];
        if (!userList.isEmpty()) {
            this.userInstance = userList[0];
            String emailaddress = (updateUserNAccount) ? pUserEmail : this.userInstance.Email;
            phoneNumberToUser = (updateUserNAccount) ? pUserMobile : this.userInstance.MobilePhone;
            if (!String.isBlank(emailaddress)) {
                this.encryptedEmail = emailaddress.replaceAll('(^[^@]{2}|(?!^)\\G)[^@]', '$1*');
            }
        }

        String headerdata = URL.getCurrentRequestUrl().toExternalForm();
        String sourceUrl = ApexPages.currentPage().getParameters().get('source');
        if (String.isNotBlank(sourceUrl)) {
            this.pageSource = sourceUrl;
        }

        List < String > urlValueList = new List < String > ();
        urlValueList = headerdata.split('/apex');
        if (!urlValueList.isEmpty()) {
            String url = urlValueList[0];
            this.uiConfiguration = ClientPortal_CustomRegisterCntrl.getClientPortalUIConfiguration(url, null);
        }
    }

    public PageReference updateUserAndRedirect() {
        updateUserNAccount = false;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserEmail')) || String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserMobile'))) {
            updateUserNAccount = true;
            pUserEmail = ApexPages.currentPage().getParameters().get('pUserEmail');
            pUserMobile = ApexPages.currentPage().getParameters().get('pUserMobile');
        }
        System.debug(updateUserNAccount + 'updateUserNAccount' + pUserEmail);
        Boolean isTrustedIP = false;
        String sourceIP = ClientPortal_Utility.getUserIPAddress();
        /* If login history not having any records, assigning isTrustedIp as FALSE
         * If login history having any records, if atleast one record source ip is matched with logged in user's
         * source ip assining isTrusted as true or else by default it will be flase
         */

        this.loginHistoryInstance = new Portal_Identity_Service__c();
        Id recordTypeId = ClientPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Login History');
        List < Portal_Identity_Service__c > loginHistoryList = [SELECT Id, Status__c, Last_Login_Time__c
            FROM Portal_Identity_Service__c
            WHERE RecordTypeId =: recordTypeId
            AND User__c =: UserInfo.getUserId()
            AND Ip_Address__c =: sourceIP order By createddate desc
        ];

        if (!loginHistoryList.isEmpty()) {

            for (Portal_Identity_Service__c loginInstance: loginHistoryList) {
                this.loginHistoryInstance = loginInstance.clone();
                this.loginHistoryInstance.Id = loginInstance.Id;
                this.loginHistoryInstance.Last_Login_Time__c = System.now();

                if (loginInstance.Last_Login_Time__c.date().daysbetween(System.today()) < 30 &&
                    loginInstance.Status__c == 'Success') {
                    isTrustedIP = true;
                } else {
                    this.loginHistoryInstance.Status__c = 'Initiated';
                }
                break;
            }
        } else {
            /* If there were no records with user and ip address */
            this.loginHistoryInstance = new Portal_Identity_Service__c(
                Ip_Address__c = sourceIP,
                Last_Login_Time__c = System.now(),
                User__c = UserInfo.getUserId(),
                Status__c = 'Initiated',
                RecordTypeId = recordTypeId);
                if(pageSource == ClientPortal_Constants.PORTAL_REG_2FA_SOURCE){
                    insert this.loginHistoryInstance;
                    isTrustedIP = true;
                    updateLendingAppStatus(UserInfo.getUserId());
                }
        }
        if (isTrustedIP == false) {
            User userInstance = new User(Id = UserInfo.getUserId(),
                Is_User_Authenticated__c = false);
            update userInstance;
            upsert this.loginHistoryInstance;
        } else {
            User userInstance = new User(Id = UserInfo.getUserId(), Is_User_Authenticated__c = true);
            if (updateUserNAccount) {
                userInstance.Username = pUserEmail;
                userInstance.Email = pUserEmail;
                userInstance.MobilePhone = pUserMobile;
            }

            update userInstance;
            updateUserIPAddressOnAccount(UserInfo.getUserId(), sourceIP, updateUserNAccount, pUserEmail, pUserMobile, this.loginHistoryInstance.Id);

            if (String.isNotBlank(this.uiConfiguration.portfolio.Domain_URL__c)) {
                PageReference urlRedirect = new Pagereference(this.uiConfiguration.portfolio.Domain_URL__c);
                urlRedirect.setRedirect(true);
                return urlRedirect;
            }
        }
        return null;
    }
    @future
    public static void updateUserIPAddressOnAccount(String userId, String ipAddress, Boolean updateUserNAccount, String pUserEmail, String pUserMobile, String loginInstanceId) {
        User currentuser = [Select Id, AccountId from User where id =: userId LIMIT 1];
        List < Account > accountsToUpdate = new List < Account > ();


        Portal_Identity_Service__c loginInsatance = new Portal_Identity_Service__c();
        loginInsatance.Id = loginInstanceId;
        loginInsatance.Status__c = 'Success';
        update loginInsatance;

        Account userAccount = new Account();
        userAccount.Id = currentuser.AccountId;
        userAccount.IP_Address__c = ipAddress;
        if (updateUserNAccount) {
            userAccount.personEmail = pUserEmail;
            userAccount.PersonMobilePhone = pUserMobile;
        }
        accountsToUpdate.add(userAccount);


        if (!updateUserNAccount) {
            update accountsToUpdate;
            return;
        }
        List < Account > currentUserAsRelatedList = [Select Id, VCL_Related_Person_Email__c FROM Account WHERE VCL_Related_Portal_Account__c =: userAccount.Id];
        for (Account userAcc: currentUserAsRelatedList) {
            userAcc.VCL_Related_Person_Email__c = pUserEmail;
            accountsToUpdate.add(userAcc);
        }

        update accountsToUpdate;
        List < fsCore__Lending_Application__c > lenidngAppsToUpdate = new List < fsCore__Lending_Application__c > ();
        for (fsCore__Lending_Application__c relatedLendingApp: [SELECT ID
                FROM fsCore__Lending_Application__c
                WHERE fsCore__Primary_Customer_Account__c =: userAccount.Id
            ]) {
            lenidngAppsToUpdate.add(new fsCore__Lending_Application__c(
                Id = relatedLendingApp.Id,
                Primary_Applicant_Email__c = pUserEmail
            ));
        }

        if (!lenidngAppsToUpdate.isEmpty()) {
            update lenidngAppsToUpdate;
        }
    }

    public void sendVerificationCodeToClient() {
        String selectedMode = ApexPages.currentPage().getParameters().get('selctedMode');
        Id recordTypeId = ClientPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification');

        if (String.isNotBlank(selectedMode)) {
            this.exceptionText = '';
            this.enteredText = null;

            if (selectedMode == 'agentSentCodeVerification') {
                this.actionString = 'agentSentCodeVerification';
            } else {
                this.validationCode = Integer.valueOf(getRandomNumber(6));
                updateUserNAccount = false;
                if (String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserEmail')) || String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserMobile'))) {
                    updateUserNAccount = true;
                    pUserEmail = ApexPages.currentPage().getParameters().get('pUserEmail');
                    pUserMobile = ApexPages.currentPage().getParameters().get('pUserMobile');
                }
                if (selectedMode == 'Email') {
                    System.debug('@@here - sendVerificationCodeToClient');
                    this.identityVerificationInstance = new Portal_Identity_Service__c(
                        User__c = UserInfo.getUserId(),
                        Status__c = 'Initiated',
                        RecordTypeId = recordTypeId,
                        Type__c = 'Email',
                        Unique_Identifier__c = String.valueOf(this.validationCode));
                    insert identityVerificationInstance;

                    Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                    String emailToUse = (updateUserNAccount != null && updateUserNAccount) ? pUserEmail : this.userInstance.Email;

                    System.debug('emailToUse ' + emailToUse);
                    emailInstance.setToAddresses(new String[] {
                        emailToUse
                    });
                    //emailInstance.setBCCAddresses(new List<String>{'jtighe@stratfs.com','acarroll@stratfs.com'});
                    String subjectToSend = 'Your Versara Lending Portal Verification Code.';
                    emailInstance.setSubject(subjectToSend);
                    EmailTemplate template = ClientPortal_Utility.getEmailTemplate('Generic_2FA_Code_Notification_HTML');
                    String htmlBody = template.HtmlValue;
                    htmlBody = htmlBody.replace('{!UserName}', UserInfo.getName());
                    htmlBody = htmlBody.replace('{!VerificationCode}', String.valueOf(this.validationCode));
                    emailInstance.setHTMLBody(htmlbody);

                    String plainTextBody = template.Body;
                    plainTextBody = plainTextBody.replace('{!UserName}', UserInfo.getName());
                    plainTextBody = plainTextBody.replace('{!VerificationCode}', String.valueOf(this.validationCode));
                    emailInstance.setPlainTextBody(plainTextBody.stripHtmlTags());

                    /*
                    String htmlbody = 'Hello ' + UserInfo.getName() + ', <br />'
                                    + '<br/>Your verification code is <span style="color:maroon">' + this.validationCode + '</span> <br /> <br />'
                                    + 'Thank you <br/>'
                                    + 'Versara Lending Team'; */

                    Id owdEmailId = ClientPortal_Utility.getOrgWideEmailId('Client Service Versara Team');
                    if (owdEmailId != null) {
                        emailInstance.setOrgWideEmailAddressId(owdEmailId);
                    }
                    Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                        emailInstance
                    });

                    List < EmailMessage > emailMessageList = [SELECT Id
                        FROM EmailMessage
                        WHERE Subject
                        LIKE: subjectToSend
                        ORDER BY CreatedDate DESC LIMIT 1
                    ];

                    if (mailResultList[0].isSuccess() == true && !emailMessageList.isEmpty()) {
                        EmailMessage emailMessageToUpdate = new EmailMessage(Id = emailMessageList[0].Id,
                            Related_Account__c = this.userInstance.contact.AccountId,
                            Decision_Source__c = 'Portal',
                            Action_Performed__c = '2FA Email By Client');
                        update emailMessageToUpdate;
                    }

                    this.identityVerificationInstance = new Portal_Identity_Service__c(
                        User__c = UserInfo.getUserId(),
                        Status__c = 'Initiated',
                        RecordTypeId = recordTypeId);
                    this.identityVerificationInstance.Type__c = 'Email';
                    this.identityVerificationInstance.Unique_Identifier__c = String.valueOf(this.validateCode());
                    insert this.identityVerificationInstance;
                    this.exceptionText = 'Please provide your verification code';

                } else if (selectedMode == 'Mobile' || selectedMode == 'Phone Call') {
                    this.identityVerificationInstance = new Portal_Identity_Service__c(
                        User__c = UserInfo.getUserId(),
                        Status__c = 'Initiated',
                        RecordTypeId = recordTypeId);
                    String mobileToUse = (updateUserNAccount) ? pUserMobile : this.userInstance.MobilePhone;
                    if (selectedMode == 'Mobile') {

                        String textMessage = 'Your Versara Lending portal verification code is:' + this.validationCode;

                        if (!Test.isRunningTest()) {
                            TwilioMessage messageInstance = TwilioCommunications.sendSMS('+13213924921', mobileToUse, textMessage);
                        }
                        this.identityVerificationInstance.Description__c = textMessage + '<br /> <b> To Mobile: </b> ' + mobileToUse;
                        this.identityVerificationInstance.Type__c = 'SMS';
                        this.identityVerificationInstance.Unique_Identifier__c = String.valueOf(this.validationCode);
                    } else if (selectedMode == 'Phone Call') {
                        System.debug('***** this.validationCode-->' + this.validationCode);
                        try {
                            //SFSPortal_PortalDetailsController.sendCallToClient(this.userInstance.MobilePhone, this.validationCode);
                        } catch (Exception e) {
                            this.exceptionText = e.getMessage();
                        }
                        String textMessage = 'Hello, ' + this.validationCode + ' is your code to confirm your identity.';
                        this.identityVerificationInstance.Description__c = textMessage + '<br /> <b> To Mobile: </b> ' + mobileToUse;
                        this.identityVerificationInstance.Type__c = 'Phone Call';
                    }
                    insert this.identityVerificationInstance;
                    this.exceptionText = 'Please provide your verification code';
                }
                this.sentTime = System.now();
                this.actionString = 'codeVerification';
            }
        }
        SYstem.debug('@@@ actionString ' + actionString);
    }

    public PageReference validateCode() {
        updateUserNAccount = false;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserEmail')) || String.isNotBlank(ApexPages.currentPage().getParameters().get('pUserMobile'))) {
            updateUserNAccount = true;
            pUserEmail = ApexPages.currentPage().getParameters().get('pUserEmail');
            pUserMobile = ApexPages.currentPage().getParameters().get('pUserMobile');
        }
        System.debug(updateUserNAccount + 'updateUserNAccount' + pUserEmail);
        if (this.enteredText != null) {
            this.exceptionText = '';
            if (!this.enteredText.isNumeric()) {
                this.exceptionText = 'Invalid Code. Please Try Again.';
                return null;
            }
            DateTime validateTime = System.now();
            Long minutes = (validateTime.getTime() - (this.sentTime).getTime()) / 60000;
            if (minutes >= 60) {
                this.exceptionText = 'Verification code is expired. Click Resend to send again.';
            } else {
                if (Integer.valueOf(this.validationCode) == Integer.valueOf(this.enteredText)) {
                    String sourceIp = ClientPortal_Utility.getUserIPAddress();
                    if (this.identityVerificationInstance != null && this.identityVerificationInstance.Id != null) {
                        updateIdentityVerificationInstance(identityVerificationInstance.Id);
                    }

                    User userInstance = new User(Id = UserInfo.getUserId(), Is_User_Authenticated__c = true);
                    if (updateUserNAccount) {
                        userInstance.Username = pUserEmail;
                        userInstance.Email = pUserEmail;
                        userInstance.MobilePhone = pUserMobile;
                    }

                    update userInstance;
                    updateUserIPAddressOnAccount(UserInfo.getUserId(), sourceIP, updateUserNAccount, pUserEmail, pUserMobile, this.loginHistoryInstance.Id);

                    if (String.isNotBlank(this.pageSource)) {
                        if (this.pageSource == 'userRegistration') {
                            this.actionString = 'verificationSuccess';
                            updateLendingAppStatus(UserInfo.getUserId());
                            return null;
                        }
                    }
                    if (String.isNotBlank(this.uiConfiguration.portfolio.Domain_URL__c)) {
                        PageReference pg = new PageReference(this.uiConfiguration.portfolio.Domain_URL__c);
                        pg.setRedirect(true);
                        return pg;
                    }
                } else {
                    this.exceptionText = 'Incorrect Code. Please Try Again.';
                }
            }
        } else {
            this.exceptionText = 'Please provide your verification code';
        }
        return null;
    }
    @future
    public static void updateIdentityVerificationInstance(String identityId) {
        Portal_Identity_Service__c identityVerificationInstance = new Portal_Identity_Service__c();
        identityVerificationInstance.Id = identityId;
        identityVerificationInstance.Status__c = 'Verified';
        update identityVerificationInstance;
    }

    public PageReference validateAgentCode() {
        return null;
    }

    public static void updateLendingAppStatus(Id userId) {
        User currentUser = [Select Id, AccountId from User where id =: userId LIMIT 1];
        Account currentAccount = [Select Id, VCL_Related_Portal_Account__c, VCL_Related_Portal_Account__r.Is_VCL_Registration_Completed__c FROM Account WHERE Id =: currentUser.AccountId];
        if (currentAccount.VCL_Related_Portal_Account__c != null) {
            if (currentAccount.VCL_Related_Portal_Account__r.Is_VCL_Registration_Completed__c) {
                updateLendingAppStatusRegInProg(currentUser.AccountId);
            }
        } else {
            updateLendingAppStatusRegInProg(currentUser.AccountId);
        }
    }

    private static void updateLendingAppStatusRegInProg(String accountId) {
        fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c
            FROM fsCore__Lending_Application__c
            WHERE fsCore__Application_Status__c =: LENDING_APPLICATION_STATUS
            AND Id IN(SELECT fsCore__Lending_Application_Number__c FROM fsCore__Lending_Application_Customer__c WHERE fsCore__Account_Name__c =: accountId)
            LIMIT 1
        ];
        if (!lendingApplicationList.isEmpty()) {
            fsCore__Lending_Application__c lendApp = new fsCore__Lending_Application__c(Id = lendingApplicationList[0].Id);
            lendApp.fsCore__Application_Status__c = LENDAPP_REG_PROG;
            update lendApp;
        }
    }

    public PageReference navigateToLogin() {
        String portfolioName = uiConfiguration.portfolio.Name;
        PageReference pg = new PageReference('/secur/logout.jsp');
        pg.setRedirect(true);
        return pg;
    }

    public static String getRandomNumber(Integer length) {
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, length);
        return randomNumber;
    }
}