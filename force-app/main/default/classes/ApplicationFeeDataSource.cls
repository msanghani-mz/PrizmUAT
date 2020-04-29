/**
 * @File Name          : ApplicationFeeDataSource.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/17/2019, 1:28:43 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/25/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class ApplicationFeeDataSource implements Loop.IApexDataSource {
    
    private string feeObjectName = 'fsCore__Lending_Application_Fee__c';
    
    public Set<string> getGlobalDescribe() {
        return new Set<string>{feeObjectName};
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
            
            Loop.ExternalData.FieldInfo feeNameField = new Loop.ExternalData.FieldInfo('Fee_Name_Drawloop__c', Schema.DisplayType.STRING);
            feeNameField.label = 'Fee';
            fields.add(feeNameField);
            
            Loop.ExternalData.FieldInfo feeDescField = new Loop.ExternalData.FieldInfo('Fee_Description_Drawloop__c', Schema.DisplayType.STRING);
            feeDescField.label = 'Description';
            fields.add(feeDescField);
            
            Loop.ExternalData.FieldInfo feeAmountField = new Loop.ExternalData.FieldInfo('Fee_Amount_Drawloop__c', Schema.DisplayType.STRING);
            feeAmountField.label = 'Amount';
            feeAmountField.scale = 2;
            fields.add(feeAmountField);

            Loop.ExternalData.FieldInfo feeAmountDescField = new Loop.ExternalData.FieldInfo('Fee_Amount_Text_Drawloop__c', Schema.DisplayType.STRING);
            feeAmountDescField.label = 'AmountDesc';
            fields.add(feeAmountDescField);            
            
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
        if (String.IsBlank(objectName) || (String.IsNotBlank(objectName) && objectName != feeObjectName)){ return queryResultSet; }
        
        List<fsCore__Lending_Application_Itemization__c> origFees 
            = [SELECT Id, Fee_Name_Drawloop__c
                    , Fee_Description_Drawloop__c
                    //, Fee_Amount_Drawloop__c
                    , Fee_Calculation_Percent_Default_Formula__c
                    , Fee_Amount_Text_Drawloop__c
                 FROM fsCore__Lending_Application_Itemization__c
                WHERE fsCore__Lending_Application_Number__c = :applicationId
                  AND fsCore__Fee_Name__c != null
                  AND fsCore__Approved_Amount_Unsigned__c > 0
                ORDER BY Fee_Order_Drawloop__c];

        List<fsCore__Lending_Application_Fee__c> contractualFees 
            = [SELECT Id, Fee_Name_Drawloop__c, Fee_Description_Drawloop__c, Fee_Amount_Drawloop__c,Fee_Amount_Text_Drawloop__c
                 FROM fsCore__Lending_Application_Fee__c
                WHERE fsCore__Lending_Application_Number__c = :applicationId
                  AND fsCore__Fixed_Amount_Default__c > 0
                ORDER BY Fee_Order_Drawloop__c];

        List<string> fields = new List<string>{'Id', 'Fee_Name_Drawloop__c', 'Fee_Description_Drawloop__c', 'Fee_Amount_Drawloop__c','Fee_Amount_Text_Drawloop__c' };

        Loop.ExternalData.QueryResult queryResult = new Loop.ExternalData.QueryResult(objectName, fields);

        for (fsCore__Lending_Application_Itemization__c origFee : origFees) {
            List<string> recordValues = new List<string>();
            recordValues.add(String.valueOf(origFee.Id));
            recordValues.add(origFee.Fee_Name_Drawloop__c);
            recordValues.add(origFee.Fee_Description_Drawloop__c);
            //recordValues.add(String.valueOf(origFee.Fee_Amount_Drawloop__c));
            recordValues.add(String.valueOf(origFee.Fee_Calculation_Percent_Default_Formula__c));
            recordValues.add(' %');
            queryResult.rows.add(recordValues);
        }
        for (fsCore__Lending_Application_Fee__c ctFee : contractualFees) {
            List<string> recordValues = new List<string>();
            recordValues.add(String.valueOf(ctFee.Id));
            recordValues.add(ctFee.Fee_Name_Drawloop__c);
            recordValues.add(ctFee.Fee_Description_Drawloop__c);
            recordValues.add(String.valueOf(ctFee.Fee_Amount_Drawloop__c));
            recordValues.add(ctFee.Fee_Amount_Text_Drawloop__c);
            queryResult.rows.add(recordValues);
        }
        //Check Processing Fee 
        List<string> recordValues = new List<string>();
            recordValues.add('1111');
            recordValues.add('Check Processing Fee.');
            recordValues.add('You agree to pay $15 processing fee for every payment made by check, in addition to your payment amount.  For your convenience, we also offer ACH or automatic bill payment, which is a direct debit from your bank account at no charge to you. This charge is separate from and in addition to any charges imposed by the account administrator of your Dedicated Account.');
            recordValues.add('$15.00');
            recordValues.add('per check');
            queryResult.rows.add(recordValues);
        
        system.debug(logginglevel.error,'queryResult :'+queryResult);
        queryResultSet.add(queryResult);
        return queryResultSet;
    }
    
}