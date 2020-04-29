@isTest
private class ContractTriggerHandlerTest {
    @TestSetup
    static void setUp() {
        
        TestHelperData.createTriggerExecutionTestData();
		List<nu_dse__Fee_Template__c> feeTemplates = new List<nu_dse__Fee_Template__c>();
		
        nu_dse__Fee_Template__c feeTemplate1 = new nu_dse__Fee_Template__c();
        feeTemplate1.Name = 'RAM Versara - WLoC1';
        feeTemplate1.nu_dse__RAMS_Fee_Group_Id__c = '1231';
        feeTemplates.add(feeTemplate1);
        
        nu_dse__Fee_Template__c feeTemplate2 = new nu_dse__Fee_Template__c();
        feeTemplate2.Name = 'GCS Versara - Timberline - WLoC1';
        feeTemplate2.nu_dse__RAMS_Fee_Group_Id__c = '11111';
        feeTemplates.add(feeTemplate2);
        
        nu_dse__Fee_Template__c feeTemplate3 = new nu_dse__Fee_Template__c();
        feeTemplate3.Name = 'GCS Versara - WLoC1';
        feeTemplate3.nu_dse__RAMS_Fee_Group_Id__c = '22111';
        feeTemplates.add(feeTemplate3);
        
        insert feeTemplates;
        
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
        system.debug('++++++++testApp+++++'+testApp);
        List<fsServ__Lending_Contract__c> lendingContractList = new List<fsServ__Lending_Contract__c>();
        
        fsServ__Lending_Contract__c lendingContractInstance = new fsServ__Lending_Contract__c();
        lendingContractInstance.fsServ__Product_Name__c = productInstance.Id;
        lendingContractInstance.fsServ__Title__c = 'Sean';
        lendingContractInstance.recordTypeId = Schema.SObjectType.fsServ__Lending_Contract__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
        lendingContractInstance.fsServ__Product_Family__c = 'Loan';
        lendingContractInstance.fsServ__Lending_Application_Number__c = testApp.Id;
        lendingContractInstance.fsServ__Branch_Name__c = branchInstance.Id;
        lendingContractInstance.fsServ__Company_Name__c = companySetupInstance.Id;
        lendingContractInstance.fsServ__Contract_Status__c = 'Pending';
        lendingContractInstance.fsServ__Primary_Customer_Account__c = accList[0].Id;
        lendingContractInstance.fsServ__Financed_Amount__c = 100;
        lendingContractList.add(lendingContractInstance);
        
        insert lendingContractList;
        
        List<Account> accQueryList = [SELECT id,LastName,Prizm_External_Id__c  FROM Account];
        
        List<Account> accList1 = new List<Account>();
        
        Account accInstance2 = new Account();
        accInstance2.LastName = 'test 2';
        accInstance2.Prizm_External_Id__c = accQueryList[0].Id;
        accInstance2.Phone = '(321) 654-2';
        accInstance2.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        accList1.add(accInstance2);
        
        insert accList1;
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
        
        nu_dse__Program__c prgmInstance1 = new nu_dse__Program__c();
        prgmInstance1.nu_dse__Account__c = accList[0].Id;
        programList.add(prgmInstance1);
        
        insert programList;
        
 
       

    }

    @isTest
    private static void testWithGCSProcessor(){
    	 fsServ__Lending_Contract__c lendingContract = [Select Id, name, Investor_Name__c from fsServ__Lending_Contract__c limit 1];
        system.debug('+++++sss++++'+lendingContract);
        lendingContract.Investor_Name__c = 'Versara DNL WLoC';
        update lendingContract; 
    } 
}