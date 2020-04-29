/**
 * @File Name          : ApplicationChargeDataSource.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/25/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class ApplicationChargeDataSource implements Loop.IApexDataSource {
    
    private string chargeObjectName = 'fsCore__Lending_Application_Itemization__c';
    
    public Set<string> getGlobalDescribe() {
        return new Set<string>{chargeObjectName};
            }
    
    public Set<string> getChildRelationships(string objectName) {
        return new Set<string>();
    }
    
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objectNames) {
        List<Loop.ExternalData.DataObject> describeObjectResults = new List<Loop.ExternalData.DataObject>();
        
        for (string objectName : objectNames) {
            // Declare variable to store field data for the object
            List<Loop.ExternalData.FieldInfo> fields = new List<Loop.ExternalData.FieldInfo>();
            
            fields.add(new Loop.ExternalData.FieldInfo('Id', Schema.DisplayType.ID));
            
            Loop.ExternalData.FieldInfo approvedAmountSigned = new Loop.ExternalData.FieldInfo('fsCore__Approved_Amount_Signed__c', Schema.DisplayType.STRING);
            approvedAmountSigned.label = 'Approved Amount Signed';
            fields.add(approvedAmountSigned);          
            
            // Declare variable to add to results list
            Loop.ExternalData.DataObject describeObjectResult = new Loop.ExternalData.DataObject(objectName, fields);
            
            // Add to results list
            describeObjectResults.add(describeObjectResult);
        }
        
        return describeObjectResults;
    }
    
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        Id applicationId = requestInfo.RecordId; //assuming that recordId is the applicationId
        
        Loop.ExternalData.QueryResultSet queryResultSet = new Loop.ExternalData.QueryResultSet();
        
        system.debug(logginglevel.ERROR, requestInfo.GetObjectNames().size());
        if (requestInfo.GetObjectNames() == null){ return queryResultSet; }
        if (requestInfo.GetObjectNames().size() > 1 || requestInfo.GetObjectNames().size() < 1){
            return queryResultSet; 
        }
        
        String objectName = requestInfo.GetObjectNames().get(0);
        if (String.IsBlank(objectName) || (String.IsNotBlank(objectName) && objectName != chargeObjectName)){ return queryResultSet; }
        
        AggregateResult[] charges 
            = [SELECT SUM(fsCore__Approved_Amount_Signed__c) total
               FROM fsCore__Lending_Application_Itemization__c
               WHERE fsCore__Lending_Application_Number__c = :applicationId
               AND Itemization_Code_Formula__c IN ('PREPAID_FINANCE_CHARGE','ORIGINATION_FEE')];
        
        List<string> fields = new List<string>{'fsCore__Approved_Amount_Signed__c'};
            Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, fields);
            
            
        system.debug(logginglevel.error,'charges :'+charges);
        for(AggregateResult agr : charges){
            List<string> recordValues = new List<String>();
            recordValues.add('$'+(String.valueOf(agr.get('total'))));
            queryResult.rows.add(recordValues);
        }
        system.debug(logginglevel.error,'Final queryResult :'+queryResult);
        queryResultSet.add(queryResult);
        system.debug(logginglevel.error,'Final queryResultSet :'+queryResultSet);
        return queryResultSet;
    }
    
}