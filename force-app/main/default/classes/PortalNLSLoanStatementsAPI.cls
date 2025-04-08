/**********************************************************************************************************************
 * @description       : This portal API class helps in fetching all the loans statement details for a 
 *                      particular loan id from NLS.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 30-05-2022
 * @last modified by  : Subham Nandi
**********************************************************************************************************************/

global without sharing class PortalNLSLoanStatementsAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    public static final String CLASS_NAME = 'PortalNLSLoanStatementsAPI';
    public static final String KEY_STATEMENT_TYPE = 'statementType';
    // parameters specific for this class [end]
    
    /**
    * @description - Purpose of this method is to fetch all the loans statement details for a 
    *                particular loan id from NLS
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        String loanId;
        String statementType = '';
        clcommon.Response objResponse = new clcommon.Response();
        List<Object> parsedResponseList = new List<Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
        try {
            List<User> currentUserList =  [SELECT  Id, 
                                        accountId 
                                FROM User 
                                WHERE Id =: UserInfo.getUserId()];
            //Check required params.
            if (null == argumentsFromPortal.get(PortalConstants.LOAN_ID)){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            loanId = String.valueOf(argumentsFromPortal.get(PortalConstants.LOAN_ID));
            if(String.isNotBlank(String.valueOf(argumentsFromPortal.get(KEY_STATEMENT_TYPE)))){
                statementType = String.valueOf(argumentsFromPortal.get(KEY_STATEMENT_TYPE));
            }
            if(statementType != null &&
                currentUserList.size() > 0){
                parsedResponseList = NLSCallout.nlsGetLoanStatementsCalloutMethod(currentUserList[0].accountId, loanId, statementType) ;

                if(parsedResponseList == null) {
                    throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
                }

                for (Object data : parsedResponseList) {
                    Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(data));
                    dataMap.put('Statement_Date', Date.valueOf((String) dataMap.get('Statement_Date')));

                    responseDataList.add( new clcommon.PortalCustomRemoteActionRecord(dataMap));
                }
            }
           
            objResponse = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            objResponse.status = clcommon.Constants.SUCCESS; 
        } catch (CustomException objCustomException) {
            objResponse.status = clcommon.Constants.API_EXCEPTION;
            objResponse.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            objResponse.status = clcommon.Constants.API_EXCEPTION; 
            objResponse.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return objResponse;
    }
}

// 2023-02-09T00:00:00