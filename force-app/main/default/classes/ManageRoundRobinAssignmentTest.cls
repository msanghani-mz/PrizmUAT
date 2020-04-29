@isTest
public class ManageRoundRobinAssignmentTest {

    @isTest
    private static void test(){
        Id usrId= 'a1kL0000001dwFfIAI';
        Test.startTest();
        ManageRoundRobinAssignment.usersForDNLSales();
        ManageRoundRobinAssignment.usersForDoc();
        ManageRoundRobinAssignment.manageAssignment(usrId);
        Test.stopTest();
    }
}