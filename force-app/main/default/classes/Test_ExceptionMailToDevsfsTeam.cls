@isTest
public class Test_ExceptionMailToDevsfsTeam {
    @isTest
    public static void TestMethodEcxeption(){
       
        ExceptionMailToDevSfsTeam edv=new ExceptionMailToDevSfsTeam(12,'test Msg','test type');
        edv.sendEmailToTeam();
    }
}