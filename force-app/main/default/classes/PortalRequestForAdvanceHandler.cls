/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-28-2025
 * @last modified by  : Ayan Bhowmik
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   07-02-2024   Ayush Kumar Singh   Initial Version
**/

global inherited sharing class PortalRequestForAdvanceHandler {
    private static final String REQUEST_FOR_ADVANCE_API = PortalRequestForAdvanceAPI.class.getName();
    private static final String KEY_AMOUNT = 'amount';
    private static final String KEY_PURPOSE = 'purpose';
    private static final String KEY_ACCOUNT_ID = 'accountId';
    private static final String KEY_PAYMENT_MODE = 'paymentMode';
    private static final String KEY_APPLICATION_ID = 'applicationId';
    private static final String KEY_DRAFT_CHILD = 'draftChild';
    private static final String KEY_PAYEE = 'payee';
    private static final String KEY_DRAFT_NUMBER = 'draftNumber';
    private static final String KEY_PRICING_DETAILS = 'pricingId';
    private static final String KEY_ID = 'Id';
    private static final String KEY_GROWER_NAME = 'growerName';
    private static final String IS_ADVANCING = 'isAdvancing';
    private static final String IS_SUSPENSE_CLEARED = 'isSuspenseCleared';
    private static final String KEY_FUNDING_TRANSACTION_ID = 'fundingTransactionId';
    private static final String KEY_APPLICATION = 'applicationObj';
    private static final String KEY_ACTUAL_AMOUNT = 'actualAmount';
    private static final String KEY_AVAILABLE = 'available';
    private static final String KEY_DRAFT_AMOUNT = 'draftAmount';
    private static final String KEY_CREDIT_BALANCE = 'creditBalance';
    private static final String KEY_REFERENCE = 'reference';
    private static final String ACH = 'ACH';
    private static final String DRAFT = 'DRAFT';
    private static final String NEW_RECORD = 'new_record_id';
    private static final String DESCRIPTION = 'Description__c';
    private static final String GENESIS_AMOUNT = 'genesis__Amount__c';
    private static final String REFERENCE = 'genesis__Reference__c';
    private static final String MAX_FINIANCED_AMOUNT = 'genesis__Maximum_Financed_Amount__c';
    private static final String EMAIL_TEMPLATE = 'ACH/Draft to clear Suspense (SF to Loan Accounting)';
    private static final String LOAN_NUMBER = '{!LoanNumber}';
    private static final String GROWER_NAME = '{!GrowerName}';
    private static final String TOTAL_AMOUNT = '{!TotalAmount}';
    private static final String MATURITY_DATE = '{!MaturityDate}';
    private static final String CFA_ORGANISATION = System.Label.CFA_Sender_Name;
    private static final String PRICING_TO_CREDIT_BALANCE = 'pricingToCreditBlncMap';
    private static final String PRICING_TO_PRINCIPAL_ADVANCE = 'prcngToPrncpalAdvncMap';
    /**
     * @description This method send the email to loan accounting
     * @param pricingDetailIdWithCredit 
     * @param amount  
     * @param growerName 
     */
    private static void sendMail(String pricingDetailIdWithCredit,
                                    Decimal amount,
                                    String growerName){
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        genesis__Application_Pricing_Detail__c objPricingList = [ SELECT Id,
                                                                        genesis__Application__r.genesis__Maturity_Date__c,
                                                                        Loan_Number__c,
                                                                        Credit_Balance__c,
                                                                        genesis__Application__r.Dealer_Name__c,
                                                                        genesis__Application__r.Dealer_Name__r.Coop_Type__c
                                                                    FROM genesis__Application_Pricing_Detail__c
                                                                    WHERE Id = :pricingDetailIdWithCredit];

        senderAddressList = CFAOriginationHelperClass.getOrgWideEmailAddress();                                                       
        EmailTemplate emailTemplate = EmailUtil.getEmailTemplate(EMAIL_TEMPLATE);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS});
        email.subject = emailTemplate.Subject;
        email.setTemplateId(emailTemplate.Id);
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);                                           
        String emailBody = emailTemplate.HtmlValue;
        String paymentAmountStr = String.valueOf(amount);
        //Formatting the Amount
        String amountString = PortalConstants.DOLLAR_STRING + paymentAmountStr;
        emailBody = emailBody.replace(LOAN_NUMBER,objPricingList.Loan_Number__c);
        emailBody = emailBody.replace(GROWER_NAME,growerName);
        emailBody = emailBody.replace(TOTAL_AMOUNT,amountString);
        emailBody = emailBody.replace(MATURITY_DATE,objPricingList.genesis__Application__r.genesis__Maturity_Date__c.format());
        emailBody = emailBody.replace(PortalConstants.REPLACE_LOGO_URL, 
                                        EmailUtil.setLogoURL(objPricingList.genesis__Application__r.Dealer_Name__c));
        email.setHtmlBody(emailBody);
        emailsToSend.add(email);
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailsToSend);
        String emailStatus = emailResults[0].isSuccess() ? ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;
        Map<String,Object> emailLogMap = new Map<String,Object>{
            ConstantValues.KEY_FROM_ADDRESS => PortalApplicationOriginationHelper.getLoggedInUser()[0].Email,
            ConstantValues.KEY_TO_ADDRESS => ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS,
            ConstantValues.KEY_EMAIL_TEMPLATE => emailTemplate.Name,
            ConstantValues.KEY_MESSAGE => emailBody,
            ConstantValues.KEY_CLASS_NAME => REQUEST_FOR_ADVANCE_API,
            ConstantValues.KEY_EMAIL_STATUS => emailStatus
        };
        if(emailStatus == ConstantValues.FAILURE_STATUS){
            emailLogMap.put(ConstantValues.KEY_ERROR_MESSAGE,emailResults[0].getErrors()[0].getMessage());   
        }
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(emailLogMap);
        if(notificationObj != null){
            Database.insert(notificationObj, PortalConstants.TRUE_VALUE);
        }
    }

     /**
     * @description This method send mail to loan accounting on every credit balance is paid and create funding transaction record.
     * @param paramMap 
     * @param paymentModeId 
     * @param amount 
     * @return  `Decimal`
     */
    public static Decimal createAchForSuspenseBalance(Map<String, Object> paramMap, Id paymentModeId, Decimal amount){

        String applicationId = String.valueOf(paramMap.get(KEY_APPLICATION_ID));
        String purpose = String.valueOf(paramMap.get(KEY_PURPOSE));
        String fundingTransactionId = String.valueOf(paramMap.get(KEY_FUNDING_TRANSACTION_ID));
        String growerName = String.valueOf(paramMap.get(KEY_GROWER_NAME));
        String paymentMode = String.valueOf(paramMap.get(KEY_PAYMENT_MODE));
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        List<genesis__Funding_Transaction__c> fundingTxnToClearList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Application_Pricing_Detail__c> objPrcingToClearBalance = [SELECT Id,
                                                                                        Credit_Balance__c
                                                                                    FROM genesis__Application_Pricing_Detail__c
                                                                                    WHERE genesis__Application__c = :applicationId 
                                                                                    AND Credit_Balance__c != null 
                                                                                    AND Credit_Balance__c > 0 
                                                                                    AND genesis__Enabled_Flag__c = true
                                                                                    ORDER BY genesis__Interest_Rate__c DESC];
        if(!paymentMode.equalsIgnoreCase(ACH)){ 
            return amount;
        }            
        for(genesis__Application_Pricing_Detail__c eachPrcingToClearObj : objPrcingToClearBalance){
            if(amount < 0){
                throw new CustomException(PortalConstants.INVALID_AMOUNT);
            }   
            if(fundingTransactionId.equalsIgnoreCase(NEW_RECORD) & amount > 0){
            //Create a funding transaction record for Suspense Balance
                genesis__Funding_Transaction__c fundingTxnToClearObj = new genesis__Funding_Transaction__c();
                fundingTxnToClearObj.genesis__Amount__c = (amount <= eachPrcingToClearObj.Credit_Balance__c) ? amount : eachPrcingToClearObj.Credit_Balance__c;
                fundingTxnToClearObj.genesis__Reference__c = purpose;
                fundingTxnToClearObj.genesis__Application__c = applicationId;
                fundingTxnToClearObj.genesis__Payment_Mode__c = paymentModeId;
                fundingTxnToClearObj.genesis__Funding_Date__c = date.today();
                fundingTxnToClearObj.Grower_Name__c = growerName;
                fundingTxnToClearObj.Pricing_Detail__c = eachPrcingToClearObj.Id;
                fundingTxnToClearObj.Is_Clearing_Suspense__c = true;
                fundingTxnToClearObj.genesis__Reference__c = purpose;

                //Create invoice for each funding transaction
                invoiceObj = PaymentInvoiceHelper.createInvoice(applicationId, fundingTxnToClearObj.genesis__Payment_Mode__c, fundingTxnToClearObj.genesis__Amount__c);
                fundingTxnToClearObj.invoice__c = invoiceObj.Id;

                amount = amount - fundingTxnToClearObj.genesis__Amount__c;
                eachPrcingToClearObj.Credit_Balance__c = eachPrcingToClearObj.Credit_Balance__c - fundingTxnToClearObj.genesis__Amount__c;
                
                fundingTxnToClearList.add(fundingTxnToClearObj);
                //Send email for every creedit balance that is paid
                sendMail(eachPrcingToClearObj.Id, 
                        fundingTxnToClearObj.genesis__Amount__c, 
                        growerName);
            }
        }
        if(fundingTxnToClearList.size() > 0){
            Database.insert(fundingTxnToClearList,true);
        }
        Database.update(objPrcingToClearBalance,true);
        return amount;
    }
    /**
     * @description 
     * @param paramMap 
     * @param applicationsObj 
     * @param pricingDetailsObj 
     * @exception 
     */
     public static void createFundingTransactionForACH(Map<String, Object> paramMap, 
                                                    genesis__Applications__c applicationsObj, 
                                                    genesis__Application_Pricing_Detail__c pricingDetailsObj){

        String applicationId = String.valueOf(paramMap.get(KEY_APPLICATION_ID));
        String purpose = String.valueOf(paramMap.get(KEY_PURPOSE));
        String fundingTransactionId = String.valueOf(paramMap.get(KEY_FUNDING_TRANSACTION_ID));
        String growerName = String.valueOf(paramMap.get(KEY_GROWER_NAME));
        String pricingDetails = String.valueOf(paramMap.get(KEY_PRICING_DETAILS));
        Decimal amount = (Decimal)paramMap.get(KEY_AMOUNT);
        Id paymentModeId = (Id)paramMap.get(KEY_ID);
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        PortalLoanServicingHelper.throwCustomError(amount==null,ConstantValues.PARAMETER_MISSING);
        PortalLoanServicingHelper.throwCustomError(purpose==null,ConstantValues.PARAMETER_MISSING);

        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        PortalLoanServicingHelper.throwCustomError(amount<=0,PortalConstants.INVALID_AMOUNT);
        applicationsObj.Id = pricingDetailsObj.genesis__Application__c;

        //Instance for Child Loan to update Principal Advanced
        genesis__Application_Pricing_Detail__c objChildLoanPrincipal = new genesis__Application_Pricing_Detail__c(Id = pricingDetailsObj.Id);
        if(fundingTransactionId.equalsIgnoreCase(NEW_RECORD)){
            PortalLoanServicingHelper.throwCustomError(pricingDetailsObj.genesis__Application__r.Available__c < amount,PortalConstants.INSUFFICIENT_AVAILABLE_FUNDS);
            objFundingTransaction.Invoice__c = invoiceObj.Id;
            objFundingTransaction.genesis__Amount__c = amount;
            objFundingTransaction.genesis__Reference__c = purpose;
            objFundingTransaction.genesis__Application__c = applicationId;
            objFundingTransaction.genesis__Payment_Mode__c = paymentModeId;
            objFundingTransaction.genesis__Funding_Date__c = date.today();
            objFundingTransaction.Grower_Name__c = growerName;
            objFundingTransaction.Pricing_Detail__c = pricingDetails;

            //Creating invoice & Update total amount
            invoiceObj = PaymentInvoiceHelper.createInvoice(applicationId, String.valueOf(paymentModeId),objFundingTransaction.genesis__Amount__c);
            objFundingTransaction.invoice__c = invoiceObj.Id;

            applicationsObj.Peak_Loan_Volume__c = pricingDetailsObj.genesis__Application__r.Peak_Loan_Volume__c + amount;

            //Updating the Current Principal Balance on Child Loans
            objChildLoanPrincipal.Principal_Advanced__c = pricingDetailsObj.Principal_Advanced__c + amount;
        }else{
            genesis__Funding_Transaction__c existingFundingTxnObj = [SELECT Id, 
                                                                            format(genesis__Amount__c),
                                                                            Loan_Number__c,
                                                                            Invoice__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE genesis__Payment_Mode__r.Name =: ACH
                                                                        AND posted_to_nls__c =: PortalConstants.FALSE_VALUE
                                                                        AND genesis__cleared__c =: PortalConstants.FALSE_VALUE
                                                                        AND Id =: fundingTransactionId];
            PortalLoanServicingHelper.throwCustomError(existingFundingTxnObj == null,PortalConstants.SOMETHING_WENT_WRONG);
            if (existingFundingTxnObj.genesis__Amount__c != amount){
                if(pricingDetailsObj.genesis__Application__r.Available__c + existingFundingTxnObj.genesis__Amount__c < amount){
                    throw new CustomException(PortalConstants.INSUFFICIENT_AVAILABLE_FUNDS);
                }
                applicationsObj.Peak_Loan_Volume__c = pricingDetailsObj.genesis__Application__r.Peak_Loan_Volume__c - existingFundingTxnObj.genesis__Amount__c + amount;
                //Updating the Current Principal Balance when editing an existing ACH
                objChildLoanPrincipal.Principal_Advanced__c = pricingDetailsObj.Principal_Advanced__c - existingFundingTxnObj.genesis__Amount__c + amount;
            }

            objFundingTransaction.genesis__Amount__c = amount;
            objFundingTransaction.genesis__Reference__c = purpose;
            objFundingTransaction.Id = fundingTransactionId;
            objFundingTransaction.genesis__Payment_Mode__c = paymentModeId;

            //Updating Total Amount in Invoice
            PaymentInvoiceHelper.updateInvoice(existingFundingTxnObj.Invoice__c, objFundingTransaction.genesis__Amount__c);
        }

        Database.upsert(objFundingTransaction,true);
        // //Sending an Email to check suspense
        // sendMail(objFundingTransaction.Id, 
        //         objFundingTransaction.genesis__Amount__c, 
        //         objFundingTransaction.Grower_Name__c);
        Database.update(applicationsObj,true);
        Database.update(objChildLoanPrincipal,true);
    }
    /**
     * @description 
     * @param paramMap 
     * @param pricingToCreditBlncMap 
     * @param pricingToPrincipalAdvMap 
     */
     public static void createFundingTransactionForDraft(Map<String, Object> paramMap,
                                                            Map<String, Decimal> pricingToCreditBlncMap,
                                                            Map<String, Decimal> pricingToPrincipalAdvMap){

        List<genesis__Funding_Transaction__c> updtChildLoanToClearList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Application_Pricing_Detail__c> updtPrcngDtlForClrngList = new List<genesis__Application_Pricing_Detail__c>();
        List<genesis__Funding_Transaction__c> updateChildLoanList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Application_Pricing_Detail__c> prcncpalAdvnUpdtList = new List<genesis__Application_Pricing_Detail__c>();

        String applicationId = String.valueOf(paramMap.get(KEY_APPLICATION_ID));
        String growerName = String.valueOf(paramMap.get(KEY_GROWER_NAME));
        Id paymentModeId = (Id)paramMap.get(KEY_ID);
        String draftNumber = String.valueOf(paramMap.get(KEY_DRAFT_NUMBER));
        String payee = String.valueOf(paramMap.get(KEY_PAYEE));
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get(KEY_APPLICATION);
        Boolean isSuspenseCleared = (Boolean)paramMap.get(IS_SUSPENSE_CLEARED);
        Boolean isAdvancing = (Boolean)paramMap.get(IS_ADVANCING);
        Decimal available = applicationObj.Available__c;
        Decimal principalBalance = applicationObj.Peak_Loan_Volume__c;
        String childLoans = String.valueOf(paramMap.get(KEY_DRAFT_CHILD));
        Decimal totalInvoiceAmount = 0;
        Map<String, Object> paramForBalanceCheckMap = new Map<String, Object>();
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        PortalLoanServicingHelper.throwCustomError(childLoans == null,ConstantValues.PARAMETER_MISSING);
        PortalLoanServicingHelper.throwCustomError(payee == null,ConstantValues.PARAMETER_MISSING);
        PortalLoanServicingHelper.throwCustomError(draftNumber == null,ConstantValues.PARAMETER_MISSING);
        checkForSuspenceBalance(isAdvancing,isSuspenseCleared);

        List<Object> childLoanList = (List<Object>) Json.deserializeUntyped(childLoans);

        // Creating invoice
        invoiceObj = PaymentInvoiceHelper.createInvoice(applicationId, String.valueOf(paymentModeId));

        for(Object objChildLoan : childLoanList){
            Map<String, Object> request = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objChildLoan));
            Decimal draftAmount = Decimal.valueOf(String.valueOf(request.get(MAX_FINIANCED_AMOUNT)));
            Decimal actualAmount = draftAmount;
            String description = String.valueOf(request.get(DESCRIPTION));
            String pricingDetailId = String.valueOf(request.get(KEY_ID));
            Date todaysDate = Date.today();
            PortalLoanServicingHelper.throwCustomError(draftAmount<0,PortalConstants.INVALID_AMOUNT);
            validateDealerBASFEarlyAdvanceEligibility(new Map<String, Object>{
                PortalConstants.FIELD_CIF_NUMBER => applicationObj.Dealer_Name__r.CIF_Number__c,
                PortalConstants.FIELD_DESCRIPTION => String.valueOf(request.get('genesis__Rate_Card_Setup_Detail__r.Description__c')),
                PortalConstants.FIELD_INTEREST_RATE => Decimal.valueOf(String.valueOf(request.get(PortalConstants.FIELD_INTEREST_RATE))),
                PortalConstants.FIELD_CROP_YEAR => applicationObj.Crop_Year__c,
                PortalConstants.KEY_TRANSACTION_AMOUNT => draftAmount,
                PortalConstants.KEY_PAYMENT_MODE => DRAFT
            });

            Decimal creditBalance = 0;
            if(pricingToCreditBlncMap.containsKey(String.valueOf(request.get(KEY_ID)))){
                //Need to create a record for Clearing balance
                genesis__Funding_Transaction__c fundingTxnToClearObj = new genesis__Funding_Transaction__c();
                creditBalance = pricingToCreditBlncMap.get(String.valueOf(request.get(KEY_ID)));
                genesis__Application_Pricing_Detail__c prcngDtlForCreditBlncObj = new genesis__Application_Pricing_Detail__c(Id = String.valueOf(request.get(KEY_ID)));
                if(creditBalance > 0 && draftAmount >= creditBalance){
                        //isSuspenseCleared = true;
                        //Pay all the credit balance left on the loan
                    fundingTxnToClearObj.genesis__Amount__c = creditBalance;
                    draftAmount = draftAmount - fundingTxnToClearObj.genesis__Amount__c;

                    fundingTxnToClearObj.genesis__Application__c = applicationId;
                    fundingTxnToClearObj.genesis__Payment_Mode__c = paymentModeId;
                    fundingTxnToClearObj.genesis__Funding_Date__c = todaysDate;
                    fundingTxnToClearObj.Grower_Name__c = growerName;
                    fundingTxnToClearObj.genesis__Reference__c = description;
                    fundingTxnToClearObj.Pricing_Detail__c = pricingDetailId;
                    fundingTxnToClearObj.Draft_Number__c = draftNumber;
                    fundingTxnToClearObj.Payee__c = payee;
                    fundingTxnToClearObj.Is_Clearing_Suspense__c = true;
                    fundingTxnToClearObj.invoice__c = invoiceObj.Id;
                    prcngDtlForCreditBlncObj.Credit_Balance__c = 0;
                    updtChildLoanToClearList.add(fundingTxnToClearObj);
                    updtPrcngDtlForClrngList.add(prcngDtlForCreditBlncObj);
                    
                    //Adding total amount for invoice
                    totalInvoiceAmount += fundingTxnToClearObj.genesis__Amount__c;

                } else if(creditBalance > 0 && draftAmount!=0){
                        //the credit balance is yet not cleared. Just pay the draftAmount to the Clear
                        //isSuspenseCleared = false;
                    fundingTxnToClearObj.genesis__Amount__c = draftAmount;
                    fundingTxnToClearObj.genesis__Application__c = applicationId;
                    fundingTxnToClearObj.genesis__Payment_Mode__c = paymentModeId;
                    fundingTxnToClearObj.genesis__Funding_Date__c = todaysDate;
                    fundingTxnToClearObj.Grower_Name__c = growerName;
                    fundingTxnToClearObj.genesis__Reference__c = description;
                    fundingTxnToClearObj.Pricing_Detail__c = pricingDetailId;
                    fundingTxnToClearObj.Draft_Number__c = draftNumber;
                    fundingTxnToClearObj.Payee__c = payee;
                    fundingTxnToClearObj.Is_Clearing_Suspense__c = true;

                    fundingTxnToClearObj.invoice__c = invoiceObj.Id;

                    prcngDtlForCreditBlncObj.Credit_Balance__c = creditBalance - fundingTxnToClearObj.genesis__Amount__c;
                    updtChildLoanToClearList.add(fundingTxnToClearObj);
                    updtPrcngDtlForClrngList.add(prcngDtlForCreditBlncObj);
                    
                    //Adding total amount for invoice
                    totalInvoiceAmount += fundingTxnToClearObj.genesis__Amount__c;

                    continue;
                }   
            }
            if(draftAmount == 0){
                continue;
            }
            paramForBalanceCheckMap.put(KEY_AVAILABLE, available);
            paramForBalanceCheckMap.put(KEY_DRAFT_AMOUNT, draftAmount);
            paramForBalanceCheckMap.put(IS_SUSPENSE_CLEARED, isSuspenseCleared);
            paramForBalanceCheckMap.put(KEY_ACTUAL_AMOUNT, actualAmount);
            paramForBalanceCheckMap.put(KEY_CREDIT_BALANCE, creditBalance);
            checkInsufficientAndSuspenseBalance(paramForBalanceCheckMap);

            genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
            objFundingTransaction.genesis__Application__c = applicationId;
            objFundingTransaction.genesis__Payment_Mode__c = paymentModeId;
            objFundingTransaction.genesis__Funding_Date__c = todaysDate;
            objFundingTransaction.Grower_Name__c = growerName;
            objFundingTransaction.genesis__Amount__c = draftAmount;
            objFundingTransaction.genesis__Reference__c = description;
            objFundingTransaction.Pricing_Detail__c = pricingDetailId;
            objFundingTransaction.Draft_Number__c = draftNumber;
            objFundingTransaction.Payee__c = payee;
            objFundingTransaction.invoice__c = invoiceObj.Id;

            updateChildLoanList.add(objFundingTransaction);
            available = available - draftAmount;
            principalBalance = principalBalance + draftAmount;
            //Need to update the Principal Advanced on Child
            Decimal childCurrentPrincipal = pricingToPrincipalAdvMap.get(objFundingTransaction.Pricing_Detail__c);
            genesis__Application_Pricing_Detail__c objChildToUpdatePrincipal = new genesis__Application_Pricing_Detail__c(Id = objFundingTransaction.Pricing_Detail__c);
            objChildToUpdatePrincipal.Principal_Advanced__c = childCurrentPrincipal + draftAmount;
            prcncpalAdvnUpdtList.add(objChildToUpdatePrincipal);

            //Adding total amount for invoice
            totalInvoiceAmount += draftAmount;
        }
        applicationObj.Peak_Loan_Volume__c = principalBalance;

        Database.insert(updateChildLoanList,false);
        Database.insert(updtChildLoanToClearList,false);
        Database.update(applicationObj,false);
        Database.update(updtPrcngDtlForClrngList,true);
        Database.update(prcncpalAdvnUpdtList,true);

        //Updating Invoice
        PaymentInvoiceHelper.updateInvoice(invoiceObj.Id, totalInvoiceAmount);

        for(genesis__Funding_Transaction__c eachDraft : updtChildLoanToClearList){
            sendMail(eachDraft.Pricing_Detail__c, 
                    eachDraft.genesis__Amount__c,
                    eachDraft.Grower_Name__c);
        }
    }

    /**
     * @description Check For Suspence Balance
     * @param isAdvancing 
     * @param isSuspenseCleared 
     * @exception 
     */
    private static void checkForSuspenceBalance(Boolean isAdvancing, Boolean isSuspenseCleared){
        if(isAdvancing && !isSuspenseCleared){
            throw new CustomException(PortalConstants.CHECK_SUSPENSE_BALANCE_ERROR);
        }
    }

    /**
     * @description 
     * @param paramForBalanceCheckMap 
     * @exception 
     */
    private static void checkInsufficientAndSuspenseBalance(Map<String, Object> paramForBalanceCheckMap){

        if((Decimal)paramForBalanceCheckMap.get(KEY_AVAILABLE) < (Decimal)paramForBalanceCheckMap.get(KEY_DRAFT_AMOUNT)){
            throw new CustomException(PortalConstants.INSUFFICIENT_AVAILABLE_FUNDS);
        }
        if(!(Boolean)paramForBalanceCheckMap.get(IS_SUSPENSE_CLEARED) || (Decimal)paramForBalanceCheckMap.get(KEY_ACTUAL_AMOUNT) < (Decimal)paramForBalanceCheckMap.get(KEY_CREDIT_BALANCE)){
            throw new CustomException(PortalConstants.CHECK_SUSPENSE_BALANCE_ERROR);
        }
    }
    /**
    * @description : Check whether the Suspense is getting cleared in the transaction or Nor
    * @author Tuhin Bhunia | 06-24-2024 
    * @param childLoanList 
    * @param pricingToCreditBlncMap 
    * @return Boolean 
    **/
    public static Boolean checkSuspesneGettingClearedOrNot(List<Object> childLoanList, Map<String,Decimal> pricingToCreditBlncMap){

        Boolean isSuspenseCleared = true;
        for(Object eachChildloanRequest: childLoanList){
            Map<String, Object> request = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(eachChildloanRequest));
            Decimal draftAmount = Decimal.valueOf(String.valueOf(request.get(MAX_FINIANCED_AMOUNT)));
            Decimal creditBalance = pricingToCreditBlncMap.get(String.valueOf(request.get(KEY_ID)));
            if(draftAmount < creditBalance){
                isSuspenseCleared = false;
                break;
            }
        }
        return isSuspenseCleared;
    }
    /**
    * @description The purpose of this method is to validate if the dealer has the ability to do early basf advances on 0% grower rate
    * @author Ayan Bhowmik | 03-28-2025 
    * @param paramMap 
    **/
    public static void validateDealerBASFEarlyAdvanceEligibility(Map<String, Object> paramMap){
        if(String.valueOf(paramMap.get(PortalConstants.KEY_PAYMENT_MODE)).equalsIgnoreCase(DRAFT) && (Decimal)paramMap.get(PortalConstants.KEY_TRANSACTION_AMOUNT) == 0){
            return;
        }
        if(!JSON.serialize(System.Label.BASF_Early_Eligible_Dealer_CIF).contains(String.valueOf(paramMap.get(PortalConstants.FIELD_CIF_NUMBER)))
                    && String.valueOf(paramMap.get(PortalConstants.FIELD_DESCRIPTION)) == PortalConstants.BASF_EARLY_TRANCHE_DESCRIPTION
                    && (Decimal)paramMap.get(PortalConstants.FIELD_INTEREST_RATE) == 0
                    && String.valueOf(paramMap.get(PortalConstants.FIELD_CROP_YEAR)) == PortalConstants.STRING_TWO_ZERO_TWO_FIVE){
            throw new CustomException(PortalConstants.EARLY_BASF_ADVANCE_ERROR);
        }
    }
}