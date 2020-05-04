({
    
    setTableColumns : function(component, event, helper) {
        component.set("v.customerTableColumns", [
            { label: "Customer Name", fieldName: "Person_Name_Formula__c", type: "text"},
            { label: "Type", fieldName: "fsCore__Customer_Type__c", type: "text"}
        ]);
    },
    
    setTableRows : function(component, event, helper) {
        helper.showSpinner(component, event);
        var action = component.get("c.getCustomers"); 
        action.setParams({
            "pId" : component.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.customers", response.getReturnValue());
                helper.hideSpinner(component, event);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        
        $A.enqueueAction(action);
    },
    
    requestAdditionalProof : function(component, event, helper) {
        var selectedCustomers = component.find("customerTable").getSelectedRows();
        var applicationId = component.get("v.recordId");
        if (selectedCustomers.length > 0){
            var selectedCustomersJSON = JSON.stringify(selectedCustomers);
            //alert(selectedCustomersJSON);
      
            helper.hideError(component, event);
            helper.showSpinner(component, event);

            var action = component.get("c.requestAdditionalAddressProof");
            
            action.setParams({
                "pSelectedCustomersJSON" : selectedCustomersJSON,
                "applicationId" : applicationId
            });
               
            action.setCallback(this, function (response) {
                 helper.hideSpinner(component, event); 
                 var state = response.getState();
                //var result = JSON.parse(response.getReturnValue());
                 if (state === "SUCCESS") {
                     helper.hideSpinner(component, event); 
                     helper.raiseToast(component, event);
                     helper.refreshAndCloseWindow(component, event);
                     
                 }
                 else{
                     var errMsg= response.getError();
                     helper.hideSpinner(component, event); 
                     helper.showError(component, event,errMsg);
                 }
            });
            
        }  
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
    hideError : function(component, event) {
        component.set("v.hasError", false);
        component.set("v.errorMessage", "");
    },
    raiseToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "Success",
            "message": "Additional address proof has been requested successfully!"
        });
        toastEvent.fire();
    },
    refreshAndCloseWindow : function(component, event) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
})