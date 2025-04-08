/**
 * @description       : This Class is used to do callout for fetching the annual amount paid per year from NLS and return to portal
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing class PortalAnnualAmountPaidAPI implements clcommon.PortalCustomRemoteAPI1{
    
    private static final String NLS_LOAN_TRANSACTIONS_API = 'PortalAnnualAmountPaidAPI';
    private static final String KEY_LOAN_NUMBER = 'loanNumber';
    private static final String KEY_YEAR = 'calendar_year';
    private static final String KEY_CHILD_LOAN_YEAR = 'child_calendar_year';
    private static final String KEY_CHILD_LOAN_NUMBER = 'child_loan_number';
    private static final String KEY_LOAN_DESCRIPTION = 'child_loan_description';
    private static final String KEY_INTEREST_PAID = 'child_total_interest_paid';
    private static final String KEY_INTEREST_ACCRUED = 'child_total_interest_accrued';
    private static final String YEAR_NUMBER = 'Year_Number';
    private static final String INTEREST_EARNED = 'Interest_Earned';
    private static final String INTEREST_PAID = 'Interest_Paid';
    private static final String KEY_PRICING_ID_LIST = 'pricingIdList';

    private static final String API_TYPE = 'NLS Annual Amount Paid API Type';


    
    /**
     * @description This Method is called from the portal
     * @param componentStrName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> request) {
        string loanNumber;
        String year;

        clcommon.Response response = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String,String> loanNumberMap = new Map<String,String>();
        Map<String,String> descriptionMap = new Map<String,String>();

        try {                          
            //Check required params.
            
            checkRequestParam(KEY_LOAN_NUMBER,request);
            checkRequestParam(KEY_YEAR,request);
            
            loanNumber = String.valueOf(request.get(KEY_LOAN_NUMBER));
            year = String.valueOf(request.get(KEY_YEAR));

            validateUser(loanNumber);

                
            List<genesis__Application_Pricing_Detail__c> appPricingList = [SELECT Id,Loan_Id__c,Loan_Number__c,genesis__Rate_Card_Setup_detail__r.Description__c
                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                        WHERE genesis__Application__r.genesis__Loan_Number__c = :loanNumber and genesis__Enabled_Flag__c = true];

              
            List<Id> pricingIdList = new List<Id>();
            for(genesis__Application_Pricing_Detail__c pricingDetail : appPricingList){
                pricingIdList.add(pricingDetail.id);
                loanNumberMap.put(pricingDetail.Loan_Id__c,pricingDetail.Loan_Number__c);
                descriptionMap.put(pricingDetail.Loan_Id__c,pricingDetail.genesis__Rate_Card_Setup_detail__r.Description__c);
            }
            

            Map<String, Object> queryIdMap = new Map<String, Object> {
                KEY_PRICING_ID_LIST => pricingIdList
            };
            
            intframework.BaseIntegrationResponse responseObject;
            intframework.AbstractIntegrationService baseIntegrationService = 
            intframework.IntegrationServiceFactory.getBaseIntegrationService();

            responseObject = (intframework.BaseIntegrationResponse) baseIntegrationService.runSynchronousIntegrationService(
                                                                        ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                        API_TYPE,
                                                                        queryIdMap,
                                                                        new Map<String, Object>()
                                                                );

            if(responseObject == null){
                throw new CustomException(ConstantValues.INTEGRATION_FAILED);
            }

            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(responseObject.getBody());
            Map<String,Object> loanDetailsMap = new Map<String,Object>();
            if(responseMap.containsKey(year)){
                loanDetailsMap = (Map<String,Object>)responseMap.get(year);
            }

            List<Map<String,Object>> childLoanList = new List<Map<String,Object>>();
            for(String loanId : loanDetailsMap.keySet()){
                Map<String,Object> loanStatisticMap = (Map<String,Object>)loanDetailsMap.get(loanId);
                Decimal interestPaid = (Decimal)loanStatisticMap.get(INTEREST_PAID);

                Decimal accruedInterest = (Decimal)loanStatisticMap.get(INTEREST_EARNED);
                Map<String,Object> childLoanMap = new Map<String,Object>{
                    KEY_YEAR => loanStatisticMap.get(YEAR_NUMBER),
                    KEY_CHILD_LOAN_NUMBER => loanNumberMap.get(loanId),
                    KEY_LOAN_DESCRIPTION => descriptionMap.get(loanId),
                    KEY_INTEREST_PAID => interestPaid.setScale(2),
                    KEY_INTEREST_ACCRUED => accruedInterest.setScale(2)
                };
                childLoanList.add((Map<String,Object>)childLoanMap);
                responseData.add(new clcommon.PortalCustomRemoteActionRecord((Map<String,Object>)childLoanMap));
            }
            
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.status = clcommon.Constants.SUCCESS; 
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objException, NLS_LOAN_TRANSACTIONS_API);
        }
        return response; 
    }

    /**
     * @description Validate whether logged in user has an access or not
     * @param loanNumber 
     * @exception 
     */
    private static void validateUser(String loanNumber){
        List<genesis__Applications__c> applicationList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c =: loanNumber];
        if(applicationList.size() == 0){
            throw new CustomException(PortalConstants.NO_APPLICATIONS_FOUND);
        }
        String applicationId = applicationList[0].id;
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }

    /**
     * @description check the request param
     * @param param 
     * @param request 
     * @exception 
     */
    private static void checkRequestParam(String param,Map<String, Object> request){
        if (!request.containsKey(param) && request.get(param) == null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}