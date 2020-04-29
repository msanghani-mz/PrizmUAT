/*
* Class   : CreditPullController
* Purpose : This class has the methods to invoke the credit pull integration
* Author  : Financial Spectra
*/
public with sharing class CreditPullController {
    
    public static String errorMessage;
    @AuraEnabled
    public static CreditPullAttributes getPullTypeAttributes(){
        CreditPullAttributes pullAttribs = new CreditPullAttributes();
        pullAttribs.isDisplayPullTypeButton = fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Display_Pull_Type_Toggle_Button');
        pullAttribs.defaultPullType = SFS_System_Settings__c.getInstance().Default_Pull_Type_DNL__c;
        pullAttribs.defaultPullType = (String.IsNotBlank(pullAttribs.defaultPullType) && pullAttribs.defaultPullType.equalsIgnoreCase('Hard')) ? 'Hard' : 'Soft';
        
        pullAttribs.isDisplayBureauOptions = fsCore.CustomPermissionUtil.getInstance().isCustomPermissionAssigned('Display_Credit_Bureau_Options');
        //pullAttribs.isDisplayBureauOptions = true; //For Testing
        pullAttribs.bureaus = new List<LabelValueType>();
        
        List<Credit_Bureau__mdt> creditBureaus = [SELECT Id, MasterLabel, Credit_Bureau_Code__c, Is_Default__c
                                                  FROM Credit_Bureau__mdt WHERE Is_Active__c = true
                                                  ORDER BY Display_Order__c ASC];
        
        for(Credit_Bureau__mdt bureau : creditBureaus){
            if (bureau.Is_Default__c){
                pullAttribs.defaultBureau = bureau.Credit_Bureau_Code__c;
                pullAttribs.bureaus.add(new LabelValueType(bureau.MasterLabel, bureau.Credit_Bureau_Code__c));
            }
            else if (pullAttribs.isDisplayBureauOptions){
                pullAttribs.bureaus.add(new LabelValueType(bureau.MasterLabel, bureau.Credit_Bureau_Code__c));
            }
        }
        
        if (pullAttribs.bureaus.size() == 0 && creditBureaus.size() > 0){
            pullAttribs.bureaus.add(new LabelValueType(creditBureaus.get(0).MasterLabel, creditBureaus.get(0).Credit_Bureau_Code__c));
        }
        if (String.IsBlank(pullAttribs.defaultBureau) && pullAttribs.bureaus.size() > 0){
            pullAttribs.defaultBureau = pullAttribs.bureaus.get(0).value;
        }
        
        System.debug(loggingLevel.ERROR, pullAttribs);
        return pullAttribs;
    }
    
    @AuraEnabled
    public static List<CreditPullCustomer> getCustomers(Id pId){  
        List<CreditPullCustomer> creditCustomerList;
        
        if(pId.getSObjectType().getDescribe().getName() == Schema.SObjectType.fsCore__Lending_Application__c.getName()){
           creditCustomerList = CreditPullUtil.getApplicationCustomers(pId);
        }else if(pId.getSObjectType().getDescribe().getName() == Schema.SObjectType.fsServ__Lending_Contract__c.getName()){
           creditCustomerList = CreditPullUtil.getContractCustomers(pId);
        }
        return creditCustomerList;
    }
    
    @AuraEnabled
    public static String pullCreditReport(String pSelectedCustomersJSON, Boolean pIsSoftPull, String pBureauCode){
        System.debug(loggingLevel.ERROR, 'CreditPullController.pullCreditReport(+)');
        System.debug(loggingLevel.ERROR, '-- Input Params : Bureau Code=' + pBureauCode + '; Is Soft Pull=' + pIsSoftPull + '; Customer JSON=' + pSelectedCustomersJSON);
        
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        CreditPullAction crPullAction = new CreditPullAction();
        try{
            List<CreditPullCustomer> selectedCustomers =
                (List<CreditPullCustomer>)JSON.deserialize(pSelectedCustomersJSON, List<CreditPullCustomer>.class);
            
                       
            Boolean isPrimaryCustomerSelected = false; 
            String pullEntity = CreditPullAction.PULL_ENTITY_CONTRACT;
            
            for(CreditPullCustomer customer : selectedCustomers){
                if (customer.customer_Type == fsCore.Constants.CUSTOMER_TYPE_PRIMARY){
                    isPrimaryCustomerSelected = true;
                }
                if (customer.is_customer_source_lending_application){
                    pullEntity = CreditPullAction.PULL_ENTITY_APPLICATION;
                }
            }    
            
            if (!isPrimaryCustomerSelected){
                //  errorMessage = 'Invalid Selection, Primary customer must be selected.';
                // actionOP.addError('Invalid Selection, Primary customer must be selected.');
                throw constructAndThrowAuraException('Invalid Selection, Primary customer must be selected.');
            }
            
            Set<Id> customerIdSet = new Set<Id>();
            for(CreditPullCustomer customer : selectedCustomers){
                customerIdSet.add(customer.customer_Id);
            }
            System.debug(loggingLevel.ERROR, '--  Customers Ids : ' + customerIdSet);
            
            fsCore.ActionInput actionIP = new fsCore.ActionInput();
            actionIP.addRecords(customerIdSet);
            crPullAction.setCustomers(selectedCustomers);
            crPullAction.setInput(actionIP);
            crPullAction.setPullType(pIsSoftPull ? 'Soft' : 'Hard');
            crPullAction.setPullEntity(pullEntity);
            crPullAction.setPullSource(pBureauCode);
            crPullAction.process();
     
            actionOP = crPullAction.getOutput();
        } 
        catch (Exception e){
            actionOP.addError(e.getMessage());
            actionOP.setIsSuccess(false);
            errorMessage = e.getMessage();

        }
        List<Credit_Pull_Report__c> cpReports = crPullAction.getCreditPullReportRecords();
        System.debug(loggingLevel.ERROR, 'cpReports-- > '+ cpReports);
        if ( ((cpReports != null) && (!cpReports.isEmpty())) && (actionOP.getIsSuccess())){
            System.debug(loggingLevel.ERROR, 'cpReports Report'+ cpReports.get(0).Id);
            actionOP.setRecordId(cpReports.get(0).Id);
        }
        
        System.debug(loggingLevel.ERROR, 'CreditPullController.pullCreditReport(-)'+ actionOP.getJSONString());
        return actionOP.getJSONString();
        //return (actionOP.getIsSuccess() ? crPullAction.getCreditPullReportRecords() : null);
        
    }
    
    private static AuraHandledException constructAndThrowAuraException(String pErrorMessage){
        AuraHandledException e = new AuraHandledException(pErrorMessage);
        e.setMessage(pErrorMessage);
        return e;
    }

    @AuraEnabled
    public static String generateReportPDF(String pReportId){
        fsCore.ActionOutput actionOP = new fsCore.ActionOutput();
        
        try{
            //List<Credit_Pull_Report__c> creditPullReports =
            //    (List<Credit_Pull_Report__c>)JSON.deserialize(pCreditPullReportsJSON, List<Credit_Pull_Report__c>.class);
            
            Set<Id> reportIdSet = new Set<Id>();
            reportIdSet.add(Id.ValueOf(pReportId));
            //for(Credit_Pull_Report__c cpReport : creditPullReports){
                
            //}
            System.debug(loggingLevel.ERROR, '-- Credit Pull Report Ids : ' + reportIdSet);
            
            fsCore.ActionInput actionIP = new fsCore.ActionInput();
            actionIP.addRecords(reportIdSet);
            
            GenerateCreditReportAction pdfGenAction = new GenerateCreditReportAction();
            pdfGenAction.setInput(actionIP);
            pdfGenAction.process();
            
            actionOP = pdfGenAction.getOutput();
        } 
        catch (Exception e){
            System.debug(loggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
            actionOP.addError(e);
        }
        
        if (actionOP.getIsSuccess()){
            actionOP.setMessage(Label.Action_Completed_Title);
            actionOP.setMessageDetails(Label.Credit_Pull_Success_Message);
        }
        
        return actionOP.getJSONString();
    }
    
    
}