/**
* Class Name  : ContractBalancesRollupAction
* Description : Class to refresh the tradelines on lending application
*               by fetching the information fro NuDebt 
* Author      : Financial Spectra
*/
public with sharing class ContractBalancesRollupAction implements fsCore.ActionProcessor{
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    
    private List<fsServ__Lending_Contract__c> mContractList;
    private Map<Id,List<fsServ__Contract_Balance__c>> mContractBalancesMap;
    

    public class ContractBalancesRollupException extends Exception{}
    
    public ContractBalancesRollupAction(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
    }
    

    private void queryContracts(Set<Id> pContractIds){
        System.debug(logginglevel.error,'pContractIds :---'+pContractIds);
        fsCore.DynamicQueryBuilder contractQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Lending_Contract__c.getName())
                                              .addFields()
                                              .addWhereConditionWithBind(1,'Id','IN','pContractIds');

        mContractList = (List<fsServ__Lending_Contract__c>) Database.query(contractQuery.getQueryString());
        System.debug('mContractList:---'+mContractList);

    }  
    private void queryContractBalances(Set<Id> pContractIds){
        mContractBalancesMap = new Map<Id,List<fsServ__Contract_Balance__c>>();

        for (Id contractId : pContractIds){
            mContractBalancesMap.put(contractId, new List<fsServ__Contract_Balance__c>());
        }        

        fsCore.DynamicQueryBuilder contractBalancesQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Contract_Balance__c.getName())
                                              .addFields()
                                              .addWhereConditionWithBind(1,'fsServ__Lending_Contract_Number__c','IN','pContractIds');
 
        List<fsServ__Contract_Balance__c> contractBalancesList = (List<fsServ__Contract_Balance__c>) Database.query(contractBalancesQuery.getQueryString());
        System.debug('contractBalancesList:---'+contractBalancesList);

        for (fsServ__Contract_Balance__c balance : contractBalancesList){
            if (mContractBalancesMap.containsKey(balance.fsServ__Lending_Contract_Number__c)){
                mContractBalancesMap.get(balance.fsServ__Lending_Contract_Number__c).add(balance);
            }
        }

    }        
    //action input has the set of application ids
    public void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;
        queryContracts(mActionInput.getRecords());
        queryContractBalances(mActionInput.getRecords());        
    }
    
    public void process(){

        for (fsServ__Lending_Contract__c contract : mContractList){
            contract.ChargeOff_Recovered_Amount_MTD__c = 0;
            contract.ChargeOff_Recovered_Amount_YTD__c = 0;
            for (fsServ__Contract_Balance__c contractBalance : mContractBalancesMap.get(contract.Id)){
                   contract.ChargeOff_Recovered_Amount_MTD__c += contractBalance.fsServ__ChargedOff_Recovered_Month_To_Date__c;
                    contract.ChargeOff_Recovered_Amount_YTD__c+= contractBalance.fsServ__ChargedOff_Recovered_Year_To_Date__c;

                if (contractBalance.fsServ__Balance_Code__c == 'LATE_FEE_BALANCE'){
                    contract.Late_Fee_Received_Amount_MTD__c  = contractBalance.fsServ__Paid_Amount_Month_To_Date__c;
                    contract.Late_Fee_Received_Amount_YTD__c = contractBalance.fsServ__Paid_Amount_Year_To_Date__c;
                    contract.Late_Fee_Received_Amount_Total__c = contractBalance.fsServ__Paid_Amount__c;

                }
                if (contractBalance.fsServ__Balance_Code__c == 'PRINCIPAL_BALANCE'){
                    contract.Principal_Received_Amount_MTD__c = contractBalance.fsServ__Paid_Amount_Month_To_Date__c;
                    contract.Principal_Received_Amount_YTD__c = contractBalance.fsServ__Paid_Amount_Year_To_Date__c;
                    contract.Principal_Received_Amount_Total__c = contractBalance.fsServ__Paid_Amount__c;
                    contract.Principal_Outstanding_Amount__c = contractBalance.fsServ__Outstanding_Amount__c;
                    contract.Principal_ChargedOff_Amount__c = contractBalance.fsServ__ChargedOff_Amount__c;
                }
                if (contractBalance.fsServ__Balance_Code__c == 'INTEREST_BALANCE'){
                    contract.Interest_Received_Amount_MTD__c = contractBalance.fsServ__Paid_Amount_Month_To_Date__c;
                    contract.Interest_Received_Amount_YTD__c = contractBalance.fsServ__Paid_Amount_Year_To_Date__c;
                    contract.Interest_Received_Amount_Total__c = contractBalance.fsServ__Paid_Amount__c;
                    contract.Interest_ChargedOff_Amount__c = contractBalance.fsServ__ChargedOff_Amount__c;
                }                               
            }

        }


        Savepoint sp = Database.setSavepoint();
            try{                
                fsCore.DMLResult appSaveRslt = fsServ.LendingContractDMLWrapper.getInstance().updateData(mContractList);
            if (appSaveRslt.hasErrors())  { 
                appSaveRslt.throwError();  }   
            }
            catch (Exception e){
                System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
                Database.rollback(sp);
                mActionOutput.addError(e);
            }
        System.debug(loggingLevel.ERROR, '-- ContractBalancesRollupAction.process(-)');
    }
    
    public fsCore.ActionOutput getOutput(){
        return mActionOutput;
    }
    
    public void saveErrors(){
        if (mActionOutput.getErrors().size() > 0){
            fsCore.DiagnosticLogUtil.logErrors('ContractBalancesRollupAction', 'process', mActionOutput.getErrors());
        }
    }
    
}