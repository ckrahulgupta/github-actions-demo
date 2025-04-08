/**
 * @description       : External API to get the application details
 * @author            : Suraj Kumar | 07-05-2024
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : Kabir Pramanik
**/
@RestResource(urlMapping = '/api/v1/external/getApplicationStatus')
global without sharing class ExternalApplicationDetailsAPI {
    private static final String CLASS_NAME = ExternalApplicationDetailsAPI.class.getName();
    static Account dealerForExtUser;

    /**
    * @description : Http post method to sent application details
    * @author Suraj Kumar | 07-05-2024 
    **/
    @HttpPost
    global static void doSentApplicationDetails(){
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> contentMap = new Map<String, Object>();
        Map<String, Object> bodyMap = new Map<String, Object>();
        RestRequest requestParam = RestContext.request;
        String requestBody = requestParam.requestBody.toString();
        String applicationId;
        String userId;
        RestResponse response = RestContext.response;
        try{
            response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            ExternalApplicationOriginationUtil.checkForBlankParameter(requestBody);
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);

            ExternalAdditionalInfoValidationUtil.validateRequiredKey(requestMap, ExternalConstants.APPLICATION_DETAIL_KEY, ExternalConstants.APPLICATION_DETAILS_MISSING);
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(requestMap, ExternalConstants.BORROWER_DETAIL_KEY, ExternalConstants.BORROWER_DETAILS_MISSING);

            Map<String,Object> applicationDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
            Map<String,Object> userDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);

            ExternalAdditionalInfoValidationUtil.validateRequiredKey(applicationDetailsMap,ExternalConstants.ID_KEY, ExternalConstants.APPLICATION_ID_MISSING);
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(userDetailsMap,ExternalConstants.USER_ID_KEY, ExternalConstants.USER_ID_MISSING);

            applicationId = String.valueOf(applicationDetailsMap.get(ExternalConstants.ID_KEY));
            userId = String.valueOf(userDetailsMap.get(ExternalConstants.USER_ID_KEY));

            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  

            dealerForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);
            ExternalSecurityUtil.validateBorrowerWithApplication(applicationId,userId,dealerForExtUser.Id);

            genesis__Applications__c applicationObj = [SELECT Id,
                                                                genesis__Status__c,
                                                                genesis__Credit_Rating__c,
                                                                genesis__Credit_Rating__r.Name
                                                            FROM genesis__Applications__c 
                                                            WHERE Id =: applicationId];
            String appStatus = applicationObj.genesis__Status__c == null ? ExternalConstants.NA_VALUE : applicationObj.genesis__Status__c;
            String creditRating = applicationObj.genesis__Credit_Rating__c == null ? ExternalConstants.NA_VALUE : applicationObj.genesis__Credit_Rating__r.Name;
            
            bodyMap.put(ExternalConstants.APP_STATUS_KEY, appStatus);
            bodyMap.put(ExternalConstants.CREDIT_RATING_KEY, creditRating);
            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            response.statusCode = ExternalConstants.TWO_HUNDRED_STATUS_CODE;
            
        }
        catch(CustomException customExceptionObj){
            ExternalExceptionUtil.saveExceptionLog(customExceptionObj, CLASS_NAME);
            if(customExceptionObj.getMessage().equals(ExternalConstants.USER_NOT_AUTHORISED)){
                ExternalExceptionUtil.setUnauthorizeResponse(response);
            }
            else{
                ExternalExceptionUtil.setFailureResponse(response,customExceptionObj.getMessage());
            }
        }
        catch(Exception exceptionObj){
            ExternalExceptionUtil.saveExceptionLog(exceptionObj, CLASS_NAME);
            ExternalExceptionUtil.setFailureResponse(response,ExternalConstants.UNEXPECTED_ERROR);
        }
    }
}