@isTest
private class LendingContractDeletionUtilTest {
    @testSetup
    static void createData(){
        TestHelperData.createTriggerExecutionTestData();
        //create company and branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        
        
        //
        //create balance, transaction and itemization setup
        //
        
        fsCore__Balance_Setup__c testBalance = fsCore.TestHelperFinancial.getTestBalanceSetup('Test Balance Name', 'Principal');
        insert testBalance;
        
        fsCore__Transaction_Setup__c testTransaction = fsCore.TestHelperFinancial.getTestTransactionSetup('Test Transaction Name', testBalance.id, 'Post');
        insert testTransaction;
        
        Map<Id, fsCore__Transaction_Parameter_Field__mdt> txnParamFieldMDTMap = fsCore.TransactionParamMetadataUtil.getTransactionParamFieldMap();
        System.debug('txnParamFieldMDTMap:--'+txnParamFieldMDTMap);
        Id txnParamFieldID;
        for (fsCore__Transaction_Parameter_Field__mdt txnParamMDT : txnParamFieldMDTMap.values()){
            if (txnParamMDT.fsCore__Field_Name__c.equalsIgnoreCase('fsServ__Transaction_Amount__c')){
                txnParamFieldID = txnParamMDT.Id;
                break;
            }
        }
        System.debug('txnParamFieldID:--'+txnParamFieldID);
        fsCore__Transaction_Parameter_Setup__c testTxnParam = fsCore.TestHelperFinancial.getTestTxnParamSetup(
            'fscore__application_date__c'
            , testTransaction.Id
            , txnParamFieldID
            , 1);
        testTxnParam.fsCore__Field_Object_Name__c = 'fscore__lending_application__c';
        testTxnParam.Name = 'Test Parameter';
        insert testTxnParam;
        
        
        List<fsCore__Itemization_Setup__c> testItemizations  = new List<fsCore__Itemization_Setup__c>();
        fsCore__Itemization_Setup__c testItemization = fsCore.TestHelperFinancial.getTestItemizationSetup('Test Itemization Name', 'Financed Amount', testTransaction.Id);
        fsCore__Itemization_Setup__c testItemization1 = fsCore.TestHelperFinancial.getTestItemizationSetup('Test Itemization Name1', ' Prepaid Fee', testTransaction.Id);
        testItemizations.add(testItemization);
        testItemizations.add(testItemization1);
        insert testItemizations;
        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c = 'VCL';
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        
        
        //
        //create product itemizations
        // 
        List<fsCore__Product_Itemization_Setup__c> testProductItzms = new List<fsCore__Product_Itemization_Setup__c>();
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItemization
                                                                                     , 'Yes'
                                                                                     , 1, fsCore.Constants.MINUS));
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItemization1
                                                                                     , 'No'
                                                                                     , 2, fsCore.Constants.PLUS));
        insert testProductItzms;
        System.assert(testProductItzms.size() > 0, 'Test product itemizations created assert');        
        
        //
        //create contract template
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        
        
        
        //create Stage
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Test Stage Name', 'Lending_Application_Stage', 'Origination', 12);
        insert testStage; 
        System.assert(testStage.Id != null, 'testStage created assert');    
        //
        //create Lending Application by populating company, branch, product
        //
        List<fsCore__Lending_Application__c> testApplications = new List<fsCore__Lending_Application__c>();
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        testApplications.add(testApplication);
        fsCore__Lending_Application__c testApplication1 = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                             , testBranch
                                                                                                                             , testProduct
                                                                                                                             , testContractTemplate
                                                                                                                             , 'Test Application');
        testApplications.add(testApplication1);
        insert testApplications;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        
        
        //create Lending Application itemizations
        
        List<fsCore__Lending_Application_Itemization__c> testAppItemizations = fsCore.TestHelperLendingApplication.getTestApplicationItemizations(
            testApplication
            , testProductItzms);
        integer counter = 1;
        for (fsCore__Lending_Application_Itemization__c itm :testAppItemizations){
            if (counter == 1){
                itm.Current_Creditor__c = 'TTE';
                itm.Original_Creditor__c = 'TTE';
            }
        }
        
        insert testAppItemizations;
        System.assert(testAppItemizations.size() > 0, 'Test Lending Application itemizations created assert');  
        
        //create Lending Contract
        List<fsServ__Lending_Contract__c> testLendingContracts = new List<fsServ__Lending_Contract__c>();
        fsServ__Lending_Contract__c testLendingContract = new fsServ__Lending_Contract__c();
        testLendingContract.fsServ__Contract_Status__c = 'Active';
        testLendingContract.fsServ__Branch_Name__c = testBranch.Id;
        testLendingContract.fsServ__Company_Name__c = testCompany.Id;
        testLendingContract.fsServ__Product_Name__c = testProduct.Id;
        testLendingContract.fsServ__Contract_Template_Name__c = testContractTemplate.id;
        testLendingContract.fsServ__Financed_Amount__c = 1000;
        testLendingContract.fsServ__Contract_Date__c = Date.today();
        testLendingContract.fsServ__Current_Payment_Amount__c = 1000;
        testLendingContract.fsServ__Next_Payment_Due_Date__c = Date.today().addDays(30);
        testLendingContract.fsServ__Current_Payment_Cycle__c = 'Monthly';
        testLendingContract.fsServ__Lending_Application_Number__c = testApplications[0].id;
        testLendingContracts.add(testLendingContract);
        
        fsServ__Lending_Contract__c testLendingContract1 = new fsServ__Lending_Contract__c();
        testLendingContract1.fsServ__Contract_Status__c = 'Active';
        testLendingContract1.fsServ__Branch_Name__c = testBranch.Id;
        testLendingContract1.fsServ__Company_Name__c = testCompany.Id;
        testLendingContract1.fsServ__Product_Name__c = testProduct.Id;
        testLendingContract1.fsServ__Financed_Amount__c = 1000;
        testLendingContract1.fsServ__Contract_Date__c = Date.today();
        testLendingContract1.fsServ__Contract_Template_Name__c = testContractTemplate.id;
        testLendingContract1.fsServ__Current_Payment_Amount__c = 1000;
        testLendingContract1.fsServ__Next_Payment_Due_Date__c = Date.today().addDays(30);
        testLendingContract1.fsServ__Current_Payment_Cycle__c = 'Monthly';
        testLendingContract1.fsServ__Lending_Application_Number__c = testApplications[1].id;
        
        testLendingContracts.add(testLendingContract1);
        insert testLendingContracts;
        System.assert(testLendingContracts.size()>0, 'Test Lending Contracts created assert');  
        
        //Inbound Payments
        
        List<fsServ__Inbound_Payment__c> testInboundPaymentList =fsServ.TestHelperGlobal.getInboundPayments(testLendingContracts,Date.Today().addDays(30));        
        insert testInboundPaymentList;
        System.assert(testInboundPaymentList.size()>0, 'Test Inbound payments created assert'); 
        List<fsServ__Inbound_Payment__c> testInboundPaymentUpdateList = new List<fsServ__Inbound_Payment__c>(); 
        for(fsServ__Inbound_Payment__c testInboundPayment : testInboundPaymentList){
            testInboundPayment.fsServ__Is_Process_Payment_On_Save__c = true;
            testInboundPaymentUpdateList.add(testInboundPayment);
        }
        //update testInboundPaymentUpdateList;
        
        //Outbound Payments
        List<fsCore__Outbound_Payment__c> testOutboundpaymnts = fsServ.TestHelperGlobal.getOutboundPayments(testLendingContracts);
        insert testOutboundpaymnts;
        System.assert(testOutboundpaymnts.size()>0, 'testOutboundpaymnts created assert');  
        
        /*  //Direct Debit 
List<fsServ__Contract_Direct_Debit__c> testDirectDebits = fsServ.TestHelperGlobal.getDirectDebits(testLendingContracts, 500);
insert testDirectDebits;
System.assert(testDirectDebits.size()>0, 'testDirectDebits created assert');  */
        
        //Transaction Queue
        List<fsServ__Transaction_Processing_Queue__c> testTrnxQueues  = new List<fsServ__Transaction_Processing_Queue__c>();
        for(fsServ__Lending_Contract__c contract: testLendingContracts){
            fsServ__Transaction_Processing_Queue__c testTrnxQueue = fsServ.TestHelperGlobal.getQueuedTransaction(contract, testTransaction , date.today());
            testTrnxQueues.add(testTrnxQueue);
        }
        insert testTrnxQueues;
        System.assert(testTrnxQueues.size()>0, 'testTrnxQueues created assert');  
        
        //Transaction Queue Param
        List<fsCore__Transaction_Parameter_Setup__c> trnxParamList = new List<fsCore__Transaction_Parameter_Setup__c>();
        trnxParamList.add(testTxnParam);
        List<fsServ__Transaction_Processing_Parameter__c> testTrnxQueuesParams  = new List<fsServ__Transaction_Processing_Parameter__c>();
        for(fsServ__Transaction_Processing_Queue__c testTrnxQueue: testTrnxQueues){
            Map<String, fsServ__Transaction_Processing_Parameter__c> testTrnxQueueParamMap = fsServ.TestHelperGlobal.getQueuedTxnParams(testTrnxQueue,trnxParamList );
            fsServ__Transaction_Processing_Parameter__c testTrnxQueueParam = testTrnxQueueParamMap.get(testTxnParam.fsCore__Field_Name__c.toLowerCase());
            testTrnxQueueParam.fsServ__Data_Type__c = 'Currency';
            testTrnxQueuesParams.add(testTrnxQueueParam);
        }
        insert testTrnxQueuesParams;
        System.assert(testTrnxQueuesParams.size()>0, 'testTrnxQueuesParams created assert');  
        
        
        
        //Contract Stage
        List<fsServ__Contract_Stage__c> testContractStages  = new List<fsServ__Contract_Stage__c>();
        for(fsServ__Lending_Contract__c contract: testLendingContracts){
            fsServ__Contract_Stage__c testContractStage = fsServ.TestHelperGlobal.getContractStage(contract, testStage);
            testContractStages.add(testContractStage);
        }
        insert testContractStages;
        System.assert(testContractStages.size()>0, 'testContractStages created assert'); 
        
        //Payment Batch
        List< fsServ__Payment_Batch__c> paymentBatches = new List<fsServ__Payment_Batch__c>();
        fsServ__Payment_Batch__c paymentBatch =  fsServ.TestHelperGlobal.getPaymentBatch(testBranch,'Inbound', Date.today());
        paymentBatches.add(paymentBatch) ;        
        fsServ__Payment_Batch__c paymentBatch1 =  fsServ.TestHelperGlobal.getPaymentBatch(testBranch,'Outbound', Date.today());
        paymentBatches.add(paymentBatch1) ;
        insert paymentBatches ;
        System.assert(paymentBatches.size()>0, 'paymentBatches created assert'); 
        
        //Contract Disbursement
        List<fsServ__Contract_Disbursement__c > testContractDisbursements  = new List<fsServ__Contract_Disbursement__c>();
        for(fsServ__Lending_Contract__c contract: testLendingContracts){
            //fsServ__Contract_Disbursement__c testContractDisbursement = fsServ.TestContractDataHelper.getTestContractDisbursement(contract, null, null, 1000);
            Map<String, RecordType> disbursementRecTypeMap
                = fsCore.RecordTypeUtil.getInstance()
                .getRecordTypeMapByName(Schema.SObjectType.fsServ__Contract_Disbursement__c.getName());
            
            fsServ__Contract_Disbursement__c testDisbursement = new fsServ__Contract_Disbursement__c();
            testDisbursement.fsServ__Lending_Contract_Number__c = contract.Id;
            testDisbursement.RecordTypeId = disbursementRecTypeMap.get(fsServ.Constants.RECORD_TYPE_OPEN).Id;
            testDisbursement.fsServ__Disbursement_Party_Type__c = 'Customer';
            testDisbursement.fsServ__Account_Name__c = null;
            testDisbursement.fsServ__Contact_Name__c = null;
            testDisbursement.fsServ__Bank_Account_Name__c = null;
            testDisbursement.fsServ__Disbursement_Amount__c = 1000;
            testDisbursement.fsServ__Disbursement_Date__c = System.today();
            testDisbursement.fsServ__Payment_Method__c = 'Electronic Clearing';
            testDisbursement.fsServ__Reference__c = null;
            
            testContractDisbursements.add(testDisbursement);
        }
        insert testContractDisbursements;
        System.assert(testContractDisbursements.size()>0, 'testContractDisbursements created assert'); 
        
        
    }
    @isTest
    static void checkInsertedData(){
        /*List<fsCore__Assignment__c> assignments = [Select id from fsCore__Assignment__c];
        System.debug('Assignment'+assignments.Size());
        System.assert(assignments.Size()>0,'Assignment asserted');*/
        
        List<fsCore__Outbound_Payment__c> outboundPayments = [Select id,fsServ__Payment_Batch_Number__c from fsCore__Outbound_Payment__c];
        System.debug('outboundPayments'+outboundPayments.Size());
        System.assert(outboundPayments.Size()>0,'outboundPayments asserted');
        
        List<fsCore__Lending_Document_Record__c> docRecords = [Select id from fsCore__Lending_Document_Record__c];
        System.debug('docRecords'+docRecords.Size());
        //System.assert(docRecords.Size()>0,'docRecords asserted');
        
        List<fsServ__Contract_Transaction_Balance_Allocation__c> trnxBalAllocations = [Select id from fsServ__Contract_Transaction_Balance_Allocation__c];
        System.debug('trnxBalAllocations'+trnxBalAllocations.Size());
        //System.assert(trnxBalAllocations.Size()>0,'trnxBalAllocations asserted');    //
        
        List<fsServ__Contract_Transaction__c> conTrnxs = [Select id from fsServ__Contract_Transaction__c];
        System.debug('conTrnxs'+conTrnxs.Size());
        //System.assert(conTrnxs.Size()>0,'conTrnxs asserted');
        
        List<fsServ__Transaction_Processing_Queue__c> trnxQueues = [Select id from fsServ__Transaction_Processing_Queue__c];
        System.debug('trnxQueues'+trnxQueues.Size());
        System.assert(trnxQueues.Size()>0,'trnxQueues asserted');
        
        List<fsServ__Transaction_Processing_Parameter__c> trnxParameters = [Select id from fsServ__Transaction_Processing_Parameter__c ]; 
        System.debug('trnxParameters'+trnxParameters.Size());
        //System.assert(trnxParameters.Size()>0,'trnxParameters asserted');
        
        List<fsServ__Contract_Stage__c> conStages = [Select id from fsServ__Contract_Stage__c];
        System.debug('conStages'+conStages.Size());
        System.assert(conStages.Size()>0,'conStages asserted');
        
        List<fsServ__Contract_Draw_Preference__c> conDrawPrefrences = [Select id from fsServ__Contract_Draw_Preference__c];
        System.debug('conDrawPrefrences'+conDrawPrefrences.Size());
        //System.assert(conDrawPrefrences.Size()>0,'conDrawPrefrences asserted');
        
        List<fsServ__Contract_Holiday_Preference__c> conHolidayPrefrences = [Select id from fsServ__Contract_Holiday_Preference__c];
        System.debug('conHolidayPrefrences'+conHolidayPrefrences.Size());
        // System.assert(conHolidayPrefrences.Size()>0,'conHolidayPrefrences asserted');
        
        List<fsServ__Contract_Payment_Preference__c> conPaymentPrefrences = [Select id from fsServ__Contract_Payment_Preference__c];
        System.debug('conPaymentPrefrences'+conPaymentPrefrences.Size());
        // System.assert(conPaymentPrefrences.Size()>0,'conPaymentPrefrences asserted');
        
        List<fsServ__Contract_Rate_Preference__c> conRatePrefrences = [Select id from fsServ__Contract_Rate_Preference__c];
        System.debug('conRatePrefrences'+conRatePrefrences.Size());
        //  System.assert(conRatePrefrences.Size()>0,'conRatePrefrences asserted');
        
        List<fsServ__Contract_Repayment_Schedule__c> conRepaymentPrefrences = [Select id from fsServ__Contract_Repayment_Schedule__c ];
        System.debug('conRepaymentPrefrences'+conRepaymentPrefrences.Size());
        // System.assert(conRepaymentPrefrences.Size()>0,'conRepaymentPrefrences asserted');
        
        List<fsServ__Contract_Repayment__c> conRepayments = [Select id from fsServ__Contract_Repayment__c];
        System.debug('conRepayments'+conRepayments.Size());
        //System.assert(conRepayments.Size()>0,'conRepayments asserted');
        
        List<fsServ__Contract_Payoff_Quote_Detail__c> conPayoffQuoteDetails = [Select id from fsServ__Contract_Payoff_Quote_Detail__c];
        System.debug('conPayoffQuoteDetails'+conPayoffQuoteDetails.Size());
        //System.assert(conPayoffQuoteDetails.Size()>0,'conPayoffQuoteDetails asserted');
        
        List<fsServ__Contract_Payoff_Quote__c> conPayoffQuotes = [Select id from fsServ__Contract_Payoff_Quote__c];
        System.debug('conPayoffQuotes'+conPayoffQuotes.Size());
        //System.assert(conPayoffQuotes.Size()>0,'conPayoffQuotes asserted');
        
        List<fsServ__Contract_Itemization__c> conItemizations = [Select id from fsServ__Contract_Itemization__c ];
        System.debug('conItemizations'+conItemizations.Size());
        //System.assert(conItemizations.Size()>0,'outboundPayments asserted');
        
        List<fsServ__Contract_Due__c> conDues = [Select id from fsServ__Contract_Due__c];
        System.debug('conDues'+conDues.Size());
        // System.assert(conDues.Size()>0,'outboundPayments asserted');
        
        List<fsServ__Contract_Balance__c> conBalances = [Select id from fsServ__Contract_Balance__c ];
        System.debug('conBalances'+conBalances.Size());
        //System.assert(conBalances.Size()>0,'conBalances asserted');
        
        List<fsServ__Contract_Fee_Tier__c> conFeeTiers = [Select id from fsServ__Contract_Fee_Tier__c ];
        System.debug('conFeeTiers'+conFeeTiers.Size());
        // System.assert(conFeeTiers.Size()>0,'conFeeTiers asserted');
        
        List<fsServ__Contract_Fee__c> conFees = [Select id from fsServ__Contract_Fee__c ];
        System.debug('conFees'+conFees.Size());
        //System.assert(conFees.Size()>0,'conFees asserted');
        
        List<fsServ__Contract_Insurance__c> conInsurances = [Select id from fsServ__Contract_Insurance__c ];
        System.debug('conInsurances'+conInsurances.Size());
        //System.assert(conInsurances.Size()>0,'conInsurances asserted');
        
        List<fsServ__Inbound_Payment__c> inboundPayments = [Select id,fsServ__Payment_Batch_Number__c from fsServ__Inbound_Payment__c];
        System.debug('inboundPayments'+inboundPayments.Size());
        System.assert(inboundPayments.Size()>0,'inboundPayments asserted');
        
        List<fsServ__Payment_Batch__c> paymentBatches = [Select id from fsServ__Payment_Batch__c ]; 
        System.debug('paymentBatches'+paymentBatches.Size());
        System.assert(paymentBatches.Size()>0,'paymentBatches asserted');
        
        List<fsServ__Contract_Investment_Balance__c> investmentBals = [Select id from fsServ__Contract_Investment_Balance__c];
        System.debug('investmentBals'+investmentBals.Size());
        //System.assert(investmentBals.Size()>0,'investmentBals asserted');
        
        List<fsServ__Contract_Investment_Transaction__c> investmentTrnxs = [Select id from fsServ__Contract_Investment_Transaction__c];
        System.debug('investmentTrnxs'+investmentTrnxs.Size());
        // System.assert(investmentTrnxs.Size()>0,'investmentTrnxs asserted');
        
        List<fsServ__Contract_Investment__c> investments = [Select id from fsServ__Contract_Investment__c ];
        System.debug('investments'+investments.Size());
        //System.assert(investments.Size()>0,'investments asserted');
        
        List<fsServ__Contract_Investment_Charge__c> investmentCharges = [Select id from fsServ__Contract_Investment_Charge__c ];  
        System.debug('investmentCharges'+investmentCharges.Size());
        //System.assert(investmentCharges.Size()>0,'investmentCharges asserted');
        
        List<fsServ__Contract_Collateral__c> conCollaterals = [Select id from fsServ__Contract_Collateral__c];
        System.debug('conCollaterals'+conCollaterals.Size());
        //System.assert(conCollaterals.Size()>0,'conCollaterals asserted');
        
        List<fsServ__Contract_Direct_Debit__c> conDirectDebits = [Select id from fsServ__Contract_Direct_Debit__c];
        System.debug('conDirectDebits'+conDirectDebits.Size());
        //System.assert(conDirectDebits.Size()>0,'conDirectDebits asserted');
        
        List<fsServ__Contract_Disbursement__c> conDisbursements = [Select id from fsServ__Contract_Disbursement__c ];
        System.debug('conDisbursements'+conDisbursements.Size());
        System.assert(conDisbursements.Size()>0,'conDisbursements asserted');
        
        List<fsServ__Contract_Customer__c> conCustomers = [Select id from fsServ__Contract_Customer__c ];
        System.debug('conCustomers'+conCustomers.Size());
        //System.assert(conCustomers.Size()>0,'conCustomers asserted');
        
        List<fsServ__Lending_Contract__c> lendingContracts = [Select id from fsServ__Lending_Contract__c ];
        System.debug('lendingContracts'+lendingContracts.Size());
        System.assert(lendingContracts.Size()>0,'lendingContracts asserted');
        
    }
    
    @isTest
    static void testDeletion(){
        Test.startTest();
        
        List<fsServ__Lending_Contract__c> LendingContracts = [SELECT Id, Name, fsServ__External_System_Reference_Number__c FROM fsServ__Lending_Contract__c];
        System.assert(LendingContracts.size()>0, 'Lending Contracts asserted');
        
        Set<String> lendingContractNumber = new Set<String>();    
        lendingContractNumber.add(LendingContracts[0].Name);
        lendingContractNumber.add(LendingContracts[1].Name);
        
        LendingContractDeletionUtil.deleteContract(lendingContractNumber);
        Test.stopTest();
        
        LendingContracts = [Select id from fsServ__Lending_Contract__c where id IN: lendingContractNumber];
        System.assertEquals(0, LendingContracts.size());
        
        List<fsCore__Outbound_Payment__c> outboundPayments = [Select id from fsCore__Outbound_Payment__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, outboundPayments.size());
        
        List<fsCore__Lending_Document_Record__c> docRecords = [Select id from fsCore__Lending_Document_Record__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, docRecords.size());
        
        List<fsServ__Contract_Transaction_Balance_Allocation__c> trnxBalAllocations = [Select id from fsServ__Contract_Transaction_Balance_Allocation__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, trnxBalAllocations.size());
        
        List<fsServ__Contract_Transaction__c> conTrnxs = [Select id from fsServ__Contract_Transaction__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conTrnxs.size());
        
        List<fsServ__Transaction_Processing_Queue__c> trnxQueues = [Select id from fsServ__Transaction_Processing_Queue__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, trnxQueues.size());
        
        List<fsServ__Contract_Stage__c> conStages = [Select id from fsServ__Contract_Stage__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber]; 
        System.assertEquals(0, conStages.size());
        
        List<fsServ__Contract_Draw_Preference__c> conDrawPrefrences = [Select id from fsServ__Contract_Draw_Preference__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, conDrawPrefrences.size());
        
        List<fsServ__Contract_Holiday_Preference__c> conHolidayPrefrences = [Select id from fsServ__Contract_Holiday_Preference__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conHolidayPrefrences.size());
        
        List<fsServ__Contract_Payment_Preference__c> conPaymentPrefrences = [Select id from fsServ__Contract_Payment_Preference__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, conPaymentPrefrences.size());
        
        List<fsServ__Contract_Rate_Preference__c> conRatePrefrences = [Select id from fsServ__Contract_Rate_Preference__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conRatePrefrences.size());
        
        List<fsServ__Contract_Repayment_Schedule__c> conRepaymentPrefrences = [Select id from fsServ__Contract_Repayment_Schedule__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conRepaymentPrefrences.size());
        
        List<fsServ__Contract_Repayment__c> conRepayments = [Select id from fsServ__Contract_Repayment__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, conRepayments.size());
        
        List<fsServ__Contract_Payoff_Quote_Detail__c> conPayoffQuoteDetails = [Select id from fsServ__Contract_Payoff_Quote_Detail__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conPayoffQuoteDetails.size());
        
        List<fsServ__Contract_Payoff_Quote__c> conPayoffQuotes = [Select id from fsServ__Contract_Payoff_Quote__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conPayoffQuotes.size());
        
        List<fsServ__Contract_Itemization__c> conItemizations = [Select id from fsServ__Contract_Itemization__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, conItemizations.size());
        
        List<fsServ__Contract_Due__c> conDues = [Select id from fsServ__Contract_Due__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conDues.size());
        
        List<fsServ__Contract_Balance__c> conBalances = [Select id from fsServ__Contract_Balance__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conBalances.size());
        
        List<fsServ__Contract_Fee_Tier__c> conFeeTiers = [Select id from fsServ__Contract_Fee_Tier__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, conFeeTiers.size());
        
        List<fsServ__Contract_Fee__c> conFees = [Select id from fsServ__Contract_Fee__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conFees.size());
        
        List<fsServ__Contract_Insurance__c> conInsurances = [Select id from fsServ__Contract_Insurance__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, conInsurances.size());
        
        List<fsServ__Inbound_Payment__c> inboundPayments = [Select id,fsServ__Payment_Batch_Number__c from fsServ__Inbound_Payment__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, inboundPayments.size());
        
        List<fsServ__Contract_Investment_Balance__c> investmentBals = [Select id from fsServ__Contract_Investment_Balance__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, investmentBals.size());
        
        List<fsServ__Contract_Investment_Transaction__c> investmentTrnxs = [Select id from fsServ__Contract_Investment_Transaction__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, investmentTrnxs.size());
        
        List<fsServ__Contract_Investment__c> investments = [Select id from fsServ__Contract_Investment__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, investments.size());
        
        List<fsServ__Contract_Collateral__c> conCollaterals = [Select id from fsServ__Contract_Collateral__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conCollaterals.size());
        
        List<fsServ__Contract_Direct_Debit__c> conDirectDebits = [Select id from fsServ__Contract_Direct_Debit__c where fsServ__Lending_Contract_Number__c IN:lendingContractNumber];
        System.assertEquals(0, conDirectDebits.size());
        
        List<fsServ__Contract_Disbursement__c> conDisbursements = [Select id from fsServ__Contract_Disbursement__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conDisbursements.size());
        
        List<fsServ__Contract_Customer__c> conCustomers = [Select id from fsServ__Contract_Customer__c where fsServ__Lending_Contract_Number__c IN: lendingContractNumber];
        System.assertEquals(0, conCustomers.size());
        
    }
}