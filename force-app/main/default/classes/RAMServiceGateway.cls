/**
 * @File Name          : RAMServiceGateway.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/4/2019, 10:13:16 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/2/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
//Warning: '<xsd:any>' element type has been changed to dataType List<DOM.XmlNode> called anyElement
//Warning: Ignoring <s:element ref="s:schema"/> sequence Element
//Methods Included: StartSession, EndSession, AddAffiliate, UpdateAffiliate, AddFeeGroup, AddFeeGroup2, UpdateFeeGroup, UpdateFeeGroup2, NewClient, UpdateClient, AddUpdateClientBanking, ChangeAccountStatus, PayScheduleCreate, GetClientPaymentSchedule, PayScheduleUpdateSingle, PayScheduleAddSingle, SettlementAddSinglePayment, SettlementUpdateSinglePayment, SettlementUpdateSinglePaymentExtended, GetMadePaymentsByClient, GetMadePaymentsByDate, GetMadePaymentsByDateExtended, GetClientInfo, GetAllClients, GetClientInfo_Bulk, GetClientInfo_ByDate, GetClientSavings, GetClientSavings_Bulk, GetClientSavings_ByDate, GetHolidaySchedule, GetPaymentStatus, GetReturns, GetRefunds, GetReturnsDateRange, GetChangedStatusClients, GetVendorCurrentFees, GetPaymentTypeInfo, GetPaymentIDByExtendedID, GetClientTransByID, GetClientTransByClientID, GetClientTransByPaymentDateRange, GetClientTransactionsByUpdateDate, ClearPaymentSchedule, RemoveUser, RemoveAllSettlements, RemoveSettlement, GetUpdatedSavings, PayFromClientTrust, PayFromClientTrustWithSplits, PayFromClientTrust_Extended, GetSettlements_Bulk, GetClientPaymentSchedule_Bulk, SettlementAddSinglePaymentWithFee, SettlementUpdateSinglePaymentWithFee, SettlementUpdateSinglePaymentWithFeeByExtendedID, Report_PostedPayments, Report_Cancellations, Report_ClientsOnHold, Report_SavingsSummary, Report_OutstandingChecks, Report_FeeAccrualBalance, Report_ClientReturns, Report_ClientActivity, Report_TrackingByDate, ListAllPayees, UpdateClientCombined, UpdateClientAgent, UploadClientDocument, GetDocumentStatus, CancelDocument, SetClientPhase, SetClientFees, RVDVerify, ReleaseClientFeesandSavings, AddClientCard, RemoveClientCard, ChargeClientCard, ChargeClientCardWithCVV, ScheduleClientCardCharge, ChargeFromPayee, FundClientEscrow, UploadCardAuth, UpdateClientSSN, Report_PostedPaymentsFromTrust, PendingFees_Show, PendingFees_ShowAll, PendingFees_Remove, GetClientLedger, BAV_VerifyAccount, BAV_VerifyAccount_Update, FundClientBankAccount
// Primary Port Class Name: RAMSGatewayVer2Soap 
public class RAMServiceGateway {
    public class AddAffiliate_element {
        public String sessid;
        public String Name;
        public String Address;
        public String city;
        public String StateAbbrev;
        public String ZIP;
        public String Phone;
        public String NameonAccount;
        public String bankrouting;
        public String BankaccountNumber;
        public String accounttype;
        public String bankname;
        public String bankcity;
        public String bankphone;
        public String bankstateabbrev;
        public String bankzip;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] Name_type_info = new String[]{'Name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Address_type_info = new String[]{'Address','http://www.ramservicing.com/','string','0','1','false'};
        private String[] city_type_info = new String[]{'city','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbrev_type_info = new String[]{'StateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP_type_info = new String[]{'ZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone_type_info = new String[]{'Phone','http://www.ramservicing.com/','string','0','1','false'};
        private String[] NameonAccount_type_info = new String[]{'NameonAccount','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankrouting_type_info = new String[]{'bankrouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] BankaccountNumber_type_info = new String[]{'BankaccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] accounttype_type_info = new String[]{'accounttype','http://www.ramservicing.com/','BankAccountType','1','1','false'};
        private String[] bankname_type_info = new String[]{'bankname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankcity_type_info = new String[]{'bankcity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankphone_type_info = new String[]{'bankphone','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankstateabbrev_type_info = new String[]{'bankstateabbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankzip_type_info = new String[]{'bankzip','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','Name','Address','city','StateAbbrev','ZIP','Phone','NameonAccount','bankrouting','BankaccountNumber','accounttype','bankname','bankcity','bankphone','bankstateabbrev','bankzip'};
    }
    public class AddAffiliateResponse_element {
        public String AddAffiliateResult;
        private String[] AddAffiliateResult_type_info = new String[]{'AddAffiliateResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'AddAffiliateResult'};
    }
    public class AddClientCard_element {
        public String sessid;
        public Integer ClientID;
        public String CardNum;
        public Integer CardExpiryMonth;
        public Integer CardExpiryYear;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] CardNum_type_info = new String[]{'CardNum','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CardExpiryMonth_type_info = new String[]{'CardExpiryMonth','http://www.ramservicing.com/','int','1','1','false'};
        private String[] CardExpiryYear_type_info = new String[]{'CardExpiryYear','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','CardNum','CardExpiryMonth','CardExpiryYear'};
    }
    public class AddClientCardResponse_element {
        public Integer AddClientCardResult;
        private String[] AddClientCardResult_type_info = new String[]{'AddClientCardResult','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'AddClientCardResult'};
    }
    public class AddFeeGroup_element {
        public String sessid;
        public String GroupName;
        public Boolean fee1isamt;
        public Boolean fee2isamt;
        public Boolean fee3isamt;
        public Boolean fee4isamt;
        public Boolean fee5isamt;
        public Boolean fee6isamt;
        public Boolean fee7isamt;
        public Integer fee1payeeid;
        public Integer fee1payeeid2;
        public Integer fee1payeeid3;
        public Integer fee1payeeid4;
        public Integer fee2payeeid;
        public Integer fee2payeeid2;
        public Integer fee2payeeid3;
        public Integer fee2payeeid4;
        public Integer fee3payeeid;
        public Integer fee3payeeid2;
        public Integer fee3payeeid3;
        public Integer fee3payeeid4;
        public Integer fee4payeeid;
        public Integer fee4payeeid2;
        public Integer fee4payeeid3;
        public Integer fee4payeeid4;
        public Integer fee5payeeid;
        public Integer fee5payeeid2;
        public Integer fee5payeeid3;
        public Integer fee5payeeid4;
        public Integer fee6payeeid;
        public Integer fee6payeeid2;
        public Integer fee6payeeid3;
        public Integer fee6payeeid4;
        public Integer fee7payeeid;
        public Integer fee7payeeid2;
        public Integer fee7payeeid3;
        public Integer fee7payeeid4;
        public Double fee1split1;
        public Double fee1split2;
        public Double fee1split3;
        public Double fee1split4;
        public Double fee2split1;
        public Double fee2split2;
        public Double fee2split3;
        public Double fee2split4;
        public Double fee3split1;
        public Double fee3split2;
        public Double fee3split3;
        public Double fee3split4;
        public Double fee4split1;
        public Double fee4split2;
        public Double fee4split3;
        public Double fee4split4;
        public Double fee5split1;
        public Double fee5split2;
        public Double fee5split3;
        public Double fee5split4;
        public Double fee6split1;
        public Double fee6split2;
        public Double fee6split3;
        public Double fee6split4;
        public Double fee7split1;
        public Double fee7split2;
        public Double fee7split3;
        public Double fee7split4;
        public String fee1name;
        public String fee2name;
        public String fee3name;
        public String fee4name;
        public String fee5name;
        public String fee6name;
        public String fee7name;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] GroupName_type_info = new String[]{'GroupName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1isamt_type_info = new String[]{'fee1isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2isamt_type_info = new String[]{'fee2isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3isamt_type_info = new String[]{'fee3isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4isamt_type_info = new String[]{'fee4isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5isamt_type_info = new String[]{'fee5isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6isamt_type_info = new String[]{'fee6isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7isamt_type_info = new String[]{'fee7isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee1payeeid_type_info = new String[]{'fee1payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid2_type_info = new String[]{'fee1payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid3_type_info = new String[]{'fee1payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid4_type_info = new String[]{'fee1payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid_type_info = new String[]{'fee2payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid2_type_info = new String[]{'fee2payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid3_type_info = new String[]{'fee2payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid4_type_info = new String[]{'fee2payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid_type_info = new String[]{'fee3payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid2_type_info = new String[]{'fee3payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid3_type_info = new String[]{'fee3payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid4_type_info = new String[]{'fee3payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid_type_info = new String[]{'fee4payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid2_type_info = new String[]{'fee4payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid3_type_info = new String[]{'fee4payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid4_type_info = new String[]{'fee4payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid_type_info = new String[]{'fee5payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid2_type_info = new String[]{'fee5payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid3_type_info = new String[]{'fee5payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid4_type_info = new String[]{'fee5payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid_type_info = new String[]{'fee6payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid2_type_info = new String[]{'fee6payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid3_type_info = new String[]{'fee6payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid4_type_info = new String[]{'fee6payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid_type_info = new String[]{'fee7payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid2_type_info = new String[]{'fee7payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid3_type_info = new String[]{'fee7payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid4_type_info = new String[]{'fee7payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1split1_type_info = new String[]{'fee1split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split2_type_info = new String[]{'fee1split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split3_type_info = new String[]{'fee1split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split4_type_info = new String[]{'fee1split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split1_type_info = new String[]{'fee2split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split2_type_info = new String[]{'fee2split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split3_type_info = new String[]{'fee2split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split4_type_info = new String[]{'fee2split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split1_type_info = new String[]{'fee3split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split2_type_info = new String[]{'fee3split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split3_type_info = new String[]{'fee3split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split4_type_info = new String[]{'fee3split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split1_type_info = new String[]{'fee4split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split2_type_info = new String[]{'fee4split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split3_type_info = new String[]{'fee4split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split4_type_info = new String[]{'fee4split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split1_type_info = new String[]{'fee5split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split2_type_info = new String[]{'fee5split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split3_type_info = new String[]{'fee5split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split4_type_info = new String[]{'fee5split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split1_type_info = new String[]{'fee6split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split2_type_info = new String[]{'fee6split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split3_type_info = new String[]{'fee6split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split4_type_info = new String[]{'fee6split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split1_type_info = new String[]{'fee7split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split2_type_info = new String[]{'fee7split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split3_type_info = new String[]{'fee7split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split4_type_info = new String[]{'fee7split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1name_type_info = new String[]{'fee1name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee2name_type_info = new String[]{'fee2name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee3name_type_info = new String[]{'fee3name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee4name_type_info = new String[]{'fee4name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee5name_type_info = new String[]{'fee5name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee6name_type_info = new String[]{'fee6name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee7name_type_info = new String[]{'fee7name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','GroupName','fee1isamt','fee2isamt','fee3isamt','fee4isamt','fee5isamt','fee6isamt','fee7isamt','fee1payeeid','fee1payeeid2','fee1payeeid3','fee1payeeid4','fee2payeeid','fee2payeeid2','fee2payeeid3','fee2payeeid4','fee3payeeid','fee3payeeid2','fee3payeeid3','fee3payeeid4','fee4payeeid','fee4payeeid2','fee4payeeid3','fee4payeeid4','fee5payeeid','fee5payeeid2','fee5payeeid3','fee5payeeid4','fee6payeeid','fee6payeeid2','fee6payeeid3','fee6payeeid4','fee7payeeid','fee7payeeid2','fee7payeeid3','fee7payeeid4','fee1split1','fee1split2','fee1split3','fee1split4','fee2split1','fee2split2','fee2split3','fee2split4','fee3split1','fee3split2','fee3split3','fee3split4','fee4split1','fee4split2','fee4split3','fee4split4','fee5split1','fee5split2','fee5split3','fee5split4','fee6split1','fee6split2','fee6split3','fee6split4','fee7split1','fee7split2','fee7split3','fee7split4','fee1name','fee2name','fee3name','fee4name','fee5name','fee6name','fee7name'};
    }
    public class AddFeeGroup2_element {
        public String sessid;
        public String GroupName;
        public Boolean fee1isamt;
        public Boolean fee2isamt;
        public Boolean fee3isamt;
        public Boolean fee4isamt;
        public Boolean fee5isamt;
        public Boolean fee6isamt;
        public Boolean fee7isamt;
        public Integer fee1payeeid;
        public Integer fee1payeeid2;
        public Integer fee1payeeid3;
        public Integer fee1payeeid4;
        public Integer fee2payeeid;
        public Integer fee2payeeid2;
        public Integer fee2payeeid3;
        public Integer fee2payeeid4;
        public Integer fee3payeeid;
        public Integer fee3payeeid2;
        public Integer fee3payeeid3;
        public Integer fee3payeeid4;
        public Integer fee4payeeid;
        public Integer fee4payeeid2;
        public Integer fee4payeeid3;
        public Integer fee4payeeid4;
        public Integer fee5payeeid;
        public Integer fee5payeeid2;
        public Integer fee5payeeid3;
        public Integer fee5payeeid4;
        public Integer fee6payeeid;
        public Integer fee6payeeid2;
        public Integer fee6payeeid3;
        public Integer fee6payeeid4;
        public Integer fee7payeeid;
        public Integer fee7payeeid2;
        public Integer fee7payeeid3;
        public Integer fee7payeeid4;
        public Double fee1split1;
        public Double fee1split2;
        public Double fee1split3;
        public Double fee1split4;
        public Double fee2split1;
        public Double fee2split2;
        public Double fee2split3;
        public Double fee2split4;
        public Double fee3split1;
        public Double fee3split2;
        public Double fee3split3;
        public Double fee3split4;
        public Double fee4split1;
        public Double fee4split2;
        public Double fee4split3;
        public Double fee4split4;
        public Double fee5split1;
        public Double fee5split2;
        public Double fee5split3;
        public Double fee5split4;
        public Double fee6split1;
        public Double fee6split2;
        public Double fee6split3;
        public Double fee6split4;
        public Double fee7split1;
        public Double fee7split2;
        public Double fee7split3;
        public Double fee7split4;
        public String fee1name;
        public String fee2name;
        public String fee3name;
        public String fee4name;
        public String fee5name;
        public String fee6name;
        public String fee7name;
        public Boolean holdfee1;
        public Boolean holdfee2;
        public Boolean holdfee3;
        public Boolean holdfee4;
        public Boolean holdfee5;
        public Boolean holdfee6;
        public Boolean holdfee7;
        public Boolean Fee1IEF;
        public Boolean fee2ief;
        public Boolean fee3ief;
        public Boolean fee4ief;
        public Boolean fee5ief;
        public Boolean fee6IEF;
        public Boolean fee7IEF;
        public Boolean fee1LDF;
        public Boolean fee2LDF;
        public Boolean fee3LDF;
        public Boolean fee4LDF;
        public Boolean fee5LDF;
        public Boolean fee6LDF;
        public Boolean fee7LDF;
        public Boolean Iscontingency;
        public Boolean UsesAttorneyFlow;
        public Double LDFAmount;
        public Double OpFeeAmount;
        public Double IEFPercentage;
        public Integer AttorneyAffiliateID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] GroupName_type_info = new String[]{'GroupName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1isamt_type_info = new String[]{'fee1isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2isamt_type_info = new String[]{'fee2isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3isamt_type_info = new String[]{'fee3isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4isamt_type_info = new String[]{'fee4isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5isamt_type_info = new String[]{'fee5isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6isamt_type_info = new String[]{'fee6isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7isamt_type_info = new String[]{'fee7isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee1payeeid_type_info = new String[]{'fee1payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid2_type_info = new String[]{'fee1payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid3_type_info = new String[]{'fee1payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid4_type_info = new String[]{'fee1payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid_type_info = new String[]{'fee2payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid2_type_info = new String[]{'fee2payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid3_type_info = new String[]{'fee2payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid4_type_info = new String[]{'fee2payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid_type_info = new String[]{'fee3payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid2_type_info = new String[]{'fee3payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid3_type_info = new String[]{'fee3payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid4_type_info = new String[]{'fee3payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid_type_info = new String[]{'fee4payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid2_type_info = new String[]{'fee4payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid3_type_info = new String[]{'fee4payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid4_type_info = new String[]{'fee4payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid_type_info = new String[]{'fee5payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid2_type_info = new String[]{'fee5payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid3_type_info = new String[]{'fee5payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid4_type_info = new String[]{'fee5payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid_type_info = new String[]{'fee6payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid2_type_info = new String[]{'fee6payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid3_type_info = new String[]{'fee6payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid4_type_info = new String[]{'fee6payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid_type_info = new String[]{'fee7payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid2_type_info = new String[]{'fee7payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid3_type_info = new String[]{'fee7payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid4_type_info = new String[]{'fee7payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1split1_type_info = new String[]{'fee1split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split2_type_info = new String[]{'fee1split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split3_type_info = new String[]{'fee1split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split4_type_info = new String[]{'fee1split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split1_type_info = new String[]{'fee2split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split2_type_info = new String[]{'fee2split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split3_type_info = new String[]{'fee2split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split4_type_info = new String[]{'fee2split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split1_type_info = new String[]{'fee3split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split2_type_info = new String[]{'fee3split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split3_type_info = new String[]{'fee3split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split4_type_info = new String[]{'fee3split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split1_type_info = new String[]{'fee4split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split2_type_info = new String[]{'fee4split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split3_type_info = new String[]{'fee4split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split4_type_info = new String[]{'fee4split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split1_type_info = new String[]{'fee5split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split2_type_info = new String[]{'fee5split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split3_type_info = new String[]{'fee5split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split4_type_info = new String[]{'fee5split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split1_type_info = new String[]{'fee6split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split2_type_info = new String[]{'fee6split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split3_type_info = new String[]{'fee6split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split4_type_info = new String[]{'fee6split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split1_type_info = new String[]{'fee7split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split2_type_info = new String[]{'fee7split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split3_type_info = new String[]{'fee7split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split4_type_info = new String[]{'fee7split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1name_type_info = new String[]{'fee1name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee2name_type_info = new String[]{'fee2name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee3name_type_info = new String[]{'fee3name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee4name_type_info = new String[]{'fee4name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee5name_type_info = new String[]{'fee5name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee6name_type_info = new String[]{'fee6name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee7name_type_info = new String[]{'fee7name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] holdfee1_type_info = new String[]{'holdfee1','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee2_type_info = new String[]{'holdfee2','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee3_type_info = new String[]{'holdfee3','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee4_type_info = new String[]{'holdfee4','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee5_type_info = new String[]{'holdfee5','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee6_type_info = new String[]{'holdfee6','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee7_type_info = new String[]{'holdfee7','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] Fee1IEF_type_info = new String[]{'Fee1IEF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2ief_type_info = new String[]{'fee2ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3ief_type_info = new String[]{'fee3ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4ief_type_info = new String[]{'fee4ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5ief_type_info = new String[]{'fee5ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6IEF_type_info = new String[]{'fee6IEF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7IEF_type_info = new String[]{'fee7IEF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee1LDF_type_info = new String[]{'fee1LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2LDF_type_info = new String[]{'fee2LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3LDF_type_info = new String[]{'fee3LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4LDF_type_info = new String[]{'fee4LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5LDF_type_info = new String[]{'fee5LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6LDF_type_info = new String[]{'fee6LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7LDF_type_info = new String[]{'fee7LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] Iscontingency_type_info = new String[]{'Iscontingency','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] UsesAttorneyFlow_type_info = new String[]{'UsesAttorneyFlow','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] LDFAmount_type_info = new String[]{'LDFAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] OpFeeAmount_type_info = new String[]{'OpFeeAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] IEFPercentage_type_info = new String[]{'IEFPercentage','http://www.ramservicing.com/','double','1','1','false'};
        private String[] AttorneyAffiliateID_type_info = new String[]{'AttorneyAffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','GroupName','fee1isamt','fee2isamt','fee3isamt','fee4isamt','fee5isamt','fee6isamt','fee7isamt','fee1payeeid','fee1payeeid2','fee1payeeid3','fee1payeeid4','fee2payeeid','fee2payeeid2','fee2payeeid3','fee2payeeid4','fee3payeeid','fee3payeeid2','fee3payeeid3','fee3payeeid4','fee4payeeid','fee4payeeid2','fee4payeeid3','fee4payeeid4','fee5payeeid','fee5payeeid2','fee5payeeid3','fee5payeeid4','fee6payeeid','fee6payeeid2','fee6payeeid3','fee6payeeid4','fee7payeeid','fee7payeeid2','fee7payeeid3','fee7payeeid4','fee1split1','fee1split2','fee1split3','fee1split4','fee2split1','fee2split2','fee2split3','fee2split4','fee3split1','fee3split2','fee3split3','fee3split4','fee4split1','fee4split2','fee4split3','fee4split4','fee5split1','fee5split2','fee5split3','fee5split4','fee6split1','fee6split2','fee6split3','fee6split4','fee7split1','fee7split2','fee7split3','fee7split4','fee1name','fee2name','fee3name','fee4name','fee5name','fee6name','fee7name','holdfee1','holdfee2','holdfee3','holdfee4','holdfee5','holdfee6','holdfee7','Fee1IEF','fee2ief','fee3ief','fee4ief','fee5ief','fee6IEF','fee7IEF','fee1LDF','fee2LDF','fee3LDF','fee4LDF','fee5LDF','fee6LDF','fee7LDF','Iscontingency','UsesAttorneyFlow','LDFAmount','OpFeeAmount','IEFPercentage','AttorneyAffiliateID'};
    }
    public class AddFeeGroup2Response_element {
        public String AddFeeGroup2Result;
        private String[] AddFeeGroup2Result_type_info = new String[]{'AddFeeGroup2Result','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'AddFeeGroup2Result'};
    }
    public class AddFeeGroupResponse_element {
        public String AddFeeGroupResult;
        private String[] AddFeeGroupResult_type_info = new String[]{'AddFeeGroupResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'AddFeeGroupResult'};
    }
    public class AddUpdateClientBanking_element {
        public String sessid;
        public Integer clientid;
        public String Accountnumber;
        public String NameonAccount;
        public String Routing;
        public String bankname;
        public String AccountType;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Accountnumber_type_info = new String[]{'Accountnumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] NameonAccount_type_info = new String[]{'NameonAccount','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Routing_type_info = new String[]{'Routing','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankname_type_info = new String[]{'bankname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AccountType_type_info = new String[]{'AccountType','http://www.ramservicing.com/','BankAccountType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid','Accountnumber','NameonAccount','Routing','bankname','AccountType'};
    }
    public class AddUpdateClientBankingResponse_element {
        public String AddUpdateClientBankingResult;
        private String[] AddUpdateClientBankingResult_type_info = new String[]{'AddUpdateClientBankingResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'AddUpdateClientBankingResult'};
    }
    public class ArrayOfCompany {
        public RAMServiceGateway.Company[] Company;
        private String[] Company_type_info = new String[]{'Company','http://www.ramservicing.com/','Company','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Company'};
    }
    public class ArrayOfDouble {
        public Double[] double_x;
        private String[] double_x_type_info = new String[]{'double','http://www.ramservicing.com/','double','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'double_x'};
    }
    public class ArrayOfPaymentLine {
        public RAMServiceGateway.PaymentLine[] PaymentLine;
        private String[] PaymentLine_type_info = new String[]{'PaymentLine','http://www.ramservicing.com/','PaymentLine','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PaymentLine'};
    }
    public class ArrayOfPaymentLineDetailed {
        public RAMServiceGateway.PaymentLineDetailed[] PaymentLineDetailed;
        private String[] PaymentLineDetailed_type_info = new String[]{'PaymentLineDetailed','http://www.ramservicing.com/','PaymentLineDetailed','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PaymentLineDetailed'};
    }
    public class ArrayOfString {
        public String[] string_x;
        private String[] string_x_type_info = new String[]{'string','http://www.ramservicing.com/','string','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'string_x'};
    }
    public class BAV_VerifyAccount_element {
        public String sessid;
        public String ClientID;
        public Integer FundingSourcePayeeID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] FundingSourcePayeeID_type_info = new String[]{'FundingSourcePayeeID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','FundingSourcePayeeID'};
    }
    public class BAV_VerifyAccount_Update_element {
        public String sessid;
        public String ClientID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID'};
    }
    public class BAV_VerifyAccount_UpdateResponse_element {
        public String BAV_VerifyAccount_UpdateResult;
        private String[] BAV_VerifyAccount_UpdateResult_type_info = new String[]{'BAV_VerifyAccount_UpdateResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'BAV_VerifyAccount_UpdateResult'};
    }
    public class BAV_VerifyAccountResponse_element {
        public String BAV_VerifyAccountResult;
        private String[] BAV_VerifyAccountResult_type_info = new String[]{'BAV_VerifyAccountResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'BAV_VerifyAccountResult'};
    }
    public class CancelDocument_element {
        public String sessid;
        public Double DocumentID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] DocumentID_type_info = new String[]{'DocumentID','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','DocumentID'};
    }
    public class CancelDocumentResponse_element {
        public String CancelDocumentResult;
        private String[] CancelDocumentResult_type_info = new String[]{'CancelDocumentResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'CancelDocumentResult'};
    }
    public class ChangeAccountStatus_element {
        public String sessid;
        public Integer ClientID;
        public String AccountStatus;
        public String AchStatus;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] AccountStatus_type_info = new String[]{'AccountStatus','http://www.ramservicing.com/','AccountStatus','1','1','false'};
        private String[] AchStatus_type_info = new String[]{'AchStatus','http://www.ramservicing.com/','ACHStatus','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','AccountStatus','AchStatus'};
    }
    public class ChangeAccountStatusResponse_element {
        public String ChangeAccountStatusResult;
        private String[] ChangeAccountStatusResult_type_info = new String[]{'ChangeAccountStatusResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ChangeAccountStatusResult'};
    }
    public class ChargeClientCard_element {
        public String sessid;
        public Integer clientID;
        public Integer CardID;
        public String extendedID;
        public Double fee1;
        public Double fee2;
        public Double fee3;
        public Double fee4;
        public Double fee5;
        public Double fee6;
        public Double fee7;
        public Double TotalPaymentAmount;
        public Double savings;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] CardID_type_info = new String[]{'CardID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] extendedID_type_info = new String[]{'extendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1_type_info = new String[]{'fee1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2_type_info = new String[]{'fee2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3_type_info = new String[]{'fee3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4_type_info = new String[]{'fee4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5_type_info = new String[]{'fee5','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6_type_info = new String[]{'fee6','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7_type_info = new String[]{'fee7','http://www.ramservicing.com/','double','1','1','false'};
        private String[] TotalPaymentAmount_type_info = new String[]{'TotalPaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] savings_type_info = new String[]{'savings','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientID','CardID','extendedID','fee1','fee2','fee3','fee4','fee5','fee6','fee7','TotalPaymentAmount','savings'};
    }
    public class ChargeClientCardResponse_element {
        public RAMServiceGateway.ArrayOfString ChargeClientCardResult;
        private String[] ChargeClientCardResult_type_info = new String[]{'ChargeClientCardResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ChargeClientCardResult'};
    }
    public class ChargeClientCardWithCVV_element {
        public String sessid;
        public Integer clientID;
        public Integer CardID;
        public String extendedID;
        public Double fee1;
        public Double fee2;
        public Double fee3;
        public Double fee4;
        public Double fee5;
        public Double fee6;
        public Double fee7;
        public Double TotalPaymentAmount;
        public Double savings;
        public String CVV;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] CardID_type_info = new String[]{'CardID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] extendedID_type_info = new String[]{'extendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1_type_info = new String[]{'fee1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2_type_info = new String[]{'fee2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3_type_info = new String[]{'fee3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4_type_info = new String[]{'fee4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5_type_info = new String[]{'fee5','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6_type_info = new String[]{'fee6','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7_type_info = new String[]{'fee7','http://www.ramservicing.com/','double','1','1','false'};
        private String[] TotalPaymentAmount_type_info = new String[]{'TotalPaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] savings_type_info = new String[]{'savings','http://www.ramservicing.com/','double','1','1','false'};
        private String[] CVV_type_info = new String[]{'CVV','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientID','CardID','extendedID','fee1','fee2','fee3','fee4','fee5','fee6','fee7','TotalPaymentAmount','savings','CVV'};
    }
    public class ChargeClientCardWithCVVResponse_element {
        public RAMServiceGateway.ArrayOfString ChargeClientCardWithCVVResult;
        private String[] ChargeClientCardWithCVVResult_type_info = new String[]{'ChargeClientCardWithCVVResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ChargeClientCardWithCVVResult'};
    }
    public class ChargeFromPayee_element {
        public String sessid;
        public Integer DraftFromID;
        public Integer DepositToID;
        public Integer ClientID;
        public Double Amount;
        public String Notes;
        public String ExternalID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] DraftFromID_type_info = new String[]{'DraftFromID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] DepositToID_type_info = new String[]{'DepositToID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Notes_type_info = new String[]{'Notes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExternalID_type_info = new String[]{'ExternalID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','DraftFromID','DepositToID','ClientID','Amount','Notes','ExternalID'};
    }
    public class ChargeFromPayeeResponse_element {
        public String ChargeFromPayeeResult;
        private String[] ChargeFromPayeeResult_type_info = new String[]{'ChargeFromPayeeResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ChargeFromPayeeResult'};
    }
    public class ClearPaymentSchedule_element {
        public String sessid;
        public Integer clientid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid'};
    }
    public class ClearPaymentScheduleResponse_element {
        public String ClearPaymentScheduleResult;
        private String[] ClearPaymentScheduleResult_type_info = new String[]{'ClearPaymentScheduleResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ClearPaymentScheduleResult'};
    }
    public class ClientDocumentStatus {
        public String Notes;
        public String DocumentStatus;
        private String[] Notes_type_info = new String[]{'Notes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DocumentStatus_type_info = new String[]{'DocumentStatus','http://www.ramservicing.com/','ClientDocumentStatusNumeric','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Notes','DocumentStatus'};
    }
    public class Company {
        public Integer PayeeID;
        public String Name;
        public String AcctLast4;
        public String Routing;
        public String PayeeType;
        private String[] PayeeID_type_info = new String[]{'PayeeID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Name_type_info = new String[]{'Name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AcctLast4_type_info = new String[]{'AcctLast4','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Routing_type_info = new String[]{'Routing','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeType_type_info = new String[]{'PayeeType','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PayeeID','Name','AcctLast4','Routing','PayeeType'};
    }
    public class EndSession_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class EndSessionResponse_element {
        public String EndSessionResult;
        private String[] EndSessionResult_type_info = new String[]{'EndSessionResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'EndSessionResult'};
    }
    public class FundClientBankAccount_element {
        public String sessid;
        public String ClientID;
        public Integer FundingSourcePayeeID;
        public Double Amount;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] FundingSourcePayeeID_type_info = new String[]{'FundingSourcePayeeID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','FundingSourcePayeeID','Amount'};
    }
    public class FundClientBankAccountResponse_element {
        public String FundClientBankAccountResult;
        private String[] FundClientBankAccountResult_type_info = new String[]{'FundClientBankAccountResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'FundClientBankAccountResult'};
    }
    public class FundClientEscrow_element {
        public String sessid;
        public Integer ClientID;
        public Integer FundFromPayeeID;
        public Double Amount;
        public String Notes;
        public String ExtendedID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] FundFromPayeeID_type_info = new String[]{'FundFromPayeeID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Notes_type_info = new String[]{'Notes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','FundFromPayeeID','Amount','Notes','ExtendedID'};
    }
    public class FundClientEscrowResponse_element {
        public String FundClientEscrowResult;
        private String[] FundClientEscrowResult_type_info = new String[]{'FundClientEscrowResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'FundClientEscrowResult'};
    }
    public class GetAllClients_element {
        public String sessid;
        public DateTime FromDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] FromDate_type_info = new String[]{'FromDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','FromDate'};
    }
    public class GetAllClientsResponse_element {
        public RAMServiceGateway.GetAllClientsResponse_GetAllClientsResult_element GetAllClientsResult;
        private String[] GetAllClientsResult_type_info = new String[]{'GetAllClientsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetAllClientsResult'};
    }
    
    //Warning: '<xsd:any>' element type has been changed to dataType List<DOM.XmlNode> called anyElement
    public class GetAllClientsResponse_GetAllClientsResult_element {
        public List<DOM.XmlNode> anyElement;
        private String[] anyElement_type_info = new String[]{'anyElement','http://www.ramservicing.com/','List<DOM.XmlNode>','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'anyElement'};
    }
    public class GetChangedStatusClients_element {
        public String sessid;
        public DateTime AfterDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] AfterDate_type_info = new String[]{'AfterDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','AfterDate'};
    }
    public class GetChangedStatusClientsResponse_element {
        public RAMServiceGateway.GetChangedStatusClientsResponse_GetChangedStatusClientsResult_element GetChangedStatusClientsResult;
        private String[] GetChangedStatusClientsResult_type_info = new String[]{'GetChangedStatusClientsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetChangedStatusClientsResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class GetChangedStatusClientsResponse_GetChangedStatusClientsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientInfo_Bulk_element {
        public String sessid;
        public RAMServiceGateway.ArrayOfString ClientIDs;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientIDs_type_info = new String[]{'ClientIDs','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientIDs'};
    }
    public class GetClientInfo_BulkResponse_element {
        public RAMServiceGateway.GetClientInfo_BulkResponse_GetClientInfo_BulkResult_element GetClientInfo_BulkResult;
        private String[] GetClientInfo_BulkResult_type_info = new String[]{'GetClientInfo_BulkResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientInfo_BulkResult'};
    }
    public class GetClientInfo_BulkResponse_GetClientInfo_BulkResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientInfo_ByDate_element {
        public String sessid;
        public DateTime startdate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] startdate_type_info = new String[]{'startdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','startdate'};
    }
    public class GetClientInfo_ByDateResponse_element {
        public RAMServiceGateway.GetClientInfo_ByDateResponse_GetClientInfo_ByDateResult_element GetClientInfo_ByDateResult;
        private String[] GetClientInfo_ByDateResult_type_info = new String[]{'GetClientInfo_ByDateResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientInfo_ByDateResult'};
    }
    public class GetClientInfo_ByDateResponse_GetClientInfo_ByDateResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientInfo_element {
        public String sessid;
        public Integer clientid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid'};
    }
    public class GetClientInfoResponse_element {
        public RAMServiceGateway.ArrayOfString GetClientInfoResult;
        private String[] GetClientInfoResult_type_info = new String[]{'GetClientInfoResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientInfoResult'};
    }
    public class GetClientLedger_element {
        public String sessid;
        public String ClientID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID'};
    }
    public class GetClientLedgerResponse_element {
        public RAMServiceGateway.GetClientLedgerResponse_GetClientLedgerResult_element GetClientLedgerResult;
        private String[] GetClientLedgerResult_type_info = new String[]{'GetClientLedgerResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientLedgerResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class GetClientLedgerResponse_GetClientLedgerResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientPaymentSchedule_Bulk_element {
        public String sessid;
        public RAMServiceGateway.ArrayOfString ClientIDs;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientIDs_type_info = new String[]{'ClientIDs','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientIDs'};
    }
    public class GetClientPaymentSchedule_BulkResponse_element {
        public RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_GetClientPaymentSchedule_BulkResult_element GetClientPaymentSchedule_BulkResult;
        private String[] GetClientPaymentSchedule_BulkResult_type_info = new String[]{'GetClientPaymentSchedule_BulkResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientPaymentSchedule_BulkResult'};
    }
    public class GetClientPaymentSchedule_BulkResponse_GetClientPaymentSchedule_BulkResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientPaymentSchedule_element {
        public String sessid;
        public Integer clientid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid'};
    }
    public class GetClientPaymentScheduleResponse_element {
        public RAMServiceGateway.ArrayOfPaymentLine GetClientPaymentScheduleResult;
        private String[] GetClientPaymentScheduleResult_type_info = new String[]{'GetClientPaymentScheduleResult','http://www.ramservicing.com/','ArrayOfPaymentLine','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientPaymentScheduleResult'};
    }
    public class GetClientSavings_Bulk_dt_clients_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientSavings_Bulk_element {
        public String sessid;
        public RAMServiceGateway.GetClientSavings_Bulk_dt_clients_element dt_clients;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] dt_clients_type_info = new String[]{'dt_clients','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','dt_clients'};
    }
    public class GetClientSavings_BulkResponse_element {
        public RAMServiceGateway.GetClientSavings_BulkResponse_GetClientSavings_BulkResult_element GetClientSavings_BulkResult;
        private String[] GetClientSavings_BulkResult_type_info = new String[]{'GetClientSavings_BulkResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientSavings_BulkResult'};
    }
    public class GetClientSavings_BulkResponse_GetClientSavings_BulkResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientSavings_ByDate_element {
        public String sessid;
        public DateTime startdate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] startdate_type_info = new String[]{'startdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','startdate'};
    }
    public class GetClientSavings_ByDateResponse_element {
        public RAMServiceGateway.GetClientSavings_ByDateResponse_GetClientSavings_ByDateResult_element GetClientSavings_ByDateResult;
        private String[] GetClientSavings_ByDateResult_type_info = new String[]{'GetClientSavings_ByDateResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientSavings_ByDateResult'};
    }
    public class GetClientSavings_ByDateResponse_GetClientSavings_ByDateResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientSavings_element {
        public String sessid;
        public Integer clientid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid'};
    }
    public class GetClientSavingsResponse_element {
        public RAMServiceGateway.ArrayOfDouble GetClientSavingsResult;
        private String[] GetClientSavingsResult_type_info = new String[]{'GetClientSavingsResult','http://www.ramservicing.com/','ArrayOfDouble','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientSavingsResult'};
    }
    public class GetClientTransactionsByUpdateDate_element {
        public String sessid;
        public DateTime update_date;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] update_date_type_info = new String[]{'update_date','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','update_date'};
    }
    public class GetClientTransactionsByUpdateDateResponse_element {
        public RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_GetClientTransactionsByUpdateDateResult_element GetClientTransactionsByUpdateDateResult;
        private String[] GetClientTransactionsByUpdateDateResult_type_info = new String[]{'GetClientTransactionsByUpdateDateResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientTransactionsByUpdateDateResult'};
    }
    public class GetClientTransactionsByUpdateDateResponse_GetClientTransactionsByUpdateDateResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientTransByClientID_element {
        public String sessid;
        public Integer clientid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid'};
    }
    public class GetClientTransByClientIDResponse_element {
        public RAMServiceGateway.GetClientTransByClientIDResponse_GetClientTransByClientIDResult_element GetClientTransByClientIDResult;
        private String[] GetClientTransByClientIDResult_type_info = new String[]{'GetClientTransByClientIDResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientTransByClientIDResult'};
    }
    public class GetClientTransByClientIDResponse_GetClientTransByClientIDResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientTransByID_element {
        public String sessid;
        public Integer id;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] id_type_info = new String[]{'id','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','id'};
    }
    public class GetClientTransByIDResponse_element {
        public RAMServiceGateway.GetClientTransByIDResponse_GetClientTransByIDResult_element GetClientTransByIDResult;
        private String[] GetClientTransByIDResult_type_info = new String[]{'GetClientTransByIDResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientTransByIDResult'};
    }
    public class GetClientTransByIDResponse_GetClientTransByIDResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetClientTransByPaymentDateRange_element {
        public String sessid;
        public DateTime start_date;
        public DateTime end_date;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] start_date_type_info = new String[]{'start_date','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] end_date_type_info = new String[]{'end_date','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','start_date','end_date'};
    }
    public class GetClientTransByPaymentDateRangeResponse_element {
        public RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_GetClientTransByPaymentDateRangeResult_element GetClientTransByPaymentDateRangeResult;
        private String[] GetClientTransByPaymentDateRangeResult_type_info = new String[]{'GetClientTransByPaymentDateRangeResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetClientTransByPaymentDateRangeResult'};
    }
    public class GetClientTransByPaymentDateRangeResponse_GetClientTransByPaymentDateRangeResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetDocumentStatus_element {
        public String sessid;
        public String ClientID;
        public Double DocumentID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DocumentID_type_info = new String[]{'DocumentID','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','DocumentID'};
    }
    public class GetDocumentStatusResponse_element {
        public RAMServiceGateway.ClientDocumentStatus GetDocumentStatusResult;
        private String[] GetDocumentStatusResult_type_info = new String[]{'GetDocumentStatusResult','http://www.ramservicing.com/','ClientDocumentStatus','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetDocumentStatusResult'};
    }
    public class GetHolidaySchedule_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class GetHolidayScheduleResponse_element {
        public RAMServiceGateway.ArrayOfString GetHolidayScheduleResult;
        private String[] GetHolidayScheduleResult_type_info = new String[]{'GetHolidayScheduleResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetHolidayScheduleResult'};
    }
    public class GetMadePaymentsByClient_element {
        public String sessid;
        public Integer clid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clid_type_info = new String[]{'clid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clid'};
    }
    public class GetMadePaymentsByClientResponse_element {
        public RAMServiceGateway.ArrayOfPaymentLine GetMadePaymentsByClientResult;
        private String[] GetMadePaymentsByClientResult_type_info = new String[]{'GetMadePaymentsByClientResult','http://www.ramservicing.com/','ArrayOfPaymentLine','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetMadePaymentsByClientResult'};
    }
    public class GetMadePaymentsByDate_element {
        public String sessid;
        public DateTime startdate;
        public DateTime enddate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] startdate_type_info = new String[]{'startdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] enddate_type_info = new String[]{'enddate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','startdate','enddate'};
    }
    public class GetMadePaymentsByDateExtended_element {
        public String sessid;
        public DateTime startdate;
        public DateTime enddate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] startdate_type_info = new String[]{'startdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] enddate_type_info = new String[]{'enddate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','startdate','enddate'};
    }
    public class GetMadePaymentsByDateExtendedResponse_element {
        public RAMServiceGateway.ArrayOfPaymentLineDetailed GetMadePaymentsByDateExtendedResult;
        private String[] GetMadePaymentsByDateExtendedResult_type_info = new String[]{'GetMadePaymentsByDateExtendedResult','http://www.ramservicing.com/','ArrayOfPaymentLineDetailed','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetMadePaymentsByDateExtendedResult'};
    }
    public class GetMadePaymentsByDateResponse_element {
        public RAMServiceGateway.ArrayOfPaymentLine GetMadePaymentsByDateResult;
        private String[] GetMadePaymentsByDateResult_type_info = new String[]{'GetMadePaymentsByDateResult','http://www.ramservicing.com/','ArrayOfPaymentLine','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetMadePaymentsByDateResult'};
    }
    public class GetPaymentIDByExtendedID_element {
        public String sessid;
        public String extendedID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] extendedID_type_info = new String[]{'extendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','extendedID'};
    }
    public class GetPaymentIDByExtendedIDResponse_element {
        public RAMServiceGateway.ArrayOfString GetPaymentIDByExtendedIDResult;
        private String[] GetPaymentIDByExtendedIDResult_type_info = new String[]{'GetPaymentIDByExtendedIDResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetPaymentIDByExtendedIDResult'};
    }
    public class GetPaymentStatus_element {
        public String sessid;
        public Integer PaymentScheduleID;
        public Integer clientID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] PaymentScheduleID_type_info = new String[]{'PaymentScheduleID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','PaymentScheduleID','clientID'};
    }
    public class GetPaymentStatusResponse_element {
        public RAMServiceGateway.ArrayOfString GetPaymentStatusResult;
        private String[] GetPaymentStatusResult_type_info = new String[]{'GetPaymentStatusResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetPaymentStatusResult'};
    }
    public class GetPaymentTypeInfo_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class GetPaymentTypeInfoResponse_element {
        public RAMServiceGateway.GetPaymentTypeInfoResponse_GetPaymentTypeInfoResult_element GetPaymentTypeInfoResult;
        private String[] GetPaymentTypeInfoResult_type_info = new String[]{'GetPaymentTypeInfoResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetPaymentTypeInfoResult'};
    }
    public class GetPaymentTypeInfoResponse_GetPaymentTypeInfoResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetRefunds_element {
        public String sessid;
        public DateTime ForDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ForDate_type_info = new String[]{'ForDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ForDate'};
    }
    public class GetRefundsResponse_element {
        public RAMServiceGateway.GetRefundsResponse_GetRefundsResult_element GetRefundsResult;
        private String[] GetRefundsResult_type_info = new String[]{'GetRefundsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetRefundsResult'};
    }
    public class GetRefundsResponse_GetRefundsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetReturns_element {
        public String sessid;
        public DateTime ForDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ForDate_type_info = new String[]{'ForDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ForDate'};
    }
    public class GetReturnsDateRange_element {
        public String sessid;
        public DateTime start_date;
        public DateTime end_date;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] start_date_type_info = new String[]{'start_date','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] end_date_type_info = new String[]{'end_date','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','start_date','end_date'};
    }
    public class GetReturnsDateRangeResponse_element {
        public RAMServiceGateway.GetReturnsDateRangeResponse_GetReturnsDateRangeResult_element GetReturnsDateRangeResult;
        private String[] GetReturnsDateRangeResult_type_info = new String[]{'GetReturnsDateRangeResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetReturnsDateRangeResult'};
    }
    public class GetReturnsDateRangeResponse_GetReturnsDateRangeResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetReturnsResponse_element {
        public RAMServiceGateway.GetReturnsResponse_GetReturnsResult_element GetReturnsResult;
        private String[] GetReturnsResult_type_info = new String[]{'GetReturnsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetReturnsResult'};
    }
    public class GetReturnsResponse_GetReturnsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetSettlements_Bulk_element {
        public String sessid;
        public RAMServiceGateway.ArrayOfString ClientIDs;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientIDs_type_info = new String[]{'ClientIDs','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientIDs'};
    }
    public class GetSettlements_BulkResponse_element {
        public RAMServiceGateway.GetSettlements_BulkResponse_GetSettlements_BulkResult_element GetSettlements_BulkResult;
        private String[] GetSettlements_BulkResult_type_info = new String[]{'GetSettlements_BulkResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetSettlements_BulkResult'};
    }
    public class GetSettlements_BulkResponse_GetSettlements_BulkResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetUpdatedSavings_element {
        public String sessid;
        public DateTime FromDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] FromDate_type_info = new String[]{'FromDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','FromDate'};
    }
    public class GetUpdatedSavingsResponse_element {
        public RAMServiceGateway.GetUpdatedSavingsResponse_GetUpdatedSavingsResult_element GetUpdatedSavingsResult;
        private String[] GetUpdatedSavingsResult_type_info = new String[]{'GetUpdatedSavingsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetUpdatedSavingsResult'};
    }
    public class GetUpdatedSavingsResponse_GetUpdatedSavingsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class GetVendorCurrentFees_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class GetVendorCurrentFeesResponse_element {
        public RAMServiceGateway.GetVendorCurrentFeesResponse_GetVendorCurrentFeesResult_element GetVendorCurrentFeesResult;
        private String[] GetVendorCurrentFeesResult_type_info = new String[]{'GetVendorCurrentFeesResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'GetVendorCurrentFeesResult'};
    }
    public class GetVendorCurrentFeesResponse_GetVendorCurrentFeesResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ListAllPayees_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class ListAllPayeesResponse_element {
        public RAMServiceGateway.ArrayOfCompany ListAllPayeesResult;
        private String[] ListAllPayeesResult_type_info = new String[]{'ListAllPayeesResult','http://www.ramservicing.com/','ArrayOfCompany','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ListAllPayeesResult'};
    }
    public class NewClient_element {
        public String sessid;
        public Integer ClientID;
        public String Firstname;
        public String Lastname;
        public String FirstName2;
        public String lastname2;
        public String EmailAddress;
        public String TaxID;
        public String TaxID2;
        public String StreetAddress;
        public String City;
        public String ZIP;
        public String StateAbbreviation;
        public String StreetAddress2;
        public String City2;
        public String ZIP2;
        public String StateAbbreviation2;
        public String Phone1;
        public String Phone2;
        public String Phone3;
        public String DOB1;
        public String DOB2;
        public String AccountStatus;
        public Integer AffiliateID;
        public Integer FeeSplitGroupID;
        public String AccountHoldStatus;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Firstname_type_info = new String[]{'Firstname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Lastname_type_info = new String[]{'Lastname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] FirstName2_type_info = new String[]{'FirstName2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] lastname2_type_info = new String[]{'lastname2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxID_type_info = new String[]{'TaxID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxID2_type_info = new String[]{'TaxID2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StreetAddress_type_info = new String[]{'StreetAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] City_type_info = new String[]{'City','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP_type_info = new String[]{'ZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbreviation_type_info = new String[]{'StateAbbreviation','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StreetAddress2_type_info = new String[]{'StreetAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] City2_type_info = new String[]{'City2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP2_type_info = new String[]{'ZIP2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbreviation2_type_info = new String[]{'StateAbbreviation2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone1_type_info = new String[]{'Phone1','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone2_type_info = new String[]{'Phone2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone3_type_info = new String[]{'Phone3','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DOB1_type_info = new String[]{'DOB1','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DOB2_type_info = new String[]{'DOB2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AccountStatus_type_info = new String[]{'AccountStatus','http://www.ramservicing.com/','AccountStatus','1','1','false'};
        private String[] AffiliateID_type_info = new String[]{'AffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] FeeSplitGroupID_type_info = new String[]{'FeeSplitGroupID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] AccountHoldStatus_type_info = new String[]{'AccountHoldStatus','http://www.ramservicing.com/','ACHStatus','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','Firstname','Lastname','FirstName2','lastname2','EmailAddress','TaxID','TaxID2','StreetAddress','City','ZIP','StateAbbreviation','StreetAddress2','City2','ZIP2','StateAbbreviation2','Phone1','Phone2','Phone3','DOB1','DOB2','AccountStatus','AffiliateID','FeeSplitGroupID','AccountHoldStatus'};
    }
    public class NewClientResponse_element {
        public RAMServiceGateway.ArrayOfString NewClientResult;
        private String[] NewClientResult_type_info = new String[]{'NewClientResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'NewClientResult'};
    }
    public class PayFromClientTrust_element {
        public String sessid;
        public Integer ClientID;
        public Double Amount;
        public Integer PayeeID;
        public String Description;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PayeeID_type_info = new String[]{'PayeeID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Description_type_info = new String[]{'Description','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','Amount','PayeeID','Description'};
    }
    public class PayFromClientTrust_Extended_element {
        public String sessid;
        public Integer ClientID;
        public Double Amount;
        public Integer PayeeID;
        public String Description;
        public String ExternalID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PayeeID_type_info = new String[]{'PayeeID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Description_type_info = new String[]{'Description','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExternalID_type_info = new String[]{'ExternalID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','Amount','PayeeID','Description','ExternalID'};
    }
    public class PayFromClientTrust_ExtendedResponse_element {
        public String PayFromClientTrust_ExtendedResult;
        private String[] PayFromClientTrust_ExtendedResult_type_info = new String[]{'PayFromClientTrust_ExtendedResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PayFromClientTrust_ExtendedResult'};
    }
    public class PayFromClientTrustResponse_element {
        public String PayFromClientTrustResult;
        private String[] PayFromClientTrustResult_type_info = new String[]{'PayFromClientTrustResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PayFromClientTrustResult'};
    }
    public class PayFromClientTrustWithSplits_element {
        public String SessID;
        public Integer ClientID;
        public Double Fee1Amt;
        public Double Fee2Amt;
        public Double Fee3Amt;
        public Double Fee4Amt;
        public Double Fee5Amt;
        public Double Fee6Amt;
        public Double Fee7Amt;
        public String Description;
        public String ExternalID;
        private String[] SessID_type_info = new String[]{'SessID','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Fee1Amt_type_info = new String[]{'Fee1Amt','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee2Amt_type_info = new String[]{'Fee2Amt','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee3Amt_type_info = new String[]{'Fee3Amt','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee4Amt_type_info = new String[]{'Fee4Amt','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee5Amt_type_info = new String[]{'Fee5Amt','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee6Amt_type_info = new String[]{'Fee6Amt','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee7Amt_type_info = new String[]{'Fee7Amt','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Description_type_info = new String[]{'Description','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExternalID_type_info = new String[]{'ExternalID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SessID','ClientID','Fee1Amt','Fee2Amt','Fee3Amt','Fee4Amt','Fee5Amt','Fee6Amt','Fee7Amt','Description','ExternalID'};
    }
    public class PayFromClientTrustWithSplitsResponse_element {
        public String PayFromClientTrustWithSplitsResult;
        private String[] PayFromClientTrustWithSplitsResult_type_info = new String[]{'PayFromClientTrustWithSplitsResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PayFromClientTrustWithSplitsResult'};
    }
    public class PaymentLine {
        public DateTime SchedDate;
        public Double Fee1Amount;
        public Double Fee2Amount;
        public Double Fee3Amount;
        public Double Fee4Amount;
        public Double Fee5Amount;
        public Double Fee6Amount;
        public Double Fee7Amount;
        public Double SavingsAmount;
        public Double TotalPaymentAmount;
        public Boolean Paid;
        public Boolean Returned;
        public Double RAMFEE;
        public Integer PID;
        private String[] SchedDate_type_info = new String[]{'SchedDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] Fee1Amount_type_info = new String[]{'Fee1Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee2Amount_type_info = new String[]{'Fee2Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee3Amount_type_info = new String[]{'Fee3Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee4Amount_type_info = new String[]{'Fee4Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee5Amount_type_info = new String[]{'Fee5Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee6Amount_type_info = new String[]{'Fee6Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee7Amount_type_info = new String[]{'Fee7Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] SavingsAmount_type_info = new String[]{'SavingsAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] TotalPaymentAmount_type_info = new String[]{'TotalPaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Paid_type_info = new String[]{'Paid','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] Returned_type_info = new String[]{'Returned','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] RAMFEE_type_info = new String[]{'RAMFEE','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PID_type_info = new String[]{'PID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SchedDate','Fee1Amount','Fee2Amount','Fee3Amount','Fee4Amount','Fee5Amount','Fee6Amount','Fee7Amount','SavingsAmount','TotalPaymentAmount','Paid','Returned','RAMFEE','PID'};
    }
    public class PaymentLineDetailed {
        public DateTime SchedDate;
        public Double Fee1Amount;
        public Double Fee2Amount;
        public Double Fee3Amount;
        public Double Fee4Amount;
        public Double Fee5Amount;
        public Double Fee6Amount;
        public Double Fee7Amount;
        public Double SavingsAmount;
        public Double TotalPaymentAmount;
        public Boolean Paid;
        public Boolean Returned;
        public Double RAMFEE;
        public Integer PID;
        public Integer ClientID;
        public String Action;
        public String ACH;
        public String Status;
        public String Notes;
        public DateTime PostDate;
        private String[] SchedDate_type_info = new String[]{'SchedDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] Fee1Amount_type_info = new String[]{'Fee1Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee2Amount_type_info = new String[]{'Fee2Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee3Amount_type_info = new String[]{'Fee3Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee4Amount_type_info = new String[]{'Fee4Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee5Amount_type_info = new String[]{'Fee5Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee6Amount_type_info = new String[]{'Fee6Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Fee7Amount_type_info = new String[]{'Fee7Amount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] SavingsAmount_type_info = new String[]{'SavingsAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] TotalPaymentAmount_type_info = new String[]{'TotalPaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] Paid_type_info = new String[]{'Paid','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] Returned_type_info = new String[]{'Returned','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] RAMFEE_type_info = new String[]{'RAMFEE','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PID_type_info = new String[]{'PID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Action_type_info = new String[]{'Action','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ACH_type_info = new String[]{'ACH','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Status_type_info = new String[]{'Status','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Notes_type_info = new String[]{'Notes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PostDate_type_info = new String[]{'PostDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SchedDate','Fee1Amount','Fee2Amount','Fee3Amount','Fee4Amount','Fee5Amount','Fee6Amount','Fee7Amount','SavingsAmount','TotalPaymentAmount','Paid','Returned','RAMFEE','PID','ClientID','Action','ACH','Status','Notes','PostDate'};
    }
    public class PayScheduleAddSingle_element {
        public String Sessid;
        public Integer clientID;
        public String extendedID;
        public Double fee1;
        public Double fee2;
        public Double fee3;
        public Double fee4;
        public Double fee5;
        public Double fee6;
        public Double fee7;
        public Double TotalPaymentAmount;
        public Double savings;
        public DateTime paymentdate;
        private String[] Sessid_type_info = new String[]{'Sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] extendedID_type_info = new String[]{'extendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1_type_info = new String[]{'fee1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2_type_info = new String[]{'fee2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3_type_info = new String[]{'fee3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4_type_info = new String[]{'fee4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5_type_info = new String[]{'fee5','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6_type_info = new String[]{'fee6','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7_type_info = new String[]{'fee7','http://www.ramservicing.com/','double','1','1','false'};
        private String[] TotalPaymentAmount_type_info = new String[]{'TotalPaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] savings_type_info = new String[]{'savings','http://www.ramservicing.com/','double','1','1','false'};
        private String[] paymentdate_type_info = new String[]{'paymentdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Sessid','clientID','extendedID','fee1','fee2','fee3','fee4','fee5','fee6','fee7','TotalPaymentAmount','savings','paymentdate'};
    }
    public class PayScheduleAddSingleResponse_element {
        public RAMServiceGateway.ArrayOfString PayScheduleAddSingleResult;
        private String[] PayScheduleAddSingleResult_type_info = new String[]{'PayScheduleAddSingleResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PayScheduleAddSingleResult'};
    }
    public class PayScheduleCreate_element {
        public String sessid;
        public Integer ClientID;
        public RAMServiceGateway.ArrayOfPaymentLine PaySchedule;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PaySchedule_type_info = new String[]{'PaySchedule','http://www.ramservicing.com/','ArrayOfPaymentLine','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','PaySchedule'};
    }
    public class PayScheduleCreateResponse_element {
        public RAMServiceGateway.ArrayOfPaymentLine PayScheduleCreateResult;
        private String[] PayScheduleCreateResult_type_info = new String[]{'PayScheduleCreateResult','http://www.ramservicing.com/','ArrayOfPaymentLine','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PayScheduleCreateResult'};
    }
    public class PayScheduleUpdateSingle_element {
        public String Sessid;
        public Integer clientID;
        public Integer PID;
        public Double fee1;
        public Double fee2;
        public Double fee3;
        public Double fee4;
        public Double fee5;
        public Double fee6;
        public Double fee7;
        public Double savings;
        public DateTime paymentdate;
        public Double TotalPaymentAmount;
        private String[] Sessid_type_info = new String[]{'Sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PID_type_info = new String[]{'PID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1_type_info = new String[]{'fee1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2_type_info = new String[]{'fee2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3_type_info = new String[]{'fee3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4_type_info = new String[]{'fee4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5_type_info = new String[]{'fee5','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6_type_info = new String[]{'fee6','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7_type_info = new String[]{'fee7','http://www.ramservicing.com/','double','1','1','false'};
        private String[] savings_type_info = new String[]{'savings','http://www.ramservicing.com/','double','1','1','false'};
        private String[] paymentdate_type_info = new String[]{'paymentdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] TotalPaymentAmount_type_info = new String[]{'TotalPaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Sessid','clientID','PID','fee1','fee2','fee3','fee4','fee5','fee6','fee7','savings','paymentdate','TotalPaymentAmount'};
    }
    public class PayScheduleUpdateSingleResponse_element {
        public RAMServiceGateway.ArrayOfString PayScheduleUpdateSingleResult;
        private String[] PayScheduleUpdateSingleResult_type_info = new String[]{'PayScheduleUpdateSingleResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PayScheduleUpdateSingleResult'};
    }
    public class PendingFees_Remove_element {
        public String sessid;
        public Integer PendingFeeID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] PendingFeeID_type_info = new String[]{'PendingFeeID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','PendingFeeID'};
    }
    public class PendingFees_RemoveResponse_element {
        public String PendingFees_RemoveResult;
        private String[] PendingFees_RemoveResult_type_info = new String[]{'PendingFees_RemoveResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PendingFees_RemoveResult'};
    }
    public class PendingFees_Show_element {
        public String sessid;
        public String ClientID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID'};
    }
    public class PendingFees_ShowAll_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class PendingFees_ShowAllResponse_element {
        public RAMServiceGateway.PendingFees_ShowAllResponse_PendingFees_ShowAllResult_element PendingFees_ShowAllResult;
        private String[] PendingFees_ShowAllResult_type_info = new String[]{'PendingFees_ShowAllResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PendingFees_ShowAllResult'};
    }
    public class PendingFees_ShowAllResponse_PendingFees_ShowAllResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class PendingFees_ShowResponse_element {
        public RAMServiceGateway.PendingFees_ShowResponse_PendingFees_ShowResult_element PendingFees_ShowResult;
        private String[] PendingFees_ShowResult_type_info = new String[]{'PendingFees_ShowResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'PendingFees_ShowResult'};
    }
    public class PendingFees_ShowResponse_PendingFees_ShowResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }

    public class RAMSGatewayVer2Soap {
        public String endpoint_x;
        public String mClientKey;
        public String mSettingsKey;
        Map<String, RAMSAPISetting__c> mRamAPISettingMap;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://www.ramservicing.com/','RAMServiceGateway','http://microsoft.com/wsdl/types/','microsoftComWsdlTypes'};

            public  RAMSGatewayVer2Soap(){
                
                if(Test.isRunningTest()){
                    mRamAPISettingMap = new map <String, RAMSAPISetting__c>();
                    endpoint_x = 'https://staging.ramservicing.com/services/RAMSGatewayVer2.asmx';
                    mClientKey = 'ECF71013-E596-4041-ADFE-32D88C418358';
                    
                    RAMSAPISetting__c ramsAPISetting = new RAMSAPISetting__c();
                    ramsAPISetting.name = fsCore.Constants.ORG_TYPE_TEST;
                    ramsAPISetting.Client_Key__c = 'ECF71013-E596-4041-ADFE-32D88C418358';
                    ramsAPISetting.Default_DSCID__c = '1';
                    ramsAPISetting.Default_Group_ID__c = '2461';
                    ramsAPISetting.Endpoint_URI__c = 'https://staging.ramservicing.com/services/RAMSGatewayVer2.asmx';
                    ramsAPISetting.Is_Exception_Logging_Enabled__c = true;                  
                    
                    mRamAPISettingMap.put('TEST',ramsAPISetting);
                    mRamAPISettingMap.put('LIVE',ramsAPISetting);
                    
	                mSettingsKey = 'LIVE';
	                if (SFSUtil.getIsSandbox()){
	                    mSettingsKey = 'TEST';
	                }                    
                    
                }else{
                    mRamAPISettingMap = RAMSAPISetting__c.getAll();
                    
                    if (mRamAPISettingMap.size() == 0){
                        throw new RAMSGatewayVer2SoapException('RAM API Settings not defined.');
                    }
                    mSettingsKey = 'LIVE';
                    if (SFSUtil.getIsSandbox()){
                        mSettingsKey = 'TEST';
                    }
                    
                    system.debug(logginglevel.error,'mSettingsKey is '+mSettingsKey);
                    system.debug(logginglevel.error,'mSettingsKey is '+mRamAPISettingMap.get(mSettingsKey));
                    
                    endpoint_x = mRamAPISettingMap.get(mSettingsKey).Endpoint_URI__c;
                    mClientKey = mRamAPISettingMap.get(mSettingsKey).Client_Key__c;
                    
                    system.debug(logginglevel.error,'endpoint_x :'+endpoint_x);
                    system.debug(logginglevel.error,'mClientKey :'+mClientKey);
                }
                
                
            }
        public String AddAffiliate(String sessid,String Name,String Address,String city,String StateAbbrev,String ZIP,String Phone,String NameonAccount,String bankrouting,String BankaccountNumber,String accounttype,String bankname,String bankcity,String bankphone,String bankstateabbrev,String bankzip) {
            RAMServiceGateway.AddAffiliate_element request_x = new RAMServiceGateway.AddAffiliate_element();
            RAMServiceGateway.AddAffiliateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.Name = Name;
            request_x.Address = Address;
            request_x.city = city;
            request_x.StateAbbrev = StateAbbrev;
            request_x.ZIP = ZIP;
            request_x.Phone = Phone;
            request_x.NameonAccount = NameonAccount;
            request_x.bankrouting = bankrouting;
            request_x.BankaccountNumber = BankaccountNumber;
            request_x.accounttype = accounttype;
            request_x.bankname = bankname;
            request_x.bankcity = bankcity;
            request_x.bankphone = bankphone;
            request_x.bankstateabbrev = bankstateabbrev;
            request_x.bankzip = bankzip;
            Map<String, RAMServiceGateway.AddAffiliateResponse_element> response_map_x = new Map<String, RAMServiceGateway.AddAffiliateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/AddAffiliate',
                'http://www.ramservicing.com/',
                'AddAffiliate',
                'http://www.ramservicing.com/',
                'AddAffiliateResponse',
                'RAMServiceGateway.AddAffiliateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AddAffiliateResult;
        }

        public Integer AddClientCard(String sessid,Integer ClientID,String CardNum,Integer CardExpiryMonth,Integer CardExpiryYear) {
            RAMServiceGateway.AddClientCard_element request_x = new RAMServiceGateway.AddClientCard_element();
            RAMServiceGateway.AddClientCardResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.CardNum = CardNum;
            request_x.CardExpiryMonth = CardExpiryMonth;
            request_x.CardExpiryYear = CardExpiryYear;
            Map<String, RAMServiceGateway.AddClientCardResponse_element> response_map_x = new Map<String, RAMServiceGateway.AddClientCardResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/AddClientCard',
                'http://www.ramservicing.com/',
                'AddClientCard',
                'http://www.ramservicing.com/',
                'AddClientCardResponse',
                'RAMServiceGateway.AddClientCardResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AddClientCardResult;
        }

        /*public String AddFeeGroup(String sessid,String GroupName,Boolean fee1isamt,Boolean fee2isamt,Boolean fee3isamt,Boolean fee4isamt,Boolean fee5isamt,Boolean fee6isamt,Boolean fee7isamt,Integer fee1payeeid,Integer fee1payeeid2,Integer fee1payeeid3,Integer fee1payeeid4,Integer fee2payeeid,Integer fee2payeeid2,Integer fee2payeeid3,Integer fee2payeeid4,Integer fee3payeeid,Integer fee3payeeid2,Integer fee3payeeid3,Integer fee3payeeid4,Integer fee4payeeid,Integer fee4payeeid2,Integer fee4payeeid3,Integer fee4payeeid4,Integer fee5payeeid,Integer fee5payeeid2,Integer fee5payeeid3,Integer fee5payeeid4,Integer fee6payeeid,Integer fee6payeeid2,Integer fee6payeeid3,Integer fee6payeeid4,Integer fee7payeeid,Integer fee7payeeid2,Integer fee7payeeid3,Integer fee7payeeid4,Double fee1split1,Double fee1split2,Double fee1split3,Double fee1split4,Double fee2split1,Double fee2split2,Double fee2split3,Double fee2split4,Double fee3split1,Double fee3split2,Double fee3split3,Double fee3split4,Double fee4split1,Double fee4split2,Double fee4split3,Double fee4split4,Double fee5split1,Double fee5split2,Double fee5split3,Double fee5split4,Double fee6split1,Double fee6split2,Double fee6split3,Double fee6split4,Double fee7split1,Double fee7split2,Double fee7split3,Double fee7split4,String fee1name,String fee2name,String fee3name,String fee4name,String fee5name,String fee6name,String fee7name) {
            RAMServiceGateway.AddFeeGroup_element request_x = new RAMServiceGateway.AddFeeGroup_element();
            RAMServiceGateway.AddFeeGroupResponse_element response_x;
            request_x.sessid = sessid;
            request_x.GroupName = GroupName;
            request_x.fee1isamt = fee1isamt;
            request_x.fee2isamt = fee2isamt;
            request_x.fee3isamt = fee3isamt;
            request_x.fee4isamt = fee4isamt;
            request_x.fee5isamt = fee5isamt;
            request_x.fee6isamt = fee6isamt;
            request_x.fee7isamt = fee7isamt;
            request_x.fee1payeeid = fee1payeeid;
            request_x.fee1payeeid2 = fee1payeeid2;
            request_x.fee1payeeid3 = fee1payeeid3;
            request_x.fee1payeeid4 = fee1payeeid4;
            request_x.fee2payeeid = fee2payeeid;
            request_x.fee2payeeid2 = fee2payeeid2;
            request_x.fee2payeeid3 = fee2payeeid3;
            request_x.fee2payeeid4 = fee2payeeid4;
            request_x.fee3payeeid = fee3payeeid;
            request_x.fee3payeeid2 = fee3payeeid2;
            request_x.fee3payeeid3 = fee3payeeid3;
            request_x.fee3payeeid4 = fee3payeeid4;
            request_x.fee4payeeid = fee4payeeid;
            request_x.fee4payeeid2 = fee4payeeid2;
            request_x.fee4payeeid3 = fee4payeeid3;
            request_x.fee4payeeid4 = fee4payeeid4;
            request_x.fee5payeeid = fee5payeeid;
            request_x.fee5payeeid2 = fee5payeeid2;
            request_x.fee5payeeid3 = fee5payeeid3;
            request_x.fee5payeeid4 = fee5payeeid4;
            request_x.fee6payeeid = fee6payeeid;
            request_x.fee6payeeid2 = fee6payeeid2;
            request_x.fee6payeeid3 = fee6payeeid3;
            request_x.fee6payeeid4 = fee6payeeid4;
            request_x.fee7payeeid = fee7payeeid;
            request_x.fee7payeeid2 = fee7payeeid2;
            request_x.fee7payeeid3 = fee7payeeid3;
            request_x.fee7payeeid4 = fee7payeeid4;
            request_x.fee1split1 = fee1split1;
            request_x.fee1split2 = fee1split2;
            request_x.fee1split3 = fee1split3;
            request_x.fee1split4 = fee1split4;
            request_x.fee2split1 = fee2split1;
            request_x.fee2split2 = fee2split2;
            request_x.fee2split3 = fee2split3;
            request_x.fee2split4 = fee2split4;
            request_x.fee3split1 = fee3split1;
            request_x.fee3split2 = fee3split2;
            request_x.fee3split3 = fee3split3;
            request_x.fee3split4 = fee3split4;
            request_x.fee4split1 = fee4split1;
            request_x.fee4split2 = fee4split2;
            request_x.fee4split3 = fee4split3;
            request_x.fee4split4 = fee4split4;
            request_x.fee5split1 = fee5split1;
            request_x.fee5split2 = fee5split2;
            request_x.fee5split3 = fee5split3;
            request_x.fee5split4 = fee5split4;
            request_x.fee6split1 = fee6split1;
            request_x.fee6split2 = fee6split2;
            request_x.fee6split3 = fee6split3;
            request_x.fee6split4 = fee6split4;
            request_x.fee7split1 = fee7split1;
            request_x.fee7split2 = fee7split2;
            request_x.fee7split3 = fee7split3;
            request_x.fee7split4 = fee7split4;
            request_x.fee1name = fee1name;
            request_x.fee2name = fee2name;
            request_x.fee3name = fee3name;
            request_x.fee4name = fee4name;
            request_x.fee5name = fee5name;
            request_x.fee6name = fee6name;
            request_x.fee7name = fee7name;
            Map<String, RAMServiceGateway.AddFeeGroupResponse_element> response_map_x = new Map<String, RAMServiceGateway.AddFeeGroupResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/AddFeeGroup',
                'http://www.ramservicing.com/',
                'AddFeeGroup',
                'http://www.ramservicing.com/',
                'AddFeeGroupResponse',
                'RAMServiceGateway.AddFeeGroupResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AddFeeGroupResult;
        }

        public String AddFeeGroup2(String sessid,String GroupName,Boolean fee1isamt,Boolean fee2isamt,Boolean fee3isamt,Boolean fee4isamt,Boolean fee5isamt,Boolean fee6isamt,Boolean fee7isamt,Integer fee1payeeid,Integer fee1payeeid2,Integer fee1payeeid3,Integer fee1payeeid4,Integer fee2payeeid,Integer fee2payeeid2,Integer fee2payeeid3,Integer fee2payeeid4,Integer fee3payeeid,Integer fee3payeeid2,Integer fee3payeeid3,Integer fee3payeeid4,Integer fee4payeeid,Integer fee4payeeid2,Integer fee4payeeid3,Integer fee4payeeid4,Integer fee5payeeid,Integer fee5payeeid2,Integer fee5payeeid3,Integer fee5payeeid4,Integer fee6payeeid,Integer fee6payeeid2,Integer fee6payeeid3,Integer fee6payeeid4,Integer fee7payeeid,Integer fee7payeeid2,Integer fee7payeeid3,Integer fee7payeeid4,Double fee1split1,Double fee1split2,Double fee1split3,Double fee1split4,Double fee2split1,Double fee2split2,Double fee2split3,Double fee2split4,Double fee3split1,Double fee3split2,Double fee3split3,Double fee3split4,Double fee4split1,Double fee4split2,Double fee4split3,Double fee4split4,Double fee5split1,Double fee5split2,Double fee5split3,Double fee5split4,Double fee6split1,Double fee6split2,Double fee6split3,Double fee6split4,Double fee7split1,Double fee7split2,Double fee7split3,Double fee7split4,String fee1name,String fee2name,String fee3name,String fee4name,String fee5name,String fee6name,String fee7name,Boolean holdfee1,Boolean holdfee2,Boolean holdfee3,Boolean holdfee4,Boolean holdfee5,Boolean holdfee6,Boolean holdfee7,Boolean Fee1IEF,Boolean fee2ief,Boolean fee3ief,Boolean fee4ief,Boolean fee5ief,Boolean fee6IEF,Boolean fee7IEF,Boolean fee1LDF,Boolean fee2LDF,Boolean fee3LDF,Boolean fee4LDF,Boolean fee5LDF,Boolean fee6LDF,Boolean fee7LDF,Boolean Iscontingency,Boolean UsesAttorneyFlow,Double LDFAmount,Double OpFeeAmount,Double IEFPercentage,Integer AttorneyAffiliateID) {
            RAMServiceGateway.AddFeeGroup2_element request_x = new RAMServiceGateway.AddFeeGroup2_element();
            RAMServiceGateway.AddFeeGroup2Response_element response_x;
            request_x.sessid = sessid;
            request_x.GroupName = GroupName;
            request_x.fee1isamt = fee1isamt;
            request_x.fee2isamt = fee2isamt;
            request_x.fee3isamt = fee3isamt;
            request_x.fee4isamt = fee4isamt;
            request_x.fee5isamt = fee5isamt;
            request_x.fee6isamt = fee6isamt;
            request_x.fee7isamt = fee7isamt;
            request_x.fee1payeeid = fee1payeeid;
            request_x.fee1payeeid2 = fee1payeeid2;
            request_x.fee1payeeid3 = fee1payeeid3;
            request_x.fee1payeeid4 = fee1payeeid4;
            request_x.fee2payeeid = fee2payeeid;
            request_x.fee2payeeid2 = fee2payeeid2;
            request_x.fee2payeeid3 = fee2payeeid3;
            request_x.fee2payeeid4 = fee2payeeid4;
            request_x.fee3payeeid = fee3payeeid;
            request_x.fee3payeeid2 = fee3payeeid2;
            request_x.fee3payeeid3 = fee3payeeid3;
            request_x.fee3payeeid4 = fee3payeeid4;
            request_x.fee4payeeid = fee4payeeid;
            request_x.fee4payeeid2 = fee4payeeid2;
            request_x.fee4payeeid3 = fee4payeeid3;
            request_x.fee4payeeid4 = fee4payeeid4;
            request_x.fee5payeeid = fee5payeeid;
            request_x.fee5payeeid2 = fee5payeeid2;
            request_x.fee5payeeid3 = fee5payeeid3;
            request_x.fee5payeeid4 = fee5payeeid4;
            request_x.fee6payeeid = fee6payeeid;
            request_x.fee6payeeid2 = fee6payeeid2;
            request_x.fee6payeeid3 = fee6payeeid3;
            request_x.fee6payeeid4 = fee6payeeid4;
            request_x.fee7payeeid = fee7payeeid;
            request_x.fee7payeeid2 = fee7payeeid2;
            request_x.fee7payeeid3 = fee7payeeid3;
            request_x.fee7payeeid4 = fee7payeeid4;
            request_x.fee1split1 = fee1split1;
            request_x.fee1split2 = fee1split2;
            request_x.fee1split3 = fee1split3;
            request_x.fee1split4 = fee1split4;
            request_x.fee2split1 = fee2split1;
            request_x.fee2split2 = fee2split2;
            request_x.fee2split3 = fee2split3;
            request_x.fee2split4 = fee2split4;
            request_x.fee3split1 = fee3split1;
            request_x.fee3split2 = fee3split2;
            request_x.fee3split3 = fee3split3;
            request_x.fee3split4 = fee3split4;
            request_x.fee4split1 = fee4split1;
            request_x.fee4split2 = fee4split2;
            request_x.fee4split3 = fee4split3;
            request_x.fee4split4 = fee4split4;
            request_x.fee5split1 = fee5split1;
            request_x.fee5split2 = fee5split2;
            request_x.fee5split3 = fee5split3;
            request_x.fee5split4 = fee5split4;
            request_x.fee6split1 = fee6split1;
            request_x.fee6split2 = fee6split2;
            request_x.fee6split3 = fee6split3;
            request_x.fee6split4 = fee6split4;
            request_x.fee7split1 = fee7split1;
            request_x.fee7split2 = fee7split2;
            request_x.fee7split3 = fee7split3;
            request_x.fee7split4 = fee7split4;
            request_x.fee1name = fee1name;
            request_x.fee2name = fee2name;
            request_x.fee3name = fee3name;
            request_x.fee4name = fee4name;
            request_x.fee5name = fee5name;
            request_x.fee6name = fee6name;
            request_x.fee7name = fee7name;
            request_x.holdfee1 = holdfee1;
            request_x.holdfee2 = holdfee2;
            request_x.holdfee3 = holdfee3;
            request_x.holdfee4 = holdfee4;
            request_x.holdfee5 = holdfee5;
            request_x.holdfee6 = holdfee6;
            request_x.holdfee7 = holdfee7;
            request_x.Fee1IEF = Fee1IEF;
            request_x.fee2ief = fee2ief;
            request_x.fee3ief = fee3ief;
            request_x.fee4ief = fee4ief;
            request_x.fee5ief = fee5ief;
            request_x.fee6IEF = fee6IEF;
            request_x.fee7IEF = fee7IEF;
            request_x.fee1LDF = fee1LDF;
            request_x.fee2LDF = fee2LDF;
            request_x.fee3LDF = fee3LDF;
            request_x.fee4LDF = fee4LDF;
            request_x.fee5LDF = fee5LDF;
            request_x.fee6LDF = fee6LDF;
            request_x.fee7LDF = fee7LDF;
            request_x.Iscontingency = Iscontingency;
            request_x.UsesAttorneyFlow = UsesAttorneyFlow;
            request_x.LDFAmount = LDFAmount;
            request_x.OpFeeAmount = OpFeeAmount;
            request_x.IEFPercentage = IEFPercentage;
            request_x.AttorneyAffiliateID = AttorneyAffiliateID;
            Map<String, RAMServiceGateway.AddFeeGroup2Response_element> response_map_x = new Map<String, RAMServiceGateway.AddFeeGroup2Response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/AddFeeGroup2',
                'http://www.ramservicing.com/',
                'AddFeeGroup2',
                'http://www.ramservicing.com/',
                'AddFeeGroup2Response',
                'RAMServiceGateway.AddFeeGroup2Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AddFeeGroup2Result;
        }*/

        public String AddUpdateClientBanking(String sessid,Integer clientid,String Accountnumber,String NameonAccount,String Routing,String bankname,String AccountType) {
            RAMServiceGateway.AddUpdateClientBanking_element request_x = new RAMServiceGateway.AddUpdateClientBanking_element();
            RAMServiceGateway.AddUpdateClientBankingResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            request_x.Accountnumber = Accountnumber;
            request_x.NameonAccount = NameonAccount;
            request_x.Routing = Routing;
            request_x.bankname = bankname;
            request_x.AccountType = AccountType;
            Map<String, RAMServiceGateway.AddUpdateClientBankingResponse_element> response_map_x = new Map<String, RAMServiceGateway.AddUpdateClientBankingResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/AddUpdateClientBanking',
                'http://www.ramservicing.com/',
                'AddUpdateClientBanking',
                'http://www.ramservicing.com/',
                'AddUpdateClientBankingResponse',
                'RAMServiceGateway.AddUpdateClientBankingResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AddUpdateClientBankingResult;
        }

        public String BAV_VerifyAccount(String sessid,String ClientID) {
            
            Integer FundingSourcePayeeID = Integer.ValueOf(mRamAPISettingMap.get(mSettingsKey).Default_DSCID__c);
            if (FundingSourcePayeeID == null){
                system.debug(logginglevel.error,'FundingSourcePayeeID IS Not defined, defaulting it to 1');
                FundingSourcePayeeID = 1; //THIS IS DEFAULT
            }
            system.debug(logginglevel.error,'FundingSourcePayeeID IS :'+FundingSourcePayeeID);
            RAMServiceGateway.BAV_VerifyAccount_element request_x = new RAMServiceGateway.BAV_VerifyAccount_element();
            RAMServiceGateway.BAV_VerifyAccountResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.FundingSourcePayeeID = FundingSourcePayeeID;
            Map<String, RAMServiceGateway.BAV_VerifyAccountResponse_element> response_map_x = new Map<String, RAMServiceGateway.BAV_VerifyAccountResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/BAV_VerifyAccount',
                'http://www.ramservicing.com/',
                'BAV_VerifyAccount',
                'http://www.ramservicing.com/',
                'BAV_VerifyAccountResponse',
                'RAMServiceGateway.BAV_VerifyAccountResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.BAV_VerifyAccountResult;
        }

        public String BAV_VerifyAccount_Update(String sessid,String ClientID) {
            RAMServiceGateway.BAV_VerifyAccount_Update_element request_x = new RAMServiceGateway.BAV_VerifyAccount_Update_element();
            RAMServiceGateway.BAV_VerifyAccount_UpdateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            Map<String, RAMServiceGateway.BAV_VerifyAccount_UpdateResponse_element> response_map_x = new Map<String, RAMServiceGateway.BAV_VerifyAccount_UpdateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/BAV_VerifyAccount_Update',
                'http://www.ramservicing.com/',
                'BAV_VerifyAccount_Update',
                'http://www.ramservicing.com/',
                'BAV_VerifyAccount_UpdateResponse',
                'RAMServiceGateway.BAV_VerifyAccount_UpdateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.BAV_VerifyAccount_UpdateResult;
        }

        public String CancelDocument(String sessid,Double DocumentID) {
            RAMServiceGateway.CancelDocument_element request_x = new RAMServiceGateway.CancelDocument_element();
            RAMServiceGateway.CancelDocumentResponse_element response_x;
            request_x.sessid = sessid;
            request_x.DocumentID = DocumentID;
            Map<String, RAMServiceGateway.CancelDocumentResponse_element> response_map_x = new Map<String, RAMServiceGateway.CancelDocumentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/CancelDocument',
                'http://www.ramservicing.com/',
                'CancelDocument',
                'http://www.ramservicing.com/',
                'CancelDocumentResponse',
                'RAMServiceGateway.CancelDocumentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CancelDocumentResult;
        }

        public String ChangeAccountStatus(String sessid,Integer ClientID,String AccountStatus,String AchStatus) {
            RAMServiceGateway.ChangeAccountStatus_element request_x = new RAMServiceGateway.ChangeAccountStatus_element();
            RAMServiceGateway.ChangeAccountStatusResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.AccountStatus = AccountStatus;
            request_x.AchStatus = AchStatus;
            Map<String, RAMServiceGateway.ChangeAccountStatusResponse_element> response_map_x = new Map<String, RAMServiceGateway.ChangeAccountStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ChangeAccountStatus',
                'http://www.ramservicing.com/',
                'ChangeAccountStatus',
                'http://www.ramservicing.com/',
                'ChangeAccountStatusResponse',
                'RAMServiceGateway.ChangeAccountStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ChangeAccountStatusResult;
        }

        public RAMServiceGateway.ArrayOfString ChargeClientCard(String sessid,Integer clientID,Integer CardID,String extendedID,Double fee1,Double fee2,Double fee3,Double fee4,Double fee5,Double fee6,Double fee7,Double TotalPaymentAmount,Double savings) {
            RAMServiceGateway.ChargeClientCard_element request_x = new RAMServiceGateway.ChargeClientCard_element();
            RAMServiceGateway.ChargeClientCardResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientID = clientID;
            request_x.CardID = CardID;
            request_x.extendedID = extendedID;
            request_x.fee1 = fee1;
            request_x.fee2 = fee2;
            request_x.fee3 = fee3;
            request_x.fee4 = fee4;
            request_x.fee5 = fee5;
            request_x.fee6 = fee6;
            request_x.fee7 = fee7;
            request_x.TotalPaymentAmount = TotalPaymentAmount;
            request_x.savings = savings;
            Map<String, RAMServiceGateway.ChargeClientCardResponse_element> response_map_x = new Map<String, RAMServiceGateway.ChargeClientCardResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ChargeClientCard',
                'http://www.ramservicing.com/',
                'ChargeClientCard',
                'http://www.ramservicing.com/',
                'ChargeClientCardResponse',
                'RAMServiceGateway.ChargeClientCardResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ChargeClientCardResult;
        }

        public RAMServiceGateway.ArrayOfString ChargeClientCardWithCVV(String sessid,Integer clientID,Integer CardID,String extendedID,Double fee1,Double fee2,Double fee3,Double fee4,Double fee5,Double fee6,Double fee7,Double TotalPaymentAmount,Double savings,String CVV) {
            RAMServiceGateway.ChargeClientCardWithCVV_element request_x = new RAMServiceGateway.ChargeClientCardWithCVV_element();
            RAMServiceGateway.ChargeClientCardWithCVVResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientID = clientID;
            request_x.CardID = CardID;
            request_x.extendedID = extendedID;
            request_x.fee1 = fee1;
            request_x.fee2 = fee2;
            request_x.fee3 = fee3;
            request_x.fee4 = fee4;
            request_x.fee5 = fee5;
            request_x.fee6 = fee6;
            request_x.fee7 = fee7;
            request_x.TotalPaymentAmount = TotalPaymentAmount;
            request_x.savings = savings;
            request_x.CVV = CVV;
            Map<String, RAMServiceGateway.ChargeClientCardWithCVVResponse_element> response_map_x = new Map<String, RAMServiceGateway.ChargeClientCardWithCVVResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ChargeClientCardWithCVV',
                'http://www.ramservicing.com/',
                'ChargeClientCardWithCVV',
                'http://www.ramservicing.com/',
                'ChargeClientCardWithCVVResponse',
                'RAMServiceGateway.ChargeClientCardWithCVVResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ChargeClientCardWithCVVResult;
        }

        public String ChargeFromPayee(String sessid,Integer DraftFromID,Integer DepositToID,Integer ClientID,Double Amount,String Notes,String ExternalID) {
            RAMServiceGateway.ChargeFromPayee_element request_x = new RAMServiceGateway.ChargeFromPayee_element();
            RAMServiceGateway.ChargeFromPayeeResponse_element response_x;
            request_x.sessid = sessid;
            request_x.DraftFromID = DraftFromID;
            request_x.DepositToID = DepositToID;
            request_x.ClientID = ClientID;
            request_x.Amount = Amount;
            request_x.Notes = Notes;
            request_x.ExternalID = ExternalID;
            Map<String, RAMServiceGateway.ChargeFromPayeeResponse_element> response_map_x = new Map<String, RAMServiceGateway.ChargeFromPayeeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ChargeFromPayee',
                'http://www.ramservicing.com/',
                'ChargeFromPayee',
                'http://www.ramservicing.com/',
                'ChargeFromPayeeResponse',
                'RAMServiceGateway.ChargeFromPayeeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ChargeFromPayeeResult;
        }

        public String ClearPaymentSchedule(String sessid,Integer clientid) {
            RAMServiceGateway.ClearPaymentSchedule_element request_x = new RAMServiceGateway.ClearPaymentSchedule_element();
            RAMServiceGateway.ClearPaymentScheduleResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            Map<String, RAMServiceGateway.ClearPaymentScheduleResponse_element> response_map_x = new Map<String, RAMServiceGateway.ClearPaymentScheduleResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ClearPaymentSchedule',
                'http://www.ramservicing.com/',
                'ClearPaymentSchedule',
                'http://www.ramservicing.com/',
                'ClearPaymentScheduleResponse',
                'RAMServiceGateway.ClearPaymentScheduleResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ClearPaymentScheduleResult;
        }

        public String EndSession(String sessid) {
            RAMServiceGateway.EndSession_element request_x = new RAMServiceGateway.EndSession_element();
            RAMServiceGateway.EndSessionResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.EndSessionResponse_element> response_map_x = new Map<String, RAMServiceGateway.EndSessionResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/EndSession',
                'http://www.ramservicing.com/',
                'EndSession',
                'http://www.ramservicing.com/',
                'EndSessionResponse',
                'RAMServiceGateway.EndSessionResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.EndSessionResult;
        }

        public String FundClientBankAccount(String sessid,String ClientID,Integer FundingSourcePayeeID,Double Amount) {
            RAMServiceGateway.FundClientBankAccount_element request_x = new RAMServiceGateway.FundClientBankAccount_element();
            RAMServiceGateway.FundClientBankAccountResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.FundingSourcePayeeID = FundingSourcePayeeID;
            request_x.Amount = Amount;
            Map<String, RAMServiceGateway.FundClientBankAccountResponse_element> response_map_x = new Map<String, RAMServiceGateway.FundClientBankAccountResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/FundClientBankAccount',
                'http://www.ramservicing.com/',
                'FundClientBankAccount',
                'http://www.ramservicing.com/',
                'FundClientBankAccountResponse',
                'RAMServiceGateway.FundClientBankAccountResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.FundClientBankAccountResult;
        }

        public String FundClientEscrow(String sessid,Integer ClientID,Integer FundFromPayeeID,Double Amount,String Notes,String ExtendedID) {
            RAMServiceGateway.FundClientEscrow_element request_x = new RAMServiceGateway.FundClientEscrow_element();
            RAMServiceGateway.FundClientEscrowResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.FundFromPayeeID = FundFromPayeeID;
            request_x.Amount = Amount;
            request_x.Notes = Notes;
            request_x.ExtendedID = ExtendedID;
            Map<String, RAMServiceGateway.FundClientEscrowResponse_element> response_map_x = new Map<String, RAMServiceGateway.FundClientEscrowResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/FundClientEscrow',
                'http://www.ramservicing.com/',
                'FundClientEscrow',
                'http://www.ramservicing.com/',
                'FundClientEscrowResponse',
                'RAMServiceGateway.FundClientEscrowResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.FundClientEscrowResult;
        }

        public RAMServiceGateway.GetAllClientsResponse_GetAllClientsResult_element GetAllClients(String sessid,DateTime FromDate) {
            RAMServiceGateway.GetAllClients_element request_x = new RAMServiceGateway.GetAllClients_element();
            RAMServiceGateway.GetAllClientsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.FromDate = FromDate;
            Map<String, RAMServiceGateway.GetAllClientsResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetAllClientsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetAllClients',
                'http://www.ramservicing.com/',
                'GetAllClients',
                'http://www.ramservicing.com/',
                'GetAllClientsResponse',
                'RAMServiceGateway.GetAllClientsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetAllClientsResult;
        }

        public RAMServiceGateway.GetChangedStatusClientsResponse_GetChangedStatusClientsResult_element GetChangedStatusClients(String sessid,DateTime AfterDate) {
            RAMServiceGateway.GetChangedStatusClients_element request_x = new RAMServiceGateway.GetChangedStatusClients_element();
            RAMServiceGateway.GetChangedStatusClientsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.AfterDate = AfterDate;
            Map<String, RAMServiceGateway.GetChangedStatusClientsResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetChangedStatusClientsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetChangedStatusClients',
                'http://www.ramservicing.com/',
                'GetChangedStatusClients',
                'http://www.ramservicing.com/',
                'GetChangedStatusClientsResponse',
                'RAMServiceGateway.GetChangedStatusClientsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetChangedStatusClientsResult;
        }

        public RAMServiceGateway.ArrayOfString GetClientInfo(String sessid,Integer clientid) {
            RAMServiceGateway.GetClientInfo_element request_x = new RAMServiceGateway.GetClientInfo_element();
            RAMServiceGateway.GetClientInfoResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            Map<String, RAMServiceGateway.GetClientInfoResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientInfoResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientInfo',
                'http://www.ramservicing.com/',
                'GetClientInfo',
                'http://www.ramservicing.com/',
                'GetClientInfoResponse',
                'RAMServiceGateway.GetClientInfoResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientInfoResult;
        }

        public RAMServiceGateway.GetClientInfo_BulkResponse_GetClientInfo_BulkResult_element GetClientInfo_Bulk(String sessid,RAMServiceGateway.ArrayOfString ClientIDs) {
            RAMServiceGateway.GetClientInfo_Bulk_element request_x = new RAMServiceGateway.GetClientInfo_Bulk_element();
            RAMServiceGateway.GetClientInfo_BulkResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientIDs = ClientIDs;
            Map<String, RAMServiceGateway.GetClientInfo_BulkResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientInfo_BulkResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientInfo_Bulk',
                'http://www.ramservicing.com/',
                'GetClientInfo_Bulk',
                'http://www.ramservicing.com/',
                'GetClientInfo_BulkResponse',
                'RAMServiceGateway.GetClientInfo_BulkResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientInfo_BulkResult;
        }

        public RAMServiceGateway.GetClientInfo_ByDateResponse_GetClientInfo_ByDateResult_element GetClientInfo_ByDate(String sessid,DateTime startdate) {
            RAMServiceGateway.GetClientInfo_ByDate_element request_x = new RAMServiceGateway.GetClientInfo_ByDate_element();
            RAMServiceGateway.GetClientInfo_ByDateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.startdate = startdate;
            Map<String, RAMServiceGateway.GetClientInfo_ByDateResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientInfo_ByDateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientInfo_ByDate',
                'http://www.ramservicing.com/',
                'GetClientInfo_ByDate',
                'http://www.ramservicing.com/',
                'GetClientInfo_ByDateResponse',
                'RAMServiceGateway.GetClientInfo_ByDateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientInfo_ByDateResult;
        }

        public RAMServiceGateway.GetClientLedgerResponse_GetClientLedgerResult_element GetClientLedger(String sessid,String ClientID) {
            RAMServiceGateway.GetClientLedger_element request_x = new RAMServiceGateway.GetClientLedger_element();
            RAMServiceGateway.GetClientLedgerResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            Map<String, RAMServiceGateway.GetClientLedgerResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientLedgerResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientLedger',
                'http://www.ramservicing.com/',
                'GetClientLedger',
                'http://www.ramservicing.com/',
                'GetClientLedgerResponse',
                'RAMServiceGateway.GetClientLedgerResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientLedgerResult;
        }

        public RAMServiceGateway.ArrayOfPaymentLine GetClientPaymentSchedule(String sessid,Integer clientid) {
            RAMServiceGateway.GetClientPaymentSchedule_element request_x = new RAMServiceGateway.GetClientPaymentSchedule_element();
            RAMServiceGateway.GetClientPaymentScheduleResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            Map<String, RAMServiceGateway.GetClientPaymentScheduleResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientPaymentScheduleResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientPaymentSchedule',
                'http://www.ramservicing.com/',
                'GetClientPaymentSchedule',
                'http://www.ramservicing.com/',
                'GetClientPaymentScheduleResponse',
                'RAMServiceGateway.GetClientPaymentScheduleResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientPaymentScheduleResult;
        }

        public RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_GetClientPaymentSchedule_BulkResult_element GetClientPaymentSchedule_Bulk(String sessid,RAMServiceGateway.ArrayOfString ClientIDs) {
            RAMServiceGateway.GetClientPaymentSchedule_Bulk_element request_x = new RAMServiceGateway.GetClientPaymentSchedule_Bulk_element();
            RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientIDs = ClientIDs;
            Map<String, RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientPaymentSchedule_Bulk',
                'http://www.ramservicing.com/',
                'GetClientPaymentSchedule_Bulk',
                'http://www.ramservicing.com/',
                'GetClientPaymentSchedule_BulkResponse',
                'RAMServiceGateway.GetClientPaymentSchedule_BulkResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientPaymentSchedule_BulkResult;
        }

        public RAMServiceGateway.ArrayOfDouble GetClientSavings(String sessid,Integer clientid) {
            RAMServiceGateway.GetClientSavings_element request_x = new RAMServiceGateway.GetClientSavings_element();
            RAMServiceGateway.GetClientSavingsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            Map<String, RAMServiceGateway.GetClientSavingsResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientSavingsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientSavings',
                'http://www.ramservicing.com/',
                'GetClientSavings',
                'http://www.ramservicing.com/',
                'GetClientSavingsResponse',
                'RAMServiceGateway.GetClientSavingsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientSavingsResult;
        }

        public RAMServiceGateway.GetClientSavings_BulkResponse_GetClientSavings_BulkResult_element GetClientSavings_Bulk(String sessid,RAMServiceGateway.GetClientSavings_Bulk_dt_clients_element dt_clients) {
            RAMServiceGateway.GetClientSavings_Bulk_element request_x = new RAMServiceGateway.GetClientSavings_Bulk_element();
            RAMServiceGateway.GetClientSavings_BulkResponse_element response_x;
            request_x.sessid = sessid;
            request_x.dt_clients = dt_clients;
            Map<String, RAMServiceGateway.GetClientSavings_BulkResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientSavings_BulkResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientSavings_Bulk',
                'http://www.ramservicing.com/',
                'GetClientSavings_Bulk',
                'http://www.ramservicing.com/',
                'GetClientSavings_BulkResponse',
                'RAMServiceGateway.GetClientSavings_BulkResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientSavings_BulkResult;
        }

        public RAMServiceGateway.GetClientSavings_ByDateResponse_GetClientSavings_ByDateResult_element GetClientSavings_ByDate(String sessid,DateTime startdate) {
            RAMServiceGateway.GetClientSavings_ByDate_element request_x = new RAMServiceGateway.GetClientSavings_ByDate_element();
            RAMServiceGateway.GetClientSavings_ByDateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.startdate = startdate;
            Map<String, RAMServiceGateway.GetClientSavings_ByDateResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientSavings_ByDateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientSavings_ByDate',
                'http://www.ramservicing.com/',
                'GetClientSavings_ByDate',
                'http://www.ramservicing.com/',
                'GetClientSavings_ByDateResponse',
                'RAMServiceGateway.GetClientSavings_ByDateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientSavings_ByDateResult;
        }

        public RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_GetClientTransactionsByUpdateDateResult_element GetClientTransactionsByUpdateDate(String sessid,DateTime update_date) {
            RAMServiceGateway.GetClientTransactionsByUpdateDate_element request_x = new RAMServiceGateway.GetClientTransactionsByUpdateDate_element();
            RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.update_date = update_date;
            Map<String, RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientTransactionsByUpdateDate',
                'http://www.ramservicing.com/',
                'GetClientTransactionsByUpdateDate',
                'http://www.ramservicing.com/',
                'GetClientTransactionsByUpdateDateResponse',
                'RAMServiceGateway.GetClientTransactionsByUpdateDateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientTransactionsByUpdateDateResult;
        }

        public RAMServiceGateway.GetClientTransByClientIDResponse_GetClientTransByClientIDResult_element GetClientTransByClientID(String sessid,Integer clientid) {
            RAMServiceGateway.GetClientTransByClientID_element request_x = new RAMServiceGateway.GetClientTransByClientID_element();
            RAMServiceGateway.GetClientTransByClientIDResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            Map<String, RAMServiceGateway.GetClientTransByClientIDResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientTransByClientIDResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientTransByClientID',
                'http://www.ramservicing.com/',
                'GetClientTransByClientID',
                'http://www.ramservicing.com/',
                'GetClientTransByClientIDResponse',
                'RAMServiceGateway.GetClientTransByClientIDResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientTransByClientIDResult;
        }

        public RAMServiceGateway.GetClientTransByIDResponse_GetClientTransByIDResult_element GetClientTransByID(String sessid,Integer id) {
            RAMServiceGateway.GetClientTransByID_element request_x = new RAMServiceGateway.GetClientTransByID_element();
            RAMServiceGateway.GetClientTransByIDResponse_element response_x;
            request_x.sessid = sessid;
            request_x.id = id;
            Map<String, RAMServiceGateway.GetClientTransByIDResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientTransByIDResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientTransByID',
                'http://www.ramservicing.com/',
                'GetClientTransByID',
                'http://www.ramservicing.com/',
                'GetClientTransByIDResponse',
                'RAMServiceGateway.GetClientTransByIDResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientTransByIDResult;
        }

        public RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_GetClientTransByPaymentDateRangeResult_element GetClientTransByPaymentDateRange(String sessid,DateTime start_date,DateTime end_date) {
            RAMServiceGateway.GetClientTransByPaymentDateRange_element request_x = new RAMServiceGateway.GetClientTransByPaymentDateRange_element();
            RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_element response_x;
            request_x.sessid = sessid;
            request_x.start_date = start_date;
            request_x.end_date = end_date;
            Map<String, RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetClientTransByPaymentDateRange',
                'http://www.ramservicing.com/',
                'GetClientTransByPaymentDateRange',
                'http://www.ramservicing.com/',
                'GetClientTransByPaymentDateRangeResponse',
                'RAMServiceGateway.GetClientTransByPaymentDateRangeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetClientTransByPaymentDateRangeResult;
        }

        public RAMServiceGateway.ClientDocumentStatus GetDocumentStatus(String sessid,String ClientID,Double DocumentID) {
            RAMServiceGateway.GetDocumentStatus_element request_x = new RAMServiceGateway.GetDocumentStatus_element();
            RAMServiceGateway.GetDocumentStatusResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.DocumentID = DocumentID;
            Map<String, RAMServiceGateway.GetDocumentStatusResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetDocumentStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetDocumentStatus',
                'http://www.ramservicing.com/',
                'GetDocumentStatus',
                'http://www.ramservicing.com/',
                'GetDocumentStatusResponse',
                'RAMServiceGateway.GetDocumentStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetDocumentStatusResult;
        }

        public RAMServiceGateway.ArrayOfString GetHolidaySchedule(String sessid) {
            RAMServiceGateway.GetHolidaySchedule_element request_x = new RAMServiceGateway.GetHolidaySchedule_element();
            RAMServiceGateway.GetHolidayScheduleResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.GetHolidayScheduleResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetHolidayScheduleResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetHolidaySchedule',
                'http://www.ramservicing.com/',
                'GetHolidaySchedule',
                'http://www.ramservicing.com/',
                'GetHolidayScheduleResponse',
                'RAMServiceGateway.GetHolidayScheduleResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetHolidayScheduleResult;
        }

        public RAMServiceGateway.ArrayOfPaymentLine GetMadePaymentsByClient(String sessid,Integer clid) {
            RAMServiceGateway.GetMadePaymentsByClient_element request_x = new RAMServiceGateway.GetMadePaymentsByClient_element();
            RAMServiceGateway.GetMadePaymentsByClientResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clid = clid;
            Map<String, RAMServiceGateway.GetMadePaymentsByClientResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetMadePaymentsByClientResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetMadePaymentsByClient',
                'http://www.ramservicing.com/',
                'GetMadePaymentsByClient',
                'http://www.ramservicing.com/',
                'GetMadePaymentsByClientResponse',
                'RAMServiceGateway.GetMadePaymentsByClientResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetMadePaymentsByClientResult;
        }

        public RAMServiceGateway.ArrayOfPaymentLine GetMadePaymentsByDate(String sessid,DateTime startdate,DateTime enddate) {
            RAMServiceGateway.GetMadePaymentsByDate_element request_x = new RAMServiceGateway.GetMadePaymentsByDate_element();
            RAMServiceGateway.GetMadePaymentsByDateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.startdate = startdate;
            request_x.enddate = enddate;
            Map<String, RAMServiceGateway.GetMadePaymentsByDateResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetMadePaymentsByDateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetMadePaymentsByDate',
                'http://www.ramservicing.com/',
                'GetMadePaymentsByDate',
                'http://www.ramservicing.com/',
                'GetMadePaymentsByDateResponse',
                'RAMServiceGateway.GetMadePaymentsByDateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetMadePaymentsByDateResult;
        }

        public RAMServiceGateway.ArrayOfPaymentLineDetailed GetMadePaymentsByDateExtended(String sessid,DateTime startdate,DateTime enddate) {
            RAMServiceGateway.GetMadePaymentsByDateExtended_element request_x = new RAMServiceGateway.GetMadePaymentsByDateExtended_element();
            RAMServiceGateway.GetMadePaymentsByDateExtendedResponse_element response_x;
            request_x.sessid = sessid;
            request_x.startdate = startdate;
            request_x.enddate = enddate;
            Map<String, RAMServiceGateway.GetMadePaymentsByDateExtendedResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetMadePaymentsByDateExtendedResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetMadePaymentsByDateExtended',
                'http://www.ramservicing.com/',
                'GetMadePaymentsByDateExtended',
                'http://www.ramservicing.com/',
                'GetMadePaymentsByDateExtendedResponse',
                'RAMServiceGateway.GetMadePaymentsByDateExtendedResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetMadePaymentsByDateExtendedResult;
        }

        public RAMServiceGateway.ArrayOfString GetPaymentIDByExtendedID(String sessid,String extendedID) {
            RAMServiceGateway.GetPaymentIDByExtendedID_element request_x = new RAMServiceGateway.GetPaymentIDByExtendedID_element();
            RAMServiceGateway.GetPaymentIDByExtendedIDResponse_element response_x;
            request_x.sessid = sessid;
            request_x.extendedID = extendedID;
            Map<String, RAMServiceGateway.GetPaymentIDByExtendedIDResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetPaymentIDByExtendedIDResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetPaymentIDByExtendedID',
                'http://www.ramservicing.com/',
                'GetPaymentIDByExtendedID',
                'http://www.ramservicing.com/',
                'GetPaymentIDByExtendedIDResponse',
                'RAMServiceGateway.GetPaymentIDByExtendedIDResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetPaymentIDByExtendedIDResult;
        }

        public RAMServiceGateway.ArrayOfString GetPaymentStatus(String sessid,Integer PaymentScheduleID,Integer clientID) {
            RAMServiceGateway.GetPaymentStatus_element request_x = new RAMServiceGateway.GetPaymentStatus_element();
            RAMServiceGateway.GetPaymentStatusResponse_element response_x;
            request_x.sessid = sessid;
            request_x.PaymentScheduleID = PaymentScheduleID;
            request_x.clientID = clientID;
            Map<String, RAMServiceGateway.GetPaymentStatusResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetPaymentStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetPaymentStatus',
                'http://www.ramservicing.com/',
                'GetPaymentStatus',
                'http://www.ramservicing.com/',
                'GetPaymentStatusResponse',
                'RAMServiceGateway.GetPaymentStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetPaymentStatusResult;
        }

        public RAMServiceGateway.GetPaymentTypeInfoResponse_GetPaymentTypeInfoResult_element GetPaymentTypeInfo(String sessid) {
            RAMServiceGateway.GetPaymentTypeInfo_element request_x = new RAMServiceGateway.GetPaymentTypeInfo_element();
            RAMServiceGateway.GetPaymentTypeInfoResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.GetPaymentTypeInfoResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetPaymentTypeInfoResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetPaymentTypeInfo',
                'http://www.ramservicing.com/',
                'GetPaymentTypeInfo',
                'http://www.ramservicing.com/',
                'GetPaymentTypeInfoResponse',
                'RAMServiceGateway.GetPaymentTypeInfoResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetPaymentTypeInfoResult;
        }

        public RAMServiceGateway.GetRefundsResponse_GetRefundsResult_element GetRefunds(String sessid,DateTime ForDate) {
            RAMServiceGateway.GetRefunds_element request_x = new RAMServiceGateway.GetRefunds_element();
            RAMServiceGateway.GetRefundsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ForDate = ForDate;
            Map<String, RAMServiceGateway.GetRefundsResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetRefundsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetRefunds',
                'http://www.ramservicing.com/',
                'GetRefunds',
                'http://www.ramservicing.com/',
                'GetRefundsResponse',
                'RAMServiceGateway.GetRefundsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetRefundsResult;
        }

        public RAMServiceGateway.GetReturnsResponse_GetReturnsResult_element GetReturns(String sessid,DateTime ForDate) {
            RAMServiceGateway.GetReturns_element request_x = new RAMServiceGateway.GetReturns_element();
            RAMServiceGateway.GetReturnsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ForDate = ForDate;
            Map<String, RAMServiceGateway.GetReturnsResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetReturnsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetReturns',
                'http://www.ramservicing.com/',
                'GetReturns',
                'http://www.ramservicing.com/',
                'GetReturnsResponse',
                'RAMServiceGateway.GetReturnsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetReturnsResult;
        }

        public RAMServiceGateway.GetReturnsDateRangeResponse_GetReturnsDateRangeResult_element GetReturnsDateRange(String sessid,DateTime start_date,DateTime end_date) {
            RAMServiceGateway.GetReturnsDateRange_element request_x = new RAMServiceGateway.GetReturnsDateRange_element();
            RAMServiceGateway.GetReturnsDateRangeResponse_element response_x;
            request_x.sessid = sessid;
            request_x.start_date = start_date;
            request_x.end_date = end_date;
            Map<String, RAMServiceGateway.GetReturnsDateRangeResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetReturnsDateRangeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetReturnsDateRange',
                'http://www.ramservicing.com/',
                'GetReturnsDateRange',
                'http://www.ramservicing.com/',
                'GetReturnsDateRangeResponse',
                'RAMServiceGateway.GetReturnsDateRangeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetReturnsDateRangeResult;
        }

        public RAMServiceGateway.GetSettlements_BulkResponse_GetSettlements_BulkResult_element GetSettlements_Bulk(String sessid,RAMServiceGateway.ArrayOfString ClientIDs) {
            RAMServiceGateway.GetSettlements_Bulk_element request_x = new RAMServiceGateway.GetSettlements_Bulk_element();
            RAMServiceGateway.GetSettlements_BulkResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientIDs = ClientIDs;
            Map<String, RAMServiceGateway.GetSettlements_BulkResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetSettlements_BulkResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetSettlements_Bulk',
                'http://www.ramservicing.com/',
                'GetSettlements_Bulk',
                'http://www.ramservicing.com/',
                'GetSettlements_BulkResponse',
                'RAMServiceGateway.GetSettlements_BulkResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetSettlements_BulkResult;
        }

        public RAMServiceGateway.GetUpdatedSavingsResponse_GetUpdatedSavingsResult_element GetUpdatedSavings(String sessid,DateTime FromDate) {
            RAMServiceGateway.GetUpdatedSavings_element request_x = new RAMServiceGateway.GetUpdatedSavings_element();
            RAMServiceGateway.GetUpdatedSavingsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.FromDate = FromDate;
            Map<String, RAMServiceGateway.GetUpdatedSavingsResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetUpdatedSavingsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetUpdatedSavings',
                'http://www.ramservicing.com/',
                'GetUpdatedSavings',
                'http://www.ramservicing.com/',
                'GetUpdatedSavingsResponse',
                'RAMServiceGateway.GetUpdatedSavingsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetUpdatedSavingsResult;
        }

        public RAMServiceGateway.GetVendorCurrentFeesResponse_GetVendorCurrentFeesResult_element GetVendorCurrentFees(String sessid) {
            RAMServiceGateway.GetVendorCurrentFees_element request_x = new RAMServiceGateway.GetVendorCurrentFees_element();
            RAMServiceGateway.GetVendorCurrentFeesResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.GetVendorCurrentFeesResponse_element> response_map_x = new Map<String, RAMServiceGateway.GetVendorCurrentFeesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/GetVendorCurrentFees',
                'http://www.ramservicing.com/',
                'GetVendorCurrentFees',
                'http://www.ramservicing.com/',
                'GetVendorCurrentFeesResponse',
                'RAMServiceGateway.GetVendorCurrentFeesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetVendorCurrentFeesResult;
        }

        public RAMServiceGateway.ArrayOfCompany ListAllPayees(String sessid) {
            RAMServiceGateway.ListAllPayees_element request_x = new RAMServiceGateway.ListAllPayees_element();
            RAMServiceGateway.ListAllPayeesResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.ListAllPayeesResponse_element> response_map_x = new Map<String, RAMServiceGateway.ListAllPayeesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ListAllPayees',
                'http://www.ramservicing.com/',
                'ListAllPayees',
                'http://www.ramservicing.com/',
                'ListAllPayeesResponse',
                'RAMServiceGateway.ListAllPayeesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ListAllPayeesResult;
        }

        public RAMServiceGateway.ArrayOfString NewClient(String sessid,Integer ClientID,String Firstname,String Lastname,String FirstName2,String lastname2,String EmailAddress,String TaxID,String TaxID2,String StreetAddress,String City,String ZIP,String StateAbbreviation,String StreetAddress2,String City2,String ZIP2,String StateAbbreviation2,String Phone1,String Phone2,String Phone3,String DOB1,String DOB2,String AccountStatus,Integer AffiliateID,Integer FeeSplitGroupID,String AccountHoldStatus) {
            RAMServiceGateway.NewClient_element request_x = new RAMServiceGateway.NewClient_element();
            RAMServiceGateway.NewClientResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.Firstname = Firstname;
            request_x.Lastname = Lastname;
            request_x.FirstName2 = FirstName2;
            request_x.lastname2 = lastname2;
            request_x.EmailAddress = EmailAddress;
            request_x.TaxID = TaxID;
            request_x.TaxID2 = TaxID2;
            request_x.StreetAddress = StreetAddress;
            request_x.City = City;
            request_x.ZIP = ZIP;
            request_x.StateAbbreviation = StateAbbreviation;
            request_x.StreetAddress2 = StreetAddress2;
            request_x.City2 = City2;
            request_x.ZIP2 = ZIP2;
            request_x.StateAbbreviation2 = StateAbbreviation2;
            request_x.Phone1 = Phone1;
            request_x.Phone2 = Phone2;
            request_x.Phone3 = Phone3;
            request_x.DOB1 = DOB1;
            request_x.DOB2 = DOB2;
            request_x.AccountStatus = AccountStatus;
            request_x.AffiliateID = AffiliateID;
            request_x.FeeSplitGroupID = FeeSplitGroupID;
            request_x.AccountHoldStatus = AccountHoldStatus;
            Map<String, RAMServiceGateway.NewClientResponse_element> response_map_x = new Map<String, RAMServiceGateway.NewClientResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/NewClient',
                'http://www.ramservicing.com/',
                'NewClient',
                'http://www.ramservicing.com/',
                'NewClientResponse',
                'RAMServiceGateway.NewClientResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.NewClientResult;
        }

        public String PayFromClientTrust(String sessid,Integer ClientID,Double Amount,Integer PayeeID,String Description) {
            RAMServiceGateway.PayFromClientTrust_element request_x = new RAMServiceGateway.PayFromClientTrust_element();
            RAMServiceGateway.PayFromClientTrustResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.Amount = Amount;
            request_x.PayeeID = PayeeID;
            request_x.Description = Description;
            Map<String, RAMServiceGateway.PayFromClientTrustResponse_element> response_map_x = new Map<String, RAMServiceGateway.PayFromClientTrustResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PayFromClientTrust',
                'http://www.ramservicing.com/',
                'PayFromClientTrust',
                'http://www.ramservicing.com/',
                'PayFromClientTrustResponse',
                'RAMServiceGateway.PayFromClientTrustResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PayFromClientTrustResult;
        }

        public String PayFromClientTrust_Extended(String sessid,Integer ClientID,Double Amount,Integer PayeeID,String Description,String ExternalID) {
            RAMServiceGateway.PayFromClientTrust_Extended_element request_x = new RAMServiceGateway.PayFromClientTrust_Extended_element();
            RAMServiceGateway.PayFromClientTrust_ExtendedResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.Amount = Amount;
            request_x.PayeeID = PayeeID;
            request_x.Description = Description;
            request_x.ExternalID = ExternalID;
            Map<String, RAMServiceGateway.PayFromClientTrust_ExtendedResponse_element> response_map_x = new Map<String, RAMServiceGateway.PayFromClientTrust_ExtendedResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PayFromClientTrust_Extended',
                'http://www.ramservicing.com/',
                'PayFromClientTrust_Extended',
                'http://www.ramservicing.com/',
                'PayFromClientTrust_ExtendedResponse',
                'RAMServiceGateway.PayFromClientTrust_ExtendedResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PayFromClientTrust_ExtendedResult;
        }

        public String PayFromClientTrustWithSplits(String SessID,Integer ClientID,Double Fee1Amt,Double Fee2Amt,Double Fee3Amt,Double Fee4Amt,Double Fee5Amt,Double Fee6Amt,Double Fee7Amt,String Description,String ExternalID) {
            RAMServiceGateway.PayFromClientTrustWithSplits_element request_x = new RAMServiceGateway.PayFromClientTrustWithSplits_element();
            RAMServiceGateway.PayFromClientTrustWithSplitsResponse_element response_x;
            request_x.SessID = SessID;
            request_x.ClientID = ClientID;
            request_x.Fee1Amt = Fee1Amt;
            request_x.Fee2Amt = Fee2Amt;
            request_x.Fee3Amt = Fee3Amt;
            request_x.Fee4Amt = Fee4Amt;
            request_x.Fee5Amt = Fee5Amt;
            request_x.Fee6Amt = Fee6Amt;
            request_x.Fee7Amt = Fee7Amt;
            request_x.Description = Description;
            request_x.ExternalID = ExternalID;
            Map<String, RAMServiceGateway.PayFromClientTrustWithSplitsResponse_element> response_map_x = new Map<String, RAMServiceGateway.PayFromClientTrustWithSplitsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PayFromClientTrustWithSplits',
                'http://www.ramservicing.com/',
                'PayFromClientTrustWithSplits',
                'http://www.ramservicing.com/',
                'PayFromClientTrustWithSplitsResponse',
                'RAMServiceGateway.PayFromClientTrustWithSplitsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PayFromClientTrustWithSplitsResult;
        }

        public RAMServiceGateway.ArrayOfString PayScheduleAddSingle(String Sessid,Integer clientID,String extendedID,Double fee1,Double fee2,Double fee3,Double fee4,Double fee5,Double fee6,Double fee7,Double TotalPaymentAmount,Double savings,DateTime paymentdate) {
            RAMServiceGateway.PayScheduleAddSingle_element request_x = new RAMServiceGateway.PayScheduleAddSingle_element();
            RAMServiceGateway.PayScheduleAddSingleResponse_element response_x;
            request_x.Sessid = Sessid;
            request_x.clientID = clientID;
            request_x.extendedID = extendedID;
            request_x.fee1 = fee1;
            request_x.fee2 = fee2;
            request_x.fee3 = fee3;
            request_x.fee4 = fee4;
            request_x.fee5 = fee5;
            request_x.fee6 = fee6;
            request_x.fee7 = fee7;
            request_x.TotalPaymentAmount = TotalPaymentAmount;
            request_x.savings = savings;
            request_x.paymentdate = paymentdate;
            Map<String, RAMServiceGateway.PayScheduleAddSingleResponse_element> response_map_x = new Map<String, RAMServiceGateway.PayScheduleAddSingleResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PayScheduleAddSingle',
                'http://www.ramservicing.com/',
                'PayScheduleAddSingle',
                'http://www.ramservicing.com/',
                'PayScheduleAddSingleResponse',
                'RAMServiceGateway.PayScheduleAddSingleResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PayScheduleAddSingleResult;
        }

        public RAMServiceGateway.ArrayOfPaymentLine PayScheduleCreate(String sessid,Integer ClientID,RAMServiceGateway.ArrayOfPaymentLine PaySchedule) {
            RAMServiceGateway.PayScheduleCreate_element request_x = new RAMServiceGateway.PayScheduleCreate_element();
            RAMServiceGateway.PayScheduleCreateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.PaySchedule = PaySchedule;
            Map<String, RAMServiceGateway.PayScheduleCreateResponse_element> response_map_x = new Map<String, RAMServiceGateway.PayScheduleCreateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PayScheduleCreate',
                'http://www.ramservicing.com/',
                'PayScheduleCreate',
                'http://www.ramservicing.com/',
                'PayScheduleCreateResponse',
                'RAMServiceGateway.PayScheduleCreateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PayScheduleCreateResult;
        }

        public RAMServiceGateway.ArrayOfString PayScheduleUpdateSingle(String Sessid,Integer clientID,Integer PID,Double fee1,Double fee2,Double fee3,Double fee4,Double fee5,Double fee6,Double fee7,Double savings,DateTime paymentdate,Double TotalPaymentAmount) {
            RAMServiceGateway.PayScheduleUpdateSingle_element request_x = new RAMServiceGateway.PayScheduleUpdateSingle_element();
            RAMServiceGateway.PayScheduleUpdateSingleResponse_element response_x;
            request_x.Sessid = Sessid;
            request_x.clientID = clientID;
            request_x.PID = PID;
            request_x.fee1 = fee1;
            request_x.fee2 = fee2;
            request_x.fee3 = fee3;
            request_x.fee4 = fee4;
            request_x.fee5 = fee5;
            request_x.fee6 = fee6;
            request_x.fee7 = fee7;
            request_x.savings = savings;
            request_x.paymentdate = paymentdate;
            request_x.TotalPaymentAmount = TotalPaymentAmount;
            Map<String, RAMServiceGateway.PayScheduleUpdateSingleResponse_element> response_map_x = new Map<String, RAMServiceGateway.PayScheduleUpdateSingleResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PayScheduleUpdateSingle',
                'http://www.ramservicing.com/',
                'PayScheduleUpdateSingle',
                'http://www.ramservicing.com/',
                'PayScheduleUpdateSingleResponse',
                'RAMServiceGateway.PayScheduleUpdateSingleResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PayScheduleUpdateSingleResult;
        }

        public String PendingFees_Remove(String sessid,Integer PendingFeeID) {
            RAMServiceGateway.PendingFees_Remove_element request_x = new RAMServiceGateway.PendingFees_Remove_element();
            RAMServiceGateway.PendingFees_RemoveResponse_element response_x;
            request_x.sessid = sessid;
            request_x.PendingFeeID = PendingFeeID;
            Map<String, RAMServiceGateway.PendingFees_RemoveResponse_element> response_map_x = new Map<String, RAMServiceGateway.PendingFees_RemoveResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PendingFees_Remove',
                'http://www.ramservicing.com/',
                'PendingFees_Remove',
                'http://www.ramservicing.com/',
                'PendingFees_RemoveResponse',
                'RAMServiceGateway.PendingFees_RemoveResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PendingFees_RemoveResult;
        }

        public RAMServiceGateway.PendingFees_ShowResponse_PendingFees_ShowResult_element PendingFees_Show(String sessid,String ClientID) {
            RAMServiceGateway.PendingFees_Show_element request_x = new RAMServiceGateway.PendingFees_Show_element();
            RAMServiceGateway.PendingFees_ShowResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            Map<String, RAMServiceGateway.PendingFees_ShowResponse_element> response_map_x = new Map<String, RAMServiceGateway.PendingFees_ShowResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PendingFees_Show',
                'http://www.ramservicing.com/',
                'PendingFees_Show',
                'http://www.ramservicing.com/',
                'PendingFees_ShowResponse',
                'RAMServiceGateway.PendingFees_ShowResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PendingFees_ShowResult;
        }

        public RAMServiceGateway.PendingFees_ShowAllResponse_PendingFees_ShowAllResult_element PendingFees_ShowAll(String sessid) {
            RAMServiceGateway.PendingFees_ShowAll_element request_x = new RAMServiceGateway.PendingFees_ShowAll_element();
            RAMServiceGateway.PendingFees_ShowAllResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.PendingFees_ShowAllResponse_element> response_map_x = new Map<String, RAMServiceGateway.PendingFees_ShowAllResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/PendingFees_ShowAll',
                'http://www.ramservicing.com/',
                'PendingFees_ShowAll',
                'http://www.ramservicing.com/',
                'PendingFees_ShowAllResponse',
                'RAMServiceGateway.PendingFees_ShowAllResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PendingFees_ShowAllResult;
        }

        public String ReleaseClientFeesandSavings(String sessid,Integer clientid) {
            RAMServiceGateway.ReleaseClientFeesandSavings_element request_x = new RAMServiceGateway.ReleaseClientFeesandSavings_element();
            RAMServiceGateway.ReleaseClientFeesandSavingsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            Map<String, RAMServiceGateway.ReleaseClientFeesandSavingsResponse_element> response_map_x = new Map<String, RAMServiceGateway.ReleaseClientFeesandSavingsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ReleaseClientFeesandSavings',
                'http://www.ramservicing.com/',
                'ReleaseClientFeesandSavings',
                'http://www.ramservicing.com/',
                'ReleaseClientFeesandSavingsResponse',
                'RAMServiceGateway.ReleaseClientFeesandSavingsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ReleaseClientFeesandSavingsResult;
        }

        public RAMServiceGateway.RemoveAllSettlementsResponse_RemoveAllSettlementsResult_element RemoveAllSettlements(String sessid,String clientid,String ExtendedCCID) {
            RAMServiceGateway.RemoveAllSettlements_element request_x = new RAMServiceGateway.RemoveAllSettlements_element();
            RAMServiceGateway.RemoveAllSettlementsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            request_x.ExtendedCCID = ExtendedCCID;
            Map<String, RAMServiceGateway.RemoveAllSettlementsResponse_element> response_map_x = new Map<String, RAMServiceGateway.RemoveAllSettlementsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/RemoveAllSettlements',
                'http://www.ramservicing.com/',
                'RemoveAllSettlements',
                'http://www.ramservicing.com/',
                'RemoveAllSettlementsResponse',
                'RAMServiceGateway.RemoveAllSettlementsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RemoveAllSettlementsResult;
        }

        public String RemoveClientCard(String sessid,Integer ClientID,Integer CardID) {
            RAMServiceGateway.RemoveClientCard_element request_x = new RAMServiceGateway.RemoveClientCard_element();
            RAMServiceGateway.RemoveClientCardResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.CardID = CardID;
            Map<String, RAMServiceGateway.RemoveClientCardResponse_element> response_map_x = new Map<String, RAMServiceGateway.RemoveClientCardResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/RemoveClientCard',
                'http://www.ramservicing.com/',
                'RemoveClientCard',
                'http://www.ramservicing.com/',
                'RemoveClientCardResponse',
                'RAMServiceGateway.RemoveClientCardResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RemoveClientCardResult;
        }

        public String RemoveSettlement(String sessid,Integer RAMID,String ExtendedID) {
            RAMServiceGateway.RemoveSettlement_element request_x = new RAMServiceGateway.RemoveSettlement_element();
            RAMServiceGateway.RemoveSettlementResponse_element response_x;
            request_x.sessid = sessid;
            request_x.RAMID = RAMID;
            request_x.ExtendedID = ExtendedID;
            Map<String, RAMServiceGateway.RemoveSettlementResponse_element> response_map_x = new Map<String, RAMServiceGateway.RemoveSettlementResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/RemoveSettlement',
                'http://www.ramservicing.com/',
                'RemoveSettlement',
                'http://www.ramservicing.com/',
                'RemoveSettlementResponse',
                'RAMServiceGateway.RemoveSettlementResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RemoveSettlementResult;
        }

        public String RemoveUser(String sessid,String clientid) {
            RAMServiceGateway.RemoveUser_element request_x = new RAMServiceGateway.RemoveUser_element();
            RAMServiceGateway.RemoveUserResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientid = clientid;
            Map<String, RAMServiceGateway.RemoveUserResponse_element> response_map_x = new Map<String, RAMServiceGateway.RemoveUserResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/RemoveUser',
                'http://www.ramservicing.com/',
                'RemoveUser',
                'http://www.ramservicing.com/',
                'RemoveUserResponse',
                'RAMServiceGateway.RemoveUserResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RemoveUserResult;
        }

        public RAMServiceGateway.Report_CancellationsResponse_Report_CancellationsResult_element Report_Cancellations(String sessid,DateTime StartDate,DateTime EndDate) {
            RAMServiceGateway.Report_Cancellations_element request_x = new RAMServiceGateway.Report_Cancellations_element();
            RAMServiceGateway.Report_CancellationsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.StartDate = StartDate;
            request_x.EndDate = EndDate;
            Map<String, RAMServiceGateway.Report_CancellationsResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_CancellationsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_Cancellations',
                'http://www.ramservicing.com/',
                'Report_Cancellations',
                'http://www.ramservicing.com/',
                'Report_CancellationsResponse',
                'RAMServiceGateway.Report_CancellationsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_CancellationsResult;
        }

        public RAMServiceGateway.Report_ClientActivityResponse_Report_ClientActivityResult_element Report_ClientActivity(String sessid,DateTime StartDate,DateTime EndDate,Integer ClientID) {
            RAMServiceGateway.Report_ClientActivity_element request_x = new RAMServiceGateway.Report_ClientActivity_element();
            RAMServiceGateway.Report_ClientActivityResponse_element response_x;
            request_x.sessid = sessid;
            request_x.StartDate = StartDate;
            request_x.EndDate = EndDate;
            request_x.ClientID = ClientID;
            Map<String, RAMServiceGateway.Report_ClientActivityResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_ClientActivityResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_ClientActivity',
                'http://www.ramservicing.com/',
                'Report_ClientActivity',
                'http://www.ramservicing.com/',
                'Report_ClientActivityResponse',
                'RAMServiceGateway.Report_ClientActivityResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_ClientActivityResult;
        }

        public RAMServiceGateway.Report_ClientReturnsResponse_Report_ClientReturnsResult_element Report_ClientReturns(String sessid,DateTime StartDate,DateTime EndDate) {
            RAMServiceGateway.Report_ClientReturns_element request_x = new RAMServiceGateway.Report_ClientReturns_element();
            RAMServiceGateway.Report_ClientReturnsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.StartDate = StartDate;
            request_x.EndDate = EndDate;
            Map<String, RAMServiceGateway.Report_ClientReturnsResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_ClientReturnsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_ClientReturns',
                'http://www.ramservicing.com/',
                'Report_ClientReturns',
                'http://www.ramservicing.com/',
                'Report_ClientReturnsResponse',
                'RAMServiceGateway.Report_ClientReturnsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_ClientReturnsResult;
        }

        public RAMServiceGateway.Report_ClientsOnHoldResponse_Report_ClientsOnHoldResult_element Report_ClientsOnHold(String sessid) {
            RAMServiceGateway.Report_ClientsOnHold_element request_x = new RAMServiceGateway.Report_ClientsOnHold_element();
            RAMServiceGateway.Report_ClientsOnHoldResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.Report_ClientsOnHoldResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_ClientsOnHoldResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_ClientsOnHold',
                'http://www.ramservicing.com/',
                'Report_ClientsOnHold',
                'http://www.ramservicing.com/',
                'Report_ClientsOnHoldResponse',
                'RAMServiceGateway.Report_ClientsOnHoldResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_ClientsOnHoldResult;
        }

        public RAMServiceGateway.Report_FeeAccrualBalanceResponse_Report_FeeAccrualBalanceResult_element Report_FeeAccrualBalance(String sessid) {
            RAMServiceGateway.Report_FeeAccrualBalance_element request_x = new RAMServiceGateway.Report_FeeAccrualBalance_element();
            RAMServiceGateway.Report_FeeAccrualBalanceResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.Report_FeeAccrualBalanceResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_FeeAccrualBalanceResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_FeeAccrualBalance',
                'http://www.ramservicing.com/',
                'Report_FeeAccrualBalance',
                'http://www.ramservicing.com/',
                'Report_FeeAccrualBalanceResponse',
                'RAMServiceGateway.Report_FeeAccrualBalanceResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_FeeAccrualBalanceResult;
        }

        public RAMServiceGateway.Report_OutstandingChecksResponse_Report_OutstandingChecksResult_element Report_OutstandingChecks(String sessid) {
            RAMServiceGateway.Report_OutstandingChecks_element request_x = new RAMServiceGateway.Report_OutstandingChecks_element();
            RAMServiceGateway.Report_OutstandingChecksResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.Report_OutstandingChecksResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_OutstandingChecksResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_OutstandingChecks',
                'http://www.ramservicing.com/',
                'Report_OutstandingChecks',
                'http://www.ramservicing.com/',
                'Report_OutstandingChecksResponse',
                'RAMServiceGateway.Report_OutstandingChecksResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_OutstandingChecksResult;
        }

        public RAMServiceGateway.Report_PostedPaymentsResponse_Report_PostedPaymentsResult_element Report_PostedPayments(String sessid,Integer AffiliateID,DateTime StartDate,DateTime EndDate) {
            RAMServiceGateway.Report_PostedPayments_element request_x = new RAMServiceGateway.Report_PostedPayments_element();
            RAMServiceGateway.Report_PostedPaymentsResponse_element response_x;
            request_x.sessid = sessid;
            request_x.AffiliateID = AffiliateID;
            request_x.StartDate = StartDate;
            request_x.EndDate = EndDate;
            Map<String, RAMServiceGateway.Report_PostedPaymentsResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_PostedPaymentsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_PostedPayments',
                'http://www.ramservicing.com/',
                'Report_PostedPayments',
                'http://www.ramservicing.com/',
                'Report_PostedPaymentsResponse',
                'RAMServiceGateway.Report_PostedPaymentsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_PostedPaymentsResult;
        }

        public RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_Report_PostedPaymentsFromTrustResult_element Report_PostedPaymentsFromTrust(String sessid,Integer AffiliateID,DateTime StartDate,DateTime EndDate) {
            RAMServiceGateway.Report_PostedPaymentsFromTrust_element request_x = new RAMServiceGateway.Report_PostedPaymentsFromTrust_element();
            RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_element response_x;
            request_x.sessid = sessid;
            request_x.AffiliateID = AffiliateID;
            request_x.StartDate = StartDate;
            request_x.EndDate = EndDate;
            Map<String, RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_PostedPaymentsFromTrust',
                'http://www.ramservicing.com/',
                'Report_PostedPaymentsFromTrust',
                'http://www.ramservicing.com/',
                'Report_PostedPaymentsFromTrustResponse',
                'RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_PostedPaymentsFromTrustResult;
        }

        public RAMServiceGateway.Report_SavingsSummaryResponse_Report_SavingsSummaryResult_element Report_SavingsSummary(String sessid) {
            RAMServiceGateway.Report_SavingsSummary_element request_x = new RAMServiceGateway.Report_SavingsSummary_element();
            RAMServiceGateway.Report_SavingsSummaryResponse_element response_x;
            request_x.sessid = sessid;
            Map<String, RAMServiceGateway.Report_SavingsSummaryResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_SavingsSummaryResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_SavingsSummary',
                'http://www.ramservicing.com/',
                'Report_SavingsSummary',
                'http://www.ramservicing.com/',
                'Report_SavingsSummaryResponse',
                'RAMServiceGateway.Report_SavingsSummaryResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_SavingsSummaryResult;
        }

        public RAMServiceGateway.Report_TrackingByDateResponse_Report_TrackingByDateResult_element Report_TrackingByDate(String sessid,DateTime startdate,DateTime enddate) {
            RAMServiceGateway.Report_TrackingByDate_element request_x = new RAMServiceGateway.Report_TrackingByDate_element();
            RAMServiceGateway.Report_TrackingByDateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.startdate = startdate;
            request_x.enddate = enddate;
            Map<String, RAMServiceGateway.Report_TrackingByDateResponse_element> response_map_x = new Map<String, RAMServiceGateway.Report_TrackingByDateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/Report_TrackingByDate',
                'http://www.ramservicing.com/',
                'Report_TrackingByDate',
                'http://www.ramservicing.com/',
                'Report_TrackingByDateResponse',
                'RAMServiceGateway.Report_TrackingByDateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.Report_TrackingByDateResult;
        }

        public RAMServiceGateway.RVDVerifyResponse_RVDVerifyResult_element RVDVerify(String sessid,RAMServiceGateway.RVDVerify_inputtable_element inputtable) {
            RAMServiceGateway.RVDVerify_element request_x = new RAMServiceGateway.RVDVerify_element();
            RAMServiceGateway.RVDVerifyResponse_element response_x;
            request_x.sessid = sessid;
            request_x.inputtable = inputtable;
            Map<String, RAMServiceGateway.RVDVerifyResponse_element> response_map_x = new Map<String, RAMServiceGateway.RVDVerifyResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/RVDVerify',
                'http://www.ramservicing.com/',
                'RVDVerify',
                'http://www.ramservicing.com/',
                'RVDVerifyResponse',
                'RAMServiceGateway.RVDVerifyResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RVDVerifyResult;
        }

        public RAMServiceGateway.ArrayOfString ScheduleClientCardCharge(String sessid,Integer clientID,Integer CardID,String extendedID,Double fee1,Double fee2,Double fee3,Double fee4,Double fee5,Double fee6,Double fee7,Double TotalPaymentAmount,Double savings,DateTime paymentdate) {
            RAMServiceGateway.ScheduleClientCardCharge_element request_x = new RAMServiceGateway.ScheduleClientCardCharge_element();
            RAMServiceGateway.ScheduleClientCardChargeResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientID = clientID;
            request_x.CardID = CardID;
            request_x.extendedID = extendedID;
            request_x.fee1 = fee1;
            request_x.fee2 = fee2;
            request_x.fee3 = fee3;
            request_x.fee4 = fee4;
            request_x.fee5 = fee5;
            request_x.fee6 = fee6;
            request_x.fee7 = fee7;
            request_x.TotalPaymentAmount = TotalPaymentAmount;
            request_x.savings = savings;
            request_x.paymentdate = paymentdate;
            Map<String, RAMServiceGateway.ScheduleClientCardChargeResponse_element> response_map_x = new Map<String, RAMServiceGateway.ScheduleClientCardChargeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/ScheduleClientCardCharge',
                'http://www.ramservicing.com/',
                'ScheduleClientCardCharge',
                'http://www.ramservicing.com/',
                'ScheduleClientCardChargeResponse',
                'RAMServiceGateway.ScheduleClientCardChargeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ScheduleClientCardChargeResult;
        }

        public String SetClientFees(String sessid,String ClientID,Double FeeAmount) {
            RAMServiceGateway.SetClientFees_element request_x = new RAMServiceGateway.SetClientFees_element();
            RAMServiceGateway.SetClientFeesResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.FeeAmount = FeeAmount;
            Map<String, RAMServiceGateway.SetClientFeesResponse_element> response_map_x = new Map<String, RAMServiceGateway.SetClientFeesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SetClientFees',
                'http://www.ramservicing.com/',
                'SetClientFees',
                'http://www.ramservicing.com/',
                'SetClientFeesResponse',
                'RAMServiceGateway.SetClientFeesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SetClientFeesResult;
        }

        public String SetClientPhase(String sessid,String ClientID,Integer Phase) {
            RAMServiceGateway.SetClientPhase_element request_x = new RAMServiceGateway.SetClientPhase_element();
            RAMServiceGateway.SetClientPhaseResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.Phase = Phase;
            Map<String, RAMServiceGateway.SetClientPhaseResponse_element> response_map_x = new Map<String, RAMServiceGateway.SetClientPhaseResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SetClientPhase',
                'http://www.ramservicing.com/',
                'SetClientPhase',
                'http://www.ramservicing.com/',
                'SetClientPhaseResponse',
                'RAMServiceGateway.SetClientPhaseResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SetClientPhaseResult;
        }

        public Integer SettlementAddSinglePayment(String sessid,Integer clientID,Double PaymentAmount,DateTime PaymentDate,String PaymentType,String PayeeName,String PayeeAddress,String PayeeAddress2,String PayeeCity,String PayeeStateAbbrev,String PayeeZIP,String PayeePhone,String PayeeMailTo,String PayeeClientAccountNumber,String PaymentNotes,String PayeebankAccountNumber,String PayeeBankAccountRouting,String PayeeBankAccountName,String PayeeBankName,String PayeeBankAddress,String PayeeBankCity,String PayeeBankStateAbbrev,String PayeeBankZIP,String taxidlast4,String PayByPhoneNumber,String PayByPhoneContact,String CreditorName,String ReferenceNumber,String ExtendedID,String ExtendedCreditorID) {
            RAMServiceGateway.SettlementAddSinglePayment_element request_x = new RAMServiceGateway.SettlementAddSinglePayment_element();
            RAMServiceGateway.SettlementAddSinglePaymentResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientID = clientID;
            request_x.PaymentAmount = PaymentAmount;
            request_x.PaymentDate = PaymentDate;
            request_x.PaymentType = PaymentType;
            request_x.PayeeName = PayeeName;
            request_x.PayeeAddress = PayeeAddress;
            request_x.PayeeAddress2 = PayeeAddress2;
            request_x.PayeeCity = PayeeCity;
            request_x.PayeeStateAbbrev = PayeeStateAbbrev;
            request_x.PayeeZIP = PayeeZIP;
            request_x.PayeePhone = PayeePhone;
            request_x.PayeeMailTo = PayeeMailTo;
            request_x.PayeeClientAccountNumber = PayeeClientAccountNumber;
            request_x.PaymentNotes = PaymentNotes;
            request_x.PayeebankAccountNumber = PayeebankAccountNumber;
            request_x.PayeeBankAccountRouting = PayeeBankAccountRouting;
            request_x.PayeeBankAccountName = PayeeBankAccountName;
            request_x.PayeeBankName = PayeeBankName;
            request_x.PayeeBankAddress = PayeeBankAddress;
            request_x.PayeeBankCity = PayeeBankCity;
            request_x.PayeeBankStateAbbrev = PayeeBankStateAbbrev;
            request_x.PayeeBankZIP = PayeeBankZIP;
            request_x.taxidlast4 = taxidlast4;
            request_x.PayByPhoneNumber = PayByPhoneNumber;
            request_x.PayByPhoneContact = PayByPhoneContact;
            request_x.CreditorName = CreditorName;
            request_x.ReferenceNumber = ReferenceNumber;
            request_x.ExtendedID = ExtendedID;
            request_x.ExtendedCreditorID = ExtendedCreditorID;
            Map<String, RAMServiceGateway.SettlementAddSinglePaymentResponse_element> response_map_x = new Map<String, RAMServiceGateway.SettlementAddSinglePaymentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SettlementAddSinglePayment',
                'http://www.ramservicing.com/',
                'SettlementAddSinglePayment',
                'http://www.ramservicing.com/',
                'SettlementAddSinglePaymentResponse',
                'RAMServiceGateway.SettlementAddSinglePaymentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SettlementAddSinglePaymentResult;
        }

        public Integer SettlementAddSinglePaymentWithFee(String sessid,Integer clientID,Double PaymentAmount,DateTime PaymentDate,String PaymentType,String PayeeName,String PayeeAddress,String PayeeAddress2,String PayeeCity,String PayeeStateAbbrev,String PayeeZIP,String PayeeClientAccountNumber,String PaymentNotes,String PayeebankAccountNumber,String PayeeBankAccountRouting,String PayeeBankAccountName,String PayeeBankName,String PayeeBankAddress,String PayeeBankCity,String PayeeBankStateAbbrev,String PayeeBankZIP,String taxidlast4,String PayByPhoneNumber,String PayByPhoneContact,String CreditorName,String ReferenceNumber,String PayeeMailTo,Double AdditionalFees,String ExtendedID,String ExtendedCreditorID) {
            RAMServiceGateway.SettlementAddSinglePaymentWithFee_element request_x = new RAMServiceGateway.SettlementAddSinglePaymentWithFee_element();
            RAMServiceGateway.SettlementAddSinglePaymentWithFeeResponse_element response_x;
            request_x.sessid = sessid;
            request_x.clientID = clientID;
            request_x.PaymentAmount = PaymentAmount;
            request_x.PaymentDate = PaymentDate;
            request_x.PaymentType = PaymentType;
            request_x.PayeeName = PayeeName;
            request_x.PayeeAddress = PayeeAddress;
            request_x.PayeeAddress2 = PayeeAddress2;
            request_x.PayeeCity = PayeeCity;
            request_x.PayeeStateAbbrev = PayeeStateAbbrev;
            request_x.PayeeZIP = PayeeZIP;
            request_x.PayeeClientAccountNumber = PayeeClientAccountNumber;
            request_x.PaymentNotes = PaymentNotes;
            request_x.PayeebankAccountNumber = PayeebankAccountNumber;
            request_x.PayeeBankAccountRouting = PayeeBankAccountRouting;
            request_x.PayeeBankAccountName = PayeeBankAccountName;
            request_x.PayeeBankName = PayeeBankName;
            request_x.PayeeBankAddress = PayeeBankAddress;
            request_x.PayeeBankCity = PayeeBankCity;
            request_x.PayeeBankStateAbbrev = PayeeBankStateAbbrev;
            request_x.PayeeBankZIP = PayeeBankZIP;
            request_x.taxidlast4 = taxidlast4;
            request_x.PayByPhoneNumber = PayByPhoneNumber;
            request_x.PayByPhoneContact = PayByPhoneContact;
            request_x.CreditorName = CreditorName;
            request_x.ReferenceNumber = ReferenceNumber;
            request_x.PayeeMailTo = PayeeMailTo;
            request_x.AdditionalFees = AdditionalFees;
            request_x.ExtendedID = ExtendedID;
            request_x.ExtendedCreditorID = ExtendedCreditorID;
            Map<String, RAMServiceGateway.SettlementAddSinglePaymentWithFeeResponse_element> response_map_x = new Map<String, RAMServiceGateway.SettlementAddSinglePaymentWithFeeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SettlementAddSinglePaymentWithFee',
                'http://www.ramservicing.com/',
                'SettlementAddSinglePaymentWithFee',
                'http://www.ramservicing.com/',
                'SettlementAddSinglePaymentWithFeeResponse',
                'RAMServiceGateway.SettlementAddSinglePaymentWithFeeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SettlementAddSinglePaymentWithFeeResult;
        }

        public Integer SettlementUpdateSinglePayment(String sessid,Integer SettlementID,Integer clientID,Double PaymentAmount,DateTime PaymentDate,String PaymentType,String PayeeName,String PayeeAddress,String PayeeAddress2,String PayeeCity,String PayeeStateAbbrev,String PayeeZIP,String PayeePhone,String PayeeMailTo,String PayeeClientAccountNumber,String PaymentNotes,String PayeebankAccountNumber,String PayeeBankAccountRouting,String PayeeBankAccountName,String PayeeBankName,String PayeeBankAddress,String PayeeBankCity,String PayeeBankStateAbbrev,String PayeeBankZIP,String TaxIDLast4,String PayByPhoneNumber,String PayByPhoneContact,String CreditorName,String ReferenceNumber,String ExtendedID,String ExtendedCreditorID) {
            RAMServiceGateway.SettlementUpdateSinglePayment_element request_x = new RAMServiceGateway.SettlementUpdateSinglePayment_element();
            RAMServiceGateway.SettlementUpdateSinglePaymentResponse_element response_x;
            request_x.sessid = sessid;
            request_x.SettlementID = SettlementID;
            request_x.clientID = clientID;
            request_x.PaymentAmount = PaymentAmount;
            request_x.PaymentDate = PaymentDate;
            request_x.PaymentType = PaymentType;
            request_x.PayeeName = PayeeName;
            request_x.PayeeAddress = PayeeAddress;
            request_x.PayeeAddress2 = PayeeAddress2;
            request_x.PayeeCity = PayeeCity;
            request_x.PayeeStateAbbrev = PayeeStateAbbrev;
            request_x.PayeeZIP = PayeeZIP;
            request_x.PayeePhone = PayeePhone;
            request_x.PayeeMailTo = PayeeMailTo;
            request_x.PayeeClientAccountNumber = PayeeClientAccountNumber;
            request_x.PaymentNotes = PaymentNotes;
            request_x.PayeebankAccountNumber = PayeebankAccountNumber;
            request_x.PayeeBankAccountRouting = PayeeBankAccountRouting;
            request_x.PayeeBankAccountName = PayeeBankAccountName;
            request_x.PayeeBankName = PayeeBankName;
            request_x.PayeeBankAddress = PayeeBankAddress;
            request_x.PayeeBankCity = PayeeBankCity;
            request_x.PayeeBankStateAbbrev = PayeeBankStateAbbrev;
            request_x.PayeeBankZIP = PayeeBankZIP;
            request_x.TaxIDLast4 = TaxIDLast4;
            request_x.PayByPhoneNumber = PayByPhoneNumber;
            request_x.PayByPhoneContact = PayByPhoneContact;
            request_x.CreditorName = CreditorName;
            request_x.ReferenceNumber = ReferenceNumber;
            request_x.ExtendedID = ExtendedID;
            request_x.ExtendedCreditorID = ExtendedCreditorID;
            Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentResponse_element> response_map_x = new Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SettlementUpdateSinglePayment',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePayment',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePaymentResponse',
                'RAMServiceGateway.SettlementUpdateSinglePaymentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SettlementUpdateSinglePaymentResult;
        }

        public Integer SettlementUpdateSinglePaymentExtended(String sessid,String ExtendedID,Integer clientID,Double PaymentAmount,DateTime PaymentDate,String PaymentType,String PayeeName,String PayeeAddress,String PayeeAddress2,String PayeeCity,String PayeeStateAbbrev,String PayeeZIP,String PayeePhone,String PayeeMailTo,String PayeeClientAccountNumber,String PaymentNotes,String PayeebankAccountNumber,String PayeeBankAccountRouting,String PayeeBankAccountName,String PayeeBankName,String PayeeBankAddress,String PayeeBankCity,String PayeeBankStateAbbrev,String PayeeBankZIP,String TaxIDLast4,String PayByPhoneNumber,String PayByPhoneContact,String CreditorName,String ReferenceNumber,String ExtendedCreditorID) {
            RAMServiceGateway.SettlementUpdateSinglePaymentExtended_element request_x = new RAMServiceGateway.SettlementUpdateSinglePaymentExtended_element();
            RAMServiceGateway.SettlementUpdateSinglePaymentExtendedResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ExtendedID = ExtendedID;
            request_x.clientID = clientID;
            request_x.PaymentAmount = PaymentAmount;
            request_x.PaymentDate = PaymentDate;
            request_x.PaymentType = PaymentType;
            request_x.PayeeName = PayeeName;
            request_x.PayeeAddress = PayeeAddress;
            request_x.PayeeAddress2 = PayeeAddress2;
            request_x.PayeeCity = PayeeCity;
            request_x.PayeeStateAbbrev = PayeeStateAbbrev;
            request_x.PayeeZIP = PayeeZIP;
            request_x.PayeePhone = PayeePhone;
            request_x.PayeeMailTo = PayeeMailTo;
            request_x.PayeeClientAccountNumber = PayeeClientAccountNumber;
            request_x.PaymentNotes = PaymentNotes;
            request_x.PayeebankAccountNumber = PayeebankAccountNumber;
            request_x.PayeeBankAccountRouting = PayeeBankAccountRouting;
            request_x.PayeeBankAccountName = PayeeBankAccountName;
            request_x.PayeeBankName = PayeeBankName;
            request_x.PayeeBankAddress = PayeeBankAddress;
            request_x.PayeeBankCity = PayeeBankCity;
            request_x.PayeeBankStateAbbrev = PayeeBankStateAbbrev;
            request_x.PayeeBankZIP = PayeeBankZIP;
            request_x.TaxIDLast4 = TaxIDLast4;
            request_x.PayByPhoneNumber = PayByPhoneNumber;
            request_x.PayByPhoneContact = PayByPhoneContact;
            request_x.CreditorName = CreditorName;
            request_x.ReferenceNumber = ReferenceNumber;
            request_x.ExtendedCreditorID = ExtendedCreditorID;
            Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentExtendedResponse_element> response_map_x = new Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentExtendedResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SettlementUpdateSinglePaymentExtended',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePaymentExtended',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePaymentExtendedResponse',
                'RAMServiceGateway.SettlementUpdateSinglePaymentExtendedResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SettlementUpdateSinglePaymentExtendedResult;
        }

        public Integer SettlementUpdateSinglePaymentWithFee(String sessid,Integer SettlementID,Integer clientID,Double PaymentAmount,DateTime PaymentDate,String PaymentType,String PayeeName,String PayeeAddress,String PayeeAddress2,String PayeeCity,String PayeeStateAbbrev,String PayeeZIP,String PayeeClientAccountNumber,String PaymentNotes,String PayeebankAccountNumber,String PayeeBankAccountRouting,String PayeeBankAccountName,String PayeeBankName,String PayeeBankAddress,String PayeeBankCity,String PayeeBankStateAbbrev,String PayeeBankZIP,String TaxIDLast4,String PayByPhoneNumber,String PayByPhoneContact,String CreditorName,String ReferenceNumber,String PayeeMailTo,Double AdditionalFees,String ExtendedID,String ExtendedCreditorID) {
            RAMServiceGateway.SettlementUpdateSinglePaymentWithFee_element request_x = new RAMServiceGateway.SettlementUpdateSinglePaymentWithFee_element();
            RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeResponse_element response_x;
            request_x.sessid = sessid;
            request_x.SettlementID = SettlementID;
            request_x.clientID = clientID;
            request_x.PaymentAmount = PaymentAmount;
            request_x.PaymentDate = PaymentDate;
            request_x.PaymentType = PaymentType;
            request_x.PayeeName = PayeeName;
            request_x.PayeeAddress = PayeeAddress;
            request_x.PayeeAddress2 = PayeeAddress2;
            request_x.PayeeCity = PayeeCity;
            request_x.PayeeStateAbbrev = PayeeStateAbbrev;
            request_x.PayeeZIP = PayeeZIP;
            request_x.PayeeClientAccountNumber = PayeeClientAccountNumber;
            request_x.PaymentNotes = PaymentNotes;
            request_x.PayeebankAccountNumber = PayeebankAccountNumber;
            request_x.PayeeBankAccountRouting = PayeeBankAccountRouting;
            request_x.PayeeBankAccountName = PayeeBankAccountName;
            request_x.PayeeBankName = PayeeBankName;
            request_x.PayeeBankAddress = PayeeBankAddress;
            request_x.PayeeBankCity = PayeeBankCity;
            request_x.PayeeBankStateAbbrev = PayeeBankStateAbbrev;
            request_x.PayeeBankZIP = PayeeBankZIP;
            request_x.TaxIDLast4 = TaxIDLast4;
            request_x.PayByPhoneNumber = PayByPhoneNumber;
            request_x.PayByPhoneContact = PayByPhoneContact;
            request_x.CreditorName = CreditorName;
            request_x.ReferenceNumber = ReferenceNumber;
            request_x.PayeeMailTo = PayeeMailTo;
            request_x.AdditionalFees = AdditionalFees;
            request_x.ExtendedID = ExtendedID;
            request_x.ExtendedCreditorID = ExtendedCreditorID;
            Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeResponse_element> response_map_x = new Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SettlementUpdateSinglePaymentWithFee',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePaymentWithFee',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePaymentWithFeeResponse',
                'RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SettlementUpdateSinglePaymentWithFeeResult;
        }

        public Integer SettlementUpdateSinglePaymentWithFeeByExtendedID(String sessid,String ExtendedID,Integer clientID,Double PaymentAmount,DateTime PaymentDate,String PaymentType,String PayeeName,String PayeeAddress,String PayeeAddress2,String PayeeCity,String PayeeStateAbbrev,String PayeeZIP,String PayeeClientAccountNumber,String PaymentNotes,String PayeebankAccountNumber,String PayeeBankAccountRouting,String PayeeBankAccountName,String PayeeBankName,String PayeeBankAddress,String PayeeBankCity,String PayeeBankStateAbbrev,String PayeeBankZIP,String TaxIDLast4,String PayByPhoneNumber,String PayByPhoneContact,String CreditorName,String ReferenceNumber,String PayeeMailTo,Double AdditionalFees,String ExtendedCreditorID) {
            RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedID_element request_x = new RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedID_element();
            RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ExtendedID = ExtendedID;
            request_x.clientID = clientID;
            request_x.PaymentAmount = PaymentAmount;
            request_x.PaymentDate = PaymentDate;
            request_x.PaymentType = PaymentType;
            request_x.PayeeName = PayeeName;
            request_x.PayeeAddress = PayeeAddress;
            request_x.PayeeAddress2 = PayeeAddress2;
            request_x.PayeeCity = PayeeCity;
            request_x.PayeeStateAbbrev = PayeeStateAbbrev;
            request_x.PayeeZIP = PayeeZIP;
            request_x.PayeeClientAccountNumber = PayeeClientAccountNumber;
            request_x.PaymentNotes = PaymentNotes;
            request_x.PayeebankAccountNumber = PayeebankAccountNumber;
            request_x.PayeeBankAccountRouting = PayeeBankAccountRouting;
            request_x.PayeeBankAccountName = PayeeBankAccountName;
            request_x.PayeeBankName = PayeeBankName;
            request_x.PayeeBankAddress = PayeeBankAddress;
            request_x.PayeeBankCity = PayeeBankCity;
            request_x.PayeeBankStateAbbrev = PayeeBankStateAbbrev;
            request_x.PayeeBankZIP = PayeeBankZIP;
            request_x.TaxIDLast4 = TaxIDLast4;
            request_x.PayByPhoneNumber = PayByPhoneNumber;
            request_x.PayByPhoneContact = PayByPhoneContact;
            request_x.CreditorName = CreditorName;
            request_x.ReferenceNumber = ReferenceNumber;
            request_x.PayeeMailTo = PayeeMailTo;
            request_x.AdditionalFees = AdditionalFees;
            request_x.ExtendedCreditorID = ExtendedCreditorID;
            Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse_element> response_map_x = new Map<String, RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/SettlementUpdateSinglePaymentWithFeeByExtendedID',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePaymentWithFeeByExtendedID',
                'http://www.ramservicing.com/',
                'SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse',
                'RAMServiceGateway.SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SettlementUpdateSinglePaymentWithFeeByExtendedIDResult;
        }

        public String StartSession() {
            RAMServiceGateway.StartSession_element request_x = new RAMServiceGateway.StartSession_element();
            RAMServiceGateway.StartSessionResponse_element response_x;
            request_x.ClientKey = mClientKey;
            Map<String, RAMServiceGateway.StartSessionResponse_element> response_map_x = new Map<String, RAMServiceGateway.StartSessionResponse_element>();
            response_map_x.put('response_x', response_x);
            
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/StartSession',
                'http://www.ramservicing.com/',
                'StartSession',
                'http://www.ramservicing.com/',
                'StartSessionResponse',
                'RAMServiceGateway.StartSessionResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.StartSessionResult;
        }

        public String UpdateAffiliate(String sessid,Integer AffiliateID,String Name,String Address,String city,String StateAbbrev,String ZIP,String Phone,String NameonAccount,String bankrouting,String BankaccountNumber,String accounttype,String bankname,String bankcity,String bankphone,String bankstateabbrev,String bankzip) {
            RAMServiceGateway.UpdateAffiliate_element request_x = new RAMServiceGateway.UpdateAffiliate_element();
            RAMServiceGateway.UpdateAffiliateResponse_element response_x;
            request_x.sessid = sessid;
            request_x.AffiliateID = AffiliateID;
            request_x.Name = Name;
            request_x.Address = Address;
            request_x.city = city;
            request_x.StateAbbrev = StateAbbrev;
            request_x.ZIP = ZIP;
            request_x.Phone = Phone;
            request_x.NameonAccount = NameonAccount;
            request_x.bankrouting = bankrouting;
            request_x.BankaccountNumber = BankaccountNumber;
            request_x.accounttype = accounttype;
            request_x.bankname = bankname;
            request_x.bankcity = bankcity;
            request_x.bankphone = bankphone;
            request_x.bankstateabbrev = bankstateabbrev;
            request_x.bankzip = bankzip;
            Map<String, RAMServiceGateway.UpdateAffiliateResponse_element> response_map_x = new Map<String, RAMServiceGateway.UpdateAffiliateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UpdateAffiliate',
                'http://www.ramservicing.com/',
                'UpdateAffiliate',
                'http://www.ramservicing.com/',
                'UpdateAffiliateResponse',
                'RAMServiceGateway.UpdateAffiliateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateAffiliateResult;
        }

        public String UpdateClient(String sessid,Integer ClientID,String Firstname,String Lastname,String FirstName2,String lastname2,String EmailAddress,String TaxID,String TaxID2,String StreetAddress,String City,String ZIP,String StateAbbreviation,String StreetAddress2,String City2,String ZIP2,String StateAbbreviation2,String Phone1,String Phone2,String Phone3,String DOB1,String DOB2,String AccountStatus,Integer AffiliateID,Integer FeeSplitGroupID,String AccountHoldStatus) {
            RAMServiceGateway.UpdateClient_element request_x = new RAMServiceGateway.UpdateClient_element();
            RAMServiceGateway.UpdateClientResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.Firstname = Firstname;
            request_x.Lastname = Lastname;
            request_x.FirstName2 = FirstName2;
            request_x.lastname2 = lastname2;
            request_x.EmailAddress = EmailAddress;
            request_x.TaxID = TaxID;
            request_x.TaxID2 = TaxID2;
            request_x.StreetAddress = StreetAddress;
            request_x.City = City;
            request_x.ZIP = ZIP;
            request_x.StateAbbreviation = StateAbbreviation;
            request_x.StreetAddress2 = StreetAddress2;
            request_x.City2 = City2;
            request_x.ZIP2 = ZIP2;
            request_x.StateAbbreviation2 = StateAbbreviation2;
            request_x.Phone1 = Phone1;
            request_x.Phone2 = Phone2;
            request_x.Phone3 = Phone3;
            request_x.DOB1 = DOB1;
            request_x.DOB2 = DOB2;
            request_x.AccountStatus = AccountStatus;
            request_x.AffiliateID = AffiliateID;
            request_x.FeeSplitGroupID = FeeSplitGroupID;
            request_x.AccountHoldStatus = AccountHoldStatus;
            Map<String, RAMServiceGateway.UpdateClientResponse_element> response_map_x = new Map<String, RAMServiceGateway.UpdateClientResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UpdateClient',
                'http://www.ramservicing.com/',
                'UpdateClient',
                'http://www.ramservicing.com/',
                'UpdateClientResponse',
                'RAMServiceGateway.UpdateClientResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateClientResult;
        }

        public String UpdateClientAgent(String sessid,Integer ClientID,String AgentName) {
            RAMServiceGateway.UpdateClientAgent_element request_x = new RAMServiceGateway.UpdateClientAgent_element();
            RAMServiceGateway.UpdateClientAgentResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.AgentName = AgentName;
            Map<String, RAMServiceGateway.UpdateClientAgentResponse_element> response_map_x = new Map<String, RAMServiceGateway.UpdateClientAgentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UpdateClientAgent',
                'http://www.ramservicing.com/',
                'UpdateClientAgent',
                'http://www.ramservicing.com/',
                'UpdateClientAgentResponse',
                'RAMServiceGateway.UpdateClientAgentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateClientAgentResult;
        }

        public RAMServiceGateway.ArrayOfPaymentLine UpdateClientCombined(String sessid,Integer ClientID,String Firstname,String Lastname,String Firstname2,String Lastname2,String EmailAddress,String TaxID,String TaxID2,String StreetAddress,String City,String ZIP,String StateAbbreviation,String StreetAddress2,String City2,String ZIP2,String StateAbbreviation2,String Phone1,String Phone2,String Phone3,String DOB1,String DOB2,String AccountStatus,Integer AffiliateID,Integer FeeSplitGroupID,String AccountHoldStatus,String Accountnumber,String NameonAccount,String Routing,String BankName,String AccountType,RAMServiceGateway.ArrayOfPaymentLine PaySchedule) {
            RAMServiceGateway.UpdateClientCombined_element request_x = new RAMServiceGateway.UpdateClientCombined_element();
            RAMServiceGateway.UpdateClientCombinedResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.Firstname = Firstname;
            request_x.Lastname = Lastname;
            request_x.Firstname2 = Firstname2;
            request_x.Lastname2 = Lastname2;
            request_x.EmailAddress = EmailAddress;
            request_x.TaxID = TaxID;
            request_x.TaxID2 = TaxID2;
            request_x.StreetAddress = StreetAddress;
            request_x.City = City;
            request_x.ZIP = ZIP;
            request_x.StateAbbreviation = StateAbbreviation;
            request_x.StreetAddress2 = StreetAddress2;
            request_x.City2 = City2;
            request_x.ZIP2 = ZIP2;
            request_x.StateAbbreviation2 = StateAbbreviation2;
            request_x.Phone1 = Phone1;
            request_x.Phone2 = Phone2;
            request_x.Phone3 = Phone3;
            request_x.DOB1 = DOB1;
            request_x.DOB2 = DOB2;
            request_x.AccountStatus = AccountStatus;
            request_x.AffiliateID = AffiliateID;
            request_x.FeeSplitGroupID = FeeSplitGroupID;
            request_x.AccountHoldStatus = AccountHoldStatus;
            request_x.Accountnumber = Accountnumber;
            request_x.NameonAccount = NameonAccount;
            request_x.Routing = Routing;
            request_x.BankName = BankName;
            request_x.AccountType = AccountType;
            request_x.PaySchedule = PaySchedule;
            Map<String, RAMServiceGateway.UpdateClientCombinedResponse_element> response_map_x = new Map<String, RAMServiceGateway.UpdateClientCombinedResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UpdateClientCombined',
                'http://www.ramservicing.com/',
                'UpdateClientCombined',
                'http://www.ramservicing.com/',
                'UpdateClientCombinedResponse',
                'RAMServiceGateway.UpdateClientCombinedResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateClientCombinedResult;
        }

        public String UpdateClientSSN(String sessid,String ClientID,String SSN,String MI,String SSN2,String MI2) {
            RAMServiceGateway.UpdateClientSSN_element request_x = new RAMServiceGateway.UpdateClientSSN_element();
            RAMServiceGateway.UpdateClientSSNResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.SSN = SSN;
            request_x.MI = MI;
            request_x.SSN2 = SSN2;
            request_x.MI2 = MI2;
            Map<String, RAMServiceGateway.UpdateClientSSNResponse_element> response_map_x = new Map<String, RAMServiceGateway.UpdateClientSSNResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UpdateClientSSN',
                'http://www.ramservicing.com/',
                'UpdateClientSSN',
                'http://www.ramservicing.com/',
                'UpdateClientSSNResponse',
                'RAMServiceGateway.UpdateClientSSNResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateClientSSNResult;
        }

        /*public String UpdateFeeGroup(String sessid,Integer GroupID,String GroupName,Boolean fee1isamt,Boolean fee2isamt,Boolean fee3isamt,Boolean fee4isamt,Boolean fee5isamt,Boolean fee6isamt,Boolean fee7isamt,Integer fee1payeeid,Integer fee1payeeid2,Integer fee1payeeid3,Integer fee1payeeid4,Integer fee2payeeid,Integer fee2payeeid2,Integer fee2payeeid3,Integer fee2payeeid4,Integer fee3payeeid,Integer fee3payeeid2,Integer fee3payeeid3,Integer fee3payeeid4,Integer fee4payeeid,Integer fee4payeeid2,Integer fee4payeeid3,Integer fee4payeeid4,Integer fee5payeeid,Integer fee5payeeid2,Integer fee5payeeid3,Integer fee5payeeid4,Integer fee6payeeid,Integer fee6payeeid2,Integer fee6payeeid3,Integer fee6payeeid4,Integer fee7payeeid,Integer fee7payeeid2,Integer fee7payeeid3,Integer fee7payeeid4,Double fee1split1,Double fee1split2,Double fee1split3,Double fee1split4,Double fee2split1,Double fee2split2,Double fee2split3,Double fee2split4,Double fee3split1,Double fee3split2,Double fee3split3,Double fee3split4,Double fee4split1,Double fee4split2,Double fee4split3,Double fee4split4,Double fee5split1,Double fee5split2,Double fee5split3,Double fee5split4,Double fee6split1,Double fee6split2,Double fee6split3,Double fee6split4,Double fee7split1,Double fee7split2,Double fee7split3,Double fee7split4,String fee1name,String fee2name,String fee3name,String fee4name,String fee5name,String fee6name,String fee7name) {
            RAMServiceGateway.UpdateFeeGroup_element request_x = new RAMServiceGateway.UpdateFeeGroup_element();
            RAMServiceGateway.UpdateFeeGroupResponse_element response_x;
            request_x.sessid = sessid;
            request_x.GroupID = GroupID;
            request_x.GroupName = GroupName;
            request_x.fee1isamt = fee1isamt;
            request_x.fee2isamt = fee2isamt;
            request_x.fee3isamt = fee3isamt;
            request_x.fee4isamt = fee4isamt;
            request_x.fee5isamt = fee5isamt;
            request_x.fee6isamt = fee6isamt;
            request_x.fee7isamt = fee7isamt;
            request_x.fee1payeeid = fee1payeeid;
            request_x.fee1payeeid2 = fee1payeeid2;
            request_x.fee1payeeid3 = fee1payeeid3;
            request_x.fee1payeeid4 = fee1payeeid4;
            request_x.fee2payeeid = fee2payeeid;
            request_x.fee2payeeid2 = fee2payeeid2;
            request_x.fee2payeeid3 = fee2payeeid3;
            request_x.fee2payeeid4 = fee2payeeid4;
            request_x.fee3payeeid = fee3payeeid;
            request_x.fee3payeeid2 = fee3payeeid2;
            request_x.fee3payeeid3 = fee3payeeid3;
            request_x.fee3payeeid4 = fee3payeeid4;
            request_x.fee4payeeid = fee4payeeid;
            request_x.fee4payeeid2 = fee4payeeid2;
            request_x.fee4payeeid3 = fee4payeeid3;
            request_x.fee4payeeid4 = fee4payeeid4;
            request_x.fee5payeeid = fee5payeeid;
            request_x.fee5payeeid2 = fee5payeeid2;
            request_x.fee5payeeid3 = fee5payeeid3;
            request_x.fee5payeeid4 = fee5payeeid4;
            request_x.fee6payeeid = fee6payeeid;
            request_x.fee6payeeid2 = fee6payeeid2;
            request_x.fee6payeeid3 = fee6payeeid3;
            request_x.fee6payeeid4 = fee6payeeid4;
            request_x.fee7payeeid = fee7payeeid;
            request_x.fee7payeeid2 = fee7payeeid2;
            request_x.fee7payeeid3 = fee7payeeid3;
            request_x.fee7payeeid4 = fee7payeeid4;
            request_x.fee1split1 = fee1split1;
            request_x.fee1split2 = fee1split2;
            request_x.fee1split3 = fee1split3;
            request_x.fee1split4 = fee1split4;
            request_x.fee2split1 = fee2split1;
            request_x.fee2split2 = fee2split2;
            request_x.fee2split3 = fee2split3;
            request_x.fee2split4 = fee2split4;
            request_x.fee3split1 = fee3split1;
            request_x.fee3split2 = fee3split2;
            request_x.fee3split3 = fee3split3;
            request_x.fee3split4 = fee3split4;
            request_x.fee4split1 = fee4split1;
            request_x.fee4split2 = fee4split2;
            request_x.fee4split3 = fee4split3;
            request_x.fee4split4 = fee4split4;
            request_x.fee5split1 = fee5split1;
            request_x.fee5split2 = fee5split2;
            request_x.fee5split3 = fee5split3;
            request_x.fee5split4 = fee5split4;
            request_x.fee6split1 = fee6split1;
            request_x.fee6split2 = fee6split2;
            request_x.fee6split3 = fee6split3;
            request_x.fee6split4 = fee6split4;
            request_x.fee7split1 = fee7split1;
            request_x.fee7split2 = fee7split2;
            request_x.fee7split3 = fee7split3;
            request_x.fee7split4 = fee7split4;
            request_x.fee1name = fee1name;
            request_x.fee2name = fee2name;
            request_x.fee3name = fee3name;
            request_x.fee4name = fee4name;
            request_x.fee5name = fee5name;
            request_x.fee6name = fee6name;
            request_x.fee7name = fee7name;
            Map<String, RAMServiceGateway.UpdateFeeGroupResponse_element> response_map_x = new Map<String, RAMServiceGateway.UpdateFeeGroupResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UpdateFeeGroup',
                'http://www.ramservicing.com/',
                'UpdateFeeGroup',
                'http://www.ramservicing.com/',
                'UpdateFeeGroupResponse',
                'RAMServiceGateway.UpdateFeeGroupResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateFeeGroupResult;
        }

        public String UpdateFeeGroup2(String sessid,Integer GroupID,String GroupName,Boolean fee1isamt,Boolean fee2isamt,Boolean fee3isamt,Boolean fee4isamt,Boolean fee5isamt,Boolean fee6isamt,Boolean fee7isamt,Integer fee1payeeid,Integer fee1payeeid2,Integer fee1payeeid3,Integer fee1payeeid4,Integer fee2payeeid,Integer fee2payeeid2,Integer fee2payeeid3,Integer fee2payeeid4,Integer fee3payeeid,Integer fee3payeeid2,Integer fee3payeeid3,Integer fee3payeeid4,Integer fee4payeeid,Integer fee4payeeid2,Integer fee4payeeid3,Integer fee4payeeid4,Integer fee5payeeid,Integer fee5payeeid2,Integer fee5payeeid3,Integer fee5payeeid4,Integer fee6payeeid,Integer fee6payeeid2,Integer fee6payeeid3,Integer fee6payeeid4,Integer fee7payeeid,Integer fee7payeeid2,Integer fee7payeeid3,Integer fee7payeeid4,Double fee1split1,Double fee1split2,Double fee1split3,Double fee1split4,Double fee2split1,Double fee2split2,Double fee2split3,Double fee2split4,Double fee3split1,Double fee3split2,Double fee3split3,Double fee3split4,Double fee4split1,Double fee4split2,Double fee4split3,Double fee4split4,Double fee5split1,Double fee5split2,Double fee5split3,Double fee5split4,Double fee6split1,Double fee6split2,Double fee6split3,Double fee6split4,Double fee7split1,Double fee7split2,Double fee7split3,Double fee7split4,String fee1name,String fee2name,String fee3name,String fee4name,String fee5name,String fee6name,String fee7name,Boolean holdfee1,Boolean holdfee2,Boolean holdfee3,Boolean holdfee4,Boolean holdfee5,Boolean holdfee6,Boolean holdfee7,Boolean Fee1IEF,Boolean fee2ief,Boolean fee3ief,Boolean fee4ief,Boolean fee5ief,Boolean fee6IEF,Boolean fee7IEF,Boolean fee1LDF,Boolean fee2LDF,Boolean fee3LDF,Boolean fee4LDF,Boolean fee5LDF,Boolean fee6LDF,Boolean fee7LDF,Boolean Iscontingency,Boolean UsesAttorneyFlow,Double LDFAmount,Double OpFeeAmount,Double IEFPercentage,Integer AttorneyAffiliateID) {
            RAMServiceGateway.UpdateFeeGroup2_element request_x = new RAMServiceGateway.UpdateFeeGroup2_element();
            RAMServiceGateway.UpdateFeeGroup2Response_element response_x;
            request_x.sessid = sessid;
            request_x.GroupID = GroupID;
            request_x.GroupName = GroupName;
            request_x.fee1isamt = fee1isamt;
            request_x.fee2isamt = fee2isamt;
            request_x.fee3isamt = fee3isamt;
            request_x.fee4isamt = fee4isamt;
            request_x.fee5isamt = fee5isamt;
            request_x.fee6isamt = fee6isamt;
            request_x.fee7isamt = fee7isamt;
            request_x.fee1payeeid = fee1payeeid;
            request_x.fee1payeeid2 = fee1payeeid2;
            request_x.fee1payeeid3 = fee1payeeid3;
            request_x.fee1payeeid4 = fee1payeeid4;
            request_x.fee2payeeid = fee2payeeid;
            request_x.fee2payeeid2 = fee2payeeid2;
            request_x.fee2payeeid3 = fee2payeeid3;
            request_x.fee2payeeid4 = fee2payeeid4;
            request_x.fee3payeeid = fee3payeeid;
            request_x.fee3payeeid2 = fee3payeeid2;
            request_x.fee3payeeid3 = fee3payeeid3;
            request_x.fee3payeeid4 = fee3payeeid4;
            request_x.fee4payeeid = fee4payeeid;
            request_x.fee4payeeid2 = fee4payeeid2;
            request_x.fee4payeeid3 = fee4payeeid3;
            request_x.fee4payeeid4 = fee4payeeid4;
            request_x.fee5payeeid = fee5payeeid;
            request_x.fee5payeeid2 = fee5payeeid2;
            request_x.fee5payeeid3 = fee5payeeid3;
            request_x.fee5payeeid4 = fee5payeeid4;
            request_x.fee6payeeid = fee6payeeid;
            request_x.fee6payeeid2 = fee6payeeid2;
            request_x.fee6payeeid3 = fee6payeeid3;
            request_x.fee6payeeid4 = fee6payeeid4;
            request_x.fee7payeeid = fee7payeeid;
            request_x.fee7payeeid2 = fee7payeeid2;
            request_x.fee7payeeid3 = fee7payeeid3;
            request_x.fee7payeeid4 = fee7payeeid4;
            request_x.fee1split1 = fee1split1;
            request_x.fee1split2 = fee1split2;
            request_x.fee1split3 = fee1split3;
            request_x.fee1split4 = fee1split4;
            request_x.fee2split1 = fee2split1;
            request_x.fee2split2 = fee2split2;
            request_x.fee2split3 = fee2split3;
            request_x.fee2split4 = fee2split4;
            request_x.fee3split1 = fee3split1;
            request_x.fee3split2 = fee3split2;
            request_x.fee3split3 = fee3split3;
            request_x.fee3split4 = fee3split4;
            request_x.fee4split1 = fee4split1;
            request_x.fee4split2 = fee4split2;
            request_x.fee4split3 = fee4split3;
            request_x.fee4split4 = fee4split4;
            request_x.fee5split1 = fee5split1;
            request_x.fee5split2 = fee5split2;
            request_x.fee5split3 = fee5split3;
            request_x.fee5split4 = fee5split4;
            request_x.fee6split1 = fee6split1;
            request_x.fee6split2 = fee6split2;
            request_x.fee6split3 = fee6split3;
            request_x.fee6split4 = fee6split4;
            request_x.fee7split1 = fee7split1;
            request_x.fee7split2 = fee7split2;
            request_x.fee7split3 = fee7split3;
            request_x.fee7split4 = fee7split4;
            request_x.fee1name = fee1name;
            request_x.fee2name = fee2name;
            request_x.fee3name = fee3name;
            request_x.fee4name = fee4name;
            request_x.fee5name = fee5name;
            request_x.fee6name = fee6name;
            request_x.fee7name = fee7name;
            request_x.holdfee1 = holdfee1;
            request_x.holdfee2 = holdfee2;
            request_x.holdfee3 = holdfee3;
            request_x.holdfee4 = holdfee4;
            request_x.holdfee5 = holdfee5;
            request_x.holdfee6 = holdfee6;
            request_x.holdfee7 = holdfee7;
            request_x.Fee1IEF = Fee1IEF;
            request_x.fee2ief = fee2ief;
            request_x.fee3ief = fee3ief;
            request_x.fee4ief = fee4ief;
            request_x.fee5ief = fee5ief;
            request_x.fee6IEF = fee6IEF;
            request_x.fee7IEF = fee7IEF;
            request_x.fee1LDF = fee1LDF;
            request_x.fee2LDF = fee2LDF;
            request_x.fee3LDF = fee3LDF;
            request_x.fee4LDF = fee4LDF;
            request_x.fee5LDF = fee5LDF;
            request_x.fee6LDF = fee6LDF;
            request_x.fee7LDF = fee7LDF;
            request_x.Iscontingency = Iscontingency;
            request_x.UsesAttorneyFlow = UsesAttorneyFlow;
            request_x.LDFAmount = LDFAmount;
            request_x.OpFeeAmount = OpFeeAmount;
            request_x.IEFPercentage = IEFPercentage;
            request_x.AttorneyAffiliateID = AttorneyAffiliateID;
            Map<String, RAMServiceGateway.UpdateFeeGroup2Response_element> response_map_x = new Map<String, RAMServiceGateway.UpdateFeeGroup2Response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UpdateFeeGroup2',
                'http://www.ramservicing.com/',
                'UpdateFeeGroup2',
                'http://www.ramservicing.com/',
                'UpdateFeeGroup2Response',
                'RAMServiceGateway.UpdateFeeGroup2Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateFeeGroup2Result;
        }*/

        public Double UploadCardAuth(String sessid,String ClientID,String DocBody,Integer CardID) {
            RAMServiceGateway.UploadCardAuth_element request_x = new RAMServiceGateway.UploadCardAuth_element();
            RAMServiceGateway.UploadCardAuthResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.DocBody = DocBody;
            request_x.CardID = CardID;
            Map<String, RAMServiceGateway.UploadCardAuthResponse_element> response_map_x = new Map<String, RAMServiceGateway.UploadCardAuthResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UploadCardAuth',
                'http://www.ramservicing.com/',
                'UploadCardAuth',
                'http://www.ramservicing.com/',
                'UploadCardAuthResponse',
                'RAMServiceGateway.UploadCardAuthResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UploadCardAuthResult;
        }

        public Double UploadClientDocument(String sessid,String ClientID,String DocType,String DocBody) {
            RAMServiceGateway.UploadClientDocument_element request_x = new RAMServiceGateway.UploadClientDocument_element();
            RAMServiceGateway.UploadClientDocumentResponse_element response_x;
            request_x.sessid = sessid;
            request_x.ClientID = ClientID;
            request_x.DocType = DocType;
            request_x.DocBody = DocBody;
            Map<String, RAMServiceGateway.UploadClientDocumentResponse_element> response_map_x = new Map<String, RAMServiceGateway.UploadClientDocumentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                'http://www.ramservicing.com/UploadClientDocument',
                'http://www.ramservicing.com/',
                'UploadClientDocument',
                'http://www.ramservicing.com/',
                'UploadClientDocumentResponse',
                'RAMServiceGateway.UploadClientDocumentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UploadClientDocumentResult;
        }
    }
    public class ReleaseClientFeesandSavings_element {
        public String sessid;
        public Integer clientid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid'};
    }
    public class ReleaseClientFeesandSavingsResponse_element {
        public String ReleaseClientFeesandSavingsResult;
        private String[] ReleaseClientFeesandSavingsResult_type_info = new String[]{'ReleaseClientFeesandSavingsResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ReleaseClientFeesandSavingsResult'};
    }
    public class RemoveAllSettlements_element {
        public String sessid;
        public String clientid;
        public String ExtendedCCID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedCCID_type_info = new String[]{'ExtendedCCID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid','ExtendedCCID'};
    }
    public class RemoveAllSettlementsResponse_element {
        public RAMServiceGateway.RemoveAllSettlementsResponse_RemoveAllSettlementsResult_element RemoveAllSettlementsResult;
        private String[] RemoveAllSettlementsResult_type_info = new String[]{'RemoveAllSettlementsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'RemoveAllSettlementsResult'};
    }
    public class RemoveAllSettlementsResponse_RemoveAllSettlementsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class RemoveClientCard_element {
        public String sessid;
        public Integer ClientID;
        public Integer CardID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] CardID_type_info = new String[]{'CardID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','CardID'};
    }
    public class RemoveClientCardResponse_element {
        public String RemoveClientCardResult;
        private String[] RemoveClientCardResult_type_info = new String[]{'RemoveClientCardResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'RemoveClientCardResult'};
    }
    public class RemoveSettlement_element {
        public String sessid;
        public Integer RAMID;
        public String ExtendedID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] RAMID_type_info = new String[]{'RAMID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','RAMID','ExtendedID'};
    }
    public class RemoveSettlementResponse_element {
        public String RemoveSettlementResult;
        private String[] RemoveSettlementResult_type_info = new String[]{'RemoveSettlementResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'RemoveSettlementResult'};
    }
    public class RemoveUser_element {
        public String sessid;
        public String clientid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientid_type_info = new String[]{'clientid','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientid'};
    }
    public class RemoveUserResponse_element {
        public String RemoveUserResult;
        private String[] RemoveUserResult_type_info = new String[]{'RemoveUserResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'RemoveUserResult'};
    }
    public class Report_Cancellations_element {
        public String sessid;
        public DateTime StartDate;
        public DateTime EndDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] StartDate_type_info = new String[]{'StartDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] EndDate_type_info = new String[]{'EndDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','StartDate','EndDate'};
    }
    public class Report_CancellationsResponse_element {
        public RAMServiceGateway.Report_CancellationsResponse_Report_CancellationsResult_element Report_CancellationsResult;
        private String[] Report_CancellationsResult_type_info = new String[]{'Report_CancellationsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_CancellationsResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_CancellationsResponse_Report_CancellationsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_ClientActivity_element {
        public String sessid;
        public DateTime StartDate;
        public DateTime EndDate;
        public Integer ClientID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] StartDate_type_info = new String[]{'StartDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] EndDate_type_info = new String[]{'EndDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','StartDate','EndDate','ClientID'};
    }
    public class Report_ClientActivityResponse_element {
        public RAMServiceGateway.Report_ClientActivityResponse_Report_ClientActivityResult_element Report_ClientActivityResult;
        private String[] Report_ClientActivityResult_type_info = new String[]{'Report_ClientActivityResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_ClientActivityResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_ClientActivityResponse_Report_ClientActivityResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_ClientReturns_element {
        public String sessid;
        public DateTime StartDate;
        public DateTime EndDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] StartDate_type_info = new String[]{'StartDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] EndDate_type_info = new String[]{'EndDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','StartDate','EndDate'};
    }
    public class Report_ClientReturnsResponse_element {
        public RAMServiceGateway.Report_ClientReturnsResponse_Report_ClientReturnsResult_element Report_ClientReturnsResult;
        private String[] Report_ClientReturnsResult_type_info = new String[]{'Report_ClientReturnsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_ClientReturnsResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_ClientReturnsResponse_Report_ClientReturnsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_ClientsOnHold_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class Report_ClientsOnHoldResponse_element {
        public RAMServiceGateway.Report_ClientsOnHoldResponse_Report_ClientsOnHoldResult_element Report_ClientsOnHoldResult;
        private String[] Report_ClientsOnHoldResult_type_info = new String[]{'Report_ClientsOnHoldResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_ClientsOnHoldResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_ClientsOnHoldResponse_Report_ClientsOnHoldResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_FeeAccrualBalance_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class Report_FeeAccrualBalanceResponse_element {
        public RAMServiceGateway.Report_FeeAccrualBalanceResponse_Report_FeeAccrualBalanceResult_element Report_FeeAccrualBalanceResult;
        private String[] Report_FeeAccrualBalanceResult_type_info = new String[]{'Report_FeeAccrualBalanceResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_FeeAccrualBalanceResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_FeeAccrualBalanceResponse_Report_FeeAccrualBalanceResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_OutstandingChecks_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class Report_OutstandingChecksResponse_element {
        public RAMServiceGateway.Report_OutstandingChecksResponse_Report_OutstandingChecksResult_element Report_OutstandingChecksResult;
        private String[] Report_OutstandingChecksResult_type_info = new String[]{'Report_OutstandingChecksResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_OutstandingChecksResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_OutstandingChecksResponse_Report_OutstandingChecksResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_PostedPayments_element {
        public String sessid;
        public Integer AffiliateID;
        public DateTime StartDate;
        public DateTime EndDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] AffiliateID_type_info = new String[]{'AffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] StartDate_type_info = new String[]{'StartDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] EndDate_type_info = new String[]{'EndDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','AffiliateID','StartDate','EndDate'};
    }
    public class Report_PostedPaymentsFromTrust_element {
        public String sessid;
        public Integer AffiliateID;
        public DateTime StartDate;
        public DateTime EndDate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] AffiliateID_type_info = new String[]{'AffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] StartDate_type_info = new String[]{'StartDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] EndDate_type_info = new String[]{'EndDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','AffiliateID','StartDate','EndDate'};
    }
    public class Report_PostedPaymentsFromTrustResponse_element {
        public RAMServiceGateway.Report_PostedPaymentsFromTrustResponse_Report_PostedPaymentsFromTrustResult_element Report_PostedPaymentsFromTrustResult;
        private String[] Report_PostedPaymentsFromTrustResult_type_info = new String[]{'Report_PostedPaymentsFromTrustResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_PostedPaymentsFromTrustResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_PostedPaymentsFromTrustResponse_Report_PostedPaymentsFromTrustResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_PostedPaymentsResponse_element {
        public RAMServiceGateway.Report_PostedPaymentsResponse_Report_PostedPaymentsResult_element Report_PostedPaymentsResult;
        private String[] Report_PostedPaymentsResult_type_info = new String[]{'Report_PostedPaymentsResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_PostedPaymentsResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_PostedPaymentsResponse_Report_PostedPaymentsResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_SavingsSummary_element {
        public String sessid;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid'};
    }
    public class Report_SavingsSummaryResponse_element {
        public RAMServiceGateway.Report_SavingsSummaryResponse_Report_SavingsSummaryResult_element Report_SavingsSummaryResult;
        private String[] Report_SavingsSummaryResult_type_info = new String[]{'Report_SavingsSummaryResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_SavingsSummaryResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_SavingsSummaryResponse_Report_SavingsSummaryResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class Report_TrackingByDate_element {
        public String sessid;
        public DateTime startdate;
        public DateTime enddate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] startdate_type_info = new String[]{'startdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] enddate_type_info = new String[]{'enddate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','startdate','enddate'};
    }
    public class Report_TrackingByDateResponse_element {
        public RAMServiceGateway.Report_TrackingByDateResponse_Report_TrackingByDateResult_element Report_TrackingByDateResult;
        private String[] Report_TrackingByDateResult_type_info = new String[]{'Report_TrackingByDateResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'Report_TrackingByDateResult'};
    }
    
    //Warning: Ignoring <s:element ref="s:schema"/> sequence Element
    public class Report_TrackingByDateResponse_Report_TrackingByDateResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class RVDVerify_element {
        public String sessid;
        public RAMServiceGateway.RVDVerify_inputtable_element inputtable;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] inputtable_type_info = new String[]{'inputtable','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','inputtable'};
    }
    public class RVDVerify_inputtable_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class RVDVerifyResponse_element {
        public RAMServiceGateway.RVDVerifyResponse_RVDVerifyResult_element RVDVerifyResult;
        private String[] RVDVerifyResult_type_info = new String[]{'RVDVerifyResult','http://www.ramservicing.com/','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'RVDVerifyResult'};
    }
    public class RVDVerifyResponse_RVDVerifyResult_element {
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ScheduleClientCardCharge_element {
        public String sessid;
        public Integer clientID;
        public Integer CardID;
        public String extendedID;
        public Double fee1;
        public Double fee2;
        public Double fee3;
        public Double fee4;
        public Double fee5;
        public Double fee6;
        public Double fee7;
        public Double TotalPaymentAmount;
        public Double savings;
        public DateTime paymentdate;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] CardID_type_info = new String[]{'CardID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] extendedID_type_info = new String[]{'extendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1_type_info = new String[]{'fee1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2_type_info = new String[]{'fee2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3_type_info = new String[]{'fee3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4_type_info = new String[]{'fee4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5_type_info = new String[]{'fee5','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6_type_info = new String[]{'fee6','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7_type_info = new String[]{'fee7','http://www.ramservicing.com/','double','1','1','false'};
        private String[] TotalPaymentAmount_type_info = new String[]{'TotalPaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] savings_type_info = new String[]{'savings','http://www.ramservicing.com/','double','1','1','false'};
        private String[] paymentdate_type_info = new String[]{'paymentdate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientID','CardID','extendedID','fee1','fee2','fee3','fee4','fee5','fee6','fee7','TotalPaymentAmount','savings','paymentdate'};
    }
    public class ScheduleClientCardChargeResponse_element {
        public RAMServiceGateway.ArrayOfString ScheduleClientCardChargeResult;
        private String[] ScheduleClientCardChargeResult_type_info = new String[]{'ScheduleClientCardChargeResult','http://www.ramservicing.com/','ArrayOfString','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ScheduleClientCardChargeResult'};
    }
    public class SetClientFees_element {
        public String sessid;
        public String ClientID;
        public Double FeeAmount;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] FeeAmount_type_info = new String[]{'FeeAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','FeeAmount'};
    }
    public class SetClientFeesResponse_element {
        public String SetClientFeesResult;
        private String[] SetClientFeesResult_type_info = new String[]{'SetClientFeesResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SetClientFeesResult'};
    }
    public class SetClientPhase_element {
        public String sessid;
        public String ClientID;
        public Integer Phase;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phase_type_info = new String[]{'Phase','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','Phase'};
    }
    public class SetClientPhaseResponse_element {
        public String SetClientPhaseResult;
        private String[] SetClientPhaseResult_type_info = new String[]{'SetClientPhaseResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SetClientPhaseResult'};
    }
    public class SettlementAddSinglePayment_element {
        public String sessid;
        public Integer clientID;
        public Double PaymentAmount;
        public DateTime PaymentDate;
        public String PaymentType;
        public String PayeeName;
        public String PayeeAddress;
        public String PayeeAddress2;
        public String PayeeCity;
        public String PayeeStateAbbrev;
        public String PayeeZIP;
        public String PayeePhone;
        public String PayeeMailTo;
        public String PayeeClientAccountNumber;
        public String PaymentNotes;
        public String PayeebankAccountNumber;
        public String PayeeBankAccountRouting;
        public String PayeeBankAccountName;
        public String PayeeBankName;
        public String PayeeBankAddress;
        public String PayeeBankCity;
        public String PayeeBankStateAbbrev;
        public String PayeeBankZIP;
        public String taxidlast4;
        public String PayByPhoneNumber;
        public String PayByPhoneContact;
        public String CreditorName;
        public String ReferenceNumber;
        public String ExtendedID;
        public String ExtendedCreditorID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PaymentAmount_type_info = new String[]{'PaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PaymentDate_type_info = new String[]{'PaymentDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] PaymentType_type_info = new String[]{'PaymentType','http://www.ramservicing.com/','SETTLEMENT_PAYMENTYPE','1','1','false'};
        private String[] PayeeName_type_info = new String[]{'PayeeName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress_type_info = new String[]{'PayeeAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress2_type_info = new String[]{'PayeeAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeCity_type_info = new String[]{'PayeeCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeStateAbbrev_type_info = new String[]{'PayeeStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeZIP_type_info = new String[]{'PayeeZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeePhone_type_info = new String[]{'PayeePhone','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeMailTo_type_info = new String[]{'PayeeMailTo','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeClientAccountNumber_type_info = new String[]{'PayeeClientAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PaymentNotes_type_info = new String[]{'PaymentNotes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeebankAccountNumber_type_info = new String[]{'PayeebankAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountRouting_type_info = new String[]{'PayeeBankAccountRouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountName_type_info = new String[]{'PayeeBankAccountName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankName_type_info = new String[]{'PayeeBankName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAddress_type_info = new String[]{'PayeeBankAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankCity_type_info = new String[]{'PayeeBankCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankStateAbbrev_type_info = new String[]{'PayeeBankStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankZIP_type_info = new String[]{'PayeeBankZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] taxidlast4_type_info = new String[]{'taxidlast4','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneNumber_type_info = new String[]{'PayByPhoneNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneContact_type_info = new String[]{'PayByPhoneContact','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CreditorName_type_info = new String[]{'CreditorName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ReferenceNumber_type_info = new String[]{'ReferenceNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedCreditorID_type_info = new String[]{'ExtendedCreditorID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientID','PaymentAmount','PaymentDate','PaymentType','PayeeName','PayeeAddress','PayeeAddress2','PayeeCity','PayeeStateAbbrev','PayeeZIP','PayeePhone','PayeeMailTo','PayeeClientAccountNumber','PaymentNotes','PayeebankAccountNumber','PayeeBankAccountRouting','PayeeBankAccountName','PayeeBankName','PayeeBankAddress','PayeeBankCity','PayeeBankStateAbbrev','PayeeBankZIP','taxidlast4','PayByPhoneNumber','PayByPhoneContact','CreditorName','ReferenceNumber','ExtendedID','ExtendedCreditorID'};
    }
    public class SettlementAddSinglePaymentResponse_element {
        public Integer SettlementAddSinglePaymentResult;
        private String[] SettlementAddSinglePaymentResult_type_info = new String[]{'SettlementAddSinglePaymentResult','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SettlementAddSinglePaymentResult'};
    }
    public class SettlementAddSinglePaymentWithFee_element {
        public String sessid;
        public Integer clientID;
        public Double PaymentAmount;
        public DateTime PaymentDate;
        public String PaymentType;
        public String PayeeName;
        public String PayeeAddress;
        public String PayeeAddress2;
        public String PayeeCity;
        public String PayeeStateAbbrev;
        public String PayeeZIP;
        public String PayeeClientAccountNumber;
        public String PaymentNotes;
        public String PayeebankAccountNumber;
        public String PayeeBankAccountRouting;
        public String PayeeBankAccountName;
        public String PayeeBankName;
        public String PayeeBankAddress;
        public String PayeeBankCity;
        public String PayeeBankStateAbbrev;
        public String PayeeBankZIP;
        public String taxidlast4;
        public String PayByPhoneNumber;
        public String PayByPhoneContact;
        public String CreditorName;
        public String ReferenceNumber;
        public String PayeeMailTo;
        public Double AdditionalFees;
        public String ExtendedID;
        public String ExtendedCreditorID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PaymentAmount_type_info = new String[]{'PaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PaymentDate_type_info = new String[]{'PaymentDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] PaymentType_type_info = new String[]{'PaymentType','http://www.ramservicing.com/','SETTLEMENT_PAYMENTYPE','1','1','false'};
        private String[] PayeeName_type_info = new String[]{'PayeeName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress_type_info = new String[]{'PayeeAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress2_type_info = new String[]{'PayeeAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeCity_type_info = new String[]{'PayeeCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeStateAbbrev_type_info = new String[]{'PayeeStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeZIP_type_info = new String[]{'PayeeZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeClientAccountNumber_type_info = new String[]{'PayeeClientAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PaymentNotes_type_info = new String[]{'PaymentNotes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeebankAccountNumber_type_info = new String[]{'PayeebankAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountRouting_type_info = new String[]{'PayeeBankAccountRouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountName_type_info = new String[]{'PayeeBankAccountName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankName_type_info = new String[]{'PayeeBankName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAddress_type_info = new String[]{'PayeeBankAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankCity_type_info = new String[]{'PayeeBankCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankStateAbbrev_type_info = new String[]{'PayeeBankStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankZIP_type_info = new String[]{'PayeeBankZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] taxidlast4_type_info = new String[]{'taxidlast4','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneNumber_type_info = new String[]{'PayByPhoneNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneContact_type_info = new String[]{'PayByPhoneContact','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CreditorName_type_info = new String[]{'CreditorName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ReferenceNumber_type_info = new String[]{'ReferenceNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeMailTo_type_info = new String[]{'PayeeMailTo','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AdditionalFees_type_info = new String[]{'AdditionalFees','http://www.ramservicing.com/','double','1','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedCreditorID_type_info = new String[]{'ExtendedCreditorID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','clientID','PaymentAmount','PaymentDate','PaymentType','PayeeName','PayeeAddress','PayeeAddress2','PayeeCity','PayeeStateAbbrev','PayeeZIP','PayeeClientAccountNumber','PaymentNotes','PayeebankAccountNumber','PayeeBankAccountRouting','PayeeBankAccountName','PayeeBankName','PayeeBankAddress','PayeeBankCity','PayeeBankStateAbbrev','PayeeBankZIP','taxidlast4','PayByPhoneNumber','PayByPhoneContact','CreditorName','ReferenceNumber','PayeeMailTo','AdditionalFees','ExtendedID','ExtendedCreditorID'};
    }
    public class SettlementAddSinglePaymentWithFeeResponse_element {
        public Integer SettlementAddSinglePaymentWithFeeResult;
        private String[] SettlementAddSinglePaymentWithFeeResult_type_info = new String[]{'SettlementAddSinglePaymentWithFeeResult','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SettlementAddSinglePaymentWithFeeResult'};
    }
    public class SettlementUpdateSinglePayment_element {
        public String sessid;
        public Integer SettlementID;
        public Integer clientID;
        public Double PaymentAmount;
        public DateTime PaymentDate;
        public String PaymentType;
        public String PayeeName;
        public String PayeeAddress;
        public String PayeeAddress2;
        public String PayeeCity;
        public String PayeeStateAbbrev;
        public String PayeeZIP;
        public String PayeePhone;
        public String PayeeMailTo;
        public String PayeeClientAccountNumber;
        public String PaymentNotes;
        public String PayeebankAccountNumber;
        public String PayeeBankAccountRouting;
        public String PayeeBankAccountName;
        public String PayeeBankName;
        public String PayeeBankAddress;
        public String PayeeBankCity;
        public String PayeeBankStateAbbrev;
        public String PayeeBankZIP;
        public String TaxIDLast4;
        public String PayByPhoneNumber;
        public String PayByPhoneContact;
        public String CreditorName;
        public String ReferenceNumber;
        public String ExtendedID;
        public String ExtendedCreditorID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] SettlementID_type_info = new String[]{'SettlementID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PaymentAmount_type_info = new String[]{'PaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PaymentDate_type_info = new String[]{'PaymentDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] PaymentType_type_info = new String[]{'PaymentType','http://www.ramservicing.com/','SETTLEMENT_PAYMENTYPE','1','1','false'};
        private String[] PayeeName_type_info = new String[]{'PayeeName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress_type_info = new String[]{'PayeeAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress2_type_info = new String[]{'PayeeAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeCity_type_info = new String[]{'PayeeCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeStateAbbrev_type_info = new String[]{'PayeeStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeZIP_type_info = new String[]{'PayeeZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeePhone_type_info = new String[]{'PayeePhone','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeMailTo_type_info = new String[]{'PayeeMailTo','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeClientAccountNumber_type_info = new String[]{'PayeeClientAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PaymentNotes_type_info = new String[]{'PaymentNotes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeebankAccountNumber_type_info = new String[]{'PayeebankAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountRouting_type_info = new String[]{'PayeeBankAccountRouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountName_type_info = new String[]{'PayeeBankAccountName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankName_type_info = new String[]{'PayeeBankName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAddress_type_info = new String[]{'PayeeBankAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankCity_type_info = new String[]{'PayeeBankCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankStateAbbrev_type_info = new String[]{'PayeeBankStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankZIP_type_info = new String[]{'PayeeBankZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxIDLast4_type_info = new String[]{'TaxIDLast4','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneNumber_type_info = new String[]{'PayByPhoneNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneContact_type_info = new String[]{'PayByPhoneContact','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CreditorName_type_info = new String[]{'CreditorName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ReferenceNumber_type_info = new String[]{'ReferenceNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedCreditorID_type_info = new String[]{'ExtendedCreditorID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','SettlementID','clientID','PaymentAmount','PaymentDate','PaymentType','PayeeName','PayeeAddress','PayeeAddress2','PayeeCity','PayeeStateAbbrev','PayeeZIP','PayeePhone','PayeeMailTo','PayeeClientAccountNumber','PaymentNotes','PayeebankAccountNumber','PayeeBankAccountRouting','PayeeBankAccountName','PayeeBankName','PayeeBankAddress','PayeeBankCity','PayeeBankStateAbbrev','PayeeBankZIP','TaxIDLast4','PayByPhoneNumber','PayByPhoneContact','CreditorName','ReferenceNumber','ExtendedID','ExtendedCreditorID'};
    }
    public class SettlementUpdateSinglePaymentExtended_element {
        public String sessid;
        public String ExtendedID;
        public Integer clientID;
        public Double PaymentAmount;
        public DateTime PaymentDate;
        public String PaymentType;
        public String PayeeName;
        public String PayeeAddress;
        public String PayeeAddress2;
        public String PayeeCity;
        public String PayeeStateAbbrev;
        public String PayeeZIP;
        public String PayeePhone;
        public String PayeeMailTo;
        public String PayeeClientAccountNumber;
        public String PaymentNotes;
        public String PayeebankAccountNumber;
        public String PayeeBankAccountRouting;
        public String PayeeBankAccountName;
        public String PayeeBankName;
        public String PayeeBankAddress;
        public String PayeeBankCity;
        public String PayeeBankStateAbbrev;
        public String PayeeBankZIP;
        public String TaxIDLast4;
        public String PayByPhoneNumber;
        public String PayByPhoneContact;
        public String CreditorName;
        public String ReferenceNumber;
        public String ExtendedCreditorID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PaymentAmount_type_info = new String[]{'PaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PaymentDate_type_info = new String[]{'PaymentDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] PaymentType_type_info = new String[]{'PaymentType','http://www.ramservicing.com/','SETTLEMENT_PAYMENTYPE','1','1','false'};
        private String[] PayeeName_type_info = new String[]{'PayeeName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress_type_info = new String[]{'PayeeAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress2_type_info = new String[]{'PayeeAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeCity_type_info = new String[]{'PayeeCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeStateAbbrev_type_info = new String[]{'PayeeStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeZIP_type_info = new String[]{'PayeeZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeePhone_type_info = new String[]{'PayeePhone','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeMailTo_type_info = new String[]{'PayeeMailTo','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeClientAccountNumber_type_info = new String[]{'PayeeClientAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PaymentNotes_type_info = new String[]{'PaymentNotes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeebankAccountNumber_type_info = new String[]{'PayeebankAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountRouting_type_info = new String[]{'PayeeBankAccountRouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountName_type_info = new String[]{'PayeeBankAccountName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankName_type_info = new String[]{'PayeeBankName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAddress_type_info = new String[]{'PayeeBankAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankCity_type_info = new String[]{'PayeeBankCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankStateAbbrev_type_info = new String[]{'PayeeBankStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankZIP_type_info = new String[]{'PayeeBankZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxIDLast4_type_info = new String[]{'TaxIDLast4','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneNumber_type_info = new String[]{'PayByPhoneNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneContact_type_info = new String[]{'PayByPhoneContact','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CreditorName_type_info = new String[]{'CreditorName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ReferenceNumber_type_info = new String[]{'ReferenceNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedCreditorID_type_info = new String[]{'ExtendedCreditorID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ExtendedID','clientID','PaymentAmount','PaymentDate','PaymentType','PayeeName','PayeeAddress','PayeeAddress2','PayeeCity','PayeeStateAbbrev','PayeeZIP','PayeePhone','PayeeMailTo','PayeeClientAccountNumber','PaymentNotes','PayeebankAccountNumber','PayeeBankAccountRouting','PayeeBankAccountName','PayeeBankName','PayeeBankAddress','PayeeBankCity','PayeeBankStateAbbrev','PayeeBankZIP','TaxIDLast4','PayByPhoneNumber','PayByPhoneContact','CreditorName','ReferenceNumber','ExtendedCreditorID'};
    }
    public class SettlementUpdateSinglePaymentExtendedResponse_element {
        public Integer SettlementUpdateSinglePaymentExtendedResult;
        private String[] SettlementUpdateSinglePaymentExtendedResult_type_info = new String[]{'SettlementUpdateSinglePaymentExtendedResult','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SettlementUpdateSinglePaymentExtendedResult'};
    }
    public class SettlementUpdateSinglePaymentResponse_element {
        public Integer SettlementUpdateSinglePaymentResult;
        private String[] SettlementUpdateSinglePaymentResult_type_info = new String[]{'SettlementUpdateSinglePaymentResult','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SettlementUpdateSinglePaymentResult'};
    }
    public class SettlementUpdateSinglePaymentWithFee_element {
        public String sessid;
        public Integer SettlementID;
        public Integer clientID;
        public Double PaymentAmount;
        public DateTime PaymentDate;
        public String PaymentType;
        public String PayeeName;
        public String PayeeAddress;
        public String PayeeAddress2;
        public String PayeeCity;
        public String PayeeStateAbbrev;
        public String PayeeZIP;
        public String PayeeClientAccountNumber;
        public String PaymentNotes;
        public String PayeebankAccountNumber;
        public String PayeeBankAccountRouting;
        public String PayeeBankAccountName;
        public String PayeeBankName;
        public String PayeeBankAddress;
        public String PayeeBankCity;
        public String PayeeBankStateAbbrev;
        public String PayeeBankZIP;
        public String TaxIDLast4;
        public String PayByPhoneNumber;
        public String PayByPhoneContact;
        public String CreditorName;
        public String ReferenceNumber;
        public String PayeeMailTo;
        public Double AdditionalFees;
        public String ExtendedID;
        public String ExtendedCreditorID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] SettlementID_type_info = new String[]{'SettlementID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PaymentAmount_type_info = new String[]{'PaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PaymentDate_type_info = new String[]{'PaymentDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] PaymentType_type_info = new String[]{'PaymentType','http://www.ramservicing.com/','SETTLEMENT_PAYMENTYPE','1','1','false'};
        private String[] PayeeName_type_info = new String[]{'PayeeName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress_type_info = new String[]{'PayeeAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress2_type_info = new String[]{'PayeeAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeCity_type_info = new String[]{'PayeeCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeStateAbbrev_type_info = new String[]{'PayeeStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeZIP_type_info = new String[]{'PayeeZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeClientAccountNumber_type_info = new String[]{'PayeeClientAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PaymentNotes_type_info = new String[]{'PaymentNotes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeebankAccountNumber_type_info = new String[]{'PayeebankAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountRouting_type_info = new String[]{'PayeeBankAccountRouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountName_type_info = new String[]{'PayeeBankAccountName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankName_type_info = new String[]{'PayeeBankName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAddress_type_info = new String[]{'PayeeBankAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankCity_type_info = new String[]{'PayeeBankCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankStateAbbrev_type_info = new String[]{'PayeeBankStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankZIP_type_info = new String[]{'PayeeBankZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxIDLast4_type_info = new String[]{'TaxIDLast4','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneNumber_type_info = new String[]{'PayByPhoneNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneContact_type_info = new String[]{'PayByPhoneContact','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CreditorName_type_info = new String[]{'CreditorName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ReferenceNumber_type_info = new String[]{'ReferenceNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeMailTo_type_info = new String[]{'PayeeMailTo','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AdditionalFees_type_info = new String[]{'AdditionalFees','http://www.ramservicing.com/','double','1','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ExtendedCreditorID_type_info = new String[]{'ExtendedCreditorID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','SettlementID','clientID','PaymentAmount','PaymentDate','PaymentType','PayeeName','PayeeAddress','PayeeAddress2','PayeeCity','PayeeStateAbbrev','PayeeZIP','PayeeClientAccountNumber','PaymentNotes','PayeebankAccountNumber','PayeeBankAccountRouting','PayeeBankAccountName','PayeeBankName','PayeeBankAddress','PayeeBankCity','PayeeBankStateAbbrev','PayeeBankZIP','TaxIDLast4','PayByPhoneNumber','PayByPhoneContact','CreditorName','ReferenceNumber','PayeeMailTo','AdditionalFees','ExtendedID','ExtendedCreditorID'};
    }
    public class SettlementUpdateSinglePaymentWithFeeByExtendedID_element {
        public String sessid;
        public String ExtendedID;
        public Integer clientID;
        public Double PaymentAmount;
        public DateTime PaymentDate;
        public String PaymentType;
        public String PayeeName;
        public String PayeeAddress;
        public String PayeeAddress2;
        public String PayeeCity;
        public String PayeeStateAbbrev;
        public String PayeeZIP;
        public String PayeeClientAccountNumber;
        public String PaymentNotes;
        public String PayeebankAccountNumber;
        public String PayeeBankAccountRouting;
        public String PayeeBankAccountName;
        public String PayeeBankName;
        public String PayeeBankAddress;
        public String PayeeBankCity;
        public String PayeeBankStateAbbrev;
        public String PayeeBankZIP;
        public String TaxIDLast4;
        public String PayByPhoneNumber;
        public String PayByPhoneContact;
        public String CreditorName;
        public String ReferenceNumber;
        public String PayeeMailTo;
        public Double AdditionalFees;
        public String ExtendedCreditorID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ExtendedID_type_info = new String[]{'ExtendedID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] clientID_type_info = new String[]{'clientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] PaymentAmount_type_info = new String[]{'PaymentAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] PaymentDate_type_info = new String[]{'PaymentDate','http://www.ramservicing.com/','dateTime','1','1','false'};
        private String[] PaymentType_type_info = new String[]{'PaymentType','http://www.ramservicing.com/','SETTLEMENT_PAYMENTYPE','1','1','false'};
        private String[] PayeeName_type_info = new String[]{'PayeeName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress_type_info = new String[]{'PayeeAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeAddress2_type_info = new String[]{'PayeeAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeCity_type_info = new String[]{'PayeeCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeStateAbbrev_type_info = new String[]{'PayeeStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeZIP_type_info = new String[]{'PayeeZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeClientAccountNumber_type_info = new String[]{'PayeeClientAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PaymentNotes_type_info = new String[]{'PaymentNotes','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeebankAccountNumber_type_info = new String[]{'PayeebankAccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountRouting_type_info = new String[]{'PayeeBankAccountRouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAccountName_type_info = new String[]{'PayeeBankAccountName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankName_type_info = new String[]{'PayeeBankName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankAddress_type_info = new String[]{'PayeeBankAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankCity_type_info = new String[]{'PayeeBankCity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankStateAbbrev_type_info = new String[]{'PayeeBankStateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeBankZIP_type_info = new String[]{'PayeeBankZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxIDLast4_type_info = new String[]{'TaxIDLast4','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneNumber_type_info = new String[]{'PayByPhoneNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayByPhoneContact_type_info = new String[]{'PayByPhoneContact','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CreditorName_type_info = new String[]{'CreditorName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ReferenceNumber_type_info = new String[]{'ReferenceNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] PayeeMailTo_type_info = new String[]{'PayeeMailTo','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AdditionalFees_type_info = new String[]{'AdditionalFees','http://www.ramservicing.com/','double','1','1','false'};
        private String[] ExtendedCreditorID_type_info = new String[]{'ExtendedCreditorID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ExtendedID','clientID','PaymentAmount','PaymentDate','PaymentType','PayeeName','PayeeAddress','PayeeAddress2','PayeeCity','PayeeStateAbbrev','PayeeZIP','PayeeClientAccountNumber','PaymentNotes','PayeebankAccountNumber','PayeeBankAccountRouting','PayeeBankAccountName','PayeeBankName','PayeeBankAddress','PayeeBankCity','PayeeBankStateAbbrev','PayeeBankZIP','TaxIDLast4','PayByPhoneNumber','PayByPhoneContact','CreditorName','ReferenceNumber','PayeeMailTo','AdditionalFees','ExtendedCreditorID'};
    }
    public class SettlementUpdateSinglePaymentWithFeeByExtendedIDResponse_element {
        public Integer SettlementUpdateSinglePaymentWithFeeByExtendedIDResult;
        private String[] SettlementUpdateSinglePaymentWithFeeByExtendedIDResult_type_info = new String[]{'SettlementUpdateSinglePaymentWithFeeByExtendedIDResult','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SettlementUpdateSinglePaymentWithFeeByExtendedIDResult'};
    }
    public class SettlementUpdateSinglePaymentWithFeeResponse_element {
        public Integer SettlementUpdateSinglePaymentWithFeeResult;
        private String[] SettlementUpdateSinglePaymentWithFeeResult_type_info = new String[]{'SettlementUpdateSinglePaymentWithFeeResult','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'SettlementUpdateSinglePaymentWithFeeResult'};
    }
    public class StartSession_element {
        public String ClientKey;
        private String[] ClientKey_type_info = new String[]{'ClientKey','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'ClientKey'};
    }
    public class StartSessionResponse_element {
        public String StartSessionResult;
        private String[] StartSessionResult_type_info = new String[]{'StartSessionResult','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'StartSessionResult'};
    }
    public class UpdateAffiliate_element {
        public String sessid;
        public Integer AffiliateID;
        public String Name;
        public String Address;
        public String city;
        public String StateAbbrev;
        public String ZIP;
        public String Phone;
        public String NameonAccount;
        public String bankrouting;
        public String BankaccountNumber;
        public String accounttype;
        public String bankname;
        public String bankcity;
        public String bankphone;
        public String bankstateabbrev;
        public String bankzip;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] AffiliateID_type_info = new String[]{'AffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Name_type_info = new String[]{'Name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Address_type_info = new String[]{'Address','http://www.ramservicing.com/','string','0','1','false'};
        private String[] city_type_info = new String[]{'city','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbrev_type_info = new String[]{'StateAbbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP_type_info = new String[]{'ZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone_type_info = new String[]{'Phone','http://www.ramservicing.com/','string','0','1','false'};
        private String[] NameonAccount_type_info = new String[]{'NameonAccount','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankrouting_type_info = new String[]{'bankrouting','http://www.ramservicing.com/','string','0','1','false'};
        private String[] BankaccountNumber_type_info = new String[]{'BankaccountNumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] accounttype_type_info = new String[]{'accounttype','http://www.ramservicing.com/','BankAccountType','1','1','false'};
        private String[] bankname_type_info = new String[]{'bankname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankcity_type_info = new String[]{'bankcity','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankphone_type_info = new String[]{'bankphone','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankstateabbrev_type_info = new String[]{'bankstateabbrev','http://www.ramservicing.com/','string','0','1','false'};
        private String[] bankzip_type_info = new String[]{'bankzip','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','AffiliateID','Name','Address','city','StateAbbrev','ZIP','Phone','NameonAccount','bankrouting','BankaccountNumber','accounttype','bankname','bankcity','bankphone','bankstateabbrev','bankzip'};
    }
    public class UpdateAffiliateResponse_element {
        public String UpdateAffiliateResult;
        private String[] UpdateAffiliateResult_type_info = new String[]{'UpdateAffiliateResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateAffiliateResult'};
    }
    public class UpdateClient_element {
        public String sessid;
        public Integer ClientID;
        public String Firstname;
        public String Lastname;
        public String FirstName2;
        public String lastname2;
        public String EmailAddress;
        public String TaxID;
        public String TaxID2;
        public String StreetAddress;
        public String City;
        public String ZIP;
        public String StateAbbreviation;
        public String StreetAddress2;
        public String City2;
        public String ZIP2;
        public String StateAbbreviation2;
        public String Phone1;
        public String Phone2;
        public String Phone3;
        public String DOB1;
        public String DOB2;
        public String AccountStatus;
        public Integer AffiliateID;
        public Integer FeeSplitGroupID;
        public String AccountHoldStatus;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Firstname_type_info = new String[]{'Firstname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Lastname_type_info = new String[]{'Lastname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] FirstName2_type_info = new String[]{'FirstName2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] lastname2_type_info = new String[]{'lastname2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxID_type_info = new String[]{'TaxID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxID2_type_info = new String[]{'TaxID2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StreetAddress_type_info = new String[]{'StreetAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] City_type_info = new String[]{'City','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP_type_info = new String[]{'ZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbreviation_type_info = new String[]{'StateAbbreviation','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StreetAddress2_type_info = new String[]{'StreetAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] City2_type_info = new String[]{'City2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP2_type_info = new String[]{'ZIP2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbreviation2_type_info = new String[]{'StateAbbreviation2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone1_type_info = new String[]{'Phone1','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone2_type_info = new String[]{'Phone2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone3_type_info = new String[]{'Phone3','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DOB1_type_info = new String[]{'DOB1','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DOB2_type_info = new String[]{'DOB2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AccountStatus_type_info = new String[]{'AccountStatus','http://www.ramservicing.com/','AccountStatus','1','1','false'};
        private String[] AffiliateID_type_info = new String[]{'AffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] FeeSplitGroupID_type_info = new String[]{'FeeSplitGroupID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] AccountHoldStatus_type_info = new String[]{'AccountHoldStatus','http://www.ramservicing.com/','ACHStatus','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','Firstname','Lastname','FirstName2','lastname2','EmailAddress','TaxID','TaxID2','StreetAddress','City','ZIP','StateAbbreviation','StreetAddress2','City2','ZIP2','StateAbbreviation2','Phone1','Phone2','Phone3','DOB1','DOB2','AccountStatus','AffiliateID','FeeSplitGroupID','AccountHoldStatus'};
    }
    public class UpdateClientAgent_element {
        public String sessid;
        public Integer ClientID;
        public String AgentName;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] AgentName_type_info = new String[]{'AgentName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','AgentName'};
    }
    public class UpdateClientAgentResponse_element {
        public String UpdateClientAgentResult;
        private String[] UpdateClientAgentResult_type_info = new String[]{'UpdateClientAgentResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateClientAgentResult'};
    }
    public class UpdateClientCombined_element {
        public String sessid;
        public Integer ClientID;
        public String Firstname;
        public String Lastname;
        public String Firstname2;
        public String Lastname2;
        public String EmailAddress;
        public String TaxID;
        public String TaxID2;
        public String StreetAddress;
        public String City;
        public String ZIP;
        public String StateAbbreviation;
        public String StreetAddress2;
        public String City2;
        public String ZIP2;
        public String StateAbbreviation2;
        public String Phone1;
        public String Phone2;
        public String Phone3;
        public String DOB1;
        public String DOB2;
        public String AccountStatus;
        public Integer AffiliateID;
        public Integer FeeSplitGroupID;
        public String AccountHoldStatus;
        public String Accountnumber;
        public String NameonAccount;
        public String Routing;
        public String BankName;
        public String AccountType;
        public RAMServiceGateway.ArrayOfPaymentLine PaySchedule;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] Firstname_type_info = new String[]{'Firstname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Lastname_type_info = new String[]{'Lastname','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Firstname2_type_info = new String[]{'Firstname2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Lastname2_type_info = new String[]{'Lastname2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxID_type_info = new String[]{'TaxID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] TaxID2_type_info = new String[]{'TaxID2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StreetAddress_type_info = new String[]{'StreetAddress','http://www.ramservicing.com/','string','0','1','false'};
        private String[] City_type_info = new String[]{'City','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP_type_info = new String[]{'ZIP','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbreviation_type_info = new String[]{'StateAbbreviation','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StreetAddress2_type_info = new String[]{'StreetAddress2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] City2_type_info = new String[]{'City2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] ZIP2_type_info = new String[]{'ZIP2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] StateAbbreviation2_type_info = new String[]{'StateAbbreviation2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone1_type_info = new String[]{'Phone1','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone2_type_info = new String[]{'Phone2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Phone3_type_info = new String[]{'Phone3','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DOB1_type_info = new String[]{'DOB1','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DOB2_type_info = new String[]{'DOB2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AccountStatus_type_info = new String[]{'AccountStatus','http://www.ramservicing.com/','AccountStatus','1','1','false'};
        private String[] AffiliateID_type_info = new String[]{'AffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] FeeSplitGroupID_type_info = new String[]{'FeeSplitGroupID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] AccountHoldStatus_type_info = new String[]{'AccountHoldStatus','http://www.ramservicing.com/','ACHStatus','1','1','false'};
        private String[] Accountnumber_type_info = new String[]{'Accountnumber','http://www.ramservicing.com/','string','0','1','false'};
        private String[] NameonAccount_type_info = new String[]{'NameonAccount','http://www.ramservicing.com/','string','0','1','false'};
        private String[] Routing_type_info = new String[]{'Routing','http://www.ramservicing.com/','string','0','1','false'};
        private String[] BankName_type_info = new String[]{'BankName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] AccountType_type_info = new String[]{'AccountType','http://www.ramservicing.com/','BankAccountType','1','1','false'};
        private String[] PaySchedule_type_info = new String[]{'PaySchedule','http://www.ramservicing.com/','ArrayOfPaymentLine','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','Firstname','Lastname','Firstname2','Lastname2','EmailAddress','TaxID','TaxID2','StreetAddress','City','ZIP','StateAbbreviation','StreetAddress2','City2','ZIP2','StateAbbreviation2','Phone1','Phone2','Phone3','DOB1','DOB2','AccountStatus','AffiliateID','FeeSplitGroupID','AccountHoldStatus','Accountnumber','NameonAccount','Routing','BankName','AccountType','PaySchedule'};
    }
    public class UpdateClientCombinedResponse_element {
        public RAMServiceGateway.ArrayOfPaymentLine UpdateClientCombinedResult;
        private String[] UpdateClientCombinedResult_type_info = new String[]{'UpdateClientCombinedResult','http://www.ramservicing.com/','ArrayOfPaymentLine','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateClientCombinedResult'};
    }
    public class UpdateClientResponse_element {
        public String UpdateClientResult;
        private String[] UpdateClientResult_type_info = new String[]{'UpdateClientResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateClientResult'};
    }
    public class UpdateClientSSN_element {
        public String sessid;
        public String ClientID;
        public String SSN;
        public String MI;
        public String SSN2;
        public String MI2;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] SSN_type_info = new String[]{'SSN','http://www.ramservicing.com/','string','0','1','false'};
        private String[] MI_type_info = new String[]{'MI','http://www.ramservicing.com/','string','0','1','false'};
        private String[] SSN2_type_info = new String[]{'SSN2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] MI2_type_info = new String[]{'MI2','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','SSN','MI','SSN2','MI2'};
    }
    public class UpdateClientSSNResponse_element {
        public String UpdateClientSSNResult;
        private String[] UpdateClientSSNResult_type_info = new String[]{'UpdateClientSSNResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateClientSSNResult'};
    }
    public class UpdateFeeGroup_element {
        public String sessid;
        public Integer GroupID;
        public String GroupName;
        public Boolean fee1isamt;
        public Boolean fee2isamt;
        public Boolean fee3isamt;
        public Boolean fee4isamt;
        public Boolean fee5isamt;
        public Boolean fee6isamt;
        public Boolean fee7isamt;
        public Integer fee1payeeid;
        public Integer fee1payeeid2;
        public Integer fee1payeeid3;
        public Integer fee1payeeid4;
        public Integer fee2payeeid;
        public Integer fee2payeeid2;
        public Integer fee2payeeid3;
        public Integer fee2payeeid4;
        public Integer fee3payeeid;
        public Integer fee3payeeid2;
        public Integer fee3payeeid3;
        public Integer fee3payeeid4;
        public Integer fee4payeeid;
        public Integer fee4payeeid2;
        public Integer fee4payeeid3;
        public Integer fee4payeeid4;
        public Integer fee5payeeid;
        public Integer fee5payeeid2;
        public Integer fee5payeeid3;
        public Integer fee5payeeid4;
        public Integer fee6payeeid;
        public Integer fee6payeeid2;
        public Integer fee6payeeid3;
        public Integer fee6payeeid4;
        public Integer fee7payeeid;
        public Integer fee7payeeid2;
        public Integer fee7payeeid3;
        public Integer fee7payeeid4;
        public Double fee1split1;
        public Double fee1split2;
        public Double fee1split3;
        public Double fee1split4;
        public Double fee2split1;
        public Double fee2split2;
        public Double fee2split3;
        public Double fee2split4;
        public Double fee3split1;
        public Double fee3split2;
        public Double fee3split3;
        public Double fee3split4;
        public Double fee4split1;
        public Double fee4split2;
        public Double fee4split3;
        public Double fee4split4;
        public Double fee5split1;
        public Double fee5split2;
        public Double fee5split3;
        public Double fee5split4;
        public Double fee6split1;
        public Double fee6split2;
        public Double fee6split3;
        public Double fee6split4;
        public Double fee7split1;
        public Double fee7split2;
        public Double fee7split3;
        public Double fee7split4;
        public String fee1name;
        public String fee2name;
        public String fee3name;
        public String fee4name;
        public String fee5name;
        public String fee6name;
        public String fee7name;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] GroupID_type_info = new String[]{'GroupID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] GroupName_type_info = new String[]{'GroupName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1isamt_type_info = new String[]{'fee1isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2isamt_type_info = new String[]{'fee2isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3isamt_type_info = new String[]{'fee3isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4isamt_type_info = new String[]{'fee4isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5isamt_type_info = new String[]{'fee5isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6isamt_type_info = new String[]{'fee6isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7isamt_type_info = new String[]{'fee7isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee1payeeid_type_info = new String[]{'fee1payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid2_type_info = new String[]{'fee1payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid3_type_info = new String[]{'fee1payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid4_type_info = new String[]{'fee1payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid_type_info = new String[]{'fee2payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid2_type_info = new String[]{'fee2payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid3_type_info = new String[]{'fee2payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid4_type_info = new String[]{'fee2payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid_type_info = new String[]{'fee3payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid2_type_info = new String[]{'fee3payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid3_type_info = new String[]{'fee3payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid4_type_info = new String[]{'fee3payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid_type_info = new String[]{'fee4payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid2_type_info = new String[]{'fee4payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid3_type_info = new String[]{'fee4payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid4_type_info = new String[]{'fee4payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid_type_info = new String[]{'fee5payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid2_type_info = new String[]{'fee5payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid3_type_info = new String[]{'fee5payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid4_type_info = new String[]{'fee5payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid_type_info = new String[]{'fee6payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid2_type_info = new String[]{'fee6payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid3_type_info = new String[]{'fee6payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid4_type_info = new String[]{'fee6payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid_type_info = new String[]{'fee7payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid2_type_info = new String[]{'fee7payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid3_type_info = new String[]{'fee7payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid4_type_info = new String[]{'fee7payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1split1_type_info = new String[]{'fee1split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split2_type_info = new String[]{'fee1split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split3_type_info = new String[]{'fee1split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split4_type_info = new String[]{'fee1split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split1_type_info = new String[]{'fee2split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split2_type_info = new String[]{'fee2split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split3_type_info = new String[]{'fee2split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split4_type_info = new String[]{'fee2split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split1_type_info = new String[]{'fee3split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split2_type_info = new String[]{'fee3split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split3_type_info = new String[]{'fee3split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split4_type_info = new String[]{'fee3split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split1_type_info = new String[]{'fee4split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split2_type_info = new String[]{'fee4split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split3_type_info = new String[]{'fee4split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split4_type_info = new String[]{'fee4split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split1_type_info = new String[]{'fee5split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split2_type_info = new String[]{'fee5split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split3_type_info = new String[]{'fee5split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split4_type_info = new String[]{'fee5split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split1_type_info = new String[]{'fee6split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split2_type_info = new String[]{'fee6split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split3_type_info = new String[]{'fee6split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split4_type_info = new String[]{'fee6split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split1_type_info = new String[]{'fee7split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split2_type_info = new String[]{'fee7split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split3_type_info = new String[]{'fee7split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split4_type_info = new String[]{'fee7split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1name_type_info = new String[]{'fee1name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee2name_type_info = new String[]{'fee2name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee3name_type_info = new String[]{'fee3name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee4name_type_info = new String[]{'fee4name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee5name_type_info = new String[]{'fee5name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee6name_type_info = new String[]{'fee6name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee7name_type_info = new String[]{'fee7name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','GroupID','GroupName','fee1isamt','fee2isamt','fee3isamt','fee4isamt','fee5isamt','fee6isamt','fee7isamt','fee1payeeid','fee1payeeid2','fee1payeeid3','fee1payeeid4','fee2payeeid','fee2payeeid2','fee2payeeid3','fee2payeeid4','fee3payeeid','fee3payeeid2','fee3payeeid3','fee3payeeid4','fee4payeeid','fee4payeeid2','fee4payeeid3','fee4payeeid4','fee5payeeid','fee5payeeid2','fee5payeeid3','fee5payeeid4','fee6payeeid','fee6payeeid2','fee6payeeid3','fee6payeeid4','fee7payeeid','fee7payeeid2','fee7payeeid3','fee7payeeid4','fee1split1','fee1split2','fee1split3','fee1split4','fee2split1','fee2split2','fee2split3','fee2split4','fee3split1','fee3split2','fee3split3','fee3split4','fee4split1','fee4split2','fee4split3','fee4split4','fee5split1','fee5split2','fee5split3','fee5split4','fee6split1','fee6split2','fee6split3','fee6split4','fee7split1','fee7split2','fee7split3','fee7split4','fee1name','fee2name','fee3name','fee4name','fee5name','fee6name','fee7name'};
    }
    public class UpdateFeeGroup2_element {
        public String sessid;
        public Integer GroupID;
        public String GroupName;
        public Boolean fee1isamt;
        public Boolean fee2isamt;
        public Boolean fee3isamt;
        public Boolean fee4isamt;
        public Boolean fee5isamt;
        public Boolean fee6isamt;
        public Boolean fee7isamt;
        public Integer fee1payeeid;
        public Integer fee1payeeid2;
        public Integer fee1payeeid3;
        public Integer fee1payeeid4;
        public Integer fee2payeeid;
        public Integer fee2payeeid2;
        public Integer fee2payeeid3;
        public Integer fee2payeeid4;
        public Integer fee3payeeid;
        public Integer fee3payeeid2;
        public Integer fee3payeeid3;
        public Integer fee3payeeid4;
        public Integer fee4payeeid;
        public Integer fee4payeeid2;
        public Integer fee4payeeid3;
        public Integer fee4payeeid4;
        public Integer fee5payeeid;
        public Integer fee5payeeid2;
        public Integer fee5payeeid3;
        public Integer fee5payeeid4;
        public Integer fee6payeeid;
        public Integer fee6payeeid2;
        public Integer fee6payeeid3;
        public Integer fee6payeeid4;
        public Integer fee7payeeid;
        public Integer fee7payeeid2;
        public Integer fee7payeeid3;
        public Integer fee7payeeid4;
        public Double fee1split1;
        public Double fee1split2;
        public Double fee1split3;
        public Double fee1split4;
        public Double fee2split1;
        public Double fee2split2;
        public Double fee2split3;
        public Double fee2split4;
        public Double fee3split1;
        public Double fee3split2;
        public Double fee3split3;
        public Double fee3split4;
        public Double fee4split1;
        public Double fee4split2;
        public Double fee4split3;
        public Double fee4split4;
        public Double fee5split1;
        public Double fee5split2;
        public Double fee5split3;
        public Double fee5split4;
        public Double fee6split1;
        public Double fee6split2;
        public Double fee6split3;
        public Double fee6split4;
        public Double fee7split1;
        public Double fee7split2;
        public Double fee7split3;
        public Double fee7split4;
        public String fee1name;
        public String fee2name;
        public String fee3name;
        public String fee4name;
        public String fee5name;
        public String fee6name;
        public String fee7name;
        public Boolean holdfee1;
        public Boolean holdfee2;
        public Boolean holdfee3;
        public Boolean holdfee4;
        public Boolean holdfee5;
        public Boolean holdfee6;
        public Boolean holdfee7;
        public Boolean Fee1IEF;
        public Boolean fee2ief;
        public Boolean fee3ief;
        public Boolean fee4ief;
        public Boolean fee5ief;
        public Boolean fee6IEF;
        public Boolean fee7IEF;
        public Boolean fee1LDF;
        public Boolean fee2LDF;
        public Boolean fee3LDF;
        public Boolean fee4LDF;
        public Boolean fee5LDF;
        public Boolean fee6LDF;
        public Boolean fee7LDF;
        public Boolean Iscontingency;
        public Boolean UsesAttorneyFlow;
        public Double LDFAmount;
        public Double OpFeeAmount;
        public Double IEFPercentage;
        public Integer AttorneyAffiliateID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] GroupID_type_info = new String[]{'GroupID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] GroupName_type_info = new String[]{'GroupName','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee1isamt_type_info = new String[]{'fee1isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2isamt_type_info = new String[]{'fee2isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3isamt_type_info = new String[]{'fee3isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4isamt_type_info = new String[]{'fee4isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5isamt_type_info = new String[]{'fee5isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6isamt_type_info = new String[]{'fee6isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7isamt_type_info = new String[]{'fee7isamt','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee1payeeid_type_info = new String[]{'fee1payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid2_type_info = new String[]{'fee1payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid3_type_info = new String[]{'fee1payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1payeeid4_type_info = new String[]{'fee1payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid_type_info = new String[]{'fee2payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid2_type_info = new String[]{'fee2payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid3_type_info = new String[]{'fee2payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee2payeeid4_type_info = new String[]{'fee2payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid_type_info = new String[]{'fee3payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid2_type_info = new String[]{'fee3payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid3_type_info = new String[]{'fee3payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee3payeeid4_type_info = new String[]{'fee3payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid_type_info = new String[]{'fee4payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid2_type_info = new String[]{'fee4payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid3_type_info = new String[]{'fee4payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee4payeeid4_type_info = new String[]{'fee4payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid_type_info = new String[]{'fee5payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid2_type_info = new String[]{'fee5payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid3_type_info = new String[]{'fee5payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee5payeeid4_type_info = new String[]{'fee5payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid_type_info = new String[]{'fee6payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid2_type_info = new String[]{'fee6payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid3_type_info = new String[]{'fee6payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee6payeeid4_type_info = new String[]{'fee6payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid_type_info = new String[]{'fee7payeeid','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid2_type_info = new String[]{'fee7payeeid2','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid3_type_info = new String[]{'fee7payeeid3','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee7payeeid4_type_info = new String[]{'fee7payeeid4','http://www.ramservicing.com/','int','1','1','false'};
        private String[] fee1split1_type_info = new String[]{'fee1split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split2_type_info = new String[]{'fee1split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split3_type_info = new String[]{'fee1split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1split4_type_info = new String[]{'fee1split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split1_type_info = new String[]{'fee2split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split2_type_info = new String[]{'fee2split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split3_type_info = new String[]{'fee2split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee2split4_type_info = new String[]{'fee2split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split1_type_info = new String[]{'fee3split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split2_type_info = new String[]{'fee3split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split3_type_info = new String[]{'fee3split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee3split4_type_info = new String[]{'fee3split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split1_type_info = new String[]{'fee4split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split2_type_info = new String[]{'fee4split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split3_type_info = new String[]{'fee4split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee4split4_type_info = new String[]{'fee4split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split1_type_info = new String[]{'fee5split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split2_type_info = new String[]{'fee5split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split3_type_info = new String[]{'fee5split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee5split4_type_info = new String[]{'fee5split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split1_type_info = new String[]{'fee6split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split2_type_info = new String[]{'fee6split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split3_type_info = new String[]{'fee6split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee6split4_type_info = new String[]{'fee6split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split1_type_info = new String[]{'fee7split1','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split2_type_info = new String[]{'fee7split2','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split3_type_info = new String[]{'fee7split3','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee7split4_type_info = new String[]{'fee7split4','http://www.ramservicing.com/','double','1','1','false'};
        private String[] fee1name_type_info = new String[]{'fee1name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee2name_type_info = new String[]{'fee2name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee3name_type_info = new String[]{'fee3name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee4name_type_info = new String[]{'fee4name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee5name_type_info = new String[]{'fee5name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee6name_type_info = new String[]{'fee6name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] fee7name_type_info = new String[]{'fee7name','http://www.ramservicing.com/','string','0','1','false'};
        private String[] holdfee1_type_info = new String[]{'holdfee1','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee2_type_info = new String[]{'holdfee2','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee3_type_info = new String[]{'holdfee3','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee4_type_info = new String[]{'holdfee4','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee5_type_info = new String[]{'holdfee5','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee6_type_info = new String[]{'holdfee6','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] holdfee7_type_info = new String[]{'holdfee7','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] Fee1IEF_type_info = new String[]{'Fee1IEF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2ief_type_info = new String[]{'fee2ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3ief_type_info = new String[]{'fee3ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4ief_type_info = new String[]{'fee4ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5ief_type_info = new String[]{'fee5ief','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6IEF_type_info = new String[]{'fee6IEF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7IEF_type_info = new String[]{'fee7IEF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee1LDF_type_info = new String[]{'fee1LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee2LDF_type_info = new String[]{'fee2LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee3LDF_type_info = new String[]{'fee3LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee4LDF_type_info = new String[]{'fee4LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee5LDF_type_info = new String[]{'fee5LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee6LDF_type_info = new String[]{'fee6LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] fee7LDF_type_info = new String[]{'fee7LDF','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] Iscontingency_type_info = new String[]{'Iscontingency','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] UsesAttorneyFlow_type_info = new String[]{'UsesAttorneyFlow','http://www.ramservicing.com/','boolean','1','1','false'};
        private String[] LDFAmount_type_info = new String[]{'LDFAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] OpFeeAmount_type_info = new String[]{'OpFeeAmount','http://www.ramservicing.com/','double','1','1','false'};
        private String[] IEFPercentage_type_info = new String[]{'IEFPercentage','http://www.ramservicing.com/','double','1','1','false'};
        private String[] AttorneyAffiliateID_type_info = new String[]{'AttorneyAffiliateID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','GroupID','GroupName','fee1isamt','fee2isamt','fee3isamt','fee4isamt','fee5isamt','fee6isamt','fee7isamt','fee1payeeid','fee1payeeid2','fee1payeeid3','fee1payeeid4','fee2payeeid','fee2payeeid2','fee2payeeid3','fee2payeeid4','fee3payeeid','fee3payeeid2','fee3payeeid3','fee3payeeid4','fee4payeeid','fee4payeeid2','fee4payeeid3','fee4payeeid4','fee5payeeid','fee5payeeid2','fee5payeeid3','fee5payeeid4','fee6payeeid','fee6payeeid2','fee6payeeid3','fee6payeeid4','fee7payeeid','fee7payeeid2','fee7payeeid3','fee7payeeid4','fee1split1','fee1split2','fee1split3','fee1split4','fee2split1','fee2split2','fee2split3','fee2split4','fee3split1','fee3split2','fee3split3','fee3split4','fee4split1','fee4split2','fee4split3','fee4split4','fee5split1','fee5split2','fee5split3','fee5split4','fee6split1','fee6split2','fee6split3','fee6split4','fee7split1','fee7split2','fee7split3','fee7split4','fee1name','fee2name','fee3name','fee4name','fee5name','fee6name','fee7name','holdfee1','holdfee2','holdfee3','holdfee4','holdfee5','holdfee6','holdfee7','Fee1IEF','fee2ief','fee3ief','fee4ief','fee5ief','fee6IEF','fee7IEF','fee1LDF','fee2LDF','fee3LDF','fee4LDF','fee5LDF','fee6LDF','fee7LDF','Iscontingency','UsesAttorneyFlow','LDFAmount','OpFeeAmount','IEFPercentage','AttorneyAffiliateID'};
    }
    public class UpdateFeeGroup2Response_element {
        public String UpdateFeeGroup2Result;
        private String[] UpdateFeeGroup2Result_type_info = new String[]{'UpdateFeeGroup2Result','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateFeeGroup2Result'};
    }
    public class UpdateFeeGroupResponse_element {
        public String UpdateFeeGroupResult;
        private String[] UpdateFeeGroupResult_type_info = new String[]{'UpdateFeeGroupResult','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateFeeGroupResult'};
    }
    public class UploadCardAuth_element {
        public String sessid;
        public String ClientID;
        public String DocBody;
        public Integer CardID;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DocBody_type_info = new String[]{'DocBody','http://www.ramservicing.com/','string','0','1','false'};
        private String[] CardID_type_info = new String[]{'CardID','http://www.ramservicing.com/','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','DocBody','CardID'};
    }
    public class UploadCardAuthResponse_element {
        public Double UploadCardAuthResult;
        private String[] UploadCardAuthResult_type_info = new String[]{'UploadCardAuthResult','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UploadCardAuthResult'};
    }
    public class UploadClientDocument_element {
        public String sessid;
        public String ClientID;
        public String DocType;
        public String DocBody;
        private String[] sessid_type_info = new String[]{'sessid','http://www.ramservicing.com/','guid','1','1','false'};
        private String[] ClientID_type_info = new String[]{'ClientID','http://www.ramservicing.com/','string','0','1','false'};
        private String[] DocType_type_info = new String[]{'DocType','http://www.ramservicing.com/','ClientDocumentType','1','1','false'};
        private String[] DocBody_type_info = new String[]{'DocBody','http://www.ramservicing.com/','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'sessid','ClientID','DocType','DocBody'};
    }
    public class UploadClientDocumentResponse_element {
        public Double UploadClientDocumentResult;
        private String[] UploadClientDocumentResult_type_info = new String[]{'UploadClientDocumentResult','http://www.ramservicing.com/','double','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ramservicing.com/','true','false'};
        private String[] field_order_type_info = new String[]{'UploadClientDocumentResult'};
    }
    public class RAMSGatewayVer2SoapException extends Exception{}
}