/**
 * @File Name          : LendingAppApprovalCompController.cls
 * @Description        : 
 * @Author             : mz-sfdc-devs@mindzcloud.com
 * @Group              : 
 * @Last Modified By   : mz-sfdc-devs@mindzcloud.com
 * @Last Modified On   : 9/16/2019, 5:58:56 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/15/2019   mz-sfdc-devs@mindzcloud.com     Initial Version
**/

public class LendingAppApprovalCompController {
    @AuraEnabled  
    public static ApprovalList getApprovalData(){  
        ApprovalList approvalResultForObject = new ApprovalList();  
        List<ApprovalStepWrapper> lstApprovalStepWrapper = new List<ApprovalStepWrapper>(); 
        String recallApprovalProcessLink;  
        Boolean isSubmitForApproval = true; 
        processDefinition pd_AppDeclApprvl=[Select id,name from processDefinition where name='Application Decline Approval'];
        processDefinition pd_UnderwriterApprvl=[Select id,name from processDefinition where name='Underwriter Final Approval'];
        Id ApplicationDeclineApproval=pd_AppDeclApprvl.id;
        Id UnderwriterAppApproval=pd_UnderwriterApprvl.Id;
        set<ID> setLendingAppId = new set<ID>();
        set<String> SetName = new set<String>();
        for(ProcessInstance processInstance: getProcessHistory().values()){  
            for(ProcessInstanceHistory stepsWorkItem:processInstance.StepsAndWorkitems){  
                setLendingAppId.add(stepsWorkItem.TargetObjectId);  
            } 
        }
        system.debug('--setLendingApp : ' + setLendingAppId);
        
        map<Id, fsCore__Lending_Application__c> mapLendingApp = new map<Id, fsCore__Lending_Application__c>([Select id,name,fsCore__Title__c,OwnerId, Owner.Name ,Loan_Officer__c,Loan_Officer__r.Name,fsCore__Application_Received_Date__c,
                                                     Internal_Rejection_Reasons__c,Rejection_Reasons__c,fsCore__Current_Stage_Name__c, fsCore__Current_Stage_Name__r.Name,fsCore__Application_Status__c from fsCore__Lending_Application__c where Id IN :setLendingAppId]);


        
        for(ProcessInstance processInstance: getProcessHistory().values()){ 
            Map<Id,List<ProcessInstanceHistory>> mapOfProcessNodeIdAndProcessInstanceHistory = new Map<Id,List<ProcessInstanceHistory>>();  
            Set<Id> processNodeId= new Set<Id>(); 

            ApprovalStepWrapper approvalStepWrapper = new ApprovalStepWrapper();  
            for(ProcessInstanceHistory stepsWorkItem:processInstance.StepsAndWorkitems){ 
                fsCore__Lending_Application__c lApp = mapLendingApp.get(stepsWorkItem.TargetObjectId);

               /* if(stepsWorkItem.StepStatus == 'Approved' && lApp.Internal_Rejection_Reasons__c==null && processInstance.ProcessDefinitionId=='04a0W000001HkLNQA0'){  
                    approvalStepWrapper.listOfApproved.add(new ApprovalHistoryWrap(stepsWorkItem.CreatedDate, stepsWorkItem.StepStatus,lApp));  
                }  */
                    
                if(stepsWorkItem.StepStatus == 'Pending' && processInstance.ProcessDefinitionId==ApplicationDeclineApproval) {    
                    approvalStepWrapper.PendingList_ApplDeclineApproval.add(new ApprovalHistoryWrap(stepsWorkItem.CreatedDate, stepsWorkItem.StepStatus,lApp));  
                    
                }  
               
                if(stepsWorkItem.StepStatus == 'Pending' && processInstance.ProcessDefinitionId==UnderwriterAppApproval) { 
                    approvalStepWrapper.PendingList_UndwriterFinApproval.add(new ApprovalHistoryWrap(stepsWorkItem.CreatedDate, stepsWorkItem.StepStatus,lApp));  
                    
                }  
                     
               /* if(stepsWorkItem.StepStatus=='Approved' && lApp.Rejection_Reasons__c!=null && processInstance.ProcessDefinitionId=='04a0W000001HkLNQA0'){ 
                    System.debug('##Rejected Lending App:'+Lapp);
                    approvalStepWrapper.listOfRejected.add(new ApprovalHistoryWrap(stepsWorkItem.CreatedDate, stepsWorkItem.StepStatus,lApp));  
                }  */
               // approvalResultForObject.recordId = Lapp.Id;
                if(!SetName.contains(lApp.name)){
                   lstApprovalStepWrapper.add(approvalStepWrapper); 
                   SetName.add(lApp.name);
                }
                
            }  
        }
        approvalResultForObject.approvals = lstApprovalStepWrapper;  
        system.debug('--lstApprovalStepWrapper : ' + lstApprovalStepWrapper); 
        system.debug('--approvalResultForObject : ' + approvalResultForObject); 
        return approvalResultForObject;  
    }  

    /*  
    * This method queries the processinstance and workitem for the record  
    * Parameter: Record ID   
    * Returns: Map of all processinstance related to the record id  
    */  
    @AuraEnabled  
    public static Map<Id,ProcessInstance> getProcessHistory()  //Id objectId
    {  
        Map<Id,ProcessInstance> mapProcessInstance;
        map<Id,fsCore__Lending_Application__c> Lstapp=new map<Id,fsCore__Lending_Application__c>([Select id,name,fsCore__Title__c,OwnerId,Loan_Officer__c,fsCore__Application_Received_Date__c,
                                                     Internal_Rejection_Reasons__c,Rejection_Reasons__c,fsCore__Current_Stage_Name__c,fsCore__Application_Status__c from fsCore__Lending_Application__c]);
        mapProcessInstance=new Map<Id,ProcessInstance>([SELECT Id,ProcessDefinitionId, (SELECT ID, ProcessNodeId,  
                                                                    StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                                    ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                                                    OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by CreatedDate DESC )   
                                                        FROM ProcessInstance where TargetObjectId in :Lstapp.keyset() order by CreatedDate DESC]); 
                                                   
        return mapProcessInstance;
    } 

    /*
    * Wrapper class  
    */  
    public class ApprovalStepWrapper{  
        @AuraEnabled  
        public List<ApprovalHistoryWrap> listOfApproved {get;set;} 
        @AuraEnabled  
        public List<ApprovalHistoryWrap> PendingList_ApplDeclineApproval {get;set;} 
        @AuraEnabled  
        public List<ApprovalHistoryWrap> PendingList_UndwriterFinApproval {get;set;} 
        public ApprovalStepWrapper(){  
            listOfApproved = new List<ApprovalHistoryWrap>();  
            PendingList_ApplDeclineApproval=new List<ApprovalHistoryWrap>();
            PendingList_UndwriterFinApproval=new List<ApprovalHistoryWrap>();
        }  
    }  

    /*  
    * Wrapper class  
    */  
    public class ApprovalHistoryWrap{  
        @AuraEnabled  
        public Date createdDate {get;set;}  
        @AuraEnabled  
        public string LoanOfficer {get;set;}  
        @AuraEnabled  
        public string steps {get;set;}  
        @AuraEnabled  
        public string Title {get;set;} 
        @AuraEnabled  
        public string AppName {get;set;}
        @AuraEnabled 
        public Date AppRecvdDate{get;set;}
        @AuraEnabled  
        public string AppStage {get;set;}
        @AuraEnabled  
        public string RejectionReason {get;set;}
        @AuraEnabled  
        public string OwnerID {get;set;}
        @AuraEnabled  
        public string LendAppRecID {get;set;}
        public ApprovalHistoryWrap(DateTime crDate, string stp, fsCore__Lending_Application__c la){  
            createdDate = crDate.date();  
            LoanOfficer = la.Loan_Officer__r.name; 
            steps = stp;  
            Title = la.fsCore__Title__c; 
            AppName = la.Name;
            AppRecvdDate = la.fsCore__Application_Received_Date__c;
            RejectionReason = la.Internal_Rejection_Reasons__c;
            AppStage = la.fsCore__Current_Stage_Name__r.Name;
            OwnerID = la.Owner.name;
            LendAppRecID=la.Id;
        }  
    }  

    /*  
    * Wrapper class  
    */  
    public class ApprovalList{   
        @AuraEnabled  
        public List<ApprovalStepWrapper> approvals {get;set;}  
        @AuraEnabled   
        public Boolean isSubmitForApproval {get;set;}  
        @AuraEnabled  
        public Id recordId {get;set;}  
        public ApprovalList(){  
            approvals = new List<ApprovalStepWrapper>();  
            isSubmitForApproval = true;  
        }  
    }  
}