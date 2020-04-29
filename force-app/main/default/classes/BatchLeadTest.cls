@isTest
public class BatchLeadTest {
  public static testmethod void TestBatchLead()
  {
     try
     {
       List<Lead> lstLead=new List<Lead>();
       RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Lead' AND Name = 'Borrower'];
       for(integer i=0;i<50;i++)
       {
        Lead l=new Lead(LastName='TestLead'+i,RecordType=rt);
        lstLead.add(l);
       }
      RecordType rt1 = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Lead' AND Name = 'Investor'];
      for(integer i=0;i<50;i++)
      {
        Lead l=new Lead(LastName='TestLead'+i,RecordType=rt1);
        lstLead.add(l);
      }
      insert lstLead;
      
      test.startTest();
       BatchLead bl=new BatchLead();
       Id batchId=database.executeBatch(bl);
      test.stopTest();  
     }
     catch(Exception e)
     {
         system.debug('Exception:'+e+e.getLineNumber());
     }
      
  }
}