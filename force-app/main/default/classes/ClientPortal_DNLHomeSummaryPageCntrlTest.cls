@isTest
private class ClientPortal_DNLHomeSummaryPageCntrlTest {
    
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
            ClientPortal_DNLHomeSummaryPageCntrl clsObj = new ClientPortal_DNLHomeSummaryPageCntrl();
            String userEmail = clsObj.userEmail ;
            String userName = clsObj.userName ;
            String maskedSSN = clsObj.maskedSSN ;
            system.assert(clsObj.userName != null ) ;
        }
        
    }

}