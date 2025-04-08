/**
 * @description       : validation util for the external additional information API
 * @author            : Suraj Kumar | 05-16-2024
 * @group             : 
 * @last modified on  : 06-05-2024
 * @last modified by  : Suraj Kumar
**/
public inherited sharing class ExternalAdditionalInfoValidationUtil {
    public static final String DECIMAL_RGX = '^([\\d]{1,})?(\\.[\\d]{0,2})?$';
    public static final Pattern DECIMAL_PATTERN = Pattern.compile(DECIMAL_RGX);
    public static final String STATES = System.Label.Additional_Info_States;

    /**
    * @description : Validate Decimal
    * @author   Suraj Kumar | 05-16-2024 
    * @param input 
    * @param exceptionMessage
    **/
    public static void validateDecimalValue(String input, String exceptionMessage) {
        ExternalApplicationOriginationUtil.checkForEmptyString(input,exceptionMessage);
        if(DECIMAL_PATTERN.matcher(input).matches() == false){
            ExternalAdditionalInformationHandler.throwCustomException(exceptionMessage);
        }
    }
    /**
    * @description : validate state from custom label
    * @author Suraj Kumar | 05-21-2024 
    * @param state 
    **/
    public static void validateState(String state){
        List<String> statesList = STATES.split(',');
        if(!statesList.contains(state)){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.STATE_INVALID);
        }
    }

    /**
    * @description : method to validate crop details
    * @author Suraj Kumar | 05-16-2024 
    * @param collateralMap 
    **/
    public static void validateYieldInsuranceCoverage(Map<String, Object> collateralMap){
        validateRequiredKey(collateralMap, ExternalConstants.APPROVED_YEILD_KEY, ExternalConstants.CROP_APPROVED_YIELD_FIELD_MISSING);
        validateDecimalValue(String.valueOf(collateralMap.get(ExternalConstants.APPROVED_YEILD_KEY)), ExternalConstants.CROP_INVALID_APPROVED_YIELD_VALUE);
        if(Double.valueOf(collateralMap.get(ExternalConstants.APPROVED_YEILD_KEY)) < 0){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.CROP_INVALID_APPROVED_YIELD_VALUE);
        }
        validateRequiredKey(collateralMap, ExternalConstants.INSURANCE_PLAN_KEY, ExternalConstants.CROP_INSURANCE_PLAN_FIELD_MISSING);
        ExternalAdditionalInformationHandler.checkInsurancePlan(String.valueOf(collateralMap.get(ExternalConstants.INSURANCE_PLAN_KEY)));
        if(!String.valueOf(collateralMap.get(ExternalConstants.INSURANCE_PLAN_KEY)).equalsIgnoreCase(ExternalConstants.NONE_VALUE)){
            validateRequiredKey(collateralMap,ExternalConstants.COVERAGE_LEVEL_PERCENT_KEY,ExternalConstants.CROP_PERCENT_COVERAGE_LEVEL_FIELD_MISSING);
            validateDecimalValue(String.valueOf(collateralMap.get(ExternalConstants.COVERAGE_LEVEL_PERCENT_KEY)), ExternalConstants.CROP_INVALID_PERCENT_COVERAGE_LEVEL_TYPE);
            ExternalAdditionalInformationHandler.checkCoverageLevel(String.valueOf(collateralMap.get(ExternalConstants.COVERAGE_LEVEL_PERCENT_KEY))+ExternalConstants.PERCENTAGE_STRING);
        }   
    }
    
    /**
    * @description : method to validate commodity, total acer and producer share percent.
    * @author Suraj Kumar | 05-16-2024 
    * @param collateralMap 
    * @param collateralNameIdMap 
    **/
    public static void validateTotalSharePercent(Map<String, Object> collateralMap, Map<String,Id> collateralNameIdMap){
        validateRequiredKey(collateralMap, ExternalConstants.COMMODITY_KEY, ExternalConstants.CROP_COMMODITY_FIELD_MISSING);
        validateRequiredKey(collateralNameIdMap, String.valueOf(collateralMap.get(ExternalConstants.COMMODITY_KEY)), ExternalConstants.CROP_INVALID_COMMODITY_TYPE);
        validateRequiredKey(collateralMap, ExternalConstants.TOTAL_ACRES_KEY, ExternalConstants.CROP_TOTAL_ACRES_FIELD_MISSING);
        validateDecimalValue(String.valueOf(collateralMap.get(ExternalConstants.TOTAL_ACRES_KEY)), ExternalConstants.CROP_INVALID_TOTAL_ACRES_VALUE);
        if(Double.valueOf(collateralMap.get(ExternalConstants.TOTAL_ACRES_KEY)) < 0){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.CROP_INVALID_TOTAL_ACRES_VALUE);
        }
        validateRequiredKey(collateralMap, ExternalConstants.PRODUCER_SHARE_PERCENT_KEY, ExternalConstants.CROP_PRODUCER_SHARE_PERCENT_FIELD_MISSING);
        validateDecimalValue(String.valueOf(collateralMap.get(ExternalConstants.PRODUCER_SHARE_PERCENT_KEY)), ExternalConstants.CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE);

        if(Decimal.valueOf(String.valueOf(collateralMap.get(ExternalConstants.PRODUCER_SHARE_PERCENT_KEY))) < 0 
                    || Decimal.valueOf(String.valueOf(collateralMap.get(ExternalConstants.PRODUCER_SHARE_PERCENT_KEY))) > 100){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE);
        }
    }

    /**
    * @description : method to validate Feed collateral
    * @author Suraj Kumar | 05-16-2024 
    * @param collateralMap 
    * @param doFeedCollateral 
    **/
    public static void validateFeedCollateral(Map<String, Object> collateralMap, Boolean doFeedCollateral){
        if(doFeedCollateral){
            validateRequiredKey(collateralMap, ExternalConstants.COLLATERAL_FED_PERCENT, ExternalConstants.CROP_PERCENT_FED_FIELD_MISSING);
            validateDecimalValue(String.valueOf(collateralMap.get(ExternalConstants.COLLATERAL_FED_PERCENT)), ExternalConstants.CROP_INVALID_PERCENT_FED_VALUE);

            if(Decimal.valueOf(String.valueOf(collateralMap.get(ExternalConstants.COLLATERAL_FED_PERCENT))) < 0 
                    || Decimal.valueOf(String.valueOf(collateralMap.get(ExternalConstants.COLLATERAL_FED_PERCENT))) > 100){
                ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.CROP_INVALID_PERCENT_FED_VALUE);
            }
        }  
    }

    /**
    * @description : validate spouse details
    * @author Suraj Kumar | 01-04-2024 
    * @param spouseDetailsList 
    **/
    public static void validateSpouseDetails( List<Object> spouseDetailsList){
        for(Object objSpouseDetails : spouseDetailsList){
            Map<String, Object> spouseDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objSpouseDetails));
            if(spouseDetailsMap.isEmpty()){
                continue; 
            }
            ExternalApplicationOriginationUtil.checkForEmptyString((String)spouseDetailsMap.get(ExternalConstants.FIRST_NAME_KEY), ExternalConstants.SPOUSE_NAME_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)spouseDetailsMap.get(ExternalConstants.LAST_NAME_KEY), ExternalConstants.SPOUSE_NAME_MISSING);
            ExternalAdditionalInformationHandler.checkSsn(spouseDetailsMap);
            ExternalValidationUtil.validateEmailAddress(String.valueOf(spouseDetailsMap.get(ExternalConstants.EMAIL_KEY)),String.valueOf(spouseDetailsMap.get(ExternalConstants.EMAIL_KEY)));
        }
    }

    /**
    * @description : method to validate landowner details
    * @author Suraj Kumar | 01-04-2024 
    * @param landownersDetailsList 
    **/
    public static void validateLandownerDetails( List<Object> landownersDetailsList){
        for(Object landownerDetailObj : landownersDetailsList){
            Map<String, Object> landownerDetailMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(landownerDetailObj));
            if(landownerDetailMap.isEmpty()){
                continue;
            }
            ExternalApplicationOriginationUtil.checkForEmptyString((String)landownerDetailMap.get(ExternalConstants.NAME_KEY), ExternalConstants.LANDOWNER_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)landownerDetailMap.get(ExternalConstants.STATE_KEY), ExternalConstants.LANDOWNER_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)landownerDetailMap.get(ExternalConstants.COUNTY_KEY), ExternalConstants.LANDOWNER_DETAILS_MISSING);
            validateState(String.valueOf(landownerDetailMap.get(ExternalConstants.STATE_KEY)));
        }
    }

    /**
    * @description : validate buyers details
    * @author Suraj Kumar | 12-28-2023 
    * @param potentialBuyerdetailsList 
    **/
    public static void validateBuyersDetails(List<Object> potentialBuyerdetailsList){
        for(Object buyerdetailsObj : potentialBuyerdetailsList){
            Map<String, Object> potentialBuyerdetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(buyerdetailsObj));
            if(potentialBuyerdetailsMap.isEmpty()){
                continue; 
            }
            ExternalApplicationOriginationUtil.checkForEmptyString((String)potentialBuyerdetailsMap.get(ExternalConstants.NAME_KEY), ExternalConstants.BUYER_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)potentialBuyerdetailsMap.get(ExternalConstants.STREET_KEY), ExternalConstants.BUYER_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)potentialBuyerdetailsMap.get(ExternalConstants.CITY_KEY), ExternalConstants.BUYER_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)potentialBuyerdetailsMap.get(ExternalConstants.STATE_KEY), ExternalConstants.BUYER_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)potentialBuyerdetailsMap.get(ExternalConstants.POSTAL_CODE_KEY), ExternalConstants.BUYER_DETAILS_MISSING);
            ExternalValidationUtil.validateEmailAddress(String.valueOf(potentialBuyerdetailsMap.get(ExternalConstants.EMAIL_KEY)),String.valueOf(potentialBuyerdetailsMap.get(ExternalConstants.EMAIL_KEY)));
            ExternalValidationUtil.validatePhoneNum(String.valueOf(potentialBuyerdetailsMap.get(ExternalConstants.PHONE_KEY)));
            ExternalValidationUtil.validatePostalCode(String.valueOf(potentialBuyerdetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
            validateState(String.valueOf(potentialBuyerdetailsMap.get(ExternalConstants.STATE_KEY)));
        }
    }

    /**
    * @description : method to validate insurance agent detail
    * @author Suraj Kumar | 01-04-2024 
    * @param cropInsuranceDetailsList 
    **/
    public static void validateInsuranceAgentDetails(List<Object> cropInsuranceDetailsList){
        for(Object insuranceAgentDetailsObj : cropInsuranceDetailsList){
            Map<String, Object> cropInsuranceDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(insuranceAgentDetailsObj));
            if(cropInsuranceDetailsMap.isEmpty()){
                continue; 
            }
            ExternalApplicationOriginationUtil.checkForEmptyString((String)cropInsuranceDetailsMap.get(ExternalConstants.NAME_KEY), ExternalConstants.INSURANCE_AGENT_DETAIL_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)cropInsuranceDetailsMap.get(ExternalConstants.STREET_KEY), ExternalConstants.INSURANCE_AGENT_DETAIL_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)cropInsuranceDetailsMap.get(ExternalConstants.CITY_KEY), ExternalConstants.INSURANCE_AGENT_DETAIL_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)cropInsuranceDetailsMap.get(ExternalConstants.STATE_KEY), ExternalConstants.INSURANCE_AGENT_DETAIL_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString((String)cropInsuranceDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY), ExternalConstants.INSURANCE_AGENT_DETAIL_MISSING);
            ExternalValidationUtil.validateEmailAddress(String.valueOf(cropInsuranceDetailsMap.get(ExternalConstants.EMAIL_KEY)),String.valueOf(cropInsuranceDetailsMap.get(ExternalConstants.EMAIL_KEY)));
            ExternalValidationUtil.validatePhoneNum(String.valueOf(cropInsuranceDetailsMap.get(ExternalConstants.PHONE_KEY)));
            ExternalValidationUtil.validatePostalCode(String.valueOf(cropInsuranceDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
            validateState(String.valueOf(cropInsuranceDetailsMap.get(ExternalConstants.STATE_KEY)));
        }
    }

    /**
    * @description Return the User Id for the Site Admin to set as default owner for any record
    * @author Suraj | 05-16-2024
    * @return String 
    **/
    public static String getSiteAdmin(){
        List<site> objSite = [SELECT Id, AdminId, Admin.Email
                                 FROM site
                                 WHERE AdminId != :ExternalConstants.EMPTY_STRING];

        return objSite[0].AdminId;
    }

     /**
    * @description : method to validate required details of request map
    * @author Suraj Kumar | 05-14-2024 
    * @param requestMap 
    **/
    public static void validateRequestMap(Map<String,Object> requestMap){
        validateRequiredKey(requestMap, ExternalConstants.APPLICATION_DETAIL_KEY, ExternalConstants.APPLICATION_DETAILS_MISSING);
        validateRequiredKey(requestMap, ExternalConstants.BORROWER_DETAIL_KEY, ExternalConstants.BORROWER_DETAILS_MISSING);
        validateRequiredKey(requestMap, ExternalConstants.CROP_DETAILS_KEY, ExternalConstants.CROP_DETAILS_KEY_MISSING);
        validateRequiredKey(requestMap, ExternalConstants.INSURANCE_AGENT_KEY, ExternalConstants.INSURANCE_AGENT_KEY_MISSING);
        validateRequiredKey(requestMap, ExternalConstants.BUYER_KEY, ExternalConstants.BUYER_KEY_MISSING);
        validateRequiredKey(requestMap, ExternalConstants.LANDOWNER_KEY, ExternalConstants.LANDOWNER_KEY_MISSING);
        validateRequiredKey(requestMap, ExternalConstants.SPOUSE_KEY, ExternalConstants.SPOUSE_KEY_MISSING);
    }

    /**
    * @description : method to validate application detail map and user detail map , does these map contains id
    * @author Suraj Kumar | 05-14-2024 
    * @param applicationDetailsMap 
    * @param userDetailsMap 
    **/
    public static void validateApplicationUserDetailsMap(Map<String,Object> applicationDetailsMap, Map<String,Object> userDetailsMap){
        validateRequiredKey(applicationDetailsMap,ExternalConstants.ID_KEY, ExternalConstants.APPLICATION_ID_MISSING);
        validateRequiredKey(userDetailsMap,ExternalConstants.USER_ID_KEY, ExternalConstants.USER_ID_MISSING);
    }

    /**
    * @description : method to validate application id and user id
    * @author Suraj Kumar | 05-14-2024 
    * @param applicationId 
    * @param userId 
    **/
    public static void  validateApplicationUserId(String applicationId,String userId){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    genesis__Account__r.Unique_Id__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :applicationId];
        if(applicationList.size() != 1){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.APPLICATION_NOT_FOUND);
        }
        if(!userId.equals(applicationList[0].genesis__Account__r.Unique_Id__c)){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.USER_NOT_AUTHORISED);
        }
    }

    /**
    * @description : method to validate cropdetailsMap
    * @author Suraj Kumar | 05-14-2024 
    * @param cropDetailsMap 
    **/
    public static void validateCropDetailsMap(Map<String,Object> cropDetailsMap){
        validateRequiredKey(cropDetailsMap, ExternalConstants.FED_COLLATERAL_KEY, ExternalConstants.FED_COLLATERAL_MISSING);
        validateRequiredKey(cropDetailsMap, ExternalConstants.COLLATERAL_KEY, ExternalConstants.COLLATERAL_MISSING);
    }

    /**
    * @description : Method to validate required key in a Map<String,Object> and throw exception 
    * @author Suraj Kumar | 05-17-2024 
    * @param validationMap 
    * @param requiredKey 
    * @param exceptionMessage 
    **/
    public static void validateRequiredKey(Map<String,Object> validationMap, String requiredKey, String exceptionMessage){
        if(!validationMap.containsKey(requiredKey)){
            ExternalAdditionalInformationHandler.throwCustomException(exceptionMessage);
        }
    }

}