/**
 * @File Name          : MLAMatchPDFGenerator
 * @Description        : 
 * @Author             : fsDev
 * @Group              : 
 * @Last Modified By   : fsDev
 * @Last Modified On   : 4/25/2020, 11:26:10 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/21/2020   fsDev     Initial Version
**/
public class MLAMatchPDFGenerator {
    @InvocableMethod(label='MLA Disclosure Document' description=' Clients will receive the MLA disclosure document via email ')
    public static void generatePDFAndEmail(List<ID> pApplicationIds){
        
        map<Id, fsCore__Lending_Application__c> mapLendingApp = new map<Id, fsCore__Lending_Application__c>([select id,
                                                                                                                    BoxFolderId__c,
                                                                                                                    MLA_Match__c,
                                                                                                                    MLA_Disclosure_Sent_Date__c, 
                                                                                                                    Loan_Officer__c
                                                                                                               FROM fsCore__Lending_Application__c  where id = :pApplicationIds]);
        List<fsCore__Lending_Application__c> lendingAppUpdateList = new List<fsCore__Lending_Application__c>();
        MAP<Id,String> loanOfficerEmailMap =  new MAP<Id,String>();
        MAP<Id,Id> lAppToloanOfficerIdMap =  new MAP<Id,Id>();
        Set<Id> appIds = new Set<Id>();
        for (fsCore__Lending_Application__c lApp: mapLendingApp.Values()){
            if (lApp.Loan_Officer__c != null){
                lAppToloanOfficerIdMap.put(lApp.Id,lApp.Loan_Officer__c);
            }
            appIds.add(lApp.Id);
        }

        map<Id, User> loanOfficerUserMap = new map<Id, User>([SELECT Id, Name, Email, Profile.Id, Profile.Name FROM User WHERE Id IN :lAppToloanOfficerIdMap.Values()]);
        for (Id lendingAppId: mapLendingApp.keySet()){
            if (loanOfficerUserMap.get(lAppToloanOfficerIdMap.get(lendingAppId)).email != null){
                loanOfficerEmailMap.put(lendingAppId,loanOfficerUserMap.get(lAppToloanOfficerIdMap.get(lendingAppId)).email);
            }
        }
        Map<Id,List<String>> appToApplicantEmailAddressMap = getEmailAddresses(appIds);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'myloanapp@versaralending.com'];
        //first we need to get the page
        for (fsCore__Lending_Application__c lApp: mapLendingApp.Values()){
            if (!lApp.MLA_Match__c ){
                system.debug(logginglevel.error,'Not a MLA match');
                Continue;
            }
            
            PageReference MlaMatchPDF = Page.MLADisclosureDocumentPage;
            MlaMatchPDF.getParameters().put('id', lApp.Id);
            
            Blob MlaMatchPDFReport;
            if(!Test.isRunningTest()){ // for code coverage 
                MlaMatchPDFReport = MlaMatchPDF.getContent();
            } else {
                MlaMatchPDFReport = blob.valueOf('Unit.Test');
            }
            
            //create and send email 
            Messaging.EmailFileAttachment emailFileAtt = new Messaging.EmailFileAttachment();
            emailFileAtt.setBody(MlaMatchPDFReport);
            emailFileAtt.setContentType('application/pdf');
            emailFileAtt.setFileName('MLA_Disclosure.pdf');
            
            Messaging.SingleEmailMessage mess = new Messaging.SingleEmailMessage();
            mess.setSubject('Military Lending Act (MLA) Notice for Servicemembers');
            mess.setToAddresses(appToApplicantEmailAddressMap.get(lApp.Id));

            // Setting loan officer in CC
            if (loanOfficerEmailMap.get(lApp.Id) != null){
                mess.setccAddresses(new String []{loanOfficerEmailMap.get(lApp.Id)});
            }
            
            if (owea != null && owea.size() >0 ){
                mess.setOrgWideEmailAddressId(owea[0].Id);
            }
            
            mess.setWhatId(lApp.Id ); //To attach to the lending application
            mess.setHTMLBody(getHTMLBody());
            mess.setFileAttachments(new Messaging.EmailFileAttachment[]{emailFileAtt});
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mess};
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug(logginglevel.error,'The email was sent successfully.');
                //Now Save the attachment to the BOX
                if (lApp.BoxFolderId__c != null){
                    lApp.MLA_Disclosure_Sent_Date__c = DateTime.Now();
                    
                    lendingAppUpdateList.add(lApp);
                    String documentName = 'MLA_Disclosure '+DateTime.Now()+'.pdf';
                    copyDocumentToBox(MlaMatchPDFReport,lApp.BoxFolderId__c,documentName);
                }

            } else {
                System.debug(logginglevel.error,'The email failed to send: '
                  + results[0].errors[0].message);
            }
        }
        update lendingAppUpdateList;
    }

    @Future(callout=true)
    public static void copyDocumentToBox(Blob pdfDoc, String pBoxFolderId, String pFileName){
        CreateBoxFolderHandler.copyDocumentToBox(pdfDoc,pBoxFolderId,pFileName);
    }

    private static string getHTMLBody(){
        return '<span><style=\'margin-top:0in;margin-right:0in;margin-bottom:.0001pt;margin-left:0in;line-height:107%;font-size:15px;font-family:"Calibri",sans-serif;text-align:justify;\'>Dear Borrower:</span><br/><br/>'+
        '<span><style=\'margin-top:0in;margin-right:0in;margin-bottom:.0001pt;margin-left:0in;line-height:107%;font-size:15px;font-family:"Calibri",sans-serif;text-align:justify;\'>Your account is eligible for benefits under the Military Lending Act (MLA) and Versara Lending policy (collectively referred to as &ldquo;MLA&rdquo;). </span><br/><br/>'+
        '<span><style=\'margin-top:0in;margin-right:0in;margin-bottom:.0001pt;margin-left:0in;line-height:107%;font-size:15px;font-family:"Calibri",sans-serif;text-align:justify;\'>We applied these benefits to your account:</span>'+
        '<ul>'+
            '<li><style="font-family:Calibri;color:black;">Your Military Annual Percentage Rate (MAPR) will not be more than 36%;</li>'+
            '<li><style="font-family:Calibri;color:black;">Your contract rate will not be impacted and will remain as outlined in your Loan Agreement;</li>'+
            '<li><style="font-family:Calibri;color:black;">We will not charge you fees, other than late fees and non-sufficient funds fees, if applicable.</li>'+
        '</ul>'+
        '<span><style=\'margin-top:0in;margin-right:0in;margin-bottom:.0001pt;margin-left:0in;line-height:107%;font-size:15px;font-family:"Calibri",sans-serif;text-align:justify;\'>Please review the attached MLA Notice and Disclosure Statement for more information about your benefits. &nbsp;If you have any questions, please call our Client Service team at 855-397-3392 between the hours of 9:00 AM and 6:00 PM Eastern, Monday through Friday.</span><br/><br/>'+
        '<span><style=\'margin-top:0in;margin-right:0in;margin-bottom:.0001pt;margin-left:0in;line-height:107%;font-size:15px;font-family:"Calibri",sans-serif;text-align:justify;\'>Thank you for your business and for your service to our country.</span><br/><br/>'+
        '<span><style=\'margin-top:0in;margin-right:0in;margin-bottom:.0001pt;margin-left:0in;line-height:107%;font-size:15px;font-family:"Calibri",sans-serif;text-align:justify;\'>Sincerely,</span><br/>'+
        '<span><style=\'margin-top:0in;margin-right:0in;margin-bottom:.0001pt;margin-left:0in;line-height:107%;font-size:15px;font-family:"Calibri",sans-serif;text-align:justify;\'>Versara Client Service Team</span> ';
    }

    private static Map<Id,List<String>> getEmailAddresses(Set<Id> pAppIds){

        Map<Id,List<String>> emailAddressMap = new Map<Id,List<String>>();

        List<fsCore__Lending_application_Customer__c> applicants = 
            [SELECT Id
                  , fsCore__Lending_application_Number__c
                  , fsCore__Account_Name__r.PersonEmail
               FROM fsCore__Lending_application_Customer__c
              WHERE fsCore__Lending_application_Number__c IN :pAppIds
                AND fsCore__Customer_Type__c IN ('Primary','Secondary')
                AND fsCore__Account_Name__r.PersonEmail != null
                ORDER BY fsCore__Lending_application_Number__c, fsCore__Customer_Type__c];
        
            for (fsCore__Lending_application_Customer__c applicant : applicants){
                List<String> applicantEmail = new List<String>();
                if (emailAddressMap.containsKey(applicant.fsCore__Lending_application_Number__c)){
                    applicantEmail = emailAddressMap.get(applicant.fsCore__Lending_application_Number__c);
                }
                applicantEmail.add(applicant.fsCore__Account_Name__r.PersonEmail);
                emailAddressMap.put(applicant.fsCore__Lending_application_Number__c,applicantEmail);
            }
    
        Return emailAddressMap;

    }
}