public without sharing class ClientPortal_DNLGenericShowAgrmntCntrl {
    
    public String componentName{get; set;}
    public String componentAppName{get; set;}
    public Boolean showEsign {get;set;}
    public Boolean showCpa {get;set;}
    public Boolean showTcpa {get;set;}
    public Boolean showRefDisAuth {get;set;}
    public Client_Portal_Portfolio__c portfolio {get; set{
                                                        if(portfolio == null){
                                                            portfolio = ClientPortal_Utility.getUserPortfolio();
                                                        }
                                                    }
                                                }
    public String applicantsNameString {get; set{
                                                List<String> applicants = ClientPortal_Utility.getApplicantNameList();
                                                if(applicants != null){
                                                    if(applicants.size() > 1){
                                                        applicantsNameString = applicants[0] + ' and ' + applicants[1];
                                                    }else if(applicants.size() == 1){
                                                        applicantsNameString = applicants[0];
                                                    }
                                                }
                                            }
                                        }
    public ClientPortal_DNLGenericShowAgrmntCntrl() {
        showEsign = false;
        showCPA = false;
        showTcpa = false;
        showRefDisAuth = false;
        componentAppName = ClientPortal_Constants.DNL_GENERATE_AGREEMENT_LTNG_APP;
        componentName = ClientPortal_Constants.DNL_GENERIC_AGREEMENT_CMP;
        String docNameParam = ApexPages.currentPage().getParameters().get(ClientPortal_Constants.DNL_GEN_AGR_PAGE_URI_PARAM);
        if(docNameParam != null && docNameParam.trim() != ''){
            if(docNameParam == ClientPortal_Constants.DNL_ESIGN_PARAM){
                showEsign = true;
            }else if(docNameParam == ClientPortal_Constants.DNL_CPA_PARAM){
                showCPA = true;
            }else if(docNameParam == ClientPortal_Constants.DNL_TCPA_PARAM){
                showTcpa = true;
            }else if(docNameParam == ClientPortal_Constants.DNL_REF_DIS_AUTH){
                showRefDisAuth = true;
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