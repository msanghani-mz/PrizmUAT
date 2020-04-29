/*
* Copyright (c) 2017-2019 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class        - SocureIDPlusRequestBuilder
*
* Description  - Mock Socure ID+ Request Builder class
*
* Developer(s) - Aniket Singh
*
*/
global class SocureIDPlusRequestBuilder implements fsCore.WebServiceRequestBuilder{
    private fsSocr.SocureIDPlusSchema.Request mRequest;
    private Set<Id> mInputIDs;
    private Map<Id, Object> mRequestMap;
    
    global SocureIDPlusRequestBuilder(){
        //  mRequest = getRequestPayload();
    }
    
    global void setInput(Set<Id> pInputIDs){
        mInputIDs = pInputIDs;
    }
    global void build(){
        mRequestMap = new Map<Id, Object>();
        //mRequestMap.put(recId, mRequest);
        mRequestMap = getRequestPayload(mInputIDs);
        System.debug(logginglevel.error,mRequestMap);
        
    }
    global Object getData(Id pRecordId){
        return mRequestMap.get(pRecordId);
    }
    
    global Map<Id, Object> getAllData(){
        return mRequestMap;
    }
    
    /*
* Methods to construct request
*/
    global static Map<Id,fsSocr.SocureIDPlusSchema.Request> getRequestPayload(Set<Id> pApplicantIds){
        System.debug(logginglevel.error,pApplicantIds);
        Map<id,fsSocr.SocureIDPlusSchema.Request> mapApplicantIdToRequest = new Map<id,fsSocr.SocureIDPlusSchema.Request>();
        
        List<fsCore__Lending_Application_Customer__c> mApplicants = [Select id ,
                                                                     fsCore__Account_Name__c,
                                                                     fsCore__Account_Name__r.FirstName,
                                                                     fsCore__Account_Name__r.LastName,
                                                                     fsCore__Account_Name__r.Phone,
                                                                     //SUP-394
                                                                     fsCore__Account_Name__r.IP_Address__c,
                                                                     fsCore__Account_Name__r.PersonMailingCity,
                                                                     fsCore__Account_Name__r.PersonMailingPostalCode ,
                                                                     fsCore__Account_Name__r.PersonMailingStateCode,
                                                                     fsCore__Account_Name__r.PersonMailingStreet,
                                                                     fsCore__Account_Name__r.PersonEmail,
                                                                     fsCore__Account_Name__r.PersonBirthdate,
                                                                     fsCore__Account_Name__r.PersonMailingCountryCode,
                                                                     fsCore__Account_Name__r.Primary_Id_Type__c,
                                                                     fsCore__Account_Name__r.Primary_Id_Number__c,
                                                                     fsCore__Account_Name__r.Primary_Id_State__c,
                                                                     fsCore__Account_Name__r.fsCore__National_Identification_Number__pc
                                                                     from fsCore__Lending_Application_Customer__c
                                                                     where id in :pApplicantIds]; 
        
        
        try{
            for(fsCore__Lending_Application_Customer__c applicant :mApplicants){
                fsSocr.SocureIDPlusSchema.Request request = new fsSocr.SocureIDPlusSchema.Request();
                
                if(applicant.fsCore__Account_Name__r.FirstName != null){
                    request.firstName = applicant.fsCore__Account_Name__r.FirstName;
                }
                 //SUP-394
                if(applicant.fsCore__Account_Name__r.IP_Address__c != null){
                    request.ipAddress = applicant.fsCore__Account_Name__r.IP_Address__c;
                }
                if(applicant.fsCore__Account_Name__r.LastName != null){
                    request.surName = applicant.fsCore__Account_Name__r.LastName;
                }
                if(applicant.fsCore__Account_Name__r.PersonMailingCountryCode != null){
                    request.country = applicant.fsCore__Account_Name__r.PersonMailingCountryCode;
                }
                if(applicant.fsCore__Account_Name__r.PersonEmail != null ){                    
                    request.email = applicant.fsCore__Account_Name__r.PersonEmail;
                }
                if(applicant.fsCore__Account_Name__r.Phone != null){
                    if(applicant.fsCore__Account_Name__r.Phone.contains('+1')){
                      request.mobileNumber = applicant.fsCore__Account_Name__r.Phone;  
                    }
                    else{
                       request.mobileNumber = '+1' + applicant.fsCore__Account_Name__r.Phone;   
                    }   
                }
                if(applicant.fsCore__Account_Name__r.PersonMailingStreet != null){
                    request.physicalAddress = applicant.fsCore__Account_Name__r.PersonMailingStreet;
                }
                if(applicant.fsCore__Account_Name__r.PersonMailingCity != null){
                    request.city = applicant.fsCore__Account_Name__r.PersonMailingCity;
                }
                if(applicant.fsCore__Account_Name__r.PersonMailingStateCode != null){
                    request.state = applicant.fsCore__Account_Name__r.PersonMailingStateCode;
                }
                if(applicant.fsCore__Account_Name__r.PersonMailingPostalCode != null){
                    request.zip = applicant.fsCore__Account_Name__r.PersonMailingPostalCode;
                }
                if(applicant.fsCore__Account_Name__r.PersonBirthdate != null){
                    request.dob = String.valueOf(applicant.fsCore__Account_Name__r.PersonBirthdate);
                }
                if(applicant.fsCore__Account_Name__r.fsCore__National_Identification_Number__pc != null){
                    request.nationalId = applicant.fsCore__Account_Name__r.fsCore__National_Identification_Number__pc;
                }
                if(applicant.fsCore__Account_Name__r.Primary_Id_Type__c == 'Driver’s License'){
                    
                    if(applicant.fsCore__Account_Name__r.Primary_Id_Number__c != null){
                        request.driverLicense = applicant.fsCore__Account_Name__r.Primary_Id_Number__c;
                    }
                    if(applicant.fsCore__Account_Name__r.Primary_Id_State__c != null){
                       request.driverLicenseState =  applicant.fsCore__Account_Name__r.Primary_Id_State__c;
                    }
                }
                System.debug(LoggingLevel.ERROR,request);
                mapApplicantIdToRequest.put(applicant.id,request);
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error'+ e.getMessage());
        }
        System.debug(LoggingLevel.ERROR,mapApplicantIdToRequest);
        return mapApplicantIdToRequest; 
    }
    
}