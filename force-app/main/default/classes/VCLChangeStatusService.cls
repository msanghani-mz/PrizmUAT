/*
 * Class Name   - VCLChangeStatusService
 * Description  - Web Service to update the application status 
 * Developer(s) - Financial Spectra
 */
public with sharing class VCLChangeStatusService extends fsCore.WebServiceBase {
    private static final String CLASS_NAME = 'VCLChangeStatusService';
    private static final String SERVICE_NAME = 'VCL_CHANGE_STATUS';
    private Id mApplicationId;
    private HttpResponse mResponse;
    
    public class ChangeStatusRequest{
        public String ApplicationId {get; set;}
        public String ReasonForChange {get; set;}
        public String StatusId {get; set;}
    }
    
    public VCLChangeStatusService(Id pApplicationId){
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
        
        fsCore__Lending_Application__c application = [SELECT Id
                                                           , Name
                                                           , fsCore__Application_Status__c
                                                        FROM fsCore__Lending_Application__c
                                                       WHERE Id = :mApplicationId];
        
        ChangeStatusRequest request = new ChangeStatusRequest();
        request.ApplicationId = application.Id;
        request.StatusId = getStatusID(application.fsCore__Application_Status__c);
        request.ReasonForChange = ''; //To Do : how to set the reason for change
        
        String requestJSON = JSON.serialize(request);
        System.debug(loggingLevel.ERROR, '-- Request JSON : ' + requestJSON);
        
        setRequestBody(requestJSON);
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'buildRequest(-)');
    }

    private String getStatusID(String pStatus){
        String statusId;
        if (String.IsNotBlank(pStatus) && pStatus == 'Declined'){
            statusId = '2';
        } else if (String.IsNotBlank(pStatus) && pStatus == 'Withdrawn'){
            statusId = '7';
        } else if (String.IsNotBlank(pStatus) && pStatus == 'Funded'){
            statusId = '9';
        }
        return statusId;
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