/**
* Class Name  : ServicingRoundRobinProcessor
* Description : Action class to updates the OwnerId on the lending contract (DV-234)
* Author      : Financial Spectra
*             
* Detailed Description :1)  This class will assign owners to the lending contract using the round robin % age basis.
*                           
*/ 
global virtual class ServicingRoundRobinProcessor implements fsCore.ActionProcessor{         
    private static final String CLASS_NAME = 'ServicingRoundRobinProcessor';
    
    public Map<Id, fsServ__Lending_Contract__c> mContractMap;  
    public fsCore.ActionInput mActionInput;     
    private fsCore.ActionOutput mActionOutput;
    private Set<Id> mErrorConIdSet;
    private Set<Id> mConNotFoundSet;
    private Integer mTotalExistingConCount;
    public Map<Id,Integer> mUWExistingConCountMap; 
    private List<User> mServicingUserList;
    private Map<Id,String> mServicingUsersNameMap;
    
    
    global ServicingRoundRobinProcessor(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mContractMap = new Map<Id, fsServ__Lending_Contract__c>();
        mErrorConIdSet = new Set<Id>();
        mConNotFoundSet = new Set<Id>();        
        mUWExistingConCountMap = new Map<Id,Integer>();
        mServicingUserList = new List<User>();
        mServicingUsersNameMap = new Map<Id,String>();
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
        System.debug(mContractMap.Size());
        
        for (fsServ__Lending_Contract__c con : mContractMap.values()){
            //ONLY IF THE Contract_Owner_Name__c IS NULL AND FOR DNL LOANS
            if ((con.Contract_Owner_Name__c == null)
                && (con.fsServ__Product_Code__c == 'DNL')){
                    
                }else{
                    logmessage(' Con Name :'+con.Name+' Not eligible '+
                               ' Serving User Name :'+con.Contract_Owner_Name__c+
                               ' Loan Type :'+con.fsServ__Product_Code__c);
                    //KEEP ADDING NON ELIGIBLE RECORDS TO THE mErrorConIdSet TO FILTER OUT LATER
                    //mErrorConIdSet.add(app.Id);
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
                                           FROM fsServ__Lending_Contract__c 
                                           //where Contract_Owner_Assignment_Date__c = :Date.today() //PDI-711 CONSIDER ONLY TODAY'S APPS
                                           where Contract_Owner_Assignment_Date__c >= :roundRobinStartDate //DV-234 Weekly Load
                                           AND Contract_Owner_Name__c != null //THIS SHOULD NEVER HAPPEN BUT JUST IN CASE.
                                           GROUP BY ownerId];
        
        
        mTotalExistingConCount = 0;
        for(AggregateResult agg :aggResult){    
            mUWExistingConCountMap.put((Id)agg.get('ownerId'),(Integer)agg.get('num'));
            mTotalExistingConCount += mUWExistingConCountMap.get((Id)agg.get('ownerId'));
            
        }
        system.debug(logginglevel.error,' Done populateExistingAssignmentsCount');
    }
    private void populateEligibleUsers(){
        logMessage('Inside populateEligibleUsers');
        //users where profile name is 'Serving' are only eligible for round robin
        mServicingUserList = [SELECT id
                              , FirstName
                              , LastName
                              , IsActive
                              , Profile.name 
                              , Round_Robin_Allocation_percent__c
                              FROM User 
                              WHERE Profile.name='Servicing' 
                              AND isActive = true 
                              AND IsRoundRobinAllocationEnabled__c = true];      //added FirstName & Lastname in Select Query**
        
        System.debug(loggingLevel.ERROR,'mServicingUserList'+mServicingUserList);
        
        logMessage('# Of Users among which the round robin will happen '+mServicingUserList.Size());
        
        
        //THERE COULD BE A SITUATION WHEN NO CONTRACT IS ASSIGNED TO THE ELIGIBLE USER
        //IN THAT CASE ADD A ENTRY WITH 0 VALUE
        for(User usr : mServicingUserList){
            if (usr.Round_Robin_Allocation_percent__c == null){
                usr.Round_Robin_Allocation_percent__c = 100;
            }
            if (!(mUWExistingConCountMap.containsKey(usr.Id))) {
                mUWExistingConCountMap.put(usr.Id,0);
            }
            mServicingUsersNameMap.put(usr.Id,usr.FirstName);
            system.debug(logginglevel.error,' Existing '+usr.FirstName+'  -  '+mUWExistingConCountMap.get(usr.Id));
        }
        System.debug('mUWExistingConCountMap: '+mUWExistingConCountMap);
    }    
    
    global void process(){
        Savepoint processingSP = Database.setSavepoint();
        try{
            //populate contracts and validate
            populateAndValidateContracts();
            
            //populate related data and validate
            if (mContractMap.size() > 0){
                populateAndValidateRelatedData();
                removeErroneousContracts();
            }            
            logMessage('mContractMap : ' + mContractMap.size());
            //do processing
            if (mContractMap.size() > 0){
                doProcess();
            }
        } catch (Exception e){
            Database.rollback(processingSP);
            mActionOutput.addError(new fsCore.ErrorObject(e));
        }
    }
    
    private void removeErroneousContracts(){
        //remove erroneous apps from application map
        for(Id errConId : mErrorConIdSet){
            if (mContractMap.containsKey(errConId)){ mContractMap.remove(errConId); }
        }
        logMessage('Contracts to be processed after filtering : ' + mContractMap.size());
        
        //reset the error application set
        mErrorConIdSet = new Set<Id>();
    }
    
    private void populateAndValidateContracts(){
        mContractMap = fsServ.LendingContractUtil.getLendingContracts(mActionInput.getRecords());
    }    
    
    private void doProcess(){  
        
        
        logMessage(CLASS_NAME+'.doProcess()');
        Map<id, String> mapUserIdToName = new Map<id,String>();
        MAP<Id,fsServ__Lending_Contract__c> lcontractUpdateMap = new MAP<Id,fsServ__Lending_Contract__c>();
        Decimal minimumAllocation = 0;
        integer totalContracts = mTotalExistingConCount + mContractMap.size();
        for(User usr : mServicingUserList){
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
        for(User usr : mServicingUserList){
            Decimal allocationFactor = usr.Round_Robin_Allocation_percent__c / minimumAllocation;
            allocationFactor = allocationFactor.round();
            mapUserToAllocationFactor.put(usr.id,allocationFactor);
            totalCapacity = totalCapacity + allocationFactor;
        }  
        
        if(totalCapacity < totalContracts){
            Decimal multiplicationFactor = totalContracts/totalCapacity;
            multiplicationFactor = multiplicationFactor.round(System.RoundingMode.CEILING);
            for(id  userId : mapUserToAllocationFactor.keySet()){
                mapUserToAllocationFactor.put(userId ,  mapUserToAllocationFactor.get(userId)*multiplicationFactor);
            }
        }
        
        System.debug(loggingLevel.ERROR, 'mapUserToAllocationFactor ' + mapUserToAllocationFactor);
        
        System.debug(loggingLevel.ERROR, '-- mServicingUserList :'+mServicingUserList.size());
        
        
        Map<id,Decimal> mapUserToCountAvailable = new Map<id,Decimal>();
        for(id  userId : mapUserToAllocationFactor.keySet()){
            if(mapUserToAllocationFactor.get(userId) >  mUWExistingConCountMap.get(userId)){
                mapUserToCountAvailable.put(userId, mapUserToAllocationFactor.get(userId) - mUWExistingConCountMap.get(userId)); 
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
        
        for(fsServ__Lending_Contract__c con : mContractMap.values()){
            
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
                        con.Contract_Owner_Name__c = mapNumberToUser.get(z);
                        con.Contract_Owner_Assignment_Date__c = Date.today();
                        con.ownerId = con.Contract_Owner_Name__c;
                        
                        System.debug(loggingLevel.ERROR, 'con Owner Name ' + con.Contract_Owner_Name__c + '  '+ mapUserIdToName.get(mapNumberToUser.get(z)));
                        
                        lcontractUpdateMap.put(con.id,con);
                        
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
            Database.SaveResult[] contractSR = Database.update(lcontractUpdateMap.Values(), true);
            
        }catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            Database.rollback(sp);
            mActionOutput.addError(e);
        }
        System.debug(loggingLevel.ERROR, '-- ServicingRoundRobinProcessor.process(-)');
        
        logMessage('-- Output : ' + String.valueOf(mActionOutput));
        
    }
    
    @TestVisible
    private void addError(String pErrCode, String pErrMsg, String pTrace, Id pConId, String pRelatedRecord){
        fsCore.ErrorObject errorObj = new fsCore.ErrorObject();
        errorObj.setErrorCode(pErrCode);
        errorObj.setErrorMessage(pErrMsg);
        
        if (pConId != null){
            errorObj.setErrorRecordId(pConId);
            mErrorConIdSet.add(pConId);
        }
        if (String.IsNotBlank(pRelatedRecord)){
            errorObj.setErrorRecord(pRelatedRecord);
        }
        
        addError(errorObj, pTrace);
    }
    @TestVisible
    private void addError(fsCore.ErrorObject pErrorObj, String pMethod){
        pErrorObj.setErrorStackTrace(getClassName() + '.' + pMethod);
        
        if (pErrorObj.getErrorRecordId() != null && mContractMap.containsKey(pErrorObj.getErrorRecordId())){
            pErrorObj.setErrorRecordName(mContractMap.get(pErrorObj.getErrorRecordId()).Name);
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