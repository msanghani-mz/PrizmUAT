/**
 * @File Name          : PaymentHandler_Test.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : fsDev
 * @Last Modified On   : 4/24/2020, 12:35:15 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/28/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class PaymentHandler_Test {

    @TestSetup
    public static void setup() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = new nu_dse__Data_Mapping__c();
        dataMappingInstance1.Name = 'NuDebtPaymentToPrizmPayment';
        dataMappingInstance1.nu_dse__Source_sObject__c = 'nu_dse__Payment__c';
        dataMappingInstance1.nu_dse__Target_sObject__c = 'fsServ__Inbound_Payment__c';
        dataMappingList.add(dataMappingInstance1);
        
        insert dataMappingList;
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 1';
        accInstance1.Phone = '(321) 654-1';
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        
        insert accInstance1;
        
        
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
        productInstance.fsCore__Customer_Name_Format__c = 'Contact Only';
        productInstance.fsCore__Customer_Type__c = 'Person Account';
        productInstance.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        productInstance.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        

        
        insert productInstance;
        
        fsCore__Company_Setup__c companySetupInstance = new fsCore__Company_Setup__c();
        companySetupInstance.Name = 'Peerform';
        companySetupInstance.fsCore__Company_Code__c = 'PFM';
        
        insert companySetupInstance;
        
        //Queried Business Hours
        List<BusinessHours> bhs = [select id, name from BusinessHours WHERE name='Versara Business Hours'];
        system.debug('bhs:::'+bhs);
        
        //Insert Branch
        fsCore__Branch_Setup__c branchInstance = new fsCore__Branch_Setup__c();
        branchInstance.Name = 'branch';
        branchInstance.fsCore__Branch_Code__c = 'HQB';
        branchInstance.fsCore__Company_Name__c = companySetupInstance.Id;
        branchInstance.fsCore__Business_Hours_Name__c = bhs[0].Id;
        
        insert branchInstance;
        
        //Insert LendingContract
        fsServ__Lending_Contract__c lendingContractInstance = new fsServ__Lending_Contract__c();
        lendingContractInstance.fsServ__Product_Name__c = productInstance.Id;
        lendingContractInstance.fsServ__Title__c = 'Sean';
        //lendingContractInstance.fsServ__Reschedule_Impact_Method__c = 'Payment Amount';
        lendingContractInstance.fsServ__Branch_Name__c = branchInstance.Id;
        lendingContractInstance.fsServ__Company_Name__c = companySetupInstance.Id;
        lendingContractInstance.fsServ__Contract_Status__c = 'Pending';
        
        insert lendingContractInstance;
        
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'nu_dse__Amount__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'fsServ__Payment_Amount__c';
        fieldMappingList.add(fieldMappingInstance1);
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance2.nu_dse__Default_Value__c = lendingContractInstance.Id;
        fieldMappingInstance2.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance2.nu_dse__Target_Field__c = 'fsServ__Lending_Contract_Number__c';
        fieldMappingList.add(fieldMappingInstance2);
        
        insert fieldMappingList;
        
        List<Account> accQueryList = [SELECT id FROM Account];
        
        Account accInstance2 = new Account();
        accInstance2.LastName = 'test 2';
        accInstance2.Prizm_External_Id__c = accQueryList[0].Id;
        accInstance2.Phone = '(321) 654-2';
        accInstance2.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        Test.startTest();
        insert accInstance2;
        Test.stopTest();
        
        nu_dse__Program__c prgmInstance = new nu_dse__Program__c();
        prgmInstance.nu_dse__Account__c = accInstance2.Id;
        
        insert prgmInstance;        
    }
    
    @isTest
    static void updatePayment() {
    
        List<nu_dse__Program__c> prgm = [SELECT id FROM nu_dse__Program__c];
    
        nu_dse__Payment__c paymentInstance = new nu_dse__Payment__c();
        paymentInstance.nu_dse__Program__c = prgm[0].Id;
        paymentInstance.nu_dse__Amount__c = 100;
        
        Test.startTest();
        insert paymentInstance;
        Test.stopTest();
        
        List<nu_dse__Payment__c> paymentList1 = [SELECT id FROM nu_dse__Payment__c];
        
        nu_dse__Payment__c paymentInstance2 = new nu_dse__Payment__c();
        paymentInstance2.Id = paymentInstance.Id;
        paymentInstance2.nu_dse__Program__c = prgm[0].Id;
        paymentInstance.nu_dse__Amount__c = 105;
        
        update paymentInstance2;
        
        List<nu_dse__Payment__c> paymentList2 = [SELECT id, nu_dse__Amount__c FROM nu_dse__Payment__c];
        
        System.assertEquals(100,paymentList2[0].nu_dse__Amount__c);
    }
    
    /*@isTest
    static void invalidFieldMapping() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
    
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance3.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance3.nu_dse__Default_Value__c = '';
        fieldMappingInstance3.nu_dse__Is_Required__c = TRUE;
        fieldMappingInstance3.nu_dse__Target_Field__c = 'fsServ__Payment_Amount__c';
        fieldMappingList.add(fieldMappingInstance3);
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'nu_dse__Schedule_Date__c';
        fieldMappingInstance4.nu_dse__Is_Required__c = TRUE;
        fieldMappingInstance4.nu_dse__Target_Field__c = 'fsServ__Business_Date__c';
        fieldMappingList.add(fieldMappingInstance4);
        
        insert fieldMappingList;
        
        List<nu_dse__Program__c> prgm = [SELECT id FROM nu_dse__Program__c];
    
        nu_dse__Payment__c paymentInstance = new nu_dse__Payment__c();
        paymentInstance.nu_dse__Program__c = prgm[0].Id;
        
        Test.startTest();
        insert paymentInstance;
        Test.stopTest();
        
        List<nu_dse__Field_mapping__c> fieldMappingList1 = [SELECT id, nu_dse__Data_Mapping__c, nu_dse__Source_Field__c, 
                                                            nu_dse__Target_Field__c, nu_dse__Default_Value__c
                                                            FROM nu_dse__Field_mapping__c];
        
        //system.assertEquals(null,fieldMappingList1[2].nu_dse__Default_Value__c);
    }*/
    
    @isTest
    static void resultSuccessTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
    
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance6 = new nu_dse__Field_mapping__c();
        fieldMappingInstance6.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance6.nu_dse__Default_Value__c = 'asfdaAdasdasdsasadssdasdaaSXZCSDcSCSACZscassdgdfggdfgddfgadggdfgdfgdgdfgdgjgjgjdfhfghfhfgdfgfddddddad';
        fieldMappingInstance6.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance6.nu_dse__Target_Field__c = 'fsServ__Reference__c';
        fieldMappingList.add(fieldMappingInstance6);
        
        insert fieldMappingList;
        
        List<nu_dse__Program__c> prgm = [SELECT id FROM nu_dse__Program__c];
    
        nu_dse__Payment__c paymentInstance = new nu_dse__Payment__c();
        paymentInstance.nu_dse__Program__c = prgm[0].Id;
        paymentInstance.nu_dse__Amount__c = 102;
        
        Test.startTest();
        insert paymentInstance;
        Test.stopTest();
        
        List<nu_dse__Payment__c> paymentList2 = [SELECT id, nu_dse__Amount__c FROM nu_dse__Payment__c];
        
        System.assertEquals(102,paymentList2[0].nu_dse__Amount__c);
        
        paymentList2[0].nu_dse__Transaction_Status__c = 'Completed';
        update paymentList2;
        
        List<nu_dse__Payment__c> paymentList3 = [SELECT id, nu_dse__Amount__c FROM nu_dse__Payment__c];
        //System.assertEquals(2,paymentList3.size());
   }
    
    @isTest
    static void exceptionTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
    
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'nu_dse__RAMS_Synced__c';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'fsServ__Business_Date__c';
        
        insert fieldMappingInstance4;
        
        List<nu_dse__Program__c> prgm = [SELECT id FROM nu_dse__Program__c];
    
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c paymentInstance = new nu_dse__Payment__c();
        paymentInstance.nu_dse__Program__c = prgm[0].Id;
        paymentInstance.nu_dse__Amount__c = 102;
        paymentList.add(paymentInstance);
        
        Test.startTest();
        insert paymentList;
        Test.stopTest();
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT id FROM nu_dse__Error_Log__c];
        
        //system.assertEquals(3,errorLogList.size());
    }
}