/*
* Class   : MLADisclosureDocumentController
* Purpose : Controller class to generate MLA disclosure HTML report 
* Author  : Financial Spectra
*/
public class MLADisclosureDocumentController{
    
    public String mMlaDisclosureContent {get;set;}
    
    public MLADisclosureDocumentController(){
        Id lendingApplicationId = ApexPages.currentPage().getParameters().get('id');
        system.debug(logginglevel.error,'MLADisclosureDocumentController 1' );        
        setReportContent(lendingApplicationId);
    }
    
    public MLADisclosureDocumentController(ApexPages.StandardController pStdController){
        system.debug(logginglevel.error,'MLADisclosureDocumentController 2' );
        fsCore__Lending_Application__c lendingApplication = (fsCore__Lending_Application__c)pStdController.getRecord();
        system.debug(logginglevel.error,'lendingApplication :'+lendingApplication );
        setReportContent(lendingApplication.Id);
    }
    
    private void setReportContent(Id pLendingApplicationId){
        if (pLendingApplicationId != null){
            
            fsCore__Lending_Application__c application = fsCore.LendingApplicationUtil.getApplication(pLendingApplicationId);
            system.debug(logginglevel.error,'Report :'+getReportContent(application));

            mMlaDisclosureContent = getReportContent(application);
            
        }
        if (String.IsBlank(mMlaDisclosureContent)){
            mMlaDisclosureContent = '<p>*** No content found ***</p>';
        }
    }  
    
    public static string getReportContent(fsCore__Lending_Application__c pLendingApplication){
        String APL_PRIM_Person_Name_Formula;
        String APL_NON_PRIM_Person_Name_Ampersand_Formula;
        //   string Contact_Other_Address_Formula;
        List<fsCore__Lending_Application_Customer__c> applicants = [Select id, Name 
                                                                    , fsCore__Is_Primary__c
                                                                    , Person_Name_Formula__c
                                                                    , fsCore__Lending_Application_Number__c 
                                                                    , Person_Name_Ampersand_Formula__c 
                                                                    , fsCore__Contact_Name__c
                                                                    from  fsCore__Lending_Application_Customer__c
                                                                    where fsCore__Lending_Application_Number__c = :pLendingApplication.id]; 
        Set<id> contactIds  = new Set<Id>();
        for(fsCore__Lending_Application_Customer__c applicant : applicants){
            if(applicant.fsCore__Is_Primary__c){
                APL_PRIM_Person_Name_Formula = applicant.Person_Name_Formula__c;
                contactIds.add(applicant.fsCore__Contact_Name__c);
                
            }else{
                APL_NON_PRIM_Person_Name_Ampersand_Formula = applicant.Person_Name_Ampersand_Formula__c;
            }
        }
        List<Contact> contacts =[Select id, name , fsCore__Other_Address_Formula__c,OtherCity,OtherState, OtherStreet, OtherPostalCode, OtherCountry from Contact where Id In :contactIds];
        // Contact_Other_Address_Formula = contacts[0].fsCore__Other_Address_Formula__c;
        
        List<fsCore__Lending_Application_Repayment_Schedule__c> schedules = [Select id ,fsCore__Lending_Application_Number__c, Name , fsCore__Number_Of_Payments__c,fsCore__Payment_Amount__c from fsCore__Lending_Application_Repayment_Schedule__c where fsCore__Lending_Application_Number__c = :pLendingApplication.Id];
        
        String htmlBody = '<h1 style=\'margin:0in;margin-bottom:.0001pt;text-align:center;line-height:115%;font-size:16px;font-family:"Calibri Light",sans-serif;\'><span style=\'font-size:19px;line-height:115%;font-family:"Cambria",serif;\'>MILITARY LENDING ACT&nbsp;</span></h1> '+
            '<h1 style=\'margin:0in;margin-bottom:.0001pt;text-align:center;line-height:115%;font-size:16px;font-family:"Calibri Light",sans-serif;\'><span style=\'font-family:"Cambria",serif;\'>NOTICE AND DISCLOSURE STATEMENT</span></h1> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;margin-top:6.0pt;text-align:justify;\'><em><span style=\'font-size:15px;font-family:"Cambria",serif;\'>The Military Lending Act (MLA) places limits by the federal government on terms of consumer credit extended to certain servicemembers and their dependents<sup>1</sup>. Please review the information contained in this document and print a copy for your reference</span></em><strong><em><span style=\'font-size:15px;font-family:"Cambria",serif;\'>.</span></em></strong></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;\'><strong><span style=\'font-size:15px;font-family:"Cambria",serif;\'>&nbsp;</span></strong></p> '+
            '<table style="border-collapse:collapse;border:none;"> '+
            '<tbody> '+
            '<tr> '+
            '<td style="width: 238.4pt;padding: 0in 5.4pt;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:0in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>Notice Date:&nbsp;</span></strong><span style=\'font-size:15px;font-family:"Cambria",serif;\'>'+Date.today().format()+'</span></p> '+
            '</td> '+
            '<td style="width: 280.9pt;padding: 0in 5.4pt;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>Application #:&nbsp;</span></strong><span style=\'font-size:15px;font-family:"Cambria",serif;\'>'+pLendingApplication.Name+'</span></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>&nbsp;</span></strong></p> '+
            '</td> '+
            '</tr> '+
            '<tr> '+
            '<td style="width: 238.4pt;padding: 0in 5.4pt;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:0in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>Lender:</span></strong></p> '+
            '</td> '+
            '<td style="width: 280.9pt;padding: 0in 5.4pt;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>Borrower Name(s) and Address:&nbsp;</span></strong></p> '+
            '</td> '+
            '</tr> '+
            '<tr> '+
            '<td style="width: 238.4pt;padding: 0in 5.4pt;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>Versara Lending, LLC,&nbsp;</span></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>711 Third Avenue, Suite 600,</span></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>New York, NY 10017.</span></p> '+
            '</td> '+
            '<td style="width: 280.9pt;padding: 0in 5.4pt;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>'+APL_PRIM_Person_Name_Formula+'</span></p> ';
        IF(String.isNotBlank(APL_NON_PRIM_Person_Name_Ampersand_Formula)){
            htmlBody +='<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>'+APL_NON_PRIM_Person_Name_Ampersand_Formula+'</span></p> ';
        }
        IF(String.isNotBlank(contacts[0].OtherStreet)){
            htmlBody +='<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>'+contacts[0].OtherStreet+'</span></p> ';
        }
        htmlBody += '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>';
        IF(String.isNotBlank(contacts[0].OtherCity)){
            htmlBody += contacts[0].OtherCity+', ';
        }
        IF(String.isNotBlank(contacts[0].OtherState)){
            htmlBody += contacts[0].OtherState;
            
        }
        IF(String.isNotBlank(contacts[0].OtherPostalCode)){
            htmlBody += ' '+contacts[0].OtherPostalCode;
            
        }
        htmlBody += '</span></p> ';
        IF(String.isNotBlank(contacts[0].OtherCountry)){
            htmlBody +='<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-indent:.5in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>'+contacts[0].OtherCountry;
        }
        htmlBody +='</td> '+
            '</tr> '+
            '</tbody> '+
            '</table> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>&nbsp;</span></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>&nbsp;</span></p> '+
            '<div class = "container" style="border:0px solid black;margin: auto;width: 100%;padding: 0px;">'+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>Your payment schedule will be:</span></p> '+
            '<br/>'+
            '<table>'+
            '<tbody>'+
            '<tr>'+
            '<td>'+
            '<table style="float: left !important;border:1px solid black;margin-left:6.75pt;margin-right:6.75pt;" title="Select payment schedule"> '+
            '<tbody> '+
            '<tr> '+
            '<td style="width: 128.1pt;border: 1pt solid windowtext;background: white;padding: 0in 5.4pt;height: 0.25in;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>Number of Payments</span></p> '+
            '</td> '+
            '<td style="width: 128.15pt;border-top: 1pt solid windowtext;background: white;padding: 0in 5.4pt;height: 0.25in;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>Amount of Payments</span></p> '+
            '</td> '+
            '</tr> ';
        if(schedules.size()>0){
            for(fsCore__Lending_Application_Repayment_Schedule__c schedule : schedules){
                htmlBody += '<tr> '+
                    '<td style="width:128.1pt;border:solid windowtext 1.0pt;border-top:  none;background:#D9D9D9;padding:0in 5.4pt 0in 5.4pt;height:.25in;"> '+
                    '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>'+schedule.fsCore__Number_Of_Payments__c+' (e)</span></strong></p> '+
                    '</td> '+
                    '<td style="width:128.15pt;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#D9D9D9;padding:0in 5.4pt 0in 5.4pt;height:.25in;"> '+
                    '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>'+schedule.fsCore__Payment_Amount__c+' (e)</span></strong></p> '+
                    '</td> '+
                    '</tr> ';
            }
        }
        
        htmlBody += '</tbody> '+
            '</table> '+
            '</td>'+
            '<td>'+
            '<table style="float: left !important;border:1px solid black;margin-left: -13px;;margin-right:6.75pt;" title="Select payment schedule1"> '+
            '<tr> '+
            '<td colspan="2" style="width: 255.45pt;border: 1pt solid windowtext;padding: 0in 5.4pt;height: 0.25in;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>When Payments Are Due</span></p> '+
            '</td> '+
            '</tr> '+
            '<tr> '+
            '<td style="width: 127.7pt;border-right: 1pt solid windowtext;border-bottom: 1pt solid windowtext;border-left: 1pt solid windowtext;border-image: initial;border-top: none;background: rgb(217, 217, 217);padding: 0in 5.4pt;height: 0.25in;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>Starting,</span></p> '+
            '</td> '+
            '<td style="width: 127.75pt;border-top: none;border-left: none;border-bottom: 1pt solid windowtext;border-right: 1pt solid windowtext;background: rgb(217, 217, 217);padding: 0in 5.4pt;height: 0.25in;vertical-align: top;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>First Payment Date (e)</span></p> '+
            '</td> '+
            '</tr> '+
            '<tr> '+
            '<td style="width:127.7pt;border:solid windowtext 1.0pt;border-top:  none;background:#D9D9D9;padding:0in 5.4pt 0in 5.4pt;height:.25in;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>'+pLendingApplication.fsCore__Payment_Cycle__c+'</span></strong></p> '+
            '</td> '+
            '<td style="width:127.75pt;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#D9D9D9;padding:0in 5.4pt 0in 5.4pt;height:.25in;"> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:center;text-indent:0in;\'><strong><span style=\'font-size:15px;font-family:  "Cambria",serif;\'>'+(pLendingApplication.fsCore__Payment_Start_Date__c).format() +'</span></strong></p> '+
            '</td> '+
            '</tr> '+
            '</table> '+
            '</td>'+
            '</tr>'+
            '</tbody> '+
            '</table> '+
            '</div> '+
            
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><strong>&nbsp;</strong></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><strong>&nbsp;</strong></p> '+
            
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><strong><span style=\'font-size:15px;font-family:"Cambria",serif;\'>STATEMENT OF THE MILITARY ANNUAL PERCENTAGE RATE (MAPR):</strong></span></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>Federal law provides important protections to members of the Armed Forces and their dependents relating to extensions of consumer credit. In general, the cost of consumer credit to a member of the Armed Forces and his or her dependent may not exceed an annual percentage rate of 36%. This rate must include, as applicable to the credit transaction or account: the costs associated with credit insurance premiums; fees for ancillary products sold in connection with the credit transaction; any application fee charged (other than certain application fees for specified credit transactions or accounts); and any participation fee charged (other than certain participation fees for a credit card account).</span></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'>&nbsp;</p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><strong><span style=\'font-size:15px;font-family:"Cambria",serif;\'>ORAL DISCLOSURE OF TERMS PROVIDED BY VERSARA </strong></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><span style=\'font-size:15px;font-family:"Cambria",serif;\'>Contact our toll-free number at <strong>855-397-3392</strong> for oral disclosure of a statement of the MAPR and a clear description of the payment obligation. Versara will provide you with a verbal description of your obligation to make regular monthly payments for the term of your loan in accordance with your Loan Agreement. Our Support team is available during the hours of <strong>9:00 AM to 6:00 PM Eastern, Monday through Friday</strong>. To receive all required disclosures over the phone, or to discuss the terms of your loan, <strong>please contact Versara Support toll-free at 855-397-3392.</strong></span></p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'>&nbsp;</p> '+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><strong><span style=\'font-size:13px;font-family:"Cambria",serif;\'>Please review the Truth-in-Lending Act (&ldquo;TILA&rdquo;) disclosures in your Loan Agreement for additional details.</strong></span></p>'+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:16px;font-family:"Cambria",sans-serif;text-align:justify;\'><strong>&nbsp;</strong></p> '+
            '<footer>'+
            '<p style=\'margin:0in;margin-bottom:.0001pt;line-height:normal;font-size:10px;font-family:"Cambria",sans-serif;text-align:justify;\'><span style=\'font-size:10px;font-family:"Cambria",serif;\'><sup>1</sup>Covered borrower means a consumer who, at the time the consumer becomes obligated on a consumer credit transaction or establishes an account for consumer credit, is a covered member or a dependent of a covered member. The term ‘‘covered member’’ means a member of the armed forces who is serving on: (i) Active duty pursuant to title 10, title 14, or title 32, United States Code; (ii) under a call or order that does not specify a period of 30 days or fewer; or, (iii) Active Guard and Reserve duty, as that term is defined in 10 U.S.C. 101(d)(6). The term ‘‘dependent’’ with respect to a covered member means a person described in subparagraph (A), (D), (E), or (I) of 10 U.S.C. 1072(2). Covered borrower does not mean a consumer who (though a covered borrower at the time he or she became obligated on a consumer credit transaction or established an account for consumer credit) no longer is a covered member or a dependent of a covered member. If you have questions regarding your coverage under the Military Lending Act, please refer all inquiries to the Defense Manpower Data Center (DMDC).</span></p>'+
            '</footer>';
        
        return htmlBody;
    }
    
}