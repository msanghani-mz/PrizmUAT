global class Schedule_btch_docsUnderwriterNotif implements schedulable {

    global void execute(SchedulableContext SC) {
      DocsUploadedNotification_Underwriter b=new DocsUploadedNotification_Underwriter();
      database.executeBatch(b);
   }
}

/*
String cron = '0 00 09,11,15,17 * * ?';   //9am,11am,3pm,5pm
Schedule_btch_docsUnderwriterNotif sch=new Schedule_btch_docsUnderwriterNotif();
system.schedule('Schedule Doc Upload Notification', cron, sch);
*/