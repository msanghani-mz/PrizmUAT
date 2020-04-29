/*
* Class Name : TaskObject
* Purpose    : This class is used as a data structure required to 
*              create the task in the PRIZM Org
* Developer  : Financial Spectra
*/
public class TaskObject {
    public String     mLendingApplicationName       {get; set;}
    public String     mLendingContractName          {get; set;}
    public String     mOpportunityName              {get; set;}    
    public Id         mLendingApplicationId         {get; set;}
    public Id         mLendingContractId            {get; set;}
    public Id         mOpportunityId                {get; set;}    
    public Id         mApplicationChecklistId       {get; set;}
    public String     mApplicationChecklistText     {get; set;}        
    public Id         mDocusignStatusId             {get; set;}            
    public String     mEntity                       {get; set;}    //Name of the object from which task creation is invoked
    public Id         mOwnerId                      {get; set;}
    public Id         mUserId                       {get; set;}
    public Id         mDocProcessorId               {get; set;}
    public Id         mLoanOfficerId                {get; set;}    
    public Id         mNegotiatorId                 {get; set;}           
    public Id         mRecordId                     {get; set;}    
    public Id         mParentRecordId               {get; set;}    
    public Id         mWhoId                        {get; set;}    
    public String     mDescription                  {get; set;} 
    public DateTime   mDueDate                      {get; set;} 
    
    //Making it private to disable the default constructor
    //The caller must call the defined contructor with the instance of the record.
    private TaskObject(){}
    
    //When constructing for the contract
    public TaskObject(fsServ__Lending_Contract__c pLendingContract ){
        mEntity = 'fsServ__Lending_Contract__c';
        mLendingContractId = pLendingContract.Id;
        mLendingContractName = pLendingContract.Name;
        mOwnerId        = pLendingContract.OwnerId;
        //mDocProcessorId = pLendingApplication.Docs_Processor_Name__c;
        //mLoanOfficerId  = pLendingApplication.Loan_Officer__c;
        mRecordId = pLendingContract.id;
        mParentRecordId = pLendingContract.id;
        mWhoId = pLendingContract.fsServ__Primary_Customer_Contact__c;
        mUserId = UserInfo.getUserId();
    }    
    
    //When constructing for the application
    public TaskObject(fsCore__Lending_Application__c pLendingApplication ){
        mEntity = 'fsCore__Lending_Application__c';
        mLendingApplicationId = pLendingApplication.Id;
        mLendingApplicationName = pLendingApplication.Name;
        mOwnerId        = pLendingApplication.OwnerId;
        mDocProcessorId = pLendingApplication.Docs_Processor_Name__c;
        mLoanOfficerId  = pLendingApplication.Loan_Officer__c;
        mRecordId = pLendingApplication.id;
        mParentRecordId = pLendingApplication.id;
        mWhoId = pLendingApplication.fsCore__Primary_Customer_Contact__c;
        mUserId = UserInfo.getUserId();
    }
    
    //When constructing for the Opportunity
    public TaskObject(Opportunity pOpportunity ){
        mEntity = 'Opportunity';
        mOpportunityId = pOpportunity.Id;
        mOpportunityName = pOpportunity.Name;
        mOwnerId        = pOpportunity.OwnerId;
        mRecordId = pOpportunity.id;
        mParentRecordId = pOpportunity.id;
        mUserId = UserInfo.getUserId();
        mWhoId = pOpportunity.Account.personcontactId;
        //mDocProcessorId = pLendingApplication.Docs_Processor_Name__c;
        //mLoanOfficerId  = pLendingApplication.Loan_Officer__c;        
    }
    //When constructing for the fsCore__Lending_Application_Checklist__c
    public TaskObject(fsCore__Lending_Application_Checklist__c pLendingApplicationChecklist ){
        mEntity = 'fsCore__Lending_Application_Checklist__c';
        mLendingApplicationId = pLendingApplicationChecklist.fsCore__Lending_Application_Number__c;
        mLendingApplicationName = pLendingApplicationChecklist.Lending_Application_Name_Formula__c;
        mRecordId = pLendingApplicationChecklist.id;
        mParentRecordId = pLendingApplicationChecklist.fsCore__Lending_Application_Number__c;
        mApplicationChecklistText = pLendingApplicationChecklist.fsCore__Checklist_Item__c;
        mUserId = UserInfo.getUserId();
        if (pLendingApplicationChecklist.Primary_Contact_Id_Formula__c != null){
            mWhoId = Id.valueOf(pLendingApplicationChecklist.Primary_Contact_Id_Formula__c);
        }        
        
        if (pLendingApplicationChecklist.Lending_Application_Owner_Id__c != null){
            mOwnerId   = Id.ValueOf(pLendingApplicationChecklist.Lending_Application_Owner_Id__c);
        }
        if (pLendingApplicationChecklist.Lending_Application_Doc_Processor_Id__c != null){
            mDocProcessorId = Id.ValueOf(pLendingApplicationChecklist.Lending_Application_Doc_Processor_Id__c);
        }
        if (pLendingApplicationChecklist.Lending_Application_Loan_Officer_Id__c != null){
            mLoanOfficerId  = Id.ValueOf(pLendingApplicationChecklist.Lending_Application_Loan_Officer_Id__c);
        }        
        
        
    } 
    //When constructing for the dsfs__DocuSign_Status__c
    public TaskObject(dsfs__DocuSign_Status__c pDocusignStatus ){
        mEntity = 'dsfs__DocuSign_Status__c';
        mLendingApplicationId = pDocusignStatus.Lending_Application_Name__c;
        mLendingApplicationName = pDocusignStatus.Lending_Application_Name_Formula__c;
        mOpportunityId = pDocusignStatus.dsfs__Opportunity__c;
        mOpportunityName = pDocusignStatus.Opportunity_Name_Formula__c;
        mRecordId = pDocusignStatus.id;
        mParentRecordId = pDocusignStatus.Lending_Application_Name__c;
        mUserId = UserInfo.getUserId();
        if (pDocusignStatus.Contact_Id_Formula__c != null){
            mWhoId = Id.valueOf(pDocusignStatus.Contact_Id_Formula__c);
        }
        
        if (pDocusignStatus.Lending_Application_Owner_Id__c != null){
            mOwnerId   = Id.ValueOf(pDocusignStatus.Lending_Application_Owner_Id__c);
        }
        if (pDocusignStatus.Lending_Application_Doc_Processor_Id__c != null){
            mDocProcessorId = Id.ValueOf(pDocusignStatus.Lending_Application_Doc_Processor_Id__c);
        }
        if (pDocusignStatus.Lending_Application_Loan_Officer_Id__c != null){
            mLoanOfficerId  = Id.ValueOf(pDocusignStatus.Lending_Application_Loan_Officer_Id__c);
        }
    }
    //When constructing for the fsCore__Lending_Application_Stage__c
    public TaskObject(fsCore__Lending_Application_Stage__c plAppStage ){
        mEntity = 'fsCore__Lending_Application_Stage__c';
        mLendingApplicationId = plAppStage.fsCore__Lending_Application_Number__c;
        mLendingApplicationName = plAppStage.Lending_Application_Name_Formula__c;
        mRecordId = plAppStage.id;
        if (plAppStage.Opportunity_Id_Formula__c != null){
            mOpportunityId = Id.valueOf(plAppStage.Opportunity_Id_Formula__c);
        }
        mOpportunityName = plAppStage.Opportunity_Name_Formula__c;
        
        
        mParentRecordId = plAppStage.fsCore__Lending_Application_Number__c;
        mUserId = UserInfo.getUserId();
        if (plAppStage.Primary_Contact_Id_Formula__c != null){
            mWhoId = Id.valueOf(plAppStage.Primary_Contact_Id_Formula__c);
        }
        
        if (plAppStage.Lending_Application_Owner_Id__c != null){
            mOwnerId   = Id.ValueOf(plAppStage.Lending_Application_Owner_Id__c);
        }
        if (plAppStage.Lending_Application_Doc_Processor_Id__c != null){
            mDocProcessorId = Id.ValueOf(plAppStage.Lending_Application_Doc_Processor_Id__c);
        }
        if (plAppStage.Lending_Application_Loan_Officer_Id__c != null){
            mLoanOfficerId  = Id.ValueOf(plAppStage.Lending_Application_Loan_Officer_Id__c);
        }
    }
    
    //When constructing for the fsServ__Inbound_Payment__c
    public TaskObject(fsServ__Inbound_Payment__c pInboundPayment ){
        mEntity = 'fsServ__Inbound_Payment__c';
        mLendingContractId = pInboundPayment.fsServ__Lending_Contract_Number__c;
        mLendingContractName = pInboundPayment.Lending_Contract_Name_Formula__c;
        
        mRecordId = pInboundPayment.id;
        mParentRecordId = pInboundPayment.fsServ__Lending_Contract_Number__c;
        mUserId = UserInfo.getUserId();
        if (pInboundPayment.fsServ__Contact_Name__c != null){
            mWhoId = pInboundPayment.fsServ__Contact_Name__c;
        }
        if (pInboundPayment.Lending_Contract_Owner_Id__c != null){
            mOwnerId   = Id.ValueOf(pInboundPayment.Lending_Contract_Owner_Id__c);
        }
    }    
    
    /**
* @description This method will only be called when we construct the object using the instance of dsfs__DocuSign_Status__c
* because if we are constructing for opportunity then set the owner using opp
* Otherwise set it using application.
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 8/11/2019
* @param Id pOwnerId
* @return void
*/
    public void setOwnerId(Id pOwnerId){
        mOwnerId = pOwnerId;
    }
    
    //To override the user set by the constructor
    public void setUserId(Id pUserId){
        mUserId = pUserId;
    }    
    
    public void setTaskDescription(fsCore__Lending_Application__c pLendingApplication ){
        mDescription = pLendingApplication.fsCore__Comments__c ;
    } 
    public void setTaskDescription(String pDescription ){
        mDescription = pDescription;
    }
    //DV-453
    public void setTaskDueDateTime(DateTime pDueDate ){
        mDueDate = pDueDate;
    }
    
}