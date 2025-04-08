/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-06-2025
 * @last modified by  : Tuhin Bhunia
**/

global without sharing class PortalReportsAPI implements clcommon.PortalCustomRemoteAPI1 {

    // parameters specific for this class [start]
    private final String CLASSNAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private static final List<String> FILTERED_REPORT_LIST = new List<String>{ PortalConstants.EOM_ACTIVE_LOAN_REPORT, PortalConstants.EOY_REPORT, PortalConstants.LOAN_ACCOUNT_REPORT, PortalConstants.EOM_SUBSIDY_ACCRUAL_REPORT, PortalConstants.EOM_PREMIUM_ACCRUAL_REPORT};
    private static final List<String> UNFILTERED_REPORT_LIST = new List<String>{PortalConstants.RATE_CHANGE_NOTIFICATION_REPORT, PortalConstants.ONLINE_USERS_REPORT, PortalConstants.CURRENT_CROP_YEAR_REPORT, PortalConstants.PRIOR_CROP_YEAR_REPORT};

    /**
    * @description generate response data for the reports which have a filter
    * @author Rahul Gupta | 03-19-2024 
    * @param reportType 
    * @param reportFilter 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    List<clcommon.PortalCustomRemoteActionRecord> getFilteredReport(String reportType, String reportFilter){
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

            if(reportType.equals(PortalConstants.EOM_ACTIVE_LOAN_REPORT)) {
                List<Map<String, Object>> resultList = PortalReportsHandler.getEndOfMonthActiveLoanReport(reportFilter);
                responseData = PortalReportsHandler.getResponseDataFromList(resultList);
            } 
            else if (reportType.equals(PortalConstants.EOY_REPORT)) {
                List<Map<String, Object>> resultList = PortalReportsHandler.getEndOfYearReport(reportFilter);
                responseData = PortalReportsHandler.getResponseDataFromList(resultList);
            } else if (reportType.equals(PortalConstants.LOAN_ACCOUNT_REPORT)) {
                List<Map<String, Object>> resultList = PortalReportsHandler.getLoanAccountReport(String.valueOf(reportFilter));
                responseData = PortalReportsHandler.getResponseDataFromList(resultList);
            } else if (reportType.equals(PortalConstants.EOM_SUBSIDY_ACCRUAL_REPORT)) {
                List<genesis__Application_Fee_Payment__c> resultList = PortalReportsHandler.getSubsidyAccrualReport(reportFilter);
                responseData = PortalReportsHandler.getResponseDataFromList(resultList);
            } else if (reportType.equals(PortalConstants.EOM_PREMIUM_ACCRUAL_REPORT)) {
                List<genesis__Application_Fee_Payment__c> resultList = PortalReportsHandler.getPremiumAccrualReport(reportFilter);
                responseData = PortalReportsHandler.getResponseDataFromList(resultList);
            } 

        return responseData;   
    }

    
    /**
    * @description method to generate response data for the reports which does not have a filter
    * @author Rahul Gupta | 03-19-2024 
    * @param reportType 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    List<clcommon.PortalCustomRemoteActionRecord> getUnfilteredReport(String reportType){
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

        if (reportType.equals(PortalConstants.RATE_CHANGE_NOTIFICATION_REPORT)) {
            List<Map<String, Object>> resultList = PortalReportsHandler.getRateChangeNotificationReport();
            responseData = PortalReportsHandler.getResponseDataFromList(resultList);
        } else if (reportType.equals(PortalConstants.ONLINE_USERS_REPORT)) {
            List<Map<String, Object>> resultList = PortalReportsHandler.getOnlineUsersReport();
            responseData = PortalReportsHandler.getResponseDataFromList(resultList);
        } else if (reportType.equals(PortalConstants.CURRENT_CROP_YEAR_REPORT)) {
            List<genesis__Applications__c> objApplicationList = PortalReportsHandler.getCurrentCropYearReport();
            responseData = PortalReportsHandler.getResponseDataFromList(objApplicationList);
        } else if (reportType.equals(PortalConstants.PRIOR_CROP_YEAR_REPORT)) {
            List<genesis__Applications__c> applicationList = PortalReportsHandler.getPriorCropYearReport();
            responseData = PortalReportsHandler.getResponseDataFromList(applicationList);
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

        String reportType;
        String reportFilter;
        
        try {
            reportType = (String) request.get(PortalConstants.KEY_REPORT_TYPE);

            PortalReportsHelper.reportTypeMissingThrowException(request);
            // if (String.isBlank(reportType)) {
            //     throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            // }

            if(FILTERED_REPORT_LIST.contains(reportType)){

                reportFilter = (String) request.get(PortalConstants.KEY_REPORT_FILTER);
                responseData = getFilteredReport(reportType, reportFilter);
            } else if(UNFILTERED_REPORT_LIST.contains(reportType)){

                responseData = getUnfilteredReport(reportType);
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 

        } catch (CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, CLASSNAME);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION; 
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASSNAME);
        }
        
        return response;
    }

}