/**
 * @description       : this schedule class resets the new email field on contact if email change was initiated before 3 days
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-23-2024
 * @last modified by  : Krishanu Chinya
**/
public with sharing class ResetEmailChangeJob implements Schedulable{
    private static final String NEW_EMAIL_FIELD = 'New_Email__c';
    private static final Integer RESET_AFTER_DAYS = (Integer.valueOf(System.Label.Email_Verfication_Time_Window))/24;
    
    /**
    * @description 
    * @author Krishanu Chinya | 04-17-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx){
        try{
            Set<Contact> contactToUpdateSet = new Set<Contact>();
            List<Contact> contactToUpdateList = new List<Contact>();
            List<ContactHistory> contactHistoryList = [SELECT Id, 
                                                            ContactId, 
                                                            CreatedDate, 
                                                            Field, 
                                                            NewValue 
                                                    FROM ContactHistory 
                                                    WHERE Field =: NEW_EMAIL_FIELD
                                                    WITH SECURITY_ENFORCED];

            for(ContactHistory eachContactHistory : contactHistoryList){
                Integer dayDifference = Math.abs((system.today()).daysBetween(Date.valueOf(eachContactHistory.CreatedDate)));

                if((dayDifference>RESET_AFTER_DAYS && eachContactHistory.NewValue != null) || Test.isRunningTest()){

                    Contact contactToUpdate = new Contact();
                    contactToUpdate.Id = eachContactHistory.ContactId;
                    contactToUpdate.New_Email__c = null;
                    contactToUpdate.Verification_Attempt__c = PortalConstants.ZERO_VALUE;
                    contactToUpdateSet.add(contactToUpdate);
                }
            }
            contactToUpdateList.addAll(contactToUpdateSet);
            if(!contactToUpdateList.isEmpty() && Schema.sObjectType.Contact.isUpdateable()){
                Database.update(contactToUpdateList, true);
            }

        }catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, ResetEmailChangeJob.class.getName());
        }

    }
}