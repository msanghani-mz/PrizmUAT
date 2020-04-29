/*
* Class Name   - RESTApplicantHandler_V1
* Description  - Service Handler for Applicant REST Service
* Developer(s) - Financial Spectra DEV
*/
global with sharing class RESTApplicantHandler_V1 extends fsCore.RESTServiceHandlerBase{
    
    global RESTApplicantHandler_V1(){
        super();
    }    
    
    global override void postRecords(){
        invalidRequest();
    }
    
    global override void getRecords(){
        invalidRequest();
    }
    
    global override void deleteRecords(){
        invalidRequest();
    }
    
    global override void putRecords(){
        if (!isResourceURIValid()){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Id applicantId;
        try{
            applicantId = Id.valueOf(requestInfo.resourceURLInfo.resourceIdentifier);
        }
        catch (Exception e){
            addError(e);
        }
        
        if (applicantId == null){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Applicant ID cannot be blank');
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        RESTApplicant.Request applicantRequest = new RESTApplicant.Request();
        
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                applicantRequest = (RESTApplicant.Request)JSON.deserialize(requestInfo.requestBodyJSON, RESTApplicant.Request.class);
            }
            catch(Exception e){
                applicantRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        } 
        
        if (String.IsNotBlank(applicantRequest.social_security_number)){
            if (getSanitizedSSN(applicantRequest.social_security_number).length() <> 9){
                System.debug(loggingLevel.ERROR, '-- Invalid SSN Length');
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Invalid Input Social Security Number- Length' + getSanitizedSSN(applicantRequest.social_security_number).length());                
            }
        }
        if (String.IsNotBlank(applicantRequest.transunion_ssn)){
            if (getSanitizedSSN(applicantRequest.transunion_ssn).length() <> 9){
                 System.debug(loggingLevel.ERROR, '-- Invalid SSN Length');
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Invalid Input Transunion SSN- Length' + getSanitizedSSN(applicantRequest.transunion_ssn).length());                
               
            }
        }
        if (applicantRequest.annual_stated_Income != null){
            if (applicantRequest.annual_stated_Income < 0){
                System.debug(loggingLevel.ERROR, '-- Invalid annual stated Income');
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Invalid Input annual stated income' + applicantRequest.annual_stated_Income);
            }
        }        
                
        
        System.debug(loggingLevel.ERROR, '-- request parsing successful? ' + hasError);
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        if(applicantId != null){
            updateAccount(applicantId,applicantRequest);
        }
        
        setResponse(hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_ACCEPTED);
        return;
    }
    private String getSanitizedSSN(String pSSN){
        if (pSSN != null){
            return pSSN.replace('-','');
        }
        return pSSN;
    }
    public void updateAccount(Id pApplicantId, RESTApplicant.Request pApplicantRequest){
        try{
            List<fsCore__Lending_Application_Customer__c> applicant 
                = [SELECT Id
                   , fsCore__Account_Name__c
                   , fsCore__Contact_Name__c
                   , fsCore__Account_Name__r.Id
                   , fsCore__Account_Name__r.RecordTypeID
                   , fsCore__Account_Name__r.FirstName
                   , fsCore__Account_Name__r.LastName
                   , fsCore__Account_Name__r.PersonBirthdate
                   , fsCore__Account_Name__r.PersonEmail
                   , fsCore__Account_Name__r.Phone
                   , fsCore__Account_Name__r.PersonMobilePhone
                   , fsCore__Account_Name__r.PersonMailingStreet
                   , fsCore__Account_Name__r.PersonMailingCity
                   , fsCore__Account_Name__r.PersonMailingState
                   , fsCore__Account_Name__r.PersonMailingCountry
                   , fsCore__Account_Name__r.PersonMailingPostalCode
                   , fsCore__Account_Name__r.PersonOtherStreet
                   , fsCore__Account_Name__r.PersonOtherCity
                   , fsCore__Account_Name__r.PersonOtherState
                   , fsCore__Account_Name__r.PersonOtherCountry
                   , fsCore__Account_Name__r.PersonOtherPostalCode          
                   , fsCore__Account_Name__r.fsCore__National_Identification_Number__pc        
                   , fsCore__Account_Name__r.Transunion_SSN__c
                   , Annual_Stated_Income__c
                   FROM fsCore__Lending_Application_Customer__c 
                   WHERE Id = :pApplicantId ];
            
            if(applicant.size() !=0 )
            {
                
                Account applicantAccount = applicant[0].fsCore__Account_Name__r;
                if (String.IsNotBlank(pApplicantRequest.social_security_number)){
                    applicantAccount.fsCore__National_Identification_Number__pc = getSanitizedSSN(pApplicantRequest.social_security_number);
                }
                if (String.IsNotBlank(pApplicantRequest.transunion_ssn)){
                    applicantAccount.Transunion_SSN__c = getSanitizedSSN(pApplicantRequest.transunion_ssn);
                }
                if (pApplicantRequest.annual_stated_Income != null){
                    applicant[0].Annual_Stated_Income__c = pApplicantRequest.annual_stated_Income;
                    update applicant;
                }
                
                update applicantAccount;
                
            }
            else{
                throw new CustomException();
            }
            
        }
        catch(CustomException ce){
            System.debug(loggingLevel.ERROR, '-- Error when updating account : ' + ce.getMessage() + ' - ' + ce.getStackTraceString());
            addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + 'Invalid Applicant Id'); 
            
        }
        catch(Exception e){
            System.debug(loggingLevel.ERROR, '-- Error when updating account : ' + e.getMessage() + ' - ' + e.getStackTraceString());
            addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());     
        }  
        
        
    }
    
    
}