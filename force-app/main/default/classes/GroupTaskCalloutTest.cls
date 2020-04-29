@isTest(seeAllData=true)
private class GroupTaskCalloutTest {

    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new GThttpMockCallout());
        
        // Frst request
    Http h = new Http();        
    HttpRequest req1 = new HttpRequest();
    req1.setEndpoint('https://cs27.salesforce.com/services/oauth2/token');
    req1.setMethod('POST');
    req1.setBody('Access Token');
    HttpResponse res1 = h.send(req1);
    System.assertEquals('{"access_token":"somevalidAccessToken"}', res1.getBody());

    // Second request       
    HttpRequest req2 = new HttpRequest();
    req2.setEndpoint('https://cs27.salesforce.com/services/oauth2/token');
    req2.setMethod('POST');
    req2.setBody('ImportId');
    HttpResponse res2 = h.send(req2);
    System.assertEquals('{"invoiceList":[{"ImportId":"00T0m00000BjJbzEAF","currentTaskId":"00T22000003MRPvEAO"}]}', res2.getBody());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res = GroupTaskPostCallout.getInfoFromExternalService();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.assertEquals(200, res.getStatusCode());
        Test.startTest();
        fsCore__Lending_Application__c lstApp=[select Id,fsCore__Application_Status__c from fsCore__Lending_Application__c
                                   where fsCore__Application_Status__c='Negotiations Review' Limit 1];
       list<nu_dse__Group_Task__c> lstGT=new list<nu_dse__Group_Task__c>();
       nu_dse__Group_Task__c newTask = new nu_dse__Group_Task__c();
                    newTask.nu_dse__Subject__c = 'DNL Review for Negotiations';
                    newTask.nu_dse__Status__c = 'In Progress';
                    //newTask.Priority__c = 'High';
                    newTask.nu_dse__ActivityDate__c = System.today()+5;
                    //newTask.Task_Id__c=eachTask.Id;
                    newTask.nu_dse__Description__c='DNL Negotiations Review Request';
                    newtask.nu_dse__Related_To__c=lstApp.Id;
                    lstGT.add(newTask);
        /*Task t=new task();
        t.Subject=newTask.nu_dse__Subject__c;
        t.ActivityDate=newTask.nu_dse__ActivityDate__c;
        t.Status=newTask.nu_dse__Status__c;
        t.Description=newTask.nu_dse__Description__c;
        t.nu_dse__Group_Task__c=newTask.Id;
        insert t;*/
       
        /*PushGroupTaskInNudebt.pushGTInNdebt(JSON.serialize(lstGT),'CreateTest');
        PushGroupTaskInNudebt pn=new PushGroupTaskInNudebt();*/
        GroupTaskHandler_LendingApp.pushGTInNdebt(JSON.serialize(lstGT),'CreateTest');  //
        GroupTaskHandler_LendingApp pn=new GroupTaskHandler_LendingApp();  //
        String accessToken=pn.getAccessToken();
        system.assertNotEquals('Test1', accessToken);
        Test.stopTest();
    }
}