/**
 * @description       : Purpose of this class is to export applications into CSV
 * @author            : Rahul Gupta | 18-04-2022
 * @group             : 
 * @last modified on  : 26-04-2022
 * @last modified by  : Rahul Gupta
**/

global without sharing class PortalExportLoansAPI implements clcommon.PortalCustomRemoteAPI1 {
    // constants specific for this class [start]
    private static final String KEY_APPLICATIONS = 'loans';
    private static final String KEY_EXPORT_TYPE = 'exportType';
    private static final String FETCH_LOAN_SOQL = 'SELECT Id, genesis__Application__r.genesis__Loan_Number__c, genesis__Application__r.genesis__Maturity_Date__c, genesis__Application__r.genesis__Loan_Amount__c, genesis__Application__r.genesis__Account__r.Name, genesis__Application__r.genesis__Credit_Rating__r.Name, genesis__Application__r.Guarantee__c, genesis__Application__r.genesis__Status__c, genesis__Application__r.Internal_Reference_Code__c, genesis__Application__r.CreatedDate, genesis__Application__r.My_Program__r.Name, genesis__Application__r.Crop_Year__c, genesis__Application__r.genesis__Account__r.BillingCity FROM clcommon__party__c WHERE Id IN (';
    private static final String SINGLE_QUOTE_STRING = '\'';
    private static final String COMMA_STRING = ', ';
    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';
    private static final String CSV_TABLE_HEADING = 'LOAN #, MATURITY DATE, LOAN AMOUNT, GROWER NAME, TIER, GUARANTEE %, STATUS, IRC, DATE SUBMITTED, MY PROGRAM, CROP YEAR, CITY\n';
    private static final String PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><body><h1 style="font-size: 15pt;">Applications</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"><tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"><th>LOAN #</th><th>MATURITY DATE</th><th>LOAN AMOUNT</th><th>GROWER NAME</th><th>TIER</th><th>GUARANTEE %</th><th>STATUS</th><th>IRC</th><th>DATE SUBMITTED</th><th>MY PROGRAM</th><th>CROP YEAR</th><th>CITY</th></tr>';
    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td style="padding: 7.5pt 11.25pt">';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    // constants specific for this class [end]
    
    String applicationsString = '';
    String exportType = '';
    
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
            
    /**
    * @author Rahul Gupta | 18-04-2022 
    * @param String componentStructureName 
    * @param String[] disclosureNames 
    * @param Map<String,Object> request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();

        List<clcommon__party__c> objPartyList = new List<clcommon__party__c>();
        Map<String, Object> responseFieldMap = new Map<String, Object>();
    
        try {
             // checking whether valid arguments are coming
             if (request.get(KEY_APPLICATIONS) == null ||
                 request.get(KEY_EXPORT_TYPE) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            applicationsString = String.valueOf(request.get(KEY_APPLICATIONS));
            exportType = String.valueOf(request.get(KEY_EXPORT_TYPE));

            List<Object> applicationList = (List<Object>) JSON.deserializeUntyped(applicationsString);

            if (applicationList.size() == 0) {
                throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
            }

            String fetchLoanSOQL = FETCH_LOAN_SOQL;

            // crafting the query for fetching the required applications
            for (Object application : applicationList) {
                fetchLoanSOQL += SINGLE_QUOTE_STRING + String.valueOf(application) + SINGLE_QUOTE_STRING + COMMA_STRING;
            }

            fetchLoanSOQL = fetchLoanSOQL.removeEnd(COMMA_STRING) + CLOSING_FIRST_BRACKET_STRING;

            objPartyList = Database.query(fetchLoanSOQL);

            if (exportType == CSV_VALUE) {
                String commaSeparatedStringRow = CSV_TABLE_HEADING;
                String csvString = '';

                for (clcommon__party__c objParty : objPartyList) {
                    // looping through the parties and crafting the csv table from the application data
                    commaSeparatedStringRow += (objParty.genesis__Application__r.genesis__Loan_Number__c == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.genesis__Loan_Number__c) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.genesis__Maturity_Date__c == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.genesis__Maturity_Date__c) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.genesis__Loan_Amount__c == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.genesis__Loan_Amount__c) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.genesis__Account__r.Name == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.genesis__Account__r.Name) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.genesis__Credit_Rating__r.Name == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.genesis__Credit_Rating__r.Name) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.Guarantee__c == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.Guarantee__c) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.genesis__Status__c == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.genesis__Status__c) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.Internal_Reference_Code__c == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.Internal_Reference_Code__c) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.CreatedDate == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.CreatedDate) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.My_Program__r.Name == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.My_Program__r.Name) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.Crop_Year__c == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.Crop_Year__c) + COMMA_STRING;

                    commaSeparatedStringRow += (objParty.genesis__Application__r.genesis__Account__r.BillingCity == null) ? COMMA_STRING : String.valueOf(objParty.genesis__Application__r.genesis__Account__r.BillingCity) + COMMA_STRING;


                    csvString += commaSeparatedStringRow.removeEnd(COMMA_STRING) + '\n';
                    commaSeparatedStringRow = '';
                }

                Blob csvBlob = Blob.valueOf(csvString);
                String csvBase64 = EncodingUtil.base64Encode(csvBlob);
               
                responseFieldMap.put(CSV_VALUE, csvBase64);
            } else if (exportType == PDF_VALUE) {

                String pdfData = PDF_HTML_START;

                String rowText = '';

                for (clcommon__party__c objParty : objPartyList) {
                   // looping through the parties and crafting the pdf table from the application data
                    rowText = PDF_HTML_TR_START;

                    rowText += (objParty.genesis__Application__r.genesis__Loan_Number__c == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.genesis__Loan_Number__c) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.genesis__Maturity_Date__c == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.genesis__Maturity_Date__c) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.genesis__Loan_Amount__c == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.genesis__Loan_Amount__c) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.genesis__Account__r.Name == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.genesis__Account__r.Name) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.genesis__Credit_Rating__r.Name == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.genesis__Credit_Rating__r.Name) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.Guarantee__c == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.Guarantee__c) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.genesis__Status__c == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.genesis__Status__c) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.Internal_Reference_Code__c == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.Internal_Reference_Code__c) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.CreatedDate == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.CreatedDate) + PDF_HTML_TD_END;
                    
                    rowText += (objParty.genesis__Application__r.My_Program__r.Name == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.My_Program__r.Name) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.Crop_Year__c == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.Crop_Year__c) + PDF_HTML_TD_END;

                    rowText += (objParty.genesis__Application__r.genesis__Account__r.BillingCity == null) ? PDF_HTML_TD_START_END : PDF_HTML_TD_START + String.valueOf(objParty.genesis__Application__r.genesis__Account__r.BillingCity) + PDF_HTML_TD_END;

                    rowText += PDF_HTML_TR_END;
                    pdfData += rowText + '\n';
                    rowText = '';
                }

                pdfData += PDF_HTML_END;

                Blob pdfBlob = Blob.toPdf(pdfData);
                String pdfBase64 = EncodingUtil.base64Encode(pdfBlob);
               
                responseFieldMap.put(PDF_VALUE, pdfBase64);
            }

            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
        } catch (CustomException e) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = e.getMessage();
        } catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return response;
    }
}