@isTest
public class ClientPortal_DocuSignTriggerHndlrTest {
    
    @isTest
    private static void uploadSignedDocumentOnCompleteTest() {

        dfsle__EnvelopeStatus__c envelopeStatusObj = new dfsle__EnvelopeStatus__c() ;
        envelopeStatusObj.dfsle__DocuSignId__c = '12345678' ;
        envelopeStatusObj.dfsle__Status__c = 'Sent' ;
        insert envelopeStatusObj ;
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.Is_VCL_Bank_ATD_Accepted__c = true ;
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;
        
        fsCore__Bank_Account__c bankAccountObj = ClientPortal_TestDataFactory.buildBankAccount(account1.Id) ;
        bankAccountObj.VCL_Envelope_Id__c = '12345678' ;
        bankAccountObj.Docusign_Status__c = 'Sent' ;
        insert bankAccountObj ;
        
        Map<Id, fsCore__Bank_Account__c> envelopeOldMap = new Map<Id, fsCore__Bank_Account__c>() ;
        envelopeOldMap.put(bankAccountObj.Id , bankAccountObj) ;
        
        List<fsCore__Bank_Account__c> envelopeStatusList = new List<fsCore__Bank_Account__c> () ;

        envelopeStatusList.add(new fsCore__Bank_Account__c(
            Id = bankAccountObj.Id,
            Docusign_Status__c = 'Completed' ,
            VCL_Envelope_Id__c = '12345678'
        )) ;
        
        ContentVersion docContent2 = ClientPortal_TestDataFactory.createContentVersion();
        docContent2.Title = 'Test_Completed';
        insert docContent2;
        Id conDoc2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:docContent2.Id].ContentDocumentId;
        ContentDocumentLink link2 = ClientPortal_TestDataFactory.createContentDocumentLink(conDoc2, bankAccountObj.Id);
        insert link2;
        
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'VCL', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        

        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'VCL', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        

        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        insert testProduct; 
        
        Account testAcc = [SELECT Id, PersonContactId FROM Account where Id = :account1.Id] ;
        
        list<fsCore__Lending_Application__c> lstLendApp =new list<fsCore__Lending_Application__c>();
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                                                                , testBranch
                                                                                                                , testProduct
                                                                                                                , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = account1.Id;
        testApplication.fsCore__Primary_Customer_Contact__c = testAcc.PersonContactId;
        testApplication.Loan_Type__c = 'VCL';

        lstLendApp.add(testApplication);
        insert lstLendApp;
        
        ClientPortal_DocuSignTriggerHndlr.uploadSignedDocumentOnComplete(envelopeOldMap, envelopeStatusList) ;
        
        
        
        fsCore__Bank_Account__c envelopeStatusObj1 = new fsCore__Bank_Account__c(
            Id = bankAccountObj.Id,
            Docusign_Status__c = 'Completed' ,
            VCL_Envelope_Id__c = '12345678'
        ) ;
        update envelopeStatusObj1 ;
        
        ClientPortal_DocusignSchedularClass classObj = new ClientPortal_DocusignSchedularClass(new Set<String>{bankAccountObj.Id}) ;
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test ClientPortal_DocusignSchedularClass', sch, classObj);
    }
}