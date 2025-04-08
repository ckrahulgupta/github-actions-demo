/**
 * @description       : This API is used to make payment
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/

global without sharing class PortalDealerPayoffAPI implements clcommon.PortalCustomRemoteAPI1 {
    private static final String PAYOFF_DETAILS = 'payoffDetails';
    private static final String PAYMENT_OPTION = 'paymentOption';
    private static final String PAYOFF_FLAG = 'isPayOff';
    private static final String PAYMENT_AMOUNT = 'paymentAmount';
    private static final String BANK_DETAILS = 'bankDetails';
    private static final String TRUE_VALUE = 'True';
    private static final String YES = 'Yes';
    private static final String EMAIL_TOTAL_PAYMENT_AMT = '{!TotalPayment}';
    private static final String KEY_PRICING_DET = 'pricingDetail';
    private static final String KEY_MAKE_PAYMENT = 'makePayment';
    private static final String CURRENT_OUT_STANDING = 'currOutStanding';
    private static final String COOP_TYPE = 'Coop Type';
    private static final String GROWER_NAME = 'Grower Name';
    private static final String EMAIL_CONTEXT = 'MakePaymentDealerPortal';
   
    /**
     * @description Get all outstanding payment
     * @param outstandingPaymentsMap 
     * @param userPaymentsMap 
     * @param isPayOff 
     * @return  `Boolean`
     * @exception 
     */
    private static Boolean validatePayments(Map<String, Map<String, Object>> outstandingPaymentsMap, 
                                                Map<String, Map<String, Object>> userPaymentsMap,Boolean isPayOff) {
        for (String key : outstandingPaymentsMap.keySet()) {
            if (!userPaymentsMap.containsKey(key)) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }   
            PortalLoanServicingHelper.paymentValidationForExceededPayment(outstandingPaymentsMap, userPaymentsMap, key);
            if (isPayOff) {           
                PortalLoanServicingHelper.paymentValidationForPayoff(outstandingPaymentsMap, userPaymentsMap, key);
            }
        }
        return PortalConstants.TRUE_VALUE;
    }
    /**
     * @description validate Logged in user
     * @param applicationId 
     * @exception 
     */
    private static void validateUser(String applicationId){
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }
   
    /**
     *  @description - Purpose of this method is to create funding transaction records for each payoff amounts.
     * @param componentStrName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     */
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response portalResponse = new clcommon.Response();
        try {
            // Store the details returned from Portal
            String isPayOff;
            String bankDetails;
            String applicationId;
            String payoffDetails;
            String paymentOption;
            Decimal currentOutstanding;
            List<genesis__Funding_Transaction__c> fundingTransactionList = new List<genesis__Funding_Transaction__c>();
            Map<String,String> fundingTransactionMap = new Map<String,String>();
            
            List<Object> payOffList = new List<Object>();
 
            Decimal paymentAmount; 

            // Null check for portal Params 

            PortalLoanServicingHelper.checkRequestParam(request,PAYOFF_DETAILS);
            PortalLoanServicingHelper.checkRequestParam(request,PAYMENT_AMOUNT);
            PortalLoanServicingHelper.checkRequestParam(request,PortalConstants.APPLICATION_ID);
            PortalLoanServicingHelper.checkRequestParam(request,PAYOFF_FLAG);
            PortalLoanServicingHelper.checkRequestParam(request,PAYMENT_OPTION);

            PortalApplicationOriginationHelper.checkBlankParameter(String.valueof(request.get(PortalConstants.APPLICATION_ID)), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueof(request.get(PAYOFF_DETAILS)), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueof(request.get(PAYMENT_OPTION)), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueof(request.get(PAYMENT_AMOUNT)), PortalConstants.REQUIRED_PARAMETERS_MISSING);

            isPayOff = (String) request.get(PAYOFF_FLAG);
            applicationId = (String) request.get(PortalConstants.APPLICATION_ID);
            payoffDetails = (String) request.get(PAYOFF_DETAILS);
            paymentOption = (String) request.get(PAYMENT_OPTION);
            paymentAmount = (Decimal) request.get(PAYMENT_AMOUNT);

            // Null check for values fetched from Portal 
            
            validateUser(applicationId);
            List<genesis__Applications__c> currentLoanList = PortalLoanServicingHelper.getCurrentLoan(applicationId);
                 
            Boolean applyAdditionalChecks = PortalConstants.FALSE_VALUE;

            if (currentLoanList[0].Past_Due_Amount__c > 0 || PortalLoanServicingHelper.isCloseToMaturity(currentLoanList[0].genesis__Maturity_Date__c)) {
                applyAdditionalChecks = PortalConstants.TRUE_VALUE;
            }

            // Check if the Account has any Previous Past Due Loans
            LoanServicingHelper.validatePastDueLoan(currentLoanList);

            // Fetch Pricing record details from BE for App
            payOffList = (List<Object>) JSON.deserializeUntyped(payoffDetails);

            Map<String, Map<String, Object>> outstandingPaymentsMap = new Map<String, Map<String,Object>>();
            currentOutstanding = PortalLoanServicingHelper.getCurrentOutStandingPaymentsMap(applicationId,outstandingPaymentsMap);
            Map<String, Map<String, Object>> userPaymentsMap;

            if (applyAdditionalChecks) {
                userPaymentsMap = PortalLoanServicingHelper.getPaymentsSpreadMap(paymentAmount, outstandingPaymentsMap);
            } else {
                userPaymentsMap = PortalLoanServicingHelper.getUserPaymentsMap(payOffList);
            }

            if (isPayOff.equalsIgnoreCase(TRUE_VALUE)) {
                // apply addtional payoff validations
                validatePayments(outstandingPaymentsMap, userPaymentsMap, PortalConstants.TRUE_VALUE);
            } else {
                // apply general validations
                validatePayments(outstandingPaymentsMap, userPaymentsMap, PortalConstants.FALSE_VALUE);
            }


            Map<String,Object> paymentDetailsMap = new Map<String, Object>{
                CURRENT_OUT_STANDING => currentOutstanding,
                PAYMENT_OPTION => paymentOption
            };
            

            PortalLoanServicingHelper.validateTotalAmountSpread(userPaymentsMap,paymentAmount,paymentDetailsMap);
    
            if(paymentOption.equals(KEY_MAKE_PAYMENT)){
                //Validate Bank Account and get the Bank Account Id
                bankDetails = PortalLoanServicingHelper.validateDealerBankAccount(currentLoanList[0]);
                fundingTransactionMap = new Map<String,String>{
                PAYMENT_OPTION => paymentOption,
                BANK_DETAILS => bankDetails,
                PortalConstants.APPLICATION_ID => applicationId,
                PAYOFF_FLAG => isPayOff,
                PAYMENT_AMOUNT => String.valueOf(paymentAmount)
                };
            }else{
                fundingTransactionMap = new Map<String,String>{
                    PAYMENT_OPTION => paymentOption,
                    PortalConstants.APPLICATION_ID => applicationId,
                    PAYOFF_FLAG => isPayOff,
                    PAYMENT_AMOUNT => String.valueOf(paymentAmount),
                    CURRENT_OUT_STANDING => String.valueOf(currentOutstanding)
                };
            }
            fundingTransactionList = updateFundingTransaction(outstandingPaymentsMap, userPaymentsMap, fundingTransactionMap);

            // calling this method to check if it's Overpayment & it's Mobile Deposit
            PortalLoanServicingHelper.isOverpaymentMobileDeposit(fundingTransactionMap, applicationId);

            // calling this method to update Overpayment_Amount__c field in case of overpayment mobile deposit
            PortalLoanServicingHelper.updateOverpaymentAmount(fundingTransactionMap, fundingTransactionList);
            
            updatePayoffCheck(isPayOff,fundingTransactionList, currentLoanList);  
            
            Map<String,String> emailMap = new Map<String,String>{
                EMAIL_TOTAL_PAYMENT_AMT => paymentAmount.format(),
                PAYMENT_OPTION => paymentOption,
                COOP_TYPE => currentLoanList[0].Dealer_Name__r.Coop_Type__c,
                GROWER_NAME => currentLoanList[0].genesis__Account__r.Name
            };
            PortalLoanServicingHelper.sendEmailToCL(applicationId,EMAIL_CONTEXT,emailMap);

            Map<String, Object> responseFieldsMap = new Map<String, Object>{
                PortalConstants.INVOICE_ID_KEY => fundingTransactionList[0].Invoice__c
            };

            List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>{
                new clcommon.PortalCustomRemoteActionRecord(responseFieldsMap)
            };
            portalResponse = clcommon.PortalActions.getCustomRemoteActionResponse(responseData); 
            portalResponse.status = clcommon.Constants.SUCCESS;
         }
        catch(CustomException ex) {
            Database.rollback(dbSavePoint);
            portalResponse.status = clcommon.Constants.API_EXCEPTION;
            portalResponse.errorMessage = ex.getMessage();
            PortalHelper.saveExceptionLog(ex, PortalDealerPayoffAPI.class.getName());
        } catch (Exception ex) {
            Database.rollback(dbSavePoint);
            portalResponse.status = clcommon.Constants.API_EXCEPTION;  
            portalResponse.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(ex, PortalDealerPayoffAPI.class.getName());
        }
        return portalResponse;
    }
  
   /**
    * @description  Update funding Transaction
    * @param outstandingPaymentsMap 
    * @param userPaymentsMap 
    * @param fundingTransactionMap 
    * @return  `List<genesis__Funding_Transaction__c>`
    */
    private static List<genesis__Funding_Transaction__c> updateFundingTransaction(Map<String, Map<String, Object>> outstandingPaymentsMap,
                                                                                            Map<String, Map<String, Object>> userPaymentsMap,
                                                                                            Map<String,String> fundingTransactionMap
                                                                                            ){
        Decimal totalPrincipalPaid = 0;
        Decimal totalInterestPaid = 0;
        Decimal totalFeesPaid = 0;
        List<genesis__Funding_Transaction__c> fundingTransactionsList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Application_Pricing_Detail__c> applicationPricingList = new List<genesis__Application_Pricing_Detail__c>();

        String paymentMode = fundingTransactionMap.get(PAYMENT_OPTION).equals(KEY_MAKE_PAYMENT) ? ConstantValues.PAYMENT : ConstantValues.MOBILE_DEPOSIT;

        List<clcommon__Payment_Mode__c> paymentModesList =  PortalLoanServicingHelper.getPaymentMode(paymentMode);

        clcommon__Consolidated_Invoice__c invoiceObj = PaymentInvoiceHelper.createInvoice(fundingTransactionMap.get(PortalConstants.APPLICATION_ID), String.valueOf(paymentModesList[0].Id));

        for (String key : outstandingPaymentsMap.keySet()) {
            genesis__Funding_Transaction__c fundingTransaction = PortalLoanServicingHelper.createFundingTransactionForUserPayment(
                                                                        outstandingPaymentsMap.get(key),
                                                                        userPaymentsMap.get(key),
                                                                        paymentModesList[0].Id
                                                                        );

            if (fundingTransaction.Fees_Paid__c == 0 
                && fundingTransaction.Interest_Paid__c == 0 
                && fundingTransaction.Principal_Paid__c == 0
                &&fundingTransactionMap.get(PAYOFF_FLAG) != TRUE_VALUE) {
                continue;
            }
           
            assignBankAccount(fundingTransactionMap, fundingTransaction);

            fundingTransaction.genesis__Application__c = fundingTransactionMap.get(PortalConstants.APPLICATION_ID);
            fundingTransaction.Invoice__c = invoiceObj.Id;

            genesis__Application_Pricing_Detail__c childLoan = (genesis__Application_Pricing_Detail__c) outstandingPaymentsMap.get(key).get(KEY_PRICING_DET);
            childLoan.Fees__c = childLoan.Fees__c - fundingTransaction.Fees_Paid__c;
            childLoan.Accrued_Interest__c = childLoan.Accrued_Interest__c - fundingTransaction.Interest_Paid__c;
            childLoan.Principal_Advanced__c = childLoan.Principal_Advanced__c - fundingTransaction.Principal_Paid__c;
            
            applicationPricingList.add(childLoan);
            fundingTransactionsList.add(fundingTransaction);

            totalPrincipalPaid += fundingTransaction.Principal_Paid__c;
            totalInterestPaid += fundingTransaction.Interest_Paid__c;
            totalFeesPaid += fundingTransaction.Fees_Paid__c;
        }
        invoiceObj.Total_Principal__c = totalPrincipalPaid;
        invoiceObj.Total_Interest__c = totalInterestPaid;
        invoiceObj.Total_Fees__c = totalFeesPaid;
        invoiceObj.Total_Amount__c = Decimal.valueOf(fundingTransactionMap.get(PAYMENT_AMOUNT));
        invoiceObj.Payment_Mode__c = paymentModesList[0].Id;
        
       
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
    * @description : Assign bank account to funding transaction
    * @author Suraj Kumar | 11-23-2023 
    * @param fundingTransactionMap 
    * @param fundingTransaction 
    **/
    private static void assignBankAccount(Map<String,String> fundingTransactionMap, genesis__Funding_Transaction__c fundingTransaction){
        if(fundingTransactionMap.containsKey(BANK_DETAILS)){
            fundingTransaction.genesis__Bank_Account__c = fundingTransactionMap.get(BANK_DETAILS); 
        }
    }
    /**
     * @description Update application level and funding transaction level payoff check
     * @param isPayOff
     * @param fundingTransactionList 
     * @param currentLoanList
     */
    private static void updatePayoffCheck(String isPayOff, List<genesis__Funding_Transaction__c> fundingTransactionList, List<genesis__Applications__c> currentLoanList){
        if(isPayOff.equalsIgnoreCase(TRUE_VALUE) & fundingTransactionList.size()>0) {
            currentLoanList[0].Pay_Off__c = YES;
            currentLoanList[0].Pay_Off_Date__c = System.today();
            for(genesis__Funding_Transaction__c fundingTransaction : fundingTransactionList){
                fundingTransaction.Pay_Off__c = YES;
            }
            Database.update(fundingTransactionList,PortalConstants.TRUE_VALUE);
            Database.update(currentLoanList,PortalConstants.TRUE_VALUE);
        }      
    }
}