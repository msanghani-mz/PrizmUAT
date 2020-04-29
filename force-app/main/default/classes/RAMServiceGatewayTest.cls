/**
 * @File Name          : RAMServiceGatewayTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/11/2019, 1:00:25 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/11/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class RAMServiceGatewayTest {
    
  
    
    @isTest static void coverGeneratedCodeTypes() {
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway parentObject = new RAMServiceGateway();
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode mockNode = doc.createRootElement('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/', 'env');
        new RAMServiceGateway.AddAffiliateResponse_element();
        new RAMServiceGateway.AddClientCardResponse_element();              
        new RAMServiceGateway.AddFeeGroup2Response_element();
        new RAMServiceGateway.AddFeeGroupResponse_element(); 
        new RAMServiceGateway.AddUpdateClientBankingResponse_element();             
        new RAMServiceGateway.ArrayOfCompany();             
        new RAMServiceGateway.ArrayOfDouble();              
        new RAMServiceGateway.ArrayOfPaymentLine();             
        new RAMServiceGateway.ArrayOfPaymentLineDetailed();             
        new RAMServiceGateway.ArrayOfString();              
        new RAMServiceGateway.BAV_VerifyAccount_UpdateResponse_element();
        new RAMServiceGateway.BAV_VerifyAccountResponse_element();             
        new RAMServiceGateway.CancelDocumentResponse_element();             
        new RAMServiceGateway.ChangeAccountStatusResponse_element(); 
        new RAMServiceGateway.ChargeClientCardResponse_element();
        new RAMServiceGateway.ChargeClientCardWithCVVResponse_element(); 
        new RAMServiceGateway.ChargeFromPayeeResponse_element(); 
        new RAMServiceGateway.ClearPaymentScheduleResponse_element();
        new RAMServiceGateway.ClientDocumentStatus();
        new RAMServiceGateway.Company(); 
        new RAMServiceGateway.EndSessionResponse_element();             
        new RAMServiceGateway.FundClientBankAccountResponse_element();              
        new RAMServiceGateway.FundClientEscrowResponse_element();
        new RAMServiceGateway.GetAllClientsResponse_element();              
        new RAMServiceGateway.GetAllClientsResponse_GetAllClientsResult_element();              
        new RAMServiceGateway.GetChangedStatusClientsResponse_element(); 
        new RAMServiceGateway.GetClientInfo_BulkResponse_element();             
        new RAMServiceGateway.GetClientInfo_ByDateResponse_element();
        new RAMServiceGateway.GetClientInfoResponse_element();              
        new RAMServiceGateway.GetClientLedgerResponse_element(); 
        new RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_element();              
        new RAMServiceGateway.GetClientPaymentScheduleResponse_element();
        new RAMServiceGateway.GetClientSavings_BulkResponse_element();              
        new RAMServiceGateway.GetClientSavings_ByDateResponse_element(); 
        new RAMServiceGateway.GetClientSavingsResponse_element();
        new RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_element();              
        new RAMServiceGateway.GetClientTransByClientIDResponse_element();
        new RAMServiceGateway.GetClientTransByIDResponse_element();             
        new RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_element();
        new RAMServiceGateway.GetDocumentStatusResponse_element();              
        new RAMServiceGateway.GetHolidayScheduleResponse_element();             
        new RAMServiceGateway.GetMadePaymentsByClientResponse_element(); 
        new RAMServiceGateway.GetMadePaymentsByDateExtendedResponse_element();              
        new RAMServiceGateway.GetMadePaymentsByDateResponse_element();              
        new RAMServiceGateway.GetPaymentIDByExtendedIDResponse_element();
        new RAMServiceGateway.GetPaymentStatusResponse_element();
        new RAMServiceGateway.GetPaymentTypeInfoResponse_element();             
        new RAMServiceGateway.GetRefundsResponse_element();             
        new RAMServiceGateway.GetReturnsDateRangeResponse_element(); 
        new RAMServiceGateway.GetReturnsResponse_element();             
        new RAMServiceGateway.GetSettlements_BulkResponse_element(); 
        new RAMServiceGateway.GetUpdatedSavingsResponse_element();              
        new RAMServiceGateway.GetVendorCurrentFeesResponse_element();
        new RAMServiceGateway.ListAllPayeesResponse_element();              
        new RAMServiceGateway.NewClientResponse_element();              
        new RAMServiceGateway.PayFromClientTrust_ExtendedResponse_element(); 
        new RAMServiceGateway.PayFromClientTrustResponse_element();             
        new RAMServiceGateway.PayFromClientTrustWithSplitsResponse_element();
        new RAMServiceGateway.PaymentLine(); 
        new RAMServiceGateway.PaymentLineDetailed(); 
        new RAMServiceGateway.PayScheduleAddSingleResponse_element();
        new RAMServiceGateway.PayScheduleCreateResponse_element();              
        new RAMServiceGateway.PayScheduleUpdateSingleResponse_element(); 
        new RAMServiceGateway.PendingFees_RemoveResponse_element();             
        new RAMServiceGateway.PendingFees_ShowAllResponse_element(); 
        new RAMServiceGateway.PendingFees_ShowResponse_element();
        new RAMServiceGateway.ReleaseClientFeesandSavingsResponse_element(); 
        new RAMServiceGateway.RemoveAllSettlementsResponse_element();
        new RAMServiceGateway.RemoveClientCardResponse_element();
        new RAMServiceGateway.RemoveSettlementResponse_element();
        new RAMServiceGateway.RemoveUserResponse_element();             
        new RAMServiceGateway.Report_CancellationsResponse_element();
        new RAMServiceGateway.Report_ClientActivityResponse_element();              
        new RAMServiceGateway.Report_ClientReturnsResponse_element();
        new RAMServiceGateway.Report_ClientsOnHoldResponse_element();
        new RAMServiceGateway.Report_FeeAccrualBalanceResponse_element();
        new RAMServiceGateway.Report_OutstandingChecksResponse_element();
        new RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_element();             
        new RAMServiceGateway.Report_PostedPaymentsResponse_element();              
        new RAMServiceGateway.Report_SavingsSummaryResponse_element();              
        new RAMServiceGateway.Report_TrackingByDateResponse_element();              
        new RAMServiceGateway.RVDVerifyResponse_element();              
        new RAMServiceGateway.ScheduleClientCardChargeResponse_element();
        new RAMServiceGateway.SetClientFeesResponse_element();              
        new RAMServiceGateway.SetClientPhaseResponse_element();             
        new RAMServiceGateway.SettlementAddSinglePaymentResponse_element();             
        new RAMServiceGateway.SettlementAddSinglePaymentWithFeeResponse_element();              
        new RAMServiceGateway.SettlementUpdateSinglePaymentExtendedResponse_element();              
        new RAMServiceGateway.SettlementUpdateSinglePaymentResponse_element();              
        new RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse_element();
        new RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeResponse_element();
        new RAMServiceGateway.StartSessionResponse_element();
        new RAMServiceGateway.UpdateAffiliateResponse_element(); 
        new RAMServiceGateway.UpdateClientAgentResponse_element();              
        new RAMServiceGateway.UpdateClientCombinedResponse_element();
        new RAMServiceGateway.UpdateClientResponse_element();
        new RAMServiceGateway.UpdateClientSSNResponse_element(); 
        new RAMServiceGateway.UpdateFeeGroup2Response_element(); 
        new RAMServiceGateway.UpdateFeeGroupResponse_element();             
        new RAMServiceGateway.UploadCardAuthResponse_element();             
        new RAMServiceGateway.UploadClientDocumentResponse_element();

    }
    @isTest static void coverCodeForAddAffiliate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.AddAffiliate(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForAddClientCard(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.AddClientCard(null, null, null, null, null));
    }
    @isTest static void coverCodeForAddFeeGroup(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        //System.assertEquals(null, testObject.AddFeeGroup(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForAddFeeGroup2(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        //System.assertEquals(null, testObject.AddFeeGroup2(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForAddUpdateClientBanking(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.AddUpdateClientBanking(null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForBAV_VerifyAccount(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.BAV_VerifyAccount(null, null));
    }
    @isTest static void coverCodeForBAV_VerifyAccount_Update(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.BAV_VerifyAccount_Update(null, null));
    }
    @isTest static void coverCodeForCancelDocument(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.CancelDocument(null, null));
    }
    @isTest static void coverCodeForChangeAccountStatus(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ChangeAccountStatus(null, null, null, null));
    }
    @isTest static void coverCodeForChargeClientCard(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ChargeClientCard(null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForChargeClientCardWithCVV(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ChargeClientCardWithCVV(null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForChargeFromPayee(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ChargeFromPayee(null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForClearPaymentSchedule(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ClearPaymentSchedule(null, null));
    }
    @isTest static void coverCodeForEndSession(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.EndSession(null));
    }
    @isTest static void coverCodeForFundClientBankAccount(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.FundClientBankAccount(null, null, null, null));
    }
    @isTest static void coverCodeForFundClientEscrow(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.FundClientEscrow(null, null, null, null, null, null));
    }
    @isTest static void coverCodeForGetAllClients(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetAllClients(null, null));
    }
    @isTest static void coverCodeForGetChangedStatusClients(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetChangedStatusClients(null, null));
    }
    @isTest static void coverCodeForGetClientInfo(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientInfo(null, null));
    }
    @isTest static void coverCodeForGetClientInfo_Bulk(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientInfo_Bulk(null, null));
    }
    @isTest static void coverCodeForGetClientInfo_ByDate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientInfo_ByDate(null, null));
    }
    @isTest static void coverCodeForGetClientLedger(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientLedger(null, null));
    }
    @isTest static void coverCodeForGetClientPaymentSchedule(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientPaymentSchedule(null, null));
    }
    @isTest static void coverCodeForGetClientPaymentSchedule_Bulk(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientPaymentSchedule_Bulk(null, null));
    }
    @isTest static void coverCodeForGetClientSavings(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientSavings(null, null));
    }
    @isTest static void coverCodeForGetClientSavings_Bulk(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientSavings_Bulk(null, null));
    }
    @isTest static void coverCodeForGetClientSavings_ByDate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientSavings_ByDate(null, null));
    }
    @isTest static void coverCodeForGetClientTransactionsByUpdateDate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientTransactionsByUpdateDate(null, null));
    }
    @isTest static void coverCodeForGetClientTransByClientID(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientTransByClientID(null, null));
    }
    @isTest static void coverCodeForGetClientTransByID(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientTransByID(null, null));
    }
    @isTest static void coverCodeForGetClientTransByPaymentDateRange(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetClientTransByPaymentDateRange(null, null, null));
    }
    @isTest static void coverCodeForGetDocumentStatus(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetDocumentStatus(null, null, null));
    }
    @isTest static void coverCodeForGetHolidaySchedule(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetHolidaySchedule(null));
    }
    @isTest static void coverCodeForGetMadePaymentsByClient(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetMadePaymentsByClient(null, null));
    }
    @isTest static void coverCodeForGetMadePaymentsByDate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetMadePaymentsByDate(null, null, null));
    }
    @isTest static void coverCodeForGetMadePaymentsByDateExtended(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetMadePaymentsByDateExtended(null, null, null));
    }
    @isTest static void coverCodeForGetPaymentIDByExtendedID(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetPaymentIDByExtendedID(null, null));
    }
    @isTest static void coverCodeForGetPaymentStatus(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetPaymentStatus(null, null, null));
    }
    @isTest static void coverCodeForGetPaymentTypeInfo(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetPaymentTypeInfo(null));
    }
    @isTest static void coverCodeForGetRefunds(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetRefunds(null, null));
    }
    @isTest static void coverCodeForGetReturns(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetReturns(null, null));
    }
    @isTest static void coverCodeForGetReturnsDateRange(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetReturnsDateRange(null, null, null));
    }
    @isTest static void coverCodeForGetSettlements_Bulk(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetSettlements_Bulk(null, null));
    }
    @isTest static void coverCodeForGetUpdatedSavings(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetUpdatedSavings(null, null));
    }
    @isTest static void coverCodeForGetVendorCurrentFees(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.GetVendorCurrentFees(null));
    }
    @isTest static void coverCodeForListAllPayees(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ListAllPayees(null));
    }
    @isTest static void coverCodeForNewClient(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.NewClient(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForPayFromClientTrust(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PayFromClientTrust(null, null, null, null, null));
    }
    @isTest static void coverCodeForPayFromClientTrust_Extended(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PayFromClientTrust_Extended(null, null, null, null, null, null));
    }
    @isTest static void coverCodeForPayFromClientTrustWithSplits(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PayFromClientTrustWithSplits(null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForPayScheduleAddSingle(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PayScheduleAddSingle(null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForPayScheduleCreate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PayScheduleCreate(null, null, null));
    }
    @isTest static void coverCodeForPayScheduleUpdateSingle(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PayScheduleUpdateSingle(null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForPendingFees_Remove(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PendingFees_Remove(null, null));
    }
    @isTest static void coverCodeForPendingFees_Show(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PendingFees_Show(null, null));
    }
    @isTest static void coverCodeForPendingFees_ShowAll(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.PendingFees_ShowAll(null));
    }
    @isTest static void coverCodeForReleaseClientFeesandSavings(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ReleaseClientFeesandSavings(null, null));
    }
    @isTest static void coverCodeForRemoveAllSettlements(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.RemoveAllSettlements(null, null, null));
    }
    @isTest static void coverCodeForRemoveClientCard(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.RemoveClientCard(null, null, null));
    }
    @isTest static void coverCodeForRemoveSettlement(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.RemoveSettlement(null, null, null));
    }
    @isTest static void coverCodeForRemoveUser(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.RemoveUser(null, null));
    }
    @isTest static void coverCodeForReport_Cancellations(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_Cancellations(null, null, null));
    }
    @isTest static void coverCodeForReport_ClientActivity(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_ClientActivity(null, null, null, null));
    }
    @isTest static void coverCodeForReport_ClientReturns(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_ClientReturns(null, null, null));
    }
    @isTest static void coverCodeForReport_ClientsOnHold(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_ClientsOnHold(null));
    }
    @isTest static void coverCodeForReport_FeeAccrualBalance(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_FeeAccrualBalance(null));
    }
    @isTest static void coverCodeForReport_OutstandingChecks(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_OutstandingChecks(null));
    }
    @isTest static void coverCodeForReport_PostedPayments(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_PostedPayments(null, null, null, null));
    }
    @isTest static void coverCodeForReport_PostedPaymentsFromTrust(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_PostedPaymentsFromTrust(null, null, null, null));
    }
    @isTest static void coverCodeForReport_SavingsSummary(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_SavingsSummary(null));
    }
    @isTest static void coverCodeForReport_TrackingByDate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.Report_TrackingByDate(null, null, null));
    }
    @isTest static void coverCodeForRVDVerify(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.RVDVerify(null, null));
    }
    @isTest static void coverCodeForScheduleClientCardCharge(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.ScheduleClientCardCharge(null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForSetClientFees(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SetClientFees(null, null, null));
    }
    @isTest static void coverCodeForSetClientPhase(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SetClientPhase(null, null, null));
    }
    @isTest static void coverCodeForSettlementAddSinglePayment(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SettlementAddSinglePayment(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForSettlementAddSinglePaymentWithFee(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SettlementAddSinglePaymentWithFee(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForSettlementUpdateSinglePayment(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SettlementUpdateSinglePayment(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForSettlementUpdateSinglePaymentExtended(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SettlementUpdateSinglePaymentExtended(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForSettlementUpdateSinglePaymentWithFee(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SettlementUpdateSinglePaymentWithFee(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForSettlementUpdateSinglePaymentWithFeeByExtendedID(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.SettlementUpdateSinglePaymentWithFeeByExtendedID(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForStartSession(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.StartSession());
    }
    @isTest static void coverCodeForUpdateAffiliate(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.UpdateAffiliate(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForUpdateClient(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.UpdateClient(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForUpdateClientAgent(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.UpdateClientAgent(null, null, null));
    }
    @isTest static void coverCodeForUpdateClientCombined(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.UpdateClientCombined(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForUpdateClientSSN(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.UpdateClientSSN(null, null, null, null, null, null));
    }
    @isTest static void coverCodeForUpdateFeeGroup(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        //System.assertEquals(null, testObject.UpdateFeeGroup(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForUpdateFeeGroup2(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        //System.assertEquals(null, testObject.UpdateFeeGroup2(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null));
    }
    @isTest static void coverCodeForUploadCardAuth(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.UploadCardAuth(null, null, null, null));
    }
    @isTest static void coverCodeForUploadClientDocument(){
        Test.setMock(WebServiceMock.class, new RAMServiceMockImpl());
        RAMServiceGateway.RAMSGatewayVer2Soap testObject = new RAMServiceGateway.RAMSGatewayVer2Soap();
        System.assertEquals(null, testObject.UploadClientDocument(null, null, null, null));
    }

}