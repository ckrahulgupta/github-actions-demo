/**
 * @description       : This is the controller class which is called by LWC
 * @author            : Simran
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : Krishanu Chinya
**/
public with sharing class UpdateDealerRelationAPI {
    private static final String IS_PERMISSIONED_USER_ADDED = 'isPermissionedUserAdded';
    private static final String IS_PERMISSIONED_USER_REMOVED = 'isPermissionedUserRemoved';
    private static final String ACCOUNT_OBJ = 'accountObj';
    private static final String RECORD_TYPE_NAME = 'recordTypeName';
    private static Map<String,Object> recordDetailsMap = new Map<String,Object>();
    private static final List<String> PERMISSIONED_USER = ConstantValues.PERMISSIONED_USER;

    /**
    * @description This method is used to get the dealer account details
    * @author Simran | 02-12-2024 
    * @return List<Account> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Account> getDealerAccount(){
        try {
            List<Account> accountList=[SELECT Id,
                                            Name 
                                        FROM Account 
                                        WHERE RecordType.Name=:ConstantValues.DEALER 
                                        WITH SECURITY_ENFORCED
                                        Order by Name ASC];
            return accountList;
        } catch (Exception e) {
            throw new AuraHandledException(ConstantValues.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description This method is used to get the entity role
    * @author Simran | 02-14-2024 
    * @param recordId 
    * @return List<RecordType> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getEntityRole(String recordId){
        try {
            Set<String> recordTypeNames = new Set<String>{
                                            ConstantValues.CERTIFIED_LENDER,
                                            ConstantValues.CERTIFIED_LENDER_PLUS,
                                            ConstantValues.SALES_AGENT,
                                            ConstantValues.SALES_AGENT_PLUS,
                                            ConstantValues.SALES_AGENT_ADMIN,
                                            ConstantValues.INQUIRY,
                                            ConstantValues.INQUIRY_PLUS,
                                            ConstantValues.PAYMENT_ADMINISTRATOR,
                                            ConstantValues.AUTHORIZED_PERSON,
                                            ConstantValues.AGRIBUSINESS,
                                            ConstantValues.GENERAL_MANAGER,
                                            ConstantValues.PRIMARY_CONTACT,
                                            ConstantValues.FIELD_STAFF_AGENT,
                                            ConstantValues.OTHER};
                                        
            List<RecordType> objRecordType = [SELECT Id,
                                                    Name 
                                                FROM RecordType 
                                                WHERE Name In :recordTypeNames
                                                AND SobjectType=:ConstantValues.ACCOUNT
                                                WITH SECURITY_ENFORCED];
            return objRecordType;
        } catch (Exception e) {
            throw new AuraHandledException(ConstantValues.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description This method is used to get the account details
    * @author Simran | 02-12-2024 
    * @param recordId 
    * @return Account 
    **/
    @AuraEnabled(cacheable=true)
    public static Account getAccountName(String recordId) {
        try{
            return fetchAccountRecord(recordId);
        }
        catch (Exception e) {
            throw new AuraHandledException(ConstantValues.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description This method is used to update the dealer contact details
    * @author Simran | 02-02-2024 
    * @param accountId 
    * @param dealerId 
    * @param entityRoleList 
    **/
    @AuraEnabled
    public static void updateDealerRelation(String accountId,String dealerId, List<String> entityRoleList) {
        try{
            List<Id> dealerListId = new List<Id>();
            Boolean isPermissionedUserAdded = false;
            Boolean isPermissionedUserRemoved = false;
            List<Id> saAdminRelationship = new List<Id>();
            List<String> newRelation = new List<String>();
            List<String> removeRelation = new List<String>();
            Account objAccount = fetchAccountRecord(accountId);
            String previousDealerId = objAccount.ParentId;
            String recordTypeName = ConstantValues.EMPTY_STRING;
            List<String> newRelRecordTypeName = new List<String>();
            List<String> existingRelationshipsName = new List<String>();
            List<RecordType> existingRelRecordTypes = fetchExistingRelationships(accountId);
            String selectedDealerCoop = CFAOriginationHelperClass.getCoopTypeByAccountId(dealerId);
            List<RecordType> newRelationshipRecordType = [SELECT Id,
                                                                Name 
                                                            FROM RecordType 
                                                            WHERE Id IN :entityRoleList
                                                            AND sObjectType =: ConstantValues.ACCOUNT
                                                            WITH SECURITY_ENFORCED];
            
            newRelRecordTypeName = CFAOriginationHelperClass.getRecordTypeNamesList(newRelationshipRecordType);
            existingRelationshipsName = CFAOriginationHelperClass.getRecordTypeNamesList(existingRelRecordTypes);
            
            if(previousDealerId != dealerId){
                removeRelation = (List<String>)JSON.deserialize(JSON.serialize(CFAOriginationHelperClass.valuesNotInList(existingRelationshipsName, new List<String>())), List<String>.class);
                newRelation =(List<String>)JSON.deserialize(JSON.serialize(CFAOriginationHelperClass.valuesNotInList(newRelRecordTypeName, new List<String>())), List<String>.class);
            } else {
                removeRelation = (List<String>)JSON.deserialize(JSON.serialize(CFAOriginationHelperClass.valuesNotInList(existingRelationshipsName, newRelRecordTypeName)), List<String>.class);
                newRelation = (List<String>)JSON.deserialize(JSON.serialize(CFAOriginationHelperClass.valuesNotInList(newRelRecordTypeName, existingRelationshipsName)), List<String>.class);
            }
            isPermissionedUserRemoved = CFAOriginationHelperClass.hasAnySameValueInList(removeRelation, PERMISSIONED_USER);
            isPermissionedUserAdded = CFAOriginationHelperClass.hasAnySameValueInList(newRelation, PERMISSIONED_USER);

            if(removeRelation.isEmpty() & newRelation.isEmpty()){
                return;
            }

            recordDetailsMap.put(ConstantValues.PREVIOUS_RECORD_TYPE_NAME, removeRelation);
            recordDetailsMap.put(ConstantValues.PREVIOUS_DEALER_ID,previousDealerId);
            recordDetailsMap.put(ConstantValues.DEALER_CONTACT_ID, accountId);
            recordDetailsMap.put(ConstantValues.DEALER_ID,dealerId);
            recordDetailsMap.put(ConstantValues.RECORD_TYPE_NAME, newRelation);
            recordDetailsMap.put(ConstantValues.SELECTED_DEALER_COOP, selectedDealerCoop);

            // Setting the parent id and recordtype in account.
            recordTypeName = CFAOriginationHelperClass.updateParentIdAndRecordType(newRelationshipRecordType, 
                                                                                            objAccount, 
                                                                                            dealerId);
            // Updating the user profile according the selected role if any user already exists.
            CFAOriginationHelperClass.updateUserProfile(selectedDealerCoop, accountId, recordTypeName);

            // Fetching sales agent admin for sa/sa+.
            saAdminRelationship = PortalApplicationOriginationHelper.fetchSAAdmin(accountId);

            // To delete sa admin parties for sa/sa+ role change putting sa admin details in recordDetailsMap
            recordDetailsMap.put(ConstantValues.SALES_AGENT_ADMIN_RELATIONSHIP, saAdminRelationship);

            // Deleting the existing relationship with previous dealer previous roles.                                                                            
            dealerListId = CFAOriginationHelperClass.deleteExistingRelationship(removeRelation, previousDealerId, accountId);
            
            // Creating a dummy relationship with previous dealer previous roles.
            CFAOriginationHelperClass.createDummyRelationship(dealerListId, new Map<String, String>{ConstantValues.ACCOUNT_ID => accountId, ConstantValues.DEALER_ID => previousDealerId}, removeRelation);
            
            // Creating a new relationships with new dealer new roles.
            CFAOriginationHelperClass.createRelationshipRecord(recordDetailsMap);

            // Creating account sharing records for CL/CL+/PA/FSA.
            CFAOriginationHelperClass.createAccountshareRecord(recordDetailsMap);

            updateDealerContactRole(new Map<String, Object>{ IS_PERMISSIONED_USER_ADDED => isPermissionedUserAdded,
                                                             IS_PERMISSIONED_USER_REMOVED => isPermissionedUserRemoved,
                                                            ACCOUNT_OBJ => objAccount,
                                                            ConstantValues.DEALER_ID => dealerId,
                                                            RECORD_TYPE_NAME => recordTypeName});
        } catch (CustomException customExceptionObj) {
            CFAOriginationHelperClass.throwAuraHandledException(customExceptionObj.getMessage());
        }
         catch (Exception e) {
            CFAOriginationHelperClass.throwAuraHandledException(ConstantValues.SOMETHING_WENT_WRONG);
        }
    }
    /**
    * @description The purpose of this method is to perform according to the parameters.
    * @author Ayan Bhowmik | 04-08-2024 
    * @param paramMap 
    **/
    private static void updateDealerContactRole(Map<String, Object> paramMap) {
        Boolean isPermissionedUserAdded = (Boolean)paramMap.get(IS_PERMISSIONED_USER_ADDED);
        Boolean isPermissionedUserRemoved = (Boolean)paramMap.get(IS_PERMISSIONED_USER_REMOVED);
        Account accountObj = (Account)paramMap.get(ACCOUNT_OBJ);
        String dealerId = String.valueOf(paramMap.get(ConstantValues.DEALER_ID));
        List<User> existingUserList = [SELECT Id, 
                                            ProfileId, 
                                            Coop_Type__c,
                                            IsActive
                                        FROM User 
                                        WHERE AccountId =: accountObj.Id 
                                        WITH SECURITY_ENFORCED LIMIT 1];
        // Permission user added but no permissioned user removed and no any user exists for individual.
        // Create a user and call create party batch.
        if(isPermissionedUserAdded & !isPermissionedUserRemoved & existingUserList.isEmpty()){
            List<Contact> contactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: accountObj.Id
                                            WITH SECURITY_ENFORCED];
            CFAOriginationHelperClass.checkEmptyList(contactList, ConstantValues.SOMETHING_WENT_WRONG);
            if(contactList[ConstantValues.ZERO_VALUE].Email == null || String.isBlank(contactList[ConstantValues.ZERO_VALUE].Email)){
                throw new CustomException(ConstantValues.EMAIL_NOT_FOUND);
            }
            recordDetailsMap.put(ConstantValues.DEALER_CONTACT_LIST, contactList);
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
        }
        // Permissioned user added but no permissioned user removed and a user exists for individual.
        // Call create party batch.
        else if(isPermissionedUserAdded & !isPermissionedUserRemoved){
            CFAOriginationHelperClass.createPartyBatch(recordDetailsMap);
        } // Dealer Changed or permissioned user role changed.
        else if (accountObj.ParentId != dealerId | isPermissionedUserRemoved) {
            recordDetailsMap.put(ConstantValues.UPDATE_RECORD, true);
            deletePartyBatch(recordDetailsMap);
        }
    }

    /**
    * @description This method is used to call the DeleteDealerContactPartyBatch
    * @author Simran | 02-14-2024 
    * @param recordDetailsMap 
    **/
    public static void deletePartyBatch(Map<String, Object> recordDetailsMap){
            DeleteDealerContactPartyBatch deleteDealerContactParty = new DeleteDealerContactPartyBatch(recordDetailsMap);
            Database.executeBatch(deleteDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));  
    }
   
    /**
    * @description This method is used to delete the dealer contact details
    * @author Simran | 02-07-2024 
    * @param accountId 
    **/
   @AuraEnabled
    public static void deleteDealerRelation(String accountId){
        try{
            List<Id> saAdminRelationship = new List<Id>();
            List<RecordType> existingRelRecordTypes = fetchExistingRelationships(accountId);
            List<Id> dealerListId = new List<Id>();
            List<String> existingRelationshipsName = new List<String>();
            Account objAccount = fetchAccountRecord(accountId);
            
            existingRelationshipsName = CFAOriginationHelperClass.getRecordTypeNamesList(existingRelRecordTypes);

            recordDetailsMap.put(ConstantValues.DEALER_CONTACT_ID,objAccount.Id);
            recordDetailsMap.put(ConstantValues.PREVIOUS_RECORD_TYPE_NAME,existingRelationshipsName);
            recordDetailsMap.put(ConstantValues.PREVIOUS_DEALER_ID,objAccount.ParentId);

             // Fetching sales agent admin for sa/sa+.
             saAdminRelationship = PortalApplicationOriginationHelper.fetchSAAdmin(accountId);

             // To delete sa admin parties for sa/sa+ role change putting sa admin details in recordDetailsMap
             recordDetailsMap.put(ConstantValues.SALES_AGENT_ADMIN_RELATIONSHIP, saAdminRelationship);
 
             // Deleting the existing relationship with previous dealer previous roles.                                                                            
             dealerListId = CFAOriginationHelperClass.deleteExistingRelationship(existingRelationshipsName, objAccount.ParentId, accountId);
             
             // Creating a dummy relationship with previous dealer previous roles.
             CFAOriginationHelperClass.createDummyRelationship(dealerListId, new Map<String, String>{ConstantValues.ACCOUNT_ID => accountId, ConstantValues.DEALER_ID => objAccount.ParentId}, existingRelationshipsName);

             // Inactivating the user if individual has a user.
             CFAOriginationHelperClass.updateUserProfile(ConstantValues.EMPTY_STRING, accountId, ConstantValues.EMPTY_STRING);

            DeleteDealerContactPartyBatch deleteDealerContactParty = new DeleteDealerContactPartyBatch(recordDetailsMap);
            Database.executeBatch(deleteDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));
        }
        catch (Exception e) {
            throw new AuraHandledException(ConstantValues.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description 
    * @author Simran | 02-19-2024 
    * @param recordId 
    * @return Account 
    **/
    public static Account fetchAccountRecord(Id recordId){
        return [SELECT Id,
                    Name,
                    ParentId,
                    Parent.Name,
                    Parent.Coop_Type__c,
                    RecordTypeId,
                    RecordType.Name 
                FROM Account 
                WHERE Id=:recordId 
                WITH SECURITY_ENFORCED];
    }
    
    /**
    * @description 
    * @author Ayan Bhowmik | 03-28-2024 
    * @param recordId 
    * @return List<RecordType> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<RecordType> fetchExistingRelationships(Id recordId){
        try{
            List<String> existingRelName = new List<String>();
            List<clcommon__Relationship__c> existingRelationship = [SELECT Id, 
                                                                            clcommon__Relationship__r.Name 
                                                                        FROM clcommon__Relationship__c 
                                                                        WHERE clcommon__Related_Entity__c =: recordId
                                                                        WITH SECURITY_ENFORCED]; 
            for(clcommon__Relationship__c eachRel :existingRelationship){
                existingRelName.add(eachRel.clcommon__Relationship__r.Name);
            }
            List<RecordType> existingRecordTypes = [SELECT Id,
                                                        Name 
                                                    FROM RecordType 
                                                    WHERE Name In :existingRelName
                                                    AND SobjectType=:ConstantValues.ACCOUNT
                                                    WITH SECURITY_ENFORCED];
            return existingRecordTypes;
        } catch(Exception exceptionObj) {
            throw new AuraHandledException(ConstantValues.SOMETHING_WENT_WRONG);
        }
    }
}