/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 02-14-2025
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   14-11-2023   Subham Nandi   Initial Version
**/
global with sharing class ConstantValues {
    
    global static final String SOAP_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    global static final String SERVICE_NS = 'http://www.liquidCredit.com/';
    global static final String FICO_INT_FAMILY = 'FICO';
    global static final String FICO_INT_TYPE = 'Credit Score';
    global static final String SUB_XREF_ID = '20211118094147';
    global static final String PRODUCT_CATEGORY_ID = '2200';
    global static final String CUSTOMER_XREF_ID = '57041';
    global static final String BUSINESS_XREF_ID = '57041';
    global static final String OL_SCORE_CUTOFF = '300';
    global static final String SCORING_MODEL = '700';
    global static final String PRINT_IMAGE_REQUEST_FLAG = 'Y';
    global static final String PARSED_DATA_REQUEST_FLAG = 'N';
    global static final String RAW_DATA_REQUEST_FLAG = 'N';
    global static final String SCORE1_MODEL = 'FE';
    global static final String SCORE2_MODEL = 'G';
    global static final String CODE = 'XPN';
    global static final String PRIORITY = 'primary';
    global static final String NONDIGITS = '[^0-9]';
    global static final String HEADER_CONTENT_LENGHT = 'text/xml;charset=UTF-8';
    global static final String HEADER_SOAP_ACTION = 'http://www.liquidCredit.com/ObtainDecisionData';
    global static final String NEW_SUBMITTED_APP_STATUS = 'NEW-SUBMITTED';
    global static final String REJECTED_APP_STATUS = 'DENIED';
    global static final String BORROWER_PARTY = 'BORROWER';
    global static final String PRINCIPAL_PARTY = 'PRINCIPAL';
    global static final String RESPONSE_ATTACHMENT_NAME = 'Response from FICO';
    global static final String SBSS_SCORE = 'SBSS70';
    global static final String SCORE_1 = 'score1';
    global static final String SCORE_2 = 'score2';
    global static final Integer MAX_PRINCIPAL_FOR_CALLOUT = 2;
    global static final String LOAN_PURPOSE = 'Crop';
    global static final String SCORECARD_GENERATED = 'NEW - SCORECARD GENERATED';
    global static final String CREDIT_RATE_1 = 'Tier 1';
    global static final String CREDIT_RATE_2 = 'Tier 2';
    global static final String CREDIT_RATE_3 = 'Tier 3';
    global static final String CREDIT_RATE_4 = 'Tier 4';
    global static final String MY_PROGRAM_EXPIRED_STATUS = 'Expired';
    global static final String RESERVE_AMOUNT_EMAIL='Change in Reserve Amount Notification';
    public static final String CL_PARTY_NAME = 'CERTIFIED LENDER';
    public static final String CLP_PARTY_NAME='CERTIFIED LENDER PLUS';
    public static final String PAYMENT_ADMINISTRATOR_PARTY_NAME = 'PAYMENT ADMINISTRATOR';
    public static final String VOIDED_STATUS='Voided';
    public static final String MAXIMUM_ELIGIBLE_FICO = System.Label.FICO_Maximum_Eligible;
    public static final String MAXIMUM_ELIGIBLE_SBSS = System.Label.SBSS_Maximum_Eligible;
    public static final String ORG_WIDE_NO_REPLY_EMAIL_ADDRESS = System.Label.NO_REPLY_CFA_SENDER_NAME;
    public static final String SOLE_PROP_ENTITY = 'Individual(s) - Sole Proprietorship';
    public static final String EOM_EMAIL_NOTIFICATION_BATCH_SIZE = System.Label.EOM_Email_Notification_to_CFA_Grower_Batch_Size;
    public static final String ACCOUNT = 'Account';
    public static final List<String> PERMISSIONED_USER = new List<String>{'Certified Lender',
                                                                            'Certified Lender Plus',
                                                                            'Field Staff Agent',
                                                                            'Inquiry',
                                                                            'Inquiry Plus',
                                                                            'Payment Administrator',
                                                                            'Sales Agent',
                                                                            'Sales Agent Admin',
                                                                            'Sales Agent Plus'};

    //DATA FROM CUSTOM LABEL
    global static final String CONNECTION_USERNAME = System.Label.FICO_CONNECTION_USERNAME;
    global static final String CONNECTION_PASSWORD = System.Label.FICO_CONNECTION_PASSWORD;
    global static final String CUSTOMER_ID = System.Label.FICO_CUSTOMER_ID;
    global static final String SUBSCRIBER_ID_NUMBER = System.Label.FICO_SUBSCRIBER_ID_NUMBER;
    global static final String FICO_MIN_TIER_1 = System.Label.FICO_MIN_TIER1;
    global static final String FICO_MIN_TIER_2 = System.Label.FICO_MIN_TIER2;
    global static final String FICO_MIN_TIER_3 = System.Label.FICO_MIN_TIER3;
    global static final String SBSS_MIN_TIER_1 = System.Label.FICO_SB_MIN_TIER1;
    global static final String SBSS_MIN_TIER_2 = System.Label.FICO_SB_MIN_TIER2;
    global static final String SBSS_MIN_TIER_3 = System.Label.FICO_SB_MIN_TIER3;
    global static final String GUARANTEE_FOR_TIER_1 = System.Label.Guarantee_For_Tier_1;
    global static final String GUARANTEE_FOR_TIER_2 = System.Label.Guarantee_For_Tier_2;
    global static final String GUARANTEE_FOR_TIER_3 = System.Label.Guarantee_For_Tier_3;
    global static final String GUARANTEE_FOR_TIER_4 = System.Label.Guarantee_For_Tier_4;
    global static final String FICO_MAX_TIER_1 = System.Label.FICO_MAX_TIER_1;
    global static final String CERT_NAME = System.Label.Docusign_Cert_Name;
    global static final Integer PRICING_MANAGEMENT_DAG_BATCH_SIZE = Integer.valueOf(System.Label.Pricing_Management_Dag_Batch_Size);
    global static final Integer UPDATE_INVOICE_DAG_BATCH_SIZE = Integer.valueOf(System.Label.Update_Invoice_Dag_Batch_Size);

    
    //MY PROGRAM CONSTANTS
    global static final String APPROVAL_ERROR = 'Approval of My Program';
    global static final String UPDATE_CFA_ADV_RATE_ERROR = 'Error in updating CFA Advantage Rate';
    
    //ERROR CONSTANTS
    global static final String FICO_CALLOUT_EXCEPTION = 'FICO Callout Exception';
    global static final String FICO_ADAPTER_EXCEPTION = 'FICO Adapter Exception';
    global static final String HTTP_CALLOUT_EXCEPTION = 'Http Callout Exception';
    global static final String REQUEST_GENERATION_EXCEPTION = 'Generate Request Body Exception';
    global static final String RESPONSE_PARSER_EXCEPTION = 'Response Parser Exception';
    global static final String CREDIT_RATING_EXCEPTION = 'Calling Credit Rating Exception';
    global static final String FICOFLOW_EXCEPTION = 'No appication id is recieved from flow to complete credit reference';
    global static final String MISSING_PARAMETERS = 'Parameters are missing';
    global static final String SCHEDULED_PRICING_ERROR = 'Scheduled Pricing Generation Error';
    global static final String PRICING_NOT_FOUND = 'Pricing not found to deactivate/activate';
    global static final String RATE_CARD_NOT_FOUND = 'Rate Card not found to deactivate/activate';
    global static final String FICOFROM_FLOW_ERROR = 'Calling FICO From Flow Error';
    global static final String APPLICATION_ID_MISSING = 'Applicaiton Id Not Found to make the FICO Callout from Flow';
    public static final String INSUFFICIENT_ACCESS_ON_OBJECTS = 'Insufficient Access on Objects';
    public static final String EMAIL_LIST_EMPTY = 'Email List is Empty';
    public static final String EOM_EMAIL_TO_CFA_GROWER = 'EOM CFA Email Statement Notification';
    public static final String CL_OR_CLP_PARTY_NOT_FOUND = 'CL or CLP party not found';
    public static final String ASSOCIATED_WITH_NON_ACCRUAL = 'We cannot book this loan because the Borrower or the Principal party is associated with a non-accrual or a past due loan';
    private static final String PARTY_ERROR = 'No Parties found';
    private static final String NULL_CONTENT_DOCUMENT = 'No Content Document Id found';
    public static final String BASE_RATE_NOT_FOUND = 'Base rate information could not be fetched.';


    //Constants for NLS Integration Family
    public static final String AUTHORIZATION = 'Authorization';
    public static final String BEARER = 'Bearer ';
    public static final String POST_METHOD = 'POST';
    public static final String GET_METHOD = 'GET';
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String URL_ENCODED = 'application/x-www-form-urlencoded';
    public static final String CONGA_URL = 'https://staging-cooperative-finance.cs211.force.com/ltng/apex/APXTConga4__Conga_Composer?';
    public static final String SESSION_ID = 'sessionId=';
    public static final String SERVER_URL = '&serverUrl=';
    public static final String ENCODING_SCHEME = 'UTF-8';
    public static final String ACCESS_TOKEN_GENERATOR = 'AccessTokenGenerator';
    public static final String NLS_CALLOUT = 'NLSCallout';
    public static final String NLS_INTEGRATION_FAMILY = 'NLS Integration';
    public static final String INTEGRATION_API_TYPE_SEARCH_LOAN = 'Search Loans Integration API Type';
    public static final String INTEGRATION_API_TYPE_GET_LOANID = 'NLS Fetch LoanId API Configuration';
    public static final String INTEGRATION_API_TYPE_GET_LOAN = 'Get loan Integration API Type';
    public static final String INTEGRATION_API_TYPE_LOAN_TRANSACTION = 'Loan Transactions Integration API Type';
    public static final String INTEGRATION_API_TYPE_LOAN_STATEMENTS = 'Get Loan Statements Integration API Type';
    public static final String INTEGRATION_API_TYPE_LOAN_STATEMENTS_FILE = 'Get Loan Statements File Integration API Type';
    public static final String INTEGRATION_API_TYPE_XML_IMPORT = 'Post NLS XML Import Integration API Type';
    public static final String INTEGRATION_API_TYPE_CREDIT_LINES = 'Get Credit Lines Integration API Type';
    public static final String INTEGRATION_API_TYPE_GET_CHILD_LOANID = 'NLS Fetch Child LoanId API Configuration';
    public static final String INTEGRATION_API_TYPE_LOAN_DETAILS = 'Get Loan Details Integration API Type';
    public static final String INTEGRATION_API_TYPE_LOAN_STATISTICS = 'Get Loan Statistics Integration API Type';
    public static final String INTEGRATION_API_TYPE_LOAN_STATUSES = 'Get Loan Statuses Integration API Type';
    public static final String INTEGRATION_API_TYPE_PAYOFF_DETAILS = 'Get Payoff Details Integration API Type';
    public static final String INTEGRATION_API_TYPE_CHILD_PAYOFF_DETAILS = 'Get Child Payoff Details Integration API Type';
    public static final String INTEGRATION_API_TYPE_GET_CHILD_LOAN = 'Get Child loan Integration API Type';
    public static final String INTEGRATION_API_TYPE_PAYOFF_CALCULATOR = 'Get Payoff Details for Payoff Calculator';
    public static final String PAYMENT_TYPE = 'paymentType';
    public static final String PAYMENT_INITIATED = 'Initiated';
    public static final String INTEGRATION_API_TYPE_MODIFY_FIELD = 'Modify Field API Type';
    public static final String INTEGRATION_API_TYPE_APPROVE_MODIFICATION = 'Approve Modification Request API Type';
    
    public static final String ACCOUNT_ID = 'accountId';
    public static final String STATEMENT_TYPE = 'statementType';
    public static final String STATUS_CODE = 'statusCode';
    public static final String GROWER_NAME = 'growerName';
    public static final String LOAN_AMOUNT = 'loanAmount';
    public static final String LOAN_ID = 'loanId';
    public static final String REPLACE_LOAN_ID = '{!loan_id}';
    public static final String REPLACE_PARTICIPANT_ID = '{!participant_id}';
    public static final String PARTICIPANT_ID = 'participantId';
    public static final String STATEMENT_ID = 'statementId';
    public static final String REPLACE_STATEMENT_ID ='{!statement_id}';
    public static final String LOAN_NUMBER = 'loanNumber';
    public static final String PARTY_TYPE = 'partyType';
    public static final String MATURITY_DATE = 'maturityDate';
    public static final String OLD_MATURITY_DATE = 'currentMaturityDate';
    public static final String REPLACE_LOAN_AMOUNT = '{!LoanAmount}';
    public static final String REPLACE_LOAN_NUMBER = '{!LoanNumber}';
    public static final String REPLACE_MATURITY_DATE = '{!MaturityDate}';
    public static final String REPLACE_DEALER_NAME = '{!DealerName}';
    public static final String REPLACE_DEALER_CITY = '{!DealerCity}';
    public static final String REPLACE_DEALER_STATE = '{!DealerState}';
    public static final String REPLACE_DEALER_CIF = '{!DealerCIF}';
    public static final String REPLACE_GROWER_NAME = '{!GrowersName}';
    public static final String REPLACE_BATCH_AMOUNT = '{!BatchAmount}';
    public static final String REPLACE_PAYOFF_DATE_PARAMS = '{!payoffDate}';
    public static final String REPLACE_CLEARING_DATE = '{!ClearingDate}';
    public static final String REPLACE_FUNDING_DATE = '{!FundingDate}';
    public static final String MASTER_ACCTREFNO = 'masterAcctrefno';
    public static final String LOAN_TYPE = 'loanType';
    public final static String CLOSED_LOAN_RESPONSE_BODY ='{"closedLoans":{!CloseLoanBody},"activeLoans":{!ActiveLoanbody}}';
    public final static String RESPONSE_BODY ='{"response":{!responseBody}}';
    public final static String REPLACE_RESPONSE_BODY ='{!responseBody}';
    public final static String ACTIVE_STATUS_CODE = '"Status_Code_No": "0"';
    public final static String ACTIVE_PAYOFF_DATE = '"Payoff_Date": "ISNOTNULL"';
    public final static String REPLACE_STATUS_CODE = '"Status_Code_No": "1"';
    public final static String REPLACE_PAYOFF_DATE = '"Payoff_Date": ""';
    public final static String REPLACE_ACTIVE_LOAN = '{!ActiveLoanbody}';
    public final static String REPLACE_CLOSE_LOAN = '{!CloseLoanBody}';
    public final static String STATEMENT_PARAMS_FOR_THIS_YEAR ='?startDate={!Year}0101&endDate={!Year}{!Month}{!Day}';
    public final static String STATEMENT_PARAMS_FOR_LAST_YEAR ='?startDate={!Year}0101&endDate={!Year}1231';
    public final static String REPLACE_YEAR ='{!Year}';
    public final static String REPLACE_MONTH ='{!Month}';
    public final static String REPLACE_DAY ='{!day}';
    public static final String PAYLOAD = 'payload';
    public static final String DATA = 'data';
    public static final String ACH = 'ACH';
    public static final String DRAFT = 'DRAFT';
    public static final String PAYMENT = 'PAYMENT';
    public static final String PRODUCT_RETURN = 'PRODUCT RETURN';
    public static final String MOBILE_DEPOSIT = 'MOBILE DEPOSIT';
    public static final String ACTIVE = 'ACTIVE';
    public static final String CLOSED = 'CLOSED';
    public final static String PENDING_APPROVAL_APPLICATION_STATUS = 'PENDING APPROVAL';
    public static final String INITIATED_STATUS = 'INITIATED';
    public static final String NON_ACCRUAL = 'NON-ACCRUAL';
    public static final String IMPORTED = 'IMPORTED';
    public static final String NLS_IMPORT_BATCH_SIZE = '1';
    public static final String PRE_PRINTED='Pre Printed Application.pdf';
    public static final String PRE_PRINTED_ERROR='Unable to delete pre-printed applications.';
    public static final Integer GMT_TO_CST_HOUR_DIFF = 1;
    public static final String GMT_TO_CDT_HOUR_DIFF = System.label.GMT_TO_CDT_HOUR_DIFF;
    public static final String APPLICATION_NOTE_APPROVE_STATUS = 'Approved';
    public static final String APPLICATION_NOTE_DECLINE_STATUS = 'Declined';
    public static final String APPLICATION_NOTE_FAILED_STATUS = 'Failed To Update';
    public static final String FAILED_MODIFICATION_MESSAGE = 'Failed to Update the modification request.Please try after sometime.';
    public static final String SUCCESS_MODIFICATION_MESSAGE = 'Modification request has been updated successfully and email to Certified Lender has been sent.';
    public static final String LOAN_DECLINATION_MESSAGE = 'Loan Amount Modification request has been successfully declined and email to Certified Lender has been sent.';
    public static final String MATURITY_DECLINATION_MESSAGE = 'Maturity Date Modification request has been successfully declined and email to Certified Lender has been sent.';
    public static final String DECLINE_LOAN_AMOUNT_MODIFICATION = 'Decline Loan Amount Modification';
    public static final String DECLINE_MATURITY_DATE_MODIFICATION = 'Decline Maturity Date Modification';
    public static final String APPROVE_LOAN_AMOUNT_MODIFICATION = 'Approve Loan Amount Modification';
    public static final String APPROVE_MATURITY_DATE_MODIFICATION = 'Approve Maturity Date Modification';
    public static final String ACH_ACTIVITY_NOTICE = 'ACH Activity Notice';
    public static final String PRODUCT_RETURN_NOTICE = 'Product Return Activity Notice';
    public static final String THIRTY_TWO_DAYS_RATE_CHANGE = '32 Day Rate Change Notific';
    public static final String FOURTY_FIVE_DAYS_RATE_CHANGE = '45 Day Rate Change Notific';
    public static final String REPLACE_LOGO_URL = '{!logoURL}';
    public static final String ACCESS_LABEL_EDIT = 'edit';
    public static final String OPPORTUNITY_ACCESS_LEVEL = 'None';
    public static final String DEALER_CONTACT_PARTY_BATCH_INVOCABLE_LABEL='Create Dealer Contact Party';
    public static final String DEALER_COOP_TYPE ='dealerCoopType';
    public static final String DEALER_CONTACT_ID ='dealerContactId';
    public static final String RECORD_TYPE_NAME ='recordTypeName';
    public static final String PREVIOUS_RECORD_TYPE_NAME = 'previousRecordTypeName';
    public static final String DEALER_ID ='parentId';
    public static final String PREVIOUS_DEALER_ID = 'previousDealerId';
    public static final String SELECTED_DEALER_COOP = 'selectedDealerCoop';
    public static final String UPDATE_RECORD ='updateRecord';
    public static final String SALES_AGENT_ADMIN_RELATIONSHIP = 'SalesAgentAdminRelationship';
    public static final String DEALER_CONTACT_LIST = 'dealerContactList';
    public static final String CONTACT_FETCH_ERROR = 'Contact Fetch Error';
    public static final String PROFILE_FETCH_ERROR = 'Profile Fetch Error';
    public static final String ACCESS_LABEL_READ = 'read';
    public static final String KEY_DEALER_CITY = 'dealerCity';
    public static final String KEY_DEALER_STATE = 'dealerState';
    public static final String KEY_DEALER_CIF = 'dealerCIF';
    public static final String KEY_DEALER_ID = 'dealerId';
    
    //System Labels.
    public static final String TRANSACTIONS_LOAN_GROUP = System.label.TRANSACTIONS_LOAN_GROUP;
    public static final String USERNAME = system.label.q2admin;
    public static final String SCOPE = system.label.openid_api;
    public static final String CLIENT_ID = system.label.apiuser;
    public static final String TEST_MAIL = system.label.TestEmail;
    public static final String GRANT_TYPE = system.label.password;
    public static final String PASSWARD = system.label.password29cfa_Q2;
    public static final String CALLOUT_LIMIT = system.label.Callout_limit;
    public static final String CLIENT_SECRET = system.label.password29cfa_Q2;
    public static final String TOKEN_URL = system.label.Access_Token_Generator_URL;
    public static final String REVOKE_TOKEN_URL = system.label.Access_Token_Revocation_URL;
    public static final String SENDER_DISPLAY_NAME = system.label.EMAIL_SENDER_DISPLAY_NAME;
    public static final String MATURITY_DATE_EMAIL_TEMPLATE = system.label.Email_Maturity_Date;
    public static final String MODIFIED_LOAN_AMOUNT_EMAIL_TEMPLATE = system.label.Email_For_Modified_Loan_Amount;
    public static final String LOAN_ACCOUNTING_EMAIL_ADDRESS = System.Label.Loan_Accounting_Email;
    public static final String PAYMENT_NACHA_EMAIL_ADDRESS = System.Label.Payment_NACHA_Email;
    public static final String CFA_EMAIL_DOCUSIGN = System.Label.CFA_Sign_Agreement_Email;
    public static final String ORGWIDE_SENDER_EMAIL = System.Label.Sender_Email;
    public static final String GROWER_URL=System.Label.Grower_Portal_URL;
    public static final String GROWER_REGISTRATION_URL=System.Label.Grower_Portal_Registration_URL;
    public static final String GMK_GROWER_URL=System.Label.GMK_Grower_Portal_Url;
    public static final String LOGO_BASE_URL= System.Label.Logo_Base_Url;
    public static final String LANDUS_GROWER_URL = System.Label.Landus_Grower_Portal_Url;
    public static final String TRANSACTION_CODES=System.Label.ABANDONED_TRNX_CODE_SET;
    public static final String PAYMENT_PENDING_REPORT = System.Label.NLS_Payment_Report_Pending;
    public static final String PAYMENT_PENDING_REPORT_FOLDER = System.Label.NLS_Payment_Report_Folder;
    public static final String DEALER_CIF_NUMBER= System.Label.External_Dealer_CIF_Number;
    public static final String MOBILE_DEPOSIT_PENDING_REPORT_FOLDER = System.Label.NLS_Mobile_Deposit_Report_Folder;
    public static final String MOBILE_DEPOSIT_PENDING_REPORT = System.Label.NLS_Mobile_Deposit_Report_Pending;
    public static final String CFA_ORGANISATION = System.Label.CFA_Sender_Name;
    public static final Integer MAX_TRANCHES = Integer.valueOf(System.Label.MAX_TRANCHES);
    public static final String PRODUCT_RETURN_REPORTS = System.Label.Loan_Accounting_Product_Return_Reports;
    public static final String PRODUCT_RETURN_PENDING = System.Label.Loan_Accounting_Product_Return_Pending;
    public static final String PRODUCT_RETURN_INITIATED = System.Label.Loan_Accounting_Product_Return_Initiated;
    public static final String PRODUCT_RETURN_POSTED = System.Label.Loan_Accounting_Product_Return_Posted;
    public static final String DEALER_ONLINE_PAYMENT_REPORTS = System.Label.Dealer_Online_Payment_Reports;
    public static final String DEALER_ONLINE_PAYMENT_INITIATED = System.Label.Dealer_Online_Payment_Initiated;
    public static final String DEALER_ONLINE_PAYMENT_POSTED = System.Label.Dealer_Online_Payment_Posted;
    public static final String DEALER_ONLINE_PAYMENT_PENDING = System.Label.Dealer_Online_Payment_Pending;
    public static final String EMAIL_TEMP_EXIST_GROWER = System.Label.Email_For_Existing_Members;
    public static final String EMAIL_TEMP_GROWER = System.Label.Email_for_New_Member_Welcome;
    public static final String GMK_EMAIL_TEMP_GROWER = System.Label.GMK_New_Member_Welcome_Email;
    public static final String CFA_LOGO = System.Label.CFA_Logo_Url;
    public static final String LANDUS_LOGO = System.Label.Landus_Logo_Url;
    public static final String GMK_LOGO = System.Label.GMK_Logo_Url;
    public static final String CFA_REGISTRATION_URL = System.Label.CFA_Registration_Url;
    public static final String LANDUS_REGISTRATION_URL = System.Label.Landus_Registration_Url;
    public static final String GMK_REGISTRATION_URL = System.Label.GMK_Registration_Url;
    public static final String GMK_PHONE = System.Label.Gmk_Grower_Phone;
    public static final String PHONE = System.Label.Grower_Phone;
    public static final String LANDUS_SHARED_INBOX_EMAIL = System.label.Landus_Shared_Email;
    public static final String CREATE_DELETE_PARTY_BATCH_SIZE = System.label.Create_Or_Delete_Party_Batch_Size;
    public final static String CFA_NAME = System.label.CFA_Organization_Name;
    public final static String GMK_NAME = System.label.GMK_Organization_Name;
    public final static String LANDUS_NAME = System.label.Landus_Organization_Name;

    public static final String SELECT_GMK_DEALER='Please select Growmark Dealer';
    
    //Constants with Exception messages.
    public static final String INVALID_DATE = 'ERROR: INVALID DATE';
    public static final String CALLOUT_EXCEPTION = 'ERROR: Callout fails';
    public static final String CIF_IS_EMPTY = 'ERROR: CIF number is Empty.';
    public static final String INVALID_PARTY_TYPE = 'ERROR: Invalid Party Type';
    public static final String SOMETHING_WENT_WRONG = 'ERROR: SOMETHING WENT WRONG';
    public static final String INTEGRATION_FAILED = 'Callout failed: Getting null response';
    public static final String ACCOUNT_ID_MISSING = 'ERROR: Accound Id is Missing.';
    public static final String EMAIL_SEND_FAILED = 'ERROR: FAILED TO SEND THE EMAIL';
    public static final String LIST_ACCOUNT_IS_EMPTY = 'ERROR: Account List is Empty';
    public static final String PARAMETER_MISSING = 'ERROR: Required parameter is Missing.';
    public static final String ACCESS_TOKEN_NULL = 'ERROR: could not generate the Access Token';
    public static final String ORGWIDE_ADDRESS_NOT_FOUND = 'ERROR: Organization Email Address Not Found.';
    public static final String DEALER_NOT_FOUND = 'ERROR: Dealers not found.';
    public final static String EMAIL_TEMPLATE_ERROR = 'ERROR: Email template could not be fetched ';
        public static final String EMAIL_NOT_FOUND = 'This individual doesn\'t have any email';
    public static final String CREDENTIAL_ERROR = 'DocuSign Credentials missing';

    //Profile Setup Constant
    public static final String INSUFFICIENT_ACCESS = 'Insufficient Permission: You do not have the necessary permission for this action.';
    public static final String PROFILE_ADMIN = 'System Administrator';
    public static final String PROFILE_CFA_ADMIN = 'CFA Admin User';
    public static final String PROFILE_LOAN_ACCOUNTING = 'Loan Accounting';
    public static final String PROFILE_CREDIT = 'Credit';
    public static final String PROFILE_EXECUTIVE = 'Executive';
    public static final String PROFILE_FIELD_STAFF = 'Field Staff';
    public static final String PROFILE_MASTER_CREDIT = 'Master Credit';
    public static final List<String> PARTY_FICO_CALLOUT_PERMISSIONED_USER_LIST = new List<String>{PROFILE_ADMIN,
                                                                                                    PROFILE_CFA_ADMIN,
                                                                                                    PROFILE_CREDIT,
                                                                                                    PROFILE_MASTER_CREDIT};

    //NTB Error
    public static final String NTB_INVALID_CROPYEAR = 'Please enter a valid Crop Year! Crop Year must be 4 digits long and should contain numbers only.';
    public static final String NTB_NOAPPLICATION = 'There are no Active Application of this Crop Year';
    public static final String NTB_BLANK_CROPYEAR = 'Please enter Crop Year';
    public static final String NTB_BLANK_DOCUMENT='Please generate NTB documents first';

    // Book to error
    public static final String INSUFFICIENT_DEALER_FUND = 'Available dealer fund is insufficient.';

    // Coop Type
    global final static String GROWMARK_COOP_TYPE = 'Growmark';
    global final static String CFA_COOP_TYPE = 'CFA';
    global final static String LANDUS_COOP_TYPE = 'Landus';
    global final static String CONDUIT_COOP_TYPE = 'Landus-Conduit';
    global final static String KEY_GREY_LABEL = 'GreyLabel';

    // Statement Code
    public static final String COMMITMENT_STATEMENT_CODE_SUFFIX = ' COMMITMENT STATEMENT CODE';
    public static final String MONTHLY_STATEMENT_CODE_SUFFIX = ' MONTHLY STATEMENT CODE';

    // Special Character Constants
    public static final String HYPHEN_STRING = '-';
    public static final String DOLLAR_STRING = '$';
    public static final String PERCENTAGE_STRING = '%';
    public static final String SPACE_STRING = ' ';
    public static final String UNDERSCORE_STRING = '_';
    public static final String COMMA_STRING = ',';
    public static final String FORMAT_TO_DECIMAL_STRING = '.00';
    public static final String FORMAT_STRING = '0';
    public static final String PERIOD_STRING = '.';
    public static final String EMPTY_STRING = '';
    public static final String BRACKETS_STRING = '()';
    public static final String LEFT_SQUARE_BRACKET_STRING = '[';
    public static final String RIGHT_SQUARE_BRACKET_STRING = ']';
    public static final String IMAGE_SLASH_STRING = 'image/';
    public static final String PUBLIC_STRING = 'public';

    // Decimal Constants
    public static final Integer ZERO_VALUE = 0;
    public static final Integer ONE_VALUE = 1;
    public static final Integer TWO_VALUE = 2;
    public static final Integer FOUR_VALUE = 4;
    public static final Integer FIVE_VALUE = 5;
    public static final Integer SEVEN_VALUE = 7;
    public static final Integer EIGHT_VALUE = 8;
    public static final Integer NINE_VALUE = 9;
    public static final Integer TEN_VALUE = 10;
    public static final Integer TWELVE_VALUE = 12;
    public static final Integer FIFTEEN_VALUE = 15;
    public static final Integer TWENTY_SIX_VALUE = 26;
    public static final Integer SIXTY_FIVE_VALUE = 65;
    public static final Integer TWO_HUNDRED_VALUE = 200;

    // User related constants
    public static final String CUSTOMER_COMMUNITY_PLUS = 'Customer Community Plus';
    public static final String LICENSES_FETCHING_ERROR = 'Licenses could not be fetch';
    public static final String NO_LICENSES = 'Unfortunately, we are currently out of licenses.';
    public static final String ISO_ENCODING = 'ISO-8859-1';
public static final String ADMIN_ADMIN_USER_NAME = 'Admin Admin';

    // Interest Rate Type
    public static final String VARIABLE_STRING = 'Variable';

    //Crop Year
    public static final String CROPYEAR_XXI = '2021';
    public static final String CROPYEAR_XXII = '2022';
    public static final String CROPYEAR_XXIII = '2023';

    //Base Rate
    public static final String CFA_ADVANTAGE_RATE = 'CFA Advantage Rate';
    public static final String FIELD_FINANCE_RATE = 'Field Finance Rate';
    public static final String FS_INDEX_RATE = 'FS Index Rate';

    //Exception
    public static final String LIST_EMPTY_CHECK = 'List is Empty';
    public static final String EMPTY_PARAMETERS = 'Empty Parameters';
    public static final String RECORD_TYPE_NOT_FOUND = 'Record Type Not Found';
    public static final String PARTNER_PROGRAM_NOT_FOUND = 'Partner Program Not Found';

    //Base Rate Change
    public static final String DUMMY_RECORD = System.Label.DummyRecord;
    public static final String BASERATE_NOTIFICATION = 'All rate cards have been updated.';
    public static final String BASERATE_TITLE = ' has been updated.';
    public static final String BASE_RATE_NOTIFICATION_TYPE = 'Base_Rate_Change_Notification';
    public static final String LOAN_ACCOUNTING_GROUP = 'Loan Accounting Group';

    //Email Log Related Constant
    public static final String KEY_FROM_ADDRESS = 'fromAddress';
    public static final String KEY_TO_ADDRESS = 'toAddress';
    public static final String KEY_EMAIL_TEMPLATE = 'emailtemplateForLog';
    public static final String KEY_MESSAGE = 'messageLog';
    public static final String KEY_CLASS_NAME = 'className';
    public static final String KEY_EMAIL_STATUS = 'emailStatus';
    public static final String SUCCESS_STATUS = 'Success';
    public static final String FAILURE_STATUS = 'Failure';
    public static final String EMAIL_MISSING = 'Recipient Email Missing'; 
    public static final String LOAN_NUMBER_MISSING = 'Loan Number Missing';
    public static final String SENDER_MISSING = 'Sender Address Missing';
    public static final String KEY_ERROR_MESSAGE = 'errorMessage';



    // Regex Expressions
    public static final String NON_ALPHA_NUMERIC_REGEX = '[^a-zA-Z0-9]';
    public static final String EMAIL_REGEX = '^[a-zA-Z0-9._|\\\\%⌗~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    public static final String ESCAPED_AMPERSAND = '&amp;';
    public static final String AMPERSAND = '&';
    public static final String ESCAPED_QUOTE = '&quot;';
    public static final String DOUBLE_QUOTE = '"';
    public static final String SINGLE_QUOTE = '\'';
    public static final String ESCAPED_SINGLE_QUOTE = '&#39;';
    public static final String DOUBLE_ESCAPED_AMPERSAND = '&amp;amp;';
    public static final String DOUBLE_ESCAPED_QUOTE = '&amp;quot;';
    public static final String DOUBLE_ESCAPED_SINGLE_QUOTE = '&amp;#39;';
    public static final String LESS_THAN_SIGN = '<';
    public static final String GREATER_THAN_SIGN = '>';
    public static final String ESCAPED_GREATER_THAN_SIGN = '&gt;';
    public static final String ESCAPED_LESS_THAN_SIGN = '&lt;';
    public static final String DOUBLE_ESCAPED_LESS_THAN_SIGN = '&amp;lt;';
    public static final String DOUBLE_ESCAPED_GREATER_THAN_SIGN = '&amp;gt;';
    public static final String ESCAPED_PARAGRAPH_TAG = '&lt;p&gt;';
    public static final String ESCAPED_CLOSING_PARAGRAPH_TAG = '&lt;/p&gt;';




    // Account Record Types
    public static final String DEALER = 'Dealer';
    public static final String CERTIFIED_LENDER ='Certified Lender';
    public static final String CERTIFIED_LENDER_PLUS ='Certified Lender Plus';
    public static final String PAYMENT_ADMINISTRATOR = 'Payment Administrator';
    public static final String FIELD_STAFF_AGENT ='Field Staff Agent';
    public static final String INQUIRY ='Inquiry';
    public static final String INQUIRY_PLUS ='Inquiry Plus';
    public static final String SALES_AGENT ='Sales Agent';
    public static final String SALES_AGENT_PLUS ='Sales Agent Plus';
    public static final String SALES_AGENT_ADMIN ='Sales Agent Admin';
    public static final String AUTHORIZED_PERSON ='Authorized Person';
    public static final String AGRIBUSINESS ='AgriBusiness';
    public static final String GENERAL_MANAGER ='General Manager';
    public static final String PRIMARY_CONTACT ='Primary Contact';
    public static final String COAPPLICANT ='CoApplicant';
    public static final String GROWER ='Grower';
    public static final String BUYER ='BUYER';
    public static final String INSURANCE_AGENT ='Insurance Agent';
    public static final String SPOUSE ='Spouse';
    public static final String LANDOWNER ='Landowner';
    public static final String OTHER ='Other';
    public static final String MAP_IS_EMPTY = 'Map is empty.';

    //Signing Methods
    public static final String HYBRID_DOCUSIGN = 'Hybrid - Docusign';
    public static final String IN_PERSON_HYBRID = 'DocuSign Hybrid';
    public static final String IN_PERSON_DOCUSIGN = 'In Person - Docusign';
    public static final String EMAIL_DOCUSIGN = 'Email - Docusign';

    //Invoice Keys
    public static final String INVOICE_ID_KEY = 'InvoiceId';
    
    public static final String DATE_TIME_FORMAT = 'yyyy-MM-dd HH:mm:ss';
    
    public static final String NO_REPORT_FOUND = 'No report found with the given ID.';
    public static final String SPACE_HYPEN_SPACE_STRING = ' - ';
    public static final String DOT_XLS_STRING = '.xls';
    public static final String STATUS_INITIATED = 'Initiated';
    public static final Boolean TRUE_VALUE = true;
    public static final Boolean FALSE_VALUE = false;

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
    public static final String STATUS_POSTED = 'Posted';
    public static final String KEY_FUNDING_TRANSACTION_LIST = 'fundingTransactionList';
    public static final String KEY_INVOICE_ID_SET = 'invoiceIdSet';


    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_VOIDED = 'Voided';
    public static final String APPLICATION_ID_KEY = 'applicationId';
    public static final String KEY_AMOUNT = 'amount';
    public static final String ID_KEY = 'Id';
    public static final String KEY_TOTAL_PRINCIPAL = 'totalPrincipal';
    public static final String KEY_TOTAL_INTEREST= 'totalInterest';
    public static final String KEY_TOTAL_FEES= 'totalFees';
    public static final String KEY_TOTAL_AMOUNT= 'totalAmount';
    public static final String KEY_TOTAL_COUNT  = 'totalCount';
    public static final String KEY_CLEAR_OR_POST_COUNT = 'clearOrPostCount';

    public static final String INVALID_INVOICE = 'Invalid invoice number.';
    public static final String KEY_RESOURCE= '/resource/';
    public static final String NO_TRANSACTION_DATA = 'No transaction data is available for this invoice.';

}