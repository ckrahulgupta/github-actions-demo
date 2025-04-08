/**
 * @description       : This class Export CSV and PDF for all transactions
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 04-03-2024
 **/
global without sharing class PortalExportAllTransactionsAPI implements clcommon.PortalCustomRemoteAPI1 {

    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';
    private static final String TRANSCTIONS = 'transactions';

    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PORTAL_EXPORT_API = 'PortalExportAllTransactionsAPI';

    private static final String TRANSAC_CSV_TABLE_HEADING = 'GROWER NAME, DESCRIPTION, RATE, LOAN NUMBER, AMOUNT, TRANSACTION TYPE, PURPOSE, DATE ENTERED, STATUS\n';
    private static final String TRANSAC_PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><body> <h1 style="font-size: 15pt;">Transactions</h1> <table border="1" cellpadding="5" style="font-size: 6.6pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold; font-size: 6.6pt;"> <th>GROWER NAME</th> <th>DESCRIPTION</th> <th>RATE</th> <th>LOAN NUMBER</th> <th>AMOUNT</th> <th>TRANSACTION TYPE</th> <th>PURPOSE</th> <th>DATE ENTERED</th> <th>STATUS</th>';

    private static Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();


    /**
    * @description - This method is used to export CSV and PDF
    * @author Sk Minsar | 03-18-2024 
    * @param exportType 
    * @param transactionList 
    **/
    private static void exportTransaction(String exportType, List<Map<String,Object>> transactionList){
        if(exportType.equals(CSV_VALUE)){
            String tableData = TRANSAC_CSV_TABLE_HEADING;
            String tableRow = '';
            for(Map<String,Object> transactionMap : transactionList){
                List<String> dateParts = ((String)transactionMap.get(PortalConstants.KEY_CREATED_DATE)).split(ConstantValues.HYPHEN_STRING);
                String setDate = dateParts[1] + ConstantValues.HYPHEN_STRING + dateParts[2] + ConstantValues.HYPHEN_STRING + dateParts[0];
                
                tableRow = PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_GROWER_NAME)))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_DESCRIPTION)))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_RATE)))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_LAON_NUMBER)))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_AMOUNT)))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_TRANSACTION_TYPE)))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_PURPOSE)))
                                + PortalReportsHelper.createCSVTableRow(setDate)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_STATUS)));

                tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + PortalConstants.NEWLINE_STRING;  
            }
            responseFieldMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
            return;

        }
        else if(exportType.equals(PDF_VALUE)){
            String tableData = TRANSAC_PDF_HTML_START;
            String tableRow = '';
            for(Map<String,Object> transactionMap : transactionList){
                List<String> dateParts = ((String)transactionMap.get(PortalConstants.KEY_CREATED_DATE)).split(ConstantValues.HYPHEN_STRING);
                String setDate = dateParts[1]+ ConstantValues.HYPHEN_STRING + dateParts[2] + ConstantValues.HYPHEN_STRING + dateParts[0];
                tableRow = PDF_HTML_TR_START;
                tableRow += + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_GROWER_NAME)))
                                + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_DESCRIPTION)))
                                + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_RATE)))
                                + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_LAON_NUMBER)))
                                + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_AMOUNT)))
                                + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_TRANSACTION_TYPE)))
                                + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_PURPOSE)))
                                + PortalReportsHelper.createPDFTableRow(setDate)
                                + PortalReportsHelper.createPDFTableRow(PortalReportsHelper.getString(transactionMap.get(PortalConstants.KEY_STATUS)));
                tableRow += PDF_HTML_TR_END;
                tableData += tableRow;   
            }
            tableData += PDF_HTML_END;
            responseFieldMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
            return;

        } 
    }



    /**
    * @description - This method helps to call the export Transactions
    * @author Sk Minsar | 03-18-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames, Map<String, Object> request){
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            if (String.isBlank((String) request.get(PortalConstants.KEY_EXPORT_TYPE))) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            String exportType = String.valueOf(request.get(PortalConstants.KEY_EXPORT_TYPE));
            
            if(request.get(TRANSCTIONS) == null){
                throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
            }
            List<Object> transactionInfoList = (List<Object>)Json.deserializeUntyped(String.valueOf(request.get(TRANSCTIONS)));
            PortalApplicationOriginationHelper.checkEmptyList(transactionInfoList, PortalConstants.NO_DATA_TO_EXPORT);
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