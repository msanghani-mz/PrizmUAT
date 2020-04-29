/**
* Class Name  : ContractCustomTriggerManager
* Description : This class handles the custom logic for fsCore.LendingContractTrigger
* Author      : Financial Spectra
* 
*/
global with sharing class ContractCustomTriggerManager implements fsCore.TriggerManager {
    
    global void beforeInsert(List<sObject> pNewRecList){}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    
    //custom implementation of after trigger event
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        BoxFolderCreationQueueable createBoxFolder = new BoxFolderCreationQueueable(pNewRecMap.keySet());
        // enqueue the job for processing
        ID jobID = System.enqueueJob(createBoxFolder);
        createWelcomeTask(pNewRecList);
        //DV-234
        submitForRoundRobin(pNewRecList);
        
        //VF-3, create outbound payments on contract on VCL Funding Approval   
        createOutboundPayments(pNewRecList);
        
    }
    
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        // DV-6 (Update the fee template on program when invester name gets changed on contract)
        ContractTriggerHandler.updateFeeTemplate((List<fsServ__Lending_Contract__c>)pNewRecList, (Map<Id, fsServ__Lending_Contract__c>)pOldRecMap);        
    }
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
    
    private void createWelcomeTask(List<fsServ__Lending_Contract__c>pNewRecList){
        List<Task> welcomeTaskList = new List<Task>();
        List<fsServ__Lending_Contract__c> newVCLContractList = new List<fsServ__Lending_Contract__c>();
        List<fsServ__Lending_Contract__c> newDNLContractList = new List<fsServ__Lending_Contract__c>();
        for(fsServ__Lending_Contract__c contract : pNewRecList){
            if (contract.fsServ__Product_Code__c == 'VCL'){
                newVCLContractList.add(contract);
            }
            if (contract.fsServ__Product_Code__c == 'DNL'){
                newDNLContractList.add(contract);
            }
            
        }
        if (newVCLContractList.size() > 0){
            welcomeTaskList.addAll(getTaskList(newVCLContractList,'VCL_WELCOME_CALL'));
        }
        if (newDNLContractList.size() > 0){
            welcomeTaskList.addAll(getTaskList(newDNLContractList,'DNL_WELCOME_CALL'));
        }
        if(welcomeTaskList.size()>0){
            try{
                User u = [Select id , Name, 
                          IsActive from User 
                          where  Name = 'Veronica Sanchez'
                          and Profile.Name = 'Servicing'
                          and IsActive = true];
                System.debug(loggingLevel.ERROR, u);
                if(u != null){                
                    for(Task t : welcomeTaskList){
                        t.OwnerId = u.id;  
                    }                  
                }   
            } 
            catch(Exception e){
             System.debug(LoggingLevel.ERROR , e.getMessage());
            }
            
            insert welcomeTaskList;
        }
    }
    
    private List<Task> getTaskList(List<fsServ__Lending_Contract__c> pRecList, String pTaskCode){
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        
        for (fsServ__Lending_Contract__c lcontract: pRecList){
            TaskObject tsk =  new TaskObject(lcontract);
            
            tsk.setTaskDescription('A new client, ' + lcontract.fsServ__Title__c +' has been graduated. Please reach out to them for their welcome call');
            tsk.setTaskDueDateTime(System.now());
            taskObjectList.add(tsk);
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        
        return TaskHandler.updateDueDateToBusinessDate(TaskHandler.getTasks(taskObjectMap),true);
        
    }
    private static void createOutboundPayments(List<fsServ__Lending_Contract__c>pNewRecList){
        System.debug(loggingLevel.Error,'Outbound Payment Creation----');
        List<fsServ__Lending_Contract__c> VCLContracts = new List<fsServ__Lending_Contract__c>();
        Set<id>appids = new Set<Id>();
        for(fsServ__Lending_Contract__c contract : pNewRecList){
            if (contract.fsServ__Product_Code__c == 'VCL'){
                appids.add(contract.fsServ__Lending_Application_Number__c);
                VCLContracts.add(contract);
            }
        }
        Map<id, fsCore__Lending_Application__c> IdToAppMap = new Map<id, fsCore__Lending_Application__c>([Select id,fsCore__Primary_Customer_Account__r.fsCore__Primary_Bank_Account__c, Funding_Approver_Name__c,Funding_Approval_Date_Time__c,fsCore__Is_Funded__c,fsServ__Is_Contracted__c,Is_Funding_Approved__c from fsCore__Lending_Application__c where id In :appids]);
        List<fsCore__Outbound_Payment__c> outboundPayments = new List<fsCore__Outbound_Payment__c>();
        for(fsServ__Lending_Contract__c contract : VCLContracts){
            System.debug(loggingLevel.ERROR,'appApproved:---'+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).Is_Funding_Approved__c);
            System.debug(loggingLevel.ERROR,'appContracted:---'+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).fsServ__Is_Contracted__c);
            System.debug(loggingLevel.ERROR,'appNo:---'+contract.fsServ__Lending_Application_Number__c);
            System.debug(loggingLevel.ERROR,'appFunded--'+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).fsCore__Is_Funded__c);
            System.debug(loggingLevel.ERROR,'ConBranch:---'+contract.fsServ__Branch_Name__c);
            System.debug(loggingLevel.ERROR,'ConBank:---'+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).fsCore__Primary_Customer_Account__r.fsCore__Primary_Bank_Account__c);
            System.debug(loggingLevel.ERROR,'ConLoanAmt:---'+contract.fsServ__Financed_Amount__c);
            System.debug(loggingLevel.ERROR,'ConPriAccount--'+contract.fsServ__Primary_Customer_Account__c);
            System.debug(loggingLevel.ERROR,'ConApprover--'+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).Funding_Approver_Name__c);
            System.debug(loggingLevel.ERROR,'ConApprovalDate--'+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).Funding_Approval_Date_Time__c);
            
            if(IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).Is_Funding_Approved__c){
                System.debug(loggingLevel.Error,'Outbound Payment Creation----1');
                fsCore__Outbound_Payment__c outboundPayment = new fsCore__Outbound_Payment__c();
                outboundPayment.fsCore__Company_Name__c =  contract.fsServ__Company_Name__c;
                outboundPayment.fsCore__Branch_Name__c = contract.fsServ__Branch_Name__c;
                outboundPayment.fsCore__Payment_Date__c = Date.today();
                outboundPayment.fsCore__Payment_Amount__c = contract.fsServ__Financed_Amount__c;
                outboundPayment.fsCore__Payment_Status__c = 'Ready';
                outboundPayment.fsCore__Account_Name__c = contract.fsServ__Primary_Customer_Account__c;
                outboundPayment.fsCore__Comment__c ='Funding approved by '+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).Funding_Approver_Name__c+' on '+IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).Funding_Approval_Date_Time__c ; 
                outboundPayment.fsCore__Payment_Method__c = 'Electronic Clearing';
                outboundPayment.fsCore__Bank_Account_Name__c = IdToAppMap.get(contract.fsServ__Lending_Application_Number__c).fsCore__Primary_Customer_Account__r.fsCore__Primary_Bank_Account__c;
                outboundPayment.fsServ__Lending_Contract_Number__c = contract.id;
                outboundPayment.fsCore__Payment_Source__c = 'Disbursement';
                outboundPayments.add(outboundPayment);
                System.debug(loggingLevel.Error,'Outbound Payment Creation----1 end');
            }
        }
        if(outboundPayments.size()>0){
            insert outboundPayments;   
        }        
        System.debug(loggingLevel.Error,'Outbound Payment Creation----End');
    }
    //DV-234
    private void submitForRoundRobin(List<fsServ__Lending_Contract__c>pNewRecList){
        Set<id> DNLContracts = new Set<id>();
        for(fsServ__Lending_Contract__c contract : pNewRecList){
            if (contract.fsServ__Product_Code__c == 'DNL'){
                DNLContracts.add(contract.id);
            }
        } 
        if(DNLContracts.size()>0){
            System.enqueueJob(new ServicingRoundRobinQueueable(DNLContracts));  
            
        }
        
    }
    
}