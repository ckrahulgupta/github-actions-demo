/**********************************************************************************************************************
 * @description       : This Portal API helps in getting the count for all the individual applications status.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : Krishanu Chinya
**********************************************************************************************************************/

global without sharing class PortalApplicationStatusCountAPI implements clcommon.PortalCustomRemoteAPI1 {

    // parameters specific for this class [start]
    private static final String CLASS_NAME = 'PortalApplicationStatusCountAPI';
    private static final String KEY_APPLICATION_STATUS_COUNT = 'applicationStatusCount';

    private static Integer value;
    private static Map<String,Integer> responseMap = new Map<String, Integer> {
        PortalConstants.ALL_APPLICATION => 0,
        PortalConstants.INCOMPLETE_STATUS => 0,
        PortalConstants.REVIEW_STATUS => 0,
        PortalConstants.PENDING_STATUS => 0,
        PortalConstants.BOOKED_STATUS => 0,
        PortalConstants.E_SIGN_PENDING => 0,
        PortalConstants.E_SIGN_COMPLETE => 0,
        PortalConstants.SCORED => 0,
        PortalConstants.WITHDRAWN => 0,
        PortalConstants.EXPIRED => 0,
        PortalConstants.DENIED => 0,
        PortalConstants.ACTIVE_STATUS => 0,
        PortalConstants.PAPER_SCANNED_PENDING => 0,
        PortalConstants.EVERGREEN_RENEWAL => 0
    };
    // parameters specific for this class [end]

    /**
    * @description - Purpose of this method is to iterate through all the application and provide the 
    *                count for different application status
    * @author Arka Jyoti Deb | 04-26-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        Integer total;
        List<User> objCurrentUserList = new List<User>();
        clcommon.Response response = new clcommon.Response();
        Map<String,Map<String,Integer>> parseResponseMap = new Map<String,Map<String,Integer>>();
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
        List<clcommon.PortalCustomRemoteActionRecord> responseDataMap = new List<clcommon.PortalCustomRemoteActionRecord>();

        try {
            objCurrentUserList = PortalApplicationOriginationHelper.getLoggedInUser();

            objApplicationList = [SELECT Id,
                                        Signing_Method__c,
                                        genesis__Status__c,
                                        Is_Evergreen__c 
                                    FROM genesis__Applications__c
                                    WHERE Id IN (SELECT genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Account__r.Id = :objCurrentUserList[0].AccountId
                                                AND genesis__Application__r.Dealer_Name__c = :objCurrentUserList[0].Account.ParentId)];
            
            Set<genesis__Applications__c> objApplicationSet = new Set<genesis__Applications__c>(objApplicationList);
            segregateApplicationStatus(objApplicationSet); // this method will update the application status map (responseMap)

            total = responseMap.get(PortalConstants.REVIEW_STATUS) 
                        + responseMap.get(PortalConstants.EXPIRED) 
                        + responseMap.get(PortalConstants.DENIED) 
                        + responseMap.get(PortalConstants.BOOKED_STATUS) 
                        + responseMap.get(PortalConstants.WITHDRAWN) 
                        + responseMap.get(PortalConstants.PENDING_STATUS) 
                        + responseMap.get(PortalConstants.E_SIGN_PENDING) 
                        + responseMap.get(PortalConstants.PAPER_SCANNED_PENDING)
                        + responseMap.get(PortalConstants.INCOMPLETE_STATUS);
                        // + responseMap.get(PortalConstants.ACTIVE_STATUS);

            responseMap.put(PortalConstants.ALL_APPLICATION, total);
            parseResponseMap.put(KEY_APPLICATION_STATUS_COUNT, responseMap);
            responseDataMap.add( new clcommon.PortalCustomRemoteActionRecord(parseResponseMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataMap);
            response.content = null;
            response.status = clcommon.Constants.SUCCESS; 
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response; 
    }

    /**
    * @description - Purpose of this method is to iterate through all the application and updates the 
    *                status count map.
    * @author Tuhin Bhunia | 12-26-2023 
    * @param objApplicationSet
    **/
    private static void segregateApplicationStatus(Set<genesis__Applications__c> objApplicationSet){

        List<String> applicationStatusList = new List<String>{

            PortalConstants.NEW_ENTERED_APPLICATION_STATUS,
            PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS,
            PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS,
            PortalConstants.NEW_SCORECARD_APPLICATION_STATUS,

            PortalConstants.WITHDRAWN_APPLICATION_STATUS,
            PortalConstants.PENDING_WITHDRAWAL_APPLICATION_STATUS,
            PortalConstants.BOOK_TO_CORE_APPLICATION_STATUS,
            PortalConstants.EXPIRED_APPLICATION_STATUS,

            PortalConstants.REJECTED_APPLICATION_STATUS,
            PortalConstants.NEW_SUBMITTED_APPLICATION_STATUS,
            PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS,
            PortalConstants.ACTIVE_APPLICATION_STATUS
        };

        for(genesis__Applications__c objApplication: objApplicationSet){

            if(applicationStatusList.contains(objApplication.genesis__Status__c)){

                isNewApplication(objApplication);
                isApplicationEsignPending(objApplication);
                isApplicationPaperScannedPending(objApplication);
                isApplicationPendingStatus(objApplication); // not used in portal
                isApplicationWithdrawn(objApplication);
                isApplicationBookedToCore(objApplication);
                isApplicationExpired(objApplication);
                isApplicationRejected(objApplication);
                isApplicationScored(objApplication);
                isApplicationSubmitted(objApplication);
                isApplicationSigningCompleted(objApplication);
                isApplicationActive(objApplication);
                isApplicationEvergreenRenewal(objApplication);
                
            }else{
                continue;
            }
            
        }
    }

    /**
     * @description - This method check if the application status is New - Entered.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication
     */
    private static void isNewApplication(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.NEW_ENTERED_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.INCOMPLETE_STATUS);
            responseMap.put(PortalConstants.INCOMPLETE_STATUS, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is E-Sign Pending.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationEsignPending(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS) 
                && (objApplication.Signing_Method__c.equals(PortalConstants.EMAIL_DOCUSIGN) 
                        | objApplication.Signing_Method__c.equals(PortalConstants.IN_PERSON_DOCUSIGN) 
                        | objApplication.Signing_Method__c.equals(ConstantValues.HYBRID_DOCUSIGN))){
            value = responseMap.get(PortalConstants.E_SIGN_PENDING);
            responseMap.put(PortalConstants.E_SIGN_PENDING, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Paper - Scanned.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationPaperScannedPending(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS) && objApplication.Signing_Method__c.equals(PortalConstants.PAPER_SCANNED)){
            value = responseMap.get(PortalConstants.PAPER_SCANNED_PENDING);
            responseMap.put(PortalConstants.PAPER_SCANNED_PENDING, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Pending
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationPendingStatus(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS) || objApplication.genesis__Status__c.equals(PortalConstants.NEW_SCORECARD_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.PENDING_STATUS);
            responseMap.put(PortalConstants.PENDING_STATUS, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Withdrawn.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationWithdrawn(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.WITHDRAWN_APPLICATION_STATUS) || objApplication.genesis__Status__c.equals(PortalConstants.PENDING_WITHDRAWAL_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.WITHDRAWN);
            responseMap.put(PortalConstants.WITHDRAWN, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Booked to Core.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationBookedToCore(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.BOOK_TO_CORE_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.BOOKED_STATUS);
            responseMap.put(PortalConstants.BOOKED_STATUS, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Expired.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationExpired(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.EXPIRED_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.EXPIRED);
            responseMap.put(PortalConstants.EXPIRED, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Rejected.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationRejected(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.REJECTED_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.DENIED);
            responseMap.put(PortalConstants.DENIED, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Scored.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationScored(genesis__Applications__c objApplication){
        
        if(objApplication.genesis__Status__c.equals(PortalConstants.NEW_SCORECARD_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.SCORED);
            responseMap.put(PortalConstants.SCORED, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Submitted.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationSubmitted(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.NEW_SUBMITTED_APPLICATION_STATUS) || objApplication.genesis__Status__c.equals(PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.REVIEW_STATUS);
            responseMap.put(PortalConstants.REVIEW_STATUS, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Signature - Completed.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationSigningCompleted(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.E_SIGN_COMPLETE);
            responseMap.put(PortalConstants.E_SIGN_COMPLETE, value + 1);
        }
    }

    /**
     * @description - This method check if the application status is Active.
     * @author Tuhin Bhunia | 12-26-2023
     * @param objApplication 
     */
    private static void isApplicationActive(genesis__Applications__c objApplication){

        if(objApplication.genesis__Status__c.equals(PortalConstants.ACTIVE_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.ACTIVE_STATUS);
            responseMap.put(PortalConstants.ACTIVE_STATUS, value + 1);
        }
    }

    /**
    * @description - This method check if the application is Evergreen or Not
    * @author Sk Minsar | 06-19-2024 
    * @param objApplication 
    **/
    private static void isApplicationEvergreenRenewal(genesis__Applications__c objApplication){

        if(objApplication.Is_Evergreen__c == PortalConstants.TRUE_VALUE && !objApplication.genesis__Status__c.equals(PortalConstants.ACTIVE_APPLICATION_STATUS) && !objApplication.genesis__Status__c.equals(PortalConstants.CLOSED_APPLICATION_STATUS)){
            value = responseMap.get(PortalConstants.EVERGREEN_RENEWAL);
            responseMap.put(PortalConstants.EVERGREEN_RENEWAL, value + 1);
        }
    }
}