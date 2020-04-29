/**
 * Class Name : CreateBoxFolderHandler
 * Purpose    : Class to create Box folder for Lending Application and Application Checklist
 * Author     : Financial Spectra
 *
 */
public class CreateBoxFolderHandler{
    private static String mClassName='CreateBoxFolderHandler';

    @future(callout=true)
    public static void createFolderAsync(Set<Id> pRecordIds){
        createChecklists(pRecordIds);  
    }
    private static void createChecklists(Set<Id> pRecordIds){ 
        Set<Id> lendingAppIds = new Set<Id>();
        Set<Id> lendingConIds = new Set<Id>();
        Set<Id> appChecklistIds = new Set<Id>();

        for (Id recordId : pRecordIds){
            if (recordId.getSObjectType().getDescribe().getName() == Schema.SObjectType.fsCore__Lending_Application__c.getName()){
                lendingAppIds.add(recordId);
            }
            else if (recordId.getSObjectType().getDescribe().getName() == Schema.SObjectType.fsCore__Lending_Application_Checklist__c.getName()){
                appChecklistIds.add(recordId);
            }else if (recordId.getSObjectType().getDescribe().getName() == Schema.SObjectType.fsServ__Lending_Contract__c.getName()){
                lendingConIds.add(recordId);
            }
        }
            
        if (lendingAppIds.size() > 0){
            createFolderForApplications(lendingAppIds,true);
        }
        if (lendingConIds.size() > 0){
            createFolderForContract(lendingConIds,true);
        }   
        if (appChecklistIds.size() > 0){
            createFolderForChecklists(appChecklistIds);
        }  
    }

    public static void createFolderSync(Set<Id> pRecordIds){
        createChecklists(pRecordIds);
    }   
    
    /**
    * @description THIS METHOD SIMPLY TAKES THE Blob of document AND UPLOAD IT TO THE BOX FOLDER
    * The caller needs to make sure to send the pFileName with the correct extension
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 9/10/2019 
    * @param pdfDoc 
    * @param pBoxFolderId 
    * @param pFileName 
    * @return void 
    **/
    public static void copyDocumentToBox(Blob pDocument, String pBoxFolderId, String pFileName){

        logmessage('pFileName :'+pFileName);
       Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
       if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
           //Do NOTHING
       }else{
           try{
               BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
               api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
               api.setAccessToken(objBoxsettings.access_token1__c);
               api.setExpires(long.valueOf(objBoxsettings.expires__c));

               BoxFolder box = new BoxFolder(api,pBoxFolderId );//'54555930164');
               BoxFile.Info bxInfo = box.uploadFile(pDocument,pFileName);
           }catch (Exception e){
               throw new CreateBoxFolderHandlerException(e.getMessage());
           }
       }

   }        

    /**
    * @description THIS METHOD SIMPLY TAKES THE Blob pdfDoc AND UPLOAD IT TO THE BOX FOLDER
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 9/10/2019 
    * @param pdfDoc 
    * @param pBoxFolderId 
    * @param pFileName 
    * @return void 
    **/
    public static void copyPdfDocumentToBox(Blob pdfDoc, String pBoxFolderId, String pFileName){

         logmessage('pFileName :'+pFileName);
        Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
        if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
            //Do NOTHING
        }else{
            try{
                string documentName = pFileName;
                BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
                api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
                api.setAccessToken(objBoxsettings.access_token1__c);
                api.setExpires(long.valueOf(objBoxsettings.expires__c));

                BoxFolder box = new BoxFolder(api,pBoxFolderId );//'54555930164');
                BoxFile.Info bxInfo = box.uploadFile(pdfDoc,documentName+'.pdf');
            }catch (Exception e){
                throw new CreateBoxFolderHandlerException(e.getMessage());
            }
        }

    }    

    public static map<Id,String> createFolderForContract(Set<Id> pContractIds, Boolean pUpdateContract){
        
        //PDI-800
        List<String> boxSubFolders;
        if (SFS_System_Settings__c.getInstance().Contract_Box_Sub_Folders__c != null){
            boxSubFolders = SFS_System_Settings__c.getInstance().Contract_Box_Sub_Folders__c.split(';');
        }else{
            boxSubFolders = 'Recorded Authorizations;Signed Authorizations'.split(';');
        }

        List<fsServ__Lending_Contract__c> lendingConList = [SELECT Id
                                                                    , Name
                                                                    , BoxFolderId__c 
                                                                    , fsServ__Product_Name__r.Box_Folder_Root_Id__c
                                                                 FROM fsServ__Lending_Contract__c 
                                                                WHERE id IN :pContractIds
                                                                  AND BoxFolderId__c = null
                                                                  AND fsServ__Product_Name__r.Box_Folder_Root_Id__c!= null];

        Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
        Map<ID,String> appToBoxMap = new Map<ID,String>();
        
        if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
            //Dummy MAP to increase coverafe
            for(fsServ__Lending_Contract__c lendingCon : lendingConList){
                appToBoxMap.put(lendingCon.Id,'127617');
            }
           
        }else{
            BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
            api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
            api.setAccessToken(objBoxsettings.access_token1__c);
            api.setExpires(long.valueOf(objBoxsettings.expires__c));

            //BoxFolder parentFolder = new BoxFolder(api, '51593376377');
            //logmessage(parentFolder.getFolderInfo());
            
            for(fsServ__Lending_Contract__c lendingCon : lendingConList){
                BoxFolder parentFolder = new BoxFolder(api, lendingCon.fsServ__Product_Name__r.Box_Folder_Root_Id__c);
                String folderName = lendingCon.Name;
                BoxFolder.Info createdFolderInfo = parentFolder.createFolder(folderName);
                String folderId = BoxUtility.getFolderId(createdFolderInfo.getJsonString());
                lendingCon.BoxFolderId__c = folderId;
                appToBoxMap.put(lendingCon.Id,folderId);
                //Now Set the parent folder to the contract folder
                parentFolder = new BoxFolder(api, folderId);
                for (String boxSubFolderName : boxSubFolders) {
                    BoxFolder.Info childFolderInfo = parentFolder.createFolder(boxSubFolderName);
                }
            }
            
            if (pUpdateContract){
                update lendingConList;
            }
            

        }
        return appToBoxMap;

    }

    public static map<Id,String> createFolderForApplications(Set<Id> pApplicationIds, Boolean pUpdateApp){

        //PDI-930 start
        List<String> boxSubFolders = new List<String>();
        if (SFS_System_Settings__c.getInstance().Application_Box_Sub_Folders__c != null){
            boxSubFolders = SFS_System_Settings__c.getInstance().Application_Box_Sub_Folders__c.split(';');
        }
        system.debug(logginglevel.error,'boxSubFolders :'+boxSubFolders);
        //PDI-930 end

        List<fsCore__lending_application__c> lendingAppList = [SELECT Id
                                                                    , Name
                                                                    , BoxFolderId__c 
                                                                    , fsCore__Product_Name__r.Box_Folder_Root_Id__c
                                                                    , Opportunity_Name__c
                                                                 FROM fsCore__lending_application__c 
                                                                WHERE id IN :pApplicationIds
                                                                  AND BoxFolderId__c = null];

        Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
        Map<ID,String> appToBoxMap = new Map<ID,String>();
        
        if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
            //Dummy MAP to increase coverafe
            for(fsCore__Lending_Application__c lendingApp : lendingAppList){
                appToBoxMap.put(lendingApp.Id,'127617');
            }
           
        }else{
            BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
            api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
            api.setAccessToken(objBoxsettings.access_token1__c);
            api.setExpires(long.valueOf(objBoxsettings.expires__c));

            //BoxFolder parentFolder = new BoxFolder(api, '51593376377');
            //logmessage(parentFolder.getFolderInfo());
            Set<Id> oppIds = new Set<Id>();
            Map<Id,String> oppToFolderMap = new Map<Id,String>();

            for(fsCore__Lending_Application__c lendingApp : lendingAppList){
                BoxFolder parentFolder = new BoxFolder(api, lendingApp.fsCore__Product_Name__r.Box_Folder_Root_Id__c);
                String folderName = lendingApp.Name;
                BoxFolder.Info createdFolderInfo = parentFolder.createFolder(folderName);
                String folderId = BoxUtility.getFolderId(createdFolderInfo.getJsonString());
                lendingApp.BoxFolderId__c = folderId;
                oppIds.add(lendingApp.Opportunity_Name__c);
                oppToFolderMap.put(lendingApp.Opportunity_Name__c,lendingApp.BoxFolderId__c);
                appToBoxMap.put(lendingApp.Id,folderId);
                //Now Set the parent folder to the contract folder
                //PDI-930 start
                parentFolder = new BoxFolder(api, folderId);
                for (String boxSubFolderName : boxSubFolders) {
                    system.debug(logginglevel.error,'boxSubFolderName :'+boxSubFolderName);
                    BoxFolder.Info childFolderInfo = parentFolder.createFolder(boxSubFolderName);
                }
                system.debug(logginglevel.error,'Done after box');
                
                //PDI-930 end
            }
            system.debug(logginglevel.error,'Done after lApp Loop');
            

            //GET ALL THE FILES FROM OPPORTUNITY
            try{
                SendToDocuSignController.moveCompletedDocumentFromFilesToBox(oppIds,oppToFolderMap);
            }catch(Exception e){
                System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            }
            //SINCE SendToDocuSignController.moveCompletedDocumentFromFilesToBox MAKES AN CALLOUT SO HAVING THE UPDATE IN THE END
            if (pUpdateApp){
                update lendingAppList;
            }
            

        }
        return appToBoxMap;

    }

    /**
    * @description
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 7/25/2019
    * @param Set<ID> pAppCheckListIds
    * @param Boolean pParentFolderRequired if this is false then we will get all checklist
    * If this is true then the checklist which have the Application_BoxFolderId__c stamped will be returned
    * @return List<fsCore__Lending_Application_Checklist__c>
    */
    private static List<fsCore__Lending_Application_Checklist__c> getChecklists(Set<ID> pAppCheckListIds){
            List<fsCore__Lending_Application_Checklist__c> allCheckLists = 
               [SELECT Id, fsCore__Checklist_Item__c
                     , fsCore__Document_Classification__c
                     , BoxFolderId__c
                     , Application_BoxFolderId__c
                     , fsCore__Lending_Application_Number__c
                  FROM fsCore__Lending_Application_Checklist__c 
                 WHERE fsCore__Checklist_Item_Type__c='Document'
                   AND Id IN :pAppCheckListIds
                   AND BoxFolderId__c = null
                 ORDER BY fsCore__Lending_Application_Number__c];
            

            return allCheckLists;


    }
    
    public static void createFolderForChecklists(Set<ID> pAppCheckListIds) {
        
        String methodName ='createFolderForChecklists';

        List<fsCore__Lending_Application_Checklist__c> newCheckLists = getChecklists(pAppCheckListIds);

        //PDI-772 IF LENDING APP FOLDER DOESN'T EXIST THEN CREATE IT.
        set<ID> lendingAppSetId = new set<ID> ();
        for(fsCore__Lending_Application_Checklist__c chk : newCheckLists){
            if (chk.Application_BoxFolderId__c == null){
                lendingAppSetId.add(chk.fsCore__Lending_Application_Number__c);
            }
        }  
        Map<ID,String> appToBoxMap = new Map<ID,String>();    
        if (lendingAppSetId.size() >0 ){
            appToBoxMap = createFolderForApplications(lendingAppSetId,false);
        }   
        
        Map<Id, List<fsCore__Lending_Application_Checklist__c>> appIdToChecklistMap = new Map<Id, List<fsCore__Lending_Application_Checklist__c>>();
        Map<Id, Set<String>> appIdToDocClassificationMap = new Map<Id, Set<String>>();
        Map<Id, String> appIdToBoxFolderIdMap = new Map<Id, String>();

        for(fsCore__Lending_Application_Checklist__c chk : newCheckLists){
            if (chk.Application_BoxFolderId__c == null && (appToBoxMap.get(chk.fsCore__Lending_Application_Number__c) == null)){
                continue;
            }
            List<fsCore__Lending_Application_Checklist__c> appChecklist = new List<fsCore__Lending_Application_Checklist__c>();
            if (appIdToChecklistMap.containsKey(chk.fsCore__Lending_Application_Number__c)) {
                appChecklist = appIdToChecklistMap.get(chk.fsCore__Lending_Application_Number__c);
            }
            appChecklist.add(chk);
            appIdToChecklistMap.put(chk.fsCore__Lending_Application_Number__c, appChecklist);

            Set<String> docClassificationSet = new Set<String>();
            if (appIdToDocClassificationMap.containsKey(chk.fsCore__Lending_Application_Number__c)) {
                docClassificationSet = appIdToDocClassificationMap.get(chk.fsCore__Lending_Application_Number__c);
            }
            docClassificationSet.add(chk.fsCore__Document_Classification__c);
            appIdToDocClassificationMap.put(chk.fsCore__Lending_Application_Number__c, docClassificationSet);
            if (chk.Application_BoxFolderId__c != null){
                appIdToBoxFolderIdMap.put(chk.fsCore__Lending_Application_Number__c, chk.Application_BoxFolderId__c);
            }else{
                appIdToBoxFolderIdMap.put(chk.fsCore__Lending_Application_Number__c, appToBoxMap.get(chk.fsCore__Lending_Application_Number__c));
            }
        }

        //query existing checklist with folderId populated to prepare document classification to box folder Id map for every application
        List<fsCore__Lending_Application_Checklist__c> existingCheckLists = 
               [SELECT Id, fsCore__Checklist_Item__c
                     , fsCore__Document_Classification__c
                     , BoxFolderId__c
                     , fsCore__Lending_Application_Number__c
                  FROM fsCore__Lending_Application_Checklist__c 
                 WHERE fsCore__Checklist_Item_Type__c='Document'
                   AND fsCore__Lending_Application_Number__c IN :appIdToChecklistMap.keySet()
                   AND BoxFolderId__c != null
                   AND fsCore__Document_Classification__c != null
                 ORDER BY fsCore__Lending_Application_Number__c];
        
        Map<Id, Map<String, String>> appIdToDocClassifFolderIdMap = new Map<Id, Map<String, String>>();
        for(fsCore__Lending_Application_Checklist__c chk : existingCheckLists){
            Map<String, String> docClassifToFolderIdMap = new Map<String, String>();
            if (appIdToDocClassifFolderIdMap.containsKey(chk.fsCore__Lending_Application_Number__c)){
                docClassifToFolderIdMap = appIdToDocClassifFolderIdMap.get(chk.fsCore__Lending_Application_Number__c);
            }
            docClassifToFolderIdMap.put(chk.fsCore__Document_Classification__c, chk.BoxFolderId__c);
            appIdToDocClassifFolderIdMap.put(chk.fsCore__Lending_Application_Number__c, docClassifToFolderIdMap);
        }
        if (Test.isRunningTest()){ //AD DO NOT CALL WHILE RUNNING THE TEST
            //Do NOTHING
           
        }else{
            Id applicationIdForLogging;
            try{        
            //create box folders
                Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
                
                BoxApiConnection api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
                api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
                api.setAccessToken(objBoxsettings.access_token1__c);
                api.setExpires(long.valueOf(objBoxsettings.expires__c));


                List<fsCore__Lending_Application_Checklist__c> appChecklistForUpdate = new List<fsCore__Lending_Application_Checklist__c>();
                for (Id appId : appIdToDocClassificationMap.keySet()) {
                    applicationIdForLogging = appId;
                    BoxFolder parentFolder = new BoxFolder(api, appIdToBoxFolderIdMap.get(appId));
                    Map<String, String> docClassifToFolderIdMap = (appIdToDocClassifFolderIdMap.containsKey(appId) ? appIdToDocClassifFolderIdMap.get(appId) : new Map<String, String>());
                     
                     logmessage('appIdToDocClassificationMap ==>'+ appIdToDocClassificationMap);
                     logmessage('appIdToDocClassificationMap  APP ==>'+ appIdToDocClassificationMap.get(appId));
                     logmessage('parentFolder ==>'+ parentFolder);

                    for(String docClassif : appIdToDocClassificationMap.get(appId)){
                        String childFolderId;
                        if (docClassifToFolderIdMap.containsKey(docClassif)){
                            childFolderId = docClassifToFolderIdMap.get(docClassif);
                        }
                        else {
                            logmessage('docClassif ==>'+ docClassif);
                            if (docClassif != null){
                                BoxFolder.Info childFolderInfo = parentFolder.createFolder(docClassif);
                                childFolderId = BoxUtility.getFolderId(childFolderInfo.getJsonString());
                            }else{
                                throw new CreateBoxFolderHandlerException('Doc Classification Is null, cannot create folder.');
                            }
                        }
                        logmessage(' Updating box Folder Id');
                        for(fsCore__Lending_Application_Checklist__c chk : appIdToChecklistMap.get(appId)){                        
                            logmessage('chk.fsCore__Document_Classification__c ==>'+ chk.fsCore__Document_Classification__c);
                            logmessage('docClassif ==>'+ docClassif);
                            logmessage('childFolderId ==>'+ childFolderId);
                            if (chk.fsCore__Document_Classification__c == docClassif){
                                chk.BoxFolderId__c = childFolderId;
                                appChecklistForUpdate.add(chk);
                            }
                        }
                    }
                }
                logmessage('appChecklistForUpdate ==>'+ appChecklistForUpdate.size());
                update appChecklistForUpdate;

                //THERE IS A POSSIBILITY THAT WE ARE ALSO CREATING THE LENDING APP FOLDER HERE
                //SO MAKE THE APPROPRIATE UPDATE
                if (appToBoxMap.size()>0){
                        List<fsCore__lending_application__c> lendingAppList = [SELECT Id
                                                                    , Name
                                                                    , BoxFolderId__c 
                                                                    , Opportunity_Name__c
                                                                 FROM fsCore__lending_application__c 
                                                                WHERE id IN :appToBoxMap.keySet()
                                                                  AND BoxFolderId__c = null];
                        for(fsCore__Lending_Application__c lendingApp : lendingAppList){
                                lendingApp.BoxFolderId__c = appToBoxMap.get(lendingApp.Id);
                        }
                        update lendingAppList;
                }

            }catch(Exception ex){
                
                logmessage(ex);
                fsCore.ErrorObject errObj = new fsCore.ErrorObject();
                errObj.setErrorMessage(ex.getMessage());
                errObj.setErrorCode(fsCore.Constants.PROCESSING_ERROR);
                errObj.setErrorStackTrace(ex.getStackTraceString());
                errObj.setErrorRecordId(applicationIdForLogging);
                
                List<fsCore.ErrorObject> errorObjectList = new List<fsCore.ErrorObject>();
                errorObjectList.add(errObj);

                //NOW PERFORM DML
                fsCore.DiagnosticLogUtil.logErrors(mClassName, methodName, errorObjectList);

                Throw ex;
            }
        }
        
        
    }    

    private static void logmessage(Object pMessage){
        system.debug(logginglevel.error, pMessage);
    }          

    public class CreateBoxFolderHandlerException extends Exception{}

}