/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name   - SampleApplicantGenerator
 *
 * Description  - This class is used to create the sample account and contacts
 *
 * Developer(s) - Financial Spectra Dev
 *
 */
public class SampleApplicantGenerator {

    private fsCore__Branch_Setup__c mBranch;
    Integer mNumberOfRecords = 0;
    Boolean mCreateBankAccountFlag = false;

    public SampleApplicantGenerator(Integer pNumberOfRecords){
        mNumberOfRecords = pNumberOfRecords;
    }

    public void setBranch(String pBranchCode){
        fsCore.DynamicQueryBuilder branchQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Branch_Setup__c.getName());
        branchQuery.addFields();
        branchQuery.addWhereConditionWithBind(1,'fsCore__Branch_Code__c','=','pBranchCode');
        
        List<fsCore__Branch_Setup__c> branchQueryResult = (List<fsCore__Branch_Setup__c>)Database.query(branchQuery.getQueryString());
        if (branchQueryResult.size() == 1){
            mBranch = branchQueryResult.get(0);
        }
    }

    public void setCreateWithBankAccount(Boolean pCreateBankAccountFlag){
        mCreateBankAccountFlag = pCreateBankAccountFlag;
    }
    
    public void generateData(){
        if (mNumberOfRecords > 0){
            mNumberOfRecords = (mNumberOfRecords > 200 ? 200 :mNumberOfRecords);
            
            createPersonAccounts();
        }
    }
    
    private void createPersonAccounts(){
        List<String> firstNames = getFirstNames();
        List<String> lastNames = getLastNames();
        
        Integer fnCounter = 0;
        Integer lnCounter = 0;
        Boolean incrementCounter = true;
        Map<String, Schema.RecordTypeInfo> accRecordTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Id RecTypeId;
        if (accRecordTypeMap.containsKey('Applicant')){
            RecTypeId = accRecordTypeMap.get('Applicant').getRecordTypeId();
        }
        
        List<Account> personAccounts = new List<Account>();
        for(Integer i=1; i <= mNumberOfRecords; i++){
            Account acc = getAccountInstance();
            acc.fsCore__Email__c = firstNames.get(fnCounter) + '.' + lastNames.get(lnCounter) + '@example.com.sample';
            if (RecTypeId != null){
                acc.RecordTypeId = RecTypeId;
                acc.FirstName = firstNames.get(fnCounter);
                acc.LastName = lastNames.get(lnCounter);
                acc.personEmail = acc.fsCore__Email__c;
            } else {
                acc.Name = firstNames.get(fnCounter) + ' ' + lastNames.get(lnCounter);
            }
            
            personAccounts.add(acc);
            
            fnCounter = (fnCounter < 99) ? (fnCounter + 1) : 0;
            if (incrementCounter){
                lnCounter = lnCounter + 1;
                if (lnCounter > 99){
                    incrementCounter = false;
                    lnCounter = 99;
                }
            } 
            else {
                lnCounter = lnCounter - 1;
                if (lnCounter < 0){
                    lnCounter = 0;
                    incrementCounter = true;
                }
            }
        }
        insert personAccounts;
        
        
        
        if (mCreateBankAccountFlag){
            List<fsCore__Bank_Account__c> sampleBankAccounts = new List<fsCore__Bank_Account__c>();
            Integer counter = 1;
            for (Account acc : personAccounts){
                fsCore__Bank_Account__c bankAcct = getBankAccountInstance(counter);
                bankAcct.fsCore__Account_Name__c = acc.Id;
                bankAcct.Name = acc.FirstName + ' ' + acc.LastName;
                bankAcct.fsCore__Bank_Account_Holder_Name__c = bankAcct.Name;
                sampleBankAccounts.add(bankAcct);
                counter++;
            }
            insert sampleBankAccounts;
        }
    }

    private Account getAccountInstance(){
        Account acc = new Account();
        acc.Description = 'This is a sample account.';
        acc.Ownership = 'Private';
        acc.Type = 'Customer - Direct';
        acc.AnnualRevenue = 5000000.00;
        acc.fsCore__Is_Broker__c = false;
        acc.fsCore__Is_Investor__c = false;
        acc.fsCore__Is_Subsidy_Participant__c = false;
        acc.fsCore__Is_Securitization_Investor__c = false;
        acc.BillingCity = mBranch.fsCore__City__c;
        acc.BillingState = mBranch.fsCore__State__c;
        acc.BillingCountry = mBranch.fsCore__Country__c;
        acc.ShippingCity = acc.BillingCity;
        acc.ShippingState = acc.BillingState;
        acc.ShippingCountry = acc.BillingCountry;
        return acc;
    }

    private fsCore__Bank_Account__c getBankAccountInstance(Integer pCounter){
        fsCore__Bank_Account__c bankAcct = new fsCore__Bank_Account__c();
        bankAcct.fsCore__Bank_Account_Number__c = '99999' + String.valueOf(pCounter).leftPad(4,'0');
        bankAcct.fsCore__Bank_Identification_Code__c = '012345';
        bankAcct.fsCore__Bank_Name__c = 'ABC Bank';
        bankAcct.fsCore__Bank_Branch_Name__c = mBranch.fsCore__City__c + ' Branch';
        bankAcct.fsCore__Bank_Account_Type__c = 'Saving';
        bankAcct.fsCore__Is_Primary__c = true;
        bankAcct.fsCore__Is_Active__c = true;
        return bankAcct;
    }

    /* Method to return 100 first names */
    private List<String> getFirstNames(){
        List<String> firstNames = new List<String>{
            'Tony','Bruce','Andy','Bob','Benny','Chris','Connor','Britney','Steve','Steven',
            'Greg','Nick','Ammy','Brian','Jake','James','Joe','John','Tim','Justin',
            'Richard','Dan','Darren','Kate','Julie','Susan','Rebecca','Colin','Andrew','Clark',
            'Matt','Ben','Jacob','Bill','Emma','Rob','Thomas','Peter','Clint','Sam',
            'Russell','Ricky','Stuart','Micheal','Glenn','Shaun','Daniel','Nathan','Kevin','Edmond',
            'Amit','Emmet','Lucy','Fred','Neil','Sunny','Vivan','Alex','Vicky','Jade',
            'Victor','Mark','Sean','Brad','Will','William','Robert','Harry','Rocky','David',
            'Howard','Gary','Donald','Mickey','Jamie','Finley','Franc','Diego','Judy','Natalie',
            'Joseph','Luke','Mike','Sergie','Allen','Leo','Samantha','Juan','Larry','Jack',
            'George','Danny','Johnny','Phil','Diana','Pepper','Aaron','Ryan','Carlos','Scott'};
        return firstNames;    
    }

    /* Method to return 100 last names */
    private List<String> getLastNames(){
        List<String> lastNames = new List<String>{
            'Stark','Wayne','Murray','Dylan','Allen','Hambleton','Hoffman','Rhodes','Rodger','Smith',
            'Ward','Parker','Watson','Peterson','Broad','Cook','Lennon','Travis','Kelly','Anderson',
            'Clarke','Murphy','Abbott','Finch','Lim','Rowling','Potts','Willie','Johnson','Kent',
            'Murdock','Richardson','Oram','Norton','Ceic','Earls','Kurien','Mills','Harris','Kalman',
            'Peters','Warne','Ponting','Maxwell','McCullum','Little','Walker','Hussey','Carroll','Colvin',
            'Kapur','Bishop','Lu','Fox','Nitin','Mann','Richie','Singh','Williams','Lee',
            'Dillon','Waugh','Bradman','Fleming','Mellow','Hayden','McGarth','Loona','Potter','Brenner',
            'Hunt','Kristen','Ducworth','Thompson','Scott','Johnathan','Mark','Santa','Dunbar','Krishnan',
            'Wanda','Lumsden','Norby','Orsi','Border','Casper','Chung','Parees','King','Elison',
            'Woods','Max','Philip','Collins','Prince','Winslet','Hedges','Burton','Tezev','Evans'};
        return lastNames;    
    }

}