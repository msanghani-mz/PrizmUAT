/* 
* Class   : WS_PullEFXCreditResponseTest 
* Purpose : Test class for WS_PullEFXCreditResponse           
* Author  : Financial Spectra
*/
@isTest
public class WS_PullEFXCreditResponseTest{
    public static testmethod void test(){
        WS_PullEFXCreditResponse.parse('{ "name":"John", "age":30, "city":"New York"}');
    }
}