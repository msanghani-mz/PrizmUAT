@isTest
public class Batch_UpdateProgramProcessorStatus_Test {

    @TestSetup
    public static void setup() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = new nu_dse__Data_Mapping__c();
        dataMappingInstance1.Name = 'NuDebtProgramToPrizmAccount';
        dataMappingInstance1.nu_dse__Source_sObject__c = 'Program';
        dataMappingInstance1.nu_dse__Target_sObject__c = 'Account';
        dataMappingList.add(dataMappingInstance1);
        
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'nu_dse__Last_Disposition__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'nu_dse__Auth_RAMS_Id__c';
        fieldMappingList.add(fieldMappingInstance1);
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance2.nu_dse__Default_Value__c = 'nu_dse__CFT_Rule_Set_Id__c';
        fieldMappingInstance2.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance2.nu_dse__Target_Field__c = 'AccountNumber';
        fieldMappingList.add(fieldMappingInstance2);
        
        insert fieldMappingList;
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 1';
        accInstance1.Phone = '(321) 654-1';
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        
        insert accInstance1;

        nu_dse__Program__c programInstance1 = new nu_dse__Program__c();
        programInstance1.nu_dse__Account__c = accInstance1.Id;
        programInstance1.nu_dse__Last_Disposition__c = '121233';        

        insert programInstance1;
        
        Account accInstance2 = new Account();
        accInstance2.LastName = 'test 2';
        accInstance2.Phone = '(321) 654-0003';
        accInstance2.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        accInstance2.Prizm_External_Id__c = accInstance1.Id;
        
        Test.startTest();
        insert accInstance2;
        Test.stopTest();
    }

    @isTest
    static void updatingProgram() {

        List<nu_dse__Program__c> nuDseProgram = [SELECT Id, Name FROM nu_dse__Program__c];

        Set<Id> programIdSet =  new Set<Id>();
        programIdSet.add(nuDseProgram.get(0).id);

        Test.StartTest();
        Batch_UpdateProgramProcessorStatus  myBatchObject = new Batch_UpdateProgramProcessorStatus(programIdSet); 
        Id batchId = Database.executeBatch(myBatchObject,100);
        Test.StopTest();

    }    

}