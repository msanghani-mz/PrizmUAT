/**
* About: Webservice to pull Lead and related data from NuDebt and update in Prizm
*
* Author: Kimi Shrivastava
*
**/

global class PrizmLeadPullService {
    
        
    private static Id settelmentPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Settlement').getRecordTypeId();
    private static final String NUDEBT_PULL_DATA_SERVICE_URI = '/apexrest/pullDataForPrizmLead';
    public static NuDebtProgramWrapper pullLeadAccountDetailsFromNuDebt(List<String> listOfFileIds){
        
        String accessToken;
        String instanceURL; 
        NuDebtProgramWrapper nuDebtProgramWrapper;
        System.debug('listOfFileIds = ' + listOfFileIds);
        if(listOfFileIds == null || listOfFileIds.size() == 0){
            System.debug('listOfFileIds null = ' + listOfFileIds);
            return null;
        }
           
        
        /*if(!test.isRunningTest()){
            Map<String, Object> resultMap = getConnectionResponse();
            accessToken = (String)resultMap.get('access_token');
            instanceURL = (String)resultMap.get('instance_url'); 
        }else
            accessToken = 'Test';
        */
        
         System.debug('accessToken = ' + accessToken);
        //if(accessToken !=null){

            String endPoint = 'callOut:' + WS_Constants.NUDEBT_ORG_NAMED_CRED;
            endPoint += NUDEBT_PULL_DATA_SERVICE_URI;
            
            URL endPointURL = new URL(endPoint);

            //String endPoint=instanceURL +'/services/apexrest/pullDataForPrizmLead';
            System.debug('endPoint = ' + endPoint);
            JSONGenerator gen = JSON.createGenerator(true); 
            gen.writeObject(listOfFileIds);
            String jsonS = gen.getAsString();
            System.debug(loggingLevel.ERROR, 'jsonS = ' + jsonS);
            Http h2= new Http();

            HttpRequest httpReq= new HttpRequest();
            httpReq.setTimeout(60000);
            httpReq.setEndpoint(endPointURL.toExternalForm());
            httpReq.setMethod(WS_Constants.POST);
            httpReq.setheader('accept','application/json');
            httpReq.setBody(jsonS);
            httpReq.setHeader('Content-Type','application/json');

            //HttpRequest req2= new HttpRequest();
            //req2.setHeader('Authorization','Bearer ' + accessToken);
            //req2.setHeader('Content-Type','application/json');
            //req2.setMethod(WS_Constants.POST);
            //req2.setEndpoint(endPointURL.toExternalForm());//(endPoint);
            //req2.setTimeout(60000);
            //req2.setBody(jsonS);
            //HttpResponse res2=h2.send(req2);
            HttpResponse res2 = (new Http()).send(httpReq);  
            
            System.debug(loggingLevel.ERROR, res2+'###1203createresp');
            System.debug('###Body::'+res2.getBody());
 			String returnJSON = (String)JSON.deserializeUntyped(res2.getBody());          
            nuDebtProgramWrapper = (NuDebtProgramWrapper) JSON.deserialize(returnJSON, NuDebtProgramWrapper.class);
            System.debug(loggingLevel.ERROR , nuDebtProgramWrapper.programs);      
            System.debug(loggingLevel.ERROR , nuDebtProgramWrapper.tradelines);   
            System.debug(loggingLevel.ERROR , nuDebtProgramWrapper.payments);         

        //}
        return nuDebtProgramWrapper;
    }
    //--------------------------------------------------------------------
    // Function to send Program data corresponding to the new leads to NuDebt
    // --------------------------------------------------------------------
     public static NuDebtProgramWrapper sendProgramDataToNuDebt(NuDebtProgramWrapper nuDebtWrapper){
 		
         String accessToken;
         String instanceURL; 
         Map<String, Object> resultMap = getConnectionResponse();
         accessToken = (String)resultMap.get('access_token');
         instanceURL = (String)resultMap.get('instance_url'); 
		 NuDebtProgramWrapper nuDebtProgramWrapper;
        if(accessToken !=null){
            String endPoint=instanceURL +'/services/apexrest/pullDataForPrizmLead';
            System.debug('endPoint = ' + endPoint);
            JSONGenerator gen = JSON.createGenerator(true);    
            gen.writeObject(nuDebtWrapper);
            String jsonS = gen.getAsString();
            //System.debug(loggingLevel.ERROR, 'jsonS = ' + jsonS);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setMethod('PUT');
            req2.setEndpoint(endPoint);
            req2.setBody(jsonS);
            HttpResponse res2=h2.send(req2);
            
            System.debug(loggingLevel.ERROR, res2+'###1203createresp');
            System.debug(loggingLevel.ERROR, '###Body::'+res2.getBody());
 			String returnJSON = (String)JSON.deserializeUntyped(res2.getBody());          
            nuDebtProgramWrapper = (NuDebtProgramWrapper) JSON.deserialize(returnJSON, NuDebtProgramWrapper.class);
        }
        return nuDebtProgramWrapper;
    }
 
   /**
	* About: Update the related Payments detail for NuDebt Lead
	*
	* Author: Kimi Shrivastava
	*
	**/
    public static void updatePayments(List<NuDebtProgramWrapper.PaymentsWrapper> paymentsList, Map<Id, Lead> RelatedProgramIdLeads, List<Id> RelatedProgramIds,
                                      Map<String,Opportunity_Payment__c>  oppPaymentsMap){
        
        Opportunity_Payment__c oppPayment;        
        List<Opportunity_Payment__c> oppPaymentsList = new List<Opportunity_Payment__c>();
        Id draftPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Draft').getRecordTypeId();
        Id LoanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Loan').getRecordTypeId();
        Id RefundLoanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Refund Loan').getRecordTypeId();
        Id ApplicantRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Map<String, Opportunity_Payment__c> prizmPaymentsMapOnImportId = new Map<String, Opportunity_Payment__c>();
		List<String> importIds = new List<String>();                                          
        System.debug(loggingLevel.ERROR ,'updatePayments2323231231 ******= ' + paymentsList);
		if(paymentsList != null){
				for(NuDebtProgramWrapper.PaymentsWrapper pay: paymentsList)
					importIds.add(pay.paymentsId);
		}

		List<Opportunity_Payment__c> prizmPaymentsList = [Select Id, FileNumber__c, Import_Id__c, Lead__c, RecordTypeId, Payment_Type__c,Opportunity_Name__c, NuDebt_Payment_Name__c 
                                                          from Opportunity_Payment__c where 
                                                          //FileNumber__c = :RelatedProgramIds AND 
                                                          Import_Id__c =:importIds];
                                          
		System.debug(loggingLevel.ERROR ,'prizmPaymentsList ******= ' + prizmPaymentsList);
		if(prizmPaymentsList != null){
		for(Opportunity_Payment__c prizmPayment: prizmPaymentsList)
				prizmPaymentsMapOnImportId.put(prizmPayment.Import_Id__c, prizmPayment);
			}
		System.debug(loggingLevel.ERROR ,'prizmPaymentsMapOnImportId ******= ' + prizmPaymentsMapOnImportId);
              
        for(NuDebtProgramWrapper.PaymentsWrapper paymentWrapper: paymentsList){
                if(RelatedProgramIdLeads.containsKey(paymentWrapper.programId)){
                    Lead relatedLead = RelatedProgramIdLeads.get(paymentWrapper.programId);
                    if(prizmPaymentsMapOnImportId.containsKey(paymentWrapper.paymentsId))
                        oppPayment = prizmPaymentsMapOnImportId.get(paymentWrapper.paymentsId);
                    else if(oppPaymentsMap.containsKey(paymentWrapper.paymentsId))
                         oppPayment = oppPaymentsMap.get(paymentWrapper.paymentsId);
                     else 
                         oppPayment = new Opportunity_Payment__c();
                    
                    //oppPayment 					= new Opportunity_Payment__c();
                    oppPayment.FileNumber__c 	= relatedLead.NDS_File_Number__c;
                    oppPayment.Import_Id__c 	= paymentWrapper.paymentsId;
                    oppPayment.NuDebt_Payment_Name__c = paymentWrapper.Name;
                    oppPayment.Lead__c 			= relatedLead.Id;
                    oppPayment.RecordTypeId 	= draftPayRecTypeId;
                    oppPayment.Payment_Status__c = paymentWrapper.PaymentStatus;
                    oppPayment.Payment_Type__c 	= paymentWrapper.PaymentType;
                    oppPayment.Transaction_Method__c = paymentWrapper.TransMethod;
                    oppPayment.Transaction_Status__c = paymentWrapper.TransactionStatus;
                    if(String.IsNotBlank(paymentWrapper.ScheduleDate)) 
                        oppPayment.Schedule_Date__c = Date.ValueOf(paymentWrapper.ScheduleDate);
                    if(String.IsNotBlank(paymentWrapper.TotalAmount)) 
                        oppPayment.Total_Amount__c = Decimal.valueof(paymentWrapper.TotalAmount);
                    if(String.IsNotBlank(paymentWrapper.NFSDate)) 
                        oppPayment.NSF_Date__c 	= Date.ValueOf(paymentWrapper.NFSDate);
                    if(paymentWrapper.PayRecType=='Settlement')  
                        oppPayment.RecordTypeId = settelmentPayRecTypeId;  
                    else if(paymentWrapper.PayRecType=='Draft')
                        oppPayment.RecordTypeId = draftPayRecTypeId;
                    else if(paymentWrapper.PayRecType=='Loan')
                        oppPayment.RecordTypeId = LoanPayRecTypeId;
                    else if(paymentWrapper.PayRecType=='Refund loan')
                        oppPayment.RecordTypeId = RefundloanPayRecTypeId;
                    oppPaymentsList.add(oppPayment);
                }                
            }          
            System.debug(loggingLevel.ERROR ,'oppPaymentsList= ' + oppPaymentsList);
            upsert oppPaymentsList;
    }
    
 
   /**
	* About: Update the related Tradelines detail for NuDebt Lead
	*
	* Author: Kimi Shrivastava
	*
	**/
    
    public static Map<String,Opportunity_Payment__c> updateTradeLines(List<NuDebtProgramWrapper.TradelinesWrapper> tradelinesList, 
                                                                Map<Id, Lead> RelatedProgramIdLeads, List<Id> RelatedProgramIds){
        
        List<Opportunity_Tradelines_Offer__c> oppTradelinesOfferList = new List<Opportunity_Tradelines_Offer__c>();   
        List<NuDebtProgramWrapper.PaymentsWrapper> oppSetPaymentLst = new List<NuDebtProgramWrapper.PaymentsWrapper>();
        Map<String, Opportunity_Payment__c> newPayMap = new Map<String, Opportunity_Payment__c>();               
        List<String> importIds = new List<String>();   
        Map<String, Opportunity_Tradelines_Offer__c> prizmTradelinesMapOnImportId = new Map<String, Opportunity_Tradelines_Offer__c>();                                                            
        Opportunity_Tradelines_Offer__c oppTradeOffer;
        Opportunity_Payment__c newPay = new Opportunity_Payment__c();    
        Id leadTradeLinesRecordTypeId = Schema.SObjectType.Opportunity_Tradelines_Offer__c.getRecordTypeInfosByName().get('Lead Tradelines Offer').getRecordTypeId();
                                                                   
        // Check if any tradelines already exist in the Prizm                                       
        if(tradelinesList != null){
        	for(NuDebtProgramWrapper.TradelinesWrapper tradeline: tradelinesList)
				importIds.add(tradeline.tradelinesId);
		}
                                                                    
		List<Opportunity_Tradelines_Offer__c> prizmTradelinesList = [Select Id, FileNumber__c, Import_Id__c, Lead__c, Opportunity_Name__c 
        													from Opportunity_Tradelines_Offer__c where 
                                                            //FileNumber__c = :RelatedProgramIds AND 
                                                            Import_Id__c =:importIds];
                                                                    
		System.debug(loggingLevel.ERROR ,'prizmTradelinesList ******= ' + prizmTradelinesList);
        if(prizmTradelinesList != null){
        	for(Opportunity_Tradelines_Offer__c prizmTradeline: prizmTradelinesList)
            	prizmTradelinesMapOnImportId.put(prizmTradeline.Import_Id__c, prizmTradeline);
 		}
        System.debug(loggingLevel.ERROR ,'prizmTradelinesMapOnImportId ******= ' + prizmTradelinesMapOnImportId);

        // Update the existing records/Insert new records w.r.t. to the Lead                                                           
        for(NuDebtProgramWrapper.TradelinesWrapper tradelineWrapper: tradelinesList){
            if(RelatedProgramIdLeads.containsKey(tradelineWrapper.programId)){
                Lead relatedLead = RelatedProgramIdLeads.get(tradelineWrapper.programId);
                if(prizmTradelinesMapOnImportId.containsKey(tradelineWrapper.tradelinesId))
                    oppTradeOffer = prizmTradelinesMapOnImportId.get(tradelineWrapper.tradelinesId);
                 else
                	oppTradeOffer = new Opportunity_Tradelines_Offer__c();
                oppTradeOffer.FileNumber__c = relatedLead.NDS_File_Number__c;
                oppTradeOffer.Import_Id__c = tradelineWrapper.tradelinesId;
                oppTradeOffer.NuDebt_Tradeline_Name__c = tradelineWrapper.Name;
                oppTradeOffer.Lead__c = relatedLead.Id;
                oppTradeOffer.RecordTypeId = leadTradeLinesRecordTypeId;
                if(String.isNotBlank(tradelineWrapper.OfferAmount))
                    oppTradeOffer.Offer_Amount__c = Decimal.ValueOf(tradelineWrapper.OfferAmount);
                if(String.isNotBlank(tradelineWrapper.OfferProgramFee))
                    oppTradeOffer.Offer_Program_Fee__c = Decimal.valueOf(tradelineWrapper.OfferProgramFee);
                if(String.isNotBlank(tradelineWrapper.SettlementAmountPaid))
                    oppTradeOffer.Settlement_Amount_Paid__c = Decimal.valueOf(tradelineWrapper.SettlementAmountPaid);
                if(String.isNotBlank(tradelineWrapper.AmountPaid))
                    oppTradeOffer.Amount_Paid__c = Decimal.valueOf(tradelineWrapper.AmountPaid);
                if(tradelineWrapper.DNLEstimatedSettlement != null && tradelineWrapper.DNLEstimatedSettlement !='')
                    oppTradeOffer.Estimated_Settlement__c = Decimal.valueOf(tradelineWrapper.DNLEstimatedSettlement);
                if(tradelineWrapper.DNLFundstoClient != null && tradelineWrapper.DNLFundstoClient !='')
                    oppTradeOffer.DNL_Funds_to_Client__c = Decimal.valueOf(tradelineWrapper.DNLFundstoClient);
                if(tradelineWrapper.DNLFundsforFees != null && tradelineWrapper.DNLFundsforFees !='')
                    oppTradeOffer.DNL_Funds_for_Fees__c = Decimal.valueOf(tradelineWrapper.DNLFundsforFees);
                if(tradelineWrapper.DNLDisbursementAmount != null && tradelineWrapper.DNLDisbursementAmount !='')
                    oppTradeOffer.Actual_Settlement_Amount__c = Decimal.valueOf(tradelineWrapper.DNLDisbursementAmount);
                if(tradelineWrapper.DNLSettlementFees != null && tradelineWrapper.DNLSettlementFees !='')
                    oppTradeOffer.DNL_Settlement_Fees__c = Decimal.valueOf(tradelineWrapper.DNLSettlementFees);
                if(tradelineWrapper.DNLDisbursementDate != null && tradelineWrapper.DNLDisbursementDate !='')
                    oppTradeOffer.Settlement_Date__c = Date.valueOf(tradelineWrapper.DNLDisbursementDate);
                if(tradelineWrapper.DNLDisbursementAmount != null && tradelineWrapper.DNLDisbursementAmount !='')
                    oppTradeOffer.DNL_Disbursement_Amount__c = Decimal.valueOf(tradelineWrapper.DNLDisbursementAmount);
                if(tradelineWrapper.DNLDisbursementDate != null && tradelineWrapper.DNLDisbursementDate !='')
                    oppTradeOffer.DNL_Disbursement_Date__c = Date.valueOf(tradelineWrapper.DNLDisbursementDate);
                if(tradelineWrapper.DNLfirstSettelment != null && tradelineWrapper.DNLfirstSettelment !=''){            //PDI-1043
                    oppTradeOffer.DNL_First_Settlement__c= (tradelineWrapper.DNLfirstSettelment=='true')?true:false;
                }if(tradelineWrapper.SFSCurrentBalance != null && tradelineWrapper.SFSCurrentBalance != '')
                    oppTradeOffer.SFS_Current_Balance__c = Decimal.valueof(tradelineWrapper.SFSCurrentBalance);
                if(tradelineWrapper.OriginalDebt != null && tradelineWrapper.OriginalDebt != '')
                    oppTradeOffer.Original_Debt__c = Decimal.valueof(tradelineWrapper.OriginalDebt);
                //DV-129
                if(tradelineWrapper.NewAccountNumber!= null && tradelineWrapper.NewAccountNumber!='')
                    oppTradeOffer.New_Account_Number__c = tradelineWrapper.NewAccountNumber;
                if(tradelineWrapper.NewCreditor!= null && tradelineWrapper.NewCreditor!='')
                    oppTradeOffer.New_Creditor__c = tradelineWrapper.NewCreditor;        
                
                oppTradeOffer.Offer_Status__c = tradelineWrapper.OfferStatus;
                oppTradeOffer.Current_Stage__c = tradelineWrapper.CurrentStage;
                oppTradeOffer.Litigation_Stage__c = tradelineWrapper.LitigationStage;
                oppTradeOffer.Original_Account_Number__c  = tradelineWrapper.OriginalAccountNumber;                
                oppTradeOffer.Original_Creditor__c = tradelineWrapper.OriginalCreditorName;
                oppSetPaymentLst = new List<NuDebtProgramWrapper.PaymentsWrapper>();
                Map<String, Opportunity_Payment__c> prizmPaymentsMapOnImportId = new Map<String, Opportunity_Payment__c>();
                if(tradelineWrapper.settlementPayments != NULL){
                    List<String> paymentImportIds = new List<String>();                                          
                    if(tradelineWrapper.settlementPayments != null){
                        for(NuDebtProgramWrapper.PaymentsWrapper pay: tradelineWrapper.settlementPayments)
                            importIds.add(pay.paymentsId);
                    }
                    
                    List<Opportunity_Payment__c> prizmTradelinesPaymentsList = [Select Id, FileNumber__c, Import_Id__c, Lead__c, RecordTypeId, Payment_Type__c,Opportunity_Name__c 
                                                                      from Opportunity_Payment__c where 
                                                                      //FileNumber__c = :RelatedProgramIds AND 
                                                                      Import_Id__c =:paymentImportIds];
                    
                    System.debug(loggingLevel.ERROR ,'prizmTradelinesPaymentsList ******= ' + prizmTradelinesPaymentsList);
                    if(prizmTradelinesPaymentsList != null){
                        for(Opportunity_Payment__c prizmPayment: prizmTradelinesPaymentsList)
                            prizmPaymentsMapOnImportId.put(prizmPayment.Import_Id__c, prizmPayment);
                    }
                    System.debug(loggingLevel.ERROR ,'prizmPaymentsMapOnImportId ******= ' + prizmPaymentsMapOnImportId);                    
                    
                }
                    oppSetPaymentLst = tradelineWrapper.settlementPayments;
                if(oppSetPaymentLst != null){
                    for(NuDebtProgramWrapper.PaymentsWrapper pay: oppSetPaymentLst){
                        if(prizmPaymentsMapOnImportId.containsKey(pay.paymentsId))
                            newPay = prizmPaymentsMapOnImportId.get(pay.paymentsId);
                         else
                            newPay = new Opportunity_Payment__c();
                        newPay.Import_Id__c = pay.paymentsId;
                        newPay.Lead__c = relatedLead.Id;
                        newPay.RecordTypeId = settelmentPayRecTypeId; 
                        newPay.FileNumber__c = pay.FileNumber;
                        newPay.Payment_Status__c = pay.PaymentStatus;
                        newPay.Transaction_Method__c = pay.TransMethod;
                        newPay.Payment_Type__c = pay.PaymentType;
                        if(pay.TotalAmount != null && pay.TotalAmount != '')
                            newPay.Total_Amount__c = Double.valueOf(pay.TotalAmount);
                        if(pay.ScheduleDate != '' && pay.ScheduleDate != null)
                            newPay.Schedule_Date__c = Date.valueOf(pay.ScheduleDate);
                        
                        newPayMap.put(pay.paymentsId, newPay);
                        //paymentTradeLinemap.put(newPay.Import_Id__c,newTrade.Import_Id__c);
                    }
                }
                
                oppTradelinesOfferList.add(oppTradeOffer);
            }
            
        }
        System.debug(loggingLevel.ERROR ,'oppTradelinesOfferList = ' + oppTradelinesOfferList);
        Upsert oppTradelinesOfferList;
        
        return newPayMap;
    }
    
    //--------------------------------------------------------------------------------------------------
    // Update Draft fees for the leads
    
    
    public static void  updateDraftFeesDetails(List<NuDebtProgramWrapper.DraftFeesWrapper> draftsWrpList, Map<Id, Lead> RelatedProgramIdLeads){
        
        List<String> importIds = new List<String>();
        Map<Id, Opportunity_Draft_Fee__c> prizmDraftFeesMapOnImportId = new Map<Id, Opportunity_Draft_Fee__c>();
        // Check if any draft fees already exist in the Prizm                                       
        if(draftsWrpList != null){
        	for(NuDebtProgramWrapper.DraftFeesWrapper draftFee: draftsWrpList)
				importIds.add(draftFee.programId);
		}
                                                                    
		List<Opportunity_Draft_Fee__c> prizmDraftFeesList = [Select Id, Program_ID__c,  Lead__c 
        													from Opportunity_Draft_Fee__c where 
                                                            //FileNumber__c = :RelatedProgramIds AND 
                                                            Program_ID__c =:importIds];
                                                                    
		System.debug(loggingLevel.ERROR ,'prizmDraftFees ******= ' + prizmDraftFeesList);
        if(prizmDraftFeesList != null){
        	for(Opportunity_Draft_Fee__c prizmDraftFees: prizmDraftFeesList)
            	prizmDraftFeesMapOnImportId.put(prizmDraftFees.Program_ID__c, prizmDraftFees);
 		}
        System.debug(loggingLevel.ERROR ,'prizmDraftFeesMapOnImportId ******= ' + prizmDraftFeesMapOnImportId);
        
        Opportunity_Draft_Fee__c df = new Opportunity_Draft_Fee__c();
        List<Opportunity_Draft_Fee__c> dfList = new List<Opportunity_Draft_Fee__c>();
        if(draftsWrpList != null){
            for(NuDebtProgramWrapper.DraftFeesWrapper draftFeesWrapper : draftsWrpList){
                if(RelatedProgramIdLeads.containsKey(draftFeesWrapper.programId)){
                Lead relatedLead = RelatedProgramIdLeads.get(draftFeesWrapper.programId);
                if(prizmDraftFeesMapOnImportId.containsKey(draftFeesWrapper.programId))
                    df = prizmDraftFeesMapOnImportId.get(draftFeesWrapper.programId);
                 else
                	df = new Opportunity_Draft_Fee__c();
                	df.Program_Id__c = draftFeesWrapper.programId;  
                    df.Lead__c = relatedLead.Id;
                    df.Paid_Accumulation__c = draftFeesWrapper.PaidAccumulation;
                    df.Paid_Admin_Fee__c = draftFeesWrapper.PaidAdminFee;
                    df.Paid_Creditor_Payments__c = draftFeesWrapper.PaidCreditorPayments;
                    df.Paid_Maintenance_Fee__c = draftFeesWrapper.PaidMaintenanceFee;
                    df.Paid_Processor_Fee__c = draftFeesWrapper.PaidProcessorFee;
                    df.Paid_Program_Fee__c = draftFeesWrapper.PaidProgramFee;            
                    df.Paid_Retainer_Fee__c = draftFeesWrapper.PaidRetainerFee;            
                    df.Paid_Service_Fee__c= draftFeesWrapper.PaidServiceFee;            
                    df.Paid_Third_Party_Fee__c = draftFeesWrapper.PaidThirdPartyFee;            
                    df.Total_Accumulation__c = draftFeesWrapper.TotalAccumulation;                        
                    df.Total_Admin_Fee__c = draftFeesWrapper.TotalAdminFee;                
                    df.Total_Creditor_Payments__c = draftFeesWrapper.TotalCreditorPayments;            
                    df.Total_Maintenance_Fee__c = draftFeesWrapper.TotalMaintenanceFee;            
                    df.Total_Processor_Fee__c = draftFeesWrapper.TotalProcessorFee;             
                    df.Total_Program_Fee__c = draftFeesWrapper.TotalProgramFee;            
                    df.Total_Retainer_Fee__c = draftFeesWrapper.TotalRetainerFee;            
                    df.Total_Service_Fee__c = draftFeesWrapper.TotalServiceFee;
                    df.Total_Third_Party_Fee__c = draftFeesWrapper.TotalThirdPartyFee;
                    df.Remaining_Accumulation__c = draftFeesWrapper.RemainingAccumulation;                        
                    df.Remaining_Admin_Fee__c = draftFeesWrapper.RemainingAdminFee;                
                    df.Remaining_Creditor_Payments__c = draftFeesWrapper.RemainingCreditorPayments;            
                    df.Remaining_Maintenance_Fee__c = draftFeesWrapper.RemainingMaintenanceFee;            
                    df.Remaining_Processor_Fee__c = draftFeesWrapper.RemainingProcessorFee;             
                    df.Remaining_Program_Fee__c = draftFeesWrapper.RemainingProgramFee;            
                    df.Remaining_Retainer_Fee__c = draftFeesWrapper.RemainingRetainerFee;            
                    df.Remaining_Service_Fee__c = draftFeesWrapper.RemainingServiceFee;
                    df.Remaining_Third_Party_Fee__c = draftFeesWrapper.RemainingThirdPartyFee;
                dfList.add(df);
                }
            }
        System.debug(loggingLevel.ERROR ,'dfList = ' + dfList);
        Upsert dfList;
        }

    }
    
    //--------------------------------------------------------------------------------------------------
    
    public static Map<string,Object> getConnectionResponse(){
        //Logic For getting Access Token
        RestIntegrationInformation__mdt restIntegration = [select EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,
                                                           	Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        
        System.debug(loggingLevel.ERROR,'reqbody = ' + reqbody);
        
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(restIntegration.AccesstokenURL__c); //Change "ap4" in url to your Target Org Instance 
        req.setHeader('Content-Type','application/x-www-form-urlencoded');  
        Map<string,Object> resultMap;
        HttpResponse res=h.send(req);
        System.debug(loggingLevel.ERROR, 'Status = ' + res.getStatusCode());
        resultMap = (Map<string,Object>)JSON.deserializeUntyped(res.getBody());
        return resultMap;
    }
    
  public static void leadUpdate(NuDebtProgramWrapper nuDebtProgramWrapper, List<Lead> leads, Map<Id, Lead> leadMap, Boolean isInsert){
      System.debug('leadUpdate = ');
        List<NuDebtProgramWrapper.ProgramWrapper> ProgramList = nuDebtProgramWrapper.programs;
      
        Map<String, NuDebtProgramWrapper.ProgramWrapper> FileProgramMap = new Map<String, NuDebtProgramWrapper.ProgramWrapper>();
        Map<Id,Id> ProgramLeadMap = new Map<Id,Id>();
      	List<Id> ProgramIds = new List<Id>();
        List<Id> RelatedProgramIds = new List<Id>();
    	Map<Id, Lead> RelatedProgramIdLeads = new Map<Id, Lead>();
        NuDebtProgramWrapper.ProgramWrapper newLeadProgramWrapper = new NuDebtProgramWrapper.ProgramWrapper();
      	List<NuDebtProgramWrapper.ProgramWrapper> newLeadProgramList = new List<NuDebtProgramWrapper.ProgramWrapper>();
      
        for(NuDebtProgramWrapper.ProgramWrapper program : ProgramList){
                System.debug(loggingLevel.ERROR , 'LeadUpdateQueueable execute program.programName= '  + program.fileNumber);
                FileProgramMap.put(program.fileNumber ,program);
                System.debug(loggingLevel.ERROR , 'FileProgramMap = ' + FileProgramMap);
            }
            System.debug(loggingLevel.ERROR ,'leadUpdate = ' + leads);
            
            List<Lead> LeadList = new List<Lead>();
      		List<String> leadIdList = new List<String>();
            Lead newLead ;
            // Build lead objects based on the retrieved values from NuDebt Program
            for(Lead lead : leads){
                if(FileProgramMap.containsKey(lead.NDS_File_Number__c) 
                   && lead.NDS_File_Number__c != null 
                   && lead.NDS_File_Number__c != ''){
                       lead.ProgramName__c 		= 	FileProgramMap.get(lead.NDS_File_Number__c).programName;
                       lead.ProgramNameText__c = 	FileProgramMap.get(lead.NDS_File_Number__c).programNameText;
                       lead.FirstName			= 	FileProgramMap.get(lead.NDS_File_Number__c).firstName;
                       lead.Applicant_State__c 	= 	FileProgramMap.get(lead.NDS_File_Number__c).applicantState;
                       lead.Email				= 	FileProgramMap.get(lead.NDS_File_Number__c).email;
                       lead.Applicant_Email__c				= 	FileProgramMap.get(lead.NDS_File_Number__c).email;
                       lead.Social_Security_Number__c= FileProgramMap.get(lead.NDS_File_Number__c).socialSecurityNumber;
                       lead.Co_Applicant_First_Name__c	= 	FileProgramMap.get(lead.NDS_File_Number__c).coFirstName;
                       lead.Co_Applicant_Last_Name__c 	= 	FileProgramMap.get(lead.NDS_File_Number__c).coLastName;
                       lead.Co_Applicant_Phone__c	= 	FileProgramMap.get(lead.NDS_File_Number__c).coPhone;
                       lead.Co_Applicant_Email__c 	= 	FileProgramMap.get(lead.NDS_File_Number__c).coEmail;
                       lead.Co_Applicant_State__c	= 	FileProgramMap.get(lead.NDS_File_Number__c).coApplicantState;
                       lead.Co_Applicant_SSN__c 	= 	FileProgramMap.get(lead.NDS_File_Number__c).coApplicantSSN;
                       lead.NuDebtAccount__c 		= 	FileProgramMap.get(lead.NDS_File_Number__c).account;
                       lead.NuDebtAccountName__c 	= 	FileProgramMap.get(lead.NDS_File_Number__c).firstName + ' ' + FileProgramMap.get(lead.NDS_File_Number__c).lastName;
                       lead.Payment_Frequency__c 	= 	FileProgramMap.get(lead.NDS_File_Number__c).paymentFrequency;
                       lead.Last_Draft__c 			= 	FileProgramMap.get(lead.NDS_File_Number__c).lastDraft;                
                       lead.Unsettled_Debt__c 		= 	FileProgramMap.get(lead.NDS_File_Number__c).unsettledDebt; //DV-156
                       lead.Birth_Date__c 			=  	FileProgramMap.get(lead.NDS_File_Number__c).birthDate;
                       lead.Enrollment_Date__c		= 	FileProgramMap.get(lead.NDS_File_Number__c).enrollmentDate;
                       lead.Phone 					= 	FileProgramMap.get(lead.NDS_File_Number__c).Phone;
                       lead.Cell_phone__c			= 	FileProgramMap.get(lead.NDS_File_Number__c).cellPhone;
                       lead.Best_Phone__c			= 	FileProgramMap.get(lead.NDS_File_Number__c).bestPhone;
                       lead.Home_Phone__c			= 	FileProgramMap.get(lead.NDS_File_Number__c).homePhone;
                       lead.MobilePhone 			= 	FileProgramMap.get(lead.NDS_File_Number__c).mobilePhone;
                       lead.PersonOtherPhone__c 	= 	FileProgramMap.get(lead.NDS_File_Number__c).personOtherPhone;
                       lead.Program_Length__c		= 	FileProgramMap.get(lead.NDS_File_Number__c).programLength;
                       lead.Program_Type__c			= 	FileProgramMap.get(lead.NDS_File_Number__c).programType;
                       lead.Processor_Name__c		= 	FileProgramMap.get(lead.NDS_File_Number__c).processorName;
                       //lead.Sales_Rep__c			= 	FileProgramMap.get(lead.NDS_File_Number__c).salesRep;
                       lead.Campaign_Type__c		= 	FileProgramMap.get(lead.NDS_File_Number__c).campaignType;
                       lead.Portfolio__c			= 	FileProgramMap.get(lead.NDS_File_Number__c).portfolio;
                       lead.Portfolio_Name__c    		=  FileProgramMap.get(lead.NDS_File_Number__c).portfolioName;
                       lead.Portfolio_Support_Email__c	= FileProgramMap.get(lead.NDS_File_Number__c).portfolioSupportEmail;
                       lead.Portfolio_Retention_Email__c	= FileProgramMap.get(lead.NDS_File_Number__c).portfolioRetentionEmail;
                       lead.Portfolio_Communication_Template_Email__c = FileProgramMap.get(lead.NDS_File_Number__c).portfolioCommunicationTemplateEmail ;
                       lead.Portfolio_Type__c 						= FileProgramMap.get(lead.NDS_File_Number__c).portfolioType;
                       //lead.Lead_Number__c			= 	FileProgramMap.get(lead.NDS_File_Number__c).leadNumber;
                       
                       LeadList.add(lead);
                       leadIdList.add(lead.Id);
                   }
                if(lead.ProgramName__c != null && lead.latest_lead__c == true){
                    ProgramLeadMap.put(lead.ProgramName__c,lead.Id);
                    newLeadProgramWrapper = new NuDebtProgramWrapper.ProgramWrapper();
                    newLeadProgramWrapper.leadId = lead.Id;
                    newLeadProgramWrapper.programName = lead.ProgramName__c;
                    newLeadProgramWrapper.leadStatus = lead.Status;
                    newLeadProgramWrapper.latestLead = lead.Latest_Lead__c;
                    newLeadProgramList.add(newLeadProgramWrapper);
                    //if(lead.ProgramName__c != leadMap.get(lead.Id).ProgramName__c){
                        RelatedProgramIds.add(lead.ProgramName__c);
                        RelatedProgramIdLeads.put(lead.ProgramName__c, lead);
                    //}
                    if(lead.Status != leadMap.get(lead.Id).Status){
                        ProgramIds.add(lead.ProgramName__c);
                    }
                }
                
            }
            System.debug(loggingLevel.ERROR ,'LeadList = ' + LeadList);
      		System.debug(loggingLevel.ERROR ,'RelatedProgramIdLeads = ' + RelatedProgramIdLeads);
            update LeadList;
      
       Map<String,Opportunity_Payment__c>  newOppPaymentMap = new Map<String,Opportunity_Payment__c>();
       if(nuDebtProgramWrapper.tradelines != null && RelatedProgramIdLeads != null){
          System.debug(loggingLevel.ERROR ,'updateTradelines = ' + nuDebtProgramWrapper.tradelines);
          newOppPaymentMap = updateTradelines(nuDebtProgramWrapper.tradelines, RelatedProgramIdLeads, RelatedProgramIds);
      }
      if(nuDebtProgramWrapper.payments != null && RelatedProgramIdLeads != null){
          System.debug(loggingLevel.ERROR ,'updatePayments ******= ' + nuDebtProgramWrapper.payments);
           updatePayments(nuDebtProgramWrapper.payments, RelatedProgramIdLeads, RelatedProgramIds, newOppPaymentMap);
           updateLeadFieldsOnNuDebtPayments(leadIdList);
      } 
      System.debug(loggingLevel.ERROR ,'nuDebtProgramWrapper.draftFeesList = ' + nuDebtProgramWrapper.draftFeesList);
      if(nuDebtProgramWrapper.draftFeesList != null){
          updateDraftFeesDetails(nuDebtProgramWrapper.draftFeesList, RelatedProgramIdLeads);
      }
      
       /*if(isInsert)
       		PrizmLeadTriggerHandler.PrizmLeadTriggerAfter(ProgramIds, newLeadProgramList);*/
    }
    //--------------------------------------------------------------------
    // Function to update the Lead records to DNL Ineligible based on the failed payment status on NuDebt draft payments
    // --------------------------------------------------------------------
    public static void updateLeadFieldsOnNuDebtPayments(List<String> newLeadIds){    
        
        Id DraftRecordTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Draft').getRecordTypeId();   
        
        List<Id> LeadIds = new List<Id>();
        Set<Id> CancelledLead = new Set<Id>();
        
        List<Opportunity_Payment__c> PaymentList = [Select Id, name, RecordTypeId, Lead__c, Payment_Status__c, Schedule_Date__c, Transaction_Status__c 
                                                    from  Opportunity_Payment__c where 
                                                    Lead__c = :newLeadIds and RecordTypeId = :DraftRecordTypeId];
        for(Opportunity_Payment__c Payment : PaymentList){
            System.debug(loggingLevel.ERROR ,'Payment = ' + Payment.Transaction_Status__c);
            if(Payment.Lead__c != null && Payment.RecordTypeId == DraftRecordTypeId 
               && (Payment.Transaction_Status__c == 'Cancelled' || Payment.Transaction_Status__c == 'Skipped' || Payment.Transaction_Status__c == 'Failed')  
                 ){
                   CancelledLead.add(Payment.Lead__c);
                   System.debug('*****Payment.Lead__c'+Payment.Lead__c);
               }
        }
        System.debug(loggingLevel.ERROR ,'CancelledLead = ' + CancelledLead);
        if(!CancelledLead.isEmpty()){
            List<Lead> CancelledLeadList = [Select Id, Status, Sub_Status__c from Lead where Id=:CancelledLead ];
            
            for(Lead l : CancelledLeadList){
                L.Lead_Status_Text__c = 'DNL Ineligible';
                L.Status = 'DNL Ineligible';
                L.Sub_Status__c = 'Skip';
            }
            Update CancelledLeadList;
        }
    }
    
       // run PrizmLeadPullService.testMe(); from Execute Anonymous to test
    public static void testMe() {
       /* List<String> listOfIds = new List<String>();
        listOfIds.add('0011K000021P3OX');
        listOfIds.add('0011K000021P3cy');
        listOfIds.add('00Q2f0000025bBZEAY');
        listOfIds.add('00Q2f0000025bBaEAI');
        List<Lead> leads = [Select Id, NDS_File_Number__c from Lead 
                    where Id = :listOfIds ];
        System.debug(leads);*/
        
        List<String> listOfFileIds = new List<String>();
        listOfFileIds.add('SM0014312863');
        List<Lead> leads = [Select Id, NDS_File_Number__c,ProgramName__c, Applicant_State__c, Social_Security_Number__c, Co_Applicant_State__c, Co_Applicant_SSN__c, Account__c, MiddleName, Payment_Frequency__c,
                            Last_Draft__c, Unsettled_Debt__c, Birth_Date__c, Phone, Cell_phone__c, Best_Phone__c, Home_Phone__c, MobilePhone, PersonOtherPhone__c from Lead 
                            where NDS_File_Number__c = :listOfFileIds ];
        System.debug(leads);
        List<String> listOfFileNumbers = new List<String>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        for(Lead lead:leads){
            listOfFileNumbers.add(lead.Id);
            leadMap.put(lead.Id, lead);
        }
		updateLeadFieldsOnNuDebtPayments(listOfFileNumbers);
    }
    
    public static void testPushToNuDebt() {
            List<String> listOfIds = new List<String>();
            
            listOfIds.add('00Q0W00000qtCnFUAU');
            listOfIds.add('00Q0W00000qtCnjUAE');
            listOfIds.add('00Q0W00000qtCntUAE');
            listOfIds.add('00Q0W00000qtCo8UAE');
            listOfIds.add('00Q0W00000qtCoYUAU');
            listOfIds.add('00Q0W00000qtCodUAE');
            
            List<NuDebtProgramWrapper.ProgramWrapper> newLeadProgramList = new List<NuDebtProgramWrapper.ProgramWrapper>();
            NuDebtProgramWrapper.ProgramWrapper newLeadProgramWrapper =  new NuDebtProgramWrapper.ProgramWrapper();
            NuDebtProgramWrapper programWrapper = new NuDebtProgramWrapper();
            List<Lead> LeadList = [Select Id,Latest_Lead__c, Status, ProgramName__c from Lead where Id =:listOfIds];
            for(Lead lead:LeadList){
                newLeadProgramWrapper = new NuDebtProgramWrapper.ProgramWrapper();
                newLeadProgramWrapper.leadId = lead.Id;
                newLeadProgramWrapper.programName = lead.ProgramName__c;
                newLeadProgramWrapper.leadStatus = lead.Status;
                newLeadProgramWrapper.latestLead = lead.Latest_Lead__c;
                newLeadProgramList.add(newLeadProgramWrapper);
            }
            programWrapper.programs = newLeadProgramList;
            NuDebtProgramWrapper newWrp = PrizmLeadPullService.sendProgramDataToNuDebt(programWrapper);
        	System.debug(newWrp.programs);
           
    }
}