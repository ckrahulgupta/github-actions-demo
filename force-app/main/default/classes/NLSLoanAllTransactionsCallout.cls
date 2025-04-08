/**
 * @description       : Callout class for loan transaction
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 04-03-2024
 * @last modified by  : Sk Minsar
**/
global inherited sharing class NLSLoanAllTransactionsCallout {

    private static final String INTEGRATION_API_TYPE_LOAN_ALL_TRANSACTION = 'Loan All Transactions Integration API Type';
    private static final String CLASS_NAME = 'NLSLoanAllTransactionsCallout';


    /**
    * @description - Performs NLS TRANSACTIONS CALLOUT
    * @author Sk Minsar | 03-12-2024 
    * @param accountId 
    * @param loanIdList 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> nlsGetLoanTransactionsCalloutMethod(String accountId, List<String> loanIdList) {
		
            Map<String, Object> requestParamMap = new Map<String, Object>();
            Map<String, Object> queryIdMap = new Map<String, Object>();
            Map<String, Object> mainResponse = new Map<String, Object>();

            try{
                    requestParamMap.put(ConstantValues.ACCOUNT_ID, accountId);
                    requestParamMap.put(PortalConstants.LOAN_ID_LIST, loanIdList);
                    //Calling the integration framework
                    intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
                    intframework.BaseIntegrationResponse responseObject;
                    responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                            INTEGRATION_API_TYPE_LOAN_ALL_TRANSACTION,
                                                                                                                                            queryIdMap, requestParamMap);
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