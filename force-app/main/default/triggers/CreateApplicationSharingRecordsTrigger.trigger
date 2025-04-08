/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-08-2023   Subham Nandi   Initial Version
**/
trigger CreateApplicationSharingRecordsTrigger on Sharing_Record__e (after insert) {
  //Sharing_Record__e objPlatformEvent = Trigger.New[0];
  String applicationId = Trigger.New[0].ApplicationId__c;
  String accountId = Trigger.New[0].UserAccountId__c;
  CreateApplicationSharingRecordHandler.handler(applicationId,accountId);
}