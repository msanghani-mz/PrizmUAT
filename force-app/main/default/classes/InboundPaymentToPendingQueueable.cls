/**
* @File Name          : InboundPaymentToPendingQueueable.cls
* @Description        : This Job will mark the ACH payments to the pending status so that NuPay will process such payments
* @Author             : financial Spectra
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 8/24/2019, 12:13:28 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    8/24/2019, 12:12:55 AM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class InboundPaymentToPendingQueueable implements Queueable {
    
    private Set<Id> mRecordIds;
    
    public InboundPaymentToPendingQueueable(Set<Id> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }
    public void execute(QueueableContext context) {
        Try{
            List<fsServ__Inbound_Payment__c> inboundPaymentList = [select id
                                                                        , NuPay_Transaction_Status__c 
                                                                     FROM fsServ__Inbound_Payment__c 
                                                                    WHERE id in :mRecordIds
                                                                      AND fsServ__Payment_Mode__c = 'ACH'
                                                                      AND NuPay_Transaction_Status__c = 'Tentative'
                                                                      AND fsServ__Is_Processed__c  = false];
            for (fsServ__Inbound_Payment__c iPayment: inboundPaymentList){
                iPayment.NuPay_Transaction_Status__c = 'Pending';
            }                                                                  
            update inboundPaymentList;                                                         
        }catch(Exception ex){
           errors(ex.getMessage(),ex.getStackTraceString());
        }
        
    }
    public void errors(String pExceptionMsg, String pStackTrace){
         fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(pExceptionMsg);
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(pStackTrace);
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            fsCore.DiagnosticLogUtil.logErrors('InboundPaymentToPendingQueueable', 'execute', errorObjectList);
    }  
}