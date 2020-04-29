public without sharing class PicklistOptionsController {

  @AuraEnabled
  public static List<String> getSelectOptions(String objectName, String fieldName,
                                              Boolean doSort) {
    List<String> allOptions = new List<String>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    List<Schema.PicklistEntry> values =
      fieldMap.get(fieldName).getDescribe().getPickListValues();
    for (Schema.PicklistEntry picklistEntry : values) {
      allOptions.add(picklistEntry.getValue());
    }
    if(doSort){
      allOptions.sort();
    }
    return allOptions;
  }
}