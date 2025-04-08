/**
 * 
 * @author      Rahul Gupta
 * @description Used to schedule the end of month and end of year interest 
 *              from NLS for each loan
 * @created     30-09-2022
 * @updated     22-06-2023
 */

public with sharing class NLSGetLoanStatisticsCalloutSchedule implements Schedulable {
    
    /**
    * @description : Schedule NLSGetLoanStatisticsCallout Batch
    * @author  Pritam Roy | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {
        List<CFA_Configuration__c> errorLog = new List<CFA_Configuration__c>();
        if(Schema.sObjectType.CFA_Configuration__c.isAccessible()) {
            errorLog = [SELECT Id, 
                            GetLoanStatisticsCallout_Error_Log__c, 
                            GetLoanDetailsMonthlyCallout_Error_Log__c 
                        FROM CFA_Configuration__c 
                        LIMIT 1];
        }
        errorLog[0].GetLoanStatisticsCallout_Error_Log__c = '';
        errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c = '';
        if(Schema.sObjectType.CFA_Configuration__c.isUpdateable()) {
            Database.update(errorLog, true);
        }
        NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch();
        Database.executeBatch(obj, 20);
    }
}