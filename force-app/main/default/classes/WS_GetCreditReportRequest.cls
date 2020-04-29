/*
 * Class   : WS_GetCreditReportRequest 
 * Purpose : Structure of the Credit Analysis Web Service Request 
 * Author  : Financial Spectra
 */
public class WS_GetCreditReportRequest {

    public String velocifyId;
    public String offerId;
    public String boxFolderId;
    public String applicationName;
    public String applicationId;

    public WS_GetCreditReportRequest(){
        velocifyId = null;
        offerId = null;
        boxFolderId = null;
        applicationName = null;
        applicationId = null;
    }


}