/**
 * @description       : Constant class to keep the custom messages used for throwing exception or setting up response
 * @author            : Suraj Kumar | 11-22-2024
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : Sk Minsar
**/
public inherited sharing class CustomMessageConstants {
  
    public final static String BLANK_INVOICE = 'Invoice should not be blank';
    public final static String BLANK_COMMENT = 'Comment should not be blank';
    public final static String INVOICE_NOT_FOUND = 'Invoice not found';
    public final static String BLANK_EMAIL = 'Email should not be blank';
    public final static String INVALID_EMAIL = 'Email should be a valid email';
    //RequestBodyGeneratorHelper Exception messages start
    public final static String APPLICATION_NOT_SUBMITTED = 'Please Submit the Application before Booking it to Core';
    public final static String STATEMENT_CODE_ERROR = 'No Statement Code found on the application';
    public final static String DEALER_PRICING_TIER_MISSING = 'Dealer\'s pricing tier is missing';
    public final static String GROWER_CIF_MISSING = 'Grower CIF is missing';
    public final static String DEALER_CIF_MISSING = 'Dealer CIF is missing';
    public final static String LOAN_NUMBER_MISSING = 'Loan Number is missing';
    public final static String APPLICATION_ENTITY_MISSING = 'Application Entity is missing';
    public final static String GROWER_TAXID_MISSING = 'Grower Tax Id is missing';
    public final static String GROWER_SSN_MISSING = 'Grower SSN is missing';
    public final static String GROEWR_ACCOUNT_NAME_MISSING = 'Grower Account Name is missing';
    public final static String MATURITY_DATE_MISSING = 'Maturity Date of the application is missing';
    public final static String CROP_YEAR_MISSING = 'Crop Year for the application is missing';
    public final static String APPLICATION_GURANTEE_MISSING = 'Application Guarantee is missing';
    public final static String APPLICATION_LOAN_AMOUNT_MISSING = 'Application Loan Amount is missing';
    public final static String CREDIT_TOTAL_DRAW_LIMIT_MISSING = 'Credit Total Draw Limit is missing';
    public final static String SIGNING_METHOD_MISSING = 'Signing Method is missing';
    public final static String CREDIT_RATING_MISSING = 'Application is not scored';

    public final static String DEALER_ACCOUNT_MISSING = 'Dealer Account is missing from the application';
    public final static String DEALER_CITY_MISSING = 'Dealer City is missing';
    public final static String DEALER_STATE_MISSING = 'Dealer State is missing';
    public final static String DEALER_PORTFOLIO_MANAGER_MISSING = 'Dealer Portfolio Manager is missing';
    public final static String DEALER_PROD_AG_OFFICER_MISSING = 'Dealer Prod Ag Officer is missing';

    public final static String CHILD_LOAN_NUMBER_MISSING = 'Child Loan Number is missing';
    public final static String LOAN_DESCRIPTION_MISSING = 'Loan Description is missing';
    public final static String INTEREST_RATE_MISSING = 'Loan Interest Rate is missing';
    public final static String INTEREST_RATE_TYPE_MISSING = 'Loan Interest Rate Type is missing';
    public final static String CFA_PARTICIPATION_RATE_MISSING = 'CFA Participation rate is missing';
    public final static String START_DATE_MISSING = 'Loan Start Date is missing';
    public final static String END_DATE_MISSING = 'Loan End Date is missing';

    public final static String MY_PROGRAM_MISSING = 'My Program is missing from this application';
    public final static String PAYER_MISSING = 'Payer for My Program advance is missing';
    public final static String EFFECTIVE_DATE_MISSING = 'My Program Effective Date is missing';
    public final static String LOAN_NUMBER_ADVANCED_ON_MISSING = 'Loan Number advanced on is missing';
    //RequestBodyGeneratorHelper Exception messages end

    //Transactions Exception messages
    public final static String UNABLE_TO_DELETE_RECORD = 'Unable to delete the record.';
    public final static String NO_INVOICE_RECORD_FOUND = 'No Invoice Records Found.';
}