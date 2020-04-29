/*------------------------------------------------------------
Author:         Financial Spectra DEV
Description:    Service Handler for Pricing offer REST Service
History
<Date>      <Authors Name>      <Brief Description of Change>
21-Jul-19   FS Dev              Created
------------------------------------------------------------*/
global with sharing class RESTPricingOfferHandler_V1 extends fsCore.RESTServiceHandlerBase{
    
    private static final String SUB_RESOURCE_ACCEPT_PRICING = 'accept';
    
    global RESTPricingOfferHandler_V1(){
        super();
    }
    
    public override void getRecords(){
        invalidRequest();
    }
    
    public override void deleteRecords(){
        invalidRequest();
    }
    
    /*
* Method to create a new application with a new applicant
*/
    public override void postRecords(){
        handlePricingOfferCreate();
    }
    
    /*
* Method to update Lending Application record
* This method also handles the application decline and withdraw request as sub resources
*/
    public override void putRecords(){
        if (!isResourceURIValid()){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Id offerId;
        try{
            System.debug(logginglevel.error, requestInfo.resourceURLInfo.resourceIdentifier);
            offerId = Id.valueOf(requestInfo.resourceURLInfo.resourceIdentifier);
        }
        catch (Exception e){
            addError(e);
        }
        
        if (String.isBlank(requestInfo.resourceURLInfo.subResourceType)){
            invalidRequest();
        }        
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        //handle sub-resource - accept
        if (String.isNotBlank(requestInfo.resourceURLInfo.subResourceType)){
            if (requestInfo.resourceURLInfo.subResourceType.equalsIgnoreCase(SUB_RESOURCE_ACCEPT_PRICING)){
                handlePricingAccept(offerId);
            }
        }       
    }
    
    private void handlePricingOfferCreate(){
        RESTPricingOffer.Request offerRequest = new RESTPricingOffer.Request();
        
        //parse request
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                offerRequest = (RESTPricingOffer.Request)JSON.deserialize(requestInfo.requestBodyJSON, RESTPricingOffer.Request.class);
            }
            catch(Exception e){
                offerRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        
        fsCore__Lending_Application__c application;
        List<fsCore__Pricing_Setup__c> availablePricingList = new List<fsCore__Pricing_Setup__c>();
        if (!hasError && offerRequest != null){
            //validate and set product details
            if (offerRequest.application_id == null){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Application Id is blank');
            }
            else {
                System.debug(loggingLevel.ERROR, 'offerRequest.application_id:--'+ offerRequest.application_id  );
                application = RESTServiceUtility.getApplicationInfo(offerRequest.application_id);
                
                if (application == null){
                    addError(fsCore.RESTConstants.NOT_FOUND, 'Unable to find a application with Id ' + offerRequest.application_id);
                }else{
                    if (application.fsCore__Is_Application_Read_Only__c){
                        addError(fsCore.RESTConstants.NOT_ALLOWED, 'Application is read only, cannot generate offer ' + offerRequest.application_id);
                    }
                }
            }
            if (offerRequest.start_date == null){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Start date is blank');
            }
            if (offerRequest.versara_offer_id == null){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Versara Offer ID is blank');
            }
            if (offerRequest.payment_start_date == null){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Payment start date is blank');
            }   
            if (offerRequest.Approved_amount == null){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Approved amount is blank');
            }
            else{
                if (offerRequest.Approved_amount <=0){
                    addError(fsCore.RESTConstants.INVALID_REQUEST, 'Approved amount must be greater than zero');
                } 
            }     

            if (offerRequest.auto_accept_Offer && offerRequest.Hard_Pull_Pricing_Offer){                
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'HardPull Pricing offer cannot be sent as auto accepted.');
            }
            
            if (offerRequest.number_of_payments == null){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Number of payments is blank');
            }
            else{
                if (offerRequest.number_of_payments <=0){
                    addError(fsCore.RESTConstants.INVALID_REQUEST, 'Number of payments must be greater than zero');
                } 
            }                    
            if (offerRequest.rate == null){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'rate is blank');
            }
            else{
                if (offerRequest.rate <=0){
                    addError(fsCore.RESTConstants.INVALID_REQUEST, 'Rate must be greater than zero');
                }                 
            }                           
            if ((offerRequest.payment_start_date != null) && (offerRequest.start_date != null)){
                if (offerRequest.payment_start_date < offerRequest.start_date){
                    addError(fsCore.RESTConstants.INVALID_REQUEST, 'Payment start date must be greater or equal to start date');
                } 
                
            }
            availablePricingList = fsCore.PricingUtil.getAvailablePricings(application,false);
            if (availablePricingList.size()==0){
                addError(fsCore.RESTConstants.PRECONDITION_FAILED, 'Pricing setup not found');
            }
            //add more validations here
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        //pricing offer accept action
        //
        //create applicant and application 
        //
        fsCore__Lending_Application_Pricing_Offer__c offer;
        Savepoint sp = Database.setSavepoint();
        if (!hasError){
            try{
                
                Set<Id> pricingIdSet = new Set<Id>();
                pricingIdSet.add(availablePricingList.get(0).Id);     
                fsCore.DynamicQueryBuilder pricingSetupQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Pricing_Setup__c.getName())
                    .addFields()
                    .addWhereConditionWithBind(1,'Id','IN','pricingIdSet');
                
                List<fsCore__Pricing_Setup__c> pricingSetupList = (List<fsCore__Pricing_Setup__c>)Database.query(pricingSetupQuery.getQueryString());
                
                fsCore.PricingOfferGenerator poGen= new fsCore.PricingOfferGenerator(application, pricingSetupList[0]);
                poGen.setDefaultInputParameters();   
                fsCore.PricingOfferInputObject poInputObj = new fsCore.PricingOfferInputObject();
                
                poInputObj.setBranchCode(application.fsCore__Branch_Code_Formula__c);
                
                //DEFAULTING OF THE BOOLEAN VALUES
                if (offerRequest.Hard_Pull_Pricing_Offer == null){
                    offerRequest.Hard_Pull_Pricing_Offer = false;
                }
                if (offerRequest.include_origination_fee == null){
                    offerRequest.include_origination_fee  = false;
                }
                if (offerRequest.origination_fee_in_percent == null){
                    offerRequest.origination_fee_in_percent  = false;
                }            
                if (offerRequest.model_payment_amount == null){
                    offerRequest.model_payment_amount  = 0;
                }
                    
                Decimal financedAmount = offerRequest.Approved_amount;
                Decimal originationFee = offerRequest.origination_fee;
                if (originationFee != null && originationFee > 0){
                    if (offerRequest.include_origination_fee){
                        if (offerRequest.origination_fee_in_percent){
                            originationFee = (financedAmount * offerRequest.origination_fee)/100;
                            financedAmount = financedAmount - originationFee;
                        }else{
                            financedAmount = financedAmount - originationFee;
                        }
                    }else{
                        if (offerRequest.origination_fee_in_percent){
                            originationFee = (financedAmount * offerRequest.origination_fee)/100;
                        }
                    }
                }
                poInputObj.financedAmount = financedAmount;
                poInputObj.prepaidfee = originationFee;
                poInputObj.financeFee = 0;
                poInputObj.rate = offerRequest.rate;
                poInputObj.numberOfPayments = offerRequest.number_of_payments;
                poInputObj.paymentCycle = application.fsCore__Requested_Payment_Cycle__c;
                poInputObj.contractStartDate = offerRequest.start_date;
                poInputObj.firstPaymentDate = offerRequest.payment_start_date;
               
                
                poGen.setInputParameters(poInputObj);
                poGen.generateOffer();
                
                poGen.saveOffer();
                offer = poGen.getPricingOffer();
                
                if (offerRequest.auto_accept_Offer && !offerRequest.Hard_Pull_Pricing_Offer){
                    poGen.acceptOffer();
                    changeApplicationStatus(application.id, false, offerRequest.model_soft_pull_score);
                    //call
                }
                
                updatePricingOfferAttributes(offer.Id,offerRequest);
                if (offerRequest.apl_credit_score_factors != null){
                    updateCreditScoreFactors(application.id,offerRequest.apl_credit_score_factors);
                }
                if (offerRequest.coapl_credit_score_factors != null){
                    updateCreditScoreFactors(application.id,offerRequest.coapl_credit_score_factors);
                }
                
                poGen.calculateAPR();
                
                //SUP-280
                //StratFS WANT THE RESPONSE TO ALERT IF THERE IS MISMATCH BETWEEN INPUT AND OUTPUT PAYMENT AMOUNT
                RESTPricingOffer.Response offerResponse = new RESTPricingOffer.Response();
                
                offerResponse.loan_amount = offer.fsCore__Loan_Amount__c;
                offerResponse.financed_amount = offer.fsCore__Financed_Amount__c;
                offerResponse.rate = offer.fsCore__Rate__c;
                offerResponse.number_of_payments = offer.fsCore__Number_Of_Payments__c;
                offerResponse.payment_cycle = offer.fsCore__Payment_Cycle__c;
                offerResponse.payment_amount = offer.fsCore__Payment_Amount__c;    
                offerResponse.final_payment_amount = offer.fsCore__Final_Payment_Amount__c;    
                offerResponse.annual_percent_rate = offer.fsCore__Annual_Percent_Rate__c;                
                offerResponse.mismatch_in_payment_amount = false;

                if (offerResponse.payment_amount != offerRequest.model_payment_amount){
                    offerResponse.mismatch_in_payment_amount = true;
                }

                //set application Id and name as Meta Attributes
                Map<String, String> metaAttributes = new Map<String, String>();
                metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(offer.Id));
                setResponseMetaAttribute(metaAttributes);
                setResponseRootElement('offer', offerResponse);                

                /*Map<String, String> metaAttributes = new Map<String, String>();
                metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(offer.Id));
                setResponseMetaAttribute(metaAttributes);*/
            }
            catch (Exception e){
                System.debug(loggingLevel.ERROR, 'Exception:--'+e);
                Database.rollback(sp);
                addError(e);
            }
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_CREATED));
    }
    
    private void handlePricingAccept(Id pOfferId){
        fsCore__Lending_Application_Pricing_Offer__c offer = [SELECT Id
                                                              , fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c
                                                              , fsCore__Lending_Application_Number__r.fsCore__Application_Status__c
                                                              , fsCore__Is_Accepted__c
                                                              , Is_Hard_Pull_Pricing_Offer__c
                                                              ,fsCore__Lending_Application_Number__c
                                                              FROM fsCore__Lending_Application_Pricing_Offer__c 
                                                              WHERE Id = :pOfferId];        
        Id applicationId = offer.fsCore__Lending_Application_Number__c;
        if (offer.fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c){
            addError(fsCore.RESTConstants.NOT_ALLOWED, 'Application is read only, cannot update pricing offer ' + pOfferId);
        }
        //SUP-409 added condition to check for the application status as well
        if (offer.fsCore__Is_Accepted__c && offer.fsCore__Lending_Application_Number__r.fsCore__Application_Status__c == 'Offer Accepted'){    
            addError(fsCore.RESTConstants.NOT_ALLOWED, 'Pricing Offer is already accepted, cannot accept ' + pOfferId);
        }
        if (offer.Is_Hard_Pull_Pricing_Offer__c){    
            addError(fsCore.RESTConstants.NOT_ALLOWED, 'Hard Pull Pricing Offer cannot be accepted ' + pOfferId);
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            
           String retMsg = fsCore.LendingApplicationPricingUtil.setPricingRecordType(pOfferId, fsCore.Constants.PRICING_REC_TYPE_ACCEPTED);
             System.debug(LoggingLevel.ERROR, retMsg);
            changeApplicationStatus(applicationId, true, -1); //'-1 is a Dummy value'
            //call
            offer = [SELECT Id, name, fsCore__Is_Accepted__c
                       FROM fsCore__Lending_Application_Pricing_Offer__c 
                     WHERE Id = :pOfferId];    
            System.debug(LoggingLevel.ERROR, offer.fsCore__Is_Accepted__c);
            
            Map<String, String> metaAttributes = new Map<String, String>();
            metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(offer.Id));
            metaAttributes.put(fsCore.RESTConstants.RECORD_NAME, offer.Name);
            metaAttributes.put('Accepted', String.valueOf(offer.fsCore__Is_Accepted__c));
            setResponseMetaAttribute(metaAttributes);            
            
        }
        catch (Exception e){
            System.Debug(loggingLevel.ERROR, 'Exception:--'+e);
            Database.rollback(sp);
            addError(e, pOfferId);
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_ACCEPTED));
    }
    //This changes the status of the Lending Application to Offer Accepted on the acceptance of Pricing Offer(SUP-277)
    //SUP-409 Added the flag pIsUpdateStatus to handle the status change on create and update of pricing offer
    //        If the offer is created with auto-accept as True, then the status should not be updated to Offer Accepted
    private static void changeApplicationStatus(id pAppId, Boolean pIsUpdateStatus, Decimal pModelSoftScore){
        try{
            fsCore__Lending_Application__c app = [Select id , Name , Loan_Type__c,fsCore__Application_Status__c,Model_Soft_Pull_Score__c from fsCore__Lending_Application__c where id =:pAppId];
            if(app.Loan_Type__c == 'VCL'){
                if (pIsUpdateStatus){
                    app.fsCore__Application_Status__c = 'Offer Accepted';
                }
                if (pModelSoftScore != null && pModelSoftScore >= 0){
                    app.Model_Soft_Pull_Score__c = pModelSoftScore;
                }
                update app;
            }
        }
        catch(Exception e){
            System.debug(LOGGINGLEVEL.ERROR ,  e.getMessage() + e.getStackTraceString());
        }
    }

    private static void updateCreditScoreFactors(id pAppId,List<String> pCreditScoreFactors){
        try{
            /*fsCore__Lending_Application__c application = [Select id 
                                                        , Name 
                                                        , credit_score_factors__c
                                                     from fsCore__Lending_Application__c
                                                    where id =:pAppId]; */

            List<fsCore__Lending_Application_Customer__c> applicants = [SELECT Id, Name
                                                                        , FICO_Score__c
                                                                        , Credit_Score_Factors__c
                                                                        , fsCore__Lending_Application_Number__c
                                                                        , fsCore__Customer_Type__c
                                                                        FROM fsCore__Lending_Application_Customer__c
                                                                        WHERE fsCore__Lending_Application_Number__c = :pAppId
                                                                        ORDER BY fsCore__Customer_Type__c];

            if (applicants.size() >0 ){
                if (pCreditScoreFactors != null && pCreditScoreFactors.size() > 0){
                    List<String> creditScoreFactors = new List<String>();
                    for (String creditScoreFactor : pCreditScoreFactors){
                        if (String.IsNotBlank(creditScoreFactor)){ creditScoreFactors.add(creditScoreFactor); }
                    }
                    applicants.get(0).Credit_Score_Factors__c = String.join(creditScoreFactors, fsCore.Constants.SEMI_COLON);
                }  
            }
            if (applicants.size() >1 ){
                if (pCreditScoreFactors != null && pCreditScoreFactors.size() > 0){
                    List<String> creditScoreFactors = new List<String>();
                    for (String creditScoreFactor : pCreditScoreFactors){
                        if (String.IsNotBlank(creditScoreFactor)){ creditScoreFactors.add(creditScoreFactor); }
                    }
                    applicants.get(1).Credit_Score_Factors__c = String.join(creditScoreFactors, fsCore.Constants.SEMI_COLON); 
                    
                }  
            }
            
           /* if (pCreditScoreFactors != null && pCreditScoreFactors.size() > 0){
                List<String> creditScoreFactors = new List<String>();
                for (String creditScoreFactor : pCreditScoreFactors){
                    if (String.IsNotBlank(creditScoreFactor)){ creditScoreFactors.add(creditScoreFactor); }
                }
                application.credit_score_factors__c = String.join(creditScoreFactors, fsCore.Constants.SEMI_COLON);
            } */                                                   


            update applicants;
        }
        catch(Exception e){
            System.debug(LOGGINGLEVEL.ERROR ,  e.getMessage() + e.getStackTraceString());
        }
    }   

    private static void updatePricingOfferAttributes(id pOfferId,RESTPricingOffer.Request pOfferRequest){
        try{
            fsCore__Lending_Application_Pricing_Offer__c pOffer = [Select id , Versara_Offer_ID__c
                                                                        , Is_Hard_Pull_Pricing_Offer__c 
                                                                        , Model_Payment_Amount__c
                                                                        , Model_Annual_Percent_Rate__c
                                                                        , Model_Soft_Pull_Score__c
                                                                        , Model_Hard_Pull_Score__c
                                                                        , Model_Hard_Decline_Reason__c
                                                                     from fsCore__Lending_Application_Pricing_Offer__c 
                                                                    where id =:pOfferId limit 1];
            
            pOffer.Is_Hard_Pull_Pricing_Offer__c = pOfferRequest.Hard_Pull_Pricing_Offer;
            pOffer.Model_Payment_Amount__c = pOfferRequest.model_payment_amount;
            pOffer.Model_Annual_Percent_Rate__c = pOfferRequest.model_annual_percent_rate;
            pOffer.Model_Soft_Pull_Score__c = pOfferRequest.model_soft_pull_score;
            pOffer.Model_Hard_Pull_Score__c = pOfferRequest.model_hard_pull_score;
            pOffer.Model_Hard_Decline_Reason__c = pOfferRequest.model_hard_decline_reason;
            pOffer.Versara_Offer_ID__c = pOfferRequest.versara_offer_id;

            update pOffer;
        }
        catch(Exception e){
            System.debug(LOGGINGLEVEL.ERROR ,  e.getMessage() + e.getStackTraceString());
        }
    }    
    
}