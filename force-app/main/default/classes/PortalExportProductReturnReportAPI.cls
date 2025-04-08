/**
 * @description       : This class is used for Exporting the Product Return Summary report in Dealer Portal.
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Rahul Gorai
**/
global without sharing class PortalExportProductReturnReportAPI implements clcommon.PortalCustomRemoteAPI1{

    private final String CLASSNAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';

    private static final PortalFetchProductReturnSummaryReportAPI OBJ_PRODUCT_RETURN_REPORTS_API = new PortalFetchProductReturnSummaryReportAPI();
    private static final Map<String, String> CSV_HEADING_MAP = new Map<String, String>{
        PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT => 'GROWER NAME, LOAN #, DESCRIPTION, CROP YEAR, AMOUNT, PURPOSE, DATE ENTERED, ENTERED BY,UNIQUE IDENTIFIER\n'
    };
    private static final Map<String, String> PDF_TABLE_HEADING_MAP = new Map<String, String>{
        PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>GROWER NAME</th> <th>LOAN #</th> <th>DESCRIPTION</th> <th>CROP YEAR</th> <th>AMOUNT</th> <th>PURPOSE</th> <th>UNIQUE IDENTIFIER</th></tr>'
    };
    private static final String PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><head></head><body> <h1 align="center" style="font-size: 15pt;">';
    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_TD_START = '<td>';
    private static final String PDF_HTML_TD_END = '</td>';

    /**
     * @description : This method takes the portal request and process it.
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {

        SavePoint dbSavePoint = Database.setSavepoint();

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();
        Map<String, String> requestDataMap = new Map<String, String>();

        try{
            if(request.get(PortalConstants.KEY_REPORT_TYPE) == null || request.get(PortalConstants.KEY_EXPORT_TYPE) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            requestDataMap.put(PortalConstants.KEY_REPORT_FILTER, (String) request.get(PortalConstants.KEY_REPORT_FILTER));
            requestDataMap.put(PortalConstants.KEY_EXPORT_TYPE, (String) request.get(PortalConstants.KEY_EXPORT_TYPE));
            requestDataMap.put(PortalConstants.KEY_REPORT_TYPE, (String) request.get(PortalConstants.KEY_REPORT_TYPE));
            requestDataMap.put(PortalConstants.KEY_FROM_DATE, (String) request.get(PortalConstants.KEY_FROM_DATE));
            requestDataMap.put(PortalConstants.KEY_TO_DATE, (String) request.get(PortalConstants.KEY_TO_DATE));
            requestDataMap.put(PortalConstants.KEY_SEARCH_FILTER, (String) request.get(PortalConstants.KEY_SEARCH_FILTER));
    
            if(String.valueOf(request.get(PortalConstants.KEY_REPORT_TYPE)).equals(PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT)){
                responseData = exportFilteredReports(requestDataMap);
            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 

        }catch(Exception objException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
            PortalHelper.saveExceptionLog(objException, CLASSNAME);
        }
        return response;
    }

    /**
     * @description : This method takes the filter from request parameter and Export the Product Return Report based on the filter value.
     * @param requestDataMap 
     * @return  `List<clcommon.PortalCustomRemoteActionRecord>`
     */
    List<clcommon.PortalCustomRemoteActionRecord> exportFilteredReports(Map<String, String> requestDataMap){

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String, Object> resultMap = new Map<String, Object>();

        if(requestDataMap.get(PortalConstants.KEY_REPORT_TYPE).equals(PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT)){
            resultMap = exportProductReturnSummaryReport(requestDataMap);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap));
        }
        return responseData;
    }

    /**
     * @description : This method is used for Exporting the Product Return Report without filter.
     * @param requestDataMap 
     * @return  `Map<String, Object>`
     * @exception 
     */
    private Map<String, Object> exportProductReturnSummaryReport(Map<String, String> requestDataMap){

        String exportType  = requestDataMap.get(PortalConstants.KEY_EXPORT_TYPE);

        Map<String, Object> resultMap = new Map<String, Object>();
        List<Map<String, Object>> resultList = OBJ_PRODUCT_RETURN_REPORTS_API.getProductReturnSummaryReport(requestDataMap);

        if (resultList.isEmpty()) {
            throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
        }
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT);
            tableData+=PortalReportsHelper.createTableForProductReturnSummaryReport(resultList);

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }
        else if(exportType.equals(PDF_VALUE)){

            String tableData;
            String tableRow = '';
    
            tableData = PDF_HTML_START + PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT + PDF_TABLE_HEADING_MAP.get(PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT);

            // looping through the result map the pdf table from the application data
            for (Map<String, Object> result : resultList) {

                tableRow = PDF_HTML_TR_START;
                tableRow = createPDFTableRow(result.get('grower_name'))
                                    + createPDFTableRow(result.get('loan_number'))
                                    + createPDFTableRow(result.get('description'))
                                    + createPDFTableRow(result.get('crop_year'))
                                    + createPDFTableRow(result.get('amount'))
                                    + createPDFTableRow(result.get('purpose'))
                                    + createPDFTableRow(result.get('created_date'))
                                    + createPDFTableRow(result.get('created_by'));
                                    + createPDFTableRow(result.get('unique_identifier'));
    
                tableRow += PDF_HTML_TR_END;
                tableData += tableRow;
            }
            tableData += PDF_HTML_END;
    
            // converting html string to pdf blob and returning
            resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));

        }
        return resultMap;
    }

    /**
     * @description : This method creates the table row for PDF export.
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
}