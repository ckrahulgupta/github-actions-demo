/**
 * @description       : Purpose of this class is to Export reports in PDF and CSV format
 * @author            : Rahul Gupta
 * @group             : 
 * Created Date       : 26-08-2022
 * @last modified on  : 04-08-2025
 * @last modified by  : Rahul Gorai
**/
global without sharing class PortalExportReportsAPI implements clcommon.PortalCustomRemoteAPI1 {
    // constants specific for this class [start]
    private static final String KEY_REPORT_FILTER = 'filter';
    private static final String KEY_EXPORT_TYPE = 'exportType';
    private static final String KEY_BATCH_ID = 'batchId';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';

    private static final String CURRENT_CROP_YEAR_REPORT = 'Current Crop Year Loans Report';
    private static final String PRIOR_CROP_YEAR_REPORT = 'Previous Crop Year Loans Report';


    private static final String SINGLE_QUOTE_STRING = '\''; 
    private static final String COMMA_STRING = ',';
    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    private static final String BULLET_SYMBOL = '• ';

    private static Integer slNo = 1;
    private static Boolean slNoFlag = true;
    
    // private static final PortalReportsAPI OBJ_REPORTS_API = new PortalReportsAPI();

    private static final Map<String, String> CSV_HEADING_MAP = new Map<String, String>{
        PortalConstants.EOM_ACTIVE_LOAN_REPORT => 'NAME, LOAN #, YEAR, PURPOSE, MATURITY, CERTIFIED LENDER ,SALES AGENT,RATING, NOTE DATE, RATE, NOTE, PRINCIPAL, INTEREST, FEES, PER DIEM, AVAILABLE, RESERVED, PAST DUE, GTY %, IRC, UNIQUE IDENTIFIER, CREATED\n',

        CURRENT_CROP_YEAR_REPORT => 'NAME, YEAR, CERTIFIED LENDER, NOTE, STATUS, IRC, SALES AGENT, CREATED\n',

        PRIOR_CROP_YEAR_REPORT => 'NAME, YEAR, CERTIFIED LENDER, NOTE, STATUS, IRC, SALES AGENT, CREATED\n',

        PortalConstants.RATE_CHANGE_NOTIFICATION_REPORT => 'NAME, LOAN #, MATURITY, CERTIFIED LENDER, IRC, STREET, CITY, STATE, ZIP CODE, EMAIL, PHONE, CURRENT RATE, NEW RATE, SALES AGENT, EFFECTIVE DATE\n',

        PortalConstants.ONLINE_USERS_REPORT => 'NAME, PHONE, EMAIL, ACTIVE LOAN, UNIQUE IDENTIFIER\n',

        PortalConstants.SUBSIDY_ACCRUAL_REPORT => 'LOAN #, CITY, STATE, PRINCIPAL, INTEREST BALANCE, MONTHLY INTEREST, YEAR, PURPOSE, NAME, MATURITY, CERTIFIED LENDER ,SALES AGENT, IRC, UNIQUE IDENTIFIER, CREATED\n',

        PortalConstants.PREMIUM_ACCRUAL_REPORT => 'LOAN #, CITY, STATE, PRINCIPAL, INTEREST BALANCE, MONTHLY INTEREST, YEAR, PURPOSE, NAME, MATURITY, CERTIFIED LENDER ,SALES AGENT, IRC, UNIQUE IDENTIFIER, CREATED\n',

        PortalConstants.LOAN_ACCOUNT_REPORT => 'NAME, LOAN #, YEAR, PURPOSE, MATURITY, CERTIFIED LENDER ,SALES AGENT,RATING, NOTE DATE, RATE, NOTE, PRINCIPAL, INTEREST, FEES, PER DIEM, AVAILABLE, RESERVED, GTY %, IRC, CREATED\n',

        PortalConstants.ACH_BATCH_HISTORY_REPORT => 'NAME, LOAN #, AMOUNT, DESCRIPTION, PURPOSE, IRC, YEAR\n',

        PortalConstants.DRAFT_HISTORY_REPORT => 'NAME, DRAFT #, AMOUNT, LOAN #, YEAR, DATE RECORDED\n',

        PortalConstants.EOY_REPORT => 'NAME, LOAN #, INTEREST, CERTIFIED LENDER,SALES AGENT, ADDRESS, CITY, STATE, ZIP, IRC, UNIQUE IDENTIFIER, CREATED\n',

        PortalConstants.ACTIVE_LOAN_REPORT => 'NAME, LOAN #, YEAR, MATURITY, CERTIFIED LENDER ,SALES AGENT,RATING, NOTE DATE, RATE, NOTE, PRINCIPAL, INTEREST, FEES, PER DIEM, AVAILABLE, RESERVED, PAST DUE, GTY %, IRC, UNIQUE IDENTIFIER, CREATED\n',

        PortalConstants.PENDING_TASK_REPORT => 'SL. NO., APP #, CROP YEAR, GROWER NAME, IRC, UNIQUE IDENTIFIER,CERTIFIED LENDER, SALES AGENT, PENDING TASK, COMMENT\n'
    };

    private static final Map<String, String> CSV_PENDING_TASK_MAP = new Map<String, String>{
        'AOI_task_active' => 'AOI',
        'coll_rep_task_active' => 'coll_rep',
        'entity_doc_task_active' => 'entity_doc',
        'confirmation_of_payoff_active' => 'confirmation_of_payoff',
        'lien_search_active' => 'lien_search',
        'lien_subordination_active' => 'lien_subordination',
        'sec_notice_active' => 'sec_notice',
        'CNS_active' => 'CNS',
        'signed_credit_agreement_active' => 'signed_credit_agreement',
        'spousal_consent_active' => 'spousal_consent',
        'ucc_amendment_active' => 'ucc_amendment',
        'ucc_filing_active' => 'ucc_filing',
        'cust_loan_approval_active' => 'cust_loan_approval'
    };

    private static final Map<String,List<String>> PDF_PENDING_TASK_MAP= new Map<String,List<String>>{
        'AOI_task_active' => new List<String>{'AOI_label', 'AOI_comment'},

        'coll_rep_task_active' => new List<String>{'coll_rep_label', 'coll_rep_comment'},
        
        'entity_doc_task_active' => new List<String>{'entity_doc_label', 'entity_doc_comment'},
        
        'confirmation_of_payoff_active' => new List<String>{'confirmation_of_payoff_label', 'confirmation_of_payoff_comment'},
        
        'lien_search_active' => new List<String>{'lien_search_label', 'lien_search_comment'},
        
        'lien_subordination_active' => new List<String>{'lien_subordination_label', 'lien_subordination_comment'},
        
        'sec_notice_active' => new List<String>{'sec_notice_label', 'sec_notice_comment'},
        
        'CNS_active' => new List<String>{'CNS_label', 'CNS_comment'},
        
        'signed_credit_agreement_active' => new List<String>{'signed_credit_agreement_label', 'signed_credit_agreement_comment'},
        
        'spousal_consent_active' => new List<String>{'spousal_consent_label', 'spousal_consent_comment'},
        
        'ucc_amendment_active' => new List<String>{'ucc_amendment_label', 'ucc_amendment_comment'},
        
        'ucc_filing_active' => new List<String>{'ucc_filing_label', 'ucc_filing_comment'},
        
        'cust_loan_approval_active' => new List<String>{'cust_loan_approval_label', 'cust_loan_approval_comment'}
    };

    private static final List<String> FILTERED_REPORT_LIST = new List<String>{PortalConstants.EOM_ACTIVE_LOAN_REPORT, PortalConstants.EOY_REPORT, PortalConstants.ACTIVE_LOAN_REPORT, PortalConstants.SUBSIDY_ACCRUAL_REPORT, PortalConstants.PREMIUM_ACCRUAL_REPORT, PortalConstants.LOAN_ACCOUNT_REPORT };
    private static final List<String> UNFILTERED_REPORT_LIST = new List<String>{CURRENT_CROP_YEAR_REPORT, PRIOR_CROP_YEAR_REPORT, PortalConstants.RATE_CHANGE_NOTIFICATION_REPORT, PortalConstants.ONLINE_USERS_REPORT, PortalConstants.DRAFT_HISTORY_REPORT, PortalConstants.PENDING_TASK_REPORT};

    private static final String PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><head></head><body> <h1 align="center" style="font-size: 15pt;">';
    private static final String PDF_HEADING_END = '</h1>';
    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td>';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PDF_END = '</html>';
    private static final String PDF_LINE_BREAK = '<br>';
    private static final String PDF_TABLE_START = '<table border="1" cellpadding="3" style="font-size: 9pt;"><tbody>';
    private static final String PDF_TABLE_END = '</tbody></table>';
    private static final String PDF_TABLE_HEADING = '<tr align="center" bgcolor="#7b925f" style="font-weight: bold; ">';
    private static final String APPID = '_appId';
    private static final String CROP_YEAR = '_crop_year';
    private static final String GROWER = '_grower';
    private static final String IRC = '_irc';
    private static final String UNIQUE_IDENTIFIER = '_unique_identifier';
    private static final String CL = '_cl';
    private static final String SALES_REP = '_sales_rep';
    private static final String LABEL = '_label';
    private static final String COMMENT = '_comment';
    private static final String CROP_YEAR_HEADING = 'CROP YEAR';
    private static final String UCC_FILING_CROP_YEAR = 'ucc_filing_crop_year';
    private static final String GROWER_NAME = 'GROWER NAME';
    private static final String UCC_FILING_GROWER = 'ucc_filing_grower';
    private static final String UCC_FILING_CL = 'ucc_filing_cl';
    private static final String UCC_FILING_SALES_REP = 'ucc_filing_sales_rep';
    private static final String PDF_HTML_TD = '<td colspan="2" style="font-weight: bold; ">PENDING TASK</td>';
    private static final String UCC_FILING_APPID = 'ucc_filing_appId';
    private static final String APPLICATION_ID = 'APPLICATION ID';
    private static final String IRC_HEADING = 'IRC';
    private static final String UNIQUE_IDENTIFIER_HEADING = 'UNIQUE IDENTIFIER';
    private static final String UCC_FILING_IRC = 'ucc_filing_irc';
    private static final String UCC_FILING_UNIQUE_IDENTIFIER = 'ucc_filing_irc';
    private final String CLASSNAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));

    // constants specific for this class [end]

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param label 
    * @param cellValue 
    * @param pendingTask 
    * @return String 
    **/
    private static String pdfTableRowBuilder(String label, String cellValue, Map<String, Object> pendingTask){
        String tableRow = PDF_HTML_TR_START;
        tableRow += PortalReportsHelper.createPDFTableRow(label) + PortalReportsHelper.createPDFTableRow(pendingTask.get(cellValue));
        tableRow += PDF_HTML_TR_END;
        return tableRow;
    }

    /**
    * @description - Purpose of this method is to create pdf table row with bullet points
    * @author Sk Minsar | 10-12-2023 
    * @param label 
    * @param cellValue 
    * @param pendingTask 
    * @return String 
    **/
    private static String pdfTableBulletRowBuilder(String label, String cellValue, Map<String, Object> pendingTask){
        String tableRow = PDF_HTML_TR_START;
        tableRow += PortalReportsHelper.createPDFTableRow(BULLET_SYMBOL + pendingTask.get(label)) + PortalReportsHelper.createPDFTableRow(pendingTask.get(cellValue));
        tableRow += PDF_HTML_TR_END;
        return tableRow;
    }


    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param reportName 
    * @param pendingTask 
    * @return String 
    **/
    private static String taskWiseCSVTableRowBuilder(String reportName,Map<String, Object> pendingTask){
        String tableData = PortalConstants.EMPTY_STRING;
        String tableRow = PortalConstants.EMPTY_STRING;
        if(slNoFlag==true){
            tableRow = PortalReportsHelper.createCSVTableRow(slNo);
            slNo+=1;
            slNoFlag=false;
        }
        else{
            tableRow=PortalReportsHelper.createCSVTableRow(PortalConstants.EMPTY_STRING);
        }
        tableRow += PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+APPID))
                + PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+CROP_YEAR))
                + PortalReportsHelper.createCSVTableRow(String.valueOf(pendingTask.get(reportName+GROWER)))
                + PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+IRC))
                + PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+UNIQUE_IDENTIFIER))
                + PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+CL))
                + PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+SALES_REP))
                + PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+LABEL)) 
                + PortalReportsHelper.createCSVTableRow(pendingTask.get(reportName+COMMENT));
        tableData += tableRow.removeEnd(COMMA_STRING) + PortalConstants.NEWLINE_STRING;
        return tableData;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param pendingTask 
    * @return String 
    **/
    private static String csvPendingTaskTableRowBuilder(Map<String, Object> pendingTask){
        String tableData = PortalConstants.EMPTY_STRING;
        for(String task: CSV_PENDING_TASK_MAP.keySet()){
            String taskValue = CSV_PENDING_TASK_MAP.get(task);
            if(pendingTask.get(task)==true){
                tableData += taskWiseCSVTableRowBuilder(taskValue, pendingTask);
            }
        }
        return tableData;
    }

   
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param pendingTaskList 
    * @return String 
    **/
    private static String exportCSVpendingTaskReport(List< Map<String, Object> > pendingTaskList){
        String tableData = CSV_HEADING_MAP.get(PortalConstants.PENDING_TASK_REPORT);
        for (Map<String, Object> pendingTask : pendingTaskList) {
            slNoFlag = true;
            tableData+=csvPendingTaskTableRowBuilder(pendingTask);
        }
        return tableData;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param pendingTask 
    * @return String 
    **/
    private static String pdfPendingTaskTableRowBuilder(Map<String, Object> pendingTask){
        String tableData = PortalConstants.EMPTY_STRING;
        for(String task: PDF_PENDING_TASK_MAP.keySet()){
            String taskLabel = PDF_PENDING_TASK_MAP.get(task)[0];
            String taskComment = PDF_PENDING_TASK_MAP.get(task)[1];
            if(pendingTask.get(task)==true){
                tableData += pdfTableBulletRowBuilder(taskLabel, taskComment, pendingTask);
            }
        }
        return tableData;
    }


    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param pendingTaskList 
    * @return String 
    **/
    private static String exportPDFPendingTaskReport(List< Map<String, Object> > pendingTaskList){

                
        String tableRow = PortalConstants.EMPTY_STRING;
        String tableData = PDF_HTML_START + PortalConstants.PENDING_TASK_REPORT  + PDF_HEADING_END;
        tableData += PDF_LINE_BREAK;

        for (Map<String, Object> pendingTask : pendingTaskList) {
            tableData += PDF_TABLE_START;
            tableRow = PDF_TABLE_HEADING;
            tableRow += PortalReportsHelper.createPDFTableRow(APPLICATION_ID) + PortalReportsHelper.createPDFTableRow(pendingTask.get(UCC_FILING_APPID)) ;
            tableRow += PDF_HTML_TR_END;
            tableData += tableRow ;

            tableData += pdfTableRowBuilder(CROP_YEAR_HEADING, UCC_FILING_CROP_YEAR, pendingTask);
            tableData += pdfTableRowBuilder(GROWER_NAME, UCC_FILING_GROWER, pendingTask);
            tableData += pdfTableRowBuilder(IRC_HEADING, UCC_FILING_IRC, pendingTask);
            tableData += pdfTableRowBuilder(UNIQUE_IDENTIFIER_HEADING, UCC_FILING_UNIQUE_IDENTIFIER, pendingTask);
            tableData += pdfTableRowBuilder(PortalConstants.CL_PARTY_NAME, UCC_FILING_CL, pendingTask);
            tableData += pdfTableRowBuilder(PortalConstants.SALES_AGENT_PARTY_NAME, UCC_FILING_SALES_REP, pendingTask);

            tableRow = PDF_HTML_TR_START;
            tableRow += PDF_HTML_TD;
            tableRow += PDF_HTML_TR_END;
            tableData += tableRow;

            tableData += pdfPendingTaskTableRowBuilder(pendingTask);
            tableData += PDF_TABLE_END;
            tableData += PDF_LINE_BREAK;
        }
        tableData+=PDF_END;

        return tableData;
    }

    
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportPendingTaskReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List< Map<String, Object> > pendingTaskList = PortalFetchPendingTaskAPI.getPendingTaskReport();
        slNo = 1;
        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(pendingTaskList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = exportCSVpendingTaskReport(pendingTaskList);
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
  
        } else if (exportType.equals(PDF_VALUE)) {
            String tableData = exportPDFPendingTaskReport(pendingTaskList);
            resultMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));

            // converting html string to pdf blob and returning
        }
        return resultMap;
    }

    /**
    * @description - this method exports active loan report 
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
            String tableData = CSV_HEADING_MAP.get(PortalConstants.ACTIVE_LOAN_REPORT);

            tableData+=PortalReportsHelper.createTableForExportActiveLoanReport(objApplicationList);

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
 
        }

        return resultMap;
    }


    /**
    * @description - this method exports end of year report
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
            String tableData = CSV_HEADING_MAP.get(PortalConstants.EOY_REPORT);

            tableData+=PortalReportsHelper.createTableForEndOfYearReport(objApplicationList);

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;
    }

    /**
    * @description - this method exports end of month active loan report
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
            String tableData = CSV_HEADING_MAP.get(PortalConstants.EOM_ACTIVE_LOAN_REPORT);
            tableData+=PortalReportsHelper.createTableForEndOfMonthActiveLoanReport(resultList);
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;

    }

    /**
    * @description - this method exports current crop year report
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
            tableData+=PortalReportsHelper.createTableForCurrentCropYearReport(objApplicationList);
         
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;
    }

    /**
    * @description - this method exports prior crop year report
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
            tableData+=PortalReportsHelper.createTableForPriorCropYearReport(objApplicationList);
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;
    }
    /**
    * @description - this method exports rate change notification report
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportRateChangeNotificationReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<Map<String, Object>> rateChangeList = PortalReportsHandler.getRateChangeNotificationReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(rateChangeList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PortalConstants.RATE_CHANGE_NOTIFICATION_REPORT);
            tableData+=PortalReportsHelper.createTableForRateChangeNotificationReport(rateChangeList);
            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;
    }

    /**
    * @description - this method exports online users report
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportOnlineUsersReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<Map<String, Object>> onlineUserList = PortalReportsHandler.getOnlineUsersReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(onlineUserList);
        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PortalConstants.ONLINE_USERS_REPORT);
            tableData+=PortalReportsHelper.createTableForOnlineUsersReport(onlineUserList);

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;

    }

    /**
    * @description - this method exports subsidy accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportSubsidyAccrualReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__Application_Fee_Payment__c> appFeePaymentList = PortalReportsHandler.getSubsidyAccrualReport(reportFilter);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(appFeePaymentList);
        

        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PortalConstants.SUBSIDY_ACCRUAL_REPORT);
            tableData+=PortalReportsHelper.createTableForSubsidyAccrualReport(appFeePaymentList);

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;

    }

    /**
    * @description - this method exports premium accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportPremiumAccrualReport(String reportFilter, String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__Application_Fee_Payment__c> appFeePaymentList = PortalReportsHandler.getPremiumAccrualReport(reportFilter);

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(appFeePaymentList);
        

        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PortalConstants.PREMIUM_ACCRUAL_REPORT);
            tableData+=PortalReportsHelper.createTableForPremiumAccrualReport(appFeePaymentList);


            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;

    }

    /**
    * @description - this method exports loan account report
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
            String tableData = CSV_HEADING_MAP.get(PortalConstants.LOAN_ACCOUNT_REPORT);
            tableData+=PortalReportsHelper.createTableForLoanAccrualReport(resultList);

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;

    }

    /**
    * @description - his method exports ACH Batch History report
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
            String tableData = CSV_HEADING_MAP.get(PortalConstants.ACH_BATCH_HISTORY_REPORT);
            String tableRow = PortalConstants.EMPTY_STRING;

            // looping through the parties and crafting the csv table from the application data
            for (genesis__funding_transaction__c objFundingTransaction : objFundingTransactionList) {
                
                tableRow = PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Loan_Number__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.genesis__Amount__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objFundingTransaction.Pricing_Detail__c,objFundingTransaction.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__c,objFundingTransaction.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objFundingTransaction.genesis__Reference__c))
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getString(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Internal_Reference_Code__c))
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Crop_Year__c);

                tableData += tableRow.removeEnd(COMMA_STRING) + PortalConstants.NEWLINE_STRING;
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;

    }

    /**
    * @description - this method exports Draft History report
    * @author Sk Minsar | 11-13-2023 
    * @param exportType 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> exportDraftHistoryReport(String exportType) {
        Map<String, Object> resultMap = new Map<String, Object>(); 
        List<genesis__funding_transaction__c> objFundingTransactionList = PortalReportsHandler.getDraftHistoryReport();

        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(objFundingTransactionList);
        

        if (exportType.equals(CSV_VALUE)) {
            String tableData = CSV_HEADING_MAP.get(PortalConstants.DRAFT_HISTORY_REPORT);
            String tableRow = PortalConstants.EMPTY_STRING;

            // looping through the parties and crafting the csv table from the application data
            for (genesis__funding_transaction__c objFundingTransaction : objFundingTransactionList) {
                tableRow = PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Draft_Number__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.genesis__Amount__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Loan_Number__c)
                                + PortalReportsHelper.createCSVTableRow(objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Crop_Year__c)
                                + PortalReportsHelper.createCSVTableRow(PortalReportsHelper.getformatedDate(objFundingTransaction.CreatedDate));

                tableData += tableRow.removeEnd(COMMA_STRING) + PortalConstants.NEWLINE_STRING;
            }

            // converting comma-separated string to blob and returning
            resultMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));

        }

        return resultMap;
    }

    // this method is used to export all the reports having a filter
    List<clcommon.PortalCustomRemoteActionRecord> exportFilteredReports(String reportType, String reportFilter, String exportType){
        Map<String, Object> resultMap;
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

        if (reportType.equals(PortalConstants.EOM_ACTIVE_LOAN_REPORT)) {
            resultMap = exportEndOfMonthActiveLoanReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        }else if (reportType.equals(PortalConstants.EOY_REPORT)) {
            resultMap = exportEndOfYearReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PortalConstants.ACTIVE_LOAN_REPORT)) {
            resultMap = exportActiveLoanReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        }else if (reportType.equals(PortalConstants.SUBSIDY_ACCRUAL_REPORT)) {
            resultMap = exportSubsidyAccrualReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PortalConstants.PREMIUM_ACCRUAL_REPORT)) {
            resultMap = exportPremiumAccrualReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PortalConstants.LOAN_ACCOUNT_REPORT)) {
            resultMap = exportLoanAccountReport(reportFilter, exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        }
        return responseData;

    }

    // this method is used to export all the reports not having a filter
    List<clcommon.PortalCustomRemoteActionRecord> exportUnfilteredReports(String reportType, String exportType){
        Map<String, Object> resultMap;
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

        if (reportType.equals(CURRENT_CROP_YEAR_REPORT)) {
            resultMap = exportCurrentCropYearReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PRIOR_CROP_YEAR_REPORT)) {
            resultMap = exportPriorCropYearReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PortalConstants.RATE_CHANGE_NOTIFICATION_REPORT)) {
            resultMap = exportRateChangeNotificationReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PortalConstants.ONLINE_USERS_REPORT)) {
            resultMap = exportOnlineUsersReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        }else if (reportType.equals(PortalConstants.DRAFT_HISTORY_REPORT)) {
            resultMap = exportDraftHistoryReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        } else if (reportType.equals(PortalConstants.PENDING_TASK_REPORT)) {
            resultMap = exportPendingTaskReport(exportType);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
        }
        return responseData;
    }
    
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
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
            reportType = String.valueOf(request.get(PortalConstants.KEY_REPORT_TYPE));
            exportType = String.valueOf(request.get(KEY_EXPORT_TYPE));

            if(FILTERED_REPORT_LIST.contains(reportType)){
                reportFilter = String.valueOf(request.get(KEY_REPORT_FILTER));
                responseData = exportFilteredReports(reportType,reportFilter,exportType);
            }else if(UNFILTERED_REPORT_LIST.contains(reportType)){
                responseData = exportUnfilteredReports(reportType,exportType);
            }else if (reportType.equals(PortalConstants.ACH_BATCH_HISTORY_REPORT)) {
                
                PortalReportsHelper.requiredParameterMissingThrowException(request);
                batchId = String.valueOf(request.get(KEY_BATCH_ID));

                resultMap = exportACHBatchHistoryReport(batchId, exportType);
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap)); 
            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  

        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
            PortalHelper.saveExceptionLog(objException, CLASSNAME);
        }
        return response;
    }
}