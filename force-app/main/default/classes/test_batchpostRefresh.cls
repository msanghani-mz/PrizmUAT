@isTest
public class test_batchpostRefresh {
public static testmethod void Test_Batch_Account() 
    {
       //Test Account object  //PersonEmail='tryry@gmail.com',phone='4444444',
        Account a=new Account(name='Acc1',SSN__c='7777777',Transunion_SSN__c='8888',nu_dse__SSN__c='23232',nu_dse__Co_SSN__c='777',nu_dse__Home_Phone__c='99999676',nu_dse__External_GCS_ID__c='DSE11111111111111',
                             fsCore__Email__c='san@gmail.com',nu_dse__CO_Email_Address__c='mht@gmail.com',nu_dse__External_CFT_ID__c='EXT3232323245BB12',nu_dse__External_RAMS_ID__c='RAMSp900065324E');
        insert a;
       try{
            test.startTest();
            //string query='Select id,Name,SSN__c,Transunion_SSN__c,nu_dse__SSN__c,nu_dse__Co_SSN__c,nu_dse__Home_Phone__c,fsCore__Email__c,nu_dse__CO_Email_Address__c,nu_dse__External_GCS_ID__c,nu_dse__External_CFT_ID__c,nu_dse__External_RAMS_ID__c from Account';
            Batch_pstRefresh_Account b=new Batch_pstRefresh_Account(True);//,query
            database.executeBatch(b);  
            Test.stopTest();
        }
        catch(exception e)
        {
          system.debug('Acc Msg:'+e.getMessage());  
        }
               
    }
    
    public static testmethod void Test_Batch_BankAccount() 
    {
      //  List<nu_dse__Program__c> nuDseProgramList  = [SELECT Id FROM nu_dse__Program__c];
        
        //List<nu_dse__Bank_Account__c> nuDseBankAccList = new List<nu_dse__Bank_Account__c>(); 
        nu_dse__Bank_Account__c nuDseBankAccInstance = new nu_dse__Bank_Account__c();
        nuDseBankAccInstance.nu_dse__Bank_Account_Number__c = '1234';
        nuDseBankAccInstance.nu_dse__Holder_s_Name__c = 'XX';
        nuDseBankAccInstance.nu_dse__Routing_Number__c = '1197';
        //nuDseBankAccInstance.nu_dse__Program__c = nuDseProgramList[0].Id;
        insert nuDseBankAccInstance;
       //fsCore__Bank_Account__c ba=new fsCore__Bank_Account__c(fsCore__Bank_Account_Number__c='5645464536',fsCore__Bank_Account_Holder_Name__c='XYC',fsCore__Bank_Identification_Code__c='765');
        //insert ba;
       try{
            Test.startTest();
           // string query='Select id,nu_dse__Bank_Account_Number__c,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c from nu_dse__Bank_Account__c';
             Batch_PostRefresh_BankAcc b1=new Batch_PostRefresh_BankAcc(true);//,query
            database.executeBatch(b1);  
           test.stopTest();
        }
        catch(exception e)
        {
          system.debug('Acc Msg:'+e.getMessage());  
        }
    }
    
    public static testmethod void Test_Batch_TradeLine() 
    {
       nu_dse__TradeLine__c t=new nu_dse__TradeLine__c(nu_dse__Original_Account_Number__c='2345',nu_dse__New_Account_Number__c='8976',nu_dse__Original_Debt__c=240);
       insert t;
       try{
            test.startTest();
           //string query='Select id,nu_dse__CFT_Payee_Contact_Id__c,nu_dse__GCS_Payee_Contact_Id__c,nu_dse__RAMS_Payee_Contact_Id__c,fsCore__National_Identification_Number__c from Contact';
           // Batch_PostRefresh b=new Batch_PostRefresh('Contact','xyz');//,query
            Batch_PostRefresh_Tradeline b=new Batch_PostRefresh_Tradeline(true);
            database.executeBatch(b);  
            Test.stopTest();
        }
        catch(exception e)
        {
          system.debug('Acc Msg:'+e.getMessage());  
        }
               
    }
    
    public static testmethod void Test_Batch_Contact() 
    {
       Contact t=new Contact(nu_dse__CFT_Payee_Contact_Id__c='2345',nu_dse__GCS_Payee_Contact_Id__c='8976',nu_dse__RAMS_Payee_Contact_Id__c='240',fsCore__National_Identification_Number__c='6547',LastName='VBHG');
       insert t;
       try{
            test.startTest();
           // string query='Select id,nu_dse__CFT_Payee_Contact_Id__c,nu_dse__GCS_Payee_Contact_Id__c,nu_dse__RAMS_Payee_Contact_Id__c,fsCore__National_Identification_Number__c from Contact';
            Batch_PostRefresh_Contact b=new Batch_PostRefresh_Contact(True);//,query
            database.executeBatch(b);  
            Test.stopTest();
        }
        catch(exception e)
        {
          system.debug('Acc Msg:'+e.getMessage());  
        }
               
    }
}