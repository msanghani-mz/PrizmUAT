/**
 * @File Name          : InboundPaymentHandler_Test.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : fsDev
 * @Last Modified On   : 4/23/2020, 8:22:02 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/16/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class InboundPaymentHandler_Test {

    @TestSetup
    public static void setup() {
        
        TestHelperData.createTriggerExecutionTestData();
        
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = new nu_dse__Data_Mapping__c();
        dataMappingInstance1.Name = 'PrizmPaymentToNuDebtPayment';
        dataMappingInstance1.nu_dse__Source_sObject__c = 'fsServ__Inbound_Payment__c';
        dataMappingInstance1.nu_dse__Target_sObject__c = 'nu_dse__Payment__c';
        dataMappingList.add(dataMappingInstance1);
        
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'fsServ__Payment_Amount__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'nu_dse__Amount__c';
        fieldMappingList.add(fieldMappingInstance1);
        
        insert fieldMappingList;
        
        List<Account> accList = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 1';
        accInstance1.Phone = '(321) 654-1';
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        accList.add(accInstance1);
        
        insert accList;
        
        List<fsCore__Product_Setup__c> productList = new List<fsCore__Product_Setup__c>();
        
        fsCore__Product_Setup__c productInstance = new fsCore__Product_Setup__c();
        productInstance.Name = 'product';
        productInstance.fsCore__Product_Code__c = 'DNL';
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
        productInstance.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        productInstance.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        

        
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
        
        List<fsServ__Lending_Contract__c> lendingContractList = new List<fsServ__Lending_Contract__c>();
        
        fsServ__Lending_Contract__c lendingContractInstance = new fsServ__Lending_Contract__c();
        lendingContractInstance.fsServ__Product_Name__c = productInstance.Id;
        lendingContractInstance.fsServ__Title__c = 'Sean';
        lendingContractInstance.recordTypeId = Schema.SObjectType.fsServ__Lending_Contract__c.getRecordTypeInfosByName().get('Inactive').getRecordTypeId();
        lendingContractInstance.fsServ__Product_Family__c = 'Loan';
        //lendingContractInstance.fsServ__Reschedule_Impact_Method__c = 'Balloon Amount';
        lendingContractInstance.fsServ__Branch_Name__c = branchInstance.Id;
        lendingContractInstance.fsServ__Company_Name__c = companySetupInstance.Id;
        lendingContractInstance.fsServ__Contract_Status__c = 'Pending';
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
        
        nu_dse__Program__c prgmInstance = new nu_dse__Program__c();
        prgmInstance.nu_dse__Account__c = accInstance2.Id;
        
        insert prgmInstance;
    
        List<fsServ__Lending_Contract__c> lendingContractList1 = [SELECT id FROM fsServ__Lending_Contract__c];
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList = new List<fsServ__Inbound_Payment__c>();
        
        fsServ__Inbound_Payment__c inboundInstance = new fsServ__Inbound_Payment__c();
        inboundInstance.fsServ__Payment_Date__c = date.newInstance(2018,09,22);
        inboundInstance.fsServ__Payment_Mode__c = 'Cash';
        inboundInstance.fsServ__Payment_Amount__c = 100;
        inboundInstance.fsServ__Payment_Status__c = 'Draft';
        inboundInstance.NuPay_Transaction_Status__c = 'Tentative'; 
        inboundInstance.fsServ__Account_Name__c = accQueryList[0].Id;
        inboundInstance.fsServ__Lending_Contract_Number__c = lendingContractList1[0].Id;
        inboundPaymentList.add(inboundInstance);
        

        Test.startTest();
        insert inboundPaymentList;
        Test.stopTest();
    }
     @isTest
    static void inboundPaymntToPendingQueueable(){
        List<fsServ__Inbound_Payment__c> inboundPaymentList = [select id
                                                                        , NuPay_Transaction_Status__c 
                                                                     FROM fsServ__Inbound_Payment__c 
                                                                      where fsServ__Payment_Mode__c = 'ACH'
                                                                      AND NuPay_Transaction_Status__c = 'Tentative'
                                                                      AND fsServ__Is_Processed__c  = false];
        Set<Id> iPaymentIds = new Set<Id>();
        for(fsServ__Inbound_Payment__c iPayment : inboundPaymentList){
            iPaymentIds.add(iPayment.id);
        } 
 
        test.startTest();
        InboundPaymentToPendingQueueable queueableObj = new InboundPaymentToPendingQueueable(iPaymentIds);
        ID jobID = System.enqueueJob(queueableObj);
        queueableObj.errors('dummy','dummy');
        test.stopTest();
        
    }
    @isTest
    static void updateInBoundPayment() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance2.nu_dse__Default_Value__c = 'In Progress';
        fieldMappingInstance2.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance2.nu_dse__Target_Field__c = 'nu_dse__Transaction_Status__c';
        fieldMappingList.add(fieldMappingInstance2);
       
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance5.nu_dse__Default_Value__c = 'asfdascascSACZCAScASCSZXSfcAdgxbhsfhf';
        fieldMappingInstance5.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance5.nu_dse__Target_Field__c = 'nu_dse__Settlement_Id__c';
        fieldMappingList.add(fieldMappingInstance5);
       
        insert fieldMappingList;
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList = [SELECT id FROM fsServ__Inbound_Payment__c];
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList1 = new List<fsServ__Inbound_Payment__c>();
        
        fsServ__Inbound_Payment__c inboundInstance1 = new fsServ__Inbound_Payment__c();
        inboundInstance1.Id = inboundPaymentList[0].Id;
        inboundInstance1.fsServ__Payment_Amount__c = 105;
        inboundInstance1.NuPay_Transaction_Status__c = 'Pending';   
        inboundPaymentList1.add(inboundInstance1);
        
        Test.startTest();
        update inboundPaymentList1;
        Test.stopTest();
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList2 = [SELECT id,fsServ__Payment_Amount__c FROM fsServ__Inbound_Payment__c];
        
        system.assertEquals(105,inboundPaymentList2[0].fsServ__Payment_Amount__c);
    }
    
    @isTest 
    static void invalidFieldMapping() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance3.nu_dse__Default_Value__c = '';
        fieldMappingInstance3.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance3.nu_dse__Target_Field__c = 'nu_dse__Transaction_Status__c';
        fieldMappingInstance3.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance3);

        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'fsServ__Business_Date__c';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__Schedule_Date__c';
        fieldMappingInstance4.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance4);
        
        insert fieldMappingList;
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList = [SELECT id FROM fsServ__Inbound_Payment__c];
        
        fsServ__Inbound_Payment__c inboundInstance1 = new fsServ__Inbound_Payment__c();
        inboundInstance1.Id = inboundPaymentList[0].Id;
        inboundInstance1.fsServ__Payment_Amount__c = 105;
        
        Test.startTest();
        update inboundInstance1;
        Test.stopTest();
        
        List<nu_dse__Field_mapping__c> fieldMappingList1 = [SELECT id, nu_dse__Data_Mapping__c, nu_dse__Source_Field__c, 
                                                            nu_dse__Target_Field__c, nu_dse__Default_Value__c
                                                             FROM nu_dse__Field_mapping__c];
        
        system.assertEquals(null,fieldMappingList1[1].nu_dse__Default_Value__c);
    }
    
    @isTest
    static void resultSuccessTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        nu_dse__Field_mapping__c fieldMappingInstance6 = new nu_dse__Field_mapping__c();
        fieldMappingInstance6.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance6.nu_dse__Default_Value__c = '123214';
        fieldMappingInstance6.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance6.nu_dse__Target_Field__c = 'nu_dse__Payment_Sequence_Number__c';
        
        insert fieldMappingInstance6;
        
        List<fsServ__Inbound_Payment__c> inboundPaymentList = [SELECT id FROM fsServ__Inbound_Payment__c];
        
        fsServ__Inbound_Payment__c inboundInstance1 = new fsServ__Inbound_Payment__c();
        inboundInstance1.Id = inboundPaymentList[0].Id;
        inboundInstance1.fsServ__Payment_Amount__c = 105;
        inboundInstance1.NuPay_Transaction_Status__c = 'Pending';   
        
        Test.startTest();
        update inboundInstance1;
        Test.stopTest();
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT id FROM nu_dse__Error_Log__c];

        //system.assertEquals(3,errorLogList.size());
    }
}