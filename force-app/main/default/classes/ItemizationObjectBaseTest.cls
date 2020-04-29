/*
* Class Name   - ItemizationObjectBaseTest
* Description  - Test class for ItemizationObjectBase
* Developer(s) - Financial Spectra
*/
@isTest(seeAllData=false)
private class ItemizationObjectBaseTest{
    
    @isTest
    private static void testItmzObject_NonCalculable(){
        Test.startTest();
        
        ItemizationObjectBase itmzObj = new ItemizationObjectBase();
        itmzObj.setRecordNumber(1234);
        itmzObj.setItemizationName('Test itemization');
        itmzObj.setFeeSetup(null);
        
        System.assertEquals(1234, itmzObj.getRecordNumber());
        System.assertEquals('Test itemization', itmzObj.getItemizationName());
        System.assertEquals(null, itmzObj.getFeeSetup());
        Test.stopTest();
    }
    @isTest
    private static void testItmzObject_Calculable(){
        //create origination fee
        fsCore__Fee_Setup__c testOrigFee = fsCore.TestHelperProduct.getTestFeeSetup('Test Fee Name', null, 'Prepaid_Fee', 'Application Fee', 12345, 1);
        insert testOrigFee;
        
        System.assert(testOrigFee.Id != null, 'Test Origination Fee created assert');
        
        Test.startTest();
        
        ItemizationObjectBase itmzObj = new ItemizationObjectBase();
        itmzObj.setRecordNumber(1234);
        itmzObj.setItemizationName('Test Fee Itemization');
        itmzObj.setFeeSetup(testOrigFee);
        itmzObj.setIsFinancedAmountType(false);
        System.assertEquals(1234, itmzObj.getRecordNumber());
        System.assertEquals('Test Fee Itemization', itmzObj.getItemizationName());
        System.assertEquals(false, itmzObj.getIsFinancedAmountType());
        System.assertEquals(testOrigFee.Id, itmzObj.getFeeSetup().Id);
        System.assertEquals(null, itmzObj.getItemizationSetup(null));
        System.assertEquals(1, itmzObj.getItemizationSelectList().size());
        
        Test.stopTest();
    }
}