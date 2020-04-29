@isTest
public class ClientPortal_AuraExceptionUtilTest {

     @isTest
    static void throwAuraExceptionTest(){
       
        String message = 'test';
        setupTestData();
        try{
        ClientPortal_AuraExceptionUtil.throwAuraException(message);
        }catch(Exception e){
            System.debug('###+Exception'+e);
        }
      }
    @isTest
    static void checkAndThrowAuraHandledExceptionTest(){
        setupTestData();
         String message = 'test';
         try{
        ClientPortal_AuraExceptionUtil.checkAndThrowAuraHandledException(message);
        }catch(Exception e){
            System.debug('###+Exception'+e);
        }
       
      }
    
    @testSetup
    static void setupTestData() {
       
    }
}