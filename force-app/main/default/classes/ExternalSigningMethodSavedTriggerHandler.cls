/**
 * @description       : Handler class for ExternalSigningMethodSavedTrigger
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : Suraj Kumar
**/
public with sharing class ExternalSigningMethodSavedTriggerHandler {
    private static final String CLASS_NAME = ExternalSigningMethodSavedTriggerHandler.class.getName();

    /**
    * @description : Method to save signing method on application
    * @author Suraj Kumar | 06-03-2024 
    * @param signingMethodEventList 
    **/
    public static void saveSigningMethod(List<ExternalSigningMethodSaved__e> signingMethodEventList){
        String applicationId;
        String userId;
        String signingMethod;
        RestResponse response = RestContext.response;
        try{
            for(ExternalSigningMethodSaved__e event: signingMethodEventList){
                checkRequiredParameter(event);
                applicationId = event.Application_Id__c;
                userId = event.User_Id__c;
                signingMethod = event.Signing_Method__c;
            }

            ExternalSaveSigningMethodHandler.deleteExistingDocument(applicationId);

            genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c,
                                                                Stage__c,
                                                                Dealer_Name__r.Coop_Type__c,
                                                                Coop_Type__c,
                                                                Landus_Generate_Credit_Agreement__c,
                                                                genesis__Loan_Amount__c
                                                            FROM genesis__Applications__c
                                                            WHERE Id = :applicationId];

            applicationObj.Signing_Method__c = signingMethod;

            //Query the task for Signing
            List<Task> signedAgreementTaskList = [SELECT Id, 
                                                            Subject,
                                                            Status
                                                        FROM Task
                                                        WHERE Subject = :ExternalConstants.SIGNING_TASK 
                                                        AND genesis__Application__c = :applicationId];
            ExternalApplicationOriginationUtil.checkEmptyList(signedAgreementTaskList,ExternalConstants.SIGNED_AGREEMENT_TASK_MISSING);
            signedAgreementTaskList[0].Status = ExternalConstants.OPEN_TASK_STATUS;
            Database.update(signedAgreementTaskList,true);

            applicationObj.genesis__Status__c = ExternalConstants.E_SIGN_PENDING_APPLICATION_STATUS;
            Database.update(applicationObj,true);
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
    * @description : Method to check required parameter
    * @author Suraj Kumar | 06-03-2024 
    * @param event 
    **/
    private static void checkRequiredparameter(ExternalSigningMethodSaved__e event){
        if(event.Application_Id__c == null || event.Signing_Method__c == null || event.User_Id__c == null){
            throw new CustomException(ExternalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}