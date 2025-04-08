/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**/
public with sharing class DeleteIntegrationLogsJob implements Schedulable{
    /**
    * @description Calls the batch class to delete the Integration Logs
    * @author Soumik Pattanayak | 08-10-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {
        DeleteIntegrationLogBatch deleteLog = new DeleteIntegrationLogBatch(7);
        database.executeBatch(deleteLog,2000);
    }
}