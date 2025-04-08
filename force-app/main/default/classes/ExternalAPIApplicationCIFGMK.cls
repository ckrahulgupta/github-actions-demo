/**
 * @description This class is used to expose the Growmark Loans API to the external world
 */
@RestResource(UrlMapping = '/growmarkLoans/*')
global without sharing class ExternalAPIApplicationCIFGMK {

	global final static String GROWMARK = 'Growmark';
	global static String CIF_NUMBER;

	/**
	 * @description This method returns a list of loans and their associated records a flat a structure. CIF number should
	 * be passed by parameter as the only HTTP GET parameter in the URL
	 * @return a list of loans and their associated records a flat a structure
	 */
	@HttpGet 
	global static List<ExternalAPIUtilities.LoanWrapper> getGMKLoansByCIFNumber() {
		RestRequest getRequest = RestContext.request;
		List<String> urlParams = new List<String>();
		if (String.isBlank(CIF_NUMBER)) {
			urlParams = getRequest.requestURI.split('/');
			CIF_NUMBER = urlParams != null && urlParams.size() >= 3 ? getRequest.requestURI.split('/')[2] : CIF_NUMBER;
		}
		ExternalAPIUtilities.LoanAPIReturnedResultWrapper loansWrappers = ExternalAPIUtilities.getLoansByCIFNumber(
			  CIF_NUMBER
		);
		return loansWrappers.LoansInFlatStructure;
	}

	/**
	 * @description This method is used to push transaction
	 * @param transactionSourceId the external ID of the transaction coming from an external system
	 * @param loanNumber loan number of the child loan under which we are posting a transaction
	 * @param amount amount of the transaction
	 * @param purpose purpose of the transaction (text)
	 */
	@HttpPost
	global static void pushGMKTransaction(
		  String transactionSourceId,
		  Long loanNumber,
		  Decimal amount,
		  String purpose
	) {
		String loanNumberStr = String.valueOf(loanNumber);
		ExternalAPIUtilities.pushTransaction(
			  transactionSourceId,
			  loanNumberStr,
			  amount,
			  purpose,
			  true
		);
	}
}