/**
 * @description       : Fetches all the possible coapplicants of a particular dealer
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Krishanu Chinya
**/
global without sharing class PortalFetchCoApplicantsAPI implements clcommon.PortalCustomRemoteAPI1 {
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private static final String COAPPLICANT_NAME = 'coApplicantName';
    private static final String COAPPLICANT_EMAIL = 'coApplicantEmail';
    private static final String COAPPLICANT_SSN = 'coApplicantSSN';
    private static final String COAPPLICANT_ACC_ID = 'coApplicantAccId';
    private static final String COAPPLICANT_BUSINESS_ID = 'coApplicantBusinessId';

    List<User> loggedInUser = new List<User>();


    /**
    * @description : Constructor to initialise the required objects
    * @author Krishanu Chinya | 02-15-2024 
    **/
    global PortalFetchCoApplicantsAPI() {
        this.loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser(); 
    }

    /**
    * @description : this method is used to fetch all the possible coaplicants of the current dealer
    * @author Krishanu Chinya | 02-15-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName, String[] disclosureNames, Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();

        try {
            String dealerId = loggedInUser[0].Account.ParentId;
            List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
            Map<Id, clcommon__Party__c> partyMap = new Map<Id, clcommon__Party__c>();


            partyList = [SELECT Id, 
                                clcommon__Account__r.Id,
                                clcommon__Account__r.genesis__business_information__c,
                                clcommon__Account__r.Name, 
                                clcommon__Contact__r.Id,
                                clcommon__Contact__r.Email,
                                clcommon__Contact__r.Masked_SSN__c, 
                                genesis__Application__c 
                        FROM clcommon__Party__c 
                        WHERE clcommon__Account__r.RecordType.Name IN (
                                :PortalConstants.GROWER_PROFILE, 
                                :PortalConstants.CO_APPLICATION_RECORD_TYPE) 
                        AND clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name =: PortalConstants.SOLE_PROP_ENTITY
                        AND (genesis__Application__r.Dealer_Name__c =: dealerId 
                                OR clcommon__Account__r.ParentId =: dealerId)];


            for(clcommon__Party__c eachParty : partyList){
                if (!partyMap.containsKey((Id) eachParty.clcommon__Account__r.Id)) {
                    partyMap.put((Id) eachParty.clcommon__Account__r.Id, eachParty);
                }    
            }

            for (Id key : partyMap.keySet()){
                Map<String, Object> coApplicantDataMap = new Map<String, Object>();

                coApplicantDataMap.put(COAPPLICANT_NAME, partyMap.get(key).clcommon__Account__r.Name);
                coApplicantDataMap.put(COAPPLICANT_EMAIL, partyMap.get(key).clcommon__Contact__r.Email);
                coApplicantDataMap.put(COAPPLICANT_SSN, partyMap.get(key).clcommon__Contact__r.Masked_SSN__c);
                coApplicantDataMap.put(COAPPLICANT_ACC_ID, partyMap.get(key).clcommon__Account__r.Id);
                coApplicantDataMap.put(COAPPLICANT_BUSINESS_ID, partyMap.get(key).clcommon__Account__r.genesis__business_information__c);

                responseData.add(new clcommon.PortalCustomRemoteActionRecord(coApplicantDataMap));
            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
          
        }catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
        return response;
    }
}