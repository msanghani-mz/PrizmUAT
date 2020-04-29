/*
* Class Name   - RejectionActionController
* Description  - 
* Developer(s) - Financial Spectra
*/
public class RejectionActionController {
    
    /*
* Method to get RejectionWrapper for the Lending Application
* when the rejectApplication lightning action is loaded
*/
    @AuraEnabled
    public static RejectionWrapper getRejectionWrapper(Id pApplicationId){
        return refreshRejectionWrapper(pApplicationId,null);
    }
    
    /*
* Method to refresh the RejectionWrapper for the Lending Application
* when the Rejection Cause is changed in the rejectApplication lightning action
*/
    @AuraEnabled
    public static RejectionWrapper refreshRejectionWrapper(Id pApplicationId, String pRejectionWrpJSON){
        System.debug(loggingLevel.ERROR, '-- Rejection Wrapper : ' + pRejectionWrpJSON);
        
        //fetch application and populate the value set for Rejection Cause
        fsCore__Lending_Application__c application = [SELECT Id, fsCore__Product_Name__c
                                                      , Rejection_Cause__c
                                                      , Credit_Bureau_Used__c
                                                      , Internal_Rejection_Reason_Codes__c 
                                                      , External_Rejection_Reason_Codes__c
                                                      , Rejection_Comments__c
                                                      FROM fsCore__Lending_Application__c 
                                                      WHERE Id = :pApplicationId];
        
        RejectionWrapper rejectionWrp;
        if (String.IsBlank(pRejectionWrpJSON)){
            rejectionWrp = new RejectionWrapper();
            setRejectionCauseField(rejectionWrp, application.Rejection_Cause__c);
			rejectionWrp.internalReasonCodes = new List<String>();
			rejectionWrp.externalReasonCodes = new List<String>();
        } 
        else {
            rejectionWrp = (RejectionWrapper)JSON.deserialize(pRejectionWrpJSON, RejectionWrapper.class);
        }
        
        
        rejectionWrp.internalReasonValueSet = new List<LabelValueType>();
        rejectionWrp.internalReasonsLabel = fsCore__Lending_Application__c.Internal_Rejection_Reasons__c.getDescribe().getLabel();
        
        
        rejectionWrp.externalReasonValueSet = new List<LabelValueType>();
        rejectionWrp.externalReasonsLabel = fsCore__Lending_Application__c.External_Rejection_Reasons__c.getDescribe().getLabel();
        
        rejectionWrp.isShowCreditBureau = false;
        
        if (rejectionWrp.rejectionCauses != null && rejectionWrp.rejectionCauses.size()>0){
            setRejectionReasons(rejectionWrp, application.fsCore__Product_Name__c);
            
			Set<String> internalCodesSet = getReasonCodes(rejectionWrp.internalReasonValueSet);
			List<String> selectedInternalReasons = new List<String>();
			Set<String> externalCodesSet = getReasonCodes(rejectionWrp.externalReasonValueSet);
			List<String> selectedExternalReasons = new List<String>();
			
			
			if(rejectionWrp.internalReasonCodes != null && rejectionWrp.internalReasonCodes.size()>0){
				for(String intReasonCode : rejectionWrp.internalReasonCodes){
					if(internalCodesSet.contains(intReasonCode)){
						selectedInternalReasons.add(intReasonCode);
					}
				}	
			}
			
            if (String.IsNotBlank(application.Internal_Rejection_Reason_Codes__c)){ 
                for (String reasonCode : application.Internal_Rejection_Reason_Codes__c.split(fsCore.Constants.SEMI_COLON)){
                    if (internalCodesSet.contains(reasonCode)){
                        selectedInternalReasons.add(reasonCode);
                    }
                }
            }
			
			if(rejectionWrp.externalReasonCodes != null && rejectionWrp.externalReasonCodes.size()>0){
				for(String extReasonCode : rejectionWrp.externalReasonCodes){
					if(externalCodesSet.contains(extReasonCode)){
						selectedExternalReasons.add(extReasonCode);
					}
				}	
			}
            
            if (String.IsNotBlank(application.External_Rejection_Reason_Codes__c)){                
                for (String reasonCode : application.External_Rejection_Reason_Codes__c.split(fsCore.Constants.SEMI_COLON)){
                    if (externalCodesSet.contains(reasonCode)){
                        selectedExternalReasons.add(reasonCode);
                    }
                }
            }
            
			rejectionWrp.internalReasonCodes = selectedInternalReasons;
			rejectionWrp.externalReasonCodes = selectedExternalReasons;
			
            rejectionWrp.isShowCreditBureau = (rejectionWrp.rejectionCauses.contains('Credit Report'));
            if (rejectionWrp.isShowCreditBureau){
                setCreditBureauField(rejectionWrp, application.Credit_Bureau_Used__c);
            }
        }
        
		
        rejectionWrp.hasInternalReasons = (rejectionWrp.internalReasonValueSet.size() > 0);
        rejectionWrp.hasExternalReasons = (rejectionWrp.externalReasonValueSet.size() > 0);
        
        setCommentsField(rejectionWrp, application.Rejection_Comments__c);
        
        return rejectionWrp;
    }
    
    private static void setRejectionCauseField(RejectionWrapper pRejectionWrp, String pRejectionCause){
        pRejectionWrp.rejectionCause.value = (String.IsBlank(pRejectionCause) ? fsCore.Constants.BLANK_STRING : pRejectionCause);
        
        Schema.DescribeFieldResult rejectCauseFieldDesc = fsCore__Lookup_Value__c.Rejection_Cause__c.getDescribe();
        pRejectionWrp.rejectionCause.label = rejectCauseFieldDesc.getLabel();
        pRejectionWrp.rejectionCauseValueSet = new List<LabelValueType>();
        
        //pRejectionWrp.rejectionCauseValueSet.add(new LabelValueType('-- None --', fsCore.Constants.BLANK_STRING));
        for (Schema.PicklistEntry rejectCause : rejectCauseFieldDesc.getPicklistValues()){
            if (rejectCause.isActive()){
                pRejectionWrp.rejectionCauseValueSet.add(new LabelValueType(rejectCause.getLabel(), rejectCause.getValue()));
            }
        }
    }
    
    private static void setCreditBureauField(RejectionWrapper pRejectionWrp, String pCreditBureauUsed){
        pRejectionWrp.creditBureau.value = (String.IsBlank(pCreditBureauUsed) ? 'Equifax' : pCreditBureauUsed);
        
        Schema.DescribeFieldResult creditBureauFieldDesc = fsCore__Lending_Application__c.Credit_Bureau_Used__c.getDescribe();
        pRejectionWrp.creditBureau.label = creditBureauFieldDesc.getLabel();
        pRejectionWrp.creditBureauValueSet = new List<LabelValueType>();
        
        for (Schema.PicklistEntry creditBureau : creditBureauFieldDesc.getPicklistValues()){
            if (creditBureau.isActive()){
                pRejectionWrp.creditBureauValueSet.add(new LabelValueType(creditBureau.getLabel(), creditBureau.getValue()));
            }
        }
    }
    
    private static void setCommentsField(RejectionWrapper pRejectionWrp, String pComments){
        pRejectionWrp.comments.value = (String.IsBlank(pComments) ? fsCore.Constants.BLANK_STRING : pComments);
        pRejectionWrp.comments.label = fsCore__Lending_Application__c.Rejection_Comments__c.getDescribe().getLabel();
    }
    
    private static void setRejectionReasons(RejectionWrapper pRejectionWrp, Id pProductId){
        //populate list with reject reasons related to the rejection cause
        List<fsCore__Lookup_Value__c> rejectionReasonsRelatedToCause = new List<fsCore__Lookup_Value__c>();
        
        Set<String> selectedCauses = new Set<String>(pRejectionWrp.rejectionCauses);
        if(selectedCauses.size()>0){
            for (fsCore__Lookup_Value__c rejectReasonLkp : getRejectionReasons()){
                if (selectedCauses.contains(rejectReasonLkp.Rejection_Cause__c)) 
                {
                    rejectionReasonsRelatedToCause.add(rejectReasonLkp);
                }
            }
        }
        
        System.debug(loggingLevel.ERROR, '-- Rejection Reasons for Cause : ' + rejectionReasonsRelatedToCause);
        
        //get available reject reasons
        List<fsCore__Lookup_Value__c> availableRejectReasons 
            = fsCore.LookupValueUtil.getAvailableLookupValues(rejectionReasonsRelatedToCause, pProductId);
        System.debug(loggingLevel.ERROR, '-- Available Rejection Reasons : ' + availableRejectReasons);
        
        //prepare reason lists
        pRejectionWrp.internalReasonValueSet = new List<LabelValueType>();
        pRejectionWrp.externalReasonValueSet = new List<LabelValueType>();
        
        for (fsCore__Lookup_Value__c rejectReason : availableRejectReasons){
            LabelValueType reason = new LabelValueType();
            reason.value = rejectReason.Name;
            reason.label = rejectReason.fsCore__Lookup_Name__c + ' (' + rejectReason.Rejection_Cause__c + ')';
            if (rejectReason.Is_Internal__c){
                pRejectionWrp.internalReasonValueSet.add(reason);
            }
            else {
                pRejectionWrp.externalReasonValueSet.add(reason);
            }
        }
        
        System.debug(loggingLevel.ERROR, '-- Internal Reasons : ' + pRejectionWrp.internalReasonValueSet);
        System.debug(loggingLevel.ERROR, '-- External Reasons : ' + pRejectionWrp.externalReasonValueSet);
    }
    
    private static Set<String> getReasonCodes(List<LabelValueType> pReasonsValueSet){
        Set<String> reasonCodes = new Set<String>();
        for(LabelValueType reason : pReasonsValueSet){
            reasonCodes.add(reason.value);
        }
        return reasonCodes;
    }
    
    private static List<fsCore__Lookup_Value__c> getRejectionReasons(){
        List<fsCore__Lookup_Value__c> rejectionReasons = [SELECT Id, Name
                                                          , fsCore__Lookup_Name__c
                                                          , fsCore__Default_Product_Availability__c
                                                          , fsCore__Is_Active__c
                                                          , Rejection_Cause__c
                                                          , Is_Internal__c
                                                          , (SELECT Id, Name, fsCore__Lookup_Name__c
                                                             FROM fsCore__Lookup_Value__r
                                                             WHERE fsCore__Is_Active__c = true
                                                             ORDER BY fsCore__Lookup_Name__c ASC)
                                                          FROM fsCore__Lookup_Value__c
                                                          WHERE fsCore__Is_Active__c = true
                                                          AND RecordType.DeveloperName = 'Application_Rejection_Reason'
                                                          ORDER BY fsCore__Lookup_Name__c ASC];
        return rejectionReasons;
    }
    
    /*
* Method to save the rejection cause and reasons
*/
    @AuraEnabled
    public static String rejectApplication(Id pApplicationId, String pRejectionWrpJSON){
        fsCore.ActionOutput acOutput = new fsCore.ActionOutput();
        System.debug(loggingLevel.ERROR, '-- rejectApplication - Rejection Wrapper : ' + pRejectionWrpJSON);
        
        Savepoint sp = Database.setSavepoint();
        try{
            fsCore__Lending_Application__c application = [SELECT Id, fsCore__Product_Name__c
                                                          , Previous_Status__c 
                                                          , fsCore__Application_Status__c 
                                                          , Rejection_Cause__c
                                                          , Rejection_Causes__c
                                                          , Credit_Bureau_Used__c
                                                          , Internal_Rejection_Reasons__c 
                                                          , Internal_Rejection_Reason_Codes__c 
                                                          , External_Rejection_Reasons__c
                                                          , External_Rejection_Reason_Codes__c
                                                          , Rejection_Comments__c
                                                          , Loan_Type__c
                                                          FROM fsCore__Lending_Application__c 
                                                          WHERE Id = :pApplicationId];
            
            RejectionWrapper rejectionWrp;
            if (String.IsBlank(pRejectionWrpJSON)){
                throw new ApplicationRejectionException('Unable to decline the lending application. (Cause : Input JSON is blank)');
            } 
            else {
                rejectionWrp = (RejectionWrapper)JSON.deserialize(pRejectionWrpJSON, RejectionWrapper.class);
            }
            
            application.Rejection_Causes__c = String.join(rejectionWrp.rejectionCauses, fsCore.Constants.SEMI_COLON);            
            
            if (rejectionWrp.rejectionCauses != null && rejectionWrp.rejectionCauses.size()>0){
                if(application.Loan_Type__c == 'DNL'){
                    //application.fsCore__Application_Status__c = 'Pending Decline';
                    application.fsCore__Application_Status__c = 'Declined';
                    application.Application_Decline_Date__c  = Date.today();
                    application.fsCore__Is_Application_Read_Only__c = true;
                }
                if(application.Loan_Type__c == 'VCL'){
                    application.fsCore__Application_Status__c = 'Pending Decline';
                }
                
                Set<String> internalReasonCodeSet = new Set<String>();
                //set internal reasons
                if (rejectionWrp.hasInternalReasons){
                    if (rejectionWrp.internalReasonCodes.isEmpty()){
                        throw new ApplicationRejectionException(Label.No_Internal_Reason_Selected);
                    }
                    
                    internalReasonCodeSet = new Set<String>(rejectionWrp.internalReasonCodes);
                    
                    List<String> internalReasonLabels = new List<String>();
                    for (LabelValueType reason : rejectionWrp.internalReasonValueSet){
                        if (internalReasonCodeSet.contains(reason.value)){
                            internalReasonLabels.add(reason.label);
                        }
                    }
                    
                    application.Internal_Rejection_Reasons__c = String.join(internalReasonLabels, fsCore.Constants.SEMI_COLON);
                    application.Internal_Rejection_Reason_Codes__c = String.join(rejectionWrp.internalReasonCodes, fsCore.Constants.SEMI_COLON);
                }
                
                List<fsCore__Lookup_Value__c> externalReasonList = [SELECT id
                                                                    , name 
                                                                    , External_Rejection_Reasons__c
                                                                    FROM fsCore__Lookup_Value__c 
                                                                    WHERE Name IN :internalReasonCodeSet];
                
                
                List<String> externalReasonLabels = new List<String>();
                for (fsCore__Lookup_Value__c reason : externalReasonList){
                    externalReasonLabels.add(reason.External_Rejection_Reasons__c);
                }
                
                application.External_Rejection_Reasons__c = String.join(externalReasonLabels, fsCore.Constants.SEMI_COLON);
                //set external reasons
                /*if (rejectionWrp.hasExternalReasons){
if (rejectionWrp.externalReasonCodes.isEmpty()){
throw new ApplicationRejectionException(Label.No_External_Reason_Selected);
}

Set<String> externalReasonCodeSet = new Set<String>(rejectionWrp.externalReasonCodes);

List<String> externalReasonLabels = new List<String>();
for (LabelValueType reason : rejectionWrp.externalReasonValueSet){
if (externalReasonCodeSet.contains(reason.value)){
externalReasonLabels.add(reason.label);
}
}

application.External_Rejection_Reasons__c = String.join(externalReasonLabels, fsCore.Constants.SEMI_COLON);
application.External_Rejection_Reason_Codes__c = String.join(rejectionWrp.externalReasonCodes, fsCore.Constants.SEMI_COLON);
}*/
                
                //Set rich-text field with both internal and external reasons
                application.Rejection_Reasons__c = '<p><strong>Internal Reason(s)</strong></p>';
                application.Rejection_Reasons__c += '<ul>';
                if (application.Internal_Rejection_Reasons__c != null){
                    for (String inReason : application.Internal_Rejection_Reasons__c.split(fsCore.Constants.SEMI_COLON)){
                        application.Rejection_Reasons__c += ('<li>' + inReason + '</li>');
                    }
                }
                application.Rejection_Reasons__c += '</ul><br/>';
                application.Rejection_Reasons__c += '<p><strong>External Reason(s)</strong></p>';
                application.Rejection_Reasons__c += '<ul>';
                if (application.External_Rejection_Reasons__c != null){
                    for (String exReason : application.External_Rejection_Reasons__c.split(fsCore.Constants.SEMI_COLON)){
                        application.Rejection_Reasons__c += ('<li>' + exReason + '</li>');
                    }
                }
                application.Rejection_Reasons__c += '</ul>';
                
                //credit bureau
                if (rejectionWrp.rejectionCauses.contains('Credit Report') && String.isBlank(rejectionWrp.creditBureau.value)){
                    throw new ApplicationRejectionException(Label.No_Credit_Bureau_Selected);
                } 
                if (rejectionWrp.rejectionCauses.contains('Credit Report')){
                    application.Credit_Bureau_Used__c = rejectionWrp.creditBureau.value;
                }
            }
            else {
                application.Rejection_Reasons__c = fsCore.Constants.BLANK_STRING;
                application.Internal_Rejection_Reasons__c = fsCore.Constants.BLANK_STRING;
                application.Internal_Rejection_Reason_Codes__c = fsCore.Constants.BLANK_STRING;
                application.External_Rejection_Reasons__c = fsCore.Constants.BLANK_STRING;
                application.External_Rejection_Reason_Codes__c = fsCore.Constants.BLANK_STRING;
                application.Credit_Bureau_Used__c = fsCore.Constants.BLANK_STRING;
            }
            
            application.Rejection_Comments__c = rejectionWrp.comments.value;
            fsCore.DMLResult appSaveResult = fsCore.LendingApplicationDMLWrapper.getInstance().updateData(application);
            if (appSaveResult.hasErrors()){ acOutput.addErrors(appSaveResult.getErrorList()); }
        } 
        catch (Exception e){
            system.debug(logginglevel.error,' EXCEP :'+e);
            acOutput.addError(e);
        }
        
        if (!acOutput.getIsSuccess()){
            Database.rollback(sp);            
        } else {
            acOutput.setMessage('Success!');
            acOutput.setMessageDetails('Decline cause and reason(s) have been updated successfully.');
        }
        
        return acOutput.getJSONString();
    }
    
    public class ApplicationRejectionException extends Exception{}
    
}