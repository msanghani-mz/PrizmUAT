/**
 * @File Name          : Batch_CreateNuDebtClientAndBankAcct.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/22/2019, 8:39:40 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/22/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class Batch_CreateNuDebtClientAndBankAcct implements Database.Batchable<sObject>, Database.stateful {

    Map<String, List<nu_dse__Field_mapping__c>> mDataFieldMappingMap = new Map<String, List<nu_dse__Field_mapping__c>>();
    
    Set<Id> mProgramIds = new Set<Id>();
    Set<Id> mLendingApplicationIds = new Set<Id>();

    public Batch_CreateNuDebtClientAndBankAcct() {
        init();
    }
    private void init(){
        mDataFieldMappingMap = AccountHandler.returnFieldMappingMap();
        
        system.debug(mDataFieldMappingMap);
    }
    public Batch_CreateNuDebtClientAndBankAcct(Set<Id> pLendingApplicationIds) {
        mLendingApplicationIds = pLendingApplicationIds;
        init();
    }

    private string getQuery(){
        String queryStr = 'SELECT Id '+
                            ' FROM fsCore__Lending_Application__c  '+
                           ' WHERE fsCore__Application_Status__c = \''+SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED  +'\' ' +
                           ' AND Is_Client_Created__c = FALSE ';

        if (mLendingApplicationIds.size()> 0){
            queryStr += ' AND Id in :mLendingApplicationIds ';
        }    
        system.debug(logginglevel.error,'queryStr : '+queryStr);
        return  queryStr; 
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator(getQuery());
    }
    public void execute(Database.BatchableContext bc, List<fsCore__Lending_Application__c> pLendingApplicationList) {
        system.debug(logginglevel.error,'pLendingApplicationList SIZE::::'+pLendingApplicationList.size());

        CreateNuDebtClientAndBankAcctHandler handler = new CreateNuDebtClientAndBankAcctHandler(pLendingApplicationList,mDataFieldMappingMap);
        handler.process();
        mProgramIds.addAll(handler.getProgramIds());
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('Inside Do Finish programIds ::: finish :::: ' + mProgramIds);
        if (mProgramIds.size() >0 && !Test.isRunningTest()){
            Database.executeBatch(new Batch_UpdateProgramProcessorStatus(mProgramIds), 1);
        }
    }
}