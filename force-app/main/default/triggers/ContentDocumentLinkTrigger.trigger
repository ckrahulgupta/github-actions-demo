/***************************************************************************************
 * Trigger Name       : ContentDocumentLinkTrigger
 * Developed By       : simranjha
 * Purpose            : This trigger is fire when any content document link is created
 * @created Date      : 04-01-2022
 * @last modified on  : 08-23-2023
 * @last modified by  : Suraj Kumar
 ***************************************************************************************/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,before insert) {
    if(Trigger.isBefore){
        ContentDocumentLinkTriggerHandler.beforeInsert(trigger.new);
    }
    if(Trigger.isAfter){
        ContentDocumentLinkTriggerHandler.afterInsert(trigger.new);
    }
}