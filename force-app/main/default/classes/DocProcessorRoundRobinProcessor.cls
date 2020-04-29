/**
* Class Name  : DocProcessorRoundRobinProcessor
* Description : Action class to updates the Doc Processor Name on the lending application (PDI-677)
* Author      : Financial Spectra
*             
* Detailed Description :1)  This class will pick the eligible # of DNL applications where the Doc Processor Name IS NOT STAMPED
*                           and the current stage is the DNL_DOC_PROCESSING.
*                       2)  PICK All users where the profile is DNL Doc Collector and isActive = true
*                       3)  Using round robin populate Docs_Processor_Name__c on the application.
*/ 
global virtual class DocProcessorRoundRobinProcessor implements fsCore.ActionProcessor{         
    private static final String CLASS_NAME = 'DocProcessorRoundRobinProcessor';
    
    public Map<Id, fsCore__Lending_Application__c> mApplicationMap;   //changed from private to public**
    public fsCore.ActionInput mActionInput;          //changed from private to public**
    private fsCore.ActionOutput mActionOutput;
    private Set<Id> mErrorAppIdSet;
    private Set<Id> mAppNotFoundSet;
    private Integer mTotalExistingAppCount;
    public Map<Id,Integer> mDocProcessorExistingAppCountMap; 
    private List<User> mDocProcessorUserList;
    
    
    global DocProcessorRoundRobinProcessor(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
        mErrorAppIdSet = new Set<Id>();
        mAppNotFoundSet = new Set<Id>();        
        mDocProcessorExistingAppCountMap = new Map<Id,Integer>();
        mDocProcessorUserList = new List<User>();
    }
    global void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }    
    public void populateAndValidateRelatedData(){
        fsCore.Logger.enter(CLASS_NAME,'populateAndValidateRelatedData()');
        
        filterEligibleRecords();
        populateExistingAssignmentsCount();
        populateEligibleUsers();
        
        fsCore.Logger.exit(CLASS_NAME,'populateAndValidateRelatedData()');
    }
    
    private void filterEligibleRecords(){
        System.debug(mApplicationMap.Size());
        
        for (fsCore__Lending_Application__c app : mApplicationMap.values()){
            //ONLY IF THE DOC PROCESSOR NAME IS NULL
            //CURRENT STAGE IS DOCS PROCESSING AND LOAN IS DNL THEN PERFORM ROUND ROBIN.
            if ((app.Docs_Processor_Name__c == null)
                && (app.Current_Stage_Code_Formula__c == 'DNL_DOC_PROCESSING')
                && (app.Loan_Type__c == 'DNL')){
                    
                }else{
                    logmessage(' App Name :'+app.Name+' Not eligible '+
                               ' Doc Processor Name :'+app.Docs_Processor_Name__c+
                               ' Loan Type :'+app.Loan_Type__c+
                               ' Current Stage :'+app.Current_Stage_Code_Formula__c);
                    //KEEP ADDING NON ELIGIBLE RECORDS TO THE mErrorAppIdSet TO FILTER OUT LATER
                    mErrorAppIdSet.add(app.Id);
                }
            
        }
        
    }
    
    
    private void populateExistingAssignmentsCount(){
        
        List<AggregateResult> aggResult = [SELECT Docs_Processor_Name__c docProcessorName
                                           , count(Id) num 
                                           FROM fsCore__Lending_Application__c 
                                           WHERE Current_Stage_Code_Formula__c = 'DNL_DOC_PROCESSING'
                                           AND Docs_Processor_Name__c != null
                                           AND Loan_Type__c = 'DNL'
                                           AND fsCore__Is_Application_Read_Only__c = false //IGNORE READ ONLY APPLICATIONS
                                           AND Docs_Processor_Name__r.isActive = true //PICK THE APP FOR ACTIVE DOC PROCESSING USERS ONLY
                                           GROUP BY Docs_Processor_Name__c, fsCore__Current_Stage_Name__c];
        
        
        mTotalExistingAppCount = 0;
        for(AggregateResult agg :aggResult){            
            mDocProcessorExistingAppCountMap.put((Id)agg.get('docProcessorName'),(Integer)agg.get('num'));
            mTotalExistingAppCount += mDocProcessorExistingAppCountMap.get((Id)agg.get('docProcessorName'));
        }
        
    }
    private void populateEligibleUsers(){
        
        //users where profile name is 'DNL Doc Collector' are only eligible for round robin
        mDocProcessorUserList = [SELECT id
                                      , FirstName
                                      , LastName
                                      , IsActive
                                      , Profile.name 
                                      , Round_Robin_Allocation_percent__c
                                   FROM User 
                                  WHERE Profile.name='DNL Doc Collector' 
                                    AND isActive = true 
                                    AND IsRoundRobinAllocationEnabled__c = true];      //added FirstName & Lastname in Select Query**
        System.debug(mDocProcessoruserList);
        
        logMessage('# Of Users among which the round robin will happen '+mDocProcessorUserList.Size());
        
        
        //THERE COULD BE A SITUATION WHEN NO APPLICATION IS ASSIGNED TO THE ELIGIBLE USER
        //IN THAT CASE ADD A ENTRY WITH 0 VALUE
        for(User usr : mDocProcessorUserList){
            if (usr.Round_Robin_Allocation_percent__c == null){
                usr.Round_Robin_Allocation_percent__c = 100;
            }
            if (!(mDocProcessorExistingAppCountMap.containsKey(usr.Id))) {
                mDocProcessorExistingAppCountMap.put(usr.Id,0);
            }
        }
        System.debug('mDocProcessorExistingAppCountMap: '+mDocProcessorExistingAppCountMap);
    }    
    
    global void process(){
        Savepoint processingSP = Database.setSavepoint();
        try{
            //populate application and validate
            populateAndValidateApplications();
            
            //populate related data and validate
            if (mApplicationMap.size() > 0){
                populateAndValidateRelatedData();
                removeErroneousApplications();
            }            
            logMessage('mApplicationMap : ' + mApplicationMap.size());
            //do processing
            if (mApplicationMap.size() > 0){
                doProcess();
            }
        } catch (Exception e){
            Database.rollback(processingSP);
            mActionOutput.addError(new fsCore.ErrorObject(e));
        }
    }
    
    private void removeErroneousApplications(){
        //remove erroneous apps from application map
        for(Id errAppId : mErrorAppIdSet){
            if (mApplicationMap.containsKey(errAppId)){ mApplicationMap.remove(errAppId); }
        }
        logMessage('Applications to be processed after filtering : ' + mApplicationMap.size());
        
        //reset the error application set
        mErrorAppIdSet = new Set<Id>();
    }
    
    private void populateAndValidateApplications(){
        mApplicationMap = fsCore.LendingApplicationUtil.getApplications(mActionInput.getRecords());
    }    
    
    private void doProcess(){  
        
        logMessage(CLASS_NAME+'.doProcess()');
        
        MAP<Id,fsCore__Lending_Application__c> lapplicationUpdateMap = new MAP<Id,fsCore__Lending_Application__c>();
        
        
        Map<Id,Integer> docProcessorAppPercentMap = new Map<Id,Integer>();
        Decimal totalPercent = 0;
        for(User usr : mDocProcessorUserList){
            totalPercent += usr.Round_Robin_Allocation_percent__c ;
        }
        Decimal extraAllocCount = 0;
        for(User usr : mDocProcessorUserList){
            if (usr.Round_Robin_Allocation_percent__c == 0){
                docProcessorAppPercentMap.put(usr.Id,0);
            }else{
                integer totalApps = mTotalExistingAppCount + mApplicationMap.size();
                docProcessorAppPercentMap.put(usr.Id,Integer.ValueOf(((usr.Round_Robin_Allocation_percent__c/totalPercent)*100)));
                Decimal allocPercent = ((usr.Round_Robin_Allocation_percent__c/totalPercent)*100);
                logMessage(' allocPercent '+allocPercent);
                Decimal maximumAllocCount = (((allocPercent) *  totalApps) /100);
                logMessage(' maximumAllocCount '+maximumAllocCount);
                decimal delta = maximumAllocCount - Integer.valueOf(maximumAllocCount);
                logMessage(' delta '+delta);
                if (delta < 1){
                    extraAllocCount += delta;
                    maximumAllocCount -=  delta;
                }
                logMessage(' extraAllocCount '+extraAllocCount);
                if (extraAllocCount >= 1){
                    maximumAllocCount += extraAllocCount;
                    extraAllocCount = 0;
                }               
                docProcessorAppPercentMap.put(usr.Id,Integer.ValueOf(maximumAllocCount.round(System.RoundingMode.HALF_EVEN)));
                
            }
        }   

        
        for(User usr : mDocProcessorUserList){
            integer assignedAppCount = mDocProcessorExistingAppCountMap.get(usr.Id);
            if (docProcessorAppPercentMap.get(usr.Id)  > 0  && (docProcessorAppPercentMap.get(usr.Id) > assignedAppCount)){
                for (fsCore__Lending_Application__c app : mApplicationMap.values()){
                    if (lapplicationUpdateMap.containsKey(app.id)){
                        //THIS MEANS THE APP IS ALREADY GOT ASSIGNED SO SKIP IT
                        continue;
                    }
                    assignedAppCount +=1;
                    app.Docs_Processor_Name__c = usr.Id;
                    lapplicationUpdateMap.put(app.id,app);
                    if (assignedAppCount >= docProcessorAppPercentMap.get(usr.Id) ){
                        break;
                    }
                }     
            }           
        }



        /*for (fsCore__Lending_Application__c app : mApplicationMap.values()){
            Integer minCount = 99999;
            Integer maxCount = 0;
            Id minCountUser;
            Id maxCountUser;
            //THIS LOOP WILL FIND THE USER WHICH HAS THE MINIMUM NUMBER OF APPS ASSIGNED TO Docs_Processor_Name__c
            // AND WILL ASSIGN USING ROUND ROBIN
            for(User usr : mDocProcessorUserList){
                System.debug('mDocProcessorExistingAppCountMap.get(usr.Id): '+mDocProcessorExistingAppCountMap.get(usr.Id));
                if (mDocProcessorExistingAppCountMap.get(usr.Id) < minCount){
                    minCountUser = usr.Id;
                    minCount = mDocProcessorExistingAppCountMap.get(usr.Id);
                } else if (mDocProcessorExistingAppCountMap.get(usr.Id) > maxCount){
                    maxCountUser = usr.Id;
                    maxCount = mDocProcessorExistingAppCountMap.get(usr.Id);
                } else {
                    continue;
                }
            }
            logmessage('-- minCountUser : ' + minCountUser);
            app.Docs_Processor_Name__c = minCountUser;
            mDocProcessorExistingAppCountMap.put(minCountUser, mDocProcessorExistingAppCountMap.get(minCountUser) + 1);
            
            lapplicationUpdateList.add(app);            
        }*/
        
        Savepoint sp = Database.setSavepoint();
        try{
            Database.SaveResult[] applicationSR = Database.update(lapplicationUpdateMap.Values(), true);

            //PDI-517 MOVED FROM ApplicationCustomTriggerManager TO here
            createTaskList(lapplicationUpdateMap.Values(),'DNL_APP_IN_DOC_PROCESSING');

        }catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            Database.rollback(sp);
            mActionOutput.addError(e);
        }
        System.debug(loggingLevel.ERROR, '-- DocProcessorRoundRobinProcessor.process(-)');
        
        logMessage('-- Output : ' + String.valueOf(mActionOutput));
        
    }
    private void createTaskList(List<fsCore__Lending_Application__c> pRecList, String pTaskCode){
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        for (fsCore__Lending_Application__c lApp: pRecList){
            TaskObject tsk =  new TaskObject(lApp);
            taskObjectList.add(tsk);
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        TaskHandler.createTasks(taskObjectMap);

    }    
    @TestVisible
    private void addError(String pErrCode, String pErrMsg, String pTrace, Id pAppId, String pRelatedRecord){
        fsCore.ErrorObject errorObj = new fsCore.ErrorObject();
        errorObj.setErrorCode(pErrCode);
        errorObj.setErrorMessage(pErrMsg);
        
        if (pAppId != null){
            errorObj.setErrorRecordId(pAppId);
            mErrorAppIdSet.add(pAppId);
        }
        if (String.IsNotBlank(pRelatedRecord)){
            errorObj.setErrorRecord(pRelatedRecord);
        }
        
        addError(errorObj, pTrace);
    }
    @TestVisible
    private void addError(fsCore.ErrorObject pErrorObj, String pMethod){
        pErrorObj.setErrorStackTrace(getClassName() + '.' + pMethod);
        
        if (pErrorObj.getErrorRecordId() != null && mApplicationMap.containsKey(pErrorObj.getErrorRecordId())){
            pErrorObj.setErrorRecordName(mApplicationMap.get(pErrorObj.getErrorRecordId()).Name);
        }
        
        if (mActionInput.getRecords().size() == 1){
            mActionOutput.setMessage(pErrorObj.getErrorMessage());    
        }
        
        mActionOutput.addError(pErrorObj);
    }    
    
    
    private static void logmessage(Object pMessage){
        system.debug(logginglevel.error, pMessage);
    }     
    public String getClassName(){
        return CLASS_NAME;
    }
    global fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }    
}