global class TwilioCommunications {

    
    global static TwilioMessage sendSMS(String fromPhone, String toPhone, String sms) {
     
         TwilioConfig__c config = TwilioConfig__c.getOrgDefaults(); 
        
        TwilioRestClient client = TwilioAPI.getDefaultClient();
        
        /*
         * Only Supports US numbers. 
         */ 
        
        if(!toPhone.startsWith('+1')){
            
            toPhone = '+1'+toPHone;
        }
        
        if (fromPhone.startsWith('+1') == False) {
            
            fromPhone = '+1'+fromPhone;
        }        
        
        System.debug('**fromPhone-->'+fromPhone);
        Map<String,String> properties = new Map<String,String>(); 
        properties.put('To',toPhone); 
        properties.put('From',fromPhone);
        properties.put('Body',sms);
        
             
          TwilioMessage message = client.getAccount().getMessages().create(properties); 
          system.debug('message-->'+message);
          return message ;
    }
    
    global static TwilioCall sendVoiceBroadCast(String fromPhone, String toPhone,String url){
        
        TwilioConfig__c config = TwilioConfig__c.getOrgDefaults(); 
        
        TwilioRestClient client = TwilioAPI.getDefaultClient();
        
        System.debug('**fromPhone-->'+fromPhone);
        System.debug('**toPhone-->'+toPhone);
        
        if(toPhone != null && toPhone.startsWith('+1') == False){
            
            toPhone = '+1'+toPHone;
        }
        
        if(fromPhone != null && fromPhone.startsWith('+1') == False){
            
            fromPhone = '+1'+fromPHone;
        }
        
        System.debug('**fromPhone-->'+fromPhone);
        System.debug('**toPhone-->'+toPhone);
        
         Map<String,String> params = new Map<String,String>(); 
           params.put('To',toPhone); 
           params.put('From',fromPhone); 
           params.put('MachineDetection','DetectMessageEnd');
           params.put('Url',url);
                      
             
           TwilioCall call = client.getAccount().getCalls().create(params); 
           system.debug('voice-->'+call);
           return call; 
    }
}