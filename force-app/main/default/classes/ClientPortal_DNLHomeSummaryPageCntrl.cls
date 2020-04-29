public without sharing class ClientPortal_DNLHomeSummaryPageCntrl {
    
    public ClientPortal_DNLIncomeWrapper dnlIncomeWrapper {get;set;}
    public String maskedSSN {get;set;}
    public String userName {get;set;}
    public String userEmail {get;set;}
    public String userIpAddress {get;set;}
    public String currentDate {get;set;}
    public SummaryIncomeWrapper summaryWrapper {get;set;}
    public SummaryPreviousEmploymentWrapper prevEmploymentDetails {get;set;}
    public List<SummaryIncomeWrapper> additionalIncomeList {get;set;}
    
    public Class SummaryIncomeWrapper {
        public String incomeType {get; set;}
        public Decimal statedAmount {get; set;}
        public Date startDate {get; set;}
        public String lessThan1Year {get; set;}
        public String employmentName {get; set;}
        public String employmentTitle {get; set;}
        
        public SummaryIncomeWrapper (String incomeType, Decimal statedAmount, Date startDate, 
                              String lessThan1Year, String employmentName, String employmentTitle){
            this.incomeType = incomeType ;
            this.statedAmount = statedAmount ;
            this.startDate = startDate ;
            this.lessThan1Year = lessThan1Year ;
            this.employmentName = employmentName ;
            this.employmentTitle = employmentTitle ;
        }
    }
    
    public Class SummaryPreviousEmploymentWrapper {
        public String employmerName {get; set;}
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public String street {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        
        public SummaryPreviousEmploymentWrapper (String employmerName, Date startDate, Date endDate,
                                                String street, String city, String state)
        {
            this.employmerName = employmerName ;
            this.startDate = startDate ;
            this.endDate = endDate ;
            this.street = street ;
            this.city = city ;
            this.state = state ;
        }
    }
    
    public ClientPortal_DNLHomeSummaryPageCntrl () {
        try{
            currentDate = System.now().format('MM/dd/yyyy HH:mm:ss a','America/New_York');
            User userInstance = new User();
            List<User> userList = new List<User>();
            
            userList = [SELECT Id, Name, AccountId, Account.Name, email
                        FROM User 
                        WHERE Id = :userInfo.getUserId()
                        AND IsPortalEnabled = true];
            
            if (!userList.isEmpty()) {
                userInstance = userList[0];
                userName = userInstance.Account.Name ;
                userEmail = userInstance.Email ;
            }
            userIpAddress = ClientPortal_Utility.getUserIPAddress() ;
            
            dnlIncomeWrapper = ClientPortal_DNLHomeCntrl.getAccountAndIncomeDetails();
            summaryWrapper = new SummaryIncomeWrapper (dnlIncomeWrapper.primaryIncome.income.fsCore__Financial_Type__c,
                                                       dnlIncomeWrapper.primaryIncome.income.fsCore__Stated_Amount__c, 
                                                       dnlIncomeWrapper.primaryIncome.income.Start_Date__c, 
                                                       dnlIncomeWrapper.primaryIncome.income.Employment_Less_Than_1_Year__c, 
                                                       dnlIncomeWrapper.primaryIncome.employment.fsCore__Employer_Name__c, 
                                                       dnlIncomeWrapper.primaryIncome.employment.fsCore__Title__c);
            
            prevEmploymentDetails = new SummaryPreviousEmploymentWrapper (dnlIncomeWrapper.primaryIncome.previousEmployment.fsCore__Employer_Name__c, 
                                                                          dnlIncomeWrapper.primaryIncome.previousEmployment.fsCore__Start_Date__c, 
                                                                          dnlIncomeWrapper.primaryIncome.previousEmployment.fsCore__End_Date__c,
                                                                          dnlIncomeWrapper.primaryIncome.previousEmployment.fsCore__Street__c, 
                                                                          dnlIncomeWrapper.primaryIncome.previousEmployment.fsCore__City__c, 
                                                                          dnlIncomeWrapper.primaryIncome.previousEmployment.fsCore__State__c) ;
            
            additionalIncomeList = new List<SummaryIncomeWrapper> () ;
            for(ClientPortal_DNLIncomeWrapper.IncomeWrapper additionalIncome : dnlIncomeWrapper.additionalIncomes) {
                additionalIncomeList.add(
                    new SummaryIncomeWrapper (additionalIncome.income.fsCore__Financial_Type__c,
                                              additionalIncome.income.fsCore__Stated_Amount__c, 
                                              additionalIncome.income.Start_Date__c,
                                              '', 
                                              additionalIncome.employment.fsCore__Employer_Name__c, 
                                              additionalIncome.employment.fsCore__Title__c)
                ) ;
            }
            
            maskedSSN = 'xxxxx' + (dnlIncomeWrapper.acc.fsCore__National_Identification_Number__pc).substring(dnlIncomeWrapper.acc.fsCore__National_Identification_Number__pc.length()-4);
        }catch(Exception ex){
            system.debug('Error: ' + ex.getMessage());
            system.debug('Error: ' + ex.getStackTraceString());
        }
    }
}