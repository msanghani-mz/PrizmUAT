/**
 * @File Name          : Prizm_TaskHandler.cls
 * @Description        : 
 * @Author             : Abhinav
 * @Group              : 
 * @Last Modified By   : Abhinav
 * @Last Modified On   : 4/28/2020, 9:38:38 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/28/2020   Abhinav     Initial Version
**/
public without sharing class Prizm_TaskHandler {
    public Static boolean leadStatus = false;
    public static void Prizm_UpdateLeadStatus(List<Task> TaskNewList
                                             ){
                                                 System.debug(loggingLevel.Error,'*******prizm_task_handler**********');
                                                 Map<Id,Task> LeadTaskMap =new Map<Id,Task>();
                                                 List<Id> LeadIds = new List<Id>();
                                                 if(Prizm_TaskHandler.leadStatus == false){
                                                     
                                                     for(Task t: TaskNewList){
                                                         System.debug(loggingLevel.Error,t.whoId);
                                                         if(t.whoId != null){
                                                             String sObjName = t.WhoId.getSObjectType().getDescribe().getName();
                                                             System.debug(loggingLevel.Error,sObjName);
                                                             if(sObjName.equalsIgnoreCase('Lead') 
                                                                //&& t.status == 'Completed' 
                                                                //&& (TaskOldMap == null || TaskOldMap.get(t.id)== null  || TaskOldMap.get(t.id).status != 'Completed')
                                                               ){
                                                                   LeadIds.add(t.WhoId);
                                                                   LeadTaskMap.put(t.WhoId,t);
                                                               }
                                                         }
                                                     }
                                                 }
                                                 if(LeadIds != null && LeadIds.size() != 0){
                                                     List<LeadStatusMapping__c> leadStatusMapList = LeadStatusMapping__c.getAll().Values();
                                                     
                                                     Map<String,List<String>> SubStatusMap = new Map<String,List<String>>();
                                                     Map<String,String> statusMap = new Map<String,String>();
                                                     Map<String, List<String>> nameSubStatusMap = new Map<String, List<String>>();                                       
                                                     for(LeadStatusMapping__c LeadStatMap : leadStatusMapList){
                                                         if(!SubStatusMap.containsKey(LeadStatMap.Sub_Status__c)){
                                                             SubStatusMap.put(LeadStatMap.Sub_Status__c,new List<String>());
                                                         }if(!statusMap.containsKey(LeadStatMap.Status_List__c)){
                                                             statusMap.put(LeadStatMap.Status_List__c,LeadStatMap.Sub_Status__c);
                                                         }if(!nameSubStatusMap.containsKey(LeadStatMap.Name)){
                                                             nameSubStatusMap.put(LeadStatMap.Name,new List<String>());
                                                         }
                                                         List<String> statusList = LeadStatMap.Status_List__c.Split(',');
                                                         SubStatusMap.get(LeadStatMap.Sub_Status__c).addAll(statusList);
                                                         nameSubStatusMap.get(LeadStatMap.Name).addAll(statusList);
                                                     }
                                                     List<Lead> LeadList = [Select Id, Name, Email, NDS_File_Number__c, Lead_Status_Text__c, Processor_Name__c, isConverted, Sub_Status__c,Account__c,  OwnerId from Lead where Id = :LeadIds];
                                                     List<Lead> convertedLeads = new List<Lead>();
                                                     for(Lead l:LeadList){
                                                         System.debug('Reason = ' + LeadTaskMap.get(l.Id).Reason__c);
                                                         System.debug('Call result = ' + LeadTaskMap.get(l.Id).Call_Result__c);
                                                         if(LeadTaskMap.containsKey(l.id) && LeadTaskMap.get(l.Id).Call_Result__c != null && LeadTaskMap.get(l.Id).Call_Result__c != ''){
                                                             if(LeadTaskMap.get(l.Id).Call_Result__c.trim()  == 'Schedule Appointment' || LeadTaskMap.get(l.Id).Call_Result__c.trim()  == 'Warm Transfer'){
                                                                 if(SubStatusMap.containsKey(LeadTaskMap.get(l.Id).Call_Result__c)){
                                                                     l.Lead_Status_Text__c =  (SubStatusMap.get(LeadTaskMap.get(l.Id).Call_Result__c)).get(0);
                                                                     l.Status 	= 	  l.Lead_Status_Text__c; 
                                                                     l.Sub_Status__c =LeadTaskMap.get(l.Id).Call_Result__c.trim();
                                                                 }
                                                                 
                                                                 convertedLeads.add(l);
                                                             }else if(LeadTaskMap.get(l.Id).Reason__c != null && LeadTaskMap.get(l.Id).Call_Result__c != ''){
                                                                 l.Status = 		  LeadTaskMap.get(l.Id).Call_Result__c.trim();
                                                                 l.Lead_Status_Text__c = 		  LeadTaskMap.get(l.Id).Call_Result__c.trim();
                                                                 l.Sub_Status__c = LeadTaskMap.get(l.Id).Reason__c.trim();
                                                             }else{
                                                                 List<String> pStatusList;
                                                                 System.debug('LeadTaskMap.get(l.Id).Call_Result__c.trim() = ' + LeadTaskMap.get(l.Id).Call_Result__c.trim());
                                                                 if(nameSubStatusMap.containsKey(LeadTaskMap.get(l.Id).Call_Result__c.trim()))
                                                                     pStatusList = nameSubStatusMap.get(LeadTaskMap.get(l.Id).Call_Result__c.trim());
                                                                 else if(SubStatusMap.containsKey(LeadTaskMap.get(l.Id).Call_Result__c)){   
                                                                     System.debug('Call Result = ' + LeadTaskMap.get(l.Id).Call_Result__c);
                                                                     pStatusList = SubStatusMap.get(LeadTaskMap.get(l.Id).Call_Result__c);
                                                                 }
                                                                 System.debug('pStatusList = ' + pStatusList);
                                                                 if(pStatusList != null && pStatusList.size() != 0){
                                                                     if(pStatusList.size() == 1){
                                                                         l.Lead_Status_Text__c = pStatusList.get(0).trim();
                                                                         l.Status = l.Lead_Status_Text__c;
                                                                         if(statusMap.containsKey(l.Lead_Status_Text__c))
                                                                             l.Sub_Status__c = statusMap.get(l.Lead_Status_Text__c).trim();
                                                                     }else{
                                                                         for(Integer i=0; i<pStatusList.size(); i++){
                                                                             if(LeadTaskMap.get(l.Id).Reason__c == null && LeadTaskMap.get(l.Id).Call_Result__c != null){  
                                                                                 l.Sub_Status__c = LeadTaskMap.get(l.Id).Call_Result__c.trim();
                                                                                 System.debug('Status = ' + l.Lead_Status_Text__c + '___' + pStatusList.get(i));
                                                                                 if(l.Lead_Status_Text__c == pStatusList.get(i)){
                                                                                     if(i<pStatusList.size()-1){
                                                                                         l.Lead_Status_Text__c = pStatusList.get(i+1).trim();
                                                                                         l.Status = l.Lead_Status_Text__c;
                                                                                         System.debug('Lead_Status_Text__c  = ' +  pStatusList.get(i+1).trim());
                                                                                         if(statusMap.containsKey(l.Lead_Status_Text__c)){
                                                                                             l.Sub_Status__c = statusMap.get(l.Lead_Status_Text__c).trim();
                                                                                             System.debug('Sub_Status__c  = ' +  statusMap.get(l.Lead_Status_Text__c).trim());
                                                                                         }
                                                                                         break;
                                                                                     }else if(i >= pStatusList.size()-1){
                                                                                         l.Lead_Status_Text__c = pStatusList.get(0).trim();
                                                                                         l.Status = l.Lead_Status_Text__c;
                                                                                         if(statusMap.containsKey(l.Lead_Status_Text__c))
                                                                                             l.Sub_Status__c = statusMap.get(l.Lead_Status_Text__c).trim();
                                                                                     }
                                                                                 }else if(i >= pStatusList.size()-1){
                                                                                     l.Lead_Status_Text__c = pStatusList.get(0).trim();
                                                                                     l.Status = l.Lead_Status_Text__c;
                                                                                     if(statusMap.containsKey(l.Lead_Status_Text__c))
                                                                                         l.Sub_Status__c = statusMap.get(l.Lead_Status_Text__c).trim();
                                                                                 }
                                                                             }
                                                                         }
                                                                     }
                                                                 }
                                                                 
                                                             }    
                                                             
                                                         }
                                                         l.Status = l.Lead_Status_Text__c;
                                                     }
                                                     System.debug('**** convertedLeads '+convertedLeads);
                                                     if(convertedLeads != null && convertedLeads.size() > 0){
                                                         Update convertedLeads;      
                                                         convertLeads(convertedLeads);
                                                     } else{
                                                         System.debug('****'+LeadList);
                                                         Update LeadList;       
                                                     }
                                                 }
                                                 Prizm_TaskHandler.leadStatus = true;
                                                 
                                             }
    //--------------------------------------------------------------------------------------------
    
    private static Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    }
    
    private static void convertLeads(List<Lead> leads){
        if(leads.size() > 0){
            Boolean leadHasPaymentsAndTradelines = validatePaymentsAndTradelinesForLeadConvert(leads);
            if(leadHasPaymentsAndTradelines){
                List<Database.LeadConvert> convList= new List<Database.LeadConvert>();
                
                LeadStatus convertStatus = [SELECT Id
                                                 , MasterLabel
                                                 , IsConverted 
                                              FROM LeadStatus 
                                              WHERE IsConverted=true 
                                                AND APIName = 'DNL Converted' 
                                              LIMIT 1];

                List<Account> accList = PrizmLeadTriggerHandler.returnExistingAccountsBasedOnFileNumbers(leads);
                Map<String, Account> accToFileNumberMap = new Map<String, Account>();
                if(accList != null){
                    for(Account acc:accList){
                        accToFileNumberMap.put(acc.NDS_File_Number__c, acc);
                    }
                    
                }
                for(Lead leadObj:leads){
                    
                    Database.LeadConvert lc = new Database.LeadConvert();                
                    lc.setLeadId(leadObj.Id);
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    if(accToFileNumberMap != null && accToFileNumberMap.containsKey(leadObj.NDS_File_Number__c)){
                        Account a = accToFileNumberMap.get(leadObj.NDS_File_Number__c);
                        lc.setAccountId(a.Id);
                    }
                    
                    convList.add(lc);
                }
                try{
                    List<Database.LeadConvertResult> lcResults;
                    if (convList != null && convList.size() >0 ){
                        lcResults = Database.convertLead(convList);
                    }
                    System.debug('**** lcResults '+lcResults);
                    
                }Catch(Exception exp){
                    System.debug('**** error '+exp.getMessage());
                    //String S1 = exp.getMessage();
                    //S1 = S1.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': [');
                    Trigger.New[0].adderror(exp.getMessage());
                }
            }else{
                String S1 = 'No valid tradeline and payment exist for this lead.';
                Trigger.New[0].adderror(S1);
            }
            
        }
    }
    
 //--------------------------------------------------------------------------------------------
    public static Boolean validatePaymentsAndTradelinesForLeadConvert(List<Lead> leads){
        Boolean returnFlag = false;
        Integer tradelineCount = [Select count() from Opportunity_Tradelines_Offer__c where  Lead__c = :leads ];
        Integer paymentCount = [Select count() from Opportunity_Payment__c where  Lead__c = :leads ];
        if(tradelineCount != null && paymentCount != null && tradelineCount > 0 && paymentCount > 0){
            returnFlag = true;
        }
        return returnFlag;
    }
 //--------------------------------------------------------------------------------------------
    public static List<Task> setTaskStatusForLeadConvertBeforeInsertUpdate(List<Task> taskNewList){
        Id DNLTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Lead Task').getRecordTypeId();
        if(taskNewList != null){
            for(Task t:taskNewList){
                if(t.whoId != null){
                    String sObjName = t.WhoId.getSObjectType().getDescribe().getName();
                    System.debug(loggingLevel.Error,sObjName);
                    if(sObjName.equalsIgnoreCase('Lead')){                    
                        t.RecordTypeId = DNLTaskRecordTypeId;
                        if(t.Due_Date_Time__c != null ){
                            Datetime dueDateTime = t.Due_Date_Time__c;
                            t.ActivityDate = dueDateTime.date();
                            t.Due_Time__c = dueDateTime.time();
                            Datetime now = Datetime.now();
                            Integer offset = UserInfo.getTimezone().getOffset(now);
                            Datetime local = now.addSeconds(offset/1000);
                            System.debug('t.dueDateTime = ' +dueDateTime + '___' + local);
                            if(dueDateTime <= now){
                                System.debug('t.Call_Result__c = ' +t.Call_Result__c );
                                if(t.Call_Result__c != null && t.Call_Result__c != '' ){
                                    String callResult = t.Call_Result__c.trim();
                                    if(callResult != 'Schedule Appointment' || callResult != 'Warm Transfer')
                                        t.Status = 'Completed';
                                }
                            }

                        }else
                            if(t.Call_Result__c != null && t.Call_Result__c != '' ){
                                String callResult = t.Call_Result__c.trim();
                                if(callResult != 'Schedule Appointment' || callResult != 'Warm Transfer')
                                    t.Status = 'Completed';
                            }
                    }
                }
            }
        }
        
        return taskNewList;
    }
}