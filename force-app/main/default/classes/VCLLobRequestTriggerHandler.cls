public class VCLLobRequestTriggerHandler {
    
 @future(callout=true)

   public static void VCLLobRequestService(Id pApplicationId)
   {
       fsCore.ActionOutput aOpt = new fsCore.ActionOutput();
       try{
            VCLLobRequest srvc = new VCLLobRequest(pApplicationId);
            srvc.invoke();
            srvc.saveLogs();
            srvc.saveErrors();
            HttpResponse res = srvc.getResponse();
            System.debug(loggingLevel.ERROR , res.getStatusCode());
            if(res.getStatusCode()== 200){
                aOpt.setMessage('Lob Request has been sent successfully.');
                aOpt.setIsSuccess(true);   
                System.debug(loggingLevel.ERROR ,'checkpoint 1');
            }
            else{
                System.debug(loggingLevel.ERROR ,'checkpoint 2'+res.getStatus());
                aOpt.setMessage(res.getStatus());
                aOpt.setIsSuccess(false);  
            }
           }
            
            catch(Exception e){
                System.debug(loggingLevel.ERROR ,'checkpoint 3');
                System.debug(loggingLevel.ERROR, e.getMessage());
                aOpt.addError(e.getMessage());
            }
            
        }
    }