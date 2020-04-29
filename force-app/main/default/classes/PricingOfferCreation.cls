/**
 * Class Name  : PricingOfferCreation
 * Description : This class generates accepted pricing by changing 
 *               the payment amount to the accepted draft amount
 * Author      : Financial Spectra
 * 
 */
public class PricingOfferCreation {
    
    /*PricingOfferCreation p  =  new PricingOfferCreation();
p.createPricingOffer('a1k0W00000FCk9FQAT', 1500);*/
    public static void createPricingOffer(ID pAppId, decimal pPaymentAmount){
    Set<Id> applicationIdSet = new Set<Id>();
    applicationIdSet.add(pAppId);
    
    fsCore.DynamicQueryBuilder applicationQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
        .addFields()
        .addWhereConditionWithBind(1,'Id','IN','applicationIdSet');

    List<fsCore__Lending_Application__c> applicationList = (List<fsCore__Lending_Application__c>)Database.query(applicationQuery.getQueryString());
        
    Set<Id> pricingIdSet = new Set<Id>();
    pricingIdSet.add(applicationList[0].fsCore__Pricing_Name__c);        
    fsCore.DynamicQueryBuilder pricingSetupQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Pricing_Setup__c.getName())
        .addFields()
        .addWhereConditionWithBind(1,'Id','IN','pricingIdSet');
    
    List<fsCore__Pricing_Setup__c> pricingSetupList = (List<fsCore__Pricing_Setup__c>)Database.query(pricingSetupQuery.getQueryString());
    
    fsCore.PricingOfferGenerator poGen= new fsCore.PricingOfferGenerator(applicationList[0], pricingSetupList[0]);
    poGen.setDefaultInputParameters();
    
    fsCore.PricingOfferInputObject poInputObj = new fsCore.PricingOfferInputObject();
    poInputObj.setBranchCode(applicationList[0].fsCore__Branch_Code_Formula__c);
    poInputObj.financedAmount = applicationList[0].fsCore__Actual_Financed_Amount__c ; 
    poInputObj.prepaidfee = applicationList[0].fsCore__Actual_Prepaid_Fee__c ; 
    poInputObj.financeFee = applicationList[0].fsCore__Actual_Finance_Fee__c ; 
    poInputObj.rate = applicationList[0].fsCore__Rate__c ; 
    poInputObj.numberOfPayments = (Integer)applicationList[0].fsCore__Number_Of_Payments__c ; 
    poInputObj.paymentCycle = applicationList[0].fsCore__Payment_Cycle__c ; 
    poInputObj.paymentAmount = pPaymentAmount;
    poInputObj.contractStartDate = applicationList[0].fsCore__Contract_Date__c ; 
    poInputObj.firstPaymentDate = applicationList[0].fsCore__Payment_Start_Date__c ; 
    poInputObj.secondPaymentDate = applicationList[0].fsCore__Payment_Start_Date_2__c ; 
    
    
    poGen.setInputParameters(poInputObj);
    poGen.generateOffer();
    
    poGen.saveOffer();
    poGen.acceptOffer();
    poGen.calculateAPR();
    }
}