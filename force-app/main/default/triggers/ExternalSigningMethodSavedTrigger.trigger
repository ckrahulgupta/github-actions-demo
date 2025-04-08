/**
 * @description       : This trigger was used to save the signing method for an external API.
 *                      This trigger is now deprecated because the signing method is saved through the ExternalSaveSigningMethodAPI.
 *                      There is no need to publish the ExternalSigningMethodSaved__e platform event to save the signing method
 *                      Since we are using a flow to generate the Credit Agreement Document.
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Suraj Kumar
 * @deprecated
**/
trigger ExternalSigningMethodSavedTrigger on ExternalSigningMethodSaved__e (after insert) {
    // ExternalSigningMethodSavedTriggerHandler.saveSigningMethod(Trigger.new);
}