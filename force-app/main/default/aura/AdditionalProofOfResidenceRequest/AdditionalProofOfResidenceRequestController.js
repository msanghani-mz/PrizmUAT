({
	doInit : function(component, event, helper) {
        helper.setTableColumns(component, event, helper);
        helper.setTableRows(component, event, helper);
        

	},
    doCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onTableRowSelection : function(component, event, helper) {
        var selectedCustomers = component.find("customerTable").getSelectedRows();
        if (selectedCustomers.length > 0){
            component.set("v.disableSendMailButton", false);
        } else {
            component.set("v.disableSendMailButton", true);
        }
    },
    doRequestAdditionalProof : function(component, event, helper) {
       
        helper.requestAdditionalProof(component, event, helper);
    
    }
})