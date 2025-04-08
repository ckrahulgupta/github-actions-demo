/**
 * Created by Muhammed Sargin, December 2022
 * Last Modified By Riadh Mankai, Sep 27 2023
 */
trigger PricingDetailTrigger on genesis__Application_Pricing_Detail__c (before update, before insert) {
	if (Trigger.isBefore && Trigger.isUpdate) {
		PricingDetailTriggerHandler.mapParentToChild(Trigger.old, Trigger.new);
	} else if (Trigger.isBefore && Trigger.isInsert) {
		PricingDetailTriggerHandler.mapParentToChild(null, Trigger.new);
	}
}