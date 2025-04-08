/**
 * @description       : Batch class to delete existing pre-printed applications and reset the flag to false
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 01-09-2025
 * @last modified by  : Ayan Khanra
**/

global with sharing class DeletePreprintedApplicationsBatch implements Database.Batchable<SObject> {
    
    /**
    * @description Fetching all the pre-printed applications
    * @author Ayan Bhowmik | 02-27-2024 
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator([SELECT Id, 
                                                Preprint_Application__c 
                                        FROM genesis__Applications__c 
                                        WHERE genesis__Status__c = :ConstantValues.ACTIVE
                                        AND Preprint_Application__c = true]);
    }

    /**
    * @description The purpose of the execute method is to delete pre-printed applications
    * @author Ayan Bhowmik | 02-27-2024 
    * @param batchableContext 
    * @param applicationToUpdateList 
    **/
    global void execute(Database.BatchableContext batchableContext, List<genesis__Applications__c> applicationToUpdateList) {
        try {
            List<String> contentDocumentIdList = new List<String>();
            List<String> applicationIdList = new List<String>();
            for (Integer instance = 0; instance < applicationToUpdateList.size(); ++instance) {
                applicationToUpdateList[instance].Preprint_Application__c = false;
                applicationIdList.add(applicationToUpdateList[instance].Id);
            }
            Database.update(applicationToUpdateList, true);
            PortalApplicationOriginationHelper.checkEmptyList(applicationIdList, ConstantValues.LIST_EMPTY_CHECK);
            List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId 
                                                                FROM ContentDocumentLink
                                                                WHERE LinkedEntityId IN :applicationIdList];

            for (ContentDocumentLink contentDocumentLinkObj : contentDocumentLinkList) {
                contentDocumentIdList.add(contentDocumentLinkObj.ContentDocumentId);
            }
            PortalApplicationOriginationHelper.checkEmptyList(contentDocumentIdList, ConstantValues.LIST_EMPTY_CHECK);
            List<ContentDocument> contentDocumentList = [SELECT Id 
                                                            FROM ContentDocument 
                                                            WHERE Id IN :contentDocumentIdList
                                                            AND Title = :ConstantValues.PRE_PRINTED];
            if(!contentDocumentList.isEmpty()){
                Database.delete(contentDocumentList, true);
            }
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.PRE_PRINTED_ERROR);
        }
    }
    /**
    * @description 
    * @author Ayan Bhowmik | 02-27-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        
    }
}