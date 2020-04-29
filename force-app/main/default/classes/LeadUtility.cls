global without sharing class LeadUtility
{
    @AuraEnabled
    public static Lead leadRec(id leadRecId){
        Lead leadRec = null;
        leadRec = [Select Id,Account__c,Program_Name__c,Portfolio__c, Email, OWD_Address__c, ConvertedAccountId, ConvertedOpportunityId, View_New_Opportunity__c from Lead where ID = :leadRecId];
        return leadRec;
    }
    
    @AuraEnabled
    webservice static string sendEmail(ID leadID)
    {  
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        actionOP.setIsSuccess(false);
        String result = null;
        String currentOWDAddress= null;
        Lead leadRec = [Select Id,Account__c,Program_Name__c,Portfolio__c, Email, OWD_Address__c, Last_Email_Sent_Time__c from Lead where ID = :leadID];
        if(leadRec!= null){
            // Check to Send mail to the lead only once.
            if(leadRec.Last_Email_Sent_Time__c != null){
                 result = 'Email Error: A Success email has already been sent to this lead';
                 actionOP.addError(result);
                 
            }else
                currentOWDAddress = leadRec.OWD_Address__c;
        }
        if(currentOWDAddress != null){
            
            if(currentOWDAddress == 'Error_ProgramID')
                result = 'Email Error: Program not associate with Opportunity';
            
            if(currentOWDAddress == 'Error_PortfolioID')
                result = 'Email Error: Portfolio is not associate with Program';
            
            if(currentOWDAddress == 'Error_NoEmail')
                result =  'Email Error: No Email associated with Portfolio';
            
        //For testing
      //  currentOWDAddress = 'support@peerform.com';
      //currentOWDAddress = 'mz-sfdc-devs@mindzcloud.com';
      //currentOWDAddress = 'mchin@wyolawfirm.com';
        List<OrgWideEmailAddress> OWD = [select id, Address,DisplayName from OrgWideEmailAddress where Address=:currentOWDAddress];
        
        if(OWD !=null && OWD.size() > 0)
        {
            
            if(string.isNotBlank(leadRec.Email))
            {
                
                try
                {
                    
                    DynamicTemplateController d= new DynamicTemplateController();
                    d.LeadId = leadRec.Id;
                    d.AccountId =leadRec.Account__c;
                    d.UserId = UserInfo.getUserId();
                    d.ProgramId = leadRec.Program_Name__c;
                    d.PortfolioId = leadRec.Portfolio__c;
                    d.vfTemplateName = 'Lead_On_Time_Payment_Notification';
                    
                    string emailBody = null;
                    string subject = null;
                    
                    if(d.getTemplateContent().contains('::Split::'))
                    {
                        List<string> emailcontent = d.getTemplateContent().split('::Split::');
                        subject = emailcontent[0];
                        emailBody = emailcontent[1];
                    }
                    
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    List<String> sendTo = new List<String>();
                    sendTo.add(leadRec.Email);
                    mail.setToAddresses(sendTo);
                    mail.setReplyTo(OWD[0].Address);
                    mail.setOrgWideEmailAddressId(OWD[0].Id);
                    mail.setHtmlBody(emailBody);
                    mail.setSubject(subject);
                    mail.setTargetObjectId(leadRec.id);
                    //mail.setSaveAsActivity(false);
                    mails.add(mail);
                    
                    
                    
                    Messaging.sendEmail(mails);  
                    
                    leadRec.Last_Email_Sent_Time__c = System.now();
                    update leadRec;
                    actionOP.setIsSuccess(true);
                    result = 'Email Sent Successfully!';
                    
                    
                }
                catch(EmailException  e)
                {
                    result = e.getMessage() + ' - ' + e.getStackTraceString();
                    if(result.contains('UNVERIFIED_SENDER_ADDRESS'))
                        result = 'Email_Error: The sender' + '\'' + 's email hasn' + '\'' + 't been verified. Please verify and try again.';
                     if(result.contains('INSUFFICIENT_ACCESS_OR_READONLY'))
                        result = 'Email_Error: The user does not have sufficient access to this Org wide email address';
                    actionOP.addError(result);
                }
            }
            else
            {
                result = 'Email_Error: Invalid Customer Email';
                actionOP.addError(result);
            }
        }
        else
        {
            result = 'Email_Error: Only Lead Owner is authorized to send email';
            actionOP.addError(result);
        }
    }
        
        return actionOP.getJSONString();
        
    }
}