/**
 * @description       : Schedule class for EOM Email notification to CFA Core Grower
 * @author            : Simran
 * @group             : 
 * @last modified on  : 12-07-2023
 * @last modified by  : Simran
**/
public with sharing class ScheduleEOMEmailToCFAGrowerAPI implements Schedulable{
    
    /**
     * @description : This method is used execute the EOMEmailNotificationToCFAGrowerBatch
     * @param ctx
     */
    public void execute(SchedulableContext ctx){
        EOMEmailNotificationToCFAGrowerBatch eomEmailtoGrowerBatch = new EOMEmailNotificationToCFAGrowerBatch();
        Database.executeBatch(eomEmailtoGrowerBatch , Integer.valueOf(ConstantValues.EOM_EMAIL_NOTIFICATION_BATCH_SIZE));           
    }
}