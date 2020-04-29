/*
 * Copyright (c) 2017-2019 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class        - CFTPayRefundLoanService
 *
 * Description  - Web Service class for CFTPay Service
 *
 * Developer(s) - Anmol Chaudhary
 *
 */
public with sharing class CFTPayRefundLoanService extends CFTPayServiceBase {
    private static final String CLASS_NAME = 'CFTPayRefundLoanService';
    private static final String SERVICE_NAME = 'CFTPAY_REFUND_LOAN';
    private Set<Id> mInputIDs;
    
    public CFTPayRefundLoanService(){
        super(SERVICE_NAME);
        mInputIDs = new Set<Id>();
    }

     public void setInput(Set<Id> pInputIDs){
        mInputIDs = pInputIDs;
    }
    
    public override void buildRequest(){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'buildRequest(+)');
        System.debug(loggingLevel.ERROR, '-- Input IDs : ' + mInputIDs);
        
        fsCore__Web_Service__mdt wsInfo = getWebServiceDetails();
        System.debug(loggingLevel.ERROR, '-- Web Service Info : ' + wsInfo);
        
        String requestJSON = '{"enrollment":{"id":"4002057"},"service" : {"id" : "111"},"amount":"100","allowDuplicate":"true","scheduleDate":"11/30/2020","comment":"creating a refund loan"}';
        System.debug(loggingLevel.ERROR, '-- Request JSON : ' + requestJSON);
        
        setRequestBody(requestJSON);
        
        
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'buildRequest(-)');
    }
    
    public override void handleResponse(HttpResponse pResponse){
        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'handleResponse(+)');
        
        System.debug(loggingLevel.ERROR, '-- Response : ' + pResponse);
        System.debug(loggingLevel.ERROR, '-- Response Body : ' + pResponse.getHeader('Url'));
        
        
        try{
            {
                System.debug(loggingLevel.ERROR, '-- Standard handling of response ');
            }
        }
        catch(Exception e){
            System.debug(loggingLevel.ERROR, '-- Exception occurred when processing response : ' + e.getMessage() + ' - ' + e.getStackTraceString());
            addError(new fsCore.ErrorObject(e));
        }

        System.debug(loggingLevel.ERROR, CLASS_NAME + '.' + 'handleResponse(-)');
    }

}