@isTest
public class Test_TaskWebServiceCallout {
 @isTest
    public static void runFuture()
    {
        list<task> lstTask=[select id,status,Description from Task];
        TaskHandler.UpdateTaskStatus(JSON.serialize(lstTask));
       // FutureCallClassMethod.futureCall();
    }

   public static void runFutureWithTest()
    {
        list<task> lstTask=[select id,status,Description from Task];
        Test.startTest();
        TaskHandler.UpdateTaskStatus(JSON.serialize(lstTask));
        Test.stopTest();
        
    }
    public static void runFuture1()
    {
        list<task> lstTask=[select id,status,Description from Task];
        PushTaskToNudebt.pushTasksInNdebt(JSON.serialize(lstTask),'TestMethod');
       // FutureCallClassMethod.futureCall();
    }
    public static void runFutureWithTest1()
    {
        list<task> lstTask=[select id,status,Description from Task];
        Test.startTest();
        PushTaskToNudebt.pushTasksInNdebt(JSON.serialize(lstTask),'TestMethod');
        Test.stopTest();
        
    }
}