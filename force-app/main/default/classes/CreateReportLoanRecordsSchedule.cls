/**
 * 
 * @author      Rahul Gupta
 * @description Used to schedule the end of month and end of year interest 
 *              from NLS for each loan
 * @created     01-11-2022
 * @updated     22-06-2023
 */

public with sharing class CreateReportLoanRecordsSchedule implements Schedulable {
    
    /**
    * @description Calls the batch class to create report loan records
    * @author Soumik Pattanayak | 08-10-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {

        CreateReportLoanRecordsBatch obj = new CreateReportLoanRecordsBatch();
        Database.executeBatch(obj, 50);
    }
}