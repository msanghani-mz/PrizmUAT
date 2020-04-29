/*
* Class Name   - ApplicationTriggerHandler
* Description  - Trigger Handler for ApplicationCustomTriggeManager - (DV-268, Re-assign open UW tasks when lending application owner is changed)
* Developer(s) - Financial Spectra 
*/

public class ApplicationTriggerHandler{
  /*public static List<Task> getAppOpenTaskList(id appId){
    Profile uwProfile  = [Select ID, Name from Profile where Name = 'Underwriter'];
    List<User> userList = [Select id, Name from User where  ProfileId = :uwProfile.Id];
    Set<Id> userIdSet = new Set<Id>();
      for(User usr : userList){
          userIdSet.add(usr.Id);
      }

      List<Task> appOpenTaskToBeUpdated = [SELECT Id, Subject, OwnerId from Task where WhatId = :appId and Status != 'Completed' and OwnerId In :userIdSet];
   return appOpenTaskToBeUpdated;
}  */
}