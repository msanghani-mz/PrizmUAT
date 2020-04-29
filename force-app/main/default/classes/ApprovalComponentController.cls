public class ApprovalComponentController {  
    /*  
* This method will be called by the helper function  
* Parameter: recordId  
* Returns: instance of wrapper class  
*/  
    @AuraEnabled  
    public static ApprovalList getApprovalData(Id recId)  
    {  
        Id recordId = recId;  
        ApprovalList approvalResultForObject = new ApprovalList();  
        List<ApprovalStepWrapper> aSW = new List<ApprovalStepWrapper>();  
        String recallApprovalProcessLink;  
        Boolean isSubmitForApproval = true;  
        for(ProcessInstance pI: getProcessHistory(recordId).values())  
        { 
            
            Map<Id,List<ProcessInstanceHistory>> mapOfProcessNodeIdAndProcessInstanceHistory = new Map<Id,List<ProcessInstanceHistory>>();  
            Set<Id> processNodeId= new Set<Id>();  
            for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems)  
            {  
                if(processNodeId.size() ==0)  
                    processNodeId.add(sWI.ProcessNodeId);  
                else if(processNodeId.size()>0 && processNodeId.contains(sWI.ProcessNodeId)!= NULL)  
                    processNodeId.add(sWI.ProcessNodeId);  
            }  
            for(Id pNId: processNodeId)  
            {  
                ApprovalStepWrapper aSWr = new ApprovalStepWrapper();  
                fsCore__Lending_Application__c Lapp=[Select id,name,fsCore__Title__c,OwnerId,Loan_Officer__c,fsCore__Application_Received_Date__c,
                                                     Internal_Rejection_Reasons__c,Rejection_Reasons__c,fsCore__Current_Stage_Name__c,fsCore__Application_Status__c from fsCore__Lending_Application__c where id=:recordId];  //@
                for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems)  
                {  
                    if(sWI.processNodeId == pNID && SWI.StepStatus=='Approved' && Lapp.Internal_Rejection_Reasons__c==null)  
                    {  
                        aSWr.listOfApproved.add(new ApprovalHistoryWrap(sWI.CreatedDate, sWI.StepStatus,Lapp));  
                    }  
                    
                    if(sWI.processNodeId == pNID && SWI.StepStatus=='Pending')   
                    {  
                        aSWr.listOfSubmitted.add(new ApprovalHistoryWrap(sWI.CreatedDate, sWI.StepStatus,Lapp));  
                    }  
                    
                    if(sWI.processNodeId == pNID && SWI.StepStatus=='Approved' && Lapp.Rejection_Reasons__c!=null)  
                    {  //(Lapp.Internal_Rejection_Reasons__c!=null || Lapp.Internal_Rejection_Reasons__c!='')
                        aSWr.listOfRejected.add(new ApprovalHistoryWrap(sWI.CreatedDate, sWI.StepStatus,Lapp));  
                    }  
                    /* if(sWI.StepStatus == 'Pending')  
{  
isSubmitForApproval = false;  
}  */
                }  
                aSW.add(aSWr);  
            }  
        }  
        approvalResultForObject.approvals = aSW;  
        approvalResultForObject.recordId = recordId;  
        approvalResultForObject.isSubmitForApproval = isSubmitForApproval;  
        system.debug('asw'+aSW);  
        return approvalResultForObject;  
    }  
    /*  
* This method queries the processinstance and workitem for the record  
* Parameter: Record ID   
* Returns: Map of all processinstance related to the record id  
*/  
    @AuraEnabled  
    public static Map<Id,ProcessInstance> getProcessHistory(Id objectId)  
    {  
        Map<Id,ProcessInstance> mapProcessInstance;
        
        mapProcessInstance=new Map<Id,ProcessInstance>([SELECT Id, (SELECT ID, ProcessNodeId,  
                                                                    StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                                    ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                                                    OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by CreatedDate DESC )   
                                                        FROM ProcessInstance where TargetObjectId =:objectId order by CreatedDate DESC]);
        
        return mapProcessInstance;
    }  
    /*  
* Wrapper class  
*/  
    public class ApprovalStepWrapper{  
        @AuraEnabled  
        public List<ApprovalHistoryWrap> listOfApproved {get;set;} 
        @AuraEnabled  
        public List<ApprovalHistoryWrap> listOfSubmitted {get;set;} 
        @AuraEnabled  
        public List<ApprovalHistoryWrap> listOfRejected {get;set;} 
        //@AuraEnabled 
        //public List<fsCore__Lending_Application__c> LendingAppList{get;set;}  //@
        public ApprovalStepWrapper(){  
            listOfApproved = new List<ApprovalHistoryWrap>();  
            listOfSubmitted=new List<ApprovalHistoryWrap>();
            listOfRejected=new List<ApprovalHistoryWrap>();
        }  
    }  
    /*  
* Wrapper class  
*/  
    public class ApprovalHistoryWrap  
    {  
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
        fsCore__Lending_Application__c LendingApp{get;set;}  //@
        @AuraEnabled 
        public Date AppRecvdDate{get;set;}
        @AuraEnabled  
        public string AppStage {get;set;}
        @AuraEnabled  
        public string RejectionReason {get;set;}
        @AuraEnabled  
        public string OwnerID {get;set;}
        public ApprovalHistoryWrap(DateTime crDate, string stp, fsCore__Lending_Application__c la) //string actor string name, 
        {  
            createdDate = crDate.date();  
            //actorName = name; 
            User u=[Select id,name from user where id=:la.Loan_Officer__c];
            LoanOfficer=u.name; 
            steps = stp;  
            //assignedTo = actor; 
            Title=la.fsCore__Title__c; 
            AppName=la.Name;
            AppRecvdDate=la.fsCore__Application_Received_Date__c;
            RejectionReason=la.Internal_Rejection_Reasons__c;
            fsCore__Stage_Setup__c setUp=[Select id,name from fsCore__Stage_Setup__c where id=:la.fsCore__Current_Stage_Name__c];
            AppStage=setUp.name;
            User u1=[Select id,name from user where id=:la.OwnerId];
            OwnerID=u1.name;
        }  
    }  
    /*  
* Wrapper class  
*/  
    public class ApprovalList  
    {   
        @AuraEnabled  
        public List<ApprovalStepWrapper> approvals {get;set;}  
        // @AuraEnabled    
        //public List<fsCore__Lending_Application__c> LendingAppList{get;set;}  //@
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