public class SubmitApplicationErrContr {

    @auraenabled
    public static String getOpportunity(Id recordId){
        String OppOwnerId;
        
        System.debug('recordIdOpportunity = '+recordId);
      
        Opportunity lstop= [SELECT Id,name,Opportunity_Number__c,DRP_File_Number__c,isClone__c,isNewClonned__c,Monthly_Mortgage_or_Rent_Payment_Input__c,CloseDate,Debt_Count__c,Debit_Day_Second__c,Payment_Processor_Name__c,Unsettled_Debt__c,Opportunity_Type__c,Co_Applicant_Name__c,Is_Do_Not_Call__c,
                            StageName,Addnl_Months_with_Loan__c,Application_Signed_Date__c,Import_Program_Id__c,Import_Id__c ,Enrolled_Date__c,Debit_Day_First__c, Amount,Loan_Number_Of_Payments__c,
                            RecordType.DeveloperName,RecordTypeId,OwnerId,AccountId,Program_Number_Of_Payments__c,Program_Id__c,Program_Type__c,Remaining_Months_DRP_Program__c,Is_Application_Submitted__c,
                            Is_Application_Submit_Confirmed__c,Payment_Cycle__c,Account.Name,Account.PersonDoNotCall from Opportunity where id =: recordId Limit 1];
        if(lstop.Is_Application_Submitted__c && lstop.Is_Application_Submit_Confirmed__c && lstop.Related_Lending_Application__c!=null){
            return '007';
        }
        else{
            lstop.Is_Application_Submitted__c=true;
            update lstop;
            return lstop.Id;
        }
        
    }
}