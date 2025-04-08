/**
 * Created by Riadh Mankai, July 17th 2023
 * Basic registration handler for Landus SSO
 */

global class LandusSSORegistrationHandler implements Auth.RegistrationHandler {
  global User createUser(Id portalId, Auth.UserData data) {
    System.debug(
      'User data from production - keep this for debugging purposes:'
    );
    System.debug(data);
    User userToReturn;
    try {
      Map<String, String> landusMap = data.attributeMap;
      String landusUsername = landusMap.get('preferred_username');
      List<User> currentUsers = [
        SELECT Id
        FROM User
        WHERE
          (FederationIdentifier = :landusUsername
          OR Username = :landusUsername)
          AND IsActive = TRUE
      ];
      List<Contact> currentContacts = [
        SELECT
          Id,
          Name,
          Email,
          AccountId,
          FirstName,
          LastName,
          MobilePhone,
          Phone
        FROM Contact
        WHERE
          Email = :landusUsername
          OR MobilePhone = :landusUsername
          OR Phone = :landusUsername
      ];

      //    if user not found, provision (create) the user on the fly
      if (currentUsers.isEmpty()) {
        String emailAddress = landusMap.get('email');
        String lastName = landusMap.get('family_name');
        String firstName = String.isNotBlank(landusMap.get('given_name'))
          ? landusMap.get('given_name')
          : '';
        String accountName = firstName + ' ' + lastName;
        clcommon__Legal_Entity__c legalEntity = getLegalEntity();
        Id recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Grower')
          .getRecordTypeId();
        Id growerProfileId = [
          SELECT Id
          FROM Profile
          WHERE Name = 'Grower'
          LIMIT 1
        ]
        .Id;
        List<genesis__Business_Information__c> businessInfoList = PortalUserRegisterAPI.createBusinessInfo();

        Pattern myPattern = Pattern.compile('[0-9]+');
        Matcher myMatcher = myPattern.matcher(landusUsername);
        String phoneNumber = myMatcher.matches() ? landusUsername : '';

        Map<String, String> accountInfoMap = new Map<String, String>{
          'fullName' => accountName,
          'legalEntity' => legalEntity.Id,
          'accEmail' => emailAddress,
          'accphoneNumber' => phoneNumber,
          'recordType' => recordTypeID
        };

        //				if we don't have an existing contact, create a new account + contact
        List<Account> userAccount = new List<Account>();
        List<Contact> userContact = new List<Contact>();
        if (currentContacts.isEmpty()) {
          userAccount = PortalUserRegisterAPI.createAccount(
            businessInfoList[0].Id,
            accountInfoMap
          );
          userAccount[0].OwnerId = PortalSecurityUtil.getSiteAdmin();
          userAccount[0].Coop_Type__c = 'Landus';
          update userAccount[0];

          Map<String, String> contactInfoMap = new Map<String, String>{
            'contFirstName' => firstName,
            'contLastName' => lastName,
            'contPhoneNumber' => phoneNumber,
            'contEmail' => emailAddress,
            'contSSN' => ''
          };
          userContact = PortalUserRegisterAPI.createContact(
            userAccount[0].Id,
            contactInfoMap
          );
        }
        //				if we do have an existing contact, use it
        else {
          userContact = currentContacts;
        }

        User newUserObj = new User(
          FirstName = userContact[0].FirstName,
          LastName = userContact[0].LastName,
          Email = userContact[0].Email,
          ContactId = userContact[0].Id,
          ProfileId = growerProfileId,
          FederationIdentifier = landusUsername,
          CommunityNickname = firstName.substring(0, 1) +
            lastName +
            ' ' +
            emailAddress,
          Alias = String.valueOf(
            firstName.substring(0, 1) + lastName.substring(0, 1)
          ),
          EmailEncodingKey = 'ISO-8859-1',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          TimeZoneSidKey = 'America/Los_Angeles',
          Username = emailAddress
        );
        insert newUserObj;
        userToReturn = newUserObj;
      } else {
        userToReturn = currentUsers[0];
      }
    } catch (Exception objException) {
      System.debug('Error logging:');
      System.debug(objException);
      Database.insert(
        new clcommon__Log__c(
          Name = 'LandusSSORegistrationHandler',
          clcommon__Message__c = 'LandusSSORegistrationHandler' +
            objException.getStackTraceString() +
            objException.getMessage(),
          clcommon__Time__c = System.now()
        ),
        false
      );
    }
    return userToReturn;
  }

  global void updateUser(Id userId, Id portalId, Auth.UserData data) {
    // Do nothing for now, no need to change this. This method gets called when the user used SSO at least once.
  }

  public static clcommon__Legal_Entity__c getLegalEntity() {
    List<clcommon__Legal_Entity__c> legalEntityType = new List<clcommon__Legal_Entity__c>();
    legalEntityType = [
      SELECT Id, Name
      FROM clcommon__Legal_Entity__c
      WHERE Name = 'Individual(s) - Sole Proprietorship'
    ];
    if (legalEntityType.size() == 0) {
      throw new CustomException('Individual Entity Type Does Not Exists');
    }
    return legalEntityType[0];
  }
}