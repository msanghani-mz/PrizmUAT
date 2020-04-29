/*
 * Class   : RefreshTradelinesController
 * Purpose : This is a controller class for lightning component - refreshTradelines
 * Author  : Financial Spectra
 */
public with sharing class RefreshTradelinesController {

    @AuraEnabled
    public static String refreshDataFromNuDebt(Id pApplicationId) {
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecord(pApplicationId);
        
        fsCore.ActionOutput acOutput = new fsCore.ActionOutput();
        try{
            RefreshTradelinesAction refreshTL = new RefreshTradelinesAction();
            refreshTL.setInput(acInput);
            refreshTL.setIsCalledFromUI(true);//DV-161
            refreshTL.process();
            acOutput = refreshTL.getOutput();
            if (acOutput.getIsSuccess()){
                acOutput.setMessage(Label.NuDebt_Refresh_Success_Message);
            }
        } catch (Exception e){
            acOutput.addError(e);
        }
        
        System.debug(acOutput);
        return acOutput.getJSONString();
    }
}