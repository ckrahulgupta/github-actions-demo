/**
 * @description       :  Handler Class for Evergreen Checks
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 10-01-2025
 * @last modified by  : Soumik Pattanayak
**/
public inherited sharing class EvergreenCheckHandler {
    private static final String EXCEPTION_STRING = 'Empty Parameters';
    /**
    * @description : Check Evergreen Eligiblity if the Grower Marked as Evergreeen Allowed
    * @author  Pritam Roy | 05-09-2024 
    * @param objApplication 
    * @return genesis__Applications__c
    **/
    public static genesis__Applications__c checkIsEvergreenEligible(genesis__Applications__c objApplication){
        //Check Application's party's Evergreen Eligibility
        List<clcommon__party__c> partyList = [SELECT Id,
                                                     Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                     Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                     Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c
                                                     FROM clcommon__Party__c 
                                                     WHERE genesis__Application__c = :objApplication.Id
                                                     AND clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME,
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME) 
                                                     WITH SECURITY_ENFORCED];
        for(clcommon__party__c party: partyList){
            if(!party.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c){
                objApplication.Is_Evergreen_Eligible__c = PortalConstants.FALSE_VALUE;
                return objApplication;
            }
            if(party.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c || party.Dealer_Applicant_Relationship__r.Has_Past_Due__c){
                objApplication.Is_Evergreen_Eligible__c = PortalConstants.FALSE_VALUE;
                return objApplication;
            }
        }
        objApplication.Is_Evergreen_Eligible__c = PortalConstants.TRUE_VALUE;
        return objApplication;
    }
    /**
    * @description - Sets the Application's Evergreen Eligibility void if Grower marked as Not Allowed
    * @author Sk Minsar | 05-13-2024 
    * @param applicationObj 
    * @param isActiveOrClosed 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c updateEvergreenStatusForNotAllowed(genesis__Applications__c applicationObj, boolean isActiveOrClosed) {
        if(isActiveOrClosed){
            applicationObj.Is_Evergreen_Eligible__c = PortalConstants.FALSE_VALUE;
        } else{
            applicationObj.Is_Evergreen__c = PortalConstants.FALSE_VALUE;
            applicationObj.Stage__c = PortalConstants.APPLICANT_INFORMATION;
            applicationObj.genesis__Status__c = PortalConstants.NEW_ENTERED_APPLICATION_STATUS;
        }
        return applicationObj;
    }

    /**
    * @description - Sets the Application's Evergreen Eligibility true if Grower marked as Allowed
    * @author Sk Minsar | 05-13-2024 
    * @param applicationObj 
    * @param isActiveOrClosed 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c updateEvergreenStatusForAllowed(genesis__Applications__c applicationObj, boolean isActiveOrClosed) {
        if (isActiveOrClosed) {
            if(applicationObj.genesis__Credit_Rating__c != null &&
                (applicationObj.genesis__Credit_Rating__r.Name != ConstantValues.CREDIT_RATE_4)){
                    applicationObj = checkIsEvergreenEligible(applicationObj);
            }
        }
        return applicationObj;
    }

    /**
    * @description - This method is used to handle the isEvergreenAllowed value to Boolean
    * @author Sk Minsar | 05-10-2024 
    * @param isEvergreenAllowed 
    * @return Boolean 
    **/
    public static Boolean convertEvergreenStatusToBoolean(String isEvergreenAllowed) {
        if (isEvergreenAllowed.equals(PortalConstants.EVERGREEN_NOT_ALLOWED)) { 
            return PortalConstants.FALSE_VALUE;
        }
        return PortalConstants.TRUE_VALUE;
    }
    
    /**
    * @description - This method is used to handle the isEvergreenAllowed value to String
    * @author Sk Minsar | 05-07-2024 
    * @param isEvergreenAllowed 
    * @return String 
    **/
    public static String convertEvergreenStatusToString(Boolean isEvergreenAllowed) {
        if (!isEvergreenAllowed) { 
            return PortalConstants.EVERGREEN_NOT_ALLOWED;
        }
        return PortalConstants.EVERGREEN_ALLOWED;
    }
    
}