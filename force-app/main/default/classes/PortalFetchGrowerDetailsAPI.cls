/**
 * @description       : This class is called from Grower Details tile and is used to fetch the list of Growers.
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : Sk Minsar
**/
global without sharing class PortalFetchGrowerDetailsAPI implements clcommon.PortalCustomRemoteAPI1 {

    // constants
    private static final String KEY_ID = 'id';
    private static final String KEY_GROWER_NAME = 'grower_name';
    private static final String KEY_EMAIL = 'email';
    private static final String KEY_NEW_EMAIL = 'new_email';
    private static final String KEY_MOBILE_NUMBER = 'mobile_number';
    private static final String KEY_CIF_NUMBER = 'cif_number';
    private static final String KEY_MASKED_TIN = 'masked_tin';
    private static final String KEY_LEGAL_ENTITY = 'legal_entity';
    private static final String KEY_STATUS = 'status';
    private static final String KEY_EVERGREEN_ELIGIBILITY = 'evergreen_eligibility';

    private static List<String> nonIndividualEntityList = new List<String>{
        PortalConstants.CORPORATION,
        PortalConstants.LIMITED_LIABILITY_COMPANY,
        PortalConstants.GENERAL_PARTNERSHIP,
        PortalConstants.LIMITED_PARTNERSHIP,
        PortalConstants.JOINT_VENTURE,
        PortalConstants.TRUST
    };

    /**
    * @description : This method fetches the grower list and creates the response and return.
    * @author Tuhin Bhunia | 04-04-2024
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {
        // Starting
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();
        List<Contact> growerContactList = new List<Contact>();

        try{
            
            User loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser()[0];
            if(loggedInUser.AccountId == null || loggedInUser.Account.ParentId == null){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            growerContactList = [
                SELECT Id,
                       Email,
                       MobilePhone,
                       Masked_SSN__c,
                       New_Email__c,
                       Account.Name,
                       Account.clcommon__Email__c,
                       Account.CIF_Number__c,
                       Account.Is_Evergreen_Allowed__c,
                       Account.clcommon__Legal_Entity_Type__r.Name,
                       Account.genesis__Business_Information__r.Masked_Fed_Tax_ID__c,
                       (SELECT Id,
                                Is_Evergreen_Eligible__c
                        FROM Dealer_Applicant_Relationships__r
                        WHERE Dealer__c = :loggedInUser.Account.ParentId
                        LIMIT 1)
                FROM Contact
                WHERE Id IN (
                    SELECT Applicant_Contact__c
                    FROM Dealer_Applicant_Relationship__c
                    WHERE Dealer__c = :loggedInUser.Account.ParentId
                )
                AND AccountId != null
                AND Account.clcommon__Legal_Entity_Type__c != null 
                AND Account.RecordType.Name IN (:PortalConstants.GROWER_PROFILE, :PortalConstants.CO_APPLICATION_RECORD_TYPE)
                ORDER BY CreatedDate
            ];

            for(Contact contactObj : growerContactList){
                Map<String, Object> responseMap = createGrowerDetailsMap(contactObj);
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseMap));
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;
            
        }catch(CustomException customExceptionObj){
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(customExceptionObj, PortalFetchGrowerDetailsAPI.class.getName());
        }catch(Exception exceptionObj){
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, PortalFetchGrowerDetailsAPI.class.getName());
        }
        return response;
    }
    
    /**
    * @description : This method is used to create the Grower Details response Map
    * @author Tuhin Bhunia | 04-04-2024 
    * @param contactObj 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> createGrowerDetailsMap(Contact contactObj){

        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap = createCommonGrowerDataMap(contactObj);
        if(contactObj.Account.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){

            resultMap.put(KEY_MASKED_TIN, contactObj.Masked_SSN__c);

        }else if(contactObj.Account.clcommon__Legal_Entity_Type__r.Name == PortalConstants.INDIVIDUAL_ENTITY) {

            resultMap.put(KEY_MASKED_TIN, PortalConstants.EMPTY_STRING);

        }else{

            resultMap.put(KEY_MASKED_TIN, contactObj.Account.genesis__Business_Information__r.Masked_Fed_Tax_ID__c);
        }
        return resultMap;
    }

    /**
    * @description : Purpose of this method is to create the grower data map where the values are taken from same fields.
    * @author Tuhin Bhunia | 04-11-2024 
    * @param contactObj 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> createCommonGrowerDataMap(Contact contactObj){

        String status = PortalConstants.EMPTY_STRING;

        if(contactObj.New_Email__c == null){
            status = PortalConstants.NO_PENDING_ACTION;
        }else if(contactObj.New_Email__c != null && 
                contactObj.New_Email__c != contactObj.Email
            ){
            status = PortalConstants.EMAIL_CHANGE_IN_PROGRESS_STATUS;
        }
        Map<String, Object> growerDetailsMap = new Map<String, Object>{
            KEY_ID => contactObj.Id,
            KEY_MOBILE_NUMBER => contactObj.MobilePhone,
            KEY_CIF_NUMBER => contactObj.Account.CIF_Number__c,
            KEY_GROWER_NAME => contactObj.Account.Name,
            KEY_EMAIL => contactObj.Email,
            KEY_LEGAL_ENTITY => contactObj.Account.clcommon__Legal_Entity_Type__r.Name,
            KEY_STATUS => status,
            KEY_NEW_EMAIL => contactObj.New_Email__c,
            KEY_EVERGREEN_ELIGIBILITY => EvergreenCheckHandler.convertEvergreenStatusToString(contactObj.Dealer_Applicant_Relationships__r[0].Is_Evergreen_Eligible__c)
        };
        return growerDetailsMap;
    }
}