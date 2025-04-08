/**
 * @description       : This batch is used to add additional information details 
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 05-23-2024
 * @last modified by  : Suraj Kumar
**/
global without sharing class ExternalAdditionalInformationBatch implements Database.Batchable<Map<String,Object>> {
    private static final String CLASS_NAME = ExternalAdditionalInformationBatch.class.getName();
    private static final String ACCOUNT_SOBJECT = 'Account';

    List<Map<String,Object>> additionalInfoList = new List<Map<String,Object>>();
    Map<String, Object> requestParamMap = new Map<String,Object>();

     /**
	* @description 
	* @author Suraj Kumar | 12-26-2023 
	* @param requestParamMap 
	**/
    public ExternalAdditionalInformationBatch(Map<String,Object> requestParamMap ) {
        this.requestParamMap = requestParamMap;
    }

    /**
	* @description 
	* @author Suraj Kumar | 12-26-2023 
	* @param bc 
	* @return Iterable 
	**/
	public Iterable<Map<String,Object>> start(Database.BatchableContext bc) {
        additionalInfoList.add(requestParamMap);
        return additionalInfoList;
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-26-2023 
    * @param bc 
    * @param additionalInfoList 
    **/
    public void execute(Database.BatchableContext bc, List<Map<String,Object>> additionalInfoList){
        try{
            validateRequiredParameters(additionalInfoList);
            Map<String, Object> requestParamMap = additionalInfoList.get(0);
            String applicationId = String.valueOf(requestParamMap.get(ExternalConstants.APPLICATION_KEY));
            String partyTypeName = String.valueOf(requestParamMap.get(ExternalConstants.PARTY_TYPE));

            List<Object> spouseDetailsList = (List<Object>) requestParamMap.get(ExternalConstants.SPOUSE_KEY);
            List<Object> additionalCropDetailsList = (List<Object>) requestParamMap.get(ExternalConstants.LANDOWNER_KEY);
            List<Object> potentialBuyerdetailsList = (List<Object>) requestParamMap.get(ExternalConstants.BUYER_KEY);
            List<Object> cropInsuranceDetailsList = (List<Object>) requestParamMap.get(ExternalConstants.INSURANCE_AGENT_KEY);

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
            List<clcommon__Party_Type__c> partyTypeObjList = [SELECT Id
                                                                    FROM clcommon__Party_Type__c
                                                                    WHERE NAME =:partyTypeName 
                                                                    LIMIT 1];
            partyTypeMap.put(partyTypeName, partyTypeObjList[0]);

            //putting RecordType , partyType into containsPartyRecordMap
            containsPartyRecordMap.put(ExternalConstants.APPLICATION_KEY, applicationId);
            containsPartyRecordMap.put(ExternalConstants.RECORD_TYPE_MAP_KEY, partyRecordTypeMap);
            containsPartyRecordMap.put(ExternalConstants.PARTY_TYPE_MAP_KEY, partyTypeMap);
            if(partyTypeName.equals(ExternalConstants.SPOUSE_PARTY_NAME)){
                // processing spouse details
                ExternalAdditionalInformationHandler.processSpouseDetails(spouseDetailsList, containsPartyRecordMap, application);
            }

            if(partyTypeName.equals(ExternalConstants.LANDOWNER_PARTY_NAME)){
                //processing additional crop details
                ExternalAdditionalInformationHandler.processAdditionalCropDetails(additionalCropDetailsList, containsPartyRecordMap, application);
            }

            if(partyTypeName.equals(ExternalConstants.BUYER_PARTY_NAME)){
                // processing portential buyer details
                ExternalAdditionalInformationHandler.processPotentialBuyers(potentialBuyerdetailsList, containsPartyRecordMap, application);
            }

            if(partyTypeName.equals(ExternalConstants.INSURANCE_AGENT_PARTY_NAME)){
                // processing crop insurance details
                ExternalAdditionalInformationHandler.processCropInsuranceDetails(cropInsuranceDetailsList, containsPartyRecordMap, application);
            }
        } catch (Exception exceptionObj) {
            ExternalExceptionUtil.saveExceptionLog(exceptionObj, CLASS_NAME);
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
    private void validateRequiredParameters(List<Map<String,Object>> additionalInfoList){
        validateAdditionalInfo(additionalInfoList);
        Map<String, Object> requestParamMap = additionalInfoList.get(0);
        if(!requestParamMap.containsKey(ExternalConstants.SPOUSE_KEY) || !requestParamMap.containsKey(ExternalConstants.LANDOWNER_KEY) 
            || !requestParamMap.containsKey(ExternalConstants.BUYER_KEY) || !requestParamMap.containsKey(ExternalConstants.INSURANCE_AGENT_KEY) 
            || !requestParamMap.containsKey(ExternalConstants.APPLICATION_KEY) || !requestParamMap.containsKey(ExternalConstants.PARTY_TYPE)){
                throw new CustomException(ExternalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    
    /**
    * @description 
    * @author Suraj Kumar | 12-29-2023 
    * @param additionalInfoList 
    **/
    private static void validateAdditionalInfo(List<Map<String,Object>> additionalInfoList){
        if(additionalInfoList.size() != 1){
            throw new CustomException(ExternalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}