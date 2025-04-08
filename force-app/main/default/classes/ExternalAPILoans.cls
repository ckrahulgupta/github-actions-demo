/**
 * @description This class is used to call the external API to get the loans information
 * @author Riadh Mankai
*/
@RestResource(UrlMapping = '/api/v1/external/getLoans/*')
global without sharing class ExternalAPILoans {
	global final static String CLASS_NAME = 'ExternalAPILoans';
	global final static String NO_LOANS_FOUND = 'No loans found for the given grower';
	global final static String NOT_AUTHORIZED = 'User (dealer) is not authorized to access this API';
	global final static String NO_ACCOUNT_ID_PARAMETER = 'user_id (account_unique_Id) is required and must be passed as a URL parameter for this GET request';

	global static String accountUniqueID;
	global static String cifNumber;

	private static String errorMessage;
	@TestVisible private static List<genesis__Applications__c> outputApplications = new List<genesis__Applications__c>();

	/**
	 * @description This method returns a list of loans and their associated records a flat a structure. CIF number should
	 * be passed by parameter as the only HTTP GET parameter in the URL
	 */
	@HttpGet
	global static void getLoans() {
		RestResponse response = RestContext.response;
		RestRequest getRequest = RestContext.request;
		List<clcommon__Party__c> parties = new List<clcommon__Party__c>();
		List<Id> applicationIDs = new List<Id>();
		try {
			if (String.isBlank(accountUniqueID)) {
				accountUniqueID = getRequest.requestURI.remove('/api/v1/external/getLoans').remove('/');
				if (String.isBlank(accountUniqueID)) {
					throw new CustomException(NO_ACCOUNT_ID_PARAMETER);
				}
			}

			User currentUser = [
				  SELECT Id, Name, ProfileId, Profile.Name, AccountId, Username
				  FROM User
				  WHERE Id = :UserInfo.getUserId()
				  LIMIT 1
			];
			List<External_User_Dealer_Info__mdt> externalUserDealerInfos = [
				  SELECT Id, Dealer_CIF__c, External_User_Username__c, Is_Active__c
				  FROM External_User_Dealer_Info__mdt
				  WHERE Is_Active__c = TRUE
				  AND External_User_Username__c = :currentUser.Username
			];
			if (String.isBlank(cifNumber)) {
				if (externalUserDealerInfos.size() == 0) {
					throw new CustomException(NOT_AUTHORIZED);
				} else {
					cifNumber = externalUserDealerInfos[0].Dealer_CIF__c;
				}
			}

			parties = [
				  SELECT Id, genesis__Application__c
				  FROM clcommon__Party__c
				  // Dealer CIF number must match current user (dealer) CIF number
				  WHERE genesis__Application__r.Dealer_Name__r.CIF_Number__c = :cifNumber
				  // The account ID must match the account ID passed by parameter in the GET HTTP request
				  AND clcommon__Account__r.Unique_Id__c = :accountUniqueID
				  ORDER BY SystemModstamp DESC
			];

			for (clcommon__Party__c objParty : parties) {
				applicationIDs.add(objParty.genesis__Application__c);
			}

			if (applicationIDs.size() == 0) {
				throw new CustomException(NO_LOANS_FOUND);
			}

			outputApplications = [
				  SELECT
						Id,
						Available__c,
						Name,
						Crop_Year__c,
						Dealer_Name__r.CIF_Number__c,
						genesis__Maturity_Date__c,
						genesis__Loan_Amount__c,
						Reserved_Amount__c,
						genesis__Loan_Number__c,
						genesis__Status__c,
						Current_Principal_Balance__c,
						Current_Interest_Balance__c,
						Interest_Per_Diem__c,
						Note_Date__c,
						Guarantee__c,
						genesis__Interest_Rate__c,
						genesis__Interest_Rate_Type__c,
						Peak_Loan_Volume__c,
						genesis__Description__c,
						Interest_Accrued_Thru_Date__c,
						Dealer_Interest_Accrued__c,
						genesis__Account__r.CIF_Number__c,
						genesis__Account__r.Unique_Id__c,
						genesis__Account__r.Name,
						genesis__Account__r.Coop_Type__c,
						(
							  SELECT
									Id,
									genesis__Application__c,
									Name,
									Maturity_Date__c,
									genesis__Residual_Amount__c,
									Loan_Number__c,
									Growmark_Loan_Number__c,
									Principal_Advanced__c,
									genesis__Application__r.genesis__Account__r.Name,
									genesis__Application__r.genesis__Status__c,
									Interest_Per_Diem__c,
									genesis__Interest_Rate__c,
									genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c,
									genesis__Rate_Card_Setup_Detail__r.Description__c,
									genesis__Total_Interest__c,
									genesis__Application__r.Crop_Year__c,
									genesis__Application__r.Note_Date__c,
									genesis__Application__r.Guarantee__c,
									genesis__Application__r.genesis__Loan_Amount__c,
									genesis__Application__r.Reserved_Amount__c,
									Interest_Accrued_Thru_Date__c,
									Dealer_Interest_Accrued__c,
									Accrued_Interest__c
							  FROM genesis__Pricing_Details__r
							  WHERE genesis__Enabled_Flag__c = TRUE
						),
						(
							  SELECT
									Id,
									genesis__Amount__c,
									genesis__Application__c,
									Is_Growmark_Product_Return__c
							  FROM genesis__Funding_Transactions__r
							  WHERE Pricing_Detail__r.genesis__Enabled_Flag__c = TRUE
						)
				  FROM genesis__Applications__c
				  WHERE Id IN :applicationIDs
				  ORDER BY SystemModstamp DESC
			];
			if (!Test.isRunningTest()) {
				response.statusCode = 200;
				response.responseBody = Blob.valueOf(JSON.serialize(outputApplications));
			}
		} catch (Exception objException) {
			if (!Test.isRunningTest()) {
				response.statusCode = 500;
				response.responseBody = Blob.valueOf(objException.getMessage());
			}
			errorMessage = objException.getStackTraceString() + ' ' + objException.getMessage();
			System.debug('riri Exception: ' + errorMessage);
			insert new clcommon__Log__c(Name = CLASS_NAME, clcommon__Message__c = errorMessage, clcommon__Time__c = System.now());
		}
	}
}