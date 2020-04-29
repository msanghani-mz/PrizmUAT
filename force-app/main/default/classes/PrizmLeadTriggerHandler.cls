/**
* About: Trigger handler for creating Lead for NuDebt
*
* Author: Kimi Shrivastava
*
**/
public class PrizmLeadTriggerHandler {
    
    
    public Static boolean isTriggerExecuted = false;    
    public static NuDebtProgramWrapper nuDebtProgramWrapper =  new NuDebtProgramWrapper() ;
    
    
    public static void PrizmLeadTriggerAfter(List<Id> ProgramIds, List<NuDebtProgramWrapper.ProgramWrapper> newLeadProgramList){
        System.debug('***isAfter');        
        if(!ProgramIds.isEmpty()){
            isTriggerExecuted=true; 
            System.debug('****'+ProgramIds);
            
            // Update lead records on lead status
            
            if(Trigger.isInsert){
                List<Lead> LeadList = [Select Id,Latest_Lead__c, Status, Program_Name__c from Lead where Program_Name__c =: ProgramIds AND isConverted = false 
                                       AND Id NOT In : Trigger.newMap.keySet()];
                For(Lead lead : LeadList){
                    lead.Latest_Lead__c = false;
                }
                Update LeadList;
            }
            
            //Send Program-Lead data to NuDebt for updating the status in NuDebt - Program
            NuDebtProgramWrapper nuDebtWrapper = new NuDebtProgramWrapper();
            nuDebtWrapper.programs = newLeadProgramList;
            NuDebtProgramWrapper newWrp = PrizmLeadPullService.sendProgramDataToNuDebt(nuDebtWrapper);
            System.debug(newWrp.programs);
            
        }
    } 
    // --------------------------------------------------------------------------
    // Map custom fields of the leads to opportunity on conversion
    // --------------------------------------------------------------------------
    public static void mapConvertedLeadToOpportunity(){
        List<Lead> newLead = (List<Lead>)Trigger.new;
        List<Lead> oldLead = (List<Lead>)Trigger.old;
        System.debug('mapConvertedLeadToOpportunity ' + newLead);
        try{
        if (oldLead != null && newLead != null && oldLead.size() == 1 && newLead.size() == 1) {
            if (oldLead[0].isConverted == false && newLead[0].isConverted == true) {
                Id ApplicantRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
                // Update the record Type of the new Account
                if (newLead[0].ConvertedAccountId != null) {
                    
                    // update the converted account with some text from the lead
                    Account a = [Select a.Id, a.RecordTypeId, a.NDS_File_Number__c From Account a Where a.Id = :newLead[0].ConvertedAccountId];
                    a.RecordTypeId = ApplicantRecTypeId;
                    a.NDS_File_Number__c = newLead[0].NDS_File_Number__c;
                    a.PersonBirthdate = newLead[0].Birth_Date__c;
                    a.nu_dse__SSN__c = newLead[0].Social_Security_Number__c;
                    update a;
                    
                }   
                // Create New Account of the co-Applicant of the converted Lead.
                Account newPersonAccount ;
                // if a new account was created
                if (newLead[0].ConvertedAccountId != null && newLead[0].Co_Applicant_First_Name__c != null && newLead[0].Co_Applicant_First_Name__c != '') {
                    
                    newPersonAccount = new Account();
                    newPersonAccount.FirstName = newLead[0].Co_Applicant_First_Name__c;
                    newPersonAccount.LastName = newLead[0].Co_Applicant_Last_Name__c;
                    newPersonAccount.MiddleName = newLead[0].Co_Applicant_Middle_Name__c;
                    newPersonAccount.Phone    = newLead[0].Co_Applicant_Phone__c;
                    newPersonAccount.PersonEmail= newLead[0].Co_Applicant_Email__c;
                   newPersonAccount.NDS_File_Number__c =   newLead[0].NDS_File_Number__c + 'CO';
                    //newPersonAccount.SSN__c       = newLead[0].Co_Applicant_SSN__c;
                    //newPersonAccount.BillingState   = newLead[0].Applicant_State__c;
                    newPersonAccount.RecordTypeId = ApplicantRecTypeId;
                    System.debug(loggingLevel.ERROR, newPersonAccount);
                    upsert (newPersonAccount);
                }
               
                // if a new opportunity was created
                if (newLead[0].ConvertedOpportunityId != null && newLead[0].ConvertedAccountId != null) {
                    System.debug('mapConvertedLeadToOpportunity ' + newLead[0].ConvertedOpportunityId);
                    // update the converted opportunity with some text from the lead
                    Opportunity o = [Select o.Id, o.Payment_Processor_Name__c, o.Co_Applicant_Name__c, 
                                     o.Co_Applicant_Email__c, o.DRP_Name__c, o.DRP_Account_Number__c, o.Portfolio_Type__c, o.Law_Firm_Name__c, Lead_Id__c, StageName,
                                     Import_Program_Id__c, DRP_File_Number__c, Lead_Record_Type__c
                                     from Opportunity o Where o.Id = :newLead[0].ConvertedOpportunityId];
                    
                    // Populate the Debt count - Number of Tradelines for the particular lead                    
                    Integer tradelineCount = [Select count() from Opportunity_Tradelines_Offer__c where  Lead__c = :newLead[0].Id ];
                    if(tradelineCount != null)
                    	o.Debt_Count__c = tradelineCount;
                    if( newLead[0].Processor_Name__c.contains('CFT'))
                        o.Payment_Processor_Name__c = 'CFT';
                    if(newLead[0].Processor_Name__c.contains('GCS'))
                        o.Payment_Processor_Name__c = 'GCS';
                    if(newLead[0].Processor_Name__c.contains('RAM'))
                        o.Payment_Processor_Name__c= 'RAM';
                    if(newPersonAccount != null && newPersonAccount.Id != null)
                        o.Co_Applicant_Name__c = newPersonAccount.Id;
                    o.DRP_Name__c = newLead[0].ProgramNameText__c;
                    o.DRP_Account_Number__c = newLead[0].ConvertedAccountId;
                    o.Portfolio_Type__c = newLead[0].Portfolio_Type__c;
                    System.debug(LoggingLevel.ERROR, newLead[0].Portfolio_Name__c);
                    if(o.Portfolio_Type__c == 'Attorney')
                        o.Law_Firm_Name__c = newLead[0].Portfolio_Name__c;
                    o.Lead_Id__c = newLead[0].Id;
                    //o.StageName = 'DNL Prospecting';
                    o.Import_Program_Id__c =  newLead[0].ProgramName__c;
                    o.DRP_File_Number__c = newLead[0].NDS_File_Number__c ;
                    o.Cash_in_Dedicated_Account__c = newLead[0].Cash_in_Dedicated_Account__c;
                    o.Amount = newLead[0].Loan_Amount__c;
                    o.Loan_Number_Of_Payments__c = newLead[0].Loan_Term__c;
                    o.Addnl_Months_with_Loan__c = newLead[0].Addnl_Months_with_Loan__c;
                    o.Unpaid_Program_Fee_W_DNL__c = newLead[0].Unpaid_Program_Fees__c;
                    o.Segment__c = newLead[0].Segment__c;
                    o.Enrolled_Date__c = newLead[0].Enrollment_Date__c;
                    o.Program_Number_Of_Payments__c = newLead[0].Program_Length__c;
                    o.Lead_Record_Type__c = newLead[0].Lead_Record_Type_txt_del__c;
                    o.Remaining_Months_DRP_Program__c = newLead[0].Remaining_Months_in_Program__c;
                    update o;                    
                    
                    // Updated Related Tradelines with Opportunity Id
                    Id leadTradeLinesRecordTypeId = Schema.SObjectType.Opportunity_Tradelines_Offer__c.getRecordTypeInfosByName().get('Lead Tradelines Offer').getRecordTypeId();
                    Id tradeLinesRecordTypeId = Schema.SObjectType.Opportunity_Tradelines_Offer__c.getRecordTypeInfosByName().get('Tradelines Offer').getRecordTypeId();
                    List<Opportunity_Tradelines_Offer__c> tradelinesList = [Select Id, FileNumber__c, Import_Id__c, Lead__c, Opportunity_Name__c, RecordTypeId from Opportunity_Tradelines_Offer__c where 
                                                                            Lead__c =:newLead[0].Id];
                    if(tradelinesList != null && tradelinesList.size() > 0){
                        for(Opportunity_Tradelines_Offer__c tradeline:tradelinesList){
                            tradeline.Opportunity_Name__c = newLead[0].ConvertedOpportunityId;
                            if(tradeline.RecordTypeId == leadTradeLinesRecordTypeId)
                                tradeline.RecordTypeId = tradeLinesRecordTypeId;
                        }
                        update tradelinesList;
                    }
                    // Updated Related Payments with Opportunity Id
                    Id leadSettlementPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Settlement').getRecordTypeId();
                    Id leadDraftPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Draft').getRecordTypeId();
                    Id leadLoanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Loan').getRecordTypeId();
                    Id leadRefundLoanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Lead Refund Loan').getRecordTypeId();
                    
                    Id settlementPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
                    Id draftPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
                    Id loanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
                    Id refundLoanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Refund loan').getRecordTypeId();
                   
                    List<Opportunity_Payment__c> paymentsList = [Select Id, FileNumber__c, Import_Id__c, Lead__c, Opportunity_Name__c, RecordTypeId from Opportunity_Payment__c where 
                                                                 Lead__c =:newLead[0].Id];
                    if(paymentsList != null && paymentsList.size() > 0){
                        for(Opportunity_Payment__c payment:paymentsList){
                            payment.Opportunity_Name__c = newLead[0].ConvertedOpportunityId;
                            if(payment.RecordTypeId == leadSettlementPayRecTypeId)  
                                payment.RecordTypeId = settlementPayRecTypeId;  
                            else if(payment.RecordTypeId==leadDraftPayRecTypeId)
                                payment.RecordTypeId = draftPayRecTypeId;
                            else if(payment.RecordTypeId==leadLoanPayRecTypeId)
                                payment.RecordTypeId = LoanPayRecTypeId;
                            else if(payment.RecordTypeId==leadRefundLoanPayRecTypeId)
                                payment.RecordTypeId = RefundloanPayRecTypeId;
                            
                                
                        }
                        update paymentsList;
                    }
                    // Update Related DraftFees with Opportunity Id
                    List<Opportunity_Draft_Fee__c> draftFeesList = [Select Id,   Lead__c, Opportunity_Name__c from Opportunity_Draft_Fee__c where 
                                                                    Lead__c =:newLead[0].Id];
                    if(draftFeesList != null  && draftFeesList.size() > 0){
                        for(Opportunity_Draft_Fee__c draftFees:draftFeesList){
                            draftFees.Opportunity_Name__c = newLead[0].ConvertedOpportunityId;
                        }
                        update draftFeesList;
                    }
                    
                    //Updated Related Notes and Attachments
                    updateRelatedNotesAndAttachments(newLead[0]);                       
                    
                    // Call Webservice to update new Opportunity - Callout not allowed from trigger hence commented
                   // pullOpportunityTradeLinePaymentsClass.pullProgramDetailsFromNuDebt(o.Import_Program_Id__c );
                    PrizmOpportunityPullServiceQueueable queueableService = new PrizmOpportunityPullServiceQueueable(o.Import_Program_Id__c);
                    if(!Test.isRunningTest()){  
                        ID jobID = System.enqueueJob(queueableService); 
                    }
                   
                }   
                
            }
        }
        }catch(exception e){
            String S1 = e.getMessage();
            S1 = S1.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': [');
            Trigger.New[0].adderror(S1);
        }
    }
    
    
        /*
        * Create an event for converted leads 
        */

    public static void createEventOnConvert(List<Lead> pNewLeadList){
        if(pNewLeadList != null){
            List<Event> onConvertEvents = new List<Event>();
            List<Id> convertedContactIds = new List<Id>();
            List<Id> convertedAccountIds = new List<Id>();
            List<Id> convertedOpportunityIds = new List<Id>();
            for(Lead leadRec : pNewLeadList){
                if(leadRec.IsConverted == true){
                if(leadRec.ConvertedContactId != null)
                	convertedContactIds.add(leadRec.ConvertedContactId);
                if(leadRec.ConvertedOpportunityId != null)
                    convertedOpportunityIds.add(leadRec.ConvertedOpportunityId);
                 if(leadRec.convertedAccountId != null)
                    convertedAccountIds.add(leadRec.convertedAccountId);
                }
               
            }
            List<Task> leadTaskList = [Select Id, WhoId, Status, Call_Result__c, Due_Date_Time__c, ActivityDate, Subject, LastModifiedDate  from Task where 
                                       WhoId =:convertedContactIds 
                                       and Status != 'Completed' order by LastModifiedDate DESC];
            List<Opportunity> newOppList = [Select Id, ownerId from Opportunity where Id =:convertedOpportunityIds]   ;
            Map<Id, Task> taskContactMap = new Map<Id, Task>();
            Map<Id, Opportunity> oppIdMap = new Map<Id, Opportunity>();
            Task task;
            System.debug('leadTaskList = ' + leadTaskList);
            if(leadTaskList != null && leadTaskList.size() > 0){
                for(Task t:leadTaskList){
                    if(t.Call_Result__c!= null && t.Call_Result__c != ''
                       && (t.Call_Result__c == 'Schedule Appointment' || t.Call_Result__c == 'Warm Transfer'))
                    taskContactMap.put(t.WhoId, t);
                }
            }
            if(newOppList != null){
                for(Opportunity o:newOppList){
                    oppIdMap.put(o.Id, o);
                }
            }
            for(Lead leadRec : pNewLeadList){
                System.debug(loggingLevel.ERROR,'leadRec:---'+leadRec);
                Event e = new Event();
                e.WhoId = leadRec.ConvertedContactId;
                e.WhatId=leadRec.ConvertedOpportunityId ;
                if(taskContactMap.containsKey(e.WhoId))
                    task = taskContactMap.get(e.WhoId);
                if(task!= null && task.Subject != null && task.Subject != '' ){
                	e.Subject = task.Subject;
                }else
                    e.Subject = 'Meeting';
                if(oppIdMap != null && oppIdMap.containsKey(leadRec.ConvertedOpportunityId)){
                    Opportunity opp = oppIdMap.get(leadRec.ConvertedOpportunityId);
                    e.OwnerId= opp.OwnerId; 
                }else
                	e.OwnerId= leadRec.OwnerId; 
               
                e.StartDateTime=task.Due_Date_Time__c;
                e.DurationInMinutes = 30; //Event set for 30 minutes as per the requirement.
                e.ActivityDateTime = task.Due_Date_Time__c;
               
                e.Opportunity_Stage__c = 'DNL Prospecting';
                
                onConvertEvents.add(e);
            }
            insert onConvertEvents;
            if(leadTaskList != null)
                delete leadTaskList;
        }
        
    }
    //-----------------------------------------------------------------
    //Update Related Notes and Attachments
    //-----------------------------------------------------------------
    private static void updateRelatedNotesAndAttachments(Lead newLead){
        Set<Id> contentDocumentIds = new Set<Id>();
        //get all contentdocumentids so that you can query on contentnote
        List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:newLead.Id];
        if(contentDocumentLinkList != null){
            for(ContentDocumentLink conDoc :contentDocumentLinkList){
                contentDocumentIds.add(conDoc.ContentDocumentId);
            }
            //get all the content notes using contentDocumentIds
            List<ContentNote> contentNotes = [SELECT Id, Title, Content from ContentNote where Id In: contentDocumentIds];
            
            List<ContentNote> nte = new List<ContentNote>();
            List<ContentDocumentLink> lnk = new List<ContentDocumentLink>();
            if(contentNotes != null){
               
                // Insert into ContentDocumentLink
                for(ContentNote n : contentNotes){
                    ContentDocumentLink clnk = new ContentDocumentLink();
                    clnk.LinkedEntityId = newLead.ConvertedOpportunityId;
                    clnk.ContentDocumentId = n.Id;
                    clnk.ShareType = 'I';
                    lnk.add(clnk);
                }
                
                if(nte.size()>0){
                    insert lnk;
                }
            }
    	}
            
        
    }
    // --------------------------------------------------------------------------
    // Get existing lead accounts based on File numbers
    // --------------------------------------------------------------------------
    public static List<Account> returnExistingAccountsBasedOnFileNumbers(List<Lead> leadsList){
        List<Account> accountsList = new List<Account>();
        if(leadsList != null){            
            Set<String> fileNumbers = new Set<String>();
            for(Lead leadRec:leadsList){
                fileNumbers.add(leadRec.NDS_File_Number__c);
            }
            if(fileNumbers != null){
                accountsList = [Select Id, NDS_File_Number__c from Account where NDS_File_Number__c=:fileNumbers];
                
            }
                
        }        
        return accountsList;
    }
    
}