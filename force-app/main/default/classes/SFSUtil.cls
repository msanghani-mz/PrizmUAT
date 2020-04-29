/*
* 
* Class Name   - SFSUtil
*
*
* Developer(s) - FS 
*                
*/
global class SFSUtil {

    private static Map<String,String> StateCodeToNameMap = new Map<String,String>();
    private static Map<String,String> StateNameToCodeMap = new Map<String,String>();
    private static boolean isSandbox;

    public static String getStateCode(String pStateName){
        
        if (pStateName == null) return pStateName;

        if (StateNameToCodeMap.size() == 0){
            StateNameToCodeMap.put('Alabama', 'AL');
            StateNameToCodeMap.put('Alaska', 'AK');
            StateNameToCodeMap.put('Arizona', 'AZ');
            StateNameToCodeMap.put('Arkansas', 'AR');
            StateNameToCodeMap.put('California', 'CA');
            StateNameToCodeMap.put('Colorado', 'CO');
            StateNameToCodeMap.put('Connecticut', 'CT');
            StateNameToCodeMap.put('Delaware', 'DE');
            StateNameToCodeMap.put('Florida', 'FL');
            StateNameToCodeMap.put('Georgia', 'GA');
            StateNameToCodeMap.put('Hawaii', 'HI');
            StateNameToCodeMap.put('Idaho', 'ID');
            StateNameToCodeMap.put('Illinois', 'IL');
            StateNameToCodeMap.put('Indiana', 'IN');
            StateNameToCodeMap.put('Iowa', 'IA');
            StateNameToCodeMap.put('Kansas', 'KS');
            StateNameToCodeMap.put('Kentucky', 'KY');
            StateNameToCodeMap.put('Louisiana', 'LA');
            StateNameToCodeMap.put('Maine', 'ME');
            StateNameToCodeMap.put('Maryland', 'MD');
            StateNameToCodeMap.put('Massachusetts', 'MA');
            StateNameToCodeMap.put('Michigan', 'MI');
            StateNameToCodeMap.put('Minnesota', 'MN');
            StateNameToCodeMap.put('Mississippi', 'MS');
            StateNameToCodeMap.put('Missouri', 'MO');
            StateNameToCodeMap.put('Montana', 'MT');
            StateNameToCodeMap.put('Nebraska', 'NE');
            StateNameToCodeMap.put('Nevada', 'NV');
            StateNameToCodeMap.put('New Hampshire', 'NH');
            StateNameToCodeMap.put('New Jersey', 'NJ');
            StateNameToCodeMap.put('New Mexico', 'NM');
            StateNameToCodeMap.put('New York', 'NY');
            StateNameToCodeMap.put('North Carolina', 'NC');
            StateNameToCodeMap.put('North Dakota', 'ND');
            StateNameToCodeMap.put('Ohio', 'OH');
            StateNameToCodeMap.put('Oklahoma', 'OK');
            StateNameToCodeMap.put('Oregon', 'OR');
            StateNameToCodeMap.put('Pennsylvania', 'PA');
            StateNameToCodeMap.put('Rhode Island', 'RI');
            StateNameToCodeMap.put('South Carolina', 'SC');
            StateNameToCodeMap.put('South Dakota', 'SD');
            StateNameToCodeMap.put('Tennessee', 'TN');
            StateNameToCodeMap.put('Texas', 'TX');
            StateNameToCodeMap.put('Utah', 'UT');
            StateNameToCodeMap.put('Vermont', 'VT');
            StateNameToCodeMap.put('Virginia', 'VA');
            StateNameToCodeMap.put('Washington', 'WA');
            StateNameToCodeMap.put('West Virginia', 'WV');
            StateNameToCodeMap.put('Wisconsin', 'WI');
            StateNameToCodeMap.put('Wyoming', 'WY');

        }
        
        return StateNameToCodeMap.get(pStateName);
    }

    public static String getStateName(String pStateCode){
        
        if (pStateCode == null) return pStateCode;

        if (StateCodeToNameMap.size() == 0){
            StateCodeToNameMap.put('AL','Alabama');
            StateCodeToNameMap.put('AK','Alaska');
            StateCodeToNameMap.put('AZ','Arizona');
            StateCodeToNameMap.put('AR','Arkansas');
            StateCodeToNameMap.put('CA','California');
            StateCodeToNameMap.put('CO','Colorado');
            StateCodeToNameMap.put('CT','Connecticut');
            StateCodeToNameMap.put('DE','Delaware');
            StateCodeToNameMap.put('FL','Florida');
            StateCodeToNameMap.put('GA','Georgia');
            StateCodeToNameMap.put('HI','Hawaii');
            StateCodeToNameMap.put('ID','Idaho');
            StateCodeToNameMap.put('IL','Illinois');
            StateCodeToNameMap.put('IN','Indiana');
            StateCodeToNameMap.put('IA','Iowa');
            StateCodeToNameMap.put('KS','Kansas');
            StateCodeToNameMap.put('KY','Kentucky');
            StateCodeToNameMap.put('LA','Louisiana');
            StateCodeToNameMap.put('ME','Maine');
            StateCodeToNameMap.put('MD','Maryland');
            StateCodeToNameMap.put('MA','Massachusetts');
            StateCodeToNameMap.put('MI','Michigan');
            StateCodeToNameMap.put('MN','Minnesota');
            StateCodeToNameMap.put('MS','Mississippi');
            StateCodeToNameMap.put('MO','Missouri');
            StateCodeToNameMap.put('MT','Montana');
            StateCodeToNameMap.put('NE','Nebraska');
            StateCodeToNameMap.put('NV','Nevada');
            StateCodeToNameMap.put('OH','Ohio');
            StateCodeToNameMap.put('OK','Oklahoma');
            StateCodeToNameMap.put('OR','Oregon');
            StateCodeToNameMap.put('PA','Pennsylvania');        
            StateCodeToNameMap.put('TN','Tennessee');
            StateCodeToNameMap.put('TX','Texas');
            StateCodeToNameMap.put('UT','Utah');
            StateCodeToNameMap.put('VT','Vermont');
            StateCodeToNameMap.put('VA','Virginia');
            StateCodeToNameMap.put('WA','Washington');
            StateCodeToNameMap.put('WV','West Virginia');
            StateCodeToNameMap.put('WI','Wisconsin');
            StateCodeToNameMap.put('WY','Wyoming');
            StateCodeToNameMap.put('RI','Rhode Island');
            StateCodeToNameMap.put('SC','South Carolina');
            StateCodeToNameMap.put('SD','South Dakota');
            StateCodeToNameMap.put('NH','New Hampshire');
            StateCodeToNameMap.put('NJ','New Jersey');
            StateCodeToNameMap.put('NM','New Mexico');
            StateCodeToNameMap.put('NY','New York');
            StateCodeToNameMap.put('NC','North Carolina');
            StateCodeToNameMap.put('ND','North Dakota');
        }
        
        return StateCodeToNameMap.get(pStateCode);
    }    

    public static Boolean getIsSandbox() {
        if (isSandbox == null){
            Organization orgInfo = getOrgInfo();

            isSandbox = orgInfo.IsSandbox;
        }
        return isSandbox;
    }
    private static Organization getOrgInfo() {
       return  [SELECT Id, Name, IsSandbox FROM Organization Limit 1];
  }    
  public static Id getRecordTypeId (String pObjectApiName, String pRecordTypeName) {

    Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(pObjectApiName).getDescribe();
    Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByDeveloperName();
    Id recordTypeId;

    if(recordTypeMap.containsKey(pRecordTypeName)) {
      recordTypeId = recordTypeMap.get(pRecordTypeName).getRecordTypeId();
    }
    return recordTypeId;
  }
    

}