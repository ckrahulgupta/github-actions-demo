({
init : function (component) {
	var flow = component.find('postNLSDRAFT');
    var inputVariables = [
         { name : "PaymentMode", type : "String", value: 'DRAFT' },
        { name : "PostingToNLS", type : "Boolean", value: true }
       ];
    flow.startFlow('NLSClearFundingTransactions',inputVariables);
},
})