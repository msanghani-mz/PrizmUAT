@isTest
public class TestHelperUserUtil
{
    public static User createTestUser( Id profID, String fName, String lName)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                IsActive = true,
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId);
        return tuser;
    }
    
    public static User getTestUser(String firstName, String lastName)
    {
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       
        User usr = createTestUser( pf.Id, firstName, lastName);
        
        return usr;
       
    }
}