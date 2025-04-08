/**********************************************************************************************************************
 * @description       : This class is responsible for adding all the additional information and store them in salesforce.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-22-2024
 * @last modified by  : Suraj Kumar
**********************************************************************************************************************/

global without sharing class PortalSaveAdditionalInfoAPI implements clcommon.PortalCustomRemoteAPI1{
    
    // parameters specific for this class [start]
    private static final String CLASS_NAME = PortalSaveAdditionalInfoAPI.class.getName();
    private static final String KEY_SAVE_TYPE = 'shouldValidate';
    private static final String KEY_INDIVIDUAL_CROP_SAVE = 'individualCropSave';
    private static final String KEY_APPLICATION = 'applicationId';
    private static final String KEY_SPOUSE_DETAILS = 'spouseDetails';
    private static final String KEY_ADDITIONAL_CROP_DETAILS = 'landownersDetails';
    private static final String KEY_POTENTIAL_BUYER_DETAILS = 'buyerDetails';
    private static final String KEY_CROP_INSURANCE_DETAILS = 'insuranceAgentDetails';
    private static final String FIELD_CONTACT_FIRST_NAME = 'clcommon__Contact__r.FirstName';
    private static final String FIELD_CONTACT_LAST_NAME = 'clcommon__Contact__r.LastName';
    private static final String FIELD_CONTACT_EMAIL = 'clcommon__Contact__r.Email';
    private static final String FIELD_CONTACT_SSN = 'clcommon__Contact__r.genesis__SSN__c';
    private static final String FIELD_CONTACT_MIDDLE_NAME = 'clcommon__Contact__r.ints__Middle_Name__c';
    private static final String FIELD_ACCOUNT_NAME = 'clcommon__Account__r.Name';
    private static final String FIELDS_ACCOUNT_COUNTY = 'clcommon__Account__r.Billing_County__c';
    private static final String FIELDS_ACCOUNT_EMAIL = 'clcommon__Account__r.clcommon__Email__c';
    private static final String FIELDS_ACCOUNT_PHONE = 'clcommon__Account__r.Phone';
    private static final String FIELDS_ACCOUNT_STREET = 'clcommon__Account__r.BillingStreet';
    private static final String FIELDS_ACCOUNT_CITY = 'clcommon__Account__r.BillingCity';
    private static final String FIELDS_ACCOUNT_STATE = 'clcommon__Account__r.BillingState';
    private static final String FIELDS_ACCOUNT_POSTAL_CODE = 'clcommon__Account__r.BillingPostalCode';
    // parameters specific for this class [end]

    // constants specific for saveCropInformation
    private static final String KEY_CROP_DETAILS = 'cropDetails';
    private static final String KEY_DOES_APPLICANT_FEED_COLLATERAL = 'feedCollateral';
    private static final String FEED_COLLATERAL_CHECKED_VALUE = 'Checked';
    private static final String FEED_COLLATERAL_UNCHECKED_VALUE = 'Unchecked';
    private static final String INSURANCE_PLAN_RP_VALUE = 'RP';
    private static final String INSURANCE_PLAN_ARP_VALUE = 'ARP';
    private static final String INSURANCE_PLAN_ARH_VALUE = 'ARH';
    private static final String AGGREGATE_KEY = 'expr0';
    private static final String PORTAL_SAVE_CROP_INFORMATION_API = 'PortalSaveCropInformationAPI';
    private static final String KEY_SHOULD_ADJUST_LOAN_AMOUNT = 'shouldAdjustLoanAmount';
    private static final String KEY_NEEDS_LOAN_AMT_ADJUSTMENT = 'needsLoanAmountAdjustment';
    private static final String KEY_LOAN_AMT_REDUCED_TO_ZERO = 'loanAmountReducedToZero';
    private static final String ACCOUNT_SOBJECT = 'Account';
    private static final String RECORD_TYPE_MAP = 'recordTypeMap';
    private static final String PARTY_TYPE_MAP = 'partyTypeMap';
    
    private static final String SPOUSE_DETAILS = 'spouseDetails';
    private static final String ADDITIONAL_CROP_DETAILS = 'additionalCropDetails';
    private static final String POTENTIAL_BUYERS_DETAILS = 'potentialBuyerdetails';
    private static final String CROP_INDURANCE_DETAILS = 'cropInsuranceDetails';
    private static final String PARTY_TYPE = 'partyType';
    private static final String BATCH_IDS = 'batchIds';


    /*******************************Declaration of global variables*******************************************/
    Boolean shouldAdjustLoanAmount = false;
    Boolean shouldValidate = false;
    String feedCollateral;
    String cropDetails = '';
    string spouseDetails = '';
    string additionalCropDetails = '';
    string potentialBuyerdetails = '';
    String cropInsuranceDetails = '';

    List<Object> spouseDetailsList = new List<Object>();
    List<Object> additionalCropDetailsList = new List<Object>();
    List<Object> potentialBuyerdetailsList = new List<Object>();
    List<Object> cropInsuranceDetailsList = new List<Object>();

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param cropDetails 
    * @param application 
    * @return List<clcommon__Collateral__c> 
    **/
    private static List<clcommon__Collateral__c> getCollateralInstances(String cropDetails, genesis__Applications__c application) {
        PortalApplicationOriginationHelper.validateCropDetails(cropDetails);

        List<Object> cropDetailsList = (List<Object>) JSON.deserializeUntyped (cropDetails);
        List<clcommon__Collateral__c> finalCollaterals = new List<clcommon__Collateral__c>();
        List<clcommon__Collateral__c> collateralsToValidate = new List<clcommon__Collateral__c>();
        List<Id> collateralIdsToValidate = new List<Id>();
        List<String> validCollateralId = new List<String>();

        for (Object crop : cropDetailsList) {
            Map<String, Object> collateralMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crop));
            
            clcommon__Collateral__c collateral = new clcommon__Collateral__c();
            collateral = PortalHelper.getCollateralDetails(collateralMap);

            if (!application.Does_Applicant_Feed_Above_Collaterals__c) {
                collateral.Percent_Fed__c = null;
            }
            if(PortalApplicationOriginationHelper.isCollateralBlank(collateral, application)){
                continue;
            }
            
            if(String.isBlank(collateral.Id)){
                collateral.genesis__Application__c = application.Id;
                finalCollaterals.add(collateral);
            }else{
                collateralIdsToValidate.add(collateral.Id);
                collateralsToValidate.add(collateral);
            }
        }

        if(collateralIdsToValidate.size()>0){
            List<clcommon__collateral__c> applicationCollateral = [SELECT Id
                                                                            FROM clcommon__collateral__c
                                                                            WHERE genesis__Application__c = :application.Id
                                                                                AND Id IN :collateralIdsToValidate];
            for(clcommon__collateral__c collateralObj: applicationCollateral){
                validCollateralId.add(String.valueOf(collateralObj.Id));
            }
        }

        for(clcommon__Collateral__c validateCollateralObj: collateralsToValidate){
            Boolean isValidCollateral = PortalSecurityUtil.validateCollteralsObj(validCollateralId, validateCollateralObj.Id);
            checkValidCollateral(isValidCollateral);
            finalCollaterals.add(validateCollateralObj);
        }

        return finalCollaterals;
    }


    /**
    * @description - Purpose of this method is to store all the additional information for an application.
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(
                            String componentStrName,
                            String[] disclosureNames, 
                            Map<String, Object> request
                        ) {

        SavePoint dbSavePoint = Database.setSavepoint();

        clcommon.Response response = new clcommon.Response();
        Map<String, Object> responseFieldsMap = new Map<String, Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        
        Boolean individualCropSave = false;
        String applicationId;

        try {
            // basic validations
            individualCropSave = getIndividualCropSave(request);
            shouldValidate = getShouldValidate(request);
            shouldAdjustLoanAmount = getShouldAdjustLoanAmount(request);

            assignAdditionalInfoDetails(request);

            applicationId = String.valueOf(request.get(KEY_APPLICATION));
            
            validateApplicationId(applicationId);
            
            genesis__Applications__c application = [SELECT Id,
                                                           genesis__Loan_Amount__c,
                                                           Additional_Information_Needed__c,
                                                           genesis__Credit_Rating__r.Name, 
                                                           Credit_Application_And_Agreement_Process__c,
                                                           Does_Applicant_Feed_Above_Collaterals__c
                                                    FROM genesis__Applications__c
                                                    WHERE Id = :applicationId
                                                    LIMIT 1];

            PortalApplicationOriginationHelper.validateUser(applicationId);
            
            responseFieldsMap.put(KEY_NEEDS_LOAN_AMT_ADJUSTMENT, false);

            if (shouldAdjustLoanAmount) {
                // when shouldAdjustLoanAmount = true, i.e. when the user has chosen "Yes" from portal
                // on the popup, as the collaterals are insufficient

                Double sumTotalCollateralsPrice = PortalApplicationOriginationHelper.totalCollateralPrice(applicationId);

                // updating the loan amount and returning the response
                application.genesis__Loan_Amount__c = sumTotalCollateralsPrice;

                Database.update(application, true);

                PortalApplicationOriginationHelper.isLoanAmountZero(sumTotalCollateralsPrice, responseFieldsMap);
                
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldsMap));
                response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData); 
                response.status = clcommon.Constants.SUCCESS;
                return response;
            }

            // Processing the collaterals
            updateApplicantFeedCollateral(feedCollateral, application);

            if (shouldValidate) {
                // when user clicks on "Save & Continue"
                List<clcommon__Collateral__c> collaterals = getCollateralInstances(cropDetails, application);

                if(validateCropInformation(collaterals, application, response)){
                    return response;
                }

                // when shouldAdjustLoanAmount = false, i.e. when the user is saving the collaterals
                // by clicking the "Save & Continue" button
                PortalApplicationOriginationHelper.persistCollaterals(collaterals, application.Id);

                PortalApplicationOriginationHelper.isLoanAmountAdjustment(application, responseFieldsMap);

            } else {
                // when user clicks on "Save & Exit"

                List<clcommon__Collateral__c> collaterals = getCollateralInstances(cropDetails, application);

                for (clcommon__Collateral__c collateral : collaterals) {
                    // validate request parameters if "shouldValidate" flag is set to "true"
                    if (!PortalValidationUtil.isValidCropInformation(
                                                        collateral, 
                                                        shouldValidate,
                                                        application.Does_Applicant_Feed_Above_Collaterals__c,
                                                        response
                                                    )) {
                        return response;
                    }
                }

                PortalApplicationOriginationHelper.persistCollaterals(collaterals, application.Id);
            }
            
            Map<String,String> additionalInfoMap = new Map<String,String>{
                SPOUSE_DETAILS => spouseDetails,
                ADDITIONAL_CROP_DETAILS => additionalCropDetails,
                POTENTIAL_BUYERS_DETAILS => potentialBuyerdetails,
                CROP_INDURANCE_DETAILS => cropInsuranceDetails,
                KEY_APPLICATION => applicationId,
                KEY_SAVE_TYPE => String.valueOf(shouldValidate)
            };
            updateAdditionalInfoDetails(individualCropSave, additionalInfoMap, responseFieldsMap);
            Database.update(application, true);

            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldsMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData); 
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
   

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param isValidCollateral 
    **/
    private static void checkValidCollateral(Boolean isValidCollateral){
        if (!isValidCollateral) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-02-2024 
    * @param applicationId 
    **/
    private static void validateApplicationId(String applicationId){
        if(String.isBlank(applicationId)){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-22-2023 
    * @param feedCollateral 
    * @param application 
    **/
    private static void updateApplicantFeedCollateral(String feedCollateral, genesis__Applications__c application){
        if (feedCollateral.equals(FEED_COLLATERAL_CHECKED_VALUE)) {
            application.Does_Applicant_Feed_Above_Collaterals__c = true;
        }
        else if (feedCollateral.equals(FEED_COLLATERAL_UNCHECKED_VALUE)) {
            application.Does_Applicant_Feed_Above_Collaterals__c = false;
        } else {
            throw new CustomException(PortalConstants.APPL_INVALID_FEED_COLLATERALS_TYPE);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-02-2024 
    * @param individualCropSave 
    * @param additionalInfoMap 
    * @param responseFieldsMap 
    **/
    public static void updateAdditionalInfoDetails(Boolean individualCropSave,  Map<String,String>  additionalInfoMap, Map<String, Object> responseFieldsMap){
        if(!individualCropSave){
            List<Id> batchIds = new List<Id>();
            PortalApplicationOriginationHelper.validateAdditionalInfoDetails(additionalInfoMap);
            // Processing spouse details
            Map<String,String> spouseRequestParamMap = additionalInfoMap;
            spouseRequestParamMap.put(PARTY_TYPE, PortalConstants.SPOUSE_PARTY_NAME);
            PortalSaveAdditionalInfoBatch spouseBatchObject = new PortalSaveAdditionalInfoBatch(spouseRequestParamMap);
            Id spouseBatchObjId = Database.executeBatch(spouseBatchObject,20);

            // Processing additional crop details
            Map<String,String> landownersRequestParamMap = additionalInfoMap;
            landownersRequestParamMap.put(PARTY_TYPE , PortalConstants.LANDOWNER_PARTY_NAME);
            PortalSaveAdditionalInfoBatch landownerBatchObject = new PortalSaveAdditionalInfoBatch(landownersRequestParamMap);
            Id landownerBatchObjId =  Database.executeBatch(landownerBatchObject,20);

            //processing portential buyer details
            Map<String,String> buyersRequestParamMap = additionalInfoMap;
            buyersRequestParamMap.put(PARTY_TYPE, PortalConstants.BUYER_PARTY_NAME);
            PortalSaveAdditionalInfoBatch buyersBatchObject = new PortalSaveAdditionalInfoBatch(buyersRequestParamMap);
            Id buyersBatchObjId = Database.executeBatch(buyersBatchObject,20);

            // processing crop insurance details
            Map<String,String> insAgentRequestParamMap = additionalInfoMap;
            insAgentRequestParamMap.put(PARTY_TYPE ,PortalConstants.INSURANCE_AGENT_PARTY_NAME);
            PortalSaveAdditionalInfoBatch insuranceAgentBatchObject = new PortalSaveAdditionalInfoBatch(insAgentRequestParamMap);
            Id insuranceAgentBatchObjId = Database.executeBatch(insuranceAgentBatchObject,20);

            batchIds.add(spouseBatchObjId);
            batchIds.add(landownerBatchObjId);
            batchIds.add(buyersBatchObjId);
            batchIds.add(insuranceAgentBatchObjId);

            responseFieldsMap.put(BATCH_IDS, batchIds);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-02-2024 
    * @param request 
    * @return Boolean 
    **/
    private static Boolean getIndividualCropSave(Map<String, Object> request){
        if (request.containsKey(KEY_INDIVIDUAL_CROP_SAVE)) {
            return Boolean.valueOf(request.get(KEY_INDIVIDUAL_CROP_SAVE));
        }
        return false;
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-02-2024 
    * @param request 
    * @return Boolean 
    **/
    private static Boolean getShouldValidate(Map<String, Object> request){
        if (request.containsKey(KEY_SAVE_TYPE)) {
           return Boolean.valueOf(request.get(KEY_SAVE_TYPE));
        }
        return false;
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-02-2024 
    * @param request 
    * @return Boolean 
    **/
    private static Boolean getShouldAdjustLoanAmount(Map<String, Object> request){
        if (request.containsKey(KEY_SHOULD_ADJUST_LOAN_AMOUNT)) {
            return Boolean.valueOf(request.get(KEY_SHOULD_ADJUST_LOAN_AMOUNT));
        }
        return false;
    }


    /**
    * @description 
    * @author Suraj Kumar | 01-03-2024 
    * @param request 
    **/
    public void assignAdditionalInfoDetails(Map<String, Object> request){
        if (!shouldAdjustLoanAmount) {
            PortalApplicationOriginationHelper.validateRequestParam(request);

            feedCollateral = String.valueOf(request.get(KEY_DOES_APPLICANT_FEED_COLLATERAL));

            spouseDetails = String.valueOf(request.get(KEY_SPOUSE_DETAILS));
            additionalCropDetails = String.valueOf(request.get(KEY_ADDITIONAL_CROP_DETAILS));
            potentialBuyerdetails = String.valueOf(request.get(KEY_POTENTIAL_BUYER_DETAILS));
            cropInsuranceDetails = String.valueOf(request.get(KEY_CROP_INSURANCE_DETAILS));
            cropDetails = String.valueOf(request.get(KEY_CROP_DETAILS));

            spouseDetailsList = (List<Object>) JSON.deserializeUntyped (spouseDetails);
            additionalCropDetailsList = (List<Object>) JSON.deserializeUntyped (additionalCropDetails);
            potentialBuyerdetailsList = (List<Object>) JSON.deserializeUntyped (potentialBuyerdetails);
            cropInsuranceDetailsList = (List<Object>) JSON.deserializeUntyped (cropInsuranceDetails);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-03-2024 
    * @param collaterals 
    * @param application 
    * @param response 
    * @return Boolean 
    **/
    public Boolean validateCropInformation(List<clcommon__Collateral__c> collaterals, genesis__Applications__c application,clcommon.Response response){
        for (clcommon__Collateral__c collateral : collaterals) {
            // validate request parameters if "shouldValidate" flag is set to "true"
            if (!PortalValidationUtil.isValidCropInformation(
                                                collateral, 
                                                shouldValidate,
                                                application.Does_Applicant_Feed_Above_Collaterals__c,
                                                response
                                            )) {
                return true;
            }
        }
        return false;
    }
}