/*
* Class   : ContractNotificationAction
* Purpose : Action class to create notification records for Lending Contract Payments
* Author  : Financial Spectra
*/
global with sharing class ContractNotificationAction implements fsCore.ActionProcessor{    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput; 
    private String mNotificationType;    
    
    global class ContractNotificationActionException extends Exception{}
    
    global ContractNotificationAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }    
    
    global void setInput(fsCore.ActionInput pInput)	{
        mActionInput = pInput;
    }    
    
    global void setNotificationType(String pNotificationType){
        mNotificationType = pNotificationType;
    }    
    
    global void process(){
        System.debug(loggingLevel.ERROR, '-- Start processing ... ' + system.now());
        if (String.IsBlank(mNotificationType)){
            throw new ContractNotificationActionException('Notification Type is blank');
        }
        if (!ContractNotificationUtil.isNotificationTypeSupported(mNotificationType)){
            throw new ContractNotificationActionException('Notification Type ' + mNotificationType + ' is not supported');
        }        
        
        List<fsCore.ErrorObject> errors = ContractNotificationUtil.sendEmailNotifications(mActionInput.getRecords(), mNotificationType);
        if (errors.size() > 0){ 
            mActionOutput.addErrors(errors);
        } else {
            mActionOutput.setIsSuccess(true);
        }
        
        System.debug(loggingLevel.ERROR, '-- Finish processing ... ' + system.now());
    }    
    
    global fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }    
}