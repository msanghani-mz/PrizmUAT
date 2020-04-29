/*
 * Class Name   - RESTInvestmentHandler_V1
 * Description  - Service Handler for Investment REST Service
 * Developer(s) - Financial Spectra DEV
 */
global with sharing class RESTInvestmentHandler_V1 extends fsCore.RESTServiceHandlerBase{

    global RESTInvestmentHandler_V1(){
        super();
    }
    
    global override void getRecords(){
        invalidRequest();
    }

    /*
     * Method to create a new investment for an application
     */
    global override void postRecords(){
        System.debug(loggingLevel.ERROR, 'RESTInvestmentHandler_V1.postRecords(+)');
        RESTInvestment.Request investmentRequest = new RESTInvestment.Request();
        
        //parse request
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                investmentRequest = (RESTInvestment.Request)JSON.deserialize(requestInfo.requestBodyJSON, RESTInvestment.Request.class);
            }
            catch(Exception e){
                investmentRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        }
        
        System.debug(loggingLevel.ERROR, '-- request parsing successful? ' + hasError);
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }

        //validate request
        if (investmentRequest.application_id == null){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Application ID cannot be blank');
        }
        if (investmentRequest.investor_account_id == null && investmentRequest.investor_contact_id == null){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Please provide either an investor account ID or contact ID to create the record');
        }
        if (investmentRequest.contribution_percent == null && investmentRequest.contribution_amount == null){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Please provide either Contribution % or Contribution Amount');
        }
        if (investmentRequest.contribution_percent != null && investmentRequest.contribution_percent <= 0){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Contribution % must be greater than 0');
        }
        if (investmentRequest.contribution_amount != null && investmentRequest.contribution_amount <= 0){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Contribution Amount must be greater than 0');
        }
        System.debug(loggingLevel.ERROR, '-- request attributes validation successful? ' + hasError);
        
        //validate investor account
        Account investorAccount;
        if (investmentRequest.investor_account_id != null){
            try{
                investorAccount = [SELECT Id FROM Account WHERE Id = :investmentRequest.investor_account_id];
            }
            catch (Exception e){
                investorAccount = null;
            }
            if (investorAccount == null){
                addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Unable to find Account for the ID ' + String.valueOf(investmentRequest.investor_account_id));
            }
        }
        System.debug(loggingLevel.ERROR, '-- investor account validation successful? ' + hasError);
        
        //validate investor contact
        Contact investorContact;
        if (investmentRequest.investor_contact_id != null){
            try{
                investorContact = [SELECT Id FROM Contact WHERE Id = :investmentRequest.investor_contact_id];
            }
            catch (Exception e){
                investorContact = null;
            }
            if (investorContact == null){
                addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Unable to find Contact for the ID ' + String.valueOf(investmentRequest.investor_contact_id));
            }
        }
        System.debug(loggingLevel.ERROR, '-- investor contact validation successful? ' + hasError);
        
        //validate parent application
        fsCore__Lending_Application__c application = RESTServiceUtility.getApplicationInfo(investmentRequest.application_id);
        if (application == null){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Unable to find Lending Application for the ID ' + String.valueOf(investmentRequest.application_id));
        }
        else {
            validateParentApplication(application);
            if (application.Amount_Available_For_Investment__c <= 0){
                addError(fsCore.RESTConstants.NOT_ALLOWED, 'Amount available for investment on Lending Application is 0');
            }
            if (investmentRequest.contribution_amount != null && investmentRequest.contribution_amount > application.Amount_Available_For_Investment__c){
                addError(fsCore.RESTConstants.NOT_ALLOWED, 'Contribution Amount cannot be more than the available amount for investment');
            }
       
            //if investment already exists, check for duplicate investor account/contact
            if (application.fsCore__Number_Of_Investments__c > 0){
                List<fsCore__Lending_Application_Investment__c> existingInvestments = fsCore.LendingApplicationInvestmentUtil.getInvestments(application.Id);
                for(fsCore__Lending_Application_Investment__c investmentRec : existingInvestments){
                    if (investmentRequest.investor_account_id != null && investmentRec.fsCore__Account_Name__c != null && investmentRequest.investor_account_id == investmentRec.fsCore__Account_Name__c){
                        addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Investment for this Investor Account already exists');
                    }
                    if (investmentRequest.investor_contact_id != null && investmentRec.fsCore__Contact_Name__c != null && investmentRequest.investor_contact_id == investmentRec.fsCore__Contact_Name__c){
                        addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Investment for this Investor Contact already exists');
                    }
                }
            }
        }
        System.debug(loggingLevel.ERROR, '-- application validation successful? ' + hasError);
        
        //return if there is any validation error
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        //create investment record
        fsCore__Lending_Application_Investment__c investment = new fsCore__Lending_Application_Investment__c();
        investment.fsCore__Lending_Application_Number__c = application.Id;
        investment.fsCore__Account_Name__c = (investorAccount != null ? investorAccount.Id : null);
        investment.fsCore__Contact_Name__c = (investorContact != null ? investorContact.Id : null);
        if (investmentRequest.contribution_percent != null){
            investment.fsCore__Contribution_Percent__c = investmentRequest.contribution_percent;
            investment.fsCore__Contribution_Amount__c = (investmentRequest.contribution_percent/100) * application.Amount_Available_For_Investment__c;
        }
        else {
            investment.fsCore__Contribution_Amount__c = investmentRequest.contribution_amount;
            investment.fsCore__Contribution_Amount__c = (investmentRequest.contribution_amount/application.Amount_Available_For_Investment__c) * 100;
        }
        investment.fsCore__Rate__c = application.fsCore__Rate__c;
        investment.fsCore__Status__c = 'Approved';
        
        
        //insert investment
        fsCore.DMLResult insertResult 
            = fsCore.LendingApplicationInvestmentDMLWrapper.getInstance().insertData(new List<fsCore__Lending_Application_Investment__c>{investment});

        handleDMLResult(insertResult);

        //in case of success, set the response
        if (!hasError && investment.Id != null){
            investment = getInvestmentRecord(investment.Id);
            
            Map<String, String> metaAttributes = new Map<String, String>();
            metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(investment.Id));
            setResponseMetaAttribute(metaAttributes);
            
            RESTInvestment.Response response = new RESTInvestment.Response(investment);
            setResponseRootElement('investment', response);
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_CREATED));
        System.debug(loggingLevel.ERROR, 'RESTInvestmentHandler_V1.postRecords(-)');
    }
    
    global override void putRecords(){
        invalidRequest();
    }
    
    /*
     * Method to delete an investment record 
     */
    global override void deleteRecords(){
        System.debug(loggingLevel.ERROR, 'RESTInvestmentHandler_V1.deleteRecords(+)');
        fsCore__Lending_Application_Investment__c investment = getInvestmentRecordFromRequest();
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        fsCore__Lending_Application__c application = RESTServiceUtility.getApplicationInfo(investment.fsCore__Lending_Application_Number__c);
        validateParentApplication(application);
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        //delete investment
        fsCore.DMLResult deleteResult 
            = fsCore.LendingApplicationInvestmentDMLWrapper.getInstance().deleteData(new List<fsCore__Lending_Application_Investment__c>{investment});
        
        handleDMLResult(deleteResult);
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_OK));
        System.debug(loggingLevel.ERROR, 'RESTInvestmentHandler_V1.deleteRecords(-)');
    }

    private fsCore__Lending_Application_Investment__c getInvestmentRecordFromRequest(){
        fsCore__Lending_Application_Investment__c investment;
        
        if (isResourceURIValid()){
            try{
                Id investmentId = Id.valueOf(requestInfo.resourceURLInfo.resourceIdentifier);
                investment = getInvestmentRecord(investmentId);
                
                if (investment == null){
                    addError(fsCore.RESTConstants.NOT_FOUND, 'Unable to find an investment record for Id ' + String.valueOf(investmentId));
                }
            }
            catch (Exception e){
                addError(e);
            }
        }
        
        return investment;        
    }
 
    private fsCore__Lending_Application_Investment__c getInvestmentRecord(Id pInvestmentID){
        fsCore.DynamicQueryBuilder investmentQuery 
            = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application_Investment__c.getName())
                        .addFields()
                        .addWhereConditionWithBind(1,'Id', '=', 'pInvestmentID');  
        
        List<fsCore__Lending_Application_Investment__c> investments 
            = (List<fsCore__Lending_Application_Investment__c>)Database.query(investmentQuery.getQueryString());
        
        return (investments.size() == 1 ? investments.get(0) : null);
    }
 
    private void validateParentApplication(fsCore__Lending_Application__c pApplication){
        List<String> appValidationErrors = RESTServiceUtility.validateApplicationForAction(pApplication);
        if (appValidationErrors != null && appValidationErrors.size() > 0){
            for(String errMsg : appValidationErrors){
                addError(fsCore.RESTConstants.NOT_ALLOWED, errMsg);
            }
        }
    }
    
    private void handleDMLResult(fsCore.DMLResult pDMLResult){
        if (pDMLResult.hasErrors()){
            for(fsCore.ErrorObject errObj : pDMLResult.getErrorList()){
                addError(errObj.getErrorCode(), errObj.getErrorMessage(), errObj.getErrorRecordId(), errObj.getErrorStackTrace()); 
            }
        }
    }
}