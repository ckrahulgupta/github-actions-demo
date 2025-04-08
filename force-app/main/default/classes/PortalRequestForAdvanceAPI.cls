/**********************************************************************************************************************
 * @description       : The purpose of this class is to store all the ACH/Draft advanced requested by an user.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-28-2025
 * @last modified by  : Ayan Bhowmik
**********************************************************************************************************************/

global without sharing class PortalRequestForAdvanceAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
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
    private static final String KEY_CHILD_LOAN = 'childLoans';
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
    public static Map<String, Map<String, Decimal>> creditBalPrincipalAdvMap = new map<String, Map<String, Decimal>>();
    public static Map<String,Decimal> pricingToCreditBlncMap = new Map<String,Decimal>();
    public static Map<String,Decimal> pricingToPrincipalAdvMap = new Map<String,Decimal>();


    // parameters specific for this class [end] 


    /**
    * @description - Purpose of this method is to create records for both ACH and draft type loan request for advanced
    *                and also edit the existing ones.
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        Decimal amount;
        Decimal available;
        Decimal principalBalance;
        String purpose;
        String accountId;
        String paymentMode;
        String draftNumber;
        String applicationId;
        String pricingDetails; 
        String fundingTransactionId;
        String payee = '';
        String childLoans = '';
        Date currentMaturityDate;
        Account accountObj = new Account();
        clcommon.Response response = new clcommon.Response();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        genesis__Applications__c applicationsObj = new genesis__Applications__c();
        List<clcommon__Payment_Mode__c> paymentModeList = new List<clcommon__Payment_Mode__c>();
        genesis__Application_Pricing_Detail__c pricingDetailsObj = new genesis__Application_Pricing_Detail__c();
     
        Boolean isSuspenseCleared = true;
        Boolean isAdvancing = false;
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            amount = (Decimal)argumentsFromPortal.get(KEY_AMOUNT);
            purpose = (String)argumentsFromPortal.get(KEY_PURPOSE);
            accountId = (String)argumentsFromPortal.get(KEY_ACCOUNT_ID);
            paymentMode = (String)argumentsFromPortal.get(KEY_PAYMENT_MODE);
            applicationId = (String)argumentsFromPortal.get(KEY_APPLICATION_ID);
            pricingDetails = (String)argumentsFromPortal.get(KEY_PRICING_DETAILS);
            childLoans = (String)argumentsFromPortal.get(KEY_DRAFT_CHILD);
            payee = (String)argumentsFromPortal.get(KEY_PAYEE);
            draftNumber = String.valueOf(argumentsFromPortal.get(KEY_DRAFT_NUMBER));
            fundingTransactionId = (String)argumentsFromPortal.get(KEY_ID);
            PortalLoanServicingHelper.checkForBlankParameter(accountId);
            PortalLoanServicingHelper.checkForBlankParameter(paymentMode);
            paymentModeList = PortalLoanServicingHelper.getPaymentMode(paymentMode);
            
            accountObj = [SELECT Id,
                                 Name
                            FROM Account
                            WHERE Id=:accountId];
            PortalLoanServicingHelper.throwCustomError(accountObj == null,PortalConstants.SOMETHING_WENT_WRONG);

            if(paymentMode.equalsIgnoreCase(DRAFT)){
                applicationObj = checkArgumentsForDraft(applicationId, draftNumber);
                draftNumber = applicationObj.Dealer_Name__r.CIF_Number__c + draftNumber;
                currentMaturityDate = Date.valueOf(applicationObj.genesis__Maturity_Date__c);
                checkDuplicateDraftNumber(draftNumber);
            }else{
                pricingDetailsObj = [SELECT Id,
                                            genesis__Application__c,
                                            genesis__Application__r.Available__c,
                                            genesis__Application__r.Peak_Loan_Volume__c,
                                            genesis__Application__r.genesis__Maturity_Date__c,
                                            genesis__Application__r.genesis__Contact__r.Name,
                                            Principal_Advanced__c,
                                            Loan_Number__c,
                                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                                            genesis__Application__r.Crop_Year__c,
                                            genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c,
                                            genesis__Rate_Card_Setup_Detail__r.Description__c
                                     FROM genesis__Application_Pricing_Detail__c
                                     WHERE Id =:pricingDetails];
                currentMaturityDate = Date.valueOf(pricingDetailsObj.genesis__Application__r.genesis__Maturity_Date__c);
                applicationId = pricingDetailsObj.genesis__Application__c;
                PortalRequestForAdvanceHandler.validateDealerBASFEarlyAdvanceEligibility(new Map<String, Object>{
                    PortalConstants.FIELD_CIF_NUMBER => pricingDetailsObj.genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                    PortalConstants.FIELD_DESCRIPTION => pricingDetailsObj.genesis__Rate_Card_Setup_Detail__r.Description__c,
                    PortalConstants.FIELD_INTEREST_RATE => pricingDetailsObj.genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c,
                    PortalConstants.FIELD_CROP_YEAR => pricingDetailsObj.genesis__Application__r.Crop_Year__c,
                    PortalConstants.KEY_PAYMENT_MODE => ACH
                });
            }
           
            validateUser(applicationId);
           
            /*****************************************************Suspended loan check[end]*********************************************/
            Boolean suspendedStatus = checkForSuspendedLoan(date.today(), currentMaturityDate);
            PortalLoanServicingHelper.throwCustomError(suspendedStatus == true,PortalConstants.SUSPENDED_LOAN);
            //Clear all the credit balance that is left
            //Run trhough the Draft list and fetch the total of Draft Amount paid

            Map<String,String> validateDraftParamMap = new Map<String,String>{
                KEY_PAYMENT_MODE => paymentMode,
                KEY_FUNDING_TRANSACTION_ID => fundingTransactionId,
                KEY_CHILD_LOAN => childLoans,
                KEY_APPLICATION_ID => applicationId
            };
            Map<String,Object> checkAdvAndClrSuspenceMap = validateDraftForNewRecord(validateDraftParamMap,amount);
            amount = (Decimal)checkAdvAndClrSuspenceMap.get(KEY_AMOUNT);
            isSuspenseCleared = (Boolean)checkAdvAndClrSuspenceMap.get(IS_SUSPENSE_CLEARED);
            isAdvancing = (Boolean)checkAdvAndClrSuspenceMap.get(IS_ADVANCING);

            Map<String, Object> achSuspenseBlncParamMap = new Map<String, Object>{
                KEY_APPLICATION_ID => applicationId,
                KEY_PURPOSE => purpose,
                KEY_FUNDING_TRANSACTION_ID => fundingTransactionId,
                KEY_GROWER_NAME => accountObj.Name,
                KEY_PAYMENT_MODE => paymentMode,
                KEY_PRICING_DETAILS => pricingDetails,
                KEY_AMOUNT => amount,
                KEY_ID => paymentModeList[0].Id
            };
            amount = PortalRequestForAdvanceHandler.createAchForSuspenseBalance(achSuspenseBlncParamMap, paymentModeList[0].Id, amount);
            if(amount > 0 && paymentMode.equalsIgnoreCase(ACH)){
                Map<String, Object> achFundingTxnParamMap = new Map<String, Object>{
                    KEY_APPLICATION_ID => applicationId,
                    KEY_PURPOSE => purpose,
                    KEY_FUNDING_TRANSACTION_ID => fundingTransactionId,
                    KEY_GROWER_NAME => accountObj.Name,
                    KEY_PAYMENT_MODE => paymentMode,
                    KEY_PRICING_DETAILS => pricingDetails,
                    KEY_AMOUNT => amount,
                    KEY_ID => paymentModeList[0].Id
                };
            PortalRequestForAdvanceHandler.createFundingTransactionForACH(achFundingTxnParamMap, applicationsObj, pricingDetailsObj);
            }else if(amount > 0 && paymentMode.equalsIgnoreCase(DRAFT)){
                available = applicationObj.Available__c;
                principalBalance = applicationObj.Peak_Loan_Volume__c;
                if(fundingTransactionId.equalsIgnoreCase(NEW_RECORD)){
                    Map<String, Object> paramForDraftMap = new Map<String, Object>{
                        KEY_APPLICATION_ID => applicationId,
                        KEY_PURPOSE => purpose,
                        KEY_FUNDING_TRANSACTION_ID => fundingTransactionId,
                        KEY_GROWER_NAME => accountObj.Name,
                        KEY_PAYMENT_MODE => paymentMode,
                        KEY_PRICING_DETAILS => pricingDetails,
                        KEY_AMOUNT => amount,
                        KEY_ID => paymentModeList[0].Id,
                        KEY_DRAFT_CHILD => childLoans,
                        KEY_DRAFT_NUMBER => draftNumber,
                        KEY_PAYEE => payee,
                        IS_ADVANCING => isAdvancing,
                        IS_SUSPENSE_CLEARED => isSuspenseCleared,
                        KEY_APPLICATION => applicationObj
                    };
                    
                    PortalLoanServicingHelper.checkForBlankParameter(childLoans);
                    PortalLoanServicingHelper.checkForBlankParameter(draftNumber);
                    PortalLoanServicingHelper.checkForBlankParameter(payee);
                   
                    PortalRequestForAdvanceHandler.createFundingTransactionForDraft(paramForDraftMap,pricingToCreditBlncMap, pricingToPrincipalAdvMap);
                }else{
                    amount = (Decimal)argumentsFromPortal.get(GENESIS_AMOUNT);
                    String reference = (String)argumentsFromPortal.get(REFERENCE);
                    Map<String, Object> existFundingTxnParamMap = new Map<String, Object>{
                        KEY_AMOUNT => amount,
                        KEY_FUNDING_TRANSACTION_ID => fundingTransactionId,
                        KEY_REFERENCE => reference,
                        KEY_AVAILABLE => available,
                        KEY_DRAFT_NUMBER => draftNumber,
                        KEY_PAYEE => payee
                    };
                    createFundingTxnForExisting(existFundingTxnParamMap, applicationObj);
                }
            }
            response.status = clcommon.Constants.SUCCESS; 
        } catch (CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, REQUEST_FOR_ADVANCE_API);
        } catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;  
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, REQUEST_FOR_ADVANCE_API);
        }
        return response;
    }

    /**
     * @description 
     * @param applicationId 
     */
    private static void validateUser(String applicationId){
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        PortalApplicationOriginationHelper.checkValidUser(isValidUser);
         
    }
    /**
     * @description Validate required param for creating draft
     * @param validateDraftParamMap 
     * @param amount 
     * @return  `Map<String,Object>`
     */
    private static  Map<String,Object> validateDraftForNewRecord(Map<String,String> validateDraftParamMap , Decimal amount){
        Boolean isSuspenseCleared = true;
        Boolean isAdvancing = false;
        List<genesis__Application_Pricing_Detail__c> clrPricingBalDraftList = new List<genesis__Application_Pricing_Detail__c>();
        if(validateDraftParamMap.get(KEY_PAYMENT_MODE).equalsIgnoreCase(DRAFT) && validateDraftParamMap.get(KEY_FUNDING_TRANSACTION_ID).equalsIgnoreCase(NEW_RECORD)){
            amount = 0;
            List<Object> childLoanListRequest = (List<Object>) Json.deserializeUntyped(validateDraftParamMap.get(KEY_CHILD_LOAN));
            amount = getTotalAmountForDraft(childLoanListRequest);
            clrPricingBalDraftList = [SELECT Id,
                                            Credit_Balance__c,
                                            Principal_Advanced__c
                                        FROM genesis__Application_Pricing_Detail__c
                                        WHERE genesis__Application__c = :validateDraftParamMap.get(KEY_APPLICATION_ID) AND
                                        genesis__Enabled_Flag__c = true];   
            getCreditBlncAndPrincipalAdvncMap(clrPricingBalDraftList);
            
            isSuspenseCleared = PortalRequestForAdvanceHandler.checkSuspesneGettingClearedOrNot(childLoanListRequest, pricingToCreditBlncMap);
             //Check whether advancing on it or not
            isAdvancing = checkAdvancingOrNot(childLoanListRequest, pricingToCreditBlncMap);
           
        }
        Map<String,Object> checkAdvAndClrSuspenceMap = new Map<String,Object>{
            IS_SUSPENSE_CLEARED => isSuspenseCleared,
            IS_ADVANCING => isAdvancing,
            KEY_AMOUNT => amount
        };
        return checkAdvAndClrSuspenceMap;
       
    }
 
    /**
     * @description Thia method will edit the existing funding transaction for ach and draft.
     * @param paramMap 
     * @param applicationObj 
     */
    private static void createFundingTxnForExisting(Map<String, Object> paramMap, genesis__Applications__c applicationObj){
        Decimal amount = (Decimal)paramMap.get(KEY_AMOUNT);
        String reference = String.valueOf(paramMap.get(KEY_REFERENCE));
        String payee = String.valueOf(paramMap.get(KEY_PAYEE));
        String draftNumber = String.valueOf(paramMap.get(KEY_DRAFT_NUMBER));
        String fundingTransactionId = String.valueOf(paramMap.get(KEY_FUNDING_TRANSACTION_ID));
        Decimal available = (Decimal)paramMap.get(KEY_AVAILABLE);
        Decimal principalBalance = applicationObj.Peak_Loan_Volume__c;
        Decimal totalInvoiceAmount = 0;
        
        genesis__Funding_Transaction__c existingFundingTxnObj = [SELECT Id, 
                                                                            genesis__Amount__c,
                                                                            Pricing_Detail__c,
                                                                            Pricing_Detail__r.Principal_Advanced__c,
                                                                            Invoice__c,
                                                                            Invoice__r.Total_Amount__c
                                                                    FROM genesis__Funding_Transaction__c 
                                                                    WHERE genesis__Payment_Mode__r.Name =: DRAFT
                                                                    AND posted_to_nls__c =: PortalConstants.FALSE_VALUE
                                                                    AND genesis__cleared__c =: PortalConstants.FALSE_VALUE
                                                                    AND Id =: fundingTransactionId];
        
        PortalLoanServicingHelper.throwCustomError(existingFundingTxnObj == null,PortalConstants.SOMETHING_WENT_WRONG);
        PortalLoanServicingHelper.throwCustomError(amount <= 0,PortalConstants.INVALID_AMOUNT);
        PortalLoanServicingHelper.throwCustomError(available + existingFundingTxnObj.genesis__Amount__c  < amount,PortalConstants.INSUFFICIENT_AVAILABLE_FUNDS);

        // Updated invoice amount
        totalInvoiceAmount = existingFundingTxnObj.Invoice__r.Total_Amount__c - existingFundingTxnObj.genesis__Amount__c + amount;

        existingFundingTxnObj.genesis__Amount__c = amount;  
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Reference__c = reference;
        objFundingTransaction.genesis__Amount__c = amount;
        objFundingTransaction.Draft_Number__c = draftNumber;
        objFundingTransaction.Payee__c = payee;
        objFundingTransaction.Id = fundingTransactionId;
        objFundingTransaction.Pricing_Detail__c = existingFundingTxnObj.Pricing_Detail__c;


        Database.update(objFundingTransaction,true);
        //Update the total Invoice Amount
        PaymentInvoiceHelper.updateInvoice(existingFundingTxnObj.Invoice__c, totalInvoiceAmount);
        applicationObj.Peak_Loan_Volume__c = principalBalance - existingFundingTxnObj.genesis__Amount__c + amount;
        Database.update(applicationObj,true);
        //Update the Child Loan Principal Advanced
        genesis__Application_Pricing_Detail__c objPricingForPrincipal = new genesis__Application_Pricing_Detail__c (Id = objFundingTransaction.Pricing_Detail__c);
        Decimal currentChildPrincipal = existingFundingTxnObj.Pricing_Detail__r.Principal_Advanced__c;
        objPricingForPrincipal.Principal_Advanced__c = currentChildPrincipal - existingFundingTxnObj.genesis__Amount__c + amount;
        Database.update(objPricingForPrincipal,true);
    }


    /**
     * @description This method return total amount for draft.
     * @param childLoanListRequest 
     * @return  `Decimal`
     */
    private static Decimal getTotalAmountForDraft(List<Object> childLoanListRequest){
        Decimal amount = 0;
        for(Object eachChildloanRequest: childLoanListRequest){
            Map<String, Object> request = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(eachChildloanRequest));
            amount += Decimal.valueOf(String.valueOf(request.get(MAX_FINIANCED_AMOUNT)));
        }
        return amount;
    }

    /**
    * @description : Purpose of this method is to check if the loan is suspended or not.
    * @author Tuhin Bhunia | 06-18-2024 
    * @param currentdate 
    * @param currentMaturityDate 
    * @return Boolean 
    **/
    private static Boolean checkForSuspendedLoan(Date currentdate, Date currentMaturityDate) {

        Boolean suspendedStatus = false;
        Integer yearDiff = currentMaturityDate.year() - currentdate.year();
        Integer monthDiff = currentMaturityDate.month() - currentdate.month();

        if(yearDiff < 0 || (yearDiff == 0 && ((monthDiff == 1 & currentdate.day() >= 26) || monthDiff <= 0))){
            suspendedStatus = true;
        }else if(yearDiff == 1 && currentMaturityDate.month()==1 && currentdate.month()==12 && currentdate.day() >= 26){
            suspendedStatus = true;
        }
        return suspendedStatus;
    }

    /**
     * @description Return Pticing to principal map and principal to credit balance map
     * @param clrPricingBalDraftList 
     */
    private static void getCreditBlncAndPrincipalAdvncMap(List<genesis__Application_Pricing_Detail__c> clrPricingBalDraftList){

        for(genesis__Application_Pricing_Detail__c objEachPrcingToClear : clrPricingBalDraftList){
            if(objEachPrcingToClear.Credit_Balance__c != null && objEachPrcingToClear.Credit_Balance__c > 0){
                pricingToCreditBlncMap.put(objEachPrcingToClear.Id, objEachPrcingToClear.Credit_Balance__c);
            }
            else{
                pricingToCreditBlncMap.put(objEachPrcingToClear.Id, 0);
            }
            if(objEachPrcingToClear.Principal_Advanced__c != null && objEachPrcingToClear.Principal_Advanced__c > 0){
                pricingToPrincipalAdvMap.put(objEachPrcingToClear.Id, objEachPrcingToClear.Principal_Advanced__c);
            }
            else {
                pricingToPrincipalAdvMap.put(objEachPrcingToClear.Id, 0);
            }
        }
        
    }

    /**
    * @description : Check whether advancing on it or not
    * @author Tuhin Bhunia | 06-24-2024 
    * @param childLoanList 
    * @param pricingToCreditBlncMap 
    * @return Boolean 
    **/
    private static Boolean checkAdvancingOrNot(List<Object> childLoanList, Map<String,Decimal> pricingToCreditBlncMap){

        Boolean isAdvancing = false;
        for(Object eachChildloanRequest: childLoanList){
            Map<String, Object> request = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(eachChildloanRequest));
            Decimal draftAmount = Decimal.valueOf(String.valueOf(request.get(MAX_FINIANCED_AMOUNT)));
            Decimal creditBalance = pricingToCreditBlncMap.get(String.valueOf(request.get(KEY_ID)));
            if(draftAmount > creditBalance){
                isAdvancing = true;
                break;
            }
        }
        return isAdvancing;
    }

    /**
    * @description Check for duplicate draft number
    * @author Tuhin Bhunia | 06-24-2024 
    * @param draftNumber 
    **/
    private static void checkDuplicateDraftNumber(String draftNumber){
        if(String.isNotBlank(draftNumber)){
        List<genesis__Funding_Transaction__c> fundingTrnxCraftObj = [SELECT Id,
                                                                            Draft_Number__c
                                                                    FROM genesis__Funding_Transaction__c 
                                                                    WHERE Draft_Number__c = :draftNumber
                                                                ];
        PortalLoanServicingHelper.throwCustomError(fundingTrnxCraftObj.size() > 0,PortalConstants.DUPLICATE_DRAFT_NUMBER);
            
        }
    }

    /**
    * @description Check arg for Draft
    * @author Tuhin Bhunia | 06-24-2024 
    * @param applicationId 
    * @param draftNumber 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c checkArgumentsForDraft(Id applicationId, String draftNumber){
        List<genesis__Applications__c> objApplication = [SELECT Id,
                                                                Available__c,
                                                                genesis__Maturity_Date__c,
                                                                Peak_Loan_Volume__c,
                                                                genesis__Contact__r.Name,
                                                                Dealer_Name__r.CIF_Number__c,
                                                                Crop_Year__c
                                                        FROM genesis__Applications__c
                                                        WHERE Id =:applicationId];
    
        PortalLoanServicingHelper.throwCustomError(objApplication == null,PortalConstants.SOMETHING_WENT_WRONG);
        PortalLoanServicingHelper.throwCustomError(objApplication[0].Dealer_Name__r.CIF_Number__c == null,PortalConstants.SOMETHING_WENT_WRONG);
        PortalLoanServicingHelper.throwCustomError(draftNumber == null,ConstantValues.PARAMETER_MISSING);
        return objApplication[0];
    }
 }