/**
* @Description: This class is used to push transactions
 * @Author: Riadh Mankai
 * @Date: 2024-06-24
*/

@RestResource(UrlMapping = '/api/v1/external/saveTransaction')
global without sharing class ExternalAPITransactions {
	/**
		 * @description This method is used to push transaction
		 * @param transactionSourceId the external ID of the transaction coming from an external system
		 * @param loanNumber loan number of the child loan under which we are posting a transaction
		 * @param amount amount of the transaction
		 * @param purpose purpose of the transaction (text)
		 */
	@HttpPost
	global static void pushTransaction(
		  String transactionSourceId,
		  String loanNumber,
		  Decimal amount,
		  String purpose) {
		ExternalAPIUtilities.pushTransaction(transactionSourceId, loanNumber, amount, purpose, false);
	}
}