/**
 * @description       : This API is used to save the comment of the payment invoice
 * @author            : Suraj Kumar | 11-21-2024
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/
global without sharing class PortalSavePaymentReceiptCommentAPI implements clcommon.PortalCustomRemoteAPI1{
    /**
    * @description : Purpose of this method is to store comment on the invoice
    * @author Suraj Kumar | 11-21-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param requestMap 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                                String[] disclosureNames,
                                                Map<String, Object> requestMap) {
    
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        String comment;
        String invoiceId;
        Boolean isValidUser;
        
        try {
            PortalApplicationOriginationHelper.checkIfNullObject(requestMap, PortalConstants.REQUIRED_PARAMETERS_MISSING);

            PortalApplicationOriginationHelper.checkIfNullObject(requestMap.get(PortalConstants.INVOICE_ID_KEY), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkIfNullObject(requestMap.get(PortalConstants.COMMENT_KEY), PortalConstants.REQUIRED_PARAMETERS_MISSING);

            invoiceId = String.valueOf(requestMap.get(PortalConstants.INVOICE_ID_KEY));
            comment = String.valueOf(requestMap.get(PortalConstants.COMMENT_KEY));

            PortalApplicationOriginationHelper.checkBlankParameter(invoiceId, CustomMessageConstants.BLANK_INVOICE);
            PortalApplicationOriginationHelper.checkBlankParameter(comment, CustomMessageConstants.BLANK_COMMENT);

            List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id, 
                                                                            Application__c,
                                                                            Comment__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        WHERE Id = :invoiceId];
            PortalApplicationOriginationHelper.checkEmptyList(invoiceList,CustomMessageConstants.INVOICE_NOT_FOUND);

            isValidUser = PortalSecurityUtil.validateUserApplication(invoiceList[0].Application__c);
            if(!isValidUser){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            invoiceList[0].Comment__c = comment;
            Database.update(invoiceList[0],PortalConstants.TRUE_VALUE);

            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, PortalSavePaymentReceiptCommentAPI.class.getName());
        } 
        catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, PortalSavePaymentReceiptCommentAPI.class.getName());
        }
        return response;
    }
    
}