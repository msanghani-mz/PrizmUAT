/**
 * @File Name          : LendingContractDeletion.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/11/2019, 8:25:28 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/11/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class LendingContractDeletionUtil{
    
    /**
    * @description This methoed will delete all the child & the contract information.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 11/11/2019 
    * @param pContractsNumbers 
    * @return void 
    **/
    public static void deleteContract(Set<String> pContractsNumbers){
        List<fsServ__Lending_Contract__c> lendingContracts = [Select id from fsServ__Lending_Contract__c where Name IN: pContractsNumbers ];
        deleteContractChilds(pContractsNumbers);
        delete lendingContracts;
    }


    /**
    * @description This methoed will only delete the child information and will not delete the contract object record.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 11/11/2019 
    * @param pContractsNumbers 
    * @return void 
    **/
    public static void deleteContractChilds(Set<String> pContractsNumbers){
        List<fsServ__Lending_Contract__c> lendingContracts = [Select id from fsServ__Lending_Contract__c where Name IN: pContractsNumbers ];
        Set<Id> contractIds =new Set<Id>(); 
        for(fsServ__Lending_Contract__c contract : lendingContracts){
            contractIds.add(contract.id);
        }
        
        List<fsCore__Assignment__c> assignments = [Select id from fsCore__Assignment__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        
        List<fsCore__Outbound_Payment__c> outboundPayments = [Select id,fsServ__Payment_Batch_Number__c from fsCore__Outbound_Payment__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        Set<Id> paymntBatchesSet = new Set<Id>();
        for(fsCore__Outbound_Payment__c outboundPayment : outboundPayments){
            paymntBatchesSet.add(outboundPayment.fsServ__Payment_Batch_Number__c);
        }
        
        List<fsCore__Lending_Document_Record__c> docRecords = [Select id from fsCore__Lending_Document_Record__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Transaction_Balance_Allocation__c> trnxBalAllocations = [Select id from fsServ__Contract_Transaction_Balance_Allocation__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Transaction__c> conTrnxs = [Select id from fsServ__Contract_Transaction__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        
        List<fsServ__Transaction_Processing_Queue__c> trnxQueues = [Select id from fsServ__Transaction_Processing_Queue__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        //Set<fsServ__Transaction_Processing_Queue__c> trnxQueueSet = new Set<fsServ__Transaction_Processing_Queue__c>(trnxQueues);
        Set<Id> trnxQueueSet = new Set<Id>();
        for(fsServ__Transaction_Processing_Queue__c trnxQueue : trnxQueues){
            trnxQueueSet.add(trnxQueue.id);
        }
        List<fsServ__Transaction_Processing_Parameter__c> trnxParameters = [Select id from fsServ__Transaction_Processing_Parameter__c where fsServ__Transaction_Queue_Name__c IN :trnxQueueSet]; //make trnxQueueSet
        
        List<fsServ__Contract_Stage__c> conStages = [Select id from fsServ__Contract_Stage__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Draw_Preference__c> conDrawPrefrences = [Select id from fsServ__Contract_Draw_Preference__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Holiday_Preference__c> conHolidayPrefrences = [Select id from fsServ__Contract_Holiday_Preference__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Payment_Preference__c> conPaymentPrefrences = [Select id from fsServ__Contract_Payment_Preference__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Rate_Preference__c> conRatePrefrences = [Select id from fsServ__Contract_Rate_Preference__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Repayment_Schedule__c> conRepaymentPrefrences = [Select id from fsServ__Contract_Repayment_Schedule__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Repayment__c> conRepayments = [Select id from fsServ__Contract_Repayment__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Payoff_Quote_Detail__c> conPayoffQuoteDetails = [Select id from fsServ__Contract_Payoff_Quote_Detail__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Payoff_Quote__c> conPayoffQuotes = [Select id from fsServ__Contract_Payoff_Quote__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Itemization__c> conItemizations = [Select id from fsServ__Contract_Itemization__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Due__c> conDues = [Select id from fsServ__Contract_Due__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Balance__c> conBalances = [Select id from fsServ__Contract_Balance__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Fee_Tier__c> conFeeTiers = [Select id from fsServ__Contract_Fee_Tier__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Fee__c> conFees = [Select id from fsServ__Contract_Fee__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Insurance__c> conInsurances = [Select id from fsServ__Contract_Insurance__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        
        List<fsServ__Inbound_Payment__c> inboundPayments = [Select id,fsServ__Payment_Batch_Number__c from fsServ__Inbound_Payment__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        Set<id> paymentBatchesSet = new Set<Id>();
        for(fsServ__Inbound_Payment__c inboundPayment : inboundPayments){
            paymentBatchesSet.add(inboundPayment.fsServ__Payment_Batch_Number__c);
        }
        List<fsServ__Payment_Batch__c> paymentBatches = [Select id from fsServ__Payment_Batch__c where id IN: paymentBatchesSet or id IN :paymentBatchesSet]; 
        List<fsServ__Contract_Investment_Balance__c> investmentBals = [Select id from fsServ__Contract_Investment_Balance__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Investment_Transaction__c> investmentTrnxs = [Select id from fsServ__Contract_Investment_Transaction__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Investment__c> investments = [Select id from fsServ__Contract_Investment__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        //Set<fsServ__Contract_Investment__c>  investmentContractsSet = new Set<fsServ__Contract_Investment__c>(investments); 
        Set<Id>  investmentContractsSet = new Set<Id>(); 
        for(fsServ__Contract_Investment__c investment :investments){
            investmentContractsSet.add(investment.id);
        }
        List<fsServ__Contract_Investment_Charge__c> investmentCharges = [Select id from fsServ__Contract_Investment_Charge__c where fsServ__Contract_Investment_Number__c IN :investmentContractsSet];  //make investmentContractsSet
        
        List<fsServ__Contract_Collateral__c> conCollaterals = [Select id from fsServ__Contract_Collateral__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Direct_Debit__c> conDirectDebits = [Select id from fsServ__Contract_Direct_Debit__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Disbursement__c> conDisbursements = [Select id from fsServ__Contract_Disbursement__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        List<fsServ__Contract_Customer__c> conCustomers = [Select id from fsServ__Contract_Customer__c where fsServ__Lending_Contract_Number__c IN :contractIds];
        
        
        delete assignments;
        delete paymentBatches;
        delete outboundPayments;
        delete docRecords;
        delete trnxBalAllocations;
        delete conTrnxs;
        delete trnxParameters;
        delete trnxQueues;
        delete conStages;
        delete conDrawPrefrences;
        delete conHolidayPrefrences;
        delete conPaymentPrefrences;
        delete conRatePrefrences;
        delete conRepaymentPrefrences;
        delete conRepayments;
        delete conPayoffQuoteDetails;
        delete conPayoffQuotes;
        delete conItemizations;
        delete conDues;
        delete conBalances;
        delete conFeeTiers;
        delete conFees;
        delete conInsurances;
        delete inboundPayments;
        delete investmentBals;
        delete investmentTrnxs;
        delete investmentCharges;
        delete investments;
        delete conCollaterals;
        delete conDirectDebits;
        delete conDisbursements;
        delete conCustomers;
    }
}