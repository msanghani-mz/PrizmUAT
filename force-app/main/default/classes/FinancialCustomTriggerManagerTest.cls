@isTest
public class FinancialCustomTriggerManagerTest {
    @testSetup
    private static void createTestData(){
        Account acc = new Account();
        acc.Name='Alex Smith';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='Smith';
        con.FirstNAme='Alex';
        con.AccountId=acc.id;
        insert con; 
        
        fsCore__Trigger_Execution_Settings__c trigExecutionSettings = new fsCore__Trigger_Execution_Settings__c();
        trigExecutionSettings.fsCore__Custom_Trigger_Manager_Class__c = 'FinancialCustomTriggerManager';
        trigExecutionSettings.fsCore__Number_Of_Trigger_Executions__c = 1;
        trigExecutionSettings.name = 'FinancialTrigger';
        
        Insert trigExecutionSettings;
        
    }
    
    @isTest
    private static void testFinancialCustomTrigger(){
        Account acc=[Select Id from Account Where Name='Alex Smith'];
        Contact con=[Select Id from Contact Where AccountId =:acc.id];
        Test.startTest();
        fsCore__Financial__c financial = new fsCore__Financial__c();
        financial.fsCore__Account_Name__c=acc.id;
        financial.fsCore__Contact_Name__c=con.id;
        financial.fsCore__Financial_Family__c='Income';
        financial.fsCore__Frequency__c='Annual';
        financial.fsCore__Financial_Type__c='Investment';
        financial.Is_Primary_Income__c= true;
        financial.fsCore__Is_Active__c=true;
        insert financial;
        Test.stopTest();
        System.assert(financial.id != null,'Financial inserted');
        
    }
    
    @isTest
    private static void testFinancialCustomTrigger_Neg(){
        Account acc=[Select Id from Account Where Name='Alex Smith'];
        Contact con=[Select Id from Contact Where AccountId =: acc.id];
        
        fsCore__Financial__c financial = new fsCore__Financial__c();
        fsCore__Financial__c financial1 = new fsCore__Financial__c();
        
        Test.startTest();
        Boolean exceptionFlag = false;
        try{
            
            List<fsCore__Financial__c> financialList= new List<fsCore__Financial__c>();
            
            financial.fsCore__Account_Name__c=acc.id;
            financial.fsCore__Contact_Name__c=con.id;
            financial.fsCore__Financial_Family__c='Income';
            financial.fsCore__Frequency__c='Annual';
            financial.fsCore__Financial_Type__c='Investment';
            financial.Is_Primary_Income__c= true;
            financial.fsCore__Is_Active__c=true;
            financialList.add(financial);
            
            
            
            financial1.fsCore__Account_Name__c=acc.id;
            financial1.fsCore__Contact_Name__c=con.id;
            financial1.fsCore__Financial_Family__c='Income';
            financial1.fsCore__Frequency__c='Annual';
            financial1.fsCore__Financial_Type__c='Disability';
            financial1.Is_Primary_Income__c= true;
            financial1.fsCore__Is_Active__c=true;
            financialList.add(financial1);
            
            insert financialList;
            
        }catch(Exception ex){
            exceptionFlag = true;
        }
        Test.stopTest();
        System.assert(exceptionFlag==true);   
        System.assert(financial.id==null);
        System.assert(financial1.id==null);
        
    }
}