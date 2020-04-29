/*
 * Class   : WS_PullCredit
 * Purpose : This class invokes the Credit Report Pull Web Service 
 * Author  : Financial Spectra
 */
public class WS_PullCredit{

    private WS_PullCreditRequest mRequest;
    private WS_PullCreditRawResponse mTURawResponse;
    private WS_PullEFXCreditResponse mEFXResponse;
    private WS_PullCreditResponse mResponse;
    private HttpResponse mHttpResponse;
    private String mResponseBody;

    private Static String START_WITH_ARRAY = '({';
    private Static String START_WITH_OBJECT = '{';

    
    public WS_PullCredit(){}
    
    public class WS_PullCreditException extends Exception {}

    public void setRequest(WS_PullCreditRequest pWSRequest){
        mRequest = pWSRequest;
    }
    /*public void invokeTest(){

        //StaticResource sr= [select id,body from StaticResource Where Name = 'Credit_Pull_TEMP_Test'];
        StaticResource sr= [select id,body from StaticResource Where Name = 'Credit_Pull_TU_Test'];
        
        mResponseBody = sr.body.toString();
        
        
        mTURawResponse = (WS_PullCreditRawResponse)JSON.deserialize(mResponseBody, WS_PullCreditRawResponse.class);
        populateUnTypedJSON(fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
        populateUnTypedJSON(fsCore.Constants.CUSTOMER_TYPE_SECONDARY);
        String serilizedJson = JSON.serialize(mTURawResponse);
        serilizedJson = replaceUntypedNames(serilizedJson);
        mResponse = (WS_PullCreditResponse)JSON.deserialize(serilizedJson, WS_PullCreditResponse.class);
        
        System.debug(loggingLevel.ERROR, '-- mResponse : ' + mResponse);

    }*/

    public void invoke(){
        URL endPointURL = getEndPointURL(mRequest);
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endPointURL.toExternalForm());
        httpReq.setMethod(WS_Constants.GET);
        httpReq.setTimeout(60000);
        System.debug(loggingLevel.ERROR, '-- HTTP Request : ' + httpReq);
        System.debug(loggingLevel.ERROR, '-- mRequest.url_params.source : ' + mRequest.url_params.source);
        
        if (Test.isRunningTest()){ //AD DO NOT CALL CREDIT SERVICE WHILE RUNNING THE TEST
                            
            if (mRequest.url_params.source == CreditPullAction.PULL_SOURCE_TUHART){
                StaticResource sr= [select id,body from StaticResource Where Name = 'Credit_Pull_TU_Test'];
                mResponseBody = sr.body.toString();

                mTURawResponse = (WS_PullCreditRawResponse)JSON.deserialize(mResponseBody, WS_PullCreditRawResponse.class);
                
                populateUnTypedJSON(fsCore.Constants.CUSTOMER_TYPE_PRIMARY);

                populateUnTypedJSON(fsCore.Constants.CUSTOMER_TYPE_SECONDARY);

                String serilizedJson = JSON.serialize(mTURawResponse);

                serilizedJson = replaceUntypedNames(serilizedJson);

                mResponse = (WS_PullCreditResponse)JSON.deserialize(serilizedJson, WS_PullCreditResponse.class);
            }else if (mRequest.url_params.source == CreditPullAction.PULL_SOURCE_EFXHART){
                StaticResource sr= [select id,body from StaticResource Where Name = 'Credit_Pull_EFX_Test'];
                mResponseBody = sr.body.toString();

                mEFXResponse = (WS_PullEFXCreditResponse)JSON.deserialize(mResponseBody, WS_PullEFXCreditResponse.class);
                transformEFXToStdResp();
            }
        }else{
            mHttpResponse = (new Http()).send(httpReq);      
        
            System.debug(loggingLevel.ERROR, '-- HTTP Response : ' + mHttpResponse);
            System.debug(loggingLevel.ERROR, '--mRequest.url_params : ' + mRequest);

            if (mHttpResponse.getStatusCode() == 200){
                mResponseBody = mHttpResponse.getBody();
                try{
                    System.debug(loggingLevel.ERROR, '-- RAW Response : ' + mResponseBody);
                    if (mRequest.url_params.source == CreditPullAction.PULL_SOURCE_TUHART){
                        //FINALLY DESERIALIING THE JSON
                        mTURawResponse = (WS_PullCreditRawResponse)JSON.deserialize(mResponseBody, WS_PullCreditRawResponse.class);
                        
                        System.debug(loggingLevel.ERROR, '--Calling populateUnTypedJSON  ');

                        populateUnTypedJSON(fsCore.Constants.CUSTOMER_TYPE_PRIMARY);
                        
                        populateUnTypedJSON(fsCore.Constants.CUSTOMER_TYPE_SECONDARY);


                        String serilizedJson = JSON.serialize(mTURawResponse);

                        serilizedJson = replaceUntypedNames(serilizedJson);

                        mResponse = (WS_PullCreditResponse)JSON.deserialize(serilizedJson, WS_PullCreditResponse.class);
                        
                        System.debug(loggingLevel.ERROR, '-- Response : ' + mResponse);
                    }else if (mRequest.url_params.source == CreditPullAction.PULL_SOURCE_EFXHART){
                        System.debug(loggingLevel.ERROR, ' EFX ');
                        mEFXResponse = (WS_PullEFXCreditResponse)JSON.deserialize(mResponseBody, WS_PullEFXCreditResponse.class);
                        transformEFXToStdResp();
                    }                        
                } catch (Exception e){
                    System.debug(loggingLevel.ERROR, '-- IN EXCEPTION '+e);
                    mResponse = null;
                    System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
                }
                System.debug(loggingLevel.ERROR, '-- Final Response : ' + mResponse);
            }
        }
    }

    public WS_PullCreditResponse getResponse(){
        return mResponse;
    }
    public HttpResponse getHttpResponse(){
        if (Test.isRunningTest()){
            HttpResponse httpResp = new HttpResponse();
            httpResp.setStatusCode(200);
            return httpResp;
        }

        return mHttpResponse;
    }    

    private void transformEFXToStdResp(){
        System.debug(loggingLevel.ERROR, ' Now Transforming ');
        mResponse = new WS_PullCreditResponse();
        mResponse.success = mEFXResponse.success;
        mResponse.data = new WS_PullCreditResponse.CreditPullData();
        mResponse.data.pullType = mEFXResponse.data.pullType;
        mResponse.data.file = new WS_PullCreditResponse.CreditPullFile();
        mResponse.data.file.hx5 = new WS_PullCreditResponse.HX5();
        mResponse.data.file.hx5.html_reports = new WS_PullCreditResponse.HTMLReports();
        mResponse.data.file.hx5.html_reports.html_report = new WS_PullCreditResponse.HTMLReport();
        if (mEFXResponse.data.file.stratfsefxreport != null){
            if (mEFXResponse.data.file.stratfsefxreport.creditreport != null){
                if (mEFXResponse.data.file.stratfsefxreport.creditreport.printimage != null){
                    mResponse.data.file.hx5.html_reports.html_report.value = mEFXResponse.data.file.stratfsefxreport.creditreport.printimage.value;
                }
            }
        }
        mResponse.data.file.hx5.tty_reports = new WS_PullCreditResponse.TTYReports();
        mResponse.data.file.hx5.bureau_xml_data = new WS_PullCreditResponse.BureauXMLData();
        mResponse.data.file.hx5.hx5_transaction_information = new WS_PullCreditResponse.HX5TransactionInfo();

        if (mEFXResponse.data.cofile != null){
            mResponse.data.cofile = new WS_PullCreditResponse.CreditPullFile();
            mResponse.data.cofile.hx5 = new WS_PullCreditResponse.HX5();
            mResponse.data.cofile.hx5.html_reports = new WS_PullCreditResponse.HTMLReports();
            mResponse.data.cofile.hx5.html_reports.html_report = new WS_PullCreditResponse.HTMLReport();
            if (mEFXResponse.data.cofile.stratfsefxreport != null){
                if (mEFXResponse.data.cofile.stratfsefxreport.creditreport != null){
                    if (mEFXResponse.data.cofile.stratfsefxreport.creditreport.printimage != null){
                        mResponse.data.cofile.hx5.html_reports.html_report.value = mEFXResponse.data.cofile.stratfsefxreport.creditreport.printimage.value;
                    }
                }
            }
            mResponse.data.cofile.hx5.tty_reports = new WS_PullCreditResponse.TTYReports();
            mResponse.data.cofile.hx5.bureau_xml_data = new WS_PullCreditResponse.BureauXMLData();
            mResponse.data.cofile.hx5.hx5_transaction_information = new WS_PullCreditResponse.HX5TransactionInfo();



        }
        System.debug(loggingLevel.ERROR, ' after Transform: '+mResponse);
    }

    private  String replaceUntypedNames(String pJsonStr) {
        String jsonStr = pJsonStr;
        jsonStr = jsonStr.replace('inquiry_XXXXX', 'inquiry');
        jsonStr = jsonStr.replace('trade_XXXXX', 'trade');
        jsonStr = jsonStr.replace('employment_segments_XXXXX', 'employment_segments');
        jsonStr = jsonStr.replace('credit_summary_description_XXXXX', 'credit_summary_description');
        jsonStr = jsonStr.replace('address_information_XXXXX', 'address_information');
        jsonStr = jsonStr.replace('id_mismatch_alert_XXXXX', 'id_mismatch_alert');
        jsonStr = jsonStr.replace('name_information_XXXXX', 'name_information');
        jsonStr = jsonStr.replace('bureau_xml_data_XXXXX', 'bureau_xml_data');
        
        return jsonStr;
    }

    private List<Object>  getArrayList (Map<String, Object> pJsonMap, String pJsonString, String pElementName){

        List<Object> jsonList =new List<Object>();

        if(pJsonString.startsWith(START_WITH_OBJECT)){
            jsonList.add((Object)pJsonMap.get(pElementName));
        }else if(pJsonString.startsWith(START_WITH_ARRAY)){
            jsonList=(List<Object>)pJsonMap.get(pElementName);
        }      

        return jsonList;  
    }
    private void populateUnTypedJSON(String pCustomerType) {
        
        Map<String, Object> jsonObjMap =   (Map<String, Object>) JSON.deserializeUntyped(mResponseBody);

        if(jsonObjMap == null || jsonObjMap.size() == 0) {
                throw new WS_PullCreditException(Label.ERROR_JSON_EMPTY);
        } 
        system.debug(logginglevel.error,'jsonObjMap :'+jsonObjMap);

        Map<String, Object> dataMap =   (Map<String, Object>)jsonObjMap.get('data');
        Map<String, Object> fileMap;
        if (dataMap != null){
            if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){
                fileMap =   (Map<String, Object>)dataMap.get('file');       
            }else{
                fileMap =   (Map<String, Object>)dataMap.get('cofile');       
            }
         
        }
        Map<String, Object> hx5Map ;
        if (fileMap != null){
            hx5Map =   (Map<String, Object>)fileMap.get('hx5');
        }        
        Map<String, Object> bureau_xml_dataMap ;
        if (hx5Map != null){
            try{
                bureau_xml_dataMap =   (Map<String, Object>)hx5Map.get('bureau_xml_data');
                //TODO WE NEED TO POPULATE BUT WE MIGHT NOT NEED THEM AS WE SIMPLY NEED HTML CREDIT REPORT
                //mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX
                //mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX
            }catch(Exception ex){
                bureau_xml_dataMap = new Map<String, Object>();
            }

        }         
        Map<String, Object> tu_reportMap ;
        if (bureau_xml_dataMap != null){
            tu_reportMap =   (Map<String, Object>)bureau_xml_dataMap.get('tu_report');
        }           
        system.debug(logginglevel.error,'tu_reportMap :'+tu_reportMap);
        if (tu_reportMap != null){
            Map<String, Object> subject_segmentsMap =   (Map<String, Object>)tu_reportMap.get('subject_segments');
            system.debug(logginglevel.error,'subject_segmentsMap :'+subject_segmentsMap);
            if (subject_segmentsMap != null){

                string segmentName = 'name_information';
                if (subject_segmentsMap.get(segmentName) != null){
                    
                    String  nameInformationStr =  String.valueof(subject_segmentsMap.get(segmentName));
                    system.debug(logginglevel.error,segmentName +' '+nameInformationStr);
                    if (nameInformationStr != null){
                        List<Object> nameInformationObjectList = getArrayList (subject_segmentsMap, nameInformationStr, segmentName);
                            
                            List<WS_PullCreditRawResponse.NameInfo> nameInformationList =new List<WS_PullCreditRawResponse.NameInfo>();
                            for(Object nameInformationObjectObj : nameInformationObjectList ){
                                Map<String,Object> nameInformationObj  =(Map<String,Object>)nameInformationObjectObj; 
                                WS_PullCreditRawResponse.NameInfo nameInformation=new WS_PullCreditRawResponse.NameInfo();

                                String serJson = JSON.serialize(nameInformationObj);

                                nameInformation = (WS_PullCreditRawResponse.NameInfo)JSON.deserialize(serJson, WS_PullCreditRawResponse.NameInfo.class);

                                nameInformationList.add(nameInformation);
                            }
                            system.debug(logginglevel.error,'  nameInformationList === >'+nameInformationList.Size());

                            if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){
                                if (mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.name_information_XXXXX = nameInformationList;
                                }
                            }else{
                                if (mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.name_information_XXXXX = nameInformationList;
                                }
                            }

                    }
                }        
                segmentName = 'id_mismatch_alert';
                if (subject_segmentsMap.get(segmentName) != null){
                    String  idMismatchAlertStr =  String.valueof(subject_segmentsMap.get(segmentName));
                    if (idMismatchAlertStr != null){
                        List<Object> idMismatchAlertObjectList = getArrayList (subject_segmentsMap, idMismatchAlertStr, segmentName);
                            

                            List<WS_PullCreditRawResponse.IdMismatchAlert> IdMismatchAlertList =new List<WS_PullCreditRawResponse.IdMismatchAlert>();
                            for(Object idMismatchAlertObjectObj : idMismatchAlertObjectList ){
                                Map<String,Object> idMismatchAlertObj  =(Map<String,Object>)idMismatchAlertObjectObj; 
                                WS_PullCreditRawResponse.IdMismatchAlert idMismatchAlert=new WS_PullCreditRawResponse.IdMismatchAlert();

                                
                                String serJson = JSON.serialize(idMismatchAlertObj);

                                idMismatchAlert = (WS_PullCreditRawResponse.IdMismatchAlert)JSON.deserialize(serJson, WS_PullCreditRawResponse.IdMismatchAlert.class);


                                system.debug(logginglevel.error,'  idMismatchAlert === >'+idMismatchAlert);
                                //idMismatchAlert  = (WS_PullCreditRawResponse.IdMismatchAlert)idMismatchAlertObj;

                                IdMismatchAlertList.add(idMismatchAlert);
                            }
                            system.debug(logginglevel.error,'  IdMismatchAlertList === >'+IdMismatchAlertList.Size());                            
                            if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){     
                                if (mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX != null){                       
                                    mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.id_mismatch_alert_XXXXX = IdMismatchAlertList;
                                }
                            }else{
                                if (mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.id_mismatch_alert_XXXXX = IdMismatchAlertList;
                                }
                            }   

                    }
                }
                
                segmentName = 'address_information';
                if (subject_segmentsMap.get(segmentName) != null){
                    
                    String  addressInformationStr =  String.valueof(subject_segmentsMap.get(segmentName));
                    system.debug(logginglevel.error,'addressInformationStr :3:'+addressInformationStr);
                    if (addressInformationStr != null){

                        List<Object> addressInformationObjectList = getArrayList (subject_segmentsMap, addressInformationStr, segmentName);
                            
                            system.debug(logginglevel.error,'addressInformationObjectList.size '+addressInformationObjectList.size());
                            List<WS_PullCreditRawResponse.AddressInfo> addressInformationList =new List<WS_PullCreditRawResponse.AddressInfo>();
                            for(Object addressInformationObjectObj : addressInformationObjectList ){
                                Map<String,Object> addressInformationObj  =(Map<String,Object>)addressInformationObjectObj; 
                                WS_PullCreditRawResponse.AddressInfo addressInformation=new WS_PullCreditRawResponse.AddressInfo();

                                String serJson = JSON.serialize(addressInformationObj);

                                addressInformation = (WS_PullCreditRawResponse.AddressInfo)JSON.deserialize(serJson, WS_PullCreditRawResponse.AddressInfo.class);

                                addressInformationList.add(addressInformation);
                            }
                            system.debug(logginglevel.error,'  addressInformationList === >'+addressInformationList.Size());                            
                            if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){                                                        
                                if (mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.address_information_XXXXX = addressInformationList;
                                }
                            }else{
                                if (mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.address_information_XXXXX = addressInformationList;
                                }
                            }   

                    }
                }
                segmentName = 'credit_summary_description';
                if (subject_segmentsMap.get(segmentName) != null){
                    String  creditSummaryStr =  String.valueof(subject_segmentsMap.get(segmentName));
                    if (creditSummaryStr != null){
                        List<Object> creditSummaryObjectList = getArrayList (subject_segmentsMap, creditSummaryStr, segmentName);


                            List<WS_PullCreditRawResponse.CreditSummaryDescription> creditSummaryDescriptionList =new List<WS_PullCreditRawResponse.CreditSummaryDescription>();
                            for(Object creditSummaryDescriptionObjectObj : creditSummaryObjectList ){
                                Map<String,Object> creditSummaryDescriptionObj  =(Map<String,Object>)creditSummaryDescriptionObjectObj; 
                                WS_PullCreditRawResponse.CreditSummaryDescription creditSummaryDesc=new WS_PullCreditRawResponse.CreditSummaryDescription();

                                String serJson = JSON.serialize(creditSummaryDescriptionObj);

                                creditSummaryDesc = (WS_PullCreditRawResponse.CreditSummaryDescription)JSON.deserialize(serJson, WS_PullCreditRawResponse.CreditSummaryDescription.class);

                                creditSummaryDescriptionList.add(creditSummaryDesc);
                            }
                            system.debug(logginglevel.error,'  creditSummaryDescriptionList === >'+creditSummaryDescriptionList.Size());                            
                            if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){                                                        
                                if (mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.credit_summary_description_XXXXX = creditSummaryDescriptionList;
                                }
                            }else{
                                if (mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.credit_summary_description_XXXXX = creditSummaryDescriptionList;
                                }
                            }

                    }
                }   
                segmentName = 'employment_segments';
                if (subject_segmentsMap.get(segmentName) != null){
                    String  employmentSegmentsStr =  String.valueof(subject_segmentsMap.get(segmentName));
                    if (employmentSegmentsStr != null){
                        List<Object> employmentSegmentsObjectList = getArrayList (subject_segmentsMap, employmentSegmentsStr, segmentName);


                            List<WS_PullCreditRawResponse.employmentSegments> employmentSegmentsList =new List<WS_PullCreditRawResponse.employmentSegments>();
                            for(Object employmentSegmentsObjectObj : employmentSegmentsObjectList ){
                                Map<String,Object> employmentSegmentsObj  =(Map<String,Object>)employmentSegmentsObjectObj; 
                                WS_PullCreditRawResponse.employmentSegments employmentSegments=new WS_PullCreditRawResponse.employmentSegments();

                                String serJson = JSON.serialize(employmentSegmentsObj);

                                employmentSegments = (WS_PullCreditRawResponse.employmentSegments)JSON.deserialize(serJson, WS_PullCreditRawResponse.employmentSegments.class);

                                employmentSegmentsList.add(employmentSegments);
                            }
                            system.debug(logginglevel.error,'  employmentSegmentsList === >'+employmentSegmentsList.Size());                            
                            if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){                                                        
                                if (mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.employment_segments_XXXXX = employmentSegmentsList;
                                }
                            }else{
                                if (mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX != null){
                                    mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.employment_segments_XXXXX = employmentSegmentsList;
                                }
                            }

                    }
                }  
                segmentName = 'trade_segments';
                if (subject_segmentsMap.get(segmentName) != null){
                    Map<String, Object> trade_segmentsMap =   (Map<String, Object>)subject_segmentsMap.get(segmentName);
                    segmentName = 'trade';
                    if (trade_segmentsMap.get(segmentName) != null){
                        String  tradeSegmentsStr =  String.valueof(trade_segmentsMap.get(segmentName));
                        if (tradeSegmentsStr != null){
                            List<Object> tradeSegmentsObjectList = getArrayList (trade_segmentsMap, tradeSegmentsStr, segmentName);


                                List<WS_PullCreditRawResponse.Trade> tradeSegmentsList =new List<WS_PullCreditRawResponse.Trade>();
                                for(Object tradeSegmentsObjectObj : tradeSegmentsObjectList ){
                                    Map<String,Object> tradeSegmentsObj  =(Map<String,Object>)tradeSegmentsObjectObj; 
                                    WS_PullCreditRawResponse.Trade tradeSegments=new WS_PullCreditRawResponse.Trade();

                                    String serJson = JSON.serialize(tradeSegmentsObj);

                                    tradeSegments = (WS_PullCreditRawResponse.Trade)JSON.deserialize(serJson, WS_PullCreditRawResponse.Trade.class);

                                    tradeSegmentsList.add(tradeSegments);
                                }
                                system.debug(logginglevel.error,'  tradeSegmentsList === >'+tradeSegmentsList.Size());                            
                                if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){ 
                                    if (mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX != null){
                                        mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.trade_segments.trade_XXXXX = tradeSegmentsList;
                                    }
                                }else{
                                    if (mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX != null){
                                        mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.trade_segments.trade_XXXXX = tradeSegmentsList;
                                    }
                                }

                        }
                    } 

                } 
                segmentName = 'inquiry_segments';
                if (subject_segmentsMap.get(segmentName) != null){
                    Map<String, Object> inquiry_segmentsMap =   (Map<String, Object>)subject_segmentsMap.get(segmentName);
                    segmentName = 'inquiry';
                    if (inquiry_segmentsMap.get(segmentName) != null){
                        String  inquirySegmentsStr =  String.valueof(inquiry_segmentsMap.get(segmentName));
                        if (inquirySegmentsStr != null){
                            List<Object> inquirySegmentsObjectList = getArrayList (inquiry_segmentsMap, inquirySegmentsStr, segmentName);


                                List<WS_PullCreditRawResponse.inquiry> inquirySegmentsList =new List<WS_PullCreditRawResponse.inquiry>();
                                for(Object inquirySegmentsObjectObj : inquirySegmentsObjectList ){
                                    Map<String,Object> inquirySegmentsObj  =(Map<String,Object>)inquirySegmentsObjectObj; 
                                    WS_PullCreditRawResponse.inquiry inquirySegments=new WS_PullCreditRawResponse.inquiry();

                                    String serJson = JSON.serialize(inquirySegmentsObj);

                                    inquirySegments = (WS_PullCreditRawResponse.inquiry)JSON.deserialize(serJson, WS_PullCreditRawResponse.inquiry.class);

                                    inquirySegmentsList.add(inquirySegments);
                                }
                                system.debug(logginglevel.error,'  inquirySegmentsList === >'+inquirySegmentsList.Size());                            
                                if (fsCore.Constants.CUSTOMER_TYPE_PRIMARY.equals(pCustomerType)){ 
                                    if (mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX != null){
                                        mTURawResponse.data.file.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.inquiry_segments.inquiry_XXXXX = inquirySegmentsList;
                                    }
                                }else{
                                    if (mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX != null){
                                        mTURawResponse.data.cofile.hx5.bureau_xml_data_XXXXX.tu_report.subject_segments.inquiry_segments.inquiry_XXXXX = inquirySegmentsList;
                                    }
                                }

                        }
                    } 

                }                      

            }
        }        
        
    }

    private static URL getEndPointURL(WS_PullCreditRequest pWSRequest) {
        String endPointURL = 'callOut:' + WS_Constants.CREDIT_PULL_NAMED_CRED;
        endPointURL += (String.IsBlank(pWSRequest.application_number) ? '/99999999' : '/' + pWSRequest.application_number.leftPad(5,'0'));
        
        String paramString = '?';
        if (pWSRequest.url_params != null){
            if (String.IsNotBlank(pWSRequest.url_params.name)){
                paramString += ('name=' + EncodingUtil.urlEncode(pWSRequest.url_params.name, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.address)){
                paramString += ('address=' + EncodingUtil.urlEncode(pWSRequest.url_params.address, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.city)){
                paramString += ('city=' + EncodingUtil.urlEncode(pWSRequest.url_params.city, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.state)){
                paramString += ('state=' + EncodingUtil.urlEncode(pWSRequest.url_params.state, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.zip)){
                paramString += ('zip=' + EncodingUtil.urlEncode(pWSRequest.url_params.zip, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.ssn)){
                paramString += ('ssn=' + EncodingUtil.urlEncode(pWSRequest.url_params.ssn, 'UTF-8') + '&');
            }
            if (pWSRequest.url_params.birth_date != null){
                //ALWAYS USER LOWER CASE dd for date because uppercase D is day in year
                String birthDateString = fsCore.TypeUtil.getFormattedDate(pWSRequest.url_params.birth_date, 'MM/dd/YYYY');
                paramString += ('birthdate=' + EncodingUtil.urlEncode(birthDateString, 'UTF-8') + '&');
            }
            
            String format = (String.IsBlank(pWSRequest.url_params.format) ? 'JSON' : pWSRequest.url_params.format);
            paramString += ('format=' + EncodingUtil.urlEncode(format, 'UTF-8') + '&');

            String pullType = (String.IsBlank(pWSRequest.url_params.pull_type) ? 'soft' : pWSRequest.url_params.pull_type);
            paramString += ('pulltype=' + EncodingUtil.urlEncode(pullType, 'UTF-8') + '&');

            
            String pullSource = (String.IsBlank(pWSRequest.url_params.source) ? 'TUHART' : pWSRequest.url_params.source);
            paramString += ('source=' + EncodingUtil.urlEncode(pullSource, 'UTF-8'));


            if (String.IsNotBlank(pWSRequest.url_params.coName)){
                paramString += ('&'+'coname=' + EncodingUtil.urlEncode(pWSRequest.url_params.coName, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.coAddress)){
                paramString += ('coaddress=' + EncodingUtil.urlEncode(pWSRequest.url_params.coAddress, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.coCity)){
                paramString += ('cocity=' + EncodingUtil.urlEncode(pWSRequest.url_params.coCity, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.coState)){
                paramString += ('costate=' + EncodingUtil.urlEncode(pWSRequest.url_params.coState, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.coZip)){
                paramString += ('cozip=' + EncodingUtil.urlEncode(pWSRequest.url_params.coZip, 'UTF-8') + '&');
            }
            if (String.IsNotBlank(pWSRequest.url_params.cossn)){
                paramString += ('cossn=' + EncodingUtil.urlEncode(pWSRequest.url_params.cossn, 'UTF-8') + '&');
            }
            if (pWSRequest.url_params.coBirth_date != null){
                //ALWAYS USER LOWER CASE dd for date because uppercase D is day in year
                String birthDateString = fsCore.TypeUtil.getFormattedDate(pWSRequest.url_params.coBirth_date, 'MM/dd/YYYY');
                paramString += ('cobirthdate=' + EncodingUtil.urlEncode(birthDateString, 'UTF-8'));
            }            

        }
        
        endPointURL = (paramString.equals('?') ? endPointURL : endPointURL + paramString);
        return new URL(endPointURL);
    }

}