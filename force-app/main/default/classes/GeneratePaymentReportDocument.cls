/**
 * @description       : This class runs the report and generates th
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   15-06-2022   Subham Nandi   Initial Version
**/
public with sharing class GeneratePaymentReportDocument implements Queueable,Database.AllowsCallouts {
    //Constants Specific To this Class
    private static final String PAGE_REF_URL = '?export=Export&enc=UTF-8&xf=xls&isdtp=p1';
    private static final String ERROR_MESSAGE = 'No report found with the given ID.';
    private static final String SET_CONTENT_EXCEL = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    private static final String SET_CONTENT_PDF = 'application/pdf';
    private static final String BODY_CONTENT_FOR_TESTING = 'Setting Body Content for testing Purpose';
    private static final String REPORT_EMAIL_SUBJECT = 'NLS Payments Report';
    private static final String NACHA_REPORT = 'Payment NACHA Report';
    private static final String EMAIL_TEMPLATE_NAME = 'Payment Reporting Email Template';
    private static final String EMAIL_BODY = '<br/><br/>Please review the daily reports attached.<br/><br/><br/><br/>';
    private static final String PAGE_REF_URL_DETAILED = '/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=';
    private static final String CSV_COLUMN_HEADER = 'Routing Number, Account Number , Bank Account Name, Bank Account Type, Grower Name, Loan Number, Amount \n';
    private static final String CSV_FILE_NAME= 'NACHA File.csv';
    private static final String SUBJECT ='NACHA File for Initiated Payments';
    private static final String FOLDER_TYPE = 'Document';
    private static final String INITIATED_EMAIL_SUBJECT = 'Dealer Online Payment Initiated Report';
    private static final String ROUTING_NUMBER = 'RoutingNumber';
    private static final String BANK_ID = 'bankId';
    private static final String BANK_NAME = 'BankName';
    private static final String ACCOUNT_TYPE = 'AccountType';
    private static final String GROWER_NAME = 'GrowerName';
    private static final String LOAN_NUMBER = 'LoanNumber';
    private static final String AMOUNT = 'Amount';
    //Constants Specific To This Class
    private Id reportId;
    private Id folderId;
    /**
     * @description Purpose of this constructor is to check pass the parameters.
     * @param reportId 
     * @param folderId
     */
    public GeneratePaymentReportDocument(Id reportId, Id folderId){
        this.reportId = reportId;
        this.folderId = folderId;
    }
    /**
    * @description queue the reports
    * @author  Pritam Roy | 01-15-2024 
    * @param context 
    **/
    public void execute(QueueableContext context){
        createDocument(reportId,folderId);
    }
    /**
     * @description To run the report
     * @param reportId
     */
    private static void runReport(Id reportId) {
        Reports.ReportManager.runReport(reportId, ConstantValues.TRUE_VALUE);
    }

    /**
     * @description To get report Content
     * @param reportId
     * @return `Blob`
     */
    private static Blob getReportContent(Id reportId) {
        //To Export CSV in a formatted way
        return (new ApexPages.PageReference(PAGE_REF_URL_DETAILED + reportId)).getContent();
    }
    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Funding_Transaction__c.isAccessible())
                | (!Schema.sObjectType.OrgWideEmailAddress.isAccessible())
                | (!Schema.sObjectType.Report.isAccessible())
                | (!Schema.sObjectType.Document.isCreateable())
                | (!Schema.sObjectType.genesis__Funding_Transaction__c.isUpdateable())
                | (!Schema.sObjectType.Folder.isAccessible())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
     * @description To generate Dealer Online Payment Report
     */
    private static void generateDealerPaymentReport(){
        //Dealer Online Payment Report
        List<Report> reportList =  [SELECT  Id,
                                            Name 
                                    FROM Report 
                                    WHERE Name = :ConstantValues.DEALER_ONLINE_PAYMENT_PENDING
                                    LIMIT 1];
        //Dealer Online Payment Folder
        List<Folder> folderList =   [SELECT Id,
                                            Name 
                                    FROM Folder 
                                    WHERE Name = :ConstantValues.DEALER_ONLINE_PAYMENT_REPORTS
                                    AND Type =: FOLDER_TYPE
                                    LIMIT 1];

        //Sending Daily Dealer Online Payment Initiated Report
        GenerateDealerPaymentHandler.createDealerPaymentDocument((Id) String.valueOf(reportList[0].Id), (Id) String.valueOf(folderList[0].Id),INITIATED_EMAIL_SUBJECT);
    }
    /**
     * @description To update Pending Funding Transactions
     */
    private static void updateFundingTransaction(){
        Set<Id> invoiceIdSet = new Set<Id>();
        //Query all the Payment funding transaction and making it cleared true
        List<genesis__Funding_Transaction__c> objFundingTransactionList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Funding_Transaction__c> updateTransactionList = [SELECT Id,
                                                                              Status__c,
                                                                              Invoice__c  
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Cleared__c = :ConstantValues.FALSE_VALUE
                                                                        AND Status__c != :ConstantValues.VOIDED_STATUS
                                                                        AND genesis__Payment_Mode__r.Name =:ConstantValues.PAYMENT];
        for(genesis__Funding_Transaction__c objPaymentTransaction : updateTransactionList){
            objPaymentTransaction.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
            objPaymentTransaction.Status__c = ConstantValues.STATUS_INITIATED;
            objFundingTransactionList.add(objPaymentTransaction);
            invoiceIdSet = PaymentInvoiceHelper.addInvoiceIdSet(objPaymentTransaction.Invoice__c, invoiceIdSet);
        }
        if(!objFundingTransactionList.isEmpty()){
            Database.update(objFundingTransactionList, ConstantValues.TRUE_VALUE);
            PaymentInvoiceHelper.updateInvoiceStatus(new List<Id>(invoiceIdSet), ConstantValues.STATUS_INITIATED);
        }
    }
    /**
     * @description To send Dealer Online Payment Report,Payment Report and Payment NACHA to Loan Accounting
     * @param reportId
     * @param folderId
     */
    public static void createDocument(Id reportId, Id folderId) {
        try {
            checkAccessOnObjects();
            List<OrgWideEmailAddress> senderAddress = [SELECT Id,
                                                            Address, 
                                                            DisplayName 
                                                    FROM  OrgWideEmailAddress 
                                                    WHERE DisplayName = :ConstantValues.CFA_ORGANISATION];
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
            //Run the Report
            runReport(reportId);

            Document objDocument = new Document();
            if(!Test.isRunningTest()){
                objDocument.Body = getReportContent(reportId);
            }
            //Generate Dealer Online Payment Report
            generateDealerPaymentReport();

            objDocument.IsPublic = ConstantValues.TRUE_VALUE;
            objDocument.Name = reportList[0].Name + ConstantValues.SPACE_HYPEN_SPACE_STRING + Datetime.now() + ConstantValues.DOT_XLS_STRING;
            objDocument.FolderId = folderId;
            //Insert NLS Payment Report in Salesforce
            Database.insert(objDocument,ConstantValues.TRUE_VALUE);

            //Send the email as an attachment
            List<Messaging.EmailFileAttachment> objAttachment=new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
            objMsgEmailAttach.setFileName(reportList[0].Name+ConstantValues.DOT_XLS_STRING);
            if(!Test.isRunningTest()){
                objMsgEmailAttach.setBody(objDocument.Body);
            }else{
                objMsgEmailAttach.setBody(Blob.valueOf(BODY_CONTENT_FOR_TESTING));
            }
            objMsgEmailAttach.setContentType(SET_CONTENT_EXCEL);
            objAttachment.add(objMsgEmailAttach);
            Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
            objEmail.setUseSignature(ConstantValues.FALSE_VALUE);
            objEmail.setToAddresses(new List<String>{ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS});
            if(senderAddress.size() > 0){
                objEmail.setOrgWideEmailAddressId(senderAddress[0].Id);
            }
            objEmail.setSubject(REPORT_EMAIL_SUBJECT);
            objEmail.setHtmlBody(EMAIL_BODY);
            objEmail.setFileAttachments(objAttachment);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objEmail });

            //Query All the Funding transasction that are Not Cleared and are Not posted yet
            List<AggregateResult> nachaPayments = [ SELECT  genesis__Bank_Account__r.clcommon__Routing_Number__c RoutingNumber, 
                                                            genesis__Bank_Account__r.clcommon__Bank_Name__c BankName, 
                                                            genesis__Bank_Account__r.clcommon__Account_Type__c AccountType,
                                                            Grower_Name__c GrowerName, 
                                                            genesis__Application__r.genesis__Loan_Number__c LoanNumber, 
                                                            genesis__Bank_Account__c bankId,
                                                            SUM(genesis__Amount__c) Amount 
                                                    FROM genesis__Funding_Transaction__c 
                                                    WHERE genesis__Payment_Mode__r.Name = :ConstantValues.PAYMENT 
                                                    AND genesis__Cleared__c = :ConstantValues.FALSE_VALUE 
                                                    AND Posted_to_NLS__c = :ConstantValues.FALSE_VALUE 
                                                    AND Status__c != :ConstantValues.VOIDED_STATUS
                                                    GROUP BY genesis__Bank_Account__r.clcommon__Routing_Number__c, 
                                                            Grower_Name__c, 
                                                            genesis__Bank_Account__r.clcommon__Account_Type__c, 
                                                            genesis__Bank_Account__r.clcommon__Bank_Name__c, 
                                                            genesis__Application__r.genesis__Loan_Number__c,
                                                            genesis__Bank_Account__c];

            String finalString = GenerateNachaHelper.getNacha(nachaPayments, new Map<String, String>{
                ConstantValues.FIRST_COLUMN => ROUTING_NUMBER,
                ConstantValues.SECOND_COLUMN => BANK_ID,
                ConstantValues.THIRD_COLUMN => BANK_NAME,
                ConstantValues.FOURTH_COLUMN => ACCOUNT_TYPE,
                ConstantValues.FIFTH_COLUMN => GROWER_NAME,
                ConstantValues.SIXTH_COLUMN => LOAN_NUMBER,
                ConstantValues.SEVENTH_COLUMN => AMOUNT,
                ConstantValues.CSV_HEADER => CSV_COLUMN_HEADER
            });
                                                                                                
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(finalString);

            //Storing the NACHA in salesforce
            Document documentNACHA = new Document();
            documentNACHA.Body = csvBlob;
            documentNACHA.IsPublic = ConstantValues.TRUE_VALUE;
            documentNACHA.Name = ConstantValues.NACHA_RPORT + ConstantValues.SPACE_HYPEN_SPACE_STRING + Datetime.now() + ConstantValues.DOT_XLS_STRING;
            documentNACHA.FolderId = folderId;
            Database.insert(documentNACHA, ConstantValues.TRUE_VALUE);

            csvAttachment.setFileName(CSV_FILE_NAME);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage objNachaEmail =new Messaging.SingleEmailMessage();
            objNachaEmail.setSubject(SUBJECT);
            objNachaEmail.setToAddresses(new List<String>{ConstantValues.PAYMENT_NACHA_EMAIL_ADDRESS});
            objNachaEmail.setPlainTextBody(ConstantValues.CSV_FOR_NACHA);
            objNachaEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});

            if(senderAddress.size() > ConstantValues.ZERO_VALUE){
                objNachaEmail.setOrgWideEmailAddressId(senderAddress[0].Id);
            }
            //Sending NACHA To Loan Accounting      
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {objNachaEmail});

            //update Funding Transactions
            updateFundingTransaction();
        } catch (CustomException objCustomException) {
            // handle Custom Exception
            PortalHelper.saveExceptionLog(objCustomException, GeneratePaymentReportDocument.class.getName());
        } catch (Exception objException) {
            // handle exception
            PortalHelper.saveExceptionLog(objException, GeneratePaymentReportDocument.class.getName());
        }
    }
}