/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name   - ApplicationActionController
 *
 * Description  - Apex Controller for Calculator Lightning Components
 *
 */
public with sharing class OpportunityActionController {
    
    /*
     * Method to get pricing for application
     */
    @InvocableMethod(label='Submit Application' description='This action method applies the opportunity to lending application on submission.')
    public static void submitApplication(List<ID> pOpportunityIds) {
        
        Set<Id> opportunityIds = new Set<Id>();
        /* DV-283
        list<Opportunity> lstOpp=[Select id,Related_Lending_Application__c from Opportunity where id in: pOpportunityIds];
        for(Opportunity opp:lstOpp){
            if(opp.Related_Lending_Application__c==null){
                //opp.isNot_Application__c=true;
                opportunityIds.add(opp.id);
             }
            else{
                //opp.addError('Lending Application already created for this opportunity.');
                throw new CustomException('Lending Application already created for this opportunity.');
            }
                 
        }
        */
        for (ID oppId: pOpportunityIds){
            opportunityIds.add(oppId);
        }

        LendingApplicationCreator lendingApp = new LendingApplicationCreator(opportunityIds);
        lendingApp.createRecords();
       
    }

    /*
     * Method to get pricing for application
     */
     @AuraEnabled
    public static String getDNLPricing(Id pOpportunityId){
        String retMsg;
        List<Opportunity> oppList = [SELECT ID
                                          , Name
                                          , CloseDate
                                          , Amount
                                          , Applicant_State__c
                                      FROM Opportunity
                                     WHERE id = :pOpportunityId];      

        if (oppList == null){
            retMsg = 'Invalid Opportunity, please check and try again.';
        }                                     
        Opportunity opp = oppList[0];

        Map<Id, fsCore__Pricing_Setup__c> pricingMap = new Map<Id, fsCore__Pricing_Setup__c>();

        fsCore__Lending_Application__c application = new fsCore__Lending_Application__c();

        if (SFS_System_Settings__c.getInstance().Default_Branch_ID_DNL__c != null){
          application.fsCore__Branch_Name__c = Id.valueOf(SFS_System_Settings__c.getInstance().Default_Branch_ID_DNL__c);
        }
        
        if (SFS_System_Settings__c.getInstance().Default_Product_ID_DNL__c != null){
          application.fsCore__Product_Name__c = Id.valueOf(SFS_System_Settings__c.getInstance().Default_Product_ID_DNL__c);
        }
        if (SFS_System_Settings__c.getInstance().Default_Company_ID_DNL__c != null){
          application.fsCore__Company_Name__c = Id.valueOf(SFS_System_Settings__c.getInstance().Default_Company_ID_DNL__c);
        }        
        application.fsCore__Application_Date__c = opp.CloseDate; 
        application.fsCore__Product_Family__c = fsCore.Constants.PRODUCT_FAMILY_LOAN;
        application.fsCore__State__c = opp.Applicant_State__c;

        List<SelectOption> pricingSelectList = fsCore.SpectraCoreUtil.getBlankList();
        List<fsCore__Pricing_Setup__c> availablePricingList = new List<fsCore__Pricing_Setup__c>();
        List<fsCore__Fee_Setup__c> availableFeeList = new List<fsCore__Fee_Setup__c>();
        List<fsCore__Fee_Setup__c> availableOriginationFeeList = new List<fsCore__Fee_Setup__c>();
        
        if (application.fsCore__Branch_Name__c != null 
            && application.fsCore__Application_Date__c != null 
            && application.fsCore__State__c != null 
            && application.fsCore__Company_Name__c != null 
            && String.IsNotBlank(application.fsCore__Product_Family__c)){
            String applUniqueKey = String.valueOf(fsCore.SpectraCoreUtil.getRandomInteger());
            fsCore.MappingEvaluationInputObject applMappEvalObj = fsCore.LendingApplicationUtil.getMappingEvalInput(application);
        
            System.debug(loggingLevel.ERROR, 'Mapping Input Object : ' + applMappEvalObj);
            System.debug(loggingLevel.ERROR, 'Product Family : ' + application.fsCore__Product_Family__c);
            
            Map<String, fsCore.MappingEvaluationInputObject> mappingEvalInputMap = new Map<String, fsCore.MappingEvaluationInputObject>();
            mappingEvalInputMap.put(applUniqueKey, applMappEvalObj);
            
            fsCore.SetupMappingEvaluator pricingSetupMappEval = new fsCore.SetupMappingEvaluator(mappingEvalInputMap
                                                                                 , Schema.SObjectType.fsCore__Pricing_Setup__c.getName()
                                                                                 , application.fsCore__Product_Family__c);
                                                                                 
            Set<Id> availablePricingIdSet = pricingSetupMappEval.evaluate().get(applUniqueKey);
            availablePricingList = (List<fsCore__Pricing_Setup__c>)pricingSetupMappEval.getSetupRecords(availablePricingIdSet);



            fsCore.SetupMappingEvaluator feeSetupMappEval = new fsCore.SetupMappingEvaluator(mappingEvalInputMap
                                                                                 , Schema.SObjectType.fsCore__Fee_Setup__c.getName()
                                                                                 , application.fsCore__Product_Family__c);
                                                                                 
            Set<Id> availableFeeIdSet = feeSetupMappEval.evaluate().get(applUniqueKey);
            availableFeeList = (List<fsCore__Fee_Setup__c>)feeSetupMappEval.getSetupRecords(availableFeeIdSet);
            for (fsCore__fee_Setup__c fee : availableFeeList){
                if (fee.fsCore__Fee_Category__c == 'Origination Fee'){
                  availableOriginationFeeList.add(fee);
                }
            }  


        }else{
            if (application.fsCore__Application_Date__c == null){
                retMsg = 'Close Date/Application Date must be entered to get the pricing.';
            }else if (application.fsCore__State__c == null){
                retMsg = 'Applicant State must be entered to get the pricing.';
            }else{
                retMsg = 'Please check the SFS system custom settings for defaul DNL product or Default DNL branch ID or Default DNL Company Id.';
            }

        }

        fsCore.ActionOutput actionOutput = new fsCore.ActionOutput();
        if (retMsg == null){
            if(availablePricingList != null && !availablePricingList.isEmpty()){
              retMsg = 'Rate: '+ availablePricingList[0].fsCore__Rate_Value__c;
              actionOutput.setIsSuccess(true);
              actionOutput.setMessage(retMsg);
            }else{
              retMsg = 'No Pricing Found for the application date and state combination.';
              actionOutput.setIsSuccess(false);
              actionOutput.addError(retMsg);
            }
            logmessage('Is Sucesss:  '+actionOutput.getIsSuccess());
            if (actionOutput.getIsSuccess()){
              if(availableOriginationFeeList != null && !availableOriginationFeeList.isEmpty()){
                  retMsg += '\n'+ 'Origination Fee(%): '+availableOriginationFeeList[0].fsCore__Calculation_Percent_Default__c+'%';
                  if (opp.Amount != null && opp.Amount > 0){
                    retMsg += '\n'+ 'Origination Fee($): '+fsCore.FinancialUtil.round(availableOriginationFeeList[0].fsCore__Calculation_Percent_Default__c*(Opp.Amount/100), 2, System.RoundingMode.HALF_EVEN);
                  }
              }else{
                retMsg += '\n Origination Fee: Not Applicable.';
              }
              actionOutput.setMessage(retMsg);
            }

        }else{
            actionOutput.setIsSuccess(false);
            actionOutput.addError(retMsg);
        }

        //actionOutput.setMessageDetails();
        system.debug(logginglevel.error,' JSON :'+actionOutput.getJSONString());
        return actionOutput.getJSONString();        
        

    }

    private static void logmessage(Object pMessage){
        system.debug(logginglevel.error, pMessage);
    }      

    /*
     * Method to get pricing for application
     */
    
    /*@AuraEnabled
    public static String getDNLPricing(Id pOpportunityId){
        String retMsg;
        List<Opportunity> oppList = [SELECT ID
                                          , Name
                                          , CloseDate
                                          , Applicant_State__c
                                      FROM Opportunity
                                     WHERE id = :pOpportunityId];
        if (oppList.size()== 0){
            retMsg = 'Invalid Opportunity, please check and try again.';
        }
        Opportunity opp = oppList[0];
        if (opp.CloseDate == null){
            retMsg = 'Close Date/Application Date must be entered to get the pricing.';
        }
        if (opp.Applicant_State__c == null){
            retMsg = 'Applicant State must be entered to get the pricing.';
        }
        
       MAP<ID,fsCore__User_Parameter_Setup__c>  userParamMap =  new Map<id, fsCore__User_Parameter_Setup__c>([SELECT id
                                                                           , name 
                                                                        FROM fsCore__User_Parameter_Setup__c 
                                                                       WHERE fsCore__Is_Active__c = true
                                                                         AND fsCore__Line_Of_Business__c = 'Origination'
                                                                         AND fsCore__Field_API_Name__c ='fscore__state__c']);

        MAP<ID,fsCore__Pricing_Setup__c> pricingMap = new Map<id, fsCore__Pricing_Setup__c>([SELECT id
                                                           , name 
                                                           , fsCore__Rate_Value__c
                                                           , fsCore__Default_Selection_Rule_Result__c
                                                           , fsCore__Default_Company_Availability__c
                                                           , fsCore__Default_Product_Availability__c
                                                           , (SELECT id
                                                                   , name
                                                                   , fsCore__Selection_Rule_Name__c
                                                                from fsCore__Selection_Rule_Mapping_Setup__r
                                                               WHERE fsCore__Is_Active__c = true)
                                                        FROM fsCore__Pricing_Setup__c 
                                                       WHERE fsCore__Is_Active__c = true 
                                                         AND fsCore__Start_Date__c <= :opp.CloseDate
                                                         AND fsCore__End_Date__c > :opp.CloseDate]);

        if (pricingMap.size() == 0){
            retMsg = 'No active pricing found for the application date.';
        }

        MAP<Id,List<fsCore__Pricing_Setup__c>>finalPricingMap = new Map<Id,List<fsCore__Pricing_Setup__c>>() ;

        MAP<Id,List<fsCore__Selection_Rule_Mapping_Setup__c>>defNotAvailablePricingMap = new Map<Id,List<fsCore__Selection_Rule_Mapping_Setup__c>>() ;
        
        List<fsCore__Pricing_Setup__c> defaultAvailablePricingList= new List<fsCore__Pricing_Setup__c>();

        Set<ID> selectionRuleIds = new Set<ID>();
        for(fsCore__Pricing_Setup__c pricing : pricingMap.Values()){
            if ((pricing.fsCore__Default_Selection_Rule_Result__c == fsCore.Constants.MAPPING_AVAILABLE)
                    &&(pricing.fsCore__Default_Company_Availability__c== fsCore.Constants.MAPPING_AVAILABLE)
                    &&(pricing.fsCore__Default_Company_Availability__c== fsCore.Constants.MAPPING_AVAILABLE)){
                defaultAvailablePricingList.add(pricing);
            }else{
                defNotAvailablePricingMap.put(pricing.Id,pricing.fsCore__Selection_Rule_Mapping_Setup__r);
                for (fsCore__Selection_Rule_Mapping_Setup__c sr: pricing.fsCore__Selection_Rule_Mapping_Setup__r){
                    selectionRuleIds.add(sr.fsCore__Selection_Rule_Name__c);
                }
            }

        }
        addTothePricingMap(pOpportunityId,finalPricingMap,defaultAvailablePricingList);
    

        MAP<ID,fsCore__Rule_Setup__c> ruleMap =  new Map<id, fsCore__Rule_Setup__c>([SELECT id
                                                    , name 
                                                    , (SELECT id
                                                            , name
                                                            , fsCore__Parameter_Name__c
                                                            , fsCore__String_Value__c
                                                            , fsCore__Operator__c
                                                         from fsCore__Condition_Setup__r)
                                                    FROM fsCore__Rule_Setup__c 
                                                   WHERE fsCore__Is_Active__c = true 
                                                     AND fsCore__Rule_Type__c = 'Selection Rule'
                                                     AND fsCore__Line_Of_Business__c ='Origination'
                                                     AND ID in :selectionRuleIds]);
        system.debug(logginglevel.error,' opp.Applicant_State__c :'+opp.Applicant_State__c);
        String pricingName;
        List<fsCore__Pricing_Setup__c> defaultNotAvailablePricingList= new List<fsCore__Pricing_Setup__c>();
        for(Id pricingId : defNotAvailablePricingMap.keySet()){
            if (defNotAvailablePricingMap.get(pricingId) != null){
                for (fsCore__Selection_Rule_Mapping_Setup__c sr: defNotAvailablePricingMap.get(pricingId)){
                        if (ruleMap.get(sr.fsCore__Selection_Rule_Name__c) != null){
                            if (ruleMap.get(sr.fsCore__Selection_Rule_Name__c).fsCore__Condition_Setup__r != null){
                                for (fsCore__Condition_Setup__c cond: ruleMap.get(sr.fsCore__Selection_Rule_Name__c).fsCore__Condition_Setup__r){
                                    if (userParamMap.get(cond.fsCore__Parameter_Name__c) != null){
                                        if ((cond.fsCore__Operator__c == 'equals to')
                                            &&(cond.fsCore__String_Value__c == opp.Applicant_State__c)){
                                            system.debug(logginglevel.error,' Pricing Found !!!! : '+pricingMap.get(pricingId).Name);
                                            pricingName = 'Pricing Name: '+ pricingMap.get(pricingId).Name;
                                            defaultNotAvailablePricingList.add(pricingMap.get(pricingId));
                                        }
                                    }
                                }
                            }
                        }
                }
            }
        }
        addTothePricingMap(pOpportunityId,finalPricingMap,defaultNotAvailablePricingList);

        List<fsCore__Pricing_Setup__c> finalPricingList = finalPricingMap.get(pOpportunityId);

        if (finalPricingList == null || finalPricingList.isEmpty()){
            if (retMsg == null){
                retMsg = 'No active pricing found for the application date & State, contact administrator.';
            }
        }else if (finalPricingList.size() > 1){
            if (retMsg == null){
                retMsg = 'Multiple active pricings found for the application date & State, contact administrator.';
            }
        }
        fsCore.ActionOutput actionOutput = new fsCore.ActionOutput();
        if (retMsg == null){
            retMsg = 'Available Rate: '+ finalPricingList[0].fsCore__Rate_Value__c;
            actionOutput.setIsSuccess(true);
            actionOutput.setMessage(retMsg);
        }else{
            actionOutput.setIsSuccess(false);
            actionOutput.addError(retMsg);
        }

        //actionOutput.setMessageDetails();
        system.debug(logginglevel.error,' JSON :'+actionOutput.getJSONString());
        return actionOutput.getJSONString();
    }*/




    private static MAP <Id,List<fsCore__Pricing_Setup__c>> addTothePricingMap(Id pOpportunityId
                                                                      ,MAP<Id,List<fsCore__Pricing_Setup__c>>pAvailablePricingMap
                                                                      ,List<fsCore__Pricing_Setup__c> pDefaultAvailablePricingList){
        if (pDefaultAvailablePricingList.size()== 0){
            return pAvailablePricingMap;
        }
        if ((pDefaultAvailablePricingList.size()>0)
            && (pAvailablePricingMap.size() == 0)){
            pAvailablePricingMap.put(pOpportunityId,pDefaultAvailablePricingList);
            return pAvailablePricingMap;
        }
        List<fsCore__Pricing_Setup__c> availablePricingList = pAvailablePricingMap.get(pOpportunityId);
        availablePricingList.addAll(pDefaultAvailablePricingList);
        pAvailablePricingMap.put(pOpportunityId,availablePricingList);
        return pAvailablePricingMap;


    }

}