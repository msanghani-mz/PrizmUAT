@isTest
public class ClientPortal_SendInvitationCntrlTest {
    
    @isTest
    static void sendInvitationEmailTest(){
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.fsCore__National_Identification_Number__pc='254789658';
        insert account1;  
        
        Opportunity opp = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, 
                                                                        ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp.StageName = 'Registration In Progress';
        insert opp;
        ClientPortal_SendInvitationCntrl.ResponseWrapper SendInvitation = ClientPortal_SendInvitationCntrl.sendInvitationEmail(opp.Id);
    }
    
    @isTest
    static void sendInvitationEmailWithStageOpenTest(){
        List<Account> accountsToUpdate = new List<Account>() ;
        Account applicantAcc = ClientPortal_TestDataFactory.buildAccount('Account2', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        applicantAcc.PersonBirthdate = system.today().AddDays(-10000);
        applicantAcc.nu_dse__SSN__c = '254789658';
        applicantAcc.PersonEmail = 'test@test.com';
        applicantAcc.fsCore__National_Identification_Number__pc='254789658';
        accountsToUpdate.add(applicantAcc);  
        
        Account coApplicant = ClientPortal_TestDataFactory.buildAccount('coApplicant', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        coApplicant.PersonBirthdate = system.today().AddDays(-10000);
        coApplicant.nu_dse__SSN__c = '254786582';
        coApplicant.PersonEmail = 'test1@test.com';
        coApplicant.fsCore__National_Identification_Number__pc='254786582';
        accountsToUpdate.add(coApplicant);   
        
        insert accountsToUpdate ;
        
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(accountsToUpdate[0].Id, 
                                                                         ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Open';
        opp1.Co_Applicant_Name__c = accountsToUpdate[1].Id;
        insert opp1;
        
        ClientPortal_SendInvitationCntrl.sendInvitationEmail(opp1.Id);
    } 
    
    @isTest
    static void testValidationForMissingEmail(){
        List<Account> accountsToUpdate = new List<Account>() ;
        Account applicantAcc = ClientPortal_TestDataFactory.buildAccount('Account2', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        applicantAcc.PersonBirthdate = system.today().AddDays(-10000);
        applicantAcc.nu_dse__SSN__c = '254789658';
        applicantAcc.PersonEmail = 'test@test.com';
        applicantAcc.fsCore__National_Identification_Number__pc='254789658';
        accountsToUpdate.add(applicantAcc);  
        
        Account coApplicant = ClientPortal_TestDataFactory.buildAccount('coApplicant', ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        coApplicant.PersonBirthdate = system.today().AddDays(-10000);
        coApplicant.nu_dse__SSN__c = '254786582';
        coApplicant.PersonEmail = '';
        coApplicant.fsCore__National_Identification_Number__pc='254786582';
        accountsToUpdate.add(coApplicant);   
        
        insert accountsToUpdate ;
        
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(accountsToUpdate[0].Id, 
                                                                         ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Open';
        opp1.Co_Applicant_Name__c = accountsToUpdate[1].Id;
        insert opp1;
        
        ClientPortal_SendInvitationCntrl.sendInvitationEmail(opp1.Id);
    }
    
}