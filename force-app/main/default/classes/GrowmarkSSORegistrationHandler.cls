/**
 * Created by riadhmankai on 10/19/23.
 * Last modified by riadhmankai on 11/07/23
 */

global with sharing class GrowmarkSSORegistrationHandler implements Auth.RegistrationHandler {
	global static final String GROWER = 'Grower';
	global static final String GROWMARK = 'Growmark';
	global static final String GROWMARK_GROWER = 'Growmark Grower';

	global User createUser(Id portalId, Auth.UserData data) {
		System.debug('RegistrationHandler createUser data from production - keep this for debugging purposes:');
		System.debug(data);
		User userToReturn;
		try {
			Map<String, String> growmarkMap = data.attributeMap;
			String growmarkEmail = data.email;
			String firstName = data.email; // init
			if (String.isNotBlank(growmarkMap.get('given_name'))) {
				firstName = growmarkMap.get('given_name');
			} else if (String.isNotBlank(data.firstName)) {
				firstName = data.firstName;
			}
			String lastName = data.email; // init
			if (String.isNotBlank(growmarkMap.get('family_name'))) {
				lastName = growmarkMap.get('family_name');
			} else if (String.isNotBlank(data.lastName)) {
				lastName = data.lastName;
			}
			String fullName = String.isNotBlank(data.fullName) ? data.fullName : firstName + ' ' + lastName;
			Id gmkPermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :GROWMARK LIMIT 1].Id;
			List<User> currentUsers = [
				  SELECT Id
				  FROM User
				  WHERE (FederationIdentifier = :growmarkEmail OR Username = :growmarkEmail)
				  AND IsActive = TRUE
				  AND Coop_Type__c = :GROWMARK
			];
			List<Contact> currentContacts = [
				  SELECT Id, Name, Email, AccountId, FirstName, LastName, MobilePhone, Phone
				  FROM Contact
				  WHERE Email = :growmarkEmail
				  AND Coop_Type__c = :GROWMARK
			];

			// if user not found, provision (create) the user on the fly
			if (currentUsers.isEmpty()) {
				String accountName = fullName;
				clcommon__Legal_Entity__c legalEntity = LandusSSORegistrationHandler.getLegalEntity();
				Id recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GROWER).getRecordTypeId();
				Id growerProfileId = [SELECT Id FROM Profile WHERE Name = :GROWMARK_GROWER LIMIT 1].Id;
				List<genesis__Business_Information__c> businessInfoList = PortalUserRegisterAPI.createBusinessInfo();

				Map<String, String> accountInfoMap = new Map<String, String> {
					  'fullName' => accountName,
					  'legalEntity' => legalEntity.Id,
					  'accEmail' => growmarkEmail,
					  'accphoneNumber' => 'N/A',
					  'recordType' => recordTypeID
				};

				//	if we don't have an existing contact, create a new account + contact
				List<Account> userAccount = new List<Account>();
				List<Contact> userContact = new List<Contact>();
				if (currentContacts.isEmpty()) {
					userAccount = PortalUserRegisterAPI.createAccount(
						  businessInfoList[0].Id,
						  accountInfoMap
					);
					userAccount[0].OwnerId = PortalSecurityUtil.getSiteAdmin();
					userAccount[0].Coop_Type__c = GROWMARK;
					update userAccount[0];

					Map<String, String> contactInfoMap = new Map<String, String> {
						  'contFirstName' => firstName,
						  'contLastName' => lastName,
						  'contPhoneNumber' => 'N/A',
						  'contEmail' => growmarkEmail,
						  'contSSN' => ''
					};
					userContact = PortalUserRegisterAPI.createContact(
						  userAccount[0].Id,
						  contactInfoMap
					);
				}
				//	if we do have an existing contact, use it
				else {
					userContact = currentContacts;
				}

				User newUserObj = new User(
					  FirstName = userContact[0].FirstName,
					  LastName = userContact[0].LastName,
					  Email = userContact[0].Email,
					  ContactId = userContact[0].Id,
					  ProfileId = growerProfileId,
					  FederationIdentifier = growmarkEmail,
					  CommunityNickname = (firstName.substring(0, 1) + lastName + ' ' + growmarkEmail).abbreviate(40),
					  Alias = String.valueOf(firstName.substring(0, 1) + lastName.substring(0, 1)),
					  EmailEncodingKey = 'ISO-8859-1',
					  LanguageLocaleKey = 'en_US',
					  LocaleSidKey = 'en_US',
					  TimeZoneSidKey = 'America/Chicago',
					  Username = growmarkEmail
				);
				insert newUserObj;
				userToReturn = newUserObj;
//				Add Growmark permission assignment to assign the "Growmark" permission set to the new user
				insertGrowmarkPermissionSetFuture(gmkPermissionSetId, userToReturn.Id);
			} else {
				userToReturn = currentUsers[0];
			}
		} catch (Exception objException) {
			System.debug('RegistrationHandler createUser Error logging:');
			System.debug(objException);
			Database.insert(
				  new clcommon__Log__c(
						Name = 'growmarkSSORegistrationHandler',
						clcommon__Message__c = 'growmarkSSORegistrationHandler' +
							  objException.getStackTraceString() +
							  objException.getMessage(),
						clcommon__Time__c = System.now()
				  ),
				  false
			);
			throw new CustomException('growmarkSSORegistrationHandler' + objException.getStackTraceString() + objException.getMessage());
		}
		return userToReturn;
	}

	global void updateUser(Id userId, Id portalId, Auth.UserData data) {
		System.debug('RegistrationHandler updateUser data from production - keep this for debugging purposes:');
		System.debug(data);
		// Do nothing for now, no need to change this. This method gets called when the user used SSO at least once (when that SSO binding is user the user record page)
	}

	@Future
	global static void insertGrowmarkPermissionSetFuture(Id gmkPermissionSetId, Id userToReturnId) {
		PermissionSetAssignment psa = new PermissionSetAssignment(
			  PermissionSetId = gmkPermissionSetId,
			  AssigneeId = userToReturnId
		);
		insert psa;
	}
}