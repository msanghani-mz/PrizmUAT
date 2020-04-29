/* 
 * Class   : WS_PullCreditResponseTest 
 * Purpose : Test class for WS_PullCreditResponse           
 * Author  : Financial Spectra
 */
@isTest
public class WS_PullCreditResponseTest{

    public static testmethod void test(){

        WS_PullCreditResponse tmp1 = New WS_PullCreditResponse();
        
        WS_PullCreditResponse.gender tmp2 = New WS_PullCreditResponse.gender();
        tmp2.code = 'abc';
        
        WS_PullCreditResponse.sourceIndicator tmp3 = New WS_PullCreditResponse.sourceIndicator();
        tmp3.code = 'abc';
        tmp3.value= 'abc';
        
        WS_PullCreditResponse.messageType tmp4 = New WS_PullCreditResponse.messageType();
        tmp4.code = 'abc';
        tmp4.value= 'abc';
        
        WS_PullCreditResponse.addressType tmp5 = New WS_PullCreditResponse.addressType();
        tmp5.code = 'abc';
        tmp5.value= 'abc';
        
        WS_PullCreditResponse.alertCondition tmp6 = New WS_PullCreditResponse.alertCondition();
        tmp6.code = 'abc';
        tmp6.value= 'abc';
        
        WS_PullCreditResponse.EmploymentSegments tmp7 = New WS_PullCreditResponse.EmploymentSegments();
        tmp7.id = 'abc';
        
        WS_PullCreditResponse.IdMismatchAlert tmp8 = New WS_PullCreditResponse.IdMismatchAlert();
        tmp8.id = '123';
        tmp8.number_inquiries_last_60_days = 'abc';
        tmp8.message_type = tmp4;
        tmp8.address_type = tmp5;
        tmp8.alert_condition = tmp6;
        
        WS_PullCreditResponse.PersonalInfo tmp9 = New WS_PullCreditResponse.PersonalInfo();
        tmp9.dob = 'abc';
        tmp9.ssn = 'abc';
        tmp9.age = '10';
        tmp9.id = 'abc';
        tmp9.gender = tmp2;
        tmp9.source_indicator = tmp3;
        
        WS_PullCreditResponse.SubjectSegments tmp10 = New WS_PullCreditResponse.SubjectSegments();
        tmp10.id_mismatch_alert = new List<WS_PullCreditResponse.IdMismatchAlert>{tmp8};
        tmp10.employment_segments = new List<WS_PullCreditResponse.EmploymentSegments>{tmp7};
    }
}