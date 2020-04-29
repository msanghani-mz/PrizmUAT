/*
* Class Name   - VCLLobRequest
* Description  - Web Service to initiate Hard Pull for the Client 
* Developer(s) - Financial Spectra
*/
public with sharing class VCLLobRequest extends fsCore.WebServiceBase {
    private static final String CLASS_NAME = 'VCLLobRequest';
    //testing
    private static final String SERVICE_NAME = 'VCL_LOB_DECLINE_API';
    private Id mApplicationId;
    private HttpResponse mResponse;
    public VCLLobRequest(Id pApplicationId){
        super(SERVICE_NAME);
        this.mApplicationId = pApplicationId;
        setServiceAttributes();
    }
    
    private void setServiceAttributes(){
        System.debug(loggingLevel.ERROR, 'setServiceAttributes(+)');
        String orgType = getOrgType();
        
        /* set service instance or host URL */
        String settingsKey = 'VCL_LOB_SERVICE_LIVE';
        
        if (orgType == 'TEST'){
            settingsKey = 'VCL_LOB_SERVICE_TEST';
        }
        
        System.debug(loggingLevel.ERROR, 'Settings Key : ' + settingsKey);
        Integration_Settings__c wsSettings = Integration_Settings__c.getValues(settingsKey);        
        String instanceURL;
        if (Test.isRunningTest()){
          instanceURL = 'http://0.0.0.0:1122';
          setInstanceURL(instanceURL);
       }else{
        instanceURL = wsSettings.Folder_Endpoint__c;
        setInstanceURL(instanceURL);
        addHeader('Content-Type', 'application/json');
        addHeader('username',wsSettings.Client_id__c);
        addHeader('password',wsSettings.Client_Secret__c);
       }
          System.debug(loggingLevel.ERROR, 'setServiceAttributes(-)');
    }
    
    public override void buildRequest(){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'buildRequest(+)');
        System.debug(loggingLevel.ERROR, '-- Application ID : ' + mApplicationId);
        
        fsCore__Lending_Application__c app = [Select id 
                                              , Rejection_Causes__c
                                              , External_Rejection_Reasons__c
                                              , fsCore__Title__c
                                              , Created_date__c
                                              , fsCore__Requested_Financed_Amount__c
                                              from fsCore__Lending_Application__c
                                              where id =:mApplicationId];
        
        fsCore__Lending_Application_Customer__c applicant = [Select Id 
                                                             , fsCore__Account_Name__r.Phone
                                                             , fsCore__Customer_Name_Formula__c
                                                             , FICO_Score__c
                                                             , Credit_Score_Factors__c
                                                             , Home_Phone_Number_Formula__c
                                                             , Mailing_Street_Address_Formula__c
                                                             , Mailing_City_Formula__c
                                                             , Mailing_State_Formula__c
                                                             , Mailing_Zip__c
                                                             from fsCore__Lending_Application_Customer__c
                                                             where fsCore__Lending_Application_Number__c =: mApplicationId
                                                             and fsCore__Customer_Type__c = 'Primary'];
        
        LobSchema.LobRequest request = new LobSchema.LobRequest();
        request.application_date = String.valueOf(date.today());
        request.name = (String.isBlank(app.fsCore__Title__c)? '' :app.fsCore__Title__c);
        request.loanamount = (String.isBlank(string.valueOf(app.fsCore__Requested_Financed_Amount__c))? '' :string.valueOf(app.fsCore__Requested_Financed_Amount__c));
        request.phone = (String.isBlank(applicant.fsCore__Account_Name__r.Phone)? '' : applicant.fsCore__Account_Name__r.Phone);
        request.mailing_street = (String.isBlank(applicant.Mailing_Street_Address_Formula__c)? '' :applicant.Mailing_Street_Address_Formula__c);
        request.mailing_city = (String.isBlank(applicant.Mailing_City_Formula__c)? '' :applicant.Mailing_City_Formula__c);
        request.mailing_state = (String.isBlank(applicant.Mailing_State_Formula__c)? '' :applicant.Mailing_State_Formula__c);
        request.mailing_country= 'US';
        request.mailing_postal_code = (String.isBlank(applicant.Mailing_Zip__c)? '' :applicant.Mailing_Zip__c);
        request.credit_pulldate = (String.isBlank(string.valueOf(app.Created_date__c))? '' :string.valueOf(app.Created_date__c));
        request.fico = (String.isBlank(applicant.FICO_Score__c)? '' :applicant.FICO_Score__c);
        request.decline_cause = app.Rejection_Causes__c;
        system.debug('Decline Cause:'+ request.decline_cause);
        request.external_reasons = (String.isBlank(app.External_Rejection_Reasons__c)? '' :app.External_Rejection_Reasons__c);
        String crScore = applicant.Credit_Score_Factors__c ;
		string newCrScore ;
		List <string> newCrScoreList = new List<String>();
        if(String.isNotBlank(crScore))
        {
		List <string> crScrList = crScore.split(';');
		for ( String crScr : crScrList)
		{
			//crScr = crScr.replaceAll('Code'+crScr.substringBetween('Code',':')+':','');
			String[] crScrArray = crScr.split(':');
			crScr = (crScrArray.size() == 2) ? crScrArray[1] : crScrArray[0];
			newCrScoreList.add(crScr);
		}
        
		newCrScore = string.join(newCrScoreList,';');
        request.creditscore = (String.isBlank(newCrScore)? '' :newCrScore);
        }
        else
        {
          request.creditscore = (String.isBlank(applicant.Credit_Score_Factors__c)? '' :applicant.Credit_Score_Factors__c);  
        }
        String requestJSON = JSON.serialize(request);
        System.debug(loggingLevel.ERROR, '-- Request JSON : ' + requestJSON);
        setRequestBody(requestJSON);
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'buildRequest(-)');
    }
    
    public override void handleResponse(HttpResponse pResponse){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'handleResponse(+)');
        mResponse = pResponse;
        System.debug(loggingLevel.ERROR, '-- response : ' + mResponse.getBody());
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(mResponse.getBody());
        
        LobSchema.LobResponse res = new LobSchema.LobResponse();
        res.message = (responseMap.containsKey('message') ? String.valueOf(responseMap.get('message')) : '');
        res.error = (responseMap.containsKey('error') ? String.valueOf(responseMap.get('error')) : '');
        res.status = (responseMap.containsKey('status') ? (Boolean)responseMap.get('status') : false);
        system.debug('-- Response : '+res);
        system.debug('-- Response : '+res.status);
        system.debug('-- Response : '+res.error);
        system.debug('-- Response : '+res.message);
        
        fsCore__Lending_Application__c app = [Select id 
                                              , Lob_Response_Error__c
                                              , AAN_Sent_Date__c
                                              , Lob_Response_Message__c
                                              , Retry_Batch__c
                                              , Lob_Response_Status__c
                                              from fsCore__Lending_Application__c
                                              where id =:mApplicationId];
        
        system.debug(loggingLevel.ERROR, '-- response :' + res.message);
        
        if(mResponse.getStatusCode()== 200){
            
            app.Lob_Response_Status__c = res.status;
            app.Lob_Response_Message__c = res.message;
            if(res.status==true)
            {            
                app.Lob_Response_Error__c = '';
                app.Retry_Batch__c = false;
                if(res.message != 'No letter processed')
                {
                     app.AAN_Sent_Date__c = date.today(); 
                }
              
            }
            if(res.status==false)
            {            
                app.Lob_Response_Error__c = res.error;
                app.Retry_Batch__c = true;
            }
        }
        System.debug(loggingLevel.ERROR, '-- Status Code : ' + app.Lob_Response_Status__c);
        System.debug(loggingLevel.ERROR, '-- Status Code : ' + mResponse.getStatusCode());
        System.debug(loggingLevel.ERROR, '-- Status Code : ' + mResponse.getStatusCode());
        System.debug(loggingLevel.ERROR, '-- Response Body : ' + mResponse.getBody());
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'handleResponse(-)');
        database.upsert(app);
    }
    
    public HttpResponse getResponse(){
        if (Test.isRunningTest()){
            mResponse = new HttpResponse();
            mResponse.setStatusCode(fsCore.RESTConstants.HTTP_OK);
        }
        return mResponse;
    }
}