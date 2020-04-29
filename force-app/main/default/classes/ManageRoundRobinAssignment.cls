public class ManageRoundRobinAssignment {
    
    @AuraEnabled
    public static List<User> usersForDNLSales(){
        // Query to find out all active users with DNL Sales Profile
        //List<User> userIdList= new List<User>([SELECT id,FirstName,LastName,Name,IsActive,Is_Included_For_Round_Robin__c,Round_Robin_Assignment_Date__c,Profile.name FROM User where Profile.name='DNL Sales' and isActive = true ]);
        //return userIdList;
        return null;
    }
    @AuraEnabled
    public static List<User> usersForDoc(){
        // Query to find out all active users with DNL Sales Profile
        //List<User> userIdList= new List<User>([SELECT id,FirstName,LastName,Name,IsActive,Is_Included_For_Round_Robin__c,Round_Robin_Assignment_Date__c,Profile.name FROM User where Profile.name='DNL Doc Collector' and isActive = true ]);
        //return userIdList;
        return null;
    }
    @AuraEnabled
    public static void manageAssignment(Id pUserId){
        //User newUser =[SELECT id,FirstName,LastName,IsActive,Is_Included_For_Round_Robin__c,Round_Robin_Assignment_Date__c,Profile.name FROM User where id = :pUserId];
        //newUser.Is_Included_For_Round_Robin__c = true;
        //newUser.Round_Robin_Assignment_Date__c = date.today();     
        //update newUser;
    }
    
}