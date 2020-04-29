/**
 * @File Name          : LendingApplicationTrigHandlerTesting.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2/7/2020, 12:00:54 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/7/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class LendingApplicationTrigHandlerTesting {

  @testSetup
  static void createTestData()
  {
      try{
      TestHelperData.createTriggerExecutionTestData();

        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                              , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
        //create company and branch
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
        //create contract template (required for PricingOfferAcceptAction)
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;

        //create stage
        fsCore__Stage_Setup__c testStage1 = fsCore.TestHelperWorkflow.createTestStageWithValidationRules('Application Entry'
                                                                                        , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                        , fsCore.Constants.LOB_ORIGINATION
                                                                                        , 1);
        System.assert(testStage1.Id != null, 'Test stage 1 created assert');
        
        fsCore__Stage_Setup__c testStage2 = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                  , 2);
        testStage2.fsCore__Stage_Code__c ='DNL_DOC_PROCESSING';
        testStage2.fsCore__Line_Of_Business__c = 'Origination';
        testStage2.fsCore__Object_Name__c = 'fscore__lending_application__c';
        insert testStage2;
        System.assert(testStage2.Id != null, 'Test stage 2 created assert');


        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
                                                                                ('Test Contract Template'
                                                                               , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                               , testPaymentAlloc.Id
                                                                               , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        

        //
        //create pricing setup
        //
        fsCore__Pricing_Setup__c testPricing = fsCore.TestHelperProduct.getTestPricingSetup('Test Pricing'
                                                                            , fsCore.Constants.PRICING_METHOD_INTEREST_RATE
                                                                            , 4.00
                                                                            , 12
                                                                            , 1);
        testPricing.Is_Generate_Additional_Pricing__c = true;
        testPricing.Payment_Increase_For_Option_1__c = 10;
        testPricing.Payment_Increase_For_Option_2__c = 20;
        insert testPricing;
        System.assert(testPricing.Id != null, 'Test pricing created assert');        

        //Account and Contact for customer
        Account testAccount = fsCore.TestHelperSystem.getTestAccount('Stark Corporation');
        insert testAccount;
        System.assert(testAccount.Id != null, 'Test Account created assert');

        Contact testContact = fsCore.TestHelperSystem.getTestContact('Tony', 'Stark', testAccount.Id);
        insert testContact;
        System.assert(testContact.Id != null, 'Test Contact created assert');

        //
        //create Lending Application by populating company, branch, product
        //
        list<fsCore__Lending_Application__c> lstLendApp =new list<fsCore__Lending_Application__c>();
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApplication.fsCore__Primary_Customer_Contact__c = testContact.Id;
        
        lstLendApp.add(testApplication);
        insert lstLendApp;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

      }
      catch(Exception e)
     {
         system.debug('Exception:'+e+e.getLineNumber());
     }
      
  }
  @isTest
  private static void testApplicationDRPGraduated(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,CreatedById,Loan_Officer__c,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.fsCore__Application_Status__c = 'DRP Graduated';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].fsCore__Application_Status__c == 'DRP Graduated', 'Test Lending Application status assert');        
    
  }
  @isTest
  private static void testApplicationContactSalesRep(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,CreatedById,Loan_Officer__c,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.fsCore__Application_Status__c = 'Contact Loan Officer';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;

    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].fsCore__Application_Status__c == 'Contact Loan Officer', 'Test Lending Application status assert');        
    
  }
  @isTest
  private static void testApplicationDraftIncRequested(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,CreatedById,Loan_Officer__c,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.fsCore__Application_Status__c = 'Draft Increase Requested';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].fsCore__Application_Status__c == 'Draft Increase Requested', 'Test Lending Application status assert');        
    
  }
  /*@isTest
  private static void testApplicationNegReview(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,Loan_Officer__c,CreatedById,fsCore__Application_Status__c from fsCore__Lending_Application__c limit 1] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.fsCore__Application_Status__c = 'Negotiations Review';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].fsCore__Application_Status__c == 'Negotiations Review', 'Test Lending Application status assert');  
    nu_dse__Group_Task__c GTTask=[Select id,nu_dse__Subject__c,nu_dse__Description__c,nu_dse__Related_To__c,nu_dse__ActivityDate__c from nu_dse__Group_Task__c where nu_dse__Related_To__c=:testApp[0].Id AND nu_dse__Subject__c='DNL Review for Negotiations' limit 1];    
    system.assertEquals(GTTask.nu_dse__Subject__c,'DNL Review for Negotiations');
   
  }  */
  //PDI-736
  @isTest
  private static void testPrgStatusNSF(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,NuDebt_Program_Status__c,Loan_Officer__c,CreatedById,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.NuDebt_Program_Status__c = 'NSF';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].NuDebt_Program_Status__c == 'NSF', 'Test Lending Application status assert');        
    
  }  
    
  @isTest
  private static void testPrgStatusUnresponsiveNSF(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,NuDebt_Program_Status__c,Loan_Officer__c,CreatedById,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.NuDebt_Program_Status__c = 'UnResponsive NSF';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].NuDebt_Program_Status__c == 'UnResponsive NSF', 'Test Lending Application status assert');        
    
  }  
   
  @isTest
  private static void testPrgStatusPendingDRP(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,NuDebt_Program_Status__c,Loan_Officer__c,CreatedById,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.NuDebt_Program_Status__c = 'Pending DRP Cancellation';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].NuDebt_Program_Status__c == 'Pending DRP Cancellation', 'Test Lending Application status assert');        
    
  }  
  @isTest
  private static void testPrgStatusClientCancelled(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,NuDebt_Program_Status__c,Loan_Officer__c,CreatedById,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.NuDebt_Program_Status__c = 'Client Cancelled';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
    System.assert(testApp[0].NuDebt_Program_Status__c == 'Client Cancelled', 'Test Lending Application status assert');        
    
  }    
    
  @isTest
  private static void testApplicationDocPrpcessing(){
    List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,Loan_Officer__c,CreatedById,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;
    fsCore__Stage_Setup__c testStage = [select Id,name,fsCore__Line_Of_Business__c,fsCore__Object_Name__c from fsCore__Stage_Setup__c where fsCore__Stage_Code__c ='DNL_DOC_PROCESSING'] ;

    for (fsCore__Lending_Application__c lendingApp: testApp){
        lendingApp.fsCore__Current_Stage_Name__c = testStage.Id;
        lendingApp.fsCore__Application_Status__c = 'Draft Increase Requested';
        lendingApp.Loan_Type__c = 'DNL';
        lendingApp.Loan_Officer__c = lendingApp.CreatedById;
    }
    Test.startTest();
    update testApp;
    Test.stopTest();
  } 
  
}