/**
 * @description This class is used to test the ExternalAPILoans class
 * @see ExternalAPILoans
 * @author Riadh Mankai
*/
@IsTest
private class ExternalAPILoansTest {
	static final String TEST_DEALER_CIF_NUMBER = '870352500';
	static final String ACCOUNT_UNIQUE_ID = 'Unique012';
	static final String TEST_USERNAME = 'test5466322@test.cfa.dev';

	static void setupData() {
		// Creating data for dealer account
		Account testDealerAccount = new Account();
		testDealerAccount.Name = 'ExternalAPILoansTest-Test Dealer';
		testDealerAccount.CIF_Number__c = TEST_DEALER_CIF_NUMBER;
		testDealerAccount.Coop_Type__c = 'CFA';
		insert testDealerAccount;

		Account testGrowerAccount = new Account();
		testGrowerAccount.Name = 'ExternalAPILoansTest-Test Grower';
		testGrowerAccount.Coop_Type__c = 'CFA';
		testGrowerAccount.ParentId = testDealerAccount.Id;
		testGrowerAccount.Unique_Id__c = ACCOUNT_UNIQUE_ID;
		insert testGrowerAccount;

		// Creating a test parent application
		genesis__Applications__c application = new genesis__Applications__c();
		application.genesis__Loan_Amount__c = 37000.00;
		application.Crop_Year__c = '2009';
		application.genesis__Status__c = 'ACTIVE';
		application.genesis__Loan_Number__c = '12343435';
		application.Note_Date__c = Date.today();
		application.genesis__Maturity_Date__c = Date.today().addMonths(6);
		application.genesis__Account__c = testGrowerAccount.Id;
		application.Dealer_Name__c = testDealerAccount.Id;
		insert application;

		clcommon__Party__c party = new clcommon__Party__c();
		party.clcommon__Account__c = testGrowerAccount.Id;
		party.genesis__Application__c = application.Id;
		clcommon__Party_Type__c borrowerPartyType = new clcommon__Party_Type__c();
		borrowerPartyType.Name = 'BORROWER';
		insert borrowerPartyType;
		party.clcommon__Type__c = borrowerPartyType.Id;
		insert party;
	}

	@IsTest
	static void getLoansPositive() {
		setupData();

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
		User testIntegrationUser = new User(
			  Alias = 'intT',
			  Email = TEST_USERNAME,
			  EmailEncodingKey = 'UTF-8',
			  LastName = 'Testing Integration User',
			  LanguageLocaleKey = 'en_US',
			  FederationIdentifier = TEST_USERNAME,
			  LocaleSidKey = 'en_US',
			  ProfileId = p.Id,
			  TimeZoneSidKey = 'America/Chicago',
			  Username = TEST_USERNAME,
			  IsActive = true
		);
		insert testIntegrationUser;

		Test.startTest();
		System.runAs(testIntegrationUser) {
//			Make a positive test
			ExternalAPILoans.accountUniqueID = ACCOUNT_UNIQUE_ID;
			ExternalAPILoans.cifNumber = TEST_DEALER_CIF_NUMBER;
			ExternalAPILoans.getLoans();
		}
		Test.stopTest();

		Assert.areEqual(1, ExternalAPILoans.outputApplications.size());
	}

	@IsTest
	static void getLoansWithoutAccountIdNegative() {
		setupData();

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
		User testIntegrationUser = new User(
			  Alias = 'intT',
			  Email = TEST_USERNAME,
			  EmailEncodingKey = 'UTF-8',
			  LastName = 'Testing Integration User',
			  LanguageLocaleKey = 'en_US',
			  FederationIdentifier = TEST_USERNAME,
			  LocaleSidKey = 'en_US',
			  ProfileId = p.Id,
			  TimeZoneSidKey = 'America/Chicago',
			  Username = TEST_USERNAME,
			  IsActive = true
		);
		insert testIntegrationUser;

		Test.startTest();
		System.runAs(testIntegrationUser) {
//			Make a negative test by not providing the accountUniqueID (simulating an absent GET parameter)
			ExternalAPILoans.cifNumber = TEST_DEALER_CIF_NUMBER;
			ExternalAPILoans.getLoans();
		}
		Test.stopTest();

		Assert.areEqual(0, ExternalAPILoans.outputApplications.size());
		Assert.areNotEqual(0, [SELECT Id FROM clcommon__Log__c].size());
	}

	@IsTest
	static void getLoansWithoutCifNegative() {
		setupData();

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
		User testIntegrationUser = new User(
			  Alias = 'intT',
			  Email = TEST_USERNAME,
			  EmailEncodingKey = 'UTF-8',
			  LastName = 'Testing Integration User',
			  LanguageLocaleKey = 'en_US',
			  FederationIdentifier = TEST_USERNAME,
			  LocaleSidKey = 'en_US',
			  ProfileId = p.Id,
			  TimeZoneSidKey = 'America/Chicago',
			  Username = TEST_USERNAME,
			  IsActive = true
		);
		insert testIntegrationUser;

		Test.startTest();
		System.runAs(testIntegrationUser) {
			ExternalAPILoans.accountUniqueID = ACCOUNT_UNIQUE_ID;
			ExternalAPILoans.getLoans();
		}
		Test.stopTest();

		Assert.areEqual(0, ExternalAPILoans.outputApplications.size());
		Assert.areNotEqual(0, [SELECT Id FROM clcommon__Log__c].size());
	}

}