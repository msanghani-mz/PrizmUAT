/**
 * @File Name          : NuDebtIntegrate.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : abhinav@fsDev
 * @Last Modified On   : 4/22/2020, 10:50:08 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/13/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class NuDebtIntegrate {

    /* 
     * Method to update the NuDebt Program status in NuDebt Org 
     */
    @future(callout=true)
    public static void updateDNLStatusNotInterested(Set<Id> sObjectRecordIds,MAP<ID,ID> pProgramIdToAppMap){
        //CallOut to NuDebt for DNL- Not Interested Status Update.
        updateDNLStatus(sObjectRecordIds, pProgramIdToAppMap,'DNL Not Interested');
    }

    //PDI-118
    @future(callout=true)
    public static void updateDNLStatusDeclined(Set<Id> sObjectRecordIds, MAP<ID,ID> pProgramIdToAppMap){
        //CallOut to NuDebt for DNL- Application Declined Status Update.
        updateDNLStatus(sObjectRecordIds,pProgramIdToAppMap, 'Declined');
    }  

    //PDI-420
    @future(callout=true)
    public static void updateDNLStatusPreTilaSigned(Set<Id> sObjectRecordIds, MAP<ID,ID> pProgramIdToAppMap){
        //CallOut to NuDebt to Update DNL_Status__c on the Program in NuDebt to "Pre-TILA Signed"
        System.debug(LoggingLevel.Error , 'future');
        Map<Id, fsCore__Lending_Application__c> lendingApplicationMap = new Map<Id, fsCore__Lending_Application__c>
                                                                            ([SELECT Id , Name
                                                                                , fsCore__Loan_Amount__c
                                                                                , fsCore__Financed_Amount__c 
                                                                                , fsCore__Number_Of_Payments__c 
                                                                                , fsCore__Payment_Cycle__c
                                                                                , Underwriter__c
                                                                                , Pre_TILA_Signed_Date__c
                                                                                , Loan_Term__c
                                                                                , Loan_Officer_Name__c
                                                                                , fsCore__Requested_Payment_Start_Date__c
                                                                                , ( SELECT Id 
                                                                                         , Name
                                                                                         , Tradeline_Import_Id__c
                                                                                         , Estimated_Settlement_Percent__c
                                                                                         , fsCore__Approved_Amount_Unsigned__c
                                                                                     FROM fsCore__Lending_Application_Itemization__r)
                                                                                FROM fsCore__Lending_Application__c 
                                                                            WHERE Id IN :pProgramIdToAppMap.values()]);

           List<NuDebtProgramSchema.NuDebtProgramRequest> wsRequest = new List<NuDebtProgramSchema.NuDebtProgramRequest>();

           for (Id recordId : sObjectRecordIds){
                NuDebtProgramSchema.NuDebtProgramRequest request = new NuDebtProgramSchema.NuDebtProgramRequest();
                Id lendingApplicationId = pProgramIdToAppMap.get(recordId);
                
                request.program_Id = recordId;
                request.DNL_Status = 'Pre-TILA Signed';
                request.Estimated_Loan_Amount = lendingApplicationMap.get(lendingApplicationId).fsCore__Loan_Amount__c;
                request.Estimated_Financed_Amount = lendingApplicationMap.get(lendingApplicationId).fsCore__Financed_Amount__c;
                request.Estimated_Number_of_Payments = lendingApplicationMap.get(lendingApplicationId).fsCore__Number_Of_Payments__c;
                request.Loan_Repayment_Frequency = lendingApplicationMap.get(lendingApplicationId).fsCore__Payment_Cycle__c;
                request.Estimated_Loan_Start_Date = lendingApplicationMap.get(lendingApplicationId).fsCore__Requested_Payment_Start_Date__c;
                request.Underwriter = lendingApplicationMap.get(lendingApplicationId).Underwriter__c;			
                request.Loan_Officer = lendingApplicationMap.get(lendingApplicationId).Loan_Officer_Name__c;
                request.DNL_Term = lendingApplicationMap.get(lendingApplicationId).Loan_Term__c;
                request.DNL_Lending_Application_ID = lendingApplicationMap.get(lendingApplicationId).Id;		
              	request.DNL_Application_Number = lendingApplicationMap.get(lendingApplicationId).Name;
                request.Pre_TILA_Signed_Date = lendingApplicationMap.get(lendingApplicationId).Pre_TILA_Signed_Date__c;

                List<NuDebtProgramSchema.TradelineRequest> tradelines = new  List<NuDebtProgramSchema.TradelineRequest>();
                for (fsCore__Lending_Application_Itemization__c itm : lendingApplicationMap.get(lendingApplicationId).fsCore__Lending_Application_Itemization__r){
                    //Tradeline External ID has to be there to send the updates
                    if (itm.Tradeline_Import_Id__c != null){
                        NuDebtProgramSchema.TradelineRequest tradeline = new NuDebtProgramSchema.TradelineRequest();
                        tradeline.tradeline_Id = itm.Tradeline_Import_Id__c ;
                        tradeline.DNL_Estimated_Settlement_Percentage = itm.Estimated_Settlement_Percent__c ;
                        tradeline.DNL_Estimated_Settlement_Amount = itm.fsCore__Approved_Amount_Unsigned__c ;

                        tradelines.add(tradeline);
                    }
                }
                request.tradelines = tradelines;
                wsRequest.add(request);
        }
        System.debug(loggingLevel.ERROR , wsRequest);
        WS_UpdateProgramTradelinesToNuDebt updateProgramTradeLineAPI = new WS_UpdateProgramTradelinesToNuDebt();
        updateProgramTradeLineAPI.setRequest(wsRequest);
        updateProgramTradeLineAPI.setAppIdToRecMap(lendingApplicationMap);
        updateProgramTradeLineAPI.invoke();
        NuDebtProgramSchema.NuDebtProgramResponse wsResponse = updateProgramTradeLineAPI.getResponse();

    }

    private static void updateDNLStatus(Set<Id> sObjectRecordIds,MAP<ID,ID> pProgramIdToAppMap, String dnlStatus){
        
        List<fsCore.ErrorObject> errorList = new List<fsCore.ErrorObject>();

        try{
            for (Id recordId : sObjectRecordIds){
                try{
                    WS_UpdateDNLStatus updateStatusAPI = new WS_UpdateDNLStatus();
                    updateStatusAPI.setRecordId(String.valueOf(recordId));
                    updateStatusAPI.setDNLStatus(dnlStatus);
                    updateStatusAPI.invoke();
                }catch(Exception ex){
                    fsCore.ErrorObject errObj = new fsCore.ErrorObject();
                    errObj.setErrorRecordId(pProgramIdToAppMap.get(recordId));
                    errObj.setErrorMessage(ex.getMessage());
                    errObj.setErrorCode('DNL INVOKE EXCEPTION');
                    errObj.setErrorStackTrace(ex.getStackTraceString());
                    errorList.add(errObj);
                }
            }
        } 
        catch(Exception ex){
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode('DNL INVOKE EXCEPTION');
            errObj.setErrorStackTrace(ex.getStackTraceString());
            fsCore.DiagnosticLogUtil.logErrors('NuDebtIntegrate', 'updateDNLStatus', new List<fsCore.ErrorObject>{errObj});
        }
        //RECORD LEVEL EXCEPTION LOGGING
        if (errorList.size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('NuDebtIntegrate', 'updateDNLStatus', errorList);   
        }

    }

}