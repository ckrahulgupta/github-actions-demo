({
init : function (component) {
	var flow = component.find('postNLSProductReturn');
    var inputVariables = [
         { name : "PaymentMode", type : "String", value: 'PRODUCT RETURN' },
        { name : "PostingToNLS", type : "Boolean", value: true }
       ];
    flow.startFlow('NLSClearFundingTransactions',inputVariables);
},
})