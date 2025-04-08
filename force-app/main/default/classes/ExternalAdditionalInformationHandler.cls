/**
 * @description       : This is helper class for ExternalAdditionalInformationRestAPI
 * @author            : Suraj Kumar | 05-15-2024
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : Suraj Kumar
**/
public inherited sharing class ExternalAdditionalInformationHandler {
    private static final String KEY_APPLICATION = 'application';

    /**
    * @description : method to get collaterallist
    * @author Suraj Kumar | 05-16-2024 
    * @param collateralDetailsList 
    * @param doFeedCollateral 
    * @param applicationId
    * @return List<clcommon__Collateral__c> 
    **/
    public static List<clcommon__Collateral__c> getCollateralInstances(List<Object> collateralDetailsList, Boolean doFeedCollateral, String applicationId){
        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id, 
                                                                                    Name, 
                                                                                    Price_Per_Unit_1__c, 
                                                                                    Price_Per_Unit_2__c 
                                                                                FROM clcommon__Collateral_Category__c];
        Map<String,Id> collateralNameIdMap = new Map<String,Id>();
        for(clcommon__Collateral_Category__c collateralCategoryObj: collateralCategoryList){
            collateralNameIdMap.put(collateralCategoryObj.Name,collateralCategoryObj.Id);
        }

        List<clcommon__Collateral__c> collateralList = new List<clcommon__Collateral__c>();

        for(Object collateralDetailsObj: collateralDetailsList){
            Map<String, Object> collateralMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(collateralDetailsObj));

            ExternalAdditionalInfoValidationUtil.validateTotalSharePercent(collateralMap,collateralNameIdMap);
            ExternalAdditionalInfoValidationUtil.validateYieldInsuranceCoverage(collateralMap);
            ExternalAdditionalInfoValidationUtil.validateFeedCollateral(collateralMap,doFeedCollateral);
            clcommon__Collateral__c collateralObj = new clcommon__Collateral__c();
            collateralObj.Total_Acres__c = Double.valueOf(collateralMap.get(ExternalConstants.TOTAL_ACRES_KEY));
            collateralObj.Producer_Share_Percent__c = Decimal.valueOf(String.valueOf(collateralMap.get(ExternalConstants.PRODUCER_SHARE_PERCENT_KEY)));
            collateralObj.Approved_Yield__c = Double.valueOf(collateralMap.get(ExternalConstants.APPROVED_YEILD_KEY));
            collateralObj.Percent_Fed__c = doFeedCollateral ? Decimal.valueOf(String.valueOf(collateralMap.get(ExternalConstants.COLLATERAL_FED_PERCENT))) : 0;
            collateralObj.clcommon__Collateral_Category__c = collateralNameIdMap.get(String.valueOf(collateralMap.get(ExternalConstants.COMMODITY_KEY)));
            collateralObj.Insurance_Plan__c = String.valueOf(collateralMap.get(ExternalConstants.INSURANCE_PLAN_KEY));
            collateralObj.Percent_Coverage_Level__c = String.valueOf(collateralMap.get(ExternalConstants.INSURANCE_PLAN_KEY)).equalsIgnoreCase(ExternalConstants.NONE_VALUE) ? ExternalConstants.SPACE_STRING : String.valueOf(collateralMap.get(ExternalConstants.COVERAGE_LEVEL_PERCENT_KEY))+ExternalConstants.PERCENTAGE_STRING;
            collateralObj.clcommon__Collateral_Name__c = ExternalConstants.COMMODITY_VALUE;
            collateralObj.genesis__Application__c = applicationId;

            collateralList.add(collateralObj);
        }
        return collateralList;
    }

    /**
    * @description : method to insert spouse details 
    * @author Suraj Kumar | 12-27-2023 
    * @param spouseDetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processSpouseDetails(List<Object> spouseDetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        for(Object objSpouseDetails : spouseDetailsList){
            Map<String, Object> spouseDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objSpouseDetails));
            if(spouseDetailsMap.isEmpty()){
                continue; 
            }
            saveAdditionalInfoDetails(spouseDetailsMap, containsPartyRecordMap, PortalConstants.SPOUSE_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    }

    /**
    * @description : method to insert Landowner details
    * @author Suraj Kumar | 12-27-2023 
    * @param additionalCropDetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processAdditionalCropDetails(List<Object> additionalCropDetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        for(Object objAdditionalCropDetails : additionalCropDetailsList){
            Map<String, Object> additionalCropDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objAdditionalCropDetails));
            if(additionalCropDetailsMap.isEmpty()){
                continue; 
            }
            saveAdditionalInfoDetails(additionalCropDetailsMap, containsPartyRecordMap, PortalConstants.LANDOWNER_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    }

    /**
    * @description : method to insert buyers details
    * @author Suraj Kumar | 12-27-2023 
    * @param potentialBuyerdetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processPotentialBuyers(List<Object> potentialBuyerdetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        for(Object objPotentialBuyerdetails : potentialBuyerdetailsList){
            Map<String, Object> potentialBuyerdetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objPotentialBuyerdetails));
            if(potentialBuyerdetailsMap.isEmpty()){
                continue;
            }
            saveAdditionalInfoDetails(potentialBuyerdetailsMap, containsPartyRecordMap, PortalConstants.BUYER_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    }

    /**
    * @description : method to insert insurance agent details
    * @author Suraj Kumar | 12-27-2023 
    * @param cropInsuranceDetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processCropInsuranceDetails(List<Object> cropInsuranceDetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        for(Object objCropInsuranceDetails : cropInsuranceDetailsList){
            Map<String, Object> cropInsuranceDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objCropInsuranceDetails));
            if(cropInsuranceDetailsMap.isEmpty()){
                continue; 
            }
            saveAdditionalInfoDetails(cropInsuranceDetailsMap, containsPartyRecordMap, PortalConstants.INSURANCE_AGENT_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    }
    
    /**
    * @description : method to save additional information details
    * @author Suraj Kumar | 05-17-2024 
    * @param response 
    * @param containsPartyRecordMap 
    * @param partyName 
    **/
    public static void saveAdditionalInfoDetails(Map<String, Object> response, Map<String, Object> containsPartyRecordMap,String partyName){
        String applicationId = String.valueOf(containsPartyRecordMap.get(KEY_APPLICATION));
        Map<String, RecordType> partyRecordTypeMap =  (Map<String, RecordType>)containsPartyRecordMap.get(ExternalConstants.RECORD_TYPE_MAP_KEY);
        Map<String, clcommon__Party_Type__c> partyTypeMap = (Map<String, clcommon__Party_Type__c>) containsPartyRecordMap.get(ExternalConstants.PARTY_TYPE_MAP_KEY);

        Contact contactObj = new Contact();
        Account accountObj = new Account();
        clcommon__party__c objParty = new clcommon__party__c();
        accountObj = creatAccount(response, partyName);
        // Creating Record Type as Landowner
        if(partyName == ExternalConstants.LANDOWNER_PARTY_NAME){
            RecordType landownerRecordType = partyRecordTypeMap.get(ExternalConstants.LANDOWNER_PARTY_NAME);
            accountObj.RecordTypeId = landownerRecordType.Id;
        }
        //Creating Reecord Type as Spouse
        if(partyName == ExternalConstants.SPOUSE_PARTY_NAME){
            RecordType spouseRecordType = partyRecordTypeMap.get(ExternalConstants.SPOUSE_PARTY_NAME);
            accountObj.RecordTypeId = spouseRecordType.Id;
        }
        //Creating Record Type as Insurance Agency
        if(partyName == ExternalConstants.INSURANCE_AGENT_PARTY_NAME){
            RecordType insuranceRecordType = partyRecordTypeMap.get(ExternalConstants.INSURANCE_AGENT_PARTY_NAME);
            accountObj.RecordTypeId = insuranceRecordType.Id;
        }
        // Creating Record Type as BUYER
        if(partyName == ExternalConstants.BUYER_PARTY_NAME){
            RecordType buyerRecordType = partyRecordTypeMap.get(ExternalConstants.BUYER_PARTY_NAME);
            accountObj.RecordTypeId = buyerRecordType.Id;
        }

        Database.Insert(accountObj, true);
        contactObj = creatContact(response, partyName);
        contactObj.accountID = accountObj.Id;
        Database.Insert(contactObj, true);
        objParty.clcommon__Account__c = accountObj.Id;
        objParty.clcommon__Contact__c = contactObj.Id;
        objParty.genesis__Application__c = applicationId;
        clcommon__Party_Type__c partyType = partyTypeMap.get(partyName);
        objParty.clcommon__Type__c = partyType.Id;
        objParty.clcommon__Party_Types__c = partyName;
        Database.Insert(objParty, true);
    }

    /**
    * @description : Method to create account
    * @author Suraj Kumar | 05-17-2024  
    * @param response 
    * @param partyName 
    * @return Account 
    **/
    private static Account creatAccount(Map<String, Object> response , string partyName){
        Account accountObj = new Account();
        if (partyName.equalsIgnoreCase(ExternalConstants.SPOUSE_PARTY_NAME)){
            accountObj.Name = (String)response.get(ExternalConstants.FIRST_NAME_KEY) + ExternalConstants.SPACE_STRING
                                    + (String) response.get(ExternalConstants.LAST_NAME_KEY);
            accountObj.clcommon__Email__c = (String) response.get(ExternalConstants.EMAIL_KEY);
        }else{
            accountObj.Name = (String) response.get(ExternalConstants.NAME_KEY);
            accountObj.clcommon__Email__c = (String) response.get(ExternalConstants.EMAIL_KEY);
            accountObj.Phone = (String) response.get(ExternalConstants.PHONE_KEY);
            accountObj.BillingStreet = (String) response.get(ExternalConstants.STREET_KEY);
            accountObj.BillingCity = (String) response.get(ExternalConstants.CITY_KEY);
            accountObj.BillingState = (String) response.get(ExternalConstants.STATE_KEY);
            accountObj.BillingPostalCode = (String) response.get(ExternalConstants.POSTAL_CODE_KEY);
            accountObj.Billing_County__c = (String) response.get(ExternalConstants.COUNTY_KEY);
        }
        accountObj.OwnerId = ExternalAdditionalInfoValidationUtil.getSiteAdmin();
        return accountObj;
    }

    /**
    * @description : method to create contact
    * @author Suraj Kumar | 05-17-2024 
    * @param response 
    * @param partyName 
    * @return Contact 
    **/
    private static Contact creatContact(Map<String, Object> response , string partyName){
        Contact contactObj = new Contact();
        List<String> nameList = new List<String>();
        if (partyName.equalsIgnoreCase(ExternalConstants.SPOUSE_PARTY_NAME)){
            contactObj.Firstname = (String)response.get(ExternalConstants.FIRST_NAME_KEY);
            contactObj.ints__Middle_Name__c = (String) response.get(ExternalConstants.MIDDLE_NAME_KEY);
            contactObj.LastName = (String) response.get(ExternalConstants.LAST_NAME_KEY);
            contactObj.Email = (String) response.get(ExternalConstants.EMAIL_KEY);
            contactObj.genesis__SSN__c = (String) response.get(ExternalConstants.SSN_KEY);
        }else{
            nameList = String.valueOf((String) response.get(ExternalConstants.NAME_KEY)).split(ExternalConstants.SPACE_STRING, 2);
            if(nameList.size() == 1 ){
                contactObj.LastName = nameList[0];
            }else{
                contactObj.FirstName = nameList[0];
                contactObj.LastName = nameList[1];
            }
            contactObj.Email = (String) response.get(ExternalConstants.EMAIL_KEY);
            contactObj.Phone = (String) response.get(ExternalConstants.PHONE_KEY);
            contactObj.MailingStreet = (String) response.get(ExternalConstants.STREET_KEY);
            contactObj.MailingCity = (String) response.get(ExternalConstants.CITY_KEY);
            contactObj.MailingState = (String) response.get(ExternalConstants.STATE_KEY);
            contactObj.MailingPostalCode = (String) response.get(ExternalConstants.POSTAL_CODE_KEY);
            contactObj.Mailing_County__c = (String) response.get(ExternalConstants.COUNTY_KEY);
        }
        return contactObj;
    }

     /**
    * @description : method to throw exception
    * @author Suraj Kumar | 05-16-2024 
    * @param exceptionName 
    **/
    public static void throwCustomException(String exceptionName){ 
        throw new CustomException(exceptionName);
    }


    /**
    * @description : method to check insurance plan is valid or not
    * @author Suraj Kumar | 05-20-2024 
    * @param insuranceName 
    **/
    public static void checkInsurancePlan(String insuranceName){
        Schema.DescribeFieldResult fieldResult = clcommon__Collateral__c.Insurance_Plan__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<String> picklistValue = new List<String>();
        for(Schema.PicklistEntry pickListEntryObj: pickListEntry){
            picklistValue.add(pickListEntryObj.getValue());
        }
        if(!picklistValue.contains(insuranceName)){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.CROP_INVALID_INSURANCE_PLAN_TYPE);
        }
    }
    /**
    * @description : method to check insurance plan is valid or not
    * @author Suraj Kumar | 05-20-2024 
    * @param coverageLevel 
    **/
    public static void checkCoverageLevel(String coverageLevel){
        Schema.DescribeFieldResult fieldResult = clcommon__Collateral__c.Percent_Coverage_Level__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<String> picklistValue = new List<String>();
        for(Schema.PicklistEntry pickListEntryObj: pickListEntry){
            picklistValue.add(pickListEntryObj.getValue());
        }
        if(!picklistValue.contains(coverageLevel)){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.CROP_INVALID_PERCENT_COVERAGE_LEVEL_TYPE);
        }
    }
    /**
    * @description : check ssn is of 9 digit or not for spouse details
    * @author Suraj Kumar | 05-20-2024 
    * @param spouseDetailsMap 
    **/
    public static void checkSSN(Map<String,Object> spouseDetailsMap){
        if(!String.isBlank(String.valueOf(spouseDetailsMap.get(ExternalConstants.SSN_KEY)))){
            ExternalValidationUtil.validateSSN(String.valueOf(spouseDetailsMap.get(ExternalConstants.SSN_KEY)), String.valueOf(spouseDetailsMap.get(ExternalConstants.SSN_KEY)));
        }
    }
}