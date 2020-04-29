/**
* Class Name  : UnderwriterRoundRobinProcessor
* Description : Action class to updates the OwnerId on the lending application (DV-65)
* Author      : Financial Spectra
*             
* Detailed Description :1)  This class will assign owners to the lending app using the round robin % age basis.
*                           
*/ 
global virtual class UnderwriterRoundRobinProcessor implements fsCore.ActionProcessor{         
    private static final String CLASS_NAME = 'UnderwriterRoundRobinProcessor';
    
    public Map<Id, fsCore__Lending_Application__c> mApplicationMap;  
    public fsCore.ActionInput mActionInput;     
    private fsCore.ActionOutput mActionOutput;
    private Set<Id> mErrorAppIdSet;
    private Set<Id> mAppNotFoundSet;
    private Integer mTotalExistingAppCount;
    public Map<Id,Integer> mUWExistingAppCountMap; 
    private List<User> mUnderwritersUserList;
    private Map<Id,String> mUnderwritersNameMap;
    
    
    global UnderwriterRoundRobinProcessor(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
        mErrorAppIdSet = new Set<Id>();
        mAppNotFoundSet = new Set<Id>();        
        mUWExistingAppCountMap = new Map<Id,Integer>();
        mUnderwritersUserList = new List<User>();
        mUnderwritersNameMap = new Map<Id,String>();
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
            //ONLY IF THE Application_Owner_Name__c IS NULL AND FOR DNL LOANS
            if ((app.Application_Owner_Name__c == null)
                && (app.Loan_Type__c == 'DNL')){
                    
                }else{
                    logmessage(' App Name :'+app.Name+' Not eligible '+
                               ' UW Name :'+app.Application_Owner_Name__c+
                               ' Loan Type :'+app.Loan_Type__c);
                    //KEEP ADDING NON ELIGIBLE RECORDS TO THE mErrorAppIdSet TO FILTER OUT LATER
                    //mErrorAppIdSet.add(app.Id);
                }
            
        }
        
    }
    
    
    private void populateExistingAssignmentsCount(){
        Date todaysDate = Date.today();
        Date roundRobinStartDate = todaysDate.toStartofWeek();
        
        system.debug(logginglevel.error,'roundRobinStartDate :'+roundRobinStartDate);
        
        
        
        //date date1 = date.newInstance(2019,11,18);
        
        List<AggregateResult> aggResult = [SELECT ownerId //ON ALL DNL APP, IDEALLY Application_Owner_Name__c SHOULD BE SAME AS OWNER ID         
                                           , count(Id) num 
                                           FROM fsCore__Lending_Application__c 
                                           //where Application_Owner_Assignment_Date__c = :Date.today() //PDI-711 CONSIDER ONLY TODAY'S APPS
                                           where Application_Owner_Assignment_Date__c >= :roundRobinStartDate //DV-65 Weekly Load
                                           AND Application_Owner_Name__c != null //THIS SHOULD NEVER HAPPEN BUT JUST IN CASE.
                                           GROUP BY ownerId];
        
        
        mTotalExistingAppCount = 0;
        for(AggregateResult agg :aggResult){    
            mUWExistingAppCountMap.put((Id)agg.get('ownerId'),(Integer)agg.get('num'));
            mTotalExistingAppCount += mUWExistingAppCountMap.get((Id)agg.get('ownerId'));
            
        }
        system.debug(logginglevel.error,' Done populateExistingAssignmentsCount');
    }
    private void populateEligibleUsers(){
        logMessage('Inside populateEligibleUsers');
        //users where profile name is 'Underwriter' are only eligible for round robin
        mUnderwritersUserList = [SELECT id
                                 , FirstName
                                 , LastName
                                 , IsActive
                                 , Profile.name 
                                 , Round_Robin_Allocation_percent__c
                                 FROM User 
                                 WHERE Profile.name='Underwriter' 
                                 AND isActive = true 
                                 AND IsRoundRobinAllocationEnabled__c = true];      //added FirstName & Lastname in Select Query**
        
        System.debug(loggingLevel.ERROR,'mUnderwritersUserList'+mUnderwritersUserList);
        
        logMessage('# Of Users among which the round robin will happen '+mUnderwritersUserList.Size());
        
        
        //THERE COULD BE A SITUATION WHEN NO APPLICATION IS ASSIGNED TO THE ELIGIBLE USER
        //IN THAT CASE ADD A ENTRY WITH 0 VALUE
        for(User usr : mUnderwritersUserList){
            if (usr.Round_Robin_Allocation_percent__c == null){
                usr.Round_Robin_Allocation_percent__c = 100;
            }
            if (!(mUWExistingAppCountMap.containsKey(usr.Id))) {
                mUWExistingAppCountMap.put(usr.Id,0);
            }
            mUnderwritersNameMap.put(usr.Id,usr.FirstName);
            system.debug(logginglevel.error,' Existing '+usr.FirstName+'  -  '+mUWExistingAppCountMap.get(usr.Id));
        }
        System.debug('mUWExistingAppCountMap: '+mUWExistingAppCountMap);
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
        Map<id, String> mapUserIdToName = new Map<id,String>();
        MAP<Id,fsCore__Lending_Application__c> lapplicationUpdateMap = new MAP<Id,fsCore__Lending_Application__c>();
        Decimal minimumAllocation = 0;
        integer totalApps = mTotalExistingAppCount + mApplicationMap.size();
        for(User usr : mUnderwritersUserList){
            mapUserIdToName.put(usr.id,usr.FirstName);
            if(usr.Round_Robin_Allocation_percent__c > 0){
                if(minimumAllocation == 0){
                    minimumAllocation = usr.Round_Robin_Allocation_percent__c;  
                }
                else{
                    if(minimumAllocation > usr.Round_Robin_Allocation_percent__c) {
                        minimumAllocation = usr.Round_Robin_Allocation_percent__c;
                    }
                }
            }
        } 
        System.debug(loggingLevel.ERROR, 'minimumAllocation ' + minimumAllocation);
        
        Map<Id , Decimal> mapUserToAllocationFactor = new Map<Id , Decimal>();
        Decimal totalCapacity = 0;
        for(User usr : mUnderwritersUserList){
            Decimal allocationFactor = usr.Round_Robin_Allocation_percent__c / minimumAllocation;
            allocationFactor = allocationFactor.round();
            mapUserToAllocationFactor.put(usr.id,allocationFactor);
            totalCapacity = totalCapacity + allocationFactor;
        }  
        
        if(totalCapacity < totalApps){
            Decimal multiplicationFactor = totalApps/totalCapacity;
            multiplicationFactor = multiplicationFactor.round(System.RoundingMode.CEILING);
            for(id  userId : mapUserToAllocationFactor.keySet()){
                mapUserToAllocationFactor.put(userId ,  mapUserToAllocationFactor.get(userId)*multiplicationFactor);
            }
        }
        
        System.debug(loggingLevel.ERROR, 'mapUserToAllocationFactor ' + mapUserToAllocationFactor);
        
        System.debug(loggingLevel.ERROR, '-- mUnderwritersUserList :'+mUnderwritersUserList.size());
        
        
        Map<id,Decimal> mapUserToCountAvailable = new Map<id,Decimal>();
        for(id  userId : mapUserToAllocationFactor.keySet()){
            if(mapUserToAllocationFactor.get(userId) >  mUWExistingAppCountMap.get(userId)){
                mapUserToCountAvailable.put(userId, mapUserToAllocationFactor.get(userId) - mUWExistingAppCountMap.get(userId)); 
            }
            
        }
        System.debug(loggingLevel.ERROR, 'mapUserToCountAvailable ' + mapUserToCountAvailable);
        
        
        List<Decimal> availabilityList = new List<Decimal>(mapUserToCountAvailable.values());
        availabilityList.sort();
        integer numberOfUsers = 1;
        Map<Integer,Id> mapNumberToUser = new Map<Integer,Id>();
        System.debug(loggingLevel.ERROR, 'availabilityList' + availabilityList);
        Set<id> userSet = new Set<id>(mapUserToAllocationFactor.keySet());
        for(Integer i=availabilityList.size()-1; i>=0;i--){          
            for(id  userId : userSet){
                if(mapUserToCountAvailable.get(userId) == availabilityList.get(i)){
                    //System.debug(loggingLevel.ERROR, i + ' '+ availabilityList.get(i));
                    userSet.remove(userId);
                    mapNumberToUser.put(numberOfUsers,userId);  
                    numberOfUsers++;  
                    break;
                }
            }
        }
        
        
        
        /* Map<Integer,Id> mapNumberToUser = new Map<Integer,Id>();
        //Mapping index numbers with the users in mapNumberToUser for Round-Robin Logic
         for(Id userId : mapUserToCountAvailable.keySet()){
         mapNumberToUser.put(numberOfUsers,userId);  
         numberOfUsers++;     
         }
         */
        System.debug(loggingLevel.ERROR, 'mapNumberToUser ' + mapNumberToUser);
        numberOfUsers--;
        System.debug(loggingLevel.ERROR, 'numberOfUsers ' + numberOfUsers);
        Integer roundRobinVariable = 1; 
        
        for(fsCore__Lending_Application__c app : mApplicationMap.values()){
            
            Integer FlagVariable = 1;
            while(FlagVariable > 0){
                
                integer c = math.mod(roundRobinVariable,numberOfUsers);
                
                if(c==0)
                {
                    c = numberOfUsers;   
                }
                System.debug(loggingLevel.ERROR, 'Integer c ' + c);
                for(integer z = c ; z <= numberOfUsers ; z++){
                    if(mapUserToCountAvailable.get( mapNumberToUser.get(z))>0 ){
                        app.Application_Owner_Name__c = mapNumberToUser.get(z);
                        app.Application_Owner_Assignment_Date__c = Date.today();
                        app.ownerId = app.Application_Owner_Name__c;
                        
                        System.debug(loggingLevel.ERROR, 'app Owner Name ' + app.Application_Owner_Name__c + '  '+ mapUserIdToName.get(mapNumberToUser.get(z)));
                        
                        lapplicationUpdateMap.put(app.id,app);
                        
                        //Reducing the users available capability in mapUserToCountAvailable after it has been assigned an assignment
                        mapUserToCountAvailable.put(mapNumberToUser.get(z),mapUserToCountAvailable.get(mapNumberToUser.get(z))-1);
                        
                        //Storing the DateTime of the Assignment for the users in a Map
                        
                        roundRobinVariable = z+1; 
                        //Changing the flag variable to move to the next Application to be assigned
                        FlagVariable = 0;
                        break;
                        
                    }  
                } 
            }
        }
        
        
        
        
        
        Savepoint sp = Database.setSavepoint();
        try{
           Database.SaveResult[] applicationSR = Database.update(lapplicationUpdateMap.Values(), true);
            
        }catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            Database.rollback(sp);
            mActionOutput.addError(e);
        }
        System.debug(loggingLevel.ERROR, '-- UnderwriterRoundRobinProcessor.process(-)');
        
        logMessage('-- Output : ' + String.valueOf(mActionOutput));
        
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