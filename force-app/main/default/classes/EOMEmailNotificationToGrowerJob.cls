/**
 * @description       : Schedule class for EOM Email notification to CFA Core Grower
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class EOMEmailNotificationToGrowerJob implements Schedulable{
    /**
     * @description : This method is used execute the EOMEmailNotificationToGrowerBatch
     * @param ctx
     */
    public void execute(SchedulableContext ctx){
        EOMEmailNotificationToGrowerBatch eomEmailtoGrowerBatch = new EOMEmailNotificationToGrowerBatch();
        Database.executeBatch(eomEmailtoGrowerBatch , Integer.valueOf(ConstantValues.EOM_EMAIL_NOTIFICATION_BATCH_SIZE));           
    }
}