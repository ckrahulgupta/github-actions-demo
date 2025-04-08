({
	init: function (component) {
		var flow = component.find('postMobileDeposit');
		var inputVariables = [
			{ name: "PaymentMode", type: "String", value: 'MOBILE DEPOSIT' },
			{ name: "PostingToNLS", type: "Boolean", value: true }
		];
		flow.startFlow('NLSClearFundingTransactions', inputVariables);
	},
})