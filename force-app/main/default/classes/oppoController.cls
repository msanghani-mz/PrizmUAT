public class oppoController {
    //getOpportunity
    @auraenabled
    public static String getOpportunity(Id recordId){
        String OppOwnerId;
        //String RecTypeId;
        System.debug('recordIdOpportunity = '+recordId);
      
        Opportunity lstop= [SELECT Id,name,Cash_in_Dedicated_Account__c, Law_Firm_Name__c,Draft_Amount_Per_Period__c, Opportunity_Number__c,DRP_File_Number__c,DRP_Name__c,Portfolio_Type__c,DRP_Account_Number__c,isClone__c,isNewClonned__c,Monthly_Mortgage_or_Rent_Payment_Input__c,CloseDate,Debt_Count__c,Debit_Day_Second__c,Payment_Processor_Name__c,Unsettled_Debt__c,Opportunity_Type__c,Co_Applicant_Name__c,Is_Do_Not_Call__c,
                            StageName,Addnl_Months_with_Loan__c,Application_Signed_Date__c,Import_Program_Id__c,Import_Id__c ,Enrolled_Date__c,Debit_Day_First__c, Amount,Loan_Number_Of_Payments__c,
                            RecordType.DeveloperName,RecordTypeId,OwnerId,AccountId,Program_Number_Of_Payments__c,Program_Id__c,Program_Type__c,Remaining_Months_DRP_Program__c,Is_Application_Submitted__c,
                            Payment_Cycle__c,Account.Name,Account.PersonDoNotCall from Opportunity where id =: recordId Limit 1];
        // Opportunity_Draft_Fee__c opdrftfeeOrg=[Select id,name,Paid_Processor_Fee__c,Paid_Accumulation__c,Remaining_Third_Party_Fee__c,Remaining_Service_Fee__c,Remaining_Retainer_Fee__c,Remaining_Program_Fee__c,Remaining_Processor_Fee__c,Remaining_Maintenance_Fee__c,Remaining_Creditor_Payments__c,Remaining_Admin_Fee__c,Remaining_Accumulation__c,Total_Third_Party_Fee__c,Total_Processor_Fee__c,Total_Service_Fee__c,Total_Program_Fee__c,Total_Retainer_Fee__c,Total_Maintenance_Fee__c,Total_Accumulation__c,Total_Creditor_Payments__c,Total_Admin_Fee__c,Opportunity_Name__c from Opportunity_Draft_Fee__c where Opportunity_Name__c!=null AND Opportunity_Name__c =:recordId Limit 1];
       
        if(lstop.isNewClonned__c){ 
            return '007';
            
        }
        else
        {
        Opportunity op1=new Opportunity();
        op1.AccountId=lstop.AccountId; 
        op1.Name=lstop.Name+ lstop.Account.Name;
        //Set ownerId of Opportunity & it will used while update : Line no.47
        OppOwnerId=lstop.OwnerId;
        op1.StageName='DNL Prospecting';
        op1.Amount=lstop.Amount;
        op1.CloseDate=lstop.CloseDate;
        op1.Import_Id__c=lstop.Import_Id__c;
        lstop.Import_Id__c='';
        lstop.isNewClonned__c=true;  //DV-257
        update lstop;  
        op1.Loan_Number_Of_Payments__c=lstop.Loan_Number_Of_Payments__c;
        op1.Addnl_Months_with_Loan__c=lstop.Addnl_Months_with_Loan__c;
        op1.Application_Signed_Date__c=null;
        op1.Debit_Day_First__c=lstop.Debit_Day_First__c;
        op1.DRP_Name__c = lstop.DRP_Name__c;  //DV-417
        op1.DRP_Account_Number__c = lstop.DRP_Account_Number__c;  //DV-417
        op1.Portfolio_Type__c = lstop.Portfolio_Type__c;    //DV-417
        op1.Monthly_Mortgage_or_Rent_Payment_Input__c=lstop.Monthly_Mortgage_or_Rent_Payment_Input__c;
        op1.DRP_File_Number__c=lstop.DRP_File_Number__c;
        op1.Debt_Count__c=lstop.Debt_Count__c;
        op1.Unsettled_Debt__c=lstop.Unsettled_Debt__c;
        op1.Payment_Processor_Name__c=lstop.Payment_Processor_Name__c;
        op1.Opportunity_Type__c=lstop.Opportunity_Type__c;
        op1.Co_Applicant_Name__c=lstop.Co_Applicant_Name__c;
        op1.Is_Do_Not_Call__c=lstop.Is_Do_Not_Call__c;
        op1.Enrolled_Date__c=lstop.Enrolled_Date__c;
        op1.Is_Application_Submitted__c=False;
        op1.Import_Program_Id__c=lstop.Import_Program_Id__c;
        op1.Program_Id__c=lstop.Program_Id__c;
        op1.Debit_Day_Second__c=lstop.Debit_Day_Second__c;
        op1.Payment_Cycle__c=lstop.Payment_Cycle__c;
        op1.Program_Type__c=lstop.Program_Type__c;
        op1.Remaining_Months_DRP_Program__c=lstop.Remaining_Months_DRP_Program__c;
        op1.Program_Number_Of_Payments__c=lstop.Program_Number_Of_Payments__c;
        op1.Cash_in_Dedicated_Account__c=lstop.Cash_in_Dedicated_Account__c;
        op1.Draft_Amount_Per_Period__c=lstop.Draft_Amount_Per_Period__c;
        op1.Law_Firm_Name__c = lstop.Law_Firm_Name__c;
      // op1.Remaining_Fee_Due_To_DRP__c=lstop.Remaining_Fee_Due_To_DRP__c;
        //op1.isNewClonned__c=true;
        //RecTypeId=lstop.RecordTypeId;
        insert op1; 
        
        list<Opportunity_Draft_Fee__c> opdrftfeeOrg=[Select id,name,Paid_Processor_Fee__c,Lending_Application_Number__c,ownerId,Paid_Accumulation__c,Remaining_Third_Party_Fee__c,Remaining_Service_Fee__c,Remaining_Retainer_Fee__c,Remaining_Program_Fee__c,Remaining_Processor_Fee__c,Remaining_Maintenance_Fee__c,Remaining_Creditor_Payments__c,Remaining_Admin_Fee__c,Remaining_Accumulation__c,Total_Third_Party_Fee__c,Total_Processor_Fee__c,Total_Service_Fee__c,Total_Program_Fee__c,Total_Retainer_Fee__c,Total_Maintenance_Fee__c,Total_Accumulation__c,Total_Creditor_Payments__c,Total_Admin_Fee__c,Opportunity_Name__c from Opportunity_Draft_Fee__c where Opportunity_Name__c =:recordId ];
        //Opportunity Draft Fee
        String OwnerDF;
        if(opdrftfeeOrg.size()>0){
            for(Opportunity_Draft_Fee__c opd1:opdrftfeeOrg){
                opd1.Opportunity_Name__c=op1.id;
                //OwnerDF=opd1.ownerId;
                //opd1.ownerId=OppOwnerId;
                opd1.Lending_Application_Number__c=null;
            }
            update opdrftfeeOrg;
           
       } 
        
        Opportunity op2=[select id,Name,OwnerId,RecordTypeId from Opportunity where id=:op1.id];
        op2.OwnerId=OppOwnerId;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DNL Sales').getRecordTypeId();
        //op1.RecordTypeId=oppRecordTypeId;
        op2.RecordTypeId=oppRecordTypeId;
        Update op2;
        //Get Payment,Tradeline & bank account related to lstop & assign id of op1 in to opp--c of all related records.
        
        //Call Pull Functionality
        if (!Test.isRunningTest()) {
        	pullOpportunity(op1.Import_Id__c); //DV-417        
        }    

        system.debug('NAMEOPP:'+op1.Name); 
        System.debug('RECORD ID:'+op1.Id);
        return op1.Id;   
        }
  
    }
    
    @future(callout=true)
    public static void pullOpportunity(Id importId){
		pullOpportunityTradeLinePaymentsClass.getOppDetails(importId,UserInfo.getUserId());
    }
}