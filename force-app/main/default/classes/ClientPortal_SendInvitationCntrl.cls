public without sharing class ClientPortal_SendInvitationCntrl {
    
    @AuraEnabled
    public static ResponseWrapper sendInvitationEmail(String opportunityId) {
        
        ResponseWrapper response = new ResponseWrapper();
        
        List<Account> accountsToUpdate = new List<Account> () ;
        Opportunity opp = [SELECT Id, StageName, Account.IsCustomerPortal,
                           Account.PersonEmail, Applicant_Email__c, AccountId,
                           Co_Applicant_Name__r.PersonEmail, Co_Applicant_Email__c
                           FROM Opportunity
                           WHERE Id =: opportunityId ];
        
        if(opp.Account.IsCustomerPortal) {
            response.isSuccess = false;
            response.message = 'Client is already registered.';
            return response;
        }
        
        if(opp.StageName == 'Registration In Progress') {
            response.isSuccess = false;
            response.message = 'Registration Email already sent.';
            return response;
        }
        
        if(!opp.Account.IsCustomerPortal && opp.StageName != 'Registration In Progress') {
            if((opp.AccountId != null && (String.isBlank(opp.Account.PersonEmail) || opp.Account.PersonEmail == null)) || (opp.Co_Applicant_Name__c != null && (String.isBlank(opp.Co_Applicant_Name__r.PersonEmail) || opp.Co_Applicant_Name__r.PersonEmail == null))){
                response.isSuccess = false;
                response.message = 'Either Applicant or Co-applicant is missing Email, Please update to Send Invite to portal.';
                return response;
            }
            try {
                opp.StageName = 'Registration In Progress';
                opp.Applicant_Email__c= opp.Account.PersonEmail;
                opp.Co_Applicant_Email__c = opp.Co_Applicant_Name__r.PersonEmail;
                update opp;
                
                if(String.isNotBlank(opp.AccountId)) {
                    accountsToUpdate.add(new Account(Id = opp.AccountId, 
                                                     Welcome_Email_Sent_Date__c  = System.now(), 
                                                     Is_Welcome_Email_Sent__c = true));
                }
                if(String.isNotBlank(opp.Co_Applicant_Name__c)) {
                    accountsToUpdate.add(new Account(Id = opp.Co_Applicant_Name__c, 
                                                     Welcome_Email_Sent_Date__c  = System.now(), 
                                                     Is_Welcome_Email_Sent__c = true));
                }
                if( !accountsToUpdate.isEmpty() ) {
                    update accountsToUpdate ;
                }
                response.isSuccess = true;
                response.message = 'Success';
                return response;
            } catch(Exception e) {
                response.isSuccess = false;
                response.message = e.getMessage();
                return response;
            }
        }
        return response;
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public Boolean isSuccess {get; set;}
        @AuraEnabled
        public String message {get; set;}
    }
}