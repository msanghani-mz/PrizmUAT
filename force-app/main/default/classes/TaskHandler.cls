/**
 * @File Name          : TaskHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 3/2/2020, 11:52:54 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/11/2019, 6:14:46 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class TaskHandler{
    
   private static Integer BUSINESS_HOURS_IN_A_DAY = 8;
   private static Integer END_OF_DAY_TASK_OFFSET_MINUTES = -1;

   //DV-193
   public static list<Task> updateDueDateToBusinessDate(list<Task> pNewTaskList, Boolean pIsEndOfDayTask){
       Id BusinessHourId = getBusinessHoursForPreSalesRep(); //Get the business hours of a Pre sales rep profile, if the logged in user belongs to this profile
       if(BusinessHourId == null)
       		BusinessHourId = fsCore.SpectraCoreUtil.getBusinessHourId('VLB');
       system.debug(logginglevel.error,' BusinessHourId :'+BusinessHourId);
       if (BusinessHourId != null){
            
            for(Task lTask : pNewTaskList){
                                
                System.debug(logginglevel.error,' lTask Due_Date_Time__c :'+lTask.Due_Date_Time__c);
                System.debug(logginglevel.error,' lTask Due_Time__c :'+lTask.Due_Time__c);
                System.debug(logginglevel.error,' lTask ActivityDate :'+lTask.ActivityDate);
                System.debug(logginglevel.error,' pIsEndOfDayTask :'+pIsEndOfDayTask);
                /*if(lTask.whoId != null){
                    String sObjName = lTask.WhoId.getSObjectType().getDescribe().getName();
                    System.debug(loggingLevel.Error,sObjName);
                    if(!sObjName.equalsIgnoreCase('Lead')){*/
                        if (lTask.Due_Date_Time__c != null){
                            if (!fsCore.DateUtilGlobal.isBusinessDay(lTask.Due_Date_Time__c, BusinessHourId)){
                                lTask.Due_Date_Time__c = BusinessHours.nextStartDate(BusinessHourId,lTask.Due_Date_Time__c);
                                if (pIsEndOfDayTask){
                                    lTask.Due_Date_Time__c = lTask.Due_Date_Time__c.addHours(BUSINESS_HOURS_IN_A_DAY);
                                    lTask.Due_Date_Time__c = lTask.Due_Date_Time__c.addMinutes(END_OF_DAY_TASK_OFFSET_MINUTES);
                                }
                            }else{
                                System.debug(logginglevel.error,' Valid Business Day');
                                //This is to handle the case where task always needs to be created at end of day
                                if (pIsEndOfDayTask){
                                    lTask.Due_Date_Time__c = datetime.newInstance(lTask.Due_Date_Time__c.year(),lTask.Due_Date_Time__c.month(),lTask.Due_Date_Time__c.day(),16,59,0);
                                }
                            }
                        }else{
                            if (lTask.ActivityDate != null){
                                if (lTask.Due_Time__c != null){
                                    lTask.Due_Date_Time__c = DateTime.newInstance(lTask.ActivityDate.Year(), lTask.ActivityDate.month(), lTask.ActivityDate.day(), lTask.Due_Time__c.hour(),lTask.Due_Time__c.minute(),lTask.Due_Time__c.second());
                                }else{
                                    lTask.Due_Date_Time__c = lTask.ActivityDate;
                                }
                                if (!fsCore.DateUtilGlobal.isBusinessDay(lTask.Due_Date_Time__c, BusinessHourId)){                            
                                    lTask.Due_Date_Time__c = BusinessHours.nextStartDate(BusinessHourId,lTask.Due_Date_Time__c);
                                    if (pIsEndOfDayTask){
                                        lTask.Due_Date_Time__c = lTask.Due_Date_Time__c.addHours(BUSINESS_HOURS_IN_A_DAY);
                                        lTask.Due_Date_Time__c = lTask.Due_Date_Time__c.addMinutes(END_OF_DAY_TASK_OFFSET_MINUTES);
                                    }                            
                                }
                            }
                        }
                        //By here we should already have the Due_Date_Time__c populated
                        if (lTask.Due_Date_Time__c != null){
                            lTask.Due_Time__c = lTask.Due_Date_Time__c.Time();
                            lTask.ActivityDate = date.newinstance(lTask.Due_Date_Time__c.year(), lTask.Due_Date_Time__c.month(), lTask.Due_Date_Time__c.day());
                        }
                   // }
               // }
                System.debug(logginglevel.error,' Final lTask.Due_Date_Time__c  :'+lTask.Due_Date_Time__c );
                System.debug(logginglevel.error,' Final lTask.Due_Time__c  :'+lTask.Due_Time__c );
                System.debug(logginglevel.error,' Final lTask.ActivityDate  :'+lTask.ActivityDate );
            } 
       }
       return pNewTaskList;
   }
   
   public static void PushNudebtTask(list<Task> TrigTask)
   {
    String jsonString;
           Map<String,List<Task>> datamap = new Map<String,List<Task>>();
         //this above map represent opportunity import id i.e(Import_Id__c) again list of task
          Set<Id> oppIdsSet = new Set<Id>();
          Id DNLTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
          String oppId; 
          String objId;
         for(Task eachTask : TrigTask){
           objId = eachTask.WhatId;
             if(objId!=null){
               String sObjName = eachTask.WhatId.getSObjectType().getDescribe().getName();
               if(sObjName.equalsIgnoreCase('Opportunity') && DNLTaskRecordTypeId == eachTask.RecordTypeId)
               {
                 oppId = eachTask.WhatId; 
                 oppIdsSet.add(oppId);
               }  
             }
                  
        }
       
         Map<Id,Opportunity> currentOppMap = new Map<Id,Opportunity>([SELECT Id,Import_Id__c FROM Opportunity WHERE Id IN : oppIdsSet]);
        
       if(currentOppMap.size()>0){
         for(Task eachTask : TrigTask){
            Opportunity existingOpp = currentOppMap.get(eachTask.WhatId);
            if(existingOpp != null && eachTask.Import_Id__c==null){  //To avoid call back
                if(datamap.get(existingOpp.Import_Id__c) == null){
                    List<Task> newTaskList = new List<Task>();
                    newTaskList.add(eachTask);
                    datamap.put(existingOpp.Import_Id__c,newTaskList);
                }
                else{
                   datamap.get(existingOpp.Import_Id__c).add(eachTask);
                }
            }
        }
       }
        if(datamap.size() > 0){
            try{
                jsonString = JSON.serialize(datamap);
                PushTaskToNudebt.pushTasksInNdebt(jsonString,'CreateTaskRecord');
            }
            catch(Exception e){
                system.debug('Exception'+e.getMessage());
            }
            
        }
    
   }
    public static void UpdateNuDebtTask(List<sObject> pNewRecList,Map<Id, sObject> pOldRecMap) {

        Id DNLTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
        List<TaskStatusWrapper> TaskStatusWrapperList = new List<TaskStatusWrapper>();
        for(Task t : (List<Task>)pNewRecList){
          if(t.WhatId!=null && DNLTaskRecordTypeId == t.RecordTypeId){
            String sObjName = t.WhatId.getSObjectType().getDescribe().getName();
            if(sObjName.equalsIgnoreCase('Opportunity') && (t.Status != ((Task)pOldRecMap.get(t.Id)).Status || t.Description != ((Task)pOldRecMap.get(t.Id)).Description) && t.import_Id__c != null){
                TaskStatusWrapper TaskWrap = new TaskStatusWrapper();
                TaskWrap.TaskId = t.import_Id__c;
                TaskWrap.Status = t.Status;
                TaskWrap.Description = t.Description;
                TaskStatusWrapperList.add(TaskWrap);
            }
        }
       } 
        if(!TaskStatusWrapperList.isEmpty()){
            UpdateTaskStatus(JSON.serialize(TaskStatusWrapperList));
        }
    }
    
     public class deserializeResponse{
        public String id;
        public String access_token;   
    }
    
    @future(callout = true)
    public static void UpdateTaskStatus(String TaskList){
        RestIntegrationInformation__mdt restIntegration = [select System_Endpoint__c,EndPointURL__C,MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(restIntegration.AccesstokenURL__c); //Change "ap4" in url to your Target Org Instance 
        String accessToken;
        if(!test.isRunningTest()){
            try{
               HttpResponse res=h.send(req);
            deserializeResponse resp1=(deserializeResponse)JSON.deserialize(res.getBody(),deserializeResponse.class);
            accessToken=resp1.access_token; 
            }
            catch(Exception e){
                system.debug('Exception:'+e.getMessage());
            }
            
        } else {
            accessToken='Test';
        }
        
        
        
        //Making a callout
        if(accessToken!=null){
            String endPoint=restIntegration.System_Endpoint__c+'/updateTaskStatus';//+'?oppId='+ids; 
            //String jsonstr= getOppDataJSON(oppLst);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(TaskList);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            if(!Test.isRunningTest()){
            HttpResponse res2=h2.send(req2);
            
            System.debug(res2+'###1203createresp');
            System.debug('###Body::'+res2.getBody());
            }
        }
     }
    
    public class TaskStatusWrapper{
        public string TaskId;
        public String Status;
        public String Description;
        
        public TaskStatusWrapper(){
            TaskId = '';
            Status = '';
            Description = '';
        }
    }
    

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 8/11/2019
    * @param Map<String, List<TaskObject>> pTaskObjectMap
    * @return void
    */
    public static void createTasks(Map<String,List<TaskObject>> pTaskObjectMap){    
        
        list<task> lTsk = getTasks(pTaskObjectMap);
        insert lTsk;    
      }


    /**
    * @description This method construct the list of tasks and return to the caller
    * and does not perform any DML
    * @author fSpectra
    * @param Map<String, List<TaskObject>> pTaskObjectMap
    * @return list<task>
    */
    public static list<task> getTasks(Map<String,List<TaskObject>> pTaskObjectMap){    
        Map<String,Task_SLA_Setup__mdt> metadataCodetoAttributeMap = TaskUtility.queryTaskMdt();
            
        list<task> lTsk=new list<task>();
        for(String tObjectCode:pTaskObjectMap.keySet())
        {
            for(TaskObject taskObject:pTaskObjectMap.get(tObjectCode)){
                Task t=TaskUtility.getTask(tObjectCode, taskObject, metadataCodetoAttributeMap);
                lTsk.add(t);
            }
        }
        return lTsk;    
      }      
    
        /**
    * @description This method checks if the logged in user is a Pre Sales Rep profile. If yes, it returns the business days defined for this particular profile.
    * @author fSpectra
    * @param 
    * @return Id
    */
    public static Id getBusinessHoursForPreSalesRep(){    
        Businesshours bh;
        Id returnId;
        Id profileId= Userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName != 'Pre Sales Rep')
            returnId = null;
        else{
            bh = [Select Id, Name from BusinessHours where name = 'Pre Sales Rep business hours' and IsActive = true];
            if(bh != null)
                returnId =  bh.Id;
        }
        
        /*if(pNewTaskList != null && pNewTaskList.size() != 0){
            for(Task lTask: pNewTaskList){
                if(lTask.whoId != null){
                    String sObjName = lTask.WhoId.getSObjectType().getDescribe().getName();
                    System.debug(loggingLevel.Error,sObjName);
                    if(!sObjName.equalsIgnoreCase('Lead')){
						
					}
				}

            }
        }*/
        return returnId;
      }      

  
}