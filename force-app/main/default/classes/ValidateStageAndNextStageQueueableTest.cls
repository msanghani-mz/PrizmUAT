@isTest
public class ValidateStageAndNextStageQueueableTest {
    
    @testsetup static void createTestData(){
        
        //create custom settings
        //fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING, fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});
        
       
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
        
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        
        
        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'DNL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');       
        
        //
        //create contract template
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        
        
        //
        //create custom settings
        //
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_SYSTEM_PREFERENCE
            , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE
            , fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
            , fsCore.Constants.CUSTOM_SETTING_BATCH_JOB_SETTING
            , fsCore.Constants.CUSTOM_SETTING_BUSINESS_DATE_SETTING});
        
        //
        //create Lending Application by populating company, branch, product, contract template
        //
        List<fsCore__Lending_Application__c> testApplication = new List<fsCore__Lending_Application__c>();                                                    
        fsCore__Lending_Application__c testApplication2 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Loan Application');
        testApplication2.Loan_Processing_Letter_Sent_Date__c= System.today().adddays(-35);
        testApplication2.Pre_TILA_Sent_Date__c = Date.Today()-20;
        testApplication2.Pre_Tila_Sent_Date_First__c = testApplication2.Pre_TILA_Sent_Date__c;
        testApplication2.Is_PreTila_Signed__c = false;
        testApplication2.Loan_Type__c='DNL';
        testApplication2.pre_tila_sent_date__c = System.today();
        testApplication2.is_pretila_signed__c = true;
        testApplication2.pre_tila_signed_date__c = System.today();
        testApplication2.fsCore__Is_Current_Stage_Validated__c = true;
        testApplication.add(testApplication2);      
        insert testApplication;
        
       //create Opportunity
        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity testOpportunity = TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity.Co_Applicant_Name__c = testCoAccount.Id;
        testOpportunity.Related_Lending_Application__c = testApplication2.Id;
        testOpportunity.Import_Id__c = testApplication2.Id;
        
        Opportunity testOpportunity1= TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity1.Name = 'Test Opportunity1';
        testOpportunity1.Co_Applicant_Name__c = null;
        testOpportunity1.Program_Id__c = 'test1';
        testOpportunity1.Program_Type__c = 'test1';
        testOpportunity1.DRP_Name__c = 'DRP1211';
        testOpportunity1.DRP_Account_Number__c = '23763761';
        testOpportunity1.Related_Lending_Application__c = testApplication2.Id;
        testOpportunity1.Import_Id__c = '12761726';
        
        opplist.add(testOpportunity);
        opplist.add(testOpportunity1);
        
        
        Database.insert(opplist);
        System.assert(testOpportunity.Id != null, 'Test Opportunity created assert');
        
        testApplication2.Opp_Import_Id__c = testOpportunity.Id;
        Database.update(testApplication2);
        
        System.assert(testApplication.size() >0 , 'Test Lending Applications created assert'); 
        Opportunity_Payment__c oppPayment = new Opportunity_Payment__c();
        oppPayment.Opportunity_Name__c = oppList[0].id;
        oppPayment.Lending_Application_Number__c = testApplication2.id;
        oppPayment.Transaction_Status__c = 'In Progress';
        insert oppPayment;
        
        
        //
        //create primary customer
        //
        List<fsCore__Lending_Application_Customer__c> testPrimaryCustomer = new List<fsCore__Lending_Application_Customer__c>();
        fsCore__Lending_Application_Customer__c testPrimaryCustomer1= fsCore.TestHelperLendingApplication.getTestCustomer(testApplication[0]
                                                                                                                          , testAccount.Id
                                                                                                                          , null
                                                                                                                          , fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
        testPrimaryCustomer.add(testPrimaryCustomer1);                                                                                                                                          
        insert testPrimaryCustomer;
        System.assert(testPrimaryCustomer.Size()>0, 'Test primary customers created assert'); 
        
    }
    
   
    
    @isTest
    public static void test1(){
        fsCore__Lending_Application__c app = [Select id from fsCore__Lending_Application__c limit 1];
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        dsStatus.dsfs__DocuSign_Envelope_ID__c = '066D6D6B-41ED-49DC-B12A-6870E04B7617';
        //dsStatus.Document_Type__c = pDocumentType;
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        dsStatus.Lending_Application_Name__c = app.id;
        insert dsStatus;
        List<dsfs__DocuSign_Status__c> docuSignList = new List<dsfs__DocuSign_Status__c>{dsStatus};
              Set<Id> lendingApplicationIds = new Set<Id>();
        for(dsfs__DocuSign_Status__c docuSignStatus:docuSignList ){
            if (docuSignStatus.Lending_Application_Name__c != null){
                lendingApplicationIds.add(docuSignStatus.Lending_Application_Name__c);
            }
        }    
        
        test.startTest();
        ValidateStageAndMoveNextStageQueueable queueableObj = new ValidateStageAndMoveNextStageQueueable(lendingApplicationIds);
        ID jobID = System.enqueueJob(queueableObj);
        test.stopTest();
        
    }
    
     
    @isTest
    public static void test2(){
        fsCore__Lending_Application__c app = [Select id , fsCore__Is_Current_Stage_Validated__c from fsCore__Lending_Application__c limit 1];
        app.fsCore__Is_Current_Stage_Validated__c = false;
        update app;
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        dsStatus.dsfs__DocuSign_Envelope_ID__c = '066D6D6B-41ED-49DC-B12A-6870E04B7617';
        //dsStatus.Document_Type__c = pDocumentType;
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        dsStatus.Lending_Application_Name__c = app.id;
        insert dsStatus;
        List<dsfs__DocuSign_Status__c> docuSignList = new List<dsfs__DocuSign_Status__c>{dsStatus};
                Set<Id> lendingApplicationIds = new Set<Id>();
        for(dsfs__DocuSign_Status__c docuSignStatus:docuSignList ){
            if (docuSignStatus.Lending_Application_Name__c != null){
                lendingApplicationIds.add(docuSignStatus.Lending_Application_Name__c);
            }
        }    
                
        test.startTest();
        ValidateStageAndMoveNextStageQueueable queueableObj = new ValidateStageAndMoveNextStageQueueable(lendingApplicationIds);
        ID jobID = System.enqueueJob(queueableObj);
        test.stopTest();
        
    }

}