({
    doInit : function(component, event, helper){

        const SUCCESS = 'SUCCESS';
        
        var action = component.get("c.callBatchForClosedLoans");
    
        action.setCallback(this, response => {
            var state = response.getState();

            if (state == SUCCESS) {
                var data = response.getReturnValue();
                component.set("v.showSuccess", true);
            }
        });
    
        $A.enqueueAction(action);

    }
})