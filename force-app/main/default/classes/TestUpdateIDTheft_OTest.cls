@isTest
private class TestUpdateIDTheft_OTest{
    static TestMethod void testUpdateIDTheft_O(){
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
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
        testOpp.ID_Theft__c = false;
       
        insert testOpp;
        test.startTest();
    
        testOpp.ID_Theft__c = true;
        
        update testOpp;
        
        test.stopTest();
        Opportunity updatedTestOpp = [SELECT ID_Theft__c FROM Opportunity WHERE Id= :testOpp.Id];
        System.assertEquals(true, updatedTestOpp.ID_Theft__c );
    }
}