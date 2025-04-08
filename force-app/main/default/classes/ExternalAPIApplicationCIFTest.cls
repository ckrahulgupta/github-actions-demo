/**********************************************************************************************
 * @className         : TestExternalAPIApplicationCIF
 * @description       : Test Class for ExternalAPIApplicationCIF
 * @author            : Simran
 * @created Date      : 03-01-2022
 * @last modified on  : 06-24-2024
 * @last modified by  : Riadh Mankai
 * @see ExternalAPIApplicationCIFGMK
 * @see ExternalAPILoans
 * @see ExternalAPITransactions
 * @see ExternalAPIUtilities
 **********************************************************************************************/
@IsTest
public class ExternalAPIApplicationCIFTest {
	final static String testAccountName = 'ACK';
	final static String testDealerAccountName = 'ACK_Dealer';
	final static String testParentApplicationLoanNumber = '1234567890';
	final static String testChildLoanNumber = '58896334751';
	final static String transactionToVoidId1 = 'Test Transaction to void ID 1';
	final static Decimal creditAmount = 100;
	@TestSetup
	public static void setupAPIData() {
		//        insert payment mode objects (ACH and Product Return)
		clcommon__Payment_Mode__c paymentModeACH = new clcommon__Payment_Mode__c(Name = ExternalAPIUtilities.ACH);
		insert paymentModeACH;
		clcommon__Payment_Mode__c paymentModeProductReturn = new clcommon__Payment_Mode__c(Name = ExternalAPIUtilities.PRODUCT_RETURN);
		insert paymentModeProductReturn;
		// Creating data for Account (grower)
		Account objAccount = new Account();
		objAccount.Name = testAccountName;
		objAccount.CIF_Number__c = '132324';
		objAccount.Coop_Type__c = ExternalAPIApplicationCIFGMK.GROWMARK;
		Database.insert(objAccount);
		// Creating data for Account (dealer)
		Account dealerAccount = new Account();
		dealerAccount.Name = testDealerAccountName;
		dealerAccount.CIF_Number__c = '132325';
		dealerAccount.Coop_Type__c = ExternalAPIApplicationCIFGMK.GROWMARK;
		Database.insert(dealerAccount);

		// Creating a test parent application
		genesis__Applications__c objApplication = new genesis__Applications__c();
		objApplication.genesis__Loan_Amount__c = 35000.00;
		objApplication.Crop_Year__c = '2008';
		objApplication.genesis__Status__c = 'ACTIVE';
		objApplication.genesis__Loan_Number__c = testParentApplicationLoanNumber;
		objApplication.Note_Date__c = Date.today();
		objApplication.genesis__Maturity_Date__c = Date.today().addMonths(6);
		objApplication.genesis__Account__c = objAccount.Id;
		objApplication.Dealer_Name__c = dealerAccount.Id;
		Database.insert(objApplication);

//		create a test child loan
		genesis__Application_Pricing_Detail__c pricingDetail = new genesis__Application_Pricing_Detail__c(
			  genesis__Application__c = objApplication.Id,
			  genesis__Base_Rate__c = 5,
			  Accrued_Interest__c = 5,
			  Credit_Balance__c = creditAmount,
			  genesis__Enabled_Flag__c = true,
			  Growmark_Loan_Number__c = testChildLoanNumber,
			  Loan_Number__c = testChildLoanNumber
		);
		insert pricingDetail;
		// Creating data for Party
		clcommon__Party__c objParty = new clcommon__Party__c();
		objParty.clcommon__Party_Types__c = 'BORROWER';
		objParty.clcommon__Account__c = objAccount.Id;
		objParty.genesis__Application__c = objApplication.Id;
		Database.insert(objParty);
	}
	@IsTest
	public static void testExternalAPIApplicationCIF() {
		genesis__Applications__c objApplication = [
			  SELECT genesis__Loan_Amount__c, Crop_Year__c, genesis__Status__c, genesis__Loan_Number__c, Note_Date__c, genesis__Maturity_Date__c, genesis__Account__c, Id
			  FROM genesis__Applications__c
			  WHERE genesis__Loan_Number__c = :testParentApplicationLoanNumber
			  LIMIT 1
		];
		genesis__Application_Pricing_Detail__c pricingDetail = [
			  SELECT Id, genesis__Application__c, genesis__Base_Rate__c, Accrued_Interest__c, Credit_Balance__c, genesis__Enabled_Flag__c, Growmark_Loan_Number__c
			  FROM genesis__Application_Pricing_Detail__c
			  WHERE Growmark_Loan_Number__c = :testChildLoanNumber
			  LIMIT 1
		];
		//        Creating Funding Transaction records attached to the parent application
		genesis__Funding_Transaction__c fundingTransaction = new genesis__Funding_Transaction__c(
			  genesis__Application__c = objApplication.Id,
			  genesis__Amount__c = 50,
			  Principal__c = 70
		);
		insert fundingTransaction;

		genesis__Funding_Transaction__c fundingTransactionChild2 = new genesis__Funding_Transaction__c(
			  Pricing_Detail__c = pricingDetail.Id,
			  genesis__Amount__c = 10,
			  Principal__c = 20
		);
		insert fundingTransactionChild2;

		System.assertEquals(objApplication.genesis__Loan_Amount__c, 35000.00);

		ExternalAPIApplicationCIF.CIF_NUMBER = '132324';
		objApplication.genesis__Loan_Amount__c = 36000.00;
		System.assertEquals(36000.00, objApplication.genesis__Loan_Amount__c);

		//     Make a positive test
		ExternalAPIApplicationCIFGMK.CIF_NUMBER = '132324';
		objApplication.genesis__Loan_Amount__c = 37000.00;
		List<ExternalAPIUtilities.LoanWrapper> loansWrappers = ExternalAPIApplicationCIFGMK.getGMKLoansByCIFNumber();
		System.assertEquals(37000.00, objApplication.genesis__Loan_Amount__c);

		// Provoke an error and test it - loan number containing non alpha characters
		ExternalAPIApplicationCIFGMK.CIF_NUMBER = '132324';
		objApplication.genesis__Loan_Number__c = 'FF12A34567890H';
		update objApplication;
		loansWrappers = ExternalAPIApplicationCIFGMK.getGMKLoansByCIFNumber();
		List<clcommon__Log__c> logs = [SELECT Id, clcommon__Message__c FROM clcommon__Log__c];
		System.debug('riri logs: ' + logs);
		System.assertEquals(1, logs.size());
	}

	@IsTest
	public static void testPushGMKTransactionPost() {
		clcommon__Payment_Mode__c paymentModeACH = [SELECT Id, Name FROM clcommon__Payment_Mode__c WHERE Name = :ExternalAPIUtilities.ACH LIMIT 1];
		genesis__Applications__c objApplication = [
			  SELECT genesis__Loan_Amount__c, Crop_Year__c, genesis__Status__c, genesis__Loan_Number__c, Note_Date__c, genesis__Maturity_Date__c, genesis__Account__c, Id
			  FROM genesis__Applications__c
			  WHERE genesis__Loan_Number__c = :testParentApplicationLoanNumber
			  LIMIT 1
		];

		//        Creating Funding Transaction records attached to the parent application
		genesis__Funding_Transaction__c fundingTransaction = new genesis__Funding_Transaction__c(
			  genesis__Application__c = objApplication.Id,
			  genesis__Amount__c = 50,
			  genesis__Payment_Mode__c = paymentModeACH.Id,
			  Principal__c = 70
		);
		insert fundingTransaction;

		Test.startTest();
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 1',
			  Long.valueOf(testChildLoanNumber),
			  150,
			  'Apex Test purpose'
		);
		Test.stopTest();
		List<clcommon__Log__c> logs = [SELECT Id, Name, clcommon__Message__c FROM clcommon__Log__c];
		System.debug('riri logs: ' + logs);
		System.assertEquals(3, [SELECT Id, genesis__Payment_Mode__c FROM genesis__Funding_Transaction__c].size());
		List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT genesis__Payment_Mode__c, genesis__Payment_Mode__r.Name FROM genesis__Funding_Transaction__c];
		for (genesis__Funding_Transaction__c eachTransaction : fundingTransactions) {
			System.assertEquals(ExternalAPIUtilities.ACH, eachTransaction.genesis__Payment_Mode__r.Name);
		}

		//        test product return transaction post
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 2 product return',
			  Long.valueOf(testChildLoanNumber),
			  -10.00,
			  'Apex Test purpose 2 product return'
		);
		System.assertEquals(
			  4,
			  [SELECT Id FROM genesis__Funding_Transaction__c].size()
		);
		genesis__Funding_Transaction__c productReturnTransaction = [
			  SELECT Id, genesis__Amount__c, Is_Growmark_Product_Return__c
			  FROM genesis__Funding_Transaction__c
			  WHERE genesis__Reference__c = 'Apex Test purpose 2 product return'
			  LIMIT 1
		];
		System.assertEquals(10, productReturnTransaction.genesis__Amount__c);
		System.assertEquals(true, productReturnTransaction.Is_Growmark_Product_Return__c);

		// force an error - make the maturity date null
		objApplication.genesis__Maturity_Date__c = null;
		update objApplication;
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 3',
			  Long.valueOf(testChildLoanNumber),
			  -10.00,
			  'Apex Test purpose 2'
		);
		System.assertEquals(1, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - amount is zero
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 4',
			  Long.valueOf(testChildLoanNumber),
			  0,
			  'Apex Test purpose 2'
		);
		System.assertEquals(2, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - loan number not provided
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 5',
			  null,
			  10,
			  'Apex Test purpose 2'
		);
		System.assertEquals(3, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - borrow more than what is available
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 6',
			  Long.valueOf(testChildLoanNumber),
			  2000,
			  'Apex Test purpose 2'
		);
		System.assertEquals(4, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - product return too high
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 7',
			  Long.valueOf(testChildLoanNumber),
			  -5000,
			  'Apex Test purpose'
		);
		System.assertEquals(5, [SELECT Id FROM clcommon__Log__c].size());

		//    delete payment object and test if there is an error
		delete paymentModeACH;
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'Test Transaction ID 8',
			  Long.valueOf(testChildLoanNumber),
			  10,
			  'Apex Test purpose'
		);
		System.assertEquals(6, [SELECT Id FROM clcommon__Log__c].size());
	}

	@IsTest
	public static void testTransactionVoiding() {
//		Insert a regular transaction, with an amount superior to the credit
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  transactionToVoidId1,
			  Long.valueOf(testChildLoanNumber),
			  300,
			  'Apex Test purpose is to test the voiding feature'
		);

		Test.startTest();
//		Insert a transaction to void or cancel the previous one
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  transactionToVoidId1,
			  Long.valueOf(testChildLoanNumber),
			  -300,
			  'Apex Test purpose is void the previous transaction'
		);
		Test.stopTest();

		List<genesis__Funding_Transaction__c> voidedTransactions = [
			  SELECT Id, Status__c, Growmark_Transaction_Source_ID__c, Is_Clearing_Suspense__c, genesis__Amount__c
			  FROM genesis__Funding_Transaction__c
			  WHERE Growmark_Transaction_Source_ID__c = :transactionToVoidId1
		];
		for (genesis__Funding_Transaction__c eachVoidedTransaction : voidedTransactions) {
			Assert.areEqual('Voided', eachVoidedTransaction.Status__c);
		}
		Assert.areEqual(2, voidedTransactions.size());

		List<genesis__Funding_Transaction__c> matchingClearingSuspenseTransactions = [
			  SELECT Id, genesis__Amount__c, Is_Clearing_Suspense__c, Status__c, Pricing_Detail__r.Credit_Balance__c,
					Pricing_Detail__c
			  FROM genesis__Funding_Transaction__c
			  WHERE Growmark_Transaction_Source_ID__c = :transactionToVoidId1
			  AND Is_Clearing_Suspense__c = TRUE
		];
		Assert.areEqual(creditAmount, matchingClearingSuspenseTransactions[0].Pricing_Detail__r.Credit_Balance__c);

		List<genesis__Funding_Transaction__c> matchingRegularTransactions = [
			  SELECT Id, genesis__Amount__c, Is_Clearing_Suspense__c, Status__c, Pricing_Detail__r.Credit_Balance__c,
					Pricing_Detail__c, Pricing_Detail__r.Principal_Advanced__c, Pricing_Detail__r.genesis__Application__c,
					Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c
			  FROM genesis__Funding_Transaction__c
			  WHERE Growmark_Transaction_Source_ID__c = :transactionToVoidId1
			  AND Is_Clearing_Suspense__c = FALSE
		];
		Assert.areEqual(0, matchingRegularTransactions[0].Pricing_Detail__r.Principal_Advanced__c);
		Assert.areEqual(0, matchingRegularTransactions[0].Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c);

//		test a negative scenario: void a transaction that was already voided.
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  transactionToVoidId1,
			  Long.valueOf(testChildLoanNumber),
			  -300,
			  'Apex Test purpose is void the previous transaction'
		);
		System.assertEquals(1, [SELECT Id, clcommon__Message__c FROM clcommon__Log__c].size());
	}

	@IsTest
	static void testTransactionVoidingAlreadyCleared() {
//		Insert a regular transaction, with an amount superior to the credit
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  transactionToVoidId1,
			  Long.valueOf(testChildLoanNumber),
			  300,
			  'Apex Test purpose is to test the voiding feature'
		);
//		Tweak one of the inserted transactions to make it look like cleared (sent to NLS)
		genesis__Funding_Transaction__c transactionToClear = [
			  SELECT
					Id
			  FROM genesis__Funding_Transaction__c
			  WHERE Is_Clearing_Suspense__c = FALSE
			  AND Growmark_Transaction_Source_ID__c = :transactionToVoidId1
			  LIMIT 1
		];
		transactionToClear.genesis__Cleared__c = true;
		update transactionToClear;

		Test.startTest();
//		Insert a transaction to void or cancel the previous one
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  transactionToVoidId1,
			  Long.valueOf(testChildLoanNumber),
			  -300,
			  'Apex Test purpose is void the previous transaction'
		);
		Test.stopTest();

		System.assertEquals(1, [SELECT Id, clcommon__Message__c FROM clcommon__Log__c].size());
	}

	@IsTest
	static void testWithAmountEqualsToAvailableCredit() {
		Test.startTest();
//		Insert a regular transaction, with an amount equal to the credit
		ExternalAPIApplicationCIFGMK.pushGMKTransaction(
			  'transaction test id 001',
			  Long.valueOf(testChildLoanNumber),
			  creditAmount,
			  'Apex Test purpose is to test the voiding feature'
		);
		Test.stopTest();

		List<genesis__Funding_Transaction__c> transactionsCreated = [
			  SELECT Id, Status__c, Growmark_Transaction_Source_ID__c, Is_Clearing_Suspense__c, genesis__Amount__c, Pricing_Detail__r.Credit_Balance__c
			  FROM genesis__Funding_Transaction__c
		];
		Assert.areEqual(1, transactionsCreated.size());
		Assert.areEqual(true, transactionsCreated[0].Is_Clearing_Suspense__c);
		Assert.areEqual(creditAmount, transactionsCreated[0].genesis__Amount__c);
		Assert.areEqual(0, transactionsCreated[0].Pricing_Detail__r.Credit_Balance__c);
	}

	@IsTest
	public static void testPushGenericTransaction() {
		clcommon__Payment_Mode__c paymentModeACH = [SELECT Id, Name FROM clcommon__Payment_Mode__c WHERE Name = :ExternalAPIUtilities.ACH LIMIT 1];
		genesis__Applications__c objApplication = [
			  SELECT genesis__Loan_Amount__c, Crop_Year__c, genesis__Status__c, genesis__Loan_Number__c, Note_Date__c, genesis__Maturity_Date__c, genesis__Account__c, Id
			  FROM genesis__Applications__c
			  WHERE genesis__Loan_Number__c = :testParentApplicationLoanNumber
			  LIMIT 1
		];

		//        Creating Funding Transaction records attached to the parent application
		genesis__Funding_Transaction__c fundingTransaction = new genesis__Funding_Transaction__c(
			  genesis__Application__c = objApplication.Id,
			  genesis__Amount__c = 50,
			  genesis__Payment_Mode__c = paymentModeACH.Id,
			  Principal__c = 70
		);
		insert fundingTransaction;

//		test general generic transaction
		Test.startTest();
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 1',
			  testChildLoanNumber,
			  150,
			  'Apex Test purpose'
		);
		Test.stopTest();
		System.assertEquals(3, [SELECT Id, genesis__Payment_Mode__c FROM genesis__Funding_Transaction__c].size());
		List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT genesis__Payment_Mode__c, genesis__Payment_Mode__r.Name FROM genesis__Funding_Transaction__c];
		for (genesis__Funding_Transaction__c eachTransaction : fundingTransactions) {
			System.assertEquals(ExternalAPIUtilities.ACH, eachTransaction.genesis__Payment_Mode__r.Name);
		}

		//        test product return transaction post for generic transactions
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 2 product return',
			  testChildLoanNumber,
			  -10.00,
			  'Apex Test purpose 2 product return'
		);
		System.assertEquals(
			  4,
			  [SELECT Id FROM genesis__Funding_Transaction__c].size()
		);
		genesis__Funding_Transaction__c productReturnTransaction = [
			  SELECT Id, genesis__Amount__c, Is_Growmark_Product_Return__c
			  FROM genesis__Funding_Transaction__c
			  WHERE genesis__Reference__c = 'Apex Test purpose 2 product return'
			  LIMIT 1
		];
		System.assertEquals(10, productReturnTransaction.genesis__Amount__c);
		System.assertEquals(true, productReturnTransaction.Is_Growmark_Product_Return__c);

		// force an error - make the maturity date null
		objApplication.genesis__Maturity_Date__c = null;
		update objApplication;
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 3',
			  testChildLoanNumber,
			  -10.00,
			  'Apex Test purpose 2'
		);
		System.assertEquals(1, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - make the transaction amount zero
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 4',
			  testChildLoanNumber,
			  0,
			  'Apex Test purpose 2'
		);
		System.assertEquals(2, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - do not provide a loan number
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 5',
			  null,
			  10,
			  'Apex Test purpose 2'
		);
		System.assertEquals(3, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - borrow more than what is available
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 6',
			  testChildLoanNumber,
			  2000,
			  'Apex Test purpose 2'
		);
		System.assertEquals(4, [SELECT Id FROM clcommon__Log__c].size());

		// force an error - product return too high
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 7',
			  testChildLoanNumber,
			  -5000,
			  'Apex Test purpose'
		);
		System.assertEquals(5, [SELECT Id FROM clcommon__Log__c].size());

		//    force an error - no payment method available in the database
		delete paymentModeACH;
		ExternalAPITransactions.pushTransaction(
			  'Test Transaction ID 8',
			  testChildLoanNumber,
			  10,
			  'Apex Test purpose'
		);
		System.assertEquals(6, [SELECT Id FROM clcommon__Log__c].size());
	}

}