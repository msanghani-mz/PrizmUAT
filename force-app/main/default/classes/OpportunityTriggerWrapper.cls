/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - OpportunityTriggerWrapper
 * 
 * Description   - This is a wrapper class for all the trigger events of 
 *                 Opportunity (Object : Opportunity)
 * 
 * Developer(s)  - System Generated
 * 
 */
global with sharing class OpportunityTriggerWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'OpportunityTriggerWrapper';
    private static final String TRIGGER_NAME = 'OpportunityTrigger';
    
    public static boolean mIsExecuting = false;
    public static boolean mIsExecutingUpdateDoNotCall = false;

    private OpportunityTriggerWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }

    private static OpportunityTriggerWrapper mInstance = null;

    /* Method to get the only instance available */
    global static OpportunityTriggerWrapper getInstance(){
        if (mInstance == null) mInstance = new OpportunityTriggerWrapper();
        return mInstance;
    }

    global override void beforeInsert(List<sObject> pNewRecList) {
        //THIS IS THE DUMMY UPDATE BECAUSE I HAVE A VALIDATION RULE.
        //I AM TAKING CARE OF CORRECT UPDATE ON Opportunity_Type__c IN POST INSERT BASED ON THE RECORD TYPE
        
        /*for (Opportunity opp : (List<Opportunity>) pNewRecList){
            if(opp.Opportunity_Type__c == null)
            {
                opp.Opportunity_Type__c ='DNL';
            }
        }   */
        //Made changes for both type of opportunity i.e Peerform & DNL from Nudebt.
        //THIS CODE ADDED BY SKAMBLE
        Map<String,Opportunity> emailToOpportunityMap = new Map<String, Opportunity>();
        System.debug(loggingLevel.ERROR, pNewRecList);
        Set<String> opportunityNameSet = new Set<String>();
        for (Opportunity opp : (List<Opportunity>) pNewRecList){
            if (opp.Lead_Record_Type__c=='Borrower'){
                opp.Opportunity_Type__c ='Loan';
            }
            else if(opp.Opportunity_Type__c == null){
                opp.Opportunity_Type__c ='DNL';
            }
            System.debug(loggingLevel.Error, opp.Applicant_s_Email__c);
            if(opp.Applicant_s_Email__c != null){
                emailToOpportunityMap.put(opp.Applicant_s_Email__c, opp);
            }if(opp.Name != null)
                opportunityNameSet.add(opp.Name);
        }
        setRecordType(pNewRecList);
        System.debug(loggingLevel.Error, emailToOpportunityMap);
        System.debug(loggingLevel.Error, opportunityNameSet);
        setPaymentProcessorName(emailToOpportunityMap,opportunityNameSet);
    }

    private void setRecordType(List<sObject> pNewRecList){
    
        Map<String, Schema.RecordTypeInfo> oppRecTypeMap = Schema.SObjectType.opportunity.getRecordTypeInfosByDeveloperName();
        for (Opportunity opp : (List<Opportunity>) pNewRecList){
            if (opp.Opportunity_Type__c != null){
                
                if(opp.Opportunity_Type__c =='DNL'){
                    opp.RecordTypeId = oppRecTypeMap.get('DNL').getRecordTypeId();
                }else if(opp.Opportunity_Type__c =='CL'){
                    opp.RecordTypeId = oppRecTypeMap.get('CL').getRecordTypeId();
                }else if(opp.Opportunity_Type__c =='DI'){
                    opp.RecordTypeId = oppRecTypeMap.get('Debt_Investment').getRecordTypeId();
                }else if(opp.Opportunity_Type__c =='EI'){
                    opp.RecordTypeId = oppRecTypeMap.get('Equity_Investment').getRecordTypeId();
                }else if(opp.Opportunity_Type__c =='Loan'){
                    opp.RecordTypeId = oppRecTypeMap.get('Loan').getRecordTypeId();
                }else if(opp.Opportunity_Type__c =='PL'){
                    opp.RecordTypeId = oppRecTypeMap.get('PL').getRecordTypeId();
                }else{
                    opp.RecordTypeId = oppRecTypeMap.get('DNL').getRecordTypeId();
                }                

            }
        }
    }
    // -------------------------------------------------------------------------------------------
    // For Updating the Opportunity Payment processor name for converted Leads. -- DLM Migration
    //  -------------------------------------------------------------------------------------------
    private void setPaymentProcessorName(Map<String, Opportunity> emailToOpportunityMap, Set<String> opportunityNameSet){
        if(emailToOpportunityMap != null){
            Set<String> emailIds = emailToOpportunityMap.keySet();
            //List<Lead> leadsList = [Select Id,  email, Processor_Name__c from Lead where email = :emailIds and NuDebtAccountName__c like :opportunityNameSet AND Latest_Lead__c = true order by createdDate DESC Limit 1];
            List<Lead> leadsList = [Select Id,  email, Processor_Name__c, createdDate  from Lead where email = :emailIds order by createdDate DESC Limit 1] ;
            System.debug(loggingLevel.ERROR, leadsList);
            if(leadsList != null){
                for(Lead lead:leadsList ){
                    if(emailToOpportunityMap.containsKey(lead.email)){
                        Opportunity opp = emailToOpportunityMap.get(lead.email);
                        if(opp.Opportunity_Type__c =='DNL')
                        	opp.StageName = 'DNL Prospecting';
                        if(opp.Payment_Processor_Name__c == null){
                            if(lead.Processor_Name__c.contains('CFT'))
                                opp.Payment_Processor_Name__c = 'CFT';
                            if(lead.Processor_Name__c.contains('GCS'))
                                opp.Payment_Processor_Name__c = 'GCS';
                            if(lead.Processor_Name__c.contains('RAM'))
                                opp.Payment_Processor_Name__c= 'RAM';
                        }
                    }
                }
            }
            
        }              
    }
    // -------------------------------------------------------------------------------------------
    // For creating Co-Applicant Account. -- DLM Migration
    //-------------------------------------------------------------------------------------------
    private void createCoApplicantAccount(List<Opportunity> pNewRecList){
        Map<String, Opportunity> emailToOpportunityMap = new Map<String, Opportunity>();
        List<Account> coApplicantAccountList = new List<Account>();
        if(pNewRecList != null){
            for(Opportunity opp: pNewRecList){
                emailToOpportunityMap.put(opp.Applicant_s_Email__c, opp);
            }
        }
        System.debug('emailToOpportunityMap = ' + emailToOpportunityMap);
        if(emailToOpportunityMap != null){
            Set<String> emailIds = emailToOpportunityMap.keySet();
            List<Lead> leadsListWithCoApplicantDetails = [Select Id, email, Co_Applicant_First_Name__c, Co_Applicant_Middle_Name__c, Co_Applicant_Last_Name__c, 
                                                      Co_Applicant_Phone__c, Co_Applicant_SSN__c, Co_Applicant_State__c, Co_Applicant_Email__c from Lead 
                                                      where email = :emailIds];
             System.debug('leadsListWithCoApplicantDetails = ' + leadsListWithCoApplicantDetails);
            List<Account> listOfExistingAccounts = [Select Id, PersonEmail, FirstName, LastName from Account where PersonEmail = :emailIds ];
            System.debug('listOfExistingAccounts = ' + listOfExistingAccounts);
            if(leadsListWithCoApplicantDetails != null && listOfExistingAccounts == null){
                 RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
                for(Lead lead:leadsListWithCoApplicantDetails){
                    if(emailToOpportunityMap.containsKey(lead.email)){
                        Opportunity opp = emailToOpportunityMap.get(lead.email);
                        if(opp.AccountId != null){
                            
                            Account newPersonAccount = new Account();
                            
                            // for person accounts we can not update the Name field instead we have to update the    FirstName and LastName individually                            
                            newPersonAccount.FirstName = lead.Co_Applicant_First_Name__c;
                            newPersonAccount.LastName = lead.Co_Applicant_Last_Name__c;
                            newPersonAccount.MiddleName = lead.Co_Applicant_Middle_Name__c;
                            newPersonAccount.Phone    = lead.Co_Applicant_Phone__c;
                            newPersonAccount.PersonEmail= lead.Co_Applicant_Email__c;
                            newPersonAccount.SSN__c       = lead.Co_Applicant_SSN__c;
                            newPersonAccount.BillingState   = lead.Co_Applicant_State__c;
                            newPersonAccount.RecordType = personAccountRecordType;
                            coApplicantAccountList.add(newPersonAccount);
                        }
                    }
                        
                }
            }
        }
        System.debug('coApplicantAccountList = ' + coApplicantAccountList);
        insert coApplicantAccountList;
    }
    //-------------------------------------------------------------------------------------------
    global override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        for (opportunity newAppRec : (List<opportunity>)pNewRecList){
            if (newAppRec.Related_Lending_Application__c != null && ((opportunity)pOldRecMap.get(newAppRec.id)).Related_Lending_Application__c != null){
                if (newAppRec.Is_Application_Submitted__c && !((opportunity)pOldRecMap.get(newAppRec.id)).Is_Application_Submitted__c){
                    newAppRec.addError('Application :'+((opportunity)pOldRecMap.get(newAppRec.id)).Related_Lending_Application__c+' is already submitted for underwriting. ');
                }
            }            
        }
    }

    global override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}

    global override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        setOppName((List<Opportunity>) pNewRecList);  
        //createCoApplicantAccount((List<Opportunity>) pNewRecList);
    }

    global override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        //setOppName((List<Opportunity>) pNewRecList);  
        updateClientNotInterested((List<Opportunity>) pNewRecList, (Map<Id, Opportunity>) pOldRecMap);    
        updateSSN((List<Opportunity>) pNewRecList);    //DV-219
        cancelOpportunity((List<Opportunity>) pNewRecList, (Map<Id, Opportunity>) pOldRecMap); //DV-520
       // createCoApplicantAccount((List<Opportunity>) pNewRecList);
    }

    global override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}

    global override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}

    private List<Opportunity> getOpportunities(List<Opportunity> pOpportunityList){
        Set<ID> oppIds = new Set<ID>();
        for (Opportunity opp : pOpportunityList){
            oppIds.add(opp.Id);
        }

        List<Opportunity> oppList = [SELECT Id,name,Opportunity_Number__c,Opportunity_Type__c,Co_Applicant_Name__c,Is_Do_Not_Call__c,StageName,Import_Program_Id__c,Import_Id__c , RecordType.DeveloperName,AccountId,Account.Name,Account.PersonDoNotCall from Opportunity where id IN :oppIds];
        return oppList;        
    }

    private void setOppName(List<Opportunity> pOpportunityList){
        if( mIsExecuting ){
            // if was executed during the same context 
            // avoid recursion
            return;
        }
        mIsExecuting = true; 
        //list of new instance of object to update. 
        Opportunity[] opportunities = new Opportunity[]{}; //HACK TO UPDATE THE NAME ON POST INSERT
        
        List<Opportunity> oppList = getOpportunities(pOpportunityList);

Map<String, Schema.RecordTypeInfo> paymentRecTypeMap = Schema.SObjectType.opportunity.getRecordTypeInfosByDeveloperName();

        for (Opportunity opp : oppList){
            Opportunity opportunity  = new Opportunity(Id = opp.Id);  
            String oppNumber = opp.Opportunity_Number__c;
            if(opp.RecordType.DeveloperName.startsWith('DNL')){
                opportunity.Opportunity_Type__c ='DNL';
                //ONLY OVERWRIDING THE NAME FOR DNL LOANS
                opportunity.Name = oppNumber.replace('O-', '')+'-'+opportunity.Opportunity_Type__c +'-'+opp.Account.Name;

            }else if(opp.RecordType.DeveloperName.startsWith('CL')){
                opportunity.Opportunity_Type__c ='CL';
            }else if(opp.RecordType.DeveloperName.startsWith('Debt_Investment')){
                opportunity.Opportunity_Type__c ='DI';
            }else if(opp.RecordType.DeveloperName.startsWith('Equity_Investment')){
                opportunity.Opportunity_Type__c ='EI';
            }else if(opp.RecordType.DeveloperName.startsWith('Loan')){
                opportunity.Opportunity_Type__c ='Loan';
            }else if(opp.RecordType.DeveloperName.startsWith('PL')){
                opportunity.Opportunity_Type__c ='PL';
            }else{
                opportunity.Opportunity_Type__c ='Others';
            }
            
            opportunities.add(opportunity);
        }

        /*for (Opportunity opp : (List<Opportunity>) pNewRecList){
            if(opp.RecordType.DeveloperName.startsWith('DNL')){
                opp.Opportunity_Type__c ='DNL';
            }
        } */ 

        update opportunities;
    }  

    //DV-219
    private void updateSSN(List<Opportunity> pOpportunityList){  
        Set<ID> accountIds = new Set<ID>();
        for (opportunity opp : pOpportunityList){
            if ((opp.StageName == 'Closed Won')
                ||(opp.StageName == 'Closed Lost')){

                accountIds.add(opp.AccountId);
                if (opp.Co_Applicant_Name__c != null){
                    accountIds.add(opp.Co_Applicant_Name__c);    
                }
            }
        }       
        if (accountIds.size()> 0) {
            List<Account> accountsList = [Select Id ,PersonDoNotCall,SSN__c,nu_dse__SSN__c,fsCore__National_Identification_Number__pc FROM Account where Id IN: accountIds];
            for (Account acc : accountsList){
                if (acc.fsCore__National_Identification_Number__pc != null){
                    
                    if (acc.fsCore__National_Identification_Number__pc.length() <= 11){
                        acc.nu_dse__SSN__c = acc.fsCore__National_Identification_Number__pc;
                    }
                    
                    String ssn = acc.fsCore__National_Identification_Number__pc.replace('-','');
                    //Since acc.SSN__c is 9 digits so make sure don't insert more than 9
                    if (ssn.length() ==9){
                        acc.SSN__c  = ssn;
                    }
                }
            }
            update accountsList;
        }
    }


    private void updateClientNotInterested(List<Opportunity> pOpportunityList, Map<Id, Opportunity> pOldRecMap){  
        if( mIsExecutingUpdateDoNotCall ){
            // if was executed during the same context 
            // avoid recursion
            return;
        }
        mIsExecutingUpdateDoNotCall = true; 

        List<Account> isAccToUpdate = new List<Account>();
        List<Opportunity> oppList = getOpportunities(pOpportunityList);
        Set<ID> programIds = new Set<ID>();
        MAP<ID,ID> programIdToOppMap = new Map <ID,ID>();

        Set<ID> accountIds = new Set<ID>();
        for (opportunity opp : oppList){
            accountIds.add(opp.AccountId);
            if (opp.Co_Applicant_Name__c != null){
                accountIds.add(opp.Co_Applicant_Name__c);    
            }
            
        }
        
        Map<Id,Account> accountsMap = new Map<Id,Account>([Select Id ,PersonDoNotCall FROM Account where Id IN: accountIds]);        

        for (opportunity newOppRec : oppList){
            if ((newOppRec.StageName != ((opportunity)pOldRecMap.get(newOppRec.id)).StageName)
                && (newOppRec.StageName == 'DNL - Not interested')){
                Account acc = accountsMap.get(newOppRec.AccountId);
                acc.PersonDoNotCall = newOppRec.Is_Do_Not_Call__c;
                isAccToUpdate.add(acc);
                if (newOppRec.Import_Program_Id__c != null){
                    programIds.add(Id.valueOf(newOppRec.Import_Program_Id__c));
                    programIdToOppMap.put(Id.valueOf(newOppRec.Import_Program_Id__c),newOppRec.Id);
                }
            }            
        }
        
        if(!isAccToUpdate.isEmpty()){
           update isAccToUpdate; 
           //Call Third Party
           NuDebtIntegrate.updateDNLStatusNotInterested(programIds,programIdToOppMap); 
        }
    }

    public static void cancelOpportunity(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
        // Deactivate portal users related to opportunity
        Set<Id> accountIds = new Set<Id>();
        // Set docu sign document status to void
        Set<Id> opportunityIds = new Set<Id>();

        // Allow only system administrator to set 'COVID - Cancelled' reason for close lost
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id = :profileId].Name;
        for (Opportunity newOpp: newOpportunities) {
            Opportunity oldOpp = oldOpportunityMap.get(newOpp.Id);
            if(newOpp.StageName == 'Closed Lost' && newOpp.StageName != oldOpp.StageName) {
                if (newOpp.Closed_Lost_Reason__c == 'COVID - Cancelled' && newOpp.Closed_Lost_Reason__c != oldOpp.Closed_Lost_Reason__c) {
                    
                    if (profileName != 'System Administrator')  {
                        newOpp.addError('Only system administrator can set the closed lost reason "COVID - Cancelled". Please contact your system administrator.');
                        return;
                    }
                }
                opportunityIds.add(newOpp.Id);
                if (!String.isEmpty(newOpp.accountId)) {
                    accountIds.add(newOpp.accountId);
                }
                if (!String.isEmpty(newOpp.Applicant_Name__c)) {
                    accountIds.add(newOpp.Applicant_Name__c);
                }
                if (!String.isEmpty(newOpp.Co_Applicant_Name__c)) {
                    accountIds.add(newOpp.Co_Applicant_Name__c);
                }
            }
        }
        system.debug('++++++++accountIds+++++'+accountIds);
        // get docu sign status records related to opportunities
        Set<String> envelopeIds = new Set<String>();
        for (dsfs__DocuSign_Status__c docuSignStatus: [Select Id, dsfs__DocuSign_Envelope_ID__c from dsfs__DocuSign_Status__c where dsfs__Opportunity__c IN :opportunityIds and dsfs__Envelope_Status__c = 'Sent']) {
            envelopeIds.add(docuSignStatus.dsfs__DocuSign_Envelope_ID__c);
        }

        // call future method to void docu sign documents
        if (!envelopeIds.isEmpty()) {
            system.debug('++++++++void document+++++');
            setDocuSignStatusVoid(envelopeIds);
        }

        // call future method to deactivate portal users
        if (!accountIds.isEmpty()) {
            system.debug('++++++++deavtivate portal+++++');
            /*List<Account> accountToUpdate = new List<Account>();
            for (Account acc: [Select Id, IsCustomerPortal from Account Where Id IN :accountIds and IsCustomerPortal = true]) {
                acc.IsCustomerPortal = false;
                accountToUpdate.add(acc);
            }
            if (!accountToUpdate.isEmpty()) {
                update accountToUpdate;
            }*/
            deactivatePortalUsers(accountIds);
        }
    }

    @future (callout=true)
    public static void setDocuSignStatusVoid(Set<String> envelopIds){
        for (String envelopId: envelopIds) {
            DocuSignAPI.VoidEnvelopeStatus vEnvelopeStatus = DocusignAPIUtil.VoidEnvelope(envelopId);
            system.debug(logginglevel.error,'vEnvelopeStatus.VoidSuccess :'+vEnvelopeStatus.VoidSuccess);
        }
    }

    @future
    public static void deactivatePortalUsers(Set<Id> accountIds){
        List<Account> accountToUpdate = new List<Account>();
            for (Account acc: [Select Id, IsCustomerPortal from Account Where Id IN :accountIds and IsCustomerPortal = true]) {
                acc.IsCustomerPortal = false;
                accountToUpdate.add(acc);
            }
            if (!accountToUpdate.isEmpty()) {
                update accountToUpdate;
            }
        /*
        List<User> usersToUpdate = new List<User>();
        for (User portalUser: [Select Id, Name, IsActive from User where Contact.AccountId IN :accountIds and IsActive = true]) {
            portalUser.IsActive = false;
            usersToUpdate.add(portalUser);
        }
        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }*/
    }
}