/**
 * @description       : This is for testing purpose
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-19-2025
 * @last modified by  : Rahul Gupta
**/
global without sharing class PortalExportPaymentReceiptAPI implements clcommon.PortalCustomRemoteAPI1 {
    /**
    * @description - 
    * @author Sk Minsar | 12-10-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> argumentsFromPortal){
        Boolean isValidUser = PortalConstants.FALSE_VALUE;
        String invoiceId = null;
        List<clcommon__Consolidated_Invoice__c> invoiceList = new List<clcommon__Consolidated_Invoice__c>();
        List<genesis__Funding_Transaction__c> fundingTransactionList = new List<genesis__Funding_Transaction__c>();
        Map<String, Object> responseFieldMap = new Map<String, Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();
        try{
            PortalLoanServicingHelper.checkRequestParam(argumentsFromPortal, PortalConstants.INVOICE_ID_KEY);
            LoanServicingHelper.checkEmptyString(String.valueOf(argumentsFromPortal.get(PortalConstants.INVOICE_ID_KEY)), PortalConstants.REQUIRED_PARAMETERS_MISSING);  
            invoiceId = String.valueOf(argumentsFromPortal.get(PortalConstants.INVOICE_ID_KEY));
            invoiceList = [
                        SELECT Id,
                                Application__c,
                                Application__r.Id,
                                Application__r.genesis__Loan_Number__c,
                                Application__r.genesis__Account__r.Name,
                                Application__r.Dealer_Name__r.Coop_Type__c,
                                Total_Amount__c,
                                Createddate,
                                Invoice_Number__c,
                                Comment__c
                        FROM clcommon__Consolidated_Invoice__c
                        WHERE Id = :invoiceId
                        LIMIT 1
                    ];
            LoanServicingHelper.checkEmptyList(invoiceList, PortalConstants.INVALID_INVOICE);
            isValidUser = PortalSecurityUtil.validateUserApplication(String.valueOf(invoiceList[0].Application__c));
            if(!isValidUser){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            fundingTransactionList = [SELECT Id,
                                             Pricing_Detail__r.Loan_Number__c,
                                             genesis__Reference__c,
                                             Principal_Paid__c,
                                             Interest_Paid__c,
                                             Fees_Paid__c,
                                             genesis__Amount__c
                                    FROM genesis__Funding_Transaction__c
                                    WHERE Invoice__c = :invoiceId
                                    ORDER BY Pricing_Detail__r.Loan_Number__c];
            LoanServicingHelper.checkEmptyList(fundingTransactionList, PortalConstants.NO_TRANSACTION_DATA);
            
            // get the export as page reference
            PageReference pdfPage = PaymentInvoiceHelper.exportInvoiceAsPDF(invoiceId);
            
            
            if(!Test.isRunningTest()){
                responseFieldMap.put(PortalConstants.KEY_PDF, EncodingUtil.base64Encode(pdfPage.getContentAsPDF()));
            }
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
        } catch (CustomException objCustomException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, PortalExportPaymentReceiptAPI.class.getName());
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PortalExportPaymentReceiptAPI.class.getName());
        }
        return response;
    }

}