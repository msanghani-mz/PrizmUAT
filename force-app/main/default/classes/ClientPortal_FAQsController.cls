public class ClientPortal_FAQsController {

  @AuraEnabled
  public static ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig getClientPortalUIConfiguration(String domainURL,
                                                              String portfolioName) {

    ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig ciConfig = ClientPortal_CustomRegisterCntrl.getClientPortalUIConfiguration(domainURL,portfolioName);
    return ciConfig;

  }

  @AuraEnabled
  public static List<Client_Portal_Settings__c> getAllFrequentQuestions(String domainURL,
                                                              String portfolioName) {
    
    ClientPortal_CustomRegisterCntrl.ClientPortalUIConfig ciConfig = ClientPortal_CustomRegisterCntrl.getClientPortalUIConfiguration(domainURL,portfolioName);
    Id portfolioId = ciConfig.portfolio.Id ;

    Id faqRecordTypeId = ClientPortal_Utility.getRecordTypeId('Client_Portal_Settings__c', 'Frequently Asked Question Configuration');
    return [SELECT Question__c, Answer__c
            FROM Client_Portal_Settings__c
            WHERE recordTypeId =: faqRecordTypeId
              AND Is_Active__c = true
              AND Client_Portal_Portfolio__c=: portfolioId];

  }

}