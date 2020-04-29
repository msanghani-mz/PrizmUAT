/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name   - SampleApplicationGenerator
 *
 * Description  - This class is used to create the sample loan applications
 *
 * Developer(s) - Financial Spectra Dev
 *
 */
public class SampleApplicationGenerator {

    private fsCore__Branch_Setup__c mBranch;
    private fsCore__Product_Setup__c mProduct;
    private fsCore__Stage_Setup__c mStage;
    private fsCore__Contract_Template_Setup__c mTemplate;
    
    /* set the following values from a calculator */
    private static final Decimal SAMPLE_FINANCED_AMOUNT = 9900.00;
    private static final Decimal SAMPLE_FINANCE_FEE = 100.00;
    private static final Decimal SAMPLE_PREPAID_FEE = 0.00;
    private static final Decimal SAMPLE_PAYMENT_AMOUNT = 492.01;
    private static final Decimal SAMPLE_RATE = 22.99;
    private static final Integer SAMPLE_NUMBER_OF_PAYMENTS = 26;
    private static final String  SAMPLE_PAYMENT_CYCLE = fsCore.Constants.CYCLE_MONTHLY;
    private static final String  SAMPLE_CURRENCY_CODE = 'USD';
    
    private Boolean mSetAsTest;
    private Integer mNumberOfRecords = 0;
    private String mAppRecordTypeName;
    private String mAppStatus;
    private Date mAppStartDate;
    
    private Map<Integer, Account> mAccountMap;

    public SampleApplicationGenerator(Integer pNumberOfRecords){
        mNumberOfRecords = pNumberOfRecords;
        init();    
    }
    
    private void init(){
        mSetAsTest = false;
        mAppRecordTypeName = fsCore.Constants.RECORD_TYPE_ACTIVE;
        mAccountMap = new Map<Integer, Account>();
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

    public void setProduct(String pProductCode){
        fsCore.DynamicQueryBuilder productQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Product_Setup__c.getName());
        productQuery.addFields();
        productQuery.addWhereConditionWithBind(1,'fsCore__Product_Code__c','=','pProductCode');
        
        List<fsCore__Product_Setup__c> productQueryResult = (List<fsCore__Product_Setup__c>)Database.query(productQuery.getQueryString());
        if (productQueryResult.size() == 1){
            mProduct = productQueryResult.get(0);
        }
    }
    public void setStage(String pStageCode){
        fsCore.DynamicQueryBuilder stageQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Stage_Setup__c.getName());
        stageQuery.addFields();
        stageQuery.addWhereConditionWithBind(1,'fsCore__Stage_Code__c','=','pStageCode');
        
        List<fsCore__Stage_Setup__c> stageQueryResult = (List<fsCore__Stage_Setup__c>)Database.query(stageQuery.getQueryString());
        if (stageQueryResult.size() == 1){
            mStage = stageQueryResult.get(0);
        }
    }    

    public void setContractTemplate(String pTemplateCode){
        fsCore.DynamicQueryBuilder templateQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Contract_Template_Setup__c.getName());
        templateQuery.addFields();
        templateQuery.addWhereConditionWithBind(1,'fsCore__Contract_Template_Code__c','=','pTemplateCode');
        
        List<fsCore__Contract_Template_Setup__c> templateQueryResult = (List<fsCore__Contract_Template_Setup__c>)Database.query(templateQuery.getQueryString());
        if (templateQueryResult.size() == 1){
            mTemplate = templateQueryResult.get(0);
        }
    }
    
    public void setAsTest(Boolean pSetAsTest){
        mSetAsTest = pSetAsTest;
    }
    
    public void setApplicationRecordType(String pAppRecordTypeName){
        mAppRecordTypeName = pAppRecordTypeName;
    }

    public void setApplicationStartDate(Date pAppStartDate){
        mAppStartDate = pAppStartDate;
    }

    public void setApplicationStatus(String pStatus){
        mAppStatus = pStatus;
    }    

    private void setApplicantMaps(){
        fsCore.DynamicQueryBuilder accountQuery = fsCore.DynamicQueryFactory.createQuery('Account');
        accountQuery.addField('Id');
        accountQuery.addField('fsCore__Primary_Bank_Account__c');
        accountQuery.addWhereConditionWithValue(1,'fsCore__Email__c','LIKE','%example.com.sample');
        accountQuery.setRecordLimit(mNumberOfRecords);
        
        List<Account> accountList = (List<Account>)Database.query(accountQuery.getQueryString());
        mAccountMap = new Map<Integer, Account>();
        
        Integer recordCounter = 1;
        for (Account acc : accountList){
            mAccountMap.put(recordCounter, acc);
            recordCounter++;
        }
    }

    public void generateData(){
        if (mBranch == null){
            throw new fsCore.CustomException('Branch Setup cannot be null.');
        }
        if (mProduct == null){
            throw new fsCore.CustomException('Product Setup cannot be null.');
        }
        if (mTemplate == null){
            throw new fsCore.CustomException('Contract Template Setup cannot be null.');
        }
        if (fsCore.SystemPreferencesSettingsUtil.getOrganizationType() == fsCore.Constants.ORG_TYPE_LIVE){
            throw new fsCore.CustomException('Sample Application creation for Production Orgs is not allowed.');
        }
        
        mNumberOfRecords = (mNumberOfRecords > 200 ? 200 : mNumberOfRecords);
        try{
            createApplications();
        } catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            throw e;
        }
    }
    
    private void createApplications(){
        Map<String, Schema.RecordTypeInfo> appRecordTypeMap = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName();
        List<fsCore__Lending_Application__c> sampleApplications = new List<fsCore__Lending_Application__c>();
        fsCore.ObjectRecordMapper prodAppMapping = new fsCore.ObjectRecordMapper('Product_Application_Mapping');
        fsCore.ObjectRecordMapper ctAppMapping = new fsCore.ObjectRecordMapper('Contract_Template_Application_Mapping');
        
        setApplicantMaps();
        
        if (mAppStartDate == null){
            mAppStartDate = mBranch.fsCore__Business_Date__c;
        }

        if (mAppStatus == null){
            mAppStatus = 'Approved';
        }        
        Integer daysBetween = mAppStartDate.daysBetween(mBranch.fsCore__Business_Date__c);
        daysBetween = (daysBetween == 0 ? 1 : daysBetween);
        System.debug(loggingLevel.ERROR, '-- Days : ' + daysBetween);
        
        Double appsPerDay = Math.ceil((Double)mNumberOfRecords / (Double)daysBetween);
        System.debug(loggingLevel.ERROR, '-- Apps per day : ' + appsPerDay);
        Double perDayAppsCounter = 0;
        Date businessDate = mAppStartDate;
        Decimal factor = 1;
        
        for(Integer i=1; i <= mNumberOfRecords; i++){
            fsCore__Lending_Application__c app = new fsCore__Lending_Application__c();
            if (String.IsNotBlank(mAppRecordTypeName) && appRecordTypeMap.containsKey(mAppRecordTypeName)){
                app.RecordTypeId = appRecordTypeMap.get(mAppRecordTypeName).getRecordTypeId();
            }
            
            factor = Math.mod(i, 10);
            factor = (factor == 0 ? 0.5 : factor);
            
            app.fsCore__Product_Family__c = mProduct.fsCore__Product_Family__c;
            app.fsCore__Company_Name__c = mBranch.fsCore__Company_Name__c;
            app.fsCore__Branch_Name__c = mBranch.Id;
            if (mStage != null){
                app.fsCore__Current_Stage_Name__c = mStage.Id;
            }
            app.fsCore__Application_Date__c = businessDate;
            app.fsCore__Country__c = mBranch.fsCore__Country__c;
            app.fsCore__State__c = mBranch.fsCore__State__c;
            app.fsCore__Application_Received_Date__c = app.fsCore__Application_Date__c;
            app.fsCore__Application_Status__c = mAppStatus;
            app.fsCore__Decision__c = 'Approved';
            app.fsCore__Decision_Updated_On__c = null;
            app.fsCore__Is_Restricted_Contract__c = false;
            app.fsCore__Pricing_Name__c = null;
            app.fsCore__Pricing_Applied_On__c = null;
            app.fsCore__External_System_Reference_Number__c = null;
            app.fsCore__Is_Application_Read_Only__c = false;
            app.fsCore__Is_Funded__c = false;
            app.fsCore__Is_Voided__c = false;
            app.fsCore__Is_Test__c = mSetAsTest;
            app.fsCore__Source__c = 'Other';
            
            app.fsCore__Primary_Customer_Account__c = mAccountMap.get(i).Id;
            
            fsCore.LendingApplicationUtil.copyProductToApplication(mProduct, app, prodAppMapping);
            fsCore.LendingApplicationUtil.copyContractTemplateToApplication(mTemplate, app, ctAppMapping);
            
            app.fsCore__Contract_Date__c = app.fsCore__Application_Date__c;
            app.fsCore__Effective_Date__c = app.fsCore__Contract_Date__c;
            app.fsCore__Application_Verified_Date__c = app.fsCore__Contract_Date__c;
            app.fsCore__Financed_Amount__c = (SAMPLE_FINANCED_AMOUNT * factor).setScale(2);
            app.fsCore__Number_Of_Payments__c = SAMPLE_NUMBER_OF_PAYMENTS;
            app.fsCore__Rate__c = SAMPLE_RATE;
            app.fsCore__Payment_Amount__c = (SAMPLE_PAYMENT_AMOUNT * factor).setScale(2);
            app.fsCore__Payment_Cycle__c = SAMPLE_PAYMENT_CYCLE;
            app.fsCore__Payment_Start_Date__c = fsCore.DateUtilGlobal.adjustDateByBillingCycle(app.fsCore__Contract_Date__c, app.fsCore__Contract_Date__c.day(),fsCore.Constants.DUMMY_SECOND_DUE_DAY, app.fsCore__Payment_Cycle__c, 1);
            app.fsCore__Payment_Due_Day__c = app.fsCore__Payment_Start_Date__c.day();
            app.fsCore__Balloon_Amount__c = 0.00;
            app.fsCore__Finance_Fee__c = (SAMPLE_FINANCE_FEE * factor).setScale(2);
            app.fsCore__Prepaid_Fee__c = (SAMPLE_PREPAID_FEE * factor).setScale(2);
            app.fsCore__Index_Rate__c = 0.00;
            app.fsCore__Margin_Rate__c = 0.00;
            app.fsCore__Rate_Index_Name__c = null;
            app.fsCore__Number_Of_Interest_Only_Payments__c = 0;
            app.fsCore__Fixed_Principal_Amount__c = 0.00;
            app.fsCore__Interest_Accrual_Start_Date__c = app.fsCore__Contract_Date__c;
            app.fsCore__Loan_Amount__c = app.fsCore__Financed_Amount__c + app.fsCore__Prepaid_Fee__c;
            app.fsCore__Principal_Balance__c = app.fsCore__Financed_Amount__c + app.fsCore__Finance_Fee__c + app.fsCore__Prepaid_Fee__c;
            app.fsCore__Annual_Percent_Rate__c = SAMPLE_RATE;
            app.fsCore__Total_Financial_Charge__c = (app.fsCore__Payment_Amount__c * app.fsCore__Number_Of_Payments__c) - app.fsCore__Financed_Amount__c;
            app.fsCore__Total_Interest_Amount__c = (app.fsCore__Payment_Amount__c * app.fsCore__Number_Of_Payments__c) - app.fsCore__Financed_Amount__c;
            app.fsCore__Total_Of_Payments__c = (app.fsCore__Payment_Amount__c * app.fsCore__Number_Of_Payments__c);
            app.fsCore__Maturity_Date__c = fsCore.DateUtilGlobal.adjustDateByBillingCycle(app.fsCore__Contract_Date__c, app.fsCore__Contract_Date__c.day(), fsCore.Constants.DUMMY_SECOND_DUE_DAY, app.fsCore__Payment_Cycle__c, (Integer)app.fsCore__Number_Of_Payments__c);
            app.fsCore__Is_Final_Payment_Different__c = false;
            app.fsCore__Final_Payment_Amount__c = app.fsCore__Payment_Amount__c;
            app.fsCore__First_Period_Days__c = app.fsCore__Contract_Date__c.daysBetween(app.fsCore__Payment_Start_Date__c);
            app.fsCore__Number_Of_Payments_Monthly__c = (app.fsCore__Payment_Cycle__c == fsCore.Constants.CYCLE_MONTHLY) 
                                                              ? app.fsCore__Number_Of_Payments__c : (fsCore.DateUtilGlobal.getCycleDifference(app.fsCore__Contract_Date__c, app.fsCore__Maturity_Date__c, fsCore.Constants.CYCLE_MONTHLY));
            if (UserInfo.isMultiCurrencyOrganization()){
                app.put(fsCore.Constants.FIELD_NAME_CURRENCY, SAMPLE_CURRENCY_CODE);
            }
            sampleApplications.add(app);

            perDayAppsCounter++;
            if (perDayAppsCounter > appsPerDay){
                perDayAppsCounter = 0;
                businessDate = businessDate.addDays(1);
            }
        }
        
        //inserting application will create the customer record as well, generate title and auto-app number
        fsCore.LendingApplicationDMLWrapper.getInstance().insertData(sampleApplications, true);
    }
        
}