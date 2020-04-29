/*
* Class Name  : ManageRecordAllocationController
* Description : Controller for Manage Record Allocation Lightning Page
* Developer(s): FS Dev
*/
public class ManageRecordAllocationController {
    
    @AuraEnabled
    public static List<User> getUsers(String pProfileName){
        List<User> users
            = [SELECT Id, Name,
               Username,
               IsRoundRobinAllocationEnabled__c,
               LastRRAllocationStatusUpdatedDateTime__c ,
               Round_Robin_Allocation_percent__c
               FROM User
               WHERE Profile.Name = :pProfileName
               AND IsActive = true
               ORDER BY Name];
        
        return users;
    }
    
    @AuraEnabled
    public static String updateRoundRobinPercent(String pUserId, String pAllocationPercent){
        ReturnMessage retMsg = new ReturnMessage();
        try{
            User usr = [SELECT Id, Name, Round_Robin_Allocation_percent__c
                        FROM User
                        WHERE Id = :pUserId];
            if(Decimal.valueOf(pAllocationPercent)>1000){
                
                retMsg = new ReturnMessage(false,'Allocation Percentage cannot be greater than 1000');
            }
            if(Decimal.valueOf(pAllocationPercent)<0){
                 retMsg = new ReturnMessage(false,'Allocation Percentage cannot be less than 0');
            }
            else{
                usr.Round_Robin_Allocation_percent__c  = Decimal.valueOf(pAllocationPercent);
                Database.update(usr);
                
                retMsg.message = 'Round-Robin Allocation percentage has been updated to ' + usr.Round_Robin_Allocation_percent__c +'% for ' + usr.Name + '.';
                
            }
            
        }
        catch (Exception e){
            retMsg = new ReturnMessage(false, e.getMessage());
        }
        
        return JSON.serialize(retMsg);
    }
    
    @AuraEnabled
    public static String toggleRoundRobinStatus(String pUserId){
        ReturnMessage retMsg = new ReturnMessage();
        try{
            User usr = [SELECT Id
                        , Name
                        , IsRoundRobinAllocationEnabled__c
                        , LastRRAllocationStatusUpdatedDateTime__c 
                        , Round_Robin_Allocation_percent__c
                        FROM User
                        WHERE Id = :pUserId];
            
            usr.IsRoundRobinAllocationEnabled__c = !(usr.IsRoundRobinAllocationEnabled__c);
            usr.LastRRAllocationStatusUpdatedDateTime__c = System.now();
            Database.update(usr);
            
            retMsg.message = 'Round-Robin has been ' + (usr.IsRoundRobinAllocationEnabled__c ? 'enabled' : 'disabled') + ' for ' + usr.Name + '.';
        }
        catch (Exception e){
            retMsg = new ReturnMessage(false, e.getMessage());
        }
        
        return JSON.serialize(retMsg);
    }
    
    public class ReturnMessage{
        public Boolean isSuccess;
        public String  message;
        
        public ReturnMessage(){
            isSuccess = true;
            message = '';
        }
        
        public ReturnMessage(Boolean pIsSuccess, String pMessage){
            isSuccess = pIsSuccess;
            message = pMessage;
        }
    }
}