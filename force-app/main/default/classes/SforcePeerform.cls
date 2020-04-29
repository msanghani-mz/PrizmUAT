global with sharing class SforcePeerform {

    webservice static Task InsertTask(Task t, String userId, String loanId)
    {
        List<Lead> ld = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, OwnerId FROM Lead WHERE UserId__c =:userId];
        List<Opportunity> lo = [SELECT Id, AccountId, OwnerId FROM Opportunity WHERE Loan_Id__c =:loanId];
        Lead l;
        Opportunity o;
        
        if(lo.size()>0)
            o = lo[0];
        
        if(ld.size() == 0)
        {
            if(o != NULL)
            {
                ld = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, OwnerId FROM Lead WHERE ConvertedAccountId =:o.AccountId];
                if(ld.size()>0)
                {
                    l = ld[0];
                }
            }
        }
        else
            l = ld[0];
        
        if(l != NULL)
        {
            if(l.IsConverted == true)
            {
                t.WhatId = l.ConvertedAccountId;
                t.WhoId = l.ConvertedContactId;
            }
            else
            {
                t.WhoId = l.Id;  
            }
            
            if(l.IsConverted == true && o != NULL)
            {
                if(t.OwnerId == NULL)
                    t.OwnerId = o.OwnerId;
                t.WhatId = o.Id;
            }
            
            if(t.OwnerId == NULL)
                t.OwnerId = l.OwnerId;
            
            insert t;
        }
        return t;
    }
    
    webservice static Task InsertTaskOnUpload(String ownerId, String subject, String userId, String loanId)
    {
        Task t = new Task();
        List<Opportunity> lo = [SELECT Id, CloseDate FROM Opportunity WHERE Loan_Id__c = :loanId];
        List<Account> la = [SELECT PersonContactId FROM Account WHERE UserId__c = :userId];
        if(lo.size()>0 && la.size()>0)
        {
            Opportunity o = lo[0];
            Account a = la[0];
            t.OwnerId = ownerId;
            t.Subject = subject;
            t.ActivityDate = o.CloseDate;
            
            t.WhatId = o.Id;
            t.WhoId = a.PersonContactId;
            
            t.Priority = 'High';
            insert t;
        }
        return t;
    }
    
    webservice static Task InsertTaskOnNewBankAccount(String ownerId, String subject, String userId)
    {
        Task t = new Task();
        List<Account> la = [SELECT PersonContactId FROM Account WHERE UserId__c = :userId];
        if(la.size()>0)
        {
            Account a = la[0];
            t.OwnerId = ownerId;
            t.Subject = subject;
            t.ActivityDate = date.today();
            
            t.WhatId = a.Id;
            t.WhoId = a.PersonContactId;
            
            t.Priority = 'High';
            t.IsReminderSet = false;
            insert t;
        }
        return t;
    }
}