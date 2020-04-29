public without sharing class ClientPortal_DNLDocumentInformationCntrl {

    private static final String UPLOADED_CHKLIST_STATUS = 'Uploaded';
    
    @AuraEnabled
    public static List<ClientPortal_VCLHomeCntrl.LendingApplicationDocument> getDocumentsByLendingApplication(){
        Account accountInstance = getCurrentUserAccount();
        List<fsCore__Lending_Application__c> appList = [SELECT Id, 
                                                            (select id
                                                             FROM fsCore__Lending_Application_Customer__r 
                                                             WHERE fsCore__Account_Name__c = :accountInstance.Id LIMIT 1)
                                                            FROM fsCore__Lending_Application__c WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                                             FROM fsCore__Lending_Application_Customer__c 
                                                                                                             WHERE fsCore__Account_Name__c = :accountInstance.Id)
                                                        AND fsCore__Is_Application_Read_Only__c = false
                                                            ORDER BY SystemModStamp DESC
                                                            LIMIT 1];
        if(!appList.isEmpty()){
            return ClientPortal_VCLHomeCntrl.getDocumentsByLendingApplication(appList[0].Id);
        }
        return null;
    }

    @AuraEnabled
    public static List<ClientPortal_VCLHomeCntrl.DocumentWrapper> getDocumentsByChecklist(String checkListDetailString){
        return ClientPortal_VCLHomeCntrl.getDocumentsByChecklist(checkListDetailString);
    }

    @AuraEnabled
    public static void deleteDocumentFromChecklist(Id docId, Boolean updateCheckList){
        ClientPortal_VCLHomeCntrl.deleteDocumentFromChecklist(docId, updateCheckList);
    } 

    @AuraEnabled
    public static void deleteDocuments(String documentWrapperString){
        ClientPortal_VCLHomeCntrl.deleteDocuments(documentWrapperString);
    } 

    @AuraEnabled
    public static string uploadDocumentToCheckList(String checkListId, String documentWrapString, String accountInstanceString){
        Boolean updateAccount = false;
        return ClientPortal_VCLHomeCntrl.uploadDocumentToCheckList(checkListId, documentWrapString, accountInstanceString, updateAccount);
    } 
    
    @AuraEnabled
    public static ClientPortal_VCLHomeCntrl.CheckListWrapper getCheckLists(){
        Account accountInstance = getCurrentUserAccount();
        List<fsCore__Lending_Application__c> appList = [SELECT Id, 
                                                            (select id
                                                             FROM fsCore__Lending_Application_Customer__r 
                                                             WHERE fsCore__Account_Name__c = :accountInstance.Id LIMIT 1)
                                                            FROM fsCore__Lending_Application__c WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                                             FROM fsCore__Lending_Application_Customer__c 
                                                                                                             WHERE fsCore__Account_Name__c = :accountInstance.Id)
                                                            ORDER BY SystemModStamp DESC
                                                            LIMIT 1];
        if(!appList.isEmpty()){
            return ClientPortal_VCLHomeCntrl.getCheckLists(appList[0].Id);
        }
        return null;
    } 

    @AuraEnabled
    public static Account getCurrentUserAccount(){
        Account userAccount = new Account();
        List<User> userList = [SELECT Id, Name, AccountId
                                FROM User
                                WHERE Id =: UserInfo.getUserId()
                                AND IsPortalEnabled = true];
            
        if (!userList.isEmpty()) {
            Id userAccountId = userList[0].accountId ;
            if(String.isNotBlank(userAccountId)){
                userAccount = [SELECT Id, PersonEmail, FirstName, LastName, Name,Person_Email__c , Is_Income_Added__c, 
                                Is_VCL_ESIGN_Accepted__c, Is_VCL_ESign_Declined__c, Is_VCL_Portal_Co_Applicant__c, Is_SSN_Submitted__c,
                                Is_VCL_TILA_Accepted__c, Is_VCL_TILA_Declined__c, PersonContactId, VCL_Portal_Status1__c, Is_Bank_Info_Added__c,
                                VCL_Related_Portal_Account__r.VCL_Portal_Status1__c, VCL_Related_Portal_Account__c
                                FROM Account
                                WHERE Id=: userAccountId];
            }
        }
        return userAccount;
    }

    public static Boolean isCheckListPending(){
        Boolean checkListPending = false;
        Account accountInstance = getCurrentUserAccount();
        List<fsCore__Lending_Application__c> appList = [SELECT Id, 
                                                            (select id
                                                             FROM fsCore__Lending_Application_Customer__r 
                                                             WHERE fsCore__Account_Name__c = :accountInstance.Id LIMIT 1)
                                                            FROM fsCore__Lending_Application__c WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
                                                                                                             FROM fsCore__Lending_Application_Customer__c 
                                                                                                             WHERE fsCore__Account_Name__c = :accountInstance.Id)
                                                            ORDER BY SystemModStamp DESC
                                                            LIMIT 1];
        if(!appList.isEmpty()){
            ClientPortal_VCLHomeCntrl.CheckListWrapper wrap = ClientPortal_VCLHomeCntrl.getCheckLists(appList[0].Id);
            if(wrap.status == 'Success'){
                for(ClientPortal_VCLHomeCntrl.LendingApplicationCheckListWrapper wrapper : wrap.cheklistWrapperList){
                    if(wrapper.isPending){
                        checkListPending = true;
                        break;
                    }
                }
            }
        }
        return checkListPending;
    }

    @AuraEnabled
    public static List<ClientPortal_VCLHomeCntrl.SelectOption> createOptionList(String wrapperString){
        return ClientPortal_VCLHomeCntrl.createOptionList(wrapperString);
    }

    @AuraEnabled
    public static void uploadFileToBox(String documentListString, String checkListId){
        ClientPortal_VCLHomeCntrl.uploadFileToBox(documentListString, checkListId);
    }
}