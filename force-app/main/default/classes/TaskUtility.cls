/*
* Class Name : TaskUtility
* Purpose    : This class is used as a uitility class to populate task attributes.
*              create the task in the PRIZM Org
* Developer  : Financial Spectra
*/
public class TaskUtility {
    /**
* @description This is the main method which needs to be called to construct the task from custom metadata.
* @author fSpectra
* @param String pTaskCode
* @param TaskObject pTaskObject
* @param Map<String, Task_SLA_Setup__mdt> pMetadataCodetoAttributeMap
* @return Task
*/
    public static Task getTask(String pTaskCode, TaskObject pTaskObject, Map<String,Task_SLA_Setup__mdt> pMetadataCodetoAttributeMap){
        Task lTask= getTaskAttributesFromMetadata(pTaskCode, pMetadataCodetoAttributeMap);
        
        
        
        if (pMetadataCodetoAttributeMap.get(pTaskCode).Append_Record_Name_To_Subject__c){
            if (pTaskObject.mEntity.equalsIgnoreCase('fsCore__Lending_Application_Checklist__c')){
                lTask.type = pMetadataCodetoAttributeMap.get(pTaskCode).Task_Subject__c +' '+pTaskObject.mApplicationChecklistText;
            }else if (pTaskObject.mEntity.equalsIgnoreCase('fsCore__Lending_Application__c')){
                lTask.type = pMetadataCodetoAttributeMap.get(pTaskCode).Task_Subject__c +' '+pTaskObject.mLendingApplicationName;
            }if (pTaskObject.mEntity.equalsIgnoreCase('fsServ__Inbound_Payment__c')){
                lTask.type = pMetadataCodetoAttributeMap.get(pTaskCode).Task_Subject__c +' '+pTaskObject.mLendingContractName;
            }else{
                lTask.type = pMetadataCodetoAttributeMap.get(pTaskCode).Task_Subject__c +' '+pTaskObject.mOpportunityName;
            }
            
        }else{
            lTask.type = pMetadataCodetoAttributeMap.get(pTaskCode).Task_Subject__c;
        }
        
        
        
        
        lTask.WhatId=pTaskObject.mRecordId;
        lTask.description = pTaskObject.mDescription;
        if(pTaskObject.mDueDate != null){
            lTask.Due_Date_Time__c = pTaskObject.mDueDate; 
        }
        
        lTask.WhoId = pTaskObject.mWhoId;
        
        if (pTaskObject.mEntity.equalsIgnoreCase('fsServ__Inbound_Payment__c')){
            //DO NOTHING
        }else{
            lTask.Related_Application_Name__c = pTaskObject.mLendingApplicationId;
        }
        lTask.OwnerId=pTaskObject.mOwnerId; //DEFAULT TO OWNER
        
        //ASSOCIATE THE TASK WITH THE PARENT IF SETUP SAYS SO
        if ((pMetadataCodetoAttributeMap.get(pTaskCode).Associated_To_Record__c == 'Parent') && (pTaskObject.mParentRecordId != null)){
            lTask.WhatId=pTaskObject.mParentRecordId;
        }
        system.debug(logginglevel.error,' TASK OWNER :: '+pMetadataCodetoAttributeMap.get(pTaskCode).Task_Owner__c);
        system.debug(logginglevel.error,'  mDocProcessorId :: '+pTaskObject.mDocProcessorId);
        system.debug(logginglevel.error,'  mLoanOfficerId :: '+pTaskObject.mLoanOfficerId);
        system.debug(logginglevel.error,'  mUserId :: '+pTaskObject.mUserId);
        system.debug(logginglevel.error,'  mNegotiatorId :: '+pTaskObject.mNegotiatorId);
        system.debug(logginglevel.error,'  Related_Application_Name__c :: '+lTask.Related_Application_Name__c);
        if (pMetadataCodetoAttributeMap.get(pTaskCode).Task_Owner__c != null){
            if (pMetadataCodetoAttributeMap.get(pTaskCode).Task_Owner__c == 'Docs Processor'){
                if (pTaskObject.mDocProcessorId != null){
                    lTask.OwnerId=pTaskObject.mDocProcessorId; 
                }
            }else if (pMetadataCodetoAttributeMap.get(pTaskCode).Task_Owner__c == 'Loan Officer'){
                if (pTaskObject.mLoanOfficerId != null){
                    lTask.OwnerId=pTaskObject.mLoanOfficerId; 
                }
            }else if (pMetadataCodetoAttributeMap.get(pTaskCode).Task_Owner__c == 'User'){
                if (pTaskObject.mUserId != null){
                    lTask.OwnerId=pTaskObject.mUserId; 
                }                    
            }else if (pMetadataCodetoAttributeMap.get(pTaskCode).Task_Owner__c == 'Negotiator'){
                //TODO NO NEGOTIATOR FIELD AVAILABLE ON LENDING APP
                if (pTaskObject.mNegotiatorId != null){
                    //lTask.OwnerId=pTaskObject.mNegotiatorId; 
                }
            }
            
        }
        
        return lTask;
    }     
    
    /**
* @description
* @author fSpectra
* @return Map<String, Task_SLA_Setup__mdt>
*/
    public static Map<String,Task_SLA_Setup__mdt> queryTaskMdt(){
        List<Task_SLA_Setup__mdt> taskMdtList = [SELECT DeveloperName
                                                 ,Id
                                                 ,Is_Active__c
                                                 ,Label
                                                 ,Language
                                                 ,MasterLabel
                                                 ,NamespacePrefix
                                                 ,Priority__c
                                                 ,QualifiedApiName
                                                 ,SLA_Period__c
                                                 ,SLA_Unit__c
                                                 ,Task_Owner__c
                                                 ,Task_Subject__c
                                                 ,Task_Type__c 
                                                 ,Append_Record_Name_To_Subject__c
                                                 ,Task_Status__c
                                                 ,Record_Type_Name__c  
                                                 ,Activity_Days__c 
                                                 ,Task_Description__c 
                                                 ,Associated_To_Record__c
                                                 FROM Task_SLA_Setup__mdt 
                                                 WHERE Is_Active__c = true];
        Map<String,Task_SLA_Setup__mdt> metadataCodetoAttributeMap = new Map<String,Task_SLA_Setup__mdt>();
        for(Task_SLA_Setup__mdt taskmdt:taskMdtList){
            metadataCodetoAttributeMap.put(taskmdt.DeveloperName,taskmdt);
        }
        return metadataCodetoAttributeMap;
    }
    /**
* @description
* @author fSpectra
* @param String pTaskCode
* @param Map<String, Task_SLA_Setup__mdt> pMetadataCodetoAttributeMap
* @return Task
*/
    private static Task getTaskAttributesFromMetadata(String pTaskCode, Map<String,Task_SLA_Setup__mdt> pMetadataCodetoAttributeMap){
        
        Task lTask = new Task();
        lTask.Due_Date_Time__c = System.now();
        
        Map<String,Task_SLA_Setup__mdt> metadataCodetoAttributeMap;
        if (pMetadataCodetoAttributeMap != null && pMetadataCodetoAttributeMap.size()> 0 ){
            metadataCodetoAttributeMap = pMetadataCodetoAttributeMap;
        }else{
            metadataCodetoAttributeMap = queryTaskMdt();
        }
        
        
        if (metadataCodetoAttributeMap.get(pTaskCode) != null){
            lTask.Subject = metadataCodetoAttributeMap.get(pTaskCode).Task_Subject__c;
            if (metadataCodetoAttributeMap.get(pTaskCode).SLA_Unit__c == 'Hours'){
                if (metadataCodetoAttributeMap.get(pTaskCode).SLA_Period__c != null){
                    if (lTask.Due_Date_Time__c != null){
                        lTask.Due_Date_Time__c = lTask.Due_Date_Time__c.addHours((Integer)metadataCodetoAttributeMap.get(pTaskCode).SLA_Period__c);
                    }
                }
            }else if (metadataCodetoAttributeMap.get(pTaskCode).SLA_Unit__c == 'Days'){
                if (metadataCodetoAttributeMap.get(pTaskCode).SLA_Period__c != null){
                    lTask.Due_Date_Time__c = lTask.Due_Date_Time__c.addDays((Integer)metadataCodetoAttributeMap.get(pTaskCode).SLA_Period__c);
                }
            }
            lTask.priority= metadataCodetoAttributeMap.get(pTaskCode).Priority__c;
            lTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(metadataCodetoAttributeMap.get(pTaskCode).Record_Type_Name__c).getRecordTypeId(); //PDI-600
            lTask.status = metadataCodetoAttributeMap.get(pTaskCode).Task_Status__c;
            lTask.type = metadataCodetoAttributeMap.get(pTaskCode).Task_Type__c;
            lTask.description = metadataCodetoAttributeMap.get(pTaskCode).Task_Description__c;
            
            //DV-193
            Id BusinessHourId = fsCore.SpectraCoreUtil.getBusinessHourId('VLB');
            if (!fsCore.DateUtilGlobal.isBusinessDay(lTask.Due_Date_Time__c, BusinessHourId)){
                lTask.Due_Date_Time__c = BusinessHours.nextStartDate(BusinessHourId,lTask.Due_Date_Time__c);
            }
            lTask.Due_Time__c = lTask.Due_Date_Time__c.Time();
            lTask.ActivityDate = date.newinstance(lTask.Due_Date_Time__c.year(), lTask.Due_Date_Time__c.month(), lTask.Due_Date_Time__c.day());
            
            
            if (metadataCodetoAttributeMap.get(pTaskCode).Activity_Days__c != null){
                if (metadataCodetoAttributeMap.get(pTaskCode).Activity_Days__c > 0){
                    lTask.ActivityDate = lTask.ActivityDate + (Integer)metadataCodetoAttributeMap.get(pTaskCode).Activity_Days__c;
                }
            }
            
        }
        
        return lTask;
        
    }    
    /**
* @description
* Method to construct the map wich will be passed to the TaskHandler.getTasks or TaskHandler.createTasks
* @author fSpectra
* @param String pTaskCode
* @param TaskObject pTaskObject
* @param Map<String, list<TaskObject>> pTaskObjectMap
* @return Map<String, list<TaskObject>>
*/
    public static Map<String,list<TaskObject>> getTaskMap(String pTaskCode, TaskObject pTaskObject ,Map<String,list<TaskObject>>  pTaskObjectMap){
        
        if (pTaskObjectMap == null){
            pTaskObjectMap = new Map <String,list<TaskObject>>();
        }
        if (pTaskObjectMap.get(pTaskCode) != null){
            pTaskObjectMap.get(pTaskCode).add(pTaskObject);
        }else{
            pTaskObjectMap.put(pTaskCode,new List<TaskObject>{pTaskObject});
        }
        return pTaskObjectMap;
        
    }
}