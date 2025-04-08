/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Rahul Gorai
**/

global without sharing class PortalGrowmarkExportReportsAPI implements clcommon.PortalCustomRemoteAPI1 {
    // constants specific for this class [start]
    private static final string KEY_REPORT_TYPE = 'reportType';
    private static final string KEY_REPORT_FILTER = 'filter';
    private static final String KEY_EXPORT_TYPE = 'exportType';
    private static final String KEY_BATCH_ID = 'batchId';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';

    public static final String EOM_ACTIVE_LOAN_REPORT = 'IFP End Of Month Active Loan Report';
    public static final String RATE_CHANGE_NOTIFICATION_REPORT = 'Rate Change Notification Report';
    public static final String EOY_REPORT = 'IFP End Of Year Report';
    public static final String ONLINE_USERS_REPORT = 'Online Users Report';
    public static final String CURRENT_CROP_YEAR_REPORT = 'Current Crop Year Loans Report';
    public static final String PRIOR_CROP_YEAR_REPORT = 'Previous Crop Year Loans Report';
    public static final String SUBSIDY_ACCRUAL_REPORT = 'IFP Subsidy Accrual Report';
    public static final String PREMIUM_ACCRUAL_REPORT = 'IFP Premium Accrual Report';
    public static final String LOAN_ACCOUNT_REPORT = 'Loan Account Report';
    public static final String ACH_BATCH_HISTORY_REPORT = 'ACH Batch History Report';
    public static final String DRAFT_HISTORY_REPORT = 'DRAFT History Report';
    public static final String ACTIVE_LOAN_REPORT = 'IFP Active Loan Report';

    private static final String SINGLE_QUOTE_STRING = '\'';
    private static final String COMMA_STRING = ',';
    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    // private static final PortalReportsAPI OBJ_REPORTS_API = new PortalReportsAPI();

    private static final Map<String, String> CSV_HEADING_MAP = new Map<String, String>{
        EOM_ACTIVE_LOAN_REPORT => 'NAME, LOAN #, YEAR, PURPOSE, MATURITY, CERTIFIED LENDER, SALES AGENT, RATING, NOTE DATE, RATE, NOTE, PRINCIPAL, INTEREST, FEES, PER DIEM, AVAILABLE, RESERVED, PAST DUE, GTY %, IRC, Unique Identifier, CREATED\n',

        CURRENT_CROP_YEAR_REPORT => 'NAME, YEAR, CERTIFIED LENDER, NOTE, STATUS, IRC, Unique Identifier, SALES AGENT, CREATED\n',

        PRIOR_CROP_YEAR_REPORT => 'NAME, YEAR, CERTIFIED LENDER, NOTE, STATUS, IRC, Unique Identifier, SALES AGENT, CREATED\n',

        RATE_CHANGE_NOTIFICATION_REPORT => 'NAME, LOAN #, MATURITY, CERTIFIED LENDER, IRC, UNIQUE IDENTIFIER, STREET, CITY, STATE, ZIP CODE, EMAIL, PHONE, CURRENT RATE, NEW RATE, SALES AGENT, EFFECTIVE DATE\n',

        ONLINE_USERS_REPORT => 'NAME, PHONE, EMAIL, ACTIVE LOAN\n',

        SUBSIDY_ACCRUAL_REPORT => 'LOAN #, CITY, STATE, PRINCIPAL, INTEREST BALANCE, MONTHLY INTEREST, YEAR, PURPOSE, NAME, MATURITY,CERTIFIED LENDER ,SALES AGENT, IRC, Unique Identifier, CREATED\n',

        PREMIUM_ACCRUAL_REPORT => 'LOAN #, CITY, STATE, PRINCIPAL, INTEREST BALANCE, MONTHLY INTEREST, YEAR, PURPOSE, NAME, MATURITY, CERTIFIED LENDER, SALES AGENT, IRC, Unique Identifier, CREATED\n',

        LOAN_ACCOUNT_REPORT => 'NAME, LOAN #, YEAR, PURPOSE, MATURITY, CERTIFIED LENDER ,SALES AGENT,RATING, NOTE DATE, RATE, NOTE, PRINCIPAL, INTEREST, FEES, PER DIEM, AVAILABLE, RESERVED, GTY %, IRC, Unique Identifier, CREATED\n',

        ACH_BATCH_HISTORY_REPORT => 'NAME, LOAN #, AMOUNT, DESCRIPTION, PURPOSE, YEAR\n',

        DRAFT_HISTORY_REPORT => 'NAME, DRAFT #, AMOUNT, LOAN #, YEAR, DATE RECORDED\n',

        EOY_REPORT => 'NAME, LOAN #, INTEREST, CERTIFIED LENDER, SALES AGENT, ADDRESS, CITY, STATE, ZIP, IRC, UNIQUE IDENTIFIER, CREATED\n',

        ACTIVE_LOAN_REPORT => 'NAME, LOAN #, YEAR, MATURITY, CERTIFIED LENDER ,SALES AGENT,RATING, NOTE DATE, RATE, NOTE, PRINCIPAL, INTEREST, FEES, PER DIEM, AVAILABLE, RESERVED, PAST DUE, GTY %, IRC, Unique Identifier, CREATED\n'
    };

    private static final Map<String, String> PDF_TABLE_HEADING_MAP = new Map<String, String>{
        EOM_ACTIVE_LOAN_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th> <th>LOAN #</th> <th>YEAR</th> <th>PURPOSE</th> <th>MATURITY</th> <th>RATE</th> <th>NOTE</th> <th>PRINCIPAL</th> <th>INTEREST</th> <th>FEES</th> <th>PER DIEM</th>  <th>AVAILABLE</th> <th>RESERVED</th> <th>PAST DUE</th> <th>GTY %</th> <th>IRC</th> <th>Unique Identifier</th> <th>CREATED</th></tr>',

        ACTIVE_LOAN_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th> <th>LOAN #</th> <th>YEAR</th> <th>MATURITY</th> <th>RATE</th> <th>NOTE</th> <th>PRINCIPAL</th> <th>INTEREST</th> <th>FEES</th> <th>PER DIEM</th> <th>AVAILABLE</th> <th>RESERVED</th> <th>PAST DUE</th><th>GTY %</th> <th>IRC</th> <th>Unique Identifier</th> <th>CREATED</th> </tr>',

        CURRENT_CROP_YEAR_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th> <th>YEAR</th> <th>CERTIFIED LENDER</th> <th>NOTE</th> <th>STATUS</th> <th>IRC</th> <th>Unique Identifier</th> <th>SALES AGENT</th> <th>CREATED</th> </tr>',

        PRIOR_CROP_YEAR_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th> <th>YEAR</th> <th>CERTIFIED LENDER</th> <th>NOTE</th> <th>STATUS</th> <th>IRC</th> <th>Unique Identifier</th> <th>SALES AGENT</th> <th>CREATED</th></tr>',

        RATE_CHANGE_NOTIFICATION_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th><th>LOAN #</th><th>MATURITY</th><th>STREET</th><th>CITY</th><th>STATE</th><th>ZIP CODE</th><th>EMAIL</th><th>PHONE</th><th>CURRENT RATE</th><th>NEW RATE</th><th>SALES AGENT</th><th>EFFECTIVE DATE</th> </tr>',

        ONLINE_USERS_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th> <th>PHONE</th> <th>EMAIL</th> <th>ACTIVE LOAN</th> </tr>',

        SUBSIDY_ACCRUAL_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>LOAN #</th><th>CITY</th><th>STATE</th><th>PRINCIPAL</th> <th>INTEREST</th> <th>PER DIEM</th> <th>YEAR</th><th>PURPOSE</th><th>NAME</th><th>MATURITY</th> <th>IRC</th> <th>Unique Identifier</th> <th>CREATED</th> </tr>',

        PREMIUM_ACCRUAL_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>LOAN #</th><th>CITY</th><th>STATE</th><th>PRINCIPAL</th> <th>INTEREST</th> <th>PER DIEM</th> <th>YEAR</th><th>PURPOSE</th><th>NAME</th> <th>MATURITY</th> <th>IRC</th> <th>Unique Identifier</th> <th>CREATED</th> </tr>',

        LOAN_ACCOUNT_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th> <th>LOAN #</th> <th>YEAR</th> <th>PURPOSE</th> <th>MATURITY</th> <th>RATE</th> <th>NOTE</th> <th>PRINCIPAL</th> <th>INTEREST</th> <th>FEES</th> <th>PER DIEM</th> <th>AVAILABLE</th> <th>RESERVED</th> <th>GTY %</th> <th>IRC</th> <th>Unique Identifier</th> <th>CREATED<th> </tr>',

        ACH_BATCH_HISTORY_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th> <th>LOAN #</th> <th>AMOUNT</th> <th>DESCRIPTION</th> <th>PURPOSE</th> <th>YEAR</th> </tr>',

        DRAFT_HISTORY_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th><th>DRAFT #</th><th>AMOUNT</th><th>LOAN #</th><th>YEAR</th><th>DATE RECORDED</th> </tr>',

        EOY_REPORT => '</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>NAME</th><th>LOAN #</th> <th>INTEREST</th> <th>ADDRESS</th><th>CITY</th><th>STATE</th><th>ZIP</th><th>IRC</th> <th>Unique Identifier</th> <th>CREATED</th> </tr>'
        
    };
    private static final List<String> FILTERED_REPORT_LIST = new List<String>{ EOM_ACTIVE_LOAN_REPORT, EOY_REPORT, ACTIVE_LOAN_REPORT, SUBSIDY_ACCRUAL_REPORT, PREMIUM_ACCRUAL_REPORT, LOAN_ACCOUNT_REPORT};
    private static final List<String> UNFILTERED_REPORT_LIST = new List<String>{ CURRENT_CROP_YEAR_REPORT, PRIOR_CROP_YEAR_REPORT, RATE_CHANGE_NOTIFICATION_REPORT, ONLINE_USERS_REPORT, DRAFT_HISTORY_REPORT};

    private static final String PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><head></head><body> <h1 style="font-size: 15pt;">';
    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td style="padding: 7.5pt 11.25pt">';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PORTAL_EXPORT_API = 'PortalExportReportsAPI';
    // constants specific for this class [end]

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportActiveLoanReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__Applications__c> objApplicationList = PortalReportsHandler.getActiveLoanReport(reportFilter);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objApplicationList);
        

        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(ACTIVE_LOAN_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (genesis__Applications__c objApplication : objApplicationList) {
                tableRow = PortalReportsHelper.createCSVTableRow(String.valueOf(objApplication.genesis__Account__r.name))
                                + PortalReportsHelper.createCSVTableRow(objApplication.genesis__Loan_Number__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Crop_Year__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objApplication.genesis__Maturity_Date__c))
                                + PortalReportsHelper.createCSVTableRow(portalreportshelper.getString(objApplication.Certified_Lender__r.Name))
                                + PortalReportsHelper.createCSVTableRow(portalreportshelper.getString(objApplication.Sales_Agent__r.Name))
                                + PortalReportsHelper.createCSVTableRow(portalreportshelper.getString(objApplication.genesis__Credit_Rating__r.Name))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objApplication.Note_Date__c))
                                + PortalReportsHelper.createCSVTableRow(objApplication.genesis__Interest_Rate__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.genesis__Loan_Amount__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Current_Principal_Balance__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Total_Interest__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Total_Fees__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Total_Interest_Per_Diem__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Available__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Reserved_Amount__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Past_Due_Amount__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.Guarantee__c)
                                + PortalReportsHelper.createCSVTableRow(portalreportshelper.getString(objApplication.Internal_Reference_Code__c))
                                + PortalReportsHelper.createCSVTableRow(portalreportshelper.getString(objApplication.Unique_Identifier__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objApplication.CreatedDate));

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
        //     //pdf export type is not curreently used
        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData = PDF_HTML_START + ACTIVE_LOAN_REPORT + PDF_TABLE_HEADING_MAP.get(ACTIVE_LOAN_REPORT);
        //     String tableRow = '';

            

        //     // looping through the parties and crafting the pdf table from the application data
        //     for (genesis__Applications__c objApplication : objApplicationList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(objApplication.genesis__Account__r.name)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Loan_Number__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Crop_Year__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Maturity_Date__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Interest_Rate__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Loan_Amount__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Current_Principal_Balance__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Total_Interest__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Total_Fees__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Total_Interest_Per_Diem__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Available__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Reserved_Amount__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Past_Due_Balance__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Guarantee__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Internal_Reference_Code__c);
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Growmark_Unique_Identifier__c);

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportEndOfYearReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<Map<String, Object>> objApplicationList = PortalReportsHandler.getEndOfYearReport(reportFilter);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objApplicationList);
        

        if (exportType.equals(CSV_VALUE)) { 
            String tableData = CSV_HEADING_MAP.get(EOY_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (Map<String, Object> objApplication : objApplicationList) {
                tableRow = PortalReportsHelper.createCSVTableRow(String.valueOf(objApplication.get('grower_name')))
                                + PortalReportsHelper.createCSVTableRow(objApplication.get('loan_number'))
                                + PortalReportsHelper.createCSVTableRow(objApplication.get('interest'))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.get('certified_lender')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.get('sales_agent')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.get('street')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.get('city')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.get('state')))
                                + PortalReportsHelper.createCSVTableRow(objApplication.get('zip'))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.get('irc')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.get('unique_identifier')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objApplication.get('created_date')));
                                
                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';

                
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
        // pdf export type is not currently used

        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData;
        //     String tableRow = '';

        //     if (String.isBlank(reportFilter)) {
        //         tableData = PDF_HTML_START + EOY_REPORT + PDF_TABLE_HEADING_MAP.get(EOY_REPORT);
        //     } else {
        //         tableData = PDF_HTML_START + EOY_REPORT + ' - ' + reportFilter + PDF_TABLE_HEADING_MAP.get(EOY_REPORT);
        //     }

        //     // looping through the parties and crafting the pdf table from the application data
        //     for (Map<String, Object> objApplication : objApplicationList) {
        //         tableRow = PDF_HTML_TR_START;

        //         tableRow = PortalReportsHelper.createPDFTableRow(objApplication.get('grower_name'))
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.get('loan_number'))
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.get('interest'))
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.get('street'))
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.get('city'))
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.get('state'))
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.get('zip'))
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.get('irc'));

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportEndOfMonthActiveLoanReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<Map<String, Object>> resultList = PortalReportsHandler.getEndOfMonthActiveLoanReport(reportFilter);
        
        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(resultList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(EOM_ACTIVE_LOAN_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (Map<String, Object> result : resultList) { 
                tableRow = PortalReportsHelper.createCSVTableRow(String.valueOf(result.get('grower_name')))
                                + PortalReportsHelper.createCSVTableRow(result.get('loan_number'))
                                + PortalReportsHelper.createCSVTableRow(result.get('crop_year'))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(result.get('purpose')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(result.get('maturity_date')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(result.get('certified_lender')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(result.get('sales_agent')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(result.get('credit_rating')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(result.get('note_date')))
                                + PortalReportsHelper.createCSVTableRow(result.get('interest_rate'))
                                + PortalReportsHelper.createCSVTableRow(result.get('loan_amount'))
                                + PortalReportsHelper.createCSVTableRow(result.get('principal'))
                                + PortalReportsHelper.createCSVTableRow(result.get('interest'))
                                + PortalReportsHelper.createCSVTableRow(result.get('fees'))
                                + PortalReportsHelper.createCSVTableRow(result.get('per_diem'))
                                + PortalReportsHelper.createCSVTableRow(result.get('available'))
                                + PortalReportsHelper.createCSVTableRow(result.get('reserved'))
                                + PortalReportsHelper.createCSVTableRow(result.get('past_due'))
                                + PortalReportsHelper.createCSVTableRow(result.get('guaranty'))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(result.get('irc')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(result.get('unique_identifier')))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(result.get('created_date')));

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
        // pdf export type is not currently used

        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData;
        //     String tableRow = '';

        //     if (String.isBlank(reportFilter)) {
        //         tableData = PDF_HTML_START + EOM_ACTIVE_LOAN_REPORT + PDF_TABLE_HEADING_MAP.get(EOM_ACTIVE_LOAN_REPORT);
        //     } else {
        //         tableData = PDF_HTML_START + EOM_ACTIVE_LOAN_REPORT + ' - ' + reportFilter + PDF_TABLE_HEADING_MAP.get(EOM_ACTIVE_LOAN_REPORT);
        //     }

        //     // looping through the parties and crafting the pdf table from the application data
        //     for (Map<String, Object> result : resultList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(result.get('grower_name'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('loan_number'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('crop_year'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('purpose'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('maturity_date'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('interest_rate'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('loan_amount'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('principal'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('interest'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('fees'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('per_diem'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('available'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('reserved_amount'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('past_due'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('guaranty'))
        //                             + PortalReportsHelper.createPDFTableRow(result.get('irc'));

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;

    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportCurrentCropYearReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__Applications__c> objApplicationList = PortalReportsHandler.getCurrentCropYearReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objApplicationList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(CURRENT_CROP_YEAR_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (genesis__Applications__c objApplication : objApplicationList) {
               
                tableRow = PortalReportsHelper.createCSVTableRow(String.valueOf(objApplication.genesis__Account__r.name))
                                + PortalReportsHelper.createCSVTableRow(objApplication.Crop_Year__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Certified_Lender__r.Name))
                                + PortalReportsHelper.createCSVTableRow(objApplication.genesis__Loan_Amount__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.genesis__Status__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Internal_Reference_Code__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Unique_Identifier__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Sales_Agent__r.Name))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objApplication.CreatedDate));

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }           
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        // pdf export type is not currently used

        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData = PDF_HTML_START + CURRENT_CROP_YEAR_REPORT + PDF_TABLE_HEADING_MAP.get(CURRENT_CROP_YEAR_REPORT);
        //     String tableRow = '';

        //     // looping through the parties and crafting the pdf table from the application data
        //     for (genesis__Applications__c objApplication : objApplicationList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(objApplication.genesis__Account__r.name)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Crop_Year__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Certified_Lender__r.Name)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Loan_Amount__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Status__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Internal_Reference_Code__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Growmark_Unique_Identifier__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplication.Sales_Agent__r.Name);

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportPriorCropYearReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__Applications__c> objApplicationList = PortalReportsHandler.getPriorCropYearReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objApplicationList);
       
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PRIOR_CROP_YEAR_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (genesis__Applications__c objApplication : objApplicationList) { 
                tableRow = PortalReportsHelper.createCSVTableRow(String.valueOf(objApplication.genesis__Account__r.name))
                                + PortalReportsHelper.createCSVTableRow(objApplication.Crop_Year__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Certified_Lender__c, objApplication.Certified_Lender__r.Name))
                                + PortalReportsHelper.createCSVTableRow(objApplication.genesis__Loan_Amount__c)
                                + PortalReportsHelper.createCSVTableRow(objApplication.genesis__Status__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Internal_Reference_Code__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Unique_Identifier__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objApplication.Sales_Agent__c, objApplication.Sales_Agent__r.Name))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objApplication.CreatedDate));

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
        //   // pdf export type is not currently used
        //         } else if (exportType.equals(PDF_VALUE)) {
            
        //             String tableData = PDF_HTML_START + PRIOR_CROP_YEAR_REPORT + PDF_TABLE_HEADING_MAP.get(PRIOR_CROP_YEAR_REPORT);
        //             String tableRow = '';

        //             // looping through the parties and crafting the pdf table from the application data
        //             for (genesis__Applications__c objApplication : objApplicationList) {
        //                 tableRow = PDF_HTML_TR_START;
        //                 tableRow += PortalReportsHelper.createPDFTableRow(objApplication.genesis__Account__r.name)
        //                                     + PortalReportsHelper.createPDFTableRow(objApplication.Crop_Year__c)
        //                                     + PortalReportsHelper.createPDFTableRow(objApplication.Certified_Lender__r.Name)
        //                                     + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Loan_Amount__c)
        //                                     + PortalReportsHelper.createPDFTableRow(objApplication.genesis__Status__c)
        //                                     + PortalReportsHelper.createPDFTableRow(objApplication.Internal_Reference_Code__c)
        //                                     + PortalReportsHelper.createPDFTableRow(objApplication.Growmark_Unique_Identifier__c)
        //                                     + PortalReportsHelper.createPDFTableRow(objApplication.Sales_Agent__r.Name);

        //                 tableRow += PDF_HTML_TR_END;
        //                 tableData += tableRow;
        //             }
        //             tableData += PDF_HTML_END;

        //             // converting html string to pdf blob and returning
        //             resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportRateChangeNotificationReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<Map<String, Object>> rateChangeList = PortalReportsHandler.getRateChangeNotificationReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(rateChangeList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(RATE_CHANGE_NOTIFICATION_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (Map<String, Object> rateChange : rateChangeList) {
                
                tableRow = PortalReportsHelper.createCSVTableRow(String.valueOf(rateChange.get('grower_name')))
                            + PortalReportsHelper.createCSVTableRow(rateChange.get('loan_number'))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(rateChange.get('maturity_date')))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('certified_lender')))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('irc')))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('unique_identifier')))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('address')))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('city')))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('state')))
                            + PortalReportsHelper.createCSVTableRow(rateChange.get('zip'))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('email')))
                            + PortalReportsHelper.createCSVTableRow(rateChange.get('phone'))
                            + PortalReportsHelper.createCSVTableRow(rateChange.get('current_rate'))
                            + PortalReportsHelper.createCSVTableRow(rateChange.get('new_rate'))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(rateChange.get('sales_agent')))
                            + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(rateChange.get('effective_date')));

            tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
        }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
            //   // pdf export type is not currently used
            //         } else if (exportType.equals(PDF_VALUE)) {
            
            //             String tableData = PDF_HTML_START + RATE_CHANGE_NOTIFICATION_REPORT + PDF_TABLE_HEADING_MAP.get(RATE_CHANGE_NOTIFICATION_REPORT);
            //             String tableRow = '';

            //             // looping through the parties and crafting the pdf table from the application data
            //             for (Map<String, Object> rateChange : rateChangeList) {
            //                 tableRow = PDF_HTML_TR_START;
            //                 tableRow += PortalReportsHelper.createPDFTableRow(rateChange.get('grower_name'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('loan_number'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('maturity_date'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('address'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('city'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('state'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('zip'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('email'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('phone'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('current_rate'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('new_rate'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('sales_agent'))
            //                                 + PortalReportsHelper.createPDFTableRow(rateChange.get('effective_date'));

            //                 tableRow += PDF_HTML_TR_END;
            //                 tableData += tableRow;
            //             }
            //             tableData += PDF_HTML_END;

            //             // converting html string to pdf blob and returning
            //             resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportOnlineUsersReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<Map<String, Object>> onlineUserList = PortalReportsHandler.getOnlineUsersReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(onlineUserList);

        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(ONLINE_USERS_REPORT);
            tableData+=PortalReportsHelper.createTableForGMKOnlineUsersReport(onlineUserList);
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
  
        // pdf export type is not currently used

        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData = PDF_HTML_START + ONLINE_USERS_REPORT + PDF_TABLE_HEADING_MAP.get(ONLINE_USERS_REPORT);
        //     String tableRow = '';

        //     // looping through the parties and crafting the pdf table from the application data
        //     for (Map<String, Object> onlineUser : onlineUserList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(onlineUser.get('Name'))
        //                         + PortalReportsHelper.createPDFTableRow(onlineUser.get('Email'))
        //                         + PortalReportsHelper.createPDFTableRow(onlineUser.get('Phone'))
        //                         + PortalReportsHelper.createPDFTableRow(onlineUser.get('has_active_loan'));

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;

    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportSubsidyAccrualReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__Application_Fee_Payment__c> objFeePaymentList = PortalReportsHandler.getSubsidyAccrualReport(reportFilter);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objFeePaymentList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(SUBSIDY_ACCRUAL_REPORT);
            // String tableRow = '';
            tableData+=PortalReportsHelper.createTableForGMKSubsidyAccrualReport(objFeePaymentList);

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
  
            // pdf export type is not currently used
            
        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData = PDF_HTML_START + SUBSIDY_ACCRUAL_REPORT + PDF_TABLE_HEADING_MAP.get(SUBSIDY_ACCRUAL_REPORT);
        //     String tableRow = '';


        //     // looping through the parties and crafting the pdf table from the application data
        //     for (genesis__Application_Fee_Payment__c objApplicationFeePayment : objFeePaymentList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Pricing_Detail__r.Loan_Number__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingCity)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingState)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Principal_Balance__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Interest_Earned__c.setScale(2))
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Dealer_Monthly_Interest__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Crop_Year__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.genesis__Account__r.name)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c);
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Growmark_Unique_Identifier__c);

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;

    }


    /**
    * @description - cutoff for avoid long line of classes
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportPremiumAccrualReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__Application_Fee_Payment__c> objFeePaymentList = PortalReportsHandler.getPremiumAccrualReport(reportFilter);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objFeePaymentList);

        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PREMIUM_ACCRUAL_REPORT);
            // String tableRow = '';

            tableData+=PortalReportsHelper.createTableForGMKPremiumAccrualReport(objFeePaymentList);
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
  
            // pdf export type is not currently used

        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData = PDF_HTML_START + PREMIUM_ACCRUAL_REPORT + PDF_TABLE_HEADING_MAP.get(PREMIUM_ACCRUAL_REPORT);
        //     String tableRow = '';


        //     // looping through the parties and crafting the pdf table from the application data
        //     for (genesis__Application_Fee_Payment__c objApplicationFeePayment : objFeePaymentList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Pricing_Detail__r.Loan_Number__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingCity)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingState)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Principal_Balance__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Interest_Earned__c.setScale(2))
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Dealer_Monthly_Interest__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Crop_Year__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.genesis__Account__r.name)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c)
        //                         + PortalReportsHelper.createPDFTableRow(objApplicationFeePayment.genesis__Application__r.Growmark_Unique_Identifier__c);

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;

    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportLoanAccountReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<Map<String, Object>> resultList = PortalReportsHandler.getLoanAccountReport(reportFilter);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(resultList);
        
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(LOAN_ACCOUNT_REPORT);
            tableData+=PortalReportsHelper.createTableForGMKLoanAccrualReport(resultList);
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
            // converting comma-separated string to blob and returning
                        
            //   // pdf export type is not currently used
            //         } else if (exportType.equals(PDF_VALUE)) {
                        
            //             String tableData = PDF_HTML_START + LOAN_ACCOUNT_REPORT + PDF_TABLE_HEADING_MAP.get(LOAN_ACCOUNT_REPORT);
            //             String tableRow = '';
            
            
            //             // looping through the parties and crafting the pdf table from the application data
            //             for (Map<String, Object> result : resultList) {
            //                 tableRow = PDF_HTML_TR_START;
            //                 tableRow += PortalReportsHelper.createPDFTableRow(result.get('grower_name'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('loan_number'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('crop_year'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('purpose'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('maturity_date'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('interest_rate'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('loan_amount'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('principal'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('interest'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('fees'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('per_diem'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('available'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('reserved'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('guaranty'))
            //                                 + PortalReportsHelper.createPDFTableRow(result.get('irc'));
            
            //                 tableRow += PDF_HTML_TR_END;
            //                 tableData += tableRow;
            //             }
            //             tableData += PDF_HTML_END;
            
            //             // converting html string to pdf blob and returning
            //             resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;

}

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param batchId 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportACHBatchHistoryReport(String batchId, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__funding_transaction__c> objFundingTransactionList = PortalReportsHandler.getACHBatchHistoryReport(batchId);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objFundingTransactionList);
       
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(ACH_BATCH_HISTORY_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (genesis__funding_transaction__c objFundingTransaction : objFundingTransactionList) {
                
                tableRow = PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Loan_Number__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.genesis__Amount__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objFundingTransaction.Pricing_Detail__c, objFundingTransaction.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__c, objFundingTransaction.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objFundingTransaction.genesis__Reference__c))
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Crop_Year__c);

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
        // pdf export type is not currently used

        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData = PDF_HTML_START + ACH_BATCH_HISTORY_REPORT + PDF_TABLE_HEADING_MAP.get(ACH_BATCH_HISTORY_REPORT);
        //     String tableRow = '';

        //     // looping through the parties and crafting the pdf table from the application data
        //     for (genesis__funding_transaction__c objFundingTransaction : objFundingTransactionList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(objFundingTransaction.Grower_Name__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.Loan_Number__c)
                           
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.genesis__Amount__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.genesis__Reference__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Crop_Year__c);

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;

}

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportDraftHistoryReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__funding_transaction__c> objFundingTransactionList = PortalReportsHandler.getDraftHistoryReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objFundingTransactionList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(DRAFT_HISTORY_REPORT);
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (genesis__funding_transaction__c objFundingTransaction : objFundingTransactionList) {
                
                tableRow = PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Draft_Number__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.genesis__Amount__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Loan_Number__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Crop_Year__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objFundingTransaction.CreatedDate));

                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
        // pdf export type is not currently used

        // } else if (exportType.equals(PDF_VALUE)) {
            
        //     String tableData = PDF_HTML_START + DRAFT_HISTORY_REPORT + PDF_TABLE_HEADING_MAP.get(DRAFT_HISTORY_REPORT);
        //     String tableRow = '';

        //     // looping through the parties and crafting the pdf table from the application data
        //     for (genesis__funding_transaction__c objFundingTransaction : objFundingTransactionList) {
        //         tableRow = PDF_HTML_TR_START;
        //         tableRow += PortalReportsHelper.createPDFTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.Draft_Number__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.genesis__Amount__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.Loan_Number__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Crop_Year__c)
        //                         + PortalReportsHelper.createPDFTableRow(objFundingTransaction.CreatedDate);

        //         tableRow += PDF_HTML_TR_END;
        //         tableData += tableRow;
        //     }
        //     tableData += PDF_HTML_END;

        //     // converting html string to pdf blob and returning
        //     resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
        }

        return resultMap;

    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportType 
    * @param exportType 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    List<clcommon.PortalCustomRemoteActionRecord> exportUnfilteredReports(String reportType, String exportType){
        Map<String, Object> resultMap;
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        if (reportType.equals(CURRENT_CROP_YEAR_REPORT)) {
            resultMap = exportCurrentCropYearReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PRIOR_CROP_YEAR_REPORT)) {
            resultMap = exportPriorCropYearReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(RATE_CHANGE_NOTIFICATION_REPORT)) {
            resultMap = exportRateChangeNotificationReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(ONLINE_USERS_REPORT)) {
            resultMap = exportOnlineUsersReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(DRAFT_HISTORY_REPORT)) {
            resultMap = exportDraftHistoryReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        }
        return responseData;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportType 
    * @param reportFilter 
    * @param exportType 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    List<clcommon.PortalCustomRemoteActionRecord> exportFilteredReports(String reportType, String reportFilter, String exportType){
        Map<String, Object> resultMap;
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        if (reportType.equals(EOM_ACTIVE_LOAN_REPORT)) {
            resultMap = exportEndOfMonthActiveLoanReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(EOY_REPORT)) {
            resultMap = exportEndOfYearReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(ACTIVE_LOAN_REPORT)) {
            resultMap = exportActiveLoanReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(SUBSIDY_ACCRUAL_REPORT)) {
            resultMap = exportSubsidyAccrualReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PREMIUM_ACCRUAL_REPORT)) {
            resultMap = exportPremiumAccrualReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(LOAN_ACCOUNT_REPORT)) {
            resultMap = exportLoanAccountReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } 
        return responseData;
    }

   
    /**
    * @description 
    * @author Rahul Gupta | 18-04-2022 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {

        SavePoint dbSavePoint = Database.setSavepoint();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();
        Map<String, Object> resultMap;

        String reportType;
        String reportFilter;
        String exportType;
        String batchId;

        try {

            PortalReportsHelper.reportAndExportTypeMissingThrowException(request);
            // if (request.get(KEY_REPORT_TYPE) == null || request.get(KEY_EXPORT_TYPE) == null) {
            //     throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            // }

            reportType = String.valueOf(request.get(KEY_REPORT_TYPE));
            exportType = String.valueOf(request.get(KEY_EXPORT_TYPE));

            if(FILTERED_REPORT_LIST.contains(reportType)){
                reportFilter =  String.valueOf(request.get(KEY_REPORT_FILTER));
                responseData = exportFilteredReports(reportType,reportFilter,exportType);
            }else if(UNFILTERED_REPORT_LIST.contains(reportType)){
                responseData = exportUnfilteredReports(reportType,exportType);
            } else if (reportType.equals(ACH_BATCH_HISTORY_REPORT)) {
                
                PortalReportsHelper.requiredParameterMissingThrowException(request);
                batchId = String.valueOf(request.get(KEY_BATCH_ID));

                resultMap = exportACHBatchHistoryReport(batchId, exportType);
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 

            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  

        } catch (CustomException objCustomException) {
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