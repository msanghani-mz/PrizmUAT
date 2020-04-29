/*
* Copyright (c) 2017-2019 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class        - SocureIDPlusResponseHandler
*
* Description  - Mock Socure ID+ Response Handler class
*
* Developer(s) - Aniket Singh
*
*/
global class SocureIDPlusResponseHandler implements fsCore.WebServiceResponseHandler {
    private HttpResponse  mHttpResponse;
    List<SObject> mRecords;
    global void setResponse(HttpResponse pResponse){
        system.debug(logginglevel.error,'Response');
        mHttpResponse = pResponse;
        
    }
    global void setRecords(List<SObject> pRecords){
        mRecords = pRecords;
        system.debug(logginglevel.error,'pRecords :'+pRecords);
    }
    
    global Object getOutput(){
        return null;
    }
    global void process(){
        system.debug(logginglevel.error,'Response :'+mHttpResponse);
        system.debug(logginglevel.error,'Response Body :'+mHttpResponse.getBody());
        Id applicantId = ((fsCore__Lending_Application_Customer__c)mRecords[0]).Id; 
        fsCore__Lending_Application_Customer__c applicant = [Select id , fsCore__Lending_Application_Number__c, 
                                                             fsCore__Lending_Application_Number__r.Name,
                                                             fsCore__Lending_Application_Number__r.OwnerId,
                                                             fsCore__Lending_Application_Number__r.fsCore__Title__c,
                                                             fsCore__Lending_Application_Number__r.Max_Fraud_Score__c
                                                             from fsCore__Lending_Application_Customer__c
                                                             where id = :applicantId];
        System.debug(logginglevel.error,applicant);
        Id applicationId = applicant.fsCore__Lending_Application_Number__c;
        String applicationNum = applicant.fsCore__Lending_Application_Number__r.Name;
        fsCore__Lending_Application__c application = applicant.fsCore__Lending_Application_Number__r;
        Decimal maxFraudScore;
        if(applicant.fsCore__Lending_Application_Number__r.Max_Fraud_Score__c != null){
            maxFraudScore = applicant.fsCore__Lending_Application_Number__r.Max_Fraud_Score__c;
        }
        if(mHttpResponse.getStatusCode()== 200){
            fsSocr.SocureIDPlusSchema.Response res = (fsSocr.SocureIDPlusSchema.Response)System.JSON.deserialize(mHttpResponse.getBody(),fsSocr.SocureIDPlusSchema.Response.class);
            //Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(mHttpResponse.getBody());
            //String referenceId = (String) responseMap.get('referenceId');
            
            
            
            List<Lending_Application_Fraud_Flag__c> flagList = new List<Lending_Application_Fraud_Flag__c>();
            
            system.debug(logginglevel.error,res.referenceId);
            system.debug(logginglevel.error,res.kyc);
            system.debug(logginglevel.error,res.fraud);
            
            List<Fraud_Flag_Setup__c> flagSetupList = [Select id , Fraud_Flag_Code__c from Fraud_Flag_Setup__c];
            Map<String,Fraud_Flag_Setup__c> flagSetupMap = new Map<String,Fraud_Flag_Setup__c>();
            
            
            for (Fraud_Flag_Setup__c flagSetup : flagSetupList) {
                flagSetupMap.put(flagSetup.Fraud_Flag_Code__c,flagSetup);
            }
            
            
            if(res.addressRisk != null){
                Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
                
                flag.Fraud_Flag_Name__c = flagSetupMap.get('ADDRESS_RISK').id;
                //flag.Reason_Codes__c = getCommaSeparatedString(res.addressRisk.reasonCodes);
                List<fsSocr__Socure_Reason_Code__mdt> socureMetadataList = [Select id , fsSocr__Description__c,
                                                                            MasterLabel,fsSocr__Type__c
                                                                            from fsSocr__Socure_Reason_Code__mdt
                                                                            where MasterLabel in :res.addressRisk.reasonCodes];
                
                List<String> riskCodes = new List<String>();                                                        
                List<String> riskCodeDescription = new List<String>();
                List<String> informationCodes = new List<String>();
                List<String> informationCodeDescription = new List<String>();
                // List<String> descriptionList = new List<String>();
                if(socureMetadataList.size()>0){
                    for(fsSocr__Socure_Reason_Code__mdt metaData : socureMetadataList){ 
                        if(metaData.fsSocr__Type__c == 'Risk'){
                            riskCodeDescription.add(metaData.fsSocr__Description__c);
                            riskCodes.add(metaData.MasterLabel);
                        }
                        if(metaData.fsSocr__Type__c == 'Information'){
                            informationCodeDescription.add(metaData.fsSocr__Description__c);
                            informationCodes.add(metaData.MasterLabel);
                        }
                        // descriptionList.add(metaData.fsSocr__Description__c);
                    }
                    // flag.Reason_Code_Description__c = getCommaSeparatedReasonCodeDescription(descriptionList);
                }
                if(riskCodes.size()>0){
                    flag.Risk_Codes__c = getCommaSeparatedString(riskCodes);  
                    flag.Risk_Codes_Description__c = getCommaSeparatedReasonCodeDescription(riskCodeDescription);
                }
                if(informationCodes.size()>0){
                    flag.Informational_Codes__c = getCommaSeparatedString(informationCodes);
                    flag.Informational_Codes_Description__c = getCommaSeparatedReasonCodeDescription(informationCodeDescription);
                }
                flag.Score__c = res.addressRisk.score;
                flagList.add(flag);
                system.debug(logginglevel.error,'1'+flag);
            }
            if(res.phoneRisk != null){
                Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();            
                flag.Fraud_Flag_Name__c = flagSetupMap.get('PHONE_RISK').id;
                //flag.Reason_Codes__c = getCommaSeparatedString(res.phoneRisk.reasonCodes);
                List<fsSocr__Socure_Reason_Code__mdt> socureMetadataList = [Select id , fsSocr__Description__c,
                                                                            MasterLabel,fsSocr__Type__c
                                                                            from fsSocr__Socure_Reason_Code__mdt
                                                                            where MasterLabel in :res.phoneRisk.reasonCodes];
                List<String> riskCodes = new List<String>();                                                        
                List<String> riskCodeDescription = new List<String>();
                List<String> informationCodes = new List<String>();
                List<String> informationCodeDescription = new List<String>();
                //List<String> descriptionList = new List<String>();
                if(socureMetadataList.size()>0){
                    for(fsSocr__Socure_Reason_Code__mdt metaData : socureMetadataList){ 
                        if(metaData.fsSocr__Type__c == 'Risk'){
                            riskCodeDescription.add(metaData.fsSocr__Description__c);
                            riskCodes.add(metaData.MasterLabel);
                        }
                        if(metaData.fsSocr__Type__c == 'Information'){
                            informationCodeDescription.add(metaData.fsSocr__Description__c);
                            informationCodes.add(metaData.MasterLabel);
                        }
                        //descriptionList.add(metaData.fsSocr__Description__c);
                    }
                    //flag.Reason_Code_Description__c = getCommaSeparatedReasonCodeDescription(descriptionList);
                }
                if(riskCodes.size()>0){
                    flag.Risk_Codes__c = getCommaSeparatedString(riskCodes);  
                    flag.Risk_Codes_Description__c = getCommaSeparatedReasonCodeDescription(riskCodeDescription);
                }
                if(informationCodes.size()>0){
                    flag.Informational_Codes__c = getCommaSeparatedString(informationCodes);
                    flag.Informational_Codes_Description__c = getCommaSeparatedReasonCodeDescription(informationCodeDescription);
                }
                flag.Score__c = res.phoneRisk.score;
                flagList.add(flag);
                system.debug(logginglevel.error,'2'+flag);
            }
            if(res.emailRisk != null){
                Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
                flag.Fraud_Flag_Name__c = flagSetupMap.get('EMAIL_RISK').id;
                //flag.Reason_Codes__c = getCommaSeparatedString(res.emailRisk.reasonCodes);
                List<fsSocr__Socure_Reason_Code__mdt> socureMetadataList = [Select id , fsSocr__Description__c,
                                                                            MasterLabel,fsSocr__Type__c
                                                                            from fsSocr__Socure_Reason_Code__mdt
                                                                            where MasterLabel in :res.emailRisk.reasonCodes];
                List<String> riskCodes = new List<String>();                                                        
                List<String> riskCodeDescription = new List<String>();
                List<String> informationCodes = new List<String>();
                List<String> informationCodeDescription = new List<String>();
                //List<String> descriptionList = new List<String>();
                if(socureMetadataList.size()>0){
                    for(fsSocr__Socure_Reason_Code__mdt metaData : socureMetadataList){ 
                        if(metaData.fsSocr__Type__c == 'Risk'){
                            riskCodeDescription.add(metaData.fsSocr__Description__c);
                            riskCodes.add(metaData.MasterLabel);
                        }
                        if(metaData.fsSocr__Type__c == 'Information'){
                            informationCodeDescription.add(metaData.fsSocr__Description__c);
                            informationCodes.add(metaData.MasterLabel);
                        }
                        //descriptionList.add(metaData.fsSocr__Description__c);
                    }
                    //flag.Reason_Code_Description__c = getCommaSeparatedReasonCodeDescription(descriptionList);
                }
                if(riskCodes.size()>0){
                    flag.Risk_Codes__c = getCommaSeparatedString(riskCodes);  
                    flag.Risk_Codes_Description__c = getCommaSeparatedReasonCodeDescription(riskCodeDescription);
                }
                if(informationCodes.size()>0){
                    flag.Informational_Codes__c = getCommaSeparatedString(informationCodes);
                    flag.Informational_Codes_Description__c = getCommaSeparatedReasonCodeDescription(informationCodeDescription);
                }
                flag.Score__c = res.emailRisk.score;
                flagList.add(flag);
                system.debug(logginglevel.error,'3'+flag);
            }
            if(res.alertList != null){
                Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
                flag.Fraud_Flag_Name__c = flagSetupMap.get('ALERT_LIST').id;
                //flag.Reason_Codes__c = getCommaSeparatedString(res.alertList.reasonCodes);
                List<fsSocr__Socure_Reason_Code__mdt> socureMetadataList = [Select id , fsSocr__Description__c,
                                                                            MasterLabel,fsSocr__Type__c
                                                                            from fsSocr__Socure_Reason_Code__mdt
                                                                            where MasterLabel in :res.alertList.reasonCodes];
                List<String> riskCodes = new List<String>();                                                        
                List<String> riskCodeDescription = new List<String>();
                List<String> informationCodes = new List<String>();
                List<String> informationCodeDescription = new List<String>();
                //List<String> descriptionList = new List<String>();
                if(socureMetadataList.size()>0){
                    for(fsSocr__Socure_Reason_Code__mdt metaData : socureMetadataList){ 
                        if(metaData.fsSocr__Type__c == 'Risk'){
                            riskCodeDescription.add(metaData.fsSocr__Description__c);
                            riskCodes.add(metaData.MasterLabel);
                        }
                        if(metaData.fsSocr__Type__c == 'Information'){
                            informationCodeDescription.add(metaData.fsSocr__Description__c);
                            informationCodes.add(metaData.MasterLabel);
                        }
                        //descriptionList.add(metaData.fsSocr__Description__c);
                    }
                    //flag.Reason_Code_Description__c = getCommaSeparatedReasonCodeDescription(descriptionList);
                }
                if(riskCodes.size()>0){
                    flag.Risk_Codes__c = getCommaSeparatedString(riskCodes);  
                    flag.Risk_Codes_Description__c = getCommaSeparatedReasonCodeDescription(riskCodeDescription);
                }
                if(informationCodes.size()>0){
                    flag.Informational_Codes__c = getCommaSeparatedString(informationCodes);
                    flag.Informational_Codes_Description__c = getCommaSeparatedReasonCodeDescription(informationCodeDescription);
                }
                flag.Matches__c = String.valueOf(res.alertList.matches);
                flagList.add(flag);
                system.debug(logginglevel.error,'4'+flag);
            }
            if(res.fraud != null){
                Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
                flag.Fraud_Flag_Name__c = flagSetupMap.get('FRAUD').id;
                //flag.Reason_Codes__c = getCommaSeparatedString(res.fraud.reasonCodes);
                List<fsSocr__Socure_Reason_Code__mdt> socureMetadataList = [Select id , fsSocr__Description__c,
                                                                            MasterLabel,fsSocr__Type__c
                                                                            from fsSocr__Socure_Reason_Code__mdt
                                                                            where MasterLabel in :res.fraud.reasonCodes];
                List<String> riskCodes = new List<String>();                                                        
                List<String> riskCodeDescription = new List<String>();
                List<String> informationCodes = new List<String>();
                List<String> informationCodeDescription = new List<String>();
                //List<String> descriptionList = new List<String>();
                if(socureMetadataList.size()>0){
                    for(fsSocr__Socure_Reason_Code__mdt metaData : socureMetadataList){ 
                        if(metaData.fsSocr__Type__c == 'Risk'){
                            riskCodeDescription.add(metaData.fsSocr__Description__c);
                            riskCodes.add(metaData.MasterLabel);
                        }
                        if(metaData.fsSocr__Type__c == 'Information'){
                            informationCodeDescription.add(metaData.fsSocr__Description__c);
                            informationCodes.add(metaData.MasterLabel);
                        }
                        //descriptionList.add(metaData.fsSocr__Description__c);
                    }
                    //flag.Reason_Code_Description__c = getCommaSeparatedReasonCodeDescription(descriptionList);
                }
                if(riskCodes.size()>0){
                    flag.Risk_Codes__c = getCommaSeparatedString(riskCodes);  
                    flag.Risk_Codes_Description__c = getCommaSeparatedReasonCodeDescription(riskCodeDescription);
                }
                if(informationCodes.size()>0){
                    flag.Informational_Codes__c = getCommaSeparatedString(informationCodes);
                    flag.Informational_Codes_Description__c = getCommaSeparatedReasonCodeDescription(informationCodeDescription);
                }
                List<fsSocr.SocureIDPlusSchema.C_FraudScore> fraudScoreList  = res.fraud.scores;
                
                if(maxFraudScore == null){
                    maxFraudScore = fraudScoreList[0].score;
                }
                else if(maxFraudScore < fraudScoreList[0].score){
                    maxFraudScore = fraudScoreList[0].score; 
                }
                
                flag.Score__c = fraudScoreList[0].score;
                flag.Scores__c = String.valueOf(res.fraud.scores);     
                flagList.add(flag);
                system.debug(logginglevel.error,'5');
                
            }
            if(res.kyc != null){
                List<String> kycScores_1 = new List<String>{'R704','R901','R907','R909','R911','R920','R932','R940','R941','R947','R953','R955','R956','I902','I903','I904','I906'};
                    List<String> kycScores_2 = new List<String>{'I909','R903','R922','R923','R933','R939','R946','R954'};
                        Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
                flag.Fraud_Flag_Name__c = flagSetupMap.get('KYC').id;
                //flag.Reason_Codes__c = getCommaSeparatedString(res.kyc.reasonCodes);
                List<fsSocr__Socure_Reason_Code__mdt> socureMetadataList = [Select id , fsSocr__Description__c,
                                                                            fsSocr__KYC_Return_Code_Level__c, 
                                                                            MasterLabel,fsSocr__Type__c
                                                                            from fsSocr__Socure_Reason_Code__mdt
                                                                            where MasterLabel in :res.kyc.reasonCodes];
                
                // System.debug(loggingLevel.Error , socureMetadataList);
                // List<String> reasonCodeList = (List<String>)JSON.deserialize(res.kyc.reasonCodes, List<String.class>);
                List<String> kycLevel = new List<String>();
                List<String> riskCodes = new List<String>();                                                        
                List<String> riskCodeDescription = new List<String>();
                List<String> informationCodes = new List<String>();
                List<String> informationCodeDescription = new List<String>();
                Decimal kycScore;
                if(socureMetadataList.size()>0){
                    for(fsSocr__Socure_Reason_Code__mdt metaData : socureMetadataList){
                        
                        if(kycScores_1.contains(metaData.MasterLabel)){
                            kycScore = 0.97; 
                        }
                        if(kycScores_2.contains(metaData.MasterLabel) && kycScore == null){
                            kycScore = 0.90; 
                        }
                        
                        kycLevel.add(metaData.fsSocr__KYC_Return_Code_Level__c);
                        if(metaData.fsSocr__Type__c == 'Risk'){
                            riskCodeDescription.add(metaData.fsSocr__Description__c);
                            riskCodes.add(metaData.MasterLabel);
                        }
                        if(metaData.fsSocr__Type__c == 'Information'){
                            informationCodeDescription.add(metaData.fsSocr__Description__c);
                            informationCodes.add(metaData.MasterLabel);
                        } 
                        // descriptionList.add(metaData.fsSocr__Description__c);
                    }
                    if(kycLevel.contains('One')){
                        flag.KYC_Level__c = 'One';
                    }
                    if(kycLevel.contains('Two')){
                        flag.KYC_Level__c = 'Two';
                    }
                    if(kycLevel.contains('Three')){
                        flag.KYC_Level__c = 'Three';
                    }
                    // flag.Reason_Code_Description__c = getCommaSeparatedReasonCodeDescription(descriptionList);  
                }
                if(riskCodes.size()>0){
                    flag.Risk_Codes__c = getCommaSeparatedString(riskCodes);  
                    flag.Risk_Codes_Description__c = getCommaSeparatedReasonCodeDescription(riskCodeDescription);
                }
                if(informationCodes.size()>0){
                    flag.Informational_Codes__c = getCommaSeparatedString(informationCodes);
                    flag.Informational_Codes_Description__c = getCommaSeparatedReasonCodeDescription(informationCodeDescription);
                }
                if(kycScore != null){
                    flag.Score__c = kycScore;
                }
                flag.Field_Validations__c =  String.valueOf(res.kyc.fieldValidations);
                flagList.add(flag);
                system.debug(logginglevel.error,'6');
                
            }        
            /*if(res.nameAddressCorrelation != null){
Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
Fraud_Flag_Setup__c flagSetup = [Select id , Fraud_Flag_Code__c from Fraud_Flag_Setup__c where Fraud_Flag_Code__c = 'NAME_ADDRESS_CORRELATION'];
flag.Fraud_Flag_Name__c = flagSetup.id;
String reason='';
Boolean check = false;
for (String s : res.nameAddressCorrelation.reasonCodes) {
if (check) reason += ',';            
reason += s;
check = true;
}
flag.Reason_Codes__c = reason;
flag.Score__c = res.nameAddressCorrelation.score;
flag.Lending_Application_Number__c = applicationId;
flag.Transaction_ID__c = res.refernceId;
flagList.add(flag);
}
if(res.namePhoneCorrelation != null){
Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
Fraud_Flag_Setup__c flagSetup = [Select id , Fraud_Flag_Code__c from Fraud_Flag_Setup__c where Fraud_Flag_Code__c = 'NAME_PHONE_CORRELATION'];
flag.Fraud_Flag_Name__c = flagSetup.id;
String reason='';
Boolean check = false;
for (String s : res.namePhoneCorrelation.reasonCodes) {
if (check) reason += ',';            
reason += s;
check = true;
}
flag.Reason_Codes__c = reason;
flag.Score__c = res.namePhoneCorrelation.score;
flag.Lending_Application_Number__c = applicationId;
flag.Transaction_ID__c = res.refernceId;
flagList.add(flag);
}
if(res.nameEmailCorrelation != null){
Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
Fraud_Flag_Setup__c flagSetup = [Select id , Fraud_Flag_Code__c from Fraud_Flag_Setup__c where Fraud_Flag_Code__c = 'NAME_EMAIL_CORRELATION'];
flag.Fraud_Flag_Name__c = flagSetup.id;
String reason='';
Boolean check = false;
for (String s : res.nameEmailCorrelation.reasonCodes) {
if (check) reason += ',';            
reason += s;
check = true;
}
flag.Reason_Codes__c = reason;
flag.Score__c = res.nameEmailCorrelation.score;
flag.Lending_Application_Number__c = applicationId;
flag.Transaction_ID__c = res.refernceId;
flagList.add(flag);
}
if(res.social != null){
Lending_Application_Fraud_Flag__c flag = new Lending_Application_Fraud_Flag__c();
Fraud_Flag_Setup__c flagSetup = [Select id , Fraud_Flag_Code__c from Fraud_Flag_Setup__c where Fraud_Flag_Code__c = 'SOCIAL'];
flag.Fraud_Flag_Name__c = flagSetup.id;
String reason='';
Boolean check = false;
for (String s : res.social.reasonCodes) {
if (check) reason += ',';            
reason += s;
check = true;
}
flag.Reason_Codes__c = reason;
flag.Profiles_Found__c = JSON.serialize(res.social.profilesFound);
flag.Lending_Application_Number__c = applicationId;
flag.Transaction_ID__c = res.refernceId;
flagList.add(flag);
}*/
            
            
            if(flagList.size()>0){
                
                for(Lending_Application_Fraud_Flag__c flag : flagList){
                    flag.Lending_Application_Number__c = applicationId;
                    flag.Applicant_Name__c = applicantId;
                    flag.Transaction_ID__c = res.referenceId; 
                }
                insert flagList;
                if(maxFraudScore != null){
                    fsCore.LendingApplicationTriggerWrapper.getInstance().reset();
                    application.Max_Fraud_Score__c = maxFraudScore;
                    if(maxFraudScore>0.9){
                        Task t = new Task();
                        Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCL_Task').getRecordTypeId();
                        t.RecordTypeId = recTypeId;
                        t.OwnerId = application.OwnerId;
                        t.WhatId = application.id;
                        t.Subject = 'Fraud flag review is required';
                        t.ActivityDate = System.today();
                        t.Description = 'Fraud service has returned a score greater than 0.90 for the Lending Application '+application.Name +'-' + application.fsCore__Title__c + ' Please review the flags and update status accordingly.';
                        insert t;
                    }
                    
                    update application;   
                }
                
                
                system.debug(logginglevel.error,flagList.size() + '  '+ flagList);
                
            }
            
        }
        else{
            System.debug(loggingLevel.ERROR, 'Response code : ' + mHttpResponse.getStatusCode());
            try{
                fsSocr.SocureErrorSchema.Response errorRes = (fsSocr.SocureErrorSchema.Response)System.JSON.deserialize(mHttpResponse.getBody(),fsSocr.SocureErrorSchema.Response.class);
                System.debug(loggingLevel.ERROR, 'error Res = '+errorRes);
                fsCore__Diagnostic_Log__c error = fsCore.DiagnosticLogUtil.getErrorLog('SocureIDPlusResponseHandler', 'process', applicationId, applicationNum, mHttpResponse.getStatus(), String.join(errorRes.data.parameters,';'), mHttpResponse.getBody());
                Database.insert(error);
            }
            catch(Exception e){
                System.debug(loggingLevel.ERROR, e.getMessage() + e.getStackTraceString());
            }
           
            
        }
    }
    
    private static String getCommaSeparatedString(String[] pInput){
        String constructedString = '';
        if (pInput != null && pInput.size()>0){
            Boolean firstLoop = true;
            for (String errorCode : pInput) {
                if (firstLoop) {
                    constructedString = errorCode;
                    firstLoop = false;
                }else{
                    constructedString += ','+errorCode;
                }
            }
        }
        return  constructedString;
    }
    
    private static String getCommaSeparatedReasonCodeDescription(List<String> descriptionList){
        String description ='<ul>';
        for(String reason :descriptionList){
            description += '<li>'+ reason.escapeHtml4() +'</li>';
            System.debug(loggingLevel.ERROR,description);
        }
        description += '</ul>';
        System.debug(loggingLevel.ERROR,description);
        return description;
    }    
}