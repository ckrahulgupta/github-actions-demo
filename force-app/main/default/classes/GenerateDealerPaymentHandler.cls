/**
 * @description       : Generate Dealer Online Payment Initiated Document
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 05-10-23
 * @last modified by  : Pritam
**/
public with sharing class GenerateDealerPaymentHandler {
    //Constants specific to the class
    private static final String GENERATE_REPORT_DOCUMENT_CLASS_NAME = 'GenerateDealerPaymentHandler';
    private static final String PAGE_REF_URL = '?export=Export&enc=UTF-8&xf=xls&isdtp=p1';
    private static final String ERROR_MESSAGE = 'No report found with the given ID.';
    private static final String SET_CONTENT_EXCEL = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    private static final String SET_CONTENT_PDF = 'application/pdf';
    private static final String BODY_CONTENT_FOR_TESTING = 'Setting Body Content for testing Purpose';
    private static final String EMAIL_TEMPLATE_NAME = 'Payment Reporting Email Template';
    private static final String EMAIL_BODY = '<br/><br/>Please review the daily reports attached.<br/><br/><br/><br/>';
    private static final String PAGE_REF_URL_DETAILED = '/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=';
    private static final String CFA_NAME = ConstantValues.CFA_ORGANISATION;
    private static final String REPORT_SUBJECT_ERROR = 'No Report Subject Found';
    private static final String LOAN_ACCOUNTING_EMAIL = ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS;
    //Constants specific to the class

    /**
     * @description To run the report
     * @param reportId
     */
    private static void runReport(Id reportId) {
        Reports.ReportResults reportResults = Reports.ReportManager.runReport(reportId, true);
    }
    /**
     * @description To get the report content
     * @param reportId
     * @return `Blob`
     */
    private static Blob getReportContent(Id reportId) {
        //To Export CSV in a formatted way
        return (new ApexPages.PageReference(PAGE_REF_URL_DETAILED + reportId)).getContent();
    }
    /**
     * @description check for empty list
     * @param objList
     */
    private static void checkEmptyList(List<Object> objList){
        if(objList.isEmpty()){
            throw new CustomException(ERROR_MESSAGE);
        }
    }
    /**
     * @description check for empty variable
     * @param objVariable
     */
    private static void checkEmptyVariable(Object objVariable){
        if(objVariable==null){
            throw new CustomException(REPORT_SUBJECT_ERROR);
        }
    }
    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.Document.isCreateable()) 
                | (!Schema.sObjectType.OrgWideEmailAddress.isAccessible())
                | (!Schema.sObjectType.Report.isAccessible())
                | (!Schema.sObjectType.Folder.isAccessible())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
     * @description To Generate Dealer Online Payment Document and Send it To Loan Accounting
     * @param reportId
     * @param folderId
     * @param reportEmailSubject
     */
    public static void createDealerPaymentDocument(Id reportId, Id folderId,String reportEmailSubject) {
        try {
            checkAccessOnObjects();
            //Get Senders Address
            List<OrgWideEmailAddress> senderAddress = [SELECT Id,
                                                            Address, 
                                                            DisplayName 
                                                        FROM  OrgWideEmailAddress 
                                                        WHERE DisplayName = :CFA_NAME];
            //Get Report Name
            List<Report> reportList = [ SELECT  Id, 
                                                Name 
                                        FROM Report 
                                        WHERE Id = :reportId 
                                        LIMIT 1];
            //Get Folder Name
            List<Folder> folderList = [ SELECT  Id, 
                                                Name 
                                        FROM Folder 
                                        WHERE Id = :folderId 
                                        LIMIT 1];
            checkEmptyList(reportList);
            checkEmptyList(folderList);
            checkEmptyVariable(reportEmailSubject);
            //Run report
            runReport(reportId);
            
            //Insert Document in Salesforce
            Document objDocument = new Document();
            if(!Test.isRunningTest()){
                objDocument.Body = getReportContent(reportId);
            }
            objDocument.IsPublic = true;
            objDocument.Name = reportList[0].Name + ' - ' + Datetime.now() + '.xls';
            objDocument.FolderId = folderId;
            Database.insert(objDocument, true);

            //Send email with report as an attachment
            List<Messaging.EmailFileAttachment> attachments=new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
            objMsgEmailAttach.setFileName(reportList[0].Name+'.xls');
            if(!Test.isRunningTest()){
                objMsgEmailAttach.setBody(objDocument.Body);
            }else{
                objMsgEmailAttach.setBody(Blob.valueOf(BODY_CONTENT_FOR_TESTING));
            }
            objMsgEmailAttach.setContentType(SET_CONTENT_EXCEL);
            attachments.add(objMsgEmailAttach);
            Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
            objEmail.setUseSignature(false);
            objEmail.setToAddresses(new List<String>{LOAN_ACCOUNTING_EMAIL});
            if(senderAddress.size() > 0){
                objEmail.setOrgWideEmailAddressId(senderAddress[0].Id);
            }
            objEmail.setSubject(reportEmailSubject);
            objEmail.setHtmlBody(EMAIL_BODY);
            objEmail.setFileAttachments(attachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objEmail });
        }catch(CustomException objCustomException) {
            // handle Custom Exception
            PortalHelper.saveExceptionLog(objCustomException, GENERATE_REPORT_DOCUMENT_CLASS_NAME);
        }catch(Exception objException){
            // handle exception
            PortalHelper.saveExceptionLog(objException, GENERATE_REPORT_DOCUMENT_CLASS_NAME);
        }
    }
}