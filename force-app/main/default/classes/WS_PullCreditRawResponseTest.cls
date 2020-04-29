/* 
 * Class   : WS_PullCreditRawResponseTest 
 * Purpose : Test class for WS_PullCreditRawResponse           
 * Author  : Financial Spectra
 */
@isTest
public class WS_PullCreditRawResponseTest{

    public static testmethod void test(){

        WS_PullCreditRawResponse tmp1 = New WS_PullCreditRawResponse();
        
        WS_PullCreditRawResponse.gender tmp2 = New WS_PullCreditRawResponse.gender();
        tmp2.code = 'abc';
        
        WS_PullCreditRawResponse.sourceIndicator tmp3 = New WS_PullCreditRawResponse.sourceIndicator();
        tmp3.code = 'abc';
        tmp3.value= 'abc';
        
        WS_PullCreditRawResponse.messageType tmp4 = New WS_PullCreditRawResponse.messageType();
        tmp4.code = 'abc';
        tmp4.value= 'abc';
        
        WS_PullCreditRawResponse.addressType tmp5 = New WS_PullCreditRawResponse.addressType();
        tmp5.code = 'abc';
        tmp5.value= 'abc';
        
        WS_PullCreditRawResponse.alertCondition tmp6 = New WS_PullCreditRawResponse.alertCondition();
        tmp6.code = 'abc';
        tmp6.value= 'abc';
        
        WS_PullCreditRawResponse.EmploymentSegments tmp7 = New WS_PullCreditRawResponse.EmploymentSegments();
        tmp7.id = 'abc';
        
        WS_PullCreditRawResponse.IdMismatchAlert tmp8 = New WS_PullCreditRawResponse.IdMismatchAlert();
        tmp8.id = '123';
        tmp8.number_inquiries_last_60_days = 'abc';
        tmp8.message_type = tmp4;
        tmp8.address_type = tmp5;
        tmp8.alert_condition = tmp6;
        
        WS_PullCreditRawResponse.PersonalInfo tmp9 = New WS_PullCreditRawResponse.PersonalInfo();
        tmp9.dob = 'abc';
        tmp9.ssn = 'abc';
        tmp9.age = '10';
        tmp9.id = 'abc';
        tmp9.gender = tmp2;
        tmp9.source_indicator = tmp3;
        
        WS_PullCreditRawResponse.SubjectSegments tmp10 = New WS_PullCreditRawResponse.SubjectSegments();
        tmp10.id_mismatch_alert_XXXXX = new List<WS_PullCreditRawResponse.IdMismatchAlert>{tmp8};
        tmp10.employment_segments_XXXXX = new List<WS_PullCreditRawResponse.EmploymentSegments>{tmp7};
    }
}