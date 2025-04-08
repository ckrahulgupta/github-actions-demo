/**
 * @description       : This API is used to email the receipt of the payment invoice also update the email field on invoice
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-02-2025
 * @last modified by  : Sk Minsar
**/
global without sharing class PortalSendPaymentReceiptEmailAPI implements clcommon.PortalCustomRemoteAPI1 {

    private static final String PAYMENT_RECEIPT_EMAIL_TEMPLATE = 'Loan Payment Receipt';
    private static final String REPLACE_GROWER_NAME = '{!growerName}';
    private static final String REPLACE_LOAN_NUMBER = '{!loanNumber}';
    private static final String ATTACHMENT_FILE_NAME = 'PaymentReceipt.pdf';
   
    /**
    * @description : Purpose of this method is to email the receipt of the payment invoice also update the email field on invoice
    * @author Suraj Kumar | 11-22-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param requestMap 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                                String[] disclosureNames,
                                                Map<String, Object> requestMap) {
                                                    
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        String email;
        String invoiceId;
        Boolean isValidUser;
        try {
            PortalApplicationOriginationHelper.checkIfNullObject(requestMap, PortalConstants.REQUIRED_PARAMETERS_MISSING);

            PortalApplicationOriginationHelper.checkIfNullObject(requestMap.get(PortalConstants.INVOICE_ID_KEY), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkIfNullObject(requestMap.get(PortalConstants.EMAIL_KEY), PortalConstants.REQUIRED_PARAMETERS_MISSING);

            invoiceId = String.valueOf(requestMap.get(PortalConstants.INVOICE_ID_KEY));
            email = String.valueOf(requestMap.get(PortalConstants.EMAIL_KEY));

            PortalApplicationOriginationHelper.checkBlankParameter(invoiceId, CustomMessageConstants.BLANK_INVOICE);
            PortalApplicationOriginationHelper.checkBlankParameter(email, CustomMessageConstants.BLANK_EMAIL);

            List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id, 
                                                                            Application__c,
                                                                            Application__r.genesis__Contact__r.Name,
                                                                            Application__r.genesis__Loan_Number__c,
                                                                            Application__r.Dealer_Name__c,
                                                                            Application__r.Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                                            Email__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        WHERE Id = :invoiceId];
            PortalApplicationOriginationHelper.checkEmptyList(invoiceList,CustomMessageConstants.INVOICE_NOT_FOUND);
            PortalValidationUtil.validateEmailAddress(email, CustomMessageConstants.INVALID_EMAIL);

            isValidUser = PortalSecurityUtil.validateUserApplication(invoiceList[0].Application__c);
            if(!isValidUser){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            invoiceList[0].Email__c = email;
            Database.update(invoiceList[0],PortalConstants.TRUE_VALUE);

            emailPaymentReceipt(invoiceList);

            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
            
        } catch (CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, PortalSendPaymentReceiptEmailAPI.class.getName());
        } 
        catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, PortalSendPaymentReceiptEmailAPI.class.getName());
        }
        return response;
    }

    /**
    * @description : Method to send Email and stored the log
    * @author Suraj Kumar | 11-25-2024 
    * @param invoiceList 
    **/
    private static void emailPaymentReceipt(List<clcommon__Consolidated_Invoice__c> invoiceList){
        String emailStatus = PortalConstants.EMPTY_STRING;
        String emailSubject;
        String emailBody;
        Messaging.SendEmailResult[] result;
        Blob paymentReceiptContent;

        List<String> recipientAddressList = new List<String>{invoiceList[0].Email__c};

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplateObj = EmailUtil.getEmailTemplate(PAYMENT_RECEIPT_EMAIL_TEMPLATE);
        List<OrgWideEmailAddress> senderAddressList = EmailUtil.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
        PortalApplicationOriginationHelper.checkEmptyList(senderAddressList,ConstantValues.SENDER_MISSING);

        emailToSend.setOrgWideEmailAddressId(senderAddressList[0].Id);
        emailSubject = emailTemplateObj.subject;
        emailSubject = emailSubject.replace(REPLACE_GROWER_NAME, invoiceList[0].Application__r.genesis__Contact__r.Name);
        emailSubject = emailSubject.replace(REPLACE_LOAN_NUMBER, invoiceList[0].Application__r.genesis__Loan_Number__c);
        emailToSend.subject = emailSubject;

        emailBody = emailTemplateObj.HtmlValue;                         
        emailBody = emailBody.replace(REPLACE_GROWER_NAME, invoiceList[0].Application__r.genesis__Contact__r.Name);

        emailBody = emailBody.replace(REPLACE_LOAN_NUMBER, invoiceList[0].Application__r.genesis__Loan_Number__c);
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, EmailUtil.setLogoURL(invoiceList[0].Application__r.Dealer_Name__c));
        emailToSend.setHtmlBody(emailBody);


        // Reference the PaymentReceipt page
        PageReference paymentReceiptAttachment = PaymentInvoiceHelper.exportInvoiceAsPDF(invoiceList[0].Id);
        paymentReceiptAttachment.setRedirect(PortalConstants.TRUE_VALUE);

        // Take the PDF content
        if (!test.isRunningTest()) {
            paymentReceiptContent = paymentReceiptAttachment.getContentAsPDF();
        } else{
            paymentReceiptContent = Blob.valueOf(ATTACHMENT_FILE_NAME);
        }

        // Create the email attachment
        Messaging.EmailFileAttachment emailAttachmentObj = new Messaging.EmailFileAttachment();
        emailAttachmentObj.setFileName(ATTACHMENT_FILE_NAME);
        emailAttachmentObj.setBody(paymentReceiptContent);
        emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttachmentObj});

        emailToSend.setToAddresses(recipientAddressList); 
        result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
        emailStatus = result[0].isSuccess()?ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;

        //Store Email Log
        Map<String, Object> notificationMap = new Map<String, Object>{
            ConstantValues.KEY_FROM_ADDRESS => senderAddressList[0].Address,
            ConstantValues.KEY_TO_ADDRESS => recipientAddressList[0],
            ConstantValues.KEY_EMAIL_TEMPLATE => PAYMENT_RECEIPT_EMAIL_TEMPLATE,
            ConstantValues.KEY_MESSAGE => emailBody,
            ConstantValues.KEY_CLASS_NAME => PortalSendPaymentReceiptEmailAPI.class.getName(),
            ConstantValues.KEY_EMAIL_STATUS => emailStatus
        };
        if(emailStatus == ConstantValues.FAILURE_STATUS){
            notificationMap.put(ConstantValues.KEY_ERROR_MESSAGE, result[0].getErrors().get(0).getMessage());
        }
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(notificationMap);
        if(notificationObj != null){
            Database.insert(notificationObj,PortalConstants.TRUE_VALUE);
        }
    }
}