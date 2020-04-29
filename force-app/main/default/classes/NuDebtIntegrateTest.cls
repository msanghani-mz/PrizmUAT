/**
 * @File Name          : NuDebtIntegrateTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/28/2019, 11:17:11 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/28/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class NuDebtIntegrateTest {
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
        set<id> prgmIds = new set<id>();
        MAP<ID,ID> programIdToOppMap = new Map <ID,ID>();
        for(nu_dse__Program__c pId: [select id from nu_dse__Program__c]){
        prgmIds.add(pId.id);
        programIdToOppMap.put(pId.id,pId.id);
        } 
        Test.startTest();
        NuDebtIntegrate.updateDNLStatusNotInterested(prgmIds,programIdToOppMap);
        Test.stopTest();

        
    }
}