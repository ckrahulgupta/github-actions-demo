/**
 * 
 * @author      Rahul Gupta
 * @description Used to schedule the end of month and end of year interest 
 *              from NLS for each loan
 * @created     20-10-2022
 * @updated     22-06-2023
 */

public with sharing class NLSGetParticipantInterestBatchSchedule implements Schedulable {
    
    /**
    * @description : Schedule NLSGetParticipantInterestCallout Batch
    * @author  Pritam Roy | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {

        NLSGetParticipantInterestCalloutBatch obj = new NLSGetParticipantInterestCalloutBatch();
        Database.executeBatch(obj, 20);
    }
}