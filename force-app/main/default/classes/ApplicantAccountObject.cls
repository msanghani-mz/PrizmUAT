/**
 * @File Name          : ApplicantAccountObject.cls
 * @Description        : This class hold the information for the applicant and the account object
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/7/2019, 12:01:19 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/7/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class ApplicantAccountObject {
    public Account  account           {get; set;}
    public fsCore__Lending_Application_Customer__c  applicant        {get; set;}    
}