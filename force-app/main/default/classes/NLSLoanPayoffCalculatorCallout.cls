/**
 * @description       :  Callout class for Loan Payoff Calculator
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 12-12-2023
 * @last modified by  :  Pritam Roy
**/
global inherited sharing class NLSLoanPayoffCalculatorCallout{
    //Constants specific to this class starts
    private static final String PAYLOAD = 'payload';
    private static final String DATA = 'data';
    private static final String CLASS_NAME = 'NLSLoanPayoffCalculatorCallout';
    private static final String PAYOFF_DATE = 'payoffDate';
    private static final String LOAN_ID_LIST = 'loanIdList';
    //Constants specific to this class ends

    /**
    * @description check null variable
    * @author  Pritam Roy | 12-11-2023 
    * @param objVariable 
    * @param errorMsg 
    **/
    private static void checkVariable(Object objVariable,String errorMsg){
        if(objVariable == null){
            throw new CustomException(errorMsg);
        }
    }
   
    /**
    * @description Perform NLS Payoff Calulator callout
    * @author  Pritam Roy | 12-11-2023 
    * @param loanId 
    * @param payoffDate 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getPayoffDetails(List<String> loanId,String payoffDate) {
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        Map<String, Object> mainResponse = new Map<String,Object>();
        
        try {
            checkVariable(loanId,PortalConstants.EMPTY_ID_EXCEPION);
            checkVariable(payoffDate,PortalConstants.PAYOFF_DT_EXCEPTION);
            requestParamMap.put(PAYOFF_DATE,payoffDate);
            requestParamMap.put(LOAN_ID_LIST,loanId);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService( ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_PAYOFF_CALCULATOR,
                                                                                                                                queryIdMap,
                                                                                                                                requestParamMap);                                                                                                               
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
        }catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException,CLASS_NAME);
        }
        return mainResponse;
    }
}