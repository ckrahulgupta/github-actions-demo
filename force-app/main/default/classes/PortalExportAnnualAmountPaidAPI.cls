/**
 * @description       : This class is used to export the amount paid per year
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing  class PortalExportAnnualAmountPaidAPI implements clcommon.PortalCustomRemoteAPI1{
    private static final String KEY_EXPORT_TYPE = 'exportType';
    private static final String SINGLE_QUOTE_STRING = '\'';
    private static final String COMMA_STRING = ', ';
    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';
    private static final String PARENT_LOAN_LIST = 'parentLoanList';
    private static final String CHILD_LOAN_LIST = 'childLoanList';
    private static final String KEY_APP_ID = 'applicationId';

    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td style="padding: 7.5pt 11.25pt">';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PORTAL_EXPORT_API = 'PortalExportAnnualAmountPaidAPI';
    private static final String PARENT_CALENDAR_YEAR = 'parent_calendar_year';
    private static final String PARENT_LOAN_NUMBER = 'parent_loan_number';
    private static final String PARENT_INTEREST_PAID = 'parent_total_interest_paid';
    private static final String PARENT_INTEREST_ACCRUED = 'parent_total_interest_accrued';
    private static final String CHILD_INTEREST_ACCRUED = 'child_total_interest_accrued';
    private static final String CHILD_LOAN_DESCRIPTION = 'child_loan_description';
    private static final String CHILD_CALENDAR_YEAR = 'calendar_year';
    private static final String CHILD_LOAN_NUMBER = 'child_loan_number';
    private static final String CHILD_INTEREST_PAID = 'child_total_interest_paid';
    private static final String DOLLAR = '$ ';
    private static final String HEADING = 'Annual Interest';
    private static final String PDF_HEADING = 'Annual Interest For #';


    private static final String TRANSAC_CSV_TABLE_HEADING = 'CALENDAR YEAR, LOAN NUMBER, SUB-TRANCHE, LOAN DESCRIPTION, TOTAL INTEREST PAID, TOTAL INTEREST ACCRUED\n';
    private static final String TRANSAC_PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><body> <h1 style="font-size: 15pt;">Annual Interest</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>CALENDAR YEAR</th> <th>LOAN NUMBER</th> <th> SUB-TRANCHE</th> <th> LOAN DESCRIPTION</th> <th>TOTAL INTEREST PAID</th> <th>TOTAL INTEREST ACCRUED</th>';

    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    /**
     * @description Used to create CSV Table
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
     * @description Used to create PDF Table
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
     * @description Export the data as per selected export type
     * @param requestParamMap 
     * @param parentAnnualAmountPaid 
     * @param childAnnualAmountPaid 
     */
    private void exportAnnualAmountPaid(Map<String,String> requestParamMap, List<Map<String,Object>> parentAnnualAmountPaid, List<Map<String,Object>> childAnnualAmountPaid){
        String exportType = requestParamMap.get(KEY_EXPORT_TYPE);
        String applicationId = requestParamMap.get(KEY_APP_ID);
        Boolean isSingleRate = isSingleRateLoan(applicationId);
        if(exportType.equals(CSV_VALUE)){
            String tableData = exportCSV(isSingleRate,parentAnnualAmountPaid,childAnnualAmountPaid);
            responseFieldMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }
        else if(exportType.equals(PDF_VALUE)){ 
            String tableData = exportPDF(isSingleRate,parentAnnualAmountPaid,childAnnualAmountPaid);
            responseFieldMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        } 
    }


    
    /**
     * @description This method validate all the request parameter and return response to portal
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames, Map<String, Object> request){
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            checkRequestParam(request);
            String exportType = String.valueOf(request.get(KEY_EXPORT_TYPE));
            String applicationId = String.valueOf(request.get(KEY_APP_ID));

            List<Object> parentLoanList = (List<Object>)Json.deserializeUntyped(String.valueOf(request.get(PARENT_LOAN_LIST)));
            List<Object> childLoanList = (List<Object>)Json.deserializeUntyped(String.valueOf(request.get(CHILD_LOAN_LIST)));
            if(parentLoanList.size() == 0 || childLoanList.size() == 0){
                throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
            }
            List<Map<String,Object>> parentAnnualAmountPaid = new List<Map<String,Object>>();
            List<Map<String,Object>> childAnnualAmountPaid = new List<Map<String,Object>>();

            for(Object parentLoanInfo : parentLoanList){
                Map<String,Object> parentLoanMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(parentLoanInfo));
                parentAnnualAmountPaid.add(parentLoanMap);
            }
            for(Object childLoanInfo : childLoanList){
                Map<String,Object> childLoanMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(childLoanInfo));
                childAnnualAmountPaid.add(childLoanMap);
            }
            Map<String,String> requestParamMap = new Map<String,String>{
                KEY_EXPORT_TYPE => exportType,
                KEY_APP_ID => applicationId
            };
            exportAnnualAmountPaid(requestParamMap,parentAnnualAmountPaid,childAnnualAmountPaid);
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
    /**
     * @description Check whether export is for single rate loan or multi rate
     * @param applicationId 
     * @return  `boolean`
     */
    private static boolean isSingleRateLoan(String applicationId){
        List<genesis__Applications__c> appList = [SELECT Pricing_Count__c FROM genesis__Applications__c WHERE Id = :applicationId];
        if(appList.size() != 1){
            throw new CustomException(PortalConstants.NO_APPLICATIONS_FOUND);
        }
        if(appList[0].Pricing_Count__c == 1){
            return true;
        }
        else{
            return false;
        }
    }
    /**
     * @description Check the request parameter
     * @param request 
     * @exception 
     */
    private static void checkRequestParam(Map<String, Object> request){
        if (String.isBlank((String) request.get(KEY_EXPORT_TYPE)) && String.isBlank((String) request.get(KEY_APP_ID))) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        if(!request.containsKey(PARENT_LOAN_LIST) || request.get(PARENT_LOAN_LIST) == null || !request.containsKey(CHILD_LOAN_LIST) || request.get(CHILD_LOAN_LIST) == null){
            throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
        }
       
    }

    /**
     * @description create and export csv
     * @param isSingleRate 
     * @param parentAnnualAmountPaid 
     * @param childAnnualAmountPaid 
     * @return  `String`
     */
    private static String exportCSV(Boolean isSingleRate,List<Map<String,Object>> parentAnnualAmountPaid, List<Map<String,Object>> childAnnualAmountPaid){
        String tableData = TRANSAC_CSV_TABLE_HEADING; 
            String tableRow = '';
            String setDescription = null;
            
            if(isSingleRate == false){
                for(Map<String,Object> totalLoanAmountPaidMap : parentAnnualAmountPaid){
                    Decimal interestPaid = (Decimal)(totalLoanAmountPaidMap.get(PARENT_INTEREST_PAID));
                    Decimal interestAccrued = (Decimal)(totalLoanAmountPaidMap.get(PARENT_INTEREST_ACCRUED));

                    tableRow = createCSVTableRow(totalLoanAmountPaidMap.get(PARENT_CALENDAR_YEAR))
                                    + createCSVTableRow(totalLoanAmountPaidMap.get(PARENT_LOAN_NUMBER))
                                    + createCSVTableRow(null)
                                    + createCSVTableRow(null)
                                    + createCSVTableRow(DOLLAR + String.valueOf(interestPaid.setScale(2)))
                                    + createCSVTableRow(DOLLAR + String.valueOf(interestAccrued.setScale(2)));

                    tableData += tableRow.removeEnd(COMMA_STRING) + '\n';  
                }
            }
            for(Map<String,Object> totalLoanAmountPaidMap : childAnnualAmountPaid){
                String childLoanNumber = null;
                String parentLoanNumber = null;
                Decimal interestPaid = (Decimal)(totalLoanAmountPaidMap.get(CHILD_INTEREST_PAID));
                Decimal interestAccrued = (Decimal)(totalLoanAmountPaidMap.get(CHILD_INTEREST_ACCRUED));
                if(totalLoanAmountPaidMap.get(CHILD_LOAN_DESCRIPTION) != null){
                    setDescription = String.valueOf(totalLoanAmountPaidMap.get(CHILD_LOAN_DESCRIPTION)).replace(',', '');
                }
                if(isSingleRate == true){
                    parentLoanNumber = String.valueOf(totalLoanAmountPaidMap.get(CHILD_LOAN_NUMBER));
                }
                else{
                    childLoanNumber = String.valueOf(totalLoanAmountPaidMap.get(CHILD_LOAN_NUMBER));
                }
                tableRow = createCSVTableRow(totalLoanAmountPaidMap.get(CHILD_CALENDAR_YEAR))
                                + createCSVTableRow(parentLoanNumber)
                                + createCSVTableRow(childLoanNumber)
                                + createCSVTableRow(setDescription)
                                + createCSVTableRow(DOLLAR + String.valueOf(interestPaid.setScale(2)))
                                + createCSVTableRow(DOLLAR + String.valueOf(interestAccrued.setScale(2)));

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';  
            }
            return tableData;
    }

    /**
     * @description create and export pdf
     * @param isSingleRate 
     * @param parentAnnualAmountPaid 
     * @param childAnnualAmountPaid 
     * @return  `String`
     */
    private static String exportPDF(Boolean isSingleRate,List<Map<String,Object>> parentAnnualAmountPaid, List<Map<String,Object>> childAnnualAmountPaid){
        String loanNumber = String.valueOf(parentAnnualAmountPaid[0].get(PARENT_LOAN_NUMBER));
        String tableData = TRANSAC_PDF_HTML_START;
        tableData = tableData.replace(HEADING,PDF_HEADING + loanNumber);
        String tableRow = '';
        if(isSingleRate == false){
            for(Map<String,Object> totalLoanAmountPaidMap : parentAnnualAmountPaid){
                Decimal interestPaid = (Decimal)(totalLoanAmountPaidMap.get(PARENT_INTEREST_PAID));
                Decimal interestAccrued = (Decimal)(totalLoanAmountPaidMap.get(PARENT_INTEREST_ACCRUED));
                tableRow = PDF_HTML_TR_START;
                tableRow += createPDFTableRow(totalLoanAmountPaidMap.get(PARENT_CALENDAR_YEAR))
                                + createPDFTableRow(totalLoanAmountPaidMap.get(PARENT_LOAN_NUMBER))
                                + createPDFTableRow(null)
                                + createPDFTableRow(null)
                                + createPDFTableRow(DOLLAR + String.valueOf(interestPaid.setScale(2)))
                                + createPDFTableRow(DOLLAR + String.valueOf(interestAccrued.setScale(2)));
                tableRow += PDF_HTML_TR_END;
                tableData += tableRow;   
            }
        }
        for(Map<String,Object> totalLoanAmountPaidMap : childAnnualAmountPaid){
            String childLoanNumber = null;
            String parentLoanNumber = null;
            Decimal interestPaid = (Decimal)(totalLoanAmountPaidMap.get(CHILD_INTEREST_PAID));
            Decimal interestAccrued = (Decimal)(totalLoanAmountPaidMap.get(CHILD_INTEREST_ACCRUED));
            if(isSingleRate == true){
                parentLoanNumber = String.valueOf(totalLoanAmountPaidMap.get(CHILD_LOAN_NUMBER));
            }
            else{
                childLoanNumber = String.valueOf(totalLoanAmountPaidMap.get(CHILD_LOAN_NUMBER));
            }
            tableRow = PDF_HTML_TR_START;
            tableRow += createPDFTableRow(totalLoanAmountPaidMap.get(CHILD_CALENDAR_YEAR))
                            + createPDFTableRow(parentLoanNumber)
                            + createPDFTableRow(childLoanNumber)
                            + createPDFTableRow(totalLoanAmountPaidMap.get(CHILD_LOAN_DESCRIPTION))
                            + createPDFTableRow(DOLLAR + String.valueOf(interestPaid.setScale(2)))
                            + createPDFTableRow(DOLLAR + String.valueOf(interestAccrued.setScale(2)));
            tableRow += PDF_HTML_TR_END;
            tableData += tableRow;   
        }
        tableData += PDF_HTML_END;
        return tableData;
    }
}