({
    doInit : function(component, event, helper){
                component.set("v.showSpinner", true);
                var action = component.get("c.enableUserForGrowerPortal");
                 action.setParams({
                    "contactId" : component.get("v.recordId")
                });
            
                action.setCallback(this, function(response) {           
                var matchRes=response.getReturnValue();
                var check = matchRes== 'Success'? true : false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": check ? 'User Updated For Grower Portal' : matchRes,
                    "type": check ? "success":"error",
                    "title": check ? "Success":"Error"
                });
                toastEvent.fire();
                component.set("v.showSpinner", false);
                $A.get('e.force:refreshView').fire();    
                $A.get("e.force:closeQuickAction").fire();
            });
            
            $A.enqueueAction(action);
        
    }
})