public without sharing class DynamicTemplateController{
    public String templateEmailSubject {get; set;}
    public string LeadId{get;set;}
    public string AccountId{get;set;}
    public string ProgramId{get;set;}
    public string PortfolioId{get;set;}
    public string UserId {get;set;}
    public String vfTemplateName {get;set;}
    public static Map<String,Map<String, Schema.SObjectField>> GlobalObjectFieldList {get;set;}

    public String emailTemplateContent{
        get{
            return getTemplateContent();
        }
        set;
    }
    
    public String getTemplateContent() {
        String templateContent = '';
        List<String> fieldName = new List<String>();
        
        List<EmailTemplate> emailTemplateContent = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: vfTemplateName];
        
        if(emailTemplateContent.size() > 0) {
            templateContent = emailTemplateContent.get(0).Subject +  '::Split::' + emailTemplateContent.get(0).HtmlValue;
        }
        
        if(String.isNotBlank(templateContent)) {
            Map<String,Set<String>> mapFields = getFieldMapping(generateFieldSet(templateContent));
            Map<String,sObject> mapRecords = getRecordMapping(mapFields);
            templateContent = mergeValues(templateContent, mapFields, mapRecords);
        }
        
        system.debug('templateContent>>>'+templateContent);
        return templateContent;
    }
    

    
    //processes all fields and prepares a map of fields with object
    private Map<String,Set<String>> getFieldMapping(Set<String> fieldSet){
        Map<String,Set<String>>  mapFields = new Map<String,Set<String>>();
        for(String field : fieldSet){
            String[] fieldParts = field.replace('.','-').split('-');
            if(fieldParts.size() > 0){
                system.debug('==fieldParts===' + fieldParts);
                if(!mapFields.containsKey(fieldParts[0]))
                    mapFields.put(fieldParts[0],new Set<String>());
                mapFields.get(fieldParts[0]).add(fieldParts[1]);
            }
        }
        return mapFields;
    }
    
    
    //retrieve record and put it into the MAP with object name as keyset
    private Map<String,sObject> getRecordMapping(Map<String,Set<String>>  mapFields) {
        Map<String,sObject> mapRecords = new Map<String,sObject>();
        
        mapFields.remove('$Label');
        system.debug('----------------  '+mapFields);
        //prepares query for each set and retrieve record
        for(String objectName : mapFields.keySet()) {
            Set<String> fieldSet = mapFields.get(objectName);
            
            String query = '';
            for(String field : fieldSet){
                // if(!field.equalsIgnoreCase(Link)) {
                query += query.trim().length()== 0? getObjectFieldName(field,objectName) : (getObjectFieldName(field,objectName) != '' ?(',' + getObjectFieldName(field,objectName)) : '');
                    // }
                    }
            if(query != '')
                query = 'Select ' + query + ' from ';
           
                query+= objectName;
            
                query+= ' where ';
            if(!objectName.equalsIgnoreCase('Organization')){
               
              if(objectName.equalsIgnoreCase('Lead')){
                    query+=' id=\''+LeadId+'\' Limit 1';
                }
                
                if(objectName.equalsIgnoreCase('Account')){
                    query+=' id=\''+AccountId+'\' Limit 1';
                }
                
                 if(objectName.equalsIgnoreCase('nu_dse__Program__c')){
                    query+=' id=\''+ProgramId+'\' Limit 1';
                }
                
                if(objectName.equalsIgnoreCase('Portfolio__c')){
                    query+=' id=\''+PortfolioId+'\' Limit 1';
                }
                
                  if(objectName.equalsIgnoreCase('User')){
                    query+=' id=\''+UserId+'\' Limit 1';
                }
            }
            try{
                System.debug('-------------  '+query);
                List<sObject> records = database.query(query);
                if(records.size() > 0) {
                    mapRecords.put(objectName,records.get(0));
                }
            }Catch(Exception e){
                system.debug(e.getMessage());
            }
        }
        return mapRecords;
    }
    
    //merge record values in string
    private string mergeValues(String srcString, Map<String,Set<String>> mapFields, Map<String,sObject> mapRecords) {
        for(String objectName : mapFields.keySet()) {
            Set<String> fieldSet = mapFields.get(objectName);
            sObject record = mapRecords.get(objectName);
            for(String field : fieldSet) {
                String fieldString = objectName + '.' + field;
                if(srcString != Null && srcString.contains(fieldString)) {
                    system.debug('Field'+field);
                    system.debug('Record'+record);
                    String val = record != null ? getObjectFieldValue(field,record) : '';
                 
                    srcString = srcString.replace('{!' + fieldString + '}',val);
                }
            }
        }
        return srcString;
    }
    
    
    //prepares field set for email template
    private Set<String> generateFieldSet(String templateContent) {
        Set<String> fieldSet = new Set<String>();
        if(templateContent.contains('{')){
            fieldSet.addAll(getObjectInfo(templateContent));
        }
        return fieldSet;
    }
    
    //process string and prepares a list of fields
    private Set<String> getObjectInfo(string content) {
        Set<String> fieldSet = new Set<String>();
        integer index = 0;
        integer lastIndex=0;
        if(content.contains('{')){
            while(content.contains('{')){
                index = content.indexOf('{')+1;
                content = content.substring(index);
                if(content.substring(0, 1) == '!'){
                    lastIndex = content.indexOf('}');
                    fieldSet.Add(content.substring(1, lastIndex));
                }
                if(content.length()-1 != lastIndex){
                    content = content.substring(lastIndex+1);
                }
                else
                    break;
            }
        }
        return fieldSet;
    }
    
    //get API name for query
    private String getObjectFieldName(String templateFieldName,String objectName) {
        //Get field map for the record object
        Map<String, Schema.SObjectField> fieldMap = getFieldMap(objectName);
        if(fieldMap != null) {
            
            if(!fieldMap.containsKey(templateFieldName)) {
                if(templateFieldName.indexOf('Id__c') >= 0)
                    return templateFieldName.replace('Id__c','__c');
                else {
                    fieldMap = getFieldMap(templateFieldName);
                    if(fieldMap != NULL && fieldMap.containsKey('name'))
                        return templateFieldName + '.Name';
                    else
                        return '';
                }
            } else {
                String dataType = String.valueOf(fieldMap.get(templateFieldName).getDescribe().getSoapType());
                if(templateFieldName.indexOf('__c') >= 0 && dataType.equalsIgnoreCase('ID'))
                    return templateFieldName.replace('__c','__r') + '.Name';
                return templateFieldName;
            }
        }
        return '';
    }
    
    //get value of templateFieldName in record
    public String getObjectFieldValue(String templateFieldName,sObject record) {
        
        //Get field map for the record object
        Map<String, Schema.SObjectField> fieldMap = getFieldMap(String.valueOf(record.getsObjectType()));
        if(fieldMap != null) {
            //templateFieldName matches with object field
            if(fieldMap.containsKey(templateFieldName)){
                String dataType = String.valueOf(fieldMap.get(templateFieldName).getDescribe().getSoapType());
                if(templateFieldName.indexOf('__c') >= 0 && dataType.equalsIgnoreCase('ID')){
                    record = record.getSObject(templateFieldName.replace('__c','__r'));
                    return record != null ? (String)record.get('Name') : '';
                }
                return record.get(templateFieldName) != null ? String.valueOf(record.get(templateFieldName)) : '';
            }
            
            // if templateFieldName doesn't match with object field then check if it is ID field
            if(templateFieldName.indexOf('Id__c') >= 0){
                templateFieldName = templateFieldName.replace('Id__c','__c');
                return record.get(templateFieldName) != null ? String.valueOf(record.get(templateFieldName)) : '';
            }
            
            //templateFieldName contain '.' call this method recursively for referred object
            if(templateFieldName.indexOf('.') >= 0){
                String[] fields = templateFieldName.replace('.','-').split('-');
                return getObjectFieldValue(templateFieldName.replace(fields[0] + '.',''),record.getSObject(fields[0]));
            }
            
            //if none of above case
            fieldMap = getFieldMap(templateFieldName);
            if(fieldMap != Null) {
                record = record.getSObject(templateFieldName);
                return record != null ? (String)record.get('Name') : '';
            }
        }
        return '';
    }
    
    //Call GlobalDescribe to get fields for objType and add it in GlobalObjectFieldList
    private Map<String, Schema.SObjectField> getFieldMap(String objType) {
        objType = objType.toLowerCase();
        
        if(GlobalObjectFieldList == null)
            GlobalObjectFieldList = new Map<String,Map<String, Schema.SObjectField>>();
        
        if(!GlobalObjectFieldList.containsKey(objType)) {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            if(gd.containsKey(objType)) {
                GlobalObjectFieldList.put(objType,gd.get(objType).getDescribe().fields.getMap());
        }
      
    }
    
      return GlobalObjectFieldList.get(objType);
   
}
}