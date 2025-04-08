/**
 * @description       : purpose of this class is to provide common utility methods fro external apis
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-27-2025
 * @last modified by  : Rakesh Saraf
**/
global without sharing class ExternalApplicationOriginationUtil {
 
    /**
    * @description : this method is used fetch details of the current logged in USER
    * @author Krishanu Chinya | 05-15-2024 
    * @return User 
    **/
    public static User getLoggedInUser() {
        List<User> loggedInUserList = [SELECT Id,
                                        UserName,
                                        ContactId, 
                                        AccountId, 
                                        Account.ParentId, 
                                        Account.Parent.Name,
                                        Account.Parent.Coop_Type__c,
                                        Account.RecordTypeId,
                                        Account.RecordType.Name
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()];


        if(loggedInUserList.isEmpty()) {
            throw new CustomException(ExternalConstants.USER_NOT_AUTHORISED);
        }
        return loggedInUserList[0];
    }

    /**
    * @description : returns a map of all the party types
    * @author Krishanu Chinya | 05-20-2024 
    * @return Map<String, Id> 
    **/
    public static Map<String, Id> getPartyTypeMap() {
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
    
        List<clcommon__Party_Type__c> partyTypeList = [SELECT Id, 
                                                                Name
                                                        FROM clcommon__Party_Type__c];
    
        for (clcommon__Party_Type__c partyType : partyTypeList) {
            mapOfpartyType.put(partyType.Name, partyType.id);
        }
    
        return mapOfpartyType;
    }

    /**
    * @description : returns a map of all the legal entities
    * @author Krishanu Chinya | 05-20-2024 
    * @return Map<String, Id> 
    **/
    public static Map<String, Id> getLegalEntityMap() {
        Map<String, Id> mapOfLegalEntity = new Map<String, Id>();
    
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                Name
                                                        FROM clcommon__Legal_Entity__c];
    
        for (clcommon__Legal_Entity__c legalEntity : legalEntityList) {
            mapOfLegalEntity.put(legalEntity.Name, legalEntity.Id);
        }
        return mapOfLegalEntity;
    }

    /**
    * @description : returns a list containing all the possible legal entities
    * @author Krishanu Chinya | 05-21-2024 
    * @return List<String> 
    **/
    public static List<String> getPossibleLegalEntityList(){
        List<String> possibleLegalEntityList = new List<String>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                Name
                                                        FROM clcommon__Legal_Entity__c];
    
        for (clcommon__Legal_Entity__c legalEntity : legalEntityList) {
            possibleLegalEntityList.add(legalEntity.Name);
        }
        return possibleLegalEntityList;
    }

    /**
    * @description 
    * @author Krishanu Chinya | 05-15-2024 
    * @param legalEntityName 
    * @return String 
    **/
    public static String getLegalEntityByName(String legalEntityName){
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                    Name
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE Name =: legalEntityName];

        checkEmptyList(legalEntityList, ExternalConstants.SOMETHING_WENT_WRONG);
        return legalEntityList[0].Id;
    }

    /**
    * @description : returns the legal entity name by its id
    * @author Krishanu Chinya | 05-20-2024 
    * @param legalEntityId 
    * @return String 
    **/
    public static String getLegalEntityById(String legalEntityId){
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                    Name
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE Id =: legalEntityId];

        checkEmptyList(legalEntityList, ExternalConstants.SOMETHING_WENT_WRONG);
        return legalEntityList[0].Name;
    }

    /**
    * @description : returns the legal entity name by its id
    * @author Krishanu Chinya | 05-20-2024 
    * @param uniqueId 
    * @return String 
    **/
    public static String getLegalEntityByUniqueId(String uniqueId){
        List<Account> accountList = [SELECT Id, 
                                            Name,
                                            clcommon__Legal_Entity_Type__r.Name
                                    FROM Account
                                    WHERE Unique_id__c =: uniqueId];

        checkEmptyList(accountList, ExternalConstants.SOMETHING_WENT_WRONG);
        return accountList[0].clcommon__Legal_Entity_Type__r.Name;
    }

    /**
    * @description : this method is used to check if a list is empty
    * @author Krishanu Chinya | 05-15-2024 
    * @param listToCheck 
    * @param exceptionNameString 
    **/
    public static void checkEmptyList(List<Object> listToCheck, String exceptionNameString){
        if(listToCheck.isEmpty()){
            throw new CustomException(exceptionNameString);
        }
    }

    /**
    * @description : checks if an object is null
    * @author Krishanu Chinya | 05-27-2024 
    * @param objToCheck 
    * @param exceptionNameString 
    **/
    public static void checkForNullObject(Object objToCheck, String exceptionNameString){
        if(objToCheck == null){
            throw new CustomException(exceptionNameString);
        }
    }

    /**
    * @description : checks if the parameter is blank or not
    * @author Krishanu Chinya | 03-27-2024 
    * @param parameter 
    **/
    public static void checkForBlankParameter(String parameter){
        if (String.isBlank(parameter)) {
            throw new CustomException(ExternalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }

    /**
    * @description : throws an exception if the string to check is blank
    * @author Krishanu Chinya | 05-16-2024 
    * @param stringToCheck 
    * @param exceptionString
    **/
    public static void checkForEmptyString(String stringToCheck, String exceptionString){
        if(String.isBlank(stringToCheck)){
            throw new CustomException(exceptionString);
        }
    }

    /**
    * @description : checks whether two strings have the same values or not
    * @author Krishanu Chinya | 06-12-2024 
    * @param stringOne 
    * @param stringTwo 
    * @return Boolean 
    **/
    public static Boolean checkForSameValues(String stringOne, String stringTwo){
        if(stringOne.equals(stringTwo)){
            return true;
        }
        return false;
    }

    
    /**
    * @description : return the dealer Account information based on CIF
    * @author Suraj Kumar | 09-11-2024 
    * @param dealerCIF 
    * @return Account 
    **/
    public static Account getDealerInfoForExternalUser(String dealerCIF){
        List<Account> dealerAccountList = [SELECT Id, 
                                                Name, 
                                                CIF_Number__c,
                                                Coop_Type__c,
                                                Unique_Id__c 
                                        FROM Account 
                                        WHERE CIF_Number__c =: dealerCIF];

        checkEmptyList(dealerAccountList, ExternalConstants.DEALER_CIF_INVALID);
        return dealerAccountList[0];
    }


    /**
    * @description : Method to get a list of picklist values for a given object and field
    * @author Krishanu Chinya | 05-29-2024 
    * @param objectName 
    * @param fieldName 
    * @return List<String> 
    **/
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        
        // Retrieve the object's schema
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        // Retrieve the field's schema
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();
        
        // Check if the field is a picklist

            // Retrieve the picklist values
            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            
            // Iterate through picklist values and add them to the list
            for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                picklistValues.add(picklistEntry.getValue());
            }

        return picklistValues;
    }
    
    /**
    * @description 
    * @author Krishanu Chinya | 07-19-2024 
    * @param fieldToCheck 
    * @param value 
    * @return String 
    **/
    public static String assignValueIfEmpty(String fieldToCheck, String value){
        return String.isBlank(fieldToCheck) ? value : fieldToCheck;
    }

    /**
    * @description method to check if the marital status is null or not provided
    * @author Rakesh Saraf | 03-21-2025 
    * @param fieldToCheck 
    * @param value 
    * @return String 
    **/
    public static String assignMaritalStatus(String fieldToCheck, String value){
        if(String.isBlank(fieldToCheck) || fieldToCheck==ExternalConstants.NOT_PROVIDED_MARITAL_STATUS){
            return value;
        }
        return fieldToCheck;
    }

    /**
    * @description check if the decimal field is populated with value or not. If not, then assign the value sent
    * @author Rakesh Saraf | 03-20-2025 
    * @param fieldToCheck 
    * @param value 
    * @return Decimal 
    **/
    public static Decimal assignDecimalValueIfEmpty(Decimal fieldToCheck,Integer value){
        if(fieldToCheck==null){
            return Decimal.valueOf(value);
        }
        return fieldToCheck;
    }

    /**
    * @description : checks if the current application is the first application f a borrower
    * @author Krishanu Chinya | 07-19-2024 
    * @param appToUpdate 
    * @param borrowerAccountId 
    **/
    public static void checkForFirstApplication (genesis__Applications__c appToUpdate,Id borrowerAccountId){
        List<clcommon__Party__c> partyList = [SELECT clcommon__Account__c,
                                                        genesis__Application__r.genesis__Status__c 
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__r.genesis__Status__c IN (:ExternalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                                        :ExternalConstants.CLOSED_APPLICATION_STATUS,
                                                                                                        :ExternalConstants.PENDING_APPROVAL_APPLICATION_STATUS)
                                                AND clcommon__Party_Types__c =: ExternalConstants.BORROWER_PARTY
                                                AND clcommon__Account__c =: borrowerAccountId];
        if(!partyList.isEmpty()){
            appToUpdate.Is_First_Application__c = false;
        }
    }
     
    /**
    * @description this method will return the new value only when the field is blank and the kyc verified value for the account is set to false
    * @author Rakesh Saraf | 03-27-2025 
    * @param isKycVerified 
    * @param fieldToCheck 
    * @param value 
    * @return String 
    **/
    public static String assignValuesAfterKycCheck(Boolean isKycVerified,String fieldToCheck, String value){
        if(!isKycVerified && String.isBlank(fieldToCheck) ){
            return value;
        }
        return fieldToCheck;
    }
}