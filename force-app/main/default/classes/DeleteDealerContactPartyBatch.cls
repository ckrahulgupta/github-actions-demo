/**
 * @description       : Batch class to delete party,doc and application sharing records
 * @author            : Simran
 * @group             : 
 * @last modified on  : 04-10-2024
 * @last modified by  : Ayan Bhowmik
**/
public with sharing class DeleteDealerContactPartyBatch implements Database.Batchable<SObject> , Database.Stateful{

    private String accountId;
    private String previousDealer;
    private List<String> previousRecordTypeName;
    private List<Id> objEntityId= new List<Id>();
    private Map<String,Object> recordDetailMap = new Map<String,Object>();

    /**
     * @description Constructor that assign dealer Id,accountId,recordTypeName
     * @param recordDetailsMap 
     */
    public DeleteDealerContactPartyBatch(Map<String, Object> recordDetailsMap){
        this.recordDetailMap.putAll(recordDetailsMap);
        this.accountId=(String)recordDetailsMap.get(ConstantValues.DEALER_CONTACT_ID);
        this.previousDealer=(String)recordDetailsMap.get(ConstantValues.PREVIOUS_DEALER_ID);
        this.previousRecordTypeName=(List<String>)recordDetailsMap.get(ConstantValues.PREVIOUS_RECORD_TYPE_NAME);
    }

    /**
     * @description This start method will query all the applications.
    * @param batchableContext 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        if(previousRecordTypeName.contains(ConstantValues.FIELD_STAFF_AGENT)) {
            return Database.getQueryLocator([SELECT Id,
                                                    Name,
                                                    clcommon__Account__c,
                                                    genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE clcommon__Account__c = :accountId
                                                AND clcommon__Party_Types__c IN :previousRecordTypeName]);

        } else if(previousRecordTypeName.contains(ConstantValues.SALES_AGENT)
                        || previousRecordTypeName.contains(ConstantValues.SALES_AGENT)) {
            List<Id> saAdminRelationship = (List<id>)recordDetailMap.get(ConstantValues.SALES_AGENT_ADMIN_RELATIONSHIP);
            return Database.getQueryLocator([SELECT Id,
                                                    Name,
                                                    clcommon__Account__c,
                                                    genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE (clcommon__Account__c IN :saAdminRelationship
                                                        AND genesis__Application__r.Sales_Agent__c =: accountId
                                                        AND clcommon__Party_Types__c =: ConstantValues.SALES_AGENT_ADMIN
                                                        AND genesis__Application__r.Dealer_Name__c = :previousDealer)
                                                OR (clcommon__Account__c =: accountId
                                                    AND clcommon__Party_Types__c IN :previousRecordTypeName
                                                    AND genesis__Application__r.Dealer_Name__c = :previousDealer)]);

        } else {
            return Database.getQueryLocator([SELECT Id,
                                                    Name,
                                                    clcommon__Account__c,
                                                    genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE clcommon__Account__c =: accountId
                                                AND clcommon__Party_Types__c IN :previousRecordTypeName
                                                AND genesis__Application__r.Dealer_Name__c = :previousDealer]);
        }
    }

    /**
    * @description : This execute method will delete party, doc and app sharimg record
    * @author Simran | 01-30-2024 
    * @param batchableContext 
    * @param deletePartyList 
    **/
    public void execute(Database.BatchableContext batchableContext, List<clcommon__Party__c> deletePartyList){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            //fetching the user of choosen account
            User objUser = [SELECT Id,ContactId FROM User WHERE AccountId =:accountId];
            List<Id> appIdList = new List<Id>();
            for(clcommon__Party__c party : deletePartyList){
                appIdList.add(party.genesis__Application__c);
            }
            List<genesis__Applications__c> objAppRecords = [SELECT Id,
                                                                    Name,
                                                                    Dealer_Name__c,
                                                                    Certified_Lender__c,
                                                                    Sales_Agent__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE ID IN :appIdList 
                                                                AND (Certified_Lender__c =: accountId 
                                                                OR Sales_Agent__c =: accountId)];
            if(!objAppRecords.isEmpty()){
                Id newClId = null;
                List<clcommon__Relationship__c> dealerRelationshipList = [SELECT Id,
                                                                                clcommon__Related_Entity__c 
                                                                            FROM clcommon__Relationship__c 
                                                                            WHERE clcommon__Entity__c =: previousDealer
                                                                            AND (clcommon__Entity_Role__c =: ConstantValues.CERTIFIED_LENDER 
                                                                                OR clcommon__Entity_Role__c =: ConstantValues.CERTIFIED_LENDER_PLUS)
                                                                            AND clcommon__Related_Entity__c !=: accountId
                                                                            LIMIT 1];       
                if(!dealerRelationshipList.isEmpty()){    
                    newClId = dealerRelationshipList[ConstantValues.ZERO_VALUE].clcommon__Related_Entity__c;
                }                   
                for(genesis__Applications__c app : objAppRecords){
                    if(app.Certified_Lender__c == accountId){
                        app.Certified_Lender__c = newClId;
                    }
                    if(app.Sales_Agent__c == accountId){
                        app.Sales_Agent__c = null;
                    }
                }
                Database.update(objAppRecords, true);
            }
            List<genesis__Applications__Share> appShareToDeleteList = [SELECT Id,
                                                                            ParentId,
                                                                            UserOrGroupId
                                                                        FROM genesis__Applications__Share
                                                                        WHERE UserOrGroupId =: objUser.Id
                                                                        AND ParentId IN :appIdList];
 
            List<clcommon__Document_Category__Share> docCatShareToDeleteList = [SELECT Id,
                                                                                    ParentId,
                                                                                    UserOrGroupId
                                                                                FROM clcommon__Document_Category__Share
                                                                                WHERE UserOrGroupId =: objUser.Id
                                                                                AND Parent.genesis__Application__c IN :appIdList];
            //delete document sharing records
            Database.delete(docCatShareToDeleteList, false);
            //delete application sharing records
            Database.delete(appShareToDeleteList, false);
            //delete all existing parties
            Database.delete(deletePartyList, true);
        }
        catch (Exception objException){
            Database.rollback(dbSavePoint);
            LoggingUtility.saveExceptionLogging(objException, DeleteDealerContactPartyBatch.class.getName());
        }
    }

    /**
     * @description this method is used to delete the existing relationship and created the dummy relationship record for future use
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            if((Boolean)recordDetailMap.get(ConstantValues.UPDATE_RECORD) == true){
                createPartyBatch(recordDetailMap);
            }
        }
        catch (Exception objException){
            Database.rollback(dbSavePoint);
            LoggingUtility.saveExceptionLogging(objException, DeleteDealerContactPartyBatch.class.getName());
        }
    }
    /**
    * @description This method is used to call the CreateDealerContactPartyBatch
    * @author Simran | 02-14-2024 
    * @param dealerContactRecordMap 
    **/
   public static void createPartyBatch(Map<String, Object> dealerContactRecordMap){
        String newRecordType = CFAOriginationHelperClass.getRecordType((List<String>)dealerContactRecordMap.get(ConstantValues.RECORD_TYPE_NAME));
        if(!String.isBlank(newRecordType) && newRecordType != null){
            dealerContactRecordMap.put(ConstantValues.RECORD_TYPE_NAME, newRecordType);
            CreateDealerContactPartyBatch createDealerContactParty = new CreateDealerContactPartyBatch(dealerContactRecordMap);
            Database.executeBatch(createDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));   
        }
    }
}