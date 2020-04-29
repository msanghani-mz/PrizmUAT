/*
 * Class   : WS_AnalyzeCredit
 * Purpose : This class invokes the Credit Analysis Web Service 
 * Author  : Financial Spectra
 */
public with sharing class WS_AnalyzeCredit {
    
    private Integration_Settings__c mWSSettings;
    private String mAccessToken;
    
    private WS_AnalyzeCreditRequest  mRequest;
    private WS_AnalyzeCreditResponse mResponse;
    public boolean mIsAccessTokenSucess;
    public String mAccessTokeResponseStatus;

    public boolean mIsCreditAnalysisSucess;
    public String mCreditAnalysisResponseStatus;
    
    public WS_AnalyzeCredit(){
        setAccessToken();
    }

    public void setRequest(WS_AnalyzeCreditRequest pRequest){
        mRequest = pRequest;
    }

    private void setAccessToken(){
        if (Test.isRunningTest()){ //AD DO NOT CALL CREDIT SERVICE WHILE RUNNING THE TEST
            //DUMMY
            mIsAccessTokenSucess = true;
            mAccessToken = 'asytagfhghg'; //DUMMY
        }else{
            mWSSettings = Integration_Settings__c.getValues('Credit_Analysis');

            if (mWSSettings != null){
                String tokenEndPoint = mWSSettings.Folder_Endpoint__c + '/oauth2/token';
                //String reqbody = 'grant_type=client_credentials&client_id=' + mWSSettings.Client_Id__c + '&client_secret=' + mWSSettings.Client_Secret__c; 
                String reqbody = 'grant_type=client_credentials';
                
                HttpRequest req= new HttpRequest();
                req.setEndpoint(tokenEndPoint);
                req.setMethod('POST');
                req.setBody(reqbody);
                String username = mWSSettings.Client_Id__c;
                String password = mWSSettings.Client_Secret__c;
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);                
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                System.debug(loggingLevel.ERROR, 'Access Token Response : ' + res);
                System.debug(loggingLevel.ERROR, ' RAW Response : ' + res.getBody());

                //AccessTokenResponse tokenResponse;
                WS_PullAnalyzeCreditToken tokenResponse;
                mIsAccessTokenSucess = false;
                mAccessTokeResponseStatus = res.getStatus()+'['+res.getStatusCode()+']';
                if (res.getStatusCode() == 200){
                    //tokenResponse = (AccessTokenResponse)JSON.deserialize(res.getBody(), AccessTokenResponse.class);
                    tokenResponse = (WS_PullAnalyzeCreditToken)JSON.deserialize(res.getBody(), WS_PullAnalyzeCreditToken.class);
                    System.debug(loggingLevel.ERROR, 'Access Token  : ' + tokenResponse.access_Token);
                    mIsAccessTokenSucess = true;
                }else{
                    tokenResponse = new WS_PullAnalyzeCreditToken();
                }
                
                mAccessToken = tokenResponse.access_Token;
            }
        }
    }
    
    public class AccessTokenResponse{
        public string access_token;
        public string refresh_token;
        public string token_type;
        public string client_name;
        public string expires_in;
        public string issued;
        public string expires;
    }

    public void invoke(){
        /* Service : analyze credit without Co-Applicant */
        try{
            if(String.IsNotBlank(mAccessToken)){
                if (Test.isRunningTest()){ //AD DO NOT CALL CREDIT SERVICE WHILE RUNNING THE TEST
                    //DUMMY
                    mIsCreditAnalysisSucess = false;
                }else{                
                    URL endPointURL = getEndPointURL(mRequest);

                    HttpRequest  httpReq = new HttpRequest();
                    httpReq.setEndpoint(endPointURL.toExternalForm());
                    httpReq.setMethod(WS_Constants.GET);
                    httpReq.setHeader('Authorization','Bearer ' + mAccessToken);
                    httpReq.setHeader('Content-Type','application/x-wwww-form-urlencoded');
                    
                    Http http = new Http();
                    HttpResponse httpRes = http.send(httpReq);

                    mIsCreditAnalysisSucess = false;
                    
                    System.debug(loggingLevel.ERROR, 'Service Response : ' + httpRes);
                    mCreditAnalysisResponseStatus = httpRes.getStatus()+'['+httpRes.getStatusCode()+']';
                    if (httpRes.getStatusCode() == 200){
                        System.debug(loggingLevel.ERROR, '-- Raw Response : ' + httpRes.getBody());
                        mResponse = (WS_AnalyzeCreditResponse)JSON.deserialize(httpRes.getBody(), WS_AnalyzeCreditResponse.class);
                        mIsCreditAnalysisSucess = true;
                        System.debug(loggingLevel.ERROR, '-- Response : ' + mResponse);
                    }

                    update mWSSettings;
                }
            }
        }
        catch(Exception ex){
            System.debug(loggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
            mResponse = null;
        }
    }

    private  URL getEndPointURL(WS_AnalyzeCreditRequest pWSRequest) {
        String endPointURL = mWSSettings.Folder_Endpoint__c + '/creditanalysis/dnl'; 

        endPointURL += '?applicationId='+pWSRequest.application_number;
        
        String paramString = ('&pulltype=' + EncodingUtil.urlEncode('soft', 'UTF-8'));

        endPointURL += paramString;

        return new URL(endPointURL);
    }


    public static String sanitizeXML(String requestBody) {
        if (requestBody != null){
            requestBody = requestBody.replace('&amp;', '&'); //TO MAKE SURE THAT WE DON"T HAVE ANY &AMP;
            requestBody = requestBody.replace('&', '&amp;'); //NOT REPLACE ALL & WITH &AMP
        }
        return requestBody;
    }

    public WS_AnalyzeCreditResponse getResponse(){
        return mResponse;
    }
    
    private static void logmessage (Object pMessage){
        system.debug(logginglevel.error,pMessage);
    }           
}