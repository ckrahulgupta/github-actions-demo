({
init : function (component) {
	var flow = component.find('clearNLSACH');
    var inputVariables = [
         { name : "PaymentMode", type : "String", value: 'ACH' },
        { name : "PostingToNLS", type : "Boolean", value: false }
       ];
    flow.startFlow('NLSClearFundingTransactions',inputVariables);
},
})