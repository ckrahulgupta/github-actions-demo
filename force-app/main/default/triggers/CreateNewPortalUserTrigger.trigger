/**
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Ayush Kumar Singh
**/
trigger CreateNewPortalUserTrigger on New_Portal_User__e(after insert) {
    CreateNewPortalUserTriggerHandler.createNewUser(Trigger.New);
}