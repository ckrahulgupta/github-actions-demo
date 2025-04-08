({
init : function (component) {
	var flow = component.find('postNLSACH');
    var inputVariables = [
         { name : "PaymentMode", type : "String", value: 'ACH' },
        { name : "PostingToNLS", type : "Boolean", value: true }
       ];
    flow.startFlow('NLSClearFundingTransactions',inputVariables);
},
})