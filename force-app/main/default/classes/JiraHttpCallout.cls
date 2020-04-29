Public class JiraHttpCallout {
    
    public static void MakeCallout(string versionID){
        
        if(string.isblank(versionID)){
            versionID = '10155';
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://stratfs.atlassian.net/rest/api/3/version/'+versionID);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic YWJoYW5kYXJpQHN0cmF0ZnMuY29tOm9ZbGtUemNnYWx5eWZ5bEZCVUw5OUE0Qw==');
        HttpResponse response = http.send(request);
        system.debug('==response=='+response);
        system.debug('==response status=='+response.getstatuscode() );
        
        if(response.getstatuscode() == 200){
            JiraResponse res = (JiraResponse)JSON.deserialize(response.getBody(), JiraResponse.class);
            System.debug('JiraResponse-->'+res);
            
            // create update release.
            Jira_Release_Management__c jrm = new Jira_Release_Management__c();
            
            list<Jira_Release_Management__c> jrmlist = [select id from Jira_Release_Management__c where Version_Id__c =:versionID limit 1];
            if(!jrmlist.isempty()){
                jrm.id = jrmlist[0].id;
            }
            
            jrm.Archived__c      = res.archived;
            if(res.overdue == null){
                jrm.Overdue__c = false;       
            }else{
                jrm.Overdue__c = res.overdue; 
            }
            jrm.ProjectId__c     = string.valueof(res.projectId);
            jrm.Release_Date__c  = date.valueof(res.releaseDate);
            jrm.Release_Name__c  = res.name;
            jrm.Released__c      = res.released;
            jrm.Version_Id__c    = res.id;
            upsert jrm;
            
        }
    }
    
    
    /*
global string id;
global string name;
global string archived;
global string released;
global string releaseDate;
global string overdue;
global string userReleaseDate;
global String projectId;
global List < Jira_Release_Management__c > start(Database.BatchableContext BC) {


String query = '';
query = 'SELECT Id, name, archived, released, releaseDate, overdue, userReleaseDate, projectId  FROM Jira_Release_Management__c; 
return Database.query(query);
}


//Pass in the endpoint to be used using the string url
// public String getCalloutResponseContents(String url) {

global void execute(Database.BatchableContext BC, List < Jira_Release_Management__c > scope) {
//Instantiate a new http object
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint('https://stratfs.atlassian.net/rest/api/3/version/10155');
request.setMethod('GET');
//request.setHeader('Authorization', 'Bearer ' + access_token);
request.setHeader('Authorization', 'Basic YWJoYW5kYXJpQHN0cmF0ZnMuY29tOm9ZbGtUemNnYWx5eWZ5bEZCVUw5OUE0Qw==');
HttpResponse response = http.send(request);
// return response.getBody();
//  System.debug('responseBody--->' + response.getBody());

if (string.isNotBlank(response.getBody())) {
//Serialize response into wrapper inorder to support bulkified results. (entries node is a list)
JiraResponse JiraResponseInstance = (JiraResponse)JSON.deserialize(response.getBody(), JiraResponse.class);
System.debug('JiraResponse-->'+JiraResponseInstance);   
}      

if (response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
String parentFolderId = CreateParentAndSubFoldersInBox.getFolderId(response.getBody());

Jira_Release_Management__c.Archived__c      = parentFolderId;
Jira_Release_Management__c.Overdue__c       = parentFolderId;
Jira_Release_Management__c.ProjectId__c     = parentFolderId;
Jira_Release_Management__c.Release_Date__c  = parentFolderId;
Jira_Release_Management__c.Release_Name__c  = parentFolderId;
Jira_Release_Management__c.Released__c      = parentFolderId;
Jira_Release_Management__c.Version_Id__c    = parentFolderId;
update objAccount;

}

/*if (response.getStatusCode() == 200) {
// Deserialize the JSON string into collections of primitive data types.
Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
List<Object> Variables = (List<Object>) results.get('Variables');
for (Object Variable: Variables) {
System.debug(Variable);
}
} */
    
    
}