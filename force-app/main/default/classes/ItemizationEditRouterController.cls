/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name   - ItemizationEditRouterController
 * 
 * Description  - Controller for visualforce page - editItemizationRouter
 * 
 *
 */
public with sharing class ItemizationEditRouterController {
    private static final String CLASS_NAME = 'ItemizationEditRouterController';
    private fsCore__Lending_Application__c mApplication;
    
    public ItemizationEditRouterController(ApexPages.StandardController pStdController){
        mApplication = (fsCore__Lending_Application__c)pStdController.getRecord();
        if (mApplication.Id == null){
            throw new fsCore.CustomException(Label.fscore.Page_Not_Displayed_For_New_Record);
        }
    }

    public PageReference redirectToComponent(){
        PageReference editItmzCmp = new PageReference('/lightning/cmp/c__itemizationEditPage?c__applicationid='+mApplication.Id);
        editItmzCmp.setRedirect(true);
        return editItmzCmp;
    }
}