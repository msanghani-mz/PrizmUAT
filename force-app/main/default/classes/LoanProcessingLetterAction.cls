/*
 * Class   : LoanProcessingLetterAction
 * Purpose : Action class to generate notification records for Loan Processing Letter
 * Author  : Financial Spectra
 */
global  class LoanProcessingLetterAction extends ApplicationNotificationAction{
    
    global LoanProcessingLetterAction(){
        super();
        setNotificationType(ApplicationNotificationUtil.LOAN_PROCESSING_LETTER);
    }
    
}