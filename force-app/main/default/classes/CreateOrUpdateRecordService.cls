@RestResource(urlMapping='/CreateOrUpdateRecord/*')
global class CreateOrUpdateRecordService {
    static Map<Id,Id> opportunityMap = new Map<Id,Id>();  
    static Map<Id,String> mapIdSalesRep=new Map<Id,String>(); 
    
    @HttpPost
    global static void createOrUpdateRecord() {  //global static String createOrUpdateRecord()
        String jsonStr = '';
        String result = '';
        system.debug(logginglevel.error,'###RestContext.request::'+RestContext.request.requestBody);
        //Checking the type of response based on the keywords
        if (RestContext.request.requestBody != NULL)
            jsonStr = RestContext.request.requestBody.toString();    
        system.debug(logginglevel.error,'###jsonStr::'+jsonStr);
        result = CreateopportunityAccount(jsonStr,false);
        RestResponse response = RestContext.response;
       
        String str;
        if(result != ''){
            response.statusCode = 200; 
            system.debug(logginglevel.error,'###mapIdSalesRep_Size::'+mapIdSalesRep.size()); //
            if(mapIdSalesRep.size()>0){
                system.debug(logginglevel.error,'###mapIdSalesRep_Value::'+mapIdSalesRep); // 
                response.responseBody = Blob.valueOf(JSON.serialize(mapIdSalesRep)); //
                //str=JSON.serialize(mapIdSalesRep);//
            }
        }
        
        else{
            response.statusCode = 400;
        }
        
    }
    
    public Static String CreateopportunityAccount(String jsonStr, Boolean isPull){
        Id settelmentPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        Id draftPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id LoanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        Id RefundLoanPayRecTypeId = Schema.SObjectType.Opportunity_Payment__c.getRecordTypeInfosByName().get('Refund loan').getRecordTypeId();
        Id ApplicantRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        
        opportunityJsonClass response = new opportunityJsonClass();
        response = opportunityJsonClass.parse(jsonStr);
        system.debug(logginglevel.error,'###response::'+response);
        List<Opportunity> oppInsLst = new List<Opportunity>();
        Map<String,Opportunity> FileNumberOppMap = new Map<String,Opportunity>();
        Opportunity oppnew;
        //DV-389
        map<String,id> mapProcessorNameToId = new map<String,id>(); 
        for(nu_dse__Processor__c p: [Select id,Name from nu_dse__Processor__c]){
            mapProcessorNameToId.put(p.Name , p.Id);
        }

        Set<String> resFileNumSet = new Set<String>();
        List<Account> accLst = new List<Account>();
        Map<String,Account> filenumberAccMap = new Map<String,Account>();
        List<Account> accUpsLst = new List<Account>();
        Account newAcc;
        Account coNewAcc;
        system.debug(logginglevel.error,' response :'+response);
        for(opportunityJsonClass.cls_Opportunity oppJsonResp: response.Opportunity)
            resFileNumSet.add(oppJsonResp.FileNumber);    
        opportunityJsonClass.cls_Payments payment;
        List<opportunityJsonClass.cls_Payments> payments;
        List<opportunityJsonClass.cls_TradeLines> tradeLines;
        Opportunity_Payment__c newPay;
        Opportunity_Tradelines_Offer__c newTrade;
        List<Opportunity_Payment__c> newPayLst = new List<Opportunity_Payment__c>();
        List<Opportunity_Tradelines_Offer__c> newTradeLst = new List<Opportunity_Tradelines_Offer__c>();
        
        List<Task> TaskList = new List<Task>();
        Map<String,List<Task>> oppTaskMap = new Map<String,List<Task>>();
        
        List<fsCore__Bank_Account__c> BankAccountList = new List<fsCore__Bank_Account__c>();
        Map<String, String> BankAccountOpportunityMap = new Map<String,String>();
        
        List<Opportunity_Draft_Fee__c> DraftFeesList = new List<Opportunity_Draft_Fee__c>();
        
        Map<String,String> paymentTradeLinemap = new Map<String,String>();
        List<opportunityJsonClass.cls_SettelmentPayments> oppSetPaymentLst;
        for(opportunityJsonClass.cls_Opportunity oppJsonResp: response.Opportunity){
            Id OppoRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DNL Sales').getRecordTypeId();
            
            system.debug(logginglevel.error,'***Tasks'+oppJsonResp.Tasks);
            
            oppNew = new Opportunity();
            if(!isPull)
                oppNew.Name = oppJsonResp.Name;
            if(oppJsonResp.CloseDate != null && oppJsonResp.CloseDate != '')
            	oppNew.CloseDate = Date.ValueOf(oppJsonResp.CloseDate);
            if(!isPull)
                oppNew.StageName = 'DNL Prospecting';
            if(oppJsonResp.Id != null && oppJsonResp.Id != '')
            	oppNew.Import_Id__c = oppJsonResp.Id;
            
            system.debug('++++oppJsonResp.Id+++++++'+oppJsonResp.Id);
            system.debug('++++oppJsonResp.programId+++++++'+oppJsonResp.programId);
            //if(!isPull){
                
                if(oppJsonResp.ProcessorName != null && oppJsonResp.ProcessorName.contains('RAMS')){
                    oppNew.Payment_Processor_Name__c = 'RAM';
                }
                else{
                    oppNew.Payment_Processor_Name__c = oppJsonResp.ProcessorName;
                }
            //}
            system.debug('++++oppNew.Payment_Processor_Name__c+++++++'+oppNew.Payment_Processor_Name__c);
            oppNew.RecordTypeId = OppoRecordType;
            oppNew.DRP_Account_Number__c= oppJsonResp.ProgramName;
            oppNew.Program_Id__c = oppJsonResp.ProgramName;
            oppNew.Program_Type__c = oppJsonResp.ProgramType;
            // PDI-727: Add try catch : Line 109 to 147 [Both while migrating and pulling]
            system.debug(logginglevel.error,'***oppJsonResp.LawFirmName'+oppJsonResp.LawFirmName);
            if(oppJsonResp.LawFirmName != 'Timberline'){
                list<String> lstLawFirm=new List<String>();
                Schema.DescribeFieldResult fieldResult = Opportunity.Law_Firm_Name__c.getDescribe();
                List<Schema.PicklistEntry> pickLwaFirm = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry s:pickLwaFirm){
                    lstLawFirm.add(string.valueOf(s.getLabel()));
                }  
                system.debug(logginglevel.error,'***List:oppJsonResp.LawFirmName'+lstLawFirm);
                if(lstlawFirm.Contains(oppJsonResp.LawFirmName)) {
                    oppNew.Law_Firm_Name__c = oppJsonResp.LawFirmName; //
                    system.debug(logginglevel.error,'***oppNew.Law_Firm_Name__c'+oppNew.Law_Firm_Name__c);
                }
                else{
                    system.debug(logginglevel.error,'***In Exception');
                    ExceptionMailToDevSfsTeam em=new ExceptionMailToDevSfsTeam(116,
                                                                               oppJsonResp.Name+' Opportunity Moved from Nudebt to Prizm without law Firm Name due to Missing Portfolio '+ oppJsonResp.LawFirmName+' in Prizm. For popuating given portfolio First add it in law firm name picklist with portfolio type dependency then click on Pull Nudebt button. Lawfirm issue: Class: CreateOrUpdateRecordService  Line Number: ',
                                                                               'Opportunity Moved from Nudebt to Prizm without law Firm Name: Need to add '+oppJsonResp.LawFirmName +' PortFolio in Law Firm Name Field & need to add Field dependency with Portfolio type field in Prizm');   
                    em.sendEmailToTeam(); 
                }
                
            }
            //New portfoio populate on law firm name after added it Picklist while pull Nudebt. data
            if(!isPull){
                system.debug(logginglevel.error,'***oppJsonResp.LawFirmName'+oppJsonResp.LawFirmName);
                if(oppJsonResp.PortfolioType == 'Attorney' && oppJsonResp.LawFirmName != 'Timberline'){
                    list<String> lstLawFirm=new List<String>();
                    Schema.DescribeFieldResult fieldResult = Opportunity.Law_Firm_Name__c.getDescribe();
                    List<Schema.PicklistEntry> pickLwaFirm = fieldResult.getPicklistValues();
                    for(Schema.PicklistEntry s:pickLwaFirm){
                        lstLawFirm.add(string.valueOf(s.getLabel()));
                    }  
                    system.debug(logginglevel.error,'***List:oppJsonResp.LawFirmName'+lstLawFirm);
                    if(lstlawFirm.Contains(oppJsonResp.LawFirmName)) {
                        //oppNew.Portfolio_Type__c = oppJsonResp.PortfolioType; //
                        oppNew.Law_Firm_Name__c = oppJsonResp.LawFirmName; //
                        system.debug(logginglevel.error,'***oppNew.Law_Firm_Name__c'+oppNew.Law_Firm_Name__c);
                    }  
                }
            }
            //
            /* if(oppJsonResp.LawFirmName != 'Timberline')     //Commented due to PDI-727
oppNew.Law_Firm_Name__c = oppJsonResp.LawFirmName; */
            
            if(oppJsonResp.ProgramStatus=='Pending Cancellation')   //PDI-741 
                oppNew.NuDebt_Program_Status__c='Pending DRP Cancellation';
            else
                oppNew.NuDebt_Program_Status__c = oppJsonResp.ProgramStatus;
            oppNew.Portfolio_Type__c = oppJsonResp.PortfolioType;
            oppNew.DRP_Name__c = oppJsonResp.LawFirmName;
            // oppNew.Sales_Rep__c = oppJsonResp.SalesRep;  
            oppNew.Lead_Group__c = oppJsonResp.LeadGroup;  
            oppNew.Segment__c= oppJsonResp.Segment;      
            oppNew.Campaign_Type__c= oppJsonResp.CampaignType;  //@PDI-687
            oppNew.Opportunity_Type__c = 'DNL';
            System.debug('****'+oppJsonResp.PaymentFrequency);
            if(!isPull)   //DV-129
                oppNew.Payment_Cycle__c = oppJsonResp.PaymentFrequency;
            if(oppJsonResp.EnrollmentDate != null && oppJsonResp.EnrollmentDate != '')
                oppNew.Enrolled_Date__c = Date.valueOf(oppJsonResp.EnrollmentDate);
            if(oppJsonResp.AddnlMonthsWithLoan != null && oppJsonResp.AddnlMonthsWithLoan != '')
                oppNew.Addnl_Months_with_Loan__c = Decimal.valueOf(oppJsonResp.AddnlMonthsWithLoan);
            if(oppJsonResp.UnsettledDebt != null && oppJsonResp.UnsettledDebt != '')
                oppNew.Unsettled_Debt__c = Decimal.valueOf(oppJsonResp.UnsettledDebt);
            //if(oppJsonResp.ClientAge != null && oppJsonResp.ClientAge != '')
            //oppNew.Client_Age__c = Integer.valueOf(oppJsonResp.ClientAge); //FSpectra This is the formula field now based on Sean Request PDI-267
            if(oppJsonResp.ProgramLength != null && oppJsonResp.ProgramLength!= '')
                oppNew.Program_Number_Of_Payments__c = Integer.valueOf(oppJsonResp.ProgramLength);
            if(oppJsonResp.LoanAmount!= null && oppJsonResp.LoanAmount!= '')
                oppNew.Amount = Decimal.valueOf(oppJsonResp.LoanAmount);
            if(oppJsonResp.UnpaidProgramFeeWithDNL != null && oppJsonResp.UnpaidProgramFeeWithDNL != '')
                oppNew.Unpaid_Program_Fee_W_DNL__c= Decimal.valueOf(oppJsonResp.UnpaidProgramFeeWithDNL );
            if(oppJsonResp.UnpaidProgramFeeWODNL != null && oppJsonResp.UnpaidProgramFeeWODNL != '')
                oppNew.Unpaid_Program_Fee_WO_DNL__c= Decimal.valueOf(oppJsonResp.UnpaidProgramFeeWODNL );
            if(oppJsonResp.CashInDedicatedAccount != null && oppJsonResp.CashInDedicatedAccount != '')
                oppNew.Cash_in_Dedicated_Account__c= Decimal.valueOf(oppJsonResp.CashInDedicatedAccount );
            if(oppJsonResp.RemainingMonths != null && oppJsonResp.RemainingMonths != '')
                oppNew.Remaining_Months_DRP_Program__c = Decimal.valueOf(oppJsonResp.RemainingMonths);
            if(oppJsonResp.DebtCount!= null && oppJsonResp.DebtCount != '')
                oppNew.Debt_Count__c = Decimal.valueOf(oppJsonResp.DebtCount);
            if(oppJsonResp.LoanTerm!= null && oppJsonResp.LoanTerm != '')
                oppNew.Loan_Number_Of_Payments__c = Decimal.valueOf(oppJsonResp.LoanTerm);
            if(oppJsonResp.TwiceMonthlyReoccuringDay!= null && oppJsonResp.TwiceMonthlyReoccuringDay != '') 
                oppNew.Debit_Day_Second__c = Decimal.valueOf(oppJsonResp.TwiceMonthlyReoccuringDay);
            if(oppJsonResp.ReoccurringDebitDay != null && oppJsonResp.ReoccurringDebitDay != '') 
                oppNew.Debit_Day_First__c = Decimal.valueOf(oppJsonResp.ReoccurringDebitDay);
            /*if(oppJsonResp.LastDraft != null && oppJsonResp.LastDraft != '')// 
oppNew.Draft_Amount_Per_Period__c = Decimal.valueOf(oppJsonResp.LastDraft);*/
            //Remaining_Fee_Due_To_DRP__c
            /* System.debug('****oppJsonResp.TotalFee'+oppJsonResp.TotalFee);
if(oppJsonResp.TotalFee != null && oppJsonResp.TotalFee != null)    //PDI-1016
oppNew.Remaining_Fee_Due_To_DRP__c=Decimal.valueOf(oppJsonResp.TotalFee);
System.debug('****oppNew.Remaining_Fee_Due_To_DRP__c'+oppNew.Remaining_Fee_Due_To_DRP__c);*/
            if(oppJsonResp.DraftAmt!= null && oppJsonResp.DraftAmt!= '')   // @PDI-714
                oppNew.Draft_Amount_Per_Period__c = Decimal.valueOf(oppJsonResp.DraftAmt); 
            if(oppJsonResp.CurrentBalance != null && oppJsonResp.CurrentBalance != '') 
                oppNew.Current_Balance__c = Decimal.valueOf(oppJsonResp.CurrentBalance);
            oppNew.Import_Program_Id__c = oppJsonResp.programId;
           
            System.debug(loggingLevel.ERROR,oppNew );
            Opportunity_Draft_Fee__c df = new Opportunity_Draft_Fee__c();
            if(!isPull){   //DV-129
                
                df.Program_Id__c = oppJsonResp.programId;
                
                if(oppJsonResp.id != null && oppJsonResp.id != ''){
                    Opportunity relatedOpp = new Opportunity(import_id__c=oppJsonResp.id);
                    df.Opportunity_Name__r = relatedOpp;
                }
                if(oppJsonResp.PaidAccumulation != null && oppJsonResp.PaidAccumulation != '')
                    df.Paid_Accumulation__c = Decimal.valueOf(oppJsonResp.PaidAccumulation);
                if(oppJsonResp.PaidAdminFee != null && oppJsonResp.PaidAdminFee != '')
                    df.Paid_Admin_Fee__c = Decimal.valueOf(oppJsonResp.PaidAdminFee);
                if(oppJsonResp.PaidCreditorPayments != null && oppJsonResp.PaidCreditorPayments != '')
                    df.Paid_Creditor_Payments__c = Decimal.valueOf(oppJsonResp.PaidCreditorPayments);
                if(oppJsonResp.PaidMaintenanceFee != null && oppJsonResp.PaidMaintenanceFee != '')
                    df.Paid_Maintenance_Fee__c = Decimal.valueOf(oppJsonResp.PaidMaintenanceFee);
                if(oppJsonResp.PaidProcessorFee != null && oppJsonResp.PaidProcessorFee != '')
                    df.Paid_Processor_Fee__c = Decimal.valueOf(oppJsonResp.PaidProcessorFee);
                if(oppJsonResp.PaidProgramFee != null && oppJsonResp.PaidProgramFee != '')
                    df.Paid_Program_Fee__c = Decimal.valueOf(oppJsonResp.PaidProgramFee);            
                if(oppJsonResp.PaidRetainerFee != null && oppJsonResp.PaidRetainerFee != '')
                    df.Paid_Retainer_Fee__c = Decimal.valueOf(oppJsonResp.PaidRetainerFee);            
                if(oppJsonResp.PaidServiceFee != null && oppJsonResp.PaidServiceFee != '')
                    df.Paid_Service_Fee__c= Decimal.valueOf(oppJsonResp.PaidServiceFee);            
                if(oppJsonResp.PaidThirdPartyFee != null && oppJsonResp.PaidThirdPartyFee != '')
                    df.Paid_Third_Party_Fee__c = Decimal.valueOf(oppJsonResp.PaidThirdPartyFee);            
                if(oppJsonResp.TotalAccumulation != null && oppJsonResp.TotalAccumulation != '')
                    df.Total_Accumulation__c = Decimal.valueOf(oppJsonResp.TotalAccumulation);                        
                if(oppJsonResp.TotalAdminFee != null && oppJsonResp.TotalAdminFee != '')
                    df.Total_Admin_Fee__c = Decimal.valueOf(oppJsonResp.TotalAdminFee);                
                if(oppJsonResp.TotalCreditorPayments != null && oppJsonResp.TotalCreditorPayments != '')
                    df.Total_Creditor_Payments__c = Decimal.valueOf(oppJsonResp.TotalCreditorPayments);            
                if(oppJsonResp.TotalMaintenanceFee != null && oppJsonResp.TotalMaintenanceFee != '')
                    df.Total_Maintenance_Fee__c = Decimal.valueOf(oppJsonResp.TotalMaintenanceFee);            
                if(oppJsonResp.TotalProcessorFee != null && oppJsonResp.TotalProcessorFee != '')
                    df.Total_Processor_Fee__c = Decimal.valueOf(oppJsonResp.TotalProcessorFee);             
                if(oppJsonResp.TotalProgramFee != null && oppJsonResp.TotalProgramFee != '')
                    df.Total_Program_Fee__c = Decimal.valueOf(oppJsonResp.TotalProgramFee);            
                if(oppJsonResp.TotalRetainerFee != null && oppJsonResp.TotalRetainerFee != '')
                    df.Total_Retainer_Fee__c = Decimal.valueOf(oppJsonResp.TotalRetainerFee);            
                if(oppJsonResp.TotalServiceFee != null && oppJsonResp.TotalServiceFee != '')
                    df.Total_Service_Fee__c = Decimal.valueOf(oppJsonResp.TotalServiceFee);
                if(oppJsonResp.TotalThirdPartyFee != null && oppJsonResp.TotalThirdPartyFee != '')
                    df.Total_Third_Party_Fee__c = Decimal.valueOf(oppJsonResp.TotalThirdPartyFee);
                if(oppJsonResp.RemainingAccumulation != null && oppJsonResp.RemainingAccumulation != '')
                    df.Remaining_Accumulation__c = Decimal.valueOf(oppJsonResp.RemainingAccumulation);                        
                if(oppJsonResp.RemainingAdminFee != null && oppJsonResp.RemainingAdminFee != '')
                    df.Remaining_Admin_Fee__c = Decimal.valueOf(oppJsonResp.RemainingAdminFee);                
                if(oppJsonResp.RemainingCreditorPayments != null && oppJsonResp.RemainingCreditorPayments != '')
                    df.Remaining_Creditor_Payments__c = Decimal.valueOf(oppJsonResp.RemainingCreditorPayments);            
                if(oppJsonResp.RemainingMaintenanceFee != null && oppJsonResp.RemainingMaintenanceFee != '')
                    df.Remaining_Maintenance_Fee__c = Decimal.valueOf(oppJsonResp.RemainingMaintenanceFee);            
                if(oppJsonResp.RemainingProcessorFee != null && oppJsonResp.RemainingProcessorFee != '')
                    df.Remaining_Processor_Fee__c = Decimal.valueOf(oppJsonResp.RemainingProcessorFee);             
                if(oppJsonResp.RemainingProgramFee != null && oppJsonResp.RemainingProgramFee != '')
                    df.Remaining_Program_Fee__c = Decimal.valueOf(oppJsonResp.RemainingProgramFee);            
                if(oppJsonResp.RemainingRetainerFee != null && oppJsonResp.RemainingRetainerFee != '')
                    df.Remaining_Retainer_Fee__c = Decimal.valueOf(oppJsonResp.RemainingRetainerFee);            
                if(oppJsonResp.RemainingServiceFee != null && oppJsonResp.RemainingServiceFee != '')
                    df.Remaining_Service_Fee__c = Decimal.valueOf(oppJsonResp.RemainingServiceFee);
                if(oppJsonResp.RemainingThirdPartyFee != null && oppJsonResp.RemainingThirdPartyFee != '')
                    df.Remaining_Third_Party_Fee__c = Decimal.valueOf(oppJsonResp.RemainingThirdPartyFee);
            DraftFeesList.add(df);
            }
            
            oppNew.DRP_File_Number__c = oppJsonResp.FileNumber;
            System.debug(loggingLevel.ERROR,DraftFeesList );
            Id AccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            List<Account> accList = [Select Id,NDS_File_Number__c,FirstName,LastName, Import_BoxFolderId__c,Processor__c, PersonBirthDate, PersonMailingState, PersonOtherState
                            from Account where NDS_File_Number__c =:oppJsonResp.FileNumber ORDER BY CREATEDDATE DESC LIMIT 1];                
            if(accList != null && accList.size() != 0){
                newAcc = accList[0];
            } else{
            	newAcc = new Account();
            }
            	//newAcc.Name = oppJsonResp.AccountName;
            	newAcc.NDS_File_Number__c = oppJsonResp.FileNumber;            
                newAcc.FirstName = oppJsonResp.FirstName;
                newAcc.LastName = oppJsonResp.LastName;
                newAcc.Import_BoxFolderId__c = oppJsonResp.BoxFolderId;
                newAcc.Processor__c = mapProcessorNameToId.get(oppNew.Payment_Processor_Name__c);  //DV-389
                system.debug('++++++newAcc.Processor__c+++'+newAcc.Processor__c);
                //newAcc.isPersonAccount = true;
                newAcc.RecordTypeId = AccountRecordType;
                if(oppJsonResp.PersonBirthDate!= null && oppJsonResp.PersonBirthDate!= '')
                    newAcc.PersonBirthDate = Date.valueOf(oppJsonResp.PersonBirthDate);
                //newAcc.PersonMailingState = oppJsonResp.PersonMailingState;
                if(oppJsonResp.PersonMailingState != null && oppJsonResp.PersonMailingState.length() == 2){
                    newAcc.PersonOtherState =  SFSUtil.getStateName(oppJsonResp.PersonMailingState);
                    newAcc.PersonMailingState = newAcc.PersonOtherState;
                }
                   
                /*else{
newAcc.PersonMailingState = oppJsonResp.PersonMailingState;
}*/
                //            newAcc.PersonMailingCountry = oppJsonResp.PersonMailingCountry;
                if(newAcc.PersonOtherState != null){
                    newAcc.PersonOtherCountry = 'United States';
                    newAcc.PersonMailingCountry='United States';
                }
                newAcc.PersonEmail = oppJsonResp.PersonEmail;
                newAcc.PersonOtherStreet = oppJsonResp.PersonMailingStreet;
                newAcc.PersonMailingStreet = newAcc.PersonOtherStreet;
                //newAcc.nu_dse__Client_Number__c = Integer.valueOf(oppJsonResp.ClientNumber);
                newAcc.MiddleName = oppJsonResp.MiddleName;
            	System.debug('oppJsonResp.AccountSSN = ' + oppJsonResp.AccountSSN);
                newAcc.fsCore__National_Identification_Number__pc = oppJsonResp.AccountSSN;
            	//newAcc.nu_dse__Social_Security_Number__c = oppJsonResp.AccountSSN;
                newAcc.PersonOtherCity = oppJsonResp.PersonMailingCity;
                newAcc.PersonMailingCity = newAcc.PersonOtherCity;
                //PDI-759
                if(oppJsonResp.PersonMailingPostalCode!=null && oppJsonResp.PersonMailingPostalCode.length()>5){
                    newAcc.PersonOtherPostalCode = oppJsonResp.PersonMailingPostalCode.substring(0,5); 
                    newAcc.PersonMailingPostalCode = newAcc.PersonOtherPostalCode; //DV-389
                }
                else{
                    newAcc.PersonOtherPostalCode = oppJsonResp.PersonMailingPostalCode;
                    newAcc.PersonMailingPostalCode = newAcc.PersonOtherPostalCode; //DV-389
                }
                
                newAcc.PersonHomePhone = oppJsonResp.PersonHomePhone;
                newAcc.PersonMobilePhone = oppJsonResp.PersonMobilePhone;
                newAcc.Work_Phone__c = oppJsonResp.AccountWorkPhone;
                //DV-389
                if(newAcc.PersonHomePhone != null)
                    newAcc.Phone = newAcc.PersonHomePhone;
                else if(newAcc.PersonMobilePhone != null)
                    newAcc.Phone = newAcc.PersonMobilePhone;
                else if(newAcc.Work_Phone__c != null)
                    newAcc.Phone = newAcc.Work_Phone__c;
                else 
                    newAcc.Phone = '';

                //DV-470
                if (String.isEmpty(newAcc.PersonMobilePhone)) {
                    if(!String.isEmpty(newAcc.PersonHomePhone)){
                        newAcc.PersonMobilePhone = newAcc.PersonHomePhone;
                    } else if (!String.isEmpty(newAcc.Work_Phone__c)) {
                        newAcc.PersonMobilePhone = newAcc.Work_Phone__c;
                    }
                }

                //newAcc.Phone=oppJsonResp.Phone;  //@
                System.debug('oppJsonResp.PaymentAccountNumber = ' + oppJsonResp.PaymentAccountNumber);
                newAcc.Payment_Account_Number__c = oppJsonResp.PaymentAccountNumber;
                // newAcc.Processor__c=oppJsonResp.ProcessorName;  //@
                
                if(!isPull)
                    newAcc.U_S_Residency_Status__c = null;
                //newAcc.RecordTypeId = ApplicantRecTypeId;
                accUpsLst.add(newAcc);
            
            
               // if(!isPull){
            	system.debug(logginglevel.error,'###oppJsonResp.CoFirstName::'+oppJsonResp.CoFirstName +'oppJsonResp.CoLastName: '+oppJsonResp.CoLastName);
                if(!String.isEmpty(oppJsonResp.CoFirstName) && !String.isEmpty(oppJsonResp.CoLastName)){
                    List<Account> coAccList = [Select Id,NDS_File_Number__c,FirstName,LastName, Import_BoxFolderId__c,Processor__c, PersonBirthDate, PersonMailingState, PersonOtherState
                                             from Account where FirstName =:oppJsonResp.CoFirstName AND LastName =:oppJsonResp.CoLastName  ORDER BY CREATEDDATE DESC LIMIT 1];                
                    if(coAccList != null && coAccList.size() != 0){
                        coNewAcc = coAccList[0];
                    }else{
                        coNewAcc = new Account();
                    }
                    //coNewAcc = new Account();
                    coNewAcc.FirstName = oppJsonResp.CoFirstName;
                    coNewAcc.LastName = oppJsonResp.CoLastName;
                    coNewAcc.Import_BoxFolderId__c = oppJsonResp.BoxFolderId;
                    coNewAcc.NDS_File_Number__c = oppJsonResp.FileNumber+'CO';
                    coNewAcc.RecordTypeId = AccountRecordType;
                    coNewAcc.fsCore__National_Identification_Number__pc= oppJsonResp.CoSSN;
                    if(oppJsonResp.CoDateOfBirth != null && oppJsonResp.CoDateOfBirth != '')
                        coNewAcc.PersonBirthDate = Date.valueOf(oppJsonResp.CoDateOfBirth);
                    coNewAcc.PersonEmail = oppJsonResp.CoEmailAddress;
                    coNewAcc.PersonHomePhone = oppJsonResp.CoPhone;
                    coNewAcc.Phone = coNewAcc.PersonHomePhone; //DV-389
                    coNewAcc.Processor__c = mapProcessorNameToId.get(oppNew.Payment_Processor_Name__c);  //DV-389
                    system.debug('++++++coNewAcc.Processor__c+++'+coNewAcc.Processor__c); 
                    //DV-336: If Co Address is populate if available otherwise Applicant address populate in Co-Applicant Address.
                    if(!String.isEmpty(oppJsonResp.CoCity) && !String.isEmpty(oppJsonResp.CoState)){
                        coNewAcc.PersonOtherCity=oppJsonResp.CoCity;
                        coNewAcc.PersonMailingCity = coNewAcc.PersonOtherCity;   //DV-389
                      if(oppJsonResp.CoState != null && oppJsonResp.CoState.length() == 2){
                        coNewAcc.PersonOtherState =  SFSUtil.getStateName(oppJsonResp.CoState);
                        coNewAcc.PersonMailingState = coNewAcc.PersonOtherState;
                      }
                        
                      coNewAcc.PersonOtherStreet = oppJsonResp.CoAddrline1;
                      coNewAcc.PersonMailingStreet = coNewAcc.PersonOtherStreet;   //DV-389
                      if(oppJsonResp.CoPostalCode!=null && oppJsonResp.CoPostalCode.length()>5){
                        coNewAcc.PersonOtherPostalCode=oppJsonResp.CoPostalCode.substring(0,5);
                        coNewAcc.PersonMailingPostalCode = coNewAcc.PersonOtherPostalCode; //DV-389
                      }
                           
                      else{
                        coNewAcc.PersonOtherPostalCode=oppJsonResp.CoPostalCode;
                        coNewAcc.PersonMailingPostalCode = coNewAcc.PersonOtherPostalCode; //DV-389
                      }
                           
                      if(coNewAcc.PersonOtherState != null){
                        coNewAcc.PersonOtherCountry = 'United States';
                        coNewAcc.PersonMailingCountry='United States';  //DV-389
                     }
                    } 
                   else{
                       coNewAcc.PersonOtherCity=oppJsonResp.PersonMailingCity; 
                       coNewAcc.PersonMailingCity = coNewAcc.PersonOtherCity;   //DV-389
                       if(oppJsonResp.PersonMailingState != null && oppJsonResp.PersonMailingState.length() == 2){
                        coNewAcc.PersonOtherState =  SFSUtil.getStateName(oppJsonResp.PersonMailingState);
                        coNewAcc.PersonMailingState = coNewAcc.PersonOtherState;  //DV-389
                       }
                            
                       if(NewAcc.PersonOtherState != null){
                        coNewAcc.PersonOtherCountry = 'United States';
                        coNewAcc.PersonMailingCountry='United States';  //DV-389
                       }
                          
                       coNewAcc.PersonOtherStreet = oppJsonResp.PersonMailingStreet;
                       coNewAcc.PersonMailingStreet = coNewAcc.PersonOtherStreet;   //DV-389
                       if(oppJsonResp.PersonMailingPostalCode!=null && oppJsonResp.PersonMailingPostalCode.length()>5){
                           coNewAcc.PersonOtherPostalCode = oppJsonResp.PersonMailingPostalCode.substring(0,5);  
                           coNewAcc.PersonMailingPostalCode = coNewAcc.PersonOtherPostalCode; //DV-389   
                        }
                       else{
                           coNewAcc.PersonOtherPostalCode = oppJsonResp.PersonMailingPostalCode;
                           coNewAcc.PersonMailingPostalCode = coNewAcc.PersonOtherPostalCode; //DV-389
                         }
                       }
                    
                    //coNewAcc.RecordTypeId = ApplicantRecTypeId;
                    
                    resFileNumSet.add(coNewAcc.NDS_File_Number__c);
                    accUpsLst.add(coNewAcc);
                }
            //}
            oppInsLst.add(oppNew);
            //Mapping trade lines
            payments = new List<opportunityJsonClass.cls_Payments>();
            payments = oppJsonResp.Payments;
            system.debug(logginglevel.error,'###payments::'+payments);
            if(payments != null && payments.size() != 0){
                for(opportunityJsonClass.cls_Payments pay: payments){
                    newPay = new Opportunity_Payment__c();
                    newPay.FileNumber__c = pay.FileNumber;
                    newPay.Import_Id__c = pay.Id;
                    newPay.RecordTypeId = draftPayRecTypeId;
                    if(String.IsNotBlank(pay.NFSDate)) newPay.NSF_Date__c = Date.ValueOf(pay.NFSDate);
                    //newPay.Payment_Status__c = pay.PaymentStatus;  //Update due to Payment status issue on 11th Feb
                    newPay.Payment_Status__c = pay.TransactionStatus; //Update due to Payment status issue on 11th Feb  @
                    system.debug(logginglevel.error,'###newPay.Payment_Status__c::'+newPay.Payment_Status__c);
                    system.debug(logginglevel.error,'###pay.TransactionStatus::'+pay.TransactionStatus);
                    newPay.Payment_Type__c = pay.PaymentType;
                    if(String.IsNotBlank(pay.ScheduleDate)) newPay.Schedule_Date__c = Date.ValueOf(pay.ScheduleDate);
                    if(String.IsNotBlank(pay.TotalAmount)) newPay.Total_Amount__c = Decimal.valueof(pay.TotalAmount);
                    newPay.Transaction_Method__c = pay.TansMethod;
                    newPay.Transaction_Status__c = pay.TransactionStatus;
                    //PDI-743
                    if(pay.PayRecType=='Settlement')  
                        newPay.RecordTypeId = settelmentPayRecTypeId;  
                    else if(pay.PayRecType=='Draft')
                        newPay.RecordTypeId = draftPayRecTypeId;
                    else if(pay.PayRecType=='Loan')
                        newPay.RecordTypeId = LoanPayRecTypeId;
                    else if(pay.PayRecType=='Refund loan')
                        newPay.RecordTypeId = RefundloanPayRecTypeId;
                    //system.debug(logginglevel.error,'###newPay.RecordTypeId::'+newPay.RecordTypeId);
                   
                    newPayLst.add(newPay);
                }
            }
            system.debug(logginglevel.error,'###draftnewPayLst::'+newPayLst);
            tradeLines = new List<opportunityJsonClass.cls_TradeLines>();
            tradeLines = oppJsonResp.TradeLines;
            system.debug(logginglevel.error,'###tradeLines::'+tradeLines);
            if(tradeLines != null && tradelines.size() != 0){
                for(opportunityJsonClass.cls_TradeLines trade: tradeLines){
                    newTrade = new Opportunity_Tradelines_Offer__c();
                    newTrade.FileNumber__c = trade.FileNumber;
                    newTrade.Import_Id__c = trade.Id;
                    if(String.isNotBlank(trade.OfferAmount))
                        newTrade.Offer_Amount__c = Decimal.ValueOf(trade.OfferAmount);
                    if(String.isNotBlank(trade.OfferProgramFee))
                        newTrade.Offer_Program_Fee__c = Decimal.valueOf(trade.OfferProgramFee);
                    if(String.isNotBlank(trade.SettlementAmountPaid))
                        newTrade.Settlement_Amount_Paid__c = Decimal.valueOf(trade.SettlementAmountPaid);
                    if(String.isNotBlank(trade.AmountPaid))
                        newTrade.Amount_Paid__c = Decimal.valueOf(trade.AmountPaid);
                    if(trade.DNLEstimatedSettlement != null && trade.DNLEstimatedSettlement !='')
                        newTrade.Estimated_Settlement__c = Decimal.valueOf(trade.DNLEstimatedSettlement);
                    if(trade.DNLFundstoClient != null && trade.DNLFundstoClient !='')
                        newTrade.DNL_Funds_to_Client__c = Decimal.valueOf(trade.DNLFundstoClient);
                    if(trade.DNLFundsforFees != null && trade.DNLFundsforFees !='')
                        newTrade.DNL_Funds_for_Fees__c = Decimal.valueOf(trade.DNLFundsforFees);
                    if(trade.DNLDisbursementAmount != null && trade.DNLDisbursementAmount !='')
                        newTrade.Actual_Settlement_Amount__c = Decimal.valueOf(trade.DNLDisbursementAmount);
                    if(trade.DNLSettlementFees != null && trade.DNLSettlementFees !='')
                        newTrade.DNL_Settlement_Fees__c = Decimal.valueOf(trade.DNLSettlementFees);
                    if(trade.DNLDisbursementDate != null && trade.DNLDisbursementDate !='')
                        newTrade.Settlement_Date__c = Date.valueOf(trade.DNLDisbursementDate);
                    if(trade.DNLDisbursementAmount != null && trade.DNLDisbursementAmount !='')
                        newTrade.DNL_Disbursement_Amount__c = Decimal.valueOf(trade.DNLDisbursementAmount);
                    if(trade.DNLDisbursementDate != null && trade.DNLDisbursementDate !='')
                        newTrade.DNL_Disbursement_Date__c = Date.valueOf(trade.DNLDisbursementDate);
                    if(trade.DNLfirstSettelment != null && trade.DNLfirstSettelment !=''){            //PDI-1043
                        newTrade.DNL_First_Settlement__c= (trade.DNLfirstSettelment=='true')?true:false;
                    }
                    
                    newTrade.Offer_Status__c = trade.OfferStatus;
                    newTrade.Current_Stage__c = trade.CurrentStage;
                    newTrade.Litigation_Stage__c = trade.LitigationStage;
                    //DV-129
                    if(trade.NewAccountNumber!= null && trade.NewAccountNumber!='')
                        newTrade.New_Account_Number__c = trade.NewAccountNumber;
                    if(trade.NewCreditor!= null && trade.NewCreditor!='')
                        newTrade.New_Creditor__c = trade.NewCreditor;
                    
                    
                    newTrade.Original_Account_Number__c  = trade.OriginalAccountNumber;
                    
                    newTrade.Original_Creditor__c = trade.OriginalCreditorName;
                    system.debug(logginglevel.error,'###trade.OriginalCreditorName::'+trade.OriginalCreditorName);
                    system.debug(logginglevel.error,'###newTrade.Original_Creditor__c::'+newTrade.Original_Creditor__c);
                    newTrade.Original_Debt__c = Decimal.valueOf(trade.OriginalDebt);
                    
                    if(trade.SFSCurrentBalance != null && trade.SFSCurrentBalance != '')
                        newTrade.SFS_Current_Balance__c = Decimal.valueof(trade.SFSCurrentBalance);
                    
                    oppSetPaymentLst = new List<opportunityJsonClass.cls_SettelmentPayments>();
                    if(trade.SettelmentPayments != NULL)
                        oppSetPaymentLst = trade.SettelmentPayments;
                    system.debug(logginglevel.error,'###trade.SettelmentPayments::'+trade.SettelmentPayments);
                    for(opportunityJsonClass.cls_SettelmentPayments pay: oppSetPaymentLst){
                        newPay = new Opportunity_Payment__c();
                        newPay.Import_Id__c = pay.Id;
                        newPay.RecordTypeId = settelmentPayRecTypeId; 
                        newPay.FileNumber__c = pay.FileNumber;
                        newPay.Payment_Status__c = pay.PaymentStatus;
                        newPay.Transaction_Method__c = pay.TransactionMethod;
                        newPay.Payment_Type__c = pay.PaymentType;
                        if(pay.TotalAmount != null && pay.TotalAmount != '')
                            newPay.Total_Amount__c = Double.valueOf(pay.TotalAmount);
                        if(pay.ScheduleDate != '' && pay.ScheduleDate != null)
                            newPay.Schedule_Date__c = Date.valueOf(pay.ScheduleDate);
                        
                        newPayLst.add(newPay);
                        paymentTradeLinemap.put(newPay.Import_Id__c,newTrade.Import_Id__c);
                    }
                    newTradeLst.add(newTrade);
                    }
            }
            
            if(!isPull){
                Id DNLTaskId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
                for(Task t : oppJsonResp.Tasks){
                    Task newTsk = new Task();
                    //Opportunity opp = new Opportunity(Import_Id__c = t.whatId);  
                    newTsk.priority = t.priority;
                    newTsk.ActivityDate = t.ActivityDate;
                    newTsk.Status = t.Status;
                    newTsk.Subject = t.Subject;
                    newTsk.Description = t.Description;
                    newTsk.Import_Id__c = t.Id;
                    newTsk.RecordTypeId = DNLTaskId; //PDI-600
                    //newTsk.Tasks_Category__c = t.Tasks_Category__c; 
                    newTsk.Tasks_Category__c = 'Contacted Call Back';  
                    if (t.Due_Date_Time__c != null){ //FS FOR NULL POINTER
                        newTsk.Due_Time__c = t.Due_Date_Time__c.Time();
                        newTsk.Due_Date_Time__c = t.Due_Date_Time__c;     //DV-189
                    }
                    else{
                        Date d=t.ActivityDate;
                        newTsk.Due_Date_Time__c=DateTime.newInstance(d.Year(), d.month(), d.day(), 9, 0, 0);
                    }
                    
                    if(!oppTaskMap.containsKey(t.whatId)){
                        oppTaskMap.put(t.whatId,new List<Task>());
                    }
                    oppTaskMap.get(t.whatId).add(newTsk);
                    //TaskList.add(newTsk);
                }
            }
            
            //Bank Account
            
            opportunityJsonClass.cls_BankAccount bankAccountCls = oppJsonResp.BankAccounts;
            if(bankAccountCls != null){
                fsCore__Bank_Account__c bankAccount = new fsCore__Bank_Account__c();
                bankAccount.Import_Id__c = bankAccountCls.BankAccountId;
                bankAccount.fsCore__Bank_Account_Type__c = bankAccountCls.AccountType;
                bankAccount.Name = bankAccountCls.Name;
                bankAccount.fsCore__Bank_Account_Number__c = bankAccountCls.BankAccountNumber;
                bankAccount.fsCore__Bank_Name__c = bankAccountCls.BankName;
                bankAccount.City__c = bankAccountCls.city;
                bankAccount.fsCore__Bank_Account_Holder_Name__c = bankAccountCls.HolderName;
                bankAccount.fsCore__Bank_Identification_Code__c = bankAccountCls.RoutingNumber;
                bankAccount.State__c= bankAccountCls.state;
                bankAccount.Phone__c = bankAccountCls.telephone;
                //PDI-759
                if(bankAccountCls.zip!=null && bankAccountCls.zip.length()>5){
                    bankAccount.Zip__c = bankAccountCls.zip.substring(0,5);     
                }
                else
                {
                    bankAccount.Zip__c = bankAccountCls.zip; 
                }
                
                BankAccountList.add(BankAccount);
                
                BankAccountOpportunityMap.put(bankAccount.Import_Id__c,oppNew.DRP_File_Number__c);
            }
            
            
        }
        Schema.SObjectField importIdField = Account.NDS_File_Number__c;
        system.debug(logginglevel.error,'###accUpsLst::'+accUpsLst);
        Database.UpsertResult[] insResults = Database.upsert(accUpsLst, importIdField, false);
        system.debug(logginglevel.error,'###insResults::'+insResults);
        List<Account> newInsAccLst = [Select Id,NDS_File_Number__c From Account Where NDS_File_Number__c IN: resFileNumSet];
        system.debug(logginglevel.error,'###newInsAccLst::'+newInsAccLst);
        for(Account acc: newInsAccLst)
            fileNumberAccMap.put(acc.NDS_File_Number__c,acc);
        system.debug(logginglevel.error,'###fileNumberAccMap::'+fileNumberAccMap);
        Map<String,Opportunity> oppFileNumberMap = new Map<String,Opportunity>(); 
        
        for(Opportunity opp: OppInsLst){
            System.debug('***OpportunityRecordype '+opp.RecordTypeId);
            if(fileNumberAccMap.containsKey(opp.DRP_File_Number__c))
                opp.AccountId = fileNumberAccMap.get(opp.DRP_File_Number__c).Id;
            if(fileNumberAccMap.containsKey(opp.DRP_File_Number__c+'CO')) 
                opp.Co_Applicant_Name__c = fileNumberAccMap.get(opp.DRP_File_Number__c+'CO').Id;
        }
        
        for(fsCore__Bank_Account__c bankAccount : BankAccountList){
            if(BankAccountOpportunityMap.containsKey(bankAccount.import_Id__c) && fileNumberAccMap.containsKey(BankAccountOpportunityMap.get(bankAccount.import_Id__c)))
                bankAccount.fsCore__Account_Name__c= fileNumberAccMap.get(BankAccountOpportunityMap.get(bankAccount.import_Id__c)).Id;
        }
        
        
        
        //Upsert Bank Account;
        system.debug(logginglevel.error,'****'+BankAccountList);
        Schema.SObjectField importIdBankField = fsCore__Bank_Account__c.Import_Id__c;
        Database.UpsertResult[] upsertBankResult = Database.Upsert(BankAccountList,importIdBankField,false);
        system.debug(logginglevel.error,'*****'+upsertBankResult);
        
        //Insert OppInsLst;
        Schema.SObjectField importIdOppField = Opportunity.Import_Id__c;
        Schema.SObjectField programIdOppField = Opportunity.Import_Program_Id__c  ;
        system.debug(logginglevel.error,'###ProgramId ::'+oppInsLst[0].Import_Program_Id__c );
        Database.UpsertResult[] insOppResults;
        if(oppInsLst != null && oppInsLst[0].Import_Id__c != null && oppInsLst[0].Import_Id__c != '')
        	insOppResults = Database.upsert(oppInsLst, importIdoppField, false);
        else if(oppInsLst != null && oppInsLst[0].Import_Program_Id__c  != null )
            insOppResults = Database.upsert(oppInsLst, programIdOppField, false);
        system.debug(logginglevel.error,'###insOppResults ::'+insOppResults );
        //Map<Id,Id> OpportunityMap = new Map<Id,Id>();  //@
        for(opportunity opp: oppInsLst){
            oppFileNumberMap.put(opp.DRP_File_Number__c,opp);
            if(opp.Import_Id__c != null)
            	opportunityMap.put(opp.Import_Id__c,opp.Id);
            else if (opp.Import_Program_Id__c != null)
                opportunityMap.put(opp.Import_Program_Id__c,opp.Id);
        }
        //PDI-794  mapIdSalesRep:till Line:479
        if(!isPull){
            set<id> oopsId=new set<id>();
            for(opportunity opp: oppInsLst){
                oopsId.add(opp.id); 
            }
            List<Opportunity> lstOpp=[Select id,owner.FirstName,owner.lastName,Import_Id__c,Import_Program_Id__c from Opportunity where id in:oopsId];
            if(lstOpp.size()>0){
                for(Opportunity op:lstOpp){
                    system.debug(logginglevel.error,'###Owner Name ::'+op.owner.FirstName +' '+op.owner.lastName +'OwnerId:'+op.OwnerId +'op.Import_Id__c: '+op.Import_Id__c );  
                    if(op.Import_Id__c != null)
                    	mapIdSalesRep.put(op.Import_Id__c, op.owner.FirstName +' '+op.owner.lastName);
                    else 
                        mapIdSalesRep.put(op.Import_Program_Id__c, op.owner.FirstName +' '+op.owner.lastName);
                }  
            } 
        }
        
            
        
        if(!isPull){
            if(oppTaskMap != null)
            for(String whatId : oppTaskMap.keySet()){
                Id oppId = opportunityMap.get(whatId);
                opportunity op=[select id,name,ownerId from opportunity where id=:oppId];  //PDI-651 @Sandip
                for(Task t : oppTaskMap.get(whatId)){
                    t.whatId = oppId;
                    t.ownerId=op.ownerId; //PDI-651 @Sandip
                    TaskList.add(t);
                }
            }
            Database.SaveResult[] insTaskResults = Database.insert(TaskList);
            system.debug(logginglevel.error,'****insTaskResults::'+insTaskResults);
        }
        //Upserting Trade lines and creating a map with import id and record
        system.debug(logginglevel.error,'****newTradeLst::'+newTradeLst);
        if(newTradeLst != null){
            for(Opportunity_Tradelines_Offer__c opptrd: newTradeLst){
                System.debug(logginglevel.ERROR, opptrd.FileNumber__c);
                opptrd.Opportunity_Name__c = oppFileNumberMap.get(opptrd.FileNumber__c).Id;    
        }
        
            Schema.SObjectField importIdTradeField = Opportunity_Tradelines_Offer__c.Import_Id__c;
            Database.UpsertResult[] insTradeResults = Database.upsert(newTradeLst, importIdTradeField, false);
            system.debug(logginglevel.error,'###insTradeResults::'+insTradeResults);
            Map<String,Opportunity_Tradelines_Offer__c> oppTradeImportIdMap = new Map<String,Opportunity_Tradelines_Offer__c>();
            
            system.debug(logginglevel.error,'###newtradeLst::'+newTradeLst);
            
            for(Opportunity_Tradelines_Offer__c trade: newTradeLst)
                oppTradeImportIdMap.put(trade.Import_Id__c,trade);  
            
            system.debug(logginglevel.error,'###oppTradeImportIdMap::'+oppTradeImportIdMap);
            
            system.debug(logginglevel.error,'###paymentTradeLinemap::'+paymentTradeLinemap);
            
            for(Opportunity_Payment__c oppPay: newPayLst){
                if(oppFileNumberMap.containsKey(oppPay.FileNumber__c)){
                    oppPay.Opportunity_Name__c = oppFileNumberMap.get(oppPay.FileNumber__c).Id;
                }
                if(paymentTradeLinemap.containsKey(oppPay.Import_Id__c)){
                    String tradeImportId = paymentTradeLinemap.get(oppPay.Import_Id__c);
                    if(oppTradeImportIdMap.containskey(tradeImportId))
                        oppPay.Tradelines_Name__c = oppTradeImportIdMap.get(tradeImportId).Id;
                }
                
            }
            Schema.SObjectField importIdPayField = Opportunity_Payment__c.Import_Id__c;
            Database.UpsertResult[] inspayResults = Database.upsert(newPayLst, importIdPayField, false);
            
            system.debug(logginglevel.error,'###inspayResults::'+inspayResults);
            system.debug(logginglevel.error,'###newPayLst::'+newPayLst);

        }   
        
         
        


        
        Schema.SObjectField ProgramIdField = Opportunity_Draft_Fee__c.Program_Id__c;
         system.debug(logginglevel.error,'****DraftFeesList' +DraftFeesList);
        if(DraftFeesList!= null && DraftFeesList.size() != 0){
            for(Opportunity_Draft_Fee__c df: DraftFeesList){
                df.Opportunity_Name__c = opportunityMap.get(df.Program_ID__c);    
            }
            Database.UpsertResult[] UpsDraftFeesResults = Database.upsert(DraftFeesList, ProgramIdField, false);
            system.debug(logginglevel.error,'****Draft Fees Result' +UpsDraftFeesResults);
        }
        
        if(isPull){
            List<fsCore__Lending_Application__c> LAppList = new List<fsCore__Lending_Application__c>();
            
            Map<Id,Opportunity> OppoList = new Map<Id,Opportunity>([Select Id,Import_Id__c,Related_Lending_Application__c from opportunity where Id =: opportunityMap.values()]);
            Id selectionKeyId = null;
            for(opportunityJsonClass.cls_Opportunity oppJsonResp: response.Opportunity){
                
                if(oppJsonResp.Id != null && oppJsonResp.Id != '')
                    selectionKeyId = oppJsonResp.Id ;
                else if (oppJsonResp.ProgramId != null && oppJsonResp.ProgramId != '')
                    selectionKeyId = oppJsonResp.ProgramId;
                
                if(opportunityMap.containsKey(selectionKeyId) && 
                   OppoList.containsKey(opportunityMap.get(selectionKeyId)) && 
                   OppoList.get(opportunityMap.get(selectionKeyId)).Related_Lending_Application__c != null){
                    fsCore__Lending_Application__c LApp = new fsCore__Lending_Application__c();
                    LApp.Id = OppoList.get(opportunityMap.get(selectionKeyId)).Related_Lending_Application__c;
                    if(oppJsonResp.MonthlyLegalFee != null && oppJsonResp.MonthlyLegalFee != null)
                        LApp.Monthly_Legal_Fee__c = Decimal.valueOf(oppJsonResp.MonthlyLegalFee);
                    if(oppJsonResp.MonthlyProcessorFee != null && oppJsonResp.MonthlyProcessorFee != null)
                        LApp.Monthly_Processor_Fee__c = Decimal.valueOf(oppJsonResp.MonthlyProcessorFee);
                    if(oppJsonResp.MonthlyThirdPartyFees != null && oppJsonResp.MonthlyThirdPartyFees != null)
                        LApp.Monthly_Third_Party_Fees__c = Decimal.valueOf(oppJsonResp.MonthlyThirdPartyFees);
                    //LApp.Payment_Frequency__c = oppJsonResp.PaymentFrequency;
                    if(oppJsonResp.RecurringDebitDay != null && oppJsonResp.RecurringDebitDay != null)
                        LApp.Recurring_Debit_Day__c = Integer.valueOf(oppJsonResp.RecurringDebitDay);
                    LApp.Subscribed_to_ALLG__c = Boolean.valueOf(oppJsonResp.SubscribedtoALLG);
                    if(oppJsonResp.TwiceMonthlyRecurringDay != null && oppJsonResp.TwiceMonthlyRecurringDay != null)
                        LApp.Twice_Monthly_Recurring_Day__c = Integer.valueOf(oppJsonResp.TwiceMonthlyRecurringDay);
                    if(oppJsonResp.TotalFee != null && oppJsonResp.TotalFee != null)  //PDI-1016
                        LApp.NuDebt_Total_Actual_Fee__c=Integer.valueOf(oppJsonResp.TotalFee);  
                    system.debug(logginglevel.error,'###LApp.NuDebt_Total_Actual_Fee__c::'+LApp.NuDebt_Total_Actual_Fee__c);
                    //PDI-741
                    if(oppJsonResp.ProgramStatus=='Pending Cancellation')
                        LApp.NuDebt_Program_Status__c='Pending DRP Cancellation';
                    
                    LAppList.add(LApp);
                }
            }
            Database.Update(LAppList);
        }
        
        
        system.debug(logginglevel.error,'###OppInsLst::'+OppInsLst);
        return 'Success';
    }
}