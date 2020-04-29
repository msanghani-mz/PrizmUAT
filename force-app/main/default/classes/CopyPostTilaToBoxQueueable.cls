/**
* @File Name          : CopyPostTilaToBoxQueueable.cls
* @Description        : This Job submit the copy the post tila from files to the box.com
* @Author             : financial Spectra
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 2/24/2020, 1:27:07 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    8/24/2019, 12:12:55 AM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class CopyPostTilaToBoxQueueable implements Queueable ,Database.AllowsCallouts{
    private static final String CLASS_NAME = 'CopyPostTilaToBoxQueueable';
    private List<ContentDocumentLink> mRecordIds;
    
    public CopyPostTilaToBoxQueueable(List<ContentDocumentLink> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }
    public void execute(QueueableContext context) {
        try{
            System.debug(loggingLevel.ERROR, mRecordIds);
            copyPostTilaToBox(mRecordIds);
            System.debug(loggingLevel.ERROR, 'Success');
        }catch(Exception ex){
            fsCore.ErrorObject errObj = new fsCore.ErrorObject();
            errObj.setErrorMessage(ex.getMessage());
            errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
            errObj.setErrorStackTrace(ex.getStackTraceString());
            
            List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
            errorObjectList.add(errObj);
            
            fsCore.DiagnosticLogUtil.logErrors('InitiateSocureQueueable', 'execute', errorObjectList);
        }
        
    }
    
    private void copyPostTilaToBox(List<ContentDocumentLink> pContentDocLinks){
        System.debug(loggingLevel.ERROR, '-- ' + CLASS_NAME + '.setDocumentIdOnContentVersion(+)');
        Map<Id,Id> contentDocToLendingDocIDMap = getContentDocToLendingDocMap(pContentDocLinks);
        Map<Id, fsCore__Lending_Application__c> lendingAppMap = getLendingAppMap(contentDocToLendingDocIDMap);
        List<ContentVersion> contentVerRecords = [SELECT Id
                                                       , ContentDocumentID
                                                       , Is_Copied_To_Box_Folder__c 
                                                       , VersionData
                                                       , PathOnClient
                                                    FROM ContentVersion 
                                                   WHERE ContentDocumentID IN :contentDocToLendingDocIDMap.keySet()
                                                     AND Is_Copied_To_Box_Folder__c = false
                                                     AND Title like 'Post-Tila%' ];
        
        Set<Id> documentIds = new Set<Id>();
        for(ContentVersion file : contentVerRecords){
            if (lendingAppMap.get(contentDocToLendingDocIDMap.get(file.ContentDocumentID)).BoxFolderId__c != null){
                file.Is_Copied_To_Box_Folder__c = true;
            
                Blob pdfDoc = file.VersionData;
                String documentName = file.PathOnClient +'-'+Datetime.now().format('yyyy_MM_dd_HHmmss');
                CreateBoxFolderHandler.copyPdfDocumentToBox(pdfDoc,lendingAppMap.get(contentDocToLendingDocIDMap.get(file.ContentDocumentID)).BoxFolderId__c,documentName);

            }
        }
        Database.update(contentVerRecords);

        System.debug(loggingLevel.ERROR, '-- ' + CLASS_NAME + '.setDocumentIdOnContentVersion(-)');
    }    

    private Map<Id, Id> getContentDocToLendingDocMap(List<ContentDocumentLink> pContentDocLinks){
        Map<Id,Id> contentDocToLendingDocIDMap = new Map<Id, Id>();
 
        for(ContentDocumentLink cdLink : pContentDocLinks){
            contentDocToLendingDocIDMap.put(cdLink.ContentDocumentId, cdLink.LinkedEntityId);
        }

        return contentDocToLendingDocIDMap;
    }  
    private Map<Id, fsCore__Lending_Application__c> getLendingAppMap(Map<Id,Id> pContentDocToLendingDocIDMap){
        Map<ID, fsCore__Lending_Application__c> lendingApplicationMap = new Map<ID, fsCore__Lending_Application__c>(
            [SELECT Id
                  , BoxFolderId__c
                  , fsCore__Primary_Customer_Account__r.Import_BoxFolderId__c
               FROM fsCore__Lending_Application__c
              WHERE id IN :pContentDocToLendingDocIDMap.values()]);        
 
      
        return lendingApplicationMap;
    }        
    
}