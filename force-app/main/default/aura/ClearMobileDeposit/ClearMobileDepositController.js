({
	init: function (component) {
		var flow = component.find('clearMobileDeposit');
		var inputVariables = [
			{ name: "PaymentMode", type: "String", value: 'MOBILE DEPOSIT' },
			{ name: "PostingToNLS", type: "Boolean", value: false }
		];
		flow.startFlow('NLSClearFundingTransactions', inputVariables);
	},
})