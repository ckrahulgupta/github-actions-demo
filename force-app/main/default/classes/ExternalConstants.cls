/**
 * @description       : purpose of this class is to store all the constant values for external apis
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Rakesh Saraf
**/
public inherited sharing class ExternalConstants {
    //coop types
    public static final String LANDUS_COOP_TYPE = 'Landus';
    public final static String GROWMARK_COOP_TYPE = 'Growmark';
    public final static String CONDUIT_COOP_TYPE = 'Landus-Conduit';

    //legal entity types
    public static final String SOLE_PROP_ENTITY = 'Individual(s) - Sole Proprietorship';
    public static final String INDIVIDUAL_ENTITY = 'Individual(s) with DBA';
    public static final String CORPORATION = 'Corporation';
    public final static String GENERAL_PARTNERSHIP = 'General Partnership';
    public final static String LIMITED_PARTNERSHIP = 'Limited Partnership';
    public final static String TRUST = 'Trust';
    public final static String LIMITED_LIABILITY_COMPANY = 'Limited Liability Company';
    public final static String JOINT_VENTURE = 'Joint Venture';

    public final static String GROWER_PROFILE = 'Grower';
    public final static String CO_APPLICATION_RECORD_TYPE = 'CoApplicant';

    //titles for coapplicant
    public final static String PRESIDENT = 'President';
    public final static String VIDE_PRESIDENT = 'Vice President';
    public final static String SECRETARY = 'Secretary';
    public final static String TREASURER = 'Treasurer';
    public final static String DIRECTOR = 'Director';
    public final static String PARTNER = 'Partner';
    public final static String MEMBER = 'Member';
    public final static String MANAGER = 'Manager';
    public final static String TRUSTEE = 'Trustee';
    public final static String CO_APPLICANT = 'Co-Applicant';

    //general symbols
    public static final String HYPHEN_STRING = '-';
    public static final String DOLLAR_STRING = '$';
    public static final String PERCENTAGE_STRING = '%';
    public static final String SPACE_STRING = ' ';
    public static final String COMMA_STRING = ',';
    public static final String EMPTY_STRING = '';
    public static final String SLASH_STRING = '/';
    public static final String DOT_STRING = '.';
    public static final String AT_STRING  = '@';
    public static final String DOT_COM_STRING  = '.com';
    public static final String QUESTION_MARK_STRING  = '?';
    public static final String EQUALS_STRING  = '=';
    public static final String AMPERSAND_STRING  = '&';

    //regex
    public static final String EMAIL_REGEX = '^[a-zA-Z0-9._|\\\\%⌗~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 


    //numbers
    public static final Integer ZERO_VALUE = 0;
    public static final Integer ONE_VALUE = 1;
    public static final Integer NINE_VALUE = 9;

    //status codes 
    public static final Integer FOUR_HUNDRED_STATUS_CODE = 400;
    public static final Integer TWO_HUNDRED_ONE_STATUS_CODE = 201;
    public static final Integer FIVE_HUNDRED_STATUS_CODE = 500;
    public static final Integer FOUR_HUNDRED_ONE_STATUS_CODE = 401;
    public static final Integer FOUR_HUNDRED_THREE_STATUS_CODE = 403;
    public static final Integer TWO_HUNDRED_STATUS_CODE = 200;
    public static final Integer TWO_HUNDRED_TWO_STATUS_CODE = 202;


    //error messages
    public static final String USER_NOT_AUTHORISED = 'User is not authorized to perform this operation.';
    public static final String USERID_ALREADY_ASSIGNED = 'The applicant already exist in the system with a different user id.';
    public static final String SOMETHING_WENT_WRONG = 'Something went wrong.';
    public static final String UNEXPECTED_ERROR = 'An unexpected error has occurred. Please try again after some time.';
    public static final String REQUIRED_PARAMETERS_MISSING = 'Required parameters missing.';

    public final static String APPLICATION_DETAILS_MISSING = 'Application details missing.';
    public final static String BORROWER_DETAILS_MISSING = 'Borrower details missing.';
    public final static String PRINCIPAL_DETAILS_MISSING = 'Primary co-applicant details missing.';
    public final static String ENTITY_TYPE_MISSING = 'Applicant entity type missing.';
    public final static String APPLICANT_NAME_MISSING = 'Applicant name missing.';
    public final static String PRINCIPAL_NAME_MISSING = 'Principal name missing.';
    public final static String TOTAL_ASSETS_MISSING = 'Total Assets missing.';
    public final static String TOTAL_LIABILITIES_MISSING = 'Total Liabilities missing.';
    public final static String LOAN_AMOUNT_MISSING = 'Loan amount missing.';
    public final static String INVALID_LOAN_AMOUNT = 'Invalid loan amount.';
    public final static String INVALID_SUFFIX = 'Invalid suffix.';
    public final static String INVALID_BIRTHDATE = 'Invalid birthdate.';
    public final static String INVALID_MARITAL_STATUS = 'Invalid marital status.';
    public final static String INVALID_STATE_INCORPORATION = 'Invalid state of incorporation.';
    public final static String TITLE_MISSING = 'Title missing.';
    public final static String INVALID_TITLE = 'Invalid title.';
    public final static String PHONE_NUMBER_MISSING = 'Phone number missing.';
    public final static String POSTAL_CODE_MISSING = 'Postal code missing.';
    public final static String STATE_MISSING = 'State missing.';
    public final static String STREET_MISSING = 'Street missing.';
    public final static String CITY_MISSING = 'City missing.';
    public final static String COUNTY_MISSING = 'County missing.';
    public final static String BIRTHDATE_MISSING = 'Birthdate missing.';
    public final static String MARITAL_STATUS_MISSING = 'Marital status missing.';
    public final static String SOI_MISSING = 'State of incorporation missing.';

    public final static String SSN_MISSING = 'Social security number missing.';
    public final static String TIN_MISSING = 'Tax identification number missing.';
    public final static String BORROWER_USER_ID_MISSING = 'Borrower user id missing.';
    public final static String PRINCIPAL_USER_ID_MISSING = 'Principal user id missing.';
    public final static String INVALID_SSN = 'Invalid SSN.';
    public final static String INVALID_TIN = 'Invalid TIN.';
    public final static String INVALID_EMAIL = 'Invalid email address.';
    public final static String INVALID_PHONE_NUMBER = 'Invalid phone number.';
    public final static String SSN_CONFIRM_SSN_MISMATCH = 'The confirm SSN does not match the SSN.';
    public final static String TIN_CONFIRM_TIN_MISMATCH = 'The confirm TIN does not match the TIN.';
    public final static String EMAIL_CONFIRM_EMAIL_MISMATCH = 'The confirm email does not match the email.';
    public final static String LEGAL_ENTITY_MISMATCH = 'The legal entity type does not match.';
    public final static String BORROWER_ACCOUNT_NOT_FOUND = 'Borrower account not found';
    public final static String BORROWER_CONTACT_NOT_FOUND = 'Borrower contact not found';
    public final static String BORROWER_PARTY_NOT_FOUND = 'Borrower party not found';
    public final static String BORROWER_BUSINESS_INFO_NOT_FOUND = 'Borrower business information not found';
    public final static String PRINCIPAL_NOT_FOUND = 'Primary coapplicant not found.';
    public final static String COAPPLICANT_ALREADY_ADDED = ' is already added to the application';

    public final static String CROP_COMMODITY_FIELD_MISSING = 'Please enter the commodity for the crop information.';
    public final static String CROP_TOTAL_ACRES_FIELD_MISSING = 'Please enter the total acres for the crop information.';
    public final static String CROP_PRODUCER_SHARE_PERCENT_FIELD_MISSING = 'Please enter the producers share percent for the crop information.';
    public final static String CROP_APPROVED_YIELD_FIELD_MISSING = 'Please enter the approved yield for the crop information.';
    public final static String CROP_INSURANCE_PLAN_FIELD_MISSING = 'Please enter the insurance plan for the crop information.';
    public final static String CROP_PERCENT_COVERAGE_LEVEL_FIELD_MISSING = 'Please enter the percent coverage level for the crop information.';
    public final static String CROP_PERCENT_FED_FIELD_MISSING = 'Please enter the percent fed for the crop information.';
    public final static String CROP_INVALID_TOTAL_ACRES_VALUE = 'Total acres value should be a valid number.';
    public final static String CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE = 'Producer\'s share percent value should be between 0 and 100.';
    public final static String CROP_INVALID_APPROVED_YIELD_VALUE = 'Approved yield value should be a valid number.';
    public final static String CROP_INVALID_PERCENT_FED_VALUE = 'Percent fed value should be in between 0 and 100.';
    public final static String CROP_INVALID_COMMODITY_TYPE = 'Commodity value should be a valid option chosen from the dropdown.';
    public final static String CROP_INVALID_INSURANCE_PLAN_TYPE = 'Insurance plan value should be a valid option chosen from the dropdown.';
    public final static String CROP_INVALID_PERCENT_COVERAGE_LEVEL_TYPE = 'Percent coverage level value should be a valid option chosen from the dropdown.';
    public final static String SPOUSE_NAME_MISSING = 'Spouse name missing';
    public final static String LANDOWNER_DETAILS_MISSING = 'Landowner details missing';
    public final static String BUYER_DETAILS_MISSING = 'Buyers detail missing';
    public final static String INSURANCE_AGENT_DETAIL_MISSING = 'Insurance Agent detail missing';
    public final static String APPLICATION_ID_MISSING = 'Application id missing';
    public final static String USER_ID_MISSING = 'User id missing';
    public final static String APPLICATION_NOT_FOUND = 'Application not found';
    public final static String FED_COLLATERAL_MISSING = 'Feed collateral missing';
    public final static String COLLATERAL_MISSING = 'Collaterals missing';
    public final static String INVALID_LEGAL_ENTITY_TYPE = 'Invalid legal entity type';
    public final static String CROP_DETAILS_KEY_MISSING = 'crop_details key missing';
    public final static String INSURANCE_AGENT_KEY_MISSING = 'insurance_agent_details key missing';
    public final static String BUYER_KEY_MISSING = 'buyer_details key missing';
    public final static String LANDOWNER_KEY_MISSING = 'landowner_details key missing';
    public final static String SPOUSE_KEY_MISSING = 'spouse_details key missing';
    public final static String POSTAL_CODE_INVALID = 'Invalid postal code';
    public final static String STATE_INVALID = 'State should be a valid option chosen from the dropdown.';
    public final static String SIGNING_METHOD_MISSING = 'Signing method missing';
    public final static String SIGNING_METHOD_INVALID = 'Invalid signing method';
    public final static String DOC_CATEGORY_MISSING = 'Document category missing';
    public final static String PARTY_MISSING = 'Party missing';
    public final static String CO_APPLICANT_MISSING = 'Please add a Co-Applicant';
    public final static String SIGNING_WITHOUT_APPLICANT_INFO = 'Please fill out the Applicant Information properly before Signing the application';
    public final static String APPL_FIRST_NAME_MISSING = 'Applicant first name missing.';
    public final static String APPL_LAST_NAME_MISSING = 'Applicant last name missing.';
    public final static String APPL_ADDRESS_MISSING = 'Applicant address missing.';
    public final static String APPL_CITY_MISSING = 'Applicant city missing.';
    public final static String APPL_STATE_MISSING = 'Applicant state missing.';
    public final static String APPL_COUNTY_MISSING = 'Applicant county missing.';
    public final static String APPL_PHONE_MISSING = 'Applicant Phone Number missing.';
    public final static String APPL_ZIP_CODE_MISSING = 'Applicant ZIP code missing.';
    public final static String APPL_MARITAL_STATUS_MISSING = 'Applicant marital status missing.';
    public final static String APPL_SSN_MISSING = 'Applicant Social Security Number missing.';
    public final static String APPL_CONFIRM_SSN_MISSING = 'Applicant Confirm Social Security Number missing.';
    public final static String APPL_DATE_OF_BIRTH_MISSING = 'Applicant date of birth missing.';
    public final static String APPL_TOTAL_ASSETS_MISSING = 'Applicant total assets missing.';
    public final static String APPL_TOTAL_LIABILITIES_MISSING = 'Applicant total liabilities missing.';
    public final static String APPL_TOTAL_ASSETS_INVALID = 'Applicant total assets invalid.';
    public final static String APPL_TOTAL_LIABILITIES_INVALID = 'Applicant total liabilities invalid.';

    public final static String APPL_NAME_MISSING = 'Applicant Name missing.';
    public final static String APPL_TAX_ID_MISSING = 'Applicant TAX Id missing.';
    public final static String CO_APPL_FIRST_NAME_MISSING = 'Co-Applicant first name missing.';
    public final static String CO_APPL_LAST_NAME_MISSING = 'Co-Applicant last name missing.';
    public final static String CO_APPL_ADDRESS_MISSING = 'Co-Applicant address missing.';
    public final static String CO_APPL_CITY_MISSING = 'Co-Applicant city missing.';
    public final static String CO_APPL_STATE_MISSING = 'Co-Applicant state missing.';
    public final static String CO_APPL_COUNTY_MISSING = 'Co-Applicant county missing.';
    public final static String CO_APPL_ZIP_CODE_MISSING = 'Co-Applicant Zip code missing.';
    public final static String CO_APPL_MARITAL_STATUS_MISSING = 'Co-Applicant marital status missing.';
    public final static String CO_APPL_SSN_MISSING = 'Co-Applicant Social Security Number missing.';
    public final static String CO_APPL_DATE_OF_BIRTH_MISSING = 'Co-Applicant date of birth missing.';
    public final static String CO_APPL_TOTAL_ASSETS_MISSING = 'Co-Applicant total assets missing.';
    public final static String CO_APPL_TOTAL_LIABILITIES_MISSING = 'Co-Applicant total liabilitiesof missing.';
    public final static String CO_APPL_TOTAL_ASSETS_INVALID = 'Co-Applicant total assets invalid.';
    public final static String CO_APPL_TOTAL_LIABILITIES_INVALID = 'Co-Applicant total liabilities invalid.';
    public final static String APPL_MOBILE_MISSING ='Applicant contact number missing.';
    public final static String EMAIL_FIELD_MISSING = 'Applicant email is missing.';
    public final static String CONTACT_NUMBER_MISSING = 'Atleast one contact number of an applicant is required.';
    public final static String SIGNED_AGREEMENT_TASK_MISSING = 'Signed Agreement Task missing';
    public final static String APP_STATUS_INVALID = 'Invalid application status';
    public final static String APPLICANT_INVALID = 'Applicant party invalid or missing';
    public final static String SIGNING_METHOD_CANNOT_BE_UPDATED = 'Signing method cannot be updated for this application status';
    public final static String DEALER_DETAILS_MISSING = 'Dealer Details Missing';
    public final static String DEALER_CIF_MISSING = 'Dealer cif missing';
    public final static String DEALER_TOKEN_MISSING = 'Dealer token missing';
    public final static String DEALER_TOKEN_INVALID = 'Invalid dealer token';
    public final static String DEALER_CIF_INVALID = 'Invalid dealer cif';
    public final static String INVALID_APP_FOR_RESEND_DOCUSIGN = 'Application no longer applicable for DocuSign. Please contact CFA.';

    public static final string PAST_DUE_APPLICATIONS_EXCEPTION = 'Applicant has pending past due applications, could not initiate new application.';
    public static final string NON_ACCRUAL_APPLICATIONS_EXCEPTION = 'Applicant has pending non accrual applications, could not initiate new application.';
    public static final string NON_ACCRUAL_APPLICANT_EXCEPTION = 'One or more of the applicants is linked with a non accrual application.';
    public static final string PAST_DUE_APPLICANT_EXCEPTION = 'One or more of the applicants is linked with a past due application.';
    public static final string NO_SIGNING_METHOD = 'Signing method is not saved for this application.';
    public static final string APP_IS_NOT_READY_FOR_SCORING = 'Application is not ready for scoring.';
    public static final string COAPP_SSN_MISSING = 'Please enter the Social Security Number of the Co-Applicant.';
    public static final string COAPP_CONFIRM_SSN_MISSING = 'Please enter the Confirm Social Security Number of the Co-Applicant.';

//keys 
    public static final String ID = 'id';
    public static final String APPLICATION_DETAIL_KEY = 'application_details';
    public static final String BORROWER_DETAIL_KEY = 'borrower_details';
    public static final String PRINCIPAL_DETAIL_KEY = 'principal_details';
    public static final String USER_ID_KEY = 'user_id';
    public static final String LAST_NAME_KEY = 'last_name';
    public static final String FIRST_NAME_KEY = 'first_name';
    public static final String NAME_KEY = 'name';
    public static final String EMAIL_KEY = 'email';
    public static final String CONFIRM_EMAIL_KEY = 'confirm_email';
    public static final String PHONE_NUMBER_KEY = 'phone_number';
    public static final String WORK_PHONE_KEY = 'work_phone_number';
    public static final String HOME_PHONE_KEY = 'home_phone_number';
    public static final String TAX_ID_KEY = 'tin';
    public static final String CONFIRM_TAX_ID_KEY = 'confirm_tin';

    public static final String BIRTHDATE_KEY = 'birthdate';
    public static final String MARITAL_STATUS_KEY = 'marital_status';
    public static final String SUFFIX_KEY = 'suffix';
    public static final String TITLE_KEY = 'title';

    public static final String TOTAL_ASSETS_KEY = 'total_assets';
    public static final String TOTAL_LIABILITIES_KEY = 'total_liabilities';
    public static final String GROSS_FARM_INCOME_KEY = 'gross_farm_income';
    public static final String YEAR_BEGAN_FARMING_KEY = 'year_began_farming';
    public static final String INTERNAL_REFERENCE_CODE_KEY = 'internal_reference_code';
    public static final String STATE_OF_INCORPORATION_KEY = 'state_of_incorporation';

    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String APPLICATION_JSON = 'application/json';
    public static final String ENTITY_TYPE = 'entity_type';
    public static final String GENESIS_BUSINESS_INFORMATION_KEY ='genesis__business_information__c';
    public static final String GENESIS_ACCOUNT_KEY ='genesis__account__c';
    public static final String GENESIS_CONTACT_KEY ='genesis__Contact__c';
    public static final String LOAN_AMOUNT_KEY ='loan_amount';
    public static final String BORROWER_ACCOUNT_KEY ='borrowerAccount';
    public static final String BORROWER_CONTACT_KEY ='borrowerContact';
    public static final String PRINCIPAL_ACCOUNT_KEY ='principalAccount';
    public static final String PRINCIPAL_CONTACT_KEY ='principalContact';
    public static final String PRINCIPAL_PARTY_KEY ='principalParty';
    public static final String BORROWER_BUSINESS_KEY ='borrowerBusiness';

    public static final String COMMODITY_KEY = 'commodity';
    public static final String TOTAL_ACRES_KEY = 'total_acres';
    public static final String PRODUCER_SHARE_PERCENT_KEY = 'producer_share_percent';
    public static final String APPROVED_YEILD_KEY = 'approved_yield';
    public static final String INSURANCE_PLAN_KEY = 'insurance_plan';
    public static final String COVERAGE_LEVEL_PERCENT_KEY = 'coverage_level_percent';
    public static final String COLLATERAL_FED_PERCENT = 'collateral_fed_percent';
    public static final String STATE_KEY = 'state';
    public static final String COUNTY_KEY = 'county';
    public static final String STREET_KEY = 'street';
    public static final String CITY_KEY = 'city';
    public static final String POSTAL_CODE_KEY = 'postal_code';
    public static final String PHONE_KEY = 'phone';
    public static final String MIDDLE_NAME_KEY = 'middle_name';
    public static final String SSN_KEY = 'ssn';
    public static final String CONFIRM_SSN_KEY = 'confirm_ssn';
    public static final String APPLICATION_KEY = 'application';
    public static final String USER_KEY = 'user';
    public static final String CROP_DETAILS_KEY = 'crop_details';
    public static final String INSURANCE_AGENT_KEY = 'insurance_agent_details';
    public static final String BUYER_KEY = 'buyer_details';
    public static final String LANDOWNER_KEY = 'landowner_details';
    public static final String SPOUSE_KEY = 'spouse_details';
    public static final String ID_KEY = 'id';
    public static final String FED_COLLATERAL_KEY = 'do_feed_collateral';
    public static final String COLLATERAL_KEY = 'collaterals';
    public static final String STATUS_KEY = 'status';
    public static final String MESSAGE_KEY = 'message';
    public static final String BODY_KEY = 'body';
    public static final String CONTENT_KEY = 'content';
    public static final String RECORD_TYPE_MAP_KEY = 'recordTypeMap';
    public static final String PARTY_TYPE_MAP_KEY = 'partyTypeMap';
    public static final String AGGREGATE_KEY = 'expr0';
    public static final String SIGNING_METHOD_KEY = 'signing_method_details';
    public static final String TYPE_KEY = 'signing_type';
    public static final String BORROWER_ACC_ID_KEY = 'borrowerAccId';
    public static final String BORROWER_CONTACT_ID_KEY = 'borrowerContactId';
    public static final String BORROWER_BINFO_ID_KEY = 'borrowerBInfoId';
    public static final String DOCUSIGN_URL_KEY = 'docusign_url';
    public static final String RECORDS_KEY = 'records';
    public static final String DONE_KEY = 'done';
    public static final String TOTAL_SIZE_KEY = 'totalSize';
    public static final String PRICING_DETAIL_KEY = 'genesis__Pricing_Details__r';

    public static final String APP_STATUS_KEY = 'application_status';
    public static final String CREDIT_RATING_KEY = 'credit_rating';
    public static final String NOT_PROVIDED_MARITAL_STATUS = 'Not Provided';

    public static final String DEALER_DETAILS_KEY = 'dealer_details';
    public static final String DEALER_CIF_KEY = 'x-dealer-cif';
    public static final String DEALER_TOKEN_KEY = 'x-dealer-token';
    public static final String RESEND_DOCUSIGN_KEY = 'resend_docusign';
 
    public static final String DUPLICATE_DETAILS_KEY = 'duplicate_details';
    public static final String DUPLICATE_CONTACT_ID_KEY = 'duplicate_contact_id';
    
    
    //String values
    public static final String NONE_VALUE = 'None';
    public static final String SUCCESS = 'Success';
    public static final String COMMODITY_VALUE = 'Commodity';
    public static final String INSURANCE_PLAN_RP_VALUE = 'RP';
    public static final String INSURANCE_PLAN_ARP_VALUE = 'ARP';
    public static final String INSURANCE_PLAN_ARH_VALUE = 'ARH';
    public static final String PARTY_TYPE = 'partyType';
    public static final String SPOUSE_PARTY_NAME = 'SPOUSE';
    public static final String LANDOWNER_PARTY_NAME = 'LANDOWNER';
    public static final String BUYER_PARTY_NAME = 'BUYER';
    public static final String INSURANCE_AGENT_PARTY_NAME = 'INSURANCE AGENT';
    public static final String SUCCESS_VALUE = 'SUCCESS';
    public static final String FAILURE_VALUE = 'FAILURE';
    public static final String RECORD_CREATED_VALUE = 'Record created successfully';
    public static final String TIER_THREE_CREDIT = 'Tier 3';
    public static final String IN_PERSON_DOCUSIGN = 'In Person - Docusign';
    public static final String EMAIL_DOCUSIGN = 'Email - Docusign';
    public static final String IN_PERSON_HYBRID = 'DocuSign Hybrid';
    public final static String PAPER_SCANNED = 'Paper - Scanned';
    public static final String SIGNING_TASK = 'Signed Credit Agreement';
    public static final String APPLICANT_SIGNATURE ='Applicant Signature';
    public static final String APPLICANT_INFORMATION = 'Applicant Information';
    public static final String OPEN_TASK_STATUS = 'OPEN';
    public static final String E_SIGN_PENDING_APPLICATION_STATUS = 'SIGNATURE PENDING';
    public static final String SIGNING_METHOD_SAVED = 'Signing method saved successfully';
    public static final String SIGNING_COMPLETED = 'Signing Completed';
    public static final String PENDING_VALUE = 'PENDING';
    public static final String STATUS_SENT = 'Sent';
    public static final String STATUS_DELIVERED = 'Delivered';
    public static final String PARTY_STATUS_COMPLETED = 'E-Sign Completed';
    public static final String APPLICANT_SIGNING_COMPLETED = 'This applicant signature is completed';
    public static final String SCORE_INITIATED_MESSAGE_KEY = 'Scoring has been initiated';
    public static final String NA_VALUE = 'NA';
    public static final String RESEND_DOCUSIGN_INITIATED = 'DocuSign initiated successfully!';
    public static final String APPLICANT_ACCOUNT = 'applicantAccount';
    public static final String APPLICANT_CONTACT = 'applicantContact';
    public static final String APPLICANT_BUSINESS = 'applicantBusiness';
    public static final String DEALER_ACCOUNT = 'dealerAccount';
    public static final String PRINCIPAL_ACCOUNT_ID = 'principalAccountId';
    public static final String PRINCIPAL_CONTACT_ID = 'principalContactId';
    public static final String CONTACT_KEY = 'Contact';
    public static final String ACCOUNT_KEY = 'Account';


    //dealer relations
    public final static String FIELD_STAFF_AGENT ='Field Staff Agent';
    public final static String CERTIFIED_LENDER_PLUS ='Certified Lender Plus';
    public final static String CERTIFIED_LENDER ='Certified Lender';
    public final static String PAYMENT_ADMINISTRATOR = 'Payment Administrator';
    public final static String SALES_AGENT_ADMIN ='Sales Agent Admin';
    public final static String SALES_AGENT_PLUS ='Sales Agent Plus';
    public final static String SALES_AGENT ='Sales Agent';
    public final static String INQUIRY_PLUS ='Inquiry Plus';
    public final static String INQUIRY ='Inquiry';
    
    //party types
    public final static String BORROWER_PARTY = 'BORROWER';
    public final static String PRINCIPAL_PARTY = 'PRINCIPAL';
    public final static String DEALER_PARTY = 'DEALER';
    public final static String FIELD_STAFF_AGENT_PARTY ='FIELD STAFF AGENT';
    public final static String CERTIFIED_LENDER_PLUS_PARTY = 'CERTIFIED LENDER PLUS';
    public final static String CERTIFIED_LENDER_PARTY = 'CERTIFIED LENDER';
    public final static String SALES_AGENT_ADMIN_PARTY ='SALES AGENT ADMIN';
    public final static String SALES_AGENT_PARTY ='SALES AGENT';
    public final static String PAYMENT_ADMINISTRATOR_PARTY = 'PAYMENT ADMINISTRATOR';
    public final static String INQUIRY_PLUS_PARTY = 'INQUIRY PLUS';
    public final static String INQUIRY_PARTY = 'INQUIRY';

    //Application Default Values
    public final static Integer INTEREST_RATE = 0;
    public final static Integer TERM = 12;
    public final static String PACKAGE_TYPE = 'PACKAGE';
    public final static String LOAN_TYPE = 'LOAN';
    public final static String SIMPLIFY_TYPE = 'Simpli-Fi';
    public final static String RATE_CARD_STRING = 'RATE CARD';

    //Application Status
    public final static String NEW_ENTERED_APPLICATION_STATUS = 'NEW - ENTERED';
    public final static String PENDING_APPROVAL_APPLICATION_STATUS = 'PENDING APPROVAL';
    public final static String ACTIVE_APPLICATION_STATUS = 'ACTIVE';
    public final static String CLOSED_APPLICATION_STATUS = 'CLOSED';
    public final static String SIGNATURE_COMPLETED_APPLICATION_STATUS = 'SIGNATURE COMPLETED';
    public final static String NEW_SCORECARD_GENERATED_APPLICATION_STATUS = 'NEW - SCORECARD GENERATED';
}