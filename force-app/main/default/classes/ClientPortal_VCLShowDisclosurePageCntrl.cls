public without sharing class ClientPortal_VCLShowDisclosurePageCntrl {

    public String currentDate {get;set;}
    public String ltngAppName {get;set;}
    public String ltngCmpName {get;set;}
    public String applicationId {get;set;}
    public String currentIP {get;set;}
    public ClientPortal_VCLShowDisclosurePageCntrl() {
        currentDate = system.now().format('MM/dd/yyyy HH:mm:ss a','America/New_York');
        ltngAppName = 'c:' + ClientPortal_Constants.VCL_GEN_SHOW_AGREEMENT_LTNG_APP;
        ltngCmpName = 'c:' + ClientPortal_Constants.VCL_MLA_SHOW_AGR_LTNG_CMP;
        applicationId = apexpages.currentpage().getparameters().get('id');
        currentIP = ClientPortal_Utility.getUserIPAddress();
    }

    @AuraEnabled
    public static ClientPortal_GenerateMlaPDFVCLCntrl.VCLMlaWrapper getMLAContentWrapper(String lendingAppId){
        return ClientPortal_GenerateMlaPDFVCLCntrl.getUIWrap(lendingAppId, false);
    }
}