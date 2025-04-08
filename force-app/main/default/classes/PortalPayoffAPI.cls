/**********************************************************************************************************************
 * @description       : This portal API stores all the loan payoff details in salesforce.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**********************************************************************************************************************/

global without sharing class PortalPayoffAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    public static final String PAYOFF_APPI = 'PortalPayoffAPI';
    public static final String KEY_BANK_DETAILS = 'bankDetails';
    public static final String KEY_PAYMENT_MODE = 'paymentMode';
    public static final String KEY_PAYOFF_DETAILS = 'payoffDetails';
    public static final String PAYOFF_FLAG = 'isPayOff';
    public static final String PAYMENT_AMOUNT = 'paymentAmount';
    public static final String PAYMENT = 'Payment__c';
    public static final String APPLICATION = 'genesis__Application__c';
    public static final String EMAIL_TEMPLATE = 'Grower Payment Notification (SF to Grower BC: Loan Accounting)';
    public static final String GROWER = '{!GrowerName}';
    public static final String TOTAL_PAYMENT = '{!TotalPayment}';
    public static final String BANK_ACCOUNT = '{!BankAccountNumber}';
    public static final String POST_DATE = '{!DatePosted}';
    public static final String MATURITY_DATE = '{!MaturityDate}';
    public static final String STRING_TRUE = 'True';
    public static final String STRING_YES = 'Yes';
    public static final String ORGANISATION_EMAIL = 'THE COOPERATIVE FINANCE ASSOCIATION, INC.';
    public static final String GROWER_EMAIL = 'Grower Email';
    public static final String GROWER_NAME = 'Grower Name';
    public static final String COOP_TYPE = 'Coop Type';
    public static final String DEALER_ID = 'dealerId';
    private static final String KEY_ID = 'Id';
    private static final String APP_ID = 'applicationId';
    private static final String KEY_PRICING_DET = 'pricingDetail';
    private static final String PAYMENT_OPTION = 'paymentOption';
    private static final String BANK_DETAILS = 'bankDetails';
    private static final String TOTAL_PAYOFF = 'totalPayOffAmount';
    private static final String TOTAL_AMOUNT_PAID = 'totalAmountPaid';
    private static final String EMAIL_CONTEXT = 'MakePaymentinGrowerPortal';
    private static final String STAR_STRING = '*****';

   /**
    * @description update funding transaction
    * @param outstandingPaymentsMap 
    * @param userPaymentsMap 
    * @param fundingTransactionMap 
    * @return  `List<genesis__Funding_Transaction__c>`
    */
    public static List<genesis__Funding_Transaction__c> updateFundingTransaction(Map<String, Map<String, Object>> outstandingPaymentsMap,
                                                                                            Map<String, Map<String, Object>> userPaymentsMap,
                                                                                            Map<String,String> fundingTransactionMap
                                                                                            ){
        Decimal totalPrincipalPaid = 0;
        Decimal totalInterestPaid = 0;
        Decimal totalFeesPaid = 0;
        
        List<genesis__Funding_Transaction__c> fundingTransactionsList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Application_Pricing_Detail__c> applicationPricingList = new List<genesis__Application_Pricing_Detail__c>();
        String paymentMode = fundingTransactionMap.get(PAYMENT_OPTION);
        clcommon__Consolidated_Invoice__c invoiceObj = PaymentInvoiceHelper.createInvoice(fundingTransactionMap.get(APP_ID), paymentMode);

        for (String key : outstandingPaymentsMap.keySet()) {

            genesis__Funding_Transaction__c fundingTransactionObj = PortalLoanServicingHelper.createFundingTransactionForUserPayment(
                                                                        outstandingPaymentsMap.get(key),
                                                                        userPaymentsMap.get(key),
                                                                        paymentMode);
            fundingTransactionObj.Paid_By_Dealer__c = PortalConstants.FALSE_VALUE;
            if (fundingTransactionObj.Fees_Paid__c == 0 
                && fundingTransactionObj.Interest_Paid__c == 0 
                && fundingTransactionObj.Principal_Paid__c == 0
                &&fundingTransactionMap.get(PAYOFF_FLAG) != STRING_TRUE) {

                continue;

            }

            fundingTransactionObj.genesis__Bank_Account__c = fundingTransactionMap.get(BANK_DETAILS); 
            fundingTransactionObj.genesis__Application__c = fundingTransactionMap.get(APP_ID);
            fundingTransactionObj.Invoice__c = invoiceObj.Id;

            genesis__Application_Pricing_Detail__c childLoan = (genesis__Application_Pricing_Detail__c) outstandingPaymentsMap.get(key).get(KEY_PRICING_DET);
            childLoan.Fees__c = childLoan.Fees__c - fundingTransactionObj.Fees_Paid__c;
            childLoan.Accrued_Interest__c = childLoan.Accrued_Interest__c - fundingTransactionObj.Interest_Paid__c;
            childLoan.Principal_Advanced__c = childLoan.Principal_Advanced__c - fundingTransactionObj.Principal_Paid__c;

            applicationPricingList.add(childLoan);
            fundingTransactionsList.add(fundingTransactionObj);

            totalPrincipalPaid += fundingTransactionObj.Principal_Paid__c;
            totalInterestPaid += fundingTransactionObj.Interest_Paid__c;
            totalFeesPaid += fundingTransactionObj.Fees_Paid__c;
        }
        invoiceObj.Total_Principal__c = totalPrincipalPaid;
        invoiceObj.Total_Interest__c = totalInterestPaid;
        invoiceObj.Total_Fees__c = totalFeesPaid;
        invoiceObj.Total_Amount__c = Decimal.valueOf(fundingTransactionMap.get(PAYMENT_AMOUNT));
        invoiceObj.Payment_Mode__c = paymentMode;

       
        if (!applicationPricingList.isEmpty()) {
            Database.Update(applicationPricingList, PortalConstants.TRUE_VALUE);
        }
        if (!fundingTransactionsList.isEmpty()) {
            Database.Insert(fundingTransactionsList,PortalConstants.TRUE_VALUE);
        }
        Database.update(invoiceObj,PortalConstants.TRUE_VALUE);
        return fundingTransactionsList;
    }
    /**
     * @description validate Logged In user
     * @param currentUserList @des
     * @exception `User not authorize`
     */
    public static void validateLoggedInUserType(List<User> currentUserList){
        String loggedInUserRecordType = String.valueOf(currentUserList[0].Account.RecordType.Name);
        if(!loggedInUserRecordType.equalsIgnoreCase(PortalConstants.GROWER_PROFILE) && 
                !loggedInUserRecordType.equalsIgnoreCase(PortalConstants.CO_APPLICATION_RECORD_TYPE)){
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

    }
    /**
     * @description Get total amount paid
     * @param payoffList 
     * @return  `Decimal`
     */
    public static Decimal getTotalAmountPaid(List<Object> payoffList){
        Decimal totalPaymentAmountPaid = 0;
        for(Object payoffObj : payoffList){
            Map<String, Object> request = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(payoffObj));
            if(request.get(PAYMENT) != null && 
                Decimal.valueOf(String.valueOf(request.get(PAYMENT))) > 0){
                    totalPaymentAmountPaid = totalPaymentAmountPaid + Decimal.valueOf(String.valueOf(request.get(PAYMENT))).setScale(2);
            }
        }
        return totalPaymentAmountPaid;
    }
    /**
     * @description get current application id
     * @param payoffList 
     * @return  `String`
     */
    public static String getApplicationId(List<Object> payoffList){
        String applicationId;
        if(!payoffList.isEmpty()){
            Map<String, Object> request = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(payoffList[0]));
            applicationId = String.valueOf(request.get(APPLICATION));
        }
        return applicationId;
    }
    // parameters specific for this class [end]
  
    /**
    * @description - Purpose of this method is to create funding transaction records for each payoff amounts.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        String accountId;
        String growerName;
        String paymentMode;
        String bankDetailsId;
        String payoffDetails;
        String isPayOffFlag;
        Decimal totalPayOffAmount = 0;
       
        Decimal totalPaymentAmountPaid = 0;
        List<Object> payoffList = new List<Object>();
        clcommon.Response response = new clcommon.Response();
        List<genesis__Funding_Transaction__c> fundingTransactionList = new List<genesis__Funding_Transaction__c>();
        String applicationId;
        Map<String, Map<String, Object>> outstandingPaymentsMap = new  Map<String, Map<String, Object>>();
       
        SavePoint dbSavePoint = Database.setSavepoint();
        try {

            //checkRequestParam(argumentsFromPortal);
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal,KEY_PAYMENT_MODE);
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal,KEY_BANK_DETAILS);
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal,KEY_PAYOFF_DETAILS);
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal,PAYOFF_FLAG);

            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(argumentsFromPortal.get(KEY_PAYMENT_MODE)), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(argumentsFromPortal.get(KEY_BANK_DETAILS)), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(argumentsFromPortal.get(KEY_PAYOFF_DETAILS)), PortalConstants.REQUIRED_PARAMETERS_MISSING);


            paymentMode = (String)argumentsFromPortal.get(KEY_PAYMENT_MODE);
            bankDetailsId = (String)argumentsFromPortal.get(KEY_BANK_DETAILS);
            payoffDetails = (String)argumentsFromPortal.get(KEY_PAYOFF_DETAILS);
            isPayOffFlag = (String)argumentsFromPortal.get(PAYOFF_FLAG);
            List<User> currentUserList = PortalLoanServicingHelper.getLoggedInUser();
            validateLoggedInUserType(currentUserList);
            String loggedInGrowerAccountId = currentUserList[0].AccountId;
            List<clcommon__Payment_Mode__c> paymentModeList = PortalLoanServicingHelper.getPaymentMode(paymentMode);

            //Get the Pricing Ids List from Portal Requested JSON 
            payoffList = (List<Object>) Json.deserializeUntyped(payoffDetails);

            // Check whether grower is elligible to make payment on the loan
            applicationId = getApplicationId(payoffList);
            PortalLoanServicingHelper.validateApplicantToPay(applicationId, loggedInGrowerAccountId);
            // Payment from Grower portal
            growerName = currentUserList[0].Account.Name;
            // Check whether bank details belong to the grower
            PortalLoanServicingHelper.validateBankAccount(bankDetailsId, loggedInGrowerAccountId);
            totalPaymentAmountPaid = getTotalAmountPaid(payoffList);
            
            //Get the Pricing Details for the funding transactions
            totalPayOffAmount = PortalLoanServicingHelper.getCurrentOutStandingPaymentsMap(applicationId,outstandingPaymentsMap);

            List<genesis__Applications__c> currentLoanList = PortalLoanServicingHelper.getCurrentLoan(applicationId);
            //Throw error if the Account has any Previous Past Due Loans
            LoanServicingHelper.validatePastDueLoan(currentLoanList);
            
            //Throw error if over payment is being made
            if(totalPaymentAmountPaid > totalPayOffAmount){
                throw new CustomException(PortalConstants.EXCEEDED_PAYMENT);
            }
            Map<String, Map<String, Object>> userPaymentsMap = PortalLoanServicingHelper.getUserPaymentsSpreadMap(new Map<String, Object>{
                KEY_ID => applicationId,
                PAYMENT_AMOUNT => totalPaymentAmountPaid
            }, outstandingPaymentsMap, payOffList);

            Map<String,String> fundingTransactionMap = new Map<String,String>{
                PAYMENT_OPTION => paymentModeList[0].Id,
                BANK_DETAILS => bankDetailsId,
                APP_ID => applicationId,
                PAYOFF_FLAG => isPayOffFlag,
                PAYMENT_AMOUNT => String.valueOf(totalPaymentAmountPaid)
            };
            fundingTransactionList = updateFundingTransaction(outstandingPaymentsMap, userPaymentsMap, fundingTransactionMap);
        
            //Pay-off check 
            if(isPayOffFlag.equalsIgnoreCase(STRING_TRUE)){
                //check if the payment is accurate
                fundingTransactionList = updatePayoffCheck(fundingTransactionList,
                                                new Map<String,Decimal>{
                                                    TOTAL_PAYOFF => totalPayOffAmount,
                                                    TOTAL_AMOUNT_PAID => totalPaymentAmountPaid
                                                },currentLoanList[0]);
            }
            if(fundingTransactionList.size() > 0){
                //Only if there was a payment added in the system. Send email
                //Populating all the merge fields required in the email
                String roundOffAmount = (Decimal.valueOf(String.valueOf(totalPaymentAmountPaid)==null||String.valueOf(totalPaymentAmountPaid).trim()==PortalConstants.EMPTY_STRING?ConstantValues.FORMAT_STRING:String.valueOf(totalPaymentAmountPaid)).setScale(2) + 0.001 ).format();
                String totalPayment = roundOffAmount.substring(0,roundOffAmount.length()-1);
                getDetailForMail(new Map<String,String>{
                    TOTAL_AMOUNT_PAID => totalPayment,
                    GROWER_EMAIL => currentUserList[0].Email
                },bankDetailsId,currentLoanList);
            }

            Map<String, Object> responseFieldsMap = new Map<String, Object>{
                PortalConstants.INVOICE_ID_KEY => fundingTransactionList[0].Invoice__c
            };

            List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>{
                new clcommon.PortalCustomRemoteActionRecord(responseFieldsMap)
            };
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData); 
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, PAYOFF_APPI);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;  
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PAYOFF_APPI);
        }
        return response;
    }
    /**
     * @description update payoff check
     * @param fundingTransactionList 
     * @param paymentMap 
     * @param applicationObj 
     * @return  `List<genesis__Funding_Transaction__c>`
     * @exception 
     */
    public static List<genesis__Funding_Transaction__c> updatePayoffCheck(List<genesis__Funding_Transaction__c> fundingTransactionList, Map<String,Decimal> paymentMap,genesis__Applications__c applicationObj){
        if(paymentMap.get(TOTAL_PAYOFF) != paymentMap.get(TOTAL_AMOUNT_PAID)){
            throw new CustomException(PortalConstants.PAY_OFF_AMOUNT_INACURATE);
        }
        
        //query the application with the same account and maturity date past than this application accountId
        applicationObj.Pay_Off__c = STRING_YES;
        applicationObj.Pay_Off_Date__c = System.today();
        Database.update(applicationObj,PortalConstants.TRUE_VALUE);

        for(genesis__Funding_Transaction__c fundingTransactionObj : fundingTransactionList){
            fundingTransactionObj.Pay_Off__c = STRING_YES;
        }
        Database.update(fundingTransactionList,PortalConstants.TRUE_VALUE);
        return fundingTransactionList;
    }

    /**
     * @description Get details for mail
     * @param userMap 
     * @param bankDetailsId 
     * @param applicationList 
     */
    public static void getDetailForMail(Map<String,String> userMap, String bankDetailsId,List<genesis__Applications__c> applicationList){
        Date dateToBePosted;
        List<clcommon__Bank_Account__c> bankAccountList = [SELECT Id, 
                                                                clcommon__Bank_Account_Number__c, 
                                                                clcommon__Bank_Account_Name__c
                                                        FROM clcommon__Bank_Account__c
                                                        WHERE Id  = :bankDetailsId];
        if(System.now().hourGmt() > 15){
            //Next Business Day is Day After Tomorrow
            dateToBePosted = Portalhelper.getNextWorkingDay(System.now().addDays(2));
        }
        else{
            dateToBePosted = Portalhelper.getNextWorkingDay(System.now().addDays(1));
        }
        Map<String,String> emailMap = new Map<String,String>{
             GROWER_NAME => applicationList[0].genesis__Account__r.Name,
             GROWER_EMAIL => userMap.get(GROWER_EMAIL),
             TOTAL_PAYMENT => userMap.get(TOTAL_AMOUNT_PAID),
             BANK_ACCOUNT => bankAccountList[0].clcommon__Bank_Account_Number__c,
             COOP_TYPE => applicationList[0].Dealer_Name__r.Coop_Type__c,
             DEALER_ID => applicationList[0].Dealer_Name__c
        };

        sendMail(emailMap, dateToBePosted, applicationList[0].genesis__Maturity_Date__c);
        PortalLoanServicingHelper.sendEmailToCL(applicationList[0].Id,EMAIL_CONTEXT,emailMap);
    }
    /**
     * @description Send mail to grower
     * @param emailMap 
     * @param dateToBePosted 
     * @param maturityDate 
     */
    @future(callout=true)
    private static void sendMail( Map<String,String> emailMap,
                            Date dateToBePosted,
                            Date maturityDate
                            ){
        String growerEmail = emailMap.get(GROWER_EMAIL);
        String growerName = emailMap.get(GROWER_NAME);
        String totalPayment = emailMap.get(TOTAL_PAYMENT);
        String bankAccountNumber = emailMap.get(BANK_ACCOUNT);
        Id dealerId = emailMap.get(DEALER_ID);
        if(String.isBlank(dealerId)){
            throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
        }

        //Method to send email to the grower whenever a payment is made
        List<EmailTemplate> emailTemplateList = PortalHelper.getEmailTemplateList(EMAIL_TEMPLATE);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //Adding CFA Email
        OrgWideEmailAddress[] cfaOrganisationEmail = [SELECT Id, 
                                                            Address 
                                                        FROM OrgWideEmailAddress 
                                                        WHERE DisplayName = :ORGANISATION_EMAIL];
        if ( cfaOrganisationEmail.size() > 0 ) {
            email.setOrgWideEmailAddressId(cfaOrganisationEmail.get(0).Id);
        }
        
        String emailBody = emailTemplateList[0].HtmlValue;
        emailBody = emailBody.replace(GROWER,growerName);
        emailBody = emailBody.replace(TOTAL_PAYMENT,PortalConstants.DOLLAR_STRING+totalPayment);
        emailBody = emailBody.replace(BANK_ACCOUNT,STAR_STRING+bankAccountNumber.right(4));
        emailBody = emailBody.replace(POST_DATE,dateToBePosted.format());
        emailBody = emailBody.replace(MATURITY_DATE,maturityDate.format());
        emailBody = emailBody.replace(PortalConstants.REPLACE_LOGO_URL, EmailUtil.setLogoURL(dealerId));
        email.setHtmlBody(emailBody);
        email.subject = emailTemplateList[0].Subject;
        email.setTemplateId(emailTemplateList[0].Id);
        email.setToAddresses(new String[] {growerEmail});
        email.setBccAddresses(new String[] {ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS});
        emailsToSend.add(email);
        Messaging.sendEmail(emailsToSend);
    }
  }