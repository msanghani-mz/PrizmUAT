/**
* Class Name  : LendingApplicationCreator
* Description : This class has logic to create the lending applications
*               from custom application records
* Author      : Financial Spectra
*
*/
public class LendingApplicationCreator{
    
    private fsCore__Branch_Setup__c mDefaultBranch;
    private Map<String, opportunity> mSourceOpportunityMap;
    private Map<ID, ID> mAccountToContactIdMap;
    private fsCore__Product_Setup__c mProduct;
    private RecordType mLoanRecordType;
    private Set<Id> mSourceOppIds;
    private Set<Id> mContactIds;
    private Map<Id,Id> mOppToContactId;
    private String mFundsToCreditor = SFS_System_Settings__c.getInstance().DNL_Funds_To_Creditor_Itm__c;
    private String mDedicatedAmountCash = SFS_System_Settings__c.getInstance().DNL_Cash_In_Dedicated_Itm__c;
    private String mDrpOneMonthPayment = SFS_System_Settings__c.getInstance().DNL_One_Mth_Payment_Itm__c;
    private String mRemainingFeeDueDrp = SFS_System_Settings__c.getInstance().DNL_Rem_Fee_Due_DRP_Itm__c;    
    
    
    private String mMonthlyPaymentToDRP = 'Payment to DRP';
    private String mMonthlyObligations = 'Other obligations';
    
    
    private List<fsCore__Lending_Application__c> mNewLendingApps;
    private Map<String, fsCore__Lending_Application__c> mNewLendingAppMap;
    private Boolean mSaveRecords = true; //THIS IS FOR THE TESTING TO TURN OFF
    
    public LendingApplicationCreator(Set<Id> pSourceOppIds){
        init(pSourceOppIds);
    }
    
    private void init(Set<Id> pSourceOppIds){
        //populate source application map by name
        mSourceOpportunityMap = new Map<String, Opportunity>();
        mAccountToContactIdMap= new Map<ID, ID>();
        
        
        Set<ID> coApplicants = new Set<ID>();
        
        for(Opportunity opp : ApplicationUtil.getSourceOpportunityMap(pSourceOppIds).values()){
            mSourceOpportunityMap.put(opp.Name, opp);
            if (opp.Co_Applicant_Name__c != null){
                coApplicants.add(opp.Co_Applicant_Name__c );
            }
        }
        list<Account> coApplicantAccountList= [select id, personContactId from Account where id in :coApplicants];
        for(Account acc : coApplicantAccountList){
            mAccountToContactIdMap.put(acc.id, acc.personContactId);
        }
        
        mSourceOppIds = pSourceOppIds;
        
        
        //REQUERYING IT AGAIN BECAUSE I NEED account.personContactId ONLY FOR DNL LOANS
        mOppToContactId = new Map<Id,Id>();
        mContactIds = new Set<Id>();
        List<Opportunity> oppContactList =  [select id,account.personContactId from opportunity where id in :pSourceOppIds and Opportunity_Type__c ='DNL'];
        for(Opportunity oppContact : oppContactList){
            mOppToContactId.put(oppContact.id, oppContact.account.personContactId);
            mContactIds.add(oppContact.account.personContactId);
        }
        
        
        
    }
    
    public void createRecords(){
        /* populate the source data and the relevant maps */
        prepareData();
        
        /* validate opportunity Eligibilyt */
        validateOpportunities();
        
        
        /* create lending applications */
        createDNLLendingApplications();
        
        /* create itemizations */
        createItemizations();
        
        /* update related lending application on source */
        linkApplicationToOpportunity();
        
        /* Link documents to application */
        linkDocumentsToLendingApplications();
        
        /* Link nuDebt payments to application */
        linkNuDebtPaymentsToLendingApplications();
        
        /* Link nuDebt payments to application */
        linkNuDebtDraftFeesToLendingApplications();
        
        /* Create co-applicant */
        createCoApplicant();
        
        /* Create additionalLiabilities */
        createAdditionalLiabilities();   //PDI-359    

        
        //PDI-772 SINCE SFS WANT THE DOCUMENT CHECKLIST TO BE GENERATED ON FIRST STAGE
        //SO WE CANNOT RELY ON STAGE ACTIONS BECAUSE THE STAGE ACTIONS GETS TRIGGERED IMMEDIATELY AFTER
        //THE APP CREATION AND SINCE WE ARE CREATING THE CO-APPLICANT LATER STAGE SO THERE IS A POSSIBILITY 
        //THAT WE MISS THE CO-APPLICANT CHECKLIST
        generateDNLChecklist();
        
        /* raise validation event */
        raiseValidateAppEvent();
    }
    
    private void prepareData(){
        System.debug(loggingLevel.ERROR, '-- perpareData(+)');
        
        //set default branch
        mDefaultBranch = CommonUtil.getDefaultBranchDNL();
        if (mDefaultBranch == null){
            throw new CustomException('Unable to find the branch to create a Lending Application');
        }
        
        //populate product and product itemizations        
        mProduct = CommonUtil.getProductWithItemizations(SFS_System_Settings__c.getInstance().Default_Product_Code_DNL__c);
        
        //populate loan record type
        Map<String, RecordType> lendingAppRecTypeMap 
            = fsCore.RecordTypeUtil.getInstance()
            .getRecordTypeMapByName(Schema.SObjectType.fsCore__Lending_Application__c.getName());
        
        mLoanRecordType = lendingAppRecTypeMap.get('DNL_Loan');
        
        if (mLoanRecordType == null){
            throw new CustomException('Unable to find the record for Lending Application');
        }
        
        System.debug(loggingLevel.ERROR, '-- perpareData(-)');
    }
    private void validateOpportunities(){
        System.debug(loggingLevel.ERROR, '-- validateOpportunities(-)');
       /*
        Boolean isAppAlreadyCreated =false;
    for (opportunity sourceOpp : mSourceOpportunityMap.values()){
      if (sourceOpp.Related_Lending_Application__c != null){
        isAppAlreadyCreated = true;
      }
    }

    if (isAppAlreadyCreated){
      throw new CustomException('Lending Application already created for this opportunity.');
    }  */
        //CHECKING IN TRIGGER
        System.debug(loggingLevel.ERROR, '-- validateOpportunities(-)');
        
    }
    
    private void createDNLLendingApplications(){
        System.debug(loggingLevel.ERROR, '-- createLendingApplications(+)');
        
        fsCore.ObjectRecordMapper recordMapper = new fsCore.ObjectRecordMapper(SFSConstants.OPP_APPLICATION_MAPPING);
        
        mNewLendingApps = new List<fsCore__Lending_Application__c>();
        
        Id dnlLoanRecordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByName().get('DNL Loan').getRecordTypeId();
        
        for (opportunity sourceApp : mSourceOpportunityMap.values()){
            fsCore__Lending_Application__c newLendingApp = (fsCore__Lending_Application__c)recordMapper.getTargetRecord(sourceApp);
            newLendingApp.RecordTypeId = mLoanRecordType.Id;
            newLendingApp.fsCore__External_System_Reference_Number__c = String.valueOf(sourceApp.Id);
            
            newLendingApp.CoApplicant_Account__c = sourceApp.Co_Applicant_Name__c; //DV169
            
            //DV-322 start
            if (sourceApp.Co_Applicant_Name__c != null){
                newLendingApp.CoApplicant_Contact__c = mAccountToContactIdMap.get(sourceApp.Co_Applicant_Name__c); //DV-322
            }
            //DV-322 end
            
            //set default branch and company
            newLendingApp.fsCore__Branch_Name__c = mDefaultBranch.Id;
            newLendingApp.fsCore__Company_Name__c = mDefaultBranch.fsCore__Company_Name__c;
            newLendingApp.fsCore__Application_Status__c = 'New';
            
            newLendingApp.fsCore__Product_Name__c = mProduct.Id;
            newLendingApp.fsCore__Product_Family__c = mProduct.fsCore__Product_Family__c;
            newLendingApp.fsCore__Collateral_Family__c = mProduct.fsCore__Collateral_Family__c;
            newLendingApp.fsCore__Collateral_Sub_Family__c = mProduct.fsCore__Collateral_Sub_Family__c;
            newLendingApp.fsCore__Is_Secured__c = mProduct.fsCore__Is_Secured__c;
            newLendingApp.fsCore__Is_Syndication_Allowed__c = mProduct.fsCore__Is_Syndication_Allowed__c;
            newLendingApp.fsCore__Is_Payment_Cycle_Flexible__c = mProduct.fsCore__Is_Billing_Cycle_Flexible__c;
            newLendingApp.fsCore__Is_Funding_In_Tranches_Allowed__c = mProduct.fsCore__Is_Funding_In_Tranches_Allowed__c;
            //newLendingApp.fsCore__Requested_Payment_Cycle__c = mProduct.fsCore__Billing_Cycle__c; //THIS NEEDS TO BE POPULATED FROM OPP
            newLendingApp.fsCore__Is_Assign_Using_First_Stage_Setup__c = true; 
            //newLendingApp.NuDebt_Total_Actual_Fee__c=
            Integer secondPaymentDueDay = fsCore.Constants.DUMMY_SECOND_DUE_DAY;
            if (newLendingApp.fsCore__Requested_Payment_Cycle__c == fsCore.Constants.CYCLE_TWICE_MONTHLY){
                secondPaymentDueDay = (Integer)newLendingApp.fsCore__Payment_Due_Day_2__c;
            }              
            //PDI-398, newLendingApp.fsCore__Requested_Contract_Start_Date__c is already coming from formula by adding 90 days
            system.debug(logginglevel.error,'newLendingApp.fsCore__Requested_Contract_Start_Date__c :'+newLendingApp.fsCore__Requested_Contract_Start_Date__c);
            system.debug(logginglevel.error,'newLendingApp.fsCore__Payment_Due_Day__c :'+newLendingApp.fsCore__Payment_Due_Day__c);
            system.debug(logginglevel.error,'newLendingApp.secondPaymentDueDay :'+secondPaymentDueDay);
            system.debug(logginglevel.error,'newLendingApp.fsCore__Requested_Payment_Cycle__c :'+newLendingApp.fsCore__Requested_Payment_Cycle__c);
            newLendingApp.fsCore__Requested_Payment_Start_Date__c = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(newLendingApp.fsCore__Requested_Contract_Start_Date__c
                                                                                                                         , (Integer)newLendingApp.fsCore__Payment_Due_Day__c
                                                                                                                         , secondPaymentDueDay
                                                                                                                         , newLendingApp.fsCore__Requested_Payment_Cycle__c);
            
            //PDI-398
            newLendingApp.fsCore__Requested_Payment_Start_Date_2__c = fsCore.DateUtilGlobal.adjustDateByAddingBillingCycle(newLendingApp.fsCore__Requested_Payment_Start_Date__c
                                                                                                                           , (Integer)newLendingApp.fsCore__Payment_Due_Day__c
                                                                                                                           , secondPaymentDueDay
                                                                                                                           , newLendingApp.fsCore__Requested_Payment_Cycle__c);            
            
            
            //SET RECORD TYPE ID TO DO
            newLendingApp.RecordTypeId = dnlLoanRecordTypeId;
            mNewLendingApps.add(newLendingApp);
        }
        
        fsCore.DMLResult lendingAppDMLRslt = fsCore.LendingApplicationDMLWrapper.getInstance().insertData(mNewLendingApps);
        if (lendingAppDMLRslt.hasErrors()) lendingAppDMLRslt.throwError();
        
        // populate source app name to lending app map
        mNewLendingAppMap = new Map<String, fsCore__Lending_Application__c>();
        for(fsCore__Lending_Application__c lendingApp : mNewLendingApps){
            mNewLendingAppMap.put(lendingApp.fsCore__External_System_Reference_Number__c , lendingApp);
        }
        
        System.debug(loggingLevel.ERROR, '-- createLendingApplications(-)');
    }
    
    /*private void createItemizations(){
        System.debug(loggingLevel.ERROR, '-- createItemizations(+)');
        
        List<fsCore__Lending_Application_Itemization__c> lendingAppItemizations = new List<fsCore__Lending_Application_Itemization__c>();
        
        for(Opportunity sourceOpp : mSourceOpportunityMap.values()){
        
        fsCore__Lending_Application__c lendingApp = mNewLendingAppMap.get(sourceOpp.Name);
        for(fsCore__Product_Itemization_Setup__c prodItmz : mProduct.fsCore__Product_Itemization_Setup__r){
        fsCore__Lending_Application_Itemization__c appItmz = new fsCore__Lending_Application_Itemization__c();
        appItmz.fsCore__Lending_Application_Number__c = lendingApp.Id;
        appItmz.fsCore__Itemization_Name__c = prodItmz.fsCore__Itemization_Name__c;
        appItmz.fsCore__Itemization_Family__c = prodItmz.fsCore__Itemization_Family__c;
        appItmz.fsCore__Plus_Or_Minus__c = prodItmz.fsCore__Plus_Or_Minus__c;
        appItmz.fsCore__Disbursement_Allowed__c = prodItmz.fsCore__Disbursement_Allowed__c;
        appItmz.fsCore__Fee_Category__c = prodItmz.fsCore__Fee_Category__c;
        appItmz.fsCore__Is_Override_Allowed__c = prodItmz.fsCore__Is_Override_Allowed__c;
        appItmz.fsCore__Source__c = fsCore.Constants.ITMZ_SOURCE_PRODUCT;
        
        system.debug(logginglevel.error,'mFundsToCreditor :'+mFundsToCreditor);
        system.debug(logginglevel.error,'Prod ITM :'+prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c);
        
        if (String.IsNotBlank(mFundsToCreditor) && prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mFundsToCreditor)){
        appItmz.fsCore__Requested_Amount_Unsigned__c = sourceOpp.Amount;
        }
        else if (String.IsNotBlank(mDedicatedAmountCash) && prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mDedicatedAmountCash)){
        appItmz.fsCore__Requested_Amount_Unsigned__c = sourceOpp.Cash_in_Dedicated_Account__c;
        }
        else if (String.IsNotBlank(mDrpOneMonthPayment) && prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mDrpOneMonthPayment)){
        //appItmz.fsCore__Requested_Amount_Unsigned__c = 
        }                
        else if (String.IsNotBlank(mRemainingFeeDueDrp) && prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mRemainingFeeDueDrp)){
        appItmz.fsCore__Requested_Amount_Unsigned__c= sourceOpp.Unpaid_Program_Fee_WO_DNL__c;
        }                                
        appItmz.fsCore__Requested_Amount_Unsigned__c = (appItmz.fsCore__Requested_Amount_Unsigned__c == null) ? 0.00 : appItmz.fsCore__Requested_Amount_Unsigned__c;
        
        //We need to make sure unsigned must be without the sign
        if (appItmz.fsCore__Requested_Amount_Unsigned__c < 0){
        appItmz.fsCore__Requested_Amount_Unsigned__c = (-1) * (appItmz.fsCore__Requested_Amount_Unsigned__c);
        }
        
        system.debug(logginglevel.error,'Prod ITM Amount:'+appItmz.fsCore__Requested_Amount_Unsigned__c);
        lendingAppItemizations.add(appItmz);
        }
        }
        
        fsCore.DMLResult appItmzDMLRslt = fsCore.LendingApplicationItemizationDMLWrapper.getInstance().insertData(lendingAppItemizations);
        if (appItmzDMLRslt.hasErrors()) appItmzDMLRslt.throwError();
        
        System.debug(loggingLevel.ERROR, '-- createItemizations(-)');
    }*/
    
    private void createItemizations(){
        System.debug(loggingLevel.ERROR, '-- createItemizations(+)');
        
        List<Opportunity_Tradelines_Offer__c> oppOfferList = [SELECT  Id
                                                              , Lending_Application_Number__c
                                                              , Opportunity_Name__c
                                                              , SFS_Current_Balance__c
                                                              , Original_Creditor__c
                                                              , New_Creditor__c
                                                              , Import_Id__c
                                                              , Original_Debt__c
                                                              , Settlement__c
                                                              , Estimated_Settlement__c
                                                              , Opportunity_Name__r.Name
                                                              , Opportunity_Name__r.Id
                                                              FROM Opportunity_Tradelines_Offer__c
                                                              WHERE Opportunity_Name__c IN :mSourceOppIds];
        
        
        List<fsCore__Lending_Application_Itemization__c> lendingAppItemizations = new List<fsCore__Lending_Application_Itemization__c>();
        
        //DV-49 start
        Map<String, List<DNL_Settlement_Rates__c>> dnlSettlementRatesMap = new MAP<String, List<DNL_Settlement_Rates__c>>();
        List <DNL_Settlement_Rates__c> dnlSettlementRateList;
        if (SFS_System_Settings__c.getInstance().Is_DNL_Settlement_Active_Rates_Only__c){
            dnlSettlementRateList = [SELECT id, Original_Creditor__c,Current_Creditor__c,Average_of_Adjusted_Settlement__c,Type__c FROM DNL_Settlement_Rates__c where IsActive__c = true order by Current_Creditor__c];
        } else{
            dnlSettlementRateList = [SELECT id, Original_Creditor__c,Current_Creditor__c,Average_of_Adjusted_Settlement__c,Type__c FROM DNL_Settlement_Rates__c order by Current_Creditor__c];
        }
        string currentCreditor;
        List<DNL_Settlement_Rates__c> creditorList = new List<DNL_Settlement_Rates__c>();
        for(DNL_Settlement_Rates__c dsr : dnlSettlementRateList){
            if ((currentCreditor == null)
                ||currentCreditor != dsr.Current_Creditor__c){
                    if (currentCreditor == null){
                    currentCreditor = dsr.Current_Creditor__c;
                    creditorList = new List<DNL_Settlement_Rates__c>();
                    }else{
                        dnlSettlementRatesMap.put(currentCreditor,creditorList);
                        currentCreditor = dsr.Current_Creditor__c;
                        creditorList = new List<DNL_Settlement_Rates__c>();
                    }
                    creditorList.add(dsr);
            }
            if (creditorList.size()>0){
                dnlSettlementRatesMap.put(currentCreditor,creditorList);
            }
        }
        //DV-49 end       


        for(Opportunity sourceOpp : mSourceOpportunityMap.values()){
            
            fsCore__Lending_Application__c lendingApp = mNewLendingAppMap.get(sourceOpp.Id);
            Boolean tradelineFlag = false;
            for(fsCore__Product_Itemization_Setup__c prodItmz : mProduct.fsCore__Product_Itemization_Setup__r){
                
                system.debug(logginglevel.error,'mFundsToCreditor :'+mFundsToCreditor);
                system.debug(logginglevel.error,'Prod ITM :'+prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c);
                
                
                if (prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mFundsToCreditor)){
                    if (!tradelineFlag){
                        for(Opportunity_Tradelines_Offer__c oppOffer : oppOfferList){

                            tradelineFlag = true;
                            
                            fsCore__Lending_Application_Itemization__c appItmz = new fsCore__Lending_Application_Itemization__c();
                            appItmz.fsCore__Lending_Application_Number__c = lendingApp.Id;
                            appItmz.fsCore__Itemization_Name__c = prodItmz.fsCore__Itemization_Name__c;
                            appItmz.fsCore__Itemization_Family__c = prodItmz.fsCore__Itemization_Family__c;
                            appItmz.fsCore__Plus_Or_Minus__c = prodItmz.fsCore__Plus_Or_Minus__c;
                            appItmz.fsCore__Itemization_Code__c = prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c;
                            appItmz.fsCore__Disbursement_Allowed__c = prodItmz.fsCore__Disbursement_Allowed__c;
                            appItmz.fsCore__Fee_Category__c = prodItmz.fsCore__Fee_Category__c;
                            appItmz.fsCore__Is_Override_Allowed__c = prodItmz.fsCore__Is_Override_Allowed__c;
                            appItmz.fsCore__Source__c = fsCore.Constants.ITMZ_SOURCE_PRODUCT;
                            
                            System.debug(loggingLevel.ERROR, 'Lending App:oppOffer.SFS_Current_Balance__c'+oppOffer.SFS_Current_Balance__c);
                            System.debug(loggingLevel.ERROR, 'Lending App:oppOffer.Original_Debt__c'+oppOffer.Original_Debt__c);
                           //DV-118 Update:324 to 331
                          /*  if(oppOffer.Offer_Status__c=='Payment Plan - Active'){    //DV-55
                                appItmz.fsCore__Requested_Amount_Unsigned__c =(oppOffer.Offer_Amount__c - oppOffer.Settlement_Amount_Paid__c);
                            }
                            else{ */
                               if((oppOffer.SFS_Current_Balance__c == oppOffer.Original_Debt__c) || (oppOffer.SFS_Current_Balance__c==null && oppOffer.Original_Debt__c!=null) || (oppOffer.SFS_Current_Balance__c!=null && oppOffer.Original_Debt__c!=null)){  
                                appItmz.fsCore__Requested_Amount_Unsigned__c = oppOffer.Original_Debt__c*1.15;
                                System.debug(loggingLevel.ERROR, 'appItmz.fsCore__Requested_Amount_Unsigned__c'+appItmz.fsCore__Requested_Amount_Unsigned__c);
                               
                            }
                            else{
                                appItmz.fsCore__Requested_Amount_Unsigned__c = oppOffer.SFS_Current_Balance__c;
                            }   
                           // }
                            
                           
                            appItmz.Tradeline_Import_Id__c = oppOffer.Import_Id__c;
                            appItmz.Tradeline_Name__c  = oppOffer.Id;
                            if (oppOffer.Original_Debt__c == null && oppOffer.SFS_Current_Balance__c == null){//fSpectra added null check
                                appItmz.DNL_Original_Enrolled_Balance__c = 0;    
                            }else{
                                appItmz.DNL_Original_Enrolled_Balance__c=oppOffer.Original_Debt__c;  //PDI-860 
                            }
                            appItmz.Original_Creditor__c= (oppOffer.Original_Creditor__c == null)?oppOffer.New_Creditor__c:oppOffer.Original_Creditor__c ;
                            appItmz.Current_Creditor__c= (oppOffer.New_Creditor__c == null)?oppOffer.Original_Creditor__c:oppOffer.New_Creditor__c;
                            appItmz.Estimated_Settlement_Percent__c = oppOffer.Estimated_Settlement__c;
                            //DV-49 start
                            if (appItmz.Current_Creditor__c != null){
                                //JUST IF THE ORIGINAL AND CURRENT CREDITOR MATCH
                                Boolean matched = false;
                                if (dnlSettlementRatesMap.get(appItmz.Current_Creditor__c) != null){
                                    List<DNL_Settlement_Rates__c> dnlSettlementCreditorRateList = dnlSettlementRatesMap.get(appItmz.Current_Creditor__c);
                                    for (DNL_Settlement_Rates__c dnlSettlementRate: dnlSettlementCreditorRateList){
                                        if (dnlSettlementRate.Current_Creditor__c == appItmz.Current_Creditor__c){
                                            if (dnlSettlementRate.Average_of_Adjusted_Settlement__c != null){
                                                appItmz.Estimated_Settlement_Percent__c = dnlSettlementRate.Average_of_Adjusted_Settlement__c;
                                                matched = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (!matched){
                                    // IF NO MATCH THEN SET TO 50% AS MENTIONED IN THE TICKET PDI-713
                                    if (SFS_System_Settings__c.getInstance().Is_DNL_Settle_Unmatched_Default_Allowed__c){
                                        if (SFS_System_Settings__c.getInstance().DNL_Settlement_Unmatched_Rate__c != null){
                                            appItmz.Estimated_Settlement_Percent__c = SFS_System_Settings__c.getInstance().DNL_Settlement_Unmatched_Rate__c;
                                        }else{
                                            appItmz.Estimated_Settlement_Percent__c  = 50;
                                        }
                                    }
                                }
                
                            }                            
                            //DV-49 End
                            
                            if (appItmz.fsCore__Requested_Amount_Unsigned__c != null && appItmz.fsCore__Requested_Amount_Unsigned__c >0 ){
                                if (appItmz.Estimated_Settlement_Percent__c != null){
                                    appItmz.fsCore__Approved_Amount_Unsigned__c =  appItmz.fsCore__Requested_Amount_Unsigned__c * (appItmz.Estimated_Settlement_Percent__c/100);
                                }
                            }                            
                            if (appItmz.fsCore__Requested_Amount_Unsigned__c < 0){
                                appItmz.fsCore__Requested_Amount_Unsigned__c = (-1) * (appItmz.fsCore__Requested_Amount_Unsigned__c);
                            }                           
                            if (appItmz.fsCore__Approved_Amount_Unsigned__c < 0){
                                appItmz.fsCore__Approved_Amount_Unsigned__c = (-1) * (appItmz.fsCore__Approved_Amount_Unsigned__c);
                            } 
                            lendingAppItemizations.add(appItmz);
                        }
                    }
                }else{
                    
                    fsCore__Lending_Application_Itemization__c appItmz = new fsCore__Lending_Application_Itemization__c();
                    appItmz.fsCore__Lending_Application_Number__c = lendingApp.Id;
                    appItmz.fsCore__Itemization_Name__c = prodItmz.fsCore__Itemization_Name__c;
                    appItmz.fsCore__Itemization_Family__c = prodItmz.fsCore__Itemization_Family__c;
                    appItmz.fsCore__Plus_Or_Minus__c = prodItmz.fsCore__Plus_Or_Minus__c;
                    appItmz.fsCore__Itemization_Code__c = prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c;
                    appItmz.fsCore__Disbursement_Allowed__c = prodItmz.fsCore__Disbursement_Allowed__c;
                    appItmz.fsCore__Fee_Category__c = prodItmz.fsCore__Fee_Category__c;
                    appItmz.fsCore__Is_Override_Allowed__c = prodItmz.fsCore__Is_Override_Allowed__c;
                    appItmz.fsCore__Source__c = fsCore.Constants.ITMZ_SOURCE_PRODUCT;
                    appItmz.Estimated_Settlement_Percent__c = 100;
                    
                    
                    if (String.IsNotBlank(mDedicatedAmountCash) && prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mDedicatedAmountCash)){
                        appItmz.fsCore__Requested_Amount_Unsigned__c = sourceOpp.Cash_in_Dedicated_Account__c;
                        appItmz.fsCore__Approved_Amount_Unsigned__c = sourceOpp.Cash_in_Dedicated_Account__c;
                    }
                    else if (String.IsNotBlank(mDrpOneMonthPayment) && prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mDrpOneMonthPayment)){
                        appItmz.fsCore__Requested_Amount_Unsigned__c = sourceOpp.Draft_Amount_Per_Period__c;
                        appItmz.fsCore__Approved_Amount_Unsigned__c = sourceOpp.Draft_Amount_Per_Period__c;
                        
                    }                
                    else if (String.IsNotBlank(mRemainingFeeDueDrp) && prodItmz.fsCore__Itemization_Name__r.fsCore__Itemization_Code__c.equalsIgnoreCase(mRemainingFeeDueDrp)){
                        appItmz.fsCore__Requested_Amount_Unsigned__c= sourceOpp.Remaining_Fee_Due_To_DRP__c;
                        appItmz.fsCore__Approved_Amount_Unsigned__c = sourceOpp.Remaining_Fee_Due_To_DRP__c;
                        
                    }                                
                    appItmz.fsCore__Requested_Amount_Unsigned__c = (appItmz.fsCore__Requested_Amount_Unsigned__c == null) ? 0.00 : appItmz.fsCore__Requested_Amount_Unsigned__c;
                    
                    if (appItmz.fsCore__Requested_Amount_Unsigned__c < 0){
                        appItmz.fsCore__Requested_Amount_Unsigned__c = (-1) * (appItmz.fsCore__Requested_Amount_Unsigned__c);
                    }                           
                    if (appItmz.fsCore__Approved_Amount_Unsigned__c < 0){
                        appItmz.fsCore__Approved_Amount_Unsigned__c = (-1) * (appItmz.fsCore__Approved_Amount_Unsigned__c);
                    } 
                    system.debug(logginglevel.error,'Prod ITM Amount:'+appItmz.fsCore__Requested_Amount_Unsigned__c);
                    lendingAppItemizations.add(appItmz);
                }
            }
        }
        fsCore.DMLResult appItmzDMLRslt = fsCore.LendingApplicationItemizationDMLWrapper.getInstance().insertData(lendingAppItemizations);
        if (appItmzDMLRslt.hasErrors()) appItmzDMLRslt.throwError();
        
        System.debug(loggingLevel.ERROR, '-- createItemizations Size (-)'+lendingAppItemizations.size());    
        for(Opportunity_Tradelines_Offer__c oppOffer : oppOfferList){
            System.debug(loggingLevel.ERROR, '-- oppOffer.Opportunity_Name__r.Name : '+oppOffer.Opportunity_Name__r.Name);
            System.debug(loggingLevel.ERROR, '-- oppOffer.Opportunity_Name__r.Id : '+oppOffer.Opportunity_Name__r.Id);
            System.debug(loggingLevel.ERROR, '-- App Id# : '+mNewLendingAppMap.get(oppOffer.Opportunity_Name__r.Id).Id);
            oppOffer.Lending_Application_Number__c = mNewLendingAppMap.get(oppOffer.Opportunity_Name__r.Id).Id;
        }
        
        
        System.debug(loggingLevel.ERROR,'-- updating oppOfferList... Record Count : ' + oppOfferList.size());
        if (mSaveRecords){
            Database.SaveResult[] newDTSR = Database.update(oppOfferList,false);
            
            System.debug(loggingLevel.ERROR, '-- oppOfferList(-)'+newDTSR);
        }
        
        
    }
    
    private void linkApplicationToOpportunity(){
        System.debug(loggingLevel.ERROR, '-- linkLendingToSourceApplications(+)');
        Schema.RecordTypeInfo readOnlyOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DNL_Read_Only');
        
        for(Opportunity sourceOpp : mSourceOpportunityMap.values()){
            sourceOpp.Related_Lending_Application__c = mNewLendingAppMap.get(sourceOpp.Id).Id;
            if (readOnlyOpp != null){
                sourceOpp.RecordTypeId = readOnlyOpp.getRecordTypeId();
            }
            sourceOpp.StageName = 'Closed Won';
            //sourceOpp.isNot_Application__c=true; //DV-283
        }
        if (mSaveRecords){
            System.debug(loggingLevel.ERROR, '-- mSourceOpportunityMap.values():--'+mSourceOpportunityMap.values());
            try{ 
                  Database.SaveResult[] sourceOppSR = Database.update(mSourceOpportunityMap.values());
            }Catch(Exception e){
                System.debug(loggingLevel.ERROR, 'Exception msg:--'+e.getMessage());
                System.debug(loggingLevel.ERROR, 'Exception stack trace:--'+e.getStackTraceString());
            }
        }
        
        System.debug(loggingLevel.ERROR, '-- linkApplicationToOpportunity(-)');
        
    }
    
    private void raiseValidateAppEvent(){
        List<fsCore__Execute_Process_Action__e> validateAppEvents = new List<fsCore__Execute_Process_Action__e>();
        
        for(fsCore__Lending_Application__c application : mNewLendingAppMap.values()){
            fsCore__Execute_Process_Action__e event = new fsCore__Execute_Process_Action__e();
            event.fsCore__Action_Code__c = 'VALIDATE_APP_STAGE';
            event.fsCore__Parent_ID__c = String.valueOf(application.Id);
            validateAppEvents.add(event);
        }
        
        if(validateAppEvents.size() > 0){
            System.debug(loggingLevel.ERROR,'Raising validate application events...'); 
            if (mSaveRecords){
                List<Database.SaveResult> evtPubRslt = EventBus.publish(validateAppEvents);
            }
        }
        
    }
    private void linkDocumentsToLendingApplications(){
        System.debug(loggingLevel.ERROR, '-- linkDocumentsToLendingApplications(+)');
        List<ContentDocumentLink> lendingAppChkDocLinks = new List<ContentDocumentLink>();
        Map<Id, List<ContentDocumentLink>> contentDocLinkMap = new Map<Id, List<ContentDocumentLink>>();
        for (Id opp : mSourceOppIds){
            contentDocLinkMap.put(opp, new List<ContentDocumentLink>());
        }        
        List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId
                                                        , Id
                                                        , IsDeleted
                                                        , LinkedEntityId
                                                        , ShareType
                                                        , Visibility 
                                                        FROM ContentDocumentLink
                                                        WHERE LinkedEntityId IN :mSourceOppIds
                                                        ORDER BY LinkedEntityId];
        
        
        for(ContentDocumentLink cd:contentDocLinkList){
            if (contentDocLinkMap.containsKey(cd.LinkedEntityId)){
                contentDocLinkMap.get(cd.LinkedEntityId).add(cd);
            }
        }    
        
        for(Opportunity sourceOpp : mSourceOpportunityMap.values()){
            for(ContentDocumentLink cdLink : contentDocLinkMap.get(sourceOpp.Id)){
                ContentDocumentLink newLink = new ContentDocumentLink();
                newLink.ContentDocumentId = cdLink.ContentDocumentId;
                newLink.LinkedEntityId = mNewLendingAppMap.get(sourceOpp.Id).Id;
                newLink.ShareType = cdLink.ShareType;
                newLink.Visibility = cdLink.Visibility;
                lendingAppChkDocLinks.add(newLink);
                
            }
            
        }                                                       
        
        if (!lendingAppChkDocLinks.isEmpty()){
            System.debug(loggingLevel.ERROR,'-- saving new document links... Record Count : ' + lendingAppChkDocLinks.size());
            if (mSaveRecords){
                Database.SaveResult[] newDocLinksSR = Database.insert(lendingAppChkDocLinks,false);
            }
        }        
        System.debug(loggingLevel.ERROR, '-- linkDocumentsToLendingApplications(-)');
    }    
    
    private void linkNuDebtPaymentsToLendingApplications(){
        System.debug(loggingLevel.ERROR, '-- linkNuDebtPaymentsToLendingApplications(+)');
        List<Opportunity_Payment__c> oppPaymentsList = [SELECT  Id
                                                        , Lending_Application_Number__c
                                                        , Opportunity_Name__c
                                                        , Opportunity_Name__r.Name
                                                        , Opportunity_Name__r.Id
                                                        FROM Opportunity_Payment__c
                                                        WHERE Opportunity_Name__c IN :mSourceOppIds];
        
        
        for(Opportunity_Payment__c oppPayment : oppPaymentsList){
            oppPayment.Lending_Application_Number__c = mNewLendingAppMap.get(oppPayment.Opportunity_Name__r.Id).Id;
        }                                                       
        
        
        System.debug(loggingLevel.ERROR,'-- updating oppPaymentsList links... Record Count : ' + oppPaymentsList.size());
        if (mSaveRecords){
            Database.SaveResult[] newPaymentsSR = Database.update(oppPaymentsList,false);
        }
        
        System.debug(loggingLevel.ERROR, '-- linkNuDebtPaymentsToLendingApplications(-)');
    }  
    
    private void linkNuDebtDraftFeesToLendingApplications(){
        System.debug(loggingLevel.ERROR, '-- linkNuDebtDraftFeesToLendingApplications(+)');
        List<Opportunity_Draft_Fee__c> oppDraftFeesList = [SELECT  Id
                                                           , Lending_Application_Number__c
                                                           , Opportunity_Name__c
                                                           , Opportunity_Name__r.Name
                                                           , Opportunity_Name__r.Id
                                                           FROM Opportunity_Draft_Fee__c
                                                           WHERE Opportunity_Name__c IN :mSourceOppIds];
        
        
        for(Opportunity_Draft_Fee__c oppFee : oppDraftFeesList){
            oppFee.Lending_Application_Number__c = mNewLendingAppMap.get(oppFee.Opportunity_Name__r.Id).Id;
        }                                                       
        
        
        System.debug(loggingLevel.ERROR,'-- updating oppDraftFeeList links... Record Count : ' + oppDraftFeesList.size());
        if (mSaveRecords){
            Database.SaveResult[] newDraftFeeSR = Database.update(oppDraftFeesList,false);
            
            upsert appItemizationsWithDraftFeeUpdateList(oppDraftFeesList);
        }
        
        System.debug(loggingLevel.ERROR, '-- linkNuDebtDraftFeesToLendingApplications(-)');
    }      
    
    
    public static list<fsCore__Lending_Application_Itemization__c> appItemizationsWithDraftFeeUpdateList(List<Opportunity_Draft_Fee__c> pUpdatedDraftFeesList){
        //LOGIC TO UPDATE THE DRAFT FEE ON THE ITEMIZATIONS
        
        Set<Id> DraftFeeIds = new Set<Id>();
        for(Opportunity_Draft_Fee__c oppDraft: pUpdatedDraftFeesList){
            DraftFeeIds.add(oppDraft.Id);
        }
        
        List<Opportunity_Draft_Fee__c> oppDraftFeeList = [select id,Lending_Application_Number__c,PreTila_DNL_Fee_Formula__c from Opportunity_Draft_Fee__c where id in :DraftFeeIds];
        
        Map<Id,Opportunity_Draft_Fee__c> applicationToDraftFeeMap = new Map<Id,Opportunity_Draft_Fee__c>();
        Set<Id> applicationIds = new Set<Id>();
        for(Opportunity_Draft_Fee__c draftFee: oppDraftFeeList){
            applicationToDraftFeeMap.put(draftFee.Lending_Application_Number__c,draftFee);
            applicationIds.add(draftFee.Lending_Application_Number__c);
        }
        
        String remainingFeeDueDrp = SFS_System_Settings__c.getInstance().DNL_Rem_Fee_Due_DRP_Itm__c;    
        
        List<fsCore__Lending_Application_Itemization__c> lendingAppItemizationsList = 
            [select id
             , fsCore__Lending_Application_Number__c
             , Itemization_Code_Formula__c
             , fsCore__Requested_Amount_Unsigned__c
             , fsCore__Approved_Amount_Unsigned__c
             , fsCore__Actual_Amount_Unsigned__c
             , fsCore__Lending_Application_Number__r.NuDebt_Total_Actual_Fee__c //PDI-632 to update the actual amount on itemization
             , fsCore__Lending_Application_Number__r.Final_Approval_Date__c
             from fsCore__Lending_Application_Itemization__c 
             where  fsCore__Lending_Application_Number__c in :applicationIds
             AND Itemization_Code_Formula__c = :remainingFeeDueDrp];
        
        for(fsCore__Lending_Application_Itemization__c appItemization: lendingAppItemizationsList){
            //PDI-611
            //Do not update itemization if the application is approved. On approval we do update the Final_Approval_Date__c
            //if (appItemization.fsCore__Lending_Application_Number__r.Final_Approval_Date__c == null){
            appItemization.fsCore__Requested_Amount_Unsigned__c = applicationToDraftFeeMap.get(appItemization.fsCore__Lending_Application_Number__c).PreTila_DNL_Fee_Formula__c;
            appItemization.fsCore__Approved_Amount_Unsigned__c = applicationToDraftFeeMap.get(appItemization.fsCore__Lending_Application_Number__c).PreTila_DNL_Fee_Formula__c;
            //}
            appItemization.fsCore__Actual_Amount_Unsigned__c = appItemization.fsCore__Lending_Application_Number__r.NuDebt_Total_Actual_Fee__c;
        }
        
        return lendingAppItemizationsList;
        
    }   
    
    
    
    private fsCore__Lending_Application_Customer__c getApplicationCustomerInstance(Id pApplicationId
                                                                                   , Id pCustomerRecordTypeId
                                                                                   , Id pCustomerAccountId
                                                                                   , Id pCustomerContactId){
                                                                                       
                                                                                       fsCore__Lending_Application_Customer__c appCustomer = new fsCore__Lending_Application_Customer__c();
                                                                                       
                                                                                       appCustomer.fsCore__Lending_Application_Number__c = pApplicationId;
                                                                                       appCustomer.RecordTypeId = pCustomerRecordTypeId;
                                                                                       appCustomer.fsCore__Customer_Type__c = fsCore.Constants.CUSTOMER_TYPE_SECONDARY;
                                                                                       appCustomer.fsCore__Account_Name__c = pCustomerAccountId;
                                                                                       appCustomer.fsCore__Contact_Name__c = pCustomerContactId;
                                                                                       return appCustomer;
                                                                                   }    
    
    private void createCoApplicant(){
        System.debug(loggingLevel.ERROR, '-- createCoApplicant(+)');
        List<fsCore__Lending_Application_Customer__c> CoApplicantCustomerList = new List<fsCore__Lending_Application_Customer__c>();
        Map<String, RecordType> customerRecordTypeMap = fsCore.RecordTypeUtil.getInstance().getRecordTypeMapByName(
            Schema.SObjectType.fsCore__Lending_Application_Customer__c.getName());
        
        System.debug(loggingLevel.ERROR, 'customerRecordTypeMap :'+customerRecordTypeMap);
        for(Opportunity sourceOpp : mSourceOpportunityMap.values()){
            if (sourceOpp.Co_Applicant_Name__c != null) {
                CoApplicantCustomerList.add(getApplicationCustomerInstance(mNewLendingAppMap.get(sourceOpp.Id).Id
                                                                           , customerRecordTypeMap.get(FsCore.Constants.RECORD_TYPE_OTHER).Id
                                                                           , sourceOpp.Co_Applicant_Name__c
                                                                           , mAccountToContactIdMap.get(sourceOpp.Co_Applicant_Name__c)));
                
                
            }
            
        }   
        
        if (!CoApplicantCustomerList.isEmpty()){
            System.debug(loggingLevel.ERROR,'-- saving new customer... Record Count : ' + CoApplicantCustomerList.size());
            if (mSaveRecords){
                Database.SaveResult[] newCoAppSR = Database.insert(CoApplicantCustomerList,false);
            }
        }                
        
        System.debug(loggingLevel.ERROR, '-- createCoApplicant(-)');
    }    

    /**
    * @description : method to generate the dnl checklist  to be called after inserting the co-applicant.(PDI-772)
    * This method cannot be FUTURE because it calls further future method to create BOX folder.
    * @author financialSpectra
    * @param set<ID> pApplicationIds
    * @return void
    */
    private  void generateDNLChecklist(){
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        for (opportunity sourceApp : mSourceOpportunityMap.values()){
            acrInput.addRecord(mNewLendingAppMap.get(sourceApp.Id).id);
        }        

        GenerateCustomChkLstActionProcessor checklistActionProcessor = new GenerateCustomChkLstActionProcessor();
        checklistActionProcessor.setInput(acrInput);
        checklistActionProcessor.process();

    }
    
    private void createAdditionalLiabilities(){
        System.debug(loggingLevel.ERROR, '-- createAdditionalLiabilities(+)');
        Map<Id, List<fsCore__Financial__c>> contactFinancialMap = fsCore.AccountContactUtil.getContactFinancialsMap(mContactIds);
        Boolean monthlyPaymentToDRPFound = false;
        Boolean otherMonthlyObligationsFound = false;
        for(Opportunity sourceOpp : mSourceOpportunityMap.values()){
            List<fsCore__Financial__c> contactFinancialsList = contactFinancialMap.get(mOppToContactId.get(sourceOpp.Id)); 
            if (contactFinancialsList == null){
                contactFinancialsList = new List<fsCore__Financial__c> ();
            }
            System.debug(loggingLevel.ERROR,'-- Initial contactFinancialsList Size : ' + contactFinancialsList.size());
            
            for(fsCore__Financial__c ConFin : contactFinancialsList){
                if ((ConFin.fsCore__Financial_Family__c == 'Liability') && (ConFin.fsCore__Financial_Type__c == mMonthlyPaymentToDRP)){
                    monthlyPaymentToDRPFound = true;
                }
                if ((ConFin.fsCore__Financial_Family__c == 'Liability') && (ConFin.fsCore__Financial_Type__c == mMonthlyObligations)){
                    otherMonthlyObligationsFound = true;
                }                    
                
            }
            System.debug(loggingLevel.ERROR,'-- monthlyPaymentToDRPFound : ' + monthlyPaymentToDRPFound);
            System.debug(loggingLevel.ERROR,'-- otherMonthlyObligationsFound : ' + otherMonthlyObligationsFound);
            
            Id liabilityRecTypeId = Schema.SObjectType.fsCore__Financial__c.getRecordTypeInfosByName().get('Liability').getRecordTypeId();
            //WITH SUBSEQUENT DISCUSSIONS WITH JEHAN EVENIF THE CUSTOMER ALREADY HAVE THE RECORD FOR MONTHLY PAYMENT TO DRP
            //STILL CREATE THE RECORD IN FINANCIALS OBJECT
            if (!monthlyPaymentToDRPFound){ //SUP-12 Uncommented the code because of SUP-12 is creating duplicate mMonthlyPaymentToDRP for cloned opp
            fsCore__Financial__c monthlyPaymentFinancial = new fsCore__Financial__c();
            monthlyPaymentFinancial.RecordTypeId = liabilityRecTypeId; 
            monthlyPaymentFinancial.fsCore__Financial_Family__c= 'Liability';
            monthlyPaymentFinancial.fsCore__Financial_Type__c= mMonthlyPaymentToDRP;
            monthlyPaymentFinancial.fsCore__contact_name__c = mOppToContactId.get(sourceOpp.Id);
            monthlyPaymentFinancial.fsCore__Frequency__c = 'Monthly';
            monthlyPaymentFinancial.fsCore__Is_Include_For_Ratio_Calculation__c = true;
            if (sourceOpp.Draft_Amount_Per_Period__c != null){
                if (sourceOpp.Payment_Cycle__c == null){
                    monthlyPaymentFinancial.fsCore__Stated_Amount__c = sourceOpp.Draft_Amount_Per_Period__c;
                    monthlyPaymentFinancial.fsCore__Monthly_Stated_Amount__c = sourceOpp.Draft_Amount_Per_Period__c;
                }else{
                    Decimal multiplicationFactor = 1;
                    if ((sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_SEMI_MONTHLY)
                        ||(sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_TWICE_MONTHLY)){
                            multiplicationFactor = 2;
                        }else if (sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_DAILY){
                            multiplicationFactor = 30;
                        }else if (sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_WEEKLY){
                            multiplicationFactor = 4.2;
                        }else if (sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_BI_WEEKLY){
                            multiplicationFactor = 2.1;
                        }else if (sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_BI_MONTHLY){
                            multiplicationFactor = 0.5;
                        }else if (sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_QUARTERLY){
                            multiplicationFactor = 0.333333333333333;
                        }else if (sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_SEMI_ANNUAL){
                            multiplicationFactor = 0.166666666666667;
                        }else if (sourceOpp.Payment_Cycle__c == fsCore.Constants.CYCLE_ANNUAL){
                            multiplicationFactor = 0.083333333333333;
                        }
                    
                    monthlyPaymentFinancial.fsCore__Stated_Amount__c = sourceOpp.Draft_Amount_Per_Period__c * multiplicationFactor ;
                    monthlyPaymentFinancial.fsCore__Monthly_Stated_Amount__c = sourceOpp.Draft_Amount_Per_Period__c * multiplicationFactor;
                }
            }
            
            monthlyPaymentFinancial.fsCore__Verified_Amount__c = monthlyPaymentFinancial.fsCore__Stated_Amount__c;
            
            contactFinancialsList.add(monthlyPaymentFinancial); 
             }
            System.debug(loggingLevel.ERROR,'-- Final contactFinancialsList : ' + contactFinancialsList.size());
            if (!otherMonthlyObligationsFound){
                fsCore__Financial__c OtherMonthlyPaymentFinancial = new fsCore__Financial__c();
                OtherMonthlyPaymentFinancial.RecordTypeId = liabilityRecTypeId; 
                OtherMonthlyPaymentFinancial.fsCore__Financial_Family__c= 'Liability';
                OtherMonthlyPaymentFinancial.fsCore__Financial_Type__c= mMonthlyObligations;
                OtherMonthlyPaymentFinancial.fsCore__contact_name__c = mOppToContactId.get(sourceOpp.Id);
                OtherMonthlyPaymentFinancial.fsCore__Frequency__c = 'Monthly';
                OtherMonthlyPaymentFinancial.fsCore__Is_Include_For_Ratio_Calculation__c = true;                    
                contactFinancialsList.add(OtherMonthlyPaymentFinancial);
            }
            contactFinancialMap.put(mOppToContactId.get(sourceOpp.Id),contactFinancialsList);
            
            
            
        }
        List<fsCore__Financial__c>  finalInsertList = new List<fsCore__Financial__c>();
        for(List<fsCore__Financial__c> financialList : contactFinancialMap.Values()){
            System.debug(loggingLevel.ERROR,'-- financialList : ' + financialList.size());
            for(fsCore__Financial__c financial : financialList){
                System.debug(loggingLevel.ERROR,'-- financial.Id : ' + financial.Id);
                if (financial.Id == null){
                    finalInsertList.add(financial);    
                }
            }
            
        }
        System.debug(loggingLevel.ERROR,'-- finalInsertList : ' + finalInsertList.size());
        if (!finalInsertList.isEmpty()){
            System.debug(loggingLevel.ERROR,'-- saving new Financial... Record Count : ' + finalInsertList.size());
            if (mSaveRecords){
                Database.SaveResult[] conFinancialsSR = Database.Insert(finalInsertList,false);
            }
        }                
        
        System.debug(loggingLevel.ERROR, '-- createAdditionalLiabilities(-)');
        
        
    }
    
}