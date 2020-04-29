public without sharing class ClientPortal_ContactUsController {
    
    @AuraEnabled
    public static ResponseWrapper getAccountDetails() {
        
        ResponseWrapper response = new ResponseWrapper();
        Account acc = new Account();
        
        User userInstance = new User();
        List<User> userList = new List<User>();
        userList = [SELECT Id, Name, AccountId
                    FROM User
                    WHERE Id =: userInfo.getUserId()
                    AND IsPortalEnabled = true];
        
        if (!userList.isEmpty()) {
            userInstance = userList[0];
        }
        
        if(userInstance.accountId != null) {
            acc = [SELECT Id, PersonEmail, OwnerId, Best_time_to_contact__c
                   FROM Account
                   WHERE Id=: userInstance.accountId];
            acc.Best_time_to_contact__c = '';
        }
        
        response.acc = acc;
        response.emailInstance = new EmailMessage();
        
        return response;
    }
    
    private static void createAttachmentsForTask(Map<String, String> docIdToDocNameMap , Task taskInstance) {
        List<Attachment> attachmentsToInsert = new List<Attachment>() ;
        List<ContentDocument> docListToDelete = new List<ContentDocument>();
        for(ContentVersion conVersionObj : [SELECT Id, ContentDocumentId, VersionData 
                                            FROM ContentVersion 
                                            WHERE ContentDocumentId IN :docIdToDocNameMap.keySet() ]) {
            attachmentsToInsert.add(
                new Attachment(
                    Body = conVersionObj.VersionData ,
                    Name = docIdToDocNameMap.get(conVersionObj.ContentDocumentId) ,
                    ParentId = taskInstance.Id,
                    OwnerId = taskInstance.OwnerId
                )
            ) ;
            
            docListToDelete.add(new ContentDocument(
                Id = conVersionObj.ContentDocumentId
            ));
            
        }
        
        if( !attachmentsToInsert.isEmpty() ) {
            insert attachmentsToInsert ;
            delete docListToDelete ;
        }
    }
    
    @AuraEnabled
    public static String sendEmailAndCreateTask(Account accountDetails,
                                                String requestSubject,
                                                String bestTimeToCall,
                                                String message,
                                                String fileList)  {
        String result='Success';
        Map<String, String> docIdToDocNameMap = new Map<String, String> () ;
        try {
            List<DocumentWrapper> documentList = new List<DocumentWrapper> ();
            String taskType = 'DNL Task' ;
            Id recordTypeId ;
            User userInstance = [SELECT Id, Name, AccountId, Profile.Name
                                    FROM User
                                    WHERE Id =: userInfo.getUserId()
                                    AND IsPortalEnabled = true LIMIT 1];

            if (userInstance.Profile.Name.contains('VCL')) {
                taskType = 'VCL Task' ;
            }

            recordTypeId = ClientPortal_Utility.getRecordTypeId('Task' , taskType) ;
            
            if(String.isNotBlank(fileList)){
                documentList = (List<DocumentWrapper>)JSON.deserialize(fileList, List<DocumentWrapper>.class);
            }
                
            for(DocumentWrapper docVersionObject : documentList){
                docIdToDocNameMap.put(docVersionObject.documentId , docVersionObject.name) ;
            }
            
            Task taskInstance = new Task();
            taskInstance.Subject = requestSubject;
            taskInstance.WhatId = accountDetails.Id;
            taskInstance.Status = 'Not Started';
            taskInstance.Description = message + ' Best Time to Call: ' + bestTimeToCall;
            taskInstance.ActivityDate = System.today().addDays(1);
            taskInstance.Priority = 'Normal';
            taskInstance.OwnerId = accountDetails.OwnerId;
            taskInstance.RecordTypeId = recordTypeId ;
            insert taskInstance;
            Account accountToUpdate = new Account(Id = accountDetails.Id,
                                                 Best_time_to_contact__c = accountDetails.Best_time_to_contact__c ) ;
            update accountToUpdate;

            if(!docIdToDocNameMap.isEmpty() ) {
                createAttachmentsForTask(docIdToDocNameMap , taskInstance) ;
            }
            
            
            
            //To Do Send Email to clientService@VersaraLending.com .
            
        } catch(Exception e) {
            System.debug('Error ' + e.getMessage());
            System.debug('Error ' + e.getStackTraceString());
            result = e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    @AuraEnabled 
    public static void deleteDocument(String deleteDocumentId) {
        System.debug('deleteDocumentId ' + deleteDocumentId);
        try {
            if(deleteDocumentId != null) {
                ContentDocument contentDocumentInstance = new ContentDocument(Id = deleteDocumentId);
                delete contentDocumentInstance ;
            }
        } catch(Exception e) {
            System.debug('Error ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    public without sharing class ResponseWrapper {
        @AuraEnabled
        public Account acc {get;set;}
        @AuraEnabled
        public EmailMessage emailInstance {get;set;}
        @AuraEnabled
        public Task taskAttachmentId {get;set;}
    }
    
    public without sharing class DocumentWrapper{
        public String name {get; set;}
        public String documentId {get; set;}
    }
}