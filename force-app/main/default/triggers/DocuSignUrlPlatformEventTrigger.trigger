/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 05-10-2023
 * @last modified by  : Ayush Kumar Singh
**/
trigger DocuSignUrlPlatformEventTrigger on DocuSignPlatformEvent__e (after Insert) {

        DocusignPlatformEventTriggerHandler dSPlatformEventTriggerHandler;
        dSPlatformEventTriggerHandler = new DocusignPlatformEventTriggerHandler(Trigger.new);
    
}