({
init : function (component) {
	var flow = component.find('postNLSPAYMENT');
    var inputVariables = [
         { name : "PaymentMode", type : "String", value: 'PAYMENT' },
        { name : "PostingToNLS", type : "Boolean", value: true }
       ];
    flow.startFlow('NLSClearFundingTransactions',inputVariables);
},
})