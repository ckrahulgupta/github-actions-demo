/**
 * Created by Riadh Mankai on 3/2/23.
 * @description: utility class used in ExternalAPIApplicationCIF and potentially in other classes exposing REST endpoints
 * externally.
 */
global without sharing class ExternalAPIUtilities {
	public static final String ACH = 'ACH';
	public static final String PRODUCT_RETURN = 'PRODUCT RETURN';
	public static final String AMOUNT_ZERO = 'Advance amount must be superior to zero. Product return amount must be inferior to zero. You cannot pass zero amount';
	public static final String PRODUCT_RETURN_SUPERIOR_PRINCIPLE = 'Product Return not allowed to exceed the current Principal due on the Loan ; Negative Draw > Principal Balance ; ReturnExceedsPrincipal = 25';
	public static final String PRODUCT_RETURN_SUPERIOR_CURRENT_ADVANCES = 'Product Return not allowed if aggregate draws for the current cut-off (11:30 AM Central time) for the loan do not equal or exceed the Product Return requested ; Negative Draws > Total Advances ; ReturnsExceedAdvances = 29';
	public static final String ACCOUNT_NOT_FOUND = 'The grower account was not found ; No Loans Found for Account ; LoansNotFound = 31';
	public static final String Dealer_NOT_FOUND = 'The dealer account was not found ; No Loans Found for Account ; LoansNotFound = 31';
	public static final String MATURITY_DATE_NOT_DEFINED = 'The loan application has no maturity date';
	public static final String LOAN_NOT_FOUND = 'No active loan found ; LoanNotFound = 22';
	public static final String PAYMENT_METHOD_NOT_FOUND = 'Could not find a valid payment method (ACH)';
	public static final String PAYMENT_METHOD_PRODUCT_Return_NOT_FOUND = 'Could not find a valid payment method (PRODUCT RETURN)';
	public static final String LOAN_PAST_DUE = 'Draws are not allowed if the loan is past due ; Past Final Billing Date ; PastFinalDueDate = 23';
	public static final String CLOSE_TO_MATURITY_DATE = 'Draws are not allowed after the 26th of the month prior to the Maturity date ; Past Final Billing Date ; DaysToMaturity = 24';
	global final static String INSUFFICIENT_AVAILABLE_FUNDS = 'Amount requested exceeds what is currently Available ; ExcededPeak; ExceededPeak =27';
	global final static String EXCEEDED_COMMITMENT = 'Amount requested exceeds the loan commitment ; Exceeded Commitment; ExceededCommitment= 28';
	global final static String BAD_REQUEST = '400 Bad Request';
	global final static String CLASS_NAME = 'ExternalAPIUtilities';
	global final static String SUCCESS = 'The transaction has been posted successfully';
	global final static String DEFAULT_PURPOSE = 'Advance (transaction) or product return (negative payment)';
	global final static String VOIDED = 'Voided';
	global final static String SUCCESS_VOIDING = 'The transaction (voiding) has been posted successfully';
	global final static String ERROR_ALREADY_VOIDED = 'The transaction was already voided, you cannot voided it again';
	global final static String ERROR_ALREADY_CLEARED = 'The transaction was already sent to the accounting system - You can only void transactions before the current cut-off (11:30 AM Central time)';
	global final static String NO_MATCHING_TRANSACTION = 'No matching transaction found';
	global final static String DUPLICATE_TRANSACTION = 'Duplicate Transaction source ID - please use a different source ID';
	global final static String CENTRAL_TIME_ZONE = 'America/Chicago';
	global final static String CONNECTIFY_USER = 'Connectify User';
	global final static String CONNECTIFY_USER_PROFILE = 'CFA External API Profile';
	global enum PostOperationType {
		POST, PRODUCT_RETURN, VOIDING, STOP_WHEN_ALREADY_VOIDED, STOP_WHEN_ALREADY_CLEARED
	}
	public static final String PARENT = 'Parent';
	public static final String CHILD = 'Child';
	public static final String COULD_NOT_FIND_LOANS = 'Could not find loans associated with the provided account ID or CIF number';
	public static final String ACTIVE = 'ACTIVE';
	public static final Set<String> specialAllowedProfiles = new Set<String> {
		  'System Administrator',
		  'CFA Admin User',
		  'Growmark API Only Integration Profile'
	};
	public static final String DEALER_TOKEN_KEY = 'x-dealer-token';
	public static final String DEALER_CIF_KEY = 'x-dealer-cif';
	public static final String DEALER_TOKEN_MISSING = 'Dealer token missing';
	public static final String DEALER_CIF_MISSING = 'Dealer cif missing';
	public static PostOperationType operation = PostOperationType.POST; // Default operation is Post
	public static RestResponse response = RestContext.response;
	public static Map<String, Object> headerParamsMap;

	private static String actualDealerCIFNumber = '';
	private static RestRequest postRequest;

	private static String dealerCIFNumber;
	private static String dealerUniqueID;

	/**
	 * Wrapper class that represents the data structures that could be returned to the GET endpoint: either a list of
	 * application in a hierarchy format (sobjects), or a flat structure of both parent and child application (loans)
	 */
	global class LoanAPIReturnedResultWrapper {
		global List<genesis__Applications__c> LoansInHierarchyStructure;
		global List<LoanWrapper> LoansInFlatStructure;
		/**
		 * Constructor
		 * @param hierarchyLoans loans in Sobject format (hierarchy)
		 * @param flatLoans loans in a custom flat format
		 */
		global LoanAPIReturnedResultWrapper(
			  List<genesis__Applications__c> hierarchyLoans,
			  List<LoanWrapper> flatLoans
		) {
			this.LoansInHierarchyStructure = hierarchyLoans;
			this.LoansInFlatStructure = flatLoans;
		}
	}

	/**
	 * Wrapper class representing a loan in a flat structure (parent and child loans are modeled
	 * as separate items in a list)
	 */
	global class LoanWrapper {
		global String SalesforceID;
		global String CFALoanNumber;
		global Long LoanNumber;
		global Long ParentLoanNumber;
		global String ParentSalesforceID;
		global String CustomerName;
		global Long CustomerNumber;
		global String LoanStatus;
		global Double LoanAmount;
		global Double PeakAmount;
		global Double PrincipalBalance;
		global Double InterestBalance;
		global Double DailyInterest;
		global Integer CropYear;
		global Date EffectiveDate;
		global Date FinalDueDate;
		global Double RecoursePercent;
		global Double InterestRate;
		global String InterestRateType;
		global Double InterestRateSub;
		global String LoanPurpose;
		global Double TotalRequested;
		global String LoanLevel;
		global Datetime InterestAccruedToDate;
		global Double DrawToDate;
		global Double Available;
		global String ErrorMessage = 'N/A';
		global Boolean IsError = false;
	}

	/**
	 * @param cifNumber cif number passed by the get endpoint
	 *
	 * @return a custom wrapper (LoanAPIReturnedResultWrapper custom class) holding both a flat list structure and a
	 * hierarchy Sobject structure. This is called by HttpGet Apex methods which chose either the flat or the hierarchy
	 * structure.
	 */
	global static LoanAPIReturnedResultWrapper getLoansByCIFNumber(
		  String cifNumber
	) {
		List<genesis__Applications__c> applications = new List<genesis__Applications__c>();
		List<Id> childLoansIDs = new List<Id>();
		List<LoanWrapper> loanWrappers = new List<LoanWrapper>();
		List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
		User currentUser = [
			  SELECT Id, Name, ProfileId, Profile.Name, AccountId
			  FROM User
			  WHERE Id = :UserInfo.getUserId()
			  LIMIT 1
		];
		String partiesBaseQuery =
			  'SELECT genesis__Application__c' +
					' FROM clcommon__Party__c' +
					' WHERE clcommon__Account__r.Coop_Type__c = \'' + ExternalAPIApplicationCIFGMK.GROWMARK + '\'' +
					' AND genesis__Application__r.genesis__Account__r.Coop_Type__c = \'' + ExternalAPIApplicationCIFGMK.GROWMARK + '\'' +
					' AND genesis__Application__r.genesis__Status__c = \'' + ExternalAPIUtilities.ACTIVE + '\'' +
					' AND genesis__Application__r.Note_Date__c != NULL';
		try {
			if (String.isNotBlank(cifNumber)) {
				partiesBaseQuery = partiesBaseQuery + ' AND clcommon__Account__r.CIF_Number__c = \'' + cifNumber + '\'';
			}
			//	if this is not an admin or a Growmark API internal test user, then limit the returned records to only records the that the current user is supposed to access
			if (
				  currentUser.Profile.Name != 'System Administrator' &&
						currentUser.Profile.Name != 'CFA Admin User' &&
						currentUser.Profile.Name != 'Growmark API Only Integration Profile'
			) {
				partiesBaseQuery = partiesBaseQuery + ' AND clcommon__Account__c = \'' + currentUser.AccountId + '\'';
			}
			partiesBaseQuery = partiesBaseQuery + ' ORDER BY SystemModStamp, CreatedDate DESC';
			partyList = Database.query(partiesBaseQuery);

			if (partyList.isEmpty()) {
				throw new CustomException(COULD_NOT_FIND_LOANS);
			}
			List<Id> applicationIDs = new List<Id>();
			for (clcommon__Party__c objParty : partyList) {
				applicationIDs.add(objParty.genesis__Application__c);
			}
			applications = [
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
				  WHERE
						Id IN :applicationIDs
						AND genesis__Account__r.Coop_Type__c = :ExternalAPIApplicationCIFGMK.GROWMARK
						AND genesis__Status__c = :ExternalAPIUtilities.ACTIVE
						AND Note_Date__c != NULL
			];

			for (genesis__Applications__c eachParentLoan : applications) {
                system.debug(eachParentLoan.Id);
				LoanWrapper singleLoanWrapperParent = new LoanWrapper();
				Double totalRequestedAmountParent = 0;
				for (
					  genesis__Funding_Transaction__c eachTransaction : eachParentLoan.genesis__Funding_Transactions__r
				) {
					totalRequestedAmountParent =
						  totalRequestedAmountParent + eachTransaction.genesis__Amount__c;
				}
				singleLoanWrapperParent.SalesforceID = eachParentLoan.Id;
				singleLoanWrapperParent.LoanLevel = PARENT;
				singleLoanWrapperParent.CFALoanNumber = eachParentLoan.genesis__Loan_Number__c;
				singleLoanWrapperParent.LoanNumber = Long.valueOf(
					  eachParentLoan.genesis__Loan_Number__c
				);
				singleLoanWrapperParent.CustomerName = eachParentLoan.genesis__Account__r.Name;
				singleLoanWrapperParent.CustomerNumber = Long.valueOf(
					  eachParentLoan.genesis__Account__r.CIF_Number__c
				);
				singleLoanWrapperParent.LoanStatus = eachParentLoan.genesis__Status__c;
				singleLoanWrapperParent.LoanAmount = eachParentLoan.genesis__Loan_Amount__c;
				singleLoanWrapperParent.PrincipalBalance = eachParentLoan.Current_Principal_Balance__c;
				singleLoanWrapperParent.InterestBalance = eachParentLoan.Current_Interest_Balance__c;
				singleLoanWrapperParent.DailyInterest = eachParentLoan.Interest_Per_Diem__c;
				singleLoanWrapperParent.CropYear = String.isNotBlank(
					  eachParentLoan.Crop_Year__c
				)
					  ? Integer.valueOf(eachParentLoan.Crop_Year__c)
					  : 0;
				singleLoanWrapperParent.EffectiveDate = eachParentLoan.Note_Date__c;
				singleLoanWrapperParent.FinalDueDate = eachParentLoan.genesis__Maturity_Date__c;
				singleLoanWrapperParent.RecoursePercent = eachParentLoan.Guarantee__c;
				singleLoanWrapperParent.InterestRate = eachParentLoan.genesis__Interest_Rate__c;
				singleLoanWrapperParent.LoanPurpose = eachParentLoan.genesis__Description__c;
				singleLoanWrapperParent.TotalRequested = totalRequestedAmountParent;
				singleLoanWrapperParent.InterestAccruedToDate = eachParentLoan.Interest_Accrued_Thru_Date__c;
				singleLoanWrapperParent.PeakAmount =
					  eachParentLoan.genesis__Loan_Amount__c -
							eachParentLoan.Reserved_Amount__c;
				singleLoanWrapperParent.InterestRateSub = eachParentLoan.Dealer_Interest_Accrued__c;
				singleLoanWrapperParent.DrawToDate = eachParentLoan.Peak_Loan_Volume__c;
				singleLoanWrapperParent.Available = eachParentLoan.Available__c;
				loanWrappers.add(singleLoanWrapperParent);

				for (
					  genesis__Application_Pricing_Detail__c eachChildLoan : eachParentLoan.genesis__Pricing_Details__r
				) {
					childLoansIDs.add(eachChildLoan.Id);
					LoanWrapper singleLoanWrapperChild = new LoanWrapper();
					singleLoanWrapperChild.SalesforceID = eachChildLoan.Id;
					singleLoanWrapperChild.LoanLevel = CHILD;
					singleLoanWrapperChild.CFALoanNumber = eachChildLoan.Loan_Number__c;
					singleLoanWrapperChild.LoanNumber = String.isNotBlank(
						  eachChildLoan.Growmark_Loan_Number__c
					)
						  ? Long.valueOf(eachChildLoan.Growmark_Loan_Number__c)
						  : null;
					singleLoanWrapperChild.ParentLoanNumber = String.isNotBlank(
						  eachParentLoan.genesis__Loan_Number__c
					)
						  ? Long.valueOf(eachParentLoan.genesis__Loan_Number__c)
						  : null;
					singleLoanWrapperChild.ParentSalesforceID = eachParentLoan.Id;
					singleLoanWrapperChild.CustomerName = eachChildLoan.genesis__Application__r.genesis__Account__r.Name;
					singleLoanWrapperChild.CustomerNumber = Long.valueOf(
						  eachParentLoan.genesis__Account__r.CIF_Number__c
					);
					singleLoanWrapperChild.LoanStatus = eachChildLoan.genesis__Application__r.genesis__Status__c;
					singleLoanWrapperChild.PrincipalBalance = eachChildLoan.Principal_Advanced__c;
					singleLoanWrapperChild.InterestBalance = eachChildLoan.genesis__Total_Interest__c;
					singleLoanWrapperChild.DailyInterest = eachChildLoan.Interest_Per_Diem__c;
					singleLoanWrapperChild.CropYear = String.isNotBlank(
						  eachChildLoan.genesis__Application__r.Crop_Year__c
					)
						  ? Integer.valueOf(
								eachChildLoan.genesis__Application__r.Crop_Year__c
						  )
						  : 0;
					singleLoanWrapperChild.EffectiveDate = eachChildLoan.genesis__Application__r.Note_Date__c;
					singleLoanWrapperChild.FinalDueDate = eachChildLoan.Maturity_Date__c;
					singleLoanWrapperChild.RecoursePercent = eachChildLoan.genesis__Application__r.Guarantee__c;
					singleLoanWrapperChild.InterestRate = eachChildLoan.genesis__Interest_Rate__c;
					singleLoanWrapperChild.InterestRateType = eachChildLoan.genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c;
					singleLoanWrapperChild.LoanPurpose = eachChildLoan.genesis__Rate_Card_Setup_Detail__r.Description__c;
					singleLoanWrapperChild.InterestRateSub = eachChildLoan.Dealer_Interest_Accrued__c;
					singleLoanWrapperChild.InterestAccruedToDate = eachChildLoan.Interest_Accrued_Thru_Date__c;
					loanWrappers.add(singleLoanWrapperChild);
				}
			}

			Map<String, List<genesis__Funding_Transaction__c>> fundingTransactionsByChildLoanId = new Map<String, List<genesis__Funding_Transaction__c>>();
			for (genesis__Funding_Transaction__c eachFunding : [
				  SELECT Id, genesis__Amount__c, Pricing_Detail__c
				  FROM genesis__Funding_Transaction__c
				  WHERE Pricing_Detail__c IN :childLoansIDs
			]) {
				if (
					  fundingTransactionsByChildLoanId.containsKey(
							eachFunding.Pricing_Detail__c
					  )
				) {
					List<genesis__Funding_Transaction__c> currentTransactions = fundingTransactionsByChildLoanId.get(
						  eachFunding.Pricing_Detail__c
					);
					currentTransactions.add(eachFunding);
					fundingTransactionsByChildLoanId.put(
						  eachFunding.Pricing_Detail__c,
						  currentTransactions
					);
				} else {
					fundingTransactionsByChildLoanId.put(
						  eachFunding.Pricing_Detail__c,
						  new List<genesis__Funding_Transaction__c> {
								eachFunding
						  }
					);
				}
			}
			for (LoanWrapper eachLoanWrapper : loanWrappers) {
				if (eachLoanWrapper.LoanLevel == CHILD) {
					Double totalRequestedAmountChild = 0;
					if (
						  !fundingTransactionsByChildLoanId.isEmpty() &&
								fundingTransactionsByChildLoanId.get(
									  eachLoanWrapper.SalesforceID
								) != null
					) {
						for (
							  genesis__Funding_Transaction__c eachFunding : fundingTransactionsByChildLoanId.get(
							  eachLoanWrapper.SalesforceID
						)
						) {
							totalRequestedAmountChild =
								  totalRequestedAmountChild + eachFunding.genesis__Amount__c;
						}
						eachLoanWrapper.TotalRequested = totalRequestedAmountChild;
					}
				}
			}
			if (!Test.isRunningTest()) {
				response.statusCode = 200;
			}
		} catch (Exception objException) {
			LoanWrapper errorLoanWrapper = new LoanWrapper();
			errorLoanWrapper.IsError = true;
			errorLoanWrapper.ErrorMessage =
				  objException.getMessage() +
						'; ' +
						objException.getStackTraceString();
			loanWrappers.add(errorLoanWrapper);
			System.debug('riri error message = ' + errorLoanWrapper.ErrorMessage);
			if (!Test.isRunningTest()) {
				response.statusCode = 400;
				response.responseBody = Blob.valueOf(objException.getMessage());
			}
			Database.insert(
				  new clcommon__Log__c(
						Name = CLASS_NAME,
						clcommon__Message__c = CLASS_NAME +
							  objException.getStackTraceString() +
							  objException.getMessage(),
						clcommon__Time__c = System.now()
				  ),
				  false
			);
		}
		return new LoanAPIReturnedResultWrapper(applications, loanWrappers);
	}

	/**
	 * @description This method is used to return the matching Funding Transaction records associated to a transactionSourceID
	 * @param transactionSourceId the external ID of the transaction coming from an external system
	 * @return a list of matching Funding Transaction records
	 */
	public static List<genesis__Funding_Transaction__c> getMatchingTransactions(String transactionSourceId) {
		List<genesis__Funding_Transaction__c> matchingTransactionsToReturns = new List<genesis__Funding_Transaction__c>();
		if (String.isNotBlank(transactionSourceId)) {
			matchingTransactionsToReturns = [
				  SELECT Id, genesis__Amount__c, Is_Clearing_Suspense__c, Status__c, Pricing_Detail__r.Credit_Balance__c,
						Pricing_Detail__c, Pricing_Detail__r.Principal_Advanced__c, Pricing_Detail__r.genesis__Application__c,
						Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c, genesis__Cleared__c
				  FROM genesis__Funding_Transaction__c
				  WHERE Growmark_Transaction_Source_ID__c = :transactionSourceId
			];
		}
		return matchingTransactionsToReturns;
	}

	/**
	 * @description This method is used to validate whether a conduit user has access or not to an application
	 * @param applicationId the application we want to verify access for
	 * @param dealerCIF the dealer CIF number
	 * @param dealerUniqueID the dealer unique ID (token)
	 * @return a boolean indicating whether the user has access or not
	 */
	public static Boolean validateConduitUserAccess(String applicationId, String dealerCIF, String dealerUniqueID) {
		List<clcommon__Party__c> applicationParties = [
			  SELECT Id
			  FROM clcommon__Party__c
			  WHERE genesis__Application__c = :applicationId
			  AND clcommon__Account__r.CIF_Number__c != NULL
			  AND clcommon__Account__r.CIF_Number__c = :dealerCIF
			  AND clcommon__Account__r.Unique_Id__c != NULL
			  AND clcommon__Account__r.Unique_Id__c = :dealerUniqueID
			  AND genesis__Application__r.genesis__Status__c = :ACTIVE
		];
		Boolean isValidUser = applicationParties.isEmpty() ? false : true;
		return isValidUser;
	}

	/**
	 * @description This method is used to validate whether a Growmark user has access or not to an application
	 * @param applicationId the application we want to verify access for
	 * @param currentUser the current (context) user
	 * @return a boolean indicating whether the user has access or not
	 */
	public static Boolean validateGrowmarkUserAccess(String applicationId, User currentUser) {
		List<clcommon__Party__c> applicationParties = [
			  SELECT Id
			  FROM clcommon__Party__c
			  WHERE genesis__Application__c = :applicationId
			  AND (
					(clcommon__Contact__c != NULL AND clcommon__Contact__c = :currentUser.ContactId) OR
					(clcommon__Account__c != NULL AND clcommon__Account__c = :currentUser.AccountId)
			  )
			  AND genesis__Application__r.genesis__Status__c = :ACTIVE
		];
		Boolean isValidUser = applicationParties.isEmpty() ? false : true;
		return isValidUser;
	}

	/**
	 * @description This method assigns the variables dealerUniqueID and dealerCIFNumber
	 * @param headersMap the postRequest.headers
	 */
	public static void assignHeaderParameters(Map<String, Object> headersMap) {
		if (!headersMap.containsKey(DEALER_TOKEN_KEY)) {
			throw new CustomException(DEALER_TOKEN_MISSING);
		} else {
			dealerUniqueID = (String) headersMap.get(DEALER_TOKEN_KEY);
		}
		if (!headersMap.containsKey(DEALER_CIF_KEY)) {
			throw new CustomException(DEALER_CIF_MISSING);
		} else {
			dealerCIFNumber = (String) headersMap.get(DEALER_CIF_KEY);
		}
	}

	/**
	 * @description This method is used to push transaction
	 * @param transactionSourceId the external ID of the transaction coming from an external system
	 * @param loanNumber loan number of the child loan under which we are posting a transaction
	 * @param amount amount of the transaction
	 * @param purpose purpose of the transaction (text)
	 * @param isGrowmarkContext boolean to determine if the transaction is coming from Growmark (class ExternalAPIApplicationCIFGMK) or not
	 */
	public static void pushTransaction(
		  String transactionSourceId,
		  String loanNumber,
		  Decimal amount,
		  String purpose,
		  Boolean isGrowmarkContext
	) {
		Datetime currentDateTimeGMT = Datetime.now();
		TimeZone centralTimeZone = TimeZone.getTimeZone(CENTRAL_TIME_ZONE);
		Integer offsetHours = centralTimeZone.getOffset(currentDateTimeGMT) / (1000 * 60 * 60);
		Date currentDateGMT = currentDateTimeGMT.dateGmt();
		Decimal totalTransactionsSinceLastCutoff = 0;
		Date currentMaturityDate;
		String applicationId;
		Account objAccount = new Account();
		Account dealerAccount = new Account();
		clcommon__Payment_Mode__c ACHPaymentMode = new clcommon__Payment_Mode__c();
		clcommon__Payment_Mode__c productReturnPaymentMode = new clcommon__Payment_Mode__c();
		genesis__Application_Pricing_Detail__c objPricingDetail = new genesis__Application_Pricing_Detail__c();
		postRequest = RestContext.request;

		Savepoint dbSavePoint = Database.setSavepoint();
		try {
//			get the child loan (pricing detail) attached to the loan passed in parameters
			List<genesis__Application_Pricing_Detail__c> objPricingDetails = getPricingDetailsFromLoanNumber(loanNumber);
			if (objPricingDetails.isEmpty()) {
				throw new CustomException(LOAN_NOT_FOUND);
			}
			objPricingDetail = objPricingDetails[0];
			applicationId = objPricingDetail.genesis__Application__c;

			if (!ExternalAPIUtilities.isValidUser(objPricingDetail)) {
				throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
			}
			if(amount > 0) {
                PortalRequestForAdvanceHandler.validateDealerBASFEarlyAdvanceEligibility(new Map<String, Object>{
                    PortalConstants.FIELD_CIF_NUMBER => objPricingDetail.genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                    PortalConstants.FIELD_DESCRIPTION => objPricingDetail.genesis__Rate_Card_Setup_Detail__r.Description__c,
                    PortalConstants.FIELD_INTEREST_RATE => objPricingDetail.genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c,
                    PortalConstants.FIELD_CROP_YEAR => objPricingDetail.genesis__Application__r.Crop_Year__c,
                    PortalConstants.KEY_PAYMENT_MODE => ACH
                });
            }
//			If we have matching transactions, then we must process this as a void operation
			List<genesis__Funding_Transaction__c> matchingTransactions = ExternalAPIUtilities.getMatchingTransactions(transactionSourceId);
			if (!matchingTransactions.isEmpty() && isGrowmarkContext) {
				ExternalAPIUtilities.voidTransaction(matchingTransactions);
			}

//			End: Voiding operation handling
//			Else, if it not a void operation, we are either doing a regular transaction or a product return
			else if (matchingTransactions.isEmpty() || !isGrowmarkContext) {
				if (!matchingTransactions.isEmpty()) {
					throw new CustomException(DUPLICATE_TRANSACTION);
				}
				//			Start common validations between a regular transaction and a product return
				if (transactionSourceId == null || loanNumber == null || amount == null) {
					throw new CustomException(ConstantValues.PARAMETER_MISSING);
				}
				purpose = String.isBlank(purpose) ? DEFAULT_PURPOSE : purpose.abbreviate(255);
				if (amount == 0) {
					throw new CustomException(AMOUNT_ZERO);
				}
				List<clcommon__Payment_Mode__c> ACHPaymentModes = [
					  SELECT Id, Name
					  FROM clcommon__Payment_Mode__c
					  WHERE Name = :ACH
				];
				if (ACHPaymentModes.isEmpty()) {
					throw new CustomException(PAYMENT_METHOD_NOT_FOUND);
				}
				ACHPaymentMode = ACHPaymentModes[0];
				List<clcommon__Payment_Mode__c> productReturnPaymentModes = [
					  SELECT Id, Name
					  FROM clcommon__Payment_Mode__c
					  WHERE Name = :PRODUCT_RETURN
				];
				if (productReturnPaymentModes.isEmpty()) {
					throw new CustomException(PAYMENT_METHOD_PRODUCT_Return_NOT_FOUND);
				}
				productReturnPaymentMode = productReturnPaymentModes[0];

				objAccount = [
					  SELECT Id, Name
					  FROM Account
					  WHERE Id = :objPricingDetail.genesis__Application__r.genesis__Account__c
				];
				if (objAccount == null) {
					throw new CustomException(ACCOUNT_NOT_FOUND);
				}
				dealerAccount = [
					  SELECT Id, Name
					  FROM Account
					  WHERE Id = :objPricingDetail.genesis__Application__r.Dealer_Name__c
				];
				if (dealerAccount == null) {
					throw new CustomException(Dealer_NOT_FOUND);
				}
				if (objPricingDetail.genesis__Application__r.genesis__Maturity_Date__c == null) {
					throw new CustomException(MATURITY_DATE_NOT_DEFINED);
				}
				currentMaturityDate = objPricingDetail.genesis__Application__r.genesis__Maturity_Date__c;

				//            this covers rule 5 and 6 for regular transaction, and 4 for product return
				if ((currentMaturityDate.year() - currentDateGMT.year() < 0)) {
					throw new CustomException(LOAN_PAST_DUE);
				} else if (currentMaturityDate.year() - currentDateGMT.year() == 0) {
					if (currentMaturityDate.month() - currentDateGMT.month() == 1) {
						if (currentDateGMT.day() >= 26) {
							throw new CustomException(CLOSE_TO_MATURITY_DATE);
						}
					} else if (currentMaturityDate.month() - currentDateGMT.month() <= 0) {
						throw new CustomException(CLOSE_TO_MATURITY_DATE);
					}
				} else if (
					  currentMaturityDate.year() - currentDateGMT.year() == 1 &&
							currentMaturityDate.month() == 1 &&
							currentDateGMT.month() == 12
				) {
					if (currentDateGMT.day() >= 26) {
						throw new CustomException(CLOSE_TO_MATURITY_DATE);
					}
				}
				//			End common validations between a regular transaction and a product return

				// Query all the Pricing details which has a credit balance, to use below if we need to clear credits
				List<genesis__Funding_Transaction__c> transactionsToClear = new List<genesis__Funding_Transaction__c>();
				List<genesis__Application_Pricing_Detail__c> pricingDetailsToClear = [
					  SELECT Id, Credit_Balance__c
					  FROM genesis__Application_Pricing_Detail__c
					  WHERE
							genesis__Application__c = :applicationId
							AND Credit_Balance__c != NULL
							AND Credit_Balance__c > 0
							AND genesis__Enabled_Flag__c = TRUE
				];

				//        if traditional transaction
				if (amount > 0) {
					//        Handle credit balance clearing
					for (genesis__Application_Pricing_Detail__c objEachPricingToClear : pricingDetailsToClear) {
						genesis__Funding_Transaction__c objFundingTransactionToClear = new genesis__Funding_Transaction__c();
						//            Only touch the credit balance if we have a positive amount (a traditional transaction)
						// Create a funding transaction records for Suspense Balance
						if (amount <= objEachPricingToClear.Credit_Balance__c) {
							objFundingTransactionToClear.genesis__Amount__c = amount;
						} else {
							objFundingTransactionToClear.genesis__Amount__c = objEachPricingToClear.Credit_Balance__c;
						}
						objFundingTransactionToClear.genesis__Reference__c = purpose;
						objFundingTransactionToClear.Growmark_Transaction_Source_ID__c = transactionSourceId;
						objFundingTransactionToClear.genesis__Application__c = applicationId;
						objFundingTransactionToClear.genesis__Payment_Mode__c = ACHPaymentMode.Id;
						objFundingTransactionToClear.genesis__Funding_Date__c = currentDateGMT;
						objFundingTransactionToClear.Growmark_Transaction_Datetime_GMT__c = currentDateTimeGMT;
						objFundingTransactionToClear.Grower_Name__c = objAccount.Name;
						objFundingTransactionToClear.Pricing_Detail__c = objEachPricingToClear.Id;
						objFundingTransactionToClear.Is_Clearing_Suspense__c = true;
						objFundingTransactionToClear.Is_API_Transaction__c = true;
						amount = amount - objFundingTransactionToClear.genesis__Amount__c;
						objEachPricingToClear.Credit_Balance__c = objEachPricingToClear.Credit_Balance__c - objFundingTransactionToClear.genesis__Amount__c;
						transactionsToClear.add(objFundingTransactionToClear);
					}
					//				End of handling the credit clearing

					//            Blow is validation rule 2 (explicit for error handling purposes)
					if (objPricingDetail.genesis__Application__r.genesis__Loan_Amount__c < amount) {
						throw new CustomException(EXCEEDED_COMMITMENT);
					}
					//            Below is validation rule 1, 2, 3
					if (objPricingDetail.genesis__Application__r.Available__c < amount) {
						throw new CustomException(INSUFFICIENT_AVAILABLE_FUNDS);
					}
				}
				//			End of validation rules for Regular transaction (POST)

				//          Start of validation rules for Product Return
				else if (amount < 0) {
					operation = PostOperationType.PRODUCT_RETURN;
					//            Rule 2 product return
					if (objPricingDetail.Principal_Advanced__c - (-amount) < 0) {
						throw new CustomException(PRODUCT_RETURN_SUPERIOR_PRINCIPLE);
					}
					//            Rule 3 product return
					//            Rule 3 step 1: get the last cutoff time and current time in GMT (GMT).

					Datetime lastCutoffTimeGMT = Datetime.newInstanceGmt(
						  currentDateTimeGMT.yearGmt(),
						  currentDateTimeGMT.monthGmt(),
						  currentDateTimeGMT.dayGmt(),
						  11 + (-offsetHours),
						  30,
						  0
					);
					if (currentDateTimeGMT < lastCutoffTimeGMT) {
						lastCutoffTimeGMT = lastCutoffTimeGMT.addDays(-1);
					}
					//            Rule 3 step 2: calculate the transaction between the last cutoff and the current time
					List<genesis__Funding_Transaction__c> transactionsSinceLastCutoff = [
						  SELECT Id, Grower_Salesforce_ID__c, genesis__Amount__c, Pricing_Detail__r.genesis__Application__r.Dealer_Name__c
						  FROM genesis__Funding_Transaction__c
						  WHERE
								Pricing_Detail__r.genesis__Application__r.Dealer_Name__c = :dealerAccount.Id
								AND (Growmark_Transaction_Datetime_GMT__c > :lastCutoffTimeGMT OR CreatedDate > :lastCutoffTimeGMT)
								AND (Growmark_Transaction_Datetime_GMT__c <= :currentDateTimeGMT OR CreatedDate <= :currentDateTimeGMT)
								AND genesis__Payment_Mode__c = :ACHPaymentMode.Id
					];
					for (genesis__Funding_Transaction__c eachTransaction : transactionsSinceLastCutoff) {
						totalTransactionsSinceLastCutoff = totalTransactionsSinceLastCutoff + eachTransaction.genesis__Amount__c;
					}
					//            Rule 3 step 3: comparison
					if ((-amount) > totalTransactionsSinceLastCutoff) {
						throw new CustomException(PRODUCT_RETURN_SUPERIOR_CURRENT_ADVANCES);
					}
				}
				//			End of validation rules for Product Return

				//			Start: Record the regular transaction or the product return
				genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
				//        application Id below used to update Peak Loan Volume on parent application
				genesis__Applications__c objApplication = new genesis__Applications__c();
				objApplication.Id = objPricingDetail.genesis__Application__c;
				// Instance for Child Loan to update Principal Advanced
				objFundingTransaction.genesis__Amount__c = Math.abs(amount);
				objFundingTransaction.genesis__Reference__c = purpose;
				objFundingTransaction.Growmark_Transaction_Source_ID__c = transactionSourceId;
				objFundingTransaction.genesis__Application__c = applicationId;
				objFundingTransaction.genesis__Payment_Mode__c = amount < 0 ? productReturnPaymentMode.Id : ACHPaymentMode.Id;
				objFundingTransaction.genesis__Funding_Date__c = currentDateGMT;
				objFundingTransaction.Growmark_Transaction_Datetime_GMT__c = currentDateTimeGMT;
				objFundingTransaction.Grower_Name__c = objAccount.Name;
				objFundingTransaction.Pricing_Detail__c = objPricingDetail.Id;
				objFundingTransaction.Is_API_Transaction__c = true;
				objApplication.Peak_Loan_Volume__c = objPricingDetail.genesis__Application__r.Peak_Loan_Volume__c + amount;
				//Updating the Current Principal Balance on Child Loans
				objPricingDetail.Principal_Advanced__c = objPricingDetail.Principal_Advanced__c + amount;
				//			End: Record the regular transaction or the product return

				//			Start: database operations
				//			We do not want to insert a regular transaction if the amount = 0, this happens when the amount = credit balance
				if (amount != 0) {
					Database.upsert(objFundingTransaction, true);
					Database.update(objApplication, true);
					Database.update(objPricingDetail, true);
				}
				//			if we used the credit, insertion of transaction to clear and update of the credit amount
				if (transactionsToClear.size() > 0) {
					Database.insert(transactionsToClear, true);
					Database.update(pricingDetailsToClear, true);
				}
				//			if everything is okay (no errors raised so far), set the status code to success = 200
				if (!Test.isRunningTest()) {
					response.statusCode = 200;
					response.responseBody = Blob.valueOf(SUCCESS);
				}
			}
		} catch (CustomException customException) {
			Database.rollback(dbSavePoint);
			if (!Test.isRunningTest()) {
				response.statusCode = 400;
				response.responseBody = Blob.valueOf(
					  BAD_REQUEST + '; ' + customException.getMessage()
				);
			}
			Database.insert(
				  new clcommon__Log__c(
						Name = CLASS_NAME,
						clcommon__Message__c = CLASS_NAME +
							  customException.getStackTraceString() +
							  customException.getMessage(),
						clcommon__Time__c = Datetime.now()
				  ),
				  false
			);
		} catch (Exception objException) {
			if (!Test.isRunningTest()) {
				response.statusCode = 400;
				response.responseBody = Blob.valueOf(
					  BAD_REQUEST + '; ' + objException.getMessage()
				);
			}
			Database.insert(
				  new clcommon__Log__c(
						Name = CLASS_NAME,
						clcommon__Message__c = CLASS_NAME +
							  objException.getStackTraceString() +
							  objException.getMessage(),
						clcommon__Time__c = Datetime.now()
				  ),
				  false
			);
		}
	}

	/**
	 * @param matchingTransactions The matching transactions to void
	 * @description This method is used to void a transaction
	 */
	public static void voidTransaction(List<genesis__Funding_Transaction__c> matchingTransactions) {
		genesis__Funding_Transaction__c matchingClearingSuspenseTransaction;
		genesis__Funding_Transaction__c matchingRegularTransaction;
		genesis__Application_Pricing_Detail__c pricingDetailWithCreditIncreased;
		genesis__Application_Pricing_Detail__c pricingDetailWithBalanceDecreased;
		genesis__Applications__c applicationWithPeakAmountDecreased;
		if (matchingTransactions.isEmpty()) {
			throw new CustomException(NO_MATCHING_TRANSACTION);
		}
		for (genesis__Funding_Transaction__c eachTransactionMatched : matchingTransactions) {
			if (eachTransactionMatched.Status__c == VOIDED) {
				operation = PostOperationType.STOP_WHEN_ALREADY_VOIDED;
				break;
			}
			if (eachTransactionMatched.genesis__Cleared__c) {
				operation = PostOperationType.STOP_WHEN_ALREADY_CLEARED;
				break;
			}
			if (eachTransactionMatched.Is_Clearing_Suspense__c) {
				matchingClearingSuspenseTransaction = eachTransactionMatched;
			} else {
				matchingRegularTransaction = eachTransactionMatched;
			}
		}
//				if we find a transaction that was already voided, then throw an error
		if (operation == PostOperationType.STOP_WHEN_ALREADY_VOIDED) {
			throw new CustomException(ERROR_ALREADY_VOIDED);
		}
//				if we find a transaction that was already cleared (sent to NLS), then throw an error
		if (operation == PostOperationType.STOP_WHEN_ALREADY_CLEARED) {
			throw new CustomException(ERROR_ALREADY_CLEARED);
		}

		operation = PostOperationType.VOIDING;
//				Start: Voiding operation handling
		if (matchingClearingSuspenseTransaction != null) {
			matchingClearingSuspenseTransaction.Status__c = VOIDED;
			pricingDetailWithCreditIncreased = new genesis__Application_Pricing_Detail__c(
				  Id = matchingClearingSuspenseTransaction.Pricing_Detail__c,
				  Credit_Balance__c = matchingClearingSuspenseTransaction.Pricing_Detail__r.Credit_Balance__c + matchingClearingSuspenseTransaction.genesis__Amount__c
			);
			update matchingClearingSuspenseTransaction;
			update pricingDetailWithCreditIncreased;
		}
		if (matchingRegularTransaction != null) {
			matchingRegularTransaction.Status__c = VOIDED;
			pricingDetailWithBalanceDecreased = new genesis__Application_Pricing_Detail__c(
				  Id = matchingRegularTransaction.Pricing_Detail__c,
				  Principal_Advanced__c = matchingRegularTransaction.Pricing_Detail__r.Principal_Advanced__c - matchingRegularTransaction.genesis__Amount__c
			);
			applicationWithPeakAmountDecreased = new genesis__Applications__c(
				  Id = matchingRegularTransaction.Pricing_Detail__r.genesis__Application__c,
				  Peak_Loan_Volume__c = matchingRegularTransaction.Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c - matchingRegularTransaction.genesis__Amount__c
			);
			update matchingRegularTransaction;
			update pricingDetailWithBalanceDecreased;
			update applicationWithPeakAmountDecreased;
		}
		//			if everything is okay (no errors raised so far), set the status code to success = 200
		if (!Test.isRunningTest()) {
			response.statusCode = 200;
			response.responseBody = Blob.valueOf(SUCCESS_VOIDING);
		}
	}

	/**
	 * @param objPricingDetail The pricing detail record used for validation (aka if the user is able to access application or not)
	 * @return If the user is authorized to perform the operation
	 */
	public static Boolean isValidUser(genesis__Application_Pricing_Detail__c objPricingDetail) {
		Boolean isValidUser = false;
		String applicationId = objPricingDetail.genesis__Application__c;
		//			The actual CIF from the Pricing Detail record
		actualDealerCIFNumber = objPricingDetail.genesis__Application__r.Dealer_Name__r.CIF_Number__c ?? '';
		//			Verify access: if the current operation is authorized
		User currentUser = [
			  SELECT Id, Profile.Name, Name, ContactId, AccountId
			  FROM User
			  WHERE Id = :UserInfo.getUserId()
			  LIMIT 1
		];

		//			If this is an admin user or an internal, then we allow the operation
		if (specialAllowedProfiles.contains(currentUser.Profile.Name)) {
			isValidUser = true;
		}
		//			If this is an Agvend user
		else if (currentUser.Profile.Name == System.Label.AgVend_External_User_Profile_Label) {
			if (JSON.serialize(ConstantValues.DEALER_CIF_NUMBER).contains(actualDealerCIFNumber)) {
				isValidUser = true;
			}
		} else if (currentUser.Name == CONNECTIFY_USER || currentUser.Profile.Name == CONNECTIFY_USER_PROFILE) {
			headerParamsMap = headerParamsMap ?? (Map<String, Object>) postRequest.headers;
			assignHeaderParameters(headerParamsMap);
			isValidUser = validateConduitUserAccess(applicationId, dealerCIFNumber, dealerUniqueID);
			//			Else the default for GMK, validate with the current user only
		} else {
			isValidUser = validateGrowmarkUserAccess(applicationId, currentUser);
		}
		return isValidUser;
	}

	/**
	 * @param loanNumber The loan number, required to get the pricing detail record
	 * @return The pricing details for the loan number
	 */
	public static List<genesis__Application_Pricing_Detail__c> getPricingDetailsFromLoanNumber(String loanNumber) {
		return [
			  SELECT
					Id,
					Growmark_Loan_Number__c,
					Loan_Number__c,
					genesis__Application__c,
					genesis__Application__r.Available__c,
					genesis__Application__r.Peak_Loan_Volume__c,
					genesis__Application__r.genesis__Maturity_Date__c,
					genesis__Application__r.genesis__Contact__r.Name,
					genesis__Application__r.genesis__Loan_Amount__c,
					Principal_Advanced__c,
					genesis__Application__r.genesis__Account__c,
					genesis__Application__r.Dealer_Name__c,
					genesis__Application__r.Dealer_Name__r.CIF_Number__c,
					genesis__Rate_Card_Setup_Detail__r.Description__c,
					genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c,
					genesis__Application__r.Crop_Year__c
			  FROM genesis__Application_Pricing_Detail__c
			  WHERE
					(Loan_Number__c = :loanNumber
					OR Growmark_Loan_Number__c = :loanNumber)
					AND genesis__Enabled_Flag__c = TRUE
					AND genesis__Application__r.genesis__Status__c = :ACTIVE
		];
	}

}