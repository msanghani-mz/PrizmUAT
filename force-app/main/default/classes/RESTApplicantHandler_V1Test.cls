@isTest
private class RESTApplicantHandler_V1Test{
    
    @testSetup
    public static void createTestData(){
        
        TestHelperData.createTriggerExecutionTestData();
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Name_Format__c='Account Only';
        testProduct.fsCore__Customer_Type__c= 'Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        //create Payment Allocation Method
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        System.assert(testPaymentAlloc.Id != null, 'Test payment allocation created assert');
        
        //Contract Template 
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate; 
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');   
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        
        Database.insert(testApplication);
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');
        
        //create Account
        List<Account> accountlist = new List<Account>();
        
        Account nAccount = TestHelperData.createAccount();
        Account coAppAccount = TestHelperData.createAccount('TEST','LASTNAME');
        accountlist.add(nAccount);
        accountlist.add(coAppAccount);
        Database.insert(accountlist);
        
        System.assert(nAccount.Id != null, 'Test Account created assert');
        
        List<Account> testAccountList = [select id, personcontactId from Account where id in (:nAccount.id,:coAppAccount.Id) ];
        
        Account testAccount = testAccountList[0];
        Account testCoAccount = testAccountList[1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        
        
        //create Lending Application Customer 
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
    }
    @isTest
    private static void testServiceHandlerPutMethod_Success(){
        
        fsCore__Lending_Application_Customer__c customer   =    [SELECT Id
                                                                 , fsCore__Account_Name__c
                                                                 , fsCore__Account_Name__r.Id
                                                                 , fsCore__Account_Name__r.RecordTypeID
                                                                 , fsCore__Account_Name__r.FirstName
                                                                 , fsCore__Account_Name__r.LastName
                                                                 , fsCore__Account_Name__r.fsCore__National_Identification_Number__pc        
                                                                 , fsCore__Account_Name__r.Transunion_SSN__c
                                                                 FROM fsCore__Lending_Application_Customer__c];
        Id customerId = customer.id;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applicants/'+(String)customerId ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();   
        String jsonStr = '{ "transunion_ssn" : "1234-56-789",  "social_security_number" : "678654328"  }';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest();  
    }   
    @isTest
    private static void testServiceHandlerPutMethod_CustomerIdNull(){
        
        Id customerId = null;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applicants/'+(String)customerId ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();   
        String jsonStr = '{ "transunion_ssn" : "123-45-6789",  "social_security_number" : "678654328"  }';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest();     
    }
    @isTest
    private static void testServiceHandlerPutMethod_InvalidSSNDigits(){
        
        fsCore__Lending_Application_Customer__c customer   =    [SELECT Id
                                                                 , fsCore__Account_Name__c
                                                                 , fsCore__Account_Name__r.Id
                                                                 , fsCore__Account_Name__r.RecordTypeID
                                                                 , fsCore__Account_Name__r.FirstName
                                                                 , fsCore__Account_Name__r.LastName
                                                                 , fsCore__Account_Name__r.fsCore__National_Identification_Number__pc        
                                                                 , fsCore__Account_Name__r.Transunion_SSN__c
                                                                 FROM fsCore__Lending_Application_Customer__c];
        Id customerId = customer.id;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applicants/'+(String)customerId ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();   
        String jsonStr = '{ "transunion_ssn" : "12345678",  "social_security_number" : "67865432"  }';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest();  
    } 
    @isTest
    private static void testServiceHandlerPutMethod_InvalidApplicantId(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applicants/a1PL0000002z0wlMAA' ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();   
        String jsonStr = '{ "transunion_ssn" : "123456789",  "social_security_number" : "678654321"  }';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest(); 
        RESTRouter.doPut(); 
        Test.stopTest();  
    }   
    @isTest
    private static void testServiceHandlerPostMethod(){
        
        Id customerId = null;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applicants/'+(String)customerId ;
        RestResponse res = new RestResponse();   
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTRouter.doPost(); 
        Test.stopTest();  
    } 
    @isTest
    private static void testServiceHandlerGetMethod(){
        
        Id customerId = null;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applicants/'+(String)customerId ;
        RestResponse res = new RestResponse();   
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTRouter.doGet(); 
        Test.stopTest();  
    } 
    @isTest
    private static void testServiceHandlerDeleteMethod(){
        
        Id customerId = null;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applicants/'+(String)customerId ;
        RestResponse res = new RestResponse();   
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTRouter.doDelete(); 
        Test.stopTest();  
        RESTApplicant.Request rest1 = new RESTApplicant.Request();
              rest1.first_name = '';          
              rest1.last_name  = '';               
              rest1.date_of_birth = Date.newInstance(2019,11,11);            
              rest1.relationship  = '';            
              rest1.email   = '';                  
              rest1.phone_number = '';             
              rest1.mobile_number  = '';           
              rest1.mailing_street  = '';          
              rest1.mailing_city   = '';           
              rest1.mailing_state  = '';           
              rest1.mailing_country  = '';         
              rest1.mailing_postal_code  = '';     
              rest1.home_street     = '';          
              rest1.home_city   = '';              
              rest1.home_state   = '';             
              rest1.home_country   = '';           
              rest1.home_postal_code  = '';                
              rest1.transunion_ssn   = '';           
              rest1.social_security_number = '';   
              rest1.annual_stated_Income = 12; 
        
        RESTApplicant.Response rest2 = new RESTApplicant.Response();
       
        rest2.applicant_name = '';
        rest2.relationship = '';
        
        
    } 
}