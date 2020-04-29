/*
 * Class   : WS_GetCreditReport
 * Purpose : This class invokes the Get Credit Report Web Service for VCL Loans (SUP-150)
 * Author  : Financial Spectra
 */
public with sharing class WS_GetCreditReport {
    
    private Integration_Settings__c mWSSettings;
    private String mAccessToken;
    
    private WS_GetCreditReportRequest  mRequest;
    private WS_GetCreditReportResponse mResponse;
    public boolean mIsAccessTokenSucess;
    public String mAccessTokeResponseStatus;

    public boolean mIsGetCreditReportSucess;
    public String mGetCreditResponseStatus;
    
    public WS_GetCreditReport(){
        setAccessToken();
    }

    public void setRequest(WS_GetCreditReportRequest pRequest){
        mRequest = pRequest;
    }

    private void setAccessToken(){
        if (Test.isRunningTest()){ //AD DO NOT CALL CREDIT SERVICE WHILE RUNNING THE TEST
            //DUMMY
            mIsAccessTokenSucess = true;
            mAccessToken = 'asytagfhghg'; //DUMMY
        }else{

            String settingsKey = 'VCL_CREDIT_PULL_LIVE';
            
            if (SFSUtil.getIsSandbox()){
                settingsKey = 'VCL_CREDIT_PULL_TEST';
            }
            System.debug(loggingLevel.ERROR, 'Settings Key : ' + settingsKey);

            mWSSettings = Integration_Settings__c.getValues(settingsKey);

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

                WS_GetCreditToken tokenResponse;
                mIsAccessTokenSucess = false;
                mAccessTokeResponseStatus = res.getStatus()+'['+res.getStatusCode()+']';
                if (res.getStatusCode() == 200){
                    tokenResponse = (WS_GetCreditToken)JSON.deserialize(res.getBody(), WS_GetCreditToken.class);
                    System.debug(loggingLevel.ERROR, 'Access Token  : ' + tokenResponse.access_Token);
                    mIsAccessTokenSucess = true;
                }else{
                    tokenResponse = new WS_GetCreditToken();
                }
                
                mAccessToken = tokenResponse.access_Token;
            }
        }
    }
    
    public void invoke(){
        try{
            if(String.IsNotBlank(mAccessToken)){
                if (Test.isRunningTest()){ //AD DO NOT CALL CREDIT SERVICE WHILE RUNNING THE TEST
                    //DUMMY
                    mIsGetCreditReportSucess = true;
                    mResponse = new WS_GetCreditReportResponse();
                    mResponse.htmlCreditReport = 'Dummy';
                }else{                
                    URL endPointURL = getEndPointURL(mRequest);

                    HttpRequest  httpReq = new HttpRequest();
                    httpReq.setEndpoint(endPointURL.toExternalForm());
                    httpReq.setMethod(WS_Constants.GET);
                    httpReq.setHeader('Authorization','Bearer ' + mAccessToken);
                    httpReq.setHeader('Content-Type','application/x-wwww-form-urlencoded');
                    System.debug(loggingLevel.ERROR, 'request -'+httpReq );
                    Http http = new Http();
                    HttpResponse httpRes = http.send(httpReq);

                    mIsGetCreditReportSucess = false;
                    
                    System.debug(loggingLevel.ERROR, 'Service Response : ' + httpRes);
                    mGetCreditResponseStatus = httpRes.getStatus()+'['+httpRes.getStatusCode()+']';
                    if (httpRes.getStatusCode() == 200){
                        
                        String doc = httpRes.getBody();
                        //System.debug(loggingLevel.ERROR, '-- Raw Response : ' + httpRes.getBody());
                        
                        mResponse = new WS_GetCreditReportResponse();
                        Map<String,Blob> creditReportMap = new Map<String,Blob>();
                        XmlStreamReader reader = new XmlStreamReader(doc);
                        String currentTime = fsCore.TypeUtil.getFormattedDatetime(System.now(), 'YYMMddhhmm');
                        while(reader.hasNext()){
                            if(reader.getEventType()==Xmltag.CHARACTERS){
                                if(reader.getText()!=null && reader.getText().length()>5){
                                    //System.debug(loggingLevel.ERROR,'+++++++++++++++++++++ Xmltag.CHARACTERS is +++++++++++ ' + reader.getText());
                                    mResponse.htmlCreditReport = reader.getText();
                                    mIsGetCreditReportSucess = true;
                                    
                                    break;
                                }
                            }
                            reader.next();
                        }    
                        //System.debug(loggingLevel.ERROR, '-- Response : ' + mResponse);
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
    
    private  URL getEndPointURL(WS_GetCreditReportRequest pWSRequest) {
        String endPointURL = mWSSettings.Folder_Endpoint__c + '/getlatestreport/'; 

        // https://creditpullerls.azurewebsites.net/getlatestreport/{velocifyId}?pulltype=soft

        endPointURL += pWSRequest.offerId;
        
        String paramString = '?pulltype=' + EncodingUtil.urlEncode('soft', 'UTF-8');

        endPointURL += paramString;

        return new URL(endPointURL);
    }


    public WS_GetCreditReportResponse getResponse(){
        return mResponse;
    }
    
    private static void logmessage (Object pMessage){
        system.debug(logginglevel.error,pMessage);
    }           
}