/**
* Class Name  : ApplicationCancelVoidEnvelopeQueueable  (DV-523)
* Description : This class mark the envelope as void for the applications
*               which were Cancelled 
* Author      : Financial Spectra
*
*/
global with sharing class ApplicationCancelVoidEnvelopeQueueable implements Queueable, Database.AllowsCallouts{
    private String CLASS_NAME = 'ApplicationCancelVoidEnvelopeQueueable';
    private Set<Id> mAppIds;
    public ApplicationCancelVoidEnvelopeQueueable(Set<Id> pRecordIds) {
        this.mAppIds = pRecordIds;
    }
    public void execute(QueueableContext context) {    
        
        List<dsfs__DocuSign_Status__c> DocuSignStatusList = [Select Id
                                                                  , Name
                                                                  , Lending_Application_Name_Formula__c
                                                                  , Lending_Application_Name__c 
                                                                  , Lending_Application_Name__r.Loan_Type__c
                                                                  , Lending_Application_Status_Formula__c
                                                                  , dsfs__Envelope_Status__c
                                                                  , dsfs__DocuSign_Envelope_ID__c
                                                               FROM dsfs__DocuSign_Status__c
                                                              WHERE (dsfs__Envelope_Status__c ='Sent' or dsfs__Envelope_Status__c ='Delivered')
                                                                AND Lending_Application_Name__c IN :mAppIds
                                                                AND Lending_Application_Status_Formula__c = 'COVID-Cancelled'
                                                                AND dsfs__DocuSign_Envelope_ID__c != null ];
        
        System.debug(loggingLevel.error, 'ExecutingQueuable ' + CLASS_NAME + '...');
        System.debug(loggingLevel.error, 'DocuSignStatusList ' +DocuSignStatusList+ '...');
        DocuSignAPI.VoidEnvelopeStatus vEnvelopeStatus;
        try{
            
            for (dsfs__DocuSign_Status__c docuSignStatus : DocuSignStatusList){
                
                System.debug(loggingLevel.error,'Lending App Name :: '+docuSignStatus.Lending_Application_Name_Formula__c +
                             '  :: lending App Sttaus ==> '+docuSignStatus.Lending_Application_Status_Formula__c +
                             '  :: Envelope Status ==> '+docuSignStatus.dsfs__Envelope_Status__c +
                             '  :: Loan Type ==> '+docuSignStatus.Lending_Application_Name__r.Loan_Type__c +
                             '  :: Docusign EnvelopeId ==> '+docuSignStatus.dsfs__DocuSign_Envelope_ID__c);  
                if (docuSignStatus.Lending_Application_Name__r.Loan_Type__c == 'DNL'){
                    system.debug(logginglevel.ERROR, 'Inside the DNL if Condition');
                    
                    if (docuSignStatus.Lending_Application_Status_Formula__c == 'COVID-Cancelled') 
                    {
                        system.debug(logginglevel.ERROR, 'Voiding the envelope Envelope Id :'+docuSignStatus.dsfs__DocuSign_Envelope_ID__c);
                        try{
                            if(!test.isRunningTest()){
                                vEnvelopeStatus = DocusignAPIUtil.VoidEnvelope(String.valueOf(docuSignStatus.dsfs__DocuSign_Envelope_ID__c));
                                system.debug(logginglevel.error,'vEnvelopeStatus.VoidSuccess :'+vEnvelopeStatus.VoidSuccess);  
                                if (vEnvelopeStatus.VoidSuccess){System.debug(logginglevel.Error,'Envelope has been voided successfully!');}
                            }
                        }catch(Exception e){system.debug(logginglevel.error,' EXCEPTION While Voiding the envelope ****   '+e.getStackTraceString() +e);}                                
                    }
                }
            }

        }catch(Exception e){system.debug(logginglevel.error,' EXCEPTION ****   '+e.getStackTraceString() +e);  Throw e;}
        
    }
    
    
}