/**
 * @description       :  Re evaluate score on Evergreen Application - Save and Score, Save and Exit
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalRescoreEvergreenAPI implements clcommon.PortalCustomRemoteAPI1 {
    //Constants specific to this class starts
    private static final string APPLICATION_ID = PortalConstants.APPLICATION_ID;
    private static final string SHOULD_VALIDATE = PortalConstants.KEY_SHOULD_VALIDATE;
    private static final string EXCEPTION_STRING = PortalConstants.EXCEPTION_STRING;
    private static final string TOTAL_ASSETS = PortalConstants.TOTAL_ASSETS;
    private static final string TOTAL_LIABILITIES = PortalConstants.TOTAL_LIABILITIES;
    private static final string YEAR_BEGAN_FARMING = PortalConstants.YEAR_BEGAN_FARMING;
    //private static final string GROSS_FARM_INCOME = PortalConstants.GROSS_FARM_INCOME;
    private static final string GROSS_FARM_INCOME = 'Gross_Farm_Income__c';
    private static final string BUSINESS_DETAILS = PortalConstants.BUSINESS_DETAILS;
    private static final string PARTY_ID = PortalConstants.PARTY_ID;
    private static final string EVERGREEN_TIER_TWO_PROVIDED_STATUS = PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED;
    private static final string MISSING_ARGUMENTS = PortalConstants.MISSING_ARGUMENTS;
    private static final String CREDIT_RATING = 'CreditRating';
    private static final String EVERGREEN_BIZ_STATUS  = 'evergreenTierTwoBizInfoStatus';
    //Constants specific to this class ends

    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    genesis__Applications__c appToUpdate = new genesis__Applications__c();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    clcommon.Response response = new clcommon.Response();

    /**
     * @description Wrapper class for Business Details
     */
    global class BusinessWrapper{
        //wrapper class for Flex Rate
        global Map<Id,String> businessIncomeMap;
        global Map<Id,String> businessAssetMap;
        global Map<Id,String> businessLiablityMap;
    }
    /**
    * @description : Validate User
    * @author  Pritam Roy | 05-16-2024 
    * @param isValidUser 
    * @param objExceptionString 
    **/
    private static void checkValidUser(Boolean isValidUser, String objExceptionString){
        if(!isValidUser){
            throw new CustomException(objExceptionString);
        }
    }

    
    /**
    * @description : Update Tier Details
    * @author  Pritam Roy | 06-20-2024 
    * @param objPartyForMaxNetworth 
    * @param appToUpdate 
    **/
    private void updateTierDetails( List<clcommon__party__c> objPartyForMaxNetworth,genesis__Applications__c appToUpdate){
        Map<String, Id> creditRatingMap = getCreditRatingMatrix();
        //If save and score update networth based on tier
        if(objPartyForMaxNetworth[0].Net_Worth__c >= objPartyForMaxNetworth[0].genesis__Application__r.genesis__Loan_Amount__c){
            appToUpdate.Evergreen_Tier_Two_Business_Info_Status__c  = EVERGREEN_TIER_TWO_PROVIDED_STATUS;
            fieldsMap.put(CREDIT_RATING,ConstantValues.CREDIT_RATE_2);
            fieldsMap.put(EVERGREEN_BIZ_STATUS,EVERGREEN_TIER_TWO_PROVIDED_STATUS); 
        }else if(objPartyForMaxNetworth[0].Net_Worth__c >= 0 && objPartyForMaxNetworth[0].Net_Worth__c < objPartyForMaxNetworth[0].genesis__Application__r.genesis__Loan_Amount__c){
            appToUpdate.genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_3);
            appToUpdate.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
            appToUpdate.Additional_Information_Needed__c = true;
            appToUpdate.Evergreen_Tier_Two_Business_Info_Status__c  = PortalConstants.EVERGREEN_BIZ_STATUS_IN_ELIGIBLE;
            fieldsMap.put(CREDIT_RATING,ConstantValues.CREDIT_RATE_3);
            fieldsMap.put(EVERGREEN_BIZ_STATUS,PortalConstants.EVERGREEN_BIZ_STATUS_IN_ELIGIBLE);
        }else{
            appToUpdate.genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_4);
            appToUpdate.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_4);
            appToUpdate.Additional_Information_Needed__c = true;
            appToUpdate.Is_Evergreen__c = false;
            appToUpdate.Stage__c = PortalConstants.APPLICANT_SIGNATURE;
            appToUpdate.Evergreen_Tier_Two_Business_Info_Status__c  = PortalConstants.EVERGREEN_BIZ_STATUS_IN_ELIGIBLE;
            fieldsMap.put(CREDIT_RATING,ConstantValues.CREDIT_RATE_4);
            fieldsMap.put(EVERGREEN_BIZ_STATUS,PortalConstants.EVERGREEN_BIZ_STATUS_IN_ELIGIBLE); 
        }
    }
    /**
    * @description : Get Credit Rating Matrix
    * @author  Pritam Roy | 05-16-2024 
    * @return Map<String, Id> 
    **/
    private static Map<String, Id> getCreditRatingMatrix(){
        List<genesis__Credit_Rating_Matrix__c> objCreditRatingTierList = [SELECT  Id, 
                                                                                    Name 
                                                                            FROM genesis__Credit_Rating_Matrix__c 
                                                                            ORDER BY Name ASC 
                                                                            LIMIT 4];
        Map<String, Id> creditRatingMap = new Map<String ,Id>();
        for(genesis__Credit_Rating_Matrix__c objTier : objCreditRatingTierList){
            creditRatingMap.put(objTier.Name,objTier.Id);
        }
        return creditRatingMap;
    }
    /**
    * @description : Validate fields only on Save and Score
    * @author  Pritam Roy | 05-29-2024 
    * @param assetMap 
    * @param liabilityMap 
    * @param shouldValidate 
    **/
    private static void validateMandatoryFields(Map<String,String> assetMap,Map<String,String> liabilityMap,Boolean shouldValidate){
        if(shouldValidate){
            validateData(assetMap,true);
            validateData(liabilityMap,true);
        }else{
            validateData(assetMap,false);
            validateData(liabilityMap,false);
        }
    }
    /**
    * @description : Validate List
    * @author  Pritam Roy | 05-16-2024 
    * @param objList 
    * @param objExceptionString 
    **/
    private static void checkNullList(List<Object> objList, String objExceptionString){
        if(objList.isEmpty()){
            throw new CustomException(objExceptionString);
        }
    }
    /**
    * @description : Validate Data from Portal
    * @author  Pritam Roy | 05-28-2024 
    * @param dataToValidate 
    * @param isMandatory 
    **/
    private static void validateData(Map<String,String> dataToValidate,Boolean isMandatory){
        for(String keyData : dataToValidate.keySet()){
            if(isMandatory){
                if(dataToValidate.get(keyData) == NULL){
                    throw new CustomException(EXCEPTION_STRING);
                }
            }
        }
    }
    /**
    * @description : Validate Map
    * @author  Pritam Roy | 05-31-2024 
    * @param dataToValidate  
    **/
    private static void validateMap(Map<String,String> dataToValidate){
        if(dataToValidate.isEmpty()){
            throw new CustomException(ConstantValues.MAP_IS_EMPTY);
        }
    }
    /**
    * @description : Validates Arguments
    * @author  Pritam Roy | 05-31-2024 
    * @param request 
    * @param keyToContain 
    * @return String 
    **/
    private static String getKeyValue(Map<String, Object> request,String keyToContain){
        if(!request.containsKey(keyToContain)&&request.get(keyToContain) != NULL){
            throw new CustomException(MISSING_ARGUMENTS);
        }
        return String.valueOf(request.get(keyToContain));
    }
    /**
    * @description : Process Values for Numeric Fields
    * @author  Pritam Roy | 05-31-2024 
    * @param valueToCheck 
    * @param shouldValidate 
    * @return Decimal 
    **/
    private static Decimal getValue(String valueToCheck,Boolean shouldValidate){
        if(!shouldValidate && valueToCheck == NULL){
            return NULL;
        }else if(shouldValidate &&  valueToCheck == NULL){
            throw new CustomException(EXCEPTION_STRING);
        }
        return Decimal.valueOf(valueToCheck);
    }
    /**
    * @description : Get Parsed Data
    * @author  Pritam Roy | 06-02-2024 
    * @param parsedData 
    * @return Map<String, Map<String, Object>> 
    **/
    private static Map<String, Map<String, Object>> getData(List<Object> parsedData){
        Map<String, Map<String, Object>> businessDataMap = new Map<String, Map<String, Object>>();
        for (Object eachData : parsedData) {
            Map<String, Object> businessData = (Map<String, Object>) eachData;
            businessDataMap.put((String) businessData.get(PARTY_ID), businessData);
        }
        return businessDataMap;
    }
    /**
    * @description : Rescore Evergreen Application
    * @author  Pritam Roy | 05-21-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName, String[] disclosureNames, Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();

        List<genesis__Business_Information__c> businessInfoList = new List<genesis__Business_Information__c>();
        List<Account> accountToUpdateList = new List<Account>();
        
        List<Object> parsedData = new List<Object>();
        String applicationId = '';

        try {

            applicationId = getKeyValue(request,APPLICATION_ID); 
            Boolean shouldValidate = Boolean.valueOf(getKeyValue(request,SHOULD_VALIDATE));

            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId);
            checkValidUser(isValidUser, PortalConstants.USER_NOT_AUTHORISED);

            parsedData = (List<Object>) JSON.deserializeUntyped(getKeyValue(request,BUSINESS_DETAILS));
            Map<String, Map<String, Object>> businessDataMap = new Map<String, Map<String, Object>>();
            businessDataMap = getData(parsedData);

            Map<String,String> assetMap = new Map<String,String>();
            Map<String,String> liabilityMap = new Map<String,String>();
            Map<String,String> grossFarmIncomeMap = new Map<String,String>();
            Map<String,String> yearBeganFarmingMap = new Map<String,String>();

            //Parsing each value to a Map
            for (String eachInfo : businessDataMap.keySet()) {
                Map<String, Object> businessData = businessDataMap.get(eachInfo);
                assetMap.put(eachInfo, String.valueOf(businessData.get(TOTAL_ASSETS))); 
                liabilityMap.put(eachInfo,String.valueOf(businessData.get(TOTAL_LIABILITIES)));
                yearBeganFarmingMap.put(eachInfo,String.valueOf(businessData.get(YEAR_BEGAN_FARMING)));
                grossFarmIncomeMap.put(eachInfo,String.valueOf(businessData.get(GROSS_FARM_INCOME)));
            }
            //Validating Details from Portal
            validateMap(assetMap);
            validateMap(liabilityMap);
            validateMap(grossFarmIncomeMap);
            validateMap(yearBeganFarmingMap);
            

            //Validate fields based on Save and Exit / Save and Score
            validateMandatoryFields(assetMap,liabilityMap,shouldValidate);

            //Query Parties
            List<clcommon__Party__c> partyToUpdateList = [SELECT Id,
                                                                Total_Assets__c,
                                                                Total_Liabilities__c,
                                                                clcommon__Account__c,
                                                                clcommon__Account__r.genesis__Business_Information__c,
                                                                Gross_Farm_Income__c
                                                            FROM clcommon__Party__c 
                                                            WHERE Id IN: assetMap.keySet()];
            checkNullList(partyToUpdateList, ConstantValues.LIST_EMPTY_CHECK);

            //Update Party Asset and Liabilities
            for(clcommon__Party__c eachParty : partyToUpdateList){
                Account accountToUpdate = new Account(Id = eachParty.clcommon__Account__c);
                accountToUpdate.Year_Began_Farming__c = String.valueOf(yearBeganFarmingMap.get(eachParty.id));
                accountToUpdateList.add(accountToUpdate);

                genesis__Business_Information__c businessInfoToUpdate =  new genesis__Business_Information__c(Id = eachParty.clcommon__Account__r.genesis__Business_Information__c);
                businessInfoToUpdate.Gross_Farm_Income__c = getValue(grossFarmIncomeMap.get(eachParty.id),shouldValidate);
                businessInfoToUpdate.genesis__Total_Assets__c = getValue(assetMap.get(eachParty.id),shouldValidate);
                businessInfoToUpdate.genesis__Total_Liabilities__c = getValue(liabilityMap.get(eachParty.id),shouldValidate);
                businessInfoList.add(businessInfoToUpdate);

                eachParty.Total_Assets__c = getValue(assetMap.get(eachParty.id),shouldValidate);
                eachParty.Total_Liabilities__c = getValue(liabilityMap.get(eachParty.id),shouldValidate);
                eachParty.Gross_Farm_Income__c = getValue(grossFarmIncomeMap.get(eachParty.id),shouldValidate);
            }

            Database.update(accountToUpdateList, true);
            Database.update(partyToUpdateList, true);
            Database.update(businessInfoList, true);

            //Query party for max net worth
            List<clcommon__Party__c> objPartyForMaxNetworth = [SELECT  Id, 
                                                                            Net_Worth__c,
                                                                            clcommon__account__c,
                                                                            clcommon__account__r.clcommon__Legal_Entity_Type__r.name,
                                                                            genesis__Application__c,
                                                                            genesis__Application__r.Is_Evergreen__c,
                                                                            genesis__Application__r.Guarantee__c,
                                                                            genesis__Application__r.genesis__Credit_Rating__c,
                                                                            genesis__Application__r.Net_Worth__c, 
                                                                            genesis__Application__r.genesis__Status__c,
                                                                            genesis__Application__r.Additional_Information_Needed__c,
                                                                            genesis__Application__r.genesis__Loan_Amount__c,
                                                                            genesis__Application__r.Evergreen_Tier_Two_Business_Info_Status__c 
                                                                    FROM clcommon__Party__c 
                                                                    WHERE genesis__Application__c = :applicationId AND
                                                                    Net_Worth__c != null AND
                                                                    (clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY OR 
                                                                            clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY)
                                                                    AND clcommon__account__r.clcommon__Legal_Entity_Type__r.name !=: PortalConstants.INDIVIDUAL_ENTITY
                                                                    ORDER BY Net_Worth__c  DESC
                                                                    LIMIT 1];
            checkNullList(objPartyForMaxNetworth, ConstantValues.LIST_EMPTY_CHECK);                                                 
            
            //If save and exit return success 
            if(!shouldValidate){
                response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                response.status = clcommon.Constants.SUCCESS;
                return response;  
            }
            appToUpdate = new genesis__Applications__c(Id = objPartyForMaxNetworth[0].genesis__Application__c);
            //If save and score update networth based on tier
            updateTierDetails(objPartyForMaxNetworth,appToUpdate);
            appToUpdate.Net_Worth__c  = String.valueOf(objPartyForMaxNetworth[0].Net_Worth__c);
            Database.update(appToUpdate, true);

            responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
          
        }catch(Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, PortalRescoreEvergreenAPI.class.getName());
        }
        return response;
    }
}