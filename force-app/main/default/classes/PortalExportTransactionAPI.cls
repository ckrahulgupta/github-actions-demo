/**
 * @description       : This class export the csv and pdf for transactions 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Tuhin Bhunia
**/

global without sharing class PortalExportTransactionAPI implements clcommon.PortalCustomRemoteAPI1 {

    private static final String KEY_EXPORT_TYPE = 'exportType';
    private static final String SINGLE_QUOTE_STRING = '\'';
    private static final String COMMA_STRING = ', ';
    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';
    private static final String TRANSCTIONS = 'transactions';

    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td style="padding: 7.5pt 11.25pt">';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PORTAL_EXPORT_API = 'PortalExportAPI';

    private static final String TRANSAC_CSV_TABLE_HEADING = 'TRANSACTION DATE, TRANSACTION AMOUNT, DESCRIPTION, USER REFERENCE\n';
    private static final String TRANSAC_PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><body> <h1 style="font-size: 15pt;">Transactions</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>TRANSACTION DATE</th> <th>TRANSACTION AMOUNT</th> <th> DESCRIPTION</th> <th>USER REFERENCE</th>';

    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    /**
     * @description : This method creates the table-row for export type CSV.
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
     * @description : This method creates the table-row for export type PDF
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
     * @description : This method takes a list of transactions and export into the given format.
     * @param exportType 
     * @param transactionList 
     */
    private void exportTransaction(String exportType, List<Map<String,Object>> transactionList){
        if(exportType.equals(CSV_VALUE)){
            String tableData = TRANSAC_CSV_TABLE_HEADING;
            String tableRow = '';
            String setDescription = null;
            String userReference = null;
            
            
            for(Map<String,Object> transactionMap : transactionList){
                String dateStr =String.valueOf(transactionMap.get('Transaction_Date'));
                Date dateVal = date.valueOf(datestr);
                String setDate = dateVal.month()+ '-'+ dateVal.day()+ '-'+dateVal.year();
                if(transactionMap.get('Transaction_Description')!= null){
                    setDescription = String.valueOf(transactionMap.get('Transaction_Description')).replace(',', '');
                }
                if(transactionMap.get('User_Reference')!= null){
                    userReference = String.valueOf(transactionMap.get('User_Reference')).replace(',', '');
                }
                tableRow = createCSVTableRow(setDate)
                                + createCSVTableRow(transactionMap.get('Transaction_Amount'))
                                + createCSVTableRow(setDescription)
                                + createCSVTableRow(userReference);

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';  
            }
            responseFieldMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
            return;

        }
        else if(exportType.equals(PDF_VALUE)){
            String tableData = TRANSAC_PDF_HTML_START;
            String tableRow = '';
            for(Map<String,Object> transactionMap : transactionList){
                String dateStr =String.valueOf(transactionMap.get('Transaction_Date'));
                Date dateVal = date.valueOf(datestr);
                String setDate = dateVal.month()+ '-'+ dateVal.day()+ '-'+dateVal.year();
                tableRow = PDF_HTML_TR_START;
                tableRow += createPDFTableRow(setDate)
                                + createPDFTableRow(transactionMap.get('Transaction_Amount'))
                                + createPDFTableRow(transactionMap.get('Transaction_Description'))
                                + createPDFTableRow(transactionMap.get('User_Reference'));
                tableRow += PDF_HTML_TR_END;
                tableData += tableRow;   
            }
            tableData += PDF_HTML_END;
            responseFieldMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
            return;

        } 
    }

    /**
     * @description : This method takes and validates the Portal Request and Performs the Export Functionality.
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames, Map<String, Object> request){
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            if (String.isBlank((String) request.get(KEY_EXPORT_TYPE))) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            String exportType = String.valueOf(request.get('exportType'));

            if(request.get(TRANSCTIONS) == null){
                throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
            }
            List<Object> transactionInfoList = (List<Object>)Json.deserializeUntyped(String.valueOf(request.get(TRANSCTIONS)));
            List<Map<String,Object>> transactionList = new List<Map<String,Object>>();

            for(Object transactionInfo : transactionInfoList){
                Map<String,Object> mapOfTransactionInfo = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(transactionInfo));
                transactionList.add(mapOfTransactionInfo);
            }

            exportTransaction(exportType,transactionList);
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