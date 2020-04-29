@isTest
public class TestUpdateLendingApplicationService {
    @isTest
    public Static void TestSetApplicationFinalSettlementReachedTest() {
        TestHelperData.createTriggerExecutionTestData();
        
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = new nu_dse__Data_Mapping__c();
        dataMappingInstance1.Name = 'PrizmOutboundPaymentToNuDebtPayment';
        dataMappingInstance1.nu_dse__Source_sObject__c = 'fsCore__Outbound_Payment__c';
        dataMappingInstance1.nu_dse__Target_sObject__c = 'nu_dse__Payment__c';
        dataMappingList.add(dataMappingInstance1);
        
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'fsCore__Payment_Amount__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'nu_dse__Amount__c';
        fieldMappingList.add(fieldMappingInstance1);
        
        insert fieldMappingList;
        
        List<Account> accList = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 1';
        accInstance1.Phone = '(321) 654-1';
        accInstance1.nu_dse__External_RAMS_ID__c = '12345';
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        accList.add(accInstance1);
        
        insert accList;
        
        List<fsCore__Product_Setup__c> productList = new List<fsCore__Product_Setup__c>();
        
        fsCore__Product_Setup__c productInstance = new fsCore__Product_Setup__c();
        productInstance.Name = 'product';
        productInstance.fsCore__Product_Code__c = 'VCL';
        productInstance.fsCore__Product_Family__c = 'Loan';
        productInstance.Box_Folder_Root_Id__c = '12345';
        productInstance.fsCore__Start_Date__c = date.newInstance(2017,06,01);
        productInstance.fsCore__End_Date__c = date.newInstance(2999,12,31);
        productInstance.fsCore__Default_Company_Availability__c = 'Not Available';
        productInstance.fsCore__Default_Selection_Rule_Result__c = 'Available';
        productInstance.fsCore__Selection_Order__c = 1;
        productInstance.fsCore__Billing_Cycle__c = 'Monthly';
        productInstance.fsCore__Credit_Bureau_Portfolio_Type__c = 'Installment (I)'; 
        productInstance.fsCore__Default_Disbursement_Party_Type__c = 'Third Party';
        productInstance.fsCore__Title_Format__c = 'Primary~Secondary';
        productInstance.fsCore__Customer_Type__c = 'Person Account';        
        productInstance.fsCore__Customer_Name_Format__c = 'Contact Only';
        productInstance.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        productInstance.fsServ__Active_Contract_Record_Type__c = 'VCL_Contract';        

        
        productList.add(productInstance);
        
        insert productList;
        
        List<fsCore__Company_Setup__c> companySetupList = new List<fsCore__Company_Setup__c>();
        
        fsCore__Company_Setup__c companySetupInstance = new fsCore__Company_Setup__c();
        companySetupInstance.Name = 'Peerform';
        companySetupInstance.fsCore__Company_Code__c = 'PFM';
        companySetupList.add(companySetupInstance);
        
        insert companySetupList;
        
        List<BusinessHours> bhs = [select id, name from BusinessHours WHERE name='Versara Business Hours'];
        
        system.debug('bhs:::'+bhs);
        
        List<fsCore__Branch_Setup__c> branchList = new List<fsCore__Branch_Setup__c>();
        
        fsCore__Branch_Setup__c branchInstance = new fsCore__Branch_Setup__c();
        
        branchInstance.Name = 'branch';
        branchInstance.fsCore__Branch_Code__c = 'HQB';
        branchInstance.fsCore__Company_Name__c = companySetupInstance.Id;
        branchInstance.fsCore__Business_Hours_Name__c = bhs[0].Id;
        branchList.add(branchInstance);
        
        insert branchList;
        
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
                                                                                ('Test Contract Template'
                                                                               , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                               , testPaymentAlloc.Id
                                                                               , 1);
        insert testContractTemplate; 
              
        fsCore__Lending_Application__c testApp = fsCore.TestHelperLendingApplication.getTestApplication(companySetupList[0]
                                                                               , branchList[0]
                                                                               , productList[0]
                                                                               , 'Test Appp');
        testApp.fsCore__Is_Funding_In_Tranches_Allowed__c = true;
        testApp.fsCore__Is_Payment_Cycle_Flexible__c = false;
        testApp.fsCore__Is_Secured__c = true;
        testApp.fsCore__Is_Syndication_Allowed__c = false;
        testApp.fsCore__Application_Date__c = system.today();
        testApp.Is_Funding_Approved__c = true;
        testApp.Payment_Processor_Name__c = 'GCS';
        insert testApp;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        String JsonMsg=JSON.serialize(new Set<String>{testApp.Id});
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            updateLendingApplicationService.setApplicationFinalSettlementReached();
        Test.stopTest();
    }
}