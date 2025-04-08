/**
 * @description       : This class is called by External Platform to stores the signing method of a borrower/principal for an application.
 * @author            : Suraj Kumar | 05-29-2024
 * @group             : 
 * @last modified on  : 02-27-2025
 * @last modified by  : Krishanu Chinya
**/
@RestResource(urlMapping = '/api/v1/external/saveSigningMethod')
global without sharing class ExternalSaveSigningMethodAPI {

    private static final String CLASS_NAME = ExternalSaveSigningMethodAPI.class.getName();

    static Account dealerForExtUser;
    static Set<String> resendDocsignAppStatusSet = new Set<String>{
        ExternalConstants.NEW_ENTERED_APPLICATION_STATUS,
        ExternalConstants.E_SIGN_PENDING_APPLICATION_STATUS,
        ExternalConstants.SIGNATURE_COMPLETED_APPLICATION_STATUS,
        ExternalConstants.NEW_SCORECARD_GENERATED_APPLICATION_STATUS,
        ExternalConstants.PENDING_APPROVAL_APPLICATION_STATUS
    };
    static Set<String> saveSigningAppStatusSet = new Set<String>{
        ExternalConstants.NEW_ENTERED_APPLICATION_STATUS,
        ExternalConstants.E_SIGN_PENDING_APPLICATION_STATUS
    };
    static List<clcommon__Party__c> borrowerPartyList = new List<clcommon__Party__c>();
    static List<clcommon__Party__c> principalPartyList = new List<clcommon__Party__c>();
    
    /**
    * @description : Http post method to Save Signing Method on application
    * @author Suraj Kumar | 05-29-2024 
    **/
    @HttpPost
    global static void doSaveSigningMethod(){
        RestRequest requestParam = RestContext.request;
        String requestBody = requestParam.requestBody.toString();
        String applicationId;
        String userId;
        String signingMethod;
        Map<String, Object> responseMap = new Map<String, Object>();
        RestResponse responseObj = RestContext.response;
        Map<String, Object> contentMap = new Map<String, Object>();
        Map<String, Object> bodyMap = new Map<String, Object>();
        Boolean isResendDocusign = false;
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            responseObj.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            if (String.isBlank(requestBody)) {
                ExternalExceptionUtil.throwCustomException(ExternalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);

            ExternalApplicationOriginationUtil.checkForNullObject(requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY), ExternalConstants.APPLICATION_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForNullObject(requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY), ExternalConstants.BORROWER_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForNullObject(requestMap.get(ExternalConstants.SIGNING_METHOD_KEY), ExternalConstants.SIGNING_METHOD_MISSING);

            Map<String,Object> applicationDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
            Map<String,Object> userDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
            Map<String,Object> signingMethodMap = (Map<String,Object>) requestMap.get(ExternalConstants.SIGNING_METHOD_KEY);

            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  
            dealerForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);

            ExternalApplicationOriginationUtil.checkForNullObject(applicationDetailsMap.get(ExternalConstants.ID_KEY), ExternalConstants.APPLICATION_ID_MISSING);
            ExternalApplicationOriginationUtil.checkForNullObject(userDetailsMap.get(ExternalConstants.USER_ID_KEY), ExternalConstants.USER_ID_MISSING);
            ExternalApplicationOriginationUtil.checkForNullObject(signingMethodMap.get(ExternalConstants.TYPE_KEY), ExternalConstants.SIGNING_METHOD_MISSING);

            applicationId = String.valueOf(applicationDetailsMap.get(ExternalConstants.ID_KEY));
            userId = String.valueOf(userDetailsMap.get(ExternalConstants.USER_ID_KEY));
            signingMethod = String.valueOf(signingMethodMap.get(ExternalConstants.TYPE_KEY));

            if (signingMethodMap.containsKey(ExternalConstants.RESEND_DOCUSIGN_KEY)) {
                isResendDocusign = Boolean.valueOf(signingMethodMap.get(ExternalConstants.RESEND_DOCUSIGN_KEY));
            }

            ExternalSecurityUtil.validateBorrowerWithApplication(applicationId,userId,dealerForExtUser.Id);

            ExternalSaveSigningMethodValidationUtil.validateSigningMethod(signingMethod);

            List<clcommon__Party__c> applicantPartyList = [SELECT Id, 
                                                                    clcommon__Account__c,
                                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                    clcommon__Account__r.Name,
                                                                    clcommon__Account__r.clcommon__Email__c,
                                                                    clcommon__Contact__c,
                                                                    clcommon__Contact__r.FirstName,
                                                                    clcommon__Contact__r.LastName,
                                                                    clcommon__Contact__r.genesis__SSN__c,
                                                                    clcommon__Contact__r.Confirm_SSN__c,
                                                                    clcommon__Contact__r.Birthdate,
                                                                    clcommon__Contact__r.Email,
                                                                    clcommon__Account__r.genesis__Business_information__c,
                                                                    clcommon__Account__r.genesis__Business_information__r.genesis__Total_Assets__c,
                                                                    clcommon__Account__r.genesis__Business_information__r.genesis__Total_Liabilities__c,
                                                                    clcommon__Account__r.genesis__Business_information__r.genesis__Tax_Identification_Number__c,
                                                                    clcommon__Type__r.Name,
                                                                    Total_Assets__c,
                                                                    Total_Liabilities__c,
                                                                    DocuSign_URL__c,
                                                                    Sent_Url__c,
                                                                    DocuSign_Generation_Time__c,
                                                                    DocuSign_Signing_Status__c,
                                                                    Street__c,
                                                                    City__c,
                                                                    State__c,
                                                                    Postal_Code__c,
                                                                    County__c,
                                                                    Mobile_Number__c,
                                                                    Work_Number__c,
                                                                    Home_Number__c,
                                                                    Marital_Status__c
                                                                FROM clcommon__Party__c
                                                                WHERE genesis__Application__r.Id=:applicationId 
                                                                AND (clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY 
                                                                OR clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY)];

            getApplicantInfo(applicantPartyList);

            List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Signing_Method__c,
                                                                Stage__c,
                                                                genesis__Status__c,
                                                                Dealer_Name__r.Coop_Type__c,
                                                                Coop_Type__c,
                                                                Landus_Generate_Credit_Agreement__c,
                                                                genesis__Loan_Amount__c,
                                                                Agreement_Sign__c,
                                                                DocuSign_Credit_Agreement_Initiated__c,
                                                                Resend_Docusign__c
                                                            FROM genesis__Applications__c
                                                            WHERE Id = :applicationId];
            ExternalApplicationOriginationUtil.checkEmptyList(applicationList,ExternalConstants.APPLICATION_NOT_FOUND);

            checkApplicationStatus(applicationList[0],isResendDocusign);
            ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationList[0], borrowerPartyList);
            ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);

            if (isResendDocusign) {
                ExternalSaveSigningMethodHandler.handleResendDocusign(applicationList[0],signingMethod,applicantPartyList);
                bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.RESEND_DOCUSIGN_INITIATED);
            } else {
                ExternalSaveSigningMethodHandler.handleSaveSigningMethod(applicationList[0],signingMethod,applicantPartyList);
                bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.SIGNING_METHOD_SAVED);
            }

            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
            responseObj.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            responseObj.statusCode = ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE;
        } catch(CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.handleCustomException(customExceptionObj, CLASS_NAME, responseObj);
        } catch(Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.saveExceptionLog(exceptionObj, CLASS_NAME);
            ExternalExceptionUtil.setFailureResponse(responseObj,ExternalConstants.UNEXPECTED_ERROR);
        }
    }

    /**
    * @description : method to check application status for resend docusig and saving the singning method
    * @author Krishanu Chinya | 07-23-2024 
    * @param applicationObj 
    * @param isResendDocusign
    **/
    private static void checkApplicationStatus(genesis__Applications__c applicationObj, Boolean isResendDocusign){
        if (isResendDocusign && (!resendDocsignAppStatusSet.contains(applicationObj.genesis__Status__c))) {
            throw new CustomException(ExternalConstants.INVALID_APP_FOR_RESEND_DOCUSIGN);
        } else if (!isResendDocusign && (!saveSigningAppStatusSet.contains(applicationObj.genesis__Status__c))) {
            throw new CustomException(ExternalConstants.SIGNING_METHOD_CANNOT_BE_UPDATED);
        }
    }

    /**
    * @description : method to get Borrower and principal party
    * @author Suraj Kumar | 05-29-2024 
    * @param applicantPartyList 
    **/
    private static void getApplicantInfo(List<clcommon__Party__c> applicantPartyList){
        for (clcommon__Party__c partyObj : applicantPartyList) {
            //Check whether Total Assets and Liabilities are present before signing
            ExternalSaveSigningMethodValidationUtil.validateAssetAndLiability(partyObj);
            if (partyObj.clcommon__Type__r.Name == ExternalConstants.BORROWER_PARTY ) {
                borrowerPartyList.add(partyObj);
                ExternalSaveSigningMethodValidationUtil.validateCoApplicant(applicantPartyList);
            } else if (partyObj.clcommon__Type__r.Name == ExternalConstants.PRINCIPAL_PARTY) {
                principalPartyList.add(partyObj);
            }
        }
    }
}