public class ClientPortal_Utility {
    
    private static final String VCL_ADD_INCOME_STATUS = ClientPortal_Constants.VCL_ADD_INCOME_STATUS;
    private static final String VCL_LIST_DOCUMENT_STATUS = ClientPortal_Constants.VCL_LIST_DOCUMENT_STATUS;
    private static final String VCL_ESIGN_DISCLOSURE_STATUS = ClientPortal_Constants.VCL_ESIGN_DISCLOSURE_STATUS;
    private static final String VCL_ESIGN_TILA_STATUS = ClientPortal_Constants.VCL_ESIGN_TILA_STATUS;
    private static final String VCL_VERIFY_SSN_STATUS = ClientPortal_Constants.VCL_VERIFY_SSN_STATUS;
    private static final String VCL_BAV_STATUS = ClientPortal_Constants.VCL_BAV_STATUS;
    private static final String VCL_UPLOAD_DOCUMENT_STATUS = ClientPortal_Constants.VCL_UPLOAD_DOCUMENT_STATUS;

    public static Organization getOrgInfo() {
        List<Organization> organizationList = [SELECT Id, Name, IsSandbox
                                               FROM Organization
                                               WHERE Id =: UserInfo.getOrganizationId()];
        if(!organizationList.isEmpty()) {
            return organizationList[0];
        }
        return null;
    }
    
    public static Map<String, Id> getAccountIdFromCurrentUser() {
        Map<String, Id> accountIdMap = new Map<String, Id>();
        List<User> userList = [SELECT Id, Name, Contact.AccountId, Profile.Name
                               FROM User
                               WHERE Id =: userInfo.getUserId()
                               AND Contact.AccountId != null
                               LIMIT 1];
        if(!userList.isEmpty()) {
            accountIdMap.put('userAccountId', userList[0].Contact.AccountId);
            accountIdMap.put('primaryAccountId', userList[0].Contact.AccountId);
            accountIdMap.put('profileName', userList[0].Profile.Name);
        }
        return accountIdMap;
    }
    
    public static Map<String, Object> getCurrentUserInformation() {
        Map<String, Object> accountIdMap = new Map<String, Object>();
        List<User> userList = [SELECT Id, Name, Contact.AccountId, 
                               Profile.Name, Client_Portal_Display_Chat__c
                               FROM User
                               WHERE Id =: userInfo.getUserId()
                               AND Contact.AccountId != null
                               LIMIT 1];
        if(!userList.isEmpty()) {
            //accountIdMap.put('userAccountId', userList[0].Contact.AccountId);
            accountIdMap.put('primaryAccountId', userList[0].Contact.AccountId);
            accountIdMap.put('profileName', userList[0].Profile.Name);
            accountIdMap.put('isDisplayChatEnabled', userList[0].Client_Portal_Display_Chat__c);
        }
        return accountIdMap;
    }
    
    public static Id getRecordTypeId (String objectApi, String recordTypeName) {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectApi).getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();
        Id recordTypeId;
        
        if(recordTypeMap.containsKey(recordTypeName)) {
            recordTypeId = recordTypeMap.get(recordTypeName).getRecordTypeId();
        }
        return recordTypeId;
    }
    
    public static Id getOrgWideEmailId(String owdEmailName) {
        List<OrgWideEmailAddress> emailAddressList = [SELECT Id
                                                      FROM OrgWideEmailAddress
                                                      WHERE DisplayName = :owdEmailName
                                                      ORDER BY LastModifiedDate 
                                                      DESC LIMIT 1];
        if(!emailAddressList.isEmpty()) {
            return emailAddressList[0].Id;
        }
        return null;
    }
    
    public static EmailTemplate getEmailTemplate(String templateName){
        
        Map<String,EmailTemplate> templateNameToTemplate = new Map<String, EmailTemplate>();
        for (EmailTemplate template : [SELECT Name, Subject, HtmlValue, Body, BrandTemplateId
                                       FROM EmailTemplate
                                       WHERE DeveloperName =: templateName]){
                                           templateNameToTemplate.put(templateName, template);
                                       }
        return templateNameToTemplate.get(templateName);
    }

    public static String checkIfUserCanProceed(){
        List<String> vclStatusListToPreventSaveIncome = new List<String>();
        List<String> vclStatusListToFinaleSave = new List<String>();
        String returnMessage = 'Success';
        vclStatusListToPreventSaveIncome.add(VCL_ESIGN_DISCLOSURE_STATUS);
        vclStatusListToPreventSaveIncome.add(VCL_ESIGN_TILA_STATUS);
        vclStatusListToPreventSaveIncome.add(ClientPortal_Constants.VCL_PORTAL_STATUS_ESIGN_DIS);
        vclStatusListToPreventSaveIncome.add('');

        vclStatusListToFinaleSave.add(ClientPortal_Constants.VCL_PORTAL_DOCS_UPLOADED_STATUS);
        vclStatusListToFinaleSave.add(VCL_LIST_DOCUMENT_STATUS);

        Account userAccount = new Account();
        List<User> userList = [SELECT Id, Name, AccountId
                                FROM User
                                WHERE Id =: UserInfo.getUserId()
                                AND IsPortalEnabled = true];
        if(!userList.isEmpty()){
            userAccount = [SELECT Id, Is_VCL_Portal_Co_Applicant__c, VCL_Related_Portal_Account__c, Is_VCL_Registration_Completed__c,
                            Is_VCL_TILA_Accepted__c, Is_VCL_TILA_Declined__c, PersonContactId, VCL_Portal_Status1__c, Is_Bank_Info_Added__c,
                            TILA_Signed_Date__c, VCL_User_Registration_Date__c, VCL_Related_Portal_Account__r.VCL_Portal_Status1__c,
                            VCL_Related_Portal_Account__r.Is_Bank_Info_Added__c
                            FROM Account
                            WHERE Id= :userList[0].AccountId];
            if(userAccount.VCL_Related_Portal_Account__c != null){
                if(userAccount.VCL_Portal_Status1__c == VCL_ADD_INCOME_STATUS || userAccount.VCL_Portal_Status1__c == VCL_LIST_DOCUMENT_STATUS){
                    String applicantString = '';
                    String errorMessagePart1 = '';
                    String errorMessagePart2 = ' otherwise the application will be withdrawn.';
                    String dateValue = '';
                    if(userAccount.Is_VCL_Portal_Co_Applicant__c){
                        applicantString = 'applicant';
                    }else{
                        applicantString = 'co-applicant';
                    }
                    if(userAccount.VCL_Portal_Status1__c == VCL_ADD_INCOME_STATUS && (userAccount.VCL_Related_Portal_Account__r.VCL_Portal_Status1__c == null || vclStatusListToPreventSaveIncome.contains(userAccount.VCL_Related_Portal_Account__r.VCL_Portal_Status1__c.trim()))){
                        errorMessagePart1 = 'You cannot proceed with your loan application until your ' + applicantString + ' has finished their registration. Please remind them to do so by ';
                        dateValue = userAccount.VCL_User_Registration_Date__c.addDays(3).format('MM-dd-yyyy');
                        returnMessage = errorMessagePart1 + dateValue + errorMessagePart2;
                        //throw new AuraHandledException(errorMessagePart1 + dateValue + errorMessagePart2);
                    }else if(userAccount.VCL_Portal_Status1__c == VCL_LIST_DOCUMENT_STATUS && !vclStatusListToFinaleSave.contains(userAccount.VCL_Related_Portal_Account__r.VCL_Portal_Status1__c)){
                        errorMessagePart1 = 'You cannot proceed with your loan application until your ' + applicantString + ' has submitted the required documents for income and identity verification. Please remind them to do so by ';
                        dateValue = userAccount.TILA_Signed_Date__c.addDays(15).format('MM-dd-yyyy');
                        returnMessage = errorMessagePart1 + dateValue + errorMessagePart2;
                        //throw new AuraHandledException(errorMessagePart1 + dateValue + errorMessagePart2);
                    }
                }
            }
        }
        return returnMessage;
    }

    public static String getUserIPAddress() {
		string ReturnValue = '';  
        // True-Client-IP has the value when the request is coming via the caching integration.
        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ReturnValue == '' || ReturnValue == null) {
            ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
        if (ReturnValue == '' || ReturnValue == null) {
            ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
	    return ReturnValue;
    }
    
    public static Client_Portal_Portfolio__c getUserPortfolio(){
        Map<String, Object> valueObjectMap = getCurrentUserInformation();
        Client_Portal_Portfolio__c portfolio = new Client_Portal_Portfolio__c();
        if(valueObjectMap.containsKey('profileName')){
            String portfolioProfileName = (String)valueObjectMap.get('profileName');
            if(portfolioProfileName != null || portfolioProfileName.trim() != ''){
                portfolio = [Select Id, Name, CPA_Content__c, ESign_Content__c, RDA_Content__c, TCPA_Content__c 
                            FROM Client_Portal_Portfolio__c 
                            WHERE Profile_Name__c = :portfolioProfileName
                            ORDER BY SystemModstamp DESC
                            LIMIT 1];
            }
        }
        return portfolio;
    }

    public static List<String> getApplicantNameList(){
        String returnValue;
        Client_Portal_Portfolio__c portfolio = getUserPortfolio();
        if(portfolio != null){
            if(portfolio.Name == 'DNL'){
                return getDNLApplicantNameList();
            }
        }
        return null;
    }

    private static List<String> getDNLApplicantNameList(){
        List<String> returnList = new List<String>();
        Map<String, Object> valueIdMap = getCurrentUserInformation();
        if(valueIdMap.containsKey('primaryAccountId')){
            Id accountId = (Id)valueIdMap.get('primaryAccountId');
            Opportunity[] oppDetails = [SELECT Id, AccountId, Co_Applicant_Name__c
                                        FROM Opportunity
                                        WHERE 
                                            (AccountId =: accountId
                                                OR 
                                            Co_Applicant_Name__r.Id =: accountId)
                                        AND StageName =: ClientPortal_Constants.DNL_OPP_STAGE_REG_IN_PROGRESS
                                        ORDER BY LastModifiedDate DESC
                                        LIMIT 1];
            if(oppDetails.size() >0 ){
                Set<Id> accountIdSet = new Set<Id>();
                if(oppDetails[0].AccountId != null){
                    accountIdSet.add(oppDetails[0].AccountId);
                }
                if(oppDetails[0].Co_Applicant_Name__c != null){
                    accountIdSet.add(oppDetails[0].Co_Applicant_Name__c);
                }
                for(Account accObj : [SELECT Id, Name FROM Account WHERE Id IN :accountIdSet]){
                    returnList.add(accObj.name);
                }
            }
        }
        return returnList;
    }

    public static Integer getTimeZoneOffsetHours(DateTime d, String tz) {
        TimeZone tzSelected = TimeZone.getTimeZone(tz);
        TimeZone tzGmt = TimeZone.getTimeZone('Greenwich Mean Time');
    
        Integer gmtOffset = tzGmt.getOffset(d);
        Integer selectedOffset = tzSelected.getOffset(d);
        Integer hours = (selectedOffset - gmtOffset) / 1000 / 60 / 60; 
    
        return hours;
    }

    public static String getSobjectNameFromId(Id recordId){
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        return sobjectType;
    }

    public static OrgWideEmailAddress getOrgWideEmailAddress(){
        OrgWideEmailAddress[] owea = [select Id, DisplayName, Address from OrgWideEmailAddress where Address = :ClientPortal_Constants.PORTAL_EMAIL_FROM_ADDRESS];
        if(!owea.isEmpty()){
            return owea[0];
        }else{
            throw new AuraHandledException('Org wide email address not found, please contact your admin');
        }
    }
}