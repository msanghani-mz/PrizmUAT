@isTest
private class WS_PullCreditTest{

   @isTest
   private static void testWS_PullCreditResponse(){
       Test.startTest();
       WS_PullCreditResponse resp = new WS_PullCreditResponse();
       resp.success = true;
       resp.data = new WS_PullCreditResponse.CreditPullData();
       resp.data.pullType = 'soft';
       resp.data.file = new WS_PullCreditResponse.CreditPullFile();
       resp.data.file.hx5 = new WS_PullCreditResponse.HX5();
       resp.data.file.hx5.version = '1.0';
       resp.data.file.hx5.html_reports = new WS_PullCreditResponse.HTMLReports();
        
       resp.data.file.hx5.tty_reports = new WS_PullCreditResponse.TTYReports();
       resp.data.file.hx5.bureau_xml_data = new WS_PullCreditResponse.BureauXMLData();
       resp.data.file.hx5.hx5_transaction_information = new WS_PullCreditResponse.HX5TransactionInfo();
       
       Test.stopTest();
   }


}