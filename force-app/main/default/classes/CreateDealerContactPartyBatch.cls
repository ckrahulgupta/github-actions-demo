/**
 * @description       : Batch class to create party and application sharing record
 * @author            : Simran
 * @group             : 
 * @last modified on  : 07-09-2024
 * @last modified by  : Suraj Kumar
**/

public with sharing class CreateDealerContactPartyBatch implements Database.Batchable<SObject> {
    private String dealerId;
    private String dealerCoopType;
    private String accountId;
    private String recordTypeName;
    private List<Id> objEntityId= new List<Id>();

    /**
     * @description Constructor that assign dealer Id,accountId,recordTypeName
     * @param recordDetailsMap 
     */
    public CreateDealerContactPartyBatch(Map<String, Object> recordDetailsMap){
        this.dealerId = (String)recordDetailsMap.get(ConstantValues.DEALER_ID);
        this.dealerCoopType = (String)recordDetailsMap.get(ConstantValues.SELECTED_DEALER_COOP);
        this.accountId=(String)recordDetailsMap.get(ConstantValues.DEALER_CONTACT_ID);
        this.recordTypeName=(String)recordDetailsMap.get(ConstantValues.RECORD_TYPE_NAME);
    }
    
    /**
     * @description This start method will query all the applications.
     * @param batchableContext 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        if(recordTypeName == ConstantValues.FIELD_STAFF_AGENT){
            return Database.getQueryLocator([SELECT Id
                                                FROM genesis__Applications__c 
                                                WHERE Dealer_Name__r.Coop_Type__c = :dealerCoopType]);

        }
        else{
            return Database.getQueryLocator([SELECT Id
                                                FROM genesis__Applications__c 
                                                WHERE Dealer_Name__c = :dealerId]);
        }
    }

    /**
     * @description This execute method will add  party to all the applications of that dealer
     * @param batchableContext 
     * @param dealerApplications 
     */
    public void execute(Database.BatchableContext batchableContext, List<genesis__Applications__c> dealerApplications){
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            List<clcommon__Party__c> objPartyList = new List<clcommon__Party__c>();
            List<genesis__Applications__Share> appSharingRecList = new List<genesis__Applications__Share>();
            List<clcommon__Document_Category__c> documentCategoryList = new List<clcommon__Document_Category__c>();
            List<clcommon__Document_Category__Share> documentSharingRecordList = new List<clcommon__Document_Category__Share>();
            List<User> dealerContactUserList = [SELECT Id,
                                                        ContactId 
                                                    FROM User 
                                                    WHERE AccountId =: accountId
                                                    LIMIT 1];
            Id partyTypeId = CFAOriginationHelperClass.getPartyTypeId(recordTypeName);

                
            // processing for Party
            for (genesis__Applications__c dealerApplication : dealerApplications) {
                clcommon__Party__c newParty = new clcommon__Party__c();
                newParty.genesis__Application__c = dealerApplication.Id;
                newParty.clcommon__Account__c = accountId;
                newParty.clcommon__Contact__c = dealerContactUserList[ConstantValues.ZERO_VALUE].ContactId;
                newParty.clcommon__Type__c = partyTypeId;
                newParty.clcommon__Party_Types__c = recordTypeName;
                objPartyList.add(newParty);

                genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();
                applicationSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                applicationSharingRecord.ParentId = dealerApplication.Id;
                applicationSharingRecord.UserOrGroupId = dealerContactUserList[ConstantValues.ZERO_VALUE].Id;
                appSharingRecList.add(applicationSharingRecord);
            }
            //fetching all doc sharing records of the selected applications
            documentCategoryList = [SELECT Id
                                        FROM clcommon__Document_Category__c
                                        WHERE genesis__Application__c IN :dealerApplications];

            //creating doc sharing rec for each doc category
            for (clcommon__Document_Category__c documentCategory : documentCategoryList) {
                clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
                documentSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                documentSharingRecord.ParentId = documentCategory.Id;
                documentSharingRecord.UserOrGroupId = dealerContactUserList[ConstantValues.ZERO_VALUE].Id;
                documentSharingRecordList.add(documentSharingRecord);
            } 
            Database.insert(appSharingRecList, false);
            Database.insert(documentSharingRecordList, false);
            Database.insert(objPartyList, true);

        }
        catch (Exception objException){
            Database.rollback(dbSavePoint);
            LoggingUtility.saveExceptionLogging(objException, CreateDealerContactPartyBatch.class.getName());
        }
    }

    /**
     * @description 
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext){}

    /**
     * @description This method will create party for specific dealer by calling the batch
     * @param accountId 
     */
    //Note: Label is hardcoded here because of the salesforce limitation

    @InvocableMethod(label = 'Create Dealer Contact Party')
    public static void createPartyForSpecificDealer(List<Id> accountId){
        List<Account> dealerContact = [SELECT Id,
                                               RecordType.Name,
                                                ParentId,
                                                Parent.Coop_type__c
                                            FROM Account
                                            WHERE Id = :accountId[ConstantValues.ZERO_VALUE]];
        Map<String,Object> recordDetailsMap = new Map<String,Object>();
        recordDetailsMap.put(ConstantValues.DEALER_CONTACT_ID,dealerContact[ConstantValues.ZERO_VALUE].Id);
        recordDetailsMap.put(ConstantValues.RECORD_TYPE_NAME,dealerContact[ConstantValues.ZERO_VALUE].RecordType.Name);
        recordDetailsMap.put(ConstantValues.DEALER_ID,dealerContact[ConstantValues.ZERO_VALUE].ParentId);
        recordDetailsMap.put(ConstantValues.SELECTED_DEALER_COOP,dealerContact[ConstantValues.ZERO_VALUE].Parent.Coop_Type__c);
        
        CreateDealerContactPartyBatch createDealerContactParty = new CreateDealerContactPartyBatch(recordDetailsMap);
        Database.executeBatch(createDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));     
    }
}