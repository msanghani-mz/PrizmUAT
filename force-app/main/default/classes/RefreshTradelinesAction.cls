/**
* Class Name  : RefreshTradelinesAction
* Description : Class to refresh the tradelines on lending application
*               by fetching the information fro NuDebt 
* Author      : Financial Spectra
*/
public with sharing class RefreshTradelinesAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private Boolean mIsCalledFromUI;//DV-161
    
    private Map<Id, fsCore__Lending_Application__c> mApplicationMap;
    private Map<Id, List<fsCore__Lending_Application_Itemization__c>> mApplicationItemizationMap;
    private Map<Id, List<fsCore__Product_Itemization_Setup__c>> mProductItemizationMap;
    private String mDedicatedAmountCash = SFS_System_Settings__c.getInstance().DNL_Cash_In_Dedicated_Itm__c;
    private String remainingFeeDueDrp = SFS_System_Settings__c.getInstance().DNL_Rem_Fee_Due_DRP_Itm__c;   //DV-348
    private Map<Id, fsCore__Lending_Application_Itemization__c> mAppToCashInDedicatedItmMap;
    private Map<Id, fsCore__Lending_Application_Itemization__c> mAppToremainingFeeDueDrpMap;  //DV-348
    private List<Opportunity_Draft_Fee__c> mOppDraftFeeList;
    
    public class RefreshTradelinesException extends Exception{}
    
    public RefreshTradelinesAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mIsCalledFromUI = false;
    }

     //DV-161
     public void setIsCalledFromUI(Boolean pIsCalledFromUI){
        mIsCalledFromUI = pIsCalledFromUI;
    }
    
    //action input has the set of application ids
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
        
        //populate application map
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>
            ([SELECT Id, Name
              , Opp_Import_Id__c
              , Opportunity_Name__c
              , Current_Balance__c
              , fsCore__Application_Status__c
              , fsCore__Product_Name__c
              , fsCore__Current_Stage_Name_Formula__c,
              IsTradelineWhileRefresh__c,NuDebt_Total_Actual_Fee__c,
              Cash_In_Dedicated_Account__c
              FROM fsCore__Lending_Application__c 
              WHERE Id IN :mActionInput.getRecords()
              AND fsCore__Is_Application_Read_Only__c = false
              AND fsCore__Is_Funded__c = false
              AND fsCore__Is_Voided__c = false]);
        
        //populate itemization map
        Set<Id> applicationIdSet = mApplicationMap.keySet();
        fsCore.DynamicQueryBuilder itmzQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application_Itemization__c.getName());
        itmzQuery.addFields();
        itmzQuery.addWhereConditionWithBind(1,'fsCore__Lending_Application_Number__c','IN','applicationIdSet');
        
        //itmzQuery.addWhereConditionWithValue(2,'Tradeline_Import_Id__c','!=',null); //PDI-666 Commented because we need to pick cash in dedicated account
        
        List<fsCore__Lending_Application_Itemization__c> itmzQueryResult = (List<fsCore__Lending_Application_Itemization__c>)Database.query(itmzQuery.getQueryString());
        
        mApplicationItemizationMap = new Map<Id, List<fsCore__Lending_Application_Itemization__c>>();
        mAppToCashInDedicatedItmMap = new Map<Id, fsCore__Lending_Application_Itemization__c>();
        mAppToremainingFeeDueDrpMap = new Map<Id, fsCore__Lending_Application_Itemization__c>();   //DV-348
        for(fsCore__Lending_Application_Itemization__c itmz : itmzQueryResult){
            if (itmz.Tradeline_Import_Id__c != null){
                List<fsCore__Lending_Application_Itemization__c> appItmzList = new List<fsCore__Lending_Application_Itemization__c>();
                if (mApplicationItemizationMap.containsKey(itmz.fsCore__Lending_Application_Number__c)){
                    appItmzList = mApplicationItemizationMap.get(itmz.fsCore__Lending_Application_Number__c);
                }
                appItmzList.add(itmz);
                mApplicationItemizationMap.put(itmz.fsCore__Lending_Application_Number__c, appItmzList);
            }else{
                //APP626
                System.debug(loggingLevel.ERROR, 'Checking for ded'+mDedicatedAmountCash);
                if (itmz.Itemization_Code_Formula__c.equalsIgnoreCase(mDedicatedAmountCash)){
                    System.debug(loggingLevel.ERROR, 'Adding '+itmz);
                    mAppToCashInDedicatedItmMap.put(itmz.fsCore__Lending_Application_Number__c,itmz);
                }
                //DV-348
                if (itmz.Itemization_Code_Formula__c.equalsIgnoreCase(remainingFeeDueDrp)){
                    System.debug(loggingLevel.ERROR, 'Adding '+itmz);
                    mAppToremainingFeeDueDrpMap.put(itmz.fsCore__Lending_Application_Number__c,itmz);
                }
                // 
            }
        }
        
        //populate product itemization map 
        Set<Id> productIdSet = new Set<Id>();
        for(fsCore__Lending_Application__c app : mApplicationMap.values()){
            productIdSet.add(app.fsCore__Product_Name__c);
        }
        
        mProductItemizationMap = fsCore.ProductUtil.getProductItemizations(productIdSet);
        
        mOppDraftFeeList = [Select Id,Program_Id__c from Opportunity_Draft_Fee__c where Lending_Application_Number__c IN :applicationIdSet];
        
    }
    
    public void process(){
        System.debug(loggingLevel.ERROR, '-- RefreshTradelinesAction.process(+)');
        System.debug(loggingLevel.ERROR, 'Called From UI ?'+mIsCalledFromUI);
        List<String> nuDebtOppIdList = new List<String>();
        for (fsCore__Lending_Application__c app : mApplicationMap.values()){
            if (String.IsNotBlank(app.Opp_Import_Id__c)){
                nuDebtOppIdList.add(app.Opp_Import_Id__c);
            }
        }
        //CODE TO REFRESH DRAFT FEE
        Set<Id> ProgramIds = new Set<Id>();
        for(Opportunity_Draft_Fee__c df : mOppDraftFeeList){    
            if(df.Program_ID__c != null){
                ProgramIds.add(df.Program_ID__c);
            }
        }
        
        
        //get recent tradelines information from NuDebt
        WS_RefreshTradelines refreshTradelinesAPI = new WS_RefreshTradelines();
        refreshTradelinesAPI.setRequest(nuDebtOppIdList);
        refreshTradelinesAPI.invoke();
        OpportunityJSONClass nuDebtResponse = refreshTradelinesAPI.getResponse();
        
        if (nuDebtResponse == null){ 
            throw new RefreshTradelinesException('No response received from NuDebt Org.');
        }
        
        //PDI-646 REFRESHING DRAFT FEE
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(ProgramIds);
        
        RefreshDraftFeesAction refreshDraftFee = new RefreshDraftFeesAction();
        refreshDraftFee.setInput(acInput);
        refreshDraftFee.process();
        refreshDraftFee.saveErrors();   
        //PDI-646 REFRESHING DRAFT FEE  
        
        
        //prepare NuDebt opportunity Id to API response map 
        Map<String, OpportunityJSONClass.cls_Opportunity> oppIdToNuDebtResponseMap = new Map<String, OpportunityJSONClass.cls_Opportunity>();
        for (OpportunityJSONClass.cls_Opportunity nuDebtOpp : nuDebtResponse.Opportunity){
            oppIdToNuDebtResponseMap.put(nuDebtOpp.Id, nuDebtOpp);
        }
        System.debug(loggingLevel.ERROR, '-- Response returned for ' + oppIdToNuDebtResponseMap.size() + ' opportunities.');
        
        String dnlFundsToCreditorItmzCode = SFS_System_Settings__c.getInstance().DNL_Funds_To_Creditor_Itm__c;
        Id settlementPaymentRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        Id draftPaymentRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id LoanPaymentRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        Id RefundLoanPaymentRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Refund loan').getRecordTypeId();

        
        List<fsCore__Lending_Application_Itemization__c> itemizationUpdateList = new List<fsCore__Lending_Application_Itemization__c>();
        List<fsCore__Lending_Application_Itemization__c> itemizationInsertList = new List<fsCore__Lending_Application_Itemization__c>();
        List<Opportunity_Tradelines_Offer__c> tradelinesOfferList = new List<Opportunity_Tradelines_Offer__c>();
        List<Opportunity_Payment__c> oppPaymentList = new List<Opportunity_Payment__c>();
        List<fsCore__Lending_Application__c> applicationUpdateList = new List<fsCore__Lending_Application__c>();
        
        Map<String,String> paymentTradelineMap = new Map<String,String>();
        
        try{
            for (fsCore__Lending_Application__c app : mApplicationMap.values()){
                System.debug(loggingLevel.ERROR, '-- processing response for application ' + app.Name + ' :: NuDebt Opportunity ' + app.Opp_Import_Id__c);
                
                //check the NuDebt Opportunity ID on application
                if (String.IsBlank(app.Opp_Import_Id__c)){
                    mActionOutput.addError('Source Opportunity ID is not populated on the application. Please contact your administrator.');
                    continue;
                }
                
                System.debug(loggingLevel.ERROR, 'oppIdToNuDebtResponseMap :'+oppIdToNuDebtResponseMap.keySet());
                
                //Check if NuDebt Response exists for the Opp Import Id
                if (!oppIdToNuDebtResponseMap.containsKey(app.Opp_Import_Id__c)){
                    System.debug(loggingLevel.ERROR, 'No response received from NuDebt Org for Opportunity Id ' + app.Opp_Import_Id__c + '.');
                    mActionOutput.addError('No response received from NuDebt Org for Opportunity Id ' + app.Opp_Import_Id__c + '.');
                    continue;
                }
                
                OpportunityJSONClass.cls_Opportunity nuDebtOpp = oppIdToNuDebtResponseMap.get(app.Opp_Import_Id__c);
                
                //populating tradeline import Id to itemization map so that I can determine what to insert and what to update
                Map<String, fsCore__Lending_Application_Itemization__c> tradelineToItemizationMap = new Map<String, fsCore__Lending_Application_Itemization__c>();
                if (mApplicationItemizationMap.containsKey(app.Id)){
                    for(fsCore__Lending_Application_Itemization__c itmz : mApplicationItemizationMap.get(app.Id)){
                        if (itmz.Tradeline_Import_Id__c != null){
                            tradelineToItemizationMap.put(itmz.Tradeline_Import_Id__c, itmz);
                        }
                        
                    }
                }
                System.debug(loggingLevel.ERROR, 'mAppToCashInDedicatedItmMap Size '+mAppToCashInDedicatedItmMap.size());
                
                //set product itemization
                fsCore__Product_Itemization_Setup__c prodItmzFundToCreditor;
                if (String.IsNotBlank(dnlFundsToCreditorItmzCode) && mProductItemizationMap.containsKey(app.fsCore__Product_Name__c)){
                    for(fsCore__Product_Itemization_Setup__c pItmz : mProductItemizationMap.get(app.fsCore__Product_Name__c)){
                        if (pItmz.Itemization_Code_Formula__c.equalsIgnoreCase(dnlFundsToCreditorItmzCode)){
                            prodItmzFundToCreditor = pItmz;
                            break;
                        }
                    }
                }
                
                if(nuDebtOpp.MonthlyLegalFee != null && nuDebtOpp.MonthlyLegalFee != null){
                    app.Monthly_Legal_Fee__c = Decimal.valueOf(nuDebtOpp.MonthlyLegalFee);
                }
                if(nuDebtOpp.MonthlyProcessorFee != null && nuDebtOpp.MonthlyProcessorFee != null){
                    app.Monthly_Processor_Fee__c = Decimal.valueOf(nuDebtOpp.MonthlyProcessorFee);
                }
                if(nuDebtOpp.MonthlyThirdPartyFees != null && nuDebtOpp.MonthlyThirdPartyFees != null){
                    app.Monthly_Third_Party_Fees__c = Decimal.valueOf(nuDebtOpp.MonthlyThirdPartyFees);
                }
             
                if(nuDebtOpp.TotalFee != null && nuDebtOpp.TotalFee != null){
                    app.NuDebt_Total_Actual_Fee__c = Decimal.valueOf(nuDebtOpp.TotalFee);  
                }
                System.debug(Logginglevel.error,'###@ app.NuDebt_Total_Actual_Fee__c :: ' + app.NuDebt_Total_Actual_Fee__c);
                //PDI-1044
                if(nuDebtOpp.BegDaBalance != null && nuDebtOpp.BegDaBalance != null){
                    app.Beginning_DA_Balance__c = Decimal.valueOf(nuDebtOpp.BegDaBalance);  
                } 
                if(nuDebtOpp.AddnlDraftFundng != null && nuDebtOpp.AddnlDraftFundng != null){
                    app.Addn_l_Drafts_During_Funding__c = Decimal.valueOf(nuDebtOpp.AddnlDraftFundng);  
                } 
                if(nuDebtOpp.VersaraFundDate != null && nuDebtOpp.VersaraFundDate != null){
                    app.Versara_First_Funding_Date__c = Date.valueOf(nuDebtOpp.VersaraFundDate);  
                } 
                //PDI-626
                if(nuDebtOpp.CashInDedicatedAccount != null && nuDebtOpp.CashInDedicatedAccount != ''){
                    app.Cash_in_Dedicated_Account__c= Decimal.valueOf(nuDebtOpp.CashInDedicatedAccount );
                }
                
                app.NuDebt_Program_Status__c = nuDebtOpp.ProgramStatus;
                //PDI-1019
                if (nuDebtOpp.TradeLines != null){
                    //app.IsTradelineWhileRefresh__c=true;  //DV-60  After make this field true,  "Create Task After New Tradeline Refresh" will execute for create task.
                    for(OpportunityJSONClass.cls_TradeLines tradeline : nuDebtOpp.TradeLines){
                        if(tradeline.isLastDebt != null && tradeline.isLastDebt =='true' && app.fsCore__Current_Stage_Name_Formula__c=='Funding'){ 
                              app.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
                         }
                    //DV-60
                    System.debug(Logginglevel.error,'###@@ tradeline.isNewTrade: '+tradeline.isNewTrade);
                        if(tradeline.isNewTrade=='true'){
                            app.IsTradelineWhileRefresh__c=true;
                        }
                        System.debug(Logginglevel.error,'###@@app.IsTradelineWhileRefresh__c:'+app.IsTradelineWhileRefresh__c);
                    }
                    
                }
                                
                /*if(nuDebtOpp.CurrentBalance != null && nuDebtOpp.CurrentBalance != ''){
app.Current_Balance__c = Decimal.valueOf(nuDebtOpp.CurrentBalance);
applicationUpdateList.add(app);
}*/
                //AD ALWAYS REFRESH
                applicationUpdateList.add(app);
                
                //PDI-626
                //UPDATE CASH IN DEDICATED AMOUNT ITEMIZATIONS
                System.debug(Logginglevel.error,'### Adding mAppToCashInDedicatedItmMap ');
                if (mAppToCashInDedicatedItmMap.get(app.Id) != null){
                    fsCore__Lending_Application_Itemization__c dedicatedAmountCash =  mAppToCashInDedicatedItmMap.get(app.Id);
                    dedicatedAmountCash.fsCore__Requested_Amount_Unsigned__c = app.Cash_in_Dedicated_Account__c;
                    //dedicatedAmountCash.fsCore__Approved_Amount_Unsigned__c  = app.Cash_in_Dedicated_Account__c; //Commented due to DV-129
                    dedicatedAmountCash.fsCore__Approved_Amount_Signed__c  = app.Cash_in_Dedicated_Account__c;
                    //PDI-785 :Line 224 to 226 [commented for @602]
                    /*if(nudebtOpp.DACashforDNLPostTILA!=null)  //dedicatedAmountCash.Itemization_Code_Formula__c=='DEDICATED_AMOUNT_CASH' && 
                        dedicatedAmountCash.fsCore__Actual_Amount_Unsigned__c=decimal.valueOf(nudebtOpp.DACashforDNLPostTILA);
                    else   */
                    
                    dedicatedAmountCash.fsCore__Actual_Amount_Unsigned__c = app.Cash_in_Dedicated_Account__c;
                  
                    dedicatedAmountCash.fsCore__Actual_Amount_Signed__c = app.Cash_in_Dedicated_Account__c;
                    //Cash in dedicated account should always be negative
                    //PDI-906
                    if (dedicatedAmountCash.fsCore__Requested_Amount_signed__c > 0){
                        dedicatedAmountCash.fsCore__Requested_Amount_signed__c = (-1) * (dedicatedAmountCash.fsCore__Requested_Amount_signed__c);
                    }
                    if (dedicatedAmountCash.fsCore__Approved_Amount_Signed__c > 0){
                        dedicatedAmountCash.fsCore__Approved_Amount_Signed__c = (-1) * (dedicatedAmountCash.fsCore__Approved_Amount_Signed__c);
                    }
                    if (dedicatedAmountCash.fsCore__Actual_Amount_Signed__c > 0){
                        dedicatedAmountCash.fsCore__Actual_Amount_Signed__c = (-1) * (dedicatedAmountCash.fsCore__Actual_Amount_Signed__c);
                    }

                    //We need to make sure unsigned must be without the sign
                    if (dedicatedAmountCash.fsCore__Requested_Amount_Unsigned__c < 0){
                        dedicatedAmountCash.fsCore__Requested_Amount_Unsigned__c = (-1) * (dedicatedAmountCash.fsCore__Requested_Amount_Unsigned__c);
                    }
                    //We need to make sure unsigned must be without the sign
                    /*if (dedicatedAmountCash.fsCore__Approved_Amount_Unsigned__c < 0){   //Commented due to DV-129
                        dedicatedAmountCash.fsCore__Approved_Amount_Unsigned__c = (-1) * (dedicatedAmountCash.fsCore__Approved_Amount_Unsigned__c);
                    }*/
                    //We need to make sure unsigned must be without the sign
                    if (dedicatedAmountCash.fsCore__Actual_Amount_Unsigned__c < 0){
                        dedicatedAmountCash.fsCore__Actual_Amount_Unsigned__c = (-1) * (dedicatedAmountCash.fsCore__Actual_Amount_Unsigned__c);
                    }  
                    system.debug('@@dedicatedAmountCash.fsCore__Actual_Amount_Unsigned__c'+dedicatedAmountCash.fsCore__Actual_Amount_Unsigned__c); //@
                    
                    itemizationUpdateList.add(dedicatedAmountCash);
                }    
                //DV-348
                //UPDATE AMT IN REMAINING FEES DUE TO DRP
                if (mAppToremainingFeeDueDrpMap.get(app.Id) != null){
                    fsCore__Lending_Application_Itemization__c remainingFeesDueDrpAmount =  mAppToremainingFeeDueDrpMap.get(app.Id);
                    remainingFeesDueDrpAmount.fsCore__Actual_Amount_Unsigned__c = app.NuDebt_Total_Actual_Fee__c;
                    remainingFeesDueDrpAmount.fsCore__Actual_Amount_Signed__c = app.NuDebt_Total_Actual_Fee__c;
                                     
                   /* if (remainingFeesDueDrpAmount.fsCore__Actual_Amount_Signed__c > 0){
                        remainingFeesDueDrpAmount.fsCore__Actual_Amount_Signed__c = (-1) * (remainingFeesDueDrpAmount.fsCore__Actual_Amount_Signed__c);
                    }
                      //We need to make sure unsigned must be without the sign
                    if (remainingFeesDueDrpAmount.fsCore__Actual_Amount_Unsigned__c < 0){
                        remainingFeesDueDrpAmount.fsCore__Actual_Amount_Unsigned__c = (-1) * (remainingFeesDueDrpAmount.fsCore__Actual_Amount_Unsigned__c);
                    }  */
                    itemizationUpdateList.add(remainingFeesDueDrpAmount);
                }    
                // 
                //refreshing tradelines
                if (nuDebtOpp.TradeLines != null){
                    for(OpportunityJSONClass.cls_TradeLines tradeline : nuDebtOpp.TradeLines){
                        Opportunity_Tradelines_Offer__c newTrade = new Opportunity_Tradelines_Offer__c();
                        newTrade.FileNumber__c = tradeline.FileNumber;
                        newTrade.Import_Id__c = tradeline.Id;
                        
                        System.debug(Logginglevel.error,'### Existing tradeline :: ' + tradeline);
                        //DV-129
                        /*if(String.isNotBlank(tradeline.OfferAmount)){
                            newTrade.Offer_Amount__c = Decimal.ValueOf(tradeline.OfferAmount);
                        } 
                        if(String.isNotBlank(tradeline.OfferProgramFee)){
                            newTrade.Offer_Program_Fee__c = Decimal.valueOf(tradeline.OfferProgramFee);
                        }  */
                       
                        if(tradeline.SFSCurrentBalance != null && tradeline.SFSCurrentBalance != ''){
                            newTrade.SFS_Current_Balance__c = Decimal.valueof(tradeline.SFSCurrentBalance); 
                        }   //@PDI-737  : PDI-948 
                        if(String.isNotBlank(tradeline.SettlementAmountPaid)){
                            newTrade.Settlement_Amount_Paid__c = Decimal.valueOf(tradeline.SettlementAmountPaid);
                        }
                        if(String.isNotBlank(tradeline.DNLEstimatedSettlement)){
                            newTrade.Estimated_Settlement__c = Decimal.valueOf(tradeline.DNLEstimatedSettlement);
                        }
                        System.debug(Logginglevel.error,'### Existing DNLFundstoClient :: ' + tradeline.DNLFundstoClient);
                        if(String.isNotBlank(tradeline.DNLFundstoClient)){    
                            newTrade.DNL_Funds_to_Client__c = Decimal.valueOf(tradeline.DNLFundstoClient);
                        }
                        System.debug(Logginglevel.error,'### Existing DNLFundsforFees :: ' + tradeline.DNLFundsforFees);
                        if(String.isNotBlank(tradeline.DNLFundsforFees)){        
                            newTrade.DNL_Funds_for_Fees__c = Decimal.valueOf(tradeline.DNLFundsforFees);
                        }
                        System.debug(Logginglevel.error,'### tradeline.DNLDisbursementAmount :: ' + tradeline.DNLDisbursementAmount);
                        if(String.isNotBlank(tradeline.DNLDisbursementAmount)){    
                            newTrade.Actual_Settlement_Amount__c = Decimal.valueOf(tradeline.DNLDisbursementAmount);
                        }
                        System.debug(Logginglevel.error,'### newTrade.Actual_Settlement_Amount__c :: ' + newTrade.Actual_Settlement_Amount__c);
                        if(String.isNotBlank(tradeline.DNLSettlementFees)){    
                            newTrade.DNL_Settlement_Fees__c = Decimal.valueOf(tradeline.DNLSettlementFees);
                        }
                        if(tradeline.DNLDisbursementDate != null && tradeline.DNLDisbursementDate !=''){
                            newTrade.Settlement_Date__c = Date.valueOf(tradeline.DNLDisbursementDate);
                        }
                        if(tradeline.DNLDisbursementAmount != null && tradeline.DNLDisbursementAmount !=''){
                            newTrade.DNL_Disbursement_Amount__c = Decimal.valueOf(tradeline.DNLDisbursementAmount);
                        }
                        if(tradeline.DNLDisbursementDate != null && tradeline.DNLDisbursementDate !=''){
                            newTrade.DNL_Disbursement_Date__c = Date.valueOf(tradeline.DNLDisbursementDate);
                        }
                        newTrade.Offer_Status__c = tradeline.OfferStatus;
                        newTrade.Current_Stage__c = tradeline.CurrentStage;  
                        newTrade.Litigation_Stage__c = tradeline.LitigationStage;  
                        //newTrade.New_Account_Number__c = tradeline.NewAccountNumber;   //DV-129
                        //newTrade.New_Creditor__c = tradeline.NewCreditor;   //DV-129
                        newTrade.Original_Account_Number__c  = tradeline.OriginalAccountNumber;
                        newTrade.Original_Creditor__c = tradeline.OriginalCreditorName; 
                        newTrade.Original_Debt__c = Decimal.valueOf(tradeline.OriginalDebt);  
                        newTrade.Opportunity_Name__c = app.Opportunity_Name__c;
                        newTrade.Lending_Application_Number__c = app.Id;
                        
                        tradelinesOfferList.add(newTrade);
                        
                        if(tradeline.SettelmentPayments != NULL){
                            System.debug(Logginglevel.error,'### Settelment Payments :: ' + tradeline.SettelmentPayments);
                            
                            for(opportunityJsonClass.cls_SettelmentPayments settlementPmt : tradeline.SettelmentPayments){
                                Opportunity_Payment__c newPay = new Opportunity_Payment__c();
                                newPay.Import_Id__c = settlementPmt.Id;
                                newPay.RecordTypeId = settlementPaymentRecTypeId; 
                                newPay.FileNumber__c = settlementPmt.FileNumber;
                                newPay.Opportunity_Name__c = app.Opportunity_Name__c;
                                newPay.Lending_Application_Number__c = app.Id;
                               // newPay.Payment_Status__c = payment.TransactionStatus;  //DV-420
                               // newPay.Transaction_Status__c = payment.TransactionStatus;   //DV-420
                                oppPaymentList.add(newPay);
                                paymentTradelineMap.put(newPay.Import_Id__c, newTrade.Import_Id__c);
                            }   
                        }                         
                        
                        //refreshing itemizations
                        if (tradelineToItemizationMap.containsKey(tradeline.Id)){
                            fsCore__Lending_Application_Itemization__c appUpdItmz = tradelineToItemizationMap.get(tradeline.Id);
                            System.debug(Logginglevel.error,'### tradeline.SFSCurrentBalance-I :: ' + tradeline.SFSCurrentBalance);
                            if(tradeline.SFSCurrentBalance != null && tradeline.SFSCurrentBalance != ''){
                                System.debug(Logginglevel.error,'### tradeline.SFSCurrentBalance-II :: ' + tradeline.SFSCurrentBalance);
                                appUpdItmz.fsCore__Requested_Amount_Unsigned__c = Decimal.valueof(tradeline.SFSCurrentBalance); //DV-129
                                appUpdItmz.fsCore__Requested_Amount_signed__c = Decimal.valueof(tradeline.SFSCurrentBalance); 
                                System.debug(Logginglevel.error,'### appUpdItmz.fsCore__Requested_Amount_Unsigned__c :: ' + appUpdItmz.fsCore__Requested_Amount_Unsigned__c);
                                
                                //We need to make sure unsigned must be without the sign
                                if (appUpdItmz.fsCore__Requested_Amount_Unsigned__c < 0){
                                    appUpdItmz.fsCore__Requested_Amount_Unsigned__c = (-1) * (appUpdItmz.fsCore__Requested_Amount_Unsigned__c);
                                }                                
                            }    
                            //appUpdItmz.DNL_Original_Enrolled_Balance__c = Decimal.valueOf(tradeline.OriginalDebt)*1.15;   //@ PDI-602
                            appUpdItmz.DNL_Original_Enrolled_Balance__c = Decimal.valueOf(tradeline.OriginalDebt); 
                            appUpdItmz.Original_Creditor__c = tradeline.OriginalCreditorName;
                            system.debug('---------'+tradeline);
                            system.debug('---------'+tradeline.NewCreditor);
                            if(tradeline.NewCreditor != null 
                                	&& String.isNotBlank(tradeline.NewCreditor)
                                	&& app.fsCore__Current_Stage_Name_Formula__c == 'Funding'
                                	&& (app.fsCore__Application_Status__c == 'Final Settlement Reached' || app.fsCore__Application_Status__c == 'DRP Graduated')){
                                    	appUpdItmz.Current_Creditor__c = tradeline.NewCreditor;
                                	} // DV-530
                                
                            
                            //PDI-653
                            System.debug(Logginglevel.error,'### Existing DNLDisbursementDate :: ' + tradeline.DNLDisbursementDate);
                            if(tradeline.DNLDisbursementDate != null && tradeline.DNLDisbursementDate !=''){
                                appUpdItmz.Disbursement_Date__c = Date.valueOf(tradeline.DNLDisbursementDate);
                            } 
                               
                            if (mIsCalledFromUI){//DV-161 Only needs to update when called from UI.
                                //PDI-653  
                                if((String.isNotBlank(tradeline.DNLDisbursementAmount)) ||(String.isNotBlank(tradeline.DNLSettlementFees))){ 
                                    Decimal disbursementAmount = 0.00;
                                    Decimal settlementFee = 0.00;
                                    if ((String.isNotBlank(tradeline.DNLDisbursementAmount))){
                                        disbursementAmount = Decimal.valueOf(tradeline.DNLDisbursementAmount);
                                    }
                                    if ((String.isNotBlank(tradeline.DNLSettlementFees))){
                                        settlementFee = Decimal.valueOf(tradeline.DNLSettlementFees);
                                    }                                
                                    
                                    appUpdItmz.fsCore__Actual_Amount_Unsigned__c = disbursementAmount + settlementFee;
                                   
                                    appUpdItmz.fsCore__Actual_Amount_Signed__c = disbursementAmount + settlementFee;
                                    //We need to make sure unsigned must be without the sign
                                    if (appUpdItmz.fsCore__Actual_Amount_Unsigned__c < 0){
                                        appUpdItmz.fsCore__Actual_Amount_Unsigned__c = (-1) * (appUpdItmz.fsCore__Actual_Amount_Unsigned__c);
                                    }   
                                } 
                            }
                            //PDI-655
                            System.debug(Logginglevel.error,'### Existing DNLFundsforFees :: ' + tradeline.DNLFundsforFees);
                            if(String.isNotBlank(tradeline.DNLFundsforFees)){
                                appUpdItmz.DNL_Settlement_Fees__c = Decimal.valueOf(tradeline.DNLFundsforFees);
                            }
                            //PDI-655
                            System.debug(Logginglevel.error,'### Existing DNLFundstoClient :: ' + tradeline.DNLFundstoClient);
                            if(String.isNotBlank(tradeline.DNLFundstoClient)){
                                appUpdItmz.DNL_Funds_to_Client__c = Decimal.valueOf(tradeline.DNLFundstoClient);
                            }                                        
                            
                            //PDI-484
                            if(String.isNotBlank(tradeline.OfferAmount)){
                                appUpdItmz.Actual_Settlement_Percentage__c = (Decimal.valueOf(tradeline.OfferAmount) /Decimal.valueOf(tradeline.OriginalDebt)) * 100;
                            }
                            
                            itemizationUpdateList.add(appUpdItmz);
                            system.debug('@@itemizationUpdateList'+itemizationUpdateList); //@
                        }
                        else{
                            if (prodItmzFundToCreditor != null){
                                fsCore__Lending_Application_Itemization__c appInsItmz = new fsCore__Lending_Application_Itemization__c();
                                
                                appInsItmz.fsCore__Lending_Application_Number__c = app.Id;
                                appInsItmz.Tradeline_Import_Id__c = tradeline.Id;
                                appInsItmz.fsCore__Itemization_Name__c = prodItmzFundToCreditor.fsCore__Itemization_Name__c;
                                appInsItmz.fsCore__Itemization_Family__c = prodItmzFundToCreditor.fsCore__Itemization_Family__c;
                                appInsItmz.fsCore__Plus_Or_Minus__c = prodItmzFundToCreditor.fsCore__Plus_Or_Minus__c;
                                appInsItmz.fsCore__Disbursement_Allowed__c = prodItmzFundToCreditor.fsCore__Disbursement_Allowed__c;
                                appInsItmz.fsCore__Fee_Category__c = prodItmzFundToCreditor.fsCore__Fee_Category__c;
                                appInsItmz.fsCore__Is_Override_Allowed__c = prodItmzFundToCreditor.fsCore__Is_Override_Allowed__c;
                                appInsItmz.fsCore__Source__c = fsCore.Constants.ITMZ_SOURCE_PRODUCT;
                                System.debug(Logginglevel.error,'### tradeline.SFSCurrentBalance-I :: ' + tradeline.SFSCurrentBalance);
                                if(tradeline.SFSCurrentBalance != null && tradeline.SFSCurrentBalance != ''){
                                    System.debug(Logginglevel.error,'### tradeline.SFSCurrentBalance-II :: ' + tradeline.SFSCurrentBalance);
                                    appInsItmz.fsCore__Requested_Amount_Unsigned__c = Decimal.valueof(tradeline.SFSCurrentBalance); 
                                    appInsItmz.fsCore__Requested_Amount_Signed__c = Decimal.valueof(tradeline.SFSCurrentBalance); 
                                    System.debug(Logginglevel.error,'### appInsItmz.fsCore__Requested_Amount_Unsigned__c :: ' + appInsItmz.fsCore__Requested_Amount_Unsigned__c);
                                    //We need to make sure unsigned must be without the sign
                                    if (appInsItmz.fsCore__Requested_Amount_Unsigned__c < 0){
                                        appInsItmz.fsCore__Requested_Amount_Unsigned__c = (-1) * (appInsItmz.fsCore__Requested_Amount_Unsigned__c);
                                    }                                     
                                }                    
                                //appInsItmz.DNL_Original_Enrolled_Balance__c = Decimal.valueOf(tradeline.OriginalDebt)*1.15;  //@ PDI-602
                                appInsItmz.DNL_Original_Enrolled_Balance__c = Decimal.valueOf(tradeline.OriginalDebt);
                                appInsItmz.Original_Creditor__c = tradeline.OriginalCreditorName;
                                system.debug('---------'+tradeline.NewCreditor);
                                if(tradeline.NewCreditor != null 
                                	&& String.isNotBlank(tradeline.NewCreditor)
                                	&& app.fsCore__Current_Stage_Name_Formula__c == 'Funding'
                                	&& (app.fsCore__Application_Status__c == 'Final Settlement Reached' || app.fsCore__Application_Status__c == 'DRP Graduated')){
                                    	appInsItmz.Current_Creditor__c = tradeline.NewCreditor;
                                	} // DV-530
                                
                                //PDI-484
                                if(String.isNotBlank(tradeline.OfferAmount)){
                                    appInsItmz.Actual_Settlement_Percentage__c = (Decimal.valueOf(tradeline.OfferAmount) /Decimal.valueOf(tradeline.OriginalDebt)) * 100;
                                } 
                                //PDI-653
                                System.debug(Logginglevel.error,'### New DNLDisbursementDate :: ' + tradeline.DNLDisbursementDate);
                                if(tradeline.DNLDisbursementDate != null && tradeline.DNLDisbursementDate !=''){
                                    appInsItmz.Disbursement_Date__c = Date.valueOf(tradeline.DNLDisbursementDate);
                                } 
                                
                                //PDI-653                           
                                if(String.isNotBlank(tradeline.DNLDisbursementAmount)){    
                                    Decimal disbursementAmount = 0.00;
                                    Decimal settlementFee = 0.00;
                                    if ((String.isNotBlank(tradeline.DNLDisbursementAmount))){
                                        disbursementAmount = Decimal.valueOf(tradeline.DNLDisbursementAmount);
                                    }
                                    if ((String.isNotBlank(tradeline.DNLSettlementFees))){
                                        settlementFee = Decimal.valueOf(tradeline.DNLSettlementFees);
                                    }                                
                                    appInsItmz.fsCore__Actual_Amount_Unsigned__c = disbursementAmount + settlementFee;
                                    appInsItmz.fsCore__Actual_Amount_Signed__c = disbursementAmount + settlementFee;
                                    //We need to make sure unsigned must be without the sign
                                    if (appInsItmz.fsCore__Actual_Amount_Unsigned__c < 0){
                                        appInsItmz.fsCore__Actual_Amount_Unsigned__c = (-1) * (appInsItmz.fsCore__Actual_Amount_Unsigned__c);
                                    }                                 
                                }       
                                //PDI-655
                                System.debug(Logginglevel.error,'### New DNLFundsforFees :: ' + tradeline.DNLFundsforFees);
                                if(String.isNotBlank(tradeline.DNLFundsforFees)){
                                    appInsItmz.DNL_Settlement_Fees__c = Decimal.valueOf(tradeline.DNLFundsforFees);
                                }        
                                //PDI-655
                                System.debug(Logginglevel.error,'### New DNLFundstoClient :: ' + tradeline.DNLFundstoClient);
                                if(String.isNotBlank(tradeline.DNLFundstoClient)){
                                    appInsItmz.DNL_Funds_to_Client__c = Decimal.valueOf(tradeline.DNLFundstoClient);
                                }                                        
                                itemizationInsertList.add(appInsItmz);
                                system.debug('@@itemizationInsertList'+itemizationInsertList);
                            }
                        }
                    }
                }
                
                if (nuDebtOpp.Payments != null){
                    for(OpportunityJSONClass.cls_Payments payment : nuDebtOpp.Payments){
                        //System.debug(Logginglevel.error,'### Non Settelment Payments :: ' + payment);
                        
                        Opportunity_Payment__c newPay = new Opportunity_Payment__c();
                        
                        newPay.FileNumber__c = payment.FileNumber;
                        newPay.Import_Id__c = payment.Id;
                        newPay.RecordTypeId = draftPaymentRecTypeId;
                        if(String.IsNotBlank(payment.NFSDate)) newPay.NSF_Date__c = Date.ValueOf(payment.NFSDate);
                        //newPay.Payment_Status__c = payment.PaymentStatus;  
                        newPay.Payment_Status__c = payment.TransactionStatus;  //DV-420
                        newPay.Payment_Type__c = payment.PaymentType;
                        if(String.IsNotBlank(payment.ScheduleDate)) newPay.Schedule_Date__c = Date.ValueOf(payment.ScheduleDate);
                        if(String.IsNotBlank(payment.TotalAmount)) newPay.Total_Amount__c = Decimal.valueof(payment.TotalAmount);
                        newPay.Transaction_Method__c = payment.TansMethod;
                        newPay.Transaction_Status__c = payment.TransactionStatus;
                        newPay.Opportunity_Name__c = app.Opportunity_Name__c;
                        newPay.Lending_Application_Number__c = app.Id;
                        //PDI-743
                        if(payment.PayRecType=='Settlement'){
                            newPay.RecordTypeId = settlementPaymentRecTypeId;  
                        }else if(payment.PayRecType=='Draft'){
                            newPay.RecordTypeId = draftPaymentRecTypeId;
                        }else if(payment.PayRecType=='Loan'){
                            newPay.RecordTypeId = LoanPaymentRecTypeId;
                        }else if(payment.PayRecType=='Refund loan'){
                            newPay.RecordTypeId = RefundloanPaymentRecTypeId;
                        }
                        oppPaymentList.add(newPay);
                        
                    }                       
                }
            }
        }
        catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            mActionOutput.addError(e);
        }
           
        //perform DMLs
        Savepoint sp = Database.setSavepoint();
        if (applicationUpdateList.size() > 0){
            System.debug(loggingLevel.ERROR, '-- savings changes ... ');
            try{
                
                Map<String, Opportunity_Tradelines_Offer__c> oppTradelineImportIdMap = new Map<String, Opportunity_Tradelines_Offer__c>();
                
                if (tradelinesOfferList.size() > 0){
                    Database.UpsertResult[] insTradeResults = Database.upsert(tradelinesOfferList, Opportunity_Tradelines_Offer__c.Import_Id__c, true);
                    
                    for(Opportunity_Tradelines_Offer__c tradeline : tradelinesOfferList){
                        if (tradeline.Id != null){
                            oppTradelineImportIdMap.put(tradeline.Import_Id__c, tradeline);    
                        }
                    }
                }
                
                System.debug(loggingLevel.ERROR, '-- oppPaymentList Size ... '+oppPaymentList.size());
                if (oppPaymentList.size() > 0){
                    for(Opportunity_Payment__c oppPayment : oppPaymentList){
                        System.debug(loggingLevel.ERROR, '-- Final oppPayment ... '+oppPayment);
                        if(paymentTradelineMap.containsKey(oppPayment.Import_Id__c)){
                            String tradelineImportId = paymentTradelineMap.get(oppPayment.Import_Id__c);
                            if(oppTradelineImportIdMap.containskey(tradelineImportId)){
                                oppPayment.Tradelines_Name__c = oppTradelineImportIdMap.get(tradelineImportId).Id;
                            }
                        }
                    }
                    
                    //on 07/17/2019 changed the AllorNone parameter to false, to keep it in sync with CreateOrUpdateRecordService
                    Database.UpsertResult[] insPayResults = Database.upsert(oppPaymentList, Opportunity_Payment__c.Import_Id__c, false);
                }
                
                fsCore.LendingApplicationTriggerWrapper.getInstance().reset();         
                
                Database.SaveResult[] applicationSR = Database.update(applicationUpdateList, true);
                if (itemizationUpdateList.size() > 0){ Database.SaveResult[] itemizationUpdResults = Database.update(itemizationUpdateList, true); }
                if (itemizationInsertList.size() > 0){ Database.SaveResult[] itemizationInsResults = Database.insert(itemizationInsertList, true); }
                
            }
            catch (Exception e){
                System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
                Database.rollback(sp);
                mActionOutput.addError(e);
            }
        }
        System.debug(loggingLevel.ERROR, '-- RefreshTradelinesAction.process(-)');
    }
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('RefreshTradelinesAction', 'process', mActionOutput.getErrors());
        }
    }
    
}