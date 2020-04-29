public without sharing class ClientPortal_VCLHomeCntrl {
		
		private static final String ESIGN_STRING_NAME = 'ESign';
		private static final String TILA_STRING_NAME = 'TILA';
		private static final String ESIGN_DISCLOSURE_KEY = 'ESignDisclosure';
		private static final String ESIGN_ACCEPTANCE_DISCLOSURE_KEY = 'ESignAcceptanceDisclosure';
		private static final String ESIGN_DECLINE_DISCLOSURE_KEY = 'ESignDeclineDisclosure';
		private static final String TILA_ACCEPTANCE_DISCLOSURE_KEY = 'TilaAcceptanceDisclosure';
		private static final String TILA_DECLINE_DISCLOSURE_KEY = 'TilaDeclineDisclosure';
		private static final String LENDER_ADDRESS_STR = 'lenderAddress';
		private static final String VERIFY_IDENTITY_STR = 'verifyIdentity';
		private static final String VCL_PORTFOLIO_NAME = 'VCL';
		private static final String WITHDRAWN_STATUS = 'Withdrawn'; 
		private static final String ESIGN_TILA_SIGNED = ClientPortal_Constants.VCL_ESIGN_TILA_STATUS;
		private static final String ESIGN_DISCLOSURE_STR = ClientPortal_Constants.VCL_ESIGN_DISCLOSURE_STATUS;
		private static final String TILA_WITHDRAWN_STATUS = 'Pre-TILA Withdrawn';
		private static final String TILA_SIGNED_STATUS = 'Application in Progress';
		private static final String E_SIGN_DISCLOSURE = '_E-SIGN_DISCLOSURE_' ;
		private static final String TILA_DISCLOSURE = '_Truth_In_Lending_DISCLOSURE_'; 
		private static final String LOAN_AGREEMENT_DISCLOSURE = '_LOAN_AGREEMENT_DISCLOSURE_'; 
		private static final String MLA_DISCLOSURE = '_MILITARY_LENDING_ACT_DISCLOSURE_'; 
		private static final String ESIGN_PDF_GENERATION_URL = '/apex/ClientPortal_VCLGenerateEsignPage?content=eSign&id=';
		private static final String TILA_PDF_GENERATION_URL = '/apex/ClientPortal_VCLGenTILADisclosurePage?id=';
		private static final String LOAN_AGREEMENT_PDF_GENERATION_URL = '/apex/ClientPortal_VCLLoanAgreementPage';
		private static final String EMAIL_SUBJECT_LINE_TILA = 'Your Loan Agreement Attached';
		private static final String TILA_EMAIL_TEMPLATE_NAME = 'VCL_TILA_Loan_Agreement_Attached';
		private static final String ACCOUNT_NOT_FOUND_MESSAGE = 'We cannot locate the account based on the information.';
		private static final String RESULT_SUCCESS_MESSAGE = 'Success';
		private static final String SSN_NOT_VERIFIED_MSG = 'SSN Verification failed'; 
		private static final String BANK_ATD_DISCLOSURE_MESSAGE_KEY = 'BankATDESignDisclosureMsg';
		private static final String BANK_ATD_ESIGN_DISCLOSURE_KEY = 'BankATDESignDisclosure';
		private static final String BANK_ATD_ESIGN_ACCEPTANCE_DISCLOSURE_KEY = 'BankATDESignAcceptanceDisclosure';
		private static final String BANK_ATD_ESIGN_DECLINE_DISCLOSURE_KEY = 'BankATDESignDeclineDisclosure';
		private static final String BANK_ATD_STRING_NAME = 'BankATD';
		private static final String BANK_ATD_DISCLOSURE = '_BANK_ATD_DISCLOSURE' ;
		private static final String BANK_ATD_PDF_GENERATION_URL = '/apex/ClientPortal_VCLBankACHFormPage?lendingAppId=';
		private static final String UNAPPLICABLE_CHKLIST_STATUS = 'Not Applicable';
		private static final String UPLOADED_CHKLIST_STATUS = 'Uploaded';
		private static final String VERIFIED_CHKLIST_STATUS = 'Verified';
		private static final String PENDING_CHKLIST_STATUS = 'Pending';
		private static final String REJECTED_CHKLIST_STATUS = 'Rejected';
		private static final String DOC_PROCESSING_STAGE = 'Doc Processing';
		private static final String LEND_APP_INPROGRESS = 'In Progress';
		private static final Integer MAX_CALLOUT_FILE_SIZE = 6000000;

		
		@AuraEnabled
		public static Map<String, String> retrieveESignContent() {
			String eSignContent = null;
			Map<String, String> vclContentMap = new Map<String, String>();
			try{
				List<Client_Portal_Portfolio__c> vclPortfolioList  = [ SELECT Id, ESGIN_Disclosure_Content__c, ESGIN_Disclosure_Acceptance_Content__c, ESGIN_Disclosure_Decline_Content__c,
																	  TILA_Disclosure_Acceptance_Content__c, TILA_Disclosure_Decline_Content__c, Lender_Address__c,
																	  Bank_ATD_Message_Content__c, Bank_ATD_Esign_Disclosure_Content__c,Bank_ATD_Esign_Acceptance_Content__c,
																	  Bank_ATD_Esign_Decline_Content__c
																	  FROM Client_Portal_Portfolio__c 
																	  WHERE Name = :VCL_PORTFOLIO_NAME] ;
				
				if( !vclPortfolioList.isEmpty()) {
					vclContentMap.put(ESIGN_DISCLOSURE_KEY, vclPortfolioList[0].ESGIN_Disclosure_Content__c);
					vclContentMap.put(ESIGN_ACCEPTANCE_DISCLOSURE_KEY, vclPortfolioList[0].ESGIN_Disclosure_Acceptance_Content__c);
					vclContentMap.put(ESIGN_DECLINE_DISCLOSURE_KEY, vclPortfolioList[0].ESGIN_Disclosure_Decline_Content__c);
					vclContentMap.put(TILA_ACCEPTANCE_DISCLOSURE_KEY, vclPortfolioList[0].TILA_Disclosure_Acceptance_Content__c);
					vclContentMap.put(TILA_DECLINE_DISCLOSURE_KEY, vclPortfolioList[0].TILA_Disclosure_Decline_Content__c);
					vclContentMap.put(LENDER_ADDRESS_STR, vclPortfolioList[0].Lender_Address__c);
					vclContentMap.put(BANK_ATD_DISCLOSURE_MESSAGE_KEY, vclPortfolioList[0].Bank_ATD_Message_Content__c);
					vclContentMap.put(BANK_ATD_ESIGN_DISCLOSURE_KEY, vclPortfolioList[0].Bank_ATD_Esign_Disclosure_Content__c);
					vclContentMap.put(BANK_ATD_ESIGN_ACCEPTANCE_DISCLOSURE_KEY, vclPortfolioList[0].Bank_ATD_Esign_Acceptance_Content__c);
					vclContentMap.put(BANK_ATD_ESIGN_DECLINE_DISCLOSURE_KEY, vclPortfolioList[0].Bank_ATD_Esign_Decline_Content__c);
				}
				
			} catch(Exception exceptn) {
				System.debug('Error: ' + exceptn.getMessage() ) ;
			}
			return vclContentMap ;
		}
		
		private static void updateLendingApplicationStatus(Account userAccount, String lendingApplnId) {
			
			Boolean changeLendingAppStatus = true;
			Boolean setTILAStatus = false;
			String currentUserAccountId = userAccount.Id ;
			Set<String> statusNotAllowed = new Set<String>() ;
			statusNotAllowed.add(ESIGN_TILA_SIGNED) ;
			statusNotAllowed.add(ESIGN_DISCLOSURE_STR) ;
			Account currentAccount = new Account();
			currentAccount = [SELECT ID, VCL_Portal_Status1__c, VCL_Related_Portal_Account__r.VCL_Portal_Status1__c,
							  Is_VCL_Registration_Completed__c, VCL_Related_Portal_Account__r.Is_VCL_Registration_Completed__c
							  FROM Account
							  WHERE Id = :userAccount.Id
							  LIMIT 1];
			if(String.isBlank(currentAccount.VCL_Related_Portal_Account__c) || (currentAccount.VCL_Related_Portal_Account__r.VCL_Portal_Status1__c == ClientPortal_Constants.VCL_APPLICANT_INCOME_SCREEN_STATUS)){
				setTILAStatus = true;
			}
			
			if( setTILAStatus){
				fsCore__Lending_Application__c lendingAppInstance = new fsCore__Lending_Application__c () ;
				lendingAppInstance.Id = lendingApplnId ;
				lendingAppInstance.fsCore__Application_Status__c = TILA_SIGNED_STATUS ;
				lendingAppInstance.Pre_TILA_Signed_Date__c = System.Today();
				update lendingAppInstance ;
			}
			
		}
		
		@AuraEnabled
		public static String updateVCLDisclosureInformation(String accountDetailStr, String lendingAppInstanceIdStr,  String disclosureName, Boolean isAccepted) {
			String resultStr = 'Success';
			Account accountDetails = (Account) JSON.deserialize(accountDetailStr, Account.class);
			Account accountToUpdate = new Account (Id = accountDetails.Id) ;
			fsCore__Lending_Application__c lendingAppInstance ;
			Boolean updateLendingApplication = false ;                                                    
			Savepoint sp = Database.setSavepoint();
			try{
				lendingAppInstance = [SELECT Id, BoxFolderId__c FROM fsCore__Lending_Application__c WHERE ID = :lendingAppInstanceIdStr] ;
				if(isAccepted && disclosureName.equalsIgnoreCase(ESIGN_STRING_NAME)) {
					accountToUpdate.Is_VCL_ESIGN_Accepted__c = true ;
					accountToUpdate.VCL_Portal_Status1__c = ESIGN_TILA_SIGNED;
					updateLendingApplication = true ;
					lendingAppInstance.Pre_TILA_Sent_Date__c = System.today();
					attachEsignDisclosure(lendingAppInstance, accountDetails.Name);
				} 
				else if (!isAccepted && disclosureName.equalsIgnoreCase(ESIGN_STRING_NAME)){
					handleDisclosureDeclination( lendingAppInstanceIdStr ) ;
					accountToUpdate.Is_VCL_ESign_Declined__c = true ;
					accountToUpdate.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_ESIGN_DECLINED;
					lendingAppInstance.fsCore__Application_Status__c = WITHDRAWN_STATUS ;
					lendingAppInstance.Withdraw_Reason__c = ClientPortal_Constants.VCL_ESIGN_WITHDRAW_REASON;
					lendingAppInstance.fsCore__Is_Application_Read_Only__c = true ;
					updateLendingApplication = true ;
				}
				else if(isAccepted && disclosureName.equalsIgnoreCase(TILA_STRING_NAME)) {
					accountToUpdate.Is_VCL_TILA_Accepted__c = true ;
					accountToUpdate.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_APPLICANT_INCOME_SCREEN_STATUS;
					accountToUpdate.TILA_Signed_Date__c = System.now();
					updateLendingApplicationStatus(accountDetails, lendingAppInstance.Id) ;
					attachLoanAgreement(lendingAppInstance, accountDetails);
					if(accountDetails.MLA_Borrower__c){
						attachMLAAgreement(lendingAppInstance, accountDetails);
					}
					attachTILADisclosure(lendingAppInstance, accountDetails);
				}
				else if(!isAccepted && disclosureName.equalsIgnoreCase(TILA_STRING_NAME)) {
					handleDisclosureDeclination( lendingAppInstanceIdStr ) ;
					accountToUpdate.Is_VCL_TILA_Declined__c = true ;
					accountToUpdate.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_TILA_DECLINED;
					lendingAppInstance.fsCore__Application_Status__c = TILA_WITHDRAWN_STATUS ;
					lendingAppInstance.Withdraw_Reason__c = ClientPortal_Constants.VCL_TILA_WITHDRAW_REASON;
					lendingAppInstance.fsCore__Is_Application_Read_Only__c = true ;
					updateLendingApplication = true ;
					
				} else if(isAccepted && disclosureName.equalsIgnoreCase(BANK_ATD_STRING_NAME)) {
					accountToUpdate.Is_VCL_Bank_ATD_Accepted__c = true ;
					attachBankATDDisclosure(lendingAppInstance, accountDetails.Name);
				} else if (!isAccepted && disclosureName.equalsIgnoreCase(BANK_ATD_STRING_NAME)){
					handleDisclosureDeclination( lendingAppInstanceIdStr ) ;
					accountToUpdate.Is_VCL_Bank_ATD_Declined__c = true ;
					accountToUpdate.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_BANK_ATD_DECLINED;
					lendingAppInstance.fsCore__Application_Status__c = WITHDRAWN_STATUS ;
					lendingAppInstance.Withdraw_Reason__c = ClientPortal_Constants.VCL_ATD_WITHDRAW_REASON;
					lendingAppInstance.fsCore__Is_Application_Read_Only__c = true ;
					updateLendingApplication = true ;
				}
				
				if(updateLendingApplication) {
					update lendingAppInstance ;
				}
				update accountToUpdate ;
			} catch (Exception exceptn) {
				System.debug('Error: ' + exceptn.getMessage());
				Database.rollback(sp);
				resultStr = exceptn.getMessage() ;
			}
			return resultStr ;
		}
		
		private static void handleDisclosureDeclination(Id lendingAppInstanceId){
			
			List<Account> accountsToUpdate = new List<Account>();
			
			List<Account> accountsRelToLendingAppln = [SELECT Id, IsCustomerPortal 
													   FROM Account 
													   Where Id in 
													   (SELECT fsCore__Account_Name__c FROM fsCore__Lending_Application_Customer__c 
														WHERE fsCore__Lending_Application_Number__c = :lendingAppInstanceId)];
			for(Account relAccount : accountsRelToLendingAppln ){
				relAccount.IsCustomerPortal = false;
				relAccount.VCL_Portal_Status1__c = ClientPortal_Constants.WITHDRAWN_STATUS ;
				accountsToUpdate.add(relAccount);
			}
			
			update accountsToUpdate;
		}
		
		@Future(callout=true)
		public static void uploadFileToBox(Blob pdfDoc, String pBoxFolderId, String pFileName) {
			
			CreateBoxFolderHandler.copyDocumentToBox(pdfDoc , pBoxFolderId , pFileName) ;
		}
		
		@Future(callout=true)
		private static void getBoxIdForLendingApp(String lendingApplnId) {
			String boxFolderId = '' ;
			fsCore__Lending_Application__c userLendingAppln = [SELECT id, BoxFolderId__c
															   FROM fsCore__Lending_Application__c
															   WHERE Id =:lendingApplnId LIMIT 1] ;
			
			boxFolderId = userLendingAppln.BoxFolderId__c ;
			
			if(String.isBlank(boxFolderId)) {
				Map<ID,String> appToBoxMap = CreateBoxFolderHandler.createFolderForApplications( new Set<Id> {lendingApplnId} , true) ;
			}
			
		}
		
		@TestVisible @Future(callout=true)
		private static void uploadFileToBoxTilaEsign(Blob pdfDoc, String lendingApplnId , String pFileName) {
			String boxFolderId = '' ;
			fsCore__Lending_Application__c userLendingAppln = [SELECT id, BoxFolderId__c
															   FROM fsCore__Lending_Application__c
															   WHERE Id =:lendingApplnId LIMIT 1] ;
			
			boxFolderId = userLendingAppln.BoxFolderId__c ;
			
			pFileName = (pFileName.contains('.pdf')) ? pFileName : pFileName + '.pdf';
			CreateBoxFolderHandler.copyDocumentToBox(pdfDoc , boxFolderId , pFileName) ;
		}
		
		
		private static void attachEsignDisclosure(fsCore__Lending_Application__c lendingAppInstance , String accountName){
			String fileName = accountName + E_SIGN_DISCLOSURE + String.valueOf(system.now()) + '.pdf' ;
			PageReference esignDisclosurePR = new PageReference (ESIGN_PDF_GENERATION_URL + lendingAppInstance.Id);
			Blob esignDisclosureBody;
			if(Test.isRunningTest()){
				String tempString = 'Test content';
				esignDisclosureBody = Blob.valueOf(tempString);
			}else{
				esignDisclosureBody = esignDisclosurePR.getContentAsPDF();
			}
			createNAttachDisclosure(lendingAppInstance.Id , fileName, esignDisclosureBody) ;
			String boxFileName = accountName + E_SIGN_DISCLOSURE + Date.today() ;
			boxFileName = boxFileName.replace(' ', '').replace('-', '') ;
			//getBoxIdForLendingApp(lendingAppInstance.Id) ;
			uploadFileToBoxTilaEsign(esignDisclosureBody , lendingAppInstance.Id , boxFileName) ;
		}
		
		@TestVisible
		private static void sendMailWithAttachmentToUser(Id contactId, Id accountId, List<String> toemailAddrs, String fileName, Blob disclosureBody) {
			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'clientservice@versaralending.com'];

			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.setTargetObjectId(contactId); 
			EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName= :TILA_EMAIL_TEMPLATE_NAME];
			message.setTemplateID(emailTemplate.Id); 
			message.setWhatId(accountId);
			message.toAddresses = toemailAddrs;
			if ( owea.size() > 0 ) {
				message.setOrgWideEmailAddressId(owea.get(0).Id);
			}
			List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
			Messaging.EmailFileAttachment tilaDisclosure = new Messaging.EmailFileAttachment();
			tilaDisclosure.setFileName(fileName);
			tilaDisclosure.setBody(disclosureBody);
			attachments.add(tilaDisclosure);
			message.setFileAttachments(attachments);
			
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
				Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
			
			if (results[0].success) 
			{
				System.debug('The email was sent successfully.');
			} else {
				System.debug('The email failed to send: ' +  results[0].errors[0].message);
			}
		}
		
		private static void createNAttachDisclosure(Id parentId, String fileName, Blob disclosureBody) {
			
			ContentVersion contentVersnObj = new ContentVersion();
			contentVersnObj.ContentLocation = 'S';
			contentVersnObj.PathOnClient = fileName + '.pdf';
			contentVersnObj.Title = fileName; 
			contentVersnObj.VersionData = disclosureBody;
			insert contentVersnObj;
			
			Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersnObj.Id].ContentDocumentId;
			
			ContentDocumentLink disclosureLink = new ContentDocumentLink();
			disclosureLink.ContentDocumentId = conDoc;
			disclosureLink.LinkedEntityId = parentId; 
			disclosureLink.ShareType = 'I'; 
			insert disclosureLink;
			
		}
		
		@TestVisible
		private static void attachLoanAgreement(fsCore__Lending_Application__c lendingAppInstance, Account customerAccount){
			String fileName = customerAccount.Name + LOAN_AGREEMENT_DISCLOSURE + String.valueOf(system.now())+ '.pdf' ;
			
			PageReference loanAgreementPR = new PageReference (LOAN_AGREEMENT_PDF_GENERATION_URL);
			Blob loanAgreementBody;
			if(Test.isRunningTest()){
				String tempString = 'Test content';
				loanAgreementBody = Blob.valueOf(tempString);
			}else{
				loanAgreementBody = loanAgreementPR.getContentAsPDF();
			}
			if(!Test.isRunningTest()){
				createNAttachDisclosure(lendingAppInstance.Id , fileName, loanAgreementBody) ; 
			}        
			String boxFileName = customerAccount.Name + LOAN_AGREEMENT_DISCLOSURE + Date.today() ;
			boxFileName = boxFileName.replace(' ', '').replace('-', '') ;
			//getBoxIdForLendingApp(lendingAppInstance.Id) ;
			uploadFileToBoxTilaEsign(loanAgreementBody , lendingAppInstance.Id , boxFileName) ;
		}

		@TestVisible
		private static void attachMLAAgreement(fsCore__Lending_Application__c lendingAppInstance, Account customerAccount){
			String fileName = customerAccount.Name + MLA_DISCLOSURE + String.valueOf(system.now())+ '.pdf' ;
			
			PageReference mlaPageRef = new PageReference (getAgreementDownloadURI('MLA', lendingAppInstance.Id));
			Blob loanAgreementBody;
			if(Test.isRunningTest()){
				String tempString = 'Test content';
				loanAgreementBody = Blob.valueOf(tempString);
			}else{
				loanAgreementBody = mlaPageRef.getContentAsPDF();
			}
			if(!Test.isRunningTest()){
				createNAttachDisclosure(lendingAppInstance.Id , fileName, loanAgreementBody) ; 
			}        
			String boxFileName = customerAccount.Name + MLA_DISCLOSURE + Date.today() ;
			boxFileName = boxFileName.replace(' ', '').replace('-', '') ;
			uploadFileToBoxTilaEsign(loanAgreementBody , lendingAppInstance.Id , boxFileName) ;
		}
		
		private static void attachTILADisclosure(fsCore__Lending_Application__c lendingAppInstance, Account customerAccount){
			String fileName = customerAccount.Name + TILA_DISCLOSURE + String.valueOf(system.now())+ '.pdf' ;
			
			PageReference tilaDisclosurePR = new PageReference (TILA_PDF_GENERATION_URL + lendingAppInstance.Id);
			Blob tilaDisclosureBody;
			if(Test.isRunningTest()){
				String tempString = 'Test content';
				tilaDisclosureBody = Blob.valueOf(tempString);
			}else{
				tilaDisclosureBody = tilaDisclosurePR.getContentAsPDF();
			}
			if(!Test.isRunningTest()){
				createNAttachDisclosure(lendingAppInstance.Id , fileName, tilaDisclosureBody) ;  
			}
			
			String boxFileName = customerAccount.Name + TILA_DISCLOSURE + Date.today() ;
			boxFileName = boxFileName.replace(' ', '').replace('-', '') ;
			//getBoxIdForLendingApp(lendingAppInstance.Id) ;
			uploadFileToBoxTilaEsign(tilaDisclosureBody , lendingAppInstance.Id , boxFileName) ;
			
			List<String> toemailAddrs = new List<String> { customerAccount.Person_Email__c };
				sendMailWithAttachmentToUser(customerAccount.PersonContactId, customerAccount.Id, toemailAddrs, fileName, tilaDisclosureBody) ;
		}
		
		
		
		@AuraEnabled
		public static LendingApplicationVCLWrapper getDefaultValue() {
			
			LendingApplicationVCLWrapper wrapper = new LendingApplicationVCLWrapper();
			Account userAccount = new Account();
			User userInstance = new User();
			List<User> userList = new List<User>();
			IncomeWrapper primaryIncomeWrapper = new IncomeWrapper();
			List<IncomeWrapper> additionalIncomes = new List<IncomeWrapper>();
			
			Savepoint sp = Database.setSavepoint();
			
			try{
				userList = [SELECT Id, Name, AccountId
							FROM User
							WHERE Id =: UserInfo.getUserId()
							AND IsPortalEnabled = true];
				
				if (!userList.isEmpty()) {
					userInstance = userList[0];
				}
				Id userAccountId = userInstance.accountId ;
				if(String.isNotBlank(userAccountId)){
					userAccount = [SELECT Id, PersonEmail, FirstName, LastName, Name,Person_Email__c , Is_Income_Added__c, Is_VCL_Application_Submitted__c,
								   Is_VCL_ESIGN_Accepted__c, Is_VCL_ESign_Declined__c, Is_VCL_Portal_Co_Applicant__c, Is_SSN_Submitted__c,
								   Is_VCL_TILA_Accepted__c, Is_VCL_TILA_Declined__c, PersonContactId, VCL_Portal_Status1__c, Is_Bank_Info_Added__c,
								   VCL_Related_Portal_Account__r.VCL_Portal_Status1__c, VCL_Related_Portal_Account__c, MLA_Borrower__c
								   FROM Account
								   WHERE Id=: userAccountId];
					wrapper.accountId = userAccount.Id;
					Id financialRecordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
					
					ClientPortal_IncomeInformationWrapper incomeInfo = getIncomeInformation(userAccountId);
					wrapper.primaryIncome = incomeInfo.primaryIncome;
					wrapper.additionalIncomes = incomeInfo.additionalIncomes;
					Id liabilityRecordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Liability') ;
					Id contactId = getContactForAccount(userAccount.Id) ;
					List<fsCore__Financial__c> getLiabilitiesForAccount = getLiabilitiesListForAccount(userAccount.Id, contactId, liabilityRecordTypeId) ;
					if(!getLiabilitiesForAccount.isEmpty()) {
						userAccount.Housing_Type__c = getLiabilitiesForAccount[0].Housing_Type__c ;
						userAccount.Monthly_Mortgage_or_Rent_Payment__c = getLiabilitiesForAccount[0].fsCore__Verified_Amount__c ;
					}
					wrapper.accountInstance = userAccount;
				}            
				List<fsCore__Lending_Application__c> appList = [SELECT Id, Name, fsCore__Primary_Customer_Account__c,fsCore__Rate__c,
																Annual_Percent_Rate_Formula__c,fsCore__Payment_Start_Date__c,fsCore__Payment_Amount__c,
																fsCore__Number_Of_Months__c, fsCore__Maturity_Date__c,fsCore__Total_Interest_Amount__c,
																fsCore__Total_Financial_Charge__c,fsCore__Finance_Fee__c, fsCore__Loan_Amount__c,Payment_Amount_Monthly_Formula__c, 
																fsCore__Financed_Amount__c,Rate_Formula__c,fsCore__Primary_Customer_Account__r.fsCore__Email__c,
																fsCore__Primary_Customer_Account__r.PersonEmail,fsCore__Primary_Customer_Account__r.PersonMailingAddress,
																fsCore__Primary_Customer_Account__r.PersonMailingCity,fsCore__Primary_Customer_Account__r.PersonMailingState,
																fsCore__Primary_Customer_Account__r.PersonMailingStreet,fsCore__Primary_Customer_Account__r.FirstName,
																fsCore__Primary_Customer_Account__r.LastName,fsCore__Payment_Cycle__c, fsCore__Annual_Percent_Rate__c,
																fsCore__Primary_Customer_Account__r.PersonMailingPostalCode ,fsCore__Primary_Customer_Account__r.Is_Mailing_Home_Address_Different__c,
																fsCore__Number_Of_Repayments__c,fsCore__Total_Of_Payments__c, BoxFolderId__c, 
																(select id,name,Person_Name_Formula__c, Annual_Stated_Income__c, fsCore__Contact_Name__r.fsCore__Other_Address_Formula__c,
																 fsCore__Contact_Name__r.OtherAddress,fsCore__Contact_Name__r.OtherCity,fsCore__Contact_Name__r.OtherState,
																 fsCore__Contact_Name__r.OtherStreet,fsCore__Contact_Name__r.OtherPostalCode, Velocify_Stated_Income__c,
																 Mailing_City_Formula__c, Mailing_State_Formula__c, Mailing_Street_Address_Formula__c, Mailing_Zip__c,Is_mailing_address_different__c
																 FROM fsCore__Lending_Application_Customer__r 
																 WHERE fsCore__Account_Name__c = :wrapper.accountId LIMIT 1)
																FROM fsCore__Lending_Application__c WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
																												 FROM fsCore__Lending_Application_Customer__c 
																												 WHERE fsCore__Account_Name__c = :wrapper.accountId)
																//AND RecordType.DeveloperName!= 'Read_Only'
																AND fsCore__Is_Application_Read_Only__c = false //FSpectra
																ORDER BY SystemModStamp DESC
																LIMIT 1];
				
				if(appList.isEmpty() == False) {
					// populate the box folder id for lendinga appln if not present
					getBoxIdForLendingApp(appList[0].Id) ;
					
					wrapper.lendingAppInstance = appList[0];
					for(fsCore__Lending_Application_Customer__c applicationCustomer : appList[0].fsCore__Lending_Application_Customer__r){
						wrapper.lendingAppCustomer = applicationCustomer;
					}
				}
				
				if (wrapper.accountId != null) {
					List<fsCore__Lending_Application_Pricing_Offer__c> offerList = [
						select Id,fsCore__Lending_Application_Number__c
						from fsCore__Lending_Application_Pricing_Offer__c
						where fsCore__Lending_Application_Number__c in (select Id from fsCore__Lending_Application__c where fsCore__Primary_Customer_Account__c =: wrapper.accountId)
					];
					if(offerList.isEmpty() == False && offerList.size()>0) {
						wrapper.lendingAppPricingOfferInstance = offerList;
					}
				}
				
			} catch (Exception exceptn) {
				Database.rollback(sp);
				throw exceptn ;
			}
			
			return wrapper;
		}
		
		public static ClientPortal_IncomeInformationWrapper getIncomeInformation(Id userAccountId){
			ClientPortal_IncomeInformationWrapper incomeInfo = new ClientPortal_IncomeInformationWrapper();
			IncomeWrapper primaryIncomeWrapper = new IncomeWrapper();
			List<IncomeWrapper> additionalIncomes = new List<IncomeWrapper>();
			if(String.isNotBlank(userAccountId)){
				Map<Id,Id> incomeIdVsCurrentEmpId = new Map<Id, Id>();
				Map<Id,Id> incomeIdVsPreviousEmpId = new Map<Id, Id>();
				List<Id> empIdToQuery = new List<Id>();
				Map<Id, fsCore__Employment__c> employerIdMap = new Map<Id, fsCore__Employment__c>();
				List<fsCore__Financial__c> incomeList = new List<fsCore__Financial__c>();
				Id financialRecordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
				
				for(fsCore__Financial__c income : [SELECT Id, fsCore__Financial_Type__c,
												   fsCore__Stated_Amount__c,
												   Employment_Less_Than_1_Year__c,
												   Is_Primary_Income__c,
												   fsCore__Contact_Name__c,
												   fsCore__Account_Name__c,
												   Employment_Name__c, 
												   Previous_Employment_Name__c,
												   Start_Date__c, fsCore__Is_Active__c
												   FROM fsCore__Financial__c
												   WHERE (fsCore__Account_Name__c =: userAccountId OR
														  fsCore__Contact_Name__c =: userAccountId)
												   AND recordTypeId =: financialRecordTypeId
												   AND fsCore__Is_Active__c = true
												   ORDER BY CreatedDate DESC]){
													   incomeList.add(income);
													   if(income.Employment_Name__c != null){
														   empIdToQuery.add(income.Employment_Name__c);
													   }
													   if(income.Previous_Employment_Name__c != null){
														   empIdToQuery.add(income.Previous_Employment_Name__c);
													   }
												   }
				if(!empIdToQuery.isEmpty()){
					employerIdMap = new Map<Id, fsCore__Employment__c>([SELECT Id, fsCore__Employer_Name__c, fsCore__Title__c, fsCore__Salary__c, fsCore__Start_Date__c, fsCore__Employment_Type__c, fsCore__End_Date__c, fsCore__Street__c, fsCore__City__c, fsCore__State__c FROM fsCore__Employment__c WHERE Id IN :empIdToQuery]);
				}
				for(fsCore__Financial__c income : incomeList){
					IncomeWrapper incomewrapper = new IncomeWrapper();
					if(income.Is_Primary_Income__c){
						incomewrapper.income = income;
						if(income.Employment_Name__c != null && employerIdMap.containsKey(income.Employment_Name__c)){
							incomewrapper.employment = employerIdMap.get(income.Employment_Name__c);
						}else{
							incomewrapper.employment = new fsCore__Employment__c();
						}
						if(income.Previous_Employment_Name__c != null && employerIdMap.containsKey(income.Previous_Employment_Name__c)) {
							incomewrapper.previousEmployment = employerIdMap.get(income.Previous_Employment_Name__c);
						} else {
							incomewrapper.previousEmployment = new fsCore__Employment__c();
						}
						primaryIncomeWrapper = incomewrapper;
					}
					else {
						incomewrapper.income = income;
						if(income.Employment_Name__c != null && employerIdMap.containsKey(income.Employment_Name__c)) {
							incomewrapper.employment = employerIdMap.get(income.Employment_Name__c);
						} else {
							incomewrapper.employment = new fsCore__Employment__c();
						}
						if(income.Previous_Employment_Name__c != null && employerIdMap.containsKey(income.Previous_Employment_Name__c)) {
							incomewrapper.previousEmployment = employerIdMap.get(income.Previous_Employment_Name__c);
						} else {
							incomewrapper.previousEmployment = new fsCore__Employment__c();
						}
						if(additionalIncomes.size() < 4){
							additionalIncomes.add(incomewrapper);
						}
					}
					if(primaryIncomeWrapper.income == null){
						primaryIncomeWrapper.income = new fsCore__Financial__c();
						primaryIncomeWrapper.employment = new fsCore__Employment__c();
						primaryIncomeWrapper.previousEmployment = new fsCore__Employment__c();
					}
				}
			}
			incomeInfo.primaryIncome = primaryIncomeWrapper;
			incomeInfo.additionalIncomes = additionalIncomes;
			return incomeInfo;
		}
		@TestVisible
		private static void initiateChecklistCreation(Account accountObj){
			if(accountObj != null && accountObj.id != null){
				List<fsCore__Lending_Application__c> appList = [SELECT Id, (select id
																			FROM fsCore__Lending_Application_Customer__r 
																			WHERE fsCore__Account_Name__c = :accountObj.Id LIMIT 1)
																FROM fsCore__Lending_Application__c
																WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
																			 FROM fsCore__Lending_Application_Customer__c 
																			 WHERE fsCore__Account_Name__c = :accountObj.Id)
																//AND RecordType.DeveloperName!= 'Read_Only'
																AND fsCore__Is_Application_Read_Only__c = false //FSpectra
																ORDER BY SystemModStamp DESC
																LIMIT 1];
				if(!appList.isEmpty()){
					Set<id> pApplicationIds = new Set<id>{appList[0].Id};
						fsCore.ActionInput acrInput = new fsCore.ActionInput();
					acrInput.addRecords(pApplicationIds);
					GenerateCustomChkLstActionProcessor checklistActionProcessor = new GenerateCustomChkLstActionProcessor();
					checklistActionProcessor.setInput(acrInput);
					checklistActionProcessor.process();
				}
			}
		}
		
		private static Id getContactForAccount(Id accountId) {
			Contact contactForAccount = [SELECT Id, Name FROM Contact WHERE AccountId = :accountId] ;
			return contactForAccount.Id ;
		}
		
		private static List<fsCore__Financial__c> getLiabilitiesListForAccount (Id accountId, Id contactId , Id liabilityRecordTypeId) {        
			List<fsCore__Financial__c> getLiabilitiesForAccount = [SELECT Id, RecordTypeId,fsCore__Account_Name__c, Name, Housing_Type__c, fsCore__Verified_Amount__c
																   FROM fsCore__Financial__c
																   WHERE RecordTypeId = :liabilityRecordTypeId AND fsCore__Contact_Name__c = :contactId] ;
			return getLiabilitiesForAccount ;
		}
		
		@AuraEnabled
		public static String updateIncomeInformation(String primaryIncomeWrapperString, String additionalIncomesString, String accountInstanceString, Boolean isHomePage) {
			
			String result = 'Success';
			Savepoint sp = Database.setSavepoint();
			Account accountInstance = new Account();
			IncomeWrapper primaryIncomeWrapper;
			List<IncomeWrapper> additionalIncomes;
			List<fsCore__Financial__c> incomeToUpsert = new List<fsCore__Financial__c>();
			if(String.isNotBlank(accountInstanceString)){
				accountInstance = (Account)JSON.deserialize(accountInstanceString, Account.class);
			}
			if(String.isNotBlank(primaryIncomeWrapperString)) {
				primaryIncomeWrapper = (IncomeWrapper)JSON.deserialize(primaryIncomeWrapperString, IncomeWrapper.class);
			}
			if(String.isNotBlank(additionalIncomesString)) {
				additionalIncomes =  (List<IncomeWrapper>)JSON.deserialize(additionalIncomesString, List<IncomeWrapper>.class);
			}
			
			fsCore__Financial__c primaryIncome = new fsCore__Financial__c();
			fsCore__Employment__c primaryEmployment = new fsCore__Employment__c();
			fsCore__Employment__c primaryPreviousEmployment = new fsCore__Employment__c();
			try {
				if(primaryIncomeWrapper != null) {
					if(String.isNotBlank(primaryIncomeWrapper.income.fsCore__Financial_Type__c)) {
						primaryIncome = primaryIncomeWrapper.income;
						primaryIncome.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
						primaryIncome.Is_Primary_Income__c = true;
						primaryIncome.fsCore__Frequency__c = 'Annual';
						primaryIncome.fsCore__Account_Name__c = accountInstance.Id;
						primaryIncome.fsCore__Contact_Name__c = accountInstance.PersonContactId;
						primaryIncome.fsCore__Is_Active__c = true;
					}
					if(String.isNotBlank(primaryIncomeWrapper.employment.fsCore__Employer_Name__c)) {
						primaryEmployment = primaryIncomeWrapper.employment;
						primaryEmployment.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Employment__c', 'Employed');
						primaryEmployment.fsCore__Start_Date__c = primaryIncomeWrapper.income.Start_Date__c;
						primaryEmployment.fsCore__Salary__c = primaryIncome.fsCore__Stated_Amount__c;
						primaryEmployment.Is_Primary_Employment__c = true;
						if(String.isBlank(primaryEmployment.Id)) {
							primaryEmployment.fsCore__Contact_Name__c = accountInstance.PersonContactId;
						}
						upsert primaryEmployment;
						primaryIncome.Employment_Name__c = primaryEmployment.Id;
					} else {
						primaryIncome.Employment_Name__c = null;
					}
					if(primaryIncomeWrapper.previousEmployment != null && String.isNotBlank(primaryIncomeWrapper.previousEmployment.fsCore__Employer_Name__c)) {
						primaryPreviousEmployment = primaryIncomeWrapper.previousEmployment;
						primaryPreviousEmployment.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Employment__c', 'Employed');
						if(String.isBlank(primaryPreviousEmployment.Id)) {
							primaryPreviousEmployment.fsCore__Contact_Name__c = accountInstance.PersonContactId;
						}
						upsert primaryPreviousEmployment;
						primaryIncome.Previous_Employment_Name__c = primaryPreviousEmployment.Id;
					} else {
						primaryIncome.Previous_Employment_Name__c = null;
					}
					incomeToUpsert.add(primaryIncome);
				}
				if(additionalIncomes != null){
					for(IncomeWrapper incomeWrapper : additionalIncomes) {
						fsCore__Financial__c additionalIncome = new fsCore__Financial__c();
						fsCore__Employment__c additionalEmployment = new fsCore__Employment__c();
						if(String.isNotBlank(incomeWrapper.income.fsCore__Financial_Type__c)) {
							additionalIncome = incomeWrapper.income;
							additionalIncome.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
							additionalIncome.fsCore__Frequency__c = 'Annual';
							additionalIncome.fsCore__Account_Name__c = accountInstance.Id;
							additionalIncome.fsCore__Contact_Name__c = accountInstance.PersonContactId;
							additionalIncome.fsCore__Is_Active__c = true;
						}
						if(String.isNotBlank(incomeWrapper.employment.fsCore__Employer_Name__c)) {
							additionalEmployment = incomeWrapper.employment;
							additionalEmployment.recordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Employment__c', 'Employed');
							additionalEmployment.fsCore__Start_Date__c = incomeWrapper.income.Start_Date__c;
							if(String.isBlank(additionalEmployment.Id)) {
								additionalEmployment.fsCore__Contact_Name__c = accountInstance.PersonContactId;
							}
							additionalEmployment.fsCore__Salary__c = incomeWrapper.income.fsCore__Stated_Amount__c;
							upsert additionalEmployment;
							additionalIncome.Employment_Name__c = additionalEmployment.Id;
						} else {
							additionalIncome.Employment_Name__c = null;
						}
						incomeToUpsert.add(additionalIncome);
					}
				}
				if(!incomeToUpsert.isEmpty()){
					upsert incomeToUpsert;
				}
				if(isHomePage){
					Account acc = new Account(Id = accountInstance.Id);
					if(accountInstance.Is_VCL_Portal_Co_Applicant__c){
						acc.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_UPLOAD_DOCUMENT_STATUS;
					}else{
						acc.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_VERIFY_SSN_STATUS;
					}
					update acc;
					initiateChecklistCreation(accountInstance);
				}
			} catch (Exception e) {
				Database.rollback(sp);
				result = e.getMessage();
				throw new AuraHandledException(e.getMessage());
			}
			return result;
		}
		
		@AuraEnabled
		public static CheckListWrapper getCheckLists(String lendingApplicationId){
			String status = 'Success';
			CheckListWrapper returnWrapper = new CheckListWrapper();
			list<LendingApplicationCheckListWrapper> checkListWrapperList = new List<LendingApplicationCheckListWrapper>();
			try{
				List<User> userList = [SELECT Id, Name, AccountId
									   FROM User
									   WHERE Id =: UserInfo.getUserId()
									   AND IsPortalEnabled = true];
				Id accountId;
				if(userList.size() > 0){
					accountId = userList[0].AccountId;
				}
				Id financialRecordTypeId = ClientPortal_Utility.getRecordTypeId('fsCore__Financial__c', 'Income');
				Set<Id> incomeIdSet = new Set<Id>();
				fsCore__Financial__c primaryIncome = [SELECT Id, Is_Primary_Income__c
													  FROM fsCore__Financial__c
													  WHERE (fsCore__Account_Name__c =: accountId OR
															 fsCore__Contact_Name__c =: accountId)
													  AND recordTypeId =: financialRecordTypeId
													  AND fsCore__Is_Active__c = true
													  AND Is_Primary_Income__c = true
													  ORDER BY CreatedDate DESC LIMIT 1];
				incomeIdSet.add(primaryIncome.Id);
				for(fsCore__Financial__c income : [SELECT Id, Is_Primary_Income__c
												   FROM fsCore__Financial__c
												   WHERE (fsCore__Account_Name__c =: accountId OR
														  fsCore__Contact_Name__c =: accountId)
												   AND recordTypeId =: financialRecordTypeId
												   AND fsCore__Is_Active__c = true
												   AND Is_Primary_Income__c = false
												   ORDER BY CreatedDate DESC LIMIT 4]){
													   incomeIdSet.add(income.Id);
												   }
				
				for(fsCore__Lending_Application_Checklist__c checkListObject : [SELECT Id, Is_Checklist_Auto_Generated__c, fsCore__Checklist_Item__c,
																				Name, fsCore__Is_Required__c, fsCore__Status__c
																				FROM fsCore__Lending_Application_Checklist__c
																				WHERE fsCore__Lending_Application_Number__c = :lendingApplicationId
																				AND fsCore__Status__c != :UNAPPLICABLE_CHKLIST_STATUS
																				//AND fsCore__Status__c != :UPLOADED_CHKLIST_STATUS
																				AND Applicant_Name__c = :accountId
																				AND (Financial_Name__c IN :incomeIdSet
																					 OR Financial_Name__c = null)]){
																						 
																						 LendingApplicationCheckListWrapper wrapperObj = new LendingApplicationCheckListWrapper();
																						 wrapperObj.checklist = checkListObject;
																						 if(checkListObject.fsCore__Status__c == PENDING_CHKLIST_STATUS || checkListObject.fsCore__Status__c == REJECTED_CHKLIST_STATUS){
																							 wrapperObj.isPending = true;
																						 }else{
																							 wrapperObj.isPending = false;
																						 }
																						 checkListWrapperList.add(wrapperObj);
																					 }
			}catch(Exception exp){
				status = exp.getMessage();
			}
			returnWrapper.cheklistWrapperList = checkListWrapperList;
			returnWrapper.status = status;
			return returnWrapper;
		}
		
		private static fsCore__Lending_Application__c getLendingApplicationForAccount(Id accountId){
			fsCore__Lending_Application__c[] lendingApplicationList = [SELECT Id, Name, fsCore__Application_Status__c, fsCore__Current_Stage_Name__c
																	   FROM fsCore__Lending_Application__c
																	   WHERE Id IN (SELECT fsCore__Lending_Application_Number__c
																					FROM fsCore__Lending_Application_Customer__c 
																					WHERE fsCore__Account_Name__c = :accountId)
																	   AND fsCore__Is_Application_Read_Only__c = false //FSpectra
																	   ORDER BY SystemModStamp DESC
																	   LIMIT 1];
			if(!lendingApplicationList.isEmpty()){
				return lendingApplicationList[0];
			}
			return null;
		}

		@TestVisible @future
		private static void markLendingAppInProgress(Id accountId){
			fsCore__Lending_Application__c lendingApplication = getLendingApplicationForAccount(accountId);
			if(lendingApplication != null){
				fsCore__Lending_Application__c lendingAppInstance = new fsCore__Lending_Application__c(Id = lendingApplication.Id);
				lendingAppInstance.fsCore__Application_Status__c = LEND_APP_INPROGRESS;
				lendingAppInstance.Is_Doc_Processing__c = true;
				update lendingAppInstance;
			}
		}
		
		private static Boolean areAnyChecklistRemainingForCurrentUser(Id lendingApplicationId){
			List<User> userList = [SELECT Id, Name, AccountId
								   FROM User
								   WHERE Id =: UserInfo.getUserId()
								   AND IsPortalEnabled = true];
			Id accountId;
			if(userList.size() > 0){
				accountId = userList[0].AccountId;
			}
			String query = 'SELECT count() FROM fsCore__Lending_Application_Checklist__c WHERE fsCore__Lending_Application_Number__c = :lendingApplicationId AND Applicant_Name__c = :accountId AND fsCore__Status__c != :UNAPPLICABLE_CHKLIST_STATUS AND fsCore__Status__c != :UPLOADED_CHKLIST_STATUS';
			Integer checklistRemaining = Database.countQuery(query);
			if(checklistRemaining > 1){
				return true;
			}else{
				return false;
			}
		}

		@AuraEnabled
		public static string uploadDocumentToCheckList(String checkListId, String documentWrapString, String accountInstanceString, Boolean updateAccountStatus){
			String message = 'Success';
			Boolean markAccountUpdate = false;
			Set<String> documentIdSet = new Set<String>();
			List<ContentDocumentLink> documentLinkListToDelete = new List<ContentDocumentLink>();
			List<ContentDocumentLink> documentLinkListToInsert = new List<ContentDocumentLink>();
			List<ContentDocument> docListToUpdateName = new List<ContentDocument>();
			Account accountInstance = (Account)JSON.deserialize(accountInstanceString, Account.class);
			Account acc = new Account(Id=accountInstance.Id);
			if(updateAccountStatus){
				if(accountInstance.VCL_Portal_Status1__c != ClientPortal_Constants.VCL_LIST_DOCUMENT_STATUS){
					acc.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_LIST_DOCUMENT_STATUS;
					markAccountUpdate = true;
					markLendingAppInProgress(accountInstance.Id);
				}
			}
			if(getLendingApplicationForAccount(accountInstance.Id) != null && !areAnyChecklistRemainingForCurrentUser(getLendingApplicationForAccount(accountInstance.Id).Id)){
				acc.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_PORTAL_DOCS_UPLOADED_STATUS;
				markAccountUpdate = true;
			}
			if(markAccountUpdate){
				update acc;
			}
			if(!String.isBlank(documentWrapString)){   
				try{
					fsCore__Lending_Application_Checklist__c checklistObj = [SELECT Id, BoxFolderId__c, fsCore__Document_Classification__c
																			 FROM fsCore__Lending_Application_Checklist__c 
																			 WHERE Id = :checkListId];
					
					for(DocumentWrapper docWraper : (List<DocumentWrapper>)JSON.deserialize(documentWrapString, List<DocumentWrapper>.class)) {
						documentIdSet.add(docWraper.documentId);
					}
					for(ContentDocumentLink documentLink : [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility, ContentDocument.ContentSize, ContentDocument.Title
															FROM ContentDocumentLink
															WHERE ContentDocumentId IN :documentIdSet]) {
						if(documentLink.ShareType != 'I'){
							if(documentLink.ContentDocument.ContentSize > MAX_CALLOUT_FILE_SIZE){
								ContentDocument docToDelete = new ContentDocument(Id = documentLink.ContentDocumentId);
								delete docToDelete;
								Decimal fileSize = documentLink.ContentDocument.ContentSize/1000000;
								fileSize = fileSize.setScale(1);
								message = 'File size is too large (' + String.valueOf(fileSize) + ' MB). The maximum file size is ' + String.valueOf(MAX_CALLOUT_FILE_SIZE/1000000) + ' MB.';
								return message;
							}else{
								ContentDocumentLink newLink = documentLink.clone();
								newLink.LinkedEntityId = checkListId;
								newLink.ShareType = 'V';
								documentLinkListToInsert.add(newLink);
								documentLinkListToDelete.add(documentLink);
								ContentDocument doc = new ContentDocument(Id=documentLink.ContentDocumentId);
								doc.Title = accountInstance.Name + '_' + checklistObj.fsCore__Document_Classification__c + '_' + documentLink.ContentDocument.Title;
								docListToUpdateName.add(doc);
							}
						}
					}
					if(!documentLinkListToDelete.isEmpty()){
						delete documentLinkListToDelete;
						insert documentLinkListToInsert;
						update docListToUpdateName;
					}
					for(ContentVersion latestDocVersion : [SELECT VersionData, Title, FileExtension 
														   FROM ContentVersion 
														   WHERE ContentDocumentId IN :documentIdSet 
														   AND IsLatest = true]){
															   uploadFileToBox(latestDocVersion.VersionData, checklistObj.BoxFolderId__c, latestDocVersion.Title + '.' + latestDocVersion.FileExtension);
														   }
					fsCore__Lending_Application_Checklist__c checkListObject = new fsCore__Lending_Application_Checklist__c(Id = checkListId);
					checkListObject.fsCore__Status__c = UPLOADED_CHKLIST_STATUS;
					update checkListObject;
				}catch(Exception e){
					message = e.getMessage();
					throw new AuraHandledException(e.getMessage());
				}         
			}else{
				message = 'There was an error uploading your file. Please try again.';
			}
			return message;
		}
		
		@AuraEnabled
		public static void uploadFileToBox(String documentListString, String checkListId){
			Set<String> documentIdSet = new Set<String>();
			List<fsCore__Lending_Application_Checklist__c> checkList = new List<fsCore__Lending_Application_Checklist__c>();
			List<ContentDocument> docListToUpdate = new List<ContentDocument>();
			
			Account accountInstance = ClientPortal_VCLDocumentInformationCntrl.getCurrentUserAccount();
			checkList = [SELECT Id, BoxFolderId__c,fsCore__Document_Classification__c FROM fsCore__Lending_Application_Checklist__c WHERE Id = :checkListId];
			if(!checkList.isEmpty()){
				fsCore__Lending_Application_Checklist__c checklistObj = checkList[0];
				for(DocumentWrapper docWraper : (List<DocumentWrapper>)JSON.deserialize(documentListString, List<DocumentWrapper>.class)) {
					documentIdSet.add(docWraper.documentId);
				}
				for(ContentVersion latestDocVersion : [SELECT VersionData, Title,FileExtension, ContentDocument.ContentSize,ContentDocumentId 
													   FROM ContentVersion 
													   WHERE ContentDocumentId IN :documentIdSet 
													   AND IsLatest = true]){
					if(latestDocVersion.ContentDocument.ContentSize > MAX_CALLOUT_FILE_SIZE){
						ContentDocument doc = new ContentDocument(Id = latestDocVersion.ContentDocumentId);
						delete doc;
						Decimal fileSize = latestDocVersion.ContentDocument.ContentSize/1000000;
						fileSize = fileSize.setScale(1);
						throw new AuraHandledException('File size is too large (' + String.valueOf(fileSize) + ' MB). The maximum file size is ' + String.valueOf(MAX_CALLOUT_FILE_SIZE/1000000) + ' MB.');
					}
					ContentDocument doc = new ContentDocument(Id = latestDocVersion.ContentDocumentId);
					doc.title = accountInstance.Name + '_' + checklistObj.fsCore__Document_Classification__c + '_' + latestDocVersion.Title;
					docListToUpdate.add(doc);
					uploadFileToBox(latestDocVersion.VersionData, checklistObj.BoxFolderId__c, doc.title + '.' + doc.FileExtension);
				}
				if(!docListToUpdate.isEmpty()){
					update docListToUpdate;
				}
				fsCore__Lending_Application_Checklist__c checkListObject = new fsCore__Lending_Application_Checklist__c(Id = checkListId);
				checkListObject.fsCore__Status__c = UPLOADED_CHKLIST_STATUS;
				update checkListObject;
			}
		}
		
		@AuraEnabled
		public static List<LendingApplicationDocument> getDocumentsByLendingApplication(String lendingApplicationId){
        List<LendingApplicationDocument> finalDocumentList = new List<LendingApplicationDocument>();
        Map<Id, Id> documentIdVsParentId = new Map<Id, Id>();
        Map<Id, fsCore__Lending_Application_Checklist__c> checkListIdVsObject = new Map<Id, fsCore__Lending_Application_Checklist__c>();
        Set<Id> parentIdsSet = new Set<Id>();
        Set<Id> availableChecklistIdSet = new Set<Id>();
        Set<Id> docIdWithLendingAppSet = new Set<Id>();
        Set<Id> lendingAppIdSet = new Set<Id>();
        Boolean isTilaAddedToList = false;
		Boolean isEsignAddedToList = false;
		Boolean isLoanAgreementAddedToList = false;
        Boolean isDocuSignCompleted = ClientPortal_VCLBankAccountInfoCntrl.isDocusignCompleted() ;
        
        List<User> userList = [SELECT Id, Name, AccountId
                               FROM User
                               WHERE Id =: UserInfo.getUserId()
                               AND IsPortalEnabled = true];
        Id accountId;
        Account accountInstance;
        if(userList.size() > 0){
            accountId = userList[0].AccountId;
            accountInstance = [Select Id, Name FROM Account WHERE Id = :accountId];
        }
        parentIdsSet.add(lendingApplicationId);
        for(fsCore__Lending_Application_Checklist__c checkListObject : [SELECT Id, Is_Checklist_Auto_Generated__c, fsCore__Checklist_Item__c,
                                                                        Name, fsCore__Is_Required__c, fsCore__Status__c, fsCore__Document_Classification__c 
                                                                        FROM fsCore__Lending_Application_Checklist__c
                                                                        WHERE fsCore__Lending_Application_Number__c = :lendingApplicationId
                                                                        AND Applicant_Name__c = :accountId
                                                                        AND (fsCore__Status__c = :UPLOADED_CHKLIST_STATUS
                                                                             OR fsCore__Status__c = :VERIFIED_CHKLIST_STATUS)]) {
                                                                                 
                                                                                 parentIdsSet.add(checkListObject.Id);
                                                                                 checkListIdVsObject.put(checkListObject.Id, checkListObject);
                                                                             }
        for(ContentDocumentLink docLink : [SELECT ContentDocumentId, LinkedEntityId
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId IN :parentIdsSet]){
                                               documentIdVsParentId.put(docLink.ContentDocumentId, docLink.LinkedEntityId);
                                           }
			if(!documentIdVsParentId.isEmpty()){
				Boolean isATDAddedToList = false;
				Boolean addDocToList ;
				for(ContentDocument document : [SELECT Id, Title, SystemModstamp, LastModifiedDate, ContentSize
												FROM ContentDocument
												WHERE Id In :documentIdVsParentId.keyset()
												ORDER BY SystemModstamp DESC]){   
					addDocToList = true ;
					String keyString = accountInstance.Name + '_';
					
					LendingApplicationDocument lendingAppDoc = new LendingApplicationDocument();
					lendingAppDoc.enableLink = true ;
					lendingAppDoc.document = document;
					lendingAppDoc.isRecieved = true;
					lendingAppDoc.isoTimeStamp = document.SystemModstamp.getTime();
					Decimal fileInKb = document.ContentSize/1000;
					lendingAppDoc.fileSize = String.valueOf(fileInKb.setScale(2)) + ' KB';
					
					if(checkListIdVsObject.containsKey(documentIdVsParentId.get(document.Id))){
						lendingAppDoc.documentName = checkListIdVsObject.get(documentIdVsParentId.get(document.Id)).fsCore__Checklist_Item__c;
						lendingAppDoc.documentType = checkListIdVsObject.get(documentIdVsParentId.get(document.Id)).fsCore__Document_Classification__c;
						if(checkListIdVsObject.get(documentIdVsParentId.get(document.Id)).fsCore__Status__c == VERIFIED_CHKLIST_STATUS){
							lendingAppDoc.canUserDelete = false;
						}else{
							lendingAppDoc.canUserDelete = true;
						}
						availableChecklistIdSet.add(documentIdVsParentId.get(document.Id));
						finalDocumentList.add(lendingAppDoc);
						checkListIdVsObject.remove(documentIdVsParentId.get(document.Id));
					}else if(document.Title.contains(keyString)){
						addDocToList = false ;
						if(document.Title.contains(TILA_DISCLOSURE)){
							if(!isTilaAddedToList){
								lendingAppDoc.canUserDelete = false;
								lendingAppDoc.documentType = 'Agreement';
								lendingAppDoc.documentName = 'TILA';
								isTilaAddedToList = true;
								addDocToList = true ;
							}
						}else if(document.Title.contains(BANK_ATD_DISCLOSURE)) {
							if(!isATDAddedToList){
								isATDAddedToList = true;
								lendingAppDoc.canUserDelete = false;
								lendingAppDoc.documentType = 'Agreement';
								lendingAppDoc.documentName = 'ATD Bank Account E-sign';
								lendingAppDoc.enableLink = isDocuSignCompleted ;
								addDocToList = true ;
							}
						}else if(document.Title.contains(E_SIGN_DISCLOSURE)) {
							if(!isEsignAddedToList){
								isEsignAddedToList = true;
								lendingAppDoc.canUserDelete = false;
								lendingAppDoc.documentType = 'Agreement';
								lendingAppDoc.documentName = 'E-sign';
								addDocToList = true ;
							}
						}else if(document.Title.contains(LOAN_AGREEMENT_DISCLOSURE)){
							if(!isLoanAgreementAddedToList){
								isLoanAgreementAddedToList = true;
								lendingAppDoc.canUserDelete = false;
								lendingAppDoc.documentType = 'Agreement';   
								lendingAppDoc.documentName = 'Loan Agreement';
								addDocToList = true ;
							}
						 }
						if(addDocToList){
							finalDocumentList.add(lendingAppDoc);
						}
					}                    
				}
			}
			return finalDocumentList;
		}
		
		@AuraEnabled
		public static void deleteDocumentFromChecklist(Id docId, Boolean updateCheckList){
			Id finalParentId;
			for(ContentDocumentLink docLink :[Select Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = :docId]){
				Id parentId = docLink.LinkedEntityId;
				String parentObjectName = parentId.getSObjectType().getDescribe().getName();
				if(parentObjectName == 'fsCore__Lending_Application_Checklist__c'){
					finalParentId = parentId;
					break;
				}
			}
			if(finalParentId != null){
				Boolean deletedFromBox = deleteDocFromBox(docId, finalParentId);
				if(deletedFromBox){
					if(updateCheckList){
						String query = 'Select count() FROM ContentDocumentLink WHERE LinkedEntityId = :finalParentId';
						Integer childDocCount = Database.countQuery(query);
						if(childDocCount <= 1){
							fsCore__Lending_Application_Checklist__c checkList = new fsCore__Lending_Application_Checklist__c(Id = finalParentId);
							checkList.fsCore__Status__c = PENDING_CHKLIST_STATUS;
							update checkList;
						}
					}
				}else{
					throw new AuraHandledException('An error occurred while deleting the document, please try again.');
				}
			}
			ContentDocument doc = new ContentDocument(Id = docId);
			delete doc;
			
		}
		private static Boolean deleteDocFromBox(Id docId, Id chckListId){
			fsCore__Lending_Application_Checklist__c checkList = [Select Id, BoxFolderId__c FROM fsCore__Lending_Application_Checklist__c WHERE Id = :chckListId];
			ContentVersion latestDocVersion  = [SELECT VersionData, Title 
												FROM ContentVersion 
												WHERE ContentDocumentId = :docId 
												AND IsLatest = true];
			String itemName = latestDocVersion.Title;
			String folderId = checkList.BoxFolderId__c;
			String itemId = '';
			Boolean calloutSuccess = false;
			Integration_Settings__c objBoxsettings = BoxUtility.getAccessToken(false);
			BoxApiConnection api;
			if(objBoxsettings != null && !Test.isRunningTest()){
				api = new BoxApiConnection(objBoxsettings.client_Id__c,objBoxsettings.client_Secret__c);
				api.setLastRefresh(long.valueOf(objBoxsettings.lastRefresh__c));
				api.setAccessToken(objBoxsettings.access_token1__c);
				api.setExpires(long.valueOf(objBoxsettings.expires__c));
				BoxFolder box = new BoxFolder(api,folderId);
				list<BoxItem.Info> bxInfoList = box.getChildren();
				if(bxInfoList.size() > 0){
					for(BoxItem.Info item : bxInfoList){
						if((item.Name.lastIndexOf('.') != -1 && item.Name.substring(0,item.Name.lastIndexOf('.')) == itemName)
						  || (item.Name == itemName)){
							itemId = item.id;
						}
					}
					if(!String.isBlank(itemId)){
						String url = api.getBaseUrl() + 'files/' + itemId;
						BoxApiRequest request = new BoxApiRequest(api, url, BoxApiRequest.METHOD_DELETE);
						request.addJsonContentTypeHeader();
						request.setTimeout(api.getTimeout());
						HttpResponse response = request.send();
						calloutSuccess = BoxApiRequest.ensureBoxResourceResponseCode(response, 'BoxFolder.deleteFile', new set<Integer> {204}); 
					}else{
						calloutSuccess = true;
					}
				}
			}else{
				calloutSuccess = true;
			}
			return calloutSuccess;
		}
		
		@AuraEnabled
		public static void deleteDocuments(String documentWrapperString){
			if(documentWrapperString != null){
				List<ContentDocument> docToDelete = new List<ContentDocument>();
				List<DocumentWrapper> docList = (List<DocumentWrapper>)JSON.deserialize(documentWrapperString, List<DocumentWrapper>.class);
				for(DocumentWrapper doc : docList){
					ContentDocument content = new ContentDocument(Id = doc.documentId);
					docToDelete.add(content);
				}
				if(!docToDelete.isEmpty()){
					delete docToDelete;
				}
			}
		}
		
		@AuraEnabled
		public static String deleteAdditionalIncomeInformation(Id additionalIncomeId,
															   Id additionalEmploymentId) {
			String result = 'Success';
			try {
				if(additionalIncomeId != null ) {
					fsCore__Financial__c income = new fsCore__Financial__c(Id = additionalIncomeId);
					delete income;
				}
				if(additionalEmploymentId != null){
					fsCore__Employment__c employment = new fsCore__Employment__c(Id = additionalEmploymentId);
					delete employment;
				}
			}catch(Exception e){
				result = e.getMessage();
				throw e;
			}
			return result;
		}
		
		@AuraEnabled
		public static string retrieveSocialSecurityNumber(){
			User currentUser = [SELECT Id, Name, AccountId,Account.Portal_SSN__c
								FROM User
								WHERE Id = :UserInfo.getUserId()
								AND IsPortalEnabled = true LIMIT 1] ;
			return currentUser.Account.Portal_SSN__c;       
		}
		
		@AuraEnabled
		public static String savePortalSSN(String accountId, String portalSSN) {
			String resultString ;
			if(String.isBlank(accountId)) {
				resultString = ACCOUNT_NOT_FOUND_MESSAGE ;
				return resultString ;
			} 
			
			try{
				
				Account portalAccountToUpdate = new Account() ;
				portalAccountToUpdate.Id = accountId ;
				portalAccountToUpdate.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_BAV_STATUS;
				portalAccountToUpdate.Portal_SSN__c = portalSSN ;
				resultString = RESULT_SUCCESS_MESSAGE ;
				update portalAccountToUpdate ;
			} catch(Exception exptn) {
				System.debug('Error: ' + exptn.getMessage());
				resultString = exptn.getMessage() ;
			}
			return resultString ;
		}
		
		
		
		@AuraEnabled
		public static String verifyPortalSSN(String accountId, String portalSSN) {
			String resultString ;
			if(String.isBlank(accountId)) {
				resultString = ACCOUNT_NOT_FOUND_MESSAGE ;
				return resultString ;
			} 
			
			try{
				Account portalAccount = [SELECT Id, fsCore__National_Identification_Number__pc
										 FROM Account where Id = :accountId ] ;
				Account portalAccountToUpdate = new Account() ;
				portalAccountToUpdate.Id = portalAccount.Id ;
				portalAccountToUpdate.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_BAV_STATUS;
				portalAccountToUpdate.Portal_SSN__c = portalSSN ;
				if(portalAccount.fsCore__National_Identification_Number__pc == portalAccountToUpdate.Portal_SSN__c){
					resultString = RESULT_SUCCESS_MESSAGE ;
					update portalAccountToUpdate ;
				}
				else{
					resultString = SSN_NOT_VERIFIED_MSG ;
				}
			} catch(Exception exptn) {
				System.debug('Error: ' + exptn.getMessage());
				resultString = exptn.getMessage() ;
			}
			return resultString ;
		}
		
		private static void deleteAllBankAttachments(ID bankAccountId) {
			List<ContentDocument> contentDocList = new List<ContentDocument>() ;
			for(ContentDocumentLink attachmentToDelete : [SELECT Id, ContentDocumentId 
														  FROM ContentDocumentLink
														  WHERE LinkedEntityId = :bankAccountId]) {
															  contentDocList.add(new ContentDocument(
																  Id = attachmentToDelete.ContentDocumentId 
															  )) ;  
														  }
			
			if(!contentDocList.isEmpty()) {
				delete contentDocList ;
			}
		}
		
		public static Blob getContentForATDForm(String accountId) {
			Boolean generateEnvelope = false ;
			List<fsCore__Bank_Account__c> userBankAccountList = [SELECT Id, Name, fsCore__Account_Name__c, 
																 fsCore__Bank_Account_Holder_Name__c, fsCore__Bank_Account_Number__c,
																 fsCore__Bank_Account_Type__c, fsCore__Is_Active__c,
																 fsCore__Bank_Name__c, Routing_Number__c,
																 fsCore__Is_Verified__c, fsCore__Is_Primary__c,fsCore__Account_Name__r.Name
																 FROM fsCore__Bank_Account__c
																 WHERE fsCore__Account_Name__c =:accountId
																 ORDER BY CreatedDate DESC ] ;

			deleteAllBankAttachments(userBankAccountList[0].Id) ;
			Id lendingAppId = [SELECT fsCore__Lending_Application_Number__c
							   FROM fsCore__Lending_Application_Customer__c
							   WHERE fsCore__Account_Name__c = :userBankAccountList[0].fsCore__Account_Name__c
							   AND fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false
							   LIMIT 1].fsCore__Lending_Application_Number__c ;
			
			PageReference bankATDesignDisclosurePR = new PageReference (BANK_ATD_PDF_GENERATION_URL + lendingAppId + '&bankAccount=' + JSON.serialize(userBankAccountList[0]));
			Blob bankATDesignDisclosureBody;
			
			if(Test.isRunningTest()){
				String tempString = 'Test content';
				bankATDesignDisclosureBody = Blob.valueOf(tempString);
			}else{

				bankATDesignDisclosureBody = bankATDesignDisclosurePR.getContent();
			}
			
			return bankATDesignDisclosureBody ;
		}
		
		public static void storeEnvelopeIdonBank(Id bankId , String envelopeId) {
			fsCore__Bank_Account__c bankAccountObj = new fsCore__Bank_Account__c() ;
			bankAccountObj.Id = bankId ;
			bankAccountObj.VCL_Envelope_Id__c = envelopeId ;
			bankAccountObj.Docusign_Status__c = 'Sent';
			update bankAccountObj ;
		}
		
		@AuraEnabled
		public static String redirectToDocuSignURL(String accountId) {
			String resultStr ;
			try{
				fsCore__Bank_Account__c bankAccountObj = [Select Id,VCL_Envelope_Id__c,fsCore__Account_Name__r.Name  FROM fsCore__Bank_Account__c WHERE fsCore__Account_Name__c = :accountId LIMIT 1] ;
				
				
				Blob fileBodyStr = getContentForATDForm(accountId) ;
				String accountName = bankAccountObj.fsCore__Account_Name__r.Name.length() > 20 ? 
					bankAccountObj.fsCore__Account_Name__r.Name.substring(0, 20)  : 
				bankAccountObj.fsCore__Account_Name__r.Name;
				
				String atdFileName = accountName.trim() + BANK_ATD_DISCLOSURE + String.valueOf(System.now()).replace(' ', '').replace('-', '') ;
				
				Client_Portal_Portfolio__c vclPortfolio = [SELECT Id, Domain_URL__c FROM Client_Portal_Portfolio__c WHERE NAME = 'VCL' LIMIT 1] ;
				String redirectionURL = ClientPortal_VCLDocusignServiceClass.getSignerURL(UserInfo.getUserEmail(), 
																						  UserInfo.getName(), 
																						  vclPortfolio.Domain_URL__c,
																						  UserInfo.getUserId(),
																						  'Bank ATD Form', 
																						  fileBodyStr,
																						  atdFileName,
																						 bankAccountObj.Id);
							
				ApexPages.PageReference authPage = new PageReference(redirectionURL) ;
				authPage.setRedirect(true);
				if (!Test.isRunningTest()) {
					aura.redirect(authPage);
				} 
				resultStr = RESULT_SUCCESS_MESSAGE ;
			}catch(Exception excptn) {
				System.debug('@@@excptn ' + excptn.getMessage());
				System.debug('@@@stackTrace ' + excptn.getStackTraceString());
				resultStr = excptn.getMessage() ;
			}
			return resultStr ;
		}
		
		
		@AuraEnabled
		public static String saveBankAccountInfo(String accountId, BankAccountWrapper bankAccountObj) {
			String resultStr = ClientPortal_VCLBankAccountInfoCntrl.saveBankAccountInfo( accountId , bankAccountObj) ;
			
			if(resultStr.containsIgnoreCase('Error')) {
				return resultStr ;
			}        
			resultStr = RESULT_SUCCESS_MESSAGE ;
			return resultStr ;
		}
		
		
		
		@AuraEnabled
		public static BankAccountWrapper getBankAccountWrapper(String accountId) {
			List<fsCore__Bank_Account__c> userBankAccountList = [SELECT Id, Name, fsCore__Account_Name__c, 
																 fsCore__Bank_Account_Holder_Name__c, fsCore__Bank_Account_Number__c,
																 fsCore__Bank_Account_Type__c, fsCore__Is_Active__c,
																 fsCore__Bank_Name__c, Routing_Number__c,Is_VCL_Docusign_Sent__c,
																 fsCore__Is_Verified__c, fsCore__Is_Primary__c
																 FROM fsCore__Bank_Account__c
																 WHERE fsCore__Account_Name__c =:accountId
																 ORDER BY CreatedDate DESC ] ;
			if(userBankAccountList.isEmpty()){
				return new BankAccountWrapper() ;
			} else {
				BankAccountWrapper bankWrapperObj = new BankAccountWrapper() ;
				bankWrapperObj.accountHolderName = userBankAccountList[0].fsCore__Bank_Account_Holder_Name__c ;
				bankWrapperObj.bankAccountId = userBankAccountList[0].Id ;
				bankWrapperObj.accountType = userBankAccountList[0].fsCore__Bank_Account_Type__c ;
				bankWrapperObj.bankName = userBankAccountList[0].fsCore__Bank_Name__c ;
				bankWrapperObj.accountNumber = userBankAccountList[0].fsCore__Bank_Account_Number__c ;
				bankWrapperObj.reAccountNumber = userBankAccountList[0].fsCore__Bank_Account_Number__c ;
				bankWrapperObj.routingNumber = userBankAccountList[0].Routing_Number__c ;
				bankWrapperObj.isDocuSignSent = userBankAccountList[0].Is_VCL_Docusign_Sent__c ;
				return bankWrapperObj ;
			}
		}
		
		@AuraEnabled
		public static Object getAccountOverview(String lendingAppId){
			fsCore__Lending_Application_Pricing_Offer__c overview = [SELECT Id, fsCore__Rate__c, fsCore__Annual_Percent_Rate__c, fsCore__Payment_Amount__c, fsCore__Number_Of_Months__c, fsCore__Is_Accepted__c, 
																	 fsCore__Maturity_Date__c, fsCore__Total_Interest_Amount__c, fsCore__Finance_Fee__c, fsCore__Loan_Amount__c, fsCore__Prepaid_Fee__c
																	 FROM fsCore__Lending_Application_Pricing_Offer__c 
																	 WHERE fsCore__Lending_Application_Number__c = :lendingAppId
																	 AND fsCore__Is_Accepted__c = true
																	 ORDER BY SystemModstamp Desc
																	 LIMIT 1];
			return overview;
		}
		
		@AuraEnabled
		public static void updateVCLPortalStatusOnAccout(String accountId, String vclPortalStatus){
			Account acc = new Account(Id = accountId);
			acc.VCL_Portal_Status1__c = vclPortalStatus;
			update acc;
		}
		
		
		@AuraEnabled
		public static void updateVCLPortalStatusForATDOnAccout(String accountId){
			
			Account userAccount = new Account() ;
			userAccount.Id = accountId ;
			userAccount.Is_VCL_Bank_ATD_Accepted__c = true ;
			userAccount.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_UPLOAD_DOCUMENT_STATUS ;
			userAccount.Is_Bank_Info_Added__c = true;
			update userAccount ;

			fsCore__Bank_Account__c userBankAccount = [SELECT Id
													   FROM fsCore__Bank_Account__c
													   WHERE fsCore__Account_Name__c =:accountId LIMIT 1] ;
			
			userBankAccount.Is_VCL_Docusign_Sent__c = true; 
			update userBankAccount ;

			
		}
		
		@AuraEnabled
		public static List<String> retriveBankNameList() {
			return ClientPortal_VCLBankAccountInfoCntrl.retriveBankNameList() ;
		}
		
		@AuraEnabled
		public static Account updateAccountStateCheckboxes(String accountInstance, String stepCompleted){
			Account accObj = new Account();
			if(accountInstance != null && accountInstance.trim() != '' && stepCompleted != null && stepCompleted.trim() != ''){
				try{
					accObj = (Account)JSON.deserialize(accountInstance, Account.class);
					Account tempAccount = new Account(Id = accObj.Id);
					if(stepCompleted == 'Income Added'){
						if(!accObj.Is_Income_Added__c){
							accObj.Is_Income_Added__c = true;
							tempAccount.Is_Income_Added__c = true;
						}
					}else if(stepCompleted == 'SSN Submitted'){
						if(!accObj.Is_SSN_Submitted__c){
							accObj.Is_SSN_Submitted__c = true;
							tempAccount.Is_SSN_Submitted__c = true;
						}
					}else if(stepCompleted == 'Bank Added'){
						if(!accObj.Is_Bank_Info_Added__c){
							accObj.Is_Bank_Info_Added__c = true;
							tempAccount.Is_Bank_Info_Added__c = true;
						}
						tempAccount.VCL_Portal_Status1__c = ClientPortal_Constants.VCL_LIST_DOCUMENT_STATUS ;
					}else if(stepCompleted == 'Application Submitted'){
						if(!accObj.Is_VCL_Application_Submitted__c){
							accObj.Is_VCL_Application_Submitted__c = true;
							tempAccount.Is_VCL_Application_Submitted__c = true;
						}
					}
					if(!accountInstance.equals(JSON.serialize(accObj))){
						update tempAccount;
					}
				}catch(Exception exp){
					throw new AuraHandledException(exp.getMessage());
				}
			}
			return accObj;
		}
		
		@AuraEnabled
		public static List<SelectOption> createOptionList(String wrapperString){
			List<SelectOption> optionList = new List<SelectOption>();
			List<LendingApplicationCheckListWrapper> wrapperList = new List<LendingApplicationCheckListWrapper>();
			wrapperList = (List<LendingApplicationCheckListWrapper>)JSON.deserialize(wrapperString, List<LendingApplicationCheckListWrapper>.class);
			for(LendingApplicationCheckListWrapper checkListWrapObj : wrapperList){
				if(checkListWrapObj.isPending){
					SelectOption option = new SelectOption(checkListWrapObj.checklist.fsCore__Checklist_Item__c, checkListWrapObj.checklist.Id);
					optionList.add(option);
				}
			}
			return optionList;
		}
		
		private static void attachBankATDDisclosure(fsCore__Lending_Application__c lendingAppInstance , String accountName){
			String fileName = accountName + BANK_ATD_DISCLOSURE + String.valueOf(system.now()) + '.pdf' ;
			PageReference bankATDesignDisclosurePR = new PageReference (BANK_ATD_PDF_GENERATION_URL + lendingAppInstance.Id);
			Blob bankATDesignDisclosureBody;
			if(Test.isRunningTest()){
				String tempString = 'Test content';
				bankATDesignDisclosureBody = Blob.valueOf(tempString);
			}else{
				bankATDesignDisclosureBody = bankATDesignDisclosurePR.getContentAsPDF(); 
				createNAttachDisclosure(lendingAppInstance.Id , fileName, bankATDesignDisclosureBody) ;   
			}
			String boxFileName = accountName + BANK_ATD_DISCLOSURE + Date.today() ;
			boxFileName = boxFileName.replace(' ', '').replace('-', '') ;
			uploadFileToBox(bankATDesignDisclosureBody , lendingAppInstance.BoxFolderId__c, boxFileName) ; 
		}
		
		@AuraEnabled
		public static IncomeWrapper getIncomeWrapperInstance() {
			
			IncomeWrapper incomeWrapper = new IncomeWrapper();
			incomeWrapper.income = new fsCore__Financial__c();
			incomeWrapper.employment = new fsCore__Employment__c();
			incomeWrapper.previousEmployment = new fsCore__Employment__c();
			return incomeWrapper;
		}
		
		@AuraEnabled
		public static List<DocumentWrapper> getDocumentsByChecklist(String checkListDetailString){
			List<DocumentWrapper> docList = new List<DocumentWrapper>();
			Account userAccount = new Account();
			List<User> userList = [SELECT Id, Name, AccountId
								   FROM User
								   WHERE Id =: UserInfo.getUserId()
								   AND IsPortalEnabled = true];
			
			if (!userList.isEmpty()) {
				Id userAccountId = userList[0].accountId ;
				if(String.isNotBlank(userAccountId)){
					userAccount = [SELECT Id, Name
								   FROM Account
								   WHERE Id=: userAccountId];
				}
			}
			if(checkListDetailString != null && checkListDetailString.trim() != ''){
				fsCore__Lending_Application_Checklist__c checklistObj = (fsCore__Lending_Application_Checklist__c)JSON.deserialize(checkListDetailString, fsCore__Lending_Application_Checklist__c.class);
				Set<Id> contentDocIdSet = new Set<Id>();
				for(ContentDocumentLink docLink : [SELECT ContentDocumentId, LinkedEntityId
												   FROM ContentDocumentLink 
												   WHERE LinkedEntityId = :checklistObj.Id]){
													   contentDocIdSet.add(docLink.LinkedEntityId);
												   }
				if(!contentDocIdSet.isEmpty()){
					String keyString = userAccount.Name + '_';
					for(ContentDocument document : [SELECT Id, Title, SystemModstamp, LastModifiedDate, ContentSize
													FROM ContentDocument
													WHERE Id In :contentDocIdSet
													ORDER BY SystemModstamp DESC]){
						DocumentWrapper docWrap = new DocumentWrapper();
						docWrap.name = document.Title.replace(keyString, '');
						docWrap.documentId = document.Id;
						docList.add(docWrap);
					}
				}
			}
			return docList;
		}
		
		@AuraEnabled
		public static String checkIfUserCanProceed(){
			return ClientPortal_Utility.checkIfUserCanProceed();
		}
		
		@AuraEnabled(cacheable=true)
		public static string getAgreementURI(String agreementName, String lendingAppId){
			String response = 'Error';
			String baseURI = ClientPortal_Constants.VCL_SHOW_MLA_URI;
			if(agreementName != null && agreementName.trim() != ''){
				if(agreementName == 'MLA'){
					response = baseURI + '?id=' + lendingAppId;
				}
			}
			return response;
		}
		
		public static string getAgreementDownloadURI(String agreementName, String lendingAppId){
			String response = 'Error';
			String baseURI = ClientPortal_Constants.VCL_DOWNLOAD_MLA_URI;
			if(agreementName != null && agreementName.trim() != ''){
				if(agreementName == 'MLA'){
					response = baseURI + '?id=' + lendingAppId;
				}
			}
			return response;
		}

		public class LendingApplicationVCLWrapper {
			
			@AuraEnabled
			public String accountId;          
			@AuraEnabled
			public String accountLendingAppId;         
			@AuraEnabled
			public fsCore__Lending_Application__c lendingAppInstance ;  
			@AuraEnabled
			public fsCore__Lending_Application_Customer__c lendingAppCustomer ;           
			@AuraEnabled
			public List<fsCore__Lending_Application_Pricing_Offer__c> lendingAppPricingOfferInstance ;   
			@AuraEnabled
			public Account accountInstance ;
			@AuraEnabled
			public String annualStatedIncome {get; set;}
			@AuraEnabled
			public IncomeWrapper primaryIncome {get; set;}
			@AuraEnabled
			public List<IncomeWrapper> additionalIncomes {get; set;}
		}
		public class IncomeWrapper {
			@AuraEnabled
			public fsCore__Financial__c income {get; set;}
			@AuraEnabled
			public fsCore__Employment__c employment {get; set;}
			@AuraEnabled
			public fsCore__Employment__c previousEmployment {get; set;}
		}
		
		public Class LendingApplicationCheckListWrapper{
			@AuraEnabled public Boolean isPending {get;set;}
			@AuraEnabled public fsCore__Lending_Application_Checklist__c checklist {get; set;}
		}
		
		public class CheckListWrapper{
			@AuraEnabled public List<LendingApplicationCheckListWrapper> cheklistWrapperList {get; set;}
			@AuraEnabled public String status {get; set;}
		}
		
		public class DocumentWrapper{
			@AuraEnabled public String name {get; set;}
			@AuraEnabled public String documentId {get; set;}
		}
		
		public class LendingApplicationDocument{
			@AuraEnabled public String documentName {get; set;}
			@AuraEnabled public String documentType {get; set;}
			@AuraEnabled public Boolean isRecieved {get; set;}
			@AuraEnabled public Long isoTimeStamp {get; set;}
			@AuraEnabled public String fileSize {get; set;}
			@AuraEnabled public Boolean canUserDelete {get; set;}
			@AuraEnabled public Boolean enableLink {get; set;}
			@AuraEnabled public ContentDocument document {get; set;}
		}
		
		
		public class BankAccountWrapper {
			@AuraEnabled
			public String accountHolderName {get; set;}
			@AuraEnabled
			public String accountType {get; set;}
			@AuraEnabled
			public String bankName {get; set;}
			@AuraEnabled
			public String bankAccountId {get; set;}
			@AuraEnabled
			public String accountNumber {get; set;}
			@AuraEnabled
			public String reAccountNumber {get; set;}
			@AuraEnabled
			public String routingNumber {get; set;}
			@AuraEnabled
			public Boolean isDocuSignSent {get; set;}
		}
		
		public class SelectOption{
			@AuraEnabled public String name {get; set;}
			@AuraEnabled public String value {get; set;}
			
			public SelectOption(String name, String value){
				this.name = name;
				this.value = value;
			}
		}
	}