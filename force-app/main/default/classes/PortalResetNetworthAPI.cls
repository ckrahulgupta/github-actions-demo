/**
 * @description       :  Reset Net Worth For Evergreen Tier 2
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 10-01-2025
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalResetNetworthAPI implements clcommon.PortalCustomRemoteAPI1 {
    //Constant specific to this class starts
    private static final string APPLICATION_ID = PortalConstants.APPLICATION_ID;
    private static final string EVERGREEN_TIER_TWO_IN_PROGRESS_STATUS = PortalConstants.EVERGREEN_BIZ_STATUS_IN_PROGRESS;
    private static final string MISSING_ARGUMENTS = PortalConstants.MISSING_ARGUMENTS;
    //Constants specific to this class ends
    
     /**
    * @description : Validate User
    * @author  Pritam Roy | 05-16-2024 
    * @param isValidUser 
    * @param objExceptionString 
    **/
    private static void checkValidUser(Boolean isValidUser, String objExceptionString){
        if(isValidUser == false){
            throw new CustomException(objExceptionString);
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
    * @description : Fetch Party Details
    * @author  Pritam Roy | 05-21-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName, String[] disclosureNames, Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        List<genesis__Business_Information__c> businessInfoList = new List<genesis__Business_Information__c>();
        List<clcommon__Party__c> partyToUpdateList = new List<clcommon__Party__c>();
        clcommon.Response response = new clcommon.Response();
        String applicationId = '';

        try {
            //Get Application Id
            applicationId = getKeyValue(request, APPLICATION_ID);
            
            //Validate User with Application
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId);
            checkValidUser(isValidUser, PortalConstants.USER_NOT_AUTHORISED);

            //Query All Parties to Update
            partyToUpdateList = [SELECT Id, 
                                Total_Assets__c,
                                Total_Liabilities__c,
                                genesis__Application__c,
                                clcommon__Party_Types__c,
                                genesis__Application__r.Net_Worth__c,
                                genesis__Application__r.Evergreen_Tier_Two_Business_Info_Status__c,
                                clcommon__Account__r.genesis__Business_Information__c,
                                Gross_Farm_Income__c
                        FROM clcommon__Party__c 
                        WHERE genesis__Application__c =: applicationId
                        AND clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME,
                                                            :PortalConstants.PRINCIPAL_PARTY_NAME)
                        AND clcommon__Account__r.clcommon__Legal_Entity_Type__r.name !=: PortalConstants.INDIVIDUAL_ENTITY];
            
            PortalApplicationOriginationHelper.checkEmptyList(partyToUpdateList, ConstantValues.LIST_EMPTY_CHECK);

            for(clcommon__Party__c eachPartyObj : partyToUpdateList){
                eachPartyObj.Total_Assets__c = 0;
                eachPartyObj.Total_Liabilities__c = 0;
                eachPartyObj.Gross_Farm_Income__c = 0;

                genesis__Business_Information__c businessToUpdateObj = new genesis__Business_Information__c(Id = eachPartyObj.clcommon__Account__r.genesis__Business_Information__c);
                businessToUpdateObj.genesis__Total_Assets__c = 0;
                businessToUpdateObj.genesis__Total_Liabilities__c = 0;
                businessToUpdateObj.Gross_Farm_Income__c = 0;
                businessInfoList.add(businessToUpdateObj);
            }
            Database.update(partyToUpdateList, true);
            Database.update(businessInfoList, true);

            genesis__Applications__c appToUpdateObj = new genesis__Applications__c(Id =  partyToUpdateList[0].genesis__Application__c);
            appToUpdateObj.Net_Worth__c = NULL;
            appToUpdateObj.Evergreen_Tier_Two_Business_Info_Status__c = EVERGREEN_TIER_TWO_IN_PROGRESS_STATUS;
            Database.update(appToUpdateObj, true);

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
          
        }catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, PortalResetNetworthAPI.class.getName());
        }
        return response;
    }
}