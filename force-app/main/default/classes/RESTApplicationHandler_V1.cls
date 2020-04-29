/*
* Class Name   - RESTApplicationHandler_V1
* Description  - Service Handler for Application REST Service
* Developer(s) - Financial Spectra DEV
*/
global with sharing class RESTApplicationHandler_V1 extends fsCore.RESTServiceHandlerBase{
    
    private static final String SUB_RESOURCE_DECLINE  = 'decline';
    private static final String SUB_RESOURCE_WITHDRAW = 'withdraw';
    private static final String SUB_RESOURCE_INVESTMENT = 'investments';
    private static final String SUB_RESOURCE_HARD_PULL_GRADE  = 'hard_pull_grade';
    private static final String SUB_RESOURCE_INVESTOR_LOAN_STATUS = 'investor_loan_status';
    private static final String SUB_RESOURCE_INVESTOR_APPLICATION_STATUS = 'investor_application_status';
    private static final String SUB_RESOURCE_APPLY_TEMPLATE = 'apply_template';
    
    private static final String CURRENCY_CODE = 'USD';
    private static final String RELATION_PRIMARY = 'Primary';
    private static final String RELATION_SECONDARY = 'Secondary';
    private static final String DEFAULT_VCL_PROCESSOR_NAME = 'RAM'; //VF-8
    
    
    global RESTApplicationHandler_V1(){
        super();
    }
    
    global override void getRecords(){
        if (!isResourceURIValid()){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Id applicationId;
        try{
            applicationId = Id.valueOf(requestInfo.resourceURLInfo.resourceIdentifier);
        }
        catch (Exception e){
            addError(e);
        }
        fsCore__Lending_Application__c application = fsCore.LendingApplicationUtil.getApplication(applicationId);
        if (application == null){
            addError(fsCore.RESTConstants.INVALID_PARAMETER, 'Invalid Application ID');
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        if (String.isNotBlank(requestInfo.resourceURLInfo.subResourceType) && requestInfo.resourceURLInfo.subResourceType.equalsIgnoreCase(SUB_RESOURCE_INVESTMENT)){
            List<fsCore__Lending_Application_Investment__c> existingInvestments = fsCore.LendingApplicationInvestmentUtil.getInvestments(applicationId);
            List<RESTInvestment.Response> investments = new List<RESTInvestment.Response>();
            for(fsCore__Lending_Application_Investment__c investmentRec : existingInvestments){
                investments.add(new RESTInvestment.Response(investmentRec));
            }
            
            //set application Id and name as Meta Attributes
            Map<String, String> metaAttributes = new Map<String, String>();
            metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(applicationId));
            setResponseMetaAttribute(metaAttributes);
            setResponseRootElement('investments', investments);
            setResponse(fsCore.RESTConstants.HTTP_OK);
        }
        if (String.isNotBlank(requestInfo.resourceURLInfo.subResourceType) && requestInfo.resourceURLInfo.subResourceType.equalsIgnoreCase(SUB_RESOURCE_INVESTOR_APPLICATION_STATUS)){
            System.debug(loggingLevel.ERROR, 'Request : ' + requestInfo);
            String returnStatus= getApplicationStatus(application);
            
            //set application Id and name as Meta Attributes
            Map<String, String> metaAttributes = new Map<String, String>();
            metaAttributes.put('id', String.valueOf(application.Id));
            metaAttributes.put('application_status', returnStatus);
            setResponseMetaAttribute(metaAttributes);
            setResponse(fsCore.RESTConstants.HTTP_OK);
        }    
        if (String.isNotBlank(requestInfo.resourceURLInfo.subResourceType) && requestInfo.resourceURLInfo.subResourceType.equalsIgnoreCase(SUB_RESOURCE_INVESTOR_LOAN_STATUS)){
            System.debug(loggingLevel.ERROR, 'Request : ' + requestInfo);
            List <fsServ__Lending_Contract__c>  contractList  = [SELECT Id
                                                                 , fsServ__Lending_Application_Number__c
                                                                 , fsServ__Is_Delinquent__c
                                                                 , fsServ__Current_Delinquency_Category__c
                                                                 , fsServ__Delinquent_Days__c
                                                                 , fsServ__Contract_Status__c
                                                                 FROM fsServ__Lending_Contract__c
                                                                 WHERE fsServ__Lending_Application_Number__c = :applicationId 
                                                                 LIMIT 1];
            System.debug(loggingLevel.ERROR, 'List Size:--'+ contractList.size());
            if (contractList.size()==0){
                String returnStatus= getApplicationStatus(application);
                //set application Id and name as Meta Attributes
                Map<String, String> metaAttributes = new Map<String, String>();
                metaAttributes.put('id', String.valueOf(application.Id));
                metaAttributes.put('loan_status', returnStatus);
                setResponseMetaAttribute(metaAttributes);
                setResponse(fsCore.RESTConstants.HTTP_OK);
            }else{
                fsServ__Lending_Contract__c contract = contractList[0];
                
                String returnContractStatus = '';
                if(contract.fsServ__Is_Delinquent__c){
                    if (contract.fsServ__Contract_Status__c =='Active'){
                        if(contract.fsServ__Delinquent_Days__c >= 1 && contract.fsServ__Delinquent_Days__c <= 15 ){
                            returnContractStatus = 'In Grace Period';
                        } else if(contract.fsServ__Delinquent_Days__c >= 16 && contract.fsServ__Delinquent_Days__c <= 30 ){
                            returnContractStatus ='Late 30' ;
                        } else if(contract.fsServ__Delinquent_Days__c >= 31 && contract.fsServ__Delinquent_Days__c <= 45 ){
                            returnContractStatus = 'Late 45';
                        } else if(contract.fsServ__Delinquent_Days__c >= 46 && contract.fsServ__Delinquent_Days__c <= 60 ){
                            returnContractStatus = 'Late 60';
                        } else if(contract.fsServ__Delinquent_Days__c >= 61 && contract.fsServ__Delinquent_Days__c <= 90 ){
                            returnContractStatus = 'Late 90';
                        } else if(contract.fsServ__Delinquent_Days__c >= 91 && contract.fsServ__Delinquent_Days__c <= 120 ){
                            returnContractStatus = 'Late 120';
                        } else if(contract.fsServ__Delinquent_Days__c >= 121){
                            returnContractStatus = 'Charged Off';
                        }
                    }else if (contract.fsServ__Contract_Status__c =='Charged Off'){
                        returnContractStatus = 'Charged Off';
                    }            
                }else{
                    if(contract.fsServ__Contract_Status__c =='Active'){
                        returnContractStatus = 'Current';
                    } else if(contract.fsServ__Contract_Status__c =='Charged Off'){
                        returnContractStatus ='Charged Off' ;
                    } else if(contract.fsServ__Contract_Status__c =='Closed'){ 
                        returnContractStatus = 'Fully Paid & Closed'    ;
                    } else if(contract.fsServ__Contract_Status__c =='Paid In Full'){ 
                        returnContractStatus = 'Fully Paid' ;
                        //} else if((string.isBlank(contract.fsServ__Current_Delinquency_Category__c))&&((contract.fsServ__Contract_Status__c =='Bankruptcy')){ 
                        //    returnContractStatus = 'Bankruptcy'   ;
                        //}else if((string.isBlank(contract.fsServ__Current_Delinquency_Category__c))&&(contract.fsServ__Contract_Status__c =='Deceased')){ 
                        //    returnContractStatus = 'Deceased' ;
                    } else if(contract.fsServ__Contract_Status__c =='Pending'){ 
                        returnContractStatus = 'Pending Activation' ;
                    } else if(contract.fsServ__Contract_Status__c =='Void'){ 
                        returnContractStatus = 'Void'   ;
                    }
                } 
                
                Map<String, String> metaAttributes = new Map<String, String>();
                metaAttributes.put('id', String.valueOf(application.Id));
                metaAttributes.put('loan_status',returnContractStatus);
                setResponseMetaAttribute(metaAttributes);
                setResponse(fsCore.RESTConstants.HTTP_OK);
            }
        }       
    }
    private string getApplicationStatus(fsCore__Lending_Application__c application){
        String returnStatus = '';
        if (application.Current_Stage_Code_Formula__c == 'PL_PRE_SCREEN'){
            if(application.fsCore__Application_Status__c == 'New'){
                returnStatus = 'Pre-Screening';
            } else if(application.fsCore__Application_Status__c == 'Offer Accepted'){
                returnStatus ='Pre-Screening' ;
            } else if(application.fsCore__Application_Status__c == 'Registration in Progress'){ 
                returnStatus =  'Pre-Screening' ;
            } else if(application.fsCore__Application_Status__c == 'Application In Progress'){ 
                returnStatus =  'Pre-Screening' ;
            } else if(application.fsCore__Application_Status__c == 'Withdrawn'){
                returnStatus ='Cancelled' ;
            } else if(application.fsCore__Application_Status__c == 'Declined'){ 
                returnStatus =  'Cancelled' ;
            }                 
        }else if(application.Current_Stage_Code_Formula__c == 'PL_DOC_PROCESSING'){
            if(application.fsCore__Application_Status__c == 'In progress'){
                returnStatus = 'Docs Processing';
            } else if(application.fsCore__Application_Status__c== 'Withdrawal Requested'){
                returnStatus ='Docs Processing' ;
            }else if(application.fsCore__Application_Status__c=='Withdrawn'){ 
                returnStatus =  'Cancelled' ;
            }else if(application.fsCore__Application_Status__c=='Pending Decline'){ 
                returnStatus =  'Docs Processing';
            }else if(application.fsCore__Application_Status__c =='Declined'){ 
                returnStatus =  'Cancelled' ;
            }
            
        }else if(application.Current_Stage_Code_Formula__c == 'PL_UND_WRT'){
            if(application.fsCore__Application_Status__c == 'Pending Submission'){
                returnStatus = 'Underwriter Final Review';
            }else if(application.fsCore__Application_Status__c == 'Lead Underwriter Approved'){
                returnStatus = 'Underwriter Final Review';
            } else if(application.fsCore__Application_Status__c== 'Pending Approval'){
                returnStatus ='Underwriter Final Review' ;
            }else if(application.fsCore__Application_Status__c =='Approved for Funding'){ 
                returnStatus =  'Underwriter Final Review'  ;
            }else if(application.fsCore__Application_Status__c=='QA Issue'){ 
                returnStatus =  'Underwriter Final Review'  ;
            }else if(application.fsCore__Application_Status__c=='Withdrawn'){ 
                returnStatus =  'Cancelled' ;
            }else if(application.fsCore__Application_Status__c=='Pending Decline'){ 
                returnStatus =  'Underwriter Final Review'  ;
            }else if(application.fsCore__Application_Status__c =='Declined'){ 
                returnStatus =  'Cancelled' ;
            }
            
        }else if(application.Current_Stage_Code_Formula__c == 'PL_FUNDING'){
            if(application.fsCore__Application_Status__c == 'Lead Underwriter Approved'){
                returnStatus = 'Funding';
            }else if(application.fsCore__Application_Status__c=='BAV In Progress'){ 
                returnStatus =  'Funding'  ;
            }else if(application.fsCore__Application_Status__c== 'BAV Completed'){
                returnStatus ='Funding' ;
            }else if(application.fsCore__Application_Status__c=='BAV Failed'){ 
                returnStatus =  'Funding'  ;
            }else if(application.fsCore__Application_Status__c =='Approved for Funding'){ 
                returnStatus =  'Funding'  ;
            }else if(application.fsCore__Application_Status__c=='Pending Decline'){ 
                returnStatus =  'Funding'  ;
            }else if(application.fsCore__Application_Status__c=='Declined'){ 
                returnStatus =  'Cancelled'  ;
            }else if(application.fsCore__Application_Status__c=='Funding In Progress'){ 
                returnStatus =  'Funding'    ;
            }else if(application.fsCore__Application_Status__c=='Funded'){ 
                returnStatus =  'Funded'    ;
            }else if(application.fsCore__Application_Status__c =='Withdrawn'){ 
                returnStatus =  'Funding' ;
            }
        }    
        return returnStatus;    
    }
    
    global override void deleteRecords(){
        invalidRequest();
    }
    @testVisible
    private String getSanitizedSSN(String pSSN){
        if (pSSN != null){
            return pSSN.replace('-','');
        }
        return pSSN;
    }
    
    /*
* Method to create a new application with a new applicant
*/
    global override void postRecords(){
        handleApplicationCreate();
    }
    
    /*
* Method to update Lending Application record
* This method also handles the application decline and withdraw request as sub resources
*/
    global override void putRecords(){
        if (!isResourceURIValid()){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Id applicationId;
        try{
            applicationId = Id.valueOf(requestInfo.resourceURLInfo.resourceIdentifier);
        }
        catch (Exception e){
            addError(e);
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        
        //response should be set in the respective methods
        if (String.isBlank(requestInfo.resourceURLInfo.subResourceType)){
            handleApplicationStatusChange(applicationId);
        }
        else if (String.isNotBlank(requestInfo.resourceURLInfo.subResourceType)){
            if (requestInfo.resourceURLInfo.subResourceType.equalsIgnoreCase(SUB_RESOURCE_WITHDRAW)){
                handleApplicationWithdraw(applicationId);
            }
            else if (requestInfo.resourceURLInfo.subResourceType.equalsIgnoreCase(SUB_RESOURCE_DECLINE)){
                handleApplicationDecline(applicationId);
            }
            else if (requestInfo.resourceURLInfo.subResourceType.equalsIgnoreCase(SUB_RESOURCE_HARD_PULL_GRADE)){
                handleHardPullScoreUpdate(applicationId);
            }
            
        }
    }
    @testVisible
    private void handleApplicationCreate(){
        RESTApplication.Request appRequest = new RESTApplication.Request();
        
        //parse request
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                appRequest = (RESTApplication.Request)JSON.deserialize(requestInfo.requestBodyJSON, RESTApplication.Request.class);
            }
            catch(Exception e){
                appRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        //validate request
        fsCore__Product_Setup__c product;
        fsCore__Branch_Setup__c branch;
        
        System.debug(loggingLevel.ERROR, 'Product:--'+ RESTServiceUtility.getProduct(appRequest.product_code));
        
        if (!hasError && appRequest != null){
            //validate and set product details
            if (String.isBlank(appRequest.product_code)){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Product code is blank');
            }
            else {
                System.debug(loggingLevel.ERROR, 'appRequest.product_code:--'+ appRequest.product_code  );
                product = RESTServiceUtility.getProduct(appRequest.product_code);
                if (product == null){
                    addError(fsCore.RESTConstants.NOT_FOUND, 'Unable to find a product with code ' + appRequest.product_code);
                }
            }
            
            //validate and set branch details
            Map<String, String> defaultBranchMap = RESTServiceUtility.getDefaultBranchInfo();
            System.debug(loggingLevel.ERROR, 'DefaultBranchMap:--'+ RESTServiceUtility.getDefaultBranchInfo());
            
            if (!defaultBranchMap.containsKey(fsCore.UserBranchUtil.BRANCH_KEY_CODE)){
                addError(fsCore.RESTConstants.NOT_FOUND, 'Unable to find default branch to create the application');
            } 
            else {
                branch = RESTServiceUtility.getBranch(defaultBranchMap.get(fsCore.UserBranchUtil.BRANCH_KEY_CODE));
                if (branch == null){
                    addError(fsCore.RESTConstants.NOT_FOUND, 'Unable to find a branch with code ' + defaultBranchMap.get(fsCore.UserBranchUtil.BRANCH_KEY_CODE));
                }
            } 
            
            //there should be at least 1 applicant to create the application
            if (appRequest.applicants == null || (appRequest.applicants != null && appRequest.applicants.size() == 0)){
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Cannot create an application without an applicant');
            }
            
            //validate relationships
            if (appRequest.applicants != null && appRequest.applicants.size() > 0){
                Boolean hasPrimaryApplicant = false;
                Integer primaryApplicantCount = 0;
                
                for (RESTApplicant.Request appl : appRequest.applicants){
                    if (String.IsBlank(appl.relationship)){
                        addError(fsCore.RESTConstants.INVALID_REQUEST, 'Relationship cannot be blank for the applicant');
                    }
                    else if (appl.relationship != RELATION_PRIMARY && appl.relationship != RELATION_SECONDARY){
                        addError(fsCore.RESTConstants.INVALID_REQUEST, 'Relationship value is not valid : ' + appl.relationship);
                    }
                    
                    if (String.IsNotBlank(appl.relationship) && appl.relationship == RELATION_PRIMARY){
                        hasPrimaryApplicant = true;
                        primaryApplicantCount += 1;
                    }
                    
                    if (String.IsNotBlank(appl.social_security_number)){
                        if (getSanitizedSSN(appl.social_security_number).length() <> 9){
                            System.debug(loggingLevel.ERROR, '-- Invalid SSN Length');
                            addError(fsCore.RESTConstants.INVALID_REQUEST, 'Invalid Input Social Security Number- Length' + getSanitizedSSN(appl.social_security_number).length());                
                        }
                    }
                    if (String.IsNotBlank(appl.transunion_ssn)){
                        if (getSanitizedSSN(appl.transunion_ssn).length() <> 9){
                            System.debug(loggingLevel.ERROR, '-- Invalid SSN Length');
                            addError(fsCore.RESTConstants.INVALID_REQUEST, 'Invalid Input Transunion SSN- Length' + getSanitizedSSN(appl.transunion_ssn).length());                
                            
                        }
                    }                    
                    
                }
                if (!hasPrimaryApplicant){
                    addError(fsCore.RESTConstants.INVALID_REQUEST, 'Cannot create an application without a primary applicant.');
                }
                if (primaryApplicantCount >1 ){
                    addError(fsCore.RESTConstants.INVALID_REQUEST, 'Cannot create an application with more than one primary applicant.');
                }
            }
            
            //add more validations here
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            
            return;  
            
        }
        
        //
        //create applicant and application 
        Map<String, Id> paymentProcessorMap = new Map<String, Id>();
        
        for (nu_dse__Processor__c processor: [SELECT Id,name FROM nu_dse__Processor__c]){
            paymentProcessorMap.put(processor.name,processor.Id);
        }
        
        Savepoint sp = Database.setSavepoint();
        if (!hasError){
            try{
                //create accounts for applicants
                Map<String, List<ApplicantAccountObject>> relationToApplicantsMap = getApplicantAccountObjects(appRequest);
                List<Account> accountsForInsert = new List<Account>();
                List<Account> accountsForUpdate = new List<Account>();
                
                for(String relation : relationToApplicantsMap.keySet()){
                    for(ApplicantAccountObject aplAcc: relationToApplicantsMap.get(relation)){
                        
                        aplAcc.account.Processor__c = paymentProcessorMap.get(DEFAULT_VCL_PROCESSOR_NAME); //VF-8
                        
                        if (aplAcc.account.Id == null){
                            accountsForInsert.add(aplAcc.account);
                        } else {
                            accountsForUpdate.add(aplAcc.account);
                        }
                    }
                }
                
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true; //allow save even if the record is identified as duplicate by the duplicate rule
                dml.OptAllOrNone = false;
                
                if (accountsForInsert.size() > 0){
                    Database.insert(accountsForInsert, dml);
                    System.debug(loggingLevel.Error, 'New Accounts :--'+accountsForInsert);
                }
                if (accountsForUpdate.size() > 0){
                    Database.update(accountsForUpdate, dml);
                    System.debug(loggingLevel.Error, 'Existing Accounts :--'+accountsForUpdate);
                }
                
                //create application
                fsCore__Lending_Application__c application = getNewApplication(appRequest, branch, product, relationToApplicantsMap);
                //SUP-545
                application.Payment_Processor_Name__c = 'RAM';
                Database.insert(application);
                System.debug(loggingLevel.ERROR, 'Application:--'+application);
                System.debug(loggingLevel.ERROR, 'LoanType:--'+application.Loan_Type__c);
                
                //create applicant records
                List<fsCore__Lending_Application_Customer__c> applicants = getNewApplicants(application, relationToApplicantsMap);
                Database.insert(applicants);
                System.debug(loggingLevel.ERROR, 'applicants:--'+applicants);
                
                List<fsCore__Lending_Application_Itemization__c> allItemizations = getItemizations(application, product, appRequest);
                System.debug(loggingLevel.ERROR, 'allItemizations:--'+allItemizations);                
                Database.insert(allItemizations);
                
                application = fsCore.LendingApplicationUtil.getApplication(application.Id);
                applicants = fsCore.LendingApplicationCustomerUtil.getCustomers(application.Id);
                
                RESTApplication.Response appResponse = new RESTApplication.Response();
                appResponse.application_id = application.Id;
                appResponse.application_number = application.Name;
                appResponse.reference_number = application.fsCore__External_System_Reference_Number__c;
                appResponse.applicants = new List<RESTApplicant.Response>();
                for(fsCore__Lending_Application_Customer__c appl : applicants){
                    RESTApplicant.Response applct = new RESTApplicant.Response();
                    applct.applicant_id = appl.Id;
                    applct.applicant_account_id = appl.fsCore__Account_Name__c;
                    applct.applicant_name = appl.fsCore__Customer_Name_Formula__c;
                    applct.relationship = appl.fsCore__Customer_Type__c;
                    appResponse.applicants.add(applct);
                }
                
                //set application Id and name as Meta Attributes
                Map<String, String> metaAttributes = new Map<String, String>();
                metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(application.Id));
                metaAttributes.put(fsCore.RESTConstants.RECORD_NAME, String.valueOf(application.Name));
                setResponseMetaAttribute(metaAttributes);
                setResponseRootElement('application', appResponse);
            }
            catch (Exception e){
                System.debug(loggingLevel.ERROR, 'Exception:--'+e);
                Database.rollback(sp);
                addError(e);
            }
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_CREATED));
    }
    
    private Map<String, List<ApplicantAccountObject>> getApplicantAccountObjects(RESTApplication.Request pAppRequest){
        Map<String, List<ApplicantAccountObject>> relationToApplicantsMap = new Map<String, List<ApplicantAccountObject>>();
        
        //PLEASE CONSIDER THE FOLLOWING
        //1. We cannot run a single query to fetch the matching records because 
        //   there are multiple fields to be compared for multiple records.
        //2. We need to limit the number of duplicate identifiers (fields) to 3 or 4
        //   so that we have to execute the query on account only 3-or-4 queries to
        //   fetch the existing records.
        //3. We need to limit the number of records that can be fetched for an identifier
        //   to avoid record limit exception (using 1000 as limit now).
        //4. We need to choose only those fields that can be indexed in case of a 
        //   performance issue.
        //5. As per the client portal documentation, phone number is never entered on
        //   the UI so why to use it for duplicate matching?
        //6. If a matching account is found, do we need to copy the latest values to
        //   the fields or retain as it is?
        //7. Running a query using SSN is not recommended because it is an encrypted 
        //   field and encrypted fields cannot be indexed. This query can cause 
        //   performance issue in production (if not now, then in future).
        
        //prepare sets for the duplicate identifiers
        Set<String> emailSet = new Set<String>();
        Set<Date> dobSet = new Set<Date>();
        for (RESTApplicant.Request appl : pAppRequest.applicants){
            if (String.isNotBlank(appl.email)){
                emailSet.add(appl.email);
            }
            if (appl.date_of_birth != null){
                dobSet.add(appl.date_of_birth);
            }
        }        
        
        Map<String, Account> emailToAccountMap = getAccountsByEmail(emailSet);  
        Map<Date, List<Account>> dobToAccountsMap = getAccountsByDOB(dobSet);  
        
        for (RESTApplicant.Request appl : pAppRequest.applicants){
            ApplicantAccountObject applAccount = new ApplicantAccountObject();
            Account acct;
            Boolean createNewAccount = true;
            
            //check for a matching account by email 
            if (createNewAccount && String.isNotBlank(appl.email) && emailToAccountMap.containsKey(appl.email)){
                System.debug(loggingLevel.Error, 'Inside If');
                Account emailAccount = emailToAccountMap.get(appl.email);
                if (isAccountMatching(emailAccount, appl) && emailAccount.PersonBirthdate == appl.date_of_birth){
                    System.debug(loggingLevel.ERROR, 'Matched');
                    acct = emailAccount;
                    createNewAccount = false;
                }
            }
            
            //if now found, check for a matching account by date-of-birth 
            if (createNewAccount && appl.date_of_birth != null && dobToAccountsMap.containsKey(appl.date_of_birth)){
                for (Account dobAccount : dobToAccountsMap.get(appl.date_of_birth)){
                    if (isAccountMatching(dobAccount, appl) && dobAccount.PersonEmail == appl.email){
                        acct = dobAccount;
                        createNewAccount = false;
                        break;
                    }
                }
            }
            
            //if not found, create new account
            if (createNewAccount){
                acct = new Account();
                acct.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId();
                acct.FirstName = appl.first_name;
                acct.LastName = appl.last_name;
                acct.PersonBirthdate = appl.date_of_birth;
                acct.PersonEmail = appl.email;
                acct.Phone = appl.phone_number;
                acct.PersonMobilePhone = appl.mobile_number;
                acct.PersonMailingStreet = appl.mailing_street;
                acct.PersonMailingCity = appl.mailing_city;
                acct.PersonMailingState = getState(appl.mailing_state);
                acct.PersonMailingCountry = appl.mailing_country;
                acct.PersonMailingPostalCode = appl.mailing_postal_code;
                acct.PersonOtherStreet = appl.home_street;
                acct.PersonOtherCity = appl.home_city;
                acct.PersonOtherState = getState(appl.home_state);
                acct.PersonOtherCountry = appl.home_country;
                acct.PersonOtherPostalCode = appl.home_postal_code;            
                acct.fsCore__National_Identification_Number__pc = getSanitizedSSN(appl.social_security_number);
                acct.SSN__c = acct.fsCore__National_Identification_Number__pc; //VF-7
                acct.nu_dse__SSN__c = acct.fsCore__National_Identification_Number__pc; //VF-7
                acct.Transunion_SSN__c = getSanitizedSSN(appl.transunion_ssn);
            }
            
            applAccount.account = acct;
            
            fsCore__Lending_Application_Customer__c  appApplicant = new fsCore__Lending_Application_Customer__c();            
            appApplicant.Velocify_Stated_Income__c = appl.annual_stated_Income;
            applAccount.applicant = appApplicant;
            
            List<ApplicantAccountObject> ApplicantAccountObjectList = new List<ApplicantAccountObject>();
            
            if (relationToApplicantsMap.containsKey(appl.relationship)){
                ApplicantAccountObjectList = relationToApplicantsMap.get(appl.relationship);
            }
            
            ApplicantAccountObjectList.add(applAccount);
            relationToApplicantsMap.put(appl.relationship, ApplicantAccountObjectList);
        }
        
        return relationToApplicantsMap;
    }
    
    private Map<String, Account> getAccountsByEmail(Set<String> pEmails){
        Map<String, Account> emailToAccountMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, FirstName
                            , LastName
                            , PersonBirthdate
                            , PersonEmail
                            , PersonMobilePhone
                            , PersonMailingStreet
                            , PersonMailingCity
                            , PersonMailingState
                            , PersonMailingCountry
                            , PersonMailingPostalCode
                            , PersonOtherStreet
                            , PersonOtherCity
                            , PersonOtherState
                            , PersonOtherCountry
                            , PersonOtherPostalCode
                            , PersonContactId
                            , fsCore__National_Identification_Number__pc
                            FROM Account 
                            WHERE PersonEmail != null 
                            AND PersonEmail IN :pEmails LIMIT 1000]){
                                emailToAccountMap.put(acc.PersonEmail, acc);
                            }
        System.debug(loggingLevel.Error , emailToAccountMap);
        return emailToAccountMap;
    }
    
    private Map<Date, List<Account>> getAccountsByDOB(Set<Date> pBirthDates){
        Map<Date, List<Account>> dobToAccountsMap = new Map<Date, List<Account>>();
        for (Account acc : [SELECT Id, FirstName
                            , LastName
                            , PersonBirthdate
                            , PersonEmail
                            , PersonMobilePhone
                            , PersonMailingStreet
                            , PersonMailingCity
                            , PersonMailingState
                            , PersonMailingCountry
                            , PersonMailingPostalCode
                            , PersonOtherStreet
                            , PersonOtherCity
                            , PersonOtherState
                            , PersonOtherCountry
                            , PersonOtherPostalCode 
                            , PersonContactId
                            , fsCore__National_Identification_Number__pc
                            FROM Account 
                            WHERE PersonBirthdate != null 
                            AND PersonBirthdate IN :pBirthDates
                            LIMIT 1000]){
                                List<Account> accounts = new List<Account>();
                                if (dobToAccountsMap.containsKey(acc.PersonBirthdate)){
                                    accounts = dobToAccountsMap.get(acc.PersonBirthdate);
                                }
                                accounts.add(acc);
                                dobToAccountsMap.put(acc.PersonBirthdate, accounts);
                            }
        return dobToAccountsMap;
    }
    @testVisible
    private Boolean isAccountMatching(Account pAccount, RESTApplicant.Request pApplicant){
        Boolean isMatching = false;
        if (pAccount.FirstName == pApplicant.first_name
            && pAccount.LastName == pApplicant.last_name
            && pAccount.PersonMobilePhone == pApplicant.mobile_number
            && pAccount.PersonMailingStreet == pApplicant.mailing_street
            && pAccount.PersonMailingCity == pApplicant.mailing_city
            && pAccount.PersonMailingState == getState(pApplicant.mailing_state)
            && pAccount.PersonMailingCountry == pApplicant.mailing_country
            && pAccount.PersonMailingPostalCode == pApplicant.mailing_postal_code
            && pAccount.fsCore__National_Identification_Number__pc == getSanitizedSSN(pApplicant.social_security_number)){
                isMatching = true;
            }
        return isMatching;
    }
    
    private String getState(String pStateName){
        String stateName = pStateName;
        if ((pStateName != null ) && (pStateName.length() == 2)){
            stateName = SFSUtil.getStateName(pStateName.toUpperCase());
        }
        return stateName;
        
    }
    
    private fsCore__Lending_Application__c getNewApplication(RESTApplication.Request pAppRequest
                                                             , fsCore__Branch_Setup__c pBranch
                                                             , fsCore__Product_Setup__c pProduct
                                                             , Map<String, List<ApplicantAccountObject>> pRelationToAccountsMap){
                                                                 fsCore__Lending_Application__c application = new fsCore__Lending_Application__c();
                                                                 application.fsCore__External_System_Reference_Number__c = pAppRequest.reference_number;
                                                                 application.fsCore__Branch_Name__c = pBranch.Id; //set default branch
                                                                 application.fsCore__Company_Name__c = pBranch.fsCore__Company_Name__c;
                                                                 application.fsCore__Application_Date__c = (pAppRequest.application_date != null ? pAppRequest.application_date : pBranch.fsCore__Business_Date__c);
                                                                 application.Loan_Type__c= pProduct.fsCore__Product_Code__c;
                                                                 application.velocify_id__c = pAppRequest.velocify_id;
                                                                 
                                                                 application.fsCore__Country__c= 'United States';
                                                                 if (pRelationToAccountsMap.get(RELATION_PRIMARY) != null){
                                                                     application.fsCore__State__c= pRelationToAccountsMap.get(RELATION_PRIMARY)[0].account.PersonOtherState;
                                                                 }
                                                                 
                                                                 fsCore.LendingApplicationUtil.copyProductToApplication(pProduct, application);
                                                                 
                                                                 //Only if the payment cycle is flexible use it from the payload
                                                                 //Otherwise it will be populated from the product
                                                                 if (application.fsCore__Is_Payment_Cycle_Flexible__c){
                                                                     application.fsCore__Payment_Cycle__c = pAppRequest.requested_payment_cycle;
                                                                 }
                                                                 
                                                                 application.fsCore__Requested_Number_Of_Payments__c = pAppRequest.requested_loan_term;
                                                                 application.fsCore__Requested_Payment_Cycle__c = pAppRequest.requested_payment_cycle;
                                                                 application.fsCore__Purpose__c = pAppRequest.loan_purpose;
                                                                 
                                                                 return application;
                                                             }
    
    private List<fsCore__Lending_Application_Customer__c> getNewApplicants(fsCore__Lending_Application__c pApp
                                                                           , Map<String, List<ApplicantAccountObject>> pRelationToAccountsMap){
                                                                               Map<String, Schema.RecordTypeInfo> applicantRecTypeMap = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByDeveloperName();
                                                                               List<fsCore__Lending_Application_Customer__c> applicants = new List<fsCore__Lending_Application_Customer__c>();
                                                                               System.debug(LoggingLevel.ERROR,pRelationToAccountsMap);
                                                                               System.debug(LoggingLevel.ERROR,applicantRecTypeMap);
                                                                               
                                                                               for (String relation : pRelationToAccountsMap.keySet()){
                                                                                   for(ApplicantAccountObject acct : pRelationToAccountsMap.get(relation)){
                                                                                       fsCore__Lending_Application_Customer__c applicant = new fsCore__Lending_Application_Customer__c();
                                                                                       if (relation == RELATION_PRIMARY && applicantRecTypeMap.containsKey('Primary')){
                                                                                           applicant.RecordTypeID = applicantRecTypeMap.get('Primary').getRecordTypeId();
                                                                                           System.debug(LoggingLevel.ERROR,'Primary');
                                                                                       }
                                                                                       else if (applicantRecTypeMap.containsKey('Other')){
                                                                                           applicant.RecordTypeID = applicantRecTypeMap.get('Other').getRecordTypeId();
                                                                                           System.debug(LoggingLevel.ERROR,'Other');
                                                                                       }
                                                                                       applicant.fsCore__Lending_Application_Number__c = pApp.Id;
                                                                                       applicant.fsCore__Account_Name__c = acct.account.Id;
                                                                                       applicant.fsCore__Customer_Type__c = relation;
                                                                                       applicant.Velocify_Stated_Income__c = acct.applicant.Velocify_Stated_Income__c;
                                                                                       // applicant.fsCore__Contact_Name__c = acct.account.PersonContactId;
                                                                                       System.debug(LoggingLevel.ERROR,'Contact' +acct.account.PersonContactId);
                                                                                       applicants.add(applicant);
                                                                                   }
                                                                               }
                                                                               System.debug(LoggingLevel.ERROR,'applicants' +applicants);
                                                                               return applicants;
                                                                           }
    
    private List<fsCore__Lending_Application_Itemization__c> getItemizations(fsCore__Lending_Application__c pApp, fsCore__Product_Setup__c pProduct, RESTApplication.Request pAppRequest){
        System.Debug(loggingLevel.Error,'pProduct.id:--'+pProduct.id);
        
        List<fsCore__Product_Itemization_Setup__c> prodItemizations = fsCore.ProductUtil.getProductItemizations(pProduct.Id);
        System.Debug(loggingLevel.Error,'prodItemizations:--'+prodItemizations);
        
        List<fsCore__Lending_Application_Itemization__c> appItemizations = new List<fsCore__Lending_Application_Itemization__c>();
        appItemizations = fsCore.LendingApplicationItemizationUtil.getItemizationFromProduct(pApp.Id, CURRENCY_CODE, prodItemizations, appItemizations);
        System.Debug(loggingLevel.Error,'appItemizations:--'+appItemizations);
        
        for (fsCore__Lending_Application_Itemization__c itmz : appItemizations){
            if (itmz.fsCore__Itemization_Family__c.equalsIgnoreCase(fsCore.Constants.ITMZ_FAMILY_FINANCED_AMOUNT) 
                && itmz.fsCore__Plus_Or_Minus__c == '+' && pAppRequest.requested_loan_amount > 0){
                    itmz.fsCore__Requested_Amount_Unsigned__c = pAppRequest.requested_loan_amount;
                    itmz.fsCore__Approved_Amount_Unsigned__c = 0;
                    itmz.fsCore__Actual_Amount_Unsigned__c = 0;
                    break;
                }else {
                    itmz.fsCore__Requested_Amount_Unsigned__c = 0;
                    itmz.fsCore__Approved_Amount_Unsigned__c = 0;
                    itmz.fsCore__Actual_Amount_Unsigned__c = 0;
                }
        }
        return appItemizations;        
    }
    
    private void handleApplicationStatusChange(Id pApplicationId){
        RESTApplication.StatusChangeRequest changeStatusRequest = new RESTApplication.StatusChangeRequest();
        
        //parse request
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                changeStatusRequest = (RESTApplication.StatusChangeRequest)JSON.deserialize(requestInfo.requestBodyJSON, RESTApplication.StatusChangeRequest.class);
            }
            catch(Exception e){
                changeStatusRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            fsCore__Lending_Application__c application = [SELECT Id, fsCore__Application_Status__c
                                                          FROM fsCore__Lending_Application__c 
                                                          WHERE Id = :pApplicationId];
            
            application.fsCore__Application_Status__c = changeStatusRequest.status;
            System.debug(loggingLevel.ERROR, '-- Updated Application : ' + application);
            Database.update(application);
        }
        catch (Exception e){
            System.Debug(loggingLevel.ERROR, 'Exception:--'+e);
            Database.rollback(sp);
            addError(e, pApplicationId);
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_ACCEPTED));
    }
    private void handleHardPullScoreUpdate(Id pApplicationId){
        RESTApplication.HardPullScoreUpdateRequest hardPullScoreUpdateRequest = new RESTApplication.HardPullScoreUpdateRequest();
        
        //parse request
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                hardPullScoreUpdateRequest = (RESTApplication.HardPullScoreUpdateRequest)JSON.deserialize(requestInfo.requestBodyJSON, RESTApplication.HardPullScoreUpdateRequest.class);
            }
            catch(Exception e){
                hardPullScoreUpdateRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            fsCore__Lending_Application__c application = [SELECT Id, Model_Hard_Pull_Score__c
                                                          FROM fsCore__Lending_Application__c 
                                                          WHERE Id = :pApplicationId];
            
            application.Model_Hard_Pull_Score__c = hardPullScoreUpdateRequest.model_hard_pull_score;
            System.debug(loggingLevel.ERROR, '-- Updated Application : ' + application);
            Database.update(application);
        }
        catch (Exception e){
            System.Debug(loggingLevel.ERROR, 'Exception:--'+e);
            Database.rollback(sp);
            addError(e, pApplicationId);
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_ACCEPTED));
    }
    
    private void handleApplicationWithdraw(Id pApplicationId){
        RESTApplication.WithdrawRequest withdrawRequest = new RESTApplication.WithdrawRequest();
        
        //parse request
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                withdrawRequest = (RESTApplication.WithdrawRequest)JSON.deserialize(requestInfo.requestBodyJSON, RESTApplication.WithdrawRequest.class);
            }
            catch(Exception e){
                withdrawRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            fsCore__Lending_Application__c application = [SELECT Id, Withdraw_Reason__c
                                                          , fsCore__Application_Status__c
                                                          , fsCore__Is_Application_Read_Only__c
                                                          FROM fsCore__Lending_Application__c 
                                                          WHERE Id = :pApplicationId];
            System.debug(loggingLevel.ERROR, 'application:--'+application);
            application.fsCore__Application_Status__c = 'Withdrawn';
            application.fsCore__Is_Application_Read_Only__c = true;
            application.Withdraw_Reason__c = withdrawRequest.withdraw_reason;
            System.debug(loggingLevel.ERROR, '-- Updated Application : ' + application);
            Database.update(application);
            
            //set application Id and name as Meta Attributes
            Map<String, String> metaAttributes = new Map<String, String>();
            metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(application.Id));
            metaAttributes.put('status', application.fsCore__Application_Status__c);
            setResponseMetaAttribute(metaAttributes);
        }
        catch (Exception e){
            System.debug(loggingLevel.ERROR,'Exception:--'+e);
            Database.rollback(sp);
            addError(e, pApplicationId);
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_ACCEPTED));
    }
    
    private void handleApplicationDecline(Id pApplicationId){
        RESTApplication.DeclineRequest declineRequest = new RESTApplication.DeclineRequest();
        
        //parse request
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                
                declineRequest = (RESTApplication.DeclineRequest)JSON.deserialize(requestInfo.requestBodyJSON, RESTApplication.DeclineRequest.class);
            }
            catch(Exception e){
                declineRequest = null;
                System.debug(loggingLevel.ERROR, '-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
                addError(fsCore.RESTConstants.INVALID_REQUEST, 'Unable to parse the request due to exception - ' + e.getMessage());
            }
        }
        
        if (hasError){
            setResponse(fsCore.RESTConstants.HTTP_BAD_REQUEST);
            return;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            fsCore__Lending_Application__c application = [SELECT Id, fsCore__Product_Name__c
                                                          , Previous_Status__c 
                                                          , fsCore__Application_Status__c 
                                                          , fsCore__Is_Application_Read_Only__c
                                                          , Rejection_Causes__c
                                                          , Rejection_Comments__c
                                                          , Credit_Bureau_Used__c
                                                          , Rejection_Reasons__c
                                                          , Internal_Rejection_Reasons__c 
                                                          , Internal_Rejection_Reason_Codes__c 
                                                          , External_Rejection_Reasons__c
                                                          , External_Rejection_Reason_Codes__c
                                                          , application_decline_date__c
                                                          //, credit_score_factors__c
                                                          , fsCore__credit_score__c
                                                          , fico_score__c
                                                          FROM fsCore__Lending_Application__c 
                                                          WHERE Id = :pApplicationId];
            
            //Assuming that there would be only 1 Co-Applicant
            List<fsCore__Lending_Application_Customer__c> applicants = [SELECT Id, Name
                                                                        , FICO_Score__c
                                                                        , Credit_Score_Factors__c
                                                                        , fsCore__Lending_Application_Number__c
                                                                        , fsCore__Customer_Type__c
                                                                        FROM fsCore__Lending_Application_Customer__c
                                                                        WHERE fsCore__Lending_Application_Number__c = :pApplicationId
                                                                        ORDER BY fsCore__Customer_Type__c];
            
            application.fsCore__Application_Status__c = 'Declined';
            application.fsCore__Is_Application_Read_Only__c = true;
            application.application_decline_date__c = Date.Today();
            application.Rejection_Comments__c = declineRequest.decline_comments;
            application.Rejection_Causes__c = declineRequest.decline_cause;
            //application.fsCore__credit_score__c = declineRequest.credit_score;
            //application.fico_score__c = String.ValueOf(declineRequest.credit_score);
            //if (application.Rejection_Cause__c == 'Credit Report'){
            application.Credit_Bureau_Used__c = declineRequest.credit_bureau_used;
            // }
            application.Rejection_Reasons__c = fsCore.Constants.BLANK_STRING;
            application.Internal_Rejection_Reasons__c = fsCore.Constants.BLANK_STRING;
            application.Internal_Rejection_Reason_Codes__c = fsCore.Constants.BLANK_STRING;
            application.External_Rejection_Reasons__c = fsCore.Constants.BLANK_STRING;
            application.External_Rejection_Reason_Codes__c = fsCore.Constants.BLANK_STRING;
            
            /*if (declineRequest.internal_reasons != null && declineRequest.internal_reasons.size() > 0){
List<String> internalReasonCodes = new List<String>();
List<String> internalReasons = new List<String>();
for (RESTApplication.Reason declineReason : declineRequest.internal_reasons){
if (String.IsNotBlank(declineReason.reason_code)){ internalReasonCodes.add(declineReason.reason_code); }
if (String.IsNotBlank(declineReason.reason_description)){ internalReasons.add(declineReason.reason_description); }
}

application.Internal_Rejection_Reasons__c = String.join(internalReasons, fsCore.Constants.SEMI_COLON);
application.Internal_Rejection_Reason_Codes__c = String.join(internalReasonCodes, fsCore.Constants.SEMI_COLON);
}*/
            
            if (declineRequest.external_reasons != null && declineRequest.external_reasons.size() > 0){
                List<String> externalReasons = new List<String>();
                for (String declineReason : declineRequest.external_reasons){
                    if (String.IsNotBlank(declineReason)){ externalReasons.add(declineReason); }
                }
                application.External_Rejection_Reasons__c = String.join(externalReasons, fsCore.Constants.SEMI_COLON);
                //application.External_Rejection_Reason_Codes__c = String.join(externalReasonCodes, fsCore.Constants.SEMI_COLON);
            }
            if (applicants.size() >0 ){
                if (declineRequest.apl_credit_score_factors != null && declineRequest.apl_credit_score_factors.size() > 0 && declineRequest.apl_credit_score != null){
                    List<String> creditScoreFactors = new List<String>();
                    for (String creditScoreFactor : declineRequest.apl_credit_score_factors){
                        if (String.IsNotBlank(creditScoreFactor)){ creditScoreFactors.add(creditScoreFactor); }
                    }
                    applicants.get(0).FICO_Score__c = String.valueOf(declineRequest.apl_credit_score);
                    applicants.get(0).Credit_Score_Factors__c = String.join(creditScoreFactors, fsCore.Constants.SEMI_COLON);
                }  
            }
            if (applicants.size() >1 ){
                if (declineRequest.coapl_credit_score_factors != null && declineRequest.coapl_credit_score_factors.size() > 0 && declineRequest.coapl_credit_score != null ){
                    List<String> creditScoreFactors = new List<String>();
                    for (String creditScoreFactor : declineRequest.coapl_credit_score_factors){
                        if (String.IsNotBlank(creditScoreFactor)){ creditScoreFactors.add(creditScoreFactor); }
                    }
                    
                    applicants.get(1).FICO_Score__c = String.valueOf(declineRequest.coapl_credit_score);
                    applicants.get(1).Credit_Score_Factors__c = String.join(creditScoreFactors, fsCore.Constants.SEMI_COLON); 
                    
                }  
            }
            
            /*if (String.IsNotBlank(application.Internal_Rejection_Reasons__c)){
//Set rich-text field with both internal and external reasons
application.Rejection_Reasons__c += '<p><strong>Internal Reason(s)</strong></p>';
application.Rejection_Reasons__c += '<ul>';
for (String inReason : application.Internal_Rejection_Reasons__c.split(fsCore.Constants.SEMI_COLON)){
application.Rejection_Reasons__c += ('<li>' + inReason + '</li>');
}
application.Rejection_Reasons__c += '</ul><br/>';
}*/
            if (String.IsNotBlank(application.External_Rejection_Reasons__c)){
                application.Rejection_Reasons__c += '<p><strong>External Reason(s)</strong></p>';
                application.Rejection_Reasons__c += '<ul>';
                for (String exReason : application.External_Rejection_Reasons__c.split(fsCore.Constants.SEMI_COLON)){
                    application.Rejection_Reasons__c += ('<li>' + exReason + '</li>');
                }
                application.Rejection_Reasons__c += '</ul>';
            }
            System.debug(loggingLevel.ERROR, '-- Updated Application : ' + application);
            Database.update(applicants);
            
            fsCore.LendingApplicationTriggerWrapper.getInstance().reset();
            
            Database.update(application);
            
            
            //set application Id and name as Meta Attributes
            Map<String, String> metaAttributes = new Map<String, String>();
            metaAttributes.put(fsCore.RESTConstants.RECORD_ID, String.valueOf(application.Id));
            metaAttributes.put('status', application.fsCore__Application_Status__c);
            setResponseMetaAttribute(metaAttributes);
        }
        catch (Exception e){
            Database.rollback(sp);
            addError(e, pApplicationId);
        }
        
        setResponse((hasError ? fsCore.RESTConstants.HTTP_INTERNAL_ERROR : fsCore.RESTConstants.HTTP_ACCEPTED));
    }
    
}