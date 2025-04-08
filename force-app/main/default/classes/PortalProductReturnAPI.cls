/**
 * @description       : Portal API for Product Return Request.
 * @author            : Simran
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/
global without sharing class PortalProductReturnAPI implements clcommon.PortalCustomRemoteAPI1 {

    /**
    * @description updates the funding transaction, application and pricing details
    * @author Simran | 08-10-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
    
        Decimal amount=0;
        String purpose;
        String pricingDetails; 
        String applicationId;
        String fundingTransactionId;
        String dealerId;
        String paymentModeId;
        String bankAccountId;

        clcommon.Response response = new clcommon.Response();
        List<genesis__Application_Pricing_Detail__c> objPricingDetails = new List<genesis__Application_Pricing_Detail__c>();
        SavePoint dbSavePoint = Database.setSavepoint();
        try {

            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal, PortalConstants.KEY_PRICING_ID);
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal, PortalConstants.KEY_PURPOSE);
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal, PortalConstants.KEY_AMOUNT);
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal, PortalConstants.ID_KEY);

            PortalLoanServicingHelper.checkRequestBody(argumentsFromPortal, PortalConstants.KEY_AMOUNT);
            PortalLoanServicingHelper.checkRequestBody(argumentsFromPortal, PortalConstants.KEY_PURPOSE);
            PortalLoanServicingHelper.checkRequestBody(argumentsFromPortal, PortalConstants.KEY_PRICING_ID);
            
            if(argumentsFromPortal.get(PortalConstants.KEY_AMOUNT) == 0){
                PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.INVALID_AMOUNT);
            } 

            amount = (Decimal)argumentsFromPortal.get(PortalConstants.KEY_AMOUNT);
            purpose = (String)argumentsFromPortal.get(PortalConstants.KEY_PURPOSE);
            pricingDetails = (String)argumentsFromPortal.get(PortalConstants.KEY_PRICING_ID);
            fundingTransactionId = (String)argumentsFromPortal.get(PortalConstants.ID_KEY);

            LoanServicingHelper.checkEmptyString(pricingDetails, PortalConstants.REQUIRED_PARAMETERS_MISSING);
            LoanServicingHelper.checkEmptyString(purpose, PortalConstants.REQUIRED_PARAMETERS_MISSING);

            if(amount <= 0){
                PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.INVALID_AMOUNT);
            }

            objPricingDetails = [SELECT Id,
                                        Loan_Number__c,
                                        Past_Due_Balance__c,
                                        genesis__Application__c,
                                        genesis__Application__r.Dealer_Name__c,
                                        genesis__Application__r.Available__c,
                                        genesis__Application__r.Peak_Loan_Volume__c,
                                        genesis__Application__r.genesis__Maturity_Date__c,
                                        genesis__Application__r.genesis__Account__r.Name,
                                        Principal_Advanced__c
                                    FROM genesis__Application_Pricing_Detail__c
                                    WHERE Id =:pricingDetails];

            if(objPricingDetails.size()==0 || 
                objPricingDetails[0].genesis__Application__r.genesis__Maturity_Date__c== null || 
                objPricingDetails[0].Loan_Number__c== null){
                    PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.SOMETHING_WENT_WRONG);
            }

            applicationId = objPricingDetails[0].genesis__Application__c;
            dealerId = objPricingDetails[0].genesis__Application__r.Dealer_Name__c;

            // Validate Payment Mode and Bank Account
            paymentModeId = validatePaymentMode();

            bankAccountId = validateBankAccount(dealerId);

            // Date Validations for Product Return
            validateProductReturn(objPricingDetails[0], amount, fundingTransactionId);

            genesis__Applications__c objApplications = new genesis__Applications__c(Id=objPricingDetails[0].genesis__Application__c);
            genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
            
            if(fundingTransactionId.equalsIgnoreCase(PortalConstants.NEW_RECORD_STRING)){
                //Populate new Product Return
                createProductReturn(new Map<String, Object>{
                    PortalConstants.KEY_OBJ_FUNDING_TRANSACTION => objFundingTransaction,
                    PortalConstants.KEY_OBJ_PRICING_DETAILS => objPricingDetails[0],
                    PortalConstants.KEY_AMOUNT => amount,
                    PortalConstants.KEY_PURPOSE => purpose
                });

                objApplications.Peak_Loan_Volume__c = objPricingDetails[0].genesis__Application__r.Peak_Loan_Volume__c - amount;
                objPricingDetails[0].Principal_Advanced__c = objPricingDetails[0].Principal_Advanced__c - amount;
                objFundingTransaction.genesis__Payment_Mode__c = paymentModeId;
                objFundingTransaction.genesis__Bank_Account__c = bankAccountId;
                clcommon__Consolidated_Invoice__c invoiceObj = PaymentInvoiceHelper.createInvoice(applicationId, objFundingTransaction.genesis__Payment_Mode__c,amount);
                objFundingTransaction.invoice__c = invoiceObj.Id;
            }
            
            Database.upsert(objFundingTransaction,PortalConstants.TRUE_VALUE);
            Database.update(objApplications,PortalConstants.TRUE_VALUE);
            Database.update(objPricingDetails,PortalConstants.TRUE_VALUE);
        
            response.status = clcommon.Constants.SUCCESS; 
        }
        catch(CustomException customException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, PortalProductReturnAPI.class.getName()); 
        }
        catch(Exception objException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;  
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PortalProductReturnAPI.class.getName());
        }
        return response;
    }

    
    /**
    * @description validate product return
    * @author Soumik Pattanayak | 08-10-2024 
    * @param objPricing 
    * @param amount 
    * @param fundingTransactionId 
    **/
    private static void validateProductReturn( genesis__Application_Pricing_Detail__c objPricing,
                                                Decimal amount,
                                                String fundingTransactionId){
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(objPricing.genesis__Application__c); 
        if (!isValidUser) {
            PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.USER_NOT_AUTHORISED);
        }
        Date currentdate = System.today();
        Date currentMaturityDate = Date.valueOf(objPricing.genesis__Application__r.genesis__Maturity_Date__c);
        if(objPricing.Past_Due_Balance__c > 0 && currentMaturityDate < currentdate){
            PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.PAST_DUE_LOAN);
        }

        //validate and throw exception if next month is maturity date & current date is >=26
        LoanServicingHelper.validateCloseMaturityProductReturn(currentMaturityDate, currentdate);

        if(currentMaturityDate.year()-currentdate.year()==0 && currentMaturityDate.month()-currentdate.month()==0){
            PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.PRODUCT_RETURN_NOT_ALLOWED_IN_MONTH_OF_MATURITY_DATE);
        }
        if(currentMaturityDate < currentdate){
            PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.PAST_MATURITY_DATE);
        }
        if(objPricing.Principal_Advanced__c < amount && fundingTransactionId.equalsIgnoreCase(PortalConstants.NEW_RECORD_STRING)){
            PortalLoanServicingHelper.throwCustomError(PortalConstants.TRUE_VALUE, PortalConstants.PRODUCT_RETURN_MUST_LESS_THAN_PRINCIPAL_BALANCE);
        }
    }

    /**
    * @description Get the ACH Debit bank information for the dealer
    * @author Soumik Pattanayak | 08-10-2024 
    * @param dealerId 
    * @return String 
    **/
    private static String validateBankAccount(String dealerId){
        List<clcommon__Bank_Account__c> dealerBankAccountList = [SELECT Id 
                                                            FROM clcommon__Bank_Account__c 
                                                            WHERE ACH_Debit__c = :PortalConstants.TRUE_VALUE AND 
                                                                clcommon__Account__c = :dealerId AND 
                                                                clcommon__Active__c = :PortalConstants.TRUE_VALUE
                                                            ORDER BY createddate desc];
        
        LoanServicingHelper.checkEmptyList(dealerBankAccountList, PortalConstants.ACH_AUTHORIZATION_ERROR);
        return dealerBankAccountList[0].Id;
    }

    /**
    * @description validates payment mode
    * @author Soumik Pattanayak | 08-10-2024 
    * @return String 
    **/
    private static String validatePaymentMode(){
        List<clcommon__Payment_Mode__c> objPaymentModeList = [SELECT Id, 
                                                                Name 
                                                            FROM clcommon__Payment_Mode__c
                                                            WHERE Name =:ConstantValues.PRODUCT_RETURN 
                                                            LIMIT 1];

        LoanServicingHelper.checkEmptyList(objPaymentModeList, PortalConstants.SOMETHING_WENT_WRONG);
        return objPaymentModeList[0].Id;
    }

    /**
    * @description creates product return
    * @author Sk Minsar | 12-12-2024 
    * @param newProductReturnMap 
    **/
    private static void createProductReturn(Map<String, Object> newProductReturnMap){
        genesis__Funding_Transaction__c objFundingTransaction = (genesis__Funding_Transaction__c)newProductReturnMap.get(PortalConstants.KEY_OBJ_FUNDING_TRANSACTION);
        genesis__Application_pricing_Detail__c objPricing = (genesis__Application_pricing_Detail__c)newProductReturnMap.get(PortalConstants.KEY_OBJ_PRICING_DETAILS);

        objFundingTransaction.genesis__Amount__c = (Decimal)newProductReturnMap.get(PortalConstants.KEY_AMOUNT);
        objFundingTransaction.genesis__Reference__c = (String)newProductReturnMap.get(PortalConstants.KEY_PURPOSE);
        objFundingTransaction.genesis__Application__c = objPricing.genesis__Application__c;
        objFundingTransaction.genesis__Funding_Date__c = date.today();
        objFundingTransaction.Grower_Name__c = objPricing.genesis__Application__r.genesis__Account__r.Name;
        objFundingTransaction.Pricing_Detail__c = objPricing.Id;
    }
}