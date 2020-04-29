/**
 * @File Name          : TaskOverdueNotificationJobTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 8/6/2019, 1:03:17 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/5/2019, 10:08:17 AM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest(seeAllData=false)
public class TaskOverdueNotificationJobTest {
    
    @testSetup static void TaskCreator(){
        
        
        User usr = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs(usr){
            UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert role;
            usr = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1].Id,
                LastName = 'Singh',
                Email = 'aniket50singh@gmail.com',
                Username = 'aniket50singh@gmail.com' + System.currentTimeMillis(),
                CompanyName = 'FS',
                Title = 'AS',
                Alias = 'asingh',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = role.Id,
                IsActive = true
            );
            insert usr;
        }
        
        
        
        List<Task> taskList = new List<Task>();
        Task task1 = new Task();
        Id recTypeId1 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
        task1.RecordTypeId = recTypeId1;
        task1.Subject='Send Letter';
        task1.Priority='High';
        task1.Status='In Progress';
        task1.OwnerId=usr.id;
        task1.ActivityDate =Date.newInstance(2017, 12, 05);
        taskList.add(task1);
        
        Task task2 = new Task();
        Id recTypeId2 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
        task2.RecordTypeId = recTypeId2;
        task2.Subject='Send Letter';
        task2.Priority='Normal';
        task2.Status='In Progress';
        task2.OwnerId=usr.id;
        task2.ActivityDate =Date.newInstance(2019, 08, 05);
        taskList.add(task2);
        
        Task task3 = new Task();
        Id recTypeId3 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
        task3.RecordTypeId = recTypeId3;
        task3.Subject='Send Letter';
        task3.Priority='Low';
        task3.Status='In Progress';
        task3.OwnerId=usr.id;
        task3.ActivityDate =Date.newInstance(2020, 08, 05);
        taskList.add(task3);
        
        Task task4 = new Task();
        Id recTypeId4 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
        task4.RecordTypeId = recTypeId4;
        task4.Subject='Send Letter';
        task4.Priority='High';
        task4.Status='In Progress';
        task4.OwnerId=usr.id;
        task4.ActivityDate =Date.newInstance(2017, 12, 05);
        taskList.add(task4);
        
        Task task5 = new Task();
        Id recTypeId5 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
        task5.RecordTypeId = recTypeId5;
        task5.Subject='Send Letter';
        task5.Priority='Normal';
        task5.Status='In Progress';
        task5.OwnerId=usr.id;
        task5.ActivityDate =Date.newInstance(2019, 08, 05);
        taskList.add(task5);
        
        Task task6 = new Task();
        Id recTypeId6 = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
        task6.RecordTypeId = recTypeId6;
        task6.Subject='Send Letter';
        task6.Priority='Low';
        task6.Status='In Progress';
        task6.OwnerId=usr.id;
        task6.ActivityDate =Date.newInstance(2020, 08, 05);
        taskList.add(task6); 
        insert taskList;
        
        
    }
    
    @isTest static void batchTest(){
       // User usr = [ select Id from User Limit 1];
        Test.startTest();
        TaskOverdueNotificationJob obj = new TaskOverdueNotificationJob();
      //  Database.executeBatch(obj);
        Test.stopTest();
        
    }    
    
  /*  @isTest static void scheduleTest(){
         
        String CRON_EXP = '0 0 16 25 * ?';
        test.startTest();
        String jobId = System.schedule('TaskOverdueNotificationJobTest',CRON_EXP , new TaskOverdueNotificationJob());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        test.stopTest();
        
    }*/
}