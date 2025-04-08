/**
* @description       : This batch is used to delete SA Admin's party,sharing records
* @author            : Krishanu Chinya
* @group             :
* @last modified on  : 12-08-2023
* @last modified by  : Krishanu Chinya
**/
global without sharing class DeleteSalesAgentAdminPartyBatch implements Database.Batchable<sObject>{
    private static final String CLASS_NAME = DeleteSalesAgentAdminPartyBatch.class.getName();
 
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
    global DeleteSalesAgentAdminPartyBatch(List<String> selectedSalesAgentsList, Id saAdminAccId){
        this.saAccountIdList = selectedSalesAgentsList;
        this.saAdminAccId = saAdminAccId;
    }
 
    /**
     * @description :fetches all the required applications
     * @param context
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext context) {

        //first delete all existing parties
        return Database.getQueryLocator([SELECT Id,
                                                    Name,
                                                    clcommon__Account__c,
                                                    genesis__Application__c
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c = :saAdminAccId
                                                    AND genesis__Application__r.CreatedBy.AccountId != :saAdminAccId]);

    }
    
    /**
     * @description : deletes old party, sharing records and create new ones
     * @param context
     * @param reqPartyList
     */
    public void execute(Database.BatchableContext context, List<clcommon__Party__c> reqPartyList) {
        SavePoint dbSavePoint = Database.setSavepoint();
 
        try{ 
            //fetching the chosen sales agent admin user
            User saAdminUser = [SELECT Id,ContactId FROM User WHERE AccountId =:saAdminAccId];

            List<Id> appIdList = new List<Id>();

            for(clcommon__Party__c party : reqPartyList){
                appIdList.add(party.genesis__Application__c);
            }
 
            //delete application sharing records
            List<genesis__Applications__Share> appShareToDel = [SELECT Id,
                                                                    ParentId,
                                                                    UserOrGroupId
                                                                    FROM genesis__Applications__Share
                                                                    WHERE UserOrGroupId =: saAdminUser.Id
                                                                    AND Parent.CreatedBy.AccountId != :saAdminAccId
                                                                    AND ParentId IN :appIdList];
            Database.delete(appShareToDel, false);
 
            //delete document sharing records
            List<clcommon__Document_Category__Share> docCatShareToDel = [SELECT Id,
                                                                            ParentId,
                                                                            UserOrGroupId
                                                                            FROM clcommon__Document_Category__Share
                                                                            WHERE UserOrGroupId =: saAdminUser.Id
                                                                            AND Parent.genesis__Application__r.CreatedById != :saAdminUser.Id
                                                                            AND Parent.genesis__Application__c IN :appIdList];
            Database.delete(docCatShareToDel, false);

            //first delete all existing parties
            Database.delete(reqPartyList, true);
            
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
        CreateSalesAgentAdminPartyBatch batchObj = new CreateSalesAgentAdminPartyBatch(saAccountIdList, saAdminAccId);
        Database.executeBatch(batchObj, 20);
    }
 
}