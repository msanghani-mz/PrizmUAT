@isTest
public class ClientPortal_DNLHomeCntrlTest {
    ClientPortal_DNLHomeCntrl dnl;
    
    @isTest
    public static void getAccountAndIncomeDetailsTest(){
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        fsCore__Employment__c emp = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        insert emp;
        list<Account> accList = [Select Id, PersonEmail, FirstName, MiddleName, LastName,
                                 PersonBirthdate, fsCore__National_Identification_Number__pc,
                                 U_S_Residency_Status__c, Primary_Id_Type__c, Primary_Id_Expiration_Date__c,
                                 Primary_Id_Number__c, Primary_Id_State__c,
                                 PersonOtherStreet, Person_Other_Appartment__c,
                                 PersonOtherCity, PersonOtherPostalCode, PersonOtherState,
                                 Lived_in_Home_Address_2_Year_or_Less__c, Is_Mailing_Home_Address_Different__c,
                                 Monthly_Mortgage_or_Rent_Payment__c, Housing_Type__c,
                                 Less_than_2yrs_Street_Address__c, Less_than_2yrs_Apt_Num__c,
                                 Less_than_2yrs_City__c, Less_than_2yrs_State__c, Less_than_2yrs_Zip_Code__c,
                                 PersonMailingStreet, PersonMailing_Apt__c, PersonMailingCity,
                                 PersonMailingPostalCode, PersonMailingState, Marital_Status__c,
                                 Spouse_Name__c, Spouse_Address__c, Is_Co_Applicant_Spouse__c,
                                 PersonContactId, Is_Registration_Completed__c, Client_Portal_US_State__c,
                                 Is_DNL_Portal_Disclosure_Completed__c, Is_DNL_Portal_Disclosure_Declined__c,
                                 IsCustomerPortal, Is_DNL_Portal_Notice_Completed__c FROM Account where Id =: account1.Id LIMIT 1];
        
        fsCore__Financial__c  finc = ClientPortal_TestDataFactory.buildFinancial('Liability','Payment to DRP',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Liability'),emp.Id,accList[0].Id,true);
        insert finc;
        fsCore__Financial__c  finc1 = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),emp.Id,account1.Id,true);
        finc1.Is_Primary_Income__c = true;
        finc1.Previous_Employment_Name__c = emp.Id;
        // finc1.fsCore__Account_Name__c = account1.Id;
        insert finc1;
        system.runAs(user) {
            ClientPortal_DNLIncomeWrapper dnlIncomeWrapper = new ClientPortal_DNLIncomeWrapper(); 
            List<ClientPortal_DNLIncomeWrapper.IncomeWrapper> additionalIncomes = new  List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>();
            ClientPortal_DNLIncomeWrapper.IncomeWrapper incomewrapper =
                                          new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
            IncomeWrapper.Income = finc1;
                        String dnlIncomeWrapperString = JSON.serialize(dnlIncomeWrapper);
            String additionalIncomesString = JSON.serialize(additionalIncomes);
            ClientPortal_DNLHomeCntrl.updateIncomeInformation(dnlIncomeWrapperString, additionalIncomesString);
        }
    }
    @isTest
    public static void getAccountAndIncomeDetailsTest1(){
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        fsCore__Employment__c emp = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        emp.RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Employment__c','Employed');
        insert emp;
        fsCore__Employment__c prvEmp = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        prvEmp.RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Employment__c','Employed');
        prvEmp.Is_Primary_Employment__c = true;
        insert prvEmp;
   
        fsCore__Financial__c  finc = ClientPortal_TestDataFactory.buildFinancial('Liability','Payment to DRP',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Liability'),emp.Id,account1.Id, false);
        insert finc;
        
        fsCore__Financial__c  finc1 = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),emp.Id,account1.Id,false);
        finc1.Previous_Employment_Name__c = null;
        insert finc1;
        
        fsCore__Financial__c  fincPrv = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),prvEmp.Id,account1.Id,false);
        fincPrv.Previous_Employment_Name__c = prvEmp.Id;
        fincPrv.fsCore__Account_Name__c = account1.Id;
        fincPrv.Is_Primary_Income__c = true;
        insert fincPrv;
        
        List<fsCore__Financial__c> finList = [Select id From fsCore__Financial__c Where Id=:finc1.Id];
        ContentVersion docContent = ClientPortal_TestDataFactory.createContentVersion();
        insert docContent;
        List<ContentVersion> conVerList = new List<ContentVersion>() ;
        conVerList.add(docContent) ;
        
        system.runAs(user) {
            ClientPortal_DNLIncomeWrapper dnlIncomeWrapper = new ClientPortal_DNLIncomeWrapper();
             ClientPortal_DNLIncomeWrapper.IncomeWrapper primaryIncomewrapper =
                new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
            primaryIncomewrapper.Income = fincPrv;
            primaryIncomewrapper.employment = emp;
            primaryIncomewrapper.previousEmployment = prvEmp;
            
            dnlIncomeWrapper.primaryIncome = primaryIncomewrapper;
            dnlIncomeWrapper.acc = account1;
            
            
            List<ClientPortal_DNLIncomeWrapper.IncomeWrapper> additionalIncomes = new  List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>();
   
            ClientPortal_DNLIncomeWrapper.IncomeWrapper addIncomewrapper =
                new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
            addIncomewrapper.Income = finc1;
            additionalIncomes.add(addIncomewrapper);
            
            String dnlIncomeWrapperString = JSON.serialize(dnlIncomeWrapper);
            String additionalIncomesString = JSON.serialize(additionalIncomes);
            ClientPortal_DNLHomeCntrl.updateIncomeInformation(dnlIncomeWrapperString, additionalIncomesString);
            ClientPortal_DNLHomeCntrl.getAccountAndIncomeDetails();
            ClientPortal_DNLHomeCntrl.attachFiletoParent(conVerList , account1.Id);
        }
    }
     @isTest
    public static void getAccountAndIncomeDetailsElseTest(){
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        fsCore__Employment__c emp = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        insert emp;
       
        fsCore__Employment__c prvEmp = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        prvEmp.Is_Primary_Employment__c = false;
        insert prvEmp;
        
        fsCore__Financial__c  fincPrm = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),prvEmp.Id,account1.Id,false);
        fincPrm.Previous_Employment_Name__c = prvEmp.Id;
        fincPrm.Employment_Name__c = prvEmp.Id;
        fincPrm.fsCore__Account_Name__c = account1.Id;
        fincPrm.Is_Primary_Income__c = false;
        insert fincPrm;
        
        fsCore__Financial__c  fincPrv = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),emp.Id,account1.Id,false);
        fincPrv.Previous_Employment_Name__c = emp.Id;
        fincPrv.Employment_Name__c = emp.Id;
        //fincPrv.fsCore__Account_Name__c = account1.Id;
       // fincPrv.Is_Primary_Income__c = false;
        insert fincPrv;
        
        List<fsCore__Financial__c> finList = [Select id From fsCore__Financial__c Where Id=:fincPrv.Id];
        system.debug('####finList'+finList);
        //system.runAs(user) {
            ClientPortal_DNLIncomeWrapper dnlIncomeWrapper = new ClientPortal_DNLIncomeWrapper(); 
             ClientPortal_DNLIncomeWrapper.IncomeWrapper IncomeWrapper = new  ClientPortal_DNLIncomeWrapper.IncomeWrapper();
            IncomeWrapper.Income = fincPrm;
            List<ClientPortal_DNLIncomeWrapper.IncomeWrapper> additionalIncomes = new  List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>();
            String dnlIncomeWrapperString = JSON.serialize(dnlIncomeWrapper);
            //String additionalIncomesString = JSON.serialize(additionalIncomes);
            ClientPortal_DNLHomeCntrl.updateIncomeInformation(dnlIncomeWrapperString, '');
          //  ClientPortal_DNLIncomeWrapper.IncomeWrapper incomewrapper =
              //  new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
            ClientPortal_DNLHomeCntrl.getAccountAndIncomeDetails();
        //}
    }
    @isTest
    public static void updateAccountPersonalInformationTest(){
        
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.Person_Other_Appartment__c = '123' ;
        account1.PersonOtherStreet = '2nd street' ;
        account1.Less_than_2yrs_Apt_Num__c = '345' ;
        account1.Less_than_2yrs_Street_Address__c = '1st street' ;
        account1.PersonMailing_Apt__c = '567' ;
        account1.PersonMailingStreet = '3rd street' ;
        account1.Housing_Type__c = 'Other' ;
        account1.Monthly_Mortgage_or_Rent_Payment__c = 10.9 ;
        insert account1;  
        
        system.debug('###account1'+account1);
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        fsCore__Employment__c emp = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        emp.RecordTypeId = ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Employment__c', 'Employed');
        insert emp;
        
        fsCore__Financial__c  finc = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),emp.Id,account1.Id,false);
        finc.fsCore__Frequency__c = 'Annual';
        finc.fsCore__Contact_Name__c = account1.PersonContactId;
        test.startTest();
        insert finc;
        test.stopTest();
        
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        
        system.runAs(user) {
            ClientPortal_DNLIncomeWrapper dnlIncomeWrapper = new ClientPortal_DNLIncomeWrapper(); 
            ClientPortal_DNLIncomeWrapper.IncomeWrapper incomewrapper =
                new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
            try{
                ClientPortal_DNLHomeCntrl.updateAccountPersonalInformation(account1);
                
                account1.Person_Other_Appartment__c = '' ;
                account1.PersonOtherStreet = '2nd street' ;
                account1.Less_than_2yrs_Apt_Num__c = '' ;
                account1.Less_than_2yrs_Street_Address__c = '1st street' ;
                account1.PersonMailing_Apt__c = '' ;
                account1.PersonMailingStreet = '3rd street' ;
                ClientPortal_DNLHomeCntrl.updateAccountPersonalInformation(account1);
            }catch(Exception e){
                System.debug('###Exception'+e.getMessage());
            }
        }
    }
    
    @isTest
    public static void updateIncomeInformationTest(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account2;  
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account2.Id];
        fsCore__Employment__c empPrmPrv = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        insert empPrmPrv;
        
        fsCore__Financial__c  fincPrmPrv = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),empPrmPrv.Id,account2.Id,false);
        //fincPrmPrv.Is_Primary_Income__c = true;
        fincPrmPrv.Previous_Employment_Name__c = empPrmPrv.Id;
        insert fincPrmPrv;
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        Contact con1 = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        fsCore__Employment__c empPrm = ClientPortal_TestDataFactory.buildEmployment(con1.Id);
        insert empPrm;
        
        fsCore__Financial__c  fincPrm = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),empPrm.Id,account2.Id,false);
        fincPrm.Is_Primary_Income__c = true;
        fincPrm.Previous_Employment_Name__c = empPrm.Id;
        fincPrm.fsCore__Account_Name__c = account2.Id;
        fincPrm.fsCore__Contact_Name__c = con.Id;
        
        List<fsCore__Financial__c> additionalIncomeList = new List<fsCore__Financial__c>();
        additionalIncomeList.add(fincPrm);
        insert additionalIncomeList;
        system.debug('###account1'+account1);
        //  Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
       
       // system.runAs(user) {
            List<ClientPortal_DNLIncomeWrapper.IncomeWrapper> additionalIncomes = new List<ClientPortal_DNLIncomeWrapper.IncomeWrapper>();
            ClientPortal_DNLIncomeWrapper.IncomeWrapper incomewrapper =
                new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
           
            ClientPortal_DNLIncomeWrapper dnlIncomeWrapper = new ClientPortal_DNLIncomeWrapper(); 
                        String dnlIncomeWrapperString = JSON.serialize(dnlIncomeWrapper);
            String additionalIncomesString = JSON.serialize(additionalIncomes);
            ClientPortal_DNLHomeCntrl.updateIncomeInformation(dnlIncomeWrapperString, additionalIncomesString);
            // ClientPortal_DNLHomeCntrl.updateIncomeInformation(account2,fincPrm,empPrm,empPrmPrv,finc1,emp1,finc2,emp2,finc3,emp3,finc4,emp4,finc5,emp5,finc6,emp6,finc7,emp7);
       // }
    }
    @isTest
    public static void getContentDocsTest(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account2;  
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
        
        //ContentVersion conVersion = ClientPortal_TestDataFactory.createContentVersion();
        ContentDocumentLink conDoc = ClientPortal_TestDataFactory.createContentDocumentLink(cvList[0].ContentDocumentId,account2.Id);
        insert conDoc ;
        List<ContentDocumentLink> cdnList = [Select Id from ContentDocumentLink where ContentDocumentId =: conDoc.ContentDocumentId LIMIT 1];
        List<Id> CDIdList = new List<Id>();
        if (CDIdList.size()>0){
            CDIdList.add(cdnList[0].ContentDocumentId);
        }
        
        
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where ContentDocument.Id =: conDoc.Id];
        //System.assertEquals(cdList.size(), 1);
        
        ClientPortal_DNLHomeCntrl.getContentDocs(account2.Id);
    }
    
    
    
    @isTest
    public static void updateFinalInformationTest(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account2;  
        ClientPortal_DNLHomeCntrl.updateFinalInformation(account2);
    }
    @isTest
    public static void updateUserDisclosureResponseTest(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account2;  
        Opportunity opp = ClientPortal_TestDataFactory.buildOpportunity(account2.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp.StageName = 'Registration In Progress';
        opp.Co_Applicant_Name__c = account2.Id;
        insert opp;
        
        ClientPortal_DNLHomeCntrl.updateUserDisclosureResponse(account2,true);
    }
    @isTest
    public static void updateUserDisclosureResponseElseTest(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account2;  
        Opportunity opp = ClientPortal_TestDataFactory.buildOpportunity(account2.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp.StageName = 'Registration In Progress';
        opp.Co_Applicant_Name__c = account2.Id;
        insert opp;
        
        ClientPortal_DNLHomeCntrl.updateUserDisclosureResponse(account2,false);
    }
    @isTest
    public static void updateFinalInformationElseTest(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account2',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account2.Is_Registration_Completed__c =true;
        insert account2;  
        Account account3 = ClientPortal_TestDataFactory.buildAccount('Account3',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account3.Is_Registration_Completed__c =true;
        insert account3;
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account2.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        opp1.Co_Applicant_Name__c = account3.Id;
        insert opp1;
        Opportunity opp = ClientPortal_TestDataFactory.buildOpportunity(account2.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp.StageName = 'Portal Verification Complete';
        opp.Co_Applicant_Name__c = account3.Id;
        insert opp;
        
        List<Opportunity> oppList = [SELECT Id, Name, StageName, OwnerId,
                                     Co_Applicant_Name__c,
                                     Co_Applicant_Name__r.Is_Registration_Completed__c,
                                     Account.Is_Registration_Completed__c
                                     FROM Opportunity
                                     WHERE (AccountId =: account2.Id OR
                                            Co_Applicant_Name__c =: account3.Id)
                                     AND StageName = 'Registration In Progress'];
        Task taskInstance = ClientPortal_TestDataFactory.createTask(opp.Id);
        taskInstance.Subject = opp.Name +' has completed their application';
        taskInstance.Status = 'Not Started';
        taskInstance.Description = ' ';
        taskInstance.ActivityDate = System.today().addDays(1);
        taskInstance.Priority = 'Normal';
        insert taskInstance;
        ClientPortal_DNLHomeCntrl.updateFinalInformation(account2);
    }
    @isTest
    public static void updateFinalInformationTest1(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account2',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account2.Is_Registration_Completed__c =true;
        insert account2;  
        
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account2.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        opp1.Co_Applicant_Name__c = account2.Id;
        insert opp1;
        
        
        ClientPortal_DNLHomeCntrl.updateFinalInformation(account2);
    }
    @isTest
    public static void updateFinalInformationTest2(){
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account2',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account2.Is_Registration_Completed__c =false;
        insert account2;  
        
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account2.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        // opp1.Co_Applicant_Name__c = account2.Id;
        insert opp1;
        
        ClientPortal_DNLHomeCntrl.updateFinalInformation(account2);
    }
    @isTest
    public static void deleteAdditionalIncomeInformationTest(){
        
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        insert account1;  
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        fsCore__Employment__c empPrmPrv = ClientPortal_TestDataFactory.buildEmployment(con.Id);
        insert empPrmPrv;
        
        
        fsCore__Financial__c  fincPrm = ClientPortal_TestDataFactory.buildFinancial('Income','Investment',ClientPortal_TestDataFactory.getRecordTypeId('fsCore__Financial__c','Income'),empPrmPrv.Id,account1.Id,false);
        fincPrm.Is_Primary_Income__c = true;
        insert fincPrm;
        try{
            ClientPortal_DNLHomeCntrl.deleteAdditionalIncomeInformation(fincPrm.Id,empPrmPrv.Id);
        }catch(Exception e){
            System.debug('###Exception'+e.getMessage());
        }
    }
    
    @isTest
    public static void getAgreementURITest(){
        String agreementName = 'CPA' ;
        ClientPortal_DNLHomeCntrl.getAgreementURI(agreementName, 'DNL');
        agreementName = 'ESIGN' ;
        ClientPortal_DNLHomeCntrl.getAgreementURI(agreementName, 'DNL');
        agreementName = 'TCPA' ;
        ClientPortal_DNLHomeCntrl.getAgreementURI(agreementName, 'DNL');
        agreementName = 'RDA' ;
        ClientPortal_DNLHomeCntrl.getAgreementURI(agreementName, 'DNL');
    }
    
    @isTest
    public static void getIncomeWrapperInstanceTest(){
        ClientPortal_DNLIncomeWrapper.IncomeWrapper incomeWrapper = new ClientPortal_DNLIncomeWrapper.IncomeWrapper();
        ClientPortal_DNLHomeCntrl.getIncomeWrapperInstance();
    }
    
    @isTest
    private static void updateFinalInformationTestWithUser(){
        Account account1 = ClientPortal_TestDataFactory.buildAccount('Account',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account1.Person_Other_Appartment__c = '123' ;
        account1.PersonOtherStreet = '2nd street' ;
        account1.Less_than_2yrs_Apt_Num__c = '345' ;
        account1.Less_than_2yrs_Street_Address__c = '1st street' ;
        account1.PersonMailing_Apt__c = '567' ;
        account1.PersonMailingStreet = '3rd street' ;
        account1.Housing_Type__c = 'Other' ;
        account1.Monthly_Mortgage_or_Rent_Payment__c = 10.9 ;
        insert account1;  
        
        Account account2 = ClientPortal_TestDataFactory.buildAccount('Account2',ClientPortal_TestDataFactory.getRecordTypeId('Account','Client'),'8080808080');
        account2.Is_Registration_Completed__c =true;
        insert account2;  
        
        Opportunity opp1 = ClientPortal_TestDataFactory.buildOpportunity(account1.Id, ClientPortal_TestDataFactory.getRecordTypeId('Opportunity','DNL Sales'));
        opp1.StageName = 'Registration In Progress';
        opp1.Co_Applicant_Name__c = account2.Id;
        insert opp1;
        Opportunity oppNew = [Select Id,Opportunity_Number__c from opportunity where Id =:opp1.Id LIMIT 1 ] ;
        system.debug('###account1'+account1);
        Contact con = [SELECT Id, Account.Name FROM Contact WHERE AccountId =: account1.Id];
        
        String pId = [SELECT Id FROM Profile WHERE Name = 'DNL Customer Community Login User'].Id; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',  Username = 'user000@yopmail.com' + System.currentTimeMillis());
        insert user;
        try{
        system.runAs(user) {
            ClientPortal_DNLHomeCntrl.updateFinalInformation(account1) ;
            ClientPortal_DNLHomeCntrl.attachAgreementsToOpportunity(oppNew.Id, con.Account.Name , oppNew.Opportunity_Number__c, 'DNL') ;
        }
        }catch(Exception ex) {
            system.debug('Error: ' + ex.getMessage());
        }
    }
}