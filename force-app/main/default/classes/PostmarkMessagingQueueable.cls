/**
 * @author Riadh Mankai
 * @last modified on 6/6/24
 * @last modified by Riadh Mankai
 * @description Queueable for sending emails using the Postmark API service delivery provider asynchronously
 */
public without sharing class PostmarkMessagingQueueable implements Queueable, Database.AllowsCallouts {
	private final String payloadListJSON;
	private final String endpoint;

	/**
	 * Constructor
	 * @param payloadListJSON	String JSON representation of the list of emails to send
	 * @param endpoint			String The Postmark API endpoint to send the emails to
	 */
	public PostmarkMessagingQueueable(String payloadListJSON, String endpoint) {
		this.payloadListJSON = payloadListJSON;
		this.endpoint = endpoint;
	}

	/**
	 * Execute the Postmark API callout
	 * @param context	QueueableContext The context in which the queueable is executed
	 */
	public void execute(QueueableContext context) {
		PostmarkMessaging.sendEmailToPostmark(this.payloadListJSON, this.endpoint);
	}
}