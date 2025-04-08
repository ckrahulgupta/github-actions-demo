({
init : function (component) {
	var flow = component.find('clearNLSProductReturn');
    var inputVariables = [
         { name : "PaymentMode", type : "String", value: 'PRODUCT RETURN' },
        { name : "PostingToNLS", type : "Boolean", value: false }
       ];
    flow.startFlow('NLSClearFundingTransactions',inputVariables);
},
})