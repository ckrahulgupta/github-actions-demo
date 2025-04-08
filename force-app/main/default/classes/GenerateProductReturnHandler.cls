/**
 * @description       : Generate Product Return Initiated Document
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  :  Pritam Roy
**/
public with sharing class GenerateProductReturnHandler implements Queueable,Database.AllowsCallouts {
    //Constants specific to the class starts
    private static final String GENERATE_REPORT_DOCUMENT_CLASS_NAME = 'GenerateProductReturnHandler';
    private static final String PAGE_REF_URL = '?export=Export&enc=UTF-8&xf=xls&isdtp=p1';
    private static final String ERROR_MESSAGE = 'No report found with the given ID.';
    private static final String SET_CONTENT_EXCEL = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    private static final String BODY_CONTENT_FOR_TESTING = 'Setting Body Content for testing Purpose';
    private static final String EMAIL_BODY = '<br/><br/>Please review the daily reports attached.<br/><br/><br/><br/>';
    private static final String PAGE_REF_URL_DETAILED = '/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=';
    private static final String CSV_COLUMN_HEADER = 'Dealer Routing Number,Dealer Account Number,Dealer Bank Account Name,Dealer Bank Account Type,Dealer Name,Dealer CIF,Total Amount \n';
    private static final String COLUMN_AMOUNT = 'Amount';
    private static final String CSV_FILE_NAME= 'NACHA File.csv';
    private static final String SUBJECT ='NACHA File for Product Return Initiated Payments';
    private static final String CFA_NAME = ConstantValues.CFA_ORGANISATION;
    private static final String LOAN_ACCOUNTING_EMAIL = ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS;
    private static final String NO_ARGUMENTS_ERROR_MESSAGE = 'No Report Id or Folder Id found';
    private static final String REPORT_ID = 'reportID';
    private static final String FOLDER_ID = 'folderID';
    private static final String ROUTING_NUMBER = 'RoutingNumber';
    private static final String BANK_ID = 'bankId';
    private static final String BANK_NAME = 'BankName';
    private static final String ACCOUNT_TYPE = 'AccountType';
    private static final String DEALER_NAME = 'DealerName';
    private static final String CIF_NUMBER = 'CIFNumber';
    private static final String AMOUNT = 'Amount';
    private static final String NACHA_EMAIL_BODY = 'CSV file generated for NACHA';
    private static final Integer GMT_TO_CDT_HOUR_DIFF = -5;
    //Constants specific to the class ends
    private Map<String,Id> typeVsIdMap;
    private Boolean needNacha;
    private String reportEmailSubject;
    /**
     * @description Purpose of this constructor is to check pass the parameters.
     * @param typeVsIdMap 
     * @param needNacha 
     * @param reportEmailSubject
     */
    public GenerateProductReturnHandler(Map<String,Id> typeVsIdMap,Boolean needNacha,String reportEmailSubject){
        this.typeVsIdMap = typeVsIdMap;
        this.needNacha = needNacha;
        this.reportEmailSubject = reportEmailSubject;
    }

    /**
    * @description queue the reports
    * @author  Pritam Roy | 01-15-2024 
    * @param context 
    **/
    public void execute(QueueableContext context){
        createProductReturnDocument(typeVsIdMap,needNacha,reportEmailSubject);
    }
    /**
     * @description To run the report
     * @param reportId
     */
    private static void runReport(Id reportId) {
        Reports.ReportManager.runReport(reportId, true);
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
    private static void checkEmptyVariable(Id objVariable){
        if(objVariable==null){
            throw new CustomException(NO_ARGUMENTS_ERROR_MESSAGE);
        }
    }
    /**
     * @description check for empty arguments
     * @param typeVsIdMap
     */
    private static void checkArguments(Map<String,Id> typeVsIdMap){
        if(typeVsIdMap.containsKey(REPORT_ID)){
            checkEmptyVariable(typeVsIdMap.get(REPORT_ID));
        }
        if(typeVsIdMap.containsKey(FOLDER_ID)){
            checkEmptyVariable(typeVsIdMap.get(FOLDER_ID));
        }
    }
    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Funding_Transaction__c.isAccessible())
                | (!Schema.sObjectType.OrgWideEmailAddress.isAccessible())
                | (!Schema.sObjectType.Report.isAccessible())
                | (!Schema.sObjectType.Document.isCreateable())
                | (!Schema.sObjectType.Folder.isAccessible())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    
    /**
    * @description : Generate and Send Nacha
    * @author  Pritam Roy | 03-07-2024 
    * @param folderId 
    * @param senderAddress 
    **/
    private static void sendNacha(String folderId,List<OrgWideEmailAddress> senderAddress){
        Map<String,String> nachaArgumentsMap = new Map<String,String>();
            //Creating the NACHA File And sending it as an email
            //Query All the Funding transasction that are Not Cleared and are Not posted yet
            List<AggregateResult> nachaPayments = [ SELECT  genesis__Bank_Account__r.clcommon__Routing_Number__c RoutingNumber, 
                                                            genesis__Bank_Account__r.clcommon__Bank_Name__c BankName, 
                                                            genesis__Bank_Account__r.clcommon__Account_Type__c AccountType,
                                                            genesis__Application__r.Dealer_Name__r.Name  DealerName, 
                                                            genesis__Application__r.Dealer_Name__r.CIF_Number__c CIFNumber, 
                                                            genesis__Bank_Account__c bankId,
                                                            SUM(genesis__Amount__c) Amount 
                                                    FROM genesis__Funding_Transaction__c 
                                                    WHERE genesis__Payment_Mode__r.Name =: ConstantValues.PRODUCT_RETURN 
                                                    AND genesis__Cleared__c = false 
                                                    AND Posted_to_NLS__c = false 
                                                    AND Status__c != :ConstantValues.VOIDED_STATUS
                                                    GROUP BY genesis__Bank_Account__r.clcommon__Routing_Number__c, 
                                                            genesis__Application__r.Dealer_Name__r.Name, 
                                                            genesis__Bank_Account__r.clcommon__Account_Type__c, 
                                                            genesis__Bank_Account__r.clcommon__Bank_Name__c, 
                                                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                                                            genesis__Bank_Account__c];

            nachaArgumentsMap.put('FIRST_COLUMN',ROUTING_NUMBER);
            nachaArgumentsMap.put('SECOND_COLUMN',BANK_ID);
            nachaArgumentsMap.put('THIRD_COLUMN',BANK_NAME);
            nachaArgumentsMap.put('FOURTH_COLUMN',ACCOUNT_TYPE);
            nachaArgumentsMap.put('FIFTH_COLUMN',DEALER_NAME);
            nachaArgumentsMap.put('SIXTH_COLUMN',CIF_NUMBER);
            nachaArgumentsMap.put('SEVENTH_COLUMN',AMOUNT);
            nachaArgumentsMap.put('CSV_HEADER',CSV_COLUMN_HEADER);

            String finalString = GenerateNachaHelper.getNacha(nachaPayments,nachaArgumentsMap);
            blob csvBlob = Blob.valueOf(finalString);

            //Storing the nacha report file in Salesforce
            Document documentNACHA = new Document();
            documentNACHA.Body = csvBlob;
            documentNACHA.IsPublic = true;
            documentNACHA.Name = 'NACHA REPORT' + ' - ' + Datetime.now() + '.xls';
            documentNACHA.FolderId = folderId;
            Database.insert(documentNACHA,true);

            //Sending NACHA File
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            csvAttachment.setFileName(CSV_FILE_NAME);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage objNachaEmail =new Messaging.SingleEmailMessage();
            objNachaEmail.setSubject(SUBJECT);
            objNachaEmail.setToAddresses(new List<String>{LOAN_ACCOUNTING_EMAIL});
            objNachaEmail.setPlainTextBody(NACHA_EMAIL_BODY);
            objNachaEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            if(senderAddress.size() > 0){
                objNachaEmail.setOrgWideEmailAddressId(senderAddress[0].Id);
            }      
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {objNachaEmail});
    }
    /**
     * @description To Generate Product Return Document and send it to Loan Accounting
     * @param typeVsIdMap
     * @param needNacha
     * @param reportEmailSubject
     */
    
    public static void createProductReturnDocument(Map<String,Id> typeVsIdMap,Boolean needNacha,String reportEmailSubject) {
        try {
            checkArguments(typeVsIdMap);
            String reportId = typeVsIdMap.get(REPORT_ID);
            String folderId = typeVsIdMap.get(FOLDER_ID);
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
            Database.insert(objDocument,true);

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
            Messaging.SingleEmailMessage objReportEmail = new Messaging.SingleEmailMessage();
            objReportEmail.setUseSignature(false);
            objReportEmail.setToAddresses(new List<String>{LOAN_ACCOUNTING_EMAIL});
            if(senderAddress.size() > 0){
                objReportEmail.setOrgWideEmailAddressId(senderAddress[0].Id);
            }
            objReportEmail.setSubject(reportEmailSubject);
            objReportEmail.setHtmlBody(EMAIL_BODY);
            objReportEmail.setFileAttachments(attachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objReportEmail });

            //Check if Nacha File is Required
            if(!needNacha){
                return;
            }
            //Generate and Send Nacha
            sendNacha(folderId,senderAddress);
            //Update Funding transaction and send email to CL
            GenerateProductReturnHelper.updateFundingTransaction();
        } catch (CustomException objCustomException) {
            // handle Custom Exception
            PortalHelper.saveExceptionLog(objCustomException, GENERATE_REPORT_DOCUMENT_CLASS_NAME);
        } catch (Exception objException) {
            // handle exception
            PortalHelper.saveExceptionLog(objException, GENERATE_REPORT_DOCUMENT_CLASS_NAME);
        }
    }
}