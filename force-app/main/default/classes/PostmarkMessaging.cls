/**
 * Created by Riadh Mankai on 5/22/24.
 * This class is responsible for sending emails using the Postmark API service delivery provider.
 */

public without sharing class PostmarkMessaging {
//	static variables
	public static final Map<Id, OrgWideEmailAddress> orgWideEmailAddressesMap;
	public static final String defaultOrgWideEmailAddress = 'noreply@myfieldfinance.com';
	public static final String HTTP_METHOD = 'POST';
	public static final String BROADCAST_MESSAGE_STREAM = 'broadcast';
	public static final String OUTBOUND_MESSAGE_STREAM = 'outbound';
	static {
		List<OrgWideEmailAddress> addresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress LIMIT 200];
		if (!addresses.isEmpty()) {
			orgWideEmailAddressesMap = new Map<Id, OrgWideEmailAddress>(addresses);
		} else {
			orgWideEmailAddressesMap = new Map<Id, OrgWideEmailAddress>();
		}
	}
	private static final String NAMED_CREDENTIAL_Name = 'Postmark_Named_Credential';
	private static final String BATCH_EMAIL_ENDPOINT = '/email/batch';
	private static final String SINGLE_EMAIL_ENDPOINT = '/email';

//	non static variables
	private final String payloadJSON;
	@TestVisible private final List<Messaging.SingleEmailMessage> emailsToSend;
	private final List<Map<String, Object>> payloadList = new List<Map<String, Object>>();
	private final String messageStream;
	private final String endpoint;

	/**
	 * Constructor - send emails to a list of receivers
	 * @param emailsToSend	List<Messaging.SingleEmailMessage> List of emails to send
	 */
	public PostmarkMessaging(List<Messaging.SingleEmailMessage> emailsToSend, Boolean isBroadcast) {
		try {
			this.emailsToSend = emailsToSend;
			this.messageStream = isBroadcast ? PostmarkMessaging.BROADCAST_MESSAGE_STREAM : PostmarkMessaging.OUTBOUND_MESSAGE_STREAM;
			for (Messaging.SingleEmailMessage eachSfEmail : this.emailsToSend) {
				Map<String, Object> payloadMap = new Map<String, Object>();
				payloadMap.put('From', orgWideEmailAddressesMap.containsKey(eachSfEmail.getOrgWideEmailAddressId())
					  ? orgWideEmailAddressesMap.get(eachSfEmail.getOrgWideEmailAddressId()).Address
					  : defaultOrgWideEmailAddress);
				payloadMap.put('To', eachSfEmail.getToAddresses()[0]);
				payloadMap.put('Subject', eachSfEmail.getSubject());
				payloadMap.put('HtmlBody', eachSfEmail.getHtmlBody());
				payloadMap.put('MessageStream', this.messageStream);
				this.payloadList.add(payloadMap);
			}
			if (this.emailsToSend.size() == 1) {
				this.endpoint = 'callout:' + PostmarkMessaging.NAMED_CREDENTIAL_Name + PostmarkMessaging.SINGLE_EMAIL_ENDPOINT;
				this.payloadJSON = JSON.serialize(this.payloadList[0]);
			} else if (this.emailsToSend.size() > 1) {
				this.endpoint = 'callout:' + PostmarkMessaging.NAMED_CREDENTIAL_Name + PostmarkMessaging.BATCH_EMAIL_ENDPOINT;
				this.payloadJSON = JSON.serialize(this.payloadList);
			}
		} catch (Exception objException) {
			System.debug('PostmarkMessaging error in the constructor');
			System.debug(objException);
			insert new clcommon__Log__c(
				  Name = 'PostmarkMessaging class error in constructor',
				  clcommon__Message__c = 'PostmarkMessaging error in the constructor' +
						objException.getStackTraceString() +
						objException.getMessage(),
				  clcommon__Time__c = System.now()
			);
		}
	}

	/**
	 * Send the emails to the Postmark API
	 * @param payloadJSON	String JSON representation of the email to send
	 * @param endpoint		String The Postmark API endpoint to send the email to
	 */
	public static void sendEmailToPostmark(String payloadJSON, String endpoint) {
		try {
			HttpRequest postmarkRequest = new HttpRequest();
			postmarkRequest.setTimeout(120000);
			postmarkRequest.setMethod(PostmarkMessaging.HTTP_METHOD);
			postmarkRequest.setBody(payloadJSON);
			postmarkRequest.setEndpoint(endpoint);
			HttpResponse postmarkHttpSend = new Http().send(postmarkRequest);
			System.debug('riri PostmarkMessaging apiResultBodyPost = ' + postmarkHttpSend.getBody());
			if (postmarkHttpSend.getStatusCode() != 200) {
				throw new CustomException('PostmarkMessaging - the Postmark endpoint return the following error' + postmarkHttpSend.getBody());
			}
		} catch (Exception objException) {
			System.debug('PostmarkMessaging error in the sendEmailToPostmark() Method');
			System.debug(objException);
			insert new clcommon__Log__c(
				  Name = 'PostmarkMessaging error in send method',
				  clcommon__Message__c = 'PostmarkMessaging error in the sendEmailToPostmark() Method' +
						objException.getStackTraceString() +
						objException.getMessage(),
				  clcommon__Time__c = System.now()
			);
		}
	}

	/**
	 * Send the emails synchronously
	 */
	public void sendEmails() {
		PostmarkMessaging.sendEmailToPostmark(this.payloadJSON, this.endpoint);
	}

	/**
	 * Send the emails asynchronously via a Apex Queueable
	 */
	public void sendEmailsAsync() {
		Id QueueableJobId = System.enqueueJob(new PostmarkMessagingQueueable(this.payloadJSON, this.endpoint));
		System.debug('riri QueueableJobId = ' + QueueableJobId);
	}
}