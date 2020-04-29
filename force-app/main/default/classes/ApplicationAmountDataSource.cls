/**
 * @File Name          : ApplicationAmountDataSource.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 3/19/2020, 9:14:56 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/19/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class ApplicationAmountDataSource implements Loop.IApexDataSource {
    
    private string amountObjectName = 'fsCore__Lending_Application_Itemization__c';
    
    public Set<string> getGlobalDescribe() {
        return new Set<string>{amountObjectName};
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

            Loop.ExternalData.FieldInfo approvedAmountUnSigned = new Loop.ExternalData.FieldInfo('fsCore__Approved_Amount_UnSigned__c', Schema.DisplayType.STRING);
            approvedAmountUnSigned.label = 'Approved Amount Unsigned';
            fields.add(approvedAmountUnSigned);     
            
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
        if (String.IsBlank(objectName) || (String.IsNotBlank(objectName) && objectName != amountObjectName)){ return queryResultSet; }
        
        AggregateResult[] domp 
            = [SELECT SUM(fsCore__Approved_Amount_Signed__c) signeddtc
                    , SUM(fsCore__Approved_Amount_UnSigned__c) unsigneddtc
               FROM fsCore__Lending_Application_Itemization__c
               WHERE fsCore__Lending_Application_Number__c = :applicationId
               AND Itemization_Code_Formula__c IN ('DRP_PAYMENT_ONE_MTH','DEDICATED_AMOUNT_CASH')];
        
        List<string> fields = new List<string>{'fsCore__Approved_Amount_Signed__c','fsCore__Approved_Amount_UnSigned__c'};
            Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, fields);
            
        
        system.debug(logginglevel.error,'domp :'+domp);
        for(AggregateResult agr : domp){
            List<string> recordValues = new List<String>();
            
            String stringValue = string.valueOf(agr.get('unsigneddtc'));
			String formattedValue = ( Decimal.valueOf(stringValue==null||stringValue.trim()==''?'0':stringValue).setScale(2) + 0.001 ).format();
			String unsigneddtcAmount = formattedValue.substring(0,formattedValue.length()-1);
            
            recordValues.add('($'+unsigneddtcAmount+')');
            recordValues.add('$'+unsigneddtcAmount);
            queryResult.rows.add(recordValues);
        }
        system.debug(logginglevel.error,'Final queryResult :'+queryResult);
        queryResultSet.add(queryResult);
        system.debug(logginglevel.error,'Final queryResultSet :'+queryResultSet);
        return queryResultSet;
    }
    
}