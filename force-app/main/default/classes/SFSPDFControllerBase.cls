public with sharing virtual class SFSPDFControllerBase {

    private String mTodayDate;
    
    public SFSPDFControllerBase(){
        mTodayDate = System.today().format();
    }
    
    public String getTodayDate(){
        return mTodayDate;
    }
    
    public void downloadPDF(String pPDFFileName){
        String downloadFileName = String.IsBlank(pPDFFileName) ? 'Download.pdf' : pPDFFileName;
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + downloadFileName);
    }
    
}