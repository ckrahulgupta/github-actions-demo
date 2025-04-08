/**
 * @author Riadh Mankai
 * @last modified on 5/24/24
 * @last modified by Riadh Mankai
 * @description Test class for PostmarkMessaging
 */
@IsTest
private class PostmarkMessagingTest {
	/**
	 * Mock class for the Postmark API callout
	 */
	public class PostmarkHttpCalloutMock implements HttpCalloutMock {
		private final Boolean isSuccess;
		public PostmarkHttpCalloutMock(Boolean isSuccess) {
			this.isSuccess = isSuccess;
		}
		public HttpResponse respond(HttpRequest req) {
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			if (this.isSuccess) {
				res.setBody('{"message": "OK"}');
				res.setStatusCode(200);
			} else {
				res.setBody('{"message": "Error"}');
				res.setStatusCode(400);
			}
			return res;
		}
	}

	/**
	 * Test the constructor
	 */
	@IsTest
	static void unitTestConstructor() {
		OrgWideEmailAddress senderAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];
		EmailTemplate eomEmailTemplate = CFAOriginationHelperClass.getEmailTemplate(ConstantValues.EOM_EMAIL_TO_CFA_GROWER);
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(new String[] {
			  'rmankai@cfafs.com'
		});
		email.setSubject('Test tooling');
		String emailBody = eomEmailTemplate.HtmlValue;
		email.setHtmlBody(emailBody);
		email.setOrgWideEmailAddressId(senderAddress.Id);
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
			  email
		};

		Test.startTest();
		PostmarkMessaging myMessaging = new PostmarkMessaging(emails, false);
		Test.stopTest();

		Assert.isNotNull(myMessaging, 'Constructor should not be null');
		Assert.isNotNull(myMessaging.emailsToSend, 'Emails to send should not be null');
	}

	/**
	 * Test the constructor with an error where the passed emails lack important parameters like the html body
	 */
	@IsTest
	static void unitTestConstructorWithError() {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject('Test tooling');
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
			  email
		};

		Test.startTest();
		new PostmarkMessaging(emails, true);
		Test.stopTest();

		List<clcommon__Log__c> errorLogs = [SELECT Id, Name FROM clcommon__Log__c WHERE Name = 'PostmarkMessaging class error in constructor'];
		Assert.areEqual(1, errorLogs.size(), '1 error Log should be created');
	}

	/**
	 * Test the sendEmails method with success
	 */
	@IsTest
	static void unitTestSendEmail() {
		OrgWideEmailAddress senderAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];
		EmailTemplate eomEmailTemplate = CFAOriginationHelperClass.getEmailTemplate(ConstantValues.EOM_EMAIL_TO_CFA_GROWER);
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(new String[] {
			  'rmankai@cfafs.com'
		});
		email.setSubject('Test tooling');
		String emailBody = eomEmailTemplate.HtmlValue;
		email.setHtmlBody(emailBody);
		email.setOrgWideEmailAddressId(senderAddress.Id);
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
			  email
		};
		PostmarkMessaging myMessaging = new PostmarkMessaging(emails, false);

		// Set the mock callout class
		Test.setMock(HttpCalloutMock.class, new PostmarkHttpCalloutMock(true));

		Test.startTest();
		myMessaging.sendEmails();
		Test.stopTest();

		Assert.areEqual(0, [SELECT Id FROM clcommon__Log__c WHERE Name LIKE 'PostmarkMessaging%'].size(), 'No error Log should be created');
	}

	/**
	 * Test the sendEmails method with an error, by setting the mock callout class to return an error
	 */
	@IsTest
	static void unitTestSendEmailWithError() {
		OrgWideEmailAddress senderAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];
		EmailTemplate eomEmailTemplate = CFAOriginationHelperClass.getEmailTemplate(ConstantValues.EOM_EMAIL_TO_CFA_GROWER);
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(new String[] {
			  'rmankai@cfafs.com'
		});
		email.setSubject('Test tooling');
		String emailBody = eomEmailTemplate.HtmlValue;
		email.setHtmlBody(emailBody);
		email.setOrgWideEmailAddressId(senderAddress.Id);
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
			  email
		};
		PostmarkMessaging myMessaging = new PostmarkMessaging(emails, true);

		// Set the mock callout class and mock the API to return an error code (for example 400)
		Test.setMock(HttpCalloutMock.class, new PostmarkHttpCalloutMock(false));

		Test.startTest();
		myMessaging.sendEmails();
		Test.stopTest();

		Assert.areEqual(1, [SELECT Id FROM clcommon__Log__c WHERE Name LIKE 'PostmarkMessaging%'].size(), 'An error Log should be created');
	}

	@IsTest
	static void unitTestSendEmailAsync() {
		OrgWideEmailAddress senderAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];
		EmailTemplate eomEmailTemplate = CFAOriginationHelperClass.getEmailTemplate(ConstantValues.EOM_EMAIL_TO_CFA_GROWER);
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(new String[] {
			  'rmankai@cfafs.com'
		});
		email.setSubject('Test tooling');
		String emailBody = eomEmailTemplate.HtmlValue;
		email.setHtmlBody(emailBody);
		email.setOrgWideEmailAddressId(senderAddress.Id);
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
			  email
		};
		PostmarkMessaging myMessaging = new PostmarkMessaging(emails, false);

		// Set the mock callout class
		Test.setMock(HttpCalloutMock.class, new PostmarkHttpCalloutMock(true));

		Test.startTest();
		myMessaging.sendEmailsAsync();
		Test.stopTest();

		Assert.areEqual(0, [SELECT Id FROM clcommon__Log__c WHERE Name LIKE 'PostmarkMessaging%'].size(), 'No error Log should be created');
	}

}