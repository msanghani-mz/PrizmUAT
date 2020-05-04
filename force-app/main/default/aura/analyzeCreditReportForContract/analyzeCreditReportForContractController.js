({
	doInit : function(component, event, helper) {
		helper.doInitiaizeComponent(component, event, helper);
	},
	doCancel : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	doAnalyze : function(component, event, helper) {
		helper.doAnalyzeCreditReport(component, event, helper);
	},
})