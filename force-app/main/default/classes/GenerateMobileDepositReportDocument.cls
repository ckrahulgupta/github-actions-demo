/**********************************************************************************************************************
 * @description       : This class runs the report and sends it as attachments on email for Mobile Deposits
 * @author            : Sanjana De
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**********************************************************************************************************************/
public without sharing class GenerateMobileDepositReportDocument {
    private static final String PAGE_REF_URL = '?export=Export&enc=UTF-8&xf=xls&isdtp=p1';
    private static final String SET_CONTENT_EXCEL = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    private static final String BODY_CONTENT_FOR_TESTING = 'Setting Body Content for testing Purpose';
    private static final String REPORT_EMAIL_SUBJECT = 'NLS Mobile Deposits Report';
    private static final String EMAIL_TEMPLATE_NAME = 'Payment Reporting Email Template';
    private static final String EMAIL_BODY = '<br/><br/>Please review the daily reports attached.<br/><br/><br/><br/>';
    private static final String PAGE_REF_URL_DETAILED = '/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=';
    
    /**
    * @description : Run's the report
    * @author  Pritam Roy | 03-06-2024 
    * @param reportId 
    **/
    private static void runReport(Id reportId) {
        Reports.ReportManager.runReport(reportId, ConstantValues.TRUE_VALUE);
    }

    
    /**
    * @description : Get the report content
    * @author  Pritam Roy | 03-06-2024 
    * @param reportId 
    * @return Blob 
    **/
    private static Blob getReportContent(Id reportId) {
        //return (new ApexPages.PageReference('/' + reportId + PAGE_REF_URL)).getContent();
        //To Export CSV in a formatted way
        return (new ApexPages.PageReference(PAGE_REF_URL_DETAILED + reportId)).getContent();
    }
    /**
    * @description : Create mobile deposit document and updates status
    * @author  Pritam Roy | 03-06-2024 
    * @param reportId 
    * @param folderId 
    **/
    @future(callout=true)
    public static void createDocument(Id reportId, Id folderId) {
        Set<Id> invoiceIdSet = new Set<Id>();
        try {

            List<Report> reportList = [ SELECT  Id, 
                                                Name 
                                        FROM Report 
                                        WHERE Id = :reportId 
                                        LIMIT 1];
            
            List<Folder> folderList = [ SELECT  Id, 
                                                Name 
                                        FROM Folder 
                                        WHERE Id = :folderId 
                                        LIMIT 1];
            
            LoanServicingHelper.checkEmptyList(reportList, ConstantValues.NO_REPORT_FOUND);
            LoanServicingHelper.checkEmptyList(folderList, ConstantValues.NO_REPORT_FOUND);
            runReport(reportId);
            
            Document document = new Document();
            if(!Test.isRunningTest()){
                document.Body = getReportContent(reportId);
            }
            document.IsPublic = ConstantValues.TRUE_VALUE;
            document.Name = reportList[0].Name + ConstantValues.SPACE_HYPEN_SPACE_STRING + Datetime.now() + ConstantValues.DOT_XLS_STRING;
            document.FolderId = folderId;
            Database.insert(document);

            //Send the email as an attachment [START]------------------------------
            List<Messaging.EmailFileAttachment> attachments=new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
            objMsgEmailAttach.setFileName(reportList[0].Name+ConstantValues.DOT_XLS_STRING);
            if(!Test.isRunningTest()){
                objMsgEmailAttach.setBody(document.Body);
                //objMsgEmailAttach.setBody(System.Blob.toPdf(document.Body.toString()));
            }
            else{
                objMsgEmailAttach.setBody(Blob.valueOf(BODY_CONTENT_FOR_TESTING));
            }
            
            objMsgEmailAttach.setContentType(SET_CONTENT_EXCEL);
            attachments.add(objMsgEmailAttach);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(ConstantValues.FALSE_VALUE);
            mail.setToAddresses(new List<String>{ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS});
            mail.setSubject(REPORT_EMAIL_SUBJECT);
            mail.setHtmlBody(EMAIL_BODY);
            mail.setFileAttachments(attachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            //Send the email as an attachment [ENDS]-----------------------------------

            //Query all the Payment funding transaction and making it cleared true
            List<genesis__Funding_Transaction__c> objFundingTransactionList = new List<genesis__Funding_Transaction__c>();
            List<genesis__Funding_Transaction__c> updateTransactionList = [SELECT Id,
                                                                                  Invoice__c  
                                                                                FROM genesis__Funding_Transaction__c
                                                                                WHERE genesis__Cleared__c = :ConstantValues.FALSE_VALUE
                                                                                AND Status__c != :ConstantValues.VOIDED_STATUS
                                                                                AND genesis__Payment_Mode__r.Name =:ConstantValues.MOBILE_DEPOSIT];
            for(genesis__Funding_Transaction__c objPaymentTransaction : updateTransactionList){
                objPaymentTransaction.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
                objPaymentTransaction.Status__c = ConstantValues.STATUS_INITIATED;
                objFundingTransactionList.add(objPaymentTransaction);
                invoiceIdSet = PaymentInvoiceHelper.addInvoiceIdSet(objPaymentTransaction.Invoice__c, invoiceIdSet);
            }
            if(!objFundingTransactionList.isEmpty()){
                Database.Update(objFundingTransactionList,ConstantValues.TRUE_VALUE);
                PaymentInvoiceHelper.updateInvoiceStatus(new List<Id>(invoiceIdSet), ConstantValues.STATUS_INITIATED);
            }

        } catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, GenerateMobileDepositReportDocument.class.getName());
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, GenerateMobileDepositReportDocument.class.getName());
        }
    }
}