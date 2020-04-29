/**
 * @File Name          : ProgramHandler_Test.cls
 * @Description        : 
 * @Author             : fsDev
 * @Group              : 
 * @Last Modified By   : fsDev
 * @Last Modified On   : 4/24/2020, 12:35:03 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/24/2020   fsDev     Initial Version
**/
@isTest
public class ProgramHandler_Test {

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
    
        List<Account> accClientList = [SELECT Id,name, phone FROM Account];
        
        nu_dse__Program__c programInstance1 = new nu_dse__Program__c();
        programInstance1.nu_dse__Account__c = accClientList[1].Id;
        programInstance1.nu_dse__Last_Disposition__c = '121233';
        
        Test.startTest();
        Insert programInstance1;
        Test.stopTest();
        
        List<nu_dse__Program__c> prgmList = [SELECT id FROM nu_dse__Program__c];
        
        system.assertEquals(1,prgmList.size());
        
        nu_dse__Program__c programInstance2 = new nu_dse__Program__c();
        programInstance2.Id = programInstance1.Id;
        programInstance2.nu_dse__Last_Disposition__c = '123';
        
        Update programInstance2;
        
        List<nu_dse__Program__c> prgmUpdateList = [SELECT id, name, nu_dse__Last_Disposition__c FROM nu_dse__Program__c];
        
        system.assertEquals('123',prgmUpdateList[0].nu_dse__Last_Disposition__c);
    }
    
    @isTest
    static void invalidFieldMappingTest() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance3.nu_dse__Default_Value__c = '';
        fieldMappingInstance3.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance3.nu_dse__Target_Field__c = 'AccountNumber';
        fieldMappingInstance3.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance3);
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = '';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__CIP_Status__c';
        fieldMappingInstance4.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance4);
        
        Insert fieldMappingList;
    
        List<Account> accClientList = [SELECT Id,name, phone FROM Account];
        
        nu_dse__Program__c programInstance1 = new nu_dse__Program__c();
        programInstance1.nu_dse__Account__c = accClientList[1].Id;
        programInstance1.nu_dse__Last_Disposition__c = '121233';
        
        Test.startTest();
        insert programInstance1;
        Test.stopTest();
        
        List<nu_dse__Field_mapping__c> fieldMappingList1 = [SELECT id, nu_dse__Data_Mapping__c, nu_dse__Source_Field__c, 
                                                            nu_dse__Target_Field__c FROM nu_dse__Field_mapping__c];
        
        system.assertEquals(null,fieldMappingList1[3].nu_dse__Source_Field__c);
    }
    
    @isTest
    static void resultSuccessTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance4.nu_dse__Target_Field__c = 'Sic';
        fieldMappingInstance4.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance4.nu_dse__Default_Value__c = 'qwertyuioplkjhgfdsazxcljhktkgjhvbnmkjgfrtyujhgfytyuuy';
        
        insert fieldMappingInstance4;
        
        List<Account> accClientList = [SELECT Id,name, phone FROM Account];
        
        nu_dse__Program__c programInstance1 = new nu_dse__Program__c();
        programInstance1.nu_dse__Account__c = accClientList[1].Id;
        programInstance1.nu_dse__Last_Disposition__c = '121233';
        
        Test.startTest();
        insert programInstance1;
        Test.stopTest();
        
        List<nu_dse__Program__c> prgmUpdateList = [SELECT id, name, nu_dse__Last_Disposition__c FROM nu_dse__Program__c];
        
        system.assertEquals('121233',prgmUpdateList[0].nu_dse__Last_Disposition__c);
        
     }
     
     @isTest
     static void exceptionTesting() {
     
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance5.nu_dse__Source_Field__c = 'nu_dse__Last_Disposition__c';
        fieldMappingInstance5.nu_dse__Target_Field__c = 'NumberOfEmployees';
        
        insert fieldMappingInstance5;
        
        List<Account> accClientList = [SELECT Id,name, phone FROM Account];
        
        nu_dse__Program__c programInstance1 = new nu_dse__Program__c();
        programInstance1.nu_dse__Account__c = accClientList[1].Id;
        programInstance1.nu_dse__Last_Disposition__c = '12123';
        
        Test.startTest();
        insert programInstance1;
        Test.stopTest();
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT id FROM nu_dse__Error_Log__c];
        
        //system.assertEquals(2,errorLogList.size());
    }

}