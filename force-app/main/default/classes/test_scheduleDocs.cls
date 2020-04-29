@isTest
public class test_scheduleDocs {

    public static testmethod void TestSchedule(){
        Test.startTest();
        Schedule_btch_docsUnderwriterNotif m=new Schedule_btch_docsUnderwriterNotif();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Schedule Doc Upload Notification123', sch, m);
        Test.stopTest();
    }
}