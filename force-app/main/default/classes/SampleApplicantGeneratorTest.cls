/**
 * Class Name  : SampleApplicantGeneratorTest
 * Description : This class has test method for SampleApplicantGenerator
 * Author      : Financial Spectra
 *
 */
 @isTest
private class SampleApplicantGeneratorTest{
	
	@testSetup
    static void createTestData(){
    	TestHelperData.createTriggerExecutionTestData();
        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company'
                                                                                            , 'TESTCO'
                                                                                            , '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch'
                                                                                         , 'VLB'
                                                                                         , testCompany.Id
                                                                                         , null
                                                                                         , null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 
        
    }

	private static testMethod void testSampleApplicantGenerator(){
    	
        Test.startTest(); 
        SampleApplicantGenerator appGen = new SampleApplicantGenerator(1);
        appGen.setBranch('VLB');
        appGen.setCreateWithBankAccount(True);
        appGen.generateData();
        Test.stopTest();        
    }


}