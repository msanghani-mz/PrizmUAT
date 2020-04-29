/*
* Class   : WS_UpdateProgramTradelinesToNuDebt
* Purpose : Web service to Update Program Tradelines To NuDebt Status from Prizm
* Author  : Financial Spectra
*/
public class WS_UpdateProgramTradelinesToNuDebt {
    
    private static final String UPDATE_NUDEBT_PROGRAM_SERVICE_URI = '/apexrest/v1/UpdateNuDebtProgram';
    private static final String CLASS_NAME = 'WS_UpdateProgramTradelinesToNuDebt';
    private List<NuDebtProgramSchema.NuDebtProgramRequest> mRequest;
    private NuDebtProgramSchema.NuDebtProgramResponse mResponse;
    private Map<Id, fsCore__Lending_Application__c> mMap; 
    
    public WS_UpdateProgramTradelinesToNuDebt(){}
    
    public void setRequest(List<NuDebtProgramSchema.NuDebtProgramRequest> pRequest){
        mRequest = pRequest;
    }
    
    public void setAppIdToRecMap(Map<Id, fsCore__Lending_Application__c> pMap){
        mMap = pMap;
    }
    
    public void invoke(){
        String METHOD_NAME = 'invoke';
        
        if (mRequest == null || mRequest.isEmpty()){
            throw new CustomException('Request Body is blank.');
        }
        
        String endPoint = 'callOut:' + WS_Constants.NUDEBT_ORG_NAMED_CRED;
        endPoint += UPDATE_NUDEBT_PROGRAM_SERVICE_URI;
        
        URL endPointURL = new URL(endPoint);
        
        String jsonBody = JSON.serialize(mRequest);
        
        HttpRequest httpReq= new HttpRequest();
        httpReq.setTimeout(60000);
        httpReq.setEndpoint(endPointURL.toExternalForm());
        httpReq.setMethod(WS_Constants.POST);
        httpReq.setheader('accept','application/json');
        httpReq.setBody(jsonBody);
        httpReq.setHeader('Content-Type','application/json');
        
        System.debug(loggingLevel.ERROR, '-- jsonBody : ' + jsonBody);
        System.debug(loggingLevel.ERROR, '-- HTTP Request : ' + httpReq);
        HttpResponse httpRes;
        String responseBody;
        integer statusCode;
        try{
            httpRes = (new Http()).send(httpReq);   
            System.debug(loggingLevel.ERROR, '-- HTTP Request - after request');        
            responseBody = httpRes.getBody();
            statusCode = httpRes.getStatusCode();
            System.debug(loggingLevel.ERROR , statusCode);
        }
        catch(Exception e){
            handleException(e.getMessage(),METHOD_NAME);
        }        
        System.debug(loggingLevel.ERROR, '-- HTTP Response : ' + httpRes);
        System.debug(loggingLevel.ERROR, '-- Response Body : ' + responseBody);
        
        mResponse = (NuDebtProgramSchema.NuDebtProgramResponse)JSON.deserialize(responseBody, NuDebtProgramSchema.NuDebtProgramResponse.class);
        System.debug(loggingLevel.ERROR, '-- Final deSerialized Response Body : ' + mResponse);
        if (mResponse.is_success = false){
            handleException(mResponse.error_Message,METHOD_NAME);
        }
    }
    private void handleException(String pErrorMessage, String pMethodName){
        System.debug(loggingLevel.ERROR, '-- Handling exception : ' + pErrorMessage);
        List<fsCore__Diagnostic_Log__c> errorList = new List<fsCore__Diagnostic_Log__c>();
        for(fsCore__Lending_Application__c app : mMap.values()){
            fsCore__Diagnostic_Log__c error = fsCore.DiagnosticLogUtil.getErrorLog(CLASS_NAME
                                                                                 , pMethodName
                                                                                 , app.Id
                                                                                 , app.Name
                                                                                 , fsCore.Constants.PROCESSING_ERROR
                                                                                 , pErrorMessage
                                                                                 , null);
            errorList.add(error);
        }
        
        database.insert(errorList);
        System.debug(loggingLevel.ERROR , 'Added to Diagnostic logs for service issue');

    
    }

    
    public NuDebtProgramSchema.NuDebtProgramResponse getResponse(){
        return mResponse;
    }
}