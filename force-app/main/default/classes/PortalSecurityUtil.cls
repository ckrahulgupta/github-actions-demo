/**
 * @description       : Helper Class for Portal APIs. Contains Methods to Validate all the necessary Security Params
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 19-12-2024
 * @last modified by  : Soumik Pattanayak
**/
public without sharing class PortalSecurityUtil {
    private static final String GUEST_USER_TYPE = 'GUEST';
    private static final String STANDARD_USER_TYPE = 'STANDARD';
 
    
    /**
    * @description Validates if the user should be having access to view/update the Application or not
    * @author iAyush | 17-12-2021 
    * @param applicationId 
    * @return Boolean 
    **/
    public static Boolean validateUserApplication(String applicationId) {
        Boolean isApplicationIdValid = PortalConstants.FALSE_VALUE;
        if(String.isNotBlank(applicationId)) {
                try {
                    List<User> loggedInUser = [SELECT Id,
                                                    ContactId
                                                FROM USER
                                                    WHERE Id = :UserInfo.getUserId()];
                     
                    if(loggedInUser.size() > 0) {
                        if(loggedInUser[0].ContactId != null) {
                            List<clcommon__Party__c> applicationParties = [SELECT Id
                                                                                FROM clcommon__Party__c
                                                                                WHERE genesis__Application__c = :applicationId
                                                                                    AND clcommon__Contact__c = :loggedInUser[0].ContactId];
                            if(applicationParties.size() > 0) {
                                isApplicationIdValid = PortalConstants.TRUE_VALUE;
                            }
                        } else {
                            if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                                isApplicationIdValid = PortalConstants.TRUE_VALUE;
                            }
                        }
                    }
                } catch(Exception e) {
                    isApplicationIdValid = PortalConstants.FALSE_VALUE;
                }
        }
        return isApplicationIdValid;                                             
    }


    /**
    * @description Validates if the user should be having access to view/update the Application or not
    * @author Rahul Gupta | 16-08-2023
    * @param applicationIds 
    * @return Boolean 
    **/
    public static Boolean validateUserApplication(List<Id> applicationIds) {
        Boolean isApplicationIdValid = PortalConstants.FALSE_VALUE;
        if(applicationIds != null && applicationIds.size() > 0) {
            try {
                List<User> loggedInUser = [
                            SELECT Id,
                                    ContactId
                            FROM USER
                            WHERE Id = :UserInfo.getUserId()
                        ];
                    
                if (loggedInUser.size() > 0) {
                    if (loggedInUser[0].ContactId != null) {
                        List<clcommon__Party__c> applicationParties = [
                                        SELECT Id,
                                               genesis__Application__c
                                        FROM clcommon__Party__c
                                        WHERE genesis__Application__c IN :applicationIds
                                        AND clcommon__Contact__c = :loggedInUser[0].ContactId
                                    ];
                        
                        for (clcommon__Party__c applicationParty : applicationParties) {

                            isApplicationIdValid = PortalConstants.FALSE_VALUE;

                            for (Id applicationId : applicationIds) {
                                if (applicationParty.genesis__Application__c == applicationId) {
                                    isApplicationIdValid = PortalConstants.TRUE_VALUE;
                                    break;
                                }
                            }

                            if (!isApplicationIdValid) {
                                return isApplicationIdValid;
                            }
                        }

                    } else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isApplicationIdValid = PortalConstants.TRUE_VALUE;
                        }
                    }
                }
            } catch(Exception e) {
                isApplicationIdValid = PortalConstants.FALSE_VALUE;
            }
        }
        return isApplicationIdValid;                                             
    }

    /**
    * @description Valdiates if the Account belongs to the given application or not
    * @author iAyush | 17-12-2021 
    * @param applicationId 
    * @param accountId 
    * @return Boolean 
    **/
    public static Boolean validateUserApplicationByAccount(String applicationId, String accountId) {
        Boolean isAccountIdValid = PortalConstants.FALSE_VALUE;
         if(String.isNotBlank(accountId)) {
            if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                try {
                        List<clcommon__Party__c> applicationParties = [SELECT Id
                                                                            FROM clcommon__Party__c
                                                                            WHERE genesis__Application__c = :applicationId
                                                                                AND clcommon__Account__c = :accountId];
                        if(applicationParties.size() > 0) {
                            isAccountIdValid = PortalConstants.TRUE_VALUE;
                        }
                     else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isAccountIdValid = PortalConstants.TRUE_VALUE;
                        }
                    }
                } catch(Exception e) {
                    isAccountIdValid = PortalConstants.FALSE_VALUE;
                }
            }    
        }
        return isAccountIdValid;                                             
    }

    /**
    * @description Valdiates if the Contact belongs to the given application's Borrower or not
    * @author iAyush | 17-12-2021 
    * @param applicationId 
    * @param contactId 
    * @return Boolean 
    **/
    public static Boolean validateUserBorrowerContactByApplication(String applicationId, String contactId) {
        Boolean isContactIdValid = PortalConstants.FALSE_VALUE;
         if(String.isNotBlank(contactId)){
            if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                try {
                        List<genesis__Applications__c> application = [SELECT Id
                                                                            FROM genesis__Applications__c
                                                                            WHERE id = :applicationId
                                                                            AND genesis__Contact__c = :contactId];
                        if(application.size() > 0) {
                            isContactIdValid = PortalConstants.TRUE_VALUE;
                        }
                     else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isContactIdValid = PortalConstants.TRUE_VALUE;
                        }
                    }
                } catch(Exception e) {
                    isContactIdValid = PortalConstants.FALSE_VALUE;
                }
            }    
        }
        return isContactIdValid;                                             
    }

    /**
    * @description Return the User Id for the Site Admin to set as default owner for any record
    * @author iAyush | 17-12-2021 
    * @return String 
    **/
    public static String getSiteAdmin(){
        List<site> objSite = [SELECT Id, AdminId, Admin.Email
                                 FROM site
                                 WHERE AdminId != ''];

        return objSite[0].AdminId;
    }

    /**
    * @description - Checks if the given businessInformation belongs to the given account or not
    * @author iAyush | 19-12-2021 
    * @param businessInfoId 
    * @param accountId 
    * @return Boolean 
    **/
    public static Boolean validateUserBusinessInformation(String businessInfoId, String accountId){
        Boolean isBusinessValid = PortalConstants.FALSE_VALUE;
         if(String.isNotBlank(accountId)) {
            if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                try {
                        List<Account> accountVSBusinessInfo = [SELECT Id
                                                                    FROM Account 
                                                                    WHERE genesis__Business_Information__c = :businessInfoId 
                                                                    AND Id = :accountId];
                        if(accountVSBusinessInfo.size() > 0) {
                            isBusinessValid = PortalConstants.TRUE_VALUE;
                        }
                     else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isBusinessValid = PortalConstants.TRUE_VALUE;
                        }
                    }
                } catch(Exception e) {
                    isBusinessValid = PortalConstants.FALSE_VALUE;
                }
            }    
        }
        return isBusinessValid;
    }

    /**
    * @description - Purpose of this method is to validate whether a account is business for an application 
    * @author iAyush | 19-12-2021 
    * @param applicationId 
    * @param accountId 
    * @return Boolean 
    **/
    public static Boolean validateUserApplicationByBusinessAccount(String applicationId, String accountId){
        Boolean isAccountIdValid = PortalConstants.FALSE_VALUE;
        if(String.isNotBlank(accountId)) {
           if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
               try {
                       List<clcommon__Party__c> applicationParties = [SELECT Id
                                                                           FROM clcommon__Party__c
                                                                           WHERE genesis__Application__c = :applicationId
                                                                               AND clcommon__Account__c = :accountId
                                                                               AND clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME];
                       if(applicationParties.size() > 0) {
                           isAccountIdValid = PortalConstants.TRUE_VALUE;
                       }
                    else {
                       if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                           isAccountIdValid = PortalConstants.TRUE_VALUE;
                       }
                   }
               } catch(Exception e) {
                   isAccountIdValid = PortalConstants.FALSE_VALUE;
               }
           }    
       }
       return isAccountIdValid; 
    }

    /**
    * @description - Purpose of this method is to check whether is contact is added as a Principal Party 
    * @author iAyush | 19-12-2021 
    * @param applicationId 
    * @param contactId 
    * @return Boolean 
    **/
    public static Boolean validatePrincipalContact(String applicationId, String contactId){
        Boolean isContactValid = PortalConstants.FALSE_VALUE;
        if(String.isNotBlank(contactId)) {
            if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                try {
                        List<clcommon__Party__c> applicationParties = [SELECT Id
                                                                            FROM clcommon__Party__c
                                                                            WHERE genesis__Application__c = :applicationId
                                                                                AND clcommon__Contact__c = :contactId
                                                                                AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME];
                        if(applicationParties.size() > 0) {
                            isContactValid = PortalConstants.TRUE_VALUE;
                        }
                     else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isContactValid = PortalConstants.TRUE_VALUE;
                        }
                    }
                } catch(Exception e) {
                    isContactValid = PortalConstants.FALSE_VALUE;
                }
            }    
        }
        return isContactValid; 
    }
 
    /**
    * @description : Purpose of this method is to verify whether the party is a principal in the given application
    * @author Krishanu Chinya | 03-07-2024 
    * @param applicationId 
    * @param partyId 
    * @return Boolean 
    **/
    public static Boolean validatePrincipalParty(String applicationId, String partyId){
        Boolean isParty = PortalConstants.FALSE_VALUE;
        if(String.isNotBlank(partyId)) {
            if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                try {
                        List<clcommon__Party__c> applicationParties = [SELECT Id
                                                                            FROM clcommon__Party__c
                                                                            WHERE genesis__Application__c = :applicationId
                                                                                AND Id = :partyId
                                                                                AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME];
                        if(applicationParties.size() > 0) {
                            isParty = PortalConstants.TRUE_VALUE;
                        }
                     else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isParty = PortalConstants.TRUE_VALUE;
                        }
                    }
                } catch(Exception e) {
                    isParty = PortalConstants.FALSE_VALUE;
                }
            }    
        }
        return isParty; 
    }

    /**
    * @description : Purpose of this method is to validation whether the collateral belongs to this application
    * @author iAyush | 26-01-2022 
    * @param applicationId 
    * @param collateralId 
    * @return Boolean 
    **/
    public static Boolean validateCollteralByApplication(String applicationId, String collateralId){
        Boolean isCollateral = PortalConstants.FALSE_VALUE;
        if(String.isNotBlank(collateralId)) {
            if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                try {
                        List<clcommon__collateral__c> applicationCollateral = [SELECT Id
                                                                            FROM clcommon__collateral__c
                                                                            WHERE genesis__Application__c = :applicationId
                                                                                AND Id = :collateralId];
                        if(applicationCollateral.size() > 0) {
                            isCollateral = PortalConstants.TRUE_VALUE;
                        }
                     else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isCollateral = PortalConstants.TRUE_VALUE;
                        }
                    }
                } catch(Exception e) {
                    isCollateral = PortalConstants.FALSE_VALUE;
                }
            }    
        }
        return isCollateral; 
    }

    /**
    * @description - Purpose of this method is to validation whether the collateral belongs to this application
    * @author Suraj Kumar | 12-21-2023 
    * @param validCollateralId 
    * @param collateralId 
    * @return Boolean 
    **/
    public static Boolean validateCollteralsObj(List<String> validCollateralId, String collateralId){
        Boolean isCollateral = PortalConstants.FALSE_VALUE;
        if(String.isNotBlank(collateralId)) {
            if(GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                return PortalConstants.FALSE_VALUE;
            }
            try {
                    if(validCollateralId.contains(collateralId)) {
                        isCollateral = PortalConstants.TRUE_VALUE;
                    }
                    else {
                        if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                            isCollateral = PortalConstants.TRUE_VALUE;
                    }
                }
            } catch(Exception e) {
                isCollateral = PortalConstants.FALSE_VALUE;
            }    
        }
        return isCollateral; 
    }

    /**
    * @description Purpose of this class is to validate whether the user can access the My Program
    * @author Subham Nandi | 24-05-2022 
    * @param dealerId 
    * @param myProgramId 
    * @return Boolean 
    **/
    public static Boolean validateRateCardDetailByDealer(String dealerId, String myProgramId){
        Boolean isRateCard = PortalConstants.FALSE_VALUE;
        if(String.isNotBlank(myProgramId)){
            try {
                List<genesis__Rate_Card_Setup_Header__c> objMyProgram = [SELECT Id,
                                                                                Account__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c
                                                                        WHERE Id = :myProgramId];
                if(objMyProgram.size() > 0 &&
                    String.valueOf(objMyProgram[0].Account__c) == dealerId){
                        isRateCard = PortalConstants.TRUE_VALUE;
                }
            } catch (Exception e) {
                isRateCard = PortalConstants.FALSE_VALUE;
            }
        }
        return isRateCard;
    }

   
    /**
    * @description - validates whether logged in user has a relation with the dealer
    * @author Rahul Gupta | 09-05-2023  
    * @param dealerId 
    * @return Boolean 
    **/
    public static Boolean validateDealerByAccount(String dealerId) {
        // validate the dealerId & the logged in user, whether they have the correct authorization
        List<clcommon__Relationship__c> relations = [
                    SELECT Id,
                           clcommon__Entity__c,
                           clcommon__Entity__r.Name,
                           clcommon__Related_Entity__c,
                           clcommon__Related_Entity__r.Name,
                           clcommon__Relationship__c,
                           clcommon__Relationship__r.Name
                    FROM clcommon__Relationship__c
                    WHERE clcommon__Related_Entity__c IN (
                                SELECT AccountId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                    )
                ];

        Boolean isValid = PortalConstants.FALSE_VALUE;

        for (clcommon__Relationship__c relation : relations) {
            if (relation.clcommon__Entity__c == dealerId) {
                isValid = PortalConstants.TRUE_VALUE;
            }
        }

        return isValid;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 22-11-2024 
    * @param dealerId 
    * @return Boolean 
    **/
    public static Boolean validateDealerByGrowerAccount(String dealerId) {
        // validate the dealerId & the logged in user, whether they have the correct authorization
        List<Dealer_Applicant_Relationship__c> relationList = [
                    SELECT Id, 
                            Dealer__c, 
                            Applicant__c
                    FROM Dealer_Applicant_Relationship__c
                    WHERE Applicant__c IN (
                                SELECT AccountId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                    )
                ];

        Boolean isValid = PortalConstants.FALSE_VALUE;

        for (Dealer_Applicant_Relationship__c relation : relationList) {
            if (relation.Dealer__c == dealerId) {
                isValid = PortalConstants.TRUE_VALUE;
                return isValid;
            }
        }

        return isValid;
    }

    //__________________________________________________________________________________________________________________________________


    /**
    * @description : validates business info of all coaplicants
    * @author Krishanu Chinya | 03-07-2024 
    * @param accountVSBusinessInfoList 
    * @param businessInfoVSAccIdMap 
    * @return Boolean 
    **/
    public static Boolean validateCoApplicantBusinessInfo(List<Account> accountVSBusinessInfoList, Map<Id, Id> businessInfoVSAccIdMap){
        Boolean isBusinessValid = PortalConstants.FALSE_VALUE;

        if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
            try {
                for(Account acc: accountVSBusinessInfoList){
                    if(businessInfoVSAccIdMap.containsKey(acc.genesis__Business_Information__r.Id)){
                        if(businessInfoVSAccIdMap.get(acc.genesis__Business_Information__r.Id) == acc.Id) {
                            isBusinessValid = PortalConstants.TRUE_VALUE;
                        }
                    } else {
                        isBusinessValid = PortalConstants.FALSE_VALUE;
                    }
                    if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                        isBusinessValid = PortalConstants.TRUE_VALUE;
                    }
                    
                }
            } catch(Exception e) {
                isBusinessValid = PortalConstants.FALSE_VALUE;
            }
        }    

        return isBusinessValid;
    }

    /**
    * @description : validates coapplicant contact in the application
    * @author Krishanu Chinya | 03-07-2024 
    * @param contactId 
    * @param contactIdvsPartyMap 
    * @return Boolean 
    **/
    public static Boolean validateCoApplicantContact(String contactId, Map<Id,clcommon__Party__c> contactIdvsPartyMap){
        Boolean isContactValid = PortalConstants.FALSE_VALUE;
        if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
            try {
                if(contactIdvsPartyMap.get(contactId) != null) {
                    isContactValid = PortalConstants.TRUE_VALUE;
                }
                else {
                    if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                        isContactValid = PortalConstants.TRUE_VALUE;
                    }
                }
            } catch(Exception e) {
                isContactValid = PortalConstants.FALSE_VALUE;
            }
        }    
        return isContactValid; 
    }

    /**
    * @description : validates coapplicant party in the application
    * @author Krishanu Chinya | 03-07-2024 
    * @param partyId 
    * @param partyIdvsPartyMap 
    * @return Boolean 
    **/
    public static Boolean validateCoApplicantParty (String partyId, Map<Id,clcommon__Party__c> partyIdvsPartyMap){
        Boolean isPartyValid = PortalConstants.FALSE_VALUE;
            if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                try { 
                    if(partyIdvsPartyMap.get(partyId) != null) {
                        isPartyValid = PortalConstants.TRUE_VALUE;
                    }
                    else {
                    if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                        isPartyValid = PortalConstants.TRUE_VALUE;
                    }
                }
                } catch(Exception e) {
                    isPartyValid = PortalConstants.FALSE_VALUE;
                }
            }    
        return isPartyValid;
    }

    /**
    * @description : validates coapplicant account in the application
    * @author Krishanu Chinya | 03-07-2024 
    * @param accountId 
    * @param accountIdvsPartyMap 
    * @return Boolean 
    **/
    public static Boolean validateCoApplicantAccount (String accountId, Map<Id,clcommon__Party__c> accountIdvsPartyMap){
        Boolean isAccountValid = PortalConstants.FALSE_VALUE;
        if(!GUEST_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
            try { 
                if(accountIdvsPartyMap.get(accountId) != null) {
                    isAccountValid = PortalConstants.TRUE_VALUE;
                }
                else {
                    if(STANDARD_USER_TYPE.equalsIgnoreCase(UserInfo.getUserType())) {
                        isAccountValid = PortalConstants.TRUE_VALUE;
                    }
                }
            } catch(Exception e) {
                isAccountValid = PortalConstants.FALSE_VALUE;
            }   
        }
        return isAccountValid;
    }

    /**
    * @description : validates whether a grower belongs to a dealer or not
    * @author Krishanu Chinya | 04-08-2024 
    * @param contactId 
    **/
    public static void validateGrowerWithDealer(String contactId){
        List<User> loggedInUserList = PortalApplicationOriginationHelper.getLoggedInUser();
        List<clcommon__Party__c> growerPartyList = [SELECT Id 
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Contact__c = :contactId 
                                                    AND genesis__Application__r.Dealer_Name__c =: loggedInUserList[0].Account.ParentId
                                                    AND clcommon__Account__r.RecordType.Name IN (
                                                        :PortalConstants.GROWER_PROFILE, 
                                                        :PortalConstants.CO_APPLICATION_RECORD_TYPE)
                                                    AND clcommon__Party_Types__c IN (
                                                        :PortalConstants.BORROWER_PARTY_NAME,
                                                        :PortalConstants.PRINCIPAL_PARTY_NAME)];
        PortalApplicationOriginationHelper.checkEmptyList(growerPartyList, PortalConstants.USER_NOT_AUTHORISED);
    }
}