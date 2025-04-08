({
init : function (component) {
	var flow = component.find('clearNLSDRAFT');
    var inputVariables = [
         { name : "PaymentMode", type : "String", value: 'DRAFT' },
        { name : "PostingToNLS", type : "Boolean", value: false }
       ];
    flow.startFlow('NLSClearFundingTransactions',inputVariables);
},
})