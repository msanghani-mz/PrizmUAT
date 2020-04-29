/*
* Class Name   - ComboboxValueTest
* Description  - Test class for ComboboxValue
* Developer(s) - Financial Spectra
*/
@isTest
public class ComboboxValueTest {
    
    public static testmethod void test(){
        ComboboxValue tmp = new ComboboxValue();
        
        tmp.label = 'abc';
        tmp.value = 'abc';
        
        ComboboxValue tmp2 = new ComboboxValue('abc', 'abc');
        tmp2.label = 'abc';
        tmp2.value = 'abc';
    } 
}