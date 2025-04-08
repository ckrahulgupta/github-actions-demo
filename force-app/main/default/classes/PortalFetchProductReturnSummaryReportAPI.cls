/**
 * @description       : This class is used to fetch all the Product Returns and show it in Reports Tile in Dealer Portal.
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Rahul Gorai
**/
global without sharing class PortalFetchProductReturnSummaryReportAPI implements clcommon.PortalCustomRemoteAPI1{

    private final String CLASSNAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));

    /**
     * @description : This method is used to fetch the Product Return report based on with filter or without filter.
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

        String reportType;
        Map<String, String> requestDataMap = new Map<String, String>();

        try{

            reportType = (String) request.get(PortalConstants.KEY_REPORT_TYPE);
            if(String.isBlank(reportType)) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            if(reportType.equals(PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT)){

                requestDataMap.put(PortalConstants.KEY_REPORT_FILTER, (String) request.get(PortalConstants.KEY_REPORT_FILTER));
                requestDataMap.put(PortalConstants.KEY_REPORT_TYPE, (String) request.get(PortalConstants.KEY_REPORT_TYPE));
                requestDataMap.put(PortalConstants.KEY_FROM_DATE, (String) request.get(PortalConstants.KEY_FROM_DATE));
                requestDataMap.put(PortalConstants.KEY_TO_DATE, (String) request.get(PortalConstants.KEY_TO_DATE));
                requestDataMap.put(PortalConstants.KEY_SEARCH_FILTER, (String) request.get(PortalConstants.KEY_SEARCH_FILTER));
                
                responseData = getFilteredReport(requestDataMap);
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 

        } catch(CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, CLASSNAME);
        } catch(Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION; 
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASSNAME);
        }
        return response;
    }

    List<clcommon.PortalCustomRemoteActionRecord> getFilteredReport(Map<String, String> requestDataMap){

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        String reportType = requestDataMap.get(PortalConstants.KEY_REPORT_TYPE);

        if(reportType.equals(PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT)){

            List<Map<String, Object>>  resultList = getProductReturnSummaryReport(requestDataMap);
            for(Map<String, Object> result : resultList){
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(result));
            }
        }
        return responseData;  
    }

    /**
     * @description : This method is used to get the Product Return Summary Report
     * @param requestDataMap 
     * @return  `List<Map<String, Object>>`
     */
    public List<Map<String, Object>> getProductReturnSummaryReport(Map<String, String> requestDataMap){

        String reportFilter = requestDataMap.get(PortalConstants.KEY_REPORT_FILTER);
        String searchFilter = requestDataMap.get(PortalConstants.KEY_SEARCH_FILTER);
        String fromDate = requestDataMap.get(PortalConstants.KEY_FROM_DATE);
        String toDate = requestDataMap.get(PortalConstants.KEY_TO_DATE);

        List<genesis__Funding_Transaction__c> fundingTransactionList = new List<genesis__Funding_Transaction__c>();
        List<Map<String, Object>> productReturnSummaryList = new List<Map<String, Object>>();

        if(!String.isBlank(searchFilter)){

            fundingTransactionList = [SELECT Id,
                                            Name,
                                            CreatedDate,
                                            CreatedBy.Account.Name,
                                            Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name,
                                            Pricing_Detail__r.Loan_Number__c,
                                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            Pricing_Detail__r.genesis__Application__r.Crop_Year__c,
                                            Pricing_Detail__r.genesis__Application__r.Unique_Identifier__c,
                                            genesis__Amount__c,
                                            genesis__Reference__c
                                        FROM genesis__Funding_Transaction__c 
                                        WHERE Pricing_Detail__r.genesis__Application__r.Dealer_Name__c =: PortalReportsHelper.getDealerAccountId()
                                        AND genesis__Payment_Mode__r.name =: PortalConstants.PRODUCT_RETURN 
                                        AND (Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name LIKE :('%' + searchFilter + '%')
                                                OR Pricing_Detail__r.Loan_Number__c LIKE :(searchFilter + '%')
                                                OR Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c LIKE :(searchFilter + '%')
                                                OR Pricing_Detail__r.genesis__Application__r.Crop_Year__c LIKE :(searchFilter + '%')
                                                OR genesis__Reference__c LIKE :(searchFilter + '%')
                                                OR CreatedBy.Account.Name LIKE :('%' + searchFilter + '%')
                                            )
                                        ORDER BY CreatedDate];

            productReturnSummaryList = PortalReportsHelper.getProductReturnSummaryList(fundingTransactionList);

        }else if(!String.isBlank(fromDate) && !String.isBlank(toDate)){

            Datetime fromDateDT = datetime.newInstanceGMT(Date.valueOf(fromDate).year(),
                                                          Date.valueOf(fromDate).month(),
                                                          Date.valueOf(fromDate).day(),
                                                          0,
                                                          0,
                                                          0
                                                        );
            Datetime toDateDT = datetime.newInstanceGMT(Date.valueOf(toDate).year(),
                                                        Date.valueOf(toDate).month(),
                                                        Date.valueOf(toDate).day(),
                                                        23,
                                                        59,
                                                        59
                                                    );
            fundingTransactionList = [SELECT Id,
                                            Name,
                                            CreatedDate,
                                            CreatedBy.Account.Name,
                                            Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name,
                                            Pricing_Detail__r.Loan_Number__c,
                                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            Pricing_Detail__r.genesis__Application__r.Crop_Year__c,
                                            Pricing_Detail__r.genesis__Application__r.Unique_Identifier__c,
                                            genesis__Amount__c,
                                            genesis__Reference__c
                                        FROM genesis__Funding_Transaction__c 
                                        WHERE Pricing_Detail__r.genesis__Application__r.Dealer_Name__c =: PortalReportsHelper.getDealerAccountId()
                                        AND genesis__Payment_Mode__r.name =: PortalConstants.PRODUCT_RETURN 
                                        AND CreatedDate >= :fromDateDT
                                        AND CreatedDate <= :toDateDT
                                        ORDER BY CreatedDate
                                    ];

            productReturnSummaryList = PortalReportsHelper.getProductReturnSummaryList(fundingTransactionList);

        }else if(!String.isBlank(reportFilter)){

            Datetime fromDateDT = datetime.newInstanceGMT(Date.valueOf(reportFilter).year(),
                                                          Date.valueOf(reportFilter).month(),
                                                          Date.valueOf(reportFilter).day(),
                                                          0,
                                                          0,
                                                          0
                                                        );
            Datetime toDateDT = datetime.newInstanceGMT(Date.valueOf(reportFilter).year(),
                                                        Date.valueOf(reportFilter).month(),
                                                        Date.valueOf(reportFilter).day(),
                                                        23,
                                                        59,
                                                        59
                                                    );
            fundingTransactionList = [SELECT Id,
                                            Name,
                                            CreatedDate,
                                            CreatedBy.Account.Name,
                                            Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name,
                                            Pricing_Detail__r.Loan_Number__c,
                                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            Pricing_Detail__r.genesis__Application__r.Crop_Year__c,
                                            Pricing_Detail__r.genesis__Application__r.Unique_Identifier__c,
                                            genesis__Amount__c,
                                            genesis__Reference__c
                                        FROM genesis__Funding_Transaction__c 
                                        WHERE Pricing_Detail__r.genesis__Application__r.Dealer_Name__c =: PortalReportsHelper.getDealerAccountId()
                                        AND genesis__Payment_Mode__r.name =: PortalConstants.PRODUCT_RETURN 
                                        AND CreatedDate >= :fromDateDT
                                        AND CreatedDate <= :toDateDT
                                        ORDER BY CreatedDate];

            productReturnSummaryList = PortalReportsHelper.getProductReturnSummaryList(fundingTransactionList);
        }else{
            fundingTransactionList = [SELECT Id,
                                            Name,
                                            CreatedDate,
                                            CreatedBy.Account.Name,
                                            Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name,
                                            Pricing_Detail__r.Loan_Number__c,
                                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            Pricing_Detail__r.genesis__Application__r.Crop_Year__c,
                                            Pricing_Detail__r.genesis__Application__r.Unique_Identifier__c,
                                            genesis__Amount__c,
                                            genesis__Reference__c
                                        FROM genesis__Funding_Transaction__c 
                                        WHERE Pricing_Detail__r.genesis__Application__r.Dealer_Name__c =: PortalReportsHelper.getDealerAccountId()
                                        AND genesis__Payment_Mode__r.name =: PortalConstants.PRODUCT_RETURN
                                        ORDER BY CreatedDate];

            productReturnSummaryList = PortalReportsHelper.getProductReturnSummaryList(fundingTransactionList);
        }
        return productReturnSummaryList;
    }
}