/* 
 * Class   : PayoffNotificationTest
 * Purpose : Test class for PayoffNotification       
 * Author  : Financial Spectra
 */
@isTest(seeAllData = false)
private class PayoffNotificationTest {
static void createLendingContracts(Boolean pActiveContracts, Boolean pWithRelatedData){
        TestCustomDataLoader.loadAccounts();
        TestCustomDataLoader.loadContacts();
        
        if (pActiveContracts){
            TestCustomDataLoader.loadLendingContractsActive();
            TestCustomDataLoader.loadContractBalancesActive();
            TestCustomDataLoader.loadContractDues();
            TestCustomDataLoader.loadContractRepayments();
            TestCustomDataLoader.loadContractRepaySchedules();
        } else {
            TestCustomDataLoader.loadLendingContractsPending();
            TestCustomDataLoader.loadContractBalancesPending();
        }
        
        if (pWithRelatedData){
            TestCustomDataLoader.loadBankAccounts();
            TestCustomDataLoader.loadContractCustomers();
            TestCustomDataLoader.loadContractItemizations();
            TestCustomDataLoader.loadContractFees();
            TestCustomDataLoader.loadContractDirectDebits();
            TestCustomDataLoader.loadContractDisbursements();
        }
        
        System.assertEquals(8, [SELECT count() FROM fsServ__Lending_Contract__c]);
    }
    @testSetup static void createTestData(){
        fsServ.TestHelperGlobal.createSetupData();
        //fsServ.TestHelperGlobal.createLendingContracts(true, true); //this will create contracts with customers, direct debit and dues  
        createLendingContracts(true, true);
    } 
     @isTest
    private static void test(){
        List<id> conIds = new List<id>();
         fsServ__Lending_Contract__c  testContract = [SELECT Id, Name
                                                      ,fsServ__Paid_in_Full_Date__c
                                                      ,Is_Paid_Off_Notification_Sent__c
                                                      ,Paid_Off_Notification_Sent_Date__c
                                                      , fsServ__Contract_Status__c
                                                      ,fsServ__Total_Outstanding_Amount__c
                                                      FROM fsServ__Lending_Contract__c 
                                                      Limit 1
                                                     ];
        testContract.fsServ__Contract_Status__c = 'Paid In Full';
        testContract.Is_Paid_Off_Notification_Sent__c = false;
        testContract.fsServ__Total_Outstanding_Amount__c = 0;
        testContract.fsServ__Paid_in_Full_Date__c = Date.today();
        conIds.add(testContract.id);
        
        
        Test.startTest();
        PayoffNotification.sendNotification(conIds);
        Test.stopTest();
    }
}