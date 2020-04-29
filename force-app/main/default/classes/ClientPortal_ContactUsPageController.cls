public without sharing class ClientPortal_ContactUsPageController {
  @AuraEnabled
  public static ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig getClientPortalUIConfiguration(String domainURL,
                                                                                                     String portfolioName) {

        ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig ciConfig =
                        ClientPortal_CustomRegisterCntrl.getClientPortalUIConfiguration(domainURL,
                                                                                          portfolioName);
        return ciConfig;
	}
}