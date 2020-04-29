public with sharing class PaymentHistoryPDFController extends fsCore.PDFControllerBase{

    public fsServ__Lending_Contract__c mContract {get; private set;}
    public fsCore__Branch_Setup__c mBranch {get; private set;}
    public List<fsServ__Inbound_Payment__c> mPaymentList {get; private set;}
    
    private String mCompanyLogoURL;
    private Boolean mIsDownload;
    
    public PaymentHistoryPDFController (ApexPages.StandardController pStdController){
        super();
        this.mContract = (fsServ__Lending_Contract__c)pStdController.getRecord();
        mPaymentList = new  List<fsServ__Inbound_Payment__c>();
        mCompanyLogoURL = fsCore.Constants.BLANK_STRING;
        mIsDownload = true;
        
        setPDFContents();
    }
    
    private void setPDFContents(){
        if (mContract.Id != null){
            Map<String,String> pageURLParamMap = ApexPages.currentPage().getParameters();
            String contractType = fsCore.Constants.BLANK_STRING;
            if (pageURLParamMap.containsKey('type')){
                contractType = pageURLParamMap.get('type');
            }
            
            if (String.IsBlank(contractType) || 
                 (!contractType.equalsIgnoreCase(fsCore.Constants.PRODUCT_FAMILY_LEASE)
                   && !contractType.equalsIgnoreCase(fsCore.Constants.PRODUCT_FAMILY_LINE)
                     && !contractType.equalsIgnoreCase(fsCore.Constants.PRODUCT_FAMILY_LOAN))){
                contractType = fsCore.Constants.PRODUCT_FAMILY_LOAN;
            }
            mContract = fsServ.LendingContractUtil.getLendingContractForPDF(mContract.Id, contractType);
            mBranch = fsCore.UserBranchUtil.getBranchForPDF(mContract.fsServ__Branch_Name__c);
            mPaymentList = [Select id , fsServ__Payment_Amount__c,
                              fsServ__Payment_Status__c,
                              fsServ__Payment_Date__c, 
                              Allocated_Amount_Interest__c,
                              Allocated_Amount_Late_Fee__c,
                              Allocated_Amount_Other_Fee__c,
                              Allocated_Amount_Principal__c,
                              Rejection_Reason__c
                              from fsServ__Inbound_Payment__c 
                              where fsServ__Lending_Contract_Number__c = :mContract.id
                              Order By fsServ__Payment_Date__c];
            
            System.debug(loggingLevel.ERROR, mPaymentList );
            System.debug(loggingLevel.ERROR, mBranch );
            System.debug(loggingLevel.ERROR, mContract.Name );
             
            if (mBranch.fsCore__Company_Name__r.fsCore__Company_Logo_File_Id__c != null){
                mCompanyLogoURL = mBranch.fsCore__Company_Name__r.fsCore__Company_Logo_File_Id__c;
            }
            
            if (ApexPages.currentPage().getParameters().get('download') != null && ApexPages.currentPage().getParameters().get('download').equalsIgnoreCase('false')) {
                mIsDownload = false;
            }

            String pdfFileName =  mContract.Name + '_Payment_History.pdf';
            
            if (mIsDownload) { downloadPDF(pdfFileName); }
        }
    }
    
    public String getCompanyLogoURL(){
        return mCompanyLogoURL;
    }
    
}