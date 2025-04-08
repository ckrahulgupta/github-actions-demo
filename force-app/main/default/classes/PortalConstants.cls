/**
 * @description       : Purpose of this class is to store all the Portal contants
 * @author            : iAyush
 * @group             : 
 * @last modified by  : Ayan Bhowmik
**/

global without sharing class PortalConstants {

    // Error Message for Portal
    global final static string WRONG_MY_PROGRAM_NAME = 'Please avoid using \'#\' or \':\' in the My Program Name';
    global final static String SOMETHING_WENT_WRONG = 'Something went wrong';
    global final static String REQUIRED_PARAMETERS_MISSING = 'Required parameters missing';
    global final static String NEW_MATURITY_DATE_IS_NOT_FIFTEENTH = 'The Maturity Date should be 15th of a Month.';
    global final static String NEW_MATURITY_DATE_IS_BEYOND_SIXTY_DAYS = 'The Maturity Date cannot be extended beyond 60 Days.';
    global final static String NEW_MATURITY_IS_PAST_DATE = 'The Maturity Date cannot be a past date.';
    global final static String USER_NOT_AUTHORISED = 'User is not authorized to perform this operation.';
    global final static String INVALID_LOAN_NUMBER = 'Please enter valid loan number. Loan number: {!LoanNumber} is invalid.';
    global final static String INSUFFICIENT_AVAILABLE_FUNDS = 'Amount requested exceeds what is currently Available ';
    global final static String INVALID_AMOUNT = 'Please enter a valid amount.';
    global final static String INVALID_CSV_FILE = 'Please upload the file in CSV format.';
    global final static String CSV_FILE_FIELD_MISSING = 'Values are missing. Please check and upload all fields in the CSV file.';
    global final static String INVALID_LOAN_AMOUNT = 'Loan amount should be greater than zero.';
    global final static String INVALID_LOAN_AMOUNTS = 'Loan amount should be greater than zero';
    public static final String EMAIL_SEND_FAILED = 'Failed to send the email.';
    public static final String INSUFFICIENT_COLLATERALS = 'Please add collaterals to match the loan amount';
    public static final String INVALID_WITHDRAWN_REQUEST = 'Booked application cannot be withdrawn.';
    public static final String INVALID_DRAFT_NUMBER = 'Invalid Draft Number';
    public static final String ACH_LOAN_NUMBER=' for Loan Number : ';
    public static final String DUPLICATE= 'Duplicate Loan Number.';
    public static final String INVALID_CSV='Invalid CSV File.';
    public static final String AMOUNT_FORMAT='The loan amount should contain only numbers';
    public static final String DUPLICATE_DRAFT_NUMBER = 'Draft Number has previously been used, please update';
    public static final String NO_COAPPLICANT_FOR_THIS_APPLICATION = 'Selected Application does not have any Co-Applicant';
    global final static String INVALID_LOAN_NUMBER_ERROR = 'Invalid Loan Number.';
    public static final String NO_APPLICATIONS_FOUND= 'No applications were found.';
    global final static String LANDUS_USER_ALREADY_EXIST = 'If you have a Landus Portal login, please login and complete the application under the Financing tab or call the GROW Solutions Center at (515) 800-GROW (4769), x 6.';
    public static final String INVALID_DOCUSIGN_EMAIL_REQUEST = 'Invalid Email Request for This Status of Application';
    public static final String SEND_APPLICATION_ERROR = 'You can only send Individual Applications to the Grower';
    public static final String LEGAL_ENTITY_MISSING = 'Legal Entity Missing';
    public static final String COOP_TYPE_MISSING = 'Coop Type Missing';
    global final static String SPREAD_ALL_PAYMENT_AMOUNT = 'Please spread all payment amount among the child loan';
    global final static String SPREAD_ALL_OUTSTANDING = 'Please fill the remaining amount of the entire child loan, since you are doing overpayment';
    global final static String ERP_ID_REQUIRED = 'ERP ID is Required';
    global final static String ERP_ID_NOT_ENABLED = 'ERP ID is not enabled.';
    global final static String NO_CL_OR_SA_FOUND = 'Selected Application does not have any Certified Lender or Sales Agent';
    global final static String COAPPLICANT_ALREADY_EXIST = 'Co-Applicant is already added to the application';
    global static final String NO_RATE_CARDS_EXIST = 'Please add at least one special term tranche interest to submit this flex rate application.';
    global static final String EVERGREEN_TIER_TWO_BIZ_INFO_ERROR = 'Please score the application prior to selecting submit.';
    global final static string MISSING_APPROVAL_FOR_THE_APPLICATION = 'Please select whether you want to recommend the application';
    global final static string COULD_NOT_UPDATE_SSN = 'The SSN could not be updated.Please contact CFA';

        
    
    // Contact error messages
    global final static String EMAIL_FIELD_MISSING = 'Please enter the email for all the applicants.';

    // Collateral error messages
    global final static String CROP_COMMODITY_FIELD_MISSING = 'Please enter the commodity for the crop information.';
    global final static String CROP_TOTAL_ACRES_FIELD_MISSING = 'Please enter the total acres for the crop information.';
    global final static String CROP_PRODUCER_SHARE_PERCENT_FIELD_MISSING = 'Please enter the producers share percent for the crop information.';
    global final static String CROP_APPROVED_YIELD_FIELD_MISSING = 'Please enter the approved yield for the crop information.';
    global final static String CROP_INSURANCE_PLAN_FIELD_MISSING = 'Please enter the insurance plan for the crop information.';
    global final static String CROP_PERCENT_COVERAGE_LEVEL_FIELD_MISSING = 'Please enter the percent coverage level for the crop information.';
    global final static String CROP_PERCENT_FED_FIELD_MISSING = 'Please enter the percent fed for the crop information.';

    global final static String CROP_INVALID_COMMODITY_TYPE = 'Commodity value should be a valid option chosen from the dropdown.';
    // global final static String CROP_INVALID_TOTAL_ACRES_TYPE = 'Total acres value should contain only digits.';
    // global final static String CROP_INVALID_PRODUCER_SHARE_PERCENT_TYPE = 'Producer\'s share percent value should contain only digits.';
    // global final static String CROP_INVALID_APPROVED_YIELD_TYPE = 'Approved yield value should contain only digits.';
    global final static String CROP_INVALID_INSURANCE_PLAN_TYPE = 'Insurance plan value should be a valid option chosen from the dropdown.';
    global final static String CROP_INVALID_PERCENT_COVERAGE_LEVEL_TYPE = 'Percent coverage level value should be a valid option chosen from the dropdown.';
    // global final static String CROP_INVALID_PERCENT_FED_TYPE = 'Percent fed value should contain only digits.';

    global final static String CROP_INVALID_TOTAL_ACRES_VALUE = 'Total acres value should be a valid number.';
    global final static String CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE = 'Producer\'s share percent value should be between 0 and 100.';
    global final static String CROP_INVALID_APPROVED_YIELD_VALUE = 'Approved yield value should be a valid number.';
    global final static String CROP_INVALID_PERCENT_FED_VALUE = 'Percent fed value should be in between 0 and 100.';

    // Application error messages
    global final static String APPL_ID_FIELD_MISSING = 'Invalid application.';

    global final static String APPL_FEED_COLLATERALS_FIELD_MISSING = 'Please enter the feed collaterals value for the application.';
    global final static String APPL_INVALID_FEED_COLLATERALS_TYPE = 'Invalid feed collaterals value.';

    global final static String APPL_SALES_AGENT_FIELD_MISSING = 'Please enter the sales agent for the application.';
    global final static String APPL_YEARS_OF_BUSINESS_FIELD_MISSING = 'Please enter the years of business you have done with the applicant for the application.';
    global final static String APPL_MY_PROGRAM_FIELD_MISSING = 'Please enter the my program for the application.';

    global final static String APPL_INVALID_INTERNAL_REF_CODE_TYPE = 'Please enter valid internal reference code for the application.';
    global final static String APPL_INVALID_YEARS_OF_BUSINESS_TYPE = 'Years of business value should be a valid option chosen from the dropdown.';
    global final static String APPL_INVALID_MY_PROGRAM_TYPE = 'My program value should be a valid option chosen from the dropdown.';
    global final static String APPL_FLEX_RATE_PRICING_FIELD_MISSING = 'Please enter the flex rate pricing choice.';
    global final static String APPL_ACCEPT_APPLICABLE_GUARANTY_FIELD_MISSING = 'Please enter the accept applicable guaranty choice.';
    global final static String APPL_RECOMMEND_APPL_FIELD_MISSING = 'Please enter the recommend application choice.';
    global final static String APPL_FIRST_NAME_MISSING = 'Please enter the first name.';
    global final static String APPL_LAST_NAME_MISSING = 'Please enter the last name.';
    global final static String APPL_LOAN_AMOUNT_MISSING = 'Please enter the loan amount.';
    global final static String APPL_ENTITY_TYPE_MISSING = 'Please choose the Applicant Entity.';
    global final static String APPL_ADDRESS_MISSING = 'Please enter the address.';
    global final static String APPL_CITY_MISSING = 'Please enter the city.';
    global final static String APPL_STATE_MISSING = 'Please enter the state.';
    global final static String APPL_COUNTY_MISSING = 'Please enter the county.';
    global final static String APPL_EMAIL_MISSING = 'Please enter the Email.';
    global final static String APPL_PHONE_MISSING = 'Please enter the Phone Number.';
    global final static String APPL_ZIP_CODE_MISSING = 'Please enter the ZIP code.';
    global final static String APPL_MARITAL_STATUS_MISSING = 'Please enter the Marital Status.';
    global final static String APPL_ZIP_CODE_INVALID = 'Invalid ZIP code.';
    global final static String APPL_SSN_MISSING = 'Please enter the Social Security Number.';
    global final static String APPL_CONFIRM_SSN_MISSING = 'Please enter the Confirm Social Security Number.';
    global final static String SSN_CONFIRM_SSN_MISMATCH = 'The Confirm SSN does not match the SSN.';
    global final static String APPL_DATE_OF_BIRTH_MISSING = 'Please enter the date of birth.';
    global final static String APPL_TOTAL_ASSETS_MISSING = 'Please enter the total assets.';
    global final static String APPL_TOTAL_LIABILITIES_MISSING = 'Please enter the total liabilities.';
    global final static String APPL_TOTAL_ASSETS_EXCEPTION = 'Total Assets should be greater than Total Liabilities.';
    global final static String CO_APPLICANT_FILEDS_MISSING ='Please fill in all the Mandatory fields for CoApplicants.';
    global final static String CO_APPL_FIRST_NAME_MISSING = 'Please enter the first name of the Co-Applicant.';
    global final static String CO_APPL_LAST_NAME_MISSING = 'Please enter the last name of the Co-Applicant.';
    global final static String CO_APPL_ADDRESS_MISSING = 'Please enter the address of the Co-Applicant.';
    global final static String CO_APPL_CITY_MISSING = 'Please enter the city of the Co-Applicant.';
    global final static String CO_APPL_STATE_MISSING = 'Please enter the state of the Co-Applicant.';
    global final static String CO_APPL_COUNTY_MISSING = 'Please enter the county of the Co-Applicant.';
    global final static String CO_APPL_ZIP_CODE_MISSING = 'Please enter the ZIP code of the Co-Applicant.';
    global final static String CO_APPL_MARITAL_STATUS_MISSING = 'Please enter the Marital Status of the Co-Applicant.';
    global final static String CO_APPL_SSN_MISSING = 'Please enter the Social Security Number of the Co-Applicant.';
    global final static String CO_APPL_DATE_OF_BIRTH_MISSING = 'Please enter the date of birth for Co-Applicant.';
    global final static String CO_APPL_TOTAL_ASSETS_MISSING = 'Please enter the total assets of the Co-Applicant.';
    global final static String CO_APPL_TOTAL_LIABILITIES_MISSING = 'Please enter the total liabilities of the Co-Applicant.';
    global final static String APPL_EXISTING_BORROWER_MISSING = 'Please select an existing Borrower.';
    global final static String APPL_NAME_MISSING = 'Please enter the Name.';
    global final static String APPL_TAX_ID_MISSING = 'Please enter the TAX Id.';
    global final static String CO_APPLICANT_EXCEPTION ='Please fill in all the Mandatory fields for CoApplicants.';
    global final static String APPL_MOBILE_MISSING ='Please enter at least one contact number for Primary Applicant.';
    global final static String APPL_MOBILE_MISSING_COAPPLICANT ='Please enter at least one contact number for Co-Applicant';
    global final static String DUPLICATE_SSN ='A user already exists with the same Social Security Number.';
    global final static String DUPLICATE_TIN ='A user already exists with the same Tax Identification Number.';
    global final static String SCORE_BEFORE_SUBMIT = 'Application must be scored prior to submitting';
    global final static String SUSPENDED_LOAN = 'Your loan is currently suspended. You cannot make any advances.';
    global final static String SUSPENDED_LOANS = 'Your loan is currently suspended. You cannot make any advances';
    global final static String COMPLETE_ADDITIONAL_INFO = 'Please complete the Additional Information Task to proceed with the Application';
    global final static String COLLATERAL_ERROR = 'Please add collaterals to match the loan amount';
    global final static String SUBMITTED_WITHOUT_APPLICANT_INFO = 'Please fill out the Applicant Information properly before submitting the application';
    global final static String BORROWER_PARTY_LIST_EMPTY_ERROR = 'Borrower Party Was Not Found for this Application';
    global final static String PRINCIPAL_PARTY_LIST_EMPTY_ERROR = 'Principal Details were not found for this Application. Please Check the principal Details';
    global final static String CROP_INFO_PRICE_NULL_ERROR = 'Please add crop information before submitting the application';
    global final static String CO_APPLICANT_MISSING = 'Please add a Co-Applicant';
    global final static String DUPLICATE_USER ='A user already exists with the same details.';
    global final static String USER_EXIST_IN_SAME_DEALER ='A user already exists. Please try searching the grower.';
    global final static String DUPLICATE_SSN_OR_EMAIL ='A user already exists with the same Email or Social Security Number.';
    global final static String CHECK_SUSPENSE_BALANCE_ERROR = 'Suspense must be cleared on all loans before an advance can be made on the Available funds.';
    global final static String LESS_NETWORTH_ERROR = 'Networth cannot be less than the Loan Amount for Evergreen Loans.';
    public static final String NO_PARTY_FOUND = 'No Party Found';
    public static final String SIGNING_METHOD_MISSING = 'Signing Method Missing';
    public static final String SIGNING_METHOD_IS_NOT_EMAIL_DOCUSIGN = 'Signing Method is not Email Docusign for This Application';
    public static final String LOAN_IS_NOT_EVERGREEN_ELIGIBLE = 'Loan is not evergreen eligible.';
    public static final String SAME_NEW_EMAIL_AND_OLD_EMAIL = 'The new email is same as the previous email';
    public static final String WRONG_SSN_OR_TIN = 'The information entered does not match, please try again.';
    public static final String EMAIL_CHANGE_ALREADY_VERIFIED = 'Email Change Request is Already Verified';
    public static final String VERIFICATION_LINK_EXPIRED = 'Verification Link has Expired';
    public static final String MISSING_SSN_OR_TIN = 'Email Change Request cannot be initated as grower\'s SSN/TIN is missing';
    public static final String INVALID_EMAIL_CHANGE_REQUEST = 'Invalid Email Change Request';
    public static final String MAX_ATTEMPT_REACHED = 'All Verification Attempts Exhausted';
    public static final String ASSERTION_FAILED = 'Assertion Failed';
    public static final String SIGNING_METHOD_IS_MISSING = 'Please complete the signature process on the Applicant Signature tab prior to submitting this application.';
    public static final String DEALER_CUSTOMISE_LIMIT_EXCEEDED = 'Please contact CFA if you\'d like to customize.';
    public static final String INVALID_SSN = 'Please enter valid Social Security Number.';
    public static final String INVALID_TAX_ID = 'Please enter valid TAX Id.';
    public static final String STATE_OF_INCORPORATION_MISSING = 'Please enter the State of Incorporation';
    
    //Additional Info Error messages
    global final static String SPOUSE_NAME_MISSING = 'First and Last Name of Spouse is Mandatory.';
    global final static String SPOUSE_DETAILS_MISSING = 'Please enter all the following Spouse Details.';
    global final static String SPOUSE_DETAILS_NOT_ENTERED = 'Please enter the Spouse Details.';
    global final static String LANDOWNER_NAME_MISSING = 'Please enter Landowner\'s full name.';
    global final static String LANDOWNER_DETAILS_MISSING = 'Please complete Landowner\'s Details.';
    global final static String BUYER_NAME_MISSING = 'Please enter Buyer\'s full name.';
    global final static String BUYER_DETAILS_MISSING = 'Please enter complete Potential Buyer\'s details.';
    global final static String AGENCY_NAME_MISSING = 'Please enter the Agency name.';
    global final static String AGENCY_DETAILS_MISSING = 'Please enter complete Agency details';
    global final static String EXISTING_BUYER_ERROR = 'Please select a Potential Buyer';

    //Bank Information Error Message
    global final static String ACCOUNT_NUMBER_MISSING = 'Please add your Bank Account Number to proceed';
    global final static String ACCOUNT_NAME_MISSING = 'Please add your Bank Account Name to proceed';
    global final static String ACCOUNT_ROUTING_NUMBER_MISSING = 'Please add your Bank Routing Number to procees';
    global final static String GROWER_NOT_AUTHORIZED_TO_DELETE = 'You are not authorised to delete the record.';

    //Configs
    global final static String DEALER_PARTY_NAME = 'DEALER';
    global final static String BORROWER_PARTY_NAME = 'BORROWER';
    global final static String PRINCIPAL_PARTY_NAME = 'PRINCIPAL';
    global final static String SPOUSE_PARTY_NAME = 'SPOUSE';
    global final static String LANDOWNER_PARTY_NAME = 'LANDOWNER';
    global final static String INSURANCE_AGENT_PARTY_NAME = 'INSURANCE AGENT';
    global final static String CL_PARTY_NAME = 'CERTIFIED LENDER';
    global final static String CL_PLUS_PARTY_NAME = 'CERTIFIED LENDER PLUS';
    global final static String SALES_AGENT_PARTY_NAME = 'SALES AGENT';
    global final static String SALES_AGENT_PLUS_PARTY_NAME = 'SALES AGENT PLUS';
    global final static String INQUIRY_PLUS_PARTY_NAME = 'INQUIRY PLUS';
    global final static String INQUIRY_PARTY_NAME = 'INQUIRY';
    global final static String BUYER_PARTY_NAME = 'BUYER';
    global final static String GROWER_PROFILE = 'Grower';
    global final static String GMK_GROWER_PROFILE = 'Growmark Grower';
    global final static String CO_APPLICATION_RECORD_TYPE = 'CoApplicant';
    global final static String DEALER_PROFILE = 'Dealer';
    global final static String CERTIFIED_LENDER ='Certified Lender';
    global final static String CERTIFIED_LENDER_PLUS ='Certified Lender Plus';
    public final static String PAYMENT_ADMINISTRATOR = 'Payment Administrator';
    public final static String PAYMENT_ADMINISTRATOR_PARTY = 'PAYMENT ADMINISTRATOR';
    global final static String FIELD_STAFF_AGENT_PARTY ='FIELD STAFF AGENT';
    global final static String FIELD_STAFF_AGENT ='Field Staff Agent';
    global final static String SALES_AGENT ='Sales Agent';
    global final static String SPOUSE ='Spouse';
    global final static String RELATED_SALES_AGENT ='Related Sales Agent';
    global final static String SALES_AGENT_ADMIN ='Sales Agent Admin';
    global final static String SALES_AGENT_ADMIN_PARTY ='SALES AGENT ADMIN';
    global final static String SALES_AGENT_PLUS ='Sales Agent Plus';
    global final static String INQUIRY ='Inquiry';
    global final static String INQUIRY_PLUS ='Inquiry Plus';
    global final static String PRODUCT_TYPE_FOR_MY_PROGRAM = 'LOAN';
    global final static String REPLACE_LOAN_NUMBER = '{!LoanNumber}';
    global final static String REPLACE_DEALER_NAME = '{!DealerName}';
    global final static String REPLACE_DEALER_CITY = '{!DealerCity}';
    global final static String REPLACE_DEALER_STATE = '{!DealerState}';
    global final static String REPLACE_GROWER_NAME = '{!GrowersName}';
    global final static String REPLACE_GROWER_CITY = '{!Grower City}';
    global final static String REMOVE_GROWER_CITY = ', {!Grower City}';
    global final static String REPLACE_GROWER_STATE ='{!Grower State}';
    global final static String REMOVE_GROWER_STATE =', {!Grower State}';
    global final static String REPLACE_SALES_AGENT_NAME = '{!SalesAgentName}';
    global final static String REPLACE_APPLICATION_ID = '{!ApplicationId}';
    global final static String REPLACE_APPLICATION_ID_LINK = '{!ApplicationIdLink}';
    global final static String REPLACE_CERTIFIED_LENDER_NAME = '{!CertifiedLenderName}';
    global final static String REPLACE_INTERNAL_REFERENCE_CODE = '{!InternalReferenceCode}';
    public static final String REPLACE_MATURITY_DATE = '{!MaturityDate}';
    public static final String REPLACE_LOAN_AMOUNT = '{!LoanAmount}';
    public static final String REPLACE_LOGO_URL = '{!logoURL}';
    global final static String MY_PROGRAM_FACTOR_NAME = 'Program';
    global final static String FACTOR_EVALUATION_OPERATOR = '==';
    global final static String APPLICATION_API_NAME = 'genesis__Applications__c';
    global final static String APPLICATION_OBJECT_NAME = 'Application';
    global final static String MY_PROGRAM_FIELD_API_NAME = 'My_Program__r.Name';
    global final static String FIELD_TYPE = 'STRING';
    global final static String MY_PROGRAM_FIELD_NAME ='My Program';
    global final static String APPLICATION_ID = 'applicationId';
    global final static String APPLICATION_FIELD_NAME = 'Rate Card Name';
    global final static String DEALER_NAME = 'Dealer Name';
    global final static String MY_PROGRAM_DEALER_FIELD = 'Dealer_Name__r.Name';
    global final static String INTEREST_RATE_STRING = 'INTEREST RATE';
    global final static String FLEXRATE_ERROR = 'Flex Rate Card generation error';
    global final static String NOTE_RATE = 'Note Rate';
    global final static String RATE_CARD_STRING = 'RATE CARD';
    global final static String ALL_APPLICATION = 'allApplications';
    global final static String INCOMPLETE_STATUS = 'incompleteStatus';
    global final static String REVIEW_STATUS = 'reviewStatus';
    global final static String PENDING_STATUS = 'pendingStatus';
    global final static String BOOKED_STATUS = 'bookedStatus';
    global final static String E_SIGN_PENDING = 'eSignPending';
    global final static String PAPER_SCANNED_PENDING = 'paperScannedPending';
    global final static String E_SIGN_COMPLETE = 'eSignComplete';
    global final static String SCORED = 'scored';
    global final static String ACTIVE_STATUS = 'active';
    global final static String CLOSED_STATUS = 'closed';
    global final static String CURRENT_CROP_YEAR = 'currentCropYear';
    global final static String PRIOR_CROP_YEAR = 'priorCropYear';
    global final static String PAST_DUE = 'pastDue';
    global final static String EVERGREEN_ELIGIBLE = 'evergreenEligible';
    global final static String EVERGREEN_RENEWAL = 'evergreenRenewal';
    global final static String WITHDRAWN = 'withdrawn';
    global final static String EXPIRED = 'expired';
    global final static String DENIED = 'denied';
    global final static String TIER_1_CREDIT = 'Tier 1';
    global final static String TIER_2_CREDIT = 'Tier 2';
    global final static String TIER_THREE_CREDIT = 'Tier 3';
    global final static String CUSTOMIZE_LOAN = 'Customize';
    global final static String IN_PERSON_DOCUSIGN = 'In Person - Docusign';
    global final static String EMAIL_DOCUSIGN = 'Email - Docusign';
    global final static String NOT_SUBMITTED_MY_PROGRAM = 'Not Submitted';
    global final static String SUBMITTED_MY_PROGRAM = 'Submitted - Pending Approval';
    global final static String MY_PROGRAM_QUEUE = 'Approve My Program Queue';
    public static final String LOAN_NUMBER = 'loanNumber';
    public static final String LOAN_AMOUNT = 'loanAmount';
    public static final String GROWER_NAME = 'growerName';
    public static final String KEY_GROWER_CITY = 'growerCity';
    public static final String KEY_GROWER_STATE = 'growerState';
    public static final String LOAN_ID = 'loanId';
    public static final String SPECIAL_TERM_A = 'Special Term Sub-Tranche (A)';
    public static final String SPECIAL_TERM_B = 'Special Term Sub-Tranche (B)';
    public static final String SPECIAL_TERM_C = 'Special Term Sub-Tranche (C)';
    public static final String SPECIAL_TERM_D = 'Special Term Sub-Tranche (D)';
    public static final String SPECIAL_TERM_E = 'Special Term Sub-Tranche (E)';
    public static final String SPECIAL_TERM_F = 'Special Term Sub-Tranche (F)';
    public static final String SPECIAL_TERM_G = 'Special Term Sub-Tranche (G)';
    public static final String SPECIAL_TERM_H = 'Special Term Sub-Tranche (H)';
    public static final String MASTER_NOTERATE_A = 'NoteRate';
    public static final String SUB_TRANCHE_B = 'SpecialTermB';
    public static final String SUB_TRANCHE_C = 'SpecialTermC';
    public static final String SUB_TRANCHE_D = 'SpecialTermD';
    public static final String SUB_TRANCHE_E = 'SpecialTermE';
    public static final String SUB_TRANCHE_F = 'SpecialTermF';
    public static final String SUB_TRANCHE_G = 'SpecialTermG';
    public static final String SUB_TRANCHE_H = 'SpecialTermH';
    public static final Integer MATURITY_DATE_DAY = 15;
    public static final Integer MAXIMUM_PROGRAMS_IN_A_CROPYEAR = 3;
    public static final Integer MAXIMUM_SPECIAL_TRANCHES_NUMBER = 5;
    public static final Decimal MAXIMUM_CFA_PARTICIPATION = 1.5;
    public static final String ASSIGN_BILLING_DATE = 'assignBillingDate';
    public static final String BILLING_DATE = 'billingDate';
    public static final String ACH = 'ACH';
    public static final String DRAFT = 'DRAFT';
    public static final String STANDARD_USER_TYPE = 'STANDARD';


    //My Program Error message
    global final static String DESCRIPTION_ERROR = 'Please enter the description for all the added Sub-Tranches.';
    global final static String CROP_YEAR_VALIDATION = 'Please add only three My Programs for a specific crop year.';
    global final static String LAST_DATE_VALIDATION = 'The End Date of a rate should be on the last day of a month';
    global final static String MAXIMUM_SPECIAL_TERM_ERROR = 'You cannot enter more than 4 Special Term Interest Rates';
    global final static String CROP_YEAR_ELIGIBLE_ERROR = 'Eligible Crop Years: '+System.today().Year()+' And '+System.today().addYears(1).Year();
    global final static String CROP_YEAR_ELIGIBLE_ERROR_JAN_MAY = 'Eligible Crop Year: '+System.today().Year();
    global final static String CROP_YEAR_ELIGIBLE_ERROR_JUN_AUG = 'Eligible Crop Years: '+System.today().Year()+' And '+System.today().addYears(1).Year();
    global final static String CROP_YEAR_ELIGIBLE_ERROR_SEP_DEC = 'Eligible Crop Years: '+System.today().addYears(1).Year();
    global final static String CLOSING_FEE_EXCEEDED = 'Dealer Participation exceeds the CFA Loan Closing Fee';
    global final static String MATURITY_DATE_ON_15 = 'Please Check Whether Maturity Date is on 15th of the Month';
    global final static String START_DATE_CHECK = 'The Start Date of an additional Special Term rate must begin the next day following the End Date of the previous Special Term';
    global final static String LAST_DATE_PASSED_MATURITY = 'The End Date of a Special Term Rate cannot pass the Maturity Date';
    global final static String PRIOR_MONTH_CHECK = 'The End date of a Special Term Rate cannot be on the month prior to the maturity date';
    global final static String LAST_END_DATE_CHECK_MATURITY = 'End Date for the last Special Term Rate entered must match the Maturity Date: ';
    global final static String PREMIUM_AND_SUBSIDY_CHECK = 'You cannot save Dealer Premium % and Dealer Subsidy % together';
    global final static String EXCEEDS_NUMBER_OF_RATES = 'You can add 1 Note Rate and 4 Special Term Sub-Tranches';
    global final static String MAXIMUM_SPL_TRANCHES = 'You can add upto 5 Special Term Rate under a Special Term Sub Tranche';
    global final static String MY_PROGRAM_AUTH = 'Dealer is not authorised to delete this My Program';
    global final static String SPECIAL_TERM_SUB_TRANCHE_AUTH = 'Dealer is not authorised to delete this Special Term Sub Tranche';
    global final static String DELETE_MY_PROGRAM_INVALID = 'Deleting this Special Term Rate will make the My Program invalid for: ';
    global final static String FLEX_RATE_END_DATE_CHECK = 'Please check whether each End Date matches the maturity date :';
    global final static String  CLONE_MATURITY_DATE_ERROR = 'Maturity Date cannot be a past date';
    global final static String  SUB_TRANCHE_NULL_ERROR = 'Please add at least one Special Sub Tranche';
    global final static String  CROP_YEAR_NULL_ERROR = 'Please provide a crop year for the My Program';
    global final static String MATURITY_DATE_EXCEEDED_ERROR = 'The Maturity date for the selected Crop Year cannot exceed: 03/15/';
    global final static String MATURITY_DATE_CURRENTYEAR_ERROR ='Please verify the maturity date. The possible maturity dates for the given crop year are : ';
    global final static String CHECK_START_DATE_OF_EVERY_TRANCH = 'Start date of every special-term tranche must be same';
    global final static String LOAN_FEE_ADVANCED_ON = 'Loan fee advanced on must be a special-term tranche';
    global final static String MATURITY_DATE_ERROR = 'The maturity date must be 15th of any month of the selected crop year that is from ';
    global final static String MATURITY_DATE_ERROR_EXTENDED = ' to ';
    global final static String BILLING_DATE_TODAYS_DATE_CHECK = 'Billing date cannot be less than today\'s date';
    global final static String BILLING_DATE_MATURITY_DATE_CHECK = 'Billing date must be less than or equal to maturity date';
    global final static String BILLING_DATE_IS_NOT_LAST_DAY = 'Billing date must be last day of the month.';

    //Pay off & Making Payment error
    global final static String OVER_PAYMENT_ERROR = 'You are making an over payment. Your current due is : $';
    global final static String PAY_OFF_AMOUNT_INACURATE = 'Please match the Total Due Amount to Pay off your loan'; 
    global final static String PREVIOUS_LOAN_PAYOFF_ERROR = 'Your previous Crop Year loan must be paid in full prior to accepting payments to this loan';
    global final static String INVALID_BANK = 'Invalid Bank Account Details';

    //Application Defaults
    global final static Integer INTEREST_RATE = 0;
    global final static Integer TERM = 12;
    global final static String PACKAGE_TYPE = 'PACKAGE';
    global final static String LOAN_TYPE = 'LOAN';
    global final static String SIMPLIFY_TYPE = 'Simpli-Fi';
    global final static String CROP_INPUT_ADVANTAGE_TYPE = 'Crop Input Advantage';
    global final static String DEFAULT_BORROWER_NAME = 'Borrower Account';
    global final static String INDIVIDUAL_ENTITY = 'Individual(s) with DBA';
    global final static String INDIVIDUAL = 'Individual';
    global final static String SOLE_PROP_ENTITY = 'Individual(s) - Sole Proprietorship';
    global final static String GENERAL_PARTNERSHIP = 'General Partnership';
    global final static String LIMITED_PARTNERSHIP = 'Limited Partnership';
    global final static String TRUST = 'Trust';
    global final static String LIMITED_LIABILITY_COMPANY = 'Limited Liability Company';
    global final static String JOINT_VENTURE = 'Joint Venture';
    global final static String NEW_SUBMITTED ='NEW-SUBMITTED';
    global final static String DEALER_NOTE_TITLE ='Dealer Note';

    //Application Status
    global final static String BOOK_TO_CORE_APPLICATION_STATUS = 'BOOKED TO CORE';
    global final static String PENDING_WITHDRAWAL_APPLICATION_STATUS = 'PENDING WITHDRAWAL';
    global final static String WITHDRAWN_APPLICATION_STATUS = 'WITHDRAWN';
    global final static String E_SIGN_PENDING_APPLICATION_STATUS = 'SIGNATURE PENDING';
    global final static String E_SIGN_COMPLETED_APPLICATION_STATUS = 'SIGNATURE COMPLETED';
    global final static String NEW_ENTERED_APPLICATION_STATUS = 'NEW - ENTERED';
    global final static String EXPIRED_APPLICATION_STATUS = 'EXPIRED';
    global final static String NEW_SUBMITTED_APPLICATION_STATUS = 'NEW-SUBMITTED';
    global final static String NEW_SCORECARD_APPLICATION_STATUS = 'NEW - SCORECARD GENERATED';
    global final static String REJECTED_APPLICATION_STATUS = 'DENIED';
    global final static String PENDING_APPROVAL_APPLICATION_STATUS = 'PENDING APPROVAL';
    global final static String ACTIVE_APPLICATION_STATUS = 'ACTIVE';
    global final static String CLOSED_APPLICATION_STATUS = 'CLOSED';
    global final static String APPROVED_APPLICATION_STATUS = 'APPROVED - APPROVED';
    global final static String CROP_INFORMATION ='Crop Information';
    global final static String APPLICANT_SIGNATURE ='Applicant Signature';
    global final static String APPLICANT_INFORMATION = 'Applicant Information';
    global final static String SCORE_CREDIT_REFERENCE ='Scoring & Credit Reference';
    global final static String PAPER_SCANNED = 'Paper - Scanned';
    global final static String GROWER_STATE='{!GrowerState}';
    global final static String GROWER_CITY='{!GrowerCity}';
    global final static String SIGNATURE_PENDING = 'SIGNATURE PENDING';


    //Task Status
    global final static String ADDITIONAL_INFO_TASK = 'Additional Information Form';
    global final static String ENTITY_DOC_TASK = 'Entity Documents';
    global final static String COMPLETED_TASK_STATUS = 'Completed';
    global final static String OPEN_TASK_STATUS = 'Open';
    global final static String SIGNED_AGREEMENT_TASK = 'Signed Credit Agreement';
    global final static String LIEN_SUBORDINATION_TASK = 'Lien Subordination';
    global final static String CUSTOMIZED_LOAN_TASK = 'Customized Loan Approval';
    global final static String AOI_TASK = 'Assignment of Insurance';
    global final static String SPOUSAL_CONSENT_TASK = 'Spousal Consent';
    global final static String NTB_TASK = 'Notice of Security Interest';
    global final static String NTB_TASK_CFA_ACTION ='Notice of Security Interest (CFA Action)';
    global final static String WITHDRAWAL_FORM_TASK = 'Withdrawal Form';
    global final static String COLLATERAL_REPORT_TASK = 'Collateral Report';
    global final static String DRIVING_LICENSE_TASK = 'Driver\'s License';
    global final static String PAYOFF_CONFIRMATION_TASK ='Confirmation of Payoff (CFA Action)';
    global final static String LIEN_SEARCH_TASK ='Lien Search (CFA Action)';
    global final static String UCC_FILING_TASK ='UCC Filing (CFA Action)';
    global final static String UCC_AMENDMENT_TASK ='UCC Amendment (CFA Action)';
    global final static String CNS_TASK ='Signed Central Notification System (CNS) Form (CFA Action)';

    //Custom labels
    global final static String TEST_MAIL = system.label.TestEmail;
    global final static String SENDER_DISPLAY_NAME = system.label.EMAIL_SENDER_DISPLAY_NAME;
    public static final String MATURITY_DATE_EMAIL_TEMPLATE = system.label.Email_Maturity_Date;
    global final static String DIFFERENCE_BETWEEN_STARTDATE = system.label.Start_date_difference;
    global final static String CREDIT_REFERENCE_EMAIL_TEMPLATE = system.label.EMAIL_FOR_CREDIT_REFERENCE;
    public static final String MODIFIED_LOAN_AMOUNT_EMAIL_TEMPLATE = system.label.Email_For_Modified_Loan_Amount;
    global final static String APPLICATION_WITHDRAWN_EMAIL_TEMPLATE = system.label.EMAIL_FOR_APPLICTION_WITHDRAWN;
    global final static String GROWER_CREDIT_REFERENCE_EMAIL_TEMPLATE = system.label.EMAIL_FOR_CREDIT_REFERENCE_BY_GROWER;
    global final static String LOAN_LIMIT_FOR_AUTO_BOOKING = System.Label.Loan_Limit_For_Auto_Booking;
    global final static String LANDUS_DEALER_CIF = System.Label.LANDUS_DEALERS;
    global final static String GROWER_EVERGREEN_ELIGIBILITY_BATCH_SIZE = System.label.GROWER_EVERGREEN_ELIGIBILITY_BATCH_SIZE;
    global final static String CODE_FOR_NOSCORE_APPLICANT = System.label.Code_for_NoScore_Applicant;
    global final static String USERS_WITH_PERMISSION_TO_SUBMIT_APPLICATION = System.label.Users_With_Permission_To_Submit_Application;

    //DocuSign
    global final static String AGREEMENT_FILE_NAME = 'Credit Application Agreement.pdf';
    global final static String CUSTOMIZED_FORM_FILE_NAME = 'Customized Loan Approval.pdf';
    global final static String BORROWER_SIGNED_BY = 'Signed By  :';
    global final static String SIGNED_BY = 'Signed By';
    global final static String SIGN_BY = ':';
    global final static String SIGNER = 'Signer 1';
    global final static String INITIAL = 'INTT';
    global final static String CFA_SIGNED_BY = 'CFA_SIGN';
    global final static String CORPORATION = 'Corporation';
    global final static String ENVELOPE_STATUS = 'Sent';
    global final static String ENVELOPE_STATUS_DELIVERED = 'Delivered';
    global final static String ENVELOPE_STATUS_CREATED = 'Created';
    global final static String ENVELOPE_STATUS_COMPLETED = 'Completed';
    global final static String PARTY_STATUS_PENDING = 'E-Sign Pending';
    global final static String PARTY_STATUS_COMPLETED = 'E-Sign Completed';
    global final static String PARTY_STATUS_DECLINED = 'Declined to E-Sign';
    public final static String SIGNATURE_ONE = 'Signature1';
    public final static String INTT_ONE = 'INTT1';

    global final static String NO_AGREEMENT_FOUND = 'No Credit Application Agreement has been generated yet. Please try again after sometime.'; 
    global final static String NO_CUSTOMIZED_FORM_FOUND = 'No Customized Form has been generated yet. Please try again after sometime.'; 
    global final static String NO_WITHDRAWAL_FORM_FOUND = 'No Withdrawal Form has been generated yet. Please try again after sometime.'; 
    global final static String NO_DOCUMENT_FOUND = 'No document found.'; 
    global final static String URL = 'https://ayushdev-cooperative-finance.cs203.force.com';
    global final static String USER = 'AllUsers';
    global final static String EMBEDDED_FIELD='Embedded_DocuSign_URL__c';
    global final static String LIEN_SUBORDINATE = 'Lien Subordination';
    global final static String CUSTOMISED_FORM = 'Customized Loan Approval';
    global final static String AOI_CROP = 'AOI Crop';
    global final static String SPOUSAL_CONSENT = 'Spousal Consent';
    global final static String NTB_LETTER = 'NTB';
    global final static String WITHDRAWAL_FORM = 'Withdrawal Form';
    global final static String MODIFICATION_AGREEMENT = 'Modification Agreement';
    global final static String LOAN_COMMITMENT_LETTER = 'Loan Commitment Letter';
    global final static String LOAN_COMMITMENT_LETTER_FILE_NAME = 'Loan Commitment Letter.pdf';

    // Export
    global final static String NO_DATA_TO_EXPORT = 'No data to export.';
    
    // Bank 
    global final static String BANK_NAME_MISSING = 'Bank name is missing.';
    global final static String BANK_PHONE_MISSING = 'Bank phone number is missing.';
    global final static String BANK_ADDR_MISSING = 'Bank address is missing.';
    global final static String BANK_CITY_MISSING = 'Bank city is missing.';
    global final static String BANK_STATE_MISSING = 'Bank state is missing';
    global final static String BANK_ZIP_MISSING = 'Bank postal code is missing.';
    global final static String BANK_ROUTING_NUM_INVALID = 'Bank routing number is invalid.';

    global final static String BANK_RECORDS_MISSING = 'No bank information provided.';
    global final static String BANK_ACCOUNT_NUM_DUPLICATE = 'You have already added a Bank account with the account number: ';
    global final static String BANK_ROUTING_NUM_DUPLICATE = 'You have already added a Bank account with the routing number: ';
    global final static String BANK_ACCOUNT_NUM_EXISTS = 'Bank Account number already exists.';
    global final static String BANK_ROUTING_NUM_EXISTS = 'Bank Routing number already exists.';

    // Request for advance
    global final static String INVALID_PAYMENT_MODE = 'Invalid payment mode.';
    global final static String EXCEEDED_PAYMENT = 'The Payment Amount is Greater than the Total due';
    global final static String UNEQUAL_PAYOFF = 'The Payment Amount and the Total due does not match.';
    
    //Product Return
    global final static String PRODUCT_RETURN = 'PRODUCT RETURN';
    global final static String PRODUCT_RETURN_NOT_ALLOWED='Product Return are not allowed after 26th of the month prior to the Maturity Date';
    global final static String PRODUCT_RETURN_NOT_ALLOWED_IN_MONTH_OF_MATURITY_DATE='Product Return are not allowed in the month of Maturity Date';
    global final static String PAST_MATURITY_DATE='Product Return are not allowed for the past Maturity Date';
    global final static String PRODUCT_RETURN_MUST_LESS_THAN_PRINCIPAL_BALANCE='Product return must be less than or equal to the Principal Balance for the sub-tranche selected.';
    global final static String PAST_DUE_LOAN='Product Return cannot be done on Past Due Loans.';
    global final static String ACH_AUTHORIZATION_ERROR = 'No ACH Authorization Agreement on file. Contact loanaccounting@cfafs.com for a copy of the agreement form.';
    global static final String CONTENT_DOC_LINK_EXP = 'No Content Document Found';
    global static final String CATEGORY_ATTACHMENT_EXP = 'No Category Attachment Found';
    global static final String INVALID_PARAMS = 'Arguments not found';
    global static final String DOCUMENT_ID_NULL = 'No Document Id Found';
    // Withdrawal
    global final static String WITHDRAWAL_FORM_FILE_NAME = 'Withdrawal Form.pdf';
    
    //Email Template
    global final static String RESERVE_AMOUNT_EMAIL='Change in Reserve Amount Notification';
    global final static String PENDING_AMOUNT_DELETE='Grower Deletes Pending Online Payment (SF to Loan Accounting)';
    global final static String GROWER_COMPLETE_APPLICATION='GROWER WITH ONLINE ACCESS';
    public final static string EMAIL_TEMPLATE_TO_GROWER = 'Application Withdrawal by Dealer on Behalf of the Grower Notification';
    public final static string EMAIL_TEMPLATE_TO_CL = 'APPLICATION WITHDRAWAL BY GROWER NOTIFICATION';
   
       
    // DealerPayoffAPI 
    global final static String APPLICATION_ERROR = 'Application could not be fetched ';
    global final static String NULL_ACCOUNT_ERROR = 'No accounts found for the application ';
    global final static String EMAIL_TEMPLATE_ERROR = 'Email template could not be fetched ';

    // Growmark constants
    global final static String GROWMARK_COOP_TYPE = 'Growmark';
    global final static String GREYLABEL_COOP_TYPE = 'Gray Label';
    global final static String WHITE_LABEL_COOP_TYPE = 'White_Label_User';
    global final static String GREY_LABEL_COOP_TYPE = 'Gray_Label_User';
    global final static String BOTH_COOP_TYPE = 'All';
    global final static String CFA_COOP_TYPE = 'CFA';
    global final static String LANDUS_COOP_TYPE = 'Landus';
    global final static String FCSA_COOP_TYPE = 'FCSA PRIVATE';


    // Growmark My Program Constants
    public static final String PROGRAM = 'program';
    public static final String FIELD_CROP_YEAR = 'Crop_Year__c';
    public static final String FIELD_NAME = 'Name';
    public static final String FIELD_MATURITY_DATE = 'genesis__End_Date__c';
    public static final String FIELD_PAYER = 'Payer_of_Loan_Closing_Fee__c';
    public static final String FIELD_ADVANCEON = 'Loan_Fee_Advanced_On__c';
    public static final String FIELD_DEALER_PART = 'Dealer_Participate_on_Closing_Fee__c';
    public static final String FIELD_FEE_PORTION = 'Portion_of_Fee_to_Cover__c';
    public static final String FIELD_CFA_ADV = 'CFA_Advantage_Rate__c';
    public static final String FIELD_FS_IDX = 'FS_Index_Rate__c';
    public static final String FIELD_CLOSING_FEE = 'Closing_Fee__c';
    public static final String FIELD_ID = 'Id';
    public static final String AFFIRMATIVE = 'Yes';
    public static final String NEW_RECORD_STRING = 'new_record_id';
    public static final String NEGATIVE_STRING = 'No';
    public static final String LOAN_STRING = 'Loan';
    public static final String OBJECT_RATE = 'genesis__Rate_Card_Setup_Header__c';
    public static final String SPL_SUB_TRANCHE_STRING = 'Special Term Sub-Tranche (';

    public static final Integer MONTH_AUGUST = 8;
    public static final Integer MONTH_DECEMBER = 12;
    public static final Integer MONTH_JANUARY = 1;
    public static final Integer MONTH_FEBRUARY = 2;
    public static final Integer MONTH_MARCH = 3;
    public static final String MATURITY_AUG = '08/15/';
    public static final String MATURITY_DEC = '12/15/';
    public static final String MATURITY_JAN = '01/15/';
    public static final String MATURITY_FEB = '02/15/';
    public static final String MATURITY_MAR = '03/15/';

    public static final String KEY_SHOULD_VALIDATE = 'shouldValidate';
    public static final String FLEXPRICING = 'flexPricing';
    public static final String FLEXPROGRAM = 'flexRateProgram';
    public static final String MYPROGRAMID = 'myProgramId';
    public static final String RATEPRICING = 'ratePricing';
    public static final String FLEX_PRICE_STRING = ' Flex Price';
    public static final String FIELD_DESCRIPTION = 'Description__c';
    public static final String FIELD_CFA_PARTICIPATION = 'Participation_Percentage_CFA__c';
    public static final String FIELD_INTEREST_TYPE = 'Interest_Rate_Type__c';
    public static final String FIELD_PREMIUM = 'Participation_Percentage_Dealer__c';
    public static final String FIELD_SUBSIDY = 'Participation_Percentage_Dealer_Subsidy__c';
    public static final String FIELD_STARTDATE = 'Start_Date__c';
    public static final String FIELD_ENDDATE = 'End_Date__c';
    public static final String FIELD_INTEREST_RATE = 'genesis__Interest_Rate__c';
    public static final String INTEREST_KEY = 'interest';

    public static final List<String> STRING_JAN_TO_MAY = new List<String> {'1','2','3','4','5'};
    public static final List<String> STRING_JUN_TO_AUG = new List<String> {'6','7','8'};
    public static final List<String> STRING_SEP_TO_DEC = new List<String> {'9','10','11','12'};

    // public static final List<String> stringJanToMay = new List<String> {'1','2','3','4','5'};
    // public static final List<String> stringJuneToAug = new List<String> {'6','7','8'};
    // public static final List<String> stringSepToDec = new List<String> {'9','10','11','12'};
   
    //Reports Constants
    public static final String KEY_DATA_TYPE = 'dataType';
    public static final String KEY_BATCH_ID = 'batchId';
    public static final String KEY_REPORT_TYPE = 'reportType';
    public static final String KEY_EXPORT_TYPE = 'exportType';
    public static final String KEY_REPORT_FILTER = 'reportFilter';
    public static final String KEY_SEARCH_FILTER = 'searchFilter';
    public static final String KEY_FROM_DATE = 'fromDate';
    public static final String KEY_TO_DATE = 'toDate';
    public static final String EOM_ACTIVE_LOAN_REPORT = 'IFP End Of Month Active Loan Report';
    public static final String RATE_CHANGE_NOTIFICATION_REPORT = 'Rate Change Notification Report';
    public static final String EOY_REPORT = 'IFP End Of Year Report';
    public static final String ONLINE_USERS_REPORT = 'Online Users Report';
    public static final String CURRENT_CROP_YEAR_REPORT = 'Current Crop Year Report';
    public static final String PRIOR_CROP_YEAR_REPORT = 'Previous Crop Year Report';
    public static final String LOAN_ACCOUNT_REPORT = 'Loan Account Report';
    public static final String ACTIVE_LOAN_REPORT = 'IFP Active Loan Report';
    public static final String EOM_SUBSIDY_ACCRUAL_REPORT = 'IFP End Of Month Subsidy Accrual Report';
    public static final String EOM_PREMIUM_ACCRUAL_REPORT = 'IFP End Of Month Premium Accrual Report';
    public static final String ACTIVE_LOAN_DAILY = 'ACTIVE LOAN DAILY';
    public static final String PARTICIPANT_DAILY = 'PARTICIPANT DAILY';
    public static final String PENDING_TASK_REPORT = 'Pending Task Report';
    public static final String SUBSIDY_ACCRUAL_REPORT = 'IFP Subsidy Accrual Report';
    public static final String PREMIUM_ACCRUAL_REPORT = 'IFP Premium Accrual Report';
    public static final String ACH_BATCH_HISTORY_REPORT = 'ACH Batch History Report';
    public static final String DRAFT_HISTORY_REPORT = 'DRAFT History Report';
    public static final String PRODUCT_RETURN_SUMMERY_REPORT = 'Product Return Summary Report';
    public static final String NO_REPORT_FOUND = 'No report found with the given ID.';

    public static final String KEY_LOAN_NUMBER = 'loan_number';
    public static final String KEY_INTEREST_RATE = 'interest_rate';
    public static final String KEY_PER_DIEM = 'per_diem';
    public static final String KEY_FEES = 'fees';
    public static final String KEY_INTEREST = 'interest';
    public static final String KEY_LOAN_AMOUNT = 'loan_amount';
    public static final String KEY_AVAILABLE = 'available';
    public static final String KEY_RESERVED = 'reserved';
    public static final String KEY_MATURITY_DATE = 'maturity_date';
    public static final String KEY_CERTIFIED_LENDER = 'certified_lender';
    public static final String KEY_SALES_AGENT = 'sales_agent';
    public static final String KEY_CREDIT_RATING = 'credit_rating';
    public static final String KEY_NOTE_DATE = 'note_date';
    public static final String KEY_CROP_YEAR = 'crop_year';
    public static final String KEY_IRC_SHORT_FORM = 'irc';
    public static final String KEY_GROWMARK_UNIQUE_IDENTIFIER = 'Growmark_Unique_Identifier__c';
    public static final String KEY_GUARANTY = 'guaranty';
    public static final String KEY_PAST_DUE = 'past_due';
    public static final String KEY_CURRENT_RATE = 'current_rate';
    public static final String KEY_NEW_RATE = 'new_rate';
    public static final String KEY_EFFECTIVE_DATE = 'effective_date';
    public static final String KEY_UNIQUE_IDENTIFIER = 'unique_identifier';
    public static final String KEY_EMAIL = 'Email';
    public static final String KEY_PHONE = 'Phone';
    public static final String KEY_ADDRESS = 'address';
    public static final String KEY_CITY = 'city';
    public static final String KEY_STATE = 'state';
    public static final String KEY_ZIP = 'zip';
    public static final String KEY_STREET = 'street';
    public static final String KEY_HAS_ACTIVE_LOAN = 'has_active_loan';
    public static final String KEY_NAME = 'Name';
    public static final String KEY_CREATED_BY = 'created_by';
    public static final String KEY_PRINCIPAL_BALANCE = 'principal_balance';
    public static final String KEY_EMAIL_ID = 'email';
    public static final String KEY_MOBILE_PHONE = 'phone';


    
    // Email Template Custom Metadata Names
    public static final String LOAN_AMOUNT_MODIFICATION_EMAIL = 'Email For Loan Amount Modification';
    public static final String MATURITY_DATE_MODIFICATION_EMAIL = 'Email For Maturity Date Modification';
    public static final String APP_WITHDRAW_BY_GROWER_NOTIFIC = 'APPLICATION WITHDRAWAL BY GROWER NOTIFIC';
    public static final String APP_WITHDRAW_BY_DEALER_NOTIFIC = 'Application Withdrawal by Dealer on Behalf of the Grower Notific';

    // Special Character Constants
    public static final String HYPHEN_STRING = '-';
    public static final String DOLLAR_STRING = '$';
    public static final String PERCENTAGE_STRING = '%';
    public static final String SPACE_STRING = ' ';
    public static final String COMMA_STRING = ',';
    public static final String EMPTY_STRING = '';
    public static final String SLASH_STRING = '/';
    public static final String T_STRING = 'T';
    public static final String NEWLINE_STRING = '\n';
    public static final String DOT  = '.';
    public static final String AT_SIGN  = '@';
    public static final String DOT_COM  = '.com';
    public static final String QUESTION_MARK_STRING  = '?';
    public static final String EQUALS_STRING  = '=';
    public static final String AMPERSAND_STRING  = '&';
    public static final String PLUS_STRING  = '\\+';
    public static final String CLOSING_BRACKET_STRING  = ')';
    public static final String DOT_XLS_STRING = '.xls';
    public static final String SPACE_HYPEN_SPACE_STRING = ' - ';

    // Decimal Constants
    public static final Integer ZERO_VALUE = 0;
    public static final Integer ONE_VALUE = 1;
    public static final Integer TWO_VALUE = 2;
    public static final Integer THREE_VALUE = 3;
    public static final Integer FOUR_VALUE = 4;
    public static final Integer FIVE_VALUE = 5;
    public static final Integer SIX_VALUE = 6;
    public static final Integer SEVEN_VALUE = 7;
    public static final Integer EIGHT_VALUE = 8;
    public static final Integer NINE_VALUE = 9;
    public static final Integer TEN_VALUE = 10;
    public static final Integer ELEVEN_VALUE = 11;
    public static final Integer TWELVE_VALUE = 12;
    public static final Integer FIFTEEN_VALUE = 15;
    public static final Integer TWENTY_SIX_VALUE = 26;
    public static final Integer SIXTY_FIVE_VALUE = 65;
    public static final Integer TWO_HUNDRED_VALUE = 200;

    // Months Constants
    public static final String JANUARY = 'January';
    public static final String FEBRUARY = 'February';
    public static final String MARCH = 'March';
    public static final String APRIL = 'April';
    public static final String MAY = 'May';
    public static final String JUNE = 'June';
    public static final String JULY = 'July';
    public static final String AUGUST = 'August';
    public static final String SEPTEMBER = 'September';
    public static final String OCTOBER = 'October';
    public static final String NOVEMBER = 'November';
    public static final String DECEMBER = 'December';

    public static final String NO_SALES_AGENT_USER = 'The linked Sales Agent / Sales Agent Plus does not have an User';

    //Payoff Calculator Exception
    public static final String NULL_EXCEPTION = 'Argument is Null';
    public static final String EMPTY_ID_EXCEPION = 'Loan Id cannot be empty';
    public static final String PAYOFF_DT_EXCEPTION = 'Payoff Date cannot be null';
    public static final String INVALID_ARGUMENTS = 'Invalid Arguments';
    public static final String EMPTY_PRICING_LIST = 'Pricing detail list is empty';
    public static final String LOAN_NUMBER_EXCEPTION = 'Loan Number cannot be Empty.';


    //Constants for application origination
    public static final String NEW_APPLICANT = 'newApplicant';
    public static final String EXISTING_APPLICANT = 'existingApplicant';
    public static final String SAVE_AND_CONTINUE = 'SaveAndContinue';
    public static final String SAVE_AND_EXIT = 'SaveAndExit';
    public static final String CIF_SUFFIX = '001';
    public static final String APPLICATION_KEY = 'application';
    public static final String PRIMARY_APPLICANT_ACCOUNT_KEY = 'primaryApplicantAccount';
    public static final String PRIMARY_APPLICANT_CONTACT_KEY = 'primaryApplicantContact';
    public static final String GENESIS_BUSINESS_INFORMATION_KEY ='genesis__business_information__c';
    public static final String GENESIS_ACCOUNT_KEY ='genesis__account__c';
    public static final String GENESIS_CONTACT_KEY ='genesis__Contact__c';
    public static final String PRIMARY_APPLICANT_BUSINESS_INFO_KEY = 'primaryApplicantBusinessInformation';
    public static final String COAPPLICANT_KEY = 'coapplicant';
    public static final String SAVE_TYPE_KEY = 'shouldValidate';
    public static final String BORROWER_ENTITY_TYPE ='borrowerEntityType';
    public static final String ENGLISH_US = 'en_US';
    public static final String UTF_8_ENCODING  = 'UTF-8';
    public static final String AMERICA_LOS_ANGELES_TIME_ZONE = 'America/Los_Angeles';
    public static final String EMAIL_ENCODING = 'ISO-8859-1';
    public static final String ACCOUNT_KEY = 'Account';
    public static final String ACCOUNT_OBJ_KEY = 'accountObj';
    public static final String CONTACT_KEY = 'Contact';
    public static final String CONTACT_OBJ_KEY = 'contactObj';
    public static final String APPLICATION_OBJ_KEY = 'applicationObj';
    public static final String BUSINESS_INFO_OBJ_KEY = 'businessInfoObj';
    public static final String DEALER_COOP_TYPE_KEY = 'dealerCoopType';
    public static final String APPLICANT_DEALER_RELATION_KEY = 'applicantDealerRel';
    public static final String PRIMARY_APPLICANT_KEY = 'primaryApplicantObj';
    public static final String YEAR_BEGAN_FARMING_KEY = 'Year_Began_Farming__c';
    public static final String GROSS_FARM_INCOME_KEY = 'Gross_Farm_Income__c';
    public static final String ID_KEY = 'Id';
    public static final String LEGAL_ENTITY_NAME_KEY = 'legalEntityName';
    public static final String COOP_TYPE_KEY = 'coopType';
    public static final String WORK_NUMBER_KEY = 'Work Number';
    public static final String MOBILE_NUMBER_KEY = 'Mobile Number';
    public static final String HOME_NUMBER_KEY = 'Home Number';
    public static final String DEALER_ID_KEY = 'dealerId';
    public static final String BORROWER_PARTY_KEY = 'borrowerParty';
    public static final String FIELDS_MAP_KEY = 'fieldsMap';
    public static final String TITLE = 'Title__c';
    public static final String SUFFIX_KEY = 'Suffix__c';
    public static final String POSTAL_CODE_KEY = 'Postal_Code__c';
    public static final String CITY_KEY = 'City__c';
    public static final String STATE_KEY = 'State__c';
    public static final String STREET_KEY = 'Street__c';
    public static final String COUNTY_KEY = 'County__c';
    public static final String HOME_PHONE_KEY = 'Home_Number__c';
    public static final String WORK_PHONE_KEY = 'Work_Number__c';
    public static final String MOBILE_PHONE_KEY = 'Mobile_Number__c';
    public static final String MARITAL_STATUS_KEY = 'Marital_Status__c';
    public static final String REPLACE_COOP_KEY = '?coop=';
    public static final String COAPPLICANT_CONTACT_ID_KEY = 'clcommon__Contact__r.Id';
    public static final String COAPPLICANT_ACCOUNT_ID_KEY = 'clcommon__Account__r.Id';
    public static final String COAPPLICANT_BUSINESS_INFO_ID_KEY = 'clcommon__Account__r.genesis__Business_Information__r.Id';
    public static final String COAPPLICANT_BIRTHDAY_KEY = 'clcommon__Contact__r.Birthdate';
    public static final String COAPPLICANT_LAST_NAME_KEY = 'clcommon__Contact__r.LastName';
    public static final String COAPPLICANT_FIRST_NAME_KEY = 'clcommon__Contact__r.FirstName';
    public static final String COAPPLICANT_MIDDLE_NAME_KEY = 'clcommon__Contact__r.ints__Middle_Name__c';
    public static final String COAPPLICANT_CONTACT_EMAIL_KEY = 'clcommon__Contact__r.Email';
    public static final String COAPPLICANT_CONFIRM_EMAIL_KEY = 'clcommon__Contact__r.Confirm_Email__c';
    public static final String COAPPLICANT_CONFIRM_SSN_KEY = 'clcommon__Contact__r.Confirm_SSN__c';
    public static final String COAPPLICANT_SSN_KEY = 'clcommon__Contact__r.genesis__SSN__c';
    public static final String COAPPLICANT_YEAR_BEGAN_FARMING_KEY = 'clcommon__Account__r.Year_Began_Farming__c';
    public static final String KEY_COMPANY_OR_DBA_NAME = 'companyOrDbaName';
    public static final String KEY_PORTAL_USER_EMAIL = 'portalUserEmail';
    public static final String KEY_PORTAL_USER_FIRST_NAME = 'portalUserFirstName';
    public static final String KEY_PORTAL_USER_LAST_NAME = 'portalUserLastName';
    public static final String KEY_PORTAL_USER_ACC_ID = 'portalUserAccountId';
    public static final String KEY_PORTAL_USER_CON_ID = 'portalUserContactId';
    public static final String KEY_PORTAL_USER_CIF_NUM = 'portalUserCIFNumber';
    public static final String KEY_DEALER_RELATION = 'dealerRelations';
    public static final String KEY_DEALER_RELATION_ACC_ID = 'dealerRelationsAccountId';
    public static final String KEY_CREDIT = 'Credit';
    public static final String KEY_TASK_TESTING_ONE = 'Task Testing 1';
    public static final String KEY_TASK_TESTING_TWO = 'Task Testing 2';
    public static final String KEY_TASK_TESTING_THREE = 'Task Testing 3';
    public static final String KEY_PRIMARY_APPLICANT = 'primaryApplicant';
    public static final String KEY_CREATE_PRIMARY_APPLICANT = 'createPrimaryApplicant';
    public static final String ENTITY_KEY = 'entity';
    public static final String CO_APPLICANT_TITLE_KEY = 'Co-Applicant';
    public static final String KEY_SHOULD_DELETE = 'shouldDelete';

    //Additional info constants
    public static final String CLCOMMON_CONTACT_KEY = 'clcommon__Contact__c';
    public static final String CLCOMMON_ACCOUNT_KEY = 'clcommon__Account__c';
    public static final String CLCOMMON_ACCOUNT_NAME_KEY = 'clcommon__Account__r.Name';
    public static final String CLCOMMON_ACCOUNT_EMAIL_KEY = 'clcommon__Account__r.clcommon__Email__c';
    public static final String CLCOMMON_ACCOUNT_PHONE_KEY = 'clcommon__Account__r.Phone';
    public static final String CLCOMMON_ACCOUNT_BILLING_STREET_KEY = 'clcommon__Account__r.BillingStreet';
    public static final String CLCOMMON_ACCOUNT_BILLING_CITY_KEY = 'clcommon__Account__r.BillingCity';
    public static final String CLCOMMON_ACCOUNT_BILLING_STATE_KEY = 'clcommon__Account__r.BillingState';
    public static final String CLCOMMON_ACCOUNT_BILLING_POSTAL_CODE_KEY = 'clcommon__Account__r.BillingPostalCode';
    public static final String CLCOMMON_ACCOUNT_BILLING_COUNTY_KEY = 'clcommon__Account__r.Billing_County__c';

    //Constants for Appplication Submission
    public static final String KEY_NOTE= 'note';
    public static final String KEY_SHOULD_DENY = 'shouldDeny';
    public static final String IS_AUTOBOOK_POSSIBLE = 'isAutoBookPossible';
    public static final String CURRENT_APPLICATION = 'currentApplication';
    public static final String KEY_PRINCIPAL = 'principal';
    public static final String KEY_PARTY= 'party';
    public static final String KEY_BORROWER_ACC= 'borrowerAcc';
    public static final String KEY_PRINICPAL_ACC= 'principalAcc';
    public static final String KEY_PRINICPAL_CONTACT= 'principalContact';
    public static final String KEY_PRINICPAL_BUSINESS_INFO= 'principalBusinessInfo';
    public static final String KEY_MY_PROGRAM= 'myProgram';
    public static final String KEY_PRICING= 'pricing';
    public static final String SECURED_LIEN = 'Secured';
    public static final String UNSECURED_LIEN = 'Unsecured';
    public static final String KEY_SA = 'Sales_Agent__c';
    public static final String KEY_IRC = 'Internal_Reference_Code__c';
    public static final String TOTAL_LOAN_AMOUNT = 'totalLoanAmount';
    public static final String KEY_PRINCIPAL_EXISTING= 'principalFromExistingApplication';
    public static final String ENTITY_DOC_TASK_KEY= 'entityDocTask';
    public static final String AGGREGATE_KEY = 'expr0';
    public static final String MARITAL_STATUS_MARRIED = 'Married';
    public static final String TIER_FOUR = 'Tier 4';
    public static final String REQUEST_SECOND_LOOK = 'Request second look';
    public static final String LOGGED_IN_USER = 'loggedInUser';
    public static final String KEY_MATCH_LOAN_AMOUNT = ' to match the loan amount';
    public static final String KEY_COMPLETE_POTENTIAL = ' complete Potential';
    public static final String KEY_COMPLETE = 'complete';
    public static final String KEY_THE = 'the';
    public static final String KEY_ALL = 'all';
    public static final String KEY_FOLLOWING = 'following';
    public static final String UNASSIGNED_LIEN_OPTION = 'Unassigned';
    public static final String CROPS_LIEN_POSITION = 'Crops';
    public static final String BLANKET_LIEN_POSITION = 'Blanket';


    //NLS transactions description
    public static final String NLS_DRAFT_ADVANCE = 'Draft Advance';
    public static final String NLS_PRINCIPAL_ADVANCE = 'Principal Advance';
    public static final String NLS_PRINCIPAL_REDUCTION = 'Principal Reduction';
    public static final String NLS_PRODUCT_RETURN = 'Product Return';
    public static final String NLS_ACH_COMMERCE = 'ACH-COMMERCE';
    public static final String NLS_CHECK_COMMERCE = 'Check-Commerce';

    //Transactions Status
    public static final String STATUS_POSTED = 'Posted';
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_VOIDED = 'Voided';
    public static final String STATUS_INITIATED = 'Initiated';
    public static final String KEY_PAYMENT_MODE = 'paymentMode';
    public static final String KEY_TRANSACTIONS_STATUS = 'transactionsStatus';
    public static final String ALL_SUB_TRANCHES = 'All Sub-Tranches';
    public static final String KEY_LOAN_DESCRIPTION='loanDescription';
    public static final String LOAN_ID_LIST='loanIdList';
    public static final String PRICING_ID_LIST='pricingIdList';
    public static final String PENDING_TRANSACTION_LIST = 'pendingTransactionList';
    public static final String POSTED_TRANSACTION_LIST = 'postedTransactionList';
    public static final String VOIDED_TRANSACTION_LIST = 'voidedTransactionList';
    public static final String KEY_TRANSACTION_CODE = 'Transaction_Code';
    public static final String KEY_TRANSREF_NUM = 'Transrefno';
    public static final String KEY_REVERSAL_TRANSREF = 'Reversal_Transrefno';
    public static final String KEY_LOAN_GROUP = 'Loan_Group_No';
    public static final String KEY_LOAN_PARTICIPANTS = 'Participant_Detail_Flag';
    public static final String KEY_PAYMENT_METHOD_REFERENCE = 'Payment_Method_Reference';
    public static final String KEY_POSTED_TRANSACTIONS = 'posted_transactions';
    public static final String KEY_GROWER_NAME = 'grower_name';
    public static final String KEY_LAON_NUMBER = 'loan_number';
    public static final String KEY_LOAN_ID = 'loan_id';
    public static final String KEY_DESCRIPTION = 'description';
    public static final String KEY_RATE = 'rate';
    public static final String KEY_AMOUNT = 'amount';
    public static final String KEY_TRANSACTION_TYPE = 'transaction_type';
    public static final String KEY_PURPOSE = 'purpose';
    public static final String KEY_CREATED_DATE = 'created_date';
    public static final String KEY_STATUS = 'status';
    public static final String KEY_IS_AUTOBOOKING = 'isAutoBooking';
    public static final String KEY_POSTED_DATE = 'posted_date';
    public static final String KEY_ACCTREFNO = 'Acctrefno';
    public static final String KEY_TRANSACTION_DATE = 'Transaction_Date';
    public static final String KEY_TRANSACTION_DESCRIPTIOIN = 'Transaction_Description';
    public static final String KEY_TRANSACTION_AMOUNT = 'Transaction_Amount';
    public static final String KEY_USER_REFERENCE = 'User_Reference';
    public static final String PAYMENT = 'PAYMENT';
    public static final String FIELD_CIF_NUMBER = 'CIF_Number__c';

    
    // Grower Details Constants
    public static final String NO_PENDING_ACTION = 'No Pending Action';
    public static final String EMAIL_CHANGE_IN_PROGRESS_STATUS = 'Email Change In Progress';
    public static final String INVALID_CREDENTIALS = 'Invalid Credentials';
    public static final String EVERGREEN_ALLOWED = 'Allowed';
    public static final String EVERGREEN_NOT_ALLOWED = 'Not Allowed';
    public static final String EVERGREEN_ELIGIBILITY_DUPLICATE_EXCEPTION = 'Oops! This value is already set for Evergreen eligibility.';
    public static final Boolean TRUE_VALUE = true;
    public static final Boolean FALSE_VALUE = false;

    //Evergreen Rescore
    public static final string TOTAL_ASSETS = 'Total_Assets__c';
    public static final string TOTAL_LIABILITIES = 'Total_Liabilities__c';
    public static final string YEAR_BEGAN_FARMING = 'clcommon__Account__r.Year_Began_Farming__c';
    public static final string GROSS_FARM_INCOME = 'clcommon__Account__r.genesis__Business_Information__r.Gross_Farm_Income__c';
    public static final string BUSINESS_DETAILS = 'businessDetails';
    public static final string PARTY_ID = 'id';
    public static final string EXCEPTION_STRING = 'Please fill up assets and liabilities to save.';
    public static final String EVERGREEN_BIZ_STATUS_PENDING = 'Pending';
    public static final String EVERGREEN_BIZ_STATUS_IN_PROGRESS = 'In Progress';
    public static final String EVERGREEN_BIZ_STATUS_PROVIDED = 'Provided';
    public static final String EVERGREEN_BIZ_STATUS_IN_ELIGIBLE = 'Ineligible';
    public static final String MAP_IS_EMPTY = 'Map is empty.';
    public static final string MISSING_ARGUMENTS = 'Missing Arguments';
    public static final string KEY_EVERGREEN_ELIGIBLE = 'Evergreen Eligible';

    public static final string PAST_DUE_APPLICATIONS_EXCEPTION = 'Applicant has pending past due applications, could not initiate new application.';
    public static final string NON_ACCRUAL_APPLICATIONS_EXCEPTION = 'Applicant has pending non accrual applications, could not initiate new application.';
    public static final string EVERGREEN_CROP_YEAR_EXCEPTION = 'Unable to submit. Evergreen application requires a loan with current or prior crop year.';
    public static final string NON_ACCRUAL_APPLICANT_EXCEPTION = 'One or more of the applicants is linked with a non accrual application.';
    public static final string PAST_DUE_APPLICANT_EXCEPTION = 'One or more of the applicants is linked with a past due application.';


    // Content Document Keys
    public static final String TITLE_KEY = 'title';
    public static final String CONTENT_VERSION_ID_KEY = 'contentVersionId';
    public static final String CONTENT_DOC_ID_KEY = 'contentDocId';
    public static final String APPLICATION_ID_KEY = 'applicationId';
    public static final String NAME_KEY = 'name';

    //Invoice Keys
    public static final String INVOICE_ID_KEY = 'invoiceId';
    public static final String COMMENT_KEY = 'comment';
    public static final String EMAIL_KEY = 'email';

    // Import ACH Keys
    public static final String KEY_PARENT_LOAN_NUMBER_MAP = 'parentLoanNumberMap';
    public static final String KEY_UNIQUE_LOAN_SET = 'uniqueLoanSet';
    public static final String KEY_LOAN_DETAILS_MAP = 'loanDetailsMap';
    public static final String KEY_CSV = 'CSV';
    public static final String KEY_ACH = 'ACH';
    public static final String KEY_IMPORT_ACH_CSV_HEADER = 'FullLoanNumber,Purpose,Amount';
    public static final String ACH_LIMIT_EX = 'Import Limit Exceeded. Cannot import more than 100 ACHs.';
    public static final String CSV_HEADER_MISSING_EX = 'CSV Header Missing / Invalid Header.';
    public static final String KEY_CSV_LOAN_AMOUNT_MAP = 'csvLoanAmountMap';
    public static final String KEY_ALL_CSV_FILE_LINES_LIST = 'allCSVFileLinesList';
    public static final String KEY_OBJ_PRICING_DETAILS_LIST = 'objPricingDetailsList';
    public static final String KEY_CSV_LOAN_LIST= 'csvLoanList';
    public static final String INVALID_INVOICE = 'Invalid invoice number.';
    public static final String NO_TRANSACTION_DATA = 'No transaction data is available for this invoice.';
    public static final String KEY_PDF = 'pdf';

    //Nacha Keys
    public static final String FIRST_COLUMN ='FIRST_COLUMN';
    public static final String SECOND_COLUMN ='SECOND_COLUMN';
    public static final String THIRD_COLUMN ='THIRD_COLUMN';
    public static final String FOURTH_COLUMN ='FOURTH_COLUMN';
    public static final String FIFTH_COLUMN ='FIFTH_COLUMN';
    public static final String SIXTH_COLUMN ='SIXTH_COLUMN';
    public static final String SEVENTH_COLUMN ='SEVENTH_COLUMN';
    public static final String CSV_HEADER ='CSV_HEADER';
    public static final String NACHA_RPORT = 'NACHA REPORT';
    public static final String CSV_FOR_NACHA = 'CSV file generated for NACHA';

    //Map Keys
    public static final String KEY_OBJ_FUNDING_TRANSACTION = 'objFundingTransaction';
    public static final String KEY_OBJ_PRICING_DETAILS = 'objPricingDetails';
    public static final String KEY_PRICING_ID = 'pricingId';
    public static final String KEY_FUNDING_TRANSACTION_LIST = 'fundingTransactionList';
    public static final String KEY_INVOICE_ID_SET = 'invoiceIdSet';

    public static final String KEY_TOTAL_PRINCIPAL = 'totalPrincipal';
    public static final String KEY_TOTAL_INTEREST= 'totalInterest';
    public static final String KEY_TOTAL_FEES= 'totalFees';
    public static final String KEY_TOTAL_AMOUNT= 'totalAmount';
    public static final String KEY_TOTAL_COUNT  = 'totalCount';
    public static final String KEY_CLEAR_OR_POST_COUNT = 'clearOrPostCount';
    public static final String KEY_RESOURCE= '/resource/';

    public static final String KEY_COOP_TYPE = 'coop_type';
    public static final String KEY_IS_PAID_BY_DEALER = 'is_paid_by_dealer';
    public static final String KEY_TRASACTION_NUMBER = 'transaction_number';
    public static final String KEY_SHOW_COMMENT = 'show_comment';
    public static final String KEY_COMMENTS = 'comments';
    public static final String KEY_LOGO = 'logo';
    public static final String KEY_TRANSACTIONS = 'transactions';
    public static final String STRING_TWO_ZERO_TWO_FIVE = '2025';

    // BASF
    public static final String BASF_EARLY_TRANCHE_DESCRIPTION = 'BASF Early: 0% through 11/30/25 for purchases on or before 3/15/25';
    public static final String EARLY_BASF_ADVANCE_ERROR = 'You are not eligible to do Early Advance on this Dealer';

}