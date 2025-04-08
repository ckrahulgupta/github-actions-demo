/**
* @Description: This class is used to void transactions (advances)
 * @Author: Riadh Mankai
 * @Date: 2024-11-04
*/
@RestResource(UrlMapping = '/api/v1/external/voidTransaction')
global without sharing class ExternalAPITransactionVoiding {
	public static RestResponse response = RestContext.response;
	/**
	 * @description This method is used to push transaction
	 * @param transactionSourceId the external ID of the transaction coming from an external system
	 * @param loanNumber loan number of the child loan under which we are posting a transaction
	 */
	@HttpPost
	global static void voidTransaction(String transactionSourceId, String loanNumber) {
		try {
			List<genesis__Funding_Transaction__c> matchingTransactions = ExternalAPIUtilities.getMatchingTransactions(transactionSourceId);
			List<genesis__Application_Pricing_Detail__c> objPricingDetails = ExternalAPIUtilities.getPricingDetailsFromLoanNumber(loanNumber);
			if (objPricingDetails.isEmpty()) {
				throw new CustomException(ExternalAPIUtilities.LOAN_NOT_FOUND);
			}
			genesis__Application_Pricing_Detail__c objPricingDetail = objPricingDetails[0];
			if (!ExternalAPIUtilities.isValidUser(objPricingDetail)) {
				throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
			}
			ExternalAPIUtilities.voidTransaction(matchingTransactions);
			response.statusCode = 200;
			response.responseBody = Blob.valueOf(ExternalAPIUtilities.SUCCESS_VOIDING);
		} catch (Exception objException) {
			if (!Test.isRunningTest()) {
				response.statusCode = 400;
				response.responseBody = Blob.valueOf(
					  ExternalAPIUtilities.BAD_REQUEST + '; ' + objException.getMessage()
				);
			}
			Database.insert(
				  new clcommon__Log__c(
						Name = ExternalAPIUtilities.CLASS_NAME,
						clcommon__Message__c = ExternalAPIUtilities.CLASS_NAME +
							  objException.getStackTraceString() +
							  objException.getMessage(),
						clcommon__Time__c = Datetime.now()
				  ),
				  false
			);
		}
	}
}