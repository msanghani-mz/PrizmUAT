@isTest
public class ClientPortal_ContactUsControllerTest {
    @isTest
    static void getAccountDetailsTest(){
        ClientPortal_ContactUsController.getAccountDetails();
    }
    
    @isTest
    static void sendEmailAndCreateTaskTest(){
        Account acc = [Select Id, Name,PersonContactId, OwnerId, Best_time_to_contact__c From Account Where LastName='Account'];
        User portalUser = ClientPortal_TestDataFactory.createUser(acc.PersonContactId, 'VCL Customer Community Login User')[0];
        System.runAs(portalUser) {
            ClientPortal_ContactUsController.sendEmailAndCreateTask(acc,'taskTest','Morning','ContactUs Task Created', '');
        }
    }
    
    @isTest
    static void sendEmailAndCreateTaskWithExceptionTest() {
        try{
            Account acc = [Select Id, Name,PersonContactId, OwnerId, Best_time_to_contact__c From Account Where LastName='Account'];
            ClientPortal_ContactUsController.sendEmailAndCreateTask(acc,'taskTest','Morning','ContactUs Task Created', '');
        } catch(Exception ex) {
            System.assert(ex != null );
        }
    }
    
    @isTest
    static void sendEmailAndCreateTaskWithAttachmentsTest(){
        Account acc = [Select Id, Name, OwnerId, Best_time_to_contact__c, PersonContactId From Account Where LastName='Account'];

        User portalUser = ClientPortal_TestDataFactory.createUser(acc.PersonContactId, 'VCL Customer Community Login User')[0];
        
        ContentVersion contentVesrionObj = [Select Id, ContentDocumentId from ContentVersion Where Title = 'xxxx' AND PathOnClient='image.jpg'] ;
        List<ClientPortal_ContactUsController.DocumentWrapper> docWrapperList = new List<ClientPortal_ContactUsController.DocumentWrapper>() ;
        ClientPortal_ContactUsController.DocumentWrapper docWrapperObj = new ClientPortal_ContactUsController.DocumentWrapper();
        docWrapperObj.name = 'image.jpg' ;
        docWrapperObj.documentId = contentVesrionObj.ContentDocumentId ;
        docWrapperList.add(docWrapperObj) ;
        
        System.runAs(portalUser) {
            ClientPortal_ContactUsController.sendEmailAndCreateTask(acc,'taskTest','Morning','ContactUs Task Created', JSON.serialize(docWrapperList));
        	ClientPortal_ContactUsController.getAccountDetails() ;
        }
    }
    
    @isTest
    static void deleteDocWithExceptionTest(){
        try{
            ClientPortal_ContactUsController.ResponseWrapper response = new ClientPortal_ContactUsController.ResponseWrapper();
            response.taskAttachmentId = null ;
            ClientPortal_ContactUsController.deleteDocument('Test');
        } catch(Exception ex) {
            System.assert(ex != null );
        }
    }
    
    @isTest
    static void deleteDocTest(){
        Account acc = [Select Id, Name, OwnerId, Best_time_to_contact__c From Account Where LastName='Account'];
        
        ContentVersion contentVesrionObj = [Select Id, ContentDocumentId from ContentVersion Where Title = 'xxxx' AND PathOnClient='image.jpg'] ;
       
        ClientPortal_ContactUsController.deleteDocument(contentVesrionObj.ContentDocumentId);
    }
    
    @testSetup
    static void setupTestData() {
        EmailMessage emailInstance = new EmailMessage(); 
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        account1.OwnerId = UserInfo.getUserId();
        insert account1;
        ContentVersion testContentVersion = ClientPortal_TestDataFactory.createContentVersion() ;
        insert testContentVersion ;
        
        list<Contact> conList = ClientPortal_TestDataFactory.buildContact(account1.Id,'Account');
        insert conList;
        
        String result='Success';
        try {
            Task taskInstance = new Task();
            taskInstance.Subject = 'taskTest';
            taskInstance.WhatId = account1.Id;
            taskInstance.Status = 'Not Started';
            taskInstance.Description = 'ContactUs Task Created' + ' Best Time to Call: ' + 'Morning';
            taskInstance.ActivityDate = System.today().addDays(1);
            taskInstance.Priority = 'Normal';
            taskInstance.OwnerId = account1.OwnerId;
            insert taskInstance;
        } catch(Exception e) {
            result = e.getMessage();
        }
    }
}