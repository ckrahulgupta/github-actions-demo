@IsTest
public class LandusSSORegistrationHandlerTest {
  static final String testUsername = 'testRandom58907702@test.com';
  static final String expectedFederationID = 'test@test.test';
  static final String newFederationID = 'test@test.newValue';
  static final String userEmail = 'standarduser@testorg.com';
  @TestSetup
  public static void createTestUser() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User testUser = new User(
      Alias = 'standt',
      Email = userEmail,
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      FederationIdentifier = expectedFederationID,
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Username = testUsername
    );
    insert testUser;
    clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c(
      Name = 'Individual(s) - Sole Proprietorship'
    );
    insert legalEntity;
    CFA_Configuration__c cifConfig = new CFA_Configuration__c(
      CIF_Number__c = '360321'
    );
    insert cifConfig;
  }
  @IsTest
  public static void testExistingUser() {
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
      new Map<String, String>{ 'preferred_username' => expectedFederationID }
    );

    Test.startTest();
    LandusSSORegistrationHandler landusRegHanlder = new LandusSSORegistrationHandler();
    User u = landusRegHanlder.createUser(null, sampleData);
    landusRegHanlder.updateUser(null, null, sampleData);
    Test.stopTest();

    System.assertEquals(testUser.Id, u.Id);
  }

  @IsTest
  public static void testNewUser() {
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
      'testuserlong',
      'en_US',
      'facebook',
      null,
      new Map<String, String>{
        'preferred_username' => newFederationID,
        'given_name' => 'test firstname',
        'family_name' => 'test lastname',
        'email' => 'testemail@test.test'
      }
    );

    Test.startTest();
    LandusSSORegistrationHandler landusRegHanlder = new LandusSSORegistrationHandler();
    User u = landusRegHanlder.createUser(null, sampleData);
    Test.stopTest();

    System.Assert.areNotEqual(testUser.Id, u.Id);
    User newUser = [
      SELECT Id, FederationIdentifier, ContactId, AccountId
      FROM User
      WHERE FederationIdentifier = :newFederationID
      LIMIT 1
    ];
    System.Assert.areEqual(newFederationID, newUser.FederationIdentifier);
    System.Assert.isNotNull(newUser.ContactId);
    System.Assert.isNotNull(newUser.AccountId);
    System.Assert.areEqual(0, [SELECT Id FROM clcommon__Log__c].size());
  }

  @IsTest
  public static void testWithExistingContact() {
    User testUser = [
      SELECT Id, Name, FederationIdentifier
      FROM User
      WHERE Username = :testUsername
      LIMIT 1
    ];

    clcommon__Legal_Entity__c legalEntity = LandusSSORegistrationHandler.getLegalEntity();
    List<genesis__Business_Information__c> businessInfoList = PortalUserRegisterAPI.createBusinessInfo();
    Id recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Grower')
      .getRecordTypeId();
    Map<String, String> accountInfoMap = new Map<String, String>{
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
    userAccount[0].Coop_Type__c = 'Landus';
    update userAccount[0];
    Map<String, String> contactInfoMap = new Map<String, String>{
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
      expectedFederationID,
      null,
      'testuserlong',
      'en_US',
      'facebook',
      null,
      new Map<String, String>{
        'preferred_username' => newFederationID,
        'given_name' => 'test firstname',
        'family_name' => 'test lastname',
        'email' => userEmail
      }
    );

    Test.startTest();
    LandusSSORegistrationHandler landusRegHanlder = new LandusSSORegistrationHandler();
    User u = landusRegHanlder.createUser(null, sampleData);
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
    System.Assert.areEqual(0, [SELECT Id FROM clcommon__Log__c].size());
  }
}