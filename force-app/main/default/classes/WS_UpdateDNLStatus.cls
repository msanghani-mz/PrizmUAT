/*
 * Class   : WS_UpdateDNLStatus
 * Purpose : Web service to update the DNL Status in NuDebt Org.
 * Author  : Financial Spectra
 */
public class WS_UpdateDNLStatus {
    
    private static final String UPDATE_DNL_STATUS_SERVICE_URI = '/data/v43.0/sobjects/nu_dse__Program__c';
    private String mRecordId;
    private String mDNLStatus;
    private Set<Integer> mSuccessStatus = new Set<Integer>{204,200};

    private HttpResponse mResponse;
    
    public WS_UpdateDNLStatus(){}
    
    public void setRecordId(String pRecordId){
        mRecordId = pRecordId;
    }
    public void setDNLStatus(String pDNLStatus){
        mDNLStatus = pDNLStatus;
    }
    
    public void invoke(){
        if (String.IsBlank(mRecordId)){
            throw new CustomException('Record ID is blank.');
        }
        if (String.IsBlank(mDNLStatus)){
            throw new CustomException('DNL Status is blank.');
        }
        
        String endPoint = 'callOut:' + WS_Constants.NUDEBT_ORG_NAMED_CRED;
        endPoint += UPDATE_DNL_STATUS_SERVICE_URI;
        endPoint += '/'+ mRecordId + '?_HttpMethod=' + WS_Constants.PATCH;
        
        URL endPointURL = new URL(endPoint);
        
        String jsonBody = '{"DNL_Status__c":"' + mDNLStatus + '"}';
        
        if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
            //Do NOTHING
        }else{           
            HttpRequest httpReq= new HttpRequest();
            httpReq.setEndpoint(endPointURL.toExternalForm());
            httpReq.setHeader('Content-Type','application/json');
            httpReq.setHeader('X-HTTP-Method-Override',WS_Constants.PATCH);
            httpReq.setHeader('accept','application/json');
            httpReq.setMethod(WS_Constants.POST);
            httpReq.setBody(jsonBody);
            httpReq.setTimeout(120000);
            
            System.debug(loggingLevel.ERROR, '-- HTTP Request : ' + httpReq);
            mResponse = (new Http()).send(httpReq);      
            String responseBody = mResponse.getBody();

            System.debug(loggingLevel.ERROR, '-- HTTP Response : ' + mResponse);
            System.debug(loggingLevel.ERROR, '-- Response Body : ' + responseBody);
            //HTTP status code 204 is returned if an existing record is updated.
            //Salesforce API documentation says 204 status is expected for the successfull operation.
            Boolean successfullyUpdated  = mSuccessStatus.contains(mResponse.getStatusCode());
            
            if (!successfullyUpdated){
                if ((responseBody != null) && (responseBody.length()>0)){
                    throw new WS_UpdateDNLStatusException(responseBody);
                }else{
                    throw new WS_UpdateDNLStatusException('Status='+mResponse.getStatus()+', StatusCode='+String.ValueOf(mResponse.getStatusCode()));
                }
            }
        }

    }

    public HttpResponse getResponse(){
        return mResponse;
    }
    public class WS_UpdateDNLStatusException extends Exception{}
}