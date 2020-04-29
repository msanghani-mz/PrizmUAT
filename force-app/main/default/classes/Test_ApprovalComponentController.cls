@isTest
public class Test_ApprovalComponentController {

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
        User u=[Select id,name from user where name='Cory Thomas'];
        testApplication.Loan_Officer__c=u.id;
        testApplication.name='DNL190823006788';
        testApplication.fsCore__Application_Received_Date__c=system.today()-4;
        testApplication.Internal_Rejection_Reasons__c='';
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApplication.fsCore__Primary_Customer_Contact__c = testContact.Id;
        testApplication.BoxFolderId__c='123456789';
        lstLendApp.add(testApplication);
        insert lstLendApp;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

      }
      catch(Exception e)
     {
         system.debug('Exception:'+e+e.getLineNumber());
     }
      
  }
    public static testmethod void ApprovalComp() 
    {
       List<fsCore__Lending_Application__c> testApp = [select Id,Loan_Type__c,Internal_Rejection_Reasons__c,BoxFolderId__c,CreatedById,Loan_Officer__c,fsCore__Application_Status__c from fsCore__Lending_Application__c] ;
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(testApp[0].id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Underwriter_Final_Approval');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        Map<Id,ProcessInstance> mapProcessInstance;
        
        mapProcessInstance=new Map<Id,ProcessInstance>([SELECT Id, (SELECT ID, ProcessNodeId,  
                                                                    StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                                    ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                                                    OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by CreatedDate DESC )   
                                                        FROM ProcessInstance where TargetObjectId =:testApp[0].id order by CreatedDate DESC]);
        try{
            test.startTest();
            LendingAppApprovalCompController.getApprovalData();
            Test.stopTest();
        }
        catch(exception e)
        {
          system.debug('Acc Msg:'+e.getMessage());  
        }
               
    }
}