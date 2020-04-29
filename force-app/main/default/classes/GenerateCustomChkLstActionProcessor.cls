/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 *
 * Description  - Action class to generate checklist records for DNL Loans
 * This include generic checklist and custom checklist
 *
 *
 */
global virtual class GenerateCustomChkLstActionProcessor implements fsCore.ActionProcessor{
    private static final String CLASS_NAME = 'GenerateCustomChkLstActionProcessor';
    
    private Map<Id, fsCore__Lending_Application__c> mApplicationMap;
    private Map<String, fsCore__Checklist_Setup__c> mChecklistSetupCodeToChecklist;
    private Map<Id, String> mChecklistSetupIdToCode;
    
    private Map<String, Set<String>> mApplicationToAvailableChecklistMap;
    private Map<Id, List<fsCore__Checklist_Detail_Setup__c>> mChecklistToItemsMap;
    private Map<Id, Set<String>> mApplicationToExistingChkItemMap;
    private Map<String, Id> mExistingChkItemToIdMap;
    private Map<Id, List<fsCore__Lending_Application_Customer__c>> mApplicationToApplicantMap;
    private Map<Id, List<fsCore__Financial__c>> mApplicantToFinancialMap;

    private static final String CHECKLIST_ITEM_STATUS_PENDING  = 'Pending';
    private static final String CHECKLIST_ITEM_STATUS_VERIFIED = 'Verified';

    private List<fsCore__Checklist_Setup__c> mChecklistSetupList;
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private Set<String> mAllIncomeChecklists;
    private Set<Id> mErrorAppIdSet;
    private Set<Id> mAppNotFoundSet;

    
    
    global GenerateCustomChkLstActionProcessor(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
        mErrorAppIdSet = new Set<Id>();
        mAppNotFoundSet = new Set<Id>();        
    }
    global void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
    }    
    public void populateAndValidateRelatedData(){
        fsCore.Logger.enter(CLASS_NAME,'populateAndValidateRelatedData()');

        populateAllChecklists();

        /* get available checklist by evaluating mappings */
        populateAvailableChecklists();
        
        /* get checklist items of available checklists */
        populateChecklistItemsMap();
        
        /* get existing checklist items of applications */
        populateExistingChecklistItems();
        fsCore.Logger.exit(CLASS_NAME,'populateAndValidateRelatedData()');
    }

    private void populateAllChecklists(){
        mAllIncomeChecklists =  new Set<String>();  
        populateDNLChecklists();
        populateVCLChecklists();
    }
    private void populateDNLChecklists(){
        
        Set<String> aplIncomeChecklists = new Set<String>();
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_IND_CONTRACTOR');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_SAL');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_OTH');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_OTH_RENTAL_INCOME');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_RET_SOCIAL_SEC');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_OTH_CHILD_SUPPORT');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_SE_SOLE_PROP');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_OTH_ALIMONY');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_SAL_LESS_60');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_OTH_DISB_BENEFITS');
        aplIncomeChecklists.add('DNL_APL_INC_DOC_CHK_RET_PENSION');
        aplIncomeChecklists.add('DNL_APL_RESIDENCY_DOC_CHK_GC');

        Set<String> coAplIncomeChecklists = new Set<String>();
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_IND_CONTRACTOR');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_SAL');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_OTH');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_OTH_RENTAL_INCOME');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_RET_SOCIAL_SEC');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_OTH_CHILD_SUPPORT');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_SE_SOLE_PROP');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_OTH_ALIMONY');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_SAL_LESS_60');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_OTH_DISB_BENEFITS');
        coAplIncomeChecklists.add('DNL_COAPL_INC_DOC_CHK_RET_PENSION');
        coAplIncomeChecklists.add('DNL_COAPL_RESIDENCY_DOC_CHK_GC');

            
        mAllIncomeChecklists.addAll(aplIncomeChecklists);
        mAllIncomeChecklists.addAll(coAplIncomeChecklists);

    }
  private void populateVCLChecklists(){
        Set<String> aplIncomeChecklists = new Set<String>();
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_IND_CONTRACTOR');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_SAL');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_OTH_RENTAL_INCOME');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_RET_SOCIAL_SEC');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_OTH_CHILD_SUPPORT');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_SE_SOLE_PROP');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_OTH_ALIMONY');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_SAL_LESS_60');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_OTH_DISB_BENEFITS');
        aplIncomeChecklists.add('VCL_APL_INC_DOC_CHK_RET_PENSION');
        

        Set<String> coAplIncomeChecklists = new Set<String>();
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_IND_CONTRACTOR');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_SAL');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_OTH_RENTAL_INCOME');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_RET_SOCIAL_SEC');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_OTH_CHILD_SUPPORT');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_SE_SOLE_PROP');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_OTH_ALIMONY');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_SAL_LESS_60');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_OTH_DISB_BENEFITS');
        coAplIncomeChecklists.add('VCL_COAPL_INC_DOC_CHK_RET_PENSION');
 
        mAllIncomeChecklists.addAll(aplIncomeChecklists);
        mAllIncomeChecklists.addAll(coAplIncomeChecklists);

    }

    private void populateAvailableChecklists(){
        //Since this is for the DNL-Income Checklist
        //GET ALL THE CHECKLIST.
        mChecklistSetupList = [SELECT id
                                    , fsCore__Checklist_Code__c
                                    , fsCore__Checklist_Type__c
                                    , (SELECT Id 
                                            , name
                                            , fsCore__Checklist_Name__c
                                            , fsCore__Action_Item__c
                                            , fsCore__Action_Item_Type__c
                                            , fsCore__Document_Classification__c
                                            , fsCore__Display_Order__c
                                            , fsCore__Is_Required__c
                                         FROM fsCore__Checklist_Detail_Setup__r
                                        WHERE fsCore__Is_Active__c = true
                                        ORDER BY fsCore__Checklist_Name__c, fsCore__Display_Order__c, Name)
                                 FROM fsCore__Checklist_Setup__c ];
                                //where fsCore__Checklist_Code__c in :mAllIncomeChecklists ]; //SUP-355


        mChecklistSetupCodeToChecklist = new Map<String, fsCore__Checklist_Setup__c>();
        mChecklistSetupIdToCode = new Map<Id,String>();
        for (fsCore__Checklist_Setup__c chkSetup : mChecklistSetupList){
            if (mAllIncomeChecklists.contains(chkSetup.fsCore__Checklist_Code__c)){ //SUP-355
               mChecklistSetupCodeToChecklist.put(chkSetup.fsCore__Checklist_Code__c,chkSetup);
            }
            //AD SUP-355 We should be having all chkSetup in the below map to populate applicant/co-applicant name
            mChecklistSetupIdToCode.put(chkSetup.Id,chkSetup.fsCore__Checklist_Code__c);
        }                                


        mApplicationToApplicantMap = new Map<Id, List<fsCore__Lending_Application_Customer__c>>();
        mApplicationToAvailableChecklistMap = new Map<String, Set<String>>();

        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            mApplicationToApplicantMap.put(application.Id,new List<fsCore__Lending_Application_Customer__c>());
            mApplicationToAvailableChecklistMap.put(application.Id,new Set<String>());

        }
        system.debug(logginglevel.error,'mApplicationToApplicantMap :'+mApplicationToApplicantMap);
        system.debug(logginglevel.error,'mApplicationToAvailableChecklistMap :'+mApplicationToAvailableChecklistMap);
        mApplicantToFinancialMap = new Map<Id, List<fsCore__Financial__c>>();

        list<fsCore__Lending_Application_Customer__c> customerList = [select id
                                                                           , name
                                                                           , fsCore__Account_Name__c 
                                                                           , fsCore__Customer_Type__c
                                                                           , fsCore__Account_Name__r.PersonContactId
                                                                           , fsCore__Account_Name__r.U_S_Residency_Status__c
                                                                           , fsCore__Lending_Application_Number__c
                                                                        from fsCore__Lending_Application_Customer__c 
                                                                        where fsCore__Lending_Application_Number__c in :mApplicationToAvailableChecklistMap.keyset()];

        Set<Id> contactIds = new Set<Id>();
        for (fsCore__Lending_Application_Customer__c appCust:customerList){
            if (mApplicationToApplicantMap.containsKey(appCust.fsCore__Lending_Application_Number__c)){
                mApplicationToApplicantMap.get(appCust.fsCore__Lending_Application_Number__c).add(appCust);
            }       
            contactIds.add(appCust.fsCore__Account_Name__r.PersonContactId);
            mApplicantToFinancialMap.put(appCust.fsCore__Account_Name__r.PersonContactId,new List<fsCore__Financial__c>());
        }
        
         list<fsCore__Financial__c> financialList = [SELECT id
                                                          , fsCore__Contact_Name__c
                                                          , fsCore__Financial_Type__c 
                                                          , Employment_Name__r.fsCore__Start_Date__c
                                                      FROM fsCore__Financial__c 
                                                     WHERE fsCore__Financial_Family__c = 'Income'
                                                       AND fsCore__Contact_Name__c in :contactIds];

        for (fsCore__Financial__c fin:financialList){
            if (mApplicantToFinancialMap.containsKey(fin.fsCore__Contact_Name__c)){
                mApplicantToFinancialMap.get(fin.fsCore__Contact_Name__c).add(fin);
            }       
        }

        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            system.debug(logginglevel.error,'application :'+application.ID);
            for (fsCore__Lending_Application_Customer__c customer : mApplicationToApplicantMap.get(application.Id)){
                for (fsCore__Financial__c financial : mApplicantToFinancialMap.get(customer.fsCore__Account_Name__r.PersonContactId)){
                    String checklistCode = null;
                    if (customer.fsCore__Customer_Type__c == 'Primary'){
                        if (financial.fsCore__Financial_Type__c == 'Salary'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_SAL';
                            if ((financial.Employment_Name__r.fsCore__Start_Date__c != null) &&
                                ( financial.Employment_Name__r.fsCore__Start_Date__c > (date.today().addDays(-60)))){
                                checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_SAL_LESS_60';
                            }
                        }else if (financial.fsCore__Financial_Type__c == 'Independent Contractor'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_IND_CONTRACTOR';
                        }else if (financial.fsCore__Financial_Type__c == 'Other'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_OTH';
                        }else if (financial.fsCore__Financial_Type__c == 'Rental'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_OTH_RENTAL_INCOME';
                        }else if (financial.fsCore__Financial_Type__c == 'Social Security'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_RET_SOCIAL_SEC';
                        }else if (financial.fsCore__Financial_Type__c == 'Child Support'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_OTH_CHILD_SUPPORT';
                        }else if (financial.fsCore__Financial_Type__c == 'Self-employed'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_SE_SOLE_PROP';
                        }else if (financial.fsCore__Financial_Type__c == 'Alimony'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_OTH_ALIMONY';
                        }else if ((financial.fsCore__Financial_Type__c == 'Disability')
                                    ||(financial.fsCore__Financial_Type__c == 'VA Disability')){//PDI-1029
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_OTH_DISB_BENEFITS';
                        }else if (financial.fsCore__Financial_Type__c == 'Pension'){
                            checklistCode = application.Loan_Type__c+'_APL_INC_DOC_CHK_RET_PENSION';
                        }

                    }else{ //THIS IS FOR ANYTHING OTHER THAN PRIMARY
                        if (financial.fsCore__Financial_Type__c == 'Salary'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_SAL';
                            if ((financial.Employment_Name__r.fsCore__Start_Date__c != null) &&
                                ( financial.Employment_Name__r.fsCore__Start_Date__c > (date.today().addDays(-60)))){
                                checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_SAL_LESS_60';
                            }
                        }else if (financial.fsCore__Financial_Type__c == 'Independent Contractor'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_IND_CONTRACTOR';
                        }else if (financial.fsCore__Financial_Type__c == 'Other'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_OTH';
                        }else if (financial.fsCore__Financial_Type__c == 'Rental'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_OTH_RENTAL_INCOME';
                        }else if (financial.fsCore__Financial_Type__c == 'Social Security'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_RET_SOCIAL_SEC';
                        }else if (financial.fsCore__Financial_Type__c == 'Child Support'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_OTH_CHILD_SUPPORT';
                        }else if (financial.fsCore__Financial_Type__c == 'Self-employed'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_SE_SOLE_PROP';
                        }else if (financial.fsCore__Financial_Type__c == 'Alimony'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_OTH_ALIMONY';
                        }else if ((financial.fsCore__Financial_Type__c == 'Disability')
                                ||(financial.fsCore__Financial_Type__c == 'VA Disability')){//PDI-1029
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_OTH_DISB_BENEFITS';
                        }else if (financial.fsCore__Financial_Type__c == 'Pension'){
                            checklistCode = application.Loan_Type__c+'_COAPL_INC_DOC_CHK_RET_PENSION';
                        }
                    }
                    
                    if (checklistCode == null) {continue;}
                    System.debug(loggingLevel.ERROR, '-- Checklist Code to process : ' + checklistCode);
                    //SUP-401 added the check for checklist code in mChecklistSetupCodeToChecklist to avoid null pointer exception
                    if (mApplicationToAvailableChecklistMap.containsKey(application.Id) && mChecklistSetupCodeToChecklist.containsKey(checklistCode)){
                        mApplicationToAvailableChecklistMap.get(application.Id).add(mChecklistSetupCodeToChecklist.get(checklistCode).Id+'~'+financial.Id);
                        system.debug(logginglevel.error,'mApplicationToAvailableChecklistMap :'+mApplicationToAvailableChecklistMap);
                    }  


                }
                //DV-173
                if ((String.IsNotBlank(customer.fsCore__Account_Name__r.U_S_Residency_Status__c)) && ('Permanent Resident Alien'.equalsIgnoreCase(customer.fsCore__Account_Name__r.U_S_Residency_Status__c))){
                    String checklistCode = null;
                    if (customer.fsCore__Customer_Type__c == 'Primary'){
                        checklistCode = application.Loan_Type__c+'_APL_RESIDENCY_DOC_CHK_GC';
                    }else{
                        checklistCode = application.Loan_Type__c+'_COAPL_RESIDENCY_DOC_CHK_GC';
                    }
                    if (mApplicationToAvailableChecklistMap.containsKey(application.Id)){
                        if (mChecklistSetupCodeToChecklist.get(checklistCode) != null){
                            mApplicationToAvailableChecklistMap.get(application.Id).add(mChecklistSetupCodeToChecklist.get(checklistCode).Id);
                            system.debug(logginglevel.error,'mApplicationToAvailableChecklistMap :'+mApplicationToAvailableChecklistMap);
                        }
                        
                    }                        
                }

            }
        }
        
       

        /* Since for DNL loans we are populating everything here, so copied the core class GenerateChecklistActionProcessor code here */
         
        Map<String, fsCore.MappingEvaluationInputObject> mappingEvalInputMap = new Map<String, fsCore.MappingEvaluationInputObject>();
        String productFamily;
        
        for (fsCore__Lending_Application__c application : mApplicationMap.values()){
            fsCore.MappingEvaluationInputObject applMappEvalObj = fsCore.LendingApplicationUtil.getMappingEvalInput(application);
            mappingEvalInputMap.put(String.valueOf(application.Id), applMappEvalObj);
            productFamily = application.fsCore__Product_Family__c;
        }
        
        fsCore.SetupMappingEvaluator checklistMappEval = new fsCore.SetupMappingEvaluator(mappingEvalInputMap
                                                                          , Schema.SObjectType.fsCore__Checklist_Setup__c.getName()
                                                                          , productFamily);
        
        Map<String, Set<Id>> applicationToAvailableChecklistMap = checklistMappEval.evaluate();


        for(String applicationId : applicationToAvailableChecklistMap.keySet()){
            Set<String> checkListIds = new Set<String>();
            for (id  appCheckListId: applicationToAvailableChecklistMap.get(applicationId)){
                checkListIds.add(appCheckListId);
            }             
            if (mApplicationToAvailableChecklistMap.containsKey(applicationId)){
                checkListIds.addAll(mApplicationToAvailableChecklistMap.get(applicationId));

                mApplicationToAvailableChecklistMap.put(applicationId,checkListIds);
            }else{
                mApplicationToAvailableChecklistMap.put(applicationId,checkListIds);
            }
            system.debug(logginglevel.error,'****** *** applicationToAvailableChecklistMap  :'+mApplicationToAvailableChecklistMap.get(applicationId).size());
        }
        
    }
    
    private void populateChecklistItemsMap(){   
        Set<Id> checklistSetupIdSet = new Set<Id>();
        for(String applicationId : mApplicationToAvailableChecklistMap.keySet()){
            for (String checklistStr :mApplicationToAvailableChecklistMap.get(applicationId)){
                String[] checklistStrArr = checklistStr.split('~'); //SINCE THIS IS A CONCATENATION OF CHECKLIST AND FINANCIAL ID
                checklistSetupIdSet.add(checklistStrArr[0]);
            }
        }
        system.debug(logginglevel.error,'checklistSetupIdSet :'+checklistSetupIdSet);
        List<fsCore__Checklist_Detail_Setup__c> allChecklistItems = 
                                            [SELECT Id, Name
                                                  , fsCore__Checklist_Name__c
                                                  , fsCore__Action_Item__c
                                                  , fsCore__Action_Item_Type__c
                                                  , fsCore__Document_Classification__c
                                                  , fsCore__Display_Order__c
                                                  , fsCore__Is_Required__c
                                               FROM fsCore__Checklist_Detail_Setup__c
                                              WHERE fsCore__Checklist_Name__c IN :checklistSetupIdSet
                                                AND fsCore__Is_Active__c = true
                                              ORDER BY fsCore__Checklist_Name__c, fsCore__Display_Order__c, Name];
        
        mChecklistToItemsMap = new Map<Id, List<fsCore__Checklist_Detail_Setup__c>>();
        
        for (fsCore__Checklist_Detail_Setup__c checklistItem : allChecklistItems){
            List<fsCore__Checklist_Detail_Setup__c> checklistItems = new List<fsCore__Checklist_Detail_Setup__c>();
            
            if (mChecklistToItemsMap.containsKey(checklistItem.fsCore__Checklist_Name__c)){
                checklistItems = mChecklistToItemsMap.get(checklistItem.fsCore__Checklist_Name__c);
            }
            
            checklistItems.add(checklistItem);
            mChecklistToItemsMap.put(checklistItem.fsCore__Checklist_Name__c, checklistItems);
        }        
    }
    
    private void populateExistingChecklistItems(){
        List<fsCore__Lending_Application_Checklist__c> existingChkItems = 
                            [SELECT Id, fsCore__Checklist_Item_Setup_ID__c
                                  , fsCore__Lending_Application_Number__c
                                  , Financial_Name__c
                               FROM fsCore__Lending_Application_Checklist__c
                              WHERE fsCore__Lending_Application_Number__c IN :mApplicationMap.keySet()
                                AND Is_Checklist_Auto_Generated__c  = true //PICK ONLY PROCESS GENERATED CHECKLIST IGNORE MANUAL ONES
                                AND fsCore__Status__c != 'Not Applicable' //FOR DISABLED CHECKLIST WE SET THIS STATUS
                              ORDER BY fsCore__Lending_Application_Number__c];
    
        // this is an application id to set of exisitng checklist item setup Id map
        mApplicationToExistingChkItemMap = new Map<Id, Set<String>>();
        mExistingChkItemToIdMap= new Map<String, Id>();
        
        for (fsCore__Lending_Application_Checklist__c appChk : existingChkItems){
            Set<String> existingChkItemIdSet = new Set<String>();
            if (mApplicationToExistingChkItemMap.containsKey(appChk.fsCore__Lending_Application_Number__c)){
                existingChkItemIdSet = mApplicationToExistingChkItemMap.get(appChk.fsCore__Lending_Application_Number__c);
            }
            if (appChk.Financial_Name__c == null){
                existingChkItemIdSet.add(appChk.fsCore__Checklist_Item_Setup_ID__c);
                mExistingChkItemToIdMap.put(String.valueOf(appChk.fsCore__Lending_Application_Number__c)+String.valueOf(appChk.fsCore__Checklist_Item_Setup_ID__c),appChk.id);
            }else{
                existingChkItemIdSet.add(appChk.fsCore__Checklist_Item_Setup_ID__c+'~'+appChk.Financial_Name__c);
                mExistingChkItemToIdMap.put(String.valueOf(appChk.fsCore__Lending_Application_Number__c)+String.valueOf(appChk.fsCore__Checklist_Item_Setup_ID__c)+'~'+String.valueOf(appChk.Financial_Name__c),appChk.id);
            }
            mApplicationToExistingChkItemMap.put(appChk.fsCore__Lending_Application_Number__c, existingChkItemIdSet);
            
        }
    }
    private  fsCore__Lending_Application_Checklist__c getNewApplicationChecklistInstance(Id pApplicationId, fsCore__Checklist_Detail_Setup__c pChkItemSetup, String financialId){
        fsCore__Lending_Application_Checklist__c appChkItem = new fsCore__Lending_Application_Checklist__c();
        
        //THE BELOW CODE WILL BE FIRED WHEN THE CHECKLIST IS APPLICANT OR CO-APPLICANT SPECIFIC
        if (mChecklistSetupIdToCode.get(pChkItemSetup.fsCore__Checklist_Name__c) != null){
            String CustomerType = 'Primary';
            if (mChecklistSetupIdToCode.get(pChkItemSetup.fsCore__Checklist_Name__c).contains('_COAPL_')){
                CustomerType = 'Secondary';
            }
            Id customerId;
            for (fsCore__Lending_Application_Customer__c customer : mApplicationToApplicantMap.get(pApplicationId)){
                if (CustomerType == 'Primary'){
                    if (customer.fsCore__Customer_Type__c == 'Primary'){
                        customerId = customer.fsCore__Account_Name__c;
                    }
                }else{
                    if (customer.fsCore__Customer_Type__c != 'Primary'){
                        customerId = customer.fsCore__Account_Name__c;
                    }                
                }    
            }
            appChkItem.Applicant_Name__c = customerId;
        }
        
        appChkItem.fsCore__Lending_Application_Number__c = pApplicationId;
        appChkItem.fsCore__Checklist_Name__c = pChkItemSetup.fsCore__Checklist_Name__c;
        appChkItem.fsCore__Checklist_Item_Setup_ID__c = pChkItemSetup.Id;
        if (financialId != null && financialId.length() > 1){
            appChkItem.Financial_Name__c  = Id.ValueOf(financialId);
        }

        appChkItem.fsCore__Checklist_Item__c = pChkItemSetup.fsCore__Action_Item__c;
        appChkItem.fsCore__Checklist_Item_Type__c = pChkItemSetup.fsCore__Action_Item_Type__c;
        appChkItem.fsCore__Document_Classification__c = pChkItemSetup.fsCore__Document_Classification__c;
        appChkItem.fsCore__Is_Required__c = pChkItemSetup.fsCore__Is_Required__c;
        appChkItem.fsCore__Status__c = CHECKLIST_ITEM_STATUS_PENDING;
        appChkItem.Is_Checklist_Auto_Generated__c = true;
        
        return appChkItem;
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
        for(Id appid: mApplicationMap.keySet()){
            logMessage('Applications to be processed after filtering :appid: ' +appid);
        }
        
        //reset the error application set
        mErrorAppIdSet = new Set<Id>();
    }

    private void populateAndValidateApplications(){
        mApplicationMap = fsCore.LendingApplicationUtil.getApplications(mActionInput.getRecords());
    }    

    private void doProcess(){

        logMessage(CLASS_NAME+'.doProcess()');
        List<fsCore__Lending_Application_Checklist__c> newChkItemsForInsert = new List<fsCore__Lending_Application_Checklist__c>();
        List<fsCore__Lending_Application_Checklist__c> newChkItemsForDisable = new List<fsCore__Lending_Application_Checklist__c>();
        
        //create new checklist items for application
        
        for(Id applicationId : mApplicationToAvailableChecklistMap.keySet()){
            logMessage('--applicationId : ' + applicationId+'--Map : ' + mApplicationToAvailableChecklistMap.get(applicationId));
            for(String checklistIdFinancialID : mApplicationToAvailableChecklistMap.get(applicationId)){

                String checklistId = (checklistIdFinancialID.split('~')[0]);
                if (!mChecklistToItemsMap.containsKey(checklistId)){ continue; }
            
                Set<String> existingChkItemsSet = new Set<String>();
                if (mApplicationToExistingChkItemMap.containsKey(applicationId)){
                    existingChkItemsSet = mApplicationToExistingChkItemMap.get(applicationId);
                }
                
                String financialId = '';
                try{
                    financialId = (checklistIdFinancialID.split('~'))[1];
                }Catch(Exception e){
                    //DO NOTHING THERE IS NO FINANCIAL ID
                }
                logMessage('--checklistId : ' + checklistId+'--financialId : ' + financialId);
                for(fsCore__Checklist_Detail_Setup__c chkItem : mChecklistToItemsMap.get(checklistId)){
                    //skip if the checklist item already exists
                    if ((existingChkItemsSet.contains(chkItem.Id))
                       ||(existingChkItemsSet.contains(chkItem.Id+'~'+financialId))){  
                        continue; 
                    }
                    logMessage('--newChkItemsForInsert : ' +chkItem );
                    newChkItemsForInsert.add(getNewApplicationChecklistInstance(applicationId, chkItem,financialId));
                }
            }
            //THIS LOOP IS TO UPDATE THE EXISTING CHECKLIST AS NOT APPLICABLE.
            //logMessage('--Updating as Not applicable : ' + mApplicationToExistingChkItemMap.size());
            if (mApplicationToExistingChkItemMap.containsKey(applicationId)){
                //logMessage('--Existing app Map : ' + mApplicationToExistingChkItemMap.get(applicationId));
                for(String existingChecklistId : mApplicationToExistingChkItemMap.get(applicationId)){
                        //logMessage('--existingChecklistId : ' + existingChecklistId);
                        //logMessage('mApplicationToAvailableChecklistMap : '+mApplicationToAvailableChecklistMap.get(applicationId));

                        String checklistSetupFinancialId;
                        try{
                            checklistSetupFinancialId = (existingChecklistId.split('~'))[1];
                        }Catch(Exception e){
                            //DO NOTHING THERE IS NO FINANCIAL ID
                        }                    
                    Boolean matched= false;
                    logMessage('--New app Map : ' + mApplicationToAvailableChecklistMap.get(applicationId));
                    for(String newChecklistSetupFinId : mApplicationToAvailableChecklistMap.get(applicationId)){
                        String newChecklistSetupId = (newChecklistSetupFinId.split('~')[0]);
                        String newChecklistFinancialId;
                        try{
                            newChecklistFinancialId = (newChecklistSetupFinId.split('~')[1]);
                        }Catch(Exception e){
                            //DO NOTHING THERE IS NO FINANCIAL ID
                        } 
                        
                        logMessage('--New newChecklistSetupId : ' + newChecklistSetupId);
                        

                        Set<Id> resultIds = (new Map<Id,fsCore__Checklist_Detail_Setup__c>(mChecklistToItemsMap.get(newChecklistSetupId))).keySet();
                        
                        Set<String> resultIdStr = new Set<String>();
                        for(Id resultId :resultIds){
                            logMessage('--resultId : ' + resultId);
                            logMessage('--newChecklistFinancialId : ' + newChecklistFinancialId);
                            if (newChecklistFinancialId == null){
                                resultIdStr.add(resultId);
                            }else{
                                resultIdStr.add(resultId+'~'+newChecklistFinancialId);
                            }
                            logMessage('--resultIdStr : ' + resultIdStr);
                            
                        }

                        if (resultIdStr.contains(existingChecklistId)){
                            matched = true;
                            logMessage('MATCHED  ');
                            break;
                        }
                    }
                    logMessage('MATCHED  '+matched);
                    if (!matched){
                        logMessage('DIDNT MATCHED  '+existingChecklistId);
                        fsCore__Lending_Application_Checklist__c disableChk = new fsCore__Lending_Application_Checklist__c();
                        disableChk.id = mExistingChkItemToIdMap.get(String.valueOf(applicationId)+String.valueOf(existingChecklistId));
                        disableChk.fsCore__Status__c = 'Not Applicable';
                        newChkItemsForDisable.add(disableChk);
                    }
                }
            }            
        }
        logMessage('--Number of checklist items for insert : ' + String.valueOf(newChkItemsForInsert.size()));
        logMessage('--Number of checklist items for Not Applicable : ' + String.valueOf(newChkItemsForDisable.size()));
        for(fsCore__Lending_Application_Checklist__c chk :newChkItemsForInsert){
            logMessage('--New Chk : ' + chk);
        }
        for(fsCore__Lending_Application_Checklist__c chk :newChkItemsForDisable){
            logMessage('--Disable Chk : ' + chk);
        }        
        
        //perform dml
        //try{
        //fsCore.DMLResult chkItemDMLInsertRslt = fsCore.LendingApplicationChecklistDMLWrapper.getInstance().insertData(newChkItemsForInsert);
        //fsCore.DMLResult chkItemDMLDisableRslt = fsCore.LendingApplicationChecklistDMLWrapper.getInstance().updateData(newChkItemsForDisable);
        //
        
        //handler errors
        Database.SaveResult[] chkItemSR = Database.insert(newChkItemsForInsert,false);
        logMessage('--RESULT  : ' + chkItemSR);
        //if (chkItemDMLInsertRslt.hasErrors()) {
            for (Integer i = 0; i < chkItemSR.size(); i++){
                if (!chkItemSR.get(i).isSuccess()){
                    for(Database.Error err : chkItemSR.get(i).getErrors()){
                        addError(String.valueOf(err.getStatusCode()), err.getMessage() + ' : ' + String.valueOf(err.getFields()), 'process() ... saving records', newChkItemsForInsert.get(i).fsCore__Lending_Application_Number__c, JSON.serialize(newChkItemsForInsert.get(i)));
                    }
                }
            }
        //}
        chkItemSR = Database.Update(newChkItemsForDisable,false);
        //if (chkItemDMLDisableRslt.hasErrors()) {
            for (Integer i = 0; i < chkItemSR.size(); i++){
                if (!chkItemSR.get(i).isSuccess()){
                    for(Database.Error err : chkItemSR.get(i).getErrors()){
                        addError(String.valueOf(err.getStatusCode()), err.getMessage() + ' : ' + String.valueOf(err.getFields()), 'process() ... saving records', newChkItemsForInsert.get(i).fsCore__Lending_Application_Number__c, JSON.serialize(newChkItemsForInsert.get(i)));
                    }
                }
            }
        //}
        //}catch(Exception e){
            
        //    logMessage('-- exception : ' + String.valueOf(e));
        //}
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

    @AuraEnabled
    public static String generateIncomeDocumentChecklist(Id pApplicationId){
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        acrInput.addRecord(pApplicationId);
        
        GenerateCustomChkLstActionProcessor incomeDocAction = new GenerateCustomChkLstActionProcessor();
        incomeDocAction.setInput(acrInput);
        incomeDocAction.process();
        
        fsCore.ActionOutput acrOutput = incomeDocAction.getOutput();
        if (acrOutput.getIsSuccess()){
            acrOutput.setMessage('Success');
            acrOutput.setMessageDetails('Checklist has been generated successfully.');
            
        }
        return acrOutput.getJSONString();
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