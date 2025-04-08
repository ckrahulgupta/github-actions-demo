/**
 * @description       : Return all the growers of a particular Dealer
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 13-02-2025
 * @last modified by  : Soumik Pattanayak
**/

global without sharing class PortalFetchGrowersAPI implements clcommon.PortalCustomRemoteAPI1 {

    // constants
    private static final String KEY_QUERY = 'query';
    private static final String CLASS_NAME = 'PortalFetchGrowersAPI';
    private static final String CFA = 'CFA';
    private static final String GROWMARK = 'Growmark';
    private static final String LANDUS = 'Landus';
    private static final String KEY_ACCOUNT_ID = 'accountId';
    private static final String KEY_ACCOUNT_NAME = 'accountName';
    private static final String KEY_ACCOUNT_EMAIL = 'accountEmail';
    private static final String KEY_LEGAL_ENTITY_ID = 'legalEntityId';
    private static final String KEY_BUSINESS_INFORMATION_ID = 'businessInformationId';
    private static final String KEY_LEGAL_ENTITY_NAME = 'legalEntityName';


    /**
     * @description : Purpose of this method to fetch the logged in user details
     * @return  `User`
     */
    private static User getLoggedInUser() {
        List<User> objLoggedInUserList = [
                SELECT Id,
                      ContactId,
                      AccountId,
                      Account.ParentId,
                      Account.Parent.Coop_Type__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
    
        return objLoggedInUserList.size() != 1 ? null : objLoggedInUserList[0];
    }

   /**
    * @description : This method is used to fetch growers based on their name, SSN or TIN and where the party type is Borrower.
    * @author Rahul Gupta | 08-08-2023
    * @param loggedInUser 
    * @param query 
    * @return  `List<clcommon.PortalCustomRemoteActionRecord>`
    */
    private static List<clcommon.PortalCustomRemoteActionRecord> fetchGrowersRecord(User loggedInUser, String query) {
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

        List<Dealer_Applicant_Relationship__c> darList = [SELECT Id, 
                                                                Applicant__c,
                                                                Applicant__r.Name,
                                                                Applicant__r.clcommon__Legal_Entity_Type__r.Id,
                                                                Applicant__r.clcommon__Legal_Entity_Type__r.Name,
                                                                Applicant__r.genesis__Business_Information__r.Id,
                                                                Applicant__r.clcommon__Email__c
                                                        FROM Dealer_Applicant_Relationship__c
                                                        WHERE Dealer__c = :loggedInUser.Account.ParentId
                                                        AND (Applicant__r.Name LIKE :(PortalConstants.PERCENTAGE_STRING + query + PortalConstants.PERCENTAGE_STRING)
                                                        OR Applicant_Contact__r.genesis__SSN__c LIKE :(PortalConstants.PERCENTAGE_STRING + query)
                                                        OR Applicant__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c LIKE :(PortalConstants.PERCENTAGE_STRING + query))];

        for (Dealer_Applicant_Relationship__c darObj : darList) {
            Map<String, Object> growerData = new Map<String, Object>();

            growerData.put(KEY_ACCOUNT_ID, darObj.Applicant__c);
            growerData.put(KEY_ACCOUNT_NAME, darObj.Applicant__r.Name);
            growerData.put(KEY_ACCOUNT_EMAIL, darObj.Applicant__r.clcommon__Email__c);
            growerData.put(KEY_LEGAL_ENTITY_ID, darObj.Applicant__r.clcommon__Legal_Entity_Type__r.Id);
            growerData.put(KEY_BUSINESS_INFORMATION_ID, darObj.Applicant__r.genesis__Business_Information__r.Id);
            growerData.put(KEY_LEGAL_ENTITY_NAME, darObj.Applicant__r.clcommon__Legal_Entity_Type__r.Name);

            responseData.add(new clcommon.PortalCustomRemoteActionRecord(growerData));
        }

        return responseData;
    }

   /**
    * @description : This method takes and validates the portal request and returns the grower details to the portal.
    * @author Rahul Gupta | 18-04-2022
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return  `clcommon.Response`
    * @exception 
    */
    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();
    
        try {
            if (request.get(KEY_QUERY) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            String query = String.valueOf(request.get(KEY_QUERY));

            User loggedInUser = getLoggedInUser();

            if (loggedInUser == null) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }

            responseData = fetchGrowersRecord(loggedInUser, query);
 
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
}