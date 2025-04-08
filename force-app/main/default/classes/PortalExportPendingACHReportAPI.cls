/**
 * @description       : Export Pending ACH in CSV and PDF
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 27-03-2025
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalExportPendingACHReportAPI implements clcommon.PortalCustomRemoteAPI1 {

    private static final String CLASS_NAME = PortalExportPendingACHReportAPI.class.getName();
    private static final String PENDING_ACH_CSV_TABLE_HEADING = 'Grower Name, Loan #, Description, Rate, Amount, Purpose, IRC, Date Entered\n';
    private static final String PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;">';
    private static final String PDF_BODY_START = '<body>';
    private static final String PDF_HEADING_START_END = '<h1 style="font-size: 12pt; text-align: center;">Pending ACH Report</h1>';
    private static final String PDF_TABLE_START = '<table border="1" cellpadding="5" style="font-size: 9.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>Grower Name</th> <th>Loan #</th> <th>Description</th> <th>Rate</th> <th>Amount</th> <th>Purpose</th> <th>IRC</th> <th>Date Entered</th>';

    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td style="padding: 7.5pt 11.25pt">';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_LINE_BREAK = '<br/>';
    private static final String PDF_TABLE_END = '</table>';
    private static final String PDF_BODY_END = '</body>';
    private static final String PDF_HTML_END = '</html>';

    private static final String GROWER_NAME = 'Grower Name';
    private static final String LOAN_NUMBER = 'Loan Number';
    private static final String DESCRIPTION = 'Loan Description';
    private static final String RATE = 'Rate';
    private static final String AMOUNT = 'Amount';
    private static final String PURPOSE = 'Purpose';
    private static final String IRC = 'IRC';
    private static final String DATE_ENTERED = 'Date Entered';
    private static final String PERCENT_SIGN = ' %';
    private static final String DOLLAR_SIGN = '$ ';
    private static final String BATCH_TOTAL = 'Batch Total: $';


    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    Decimal batchTotal = 0;
    


    /**
    * @description 
    * @author Suraj Kumar | 10-13-2023 
    * @param exportFundingTrnsnObjList 
    **/
    public void exportPDFReport(List<Map<String,Object>> exportFundingTrnsnObjList){
        String pdfReport = PortalConstants.EMPTY_STRING;
        String tableData = PDF_TABLE_START;
        String tableRow = PortalConstants.EMPTY_STRING;
        String addBatchTotal = BATCH_TOTAL + String.valueOf(batchTotal);

        for(Map<String,Object> fundingTransactionObj: exportFundingTrnsnObjList){
            String crDate = PortalReportsHelper.getFormattedDate(fundingTransactionObj.get(DATE_ENTERED));

            tableRow = PDF_HTML_TR_START;
            tableRow += PortalReportsHelper.createPDFTableRow(fundingTransactionObj.get(GROWER_NAME))
                        + PortalReportsHelper.createPDFTableRow(fundingTransactionObj.get(LOAN_NUMBER))
                        + PortalReportsHelper.createPDFTableRow(fundingTransactionObj.get(DESCRIPTION))
                        + PortalReportsHelper.createPDFTableRow(fundingTransactionObj.get(RATE) + PERCENT_SIGN)
                        + PortalReportsHelper.createPDFTableRow(DOLLAR_SIGN + fundingTransactionObj.get(AMOUNT))
                        + PortalReportsHelper.createPDFTableRow(fundingTransactionObj.get(PURPOSE))
                        + PortalReportsHelper.createPDFTableRow(fundingTransactionObj.get(IRC))
                        + PortalReportsHelper.createPDFTableRow(crDate);
            
            tableRow += PDF_HTML_TR_END;
            tableData += tableRow;  
        }
        tableData += PDF_TABLE_END;
        pdfReport += PDF_HTML_START + PDF_BODY_START + PDF_HEADING_START_END  + PDF_HTML_LINE_BREAK + addBatchTotal + PDF_HTML_LINE_BREAK + PDF_HTML_LINE_BREAK + tableData + PDF_BODY_END + PDF_HTML_END;
        responseFieldMap.put(PortalConstants.KEY_PDF, EncodingUtil.base64Encode(Blob.toPdf(pdfReport)));
    }
    

    /**
    * @description 
    * @author Suraj Kumar | 10-12-2023 
    * @param exportFundingTrnsnObjList 
    **/
    public void exportCSVReport(List<Map<String,Object>> exportFundingTrnsnObjList){
        String tableData = PENDING_ACH_CSV_TABLE_HEADING;
        String tableRow = PortalConstants.EMPTY_STRING;
        String addBatchTotal = BATCH_TOTAL + String.valueOf(batchTotal) + PortalConstants.NEWLINE_STRING;
        String csvReport = PortalConstants.EMPTY_STRING;
        for(Map<String,Object> fundingTransactionObj: exportFundingTrnsnObjList){
            String crDate = PortalReportsHelper.getFormattedDate(fundingTransactionObj.get(DATE_ENTERED));

            tableRow = PortalReportsHelper.createCSVTableRow(fundingTransactionObj.get(GROWER_NAME))
                        + PortalReportsHelper.createCSVTableRow(fundingTransactionObj.get(LOAN_NUMBER))
                        + PortalReportsHelper.createCSVTableRow(fundingTransactionObj.get(DESCRIPTION))
                        + PortalReportsHelper.createCSVTableRow(fundingTransactionObj.get(RATE) + PERCENT_SIGN)
                        + PortalReportsHelper.createCSVTableRow(DOLLAR_SIGN + fundingTransactionObj.get(AMOUNT))
                        + PortalReportsHelper.createCSVTableRow(fundingTransactionObj.get(PURPOSE))
                        + PortalReportsHelper.createCSVTableRow(fundingTransactionObj.get(IRC))
                        + PortalReportsHelper.createCSVTableRow(crDate);
                        
            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + PortalConstants.NEWLINE_STRING;
        }
        csvReport = addBatchTotal + tableData;
        responseFieldMap.put(PortalConstants.KEY_CSV.toLowerCase(), EncodingUtil.base64Encode(Blob.valueOf(csvReport)));
    }

    /**
    * @description 
    * @author Suraj Kumar | 10-12-2023 
    * @param exportType 
    **/
    public void exportPendingACHReport(String exportType){
        
        String loggedInAccountId = PortalReportsHelper.getDealerAccountId();
        Map<String, Object> fundingTransactionObjMap  = null;
        List<Map<String,Object>> exportFundingTrnsnObjList = new List<Map<String,Object>>();
        List<genesis__Funding_Transaction__c> fundingTransactionObjList = [SELECT Id, 
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Application__r.Internal_Reference_Code__c,
                                                                                Loan_Number__c, 
                                                                                Loan_Description__c, 
                                                                                Pricing_Detail__r.genesis__Interest_Rate__c, 
                                                                                genesis__Amount__c, 
                                                                                genesis__Reference__c, 
                                                                                CreatedDate 
                                                                            FROM genesis__Funding_Transaction__c 
                                                                            WHERE genesis__Application__r.Dealer_Name__c = :loggedInAccountId
                                                                            AND genesis__Payment_Mode__r.Name = :ConstantValues.ACH
                                                                            AND genesis__Cleared__c = false
                                                                            AND Posted_to_NLS__c = false ];
        for (genesis__Funding_Transaction__c fundingTransactionObj : fundingTransactionObjList) {
            fundingTransactionObjMap = new Map<String, Object>();

            fundingTransactionObjMap.put(GROWER_NAME, fundingTransactionObj.genesis__Application__r.genesis__Account__r.Name);
            fundingTransactionObjMap.put(LOAN_NUMBER, fundingTransactionObj.Loan_Number__c);
            fundingTransactionObjMap.put(DESCRIPTION, fundingTransactionObj.Loan_Description__c);
            fundingTransactionObjMap.put(RATE, fundingTransactionObj.Pricing_Detail__r.genesis__Interest_Rate__c);
            fundingTransactionObjMap.put(AMOUNT, fundingTransactionObj.genesis__Amount__c);
            fundingTransactionObjMap.put(PURPOSE, fundingTransactionObj.genesis__Reference__c);
            fundingTransactionObjMap.put(IRC, fundingTransactionObj.genesis__Application__r.Internal_Reference_Code__c);
            fundingTransactionObjMap.put(DATE_ENTERED, fundingTransactionObj.CreatedDate);

            exportFundingTrnsnObjList.add(fundingTransactionObjMap);

            batchTotal += (Decimal)fundingTransactionObj.genesis__Amount__c;
        }

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(exportFundingTrnsnObjList);
        batchTotal.setScale(2);

        if(exportType.equalsIgnoreCase(PortalConstants.KEY_CSV) ){
            exportCSVReport(exportFundingTrnsnObjList);
        }
        else if(exportType.equalsIgnoreCase(PortalConstants.KEY_PDF)){
            exportPDFReport(exportFundingTrnsnObjList);
        }

    }

    /**
    * @description 
    * @author Suraj Kumar | 10-12-2023 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> request) {
        try{
            PortalLoanServicingHelper.checkRequestParam(request, PortalConstants.KEY_EXPORT_TYPE);
            PortalLoanServicingHelper.checkRequestBody(request, PortalConstants.KEY_EXPORT_TYPE);
            String exportType = String.valueOf(request.get(PortalConstants.KEY_EXPORT_TYPE));
            LoanServicingHelper.checkEmptyString(exportType, PortalConstants.REQUIRED_PARAMETERS_MISSING);
            exportPendingACHReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
        } catch (CustomException objCustomException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
}