/*
 * Class   : WS_GetDRPStatus
 * Purpose : Web service to get the DRP Status from NuDebt Org.
 * Author  : Financial Spectra
 */
public class WS_GetDRPStatus {
    
    private static final String GET_DRP_STATUS_SERVICE_URI = '/apexrest/v1/GetDRPStatus';

    private List<WS_GetDRPStatusRequest> mRequest;
    private List<WS_GetDRPStatusResponse> mResponse;
    
    public WS_GetDRPStatus(){}
    
    public void setRequest(List<WS_GetDRPStatusRequest> pRequest){
        mRequest = pRequest;
    }
   
    public void invoke(){
        if (mRequest == null || mRequest.isEmpty()){
            throw new CustomException('Request Body is blank.');
        }

        String endPoint = 'callOut:' + WS_Constants.NUDEBT_ORG_NAMED_CRED;
        endPoint += GET_DRP_STATUS_SERVICE_URI;
        
        URL endPointURL = new URL(endPoint);
        
        String jsonBody = JSON.serialize(mRequest);
        
        HttpRequest httpReq= new HttpRequest();
        httpReq.setEndpoint(endPointURL.toExternalForm());
        httpReq.setMethod(WS_Constants.POST);
        httpReq.setheader('accept','application/json');
        httpReq.setBody(jsonBody);
        httpReq.setHeader('Content-Type','application/json');

        System.debug(loggingLevel.ERROR, '-- HTTP Request : ' + httpReq);
        HttpResponse httpRes = (new Http()).send(httpReq);      
        String responseBody = httpRes.getBody();

        System.debug(loggingLevel.ERROR, '-- HTTP Response : ' + httpRes);
        System.debug(loggingLevel.ERROR, '-- Response Body : ' + responseBody);

        if (httpRes.getStatusCode() == 200) {
            try{
                mResponse = (List<WS_GetDRPStatusResponse>)JSON.deserialize(responseBody, List<WS_GetDRPStatusResponse>.class);
            } catch (Exception e){
                mResponse = null;
                System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            }
        }
    }

    public List<WS_GetDRPStatusResponse> getResponse(){
        return mResponse;
    }
}