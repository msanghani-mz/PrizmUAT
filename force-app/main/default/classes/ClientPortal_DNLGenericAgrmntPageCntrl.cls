public without sharing class ClientPortal_DNLGenericAgrmntPageCntrl {
    public String componentName{get; set;}
    public String componentAppName{get; set;}
    public Boolean showEsign {get;set;}
    public Boolean showCpa {get;set;}
    public Boolean showTcpa {get;set;}
    public Boolean showRefDisAuth {get;set;}
    public Client_Portal_Portfolio__c portfolio {get; set;}
    public String applicantsNameString {get; set;} 
    public String currentDate {get;set;}
    public String portfolioName {get;set;}

    public ClientPortal_DNLGenericAgrmntPageCntrl() {
        showEsign = false;
        showCPA = false;
        showTcpa = false;
        showRefDisAuth = false;   
        componentName = 'c:' + ClientPortal_Constants.DNL_GENERIC_AGREEMENT_CMP;  
        componentAppName = 'c:' + ClientPortal_Constants.DNL_GENERATE_AGREEMENT_LTNG_APP;
        //Integer timeZoneOffset = ClientPortal_Utility.getTimeZoneOffsetHours(system.now(), 'America/New_York');
        currentDate = system.now().format('MM/dd/yyyy HH:mm:ss a','America/New_York');
        portfolio = ClientPortal_Utility.getUserPortfolio();
        applicantsNameString = UserInfo.getName(); 
        String docNameParam = ApexPages.currentPage().getParameters().get(ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM);
        portfolioName = ApexPages.currentPage().getParameters().get(ClientPortal_Constants.DNL_GEN_AGR_PAGE_PORTFOLIO_TYPE_URI_PARAM);
        if(docNameParam != null && docNameParam.trim() != ''){
            if(docNameParam == ClientPortal_Constants.DNL_ESIGN_PARAM){
                showEsign = true;
            }else if(docNameParam == ClientPortal_Constants.DNL_CPA_PARAM){
                showCPA = true;
            }else if(docNameParam == ClientPortal_Constants.DNL_TCPA_PARAM){
                showTcpa = true;
            }else if(docNameParam == ClientPortal_Constants.DNL_REF_DIS_AUTH){
                showRefDisAuth = true;
                if(portfolio != null && portfolio.RDA_Content__c != null && portfolio.RDA_Content__c.contains(ClientPortal_Constants.DNL_AGR_PAGE_PORTFOLIO_TYPE_REPLACE) && portfolioName != null){
                    portfolio.RDA_Content__c = portfolio.RDA_Content__c.replace(ClientPortal_Constants.DNL_AGR_PAGE_PORTFOLIO_TYPE_REPLACE, portfolioName);
                }
            }else{
                //ToDo
                /* Add Error handling */
            }
        }else{
            //ToDo
            /* Add Error handling */
        }
    }
}