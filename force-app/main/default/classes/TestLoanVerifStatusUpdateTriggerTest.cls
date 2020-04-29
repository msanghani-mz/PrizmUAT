@isTest
private class TestLoanVerifStatusUpdateTriggerTest{

    static TestMethod void testLoanVerifStatusUpdate(){
        
        Opportunity testOpp = new Opportunity();
        testOpp.Name='Test Opportunity';
        testOpp.Loan_Id__c = '0';
        testOpp.CloseDate=date.today();
        testOpp.StageName='PreQualified';
        testOpp.Loan_Content_Status__c='None';
        testOpp.Hard_Pull__c='Pending';
        testOpp.PFIntegNb__c=0;
        
        insert testOpp;
        
        test.startTest();
        testOpp.Compare_Paystubs_with_Employment__c='Error';
        testOpp.Compare_W2_and_Employment__c='Error';
        testOpp.Credit_Report_Consistency__c='Verified';
        testOpp.Flags_Hits__c='Verified';
        testOpp.Send_4506T_to_IRS__c='Verified';
        testOpp.Hard_Pull__c='Error';
        testOpp.AML_Risk__c='Verified';
        testOpp.Lexis_Nexis__c='Error';
        testOpp.Income_Verified__c='Verified';
        testOpp.Employment_Verification__c='Error';
        testOpp.Address_Verification__c='Verified';
        
        testOpp.Date_Of_Death__c=Date.newInstance(2016, 1, 1);
        testOpp.Transferred_to_CFS2_Servicing__c=Date.newInstance(2016, 1, 1);
        testOpp.Transferred_to_Collection_Date__c=Date.newInstance(2016, 1, 1);
        testOpp.Bankruptcy_Chapter__c='Chapter 13';
        testOpp.Bankruptcy_Status__c='Completed';
        testOpp.Bankruptcy_Notification_Date__c=Date.newInstance(2016, 1, 1);
        
        update testOpp;
        test.stopTest();
        Opportunity updatedTestOpp= [SELECT PFIntegNb__c FROM Opportunity WHERE Id= :testOpp.Id];
        //System.assertEquals(1,updatedTestOpp.PFIntegNb__c);
        // 7 because this is caught by another trigger as well
          
    }


}