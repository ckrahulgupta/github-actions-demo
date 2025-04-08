/**
 * @description       : External Polling API for DocuSign 
 * @author            : Suraj Kumar | 06-19-2024
 * @group             : 
 * @last modified on  : 09-16-2024
 * @last modified by  : Suraj Kumar
**/
@RestResource(urlMapping = '/api/v1/external/docuSignPolling')
global without sharing class ExternalDocuSignPollingAPI {
    private static final String CLASS_NAME = ExternalDocuSignPollingAPI.class.getName();
    static Account dealerForExtUser;


    static Map<String, Object> responseMap = new Map<String, Object>();
    static Map<String, Object> contentMap = new Map<String, Object>();
    static Map<String, Object> bodyMap = new Map<String, Object>();
    /**
    * @description : Http post method to sent docusign url
    * @author Suraj Kumar | 06-19-2024 
    **/
    @HttpPost
    global static void doSentDocuSignUrl(){
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

            
            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  
            dealerForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);
            
            
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(applicationDetailsMap,ExternalConstants.ID_KEY, ExternalConstants.APPLICATION_ID_MISSING);
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(userDetailsMap,ExternalConstants.USER_ID_KEY, ExternalConstants.USER_ID_MISSING);

            applicationId = String.valueOf(applicationDetailsMap.get(ExternalConstants.ID_KEY));
            userId = String.valueOf(userDetailsMap.get(ExternalConstants.USER_ID_KEY));

            ExternalSecurityUtil.validateBorrowerWithApplication(applicationId,userId,dealerForExtUser.Id);


            genesis__Applications__c applicationObj = [SELECT Id,
                                                                Agreement_Sign__c,
                                                                genesis__Status__c,
                                                                genesis__Account__r.clcommon__Legal_Entity_Type__r.Name 
                                                            FROM genesis__Applications__c 
                                                            WHERE Id =: applicationId];
            ExternalDocuSignPollingHandler.checkAppStatus(applicationObj);
            List<clcommon__party__c> applicantPartyList = ExternalDocuSignPollingHandler.getApplicantParty(applicationObj);

            if(applicationObj.Agreement_Sign__c == true){
                bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.SIGNING_COMPLETED);
                contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
                responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
                responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
                response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                response.statusCode = ExternalConstants.TWO_HUNDRED_STATUS_CODE;
            }
            else if(applicantPartyList[0].DocuSign_Signing_Status__c == ExternalConstants.PARTY_STATUS_COMPLETED){
                bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.APPLICANT_SIGNING_COMPLETED);
                contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
                responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
                responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
                response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                response.statusCode = ExternalConstants.TWO_HUNDRED_STATUS_CODE;
            }
            else{
                sentDocuSignUrl(response,applicationObj,applicantPartyList);
            }
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

    /**
    * @description : method to sent docusign Url
    * @author Suraj Kumar | 06-19-2024 
    * @param response 
    * @param applicationObj 
    * @param applicantPartyList
    **/
    private static void sentDocuSignUrl(RestResponse response, genesis__Applications__c applicationObj, List<clcommon__party__c> applicantPartyList){
        List<dfsle__RecipientStatus__c> recipientStatusList = new List<dfsle__RecipientStatus__c>();
        
        List<dfsle__Envelope__c> envelopeList = [SELECT Id,
                                                        dfsle__DocuSignId__c 
                                                        FROM dfsle__Envelope__c 
                                                        WHERE dfsle__SourceId__c =:applicationObj.Id 
                                                        ORDER BY createddate Desc LIMIT 1];
        if(envelopeList.size()>0){
            recipientStatusList= [SELECT Id,
                                        dfsle__SourceId__c,
                                        dfsle__Status__c 
                                    FROM dfsle__RecipientStatus__c 
                                    WHERE dfsle__EnvelopeStatus__r.dfsle__SourceId__c=: applicationObj.Id 
                                    AND dfsle__EnvelopeStatus__r.dfsle__DocuSignId__c =: envelopeList[0].dfsle__DocuSignId__c 
                                    AND (dfsle__Status__c = :ExternalConstants.STATUS_SENT OR dfsle__Status__c = :ExternalConstants.STATUS_DELIVERED) LIMIT 1];
        }
        Decimal urlTime = ExternalDocuSignPollingHandler.getUrlTime(applicantPartyList);

        if(recipientStatusList.size()>0 && urlTime>=5 && applicantPartyList[0].clcommon__Contact__c == recipientStatusList[0].dfsle__SourceId__c){
            List<DocuSignPlatformEvent__e > docuSignEvents = new List<DocuSignPlatformEvent__e>();
            docuSignEvents.add(new DocuSignPlatformEvent__e(Application_Id__c = applicationObj.Id ));
            EventBus.publish(docuSignEvents);
            bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.PENDING_VALUE);
            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.PENDING_VALUE);
            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            response.statusCode = ExternalConstants.TWO_HUNDRED_TWO_STATUS_CODE;
        }
        else if(applicantPartyList[0].DocuSign_URL__c != null && applicantPartyList[0].Sent_Url__c ==false && urlTime<5){
            applicantPartyList[0].Sent_Url__c =true;
            Database.update(applicantPartyList,true);
            bodyMap.put(ExternalConstants.DOCUSIGN_URL_KEY, applicantPartyList[0].DocuSign_URL__c);
            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            response.statusCode = ExternalConstants.TWO_HUNDRED_STATUS_CODE;
        }
        else{
            bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.PENDING_VALUE);
            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.PENDING_VALUE);
            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            response.statusCode = ExternalConstants.TWO_HUNDRED_TWO_STATUS_CODE;
        }
    }
}