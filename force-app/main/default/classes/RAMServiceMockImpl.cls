//Generated by FuseIT WSDL2Apex (http://www.fuseit.com/Solutions/SFDC-Explorer/Help-WSDL-Parser.aspx)

@isTest
public class RAMServiceMockImpl implements WebServiceMock {
    public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
       
        System.debug(LoggingLevel.INFO, 'RAMServiceMockImpl.doInvoke() - ' +
            '\n request: ' + request +
            '\n response: ' + response +
            '\n endpoint: ' + endpoint +
            '\n soapAction: ' + soapAction +
            '\n requestName: ' + requestName +
            '\n responseNS: ' + responseNS +
            '\n responseName: ' + responseName +
            '\n responseType: ' + responseType);

        if(request instanceOf RAMServiceGateway.AddAffiliate_element) {
            response.put( 'response_x', new RAMServiceGateway.AddAffiliateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.AddClientCard_element) {
            response.put( 'response_x', new RAMServiceGateway.AddClientCardResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.AddFeeGroup_element) {
            response.put( 'response_x', new RAMServiceGateway.AddFeeGroupResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.AddFeeGroup2_element) {
            response.put( 'response_x', new RAMServiceGateway.AddFeeGroup2Response_element());
        }
        else if(request instanceOf RAMServiceGateway.AddUpdateClientBanking_element) {
            response.put( 'response_x', new RAMServiceGateway.AddUpdateClientBankingResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.BAV_VerifyAccount_element) {
            response.put( 'response_x', new RAMServiceGateway.BAV_VerifyAccountResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.BAV_VerifyAccount_Update_element) {
            response.put( 'response_x', new RAMServiceGateway.BAV_VerifyAccount_UpdateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.CancelDocument_element) {
            response.put( 'response_x', new RAMServiceGateway.CancelDocumentResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ChangeAccountStatus_element) {
            response.put( 'response_x', new RAMServiceGateway.ChangeAccountStatusResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ChargeClientCard_element) {
            response.put( 'response_x', new RAMServiceGateway.ChargeClientCardResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ChargeClientCardWithCVV_element) {
            response.put( 'response_x', new RAMServiceGateway.ChargeClientCardWithCVVResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ChargeFromPayee_element) {
            response.put( 'response_x', new RAMServiceGateway.ChargeFromPayeeResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ClearPaymentSchedule_element) {
            response.put( 'response_x', new RAMServiceGateway.ClearPaymentScheduleResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.EndSession_element) {
            response.put( 'response_x', new RAMServiceGateway.EndSessionResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.FundClientBankAccount_element) {
            response.put( 'response_x', new RAMServiceGateway.FundClientBankAccountResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.FundClientEscrow_element) {
            response.put( 'response_x', new RAMServiceGateway.FundClientEscrowResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetAllClients_element) {
            response.put( 'response_x', new RAMServiceGateway.GetAllClientsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetChangedStatusClients_element) {
            response.put( 'response_x', new RAMServiceGateway.GetChangedStatusClientsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientInfo_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientInfoResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientInfo_Bulk_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientInfo_BulkResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientInfo_ByDate_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientInfo_ByDateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientLedger_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientLedgerResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientPaymentSchedule_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientPaymentScheduleResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientPaymentSchedule_Bulk_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientSavings_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientSavingsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientSavings_Bulk_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientSavings_BulkResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientSavings_ByDate_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientSavings_ByDateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientTransactionsByUpdateDate_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientTransByClientID_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientTransByClientIDResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientTransByID_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientTransByIDResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetClientTransByPaymentDateRange_element) {
            response.put( 'response_x', new RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetDocumentStatus_element) {
            response.put( 'response_x', new RAMServiceGateway.GetDocumentStatusResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetHolidaySchedule_element) {
            response.put( 'response_x', new RAMServiceGateway.GetHolidayScheduleResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetMadePaymentsByClient_element) {
            response.put( 'response_x', new RAMServiceGateway.GetMadePaymentsByClientResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetMadePaymentsByDate_element) {
            response.put( 'response_x', new RAMServiceGateway.GetMadePaymentsByDateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetMadePaymentsByDateExtended_element) {
            response.put( 'response_x', new RAMServiceGateway.GetMadePaymentsByDateExtendedResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetPaymentIDByExtendedID_element) {
            response.put( 'response_x', new RAMServiceGateway.GetPaymentIDByExtendedIDResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetPaymentStatus_element) {
            response.put( 'response_x', new RAMServiceGateway.GetPaymentStatusResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetPaymentTypeInfo_element) {
            response.put( 'response_x', new RAMServiceGateway.GetPaymentTypeInfoResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetRefunds_element) {
            response.put( 'response_x', new RAMServiceGateway.GetRefundsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetReturns_element) {
            response.put( 'response_x', new RAMServiceGateway.GetReturnsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetReturnsDateRange_element) {
            response.put( 'response_x', new RAMServiceGateway.GetReturnsDateRangeResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetSettlements_Bulk_element) {
            response.put( 'response_x', new RAMServiceGateway.GetSettlements_BulkResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetUpdatedSavings_element) {
            response.put( 'response_x', new RAMServiceGateway.GetUpdatedSavingsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.GetVendorCurrentFees_element) {
            response.put( 'response_x', new RAMServiceGateway.GetVendorCurrentFeesResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ListAllPayees_element) {
            response.put( 'response_x', new RAMServiceGateway.ListAllPayeesResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.NewClient_element) {
            response.put( 'response_x', new RAMServiceGateway.NewClientResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PayFromClientTrust_element) {
            response.put( 'response_x', new RAMServiceGateway.PayFromClientTrustResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PayFromClientTrust_Extended_element) {
            response.put( 'response_x', new RAMServiceGateway.PayFromClientTrust_ExtendedResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PayFromClientTrustWithSplits_element) {
            response.put( 'response_x', new RAMServiceGateway.PayFromClientTrustWithSplitsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PayScheduleAddSingle_element) {
            response.put( 'response_x', new RAMServiceGateway.PayScheduleAddSingleResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PayScheduleCreate_element) {
            response.put( 'response_x', new RAMServiceGateway.PayScheduleCreateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PayScheduleUpdateSingle_element) {
            response.put( 'response_x', new RAMServiceGateway.PayScheduleUpdateSingleResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PendingFees_Remove_element) {
            response.put( 'response_x', new RAMServiceGateway.PendingFees_RemoveResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PendingFees_Show_element) {
            response.put( 'response_x', new RAMServiceGateway.PendingFees_ShowResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.PendingFees_ShowAll_element) {
            response.put( 'response_x', new RAMServiceGateway.PendingFees_ShowAllResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ReleaseClientFeesandSavings_element) {
            response.put( 'response_x', new RAMServiceGateway.ReleaseClientFeesandSavingsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.RemoveAllSettlements_element) {
            response.put( 'response_x', new RAMServiceGateway.RemoveAllSettlementsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.RemoveClientCard_element) {
            response.put( 'response_x', new RAMServiceGateway.RemoveClientCardResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.RemoveSettlement_element) {
            response.put( 'response_x', new RAMServiceGateway.RemoveSettlementResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.RemoveUser_element) {
            response.put( 'response_x', new RAMServiceGateway.RemoveUserResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_Cancellations_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_CancellationsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_ClientActivity_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_ClientActivityResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_ClientReturns_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_ClientReturnsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_ClientsOnHold_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_ClientsOnHoldResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_FeeAccrualBalance_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_FeeAccrualBalanceResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_OutstandingChecks_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_OutstandingChecksResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_PostedPayments_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_PostedPaymentsResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_PostedPaymentsFromTrust_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_SavingsSummary_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_SavingsSummaryResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.Report_TrackingByDate_element) {
            response.put( 'response_x', new RAMServiceGateway.Report_TrackingByDateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.RVDVerify_element) {
            response.put( 'response_x', new RAMServiceGateway.RVDVerifyResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.ScheduleClientCardCharge_element) {
            response.put( 'response_x', new RAMServiceGateway.ScheduleClientCardChargeResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SetClientFees_element) {
            response.put( 'response_x', new RAMServiceGateway.SetClientFeesResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SetClientPhase_element) {
            response.put( 'response_x', new RAMServiceGateway.SetClientPhaseResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SettlementAddSinglePayment_element) {
            response.put( 'response_x', new RAMServiceGateway.SettlementAddSinglePaymentResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SettlementAddSinglePaymentWithFee_element) {
            response.put( 'response_x', new RAMServiceGateway.SettlementAddSinglePaymentWithFeeResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SettlementUpdateSinglePayment_element) {
            response.put( 'response_x', new RAMServiceGateway.SettlementUpdateSinglePaymentResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SettlementUpdateSinglePaymentExtended_element) {
            response.put( 'response_x', new RAMServiceGateway.SettlementUpdateSinglePaymentExtendedResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SettlementUpdateSinglePaymentWithFee_element) {
            response.put( 'response_x', new RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedID_element) {
            response.put( 'response_x', new RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.StartSession_element) {
            response.put( 'response_x', new RAMServiceGateway.StartSessionResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UpdateAffiliate_element) {
            response.put( 'response_x', new RAMServiceGateway.UpdateAffiliateResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UpdateClient_element) {
            response.put( 'response_x', new RAMServiceGateway.UpdateClientResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UpdateClientAgent_element) {
            response.put( 'response_x', new RAMServiceGateway.UpdateClientAgentResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UpdateClientCombined_element) {
            response.put( 'response_x', new RAMServiceGateway.UpdateClientCombinedResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UpdateClientSSN_element) {
            response.put( 'response_x', new RAMServiceGateway.UpdateClientSSNResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UpdateFeeGroup_element) {
            response.put( 'response_x', new RAMServiceGateway.UpdateFeeGroupResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UpdateFeeGroup2_element) {
            response.put( 'response_x', new RAMServiceGateway.UpdateFeeGroup2Response_element());
        }
        else if(request instanceOf RAMServiceGateway.UploadCardAuth_element) {
            response.put( 'response_x', new RAMServiceGateway.UploadCardAuthResponse_element());
        }
        else if(request instanceOf RAMServiceGateway.UploadClientDocument_element) {
            response.put( 'response_x', new RAMServiceGateway.UploadClientDocumentResponse_element());
        }
    }
}