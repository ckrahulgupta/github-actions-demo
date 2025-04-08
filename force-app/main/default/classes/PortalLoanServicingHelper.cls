/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/

global inherited sharing class PortalLoanServicingHelper {

    private static final String KEY_TOTAL = 'total';
    private static final String KEY_ID = 'Id';
    private static final String KEY_FEES = 'fees';
    private static final String KEY_PRINCIPAL = 'principal';
    private static final String KEY_INTEREST = 'interest';
    private static final String APP_ID = 'applicationId';
    private static final String KEY_PRICING_DET = 'pricingDetail';
    private static final String KEY_LOAN_NUM = 'loanNumber';
    private static final String KEY_GROWER = 'grower';
    private static final String KEY_INTR_RATE = 'interestRate';
    private static final String KEY_DESCR = 'description';
    private static final String PAYMENT_OPTION = 'paymentOption';
    private static final String BANK_DETAILS = 'bankDetails';
    
    
    private static final String CAPITAL_A = 'A';
    private static final String CURRENT_OUT_STANDING = 'currOutStanding';
    private static final String PAYMENT_AMOUNT = 'paymentAmount';
    private static final String KEY_MAKE_PAYMENT = 'makePayment';
    private static final String PAYMENT_SPREAD_TYPE = 'paymentSpreadType';
    private static final String PAYMENT_SPREAD_VALUE = 'value';
    private static final String PAYOFF_INTEREST_TO_BE_PAID = 'Interest_To_Be_Paid__c';
    private static final String PAYOFF_FEES_TO_BE_PAID = 'Fees_To_Be_Paid__c';
    private static final String PAYOFF_PRINCIPAL_TO_BE_PAID = 'Principal_To_Be_Paid__c';
    private static final String PAYOFF_PAYMENT = 'Payment__c';

    /*CFAS-6163*/
    public static final String CFA_LOGO_URL = System.Label.CFA_Logo_Url;
    public static final String GMK_LOGO_URL = System.Label.GMK_Logo_Url;
    public static final String LANDUS_LOGO_URL = System.Label.Landus_Logo_Url;
    public static final String GROWER = '{!GrowerName}';
    public static final String TOTAL_PAYMENT = '{!TotalPayment}';
    public static final String POST_DATE = '{!DatePosted}';
    public static final String SIGNATURE = '{!Signature}';
    public static final String GROWER_NAME = 'Grower Name';
    public static final String COOP_TYPE = 'Coop Type';
    public static final String DEALER_MK_PAYMENT_ON_GROWER_BEHALF_ET = 'Dealer Make Payment on Growers Behalf';
    public static final String DEALER_MK_PAYMENT_ON_MOBILE_DEP_ET = 'Dealer Make Payment on Mobile Deposit';
    public static final String DEALER_DELETES_PAYMENT_ON_DEALER_PORTAL_ET = 'Dealer Deletes Payment on Dealer Portal';
    public static final String GROWER_SUBMT_PAYMENT_GROWER_PORTAL_ET = 'Grower Submits Payment in Grower Portal';
    public static final String GROWER_DELETES_PAYMENT_GROWER_PORTAL_ET = 'Grower Deletes Payment in Grower Portal';
    public static final Decimal TotalAmount = 0.0;	
    public static final String CFA_SIGNATURE = 'Cooperative Finance Association';
    public static final String GMK_SIGNATURE = 'FS Agri-Finance';
    public static final String LANDUS_SIGNATURE = 'Landus Financing';

    @testVisible
    static List<Email_Recipient__mdt> emailRecipientMappings {
      get {
        if (emailRecipientMappings == null) {
          emailRecipientMappings = [
            SELECT
              DeveloperName,
              MasterLabel,
              Coop_Type__c,
              Dealer_CIF__c,
              Email__c,
              Email_Template__c
            FROM Email_Recipient__mdt
          ];
        }
        return emailRecipientMappings;
      }
      set;
    }
	

  /**
   * @description Null check Request Body value
   * @param request 
   * @param param 
   * @exception 
   */
    public static void checkRequestBody(Map<String, Object> request, String param){
        if(request.get(param)== null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }

    /**
     * @description Null check request param
     * @param request 
     * @param paymentParam 
     * @exception 
     */
    public static void checkRequestParam( Map<String, Object> request,String paymentParam){
        if (!request.containsKey(paymentParam)) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    /**
     * @description Get Current Loan
     * @param applicationId 
     * @return  `List<genesis__Applications__c>`
     * @exception 
     */
    public static  List<genesis__Applications__c> getCurrentLoan(String applicationId){
        List<genesis__Applications__c> currentLoan = [SELECT Id, 
                                                                 genesis__Maturity_Date__c, 
                                                                 genesis__Account__c, 
                                                                 Past_Due_Amount__c,
                                                                 Dealer_Name__c, 
                                                                 Dealer_Name__r.Coop_Type__c,
                                                                 genesis__Account__r.Name,
                                                                 Pay_Off__c,
                                                                 Pay_Off_Date__c                                                      
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :applicationId 
                                                          AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                          LIMIT 1];

        if (currentLoan.size() != 1) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        return currentLoan;
    }

    /**
     * @description Get Logged In user
     * @return  `List<User>`
     * @exception 
     */
    public static List<User> getLoggedInUser(){
        List<User> currentUserList = [SELECT Id, 
                                                AccountId,
                                                Account.Name,
                                                Account.ParentId,
                                                Account.RecordType.Name,
                                                Email 
                                        FROM User 
                                        WHERE Id =:UserInfo.getUserId() 
                                        LIMIT 1];
        if(currentUserList.size() == 0){
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
        return currentUserList;
    }

    /**
     * @description Check Previous Due Loan
     * @param applicationId 
     * @exception 
     */
    public static void checkPastDueLoan(String applicationId){
        List<genesis__Applications__c> currentLoanList = [SELECT Id,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Id =: applicationId];
        if(currentLoanList.size()!= 1){
            throw new CustomException(PortalConstants.NO_APPLICATIONS_FOUND);
        }                                               
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                                FROM genesis__Applications__c
                                                                WHERE genesis__Maturity_Date__c < :currentLoanList[0].genesis__Maturity_Date__c
                                                                AND genesis__Account__c = :currentLoanList[0].genesis__Account__c
                                                                AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                                AND Past_Due_Amount__c > 0];
        if(applicationList.size() > 0){
            throw new CustomException(PortalConstants.PREVIOUS_LOAN_PAYOFF_ERROR);
        }
    }
    /**
     * @description Validate payment for payoff
     * @param outstandingPaymentsMap 
     * @param userPaymentsMap 
     * @param key 
     * @exception 
     */
    public static void paymentValidationForPayoff(Map<String, Map<String, Object>> outstandingPaymentsMap, 
                                                    Map<String, Map<String, Object>> userPaymentsMap,
                                                    String key){
        if (userPaymentsMap.containsKey(key) && ((Decimal) userPaymentsMap.get(key).get(KEY_PRINCIPAL) != (Decimal) outstandingPaymentsMap.get(key).get(KEY_PRINCIPAL) || 
                                                                                                        (Decimal) userPaymentsMap.get(key).get(KEY_INTEREST) != (Decimal) outstandingPaymentsMap.get(key).get(KEY_INTEREST) || 
                                                                                                        (Decimal) userPaymentsMap.get(key).get(KEY_FEES) != (Decimal) outstandingPaymentsMap.get(key).get(KEY_FEES) || 
                                                                                                        (Decimal) userPaymentsMap.get(key).get(KEY_TOTAL) != (Decimal) outstandingPaymentsMap.get(key).get(KEY_TOTAL))) {
            throw new CustomException(PortalConstants.UNEQUAL_PAYOFF);
        }
    }

    /**
     * @description Validate for exceeded payment
     * @param outstandingPaymentsMap 
     * @param userPaymentsMap 
     * @param key 
     * @exception 
     */
    public static void paymentValidationForExceededPayment(Map<String, Map<String, Object>> outstandingPaymentsMap, 
                                                                Map<String, Map<String, Object>> userPaymentsMap,
                                                                String key){
        if (userPaymentsMap.containsKey(key) && ((Decimal) userPaymentsMap.get(key).get(KEY_PRINCIPAL) > (Decimal) outstandingPaymentsMap.get(key).get(KEY_PRINCIPAL) || 
                                                                                                            (Decimal) userPaymentsMap.get(key).get(KEY_INTEREST) > (Decimal) outstandingPaymentsMap.get(key).get(KEY_INTEREST) || 
                                                                                                            (Decimal) userPaymentsMap.get(key).get(KEY_FEES) > (Decimal) outstandingPaymentsMap.get(key).get(KEY_FEES) || 
                                                                                                            (Decimal) userPaymentsMap.get(key).get(KEY_TOTAL) > (Decimal) outstandingPaymentsMap.get(key).get(KEY_TOTAL))) {
                throw new CustomException(PortalConstants.EXCEEDED_PAYMENT);
        }

    }
    /**
     * @description Get Payment Mode
     * @param paymentMode 
     * @return  `List<clcommon__Payment_Mode__c>`
     * @exception 
     */
    public static List<clcommon__Payment_Mode__c> getPaymentMode(String paymentMode){
        List<clcommon__Payment_Mode__c> paymentModesList = [SELECT Id,
                                                                    Name                                                            
                                                                FROM clcommon__Payment_Mode__c 
                                                                WHERE Name = :paymentMode
                                                                LIMIT 1];
        if (paymentModesList.isEmpty()) {
            throw new CustomException(PortalConstants.INVALID_PAYMENT_MODE);
        }
        return paymentModesList;
    }

    /**
     * @description Create Funding Transaction
     * @param outstandingPayment 
     * @param userPayment 
     * @param paymentModeId 
     * @return  `genesis__Funding_Transaction__c`
     * @exception 
     */
    public static genesis__Funding_Transaction__c createFundingTransactionForUserPayment(
                                                    Map<String, Object> outstandingPayment, 
                                                    Map<String, Object> userPayment,
                                                    String paymentModeId
                                                ) {

        genesis__Funding_Transaction__c fundingTransaction = new genesis__Funding_Transaction__c();


        fundingTransaction.genesis__Payment_Mode__c =  paymentModeId; 
        fundingTransaction.genesis__Funding_Date__c = System.today();
        fundingTransaction.Grower_Name__c = (String) outstandingPayment.get(KEY_GROWER);
        fundingTransaction.genesis__Reference__c = (String) outstandingPayment.get(KEY_DESCR);
        fundingTransaction.Rate__c = (Decimal) outstandingPayment.get(KEY_INTR_RATE);
        fundingTransaction.Principal__c = (Decimal) outstandingPayment.get(KEY_PRINCIPAL);
        fundingTransaction.Interest__c = (Decimal) outstandingPayment.get(KEY_INTEREST);
        fundingTransaction.Fees__c = (Decimal) outstandingPayment.get(KEY_FEES);
        fundingTransaction.Pricing_Detail__c = String.valueOf(outstandingPayment.get(KEY_ID));
        Decimal totalDue = (Decimal)(outstandingPayment.get(KEY_TOTAL));
        fundingTransaction.Fees_Paid__c = (Decimal) userPayment.get(KEY_FEES);
        fundingTransaction.Interest_Paid__c = (Decimal) userPayment.get(KEY_INTEREST);
        fundingTransaction.Principal_Paid__c = (Decimal) userPayment.get(KEY_PRINCIPAL);
        fundingTransaction.genesis__Amount__c = (Decimal) userPayment.get(KEY_TOTAL);

        if( fundingTransaction.genesis__Amount__c > totalDue || 
            fundingTransaction.Principal_Paid__c > fundingTransaction.Principal__c || 
            fundingTransaction.Interest_Paid__c > fundingTransaction.Interest__c || 
            fundingTransaction.Fees_Paid__c > fundingTransaction.Fees__c){
            throw new CustomException(PortalConstants.EXCEEDED_PAYMENT);
        }


        return fundingTransaction;
    }
    
    /**
     * @description validate Amount spread
     * @param userPaymentsMap 
     * @param paymentAmount 
     * @param paymentDetailsMap 
     * @exception 
     */
    public static void validateTotalAmountSpread(Map<String, Map<String, Object>> userPaymentsMap, Decimal paymentAmount, Map<String,Object> paymentDetailsMap){
        String paymentOption = (String) paymentDetailsMap.get(PAYMENT_OPTION);
        Decimal currentOutstanding = (Decimal) paymentDetailsMap.get(CURRENT_OUT_STANDING);
        Decimal totalAmountSpread = 0;
        String paymentMode = paymentOption.equals(KEY_MAKE_PAYMENT) ? ConstantValues.PAYMENT : ConstantValues.MOBILE_DEPOSIT;
        for (String key : userPaymentsMap.keySet()) {
            totalAmountSpread += (Decimal) userPaymentsMap.get(key).get(KEY_FEES) 
                                    + (Decimal) userPaymentsMap.get(key).get(KEY_INTEREST) 
                                    + (Decimal) userPaymentsMap.get(key).get(KEY_PRINCIPAL);                 
        }

        if ((paymentAmount <= currentOutstanding || paymentMode.equals(ConstantValues.PAYMENT)) && totalAmountSpread != paymentAmount) {
            throw new CustomException(PortalConstants.SPREAD_ALL_PAYMENT_AMOUNT);
        }
        validateOverPayment(paymentAmount, totalAmountSpread, paymentDetailsMap);
        // if(paymentAmount > currentOutstanding && paymentMode.equals(ConstantValues.MOBILE_DEPOSIT) && totalAmountSpread != currentOutstanding){
        //     throw new CustomException(PortalConstants.SPREAD_ALL_OUTSTANDING);
        // }
    }

    /**
    * @description 
    * @author Suraj Kumar | 11-24-2023 
    * @param paymentAmount 
    * @param totalAmountSpread 
    * @param paymentDetailsMap 
    **/
    public static void validateOverPayment(Decimal paymentAmount, Decimal totalAmountSpread, Map<String,Object> paymentDetailsMap){
        String paymentOption = (String) paymentDetailsMap.get(PAYMENT_OPTION);
        Decimal currentOutstanding = (Decimal) paymentDetailsMap.get(CURRENT_OUT_STANDING);
        String paymentMode = paymentOption.equals(KEY_MAKE_PAYMENT) ? ConstantValues.PAYMENT : ConstantValues.MOBILE_DEPOSIT;

        if(paymentAmount > currentOutstanding && paymentMode.equals(ConstantValues.MOBILE_DEPOSIT) && totalAmountSpread != currentOutstanding){
            throw new CustomException(PortalConstants.SPREAD_ALL_OUTSTANDING);
        }
    }



    /**
     * @description Get all outsanding payment
     * @param applicationId 
     * @param currentOutstandingPayment 
     * @return  `Decimal`
     */
    public static Decimal getCurrentOutStandingPaymentsMap(String applicationId, Map<String, Map<String, Object>> currentOutstandingPayment) {
        Decimal totalPayOffAmount = 0;
        List<genesis__Application_Pricing_Detail__c> pricingDetails = 
                                [SELECT Id,
                                        Loan_Number__c,
                                        genesis__Rate_Card_Setup_Detail__r.Description__c,
                                        genesis__Application__r.genesis__Account__r.Name,
                                        genesis__Interest_Rate__c,
                                        Principal_Advanced__c,
                                        Accrued_Interest__c,
                                        Fees__c,
                                        Credit_Balance__c,
                                        Total_Payoff__c
                                FROM genesis__Application_Pricing_Detail__c
                                WHERE genesis__Application__c = :applicationId
                                AND genesis__Enabled_Flag__c = :PortalConstants.TRUE_VALUE
                                ORDER BY genesis__Interest_Rate__c DESC, 
                                        Loan_Number__c ASC];

        for (genesis__Application_Pricing_Detail__c pricingDetail : pricingDetails) {

            Map<String, Object> pricingDetailMap = new Map<String, Object>();
            pricingDetailMap.put(KEY_ID, pricingDetail.Id);
            pricingDetailMap.put(KEY_LOAN_NUM, pricingDetail.Loan_Number__c);
            pricingDetailMap.put(KEY_GROWER, pricingDetail.genesis__Application__r.genesis__Account__r.Name);
            pricingDetailMap.put(KEY_INTR_RATE, pricingDetail.genesis__Interest_Rate__c == null ? 0 : pricingDetail.genesis__Interest_Rate__c);
            pricingDetailMap.put(KEY_DESCR, pricingDetail.genesis__Rate_Card_Setup_Detail__r.Description__c);
            pricingDetailMap.put(KEY_PRINCIPAL, pricingDetail.Principal_Advanced__c == null ? 0 : pricingDetail.Principal_Advanced__c);
            pricingDetailMap.put(KEY_INTEREST, pricingDetail.Accrued_Interest__c == null ? 0 : pricingDetail.Accrued_Interest__c);
            pricingDetailMap.put(KEY_FEES, pricingDetail.Fees__c == null ? 0 : pricingDetail.Fees__c);
            pricingDetailMap.put(KEY_TOTAL, pricingDetail.Total_Payoff__c == null ? 0 : pricingDetail.Total_Payoff__c);
            pricingDetailMap.put(KEY_PRICING_DET, pricingDetail);
            totalPayOffAmount += pricingDetail.Total_Payoff__c;

            currentOutstandingPayment.put(pricingDetail.Id, pricingDetailMap);
           
        }
        return totalPayOffAmount;
    }

    /**
     * @description Check maturity date is near or not
     * @param maturityDate 
     * @return  `Boolean`
     */
    public static Boolean isCloseToMaturity(Date maturityDate) {

        Integer maturityMonth = maturityDate.month();
        Integer maturityYear = maturityDate.year();

        Date nextMonthDate = System.today().addMonths(1);
        //Integer nextMonthDay= nextMonthDate.day();
        Integer nextMonthMonth = nextMonthDate.month();
        Integer nextMonthYear = nextMonthDate.year();

        // for loans maturing next month and today is passed 26th of current month
        if (maturityMonth == nextMonthMonth 
                && maturityYear == nextMonthYear 
                && System.today().day() > 26) {
            return PortalConstants.TRUE_VALUE;
        }

        // for loans past maturity date
        if((maturityYear == nextMonthYear && maturityMonth < nextMonthMonth) 
                    || (maturityYear < nextMonthYear && maturityMonth < (nextMonthMonth + 12))){
            return PortalConstants.TRUE_VALUE;
        }

        return PortalConstants.FALSE_VALUE;

    }
    /**
     * @description validate Dealer bank Info
     * @param applicationObj 
     * @return  `String`
     * @exception 
     */
    public static String validateDealerBankAccount(genesis__Applications__c applicationObj) {
        //Get the ACH Debit bank information for the dealer
        if(applicationObj.Dealer_Name__c == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        List<clcommon__Bank_Account__c> dealerBankAccount = [SELECT Id 
                                                            FROM clcommon__Bank_Account__c 
                                                            WHERE ACH_Debit__c = :PortalConstants.TRUE_VALUE AND 
                                                                clcommon__Account__c = :applicationObj.Dealer_Name__c AND 
                                                                clcommon__Active__c = :PortalConstants.TRUE_VALUE
                                                            ORDER BY createddate desc];
        if(dealerBankAccount.size() == 0){
            throw new CustomException(PortalConstants.ACH_AUTHORIZATION_ERROR);
        }
        return dealerBankAccount[0].Id;
    }

    /**
     * @description Validate bank Info
     * @param bankDetailsId 
     * @param loggedInGrowerAccountId 
     * @exception 
     */
    public static void validateBankAccount(String bankDetailsId, String loggedInGrowerAccountId){
        List<clcommon__Bank_Account__c> objBankAccountList = [ SELECT Id,
                                                                        clcommon__Account__c
                                                                    FROM clcommon__Bank_Account__c
                                                                    WHERE id = :bankDetailsId AND 
                                                                    clcommon__Account__c = :loggedInGrowerAccountId];
        if(objBankAccountList.size() == 0){
            throw new CustomException(PortalConstants.INVALID_BANK);
        }
    }

    /**
     * @description validate Applicant to pay
     * @param applicationId 
     * @param loggedInGrowerAccountId 
     * @exception 
     */
    public static void validateApplicantToPay(String applicationId,String loggedInGrowerAccountId){
        List<clcommon__Party__c> validApplicantsToPay = [SELECT Id 
                                                                    FROM clcommon__Party__c 
                                                                    WHERE genesis__Application__c = :applicationId AND 
                                                                    clcommon__Account__c =:loggedInGrowerAccountId AND
                                                                    clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME,:PortalConstants.PRINCIPAL_PARTY_NAME)];
        if(validApplicantsToPay.size() == 0){
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }
    /**
     * @description 
     * @param outstandingPaymentsMap 
     * @param paymentsSpreadMap 
     * @param dataMap 
     * @return  `Map<String,Object>`
     */
    public static Map<String,Object> spreadPayment( Map<String, Map<String, Object>> outstandingPaymentsMap,Map<String, Map<String, Object>> paymentsSpreadMap, Map<String,Object> dataMap){
        String paymentSpreadType = String.valueOf(dataMap.get(PAYMENT_SPREAD_TYPE));
        Decimal paymentAmount = (Decimal) dataMap.get(PAYMENT_AMOUNT);
        Decimal value = (Decimal) dataMap.get(PAYMENT_SPREAD_VALUE);
        if (paymentAmount > 0) {
            for (String key : outstandingPaymentsMap.keySet()) {
                if ((Decimal) outstandingPaymentsMap.get(key).get(paymentSpreadType) > 0) {
                    value = Math.min(paymentAmount, (Decimal) outstandingPaymentsMap.get(key).get(paymentSpreadType));
                    paymentsSpreadMap.get(key).put(paymentSpreadType, value);
                    paymentAmount -= value;
                }
            }     
        }
        Map<String,Object> spreadMap = new Map<String,Object>{
            PAYMENT_AMOUNT => paymentAmount,
            PAYMENT_SPREAD_VALUE => value
        };
        return spreadMap;
    }
    /**
     * @description Get Payment Spread
     * @param paymentAmount 
     * @param outstandingPaymentsMap 
     * @return  `Map<String, Map<String, Object>>`
     */
    public static Map<String, Map<String, Object>> getPaymentsSpreadMap(Decimal paymentAmount, 
                                                                                Map<String, Map<String, Object>> outstandingPaymentsMap) {
        Map<String, Map<String, Object>> paymentsSpreadMap = new Map<String, Map<String, Object>>();

         Decimal value = 0;
         Map<String,Object> spreadMap = new Map<String,Object>();

        // initialize the payment spread with 0
        for (String key : outstandingPaymentsMap.keySet()) {
            Map<String, Object> spread = new Map<String, Object>{
                KEY_FEES => 0,
                KEY_INTEREST => 0,
                KEY_PRINCIPAL => 0
            };
            paymentsSpreadMap.put(key, spread);
        } 
        Map<String,Object> dataMapForFees = new Map<String,Object>{
            PAYMENT_AMOUNT => paymentAmount,
            PAYMENT_SPREAD_TYPE => KEY_FEES,
            PAYMENT_SPREAD_VALUE => value
        };
        spreadMap = spreadPayment(outstandingPaymentsMap, paymentsSpreadMap, dataMapForFees);
        paymentAmount = (Decimal) spreadMap.get(PAYMENT_AMOUNT);
        value = (Decimal)spreadMap.get(PAYMENT_SPREAD_VALUE);

        Map<String,Object> dataMapForInterest = new Map<String,Object>{
            PAYMENT_AMOUNT => paymentAmount,
            PAYMENT_SPREAD_TYPE => KEY_INTEREST,
            PAYMENT_SPREAD_VALUE => value
        };
        spreadMap = spreadPayment(outstandingPaymentsMap, paymentsSpreadMap, dataMapForInterest);
        paymentAmount = (Decimal)spreadMap.get(PAYMENT_AMOUNT);
        value = (Decimal)spreadMap.get(PAYMENT_SPREAD_VALUE);

        Map<String,Object> dataMapForPrincipal = new Map<String,Object>{
            PAYMENT_AMOUNT => paymentAmount,
            PAYMENT_SPREAD_TYPE => KEY_PRINCIPAL,
            PAYMENT_SPREAD_VALUE => value
        };
        spreadMap = spreadPayment(outstandingPaymentsMap, paymentsSpreadMap, dataMapForPrincipal);
        paymentAmount = (Decimal)spreadMap.get(PAYMENT_AMOUNT);
        value = (Decimal)spreadMap.get(PAYMENT_SPREAD_VALUE);

        for (String key : paymentsSpreadMap.keySet()) {
            paymentsSpreadMap.get(key).put(KEY_TOTAL, 
                                    (Decimal) paymentsSpreadMap.get(key).get(KEY_FEES) 
                                        + (Decimal) paymentsSpreadMap.get(key).get(KEY_INTEREST) 
                                        + (Decimal) paymentsSpreadMap.get(key).get(KEY_PRINCIPAL));
        }

        return paymentsSpreadMap;
    }
        /**
     * @description Get user payment map
     * @param userPayments
     * @return  `Map<String, Map<String, Object>>`
     */
    public static Map<String, Map<String, Object>> getUserPaymentsMap(List<Object> userPayments) {
        Map<String, Map<String, Object>> userPaymentsMap = new Map<String, Map<String, Object>>();

        for (Object userPayment : userPayments) {
            Map<String, Object> deserializedPaymentMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(userPayment));
            Map<String, Object> userPaymentMap = new Map<String, Object>();
            userPaymentMap.put(KEY_PRINCIPAL, ((Decimal) deserializedPaymentMap.get(PAYOFF_PRINCIPAL_TO_BE_PAID)).setScale(2));
            userPaymentMap.put(KEY_INTEREST, ((Decimal) deserializedPaymentMap.get(PAYOFF_INTEREST_TO_BE_PAID)).setScale(2));
            userPaymentMap.put(KEY_FEES, ((Decimal) deserializedPaymentMap.get(PAYOFF_FEES_TO_BE_PAID)).setScale(2));
            userPaymentMap.put(KEY_TOTAL, ((Decimal) deserializedPaymentMap.get(PAYOFF_PAYMENT)).setScale(2));

            userPaymentsMap.put((String) deserializedPaymentMap.get(KEY_ID), userPaymentMap);
        } 
        return userPaymentsMap;
    } 

    /**
     * @description The purpose of this method is to spread the amount depends upon the additional check.
     * @param paramMap 
     * @param outstandingPaymentsMap 
     * @param payOffList 
     * @return  `Map<String, Map<String, Object>>`
     */
    public static Map<String, Map<String, Object>> getUserPaymentsSpreadMap(Map<String, Object> paramMap, 
                                                                                    Map<String, Map<String, Object>> outstandingPaymentsMap,
                                                                                    List<Object> payOffList){

        String applicationId = String.valueOf(paramMap.get(KEY_ID));
        Decimal totalPaymentAmountPaid = (Decimal)paramMap.get(PAYMENT_AMOUNT);
        List<genesis__Applications__c> currentLoan = PortalLoanServicingHelper.getCurrentLoan(applicationId);
        
        Boolean applyAdditionalChecks = PortalConstants.FALSE_VALUE;

        if (currentLoan[0].Past_Due_Amount__c > 0 || PortalLoanServicingHelper.isCloseToMaturity(currentLoan[0].genesis__Maturity_Date__c)) {
            applyAdditionalChecks = PortalConstants.TRUE_VALUE;
        }
        if (applyAdditionalChecks) {
            return PortalLoanServicingHelper.getPaymentsSpreadMap(totalPaymentAmountPaid, outstandingPaymentsMap);
        } else {
            return getUserPaymentsMap(payOffList);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 11-10-2023 
    * @param fundingTransactionMap 
    * @param applicationId 
    **/
    public static void isOverpaymentMobileDeposit(Map<String,String> fundingTransactionMap, String applicationId){
        String paymentMode = fundingTransactionMap.get(PAYMENT_OPTION).equals(KEY_MAKE_PAYMENT) ? ConstantValues.PAYMENT : ConstantValues.MOBILE_DEPOSIT;

        if(paymentMode == ConstantValues.MOBILE_DEPOSIT && Decimal.valueOf(fundingTransactionMap.get(PAYMENT_AMOUNT)) > Decimal.valueOf(fundingTransactionMap.get(CURRENT_OUT_STANDING))){
            // overpayment & it's Mobile Deposit
            List<genesis__Application_Pricing_Detail__c> applicationPricingList = [SELECT Id,
                                                                                            Loan_Number__c,
                                                                                            Credit_Balance__c
                                                                                    FROM genesis__Application_Pricing_Detail__c
                                                                                    WHERE genesis__Application__c = :applicationId
                                                                                    AND genesis__Enabled_Flag__c = :PortalConstants.TRUE_VALUE
                                                                                    ORDER BY genesis__Interest_Rate__c DESC, 
                                                                                            Loan_Number__c ASC];

            boolean singleChildLoan = PortalConstants.TRUE_VALUE;
            for(genesis__Application_Pricing_Detail__c pricingDetailObj: applicationPricingList){
                if(pricingDetailObj.Loan_Number__c.substring(pricingDetailObj.Loan_Number__c.length()-1).equals(CAPITAL_A)){
                    pricingDetailObj.Credit_Balance__c += Decimal.valueOf(fundingTransactionMap.get(PAYMENT_AMOUNT)) - Decimal.valueOf(fundingTransactionMap.get(CURRENT_OUT_STANDING));
                    singleChildLoan = PortalConstants.FALSE_VALUE;
                    break;
                }
            }
            if(singleChildLoan && applicationPricingList.size()>0){
                applicationPricingList[0].Credit_Balance__c += Decimal.valueOf(fundingTransactionMap.get(PAYMENT_AMOUNT)) - Decimal.valueOf(fundingTransactionMap.get(CURRENT_OUT_STANDING));
            }
            Database.update(applicationPricingList,PortalConstants.TRUE_VALUE);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 11-28-2023 
    * @param fundingTransactionMap 
    * @param fundingTransactionList 
    **/
    public static void updateOverpaymentAmount(Map<String,String> fundingTransactionMap, List<genesis__Funding_Transaction__c> fundingTransactionList){
        String paymentMode = fundingTransactionMap.get(PAYMENT_OPTION).equals(KEY_MAKE_PAYMENT) ? ConstantValues.PAYMENT : ConstantValues.MOBILE_DEPOSIT;

        if(paymentMode == ConstantValues.MOBILE_DEPOSIT 
        && Decimal.valueOf(fundingTransactionMap.get(PAYMENT_AMOUNT)) > Decimal.valueOf(fundingTransactionMap.get(CURRENT_OUT_STANDING))){
                List<Id> fundingTransactionsId = new List<Id>();
                for(genesis__Funding_Transaction__c fundingTransactionObj: fundingTransactionList){
                    fundingTransactionsId.add(fundingTransactionObj.Id);
                }

                if(fundingTransactionsId.isEmpty()){
                    return;
                }
                List<genesis__Funding_Transaction__c> sortedFundingTxnList = [SELECT Id,
                                                                                        Overpayment_Amount__c,
                                                                                        genesis__Amount__c 
                                                                                    FROM genesis__Funding_Transaction__c
                                                                                    WHERE Id In :fundingTransactionsId
                                                                                    ORDER BY loan_number__c];

                if(sortedFundingTxnList.isEmpty()){
                    return;
                }

                sortedFundingTxnList[0].Overpayment_Amount__c = Decimal.valueOf(fundingTransactionMap.get(PAYMENT_AMOUNT)) - Decimal.valueOf(fundingTransactionMap.get(CURRENT_OUT_STANDING));
                sortedFundingTxnList[0].genesis__Amount__c += sortedFundingTxnList[0].Overpayment_Amount__c;
                Database.update(sortedFundingTxnList,PortalConstants.TRUE_VALUE);
        }
    }
    /**
    * @description 
    * @author Ravi Ranjan | 11-29-2023 
    * @param applicationId 
    * @param paymentMode 
    **/
    public static void deleteMultiFundTrans(String applicationId, String paymentMode){
        List<User> objLoggedInUserList =  [ SELECT Id,
                                                    ContactId,
                                                    Contact.AccountId,
                                                    Contact.Account.ParentId
                                                FROM USER
                                                WHERE Id = :UserInfo.getUserId()];

         //Deleting ALL Pending Payments
         Map<String,Decimal> pricingToFeesPaidMap = new Map<String,Decimal>();
         Map<String,Decimal> pricingToPrincipalPaidMap = new Map<String,Decimal>();
         Map<String,Decimal> pricingToInterestPaidMap = new Map<String,Decimal>();

         Map<String,Decimal> pricingToPrincipalAdvdMap = new Map<String,Decimal>();
         Map<String,Decimal> pricingToAccruedIntrstMap = new Map<String,Decimal>();
         Map<String,Decimal> pricingToFeesMap = new Map<String,Decimal>();
         Decimal overpaymentAmount = 0;

        Map<Id, genesis__Funding_Transaction__c> idToFundingTxnMap = new Map<Id, genesis__Funding_Transaction__c>();
        Map<Id, String> idToFundingAmountMap = new Map<Id, String>();
        Map<Id, String> idToMaturityDateMap = new Map<Id, String>();

        Set<Id> pricingIdSet = new Set<Id>();
        Set<Id> invoiceIdSet = new Set<Id>();
         
        List<genesis__Funding_Transaction__c> objPendingPaymentList = [SELECT Id,
                                                                                 genesis__Amount__c,
                                                                                 Grower_Name__c,
                                                                                 Pricing_Detail__c,
                                                                                 Pricing_Detail__r.Loan_Number__c,
                                                                                 genesis__Application__r.genesis__Loan_Number__c,
                                                                                 genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                                                                 genesis__Application__r.genesis__Account__r.Name,
                                                                                 genesis__Application__r.genesis__Maturity_Date__c,
                                                                                 Pricing_Detail__r.genesis__Application__c,
                                                                                 Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c,
                                                                                 Pricing_Detail__r.Principal_Advanced__c,
                                                                                 Pricing_Detail__r.Accrued_Interest__c,
                                                                                 Pricing_Detail__r.Fees__c,
                                                                                 Pricing_Detail__r.Credit_Balance__c,
                                                                                 genesis__Payment_Mode__r.Name,
                                                                                 Principal_Paid__c,
                                                                                 Interest_Paid__c,
                                                                                 Fees_Paid__c,
                                                                                 Overpayment_Amount__c,
                                                                                 Invoice__c
                                                                             FROM genesis__Funding_Transaction__c
                                                                             WHERE genesis__Payment_Mode__r.name = :paymentMode AND 
                                                                             genesis__Cleared__c = :PortalConstants.FALSE_VALUE AND
                                                                             Posted_to_NLS__c = :PortalConstants.FALSE_VALUE AND 
                                                                             CreatedById = :objLoggedInUserList[0].Id AND 
                                                                             genesis__Application__c = :applicationId];
        
        LoanServicingHelper.checkEmptyList(objPendingPaymentList, CustomMessageConstants.UNABLE_TO_DELETE_RECORD);
        List<genesis__Application_Pricing_Detail__c> childLoansList = new List<genesis__Application_Pricing_Detail__c>();
        for(genesis__Funding_Transaction__c eachFundingTransaction : objPendingPaymentList){
            //Populate the Principal, Interest, Fees Paid Maps
            pricingToFeesPaidMap = populateFromFundTranx(pricingToFeesPaidMap, eachFundingTransaction, eachFundingTransaction.Fees_Paid__c);
            
            pricingToPrincipalPaidMap = populateFromFundTranx(pricingToPrincipalPaidMap, eachFundingTransaction, eachFundingTransaction.Principal_Paid__c);

            pricingToInterestPaidMap = populateFromFundTranx(pricingToInterestPaidMap, eachFundingTransaction, eachFundingTransaction.Interest_Paid__c);

            pricingIdSet.add(eachFundingTransaction.Pricing_Detail__c);
            //Populate Principal Advanced, Accrued Interest, Fees based on Child loan
            pricingToPrincipalAdvdMap.put(eachFundingTransaction.Pricing_Detail__c,eachFundingTransaction.Pricing_Detail__r.Principal_Advanced__c);
            pricingToAccruedIntrstMap.put(eachFundingTransaction.Pricing_Detail__c,eachFundingTransaction.Pricing_Detail__r.Accrued_Interest__c);
            pricingToFeesMap.put(eachFundingTransaction.Pricing_Detail__c,eachFundingTransaction.Pricing_Detail__r.Fees__c);
            

            String amount = String.valueOf(eachFundingTransaction.genesis__Amount__c);
            String str = ( Decimal.valueOf(amount==null||amount.trim()==''?'0':amount).setScale(2) + 0.001 ).format();
            String fundingamount = str.substring(0,str.length()-1);
            String maturityDate=(eachFundingTransaction.genesis__Application__r.genesis__Maturity_Date__c).format();
            idToFundingAmountMap.put(eachFundingTransaction.Id, fundingamount);
            idToFundingTxnMap.put(eachFundingTransaction.Id, eachFundingTransaction);
            idToMaturityDateMap.put(eachFundingTransaction.Id, maturityDate);
            // PortalHelper.sendEmailOnDeletingPendingPayment(eachFundingTransaction.Pricing_Detail__r.Loan_Number__c,eachFundingTransaction.Grower_Name__c,fundingamount,maturityDate);
            // CFAOriginationHelperClass.sendEmailOnDeletingPendingPayment(eachFundingTransaction,fundingamount,maturityDate);
            invoiceIdSet.add(eachFundingTransaction.Invoice__c);
        }
        CFAOriginationHelperClass.sendEmailOnDeletingPendingPayment(idToFundingTxnMap,idToFundingAmountMap,idToMaturityDateMap);
        // populating the value in Overpayment_Amount__c field if it's exist
        overpaymentAmount = populateOverpaymentAmount(objPendingPaymentList, overpaymentAmount);

        //Update the Child loans
        List<Id> childLoanIdList = new List<Id>(pricingIdSet);
        for(Id eachChildLoanId : childLoanIdList){
            genesis__Application_Pricing_Detail__c objChildLoan = new genesis__Application_Pricing_Detail__c(Id = eachChildLoanId);
            if(pricingToFeesPaidMap.containsKey(eachChildLoanId)){
                objChildLoan.Fees__c = pricingToFeesMap.get(eachChildLoanId) + pricingToFeesPaidMap.get(eachChildLoanId);
            }
            if(pricingToPrincipalPaidMap.containsKey(eachChildLoanId)){
                objChildLoan.Principal_Advanced__c = pricingToPrincipalPaidMap.get(eachChildLoanId) + pricingToPrincipalAdvdMap.get(eachChildLoanId);
            }
            if(pricingToInterestPaidMap.containsKey(eachChildLoanId)){
                objChildLoan.Accrued_Interest__c = pricingToInterestPaidMap.get(eachChildLoanId) + pricingToAccruedIntrstMap.get(eachChildLoanId);
            }
            childLoansList.add(objChildLoan);
        }

        //update application
        List<genesis__Applications__c> applicationList = updateApplFundingTransc(applicationId);
        

        Database.update(childLoansList,PortalConstants.TRUE_VALUE);
        Database.delete(objPendingPaymentList,PortalConstants.TRUE_VALUE);
        Database.update(applicationList,PortalConstants.TRUE_VALUE);
        Database.delete(new List<Id>(invoiceIdSet), PortalConstants.TRUE_VALUE);
        
        // calling this method to update credit balance in case of overpayment through mobile deposit
        updateCreditBalance(overpaymentAmount, paymentMode, applicationId);
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-05-2023 
    * @param overpaymentAmount 
    * @param paymentMode 
    * @param applicationId 
    **/
    public static void updateCreditBalance(Decimal overpaymentAmount, String paymentMode, String applicationId){
        if(overpaymentAmount>0 && paymentMode == ConstantValues.MOBILE_DEPOSIT ){
            List<genesis__Application_Pricing_Detail__c> applicationPricingList = [SELECT Id,
                                                                                        Loan_Number__c,
                                                                                        Credit_Balance__c
                                                                                    FROM genesis__Application_Pricing_Detail__c
                                                                                    WHERE genesis__Application__c = :applicationId
                                                                                    AND genesis__Enabled_Flag__c = :PortalConstants.TRUE_VALUE
                                                                                    ORDER BY Loan_Number__c ASC];
            if(applicationPricingList.size() >0){
                applicationPricingList[0].Credit_Balance__c -= overpaymentAmount;
                Database.update(applicationPricingList, PortalConstants.TRUE_VALUE);
            }
        }
    }
    

    /**
    * @description 
    * @author Suraj Kumar | 12-05-2023 
    * @param objPendingPaymentList 
    * @param overpaymentAmount 
    * @return Decimal 
    **/
    public static Decimal populateOverpaymentAmount(List<genesis__Funding_Transaction__c> objPendingPaymentList, Decimal overpaymentAmount){
        for(genesis__Funding_Transaction__c eachFundingTransaction: objPendingPaymentList){
            if(eachFundingTransaction.Overpayment_Amount__c >0){
                overpaymentAmount = eachFundingTransaction.Overpayment_Amount__c;
                break;
            }
        }
        return overpaymentAmount;
    }
    /**
    * @description update payoff and Payoff date
    * @author Ravi Ranjan | 12-01-2023 
    * @param applicationId 
    * @return List<genesis__Applications__c>
    **/
    public static List<genesis__Applications__c> updateApplFundingTransc(String applicationId){
        List<genesis__Applications__c> applicationList = [SELECT Pay_Off__c,
                                                                        Pay_Off_Date__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE Id =: applicationId];
            if(applicationList.size()!= 1){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            if(applicationList[0].Pay_Off__c == 'Yes'){
            applicationList[0].Pay_Off__c = 'No';
            }
            if(applicationList[0].Pay_Off_Date__c != null){
            applicationList[0].Pay_Off_Date__c = null;
            }
            return applicationList;
    }
    /**
    * @description 
    * @author Ravi Ranjan | 12-01-2023 
    * @param pricingMap 
    * @param fundingTxn 
    * @param amountPaid
    * @return Map<String, Decimal> 
    **/
    public static Map<String,Decimal> populateFromFundTranx(Map<String,Decimal> pricingMap, genesis__Funding_Transaction__c fundingTxn, Decimal amountPaid) {
        if(pricingMap.containsKey(fundingTxn.Pricing_Detail__c)){
            Decimal feesPaidTemp = pricingMap.get(fundingTxn.Pricing_Detail__c);
            if(amountPaid != null){
                feesPaidTemp = feesPaidTemp + amountPaid;
            }
            pricingMap.put(fundingTxn.Pricing_Detail__c,
                                    feesPaidTemp);
        }
        else{
            if(amountPaid != null){
                pricingMap.put(fundingTxn.Pricing_Detail__c, amountPaid);
            }
        }
        return pricingMap;
    }
    /** 
    * @description 
    * @author Ravi Ranjan | 11-29-2023 
    * @param recordId 
    **/
    public static void deleteFundingTransaction(String recordId){
        List<genesis__Funding_Transaction__c> objFundingTransactionList = [SELECT Id,
                                                                        genesis__Amount__c,
                                                                        Grower_Name__c,
                                                                        Pricing_Detail__r.Loan_Number__c,
                                                                        genesis__Application__r.genesis__Loan_Number__c,
                                                                        genesis__Application__r.genesis__Account__r.Name,
                                                                        genesis__Application__r.genesis__Maturity_Date__c,
                                                                        Pricing_Detail__r.genesis__Application__c,
                                                                        Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c,
                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                        genesis__Payment_Mode__r.Name,
                                                                        Is_Clearing_Suspense__c,
                                                                        Invoice__c
                                                                    FROM genesis__Funding_Transaction__c
                                                                    WHERE Id =: recordId
                                                                    AND genesis__Cleared__c = :PortalConstants.FALSE_VALUE
                                                                    AND Posted_to_NLS__c = :PortalConstants.FALSE_VALUE];
        LoanServicingHelper.checkEmptyList(objFundingTransactionList,CustomMessageConstants.UNABLE_TO_DELETE_RECORD);
        if(objFundingTransactionList[0].Pricing_Detail__c != null &&
        objFundingTransactionList[0].Pricing_Detail__r.genesis__Application__c != null){
            genesis__Applications__c objApplications = new genesis__Applications__c(Id = objFundingTransactionList[0].Pricing_Detail__r.genesis__Application__c);
            genesis__Application_Pricing_Detail__c objChildLoan = new genesis__Application_Pricing_Detail__c(Id = objFundingTransactionList[0].Pricing_Detail__c);
            if(objFundingTransactionList[0].Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c != null &&
                objFundingTransactionList[0].genesis__Amount__c != null &&
                !objFundingTransactionList[0].Is_Clearing_Suspense__c){
                    updateAppAndChildLoans(objFundingTransactionList[0], objApplications, objChildLoan);
                }
            PaymentInvoiceHelper.updateOrDeleteInvoice(objFundingTransactionList[0].Invoice__c, objFundingTransactionList[0].genesis__Payment_Mode__r.Name, objFundingTransactionList[0].genesis__Amount__c);
            Database.delete(objFundingTransactionList[0], PortalConstants.TRUE_VALUE);
            if(objFundingTransactionList[0].genesis__Payment_Mode__r.Name != ConstantValues.PAYMENT){
                Database.update(objApplications, PortalConstants.TRUE_VALUE);
                Database.update(objChildLoan, PortalConstants.TRUE_VALUE);
            }
        }
    }
    /**
    * @description 
    * @author Ravi Ranjan | 11-30-2023 
    * @param objFundingTransaction 
    * @param objApplications
    * @param objChildLoan
    **/
    public static void updateAppAndChildLoans(genesis__Funding_Transaction__c objFundingTransaction, genesis__Applications__c objApplications,
                                                                                            genesis__Application_Pricing_Detail__c objChildLoan){
        if(objFundingTransaction.genesis__Payment_Mode__r.Name == PortalConstants.PRODUCT_RETURN){
            objApplications.Peak_Loan_Volume__c = objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c + objFundingTransaction.genesis__Amount__c;
            objChildLoan.Principal_Advanced__c = objFundingTransaction.Pricing_Detail__r.Principal_Advanced__c + objFundingTransaction.genesis__Amount__c;
        }
        else{
        objApplications.Peak_Loan_Volume__c = objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c - objFundingTransaction.genesis__Amount__c;
        objChildLoan.Principal_Advanced__c = objFundingTransaction.Pricing_Detail__r.Principal_Advanced__c - objFundingTransaction.genesis__Amount__c;
        }
            
    }
    /**
     * @description Check for blank parameter
     * @param parameter 
     * @exception 
     */ 
    public static void checkForBlankParameter(String parameter){
        if (String.isBlank(parameter)) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    /**
     * @description Throw custom exception if condition is false
     * @param value 
     * @param exceptionString 
     * @exception 
     */
    public static void throwCustomError(Boolean value, String exceptionString){
        if (value) {
            throw new CustomException(exceptionString);
        }
    }                                                                                   
    
    
    /**
    * @description /**CFAS-6163
    * @author Soumik Pattanayak | 08-10-2024 
    * @param applicationId 
    * @return List<genesis__Funding_Transaction__c> 
    **/
    public static  List<genesis__Funding_Transaction__c> getCurrentLoanTransactions(String applicationId){
        List<genesis__Funding_Transaction__c> currentLoanTransactions = [SELECT Id, genesis__Amount__c FROM genesis__Funding_Transaction__c                                                                      
                                                                 WHERE genesis__Cleared__c = :PortalConstants.FALSE_VALUE AND Posted_to_NLS__c = :PortalConstants.FALSE_VALUE AND 
                                                                 Status__c = :PortalConstants.STATUS_PENDING AND CreatedById = :UserInfo.getUserId() AND
                                                                 genesis__Application__c = :applicationId];
        
        return currentLoanTransactions;
    }
    
    
    /**
    * @description /*LAHARI - CFAS_6163
    * @author Soumik Pattanayak | 08-10-2024 
    * @param applicationId 
    * @param emailContext 
    * @param emailMap 
    **/
    public static void sendEmailToCL(String applicationId, String emailContext, Map<String,String> emailMap){  
        
        String EmailTemplateName = '';
        if(emailContext == 'MakePaymentinGrowerPortal'){
            EmailTemplateName = GROWER_SUBMT_PAYMENT_GROWER_PORTAL_ET;
        } else if(emailContext == 'DeleteAllPendingPayment' && emailMap.get('Portal') == 'GrowerPortal'){
            EmailTemplateName = GROWER_DELETES_PAYMENT_GROWER_PORTAL_ET;
        } else if(emailContext == 'MakePaymentDealerPortal' && emailMap.get(PAYMENT_OPTION) == 'makePayment'){
            EmailTemplateName = DEALER_MK_PAYMENT_ON_GROWER_BEHALF_ET;
        } else if(emailContext == 'MakePaymentDealerPortal' && emailMap.get(PAYMENT_OPTION) != 'makePayment'){
            EmailTemplateName = DEALER_MK_PAYMENT_ON_MOBILE_DEP_ET;
        } else if(emailContext == 'DeleteAllPendingPayment' && emailMap.get('Portal') == 'DealerPortal'){
            EmailTemplateName = DEALER_DELETES_PAYMENT_ON_DEALER_PORTAL_ET;
        }
        
        List<EmailTemplate> emailTemplate = PortalHelper.getEmailTemplateList(EmailTemplateName);
        if(EmailTemplateName != '' && emailMap.containsKey(GROWER_NAME) && emailMap.get(GROWER_NAME) != '' && emailTemplate.size()>0) {
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();  
            String logoUrl = CFA_LOGO_URL;
            String signatureStr = CFA_SIGNATURE;
            // if(emailMap.get(COOP_TYPE) == PortalConstants.GROWMARK_COOP_TYPE){
            //     logoUrl = GMK_LOGO_URL;
            //     signatureStr = GMK_SIGNATURE;
            // }else if(emailMap.get(COOP_TYPE) == PortalConstants.LANDUS_COOP_TYPE){
            //     logoUrl = LANDUS_LOGO_URL;
            //     signatureStr = LANDUS_SIGNATURE;
            // } 
            
            List<genesis__Applications__c> appList = [SELECT Id,
                                                            Name, 
                                                            Coop_Type__c,
                                                            Dealer_Name__c,
                                                            Dealer_Name__r.Coop_Type__c,
                                                            Dealer_Name__r.CFA_Partner_Program__c,
                                                            Dealer_Name__r.CFA_Partner_Program__r.Name,
                                                            Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Id =: applicationId];
            

            if(appList[0].Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                logoURL = System.Label.GMK_Logo_Url;
                signatureStr = GMK_SIGNATURE;
            } else {
                if(appList[0].Dealer_Name__r.CFA_Partner_Program__c == null){
                    throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
                } else if(!String.isBlank(appList[0].Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c)){
                    logoURL = ConstantValues.LOGO_BASE_URL + appList[0].Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c;
                    signatureStr = appList[0].Dealer_Name__r.CFA_Partner_Program__r.Name;
                }         
            } 


            OrgWideEmailAddress[] orgWideEmailAddr = [SELECT Id from OrgWideEmailAddress WHERE DisplayName =: ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];          
            
            //Query for Certified lenders       
            for(clcommon__Party__c par: [Select Id, genesis__Application__c, clcommon__Contact__c,
                                         clcommon__Contact__r.Email, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName
                                         from clcommon__Party__c 
                                         WHERE genesis__Application__c =:applicationId 
                                         AND clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                        ]){  
                                            if(par.clcommon__Contact__r.Email != null && par.clcommon__Contact__r.Email != ''){                                      
                                                //send email to all the certified lenders                                            
                                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                                if ( orgWideEmailAddr.size() > 0 ) {
                                                    email.setOrgWideEmailAddressId(orgWideEmailAddr.get(0).Id);
                                                } 
                                                email.subject = emailTemplate[0].Subject;
                                                String emailBody = emailTemplate[0].HtmlValue;
                                                emailBody = emailBody.replace(GROWER,emailMap.get(GROWER_NAME));
                                                emailBody = emailBody.replace(TOTAL_PAYMENT,'$'+emailMap.get(TOTAL_PAYMENT));
                                                emailBody = emailBody.replace(POST_DATE,System.Today().format());
                                                emailBody = emailBody.replace(PortalConstants.REPLACE_LOGO_URL, logoURL);
                                                emailBody = emailBody.replace(SIGNATURE, signatureStr);                                                
                                                email.setHtmlBody(emailBody);                                         
                                                email.setToAddresses(new String[] {par.clcommon__Contact__r.Email});
                                                sendEmailList.add(email);
                                            } 
                                            
                                        }
            //Query for additional Recepients
            for (Email_Recipient__mdt addrecep : [
                SELECT Id, Coop_Type__c, Email__c
                FROM Email_Recipient__mdt
                WHERE
                Coop_Type__c = :emailMap.get(COOP_TYPE)
                AND Email_Template__c = :EmailTemplateName
            ]) {
                if(addrecep.Email__c != null && addrecep.Email__c != ''){
                    //send email to all the certified lenders
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if ( orgWideEmailAddr.size() > 0 ) {
                        email.setOrgWideEmailAddressId(orgWideEmailAddr.get(0).Id);
                    } 
                    email.subject = emailTemplate[0].Subject;
                    String emailBody = emailTemplate[0].HtmlValue;
                    emailBody = emailBody.replace(GROWER, emailMap.get(GROWER_NAME));
                    emailBody = emailBody.replace(
                        TOTAL_PAYMENT,
                        '$' + emailMap.get(TOTAL_PAYMENT)
                    );
                    emailBody = emailBody.replace(POST_DATE, System.Today().format());
                    emailBody = emailBody.replace(
                        PortalConstants.REPLACE_LOGO_URL,
                        logoURL
                    );
                    emailBody = emailBody.replace(SIGNATURE, signatureStr);              
                    email.setHtmlBody(emailBody);
                    email.setToAddresses(new List<String>{ addrecep.Email__c });
                    sendEmailList.add(email);
                }
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(sendEmailList);
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    System.debug('Email sent successfully');                    
                } else {
                    System.debug('Email failed to send: ' + result.getErrors()[0].getMessage());
                    Database.Insert(new clcommon__Log__c(Name = 'PortalEmailToCLFail',
                                                         clcommon__Message__c = 'Email failed to send: ' + result.getErrors()[0].getMessage(),                                            
                                                         clcommon__Time__c = System.Now()), PortalConstants.FALSE_VALUE);
                }
            } 
        } else {
            System.debug('Email failed to send - EmailTemplateName is blank or growername is blank or emailTemplate doesnt exist');
            Database.Insert(new clcommon__Log__c(Name = 'PortalEmailToCLFail',
                                                 clcommon__Message__c = 'Email failed to send - EmailTemplateName is blank or growername is blank or emailTemplate doesnt exist',                                            
                                                 clcommon__Time__c = System.Now()), PortalConstants.FALSE_VALUE);
        }
    } 
}