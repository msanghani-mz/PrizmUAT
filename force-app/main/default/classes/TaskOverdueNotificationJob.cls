/**
* Class Name  : TaskOverdueNotificationJob (PDI-784)
* Description : This batch job sends notification to the user for any due/overdue tasks
* Author      : Financial Spectra
*
*/
global with sharing class TaskOverdueNotificationJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'TaskOverdueNotificationJob';
    
    global TaskOverdueNotificationJob(){
        setJobQuery(getDefaultQuery());
    }
    
    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.User.getName())
            .addFields()
            .addWhereConditionWithValue(1, 'IsActive', '=', true);
        //.addWhereConditionWithValue(2, 'Name', '=', 'FS Dev');
        return jobQuery;
    }        
    
    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }
    
    global override void setParameterizedJobQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        setJobQuery(jobQuery.getQueryString());
    }
    
    global override String getClassName(){
        return CLASS_NAME;
    }
    
    global override void startJob(Database.BatchableContext pContext){}
    
    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug(loggingLevel.DEBUG, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.DEBUG, 'Scope Count : ' + pScope.size());
        
        if (pScope.size() == 0){ return null; }
        
        Set<ID> lUserIdSet = new Set<ID>();
        map <ID, List<Task>> taskMap = new map <ID, List<Task>>();        
        for (User lUser : (List<User>)pScope){
            lUserIdSet.add(lUser.Id);
            taskMap.put(lUser.id,new List<Task>());
        }
        
        List<Task> TaskList = [SELECT Id
                               , Subject
                               , Due_Date_Time__c
                               , OwnerId
                               , WhatId
                               , activityDate
                               FROM Task
                               WHERE Status != 'Completed' 
                               AND activityDate <= TODAY
                               AND activityDate != null 
                               AND OwnerId IN :lUserIdSet];
        
        for (Task lTask : taskList){
            if (taskMap.containsKey(lTask.OwnerId)){
                taskMap.get(lTask.OwnerId).add(lTask);
            }
        }        
        sendEmail((List<User>)pScope,taskMap);
        
        return new List<fsCore.ErrorObject>();
    }
    
    public void sendEmail(List<user> pUserList,Map <ID, List<Task>> pTaskMap)
    {
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        for (User lUser : pUserList){
            String emailBody = '<p>Good morning!</p>';
            String dueTasksString = '<p>Tasks due today:</p><ul>';
            String OverDueTasksString = '<p>Overdue tasks:</p><ul>';
            List<Task> ltaskList = pTaskMap.get(lUser.Id);
            for (Task lTask : ltaskList){
                if (lTask.activityDate < Date.Today()){
                    //OverDueTasksString += ('<li>' + lTask.Subject + ' ('+lTask.WhatId+')'+'</li>');
                    OverDueTasksString += ('<li><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+lTask.id+'">'+lTask.Subject+'</a></li>');
                }else{                    
                    dueTasksString += ('<li><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+lTask.id+'">'+lTask.Subject+'</a></li>');
                }
            }
            dueTasksString += '</ul>';
            OverDueTasksString += '</ul>';
            emailBody += dueTasksString+'</br>'+OverDueTasksString;
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{lUser.Email}; 
            semail.setToAddresses(sendingTo); 
            semail.setSubject('Daily Task List'); 
            semail.setHtmlBody(emailBody);
            allMails.add(semail);
        }
        if (Test.isRunningTest()){
            //DO NOTHING
        }else{
            Messaging.sendEmail(allMails); 
        }
    }
    
    global override void finishJob(Database.BatchableContext pContext){}
    
    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Task_Notification_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    
    
}