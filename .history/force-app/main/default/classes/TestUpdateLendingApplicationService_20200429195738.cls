@isTest
public class TestUpdateLendingApplicationService {
    @isTest
    public Static void TestSetApplicationFinalSettlementReachedTest() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        String JsonMsg=JSON.serialize(new Set<String>{'abc'});
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            updateLendingApplicationService.setApplicationFinalSettlementReached();
        Test.stopTest();
    }
}

