/**
* Class Name  : VCLBAVFailedJob
* Description : This batch job withdraws application if BAV Failed for VCL
* Author      : Financial Spectra
*
*/
global with sharing class VCLBAVFailedJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'VCLBAVFailedJob';
    
    global VCLBAVFailedJob(){
        setJobQuery(getDefaultQuery());
    }
    
    private fsCore.DynamicQueryBuilder getQuery(){
        Date newDate = Date.today().addDays(1);
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.Application_Bank_Account_Verification__c.getName())
            .addField('Id')
            .addField('Verification_Status__c')
            .addField('Lending_Application_Name__c')
            .addField('BAV_Withdraw_Date__c')
            .addWhereConditionWithValue(1, 'BAV_Withdraw_Date__c', '!=', null)
            .addWhereConditionWithValue(2, 'Verification_Status__c', '!=', 'Verified')
            .addWhereConditionWithValue(3, 'Verification_Status__c', '!=', 'Failed')
            .addWhereConditionWithValue(4, 'BAV_Withdraw_Date__c', '<',newDate);
        
        return jobQuery;
    }        
    
    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }
    
    global override void setParameterizedJobQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        setJobQuery(jobQuery.getQueryString());
    }
    
    global override String getClassName(){
        return CLASS_NAME;
    }
    
    global override void startJob(Database.BatchableContext pContext){}
    
    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug(loggingLevel.DEBUG, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.DEBUG, 'Scope Count : ' + pScope.size());
        
        if (pScope.size() == 0){ return null; }
        
        Set<id> applicationIds = new Set<id>();
        
        for (Application_Bank_Account_Verification__c bav : (List<Application_Bank_Account_Verification__c>)pScope){
            applicationIds.add(bav.Lending_Application_Name__c);   
        }
        
        
        
        
        System.debug(LOGGINGLevel.ERROR,'BAV SIZE '+ pScope.size());
        if(pScope.size()>0){
            List<Application_Bank_Account_Verification__c> bavList = new List<Application_Bank_Account_Verification__c>();
            
            Map<id,fsCore__Lending_Application__c> lendingAppUpdMap = new Map<id,fsCore__Lending_Application__c>();
            Map<id,fsCore__Lending_Application__c> lendingAppMap = new Map<id,fsCore__Lending_Application__c>([Select id 
                                                                                                               ,fsCore__Application_Status__c
                                                                                                               ,Withdraw_Reason__c
                                                                                                               ,Name
                                                                                                               from fsCore__Lending_Application__c
                                                                                                               where id in :applicationIds]);
            
            
            for(Application_Bank_Account_Verification__c bav : (List<Application_Bank_Account_Verification__c>)pScope){
                System.debug(LOGGINGLevel.ERROR,'inside BAV Loop'+ bav.BAV_Withdraw_Date__c);
                
                
                System.debug(LOGGINGLevel.ERROR,'inside if Loop'+ bav.BAV_Withdraw_Date__c);
                bav.Verification_Status__c = 'Failed';
                bavList.add(bav);
                
                lendingAppMap.get(bav.Lending_Application_Name__c).fsCore__Application_Status__c = 'Withdrawn';
                lendingAppMap.get(bav.Lending_Application_Name__c).Withdraw_Reason__c = 'No Activity';
                
                lendingAppUpdMap.put(bav.Lending_Application_Name__c,lendingAppMap.get(bav.Lending_Application_Name__c));
                // System.debug(LOGGINGLevel.ERROR,'Name of App'+ app.Name);
                
                System.debug(LOGGINGLevel.ERROR,'Last if Loop'+ bav.BAV_Withdraw_Date__c);   
                
            }
            
            System.debug(LOGGINGLevel.ERROR,'before bav list'+ bavList);
            
            
            Database.update(bavList);
            System.debug(LOGGINGLevel.ERROR,'after bav list'+ lendingAppUpdMap);  
            try{ 
                Database.update(lendingAppUpdMap.values());
                
                System.debug(LOGGINGLevel.ERROR,'app  list updated'+ lendingAppUpdMap);
            }
            catch(Exception e){
                System.debug(LOGGINGLevel.ERROR,'app  list updated'+ e) ;
                throw e;
            }
        }                                                        
        return null;
    }
    
    global override void finishJob(Database.BatchableContext pContext){}
    
    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('VCL_BAV_Failed');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    
    
}