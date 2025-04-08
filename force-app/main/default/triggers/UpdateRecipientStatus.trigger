/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 11-16-2023
 * @last modified by  : Ayush Kumar Singh
**/
trigger UpdateRecipientStatus on dfsle__RecipientStatus__c (after insert) {
    UpdateRecipientStatusTriggerHandler.updateDocusignRecipientStatus(Trigger.new);
}