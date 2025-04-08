/**
 * Created by riadhmankai on 11/7/23.
 */

@IsTest
public with sharing class GrowmarkSSORegistrationHandlerTest {
	final static String testAccountName = 'ACK';
	static final String testUsername = 'testRandom58907703@test.com';
	static final String expectedFederationID = 'test@test.test2001';
	static final String newFederationID = 'test@test.newValue2';
	static final String userEmail = 'standarduser@testorg.com';
	@TestSetup
	public static void createGMKTestUser() {
//		Create test account
		Account objAccount = new Account();
		objAccount.Name = testAccountName;
		objAccount.CIF_Number__c = '132324';
		objAccount.Coop_Type__c = ExternalAPIApplicationCIFGMK.GROWMARK;
		objAccount.clcommon__Email__c = userEmail;
		insert objAccount;

//		create test contact
		Contact objContact = new Contact();
		objContact.FirstName = 'testGMKRegHandlerFirstName';
		objContact.LastName = 'testGMKRegHandlerLastName';
		objContact.Email = expectedFederationID;
		objContact.AccountId = objAccount.Id;
		insert objContact;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Growmark Grower'];
		User testUser = new User(
			  Alias = 'standt',
			  Email = userEmail,
			  EmailEncodingKey = 'UTF-8',
			  LastName = 'Testing',
			  LanguageLocaleKey = 'en_US',
			  FederationIdentifier = expectedFederationID,
			  LocaleSidKey = 'en_US',
			  ProfileId = p.Id,
			  TimeZoneSidKey = 'America/Chicago',
			  Username = testUsername,
			  IsActive = true,
			  ContactId = objContact.Id
		);
		insert testUser;
		clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c(Name = 'Individual(s) - Sole Proprietorship');
		insert legalEntity;
		CFA_Configuration__c cifConfig = new CFA_Configuration__c(CIF_Number__c = '360321');
		insert cifConfig;
	}
	@IsTest
	public static void testExistingUserGMK() {
		User testUser = [
			  SELECT Id, Name
			  FROM User
			  WHERE Username = :testUsername
			  LIMIT 1
		];
		Auth.UserData sampleData = new Auth.UserData(
			  'testId',
			  'testFirst',
			  'testLast',
			  'testFirst testLast',
			  expectedFederationID,
			  null,
			  expectedFederationID,
			  'en_US',
			  'facebook',
			  null,
			  new Map<String, String> {
					'username' => expectedFederationID
			  }
		);

		Test.startTest();
		GrowmarkSSORegistrationHandler growmarkRegHandler = new GrowmarkSSORegistrationHandler();
		User u = growmarkRegHandler.createUser(null, sampleData);
		growmarkRegHandler.updateUser(null, null, sampleData);
		Test.stopTest();

		System.assertEquals(testUser.Id, u.Id);
		Assert.areEqual(1, [SELECT Id FROM User WHERE FederationIdentifier = :expectedFederationID OR FederationIdentifier = :newFederationID].size());
		Assert.areEqual(1, [SELECT Id FROM Contact].size());
		Assert.areEqual(1, [SELECT Id FROM Account].size());
		System.Assert.areEqual(0, [SELECT Id FROM clcommon__Log__c].size());
	}

	@IsTest
	public static void testNewUserGMK() {
		User testUser = [
			  SELECT Id, Name, FederationIdentifier
			  FROM User
			  WHERE Username = :testUsername
			  LIMIT 1
		];
		Auth.UserData sampleData = new Auth.UserData(
			  'testId',
			  'testFirst',
			  'testLast',
			  'testFirst testLast',
			  newFederationID,
			  null,
			  newFederationID,
			  'en_US',
			  'facebook',
			  null,
			  new Map<String, String> {
					'username' => newFederationID
			  }
		);

		Test.startTest();
		GrowmarkSSORegistrationHandler growmarkRegHandler = new GrowmarkSSORegistrationHandler();
		User u = growmarkRegHandler.createUser(null, sampleData);
		Test.stopTest();
		System.Assert.areNotEqual(testUser.Id, u.Id);
		User newUser = [
			  SELECT Id, FederationIdentifier, ContactId, AccountId
			  FROM User
			  WHERE FederationIdentifier = :newFederationID
			  LIMIT 1
		];
		System.Assert.areEqual(newFederationID, newUser.FederationIdentifier);
		Assert.areEqual(2, [SELECT Id FROM User WHERE FederationIdentifier = :expectedFederationID OR FederationIdentifier = :newFederationID].size());
		Assert.areEqual(2, [SELECT Id FROM Contact].size());
		Assert.areEqual(2, [SELECT Id FROM Account].size());
		System.Assert.areEqual(0, [SELECT Id FROM clcommon__Log__c].size());
	}

	@IsTest
	public static void testWithExistingContactGMK() {
		User testUser = [
			  SELECT Id, Name, FederationIdentifier
			  FROM User
			  WHERE Username = :testUsername
			  LIMIT 1
		];
		clcommon__Legal_Entity__c legalEntity = LandusSSORegistrationHandler.getLegalEntity();
		List<genesis__Business_Information__c> businessInfoList = PortalUserRegisterAPI.createBusinessInfo();
		Id recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
		Map<String, String> accountInfoMap = new Map<String, String> {
			  'fullName' => 'Test Account890',
			  'legalEntity' => legalEntity.Id,
			  'accEmail' => userEmail,
			  'accphoneNumber' => '1789852233',
			  'recordType' => recordTypeID
		};
		List<Account> userAccount = PortalUserRegisterAPI.createAccount(
			  businessInfoList[0].Id,
			  accountInfoMap
		);
		userAccount[0].OwnerId = PortalSecurityUtil.getSiteAdmin();
		userAccount[0].Coop_Type__c = 'Growmark';
		update userAccount[0];
		Map<String, String> contactInfoMap = new Map<String, String> {
			  'contFirstName' => 'test firstname',
			  'contLastName' => 'Account890',
			  'contPhoneNumber' => '1789852233',
			  'contEmail' => newFederationID,
			  'contSSN' => ''
		};
		List<Contact> userContact = PortalUserRegisterAPI.createContact(
			  userAccount[0].Id,
			  contactInfoMap
		);

		Auth.UserData sampleData = new Auth.UserData(
			  'testId',
			  'testFirst',
			  'testLast',
			  'testFirst testLast',
			  newFederationID,
			  null,
			  newFederationID,
			  'en_US',
			  'facebook',
			  null,
			  new Map<String, String> {
					'username' => newFederationID
			  }
		);

		Test.startTest();
		GrowmarkSSORegistrationHandler growmarkRegHandler = new GrowmarkSSORegistrationHandler();
		User u = growmarkRegHandler.createUser(null, sampleData);
		Test.stopTest();

		System.Assert.areNotEqual(testUser.Id, u.Id);
		User newUser = [
			  SELECT Id, FederationIdentifier, ContactId, AccountId
			  FROM User
			  WHERE FederationIdentifier = :newFederationID
			  LIMIT 1
		];
		System.Assert.areEqual(newFederationID, newUser.FederationIdentifier);
		System.Assert.areEqual(userContact[0].Id, newUser.ContactId);
		System.Assert.areEqual(userAccount[0].Id, newUser.AccountId);
		Assert.areEqual(2, [SELECT Id FROM User WHERE FederationIdentifier = :expectedFederationID OR FederationIdentifier = :newFederationID].size());
		Assert.areEqual(2, [SELECT Id FROM Contact].size());
		Assert.areEqual(2, [SELECT Id FROM Account].size());
		System.Assert.areEqual(0, [SELECT Id FROM clcommon__Log__c].size());
	}
}