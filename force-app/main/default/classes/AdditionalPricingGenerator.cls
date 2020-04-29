/**
 * Class Name  : AdditionalPricingGenerator
 * Description : This class generates additional pricing by changing 
 *               the payment amount of the accepted pricing offer and 
 *               update the additional pricing details (new term, new
 *               payment amount, new finance change) on the lending 
 *               application record
 * Author      : Financial Spectra
 * 
 */
public with sharing class AdditionalPricingGenerator{

    @future
    public static void generateOption1(Set<Id> pPricingOfferIds){
        List<fsCore__Lending_Application_Pricing_Offer__c> pricingOffersForOption1 = new List<fsCore__Lending_Application_Pricing_Offer__c>();
        Set<Id> applicationIds = new Set<Id>();
        
        for (fsCore__Lending_Application_Pricing_Offer__c offer : getPricingOffers(pPricingOfferIds)){
            if (offer.fsCore__Pricing_Name__r.Is_Generate_Additional_Pricing__c && offer.fsCore__Pricing_Name__r.Payment_Increase_For_Option_1__c != null){
                offer.fsCore__Payment_Amount__c = getIncreasedPaymentAmount(offer.fsCore__Payment_Amount__c, offer.fsCore__Pricing_Name__r.Payment_Increase_For_Option_1__c);
                pricingOffersForOption1.add(offer);
                applicationIds.add(offer.fsCore__Lending_Application_Number__c);
            }
        }

        Map<Id, fsCore__Lending_Application__c> applicationMap = getApplicationsForOptionUpdate(applicationIds, 1);

        for (fsCore__Lending_Application_Pricing_Offer__c offer : pricingOffersForOption1){
            fsCore.CalculatorObject calcResult = getCalculationForOption(offer);
            
            if(!calcResult.getIsSuccess()){
                throw new CustomException('Additional pricing option #1 calculation failed with error(s) : ' + String.join(calcResult.getErrorStack(), ';'));
            } 
            else {
                fsCore__Lending_Application__c application = applicationMap.get(offer.fsCore__Lending_Application_Number__c);
                application.Pricing_Option_1__c = offer.fsCore__Pricing_Name__r.Payment_Increase_For_Option_1__c.toPlainString() + '% Higher Monthly Loan Payment';
                application.Pricing_Option_1_Payment_Amount__c = calcResult.getCalculatorMain().fsCore__Payment_Amount__c;
                application.Pricing_Option_1_Finance_Charge__c = calcResult.getCalculatorMain().fsCore__Total_Finance_Charge__c;
                application.Pricing_Option_1_Number_of_Payments__c = calcResult.getCalculatorMain().fsCore__Number_Of_Payments__c;
            }
        }
        Database.update(applicationMap.values());
    }

    @future
    public static void generateOption2(Set<Id> pPricingOfferIds){
        List<fsCore__Lending_Application_Pricing_Offer__c> pricingOffersForOption2 = new List<fsCore__Lending_Application_Pricing_Offer__c>();
        Set<Id> applicationIds = new Set<Id>();
        
        for (fsCore__Lending_Application_Pricing_Offer__c offer : getPricingOffers(pPricingOfferIds)){
            if (offer.fsCore__Pricing_Name__r.Is_Generate_Additional_Pricing__c && offer.fsCore__Pricing_Name__r.Payment_Increase_For_Option_2__c != null){
                offer.fsCore__Payment_Amount__c = getIncreasedPaymentAmount(offer.fsCore__Payment_Amount__c, offer.fsCore__Pricing_Name__r.Payment_Increase_For_Option_2__c);
                pricingOffersForOption2.add(offer);
                applicationIds.add(offer.fsCore__Lending_Application_Number__c);
            }
        }

        Map<Id, fsCore__Lending_Application__c> applicationMap = getApplicationsForOptionUpdate(applicationIds, 2);

        for (fsCore__Lending_Application_Pricing_Offer__c offer : pricingOffersForOption2){
            fsCore.CalculatorObject calcResult = getCalculationForOption(offer);

            if(!calcResult.getIsSuccess()){
                throw new CustomException('Additional pricing option #2 calculation failed with error(s) : ' + String.join(calcResult.getErrorStack(), ';'));
            } 
            else {
                fsCore__Lending_Application__c application = applicationMap.get(offer.fsCore__Lending_Application_Number__c);
                application.Pricing_Option_2__c = offer.fsCore__Pricing_Name__r.Payment_Increase_For_Option_2__c.toPlainString() + '% Higher Monthly Loan Payment';
                application.Pricing_Option_2_Payment_Amount__c = calcResult.getCalculatorMain().fsCore__Payment_Amount__c;
                application.Pricing_Option_2_Finance_Charge__c = calcResult.getCalculatorMain().fsCore__Total_Finance_Charge__c;
                application.Pricing_Option_2_Number_of_Payments__c = calcResult.getCalculatorMain().fsCore__Number_Of_Payments__c;
            }
        }
        
        Database.update(applicationMap.values());
    }
    
    private static List<fsCore__Lending_Application_Pricing_Offer__c> getPricingOffers(Set<Id> pPricingOfferIds){
        fsCore.DynamicQueryBuilder offersQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application_Pricing_Offer__c.getName())
                                              .addFields()
                                              .addField('fsCore__Lending_Application_Number__r.fsCore__Product_Family__c')
                                              .addField('fsCore__Lending_Application_Number__r.fsCore__Branch_Code_Formula__c')
                                              .addField('fsCore__Lending_Application_Number__r.fsCore__Holiday_Adjustment_Daily_Cycle__c')
                                              .addField('fsCore__Pricing_Name__r.Is_Generate_Additional_Pricing__c')
                                              .addField('fsCore__Pricing_Name__r.Payment_Increase_For_Option_1__c')
                                              .addField('fsCore__Pricing_Name__r.Payment_Increase_For_Option_2__c')
                                              .addWhereConditionWithBind(1,'Id','IN','pPricingOfferIds')
                                              .addWhereConditionWithValue(2,'fsCore__Is_Accepted__c','=',true);

        List<fsCore__Lending_Application_Pricing_Offer__c> pricingOffers = (List<fsCore__Lending_Application_Pricing_Offer__c>) Database.query(offersQuery.getQueryString());
        return pricingOffers;
    }
    
    private static Decimal getIncreasedPaymentAmount(Decimal pCurrentPaymentAmount, Decimal pIncreasePercentage){
        Decimal increasedPaymentAmount = pCurrentPaymentAmount * (1 + (pIncreasePercentage * 0.01));
        //increasedPaymentAmount = increasedPaymentAmount.round(System.RoundingMode.DOWN);
        increasedPaymentAmount = increasedPaymentAmount.round(System.RoundingMode.HALF_EVEN); //Email issues reported on 6/24/2019
        return increasedPaymentAmount;
    }
    
    private static Map<Id, fsCore__Lending_Application__c> getApplicationsForOptionUpdate(Set<Id> pApplicationIds, Integer pOptionNumber){
        Map<Id, fsCore__Lending_Application__c> applicationMap = new Map<Id, fsCore__Lending_Application__c>();
        
        if (pOptionNumber == 1){
            applicationMap = new Map<Id, fsCore__Lending_Application__c>(
                                      [SELECT Id, Pricing_Option_1__c
                                            , Pricing_Option_1_Payment_Amount__c
                                            , Pricing_Option_1_Finance_Charge__c
                                            , Pricing_Option_1_Number_of_Payments__c
                                         FROM fsCore__Lending_Application__c
                                        WHERE Id IN :pApplicationIds]);
        }
        else if (pOptionNumber == 2){
            applicationMap = new Map<Id, fsCore__Lending_Application__c>(
                                      [SELECT Id, Pricing_Option_2__c
                                            , Pricing_Option_2_Payment_Amount__c
                                            , Pricing_Option_2_Finance_Charge__c
                                            , Pricing_Option_2_Number_of_Payments__c
                                         FROM fsCore__Lending_Application__c
                                        WHERE Id IN :pApplicationIds]);
        }
        
        return applicationMap;
    }

    private static fsCore.CalculatorObject getCalculationForOption(fsCore__Lending_Application_Pricing_Offer__c pPricingOffer){
        pPricingOffer.fsCore__Number_Of_Payments__c = 0;
        
        fsCore.PricingOfferCalculator pricingCalc = new fsCore.PricingOfferCalculator(pPricingOffer);
        pricingCalc.setProductFamily(pPricingOffer.fsCore__Lending_Application_Number__r.fsCore__Product_Family__c);
        pricingCalc.setBranchCode(pPricingOffer.fsCore__Lending_Application_Number__r.fsCore__Branch_Code_Formula__c);
        pricingCalc.setHolidayAdjustmentMethod(pPricingOffer.fsCore__Lending_Application_Number__r.fsCore__Holiday_Adjustment_Daily_Cycle__c);
        pricingCalc.setSkipAPRCalculation(true);
        pPricingOffer = pricingCalc.calculate(fsCore.Constants.CALCULATE_NUMBER_OF_PAYMENTS);

        return pricingCalc.getCalculatorObject();
    }
    
}