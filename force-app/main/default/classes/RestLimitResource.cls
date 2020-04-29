public class RestLimitResource {
 public static String JSONtext {get;set;}
    
    @future(callout=true)
    public static void limitExceeded() {
    
        String JSONtext = getLimitsResp().getBody();
        system.debug('JSONtext--->'+JSONtext);
        LimitWrapper limitWrapperRecord = (LimitWrapper) JSON.deserialize(EncodingUtil.urlDecode(JSONtext, 'UTF-8'), LimitWrapper.class);
        system.debug('limitWrapperRecord--->'+limitWrapperRecord);
        
        Map<String, Decimal> limitExaggerateMap = new Map<String, Decimal>();
        
        if (limitWrapperRecord.ConcurrentAsyncGetReportInstances != null && limitWrapperRecord.ConcurrentAsyncGetReportInstances.Max != Null 
                                          && limitWrapperRecord.ConcurrentAsyncGetReportInstances.Remaining > 0   && limitWrapperRecord.ConcurrentAsyncGetReportInstances.Max >= 1 ) {
            
            Decimal percentage = (((limitWrapperRecord.ConcurrentAsyncGetReportInstances.Max - limitWrapperRecord.ConcurrentAsyncGetReportInstances.Remaining).divide(limitWrapperRecord.ConcurrentAsyncGetReportInstances.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Concurrent Async Reports', percentage);
            }
        }
        if (limitWrapperRecord.ConcurrentSyncReportRuns != null && limitWrapperRecord.ConcurrentSyncReportRuns.Max != Null && limitWrapperRecord.ConcurrentSyncReportRuns.Max >= 0
                                                                                                                                    && limitWrapperRecord.ConcurrentSyncReportRuns.Remaining >= 0 ) {
            
            Decimal percentage = (((limitWrapperRecord.ConcurrentSyncReportRuns.Max - limitWrapperRecord.ConcurrentSyncReportRuns.Remaining).divide(limitWrapperRecord.ConcurrentSyncReportRuns.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Concurrent Sync Reports', percentage);
            }
        }
        if (limitWrapperRecord.DailyApiRequests != null && limitWrapperRecord.DailyApiRequests.Max != Null && limitWrapperRecord.DailyApiRequests.Max > 0
                                                                                                                 && limitWrapperRecord.DailyApiRequests.Remaining >= 0 ) {
            
            Decimal percentage = (((limitWrapperRecord.DailyApiRequests.Max - limitWrapperRecord.DailyApiRequests.Remaining).divide(limitWrapperRecord.DailyApiRequests.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily API Requests', percentage);
            }
        }
        if (limitWrapperRecord.DailyAsyncApexExecutions != null && limitWrapperRecord.DailyAsyncApexExecutions.Max != Null && limitWrapperRecord.DailyAsyncApexExecutions.Max > 0
                                                                                                                            && limitWrapperRecord.DailyAsyncApexExecutions.Remaining >= 0 ) {
            
            Decimal percentage = (((limitWrapperRecord.DailyAsyncApexExecutions.Max - limitWrapperRecord.DailyAsyncApexExecutions.Remaining).divide(limitWrapperRecord.DailyAsyncApexExecutions.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Async Apex Executions', percentage);
            }
        }
        if (limitWrapperRecord.DailyBulkApiRequests != null && limitWrapperRecord.DailyBulkApiRequests.Max != Null && limitWrapperRecord.DailyBulkApiRequests.Max > 0
                                                                                                                         && limitWrapperRecord.DailyBulkApiRequests.Remaining >= 0  ) {
            
            Decimal percentage = (((limitWrapperRecord.DailyBulkApiRequests.Max - limitWrapperRecord.DailyBulkApiRequests.Remaining).divide(limitWrapperRecord.DailyBulkApiRequests.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Bulk API Requests', percentage);
            }
        }
        if (limitWrapperRecord.DailyDurableGenericStreamingApiEvents != null && limitWrapperRecord.DailyDurableGenericStreamingApiEvents.Max != Null
                                         && limitWrapperRecord.DailyDurableGenericStreamingApiEvents.Max > 0 && limitWrapperRecord.DailyDurableGenericStreamingApiEvents.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.DailyDurableGenericStreamingApiEvents.Max - limitWrapperRecord.DailyDurableGenericStreamingApiEvents.Remaining).divide(limitWrapperRecord.DailyDurableGenericStreamingApiEvents.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Durable Generic Streaming Events', percentage);
            }
        }
        if (limitWrapperRecord.DailyDurableStreamingApiEvents != null && limitWrapperRecord.DailyDurableStreamingApiEvents.Max != Null 
                                                        && limitWrapperRecord.DailyDurableStreamingApiEvents.Max > 0  && limitWrapperRecord.DailyDurableStreamingApiEvents.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.DailyDurableStreamingApiEvents.Max - limitWrapperRecord.DailyDurableStreamingApiEvents.Remaining).divide(limitWrapperRecord.DailyDurableStreamingApiEvents.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Durable PushTopic Streaming Events', percentage);
            }
        }
        
        if (limitWrapperRecord.DailyGenericStreamingApiEvents != null && limitWrapperRecord.DailyGenericStreamingApiEvents.Max != Null 
                                                            && limitWrapperRecord.DailyGenericStreamingApiEvents.Max > 0 && limitWrapperRecord.DailyGenericStreamingApiEvents.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.DailyGenericStreamingApiEvents.Max - limitWrapperRecord.DailyGenericStreamingApiEvents.Remaining).divide(limitWrapperRecord.DailyGenericStreamingApiEvents.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Generic Streaming Events', percentage);
            }
        }
        
        if (limitWrapperRecord.DailyStandardVolumePlatformEvents != null && limitWrapperRecord.DailyStandardVolumePlatformEvents.Max != Null 
                                                    && limitWrapperRecord.DailyStandardVolumePlatformEvents.Max > 0 && limitWrapperRecord.DailyStandardVolumePlatformEvents.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.DailyStandardVolumePlatformEvents.Max - limitWrapperRecord.DailyStandardVolumePlatformEvents.Remaining).divide(limitWrapperRecord.DailyStandardVolumePlatformEvents.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Standard-Volume Platform Events', percentage);
            }
        }
        
        if (limitWrapperRecord.DailyStreamingApiEvents != null && limitWrapperRecord.DailyStreamingApiEvents.Max != Null && limitWrapperRecord.DailyStreamingApiEvents.Max > 0
                                                                                                                        && limitWrapperRecord.DailyStreamingApiEvents.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.DailyStreamingApiEvents.Max - limitWrapperRecord.DailyStreamingApiEvents.Remaining).divide(limitWrapperRecord.DailyStreamingApiEvents.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily PushTopic Streaming Events', percentage);
            }
        }
        
        if (limitWrapperRecord.DailyWorkflowEmails != null && limitWrapperRecord.DailyWorkflowEmails.Max != Null && limitWrapperRecord.DailyWorkflowEmails.Max > 0
                                                                                                                    && limitWrapperRecord.DailyWorkflowEmails.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.DailyWorkflowEmails.Max - limitWrapperRecord.DailyWorkflowEmails.Remaining).divide(limitWrapperRecord.DailyWorkflowEmails.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Workflow Emails', percentage);
            }
        }
        
        if (limitWrapperRecord.DataStorageMB != null && limitWrapperRecord.DataStorageMB.Max != Null && limitWrapperRecord.DataStorageMB.Max > 0 && limitWrapperRecord.DataStorageMB.Remaining >= 0 ) {
            
            Decimal percentage = (((limitWrapperRecord.DataStorageMB.Max - limitWrapperRecord.DataStorageMB.Remaining).divide(limitWrapperRecord.DataStorageMB.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Data Storage (MB)', percentage);
            }
        }
        
        if (limitWrapperRecord.DurableStreamingApiConcurrentClients != null && limitWrapperRecord.DurableStreamingApiConcurrentClients.Max != Null 
                                                && limitWrapperRecord.DurableStreamingApiConcurrentClients.Max > 0 && limitWrapperRecord.DurableStreamingApiConcurrentClients.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.DurableStreamingApiConcurrentClients.Max - limitWrapperRecord.DurableStreamingApiConcurrentClients.Remaining).divide(limitWrapperRecord.DurableStreamingApiConcurrentClients.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Concurrent Durable Streaming Clients', percentage);
            }
        }
        
        if (limitWrapperRecord.FileStorageMB != null && limitWrapperRecord.FileStorageMB.Max != Null && limitWrapperRecord.FileStorageMB.Max > 0 && limitWrapperRecord.FileStorageMB.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.FileStorageMB.Max - limitWrapperRecord.FileStorageMB.Remaining).divide(limitWrapperRecord.FileStorageMB.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('File Storage (MB)', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlyAsyncReportRuns != null && limitWrapperRecord.HourlyAsyncReportRuns.Max != Null && limitWrapperRecord.HourlyAsyncReportRuns.Max > 0
                                                                                                                        && limitWrapperRecord.HourlyAsyncReportRuns.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyAsyncReportRuns.Max - limitWrapperRecord.HourlyAsyncReportRuns.Remaining).divide(limitWrapperRecord.HourlyAsyncReportRuns.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Async Reports', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlyDashboardRefreshes != null && limitWrapperRecord.HourlyDashboardRefreshes.Max != Null && limitWrapperRecord.HourlyDashboardRefreshes.Max > 0
                                                                                                                                 && limitWrapperRecord.HourlyDashboardRefreshes.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyDashboardRefreshes.Max - limitWrapperRecord.HourlyDashboardRefreshes.Remaining).divide(limitWrapperRecord.HourlyDashboardRefreshes.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Dashboard Refreshes', percentage);
            }
        }
               
        if (limitWrapperRecord.HourlyDashboardResults != null && limitWrapperRecord.HourlyDashboardResults.Max != Null && limitWrapperRecord.HourlyDashboardResults.Max > 0
                                                                                                                             && limitWrapperRecord.HourlyDashboardResults.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyDashboardResults.Max - limitWrapperRecord.HourlyDashboardResults.Remaining).divide(limitWrapperRecord.HourlyDashboardResults.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Dashboard Results', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlyDashboardStatuses != null && limitWrapperRecord.HourlyDashboardStatuses.Max != Null && limitWrapperRecord.HourlyDashboardStatuses.Max > 0
                                                                                                                              && limitWrapperRecord.HourlyDashboardStatuses.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyDashboardStatuses.Max - limitWrapperRecord.HourlyDashboardStatuses.Remaining).divide(limitWrapperRecord.HourlyDashboardStatuses.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Dashboard Statuses', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlyLongTermIdMapping != null && limitWrapperRecord.HourlyLongTermIdMapping.Max != Null && limitWrapperRecord.HourlyLongTermIdMapping.Max > 0
                                                                                                                             && limitWrapperRecord.HourlyLongTermIdMapping.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyLongTermIdMapping.Max - limitWrapperRecord.HourlyLongTermIdMapping.Remaining).divide(limitWrapperRecord.HourlyLongTermIdMapping.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Long Term ID Mappings', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlyODataCallout != null && limitWrapperRecord.HourlyODataCallout.Max != Null && limitWrapperRecord.HourlyODataCallout.Max > 0
                                                                                                                    && limitWrapperRecord.HourlyODataCallout.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyODataCallout.Max - limitWrapperRecord.HourlyODataCallout.Remaining).divide(limitWrapperRecord.HourlyODataCallout.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly OData Callout', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlyShortTermIdMapping != null && limitWrapperRecord.HourlyShortTermIdMapping.Max != Null && limitWrapperRecord.HourlyShortTermIdMapping.Max > 0 
                                                                                                                                && limitWrapperRecord.HourlyShortTermIdMapping.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyShortTermIdMapping.Max - limitWrapperRecord.HourlyShortTermIdMapping.Remaining).divide(limitWrapperRecord.HourlyShortTermIdMapping.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Short Term ID Mappings', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlySyncReportRuns != null && limitWrapperRecord.HourlySyncReportRuns.Max != Null && limitWrapperRecord.HourlySyncReportRuns.Max > 0 
                                                                                                                        && limitWrapperRecord.HourlySyncReportRuns.Remaining >= 0){
            
            Decimal percentage = (((limitWrapperRecord.HourlySyncReportRuns.Max - limitWrapperRecord.HourlySyncReportRuns.Remaining).divide(limitWrapperRecord.HourlySyncReportRuns.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Sync Reports', percentage);
            }
        }
        
        if (limitWrapperRecord.HourlyTimeBasedWorkflow != null && limitWrapperRecord.HourlyTimeBasedWorkflow.Max != Null && limitWrapperRecord.HourlyTimeBasedWorkflow.Max > 0 
                                                                                                                                && limitWrapperRecord.HourlyTimeBasedWorkflow.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.HourlyTimeBasedWorkflow.Max - (limitWrapperRecord.HourlyTimeBasedWorkflow.Remaining <= 0 ? 0 : limitWrapperRecord.HourlyTimeBasedWorkflow.Remaining)).divide(limitWrapperRecord.HourlyTimeBasedWorkflow.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Hourly Time Based Workflow', percentage);
            }
        }
        
        if (limitWrapperRecord.SingleEmail != null && limitWrapperRecord.SingleEmail.Max != Null && limitWrapperRecord.SingleEmail.Max > 0 && limitWrapperRecord.SingleEmail.Remaining >= 0) {
            
            Decimal percentage = ((( limitWrapperRecord.SingleEmail.Max - limitWrapperRecord.SingleEmail.Remaining).divide(limitWrapperRecord.SingleEmail.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Single Emails', percentage);
            }
        }
        
        if (limitWrapperRecord.MassEmail != null && limitWrapperRecord.MassEmail.Max != Null && limitWrapperRecord.MassEmail.Max > 0 && limitWrapperRecord.MassEmail.Remaining >= 0) {
            
            Decimal percentage = (((limitWrapperRecord.MassEmail.Max - limitWrapperRecord.MassEmail.Remaining).divide(limitWrapperRecord.MassEmail.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Daily Mass Emails', percentage);
            }
        }
        
        if (limitWrapperRecord.StreamingApiConcurrentClients != null && limitWrapperRecord.StreamingApiConcurrentClients.Max != Null 
                                                                && limitWrapperRecord.StreamingApiConcurrentClients.Max > 0  && limitWrapperRecord.StreamingApiConcurrentClients.Remaining >= 0) {
            
            Decimal percentage = ((( limitWrapperRecord.StreamingApiConcurrentClients.Max - limitWrapperRecord.StreamingApiConcurrentClients.Remaining).divide(limitWrapperRecord.StreamingApiConcurrentClients.Max, 
                                    2, System.RoundingMode.UP)) * 100 );
            if (percentage >= 75) {
                
                limitExaggerateMap.put('Concurrent Streaming Clients', percentage);
            }
        }
        system.debug('limitExaggerateMap--->'+ limitExaggerateMap);
        
        if (limitExaggerateMap.isEmpty() == False) {
            
            String message = '';
            for (String  limits: limitExaggerateMap.Keyset()) {
                
                message += limits +' : '+ limitExaggerateMap.get(limits)+'% \n';
            }
            system.debug('message--->'+ message);
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{'Abhandari@stratfs.com'}; 
            semail.setToAddresses(sendingTo); 
            semail.setSubject('Limits exceeded in UAT'); 
            semail.setHtmlBody(message); 
            system.debug('semail--->'+ semail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 

            /*
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{'rishanthin@gmail.com'};
            semail.setToAddresses(sendingTo);
            semail.setSubject('Limits exceeded in UAT');
            semail.setHtmlBody(message);
            system.debug('semail--->'+ semail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});*/
        }
    }
    
    public RestLimitResource() {
        JSONtext = getLimitsResp().getBody();
        system.debug('JSONtext--->'+JSONtext);
    }
 
    public static HttpResponse getLimitsResp() {
    
        List<ApexClass> apiVersionFromApexClass = [SELECT ApiVersion, Name FROM ApexClass WHERE Name = 'RestLimitResource'];
        
        if (apiVersionFromApexClass != null && apiVersionFromApexClass.isEmpty() == False) {
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('GET');
            String url = System.URL.getSalesforceBaseURL().toExternalForm() +'/services/data/v'+apiVersionFromApexClass[0].ApiVersion+'/limits';
            req.setHeader('Authorization','Bearer '+UserInfo.getSessionId());

            req.setEndpoint(url);
            return http.send(req);
        }
        return null;
    }
    
    public class LimitVariableWrapper {
        
        public Decimal Max {get;set;}
        public Decimal Remaining {get;set;}
    }
    
    public class LimitWrapper {
    
        public LimitVariableWrapper ConcurrentAsyncGetReportInstances {get;set;}
        public LimitVariableWrapper ConcurrentSyncReportRuns {get;set;}
        public LimitVariableWrapper DailyApiRequests {get;set;}
        public LimitVariableWrapper DailyAsyncApexExecutions {get;set;}
        public LimitVariableWrapper DailyBulkApiRequests {get;set;}
        public LimitVariableWrapper DailyDurableGenericStreamingApiEvents {get;set;}
        public LimitVariableWrapper DailyDurableStreamingApiEvents {get;set;}
        public LimitVariableWrapper DailyGenericStreamingApiEvents {get;set;}
        public LimitVariableWrapper DailyStandardVolumePlatformEvents {get;set;}
        public LimitVariableWrapper DailyStreamingApiEvents {get;set;}
        public LimitVariableWrapper DailyWorkflowEmails {get;set;}
        public LimitVariableWrapper DataStorageMB {get;set;}
        public LimitVariableWrapper DurableStreamingApiConcurrentClients {get;set;}
        public LimitVariableWrapper FileStorageMB {get;set;}
        public LimitVariableWrapper HourlyAsyncReportRuns {get;set;}
        public LimitVariableWrapper HourlyDashboardRefreshes {get;set;}
        public LimitVariableWrapper HourlyDashboardResults {get;set;}
        public LimitVariableWrapper HourlyDashboardStatuses {get;set;}
        public LimitVariableWrapper HourlyLongTermIdMapping {get;set;}
        public LimitVariableWrapper HourlyODataCallout {get;set;}
        public LimitVariableWrapper HourlyShortTermIdMapping {get;set;}
        public LimitVariableWrapper HourlySyncReportRuns {get;set;}
        public LimitVariableWrapper HourlyTimeBasedWorkflow {get;set;}
        public LimitVariableWrapper MassEmail {get;set;}
        public LimitVariableWrapper SingleEmail {get;set;}
        public LimitVariableWrapper StreamingApiConcurrentClients {get;set;}
    }
}