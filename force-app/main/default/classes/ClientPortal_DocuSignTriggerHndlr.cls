public class ClientPortal_DocuSignTriggerHndlr {
    private static final String COMPLETED_ENVELOPE_STATUS = 'Completed' ;
    public static void uploadSignedDocumentOnComplete(Map<Id, fsCore__Bank_Account__c> envelopeOldMap ,List<fsCore__Bank_Account__c> envelopeStatusList) {

        try{
            
            Set<String> bankAccountIdSet = new Set<String>(); 
			
            for(fsCore__Bank_Account__c bankAccForEnvelope : envelopeStatusList) {
                System.debug('@@Inside Trigger Handler - ' + envelopeOldMap.get(bankAccForEnvelope.Id).Docusign_Status__c + '--'+  bankAccForEnvelope.Docusign_Status__c) ;
                if(!COMPLETED_ENVELOPE_STATUS.equalsIgnoreCase(envelopeOldMap.get(bankAccForEnvelope.Id).Docusign_Status__c) && COMPLETED_ENVELOPE_STATUS.equalsIgnoreCase(bankAccForEnvelope.Docusign_Status__c)) {
                    
                    System.debug('@@Inside bankAccForEnvelope.Id ' + bankAccForEnvelope.Id ) ;
                    bankAccountIdSet.add(bankAccForEnvelope.Id) ;
                }
            }
            
            /*for(dsfs__DocuSign_Status__c envelopeStatus : envelopeStatusList) {
                
                if(!COMPLETED_ENVELOPE_STATUS.equalsIgnoreCase(envelopeOldMap.get(envelopeStatus.Id).dsfs__Envelope_Status__c) && COMPLETED_ENVELOPE_STATUS.equalsIgnoreCase(envelopeStatus.dsfs__Envelope_Status__c)) {
                    envelopeIdsToProcess.add(envelopeStatus.dsfs__DocuSign_Envelope_ID__c) ;
                }
            }

            if(envelopeIdsToProcess.isEmpty()) {
                return ;
            }
            
            for(fsCore__Bank_Account__c bankAccForEnvelope : [SELECT Id, fsCore__Account_Name__c, fsCore__Account_Name__r.Is_VCL_Bank_ATD_Accepted__c 
                                                              FROM fsCore__Bank_Account__c
                                                              WHERE VCL_Envelope_Id__c IN :envelopeIdsToProcess
                                                             ] )
            {

                if(bankAccForEnvelope.fsCore__Account_Name__r.Is_VCL_Bank_ATD_Accepted__c) {
                    accountIdToBankAccountMap.put(bankAccForEnvelope.fsCore__Account_Name__c, bankAccForEnvelope.Id) ;
                    bankAccountAccountIdToMap.put(bankAccForEnvelope.Id , bankAccForEnvelope.fsCore__Account_Name__c) ;
                }
            }*/
			
            
            if(!bankAccountIdSet.isEmpty()) {
                System.schedule('ClientPortal_DocusignJob ' + System.now(), 
                                ClientPortal_DocusignSchedularClass.GetCRONExpression((System.now()).addMinutes(1)) , 
                                new ClientPortal_DocusignSchedularClass(bankAccountIdSet));
            }
        }  catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage()) ;
        }
            
    }
    // method will be called from the ClientPortal_DocusignSchedularClass 
    public static void processBankAccountData(List<fsCore__Bank_Account__c> envelopeStatusList) {
         try{
            Set<String> envelopeIdsToProcess = new Set<String>() ;
            Map<Id, Id> accountIdToBankAccountMap = new Map<Id, Id>() ;
            Map<Id, Id> bankAccountAccountIdToMap = new Map<Id, Id>() ;
            Map<Id, Set<Id>> contentDocsForBankAccount = new Map<Id, Set<Id>>() ;
            Map<Id, Id> contentDocForBankAccMap = new Map<Id, Id>() ;
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> contentDocIdSet ;
			
            for(fsCore__Bank_Account__c bankAccForEnvelope : envelopeStatusList) {
                System.debug('@@Inside Trigger Handler') ;
                
                accountIdToBankAccountMap.put(bankAccForEnvelope.fsCore__Account_Name__c, bankAccForEnvelope.Id) ;
                bankAccountAccountIdToMap.put(bankAccForEnvelope.Id , bankAccForEnvelope.fsCore__Account_Name__c) ;
                System.debug('@@Inside bankAccForEnvelope.Id ' + bankAccForEnvelope.Id ) ;
            }
            
            if(accountIdToBankAccountMap.isEmpty()) {
                return ;
            }
            List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, LinkedEntityId
                                                              FROM ContentDocumentLink
                                                              WHERE LinkedEntityId IN :accountIdToBankAccountMap.values()] ;
            System.debug('@@Inside contentDocumentLinks ' + contentDocumentLinks ) ;
            
            if(contentDocumentLinks.isEmpty()) {
               
                return ;
            }
            
            for( ContentDocumentLink contentDocList : contentDocumentLinks) {
                contentDocIdSet = new Set<Id>() ;
                

                
                if(contentDocsForBankAccount.containsKey(contentDocList.LinkedEntityId)) {
                    contentDocIdSet = contentDocsForBankAccount.get(contentDocList.LinkedEntityId) ;
                }
                
                contentDocIdSet.add(contentDocList.ContentDocumentId) ;
                contentDocsForBankAccount.put(contentDocList.LinkedEntityId, contentDocIdSet) ;
                contentDocForBankAccMap.put(contentDocList.ContentDocumentId, contentDocList.LinkedEntityId) ;
            }
            
            for(ContentDocument contentDocs : [Select Id, TITLE from ContentDocument where Id IN :contentDocForBankAccMap.keySet()]) {
                                
                if(String.isBlank(contentDocs.Title) || !contentDocs.Title.contains('_Completed')) {
                    contentDocForBankAccMap.remove(contentDocs.Id) ;
                } else{
                    accountIdSet.add(bankAccountAccountIdToMap.get(contentDocForBankAccMap.get(contentDocs.Id))) ;
                }
            }
            
            List<fsCore__Lending_Application__c> lendingAppList = [SELECT Id, BoxFolderId__c, fsCore__Primary_Customer_Account__c
                                                                   FROM fsCore__Lending_Application__c
                                                                   WHERE fsCore__Primary_Customer_Account__c IN :accountIdSet 
                                                                   AND fsCore__Is_Application_Read_Only__c = false //FSpectra
                                                                  ] ;
            
            List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink> () ;
            Map<String, String> lenidngAppBoxIdToContentDoc = new Map<String, String> () ;
            Map<String, boolean> contentDocforApp = new Map<String, boolean> () ;
            
            for(ContentDocumentLink contentDocLinkForApp : [Select Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId = :lendingAppList[0].Id] ){
                contentDocforApp.put(contentDocLinkForApp.ContentDocumentId , true) ;
            }
            

            for( fsCore__Lending_Application__c lendingApp : lendingAppList) {
                                
                if(accountIdToBankAccountMap.get(lendingApp.fsCore__Primary_Customer_Account__c) != null && contentDocsForBankAccount.get(accountIdToBankAccountMap.get(lendingApp.fsCore__Primary_Customer_Account__c)) != null) {
                    
                    for(Id contentDocId : contentDocsForBankAccount.get(accountIdToBankAccountMap.get(lendingApp.fsCore__Primary_Customer_Account__c))) {
                        
                        if(contentDocForBankAccMap.get(contentDocId) != null && !contentDocforApp.containsKey(contentDocId)) {
                            
                            contentDocumentLinksToInsert.add( new ContentDocumentLink(
                                ContentDocumentId = contentDocId ,
                                LinkedEntityId = lendingApp.Id,
                                ShareType = 'I', 
                                Visibility = 'AllUsers' 
                            )) ;
                            lenidngAppBoxIdToContentDoc.put(contentDocId, lendingApp.BoxFolderId__c ) ;
                        }
                        
                    }
                }
            }
            
            if(!contentDocumentLinksToInsert.isEmpty()) {
                insert contentDocumentLinksToInsert ;
            }
            System.debug('@@After contentDoc insert and before box' + lenidngAppBoxIdToContentDoc.keySet()) ;
                
            for(ContentVersion contentVer: [SELECT Id, VersionData, Title, ContentDocumentId 
                                            FROM ContentVersion 
                                            WHERE ContentDocumentId IN :lenidngAppBoxIdToContentDoc.keySet()]) {
                                                System.debug('inside for ' + contentVer.Title) ;
                                                
                                                ClientPortal_VCLHomeCntrl.uploadFileToBox(contentVer.VersionData , lenidngAppBoxIdToContentDoc.get(contentVer.ContentDocumentId) , contentVer.Title) ;
                                                
                                            }           
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage()) ;
        }
    }
}