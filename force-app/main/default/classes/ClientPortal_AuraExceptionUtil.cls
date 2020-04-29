public class ClientPortal_AuraExceptionUtil {
  public static void throwAuraException(String message) {
    checkAndThrowAuraHandledException(message);
  }

  public static void checkAndThrowAuraHandledException(String error) {
    checkAndThrowAuraHandledException(new List<String>{error});
  }

  public static void checkAndThrowAuraHandledException(List<String> errors) {
    if (errors.isEmpty()) {
      return;
    }
    String errorMessage = '';
    for(String error: errors){
      errorMessage += error+'\n';
    }
    if(String.isEmpty(errorMessage)){
      return;
    }
    AuraHandledException auraException =
        new AuraHandledException(errorMessage);
    // Using setmessage so this can be used for assert statements in test methods. If not set,
    // by default, we see "Script-thrown exception".
    auraException.setMessage(errorMessage);
    throw auraException;
  }
}