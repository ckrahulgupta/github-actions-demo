/**
 * 
 * @author      Rahul Gupta
 * @description Used to schedule the end of month and end of year interest 
 *              from NLS for each loan
 * @created     25-10-2022
 * @updated     12-06-2023
 */
public with sharing class NLSGetLoanDetailsMonthlySchedule implements Schedulable {
    /**
    * @description : Schedule NLSGetLoanDetailsMonthlyCallout Batch
    * @author  Pritam Roy | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {

        NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch();
        Database.executeBatch(obj, 20);
    }
}