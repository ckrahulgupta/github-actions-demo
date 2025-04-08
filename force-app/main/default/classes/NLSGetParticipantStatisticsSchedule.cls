/**
 * @description       : Used to schedule the end of month and end of year interest 
 *                      from NLS for each loan.
 * @author            : Rahul Gupta
 * @created           : 30-09-2022
 * @last modified on  : 03-13-2024
 * @last modified by  : Tuhin Bhunia
**/

public with sharing class NLSGetParticipantStatisticsSchedule implements Schedulable {
    
    /**
     * * @author      Rahul Gupta
     * @description   Used to schedule the end of month and end of year interest
     *                from NLS for each loan
     * @param ctx 
     */
    public void execute(SchedulableContext ctx) {

        NLSGetParticipantStatisticsCalloutBatch obj = new NLSGetParticipantStatisticsCalloutBatch();
        Database.executeBatch(obj, 20);
    }
}