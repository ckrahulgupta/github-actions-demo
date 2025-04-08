/*************************************************************************************
* @description       : Purpose of this class is to support the chooseSalesAgents LWC Component
* @author            : Krishanu Chinya
* @group             :
* @last modified on  : 12-08-2023
* @last modified by  : Krishanu Chinya
***************************************************************************************/
 
public with sharing class SalesAgentAssignmentHandler {
 
    /**
     * @description : this method fetches all the SA of a dealer and whether they have an existing relationship with the sales agent admin
     * @param accId
     * @return  `AccountWrapper`
     */
    @AuraEnabled(cacheable=true)
    public static AccountWrapper fetchSADetails(Id accId){
 
        Account acc = [SELECT Id,Name,ParentId FROM Account WHERE Id =:accId WITH SECURITY_ENFORCED];
        String dealerId = acc.ParentId;
        List<Account> allSAList = [SELECT Id, 
                                    Name 
                                    FROM Account 
                                    WHERE ParentId =: dealerId 
                                    AND (RecordType.Name =: PortalConstants.SALES_AGENT 
                                    OR RecordType.Name =: PortalConstants.SALES_AGENT_PLUS )
                                    WITH SECURITY_ENFORCED];
 
        //List<Object> resultList = new List<Object>();
        AccountWrapper res = new AccountWrapper();
        res.accVsIdMap = new Map<Id, Account>(allSAList);
        res.isRelatedMap = new Map<Id, Boolean>();
 
        List<clcommon__Relationship__c> hasRelation = [SELECT Id,
                                                            clcommon__Related_Entity__c
                                                            FROM clcommon__Relationship__c
                                                            WHERE clcommon__Entity__c =:accId
                                                                AND clcommon__Related_Entity__c IN :allSAList
                                                                AND clcommon__Relationship__r.Name =: PortalConstants.RELATED_SALES_AGENT
                                                                WITH SECURITY_ENFORCED];
 
        Map<Id, clcommon__Relationship__c> saHasRelationMap = new Map<Id, clcommon__Relationship__c> ();
 
        for(clcommon__Relationship__c rel:hasRelation) {
            saHasRelationMap.put(rel.clcommon__Related_Entity__c, rel);
        }
 
        for(Account acnt:allSAList) {
            Boolean related = false;
            if(saHasRelationMap.containsKey(acnt.Id)){
                related=true;
            }
                res.isRelatedMap.put(acnt.Id, related);
        }
        return res;
    }
 
    /**
     * @description
     * @param
     * @return
     */
    public class AccountWrapper{
        /**
         * @description : stores the id and the account object in a map
         */
        @AuraEnabled public Map<Id, Account> accVsIdMap {get; set;}
 
        /**
         * @description : stores the account Id and whether it has relation or not
         */
        @AuraEnabled public Map<Id, Boolean> isRelatedMap {get; set;}
    }
 
    /**
     * @description : this method updates relationship of the SA Admin and SA and calls a batch to create party, sharing records
     * @param selectedSalesAgentsList
     * @param saAdminAccId
     * @exception
     */
    @AuraEnabled
    public static void updateSAADetails(List<String> selectedSalesAgentsList,Id saAdminAccId){
        try {
 
            //Delete relationship of selected sales agents and the admin
            List<clcommon__Relationship__c> relToDelete = [SELECT Id,
                                                                clcommon__Entity__c,
                                                                clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Relationship__r.Name =: PortalConstants.RELATED_SALES_AGENT
                                                                AND clcommon__Entity__c=:saAdminAccId
                                                                WITH SECURITY_ENFORCED];
 
            if(Schema.sObjectType.clcommon__Relationship__c.isDeletable()){
                Database.delete(relToDelete, true);
            }
 
            //create relationship of selected sales agents and the admin
            List<clcommon__Relationship__c> relToCreate = new List<clcommon__Relationship__c>();
            clcommon__Reciprocal_Role__c clRoleObj = [SELECT Id,
                                                        Name
                                                        FROM clcommon__Reciprocal_Role__c
                                                        WHERE Name =: PortalConstants.RELATED_SALES_AGENT
                                                        WITH SECURITY_ENFORCED];
 
            for(Id saAccId:selectedSalesAgentsList){
                clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
                relationshipObj.clcommon__Relationship__c = clRoleObj.Id;
                relationshipObj.clcommon__Entity__c = saAdminAccId;
                relationshipObj.clcommon__Related_Entity__c = saAccId;
                relToCreate.add(relationshipObj);
            }
 
            if(Schema.sObjectType.clcommon__Relationship__c.isCreateable()){
                Database.insert(relToCreate, true);
            }
 
            DeleteSalesAgentAdminPartyBatch createSAAdminParty = new DeleteSalesAgentAdminPartyBatch(selectedSalesAgentsList, saAdminAccId);
            Database.executeBatch(createSAAdminParty , 20);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}