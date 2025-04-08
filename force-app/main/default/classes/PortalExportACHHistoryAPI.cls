/**
 * @description       : Export ACH history in CSV and PDF
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Tuhin Bhunia
**/
global without sharing class PortalExportACHHistoryAPI implements clcommon.PortalCustomRemoteAPI1 {
    private static final String KEY_EXPORT_TYPE = 'exportType';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';
    private static final String COMMA_STRING = ', ';


    private static final String ACH_HISTORY_CSV_TABLE_HEADING = 'DATE, TYPE, BATCH TOTAL AMOUNT, STATUS\n';
    private static final String ACH_HISTORY_PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><body> <h1 style="font-size: 15pt;">Transactions</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>DATE</th> <th>TYPE</th> <th> BATCH TOTAL AMOUNT</th> <th>STATUS</th>';

    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td style="padding: 7.5pt 11.25pt">';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PORTAL_EXPORT_API = 'PortalExportAPI';

    private static final String QUERY_KEY_BATCH_NAME = 'Name';
    private static final String QUERY_KEY_BATCH_STATUS = 'Status__c';
    private static final String QUERY_KEY_BATCH_RECORDED_DATE = 'Recorded_Date__c';
    private static final String QUERY_KEY_BATCH_TOTAL_AMOUNT = 'expr1';
    private static final String QUERY_KEY_BATCH_ID = 'Batch__c';
    private static final String KEY_BATCH_ID = 'batch_id';
    private static final String KEY_BATCH_NAME = 'batch_name';
    private static final String KEY_BATCH_DATE = 'batch_date';
    private static final String KEY_BATCH_TOTAL_AMOUNT = 'total_amount';
    private static final String KEY_BATCH_STATUS = 'batch_status';


    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    /**
     * @description : This method is used to fetch dealer Account Id from the logged in user
     * @return  `String`
     * @exception 
     */
    public String getDealerAccountId() {
        List<User> dealerAccountId = [SELECT Account.ParentId
                                                FROM User 
                                                WHERE Id = :UserInfo.getUserId()
                                                LIMIT 1];
        if (dealerAccountId.size() == 1) {
            return dealerAccountId[0].Account.ParentId;
        } else {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }

    /**
     * @description : Purpose of this method is to create table Row for CSV export
     * @param cellData 
     * @return  `String`
     */
    private static String createCSVTableRow(Object cellData) {
        String cellString = (cellData == null) ? 
                        COMMA_STRING : 
                        String.valueOf(cellData) + COMMA_STRING;

        return cellString;
    }

    /**
     * @description : Purpose of this method is to create table Row for PDF export
     * @param cellData 
     * @return  `String`
     */
    private static String createPDFTableRow(Object cellData) {
        String cellString = (cellData == null) ? 
                        PDF_HTML_TD_START_END : 
                        PDF_HTML_TD_START 
                            + String.valueOf(cellData) 
                            + PDF_HTML_TD_END;
        return cellString;
    }

    /**
     * @description : This method creates the table for CSV export
     * @param objExportFundingTransactionList 
     */
    private void processCSV(List<Map<String,Object>> objExportFundingTransactionList) {
        String tableData = ACH_HISTORY_CSV_TABLE_HEADING;
        String tableRow = '';

        for(Map<String,Object> objFundingTransaction : objExportFundingTransactionList){
            String setName = null;
            String crDate = null;
            if(objFundingTransaction.get(KEY_BATCH_NAME) != null){
                setName = String.valueof(objFundingTransaction.get(KEY_BATCH_NAME)).replace(',', '');
            }
            if(objFundingTransaction.get(KEY_BATCH_DATE) != null){
                Datetime subcrDate = (Datetime)(objFundingTransaction.get(KEY_BATCH_DATE));
                crDate = String.valueOf(date.newInstance(subcrDate.yearGmt(), subcrDate.monthGmt(), subcrDate.dayGmt()));
            }
            tableRow = createCSVTableRow(crDate)
                        + createCSVTableRow(setName)
                        + createCSVTableRow(objFundingTransaction.get(KEY_BATCH_TOTAL_AMOUNT))
                        + createCSVTableRow(objFundingTransaction.get(KEY_BATCH_STATUS));

            tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
        }

        responseFieldMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
    }

    /**
     * @description : This method is used to create the Table for PDF export
     * @param objExportFundingTransactionList 
     */
    private void processPDF(List<Map<String,Object>> objExportFundingTransactionList) {
        String tableData = ACH_HISTORY_PDF_HTML_START;
        String tableRow = '';
        for(Map<String,Object> objFundingTransaction : objExportFundingTransactionList){
            String setName = null;
            String crDate = null;
            if(objFundingTransaction.get(KEY_BATCH_NAME) != null){
                setName = String.valueof(objFundingTransaction.get(KEY_BATCH_NAME)).replace(',', '');
            }
            if(objFundingTransaction.get(KEY_BATCH_DATE) != null){
                Datetime subcrDate = (Datetime)(objFundingTransaction.get(KEY_BATCH_DATE));
                crDate = String.valueOf(date.newInstance(subcrDate.yearGmt(), subcrDate.monthGmt(), subcrDate.dayGmt()));
            }
            tableRow = createPDFTableRow(crDate)
                        + createPDFTableRow(setName)
                        + createPDFTableRow(objFundingTransaction.get(KEY_BATCH_TOTAL_AMOUNT))
                        + createPDFTableRow(objFundingTransaction.get(KEY_BATCH_STATUS));
                        
            tableRow += PDF_HTML_TR_END;
            tableData += tableRow;           
        }
        tableData += PDF_HTML_END;

        responseFieldMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
    }

    /**
     * @description : This method takes the export type and exports the document
     * @param exportType 
     * @exception 
     */
    private void exportACH(String exportType) {
        List<AggregateResult> objFundingTransactionList;
        String loggedInAccountId = getDealerAccountId();

        List<AggregateResult> objFundingTransactionAggregateResultList = [SELECT Count(Id), 
                                                                                     SUM(genesis__Amount__c),
                                                                                     Batch__c,
                                                                                     Batch__r.Name,
                                                                                     Batch__r.Status__c,
                                                                                     Batch__r.Recorded_Date__c
                                                                              FROM genesis__Funding_Transaction__c 
                                                                              WHERE genesis__Application__r.Dealer_Name__c = :loggedInAccountId
                                                                              AND Batch__c != ''
                                                                              AND genesis__Payment_Mode__r.Name = :ConstantValues.ACH
                                                                              GROUP BY Batch__c, 
                                                                                       Batch__r.Name, 
                                                                                       Batch__r.Status__c,
                                                                                       Batch__r.Recorded_Date__c
                                                                              HAVING SUM(genesis__Amount__c) > 0];

                                                                               
        Map<String, Object> objFundingTransactionMap  =null;
        List<Map<String,Object>>objExportFundingTransactionList = new List<Map<String,Object>>();

        for (AggregateResult objFundingTransactionAggregateResult : objFundingTransactionAggregateResultList) {
                objFundingTransactionMap = new Map<String, Object>();

                objFundingTransactionMap.put(KEY_BATCH_TOTAL_AMOUNT, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_TOTAL_AMOUNT));
                objFundingTransactionMap.put(KEY_BATCH_ID, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_ID));
                objFundingTransactionMap.put(KEY_BATCH_NAME, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_NAME));
                objFundingTransactionMap.put(KEY_BATCH_STATUS, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_STATUS));
                objFundingTransactionMap.put(KEY_BATCH_DATE, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_RECORDED_DATE));

                objExportFundingTransactionList.add(objFundingTransactionMap);
        }    

       

        if (objExportFundingTransactionList.size() == 0) {
            throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
        }

        
        if(exportType.equals(CSV_VALUE) ){
            
            processCSV(objExportFundingTransactionList);
            return;
        }
        else if(exportType.equals(PDF_VALUE)){
            

            processPDF(objExportFundingTransactionList);

            return;
        }
    }

    /**
     * @description : This method takes request parameters from portal and process the Export functionality based on the request parameters.
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            if (String.isBlank((String) request.get(KEY_EXPORT_TYPE))){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            String exportType = String.valueOf(request.get(KEY_EXPORT_TYPE));

            exportACH(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
        }
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, PORTAL_EXPORT_API);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PORTAL_EXPORT_API);
        }
        return response;


    }

  
}