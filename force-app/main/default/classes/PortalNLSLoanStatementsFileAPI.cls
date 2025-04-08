/**********************************************************************************************************************
 * @description       : This portal API class gets a Base64 encoded PDF File for a given Loan Statement Id from NLS.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : Ayan Bhowmik
**********************************************************************************************************************/

global without sharing class PortalNLSLoanStatementsFileAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    public static final String CLASS_NAME = 'PortalNLSLoanStatementsFileAPI';
    public static final String KEY_STATEMENT_ID = 'statementId';
    // parameters specific for this class [end]
    
    /**
    * @description - Purpose of this method is to gets a Base64 encoded PDF File for a given Loan Statement Id from NLS.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(  String componentStrName,
                                            String[] disclosureNames, 
                                            Map<String, Object> argumentsFromPortal) {
        String statementId;
        clcommon.Response objResponse = new clcommon.Response();
        Map<String, Object> parsedResponseMap = new Map<String, Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
        try {
            List<User> currentUserList =  [SELECT  Id, 
                                        accountId 
                                FROM User 
                                WHERE Id =: UserInfo.getUserId()];
            if (argumentsFromPortal.get(KEY_STATEMENT_ID) == null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            statementId = String.valueOf(argumentsFromPortal.get(KEY_STATEMENT_ID));
            if(statementId != null &&
                currentUserList.size() > 0){
                parsedResponseMap = NLSCallout.nlsGetLoanStatementsFileCalloutMethod(currentUserList[0].accountId, statementId);
            }
            if(parsedResponseMap == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            responseDataList.add( new clcommon.PortalCustomRemoteActionRecord(parsedResponseMap));
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