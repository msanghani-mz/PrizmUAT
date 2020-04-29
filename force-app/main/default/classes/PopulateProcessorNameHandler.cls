public class PopulateProcessorNameHandler {
    
    public static void PopulateProcessorName(){
        // set<id> oppId=new set<Id>();
        set<id> AppId=new Set<Id>();  //@
        map<String,id> mapProcessorNameToId = new map<String,id>();
        List<Opportunity> OpportunityList = (List<Opportunity>)Trigger.new;
        Map<Id, Opportunity> opportunityOldMap = (Map<Id, Opportunity>) Trigger.oldMap ;
        // map<id,id> mapOppIdToAccount= new  map<id,id>();      
        list<Account> lstToUpdate=new list<Account>();
        //list<Account> lstAccc= [Select id,Name,Processor__c from Account where id in : AppId];
        for(Opportunity op:OpportunityList){
            //mapOppIdToAccount.put(op.Id,op.Applicant_Name__c); 
            AppId.add(op.Applicant_Name__c);
            AppId.add(op.Co_Applicant_Name__c);
        }
        
        for(nu_dse__Processor__c p: [Select id,Name from nu_dse__Processor__c]){
            mapProcessorNameToId.put(p.Name , p.Id);
        }
        
        map<id,Account> mapIdToAcc= new map<id,Account>([Select id,nu_dse__Co_First_Name__c,nu_dse__Co_Last_Name__c,nu_dse__Co_Date_of_Birth__c,FirstName,LastName,PersonBirthdate from Account where id in: AppId]);   //@
        Set<Id> accountIdToUpdate = new Set<Id>() ;
        for(Opportunity op:OpportunityList){
            if(opportunityOldMap.get(op.Id).StageName != op.StageName && op.StageName=='Closed Won') {
                
                
                if(String.isNotBlank(op.Co_Applicant_Name__c) && !accountIdToUpdate.contains(op.Co_Applicant_Name__c)){
                    accountIdToUpdate.add(op.Co_Applicant_Name__c) ;
                    lstToUpdate.add(new Account(
                        Id = op.Co_Applicant_Name__c ,
                        //nu_dse__Co_First_Name__c= op.Co_Applicant_Name__r
                        Processor__c = mapProcessorNameToId.get(op.Payment_Processor_Name__c)
                    )); 
                }
                if(String.isNotBlank(op.Applicant_Name__c) &&  String.isNotBlank(op.Co_Applicant_Name__c) && String.isBlank(mapIdToAcc.get(op.Applicant_Name__c).nu_dse__Co_First_Name__c)  && !accountIdToUpdate.contains(op.Applicant_Name__c)){
                    accountIdToUpdate.add(op.Applicant_Name__c) ;
                    lstToUpdate.add(new Account(
                        Id = op.Applicant_Name__c ,
                        nu_dse__Co_First_Name__c= mapIdToAcc.get(op.Co_Applicant_Name__c).FirstName,
                        nu_dse__Co_Last_Name__c= mapIdToAcc.get(op.Co_Applicant_Name__c).LastName,
                        nu_dse__Co_Date_of_Birth__c= mapIdToAcc.get(op.Co_Applicant_Name__c).PersonBirthdate ,
                        Processor__c = mapProcessorNameToId.get(op.Payment_Processor_Name__c)
                    ));
                } else if(String.isNotBlank(op.Applicant_Name__c) &&  !accountIdToUpdate.contains(op.Applicant_Name__c)){ 
                    accountIdToUpdate.add(op.Applicant_Name__c) ;
                    lstToUpdate.add(new Account(
                        Id = op.Applicant_Name__c ,
                        
                        Processor__c = mapProcessorNameToId.get(op.Payment_Processor_Name__c)
                    ));
                }  
            }
            
        }
        if(lstToUpdate.size()>0){
            update lstToUpdate ;
            system.debug('@@@@lstToUpdate'+lstToUpdate);
        }
    }
    
   /* public static void SubmitApplicationError()
    {
       List<Opportunity> OpportunityList = (List<Opportunity>)Trigger.new;
        for(Opportunity opp:OpportunityList){
            if(opp.Is_Application_Submitted__c && opp.Is_Application_Submit_Confirmed__c && opp.Related_Lending_Application__c!=null){
               opp.addError('Given Application already have Lending Application');
             }
                             
        }
    } */

    public static void validateBankAccounts(List<Opportunity> OpportunityList, Map<Id, Opportunity> opportunityOldMap) {
        Map<Id, Id> opportunityIdByAccountIdMap = new Map<Id, Id>();
        for (Opportunity newOpportunity: OpportunityList) {
            Opportunity oldOpportunity = opportunityOldMap.get(newOpportunity.Id);
            if ((newOpportunity.StageName == 'Closed Won' && newOpportunity.StageName != oldOpportunity.StageName) 
                || (newOpportunity.Is_Application_Submitted__c && !oldOpportunity.Is_Application_Submitted__c)
                && !String.isEmpty(newOpportunity.AccountId)) {
                    opportunityIdByAccountIdMap.put(newOpportunity.AccountId, newOpportunity.Id);
            }
        }
        Map<Id, fsCore__Bank_Account__c> bankAccountByAccountId = new Map<Id, fsCore__Bank_Account__c>();
        if (!opportunityIdByAccountIdMap.isEmpty()) {
            for (fsCore__Bank_Account__c bankAccount: [Select Id, Name, fsCore__Account_Name__c, fsCore__Bank_Account_Number__c, fsCore__Bank_Account_Type__c, fsCore__Bank_Identification_Code__c from fsCore__Bank_Account__c where fsCore__Account_Name__c IN: opportunityIdByAccountIdMap.keySet()]) {
                bankAccountByAccountId.put(bankAccount.fsCore__Account_Name__c, bankAccount);
            }
            for (Opportunity newOpportunity: OpportunityList) {
                if (!bankAccountByAccountId.containsKey(newOpportunity.AccountId)) {
                    newOpportunity.addError('No bank account record found for this applicant. Please enter this information based on NuDebt or based on applicant’s input.');
                } else {
                    fsCore__Bank_Account__c bankAccount = bankAccountByAccountId.get(newOpportunity.AccountId);
                    if (String.isEmpty(bankAccount.fsCore__Bank_Account_Number__c)) {
                        newOpportunity.addError('"Bank Account #" not populated in applicant\'s bank account record. Please enter this information to continue');
                    } else if (String.isEmpty(bankAccount.fsCore__Bank_Account_Type__c)) {

                        newOpportunity.addError('"Bank Account Type" not populated in applicant\'s bank account record. Please enter this information to continue');
                    } else if (String.isEmpty(bankAccount.fsCore__Bank_Identification_Code__c)) {
                        newOpportunity.addError('"Bank Identification Code" not populated in applicant\'s bank account record. Please enter this information to continue');
                    }
                }
            }
        }    
    }
    
    public static void appendOpportunityComment(List<opportunity> opportunityList, Map<Id,opportunity> opportunityOldMap){
        Set<Id> oppIdsToUpdateComment = new Set<Id>();
        for(Opportunity newOpportunity :opportunityList){
            Opportunity oldOpportunity = opportunityOldMap.get(newOpportunity.Id);
            if(newOpportunity.StageName=='Closed Lost'&& newOpportunity.StageName!=oldOpportunity.StageName){
                oppIdsToUpdateComment.add(newOpportunity.Id);
                //newOpportunity.Comments__c += 'Test1' ;
                //system.debug('+++++newOpportunity.Comments__c+++++'+newOpportunity.Comments__c);
            }
        }
        if (!oppIdsToUpdateComment.isEmpty()) {
            appendComment(oppIdsToUpdateComment);
        }
    }
    
	@future
    public static void appendComment(Set<Id> opportunityIds){    
    	List<Opportunity> oppToUpdate = new List<Opportunity>();
        for (Opportunity opp: [Select Id, Comments__c from Opportunity where Id IN :opportunityIds]) {
            if (!String.isEmpty(opp.Comments__c)) {
            	opp.Comments__c += '\n'+'/<*** Task closed automatically when opportunity was Closed Lost by ' +UserInfo.getName()+' on '+system.now() +' ***>/';    
            } else {
                opp.Comments__c = '/<**** Task closed automatically when opportunity was Closed Lost by ' + UserInfo.getName()+  ' on '+system.now() +' ***>/';    
            }  
            oppToUpdate.add(opp);
        }
        update oppToUpdate;
    }
}