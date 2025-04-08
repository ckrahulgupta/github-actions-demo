/**********************************************************************************************************************
 * @description       : This portal API class helps in fetching all the payoff details and send them to portal.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 30-05-2022
 * @last modified by  : Subham Nandi
**********************************************************************************************************************/

global without sharing class PortalNLSActiveLoanAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    public static final String CLASS_NAME = 'PortalNLSActiveLoanAPI';
    public static final String KEY_STATUS_CODE = 'statusCode';
    public static final String KEY_MASTER_ACCTREFNO = 'masterAcctrefno';
    public static final String KEY_LOAN_TYPE = 'loanType';
    
    /**
    * @description - Purpose of this method is to fetch all the payoff details from NLS and send it to portal.
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {

        String statusCode = '';
        String loanType = '';
        String masterAcctrefno = '';
        clcommon.Response response = new clcommon.Response();
        List<Object> parsedResponseList = new List<Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        try {
            if (!String.isBlank((String)argumentsFromPortal.get(KEY_STATUS_CODE))){ 
                statusCode = (String)argumentsFromPortal.get(KEY_STATUS_CODE);
            }
            if(!String.isBlank((String)argumentsFromPortal.get(KEY_LOAN_TYPE))){
                loanType = (String)argumentsFromPortal.get(KEY_LOAN_TYPE);
            }
            if(!String.isBlank(String.valueof(argumentsFromPortal.get(KEY_MASTER_ACCTREFNO)))){
                masterAcctrefno = String.valueof(argumentsFromPortal.get(KEY_MASTER_ACCTREFNO));
            }
            List<User> currentUserList =[SELECT Id, 
                                                accountId,
                                                ProfileId
                                        FROM User 
                                        WHERE Id =: UserInfo.getUserId()];
            if(currentUserList.size() > 0){
                parsedResponseList = NLSCallout.nlsSearchLoanCalloutMethod( currentUserList[0].accountId, 
                                                                            currentUserList[0].ProfileId, 
                                                                            statusCode, 
                                                                            loanType, 
                                                                            masterAcctrefno);
            }
            if(parsedResponseList == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            for(Object parsedResponse: parsedResponseList) {
                responseData.add( new clcommon.PortalCustomRemoteActionRecord((Map<String,Object>)parsedResponse));
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 
        } catch (CustomException objCustomException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME); 
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;  
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
}