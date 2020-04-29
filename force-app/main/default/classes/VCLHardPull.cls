/*
 * Class Name   - VCLHardPull
 * Description  - Web Service to initiate Hard Pull for the Client 
 * Developer(s) - Financial Spectra
 */
public with sharing class VCLHardPull extends fsCore.WebServiceBase {
    private static final String CLASS_NAME = 'VCLHardPull';
    //testing
    private static final String SERVICE_NAME = 'VCL_HARD_PULL';
    private Id mApplicationId;
    private HttpResponse mResponse;
    
    public class HardPullRequest{
        public String PrizmId {get; set;}
        public Decimal VerifiedIncome {get; set;}
      
    }
    
    public VCLHardPull(Id pApplicationId){
        super(SERVICE_NAME);
        this.mApplicationId = pApplicationId;
        setServiceAttributes();
    }

    private void setServiceAttributes(){
        System.debug(loggingLevel.ERROR, 'setServiceAttributes(+)');
        String orgType = getOrgType();
        
        /* set service instance or host URL */
        String settingsKey = 'VCL_VELOCIFY_LIVE';
            
        if (orgType == 'TEST'){
            settingsKey = 'VCL_VELOCIFY_TEST';
        }
        System.debug(loggingLevel.ERROR, 'Settings Key : ' + settingsKey);

        
        Integration_Settings__c wsSettings = Integration_Settings__c.getValues(settingsKey);        
        String instanceURL;
        if (Test.isRunningTest()){
            instanceURL = 'http://0.0.0.0:1122';
        }else{
            instanceURL = wsSettings.Folder_Endpoint__c;
        }
        
        
        setInstanceURL(instanceURL);
        
        addHeader('Content-Type', 'application/json');
        
        System.debug(loggingLevel.ERROR, 'setServiceAttributes(-)');
    }
    
    public override void buildRequest(){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'buildRequest(+)');
        System.debug(loggingLevel.ERROR, '-- Application ID : ' + mApplicationId);
        fsCore__Lending_Application__c app = [Select id , Applicant_Verified_Income__c from fsCore__Lending_Application__c where id =:mApplicationId];
        
        HardPullRequest request = new HardPullRequest();
        request.PrizmId = mApplicationId;
        request.VerifiedIncome = app.Applicant_Verified_Income__c;
     
        
        String requestJSON = JSON.serialize(request);
        System.debug(loggingLevel.ERROR, '-- Request JSON : ' + requestJSON);
        
        setRequestBody(requestJSON);
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'buildRequest(-)');
    }

    
    
    public override void handleResponse(HttpResponse pResponse){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'handleResponse(+)');
        mResponse = pResponse;
        System.debug(loggingLevel.ERROR, '-- Status Code : ' + mResponse.getStatusCode());
        System.debug(loggingLevel.ERROR, '-- Response Body : ' + mResponse.getBody());
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'handleResponse(-)');
    }
    
    public HttpResponse getResponse(){
        if (Test.isRunningTest()){
            mResponse = new HttpResponse();
            mResponse.setStatusCode(fsCore.RESTConstants.HTTP_OK);
        }
        return mResponse;
    }
}