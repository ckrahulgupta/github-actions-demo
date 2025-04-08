/**
* @description       : This batch is used to create and delete SA Admin's party,sharing records
* @author            : Krishanu Chinya
* @group             :
* @last modified on  : 12-08-2023
* @last modified by  : Krishanu Chinya
**/
global without sharing class CreateSalesAgentAdminPartyBatch implements Database.Batchable<sObject>{
    private static final String CLASS_NAME = CreateSalesAgentAdminPartyBatch.class.getName();
 
    //global variables for the class
 
    //stores all the selected sales agent's account id
    List<Id> saAccountIdList = new List<Id>();
    //stores the account of the sales agent admin
    String saAdminAccId;
 
    /**
     * @description : constructor to set the saAccountIdList and saAdminAccId
     * @param selectedSalesAgentsList
     * @param saAdminAccId
     */
    global CreateSalesAgentAdminPartyBatch(List<String> selectedSalesAgentsList, Id saAdminAccId){
        this.saAccountIdList = selectedSalesAgentsList;
        this.saAdminAccId = saAdminAccId;
    }
 
    /**
     * @description :fetches all the required applications
     * @param context
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        List<clcommon__Relationship__c> isSAARelated = [SELECT Id,
                                                            Name,
                                                            clcommon__Entity__c,
                                                            clcommon__Relationship__r.Name
                                                            FROM clcommon__Relationship__c
                                                            WHERE clcommon__Entity__c =:saAdminAccId
                                                            AND clcommon__Relationship__r.Name =:PortalConstants.RELATED_SALES_AGENT];
        
        //if any SA is assigned to the SAA, fetch those app
        if(isSAARelated.size()>0){
            return Database.getQueryLocator([SELECT Name,
                                                    Id,
                                                    Sales_Agent__c
                                                    FROM genesis__Applications__c
                                                    WHERE (Sales_Agent__c
                                                    IN :saAccountIdList OR CreatedBy.AccountId IN :saAccountIdList)
                                                    AND CreatedBy.AccountId != :saAdminAccId]);
        }
        //else fetch all app where SAA have party but not created by by that SAA
        else {
            return Database.getQueryLocator([SELECT Id,
                                                    Name,
                                                    CreatedById
                                                    FROM genesis__Applications__c
                                                    WHERE Id
                                                    IN (SELECT genesis__Application__c
                                                        FROM clcommon__Party__c
                                                        WHERE clcommon__Account__c =: saAdminAccId)
                                                    AND CreatedBy.AccountId !=:saAdminAccId]);
        }
    }
    
    /**
     * @description : deletes old party, sharing records and create new ones
     * @param context
     * @param reqApplicationsList
     */
    public void execute(Database.BatchableContext context, List<genesis__Applications__c> reqApplicationsList) {
        SavePoint dbSavePoint = Database.setSavepoint();
 
        try{
            Map<String, Id> partyTypeMap = PortalHelper.getPartyTypeMap();
 
            //fetching the chosen sales agent admin user
            User saAdminUser = [SELECT Id,ContactId FROM User WHERE AccountId =:saAdminAccId];
 
            //if any new SA is assigned, then only create new party and sharing records
            if(saAccountIdList.size()>0){
                List<clcommon__Party__c> objPartyList = new List<clcommon__Party__c>();
                List<genesis__Applications__Share> appSharingRecList = new List<genesis__Applications__Share>();
                List<clcommon__Document_Category__Share> documentSharingRecordList = new List<clcommon__Document_Category__Share>();
 
                List<clcommon__Party__c> checkIfPartyExistList = new List<clcommon__Party__c>();
                checkIfPartyExistList = [SELECT Id,
                                            clcommon__Account__c,
                                            genesis__Application__c
                                            FROM clcommon__Party__c 
                                            WHERE clcommon__Account__c =:saAdminAccId 
                                            AND genesis__Application__c IN :reqApplicationsList];
                Map<Id, clcommon__Party__c> checkIfPartyExistMap = new Map<Id, clcommon__Party__c>();
                
                for(clcommon__Party__c party : checkIfPartyExistList){
                    if(!checkIfPartyExistMap.containsKey(party.genesis__Application__c)){
                        checkIfPartyExistMap.put(party.genesis__Application__c, party);
                    }
                }
                
                //looping through all the applications
                for(genesis__Applications__c app : reqApplicationsList){                    
                    if(!checkIfPartyExistMap.containsKey(app.Id)){
                        //creating party
                        clcommon__Party__c objSAParty = new clcommon__Party__c();
                        objSAParty.genesis__Application__c = app.Id;
                        objSAParty.clcommon__Account__c = saAdminAccId;
                        objSAParty.clcommon__Contact__c = saAdminUser.ContactId;
                        objSAParty.clcommon__Type__c = partyTypeMap.get(PortalConstants.SALES_AGENT_ADMIN_PARTY);
                        objSAParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
                        objPartyList.add(objSAParty);
    
                        //creating application sharing records
                        genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();
                        applicationSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                        applicationSharingRecord.ParentId = app.Id;
                        applicationSharingRecord.UserOrGroupId = saAdminUser.Id;
                        appSharingRecList.add(applicationSharingRecord);
                    }
                }
 
                //fetching all doc sharing records of the selected applications
                List<clcommon__Document_Category__c> documentCategoryList = [SELECT Id
                                                                                FROM clcommon__Document_Category__c
                                                                                WHERE genesis__Application__c IN :reqApplicationsList];
 
 
                //creating doc sharing rec for each doc catagory
                for (clcommon__Document_Category__c documentCategory : documentCategoryList) {
                    clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
                    documentSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                    documentSharingRecord.ParentId = documentCategory.Id;
                    documentSharingRecord.UserOrGroupId = saAdminUser.Id;
                    documentSharingRecordList.add(documentSharingRecord);
                }  
                
                Database.upsert(documentSharingRecordList, false);
                Database.upsert(objPartyList, true);
                Database.upsert(appSharingRecList, false);
            }
        }catch (Exception objException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        
    }
    
    /**
     * @description
     * @param context
     */
    public void finish(Database.BatchableContext context) { 
       
    }
 
}