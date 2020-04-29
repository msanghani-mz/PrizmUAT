@isTest
private class TestLoanContentStatusUpdateTriggerTest{

static TestMethod void testLoanContentStatusUpdate(){
    Opportunity testOpp = new Opportunity();
    testOpp.Name='Test Opportunity';
    testOpp.CloseDate=date.today();
    testOpp.StageName='PreQualified';
    testOpp.Loan_Id__c = '0';
    testOpp.Loan_Content_Status__c='Pending';
    testOpp.Compare_Paystubs_with_Employment__c='Error';
    testOpp.Compare_W2_and_Employment__c='Error';
    testOpp.Credit_Report_Consistency__c='Verified';
    testOpp.Flags_Hits__c='Verified';
    testOpp.Send_4506T_to_IRS__c='Verified';
    testOpp.AML_Risk__c='Verified';
    testOpp.Lexis_Nexis__c='Error';
    testOpp.PFIntegNb__c=0;
    

    insert testOpp;
    test.startTest();

    testOpp.Loan_Content_Status__c='Rejected';
    
    update testOpp;
    
    test.stopTest();
    Opportunity updatedTestOpp= [SELECT PFIntegNb__c FROM Opportunity WHERE Id= :testOpp.Id];
    //System.assertEquals(1,updatedTestOpp.PFIntegNb__c);    
}


}