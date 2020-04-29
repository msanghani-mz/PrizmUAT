@isTest
private class TestSforcePeerformServiceTest{
    static TestMethod void testInsertTaskOnUpload()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias='PFAdmin', Email='peerformadmintest@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='peerformadmintest@test.com');
        
        RecordType r = [SELECT Id FROM RecordType WHERE Name = 'Borrower' AND SobjectType = 'Account'];
        
        System.runAs(u)
        {
            test.startTest();
            String loanId = '1234';
            String userId = '9335BFB3-D382-4692-8502-A5575D269CDB';
            String ownerId = UserInfo.getUserId();
            String subject = 'User Uploaded PDF';
            
            Account a = new Account(Name='Test Account');
            a.UserId__c = userId;
            a.RecordTypeId = r.Id;
            insert a;
            
            Schema.RecordTypeInfo LoanOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Loan');
            Opportunity o = new Opportunity(Name='Test Opportunity', StageName = 'Closed Lost',recordTypeId = LoanOpp.getRecordTypeId());
            o.CloseDate=date.today();
            o.Loan_Id__c = loanId;
            //o.Account=a.id;
            system.debug(logginglevel.error,' 0 '+o);
            insert o;
            
            Account insertedA = [SELECT PersonContactId FROM Account WHERE UserId__c = :userId];
            Opportunity insertedO = [SELECT Id, CloseDate FROM Opportunity WHERE Loan_Id__c = :loanId];
                    
            Task t = SforcePeerform.InsertTaskOnUpload(ownerId, subject, userId, loanId);
            
            test.stopTest();
            
            System.assertEquals(t.OwnerId, ownerId);
            System.assertEquals(t.Subject, subject);
            System.assertEquals(t.ActivityDate, o.CloseDate);
            System.assertEquals(t.WhatId, insertedO.Id);
            System.assertEquals(t.WhoId, insertedA.PersonContactId);
            System.assertEquals(t.Priority, 'High');
        }
    }
    
    static TestMethod void testInsertTaskOnNewBankAccount()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias='PFAdmin', Email='peerformadmintest@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='peerformadmintest@test.com');
        
        RecordType r = [SELECT Id FROM RecordType WHERE Name = 'Borrower' AND SobjectType = 'Account'];
        
        System.runAs(u)
        {
            test.startTest();
            String userId = '9335BFB3-D382-4692-8502-A5575D269CDB';
            String ownerId = UserInfo.getUserId();
            String subject = 'New Bank Account Activated - Update CRB Payments';
            
            Account a = new Account(Name='Test Account');
            a.UserId__c = userId;
            a.RecordTypeId = r.Id;
            insert a;
                        
            Account insertedA = [SELECT id,PersonContactId FROM Account WHERE UserId__c = :userId];
                    
            Task t = SforcePeerform.InsertTaskOnNewBankAccount(ownerId, subject, userId);
            
            test.stopTest();
            
            System.assertEquals(t.OwnerId, ownerId);
            System.assertEquals(t.Subject, subject);
            System.assertEquals(t.ActivityDate, date.today());
            System.assertEquals(t.WhatId, insertedA.Id);
            System.assertEquals(t.WhoId, insertedA.PersonContactId);
            System.assertEquals(t.Priority, 'High');
            System.assertEquals(t.IsReminderSet, false);
        }
    }
    
    static TestMethod void testInsertTaskConvertedLead()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias='PFAdmin', Email='peerformadmintest@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='peerformadmintest@test.com');
        
        RecordType r = [SELECT Id FROM RecordType WHERE Name = 'Borrower' AND SobjectType = 'Account'];
        
        System.runAs(u)
        {
            test.startTest();
            String userId = '9335BFB3-D382-4692-8502-A5575D269CDB';
            String ownerId = UserInfo.getUserId();
            String loanId;
            
            Lead l = new Lead(LastName='Test Lead', UserId__c=userId);
            insert l;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setOpportunityName('Test Lead Opportunity');
            lc.setOverwriteLeadSource(false);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            
            Id opportunityId = lcr.getOpportunityId();
            Opportunity insertedO = [SELECT OwnerId, Loan_Id__c, Id, CloseDate FROM Opportunity WHERE Id = :opportunityId];
            Lead insertedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, OwnerId FROM Lead WHERE UserId__c =:userId];
            System.assertEquals(opportunityId, insertedO.Id);
            
            loanId = insertedO.Loan_Id__c;
            
            Task t = new Task();
            t.Subject = 'Test Insert Task';
            t.Priority = 'High';
            t.IsReminderSet = false;
            t.ActivityDate = date.today();
         
            Task insertedTask = SforcePeerform.InsertTask(t, userId, loanId);
            
            System.assertEquals(insertedO.OwnerId, insertedTask.OwnerId);
            System.assertEquals(t.Subject, insertedTask.Subject);
            System.assertEquals(t.ActivityDate, insertedTask.ActivityDate);
            System.assertEquals(t.WhatId, insertedO.Id);
            System.assertEquals(t.WhoId, insertedLead.ConvertedContactId);
            System.assertEquals(t.Priority, insertedTask.Priority);
        }
    }
    
    static TestMethod void testInsertTaskOnLead()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias='PFAdmin', Email='peerformadmintest@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='peerformadmintest@test.com');
        
        RecordType r = [SELECT Id FROM RecordType WHERE Name = 'Borrower' AND SobjectType = 'Account'];
        
        System.runAs(u)
        {
            test.startTest();
            String userId = '9335BFB3-D382-4692-8502-A5575D269CDB';
            String ownerId = UserInfo.getUserId();
            String loanId;
            
            Lead l = new Lead(LastName='Test Lead', UserId__c=userId);
            insert l;
            Lead insertedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, OwnerId FROM Lead WHERE UserId__c =:userId];
                        
            Task t = new Task();
            t.Subject = 'Test Insert Task';
            t.Priority = 'High';
            t.IsReminderSet = false;
            t.ActivityDate = date.today();
         
            Task insertedTask = SforcePeerform.InsertTask(t, userId, loanId);
            
            System.assertEquals(insertedLead.OwnerId, insertedTask.OwnerId);
            System.assertEquals(t.Subject, insertedTask.Subject);
            System.assertEquals(t.ActivityDate, insertedTask.ActivityDate);
            System.assertEquals(t.WhoId, insertedLead.Id);
            System.assertEquals(t.Priority, insertedTask.Priority);
        }
    }
    
    static TestMethod void testInsertTaskOnOpportunity()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias='PFAdmin', Email='peerformadmintest@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='peerformadmintest@test.com');
        
        RecordType r = [SELECT Id FROM RecordType WHERE Name = 'Borrower' AND SobjectType = 'Account'];
        
        System.runAs(u)
        {
            test.startTest();
            String userId = '9335BFB3-D382-4692-8502-A5575D269CDB';
            String ownerId = UserInfo.getUserId();
            String loanId;
            
            Lead l = new Lead(LastName='Test Lead', UserId__c=userId);
            insert l;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setOpportunityName('Test Lead Opportunity');
            lc.setOverwriteLeadSource(false);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            
            Id opportunityId = lcr.getOpportunityId();
            Opportunity insertedO = [SELECT OwnerId, Loan_Id__c, Id, CloseDate FROM Opportunity WHERE Id = :opportunityId];
            Lead insertedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, OwnerId FROM Lead WHERE UserId__c =:userId];
            System.assertEquals(opportunityId, insertedO.Id);
            
            loanId = insertedO.Loan_Id__c;
            
            Task t = new Task();
            t.Subject = 'Test Insert Task';
            t.Priority = 'High';
            t.IsReminderSet = false;
            t.ActivityDate = date.today();
         
            Task insertedTask = SforcePeerform.InsertTask(t, NULL, loanId);
            
            System.assertEquals(insertedO.OwnerId, insertedTask.OwnerId);
            System.assertEquals(t.Subject, insertedTask.Subject);
            System.assertEquals(t.ActivityDate, insertedTask.ActivityDate);
            System.assertEquals(t.WhatId, insertedO.Id);
            System.assertEquals(t.WhoId, insertedLead.ConvertedContactId);
            System.assertEquals(t.Priority, insertedTask.Priority);
        }
    }
}