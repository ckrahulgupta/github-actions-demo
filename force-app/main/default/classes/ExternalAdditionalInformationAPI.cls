/**
 * @description       : This class is called by connectify, used to add additional information and store them in salesforce 
 * @author            : Suraj Kumar | 05-15-2024
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : Kabir Pramanik
**/
@RestResource(urlMapping = '/api/v1/external/saveAdditionalInformation')
global without sharing class ExternalAdditionalInformationAPI {
    private static final String CLASS_NAME = ExternalAdditionalInformationAPI.class.getName();
    static Account dealerForExtUser;
   
    /**
    * @description : Http post method to create additional information  
    * @author Suraj Kumar | 05-14-2024 
    **/
    @HttpPost
    global static void doAddAdditionalInformation(){
        RestRequest requestParam = RestContext.request;
        String requestBody = requestParam.requestBody.toString();
        String applicationId;
        String userId;
        Boolean doFeedCollateral;
        List<Object> collateralDetailsList;
        Map<String, Object> responseMap = new Map<String, Object>();
        RestResponse response = RestContext.response;
        Map<String, Object> contentMap = new Map<String, Object>();
        Map<String, Object> bodyMap = new Map<String, Object>();
        try{
            response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            if(String.isBlank(requestBody)){
                ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);

            ExternalAdditionalInfoValidationUtil.validateRequestMap(requestMap);
            Map<String,Object> applicationDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
            Map<String,Object> userDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
            Map<String,Object> cropDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.CROP_DETAILS_KEY);
            List<Object> insuranceAgentDetailList = (List<Object>)requestMap.get(ExternalConstants.INSURANCE_AGENT_KEY);
            List<Object> buyersDetailsList = (List<Object>)requestMap.get(ExternalConstants.BUYER_KEY);
            List<Object> landownersDetailsList = (List<Object>)requestMap.get(ExternalConstants.LANDOWNER_KEY);
            List<Object> spouseDetailsList = (List<Object>)requestMap.get(ExternalConstants.SPOUSE_KEY);

            ExternalAdditionalInfoValidationUtil.validateApplicationUserDetailsMap(applicationDetailsMap, userDetailsMap);

            applicationId = String.valueOf(applicationDetailsMap.get(ExternalConstants.ID_KEY));
            userId = String.valueOf(userDetailsMap.get(ExternalConstants.USER_ID_KEY));

            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  

            dealerForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);
            ExternalSecurityUtil.validateBorrowerWithApplication(applicationId,userId,dealerForExtUser.Id);

            ExternalAdditionalInfoValidationUtil.validateCropDetailsMap(cropDetailsMap);

            ExternalAdditionalInfoValidationUtil.validateSpouseDetails(spouseDetailsList);
            ExternalAdditionalInfoValidationUtil.validateLandownerDetails(landownersDetailsList);
            ExternalAdditionalInfoValidationUtil.validateBuyersDetails(buyersDetailsList);
            ExternalAdditionalInfoValidationUtil.validateInsuranceAgentDetails(insuranceAgentDetailList);

            deleteExistingAdditionalInfo(applicationId);
            genesis__Applications__c applicationObj = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                Additional_Information_Needed__c,
                                                                genesis__Credit_Rating__r.Name, 
                                                                Credit_Application_And_Agreement_Process__c,
                                                                Does_Applicant_Feed_Above_Collaterals__c
                                                            FROM genesis__Applications__c
                                                            WHERE Id = :applicationId
                                                            LIMIT 1];

            

            doFeedCollateral = Boolean.valueOf(cropDetailsMap.get(ExternalConstants.FED_COLLATERAL_KEY));
            collateralDetailsList = (List<Object>) cropDetailsMap.get(ExternalConstants.COLLATERAL_KEY);
            applicationObj.Does_Applicant_Feed_Above_Collaterals__c = doFeedCollateral;
            List<clcommon__Collateral__c> collateralList = ExternalAdditionalInformationHandler.getCollateralInstances(collateralDetailsList, doFeedCollateral, applicationId);
            
            persistCollaterals(collateralList,applicationId);
            updateLoanAmount(applicationObj);

            Map<String,Object> additionalInfoMap = new Map<String,Object>{
                ExternalConstants.SPOUSE_KEY => spouseDetailsList,
                ExternalConstants.LANDOWNER_KEY => landownersDetailsList,
                ExternalConstants.BUYER_KEY => buyersDetailsList,
                ExternalConstants.INSURANCE_AGENT_KEY => insuranceAgentDetailList,
                ExternalConstants.APPLICATION_KEY => applicationId
            };
            updateAdditionalInfoDetails(additionalInfoMap);
            Database.update(applicationObj,true);

            bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.RECORD_CREATED_VALUE);
            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            response.statusCode = ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE;
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
    * @description : method to add addition details 
    * @author Suraj Kumar | 05-16-2024 
    * @param additionalInfoMap 
    **/
    private static void updateAdditionalInfoDetails(Map<String,Object> additionalInfoMap){
        // Processing spouse details
        Map<String,Object> spouseRequestParamMap = additionalInfoMap;
        spouseRequestParamMap.put(ExternalConstants.PARTY_TYPE, ExternalConstants.SPOUSE_PARTY_NAME);
        ExternalAdditionalInformationBatch spouseBatchObject = new ExternalAdditionalInformationBatch(spouseRequestParamMap);
        Database.executeBatch(spouseBatchObject,1);

        // Processing additional crop details
        Map<String,Object> landownersRequestParamMap = additionalInfoMap;
        landownersRequestParamMap.put(ExternalConstants.PARTY_TYPE , ExternalConstants.LANDOWNER_PARTY_NAME);
        ExternalAdditionalInformationBatch landownerBatchObject = new ExternalAdditionalInformationBatch(landownersRequestParamMap);
        Database.executeBatch(landownerBatchObject,1);

        //processing portential buyer details
        Map<String,Object> buyersRequestParamMap = additionalInfoMap;
        buyersRequestParamMap.put(ExternalConstants.PARTY_TYPE, ExternalConstants.BUYER_PARTY_NAME);
        ExternalAdditionalInformationBatch buyersBatchObject = new ExternalAdditionalInformationBatch(buyersRequestParamMap);
        Database.executeBatch(buyersBatchObject,1);

        // processing crop insurance details
        Map<String,Object> insAgentRequestParamMap = additionalInfoMap;
        insAgentRequestParamMap.put(ExternalConstants.PARTY_TYPE ,ExternalConstants.INSURANCE_AGENT_PARTY_NAME);
        ExternalAdditionalInformationBatch insuranceAgentBatchObject = new ExternalAdditionalInformationBatch(insAgentRequestParamMap);
        Database.executeBatch(insuranceAgentBatchObject,1);
    }

    /**
    * @description : method to create collaterals and insert in data base
    * @author Suraj Kumar | 05-16-2024 
    * @param collateralList 
    * @param applicationId 
    **/
    private static void persistCollaterals(List<clcommon__Collateral__c> collateralList, String applicationId){
        if(collateralList.size() == 0){
            return;
        }
        List<Id> collateralIds = new List<Id>();
        for (clcommon__collateral__c collateralObj : collateralList) {
            collateralIds.add(collateralObj.clcommon__Collateral_Category__c);
        }

        List<clcommon__Collateral_Category__c> collateralCategoriesList = [SELECT Id, 
                                                                                    Name, 
                                                                                    Collateral_Unit__c, 
                                                                                    Price_Per_Unit_1__c, 
                                                                                    Price_Per_Unit_2__c 
                                                                            FROM clcommon__Collateral_Category__c 
                                                                            WHERE Id IN :collateralIds];

        Map<Object, clcommon__Collateral_Category__c> collateralPriceMap = new Map<Object, clcommon__Collateral_Category__c>();
        for(clcommon__Collateral_Category__c collateralCategoryObj : collateralCategoriesList) {
                collateralPriceMap.put(collateralCategoryObj.Id, collateralCategoryObj);
        }

        for(clcommon__Collateral__c collateralObj: collateralList){
            updateCollateralPrice(collateralObj,collateralPriceMap);
        }

        Database.SaveResult[] result = Database.Insert(collateralList, true);

        List<genesis__Application_Collateral__c> applicationCollateralList = new List<genesis__Application_Collateral__c>();
        for(Database.SaveResult savedCollateral : result){
            applicationCollateralList.add(new genesis__Application_Collateral__c(
                                                    genesis__Collateral__c = savedCollateral.getId(),
                                                    genesis__Application__c = applicationId
                                                ));
        }
        Database.Insert(applicationCollateralList,true);
    }

    /**
    * @description : method to calculate collateral price
    * @author Suraj Kumar | 05-16-2024 
    * @param collateralObj 
    * @param collateralPriceMap 
    **/
    private static void updateCollateralPrice(clcommon__Collateral__c collateralObj,Map<Object, clcommon__Collateral_Category__c> collateralPriceMap){
        if (collateralPriceMap.containsKey(collateralObj.clcommon__Collateral_Category__c)) {
            if (collateralObj.Insurance_Plan__c.equals(ExternalConstants.INSURANCE_PLAN_RP_VALUE) ||
                collateralObj.Insurance_Plan__c.equals(ExternalConstants.INSURANCE_PLAN_ARP_VALUE) ||
                collateralObj.Insurance_Plan__c.equals(ExternalConstants.INSURANCE_PLAN_ARH_VALUE)) {
                collateralObj.Price__c = collateralPriceMap.get(collateralObj.clcommon__Collateral_Category__c)
                                                        .Price_Per_Unit_1__c;
            } else {
                // for insurance type YP/APH/AYP/CAT/Hail only/None
                collateralObj.Price__c = collateralPriceMap.get(collateralObj.clcommon__Collateral_Category__c)
                                                        .Price_Per_Unit_2__c;
            }
        }
    }

    /**
    * @description : method to delete existing additional information details
    * @author Suraj Kumar | 05-16-2024 
    * @param applicationId 
    **/
    private static void deleteExistingAdditionalInfo(String applicationId){
        List<genesis__Application_Collateral__c> applicationCollateralList = [SELECT Id, 
                                                                                    genesis__Collateral__c, 
                                                                                    genesis__Application__c 
                                                                                FROM genesis__Application_Collateral__c 
                                                                                WHERE genesis__Application__c =:applicationId];

        List<Id> collateralIdList = new List<Id>();
        for(genesis__Application_Collateral__c applicationCollateralObj: applicationCollateralList){
            collateralIdList.add(applicationCollateralObj.genesis__Collateral__c);
        }
        if(collateralIdList.size()>0){
            List<clcommon__Collateral__c> collateralList = [SELECT Id 
                                                                FROM clcommon__Collateral__c
                                                                WHERE Id IN :collateralIdList];
            Database.delete(collateralList,true);
            Database.delete(applicationCollateralList,true);
        }

        List<clcommon__Party__c> additionalInfoPartyList =  [SELECT Id, 
                                                                    clcommon__Account__c, 
                                                                    clcommon__Contact__c
                                                                FROM clcommon__Party__c 
                                                                WHERE genesis__Application__c = :applicationId
                                                                AND clcommon__Party_Types__c IN (:ExternalConstants.LANDOWNER_PARTY_NAME,
                                                                    :ExternalConstants.SPOUSE_PARTY_NAME,
                                                                    :ExternalConstants.INSURANCE_AGENT_PARTY_NAME,
                                                                    :ExternalConstants.BUYER_PARTY_NAME)];

        List<Id> accountIdList = new List<Id>();
        List<Id> contactIdList = new List<Id>();
        for(clcommon__Party__c partyObj: additionalInfoPartyList){
            accountIdList.add(partyObj.clcommon__Account__c);
            contactIdList.add(partyObj.clcommon__Contact__c);
        }
        Database.delete(additionalInfoPartyList,true);
        if(accountIdList.size()>0){
            List<Account> accountList = [SELECT Id
                                                FROM Account
                                                WHERE Id IN :accountIdList];
            Database.delete(accountList,true);
        }
        if(contactIdList.size() >0){
            List<Contact> contactList = [SELECT Id
                                            FROM Contact
                                            WHERE Id IN :contactIdList];
            Database.delete(contactList,true);
        }

    }

    /**
    * @description : This method is used to update the loan amount if total collateral price is less than requested loan amount for Tier 3 credit rating
    * @author Suraj Kumar | 05-27-2024 
    * @param applicationObj 
    **/
    private static void updateLoanAmount(genesis__Applications__c applicationObj){
        if(applicationObj.genesis__Credit_Rating__r.Name == ExternalConstants.TIER_THREE_CREDIT){
            Double sumTotalCollateralsPrice = Double.valueOf(
                [
                    SELECT SUM(Total_Collateral_Price__c) 
                    FROM clcommon__Collateral__c 
                    WHERE genesis__Application__c = :applicationObj.Id
                ][0].get(ExternalConstants.AGGREGATE_KEY)
                );
            if(applicationObj.genesis__Loan_Amount__c > sumTotalCollateralsPrice){
                applicationObj.genesis__Loan_Amount__c = sumTotalCollateralsPrice;
            }
        }
    }
}