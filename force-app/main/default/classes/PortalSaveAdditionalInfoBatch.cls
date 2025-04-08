/**********************************************************************************************************************
 * @description       : Purpose of this batch class is to fix Governor Limit Exception for adding all the additional information (Multiple Buyer's , Insurance Agent , Landowner's , Spouse) and store them in salesforce and this class is called from PortalSaveAdditionalInfoAPI .
 * @author            : Suraj Kumar | 12-26-2023
 * @group             : 
 * @last modified on  : 01-04-2024
 * @last modified by  : Suraj Kumar
**********************************************************************************************************************/

global without sharing class PortalSaveAdditionalInfoBatch implements Database.Batchable<Map<String,String>> {

    //parameters specific for this class Starts 
    private static final String CLASS_NAME = PortalSaveAdditionalInfoBatch.class.getName();
    private static final String SPOUSE_DETAILS = 'spouseDetails';
    private static final String ADDITIONAL_CROP_DETAILS = 'additionalCropDetails';
    private static final String POTENTIAL_BUYERS_DETAILS = 'potentialBuyerdetails';
    private static final String CROP_INDURANCE_DETAILS = 'cropInsuranceDetails';
    private static final String KEY_APPLICATION = 'applicationId';
    private static final String ACCOUNT_SOBJECT = 'Account';
    private static final String RECORD_TYPE_MAP = 'recordTypeMap';
    private static final String PARTY_TYPE_MAP = 'partyTypeMap';
    private static final String FIELD_ACCOUNT_NAME = 'clcommon__Account__r.Name';
    private static final String FIELDS_ACCOUNT_COUNTY = 'clcommon__Account__r.Billing_County__c';
    private static final String KEY_SAVE_TYPE = 'shouldValidate';
    private static final String FIELD_CONTACT_FIRST_NAME = 'clcommon__Contact__r.FirstName';
    private static final String FIELD_CONTACT_LAST_NAME = 'clcommon__Contact__r.LastName';
    private static final String FIELDS_ACCOUNT_STREET = 'clcommon__Account__r.BillingStreet';
    private static final String FIELDS_ACCOUNT_CITY = 'clcommon__Account__r.BillingCity';
    private static final String FIELDS_ACCOUNT_STATE = 'clcommon__Account__r.BillingState';
    private static final String FIELDS_ACCOUNT_POSTAL_CODE = 'clcommon__Account__r.BillingPostalCode';
    private static final String PARTY_TYPE = 'partyType';
    //parameters specific for this class End

    List<Map<String,String>> additionalInfoList = new List<Map<String,String>>();
    Map<String, String> requestParamMap = new Map<String,String>();
    Boolean shouldValidate = false;

    /**
	* @description 
	* @author Suraj Kumar | 12-26-2023 
	* @param requestParamMap 
	**/
    public PortalSaveAdditionalInfoBatch(Map<String,String> requestParamMap ) {
        this.requestParamMap = requestParamMap;
    }
    
	/**
	* @description 
	* @author Suraj Kumar | 12-26-2023 
	* @param bc 
	* @return Iterable 
	**/
	public Iterable<Map<String,String>> start(Database.BatchableContext bc) {
        additionalInfoList.add(requestParamMap);
        return additionalInfoList;
    }
    /**
    * @description 
    * @author Suraj Kumar | 12-26-2023 
    * @param bc 
    * @param additionalInfoList 
    **/
    public void execute(Database.BatchableContext bc, List<Map<String,String>> additionalInfoList){
        try{
            validateRequiredParameters(additionalInfoList);
            Map<String, String> requestParamMap = additionalInfoList.get(0);
            String spouseDetails = requestParamMap.get(SPOUSE_DETAILS);
            String additionalCropDetails = requestParamMap.get(ADDITIONAL_CROP_DETAILS);
            String potentialBuyerdetails = requestParamMap.get(POTENTIAL_BUYERS_DETAILS);
            String cropInsuranceDetails = requestParamMap.get(CROP_INDURANCE_DETAILS);
            String applicationId = requestParamMap.get(KEY_APPLICATION);
            String partyTypeName = requestParamMap.get(PARTY_TYPE);
            shouldValidate = Boolean.valueOf(requestParamMap.get(KEY_SAVE_TYPE));

            List<Object> spouseDetailsList = (List<Object>) JSON.deserializeUntyped (spouseDetails);
            List<Object> additionalCropDetailsList = (List<Object>) JSON.deserializeUntyped (additionalCropDetails);
            List<Object> potentialBuyerdetailsList = (List<Object>) JSON.deserializeUntyped (potentialBuyerdetails);
            List<Object> cropInsuranceDetailsList = (List<Object>) JSON.deserializeUntyped (cropInsuranceDetails);

            genesis__Applications__c application = [SELECT Id,
                                                            genesis__Loan_Amount__c,
                                                            Additional_Information_Needed__c,
                                                            genesis__Credit_Rating__r.Name, 
                                                            Credit_Application_And_Agreement_Process__c,
                                                            Does_Applicant_Feed_Above_Collaterals__c
                                                        FROM genesis__Applications__c
                                                        WHERE Id = :applicationId
                                                        LIMIT 1];

            Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
            Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
            Map<String, Object> containsPartyRecordMap = new Map<String, Object>();

            //Querrying record Type 
            RecordType partyRecordTypeObj = [ SELECT Id,
                                                        SobjectType,
                                                        Name
                                                    FROM RecordType
                                                    WHERE Name = :partyTypeName AND
                                                    SobjectType = :ACCOUNT_SOBJECT LIMIT 1];
            partyRecordTypeMap.put(partyTypeName, partyRecordTypeObj);


            //Querring party type
            List<clcommon__Party_Type__c> partyTypeObjList = [SELECT id
                                                                    FROM clcommon__Party_Type__c
                                                                    WHERE NAME =:partyTypeName LIMIT 1];
            partyTypeMap.put(partyTypeName, partyTypeObjList[0]);

            //putting RecordType , partyType into containsPartyRecordMap
            containsPartyRecordMap.put(KEY_APPLICATION, applicationId);
            containsPartyRecordMap.put(RECORD_TYPE_MAP, partyRecordTypeMap);
            containsPartyRecordMap.put(PARTY_TYPE_MAP, partyTypeMap);
            containsPartyRecordMap.put(KEY_SAVE_TYPE,shouldValidate);

            if(partyTypeName.equals(PortalConstants.SPOUSE_PARTY_NAME)){
                // processing spouse details
                PortalApplicationOriginationHelper.processSpouseDetails(spouseDetailsList, containsPartyRecordMap, application);
            }

            if(partyTypeName.equals(PortalConstants.LANDOWNER_PARTY_NAME)){
                //processing additional crop details
                PortalApplicationOriginationHelper.processAdditionalCropDetails(additionalCropDetailsList, containsPartyRecordMap, application);
            }

            if(partyTypeName.equals(PortalConstants.BUYER_PARTY_NAME)){
                // processing portential buyer details
                PortalApplicationOriginationHelper.processPotentialBuyers(potentialBuyerdetailsList, containsPartyRecordMap, application);
            }

            if(partyTypeName.equals(PortalConstants.INSURANCE_AGENT_PARTY_NAME)){
                // processing crop insurance details
                PortalApplicationOriginationHelper.processCropInsuranceDetails(cropInsuranceDetailsList, containsPartyRecordMap, application);
            }
        } catch (Exception objException) {
            Portalhelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
    /**
    * @description 
    * @author Suraj Kumar | 12-26-2023 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-26-2023 
    * @param additionalInfoList 
    **/
    private void validateRequiredParameters(List<Map<String,String>> additionalInfoList){
        validateAdditionalInfo(additionalInfoList);
        Map<String, String> requestParamMap = additionalInfoList.get(0);
        if(!requestParamMap.containsKey(SPOUSE_DETAILS) || !requestParamMap.containsKey(ADDITIONAL_CROP_DETAILS) 
            || !requestParamMap.containsKey(POTENTIAL_BUYERS_DETAILS) || !requestParamMap.containsKey(CROP_INDURANCE_DETAILS) 
            || !requestParamMap.containsKey(KEY_APPLICATION) || !requestParamMap.containsKey(KEY_SAVE_TYPE)
            || !requestParamMap.containsKey(PARTY_TYPE)){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    
    /**
    * @description 
    * @author Suraj Kumar | 12-29-2023 
    * @param additionalInfoList 
    **/
    private static void validateAdditionalInfo(List<Map<String,String>> additionalInfoList){
        if(additionalInfoList.size() != 1){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}