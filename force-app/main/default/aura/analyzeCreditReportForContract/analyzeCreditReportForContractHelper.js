({
	doInitiaizeComponent : function(component, event, helper) {
        helper.showSpinner(component, event);
        var action = component.get("c.getCreditReportInfo");
        action.setParams({
            "pConId" : component.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var reportInfoJSON = response.getReturnValue();
                console.log("Report Info : " + reportInfoJSON);
                helper.hideSpinner(component, event);
                
                if ($A.util.isUndefinedOrNull(reportInfoJSON)){
                    helper.showMessage(component, event, "error", "Unable to find credit report details.");
                } 
                else {
                    var reportInfo = JSON.parse(reportInfoJSON);
                    component.set("v.reportInfo", reportInfo);
                    
                    if ($A.util.isUndefinedOrNull(reportInfo.applicantCreditReportId) || !reportInfo.applicantCreditReportExists){
                        helper.showMessage(component, event, "error", $A.get("$Label.c.Applicant_Credit_Report_Not_Exist"));
                    } 
                    else if (reportInfo.coApplicantExists && ($A.util.isUndefinedOrNull(reportInfo.coApplicantCreditReportId) || !reportInfo.coApplicantCreditReportExists)){
                        helper.showMessage(component, event, "error", $A.get("$Label.c.Co_Applicant_Credit_Report_Not_Exist"));
                    } 
                    else {
                        if (reportInfo.applicantCreditReportExists && reportInfo.applicantCreditReportAnalyzed){
                            helper.showMessage(component, event, "warning", $A.get("$Label.c.Analysis_Data_Already_Exist"));
                            component.set("v.showConfirmButton", true);
                        } 
                        else {
                            helper.doAnalyzeCreditReport(component, event, helper);
                        }
                    }
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
	},
    doAnalyzeCreditReport : function(component, event, helper) {
        helper.showSpinner(component, event);
		helper.hideMessage(component, event);
        component.set("v.showConfirmButton", false);
        component.set("v.messageText", "Analyzing Credit Report ...");
        
        var action = component.get("c.analyzeCreditReport");
        action.setParams({
            "pConId" : component.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Result : " + response.getReturnValue());
                var result = JSON.parse(response.getReturnValue());
                
                if (result.isSuccess){
                    helper.raiseToast(component, event, result);
                    helper.refreshAndCloseWindow(component, event);
                }    
                else {
                    helper.showMessage(component, event, "error", result.message);
                }
                helper.hideSpinner(component, event);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
	},
    showSpinner : function(component, event) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function(component, event) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
	raiseToast : function(component, event, result) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "info",
            "title": result.message,
            "message": result.details
        });
        toastEvent.fire();
	},
    refreshAndCloseWindow : function(component, event) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    showMessage : function(component, event, messageType, messageText) {
        if (messageType == "error"){
            component.set("v.iconName", "utility:ban");
            component.set("v.iconVariant", "error");
        } else if (messageType == "warning"){
            component.set("v.iconName", "utility:notification");
            component.set("v.iconVariant", "warning");
        } 
        component.set("v.messageText", messageText);
        component.set("v.showMessage", true);
	},
    hideMessage : function(component, event) {
        component.set("v.showMessage", false);
        component.set("v.iconName", "");
        component.set("v.iconVariant", "");
        component.set("v.messageText", "");
	}
    
})