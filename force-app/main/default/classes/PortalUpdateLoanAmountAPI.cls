/**
 * @description       : This class is used for update loan amount after application score.
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 08-23-2024
 * @last modified by  : Sk Minsar
**/
global without sharing class PortalUpdateLoanAmountAPI implements clcommon.PortalCustomRemoteAPI1 {
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    
    /**
    * @description 
    * @author Sk Minsar | 08-23-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal){
        clcommon.Response response = new clcommon.Response();
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            response.status = clcommon.Constants.SUCCESS; 
        } catch(CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, CLASS_NAME);
        } catch(Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION; 
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }

}