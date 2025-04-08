/**
 * @description       : Batch class to create the Payment Administrator parties for all the applications
 * @author            : Ayan Bhowmik
 * @since             : 11-08-2023
 * @last modified on  : 03-07-2024
 * @last modified by  : Ayan Bhowmik
 */
public with sharing class CreatePaymentAdministratorPartyBatch implements Database.Batchable<sObject> {

    // Constants specific to this class.
    private static final String CLASS_NAME = CreatePaymentAdministratorPartyBatch.class.getName();
    private static final String PARAM_DEALER_ID = 'dealerId';
    private static final String PARAM_ACCOUNT_ID = 'accountId';
    private static final String PARAM_CONTACT_ID = 'contactId';
    private static final String PARAM_TYPE = 'type';
    private static final String EDIT = 'edit';
    String dealerId = NULL;

    /**
     * @description This is a empty constructor with no parameter
     */
    public CreatePaymentAdministratorPartyBatch(){}

    /**
     * @description This is a constructor that assign dealer Id
     * @param dealerId 
     */
    public CreatePaymentAdministratorPartyBatch(Id dealerId){
        this.dealerId = dealerId;
    }
    /**
     * @description This start method will query all the applications.
     * @param batchableContext 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        
        if(dealerId != NULL){
            return Database.getQueryLocator([SELECT Id, 
                                                        Dealer_Name__c 
                                                FROM genesis__Applications__c 
                                                WHERE Dealer_Name__c = :dealerId]);
        }else{
            return Database.getQueryLocator([SELECT Id, 
                                                        Dealer_Name__c 
                                                FROM genesis__Applications__c 
                                                WHERE Dealer_Name__c != NULL]);
        }
    
    }

    /**
     * @description This execute method will add payment administrator party to all the applications
     * @param batchableContext 
     * @param dealerApplications 
     */
    public void execute(Database.BatchableContext batchableContext, List<genesis__Applications__c> dealerApplications){
        
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            List<Id> dealerIds = new List<Id>();
            List<Id> applicationsId = new List<Id>();
            List<Id> dealerRelationAccountIds = new List<Id>();
            Map<String, Id> partyTypeMap = PortalHelper.getPartyTypeMap();
            Map<Object, Contact> paContactMap = new Map<Object, Contact>();
            List<clcommon__Party__c> newParties = new List<clcommon__Party__c>();
            List<clcommon__Relationship__c> dealerRelationships = new List<clcommon__Relationship__c>();
            Map<Object, List<clcommon__Party__c>> paPartyMap = new Map<Object, List<clcommon__Party__c>>();
            Map<Object, List<Map<String, Object>>> paRelationMap = new Map<Object, List<Map<String, Object>>>();

            for (genesis__Applications__c dealerApplication : dealerApplications) {
                applicationsId.add(dealerApplication.Id);
                dealerIds.add(dealerApplication.Dealer_Name__c);
            }

            if(dealerIds.isEmpty()){
                return;
            }

            dealerRelationships = [SELECT Id, 
                                            clcommon__Related_Entity__c, 
                                            clcommon__Entity__c,
                                            clcommon__Relationship__r.Name
                                        FROM clcommon__Relationship__c 
                                        WHERE clcommon__Entity__c IN :dealerIds
                                        AND clcommon__Relationship__r.Name = :ConstantValues.PAYMENT_ADMINISTRATOR_PARTY_NAME];

            dealerRelationAccountIds = getDealerRelationAccountId(dealerRelationships);
            paContactMap = CFAOriginationHelperClass.getDealerRelationContacts(dealerRelationAccountIds);
            paRelationMap = getPaRelationMap(dealerRelationships, paContactMap);
            paPartyMap = getPaPartyList(applicationsId);
                
            // processing for PA
            for (genesis__Applications__c dealerApplication : dealerApplications) {

                // if there are less PA party in the application than it needs to be
                if(hasCurrentPaPartyLess(paPartyMap, paRelationMap, dealerApplication)){
                    continue;
                }

                // find out the missing PA
                Set<Object> existingPas = getExistingPaParties(paPartyMap, dealerApplication);

                for (Map<String, Object> actualPa : paRelationMap.get(dealerApplication.Dealer_Name__c)) {

                    if (existingPas.contains(actualPa.get(PARAM_ACCOUNT_ID))) {
                        continue;
                    }
                    
                    // if the PA party is not already added to the application, add it
                    clcommon__Party__c newPaParty = new clcommon__Party__c();

                    newPaParty.genesis__Application__c = dealerApplication.Id;
                    newPaParty.clcommon__Account__c = (Id) actualPa.get(PARAM_ACCOUNT_ID);
                    newPaParty.clcommon__Contact__c = (Id) actualPa.get(PARAM_CONTACT_ID);
                    
                    if (((String) actualPa.get(PARAM_TYPE)).equalsIgnoreCase(ConstantValues.PAYMENT_ADMINISTRATOR_PARTY_NAME)) {
                        newPaParty.clcommon__Type__c = partyTypeMap.get(ConstantValues.PAYMENT_ADMINISTRATOR_PARTY_NAME);
                        newPaParty.clcommon__Party_Types__c = ConstantValues.PAYMENT_ADMINISTRATOR_PARTY_NAME;
                    } 
                    newParties.add(newPaParty);
                }
            } 
            Database.upsert(newParties, false);
            createSharingRecord(dealerIds);
        }catch (Exception exceptionObj){
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
    }

    /**
     * @description 
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext){}

    /**
     * @description Purpose of this method is to create sharing records
     * @param dealerIds 
     */
    private void createSharingRecord(List<Id> dealerIds){

        List<Id> accountList = new List<Id>();
        Map<Id, Id> userMap = new Map<Id, Id>();
        Map<Id, Id> dealerToPAMap = new Map<Id, Id>();
        List<AccountShare> newAccShareList = new List<AccountShare>();
        Map<Object, List<clcommon__Relationship__c>> relationMap = new Map<Object, List<clcommon__Relationship__c>>();

        List<clcommon__Relationship__c> dealerRelationships = [SELECT Id, 
                                                                        clcommon__Related_Entity__c, 
                                                                        clcommon__Entity__c,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c 
                                                                    WHERE clcommon__Entity__c IN :dealerIds
                                                                    AND clcommon__Relationship__r.Name = :ConstantValues.PAYMENT_ADMINISTRATOR_PARTY_NAME];
        for(clcommon__Relationship__c eachRelations : dealerRelationships) {
            dealerToPAMap.put(eachRelations.clcommon__Related_Entity__c, eachRelations.clcommon__Entity__c);
            accountList.add(eachRelations.clcommon__Related_Entity__c);
        }

        userMap = CFAOriginationHelperClass.getUserListFromAccountList(accountList);

        for (clcommon__Relationship__c eachRelations : dealerRelationships) {

            if (relationMap.containsKey(eachRelations.clcommon__Entity__c)) {
                // if the application id already present in the map
                relationMap.get(eachRelations.clcommon__Entity__c).add(eachRelations);
            } else {
                // if the application id is not present in the map
                relationMap.put(eachRelations.clcommon__Entity__c, new List<clcommon__Relationship__c>{eachRelations});
            }
        }

        for (Object key : relationMap.keySet()) {
            List<clcommon__Relationship__c> relations = relationMap.get(key);

            // loop through all the parties and create sharing record for them
            for (clcommon__Relationship__c eachRelation : relations) {

                if (userMap.containsKey(eachRelation.clcommon__Related_Entity__c)) {
                    // create application sharing records
                    AccountShare newAccShare = new AccountShare();

                    newAccShare.AccountAccessLevel = EDIT;
                    newAccShare.AccountId = dealerToPAMap.get(eachRelation.clcommon__Related_Entity__c);
                    newAccShare.UserOrGroupId = userMap.get(eachRelation.clcommon__Related_Entity__c);
                    newAccShare.OpportunityAccessLevel = 'None';

                    newAccShareList.add(newAccShare);
                }
            }
        }
        Database.upsert(newAccShareList, false);
    }

    /**
     * @description This method will return all payment administrator relationship account ids
     * @param dealerRelationships 
     * @return  `List<Id>`
     */
    private List<Id> getDealerRelationAccountId(List<clcommon__Relationship__c> dealerRelationships){
        List<Id> dealerRelationAccountIds = new List<Id>();
        for (clcommon__Relationship__c dealerRelationship : dealerRelationships) {     
            dealerRelationAccountIds.add(dealerRelationship.clcommon__Related_Entity__c);
        }
        return dealerRelationAccountIds;
    }

    /**
     * @description This method will return payment administrator relation, account, contact associate with dealer.
     * @param dealerRelationships 
     * @param paContactMap 
     * @return  `Map<Object, List<Map<String, Object>>>`
     */
    private Map<Object, List<Map<String, Object>>> getPaRelationMap(List<clcommon__Relationship__c> dealerRelationships,
                                                                        Map<Object, Contact> paContactMap){
        Map<Object, List<Map<String, Object>>> paRelationMap = new Map<Object, List<Map<String, Object>>>();

        for (clcommon__Relationship__c dealerRelationship : dealerRelationships) {
                
            Map<String, Object> rel = new Map<String, Object>();                    
            if (paRelationMap.containsKey(dealerRelationship.clcommon__Entity__c)) {
                // if the dealer id is already present in the map
                rel.put(PARAM_DEALER_ID, dealerRelationship.clcommon__Entity__c);
                rel.put(PARAM_ACCOUNT_ID, dealerRelationship.clcommon__Related_Entity__c);
                rel.put(PARAM_CONTACT_ID, paContactMap.get(dealerRelationship.clcommon__Related_Entity__c).Id);
                rel.put(PARAM_TYPE, dealerRelationship.clcommon__Relationship__r.Name);

                paRelationMap.get(dealerRelationship.clcommon__Entity__c).add(rel);

            } else {
                // if the dealer id is not already present in the map
                rel.put(PARAM_DEALER_ID, dealerRelationship.clcommon__Entity__c);
                rel.put(PARAM_ACCOUNT_ID, dealerRelationship.clcommon__Related_Entity__c);
                rel.put(PARAM_CONTACT_ID, paContactMap.get(dealerRelationship.clcommon__Related_Entity__c).Id);
                rel.put(PARAM_TYPE, dealerRelationship.clcommon__Relationship__r.Name);

                paRelationMap.put(dealerRelationship.clcommon__Entity__c, new List<Map<String, Object>>{rel});
            }
        }

        return paRelationMap;
    }

    /**
     * @description This method will return all the list of payment administrator party associated with key application.
     * @param applicationsId 
     * @return  `Map<Object, List<clcommon__Party__c>>`
     */
    private Map<Object, List<clcommon__Party__c>> getPaPartyList(List<Id> applicationsId){

        List<clcommon__Party__c> relationParties = new List<clcommon__Party__c>();
        Map<Object, List<clcommon__Party__c>> paPartyMap = new Map<Object, List<clcommon__Party__c>>();

        if(applicationsId.isEmpty()){
            return paPartyMap;
        }
        relationParties = [SELECT Id, 
                                    clcommon__Account__c,
                                    clcommon__Contact__c,
                                    genesis__Application__c,
                                    clcommon__Type__r.Name 
                                FROM clcommon__Party__c 
                                WHERE clcommon__Type__r.Name = :ConstantValues.PAYMENT_ADMINISTRATOR_PARTY_NAME
                                AND genesis__Application__c IN :applicationsId
                                AND genesis__Application__r.Dealer_Name__c != NULL];

        for (clcommon__Party__c relationParty : relationParties) {

            if (paPartyMap.containsKey(relationParty.genesis__Application__c)) {
                // if the application id already present in the map
                paPartyMap.get(relationParty.genesis__Application__c).add(relationParty);
            } else {
                // if the application id is not present in the map
                paPartyMap.put(relationParty.genesis__Application__c, new List<clcommon__Party__c>{relationParty});
            }
        }   

        return paPartyMap;
    }

    /**
     * @description This method will return if current pa party and dealer pa party are same or not.
     * @param paPartyMap 
     * @param paRelationMap 
     * @param dealerApplication 
     * @return  `Boolean`
     */
    private Boolean hasCurrentPaPartyLess(Map<Object, List<clcommon__Party__c>> paPartyMap,
                                            Map<Object, List<Map<String, Object>>> paRelationMap,
                                            genesis__Applications__c dealerApplication){

        Integer currentPaPartyCount = 0;
        Integer dealerPaPartyCount = 0;

        if (paPartyMap.get(dealerApplication.Id) != null) {
            currentPaPartyCount = paPartyMap.get(dealerApplication.Id).size();
        }

        if (paRelationMap.get(dealerApplication.Dealer_Name__c) != null) {
            dealerPaPartyCount = paRelationMap.get(dealerApplication.Dealer_Name__c).size();
        }

        if (currentPaPartyCount < dealerPaPartyCount) {
            return false;
        }else{
            return true;
        }
    }

    /**
     * @description This method will return a set of existing Payment Administrator Parties.
     * @param paPartyMap 
     * @param dealerApplication 
     * @return  `Set<Object>`
     */
    private Set<Object> getExistingPaParties(Map<Object, List<clcommon__Party__c>> paPartyMap, 
                                                genesis__Applications__c dealerApplication){

        Set<Object> existingPas = new Set<Object>();

        if (paPartyMap.get(dealerApplication.Id) != null) {
            for (clcommon__Party__c existingParty : paPartyMap.get(dealerApplication.Id)) {
                existingPas.add(existingParty.clcommon__Account__c);
            }
        }

        return existingPas;
    }

    /**
     * @description This method will create party for specific dealer by calling the batch
     * @param paymentAdministratorId 
     */
    @InvocableMethod(label = 'Create PA Party' description = 'Create Payment Administrator Party For Specific Dealer')
    public static void createPaPartyForSpecificDealer(List<Id> paymentAdministratorId){
        List<Account> dealerAccount = [SELECT Id,
                                                ParentId
                                            FROM Account
                                            WHERE Id = :paymentAdministratorId[0]];

        CreatePaymentAdministratorPartyBatch cpap = new CreatePaymentAdministratorPartyBatch(dealerAccount[0].ParentId);
        Database.executeBatch(cpap, 20);     
    }
}