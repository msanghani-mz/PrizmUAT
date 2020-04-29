/*
* Class Name   - ReasonLookupValueTest
* Description  - Test class for ReasonLookupValue
* Developer(s) - Financial Spectra
*/
@isTest
public class ReasonLookupValueTest {
    
    public static testmethod void test(){
        ReasonLookupValue tmp = new ReasonLookupValue();
        
        tmp.code  = 'abc';
        tmp.label = 'abc';
        tmp.isSelected = false;
    }
}