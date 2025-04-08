/***************************************************************************************
 * Trigger Name       : DocuSignStatusTrigger
 * Developed By       : simranjha
 * Purpose            : This trigger is fire when there is any update on Envelope status.
 * @created Date      : 04-09-2022
 * @last modified on  : 11-16-2023
 * @last modified by  : Ayush Kumar Singh
 ****************************************************************************************/
trigger DocuSignRecipientStatusTrigger on dfsle__RecipientStatus__c(after insert) {
    DocuSignRecipientStatusTriggerHandler.updateDocusignRecipientStatus(Trigger.new);
}