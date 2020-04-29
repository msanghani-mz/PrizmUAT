public class InitiateHardPull {
    
    @AuraEnabled
    public static String getHardPull(id appId){
        
        fsCore.ActionOutput aOpt = new fsCore.ActionOutput();
        try{
            VCLHardPull srvc = new VCLHardPull(appId);
            srvc.invoke();
            srvc.saveLogs();
            srvc.saveErrors();
            HttpResponse res = srvc.getResponse();
            System.debug(loggingLevel.ERROR , res.getStatusCode());
            if(res.getStatusCode()== 200){
                aOpt.setMessage('Hard Pull has been initiated successfully.');
                aOpt.setIsSuccess(true);   
                System.debug(loggingLevel.ERROR ,'InitiateHardPull 1');
            }
            else{
                System.debug(loggingLevel.ERROR ,'InitiateHardPull 2'+res.getStatus());
                aOpt.setMessage(res.getStatus());
                aOpt.setIsSuccess(false);  
            }
            
            
        } 
        catch(Exception e){
            System.debug(loggingLevel.ERROR ,'InitiateHardPull 3');
            System.debug(loggingLevel.ERROR, e.getMessage());
            aOpt.addError(e.getMessage());
            
        }  
        
        return aOpt.getJSONString();
    }
    
}