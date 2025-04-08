/**
 * @description       : Fire email when Reserve amount is updated..
 * @author            : Simran
 * @group             : 
 * @last modified on  : 04-16-2024
 * @last modified by  : Simran
**/
trigger ReserveAmountTrigger on genesis__Applications__c (after update) {
    ReserveAmountTriggerHandler.sendReserveAmountEmail(trigger.new,trigger.old);
}